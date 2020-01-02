#!/usr/bin/env python
#***************************************************************************
# Author      : Ravi Kant Singh
# Description : Python script to read Avro File and convert to json.
# Created     : 22 Oct 2018
#***************************************************************************

from avro.io import DatumReader
from avro.datafile import DataFileReader
import json, sys, time
import getopt

STATUS_IN_TERMINAL_AFTER_SECONDS = 10   # A status will be printed after these many seconds if output is going to a file.

# For some characters which can not be converted in ascii format by str()
reload(sys)
sys.setdefaultencoding('utf8')

is_pretty_print = False     # Pretty Print Json
in_file_name    = None      # Input File Name
out_file_name   = None      # Output File Name


def printUsage():
   print('Usage: ' + str(sys.argv[0]) + ' [ -h | -i input_file_name | -o output data file | -p ]')
   print('       -h  show this help and exit')
   print('       -i  input avro file')
   print('       -o  output file name')
   print('       -p  pretty print output json')


def processParams(argv):
    global in_file_name, out_file_name, is_pretty_print
    try:
       opts, args = getopt.getopt(argv, "hpi:o:")
    except getopt.GetoptError as err:
       print(str(err))
       printUsage()
       sys.exit(1)

    for opt, arg in opts:
       if opt =='-h':
          printUsage()
          sys.exit()
       elif opt == "-p":
          is_pretty_print = True
       elif opt == "-i":
          in_file_name = str(arg)
       elif opt == "-o":
          out_file_name = str(arg)

    if in_file_name is None:
        print(' * Nothing to do.')
        printUsage()
        sys.exit(1)


def openFile(file_name, arg):
    try:
        return open(file_name, arg)
    except:
        print(' * Error while opening file ' + file_name + " , mode = '" + arg + "'")
        sys.exit(1)


def main(args):
    global in_file_name, out_file_name
    processParams(args)

    print(' * Processing ' + in_file_name)
    ifh = openFile(in_file_name, "r")
    reader = DataFileReader(ifh, DatumReader())

    if out_file_name is None:
        print(' * Sending Output to STDOUT')
        ofh = sys.stdout
        print_progress_status = False
    else:
        print(' * Sending Output to ' + out_file_name)
        ofh = openFile(out_file_name, "w")
        print_progress_status = True

    rec_count = 0
    start_time = time.time()
    prev_time = start_time
    for rec in reader:
        rec_count += 1
        if is_pretty_print:
            rec_str = json.dumps(rec, indent=4, sort_keys=True)
            ofh.write("[" if (rec_count == 1) else ",\n")
        else:
            rec_str = json.dumps(rec)
            ofh.write("[" if (rec_count == 1) else ",")
        ofh.write(rec_str)
        cur_time = time.time()
        if (print_progress_status == True) and (int(cur_time - prev_time) >= STATUS_IN_TERMINAL_AFTER_SECONDS):
            print(" .... Processed record # " + str(rec_count))
            prev_time = cur_time

    ofh.write("]")
    reader.close()
    cur_time = time.time()
    print('\n * Processed ' + str(rec_count) + ' records in ' + str(int(round(cur_time - start_time))) + ' seconds.')

if __name__ == "__main__":
   main(sys.argv[1:])

