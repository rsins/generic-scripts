#!/usr/bin/python
#***************************************************************************
# Author      : Ravi Kant Singh
# Description : Python script to add new columns at the end of data file.
# Created     : 1 Jun 2018
#***************************************************************************

from collections import OrderedDict
import os, sys, getopt
import uuid, random
import getpass


# ------------- Column Value Functions --------------

def generateDataForBlankColumn(headerColumns, curValues):
   return ""


def generateHardCodedData(headerColumns, curValues):
   cardTypes =["Visa", "MasterCard", "Amex", "Rupay", ""]
   return random.choice(cardTypes)


# --------------- Global Constant Values --------------------------
class globalConstants():
   SHOW_PROGRESS_EVERY_RECORD_NUM_PERCENTAGE = 10          # Print progress information every time this % of records processed for output file
   DATA_COL_SEPARATOR = "\x07"                             # Column separator char in the input/output file
   # Stores the sorting information "column_name : sort order (=ASC|DESC)"
   # If the column name not present in the input file then that sorting command is ignored.
   ADD_COLUMNS_FUNCTION_FT1 = OrderedDict([
                                            ("COL1"         , generateHardCodedData              ),  
                                            ("COL2"         , generateDataForBlankColumn         )
                                         ])
   ADD_COLUMNS_FUNCTION_FT2 = OrderedDict([
                                            ("COL3"         , generateHardCodedData              ),  
                                            ("COL4"         , generateDataForBlankColumn         )
                                         ])
   ADD_COLUMNS_FUNCTION_MAP = {
                                "FT1"  : ADD_COLUMNS_FUNCTION_FT1,
                                "FT2"  : ADD_COLUMNS_FUNCTION_FT2
                              }

# ---------------- Global Variables --------------------------------
class globalVars():
   doNotWaitForUserInput            = False   # bool - Wait for user to press enter after printing argument details.
   reference_file                   = None    # text - input data file for reference
   output_file                      = None    # text - output data file name/path
   columnsToAddAndValueFunctionsKey = None    # text - Key for column sort order in columns sort order map
   columnsToAddAndValueFunctions    = None    # Dict - has order in which columns should be sorted


# Main Logic is in this function
def main(argv):

   # Check script arguments
   checkScriptArguments(argv)

   # Confirm with user and wait for user input to continue.
   userConfirmation()

   # Start with creating the data file.
   generateOutputFile(globalVars.reference_file,                       \
                      globalVars.output_file,                          \
                      globalVars.columnsToAddAndValueFunctions,        \
                      globalConstants.DATA_COL_SEPARATOR               \
                     )


def checkScriptArguments(argv):
   try:
      opts, args = getopt.getopt(argv, "hci:o:a:")
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
      elif opt == "-o":
         globalVars.output_file = str(arg)
      elif opt == "-a":
         globalVars.columnsToAddAndValueFunctionsKey = str(arg).upper()
         if globalVars.columnsToAddAndValueFunctionsKey in globalConstants.ADD_COLUMNS_FUNCTION_MAP:
            globalVars.columnsToAddAndValueFunctions = globalConstants.ADD_COLUMNS_FUNCTION_MAP[globalVars.columnsToAddAndValueFunctionsKey]
         else:
            print('Columns Sort Order is not valid : ' + globalVars.columnsSortOrderKey)
            print('Valid Sort Orders = ' + " , ".join(globalConstants.COLUMNS_SORT_ORDER_MAP.keys()) + "\n")

   if globalVars.columnsToAddAndValueFunctions == None and len(globalConstants.ADD_COLUMNS_FUNCTION_MAP) == 1:
      globalVars.columnsToAddAndValueFunctionsKey = globalConstants.ADD_COLUMNS_FUNCTION_MAP.keys()[0]
      globalVars.columnsToAddAndValueFunctions = globalConstants.ADD_COLUMNS_FUNCTION_MAP.values()[0]

   if globalVars.reference_file == None or globalVars.output_file == None or globalVars.columnsToAddAndValueFunctions == None:
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
   print(' Input record size         = ' + inFileSizeStr)
   print(' Columns to add            = ' + globalVars.columnsToAddAndValueFunctionsKey + " -> " + str(globalVars.columnsToAddAndValueFunctions.keys()))
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


def printUsage():
   print('Usage: ' + str(sys.argv[0]) + ' [ -h | -i reference_file | -o output data file | -a (' + ','.join(globalConstants.ADD_COLUMNS_FUNCTION_MAP.keys()) +') | -c ]')
   print('       -h  show this help and exit')
   print('       -i  reference_file to be used for generating sample data file')
   print('       -o  output data file name')
   print('       -a  give name of group of columns to add (' + " | ".join(globalConstants.ADD_COLUMNS_FUNCTION_MAP.keys()) + ')')
   print('       -c  continue without user confirmation (non-interactive mode)')


def generateOutputFile(inFileName,                    \
                       outFileName,                   \
                       columnsToAddAndValueFunctions, \
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
      print('Nothing to sort. File size = ' + str(inFileSize + 1) + ' records (including header row).')
      sys.exit(0)
   processedRecordModulo = inFileSize * globalConstants.SHOW_PROGRESS_EVERY_RECORD_NUM_PERCENTAGE / 100
   if processedRecordModulo == 0:
      processedRecordModulo = 1

   # To get column names/indices for transformations
   oldHeaderColumns = []
   newHeaderColumns = []

   cur_rec_idx = 0
   inline = infile.readline()
   while inline:
      outline = ""

      # Process the header row
      if cur_rec_idx == 0:
         newInline = inline.rstrip()                   # Remove end of line characters from the record
         eolChars = inline.replace(newInline, "")      # End of line characters in the record
         values = newInline.split(recordColSeparator)
         oldHeaderColumns = list(values)
         # Print Header Row
         print('Old Header Row: \n' + ", ".join(oldHeaderColumns) + "\n")
         #print('\nColumns to be picked to add at the end:\n\t' + ", ".join(columnsToAddAndValueFunctions.keys()))
         newColCount = 0
         for colName in columnsToAddAndValueFunctions.keys():
            if colName not in oldHeaderColumns:
               newColCount = newColCount + 1
               values.append(colName)
            else:
               print('... Column "' + colName + '" already exists in the input file. Values for this column will not be changed.')
         outline = recordColSeparator.join(values) + eolChars
         newHeaderColumns = values
         if newColCount != 0:
            print('New columns to be added = ' +  str(newColCount) + "\n\t(" + ", ".join([x for x in newHeaderColumns if x not in oldHeaderColumns]) + ")\n")
         else:
            print('No new columns to be added. Nothing to do.')
            sys.exit(0)
         print('New Header Row: \n' + ", ".join(newHeaderColumns) + "\n")
      else:
         # Generate the non-header/record row.
         newInline = inline.rstrip()                   # Remove end of line characters from the record
         eolChars = inline.replace(newInline, "")      # End of line characters in the record
         values = newInline.split(recordColSeparator)
         # Run transformation on column values
         for colName in columnsToAddAndValueFunctions.keys():
            if colName not in oldHeaderColumns:
               values.append(columnsToAddAndValueFunctions[colName](oldHeaderColumns, values))
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

   print('\nOutput file generated: ' + outFileName)
   

if not len(sys.argv) > 1:
   printUsage()
   sys.exit(1)

if __name__ == "__main__":
   main(sys.argv[1:])

