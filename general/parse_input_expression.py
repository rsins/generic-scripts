#!/usr/bin/python
#***************************************************************************
# Author      : Ravi Kant Singh
# Description : Python script to parse expression and calculate value.
# Created     : 6 Jul 2018
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
class Calculator():
   __varValues = dict()

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
  
   @staticmethod
   @FuncAttrs(2, 'Define a variable with name "a" and value "b".')
   def OpAssign(a, b):
      Calculator.__varValues[a] = b
      return b
  
   @staticmethod
   @FuncAttrs(1, 'Get value for already defined variable.')
   def OpVar(a):
      return Calculator.__varValues[a] if a in Calculator.__varValues else None


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
   @FuncAttrs(2, 'Check if value is empty.')
   def FuncIsEmpty(a):
     return True if (not a) else (True if (len(str(a)) == 0) else False)

   @staticmethod
   @FuncAttrs(3, 'Evaluate "a" to boolean expression and return "b" if true else "c" if false.')
   def FuncIf(a, b, c):
     return b if a else c

   @staticmethod
   @FuncAttrs(1, 'Convert input argument to boolean. Examples = true, 1 or y.')
   def FuncBool(a):
     return str(a).lower() in ["true", "1", "y"]
  

class Evaluator():
   # To store the mappping with "expression function" with tuple "( python function, number of arguments this function requires)"
   Operation  = {
                   "add"         : Calculator.OpAdd             ,
                   "substract"   : Calculator.OpSubstract       ,
                   "multiply"    : Calculator.OpMultiply        ,
                   "devide"      : Calculator.OpDevide          ,
                   "assign"      : Calculator.OpAssign          ,
                   "var"         : Calculator.OpVar             ,
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
                   "if"          : Validator.FuncIf             ,
                   "bool"        : Validator.FuncBool           ,
                }

   def __init__(self):
      # Store in this map all the keys and corresponding functions with number of arguments required
      self.evalKeyFunctionMap = dict()
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
      elif funcDef.argCount == 3:
          val = funcDef(args[0], args[1], args[2])
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

