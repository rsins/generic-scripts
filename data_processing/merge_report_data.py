#!/usr/bin/python
#***************************************************************************
# Author      : Ravi Kant Singh
# Description : Python script to merge input files in single file.
#                                                            
# Created     : 2 Jun 2018
#***************************************************************************

from collections import OrderedDict
import os, sys, getopt
import uuid, random
import getpass


# --------------- Global Constant Values --------------------------
class globalConstants():
   SHOW_PROGRESS_EVERY_RECORD_NUM_PERCENTAGE = 10          # Print progress information every time this % of records processed for output file
   DATA_COL_SEPARATOR = "\x07"                             # Column separator char in the input/output file


# ---------------- Global Variables --------------------------------
class globalVars():
   doNotWaitForUserInput            = False   # bool - Wait for user to press enter after printing argument details.
   inputFileNamesArr                = []      # Arr  - name of all input files         
   outputFileName                   = None    # text - output data file name/path


# Main Logic is in this function
def main(argv):

   # Check script arguments
   checkScriptArguments(argv)

   # Confirm with user and wait for user input to continue.
   userConfirmation()

   # Start with creating the data file.
   generateOutputFile(globalVars.inputFileNamesArr,                    \
                      globalVars.outputFileName,                       \
                      globalConstants.DATA_COL_SEPARATOR               \
                     )


def checkScriptArguments(argv):
   try:
      opts, args = getopt.getopt(argv, "hco:")
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
      elif opt == "-o":
         globalVars.outputFileName = str(arg)

   for f in args:
      globalVars.inputFileNamesArr.append(str(f))

   if len(globalVars.inputFileNamesArr) == 0 or globalVars.outputFileName == None:
      printUsage()
      sys.exit(1)

   if os.path.abspath(globalVars.outputFileName) in [os.path.abspath(x) for x in globalVars.inputFileNamesArr]:
      print('Both input file and output files cannot be same -> ' + globalVars.outputFileName)
      sys.exit(1)


# Print the list of file names.
def printFileNames(msg, fileNamesArr):
   lineStartPrefix = "    "
   outputFileNameSeparator = "   "
   if len(fileNamesArr) > 0:
      maxFileNameLength = max([len(x) for x in fileNamesArr])
      newFileNameArr = [x.ljust(maxFileNameLength, " ") for x in fileNamesArr]
      # Get terminal size
      tRows, tColumns = os.popen('stty size', 'r').read().split()
      # Determine how many file names can be printed on one line
      numOfNamesInOneLine = (int(tColumns) - len(lineStartPrefix)) / (maxFileNameLength + len(outputFileNameSeparator))
      print(msg)
      cur_idx = 0
      while cur_idx < len(newFileNameArr):
         print(lineStartPrefix + outputFileNameSeparator.join(newFileNameArr[cur_idx:cur_idx + numOfNamesInOneLine]))
         cur_idx = cur_idx + numOfNamesInOneLine


def userConfirmation():
   print('\n---------------------------------------------------')
   print(' Output data file name  = ' + globalVars.outputFileName)
   printFileNames(' List of Input files    : (count = ' + str(len(globalVars.inputFileNamesArr)) + ")", globalVars.inputFileNamesArr)
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
   print('Usage: ' + str(sys.argv[0]) + ' [ -h | -o output data file | -c ] file1 file2 ...')
   print('       -h  show this help and exit')
   print('       -o  output data file name')
   print('       -c  continue without user confirmation (non-interactive mode)')
   print(' ')


def generateOutputFile(inFileNamesArr,                \
                       outFileName,                   \
                       recordColSeparator             \
                      ):
   try:
      outfile = open(outFileName, 'w')
   except:
      print('Error while creating output file: ' + outFileName)
      sys.exit(1)

   # To get Header Columns
   headerColumns = None
   totalFileRecords = 0
   for inFileNameIdx in range(len(inFileNamesArr)):
      inFileName = inFileNamesArr[inFileNameIdx]

      print(' * Processing file -> ' + inFileName)
      # For progress indicator
      inFileSize  = sum(1 for line in open(inFileName))-1
      if (inFileSize <= 0):
         print('      ... Nothing to merge. File size = ' + str(inFileSize + 1) + ' records (including header row).')
         continue
      processedRecordModulo = inFileSize * globalConstants.SHOW_PROGRESS_EVERY_RECORD_NUM_PERCENTAGE / 100
      if processedRecordModulo == 0:
         processedRecordModulo = 1

      # For generating the processed record information
      paddingLen = len(str(inFileSize))
   
      cur_rec_idx = 0
      infile = open(inFileName, 'r')
      inline = infile.readline()
      while inline:
         outline = ""

         # process header row for first file
         if inFileNameIdx == 0 and cur_rec_idx == 0:
            headerColumns = inline.rstrip().split(recordColSeparator)
            outline = inline

         # Process the header row
         if inFileNameIdx != 0 and cur_rec_idx == 0:
             if headerColumns != inline.rstrip().split(recordColSeparator):
               print('        ... Header column does not match with header of first file (' + inFileNamesArr[0] + ')')
               print('        ... First File Header   :\n' + str(headerColumns))
               print('        ... Current File Header :\n' + str(inline.rstrip().split(recordColSeparator)))
               # Forcing the while loop to stop.
               inline = None
               continue
         else:
            outline = inline 
   
         # Write to output file
         outfile.write(outline)
         cur_rec_idx = cur_rec_idx + 1
         if (cur_rec_idx % processedRecordModulo) == 1 and cur_rec_idx != 1:
             print('        ... Processed input record number ' + str(cur_rec_idx - 1).rjust(paddingLen, "0"))
         inline = infile.readline()

      totalFileRecords = totalFileRecords + cur_rec_idx
      infile.close()

   outfile.close()

   # Exclude the header rows in the count
   totalFileRecords = totalFileRecords + 1 - len(inFileNamesArr)
   print('\nOutput file generated: ' + outFileName)
   print('Output file size      : ' + str(totalFileRecords))
   

if not len(sys.argv) > 1:
   printUsage()
   sys.exit(1)

if __name__ == "__main__":
   main(sys.argv[1:])

