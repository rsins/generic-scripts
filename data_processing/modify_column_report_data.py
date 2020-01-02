#!/usr/bin/python
#***************************************************************************
# Author      : Ravi Kant Singh
# Description : Python script to modify a column value based on another column.
# Created     : 3 Jul 2018
# Modified    : 31 Dec 2019 - Added more functionality, 
#                             process all columns in one expression using '%'
#***************************************************************************

from collections import OrderedDict
import os, sys, getopt
import uuid, random
import getpass
import re


# --------------- Adding more information to functions ----------------
class FuncAttrs:
    def __init__(self, argCount, desc):
        self.argCount = argCount
        self.desc = desc

    def __call__(self, f):
        f.argCount = self.argCount
        f.desc = self.desc
        return f


# --------------- Evaluator Supporting Functions ----------------
class GetterSetter():
   @staticmethod
   @FuncAttrs(3, 'Get value from a given column name.')
   def OpGet(headers, values, col):
       if col in headers:
          idx = headers.index(col)
          return values[idx]
       return None

   @staticmethod
   @FuncAttrs(4, 'Set value for given column name.')
   def OpSet(headers, values, col, val):
       if col in headers:
          idx = headers.index(col)
          values[idx] = val
          return values
       return None


class Calculator():
   @staticmethod
   @FuncAttrs(2, 'Add two numbers or concat two strings.')
   def OpAdd(a, b):
      return a + b
   
   @staticmethod
   @FuncAttrs(2, 'Substract second number from first.')
   def OpSubstract(a, b):
      return a - b

   @staticmethod
   @FuncAttrs(2, 'Multiply two numbers.')
   def OpMultiply(a, b):
      return a * b
  
   @staticmethod
   @FuncAttrs(2, 'Divide first number with second number.')
   def OpDevide(a, b):
      return a / b


class Converter():
   @staticmethod
   @FuncAttrs(1, 'Convert to int type.')
   def FuncInt(a):
      return int(a)

   @staticmethod
   @FuncAttrs(1, 'Convert to float type.')
   def FuncFloat(a):
      return float(a)

   @staticmethod
   @FuncAttrs(1, 'Convert to string type.')
   def FuncStr(a):
      return str(a)

   @staticmethod
   @FuncAttrs(1, 'Trim whitespaces from string param.')
   def FuncTrim(a):
      return str(a).strip()


class ConditionChecker():
   @staticmethod
   @FuncAttrs(2, 'Boolean and operation.')
   def OpAnd(a, b):
      return (str(a) == 'True') and (str(b) == 'True')
  
   @staticmethod
   @FuncAttrs(2, 'Boolean or operation.')
   def OpOr(a, b):
      return (str(a) == 'True') or (str(b) == 'True')
  
   @staticmethod
   @FuncAttrs(2, 'Check if values are equal.')
   def OpEqual(a, b):
      return str(a) == str(b)
  
   @staticmethod
   @FuncAttrs(2, 'Check if values are not equal.')
   def OpNotEqual(a, b):
      return not str(a) == str(b)
  
   @staticmethod
   @FuncAttrs(2, 'Check if value for "a" matches regex expression "b".')
   def OpLike(a, b):
      pattern = re.compile(str(b))
      return not (pattern.match(str(a)) == None)
 

class Validator():
   @staticmethod
   @FuncAttrs(1, 'Check if value null or empty.')
   def FuncIsEmpty(a):
     return True if (not a) else (True if (len(str(a)) == 0) else False)
  