def printArt():
    art = ''
    art +=b'\n  \x1b[0;1;34;94m\xe2\x96\x91\xe2\x96\x88\xe2\x96\x80\xe2\x96\x84\xe2\x96\x91\xe2\x96\x88\xe2\x96\x80\xe2\x96\x88\xe2\x96\x91\xe2\x96\x88\xe2\x96\x91\xe2\x96\x88\xe2\x96\x91\xe2\x96\x80\xe2\x96\x88\xe2\x96\x80\x1b[0;34m\xe2\x96\x91\xe2\x96\x91\xe2\x96\x91\xe2\x96\x88\xe2\x96\x91\xe2\x96\x88\xe2\x96\x91\xe2\x96\x88\xe2\x96\x80\xe2\x96\x88\xe2\x96\x91\xe2\x96\x88\xe2\x96\x80\xe2\x96\x88\xe2\x96\x91\xe2\x96\x80\x1b[0;37m\xe2\x96\x88\xe2\x96\x80\xe2\x96\x91\xe2\x96\x91\xe2\x96\x91\xe2\x96\x88\xe2\x96\x80\xe2\x96\x80\xe2\x96\x91\xe2\x96\x80\xe2\x96\x88\xe2\x96\x80\xe2\x96\x91\xe2\x96\x88\xe2\x96\x80\xe2\x96\x88\x1b[0;1;30;90m\xe2\x96\x91\xe2\x96\x88\xe2\x96\x80\xe2\x96\x80\xe2\x96\x91\xe2\x96\x88\xe2\x96\x91\xe2\x96\x88\x1b[0m'.decode('utf-8')
    art +=b'\n  \x1b[0;1;34;94m\xe2\x96\x91\xe2\x96\x88\xe2\x96\x80\xe2\x96\x84\xe2\x96\x91\xe2\x96\x88\xe2\x96\x80\xe2\x96\x88\x1b[0;34m\xe2\x96\x91\xe2\x96\x80\xe2\x96\x84\xe2\x96\x80\xe2\x96\x91\xe2\x96\x91\xe2\x96\x88\xe2\x96\x91\xe2\x96\x91\xe2\x96\x91\xe2\x96\x91\xe2\x96\x88\xe2\x96\x80\xe2\x96\x84\xe2\x96\x91\xe2\x96\x88\x1b[0;37m\xe2\x96\x80\xe2\x96\x88\xe2\x96\x91\xe2\x96\x88\xe2\x96\x91\xe2\x96\x88\xe2\x96\x91\xe2\x96\x91\xe2\x96\x88\xe2\x96\x91\xe2\x96\x91\xe2\x96\x91\xe2\x96\x91\xe2\x96\x80\xe2\x96\x80\xe2\x96\x88\x1b[0;1;30;90m\xe2\x96\x91\xe2\x96\x91\xe2\x96\x88\xe2\x96\x91\xe2\x96\x91\xe2\x96\x88\xe2\x96\x91\xe2\x96\x88\xe2\x96\x91\xe2\x96\x88\xe2\x96\x91\xe2\x96\x88\xe2\x96\x91\xe2\x96\x88\xe2\x96\x80\xe2\x96\x88\x1b[0m'.decode('utf-8')
    art +=b'\n  \x1b[0;34m\xe2\x96\x91\xe2\x96\x80\xe2\x96\x91\xe2\x96\x80\xe2\x96\x91\xe2\x96\x80\xe2\x96\x91\xe2\x96\x80\xe2\x96\x91\xe2\x96\x91\xe2\x96\x80\xe2\x96\x91\xe2\x96\x91\xe2\x96\x80\xe2\x96\x80\xe2\x96\x80\x1b[0;37m\xe2\x96\x91\xe2\x96\x91\xe2\x96\x91\xe2\x96\x80\xe2\x96\x91\xe2\x96\x80\xe2\x96\x91\xe2\x96\x80\xe2\x96\x91\xe2\x96\x80\xe2\x96\x91\xe2\x96\x80\xe2\x96\x91\xe2\x96\x80\xe2\x96\x91\xe2\x96\x91\x1b[0;1;30;90m\xe2\x96\x80\xe2\x96\x91\xe2\x96\x91\xe2\x96\x91\xe2\x96\x91\xe2\x96\x80\xe2\x96\x80\xe2\x96\x80\xe2\x96\x91\xe2\x96\x80\xe2\x96\x80\xe2\x96\x80\xe2\x96\x91\xe2\x96\x80\xe2\x96\x91\xe2\x96\x80\x1b[0;1;34;94m\xe2\x96\x91\xe2\x96\x80\xe2\x96\x80\xe2\x96\x80\xe2\x96\x91\xe2\x96\x80\xe2\x96\x91\xe2\x96\x80\x1b[0m'.decode('utf-8')
    art +='\n'
    print(art)

# Based on python version use appropriate method to get input from stdin
def get_line_from_input():
    return input() if sys.version_info.major >= 3 else raw_input()

# Main Logic is in this function
def main(argv):
    OUTPUT_LENGTH = "30"
    evaluator = Evaluator()
    while True:
       try:
          line = get_line_from_input()
       except (EOFError, KeyboardInterrupt) as e:
          sys.exit(0)
       line = str(line).strip() if line else ""
       if line.lower() in ["?", "help", "h"] :
          print("> " + format(line, "<" + OUTPUT_LENGTH) + " = help()")
          evaluator.showSyntax()
       elif line.lower() in ["q", "quit", "exit"]:
          print("> " + format(line, "<" + OUTPUT_LENGTH) + " = system.exit()")
          sys.exit(0)
       elif len(line) > 0:
          try:
             val = evaluator.evalExpr(line)
             print("> " + format(str(val), "<" + OUTPUT_LENGTH) + " = " + line)
          except SystemExit:
             pass
          except:
             print("> Unexpected error:", sys.exc_info())

printArt()

if __name__ == "__main__":
   main(sys.argv[1:])

