#!/usr/bin/python

import sys, getopt
import os, subprocess

def printUsage():
   print('Usage: ', str(sys.argv[0]), ' [ -b | -h ] [program to run] file-path1 file-path2 ...')
   print('       -h  show this help and exit')
   print('       -b  run program in background and return immediately.')
   print(' ')
   print(' Converts the file-paths to absolute path then runs the program with them as arguments.')

def main(argv):
   b_run_in_background = None

   try:
      opts, args = getopt.getopt(argv, "hb")
   except getopt.GetoptError:
      printUsage()
      sys.exit(1)

   for opt, arg in opts:
      if opt =='-h':
         printUsage()
         sys.exit()
      elif opt =='-b':
         b_run_in_background = True

   cmd_txt = args[0]
   for f in args[1:]:
      cmd_txt += ' ' + getAbsolutePath(f)

   if (b_run_in_background):
      cmd_txt += " &"
   
   #sys.stdout.write(cmd_txt)
   subprocess.call(cmd_txt, shell=True)


def getAbsolutePath(f):
   return os.path.abspath(f)


if not len(sys.argv) > 1:
   printUsage()
   sys.exit()

if __name__ == "__main__":
   main(sys.argv[1:])