class Evaluator():
   # To store the mappping with "expression function" with tuple "( python function, number of arguments this function requires)"
   Operation  = {
                   "add"         : Calculator.OpAdd             ,
                   "substract"   : Calculator.OpSubstract       ,
                   "multiply"    : Calculator.OpMultiply        ,
                   "devide"      : Calculator.OpDevide          ,
                }
   Converters = {
                   "int"         : Converter.FuncInt            ,
                   "float"       : Converter.FuncFloat          ,
                   "str"         : Converter.FuncStr            ,
                   "trim"        : Converter.FuncTrim           ,
                }
   Condition  = {
                   "and"         : ConditionChecker.OpAnd       ,
                   "or"          : ConditionChecker.OpOr        ,
                   "equals"      : ConditionChecker.OpEqual     ,
                   "not_equals"  : ConditionChecker.OpNotEqual  ,
                   "like"        : ConditionChecker.OpLike      ,
                }
   Validators = {
                   "is_empty"    : Validator.FuncIsEmpty        ,
                }

   def __init__(self, headerColumns, colValues):
      self.headerColumns = headerColumns
      self.colValues = colValues

      # Store in this map all the keys and corresponding functions with number of arguments required
      self.evalKeyFunctionMap = dict()
      self.evalKeyFunctionMap["column"] = self.getValueForColumn
      self.evalKeyFunctionMap.update(Evaluator.Operation)
      self.evalKeyFunctionMap.update(Evaluator.Converters)
      self.evalKeyFunctionMap.update(Evaluator.Condition)
      self.evalKeyFunctionMap.update(Evaluator.Validators)

      self.regexStr = "[(]|[)][ ]*|[ ]*,[ ]*|[a-zA-Z0-9-_ .=]+"


   def showSyntax(self):
      import string
      padLen = len(max(self.evalKeyFunctionMap.keys(), key=len))
      for (func, funcDef) in sorted(self.evalKeyFunctionMap.items()):
         print('    ' + func.ljust(padLen, " ") 
                 + format(' (' + ",".join([string.ascii_lowercase[x] for x in range(getattr(funcDef, 'argCount', 0))]) + ") ", '<15') 
                 + getattr(funcDef, 'desc', ''))

   def getheaderColumns(self):
      return self.headerColumns

   def getColValues(self):
      return self.colValues

   @FuncAttrs(1, 'Get value for a given column name.')
   def getValueForColumn(self, col):
      return GetterSetter.OpGet(self.headerColumns, self.colValues, col)
         
   def setValueForColumn(self, col, value):
      GetterSetter.OpSet(self.headerColumns, self.colValues, col, value)
         
   def peek(self, stack):
       return stack[-1] if stack else None

   def apply_operator(self, evalFunctions, evalValues):
      func = evalFunctions.pop()
      funcDef = self.evalKeyFunctionMap[func]
      args = ["" for i in range(funcDef.argCount)]
      if len(evalValues) < funcDef.argCount:
         print('* Wrong Syntax - Function = ' + func + ', expected count of args = ' + str(funcDef.argCount) + ', found only ' + str(len(evalValues)) + ".")
         sys.exit(1)
      for i in range(funcDef.argCount):
         args[funcDef.argCount - i - 1] = evalValues.pop()
      if funcDef.argCount == 1:
          val = funcDef(args[0])
      elif funcDef.argCount == 2:
          val = funcDef(args[0], args[1])
      evalValues.append(val)

   # Using modified Shunting-yard algorithm
   # Reference: http://www.martinbroadhurst.com/shunting-yard-algorithm-in-python.html
   def evalExpr(self, expr_str):
      tokens = re.findall(self.regexStr, expr_str, re.I | re.M)

      evalValues = []
      evalFunctions = []
      lastTokenIsFunction = False
      for token in tokens:
         tokenStripped = token.strip()
         if tokenStripped == "(":
            if not lastTokenIsFunction:
               print('* Wrong syntax - "' + str(self.peek(evalValues).strip() if self.peek(evalValues) else "") + '" is not a function.')
               sys.exit(1)
            evalFunctions.append(tokenStripped)
         elif tokenStripped ==")":
            top = self.peek(evalFunctions)
            while top is not None and top != "(":
               self.apply_operator(evalFunctions, evalValues)
               top = self.peek(evalFunctions)
            evalFunctions.pop() # Discard the "("
         else:
            # Operator
            top = self.peek(evalFunctions)
            while top is not None and top.strip() not in "(,)":
               self.apply_operator(evalFunctions, evalValues)
               top = self.peek(evalFunctions)
            if tokenStripped.lower() in self.evalKeyFunctionMap.keys():
               lastTokenIsFunction = True
               evalFunctions.append(tokenStripped.lower())
            else:
               lastTokenIsFunction = False
               if not tokenStripped == ",":
                  evalValues.append(token)
      while self.peek(evalFunctions) is not None:
         self.apply_operator(evalFunctions, evalValues)

      return evalValues[0]

