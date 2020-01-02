#!/usr/bin/python
#***************************************************************************
# Author      : Ravi Kant Singh
# Description : Python script to sort a data file based on a given column.
# Created     : 23 May 2018
#***************************************************************************

from operator import itemgetter
from collections import OrderedDict
import csv
import os, sys, getopt
import getpass


# ------------------ Global Constant Values -------------------------------
class globalConstants():
   SHOW_PROGRESS_EVERY_RECORD_NUM_PERCENTAGE = 10          # Print progress information every time this % of records processed for output file
   DATA_COL_SEPARATOR = "\x07"                             # Column separator char in the input/output file
   # Stores the sorting information "column_name : sort order (=ASC|DESC)"
   # If the column name not present in the input file then that sorting command is ignored.
   COLUMNS_TO_SORT_FT1 = OrderedDict([
                                       ("COL1"     , "ASC" ), 
                                       ("COL2"     , "ASC" )  
                                       ])
   COLUMNS_TO_SORT_FT2 = OrderedDict([
                                       ("COL3"     , "ASC" ), 
                                       ("COL4"     , "ASC" )  
                                    ])
   COLUMNS_SORT_ORDER_MAP = {
                              "FT1" : COLUMNS_TO_SORT_FT1,
                              "FT2" : COLUMNS_TO_SORT_FT2
                            }


# ------------------ Global Variables -------------------------------------
class globalVars():
   doNotWaitForUserInput = False   # bool - Wait for user to press enter after printing argument details.
   reference_file        = None    # text - input data file for reference
   output_file           = None    # text - output data file name/path
   columnsSortOrderKey   = None    # text - Key for column sort order in columns sort order map
   columnsSortOrder      = None    # Dict - has order in which columns should be sorted


# Main Logic is in this function
def main(argv):

   # Check script arguments
   checkScriptArguments(argv)

   # Confirm with user and wait for user input to continue.
   userConfirmation()

   # Start with creating the data file.
   generateSortedOutputFile(globalVars.reference_file,          \
                            globalVars.output_file,             \
                            globalVars.columnsSortOrder,        \
                            globalConstants.DATA_COL_SEPARATOR  \
                           )


def checkScriptArguments(argv):
   try:
      opts, args = getopt.getopt(argv, "hci:o:s:")
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
      elif opt == "-s":
         globalVars.columnsSortOrderKey = str(arg).upper()
         if globalVars.columnsSortOrderKey in globalConstants.COLUMNS_SORT_ORDER_MAP:
            globalVars.columnsSortOrder = globalConstants.COLUMNS_SORT_ORDER_MAP[globalVars.columnsSortOrderKey]
         else:
            print('Columns Sort Order is not valid : ' + globalVars.columnsSortOrderKey)
            print('Valid Sort Orders = ' + " , ".join(globalConstants.COLUMNS_SORT_ORDER_MAP.keys()) + "\n")

   if globalVars.columnsSortOrder == None and len(globalConstants.COLUMNS_SORT_ORDER_MAP) == 1:
      globalVars.columnsSortOrderKey = globalConstants.COLUMNS_SORT_ORDER_MAP.keys()[0]
      globalVars.columnsSortOrder = globalConstants.COLUMNS_SORT_ORDER_MAP.values()[0]

   if globalVars.reference_file == None or globalVars.output_file == None or globalVars.columnsSortOrder == None:
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
   print(' Columns sort order        = ' + globalVars.columnsSortOrderKey + " -> " + str(globalVars.columnsSortOrder.items()))
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
   print('Usage: ' + str(sys.argv[0]) + ' [ -h | -i reference_file | -o output data file | -s <' + ",".join(globalConstants.COLUMNS_SORT_ORDER_MAP.keys()) + '> | -c ]')
   print('       -h  show this help and exit')
   print('       -i  reference_file to be used for generating sample data file')
   print('       -o  output data file name')
   print('       -s  give name of sorting order to follow (' + " | ".join(globalConstants.COLUMNS_SORT_ORDER_MAP.keys()) + ')')
   print('       -c  continue without user confirmation (non-interactive mode)')


def generateSortedOutputFile(inFileName, outFileName, columnsForSorting, recordColSeparator):
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
   headerColumns = []
   infileRows = []
   cur_rec_idx = 0

   reader = csv.reader(infile, delimiter=recordColSeparator)
   for row in reader:
      cur_rec_idx = cur_rec_idx + 1
      # Place the first row into the header
      if cur_rec_idx == 1:
         headerColumns = row
         continue
      # Append all non-header rows into a list of data as a tuple of cells
      infileRows.append(tuple(row))

   for sortKey in reversed(columnsForSorting.keys()):
      colName = sortKey
      if colName in headerColumns:
         colIndex = headerColumns.index(colName)
         colSortOrder = columnsForSorting[colName]
         sortReverse = None
         if colSortOrder == "ASC":
            sortReverse = False
         if colSortOrder == "DESC":
            sortReverse = True
         print('Sorting Column %d ("%s") SortOrder=%s' % (colIndex, colName, colSortOrder))
         infileRows = sorted(infileRows, key=itemgetter(colIndex), reverse=sortReverse)
         print('Done sorting %d data rows (excluding header row) from %r' % ((cur_rec_idx - 1), inFileName))
      else:
         print('Sort on column "' + colName + '" skipped. It does not exist in input file.')

   # Write to output file
   writer = csv.writer(outfile, delimiter=recordColSeparator)
   writer.writerow(headerColumns)
   cur_rec_idx = 0
   for sorted_row in infileRows:
      cur_rec_idx = cur_rec_idx + 1
      writer.writerow(sorted_row)
      if (cur_rec_idx % processedRecordModulo) == 1 and cur_rec_idx != 1:
         print(' ... Writing record number ' + str(cur_rec_idx - 1).rjust(len(str(inFileSize)), "0"))

   infile.close()
   outfile.close()

   print('\nOutput file generated: ' + outFileName)
   

if not len(sys.argv) > 1:
   printUsage()
   sys.exit(1)

if __name__ == "__main__":
   main(sys.argv[1:])

