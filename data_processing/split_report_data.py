#!/usr/bin/python
#***************************************************************************
# Author      : Ravi Kant Singh
# Description : Python script to split input file in multiple files based on
#               record count (excluding header column).
# Created     : 1 Jun 2018
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
   reference_file                   = None    # text - input data file for reference
   outputFilePrefix                 = None    # text - output data file name/path
   outputFileRecordSplitSize        = None    # int  - Number of records (excluding header record) out files should be split with
   allOutFileNames                  = []      # Arr  - name of all output files generated
   pad_file_seq_in_file             = False   # Flag to indicate if sequence number in outut file name should be padded with 0.


# Main Logic is in this function
def main(argv):

   # Check script arguments
   checkScriptArguments(argv)

   # Confirm with user and wait for user input to continue.
   userConfirmation()

   # Start with creating the data file.
   generateOutputFile(globalVars.reference_file,                       \
                      globalVars.outputFilePrefix,                     \
                      globalVars.outputFileRecordSplitSize,            \
                      globalConstants.DATA_COL_SEPARATOR               \
                     )


def checkScriptArguments(argv):
   try:
      opts, args = getopt.getopt(argv, "hcPi:p:s:")
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
      elif opt == "-P":
         globalVars.pad_file_seq_in_file = True
      elif opt == "-i":
         globalVars.reference_file = str(arg)
      elif opt == "-p":
         globalVars.outputFilePrefix = str(arg)
      elif opt == "-s":
         globalVars.outputFileRecordSplitSize = int(str(arg))

   if globalVars.reference_file == None or globalVars.outputFilePrefix == None or globalVars.outputFileRecordSplitSize == None:
      printUsage()
      sys.exit(1)


def userConfirmation():
   try:
      inFileSize  = sum(1 for line in open(globalVars.reference_file))-1
   except:
      print('Error while reading input file: ' + globalVars.reference_file)
      sys.exit(1)
   inFileSizeStr = str(inFileSize)
   outFileSplitAtSizeStr = str(globalVars.outputFileRecordSplitSize)
   paddingLen = max(len(inFileSizeStr), len(outFileSplitAtSizeStr))
   countOfOutFiles = (inFileSize / globalVars.outputFileRecordSplitSize) + (1 if (inFileSize % globalVars.outputFileRecordSplitSize) > 0 else 0)
   print('\n---------------------------------------------------')
   print(' Input reference data file      = ' + globalVars.reference_file)
   print(' Output data file name prefix   = ' + globalVars.outputFilePrefix)
   print(' Padding for sequence in name   = ' + str(globalVars.pad_file_seq_in_file))
   print(' Input record size              = ' + inFileSizeStr.rjust(paddingLen, "0"))
   print(' Output record split size       = ' + outFileSplitAtSizeStr.rjust(paddingLen, "0"))
   print(' Number of files to be created  = ' + str(countOfOutFiles))
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
   print('Usage: ' + str(sys.argv[0]) + ' [ -h | -i reference_file | -P | -p prefix output data file | -s split_record_size | -c ]')
   print('       -h  show this help and exit')
   print('       -i  reference_file to be used for generating sample data file')
   print('       -p  prefix for output data file name')
   print('       -P  pad file name sequence with 0 (default is no-padding)')
   print('       -s  output splite record size (excluding header row)')
   print('       -c  continue without user confirmation (non-interactive mode)')
   print(' ')
   print(' Out Files will be created in the format <prefix>_01.dat, <prefix>_02.dat etc.')


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


# Open output file name for split records, also save it in the list of created files.
def openOutFile(outFileNamePrefix, cur_file_seq, paddingLen):
   outFileName = outFileNamePrefix + "_" + str(cur_file_seq).rjust(paddingLen, "0") + ".dat"
   try:
      outFile = open(outFileName, 'w')
      globalVars.allOutFileNames.append(outFileName)
      return outFile
   except:
      print('Error while creating output file: ' + outFileName)
      printFileNames('There are some files already created : ', globalVars.allOutFileNames)
      sys.exit(1)


def generateOutputFile(inFileName,                    \
                       outFileNamePrefix,             \
                       outputFileRecordSplitSize,     \
                       recordColSeparator             \
                      ):
   try:
      infile = open(inFileName, 'r')
   except:
      print('Error while reading input file: ' + inFileName)
      sys.exit(1)

   # For progress indicator
   inFileSize  = sum(1 for line in open(inFileName))-1
   if (inFileSize <= 1):
      print('Nothing to spliit. File size = ' + str(inFileSize + 1) + ' records (including header row).')
      sys.exit(0)
   processedRecordModulo = inFileSize * globalConstants.SHOW_PROGRESS_EVERY_RECORD_NUM_PERCENTAGE / 100
   if processedRecordModulo == 0:
      processedRecordModulo = 1

   # For generating the output file name
   paddingLenFileSeq = len(str(inFileSize / outputFileRecordSplitSize)) if globalVars.pad_file_seq_in_file else 0
   # For printing the record processing information
   paddingLen = len(str(inFileSize))
   
   # To get Header Row
   headerLine = None

   cur_file_seq = 1
   cur_rec_idx = 0
   inline = infile.readline()
   # output file object
   outfile = None
   while inline:
      outline = ""

      # Process the header row
      if cur_rec_idx == 0:
         # Print Header Row
         outline = inline
         headerLine = inline
         print('Header Row: \n' + ", ".join(inline.rstrip().split(recordColSeparator)))

         # Open the first file.
         outfile = openOutFile(outFileNamePrefix, cur_file_seq, paddingLenFileSeq)
      else:
         # Skip the header line for splitting the file
         if (cur_rec_idx != 1) and ((cur_rec_idx - 1) % outputFileRecordSplitSize == 0):
            outfile.close()
            cur_file_seq = cur_file_seq + 1
            outfile = openOutFile(outFileNamePrefix, cur_file_seq, paddingLenFileSeq)
            # Write header to the new file.
            outfile.write(headerLine)
         outline = inline 

      # Write to output file
      outfile.write(outline)
      cur_rec_idx = cur_rec_idx + 1
      if (cur_rec_idx % processedRecordModulo) == 1 and cur_rec_idx != 1:
          print(' ... Processed input record number ' + str(cur_rec_idx - 1).rjust(paddingLen, "0"))

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

   print('\nCount of Output file generated: ' + str(cur_file_seq).rjust(paddingLenFileSeq, "0"))
   printFileNames('List of output files created : ', globalVars.allOutFileNames)
   

if not len(sys.argv) > 1:
   printUsage()
   sys.exit(1)

if __name__ == "__main__":
   main(sys.argv[1:])