# --------------- Evaluator Functions END -------------------------


# --------------- Global Constant Values --------------------------
class globalConstants():
   ALL_COLUMNS_IN_EXPR = '%'                         # This indicates that expression needs to be applied for all columns.
                                                     # This standalone in expression does not mean anything unless column name also has it.
   SHOW_PROGRESS_EVERY_RECORD_NUM_PERCENTAGE = 10    # Print progress information every time this % of records processed for output file
   DATA_COL_SEPARATOR = "\x07"                       # Column separator char in the input/output file
   # Default eval expressions to be used
   DEFAULT_EVAL_EXPR_LIST = [
                              ( "%", "is_empty(column(%))", "str(null)" )
                            ]
   # Ex.                      ( "CASE_TYPE", "equals(column(COL1), str(dummy))", "str(Internal)" )


# ---------------- Global Variables --------------------------------
class globalVars():
   recordUpdateCount                = 0       # int  - indicates how many records were changes
   valueUpdateCount                 = 0       # int  - indicates how many time value for columns were changes
   doNotWaitForUserInput            = False   # bool - Wait for user to press enter after printing argument details.
   reference_file                   = None    # text - input data file for reference
   output_file                      = None    # text - output data file name/path
   eval_expr_file_name              = None    # text - file name which to be used to read eval scripts
   eval_expr_list                   = None    # List of eval expressions to be used
   data_col_separator               = globalConstants.DATA_COL_SEPARATOR 
                                              # data column separator char (for CSV it is ',' and for data file it is '\x007')


# Main Logic is in this function
def main(argv):

   # Check script arguments
   checkScriptArguments(argv)

   createEvalExprList()

   # Confirm with user and wait for user input to continue.
   userConfirmation()

   # Start with creating the data file.
   generateOutputFile(globalVars.reference_file,                       \
                      globalVars.output_file,                          \
                      globalVars.eval_expr_list,                       \
                      globalVars.data_col_separator                    \
                     )


def createEvalExprList():
   if not globalVars.eval_expr_list and not globalVars.eval_expr_file_name:
      globalVars.eval_expr_list = globalConstants.DEFAULT_EVAL_EXPR_LIST
   elif not globalVars.eval_expr_list and globalVars.eval_expr_file_name:
      globalVars.eval_expr_list = list()

      try:
         exprFile = open(globalVars.eval_expr_file_name, 'r')
      except:
         print('Error while reading eval expr file: ' + globalVars.eval_expr_file_name)
         sys.exit(1)

      for line in exprFile:
         globalVars.eval_expr_list.append(splitExprRowFromLine(line))


def splitExprRowFromLine(line):
   tokenPositions = [m.start() for m in re.finditer('"|\'', line)]

   if len(tokenPositions) < 6:
      print('Cannot convert to correct eval expressions - "' + line + '"')
      sys.exit(1)
   return (line[tokenPositions[0]+1 : tokenPositions[1]],   \
           line[tokenPositions[2]+1 : tokenPositions[3]],   \
           line[tokenPositions[4]+1 : tokenPositions[5]])


def checkScriptArguments(argv):
   try:
      opts, args = getopt.getopt(argv, "hci:o:e:E:d:")
   except getopt.GetoptError as err:
      print(str(err))
      printUsage()
      sys.exit(1)

   for opt, arg in opts:
      if opt =='-h':
         printUsage()
         sys.exit()
      elif opt == "-c":
         globalVars.doNotWaitForUserInput = True
      elif opt == "-i":
         globalVars.reference_file = str(arg)
      elif opt == "-e":
         globalVars.eval_expr_list = [ splitExprRowFromLine(str(arg)) ]
      elif opt == "-E":
         globalVars.eval_expr_file_name = str(arg)
      elif opt == "-o":
         globalVars.output_file = str(arg)
      elif opt == "-d":
         globalVars.data_col_separator = str(arg)

   if globalVars.reference_file == None or globalVars.output_file == None:
      printUsage()
      sys.exit(1)

   if os.path.abspath(globalVars.reference_file) == os.path.abspath(globalVars.output_file):
      print('Both input file and output files cannot be same -> ' + globalVars.reference_file)
      sys.exit(1)


