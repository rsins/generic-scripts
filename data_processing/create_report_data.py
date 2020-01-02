#!/usr/bin/python
#***************************************************************************
# Author      : Ravi Kant Singh
# Description : Python script to generate data file based on a reference file.
# Created     : 23 May 2018
#***************************************************************************

import os, sys, getopt
import uuid, random
import getpass


# ------------- Column Value Transformation Functions --------------

def initFunctionForInputFileStart():
   # Clear the old vs new value map as we are re-opening the input file.
   globalVars.oldAndNewUUIDMap.clear()


def generateUUIDData(invalue):
   if len(invalue) == 0:
       return invalue
   if invalue not in globalVars.oldAndNewUUIDMap:
      globalVars.oldAndNewUUIDMap[invalue] = str(uuid.uuid4())
   return globalVars.oldAndNewUUIDMap[invalue]
   

def generateUUIDBasedType1Data(invalue):
   if len(invalue) == 0:
       return invalue
   if invalue not in globalVars.oldAndNewUUIDMap:
       globalVars.oldAndNewUUIDMap[invalue] = str(random.getrandbits(64))[:7] + ":" + str(uuid.uuid4())
   return globalVars.oldAndNewUUIDMap[invalue]
   

# --------------- Global Constant Values --------------------------
class globalConstants():
   SHOW_PROGRESS_EVERY_RECORD_NUM_PERCENTAGE = 10          # Print progress information every time this % of records processed for output file
   DATA_COL_SEPARATOR = "\x07"                             # Column separator char in the input/output file
   # Tells about what transformation to run on a column values
   COLUMN_TRANSFORMATION_FUNCTIONS = {
                                        "COL1"          : generateUUIDData             ,
                                        "COL2"          : generateUUIDBasedType1Data   
                                     }

# ---------------- Global Variables --------------------------------
class globalVars():
   doNotWaitForUserInput  = False   # bool - Wait for user to press enter after printing argument details.
   reference_file         = None    # text - input data file for reference
   record_size            = None    # int  - number of records expected in output file (excluding header row)
   output_file            = None    # text - output data file name/path
   oldAndNewUUIDMap       = dict()  # dict - dictionary/map variable to store old vs new UUID or UUID based generated data    


# Main Logic is in this function
def main(argv):

   # Check script arguments
   checkScriptArguments(argv)

   # Confirm with user and wait for user input to continue.
   userConfirmation()

   # Start with creating the data file.
   generateOutputFile(globalVars.reference_file,                       \
                      globalVars.output_file,                          \
                      globalVars.record_size,                          \
                      globalConstants.COLUMN_TRANSFORMATION_FUNCTIONS, \
                      globalConstants.DATA_COL_SEPARATOR,              \
                      initFunctionForInputFileStart                    \
                     )


def checkScriptArguments(argv):
   try:
      opts, args = getopt.getopt(argv, "hci:s:o:")
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
      elif opt in ("-s"):
         globalVars.record_size = int(str(arg))

   if globalVars.reference_file == None or globalVars.record_size == None or globalVars.output_file == None:
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
   outFileSizeStr = str(globalVars.record_size)
   paddingLen = max(len(inFileSizeStr), len(outFileSizeStr))
   print('\n---------------------------------------------------')
   print(' Input reference data file = ' + globalVars.reference_file)
   print(' Output data file name     = ' + globalVars.output_file)
   print(' Input record size         = ' + inFileSizeStr.rjust(paddingLen, "0"))
   print(' Output record size        = ' + outFileSizeStr.rjust(paddingLen, "0"))
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
   print('Usage: ' + str(sys.argv[0]) + ' [ -h | -i reference_file | -o output data file | -s size | -c ]')
   print('       -h  show this help and exit')
   print('       -i  reference_file to be used for generating sample data file')
   print('       -o  output data file name')
   print('       -s  number of records inthe output file (excluding header row)')
   print('       -c  continue without user confirmation (non-interactive mode)')


def generateOutputFile(inFileName,                    \
                       outFileName,                   \
                       outputRecordSize,              \
                       columnTransformationFunctions, \
                       recordColSeparator,            \
                       initFunctionForInputFileStart  \
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

   initFunctionForInputFileStart()

   # For progress indicator
   processedRecordModulo = outputRecordSize * globalConstants.SHOW_PROGRESS_EVERY_RECORD_NUM_PERCENTAGE / 100
   if processedRecordModulo == 0:
      processedRecordModulo = 1

   # To get column names/indices for transformations
   headerColumns = []

   cur_rec_idx = 0
   while cur_rec_idx <= outputRecordSize:
      inline = infile.readline()
      outline = ""

      # if already reached end of input file
      if not inline:
         if cur_rec_idx == 0:
            print('No header file/empty input file.')
            sys.exit(1)
         infile.seek(0, 0)
         initFunctionForInputFileStart()
         # Skip the header file
         inline = infile.readline()
         inline = infile.readline()
         # Check if there is any record or only header line
         if not inline:
             print('Only header record in the input file. There are no records present.')

      # Process the header row
      if cur_rec_idx == 0:
         # Print Header Row
         outline = inline
         headerColumns = inline.rstrip().split(recordColSeparator)
         print('Header Row: \n' + ", ".join(headerColumns))
         columnsToBeTransformed = [x for x in columnTransformationFunctions.keys() if x in headerColumns]
         if len (columnsToBeTransformed) > 0:
            print('\nColumns picked for value transformation:\n\t' + ", ".join(columnsToBeTransformed))
         else:
            print('No columns will be transformed.')
      else:
         # Generate the non-header/record row.
         newInline = inline.rstrip()                   # Remove end of line characters from the record
         eolChars = inline.replace(newInline, "")      # End of line characters in the record
         values = newInline.split(recordColSeparator)
         # Run transformation on column values
         for colName in columnTransformationFunctions.keys():
            if colName in headerColumns:
               colIdx = headerColumns.index(colName)
               colValue = values[colIdx]
               values[colIdx] = columnTransformationFunctions[colName](colValue)
         outline = recordColSeparator.join(values) + eolChars

      # Write to output file
      outfile.write(outline)
      cur_rec_idx = cur_rec_idx + 1
      if (cur_rec_idx % processedRecordModulo) == 1 and cur_rec_idx != 1:
          print(' ... Processed record number ' + str(cur_rec_idx - 1).rjust(len(str(outputRecordSize)), "0"))

   infile.close()
   outfile.close()

   print('\nOutput file generated: ' + outFileName)
   

if not len(sys.argv) > 1:
   printUsage()
   sys.exit(1)

if __name__ == "__main__":
   main(sys.argv[1:])

