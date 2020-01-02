#!/usr/bin/python
#***************************************************************************
# Author      : Ravi Kant Singh
# Description : Python script to check for invalide characters in the file
# Created     : 8 June 2018
#***************************************************************************


import sys, getopt
import getpass

# ------------------ Global Constant Values -------------------------------
class globalConstants():
    INVALID_CHAR      = "\x00"
    INVALID_CHAR_STR  = "\\x00"
    STDIN_FILE        = sys.stdin


# ------------------ Global Variables -------------------------------------
class globalVars():
   doNotWaitForUserInput  = False   # bool - Wait for user to press enter after printing argument details.
   inFileName             = None    # text - input file name
   useStdIn               = False   # bool - if need to use stdin for reading data


# Main Logic is in this function
def main(argv):

   # Check script arguments
   checkScriptArguments(argv)

   # Confirm with user and wait for user input to continue.
   userConfirmation()

   # Start with creating the data file.
   inFile = open(globalVars.inFileName, "r") if not globalVars.useStdIn else globalConstants.STDIN_FILE
   checkForInvalidChar(inFile, globalConstants.INVALID_CHAR)


def checkScriptArguments(argv):
   try:
      opts, args = getopt.getopt(argv, "hcIi:")
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
      elif opt == "-I":
         if globalVars.inFileName:
            print(' * Either use -i or -I.')
            printUsage()
            sys.exit(1)
         globalVars.useStdIn = True
      elif opt == "-i":
         if globalVars.useStdIn:
            print(' * Either use -i or -I.')
            printUsage()
            sys.exit(1)
         globalVars.inFileName = str(arg)
   
   if not globalVars.useStdIn and not globalVars.inFileName:
      print('\n * Data source (file/stdin) not mentioned.\n')
      printUsage()
      sys.exit(1)


def userConfirmation():
   print('\n---------------------------------------------------')

   if not globalVars.useStdIn:
      try:
         inFileSizeStr  = str(sum(len(line) for line in open(globalVars.inFileName)))
      except:
         print('Error while reading input file: ' + globalVars.inFileName)
         sys.exit(1)
      print(' Input reference data file  = ' + globalVars.inFileName)
      print(' Input characters count     = ' + inFileSizeStr)
   else:
      globalVars.doNotWaitForUserInput = True
      print(' Input reference data file  = STDIN')

   print(' Invalid Character to Check = ' + globalConstants.INVALID_CHAR_STR)
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
   print('Usage: ' + str(sys.argv[0]) + ' [ -h | -i reference_file | -I | -c ]')
   print('       -h  show this help and exit')
   print('       -i  reference_file to be used for generating sample data file')
   print('       -I  read stdin for the input data')
   print('       -c  continue without user confirmation (non-interactive mode)')


def printCurInvalidCharBlockInfo(blockNum, idx_start, idx_end):
    print("Block " + str(blockNum).rjust(2," ")  \
        + " -  start = " + str(idx_start)        \
        + ", end = " + str(idx_end)              \
        + ", length = " + str(idx_end - idx_start + 1) + "\n")


def printCurAndPrevInvalidCharBlockDiffInfo(idx_prev_start, idx_prev_end, curBlockNum, idx_cur_start, idx_cur_end):
    print("       Diff between position of block " + str(curBlockNum)  \
        + " and block " + str(curBlockNum -1)                          \
        + " = " + str(idx_cur_start - idx_prev_end) + "\n")


def checkForInvalidChar(inFile, invalid_char):
    idx_prev_start = None
    idx_prev_end = None
    idx_cur_start = None
    idx_cur_end = None
    
    idx_byte = 0
    chars_block_count = 0
    
    c = inFile.read(1)
    while c:
        idx_byte = idx_byte + 1
    
        # Read through the current block of invalid characters
        if c == invalid_char:
            chars_block_count = chars_block_count + 1
            idx_cur_start = idx_byte
            while c == invalid_char:
                idx_byte = idx_byte + 1
                c = inFile.read(1)
            idx_cur_end = idx_byte - 1
    
            # If we need to print about first block
            if chars_block_count == 1:
                printCurInvalidCharBlockInfo(chars_block_count, idx_cur_start, idx_cur_end)
            # If we are at the end of other than first block
            if idx_prev_start and idx_prev_end:
               printCurAndPrevInvalidCharBlockDiffInfo(idx_prev_start, idx_prev_end, chars_block_count, idx_cur_start, idx_cur_end)
               printCurInvalidCharBlockInfo(chars_block_count, idx_cur_start, idx_cur_end)
            idx_prev_start = idx_cur_start
            idx_prev_end = idx_cur_end
            idx_cur_start = None
            idx_cur_end = None
    
        c = inFile.read(1)
    
    # If there is only one block
    if idx_cur_start and idx_cur_end and chars_block_count == 1:
        printCurInvalidCharBlockInfo(chars_block_count, idx_cur_start, idx_cur_end)
    

if __name__ == "__main__":
   main(sys.argv[1:])