def userConfirmation():
   try:
      inFileSizeStr  = str(sum(1 for line in open(globalVars.reference_file))-1)
   except:
      print('Error while reading input file: ' + globalVars.reference_file)
      sys.exit(1)
   print('\n---------------------------------------------------')
   print(' Input reference data file = ' + globalVars.reference_file)
   print(' Output data file name     = ' + globalVars.output_file)
   print(' Data Column Separator     = ' + '"' + globalVars.data_col_separator.encode('string_escape') + '"')
   print(' Input record size         = ' + inFileSizeStr)
   if globalVars.eval_expr_file_name:
      print(' Eval Expr File Name       = ' + globalVars.eval_expr_file_name)
   print(' Evaluation Expression     = [\n    ' + ",\n    ".join([str(e) for e in globalVars.eval_expr_list[:10]]))
   if len(globalVars.eval_expr_list) > 10:
      print('    . . . . .\n    . ' + str(len(globalVars.eval_expr_list) - 10) + ' more conditions \n    . . . . .')
   print(']')
   print('---------------------------------------------------')
   print(' ')

   if globalVars.doNotWaitForUserInput == True:
      print('Continuing with file processing.')
      print(' ')
      return

   try:
      getpass.getpass("Press enter to continue...")
      print(' ')
   except KeyboardInterrupt:
      print('\nScript Interrupted.')
      sys.exit(1)


def printAuthor():
    art = ''
    art +=b'\n  \x1b[0;1;34;94m\xe2\x96\x91\xe2\x96\x88\xe2\x96\x80\xe2\x96\x84\xe2\x96\x91\xe2\x96\x88\xe2\x96\x80\xe2\x96\x88\xe2\x96\x91\xe2\x96\x88\xe2\x96\x91\xe2\x96\x88\xe2\x96\x91\xe2\x96\x80\xe2\x96\x88\xe2\x96\x80\x1b[0;34m\xe2\x96\x91\xe2\x96\x91\xe2\x96\x91\xe2\x96\x88\xe2\x96\x91\xe2\x96\x88\xe2\x96\x91\xe2\x96\x88\xe2\x96\x80\xe2\x96\x88\xe2\x96\x91\xe2\x96\x88\xe2\x96\x80\xe2\x96\x88\xe2\x96\x91\xe2\x96\x80\x1b[0;37m\xe2\x96\x88\xe2\x96\x80\xe2\x96\x91\xe2\x96\x91\xe2\x96\x91\xe2\x96\x88\xe2\x96\x80\xe2\x96\x80\xe2\x96\x91\xe2\x96\x80\xe2\x96\x88\xe2\x96\x80\xe2\x96\x91\xe2\x96\x88\xe2\x96\x80\xe2\x96\x88\x1b[0;1;30;90m\xe2\x96\x91\xe2\x96\x88\xe2\x96\x80\xe2\x96\x80\xe2\x96\x91\xe2\x96\x88\xe2\x96\x91\xe2\x96\x88\x1b[0m'.decode('utf-8')
    art +=b'\n  \x1b[0;1;34;94m\xe2\x96\x91\xe2\x96\x88\xe2\x96\x80\xe2\x96\x84\xe2\x96\x91\xe2\x96\x88\xe2\x96\x80\xe2\x96\x88\x1b[0;34m\xe2\x96\x91\xe2\x96\x80\xe2\x96\x84\xe2\x96\x80\xe2\x96\x91\xe2\x96\x91\xe2\x96\x88\xe2\x96\x91\xe2\x96\x91\xe2\x96\x91\xe2\x96\x91\xe2\x96\x88\xe2\x96\x80\xe2\x96\x84\xe2\x96\x91\xe2\x96\x88\x1b[0;37m\xe2\x96\x80\xe2\x96\x88\xe2\x96\x91\xe2\x96\x88\xe2\x96\x91\xe2\x96\x88\xe2\x96\x91\xe2\x96\x91\xe2\x96\x88\xe2\x96\x91\xe2\x96\x91\xe2\x96\x91\xe2\x96\x91\xe2\x96\x80\xe2\x96\x80\xe2\x96\x88\x1b[0;1;30;90m\xe2\x96\x91\xe2\x96\x91\xe2\x96\x88\xe2\x96\x91\xe2\x96\x91\xe2\x96\x88\xe2\x96\x91\xe2\x96\x88\xe2\x96\x91\xe2\x96\x88\xe2\x96\x91\xe2\x96\x88\xe2\x96\x91\xe2\x96\x88\xe2\x96\x80\xe2\x96\x88\x1b[0m'.decode('utf-8')
    art +=b'\n  \x1b[0;34m\xe2\x96\x91\xe2\x96\x80\xe2\x96\x91\xe2\x96\x80\xe2\x96\x91\xe2\x96\x80\xe2\x96\x91\xe2\x96\x80\xe2\x96\x91\xe2\x96\x91\xe2\x96\x80\xe2\x96\x91\xe2\x96\x91\xe2\x96\x80\xe2\x96\x80\xe2\x96\x80\x1b[0;37m\xe2\x96\x91\xe2\x96\x91\xe2\x96\x91\xe2\x96\x80\xe2\x96\x91\xe2\x96\x80\xe2\x96\x91\xe2\x96\x80\xe2\x96\x91\xe2\x96\x80\xe2\x96\x91\xe2\x96\x80\xe2\x96\x91\xe2\x96\x80\xe2\x96\x91\xe2\x96\x91\x1b[0;1;30;90m\xe2\x96\x80\xe2\x96\x91\xe2\x96\x91\xe2\x96\x91\xe2\x96\x91\xe2\x96\x80\xe2\x96\x80\xe2\x96\x80\xe2\x96\x91\xe2\x96\x80\xe2\x96\x80\xe2\x96\x80\xe2\x96\x91\xe2\x96\x80\xe2\x96\x91\xe2\x96\x80\x1b[0;1;34;94m\xe2\x96\x91\xe2\x96\x80\xe2\x96\x80\xe2\x96\x80\xe2\x96\x91\xe2\x96\x80\xe2\x96\x91\xe2\x96\x80\x1b[0m'.decode('utf-8')
    art +='\n'
    print(art)


def printUsage():
   printAuthor()
   print('Usage: ' + str(sys.argv[0]) + ' [ -h | -i reference_file | -o output data file | -e <eval expression> | -E eval expr file name | -c ]')
   print('       -h  show this help and exit')
   print('       -i  reference_file to be used for generating sample data file')
   print('       -o  output data file name')
   print('       -d  input data/column separator')
   print('       -e  use single eval expression from command line for value modification')
   print('           Format for eval expr is - "column to update", "<if condition which should be satisfied>", "value to be updated to column"')
   print('                                       |                    |                                          |')
   print('                  _____________________|                    |                                          |')
   print('                 |                                          |                                          |')
   print('                 |              ____________________________|                                        __|')
   print('                 |             |                                                                    |    ')
   print('                 |             |                                                                    |    ')
   print('           e.g. "CASE_TYPE", "equal(col(COL1), str(dummy))"                                     , "str(Internal)"')
   print('           e.g. "%"        , "is_empty(column(%))"                                              , "str(null)"')
   print('       -E  read the evaluation script from file, please see -e for eval expr format')
   print('       -c  continue without user confirmation (non-interactive mode)')
   print('\nFollowing syntax available for expressions. Please see "globalVars.eval_expr_list".')
   Evaluator(None, None).showSyntax()


# Perform transformation based in expression on the current record
def transformValues(headerColumns, values, eval_expr):
   isValueUpdated = False
   (colName, conditionCheckExpr, valueEvalExpr) = eval_expr
   evaluator = Evaluator(headerColumns, values)
   # Check if expression needs to be applied to all columns
   if colName == globalConstants.ALL_COLUMNS_IN_EXPR:
       for oneColName in headerColumns:
           oneConditionCheckExpr = conditionCheckExpr.replace(globalConstants.ALL_COLUMNS_IN_EXPR, oneColName)
           oneValueEvalExpr = valueEvalExpr.replace(globalConstants.ALL_COLUMNS_IN_EXPR, oneColName)
           isOneValueUpdated = transformValues(headerColumns, values, (oneColName, oneConditionCheckExpr, oneValueEvalExpr))
           isValueUpdated = isValueUpdated or isOneValueUpdated
   else:
      # If expression needs to be applied to single column
       valCondition = evaluator.evalExpr(conditionCheckExpr)
       if valCondition == True:
           val = evaluator.evalExpr(valueEvalExpr)
           evaluator.setValueForColumn(colName, val)
           globalVars.valueUpdateCount += 1
           isValueUpdated = True
   return isValueUpdated


def generateOutputFile(inFileName,                    \
                       outFileName,                   \
                       eval_expr_list,                \
                       recordColSeparator             \
                      ):
   try:
      outfile = open(outFileName, 'w')
   except:
      print('Error while creating output file: ' + outFileName)
      sys.exit(1)

   try:
      infile = open(inFileName, 'r')
   except:
      print('Error while reading input file: ' + inFileName)
      sys.exit(1)

   # For progress indicator
   inFileSize  = sum(1 for line in open(inFileName))-1
   if (inFileSize <= 1):
      print('Nothing to do. File size = ' + str(inFileSize + 1) + ' records (including header row).')
      sys.exit(0)
   processedRecordModulo = inFileSize * globalConstants.SHOW_PROGRESS_EVERY_RECORD_NUM_PERCENTAGE / 100
   if processedRecordModulo == 0:
      processedRecordModulo = 1

   # To get column names/indices for transformations
   headerColumns = []

   cur_rec_idx = 0
   inline = infile.readline()
   while inline:
      outline = ""

      # Process the header row
      if cur_rec_idx == 0:
         newInline = inline.rstrip()                   # Remove end of line characters from the record
         eolChars = inline.replace(newInline, "")      # End of line characters in the record
         values = newInline.split(recordColSeparator)
         headerColumns = list(values)
         # Print Header Row
         print('Header Row: \n' + ", ".join(headerColumns) + "\n")
         outline = recordColSeparator.join(values) + eolChars
      else:
         # Generate the non-header/record row.
         newInline = inline.rstrip()                   # Remove end of line characters from the record
         eolChars = inline.replace(newInline, "")      # End of line characters in the record
         values = newInline.split(recordColSeparator)
         isRecordUpdated = False
         # Run transformation on column values
         for eval_expr in eval_expr_list:
            isValueUpdated = transformValues(headerColumns, values, eval_expr)
            isRecordUpdated = isRecordUpdated or isValueUpdated
         if isRecordUpdated:
            globalVars.recordUpdateCount += 1
         outline = recordColSeparator.join(values) + eolChars

      # Write to output file
      outfile.write(outline)
      cur_rec_idx = cur_rec_idx + 1
      if (cur_rec_idx % processedRecordModulo) == 1 and cur_rec_idx != 1:
          print(' ... Processed record number ' + str(cur_rec_idx - 1).rjust(len(str(inFileSize)), "0"))

      inline = infile.readline()
   else:
      if cur_rec_idx == 0:
         print('No header file/empty input file.')
         sys.exit(1)
      if cur_rec_idx == 1:
         print('No record, only header line is present in file.')
         sys.exit(1)


   infile.close()
   outfile.close()

   print('\nOutput file generated     : ' + outFileName)
   print('Number of values  updated : ' + str(globalVars.valueUpdateCount))
   print('Number of records updated : ' + str(globalVars.recordUpdateCount))
   

if not len(sys.argv) > 1:
   printUsage()
   sys.exit(1)

if __name__ == "__main__":
   main(sys.argv[1:])

