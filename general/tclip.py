#!/usr/bin/python
#***************************************************************************
# Author      : Ravi Kant Singh
# Description : Python script to provide the clipboard functionality in terminal.
# Created     : 29 Dec 2013
#***************************************************************************

import sys, getopt, time
import os


# No of seconds as trigger, if script takes more than this time to collect all the text then
# user confirmation will be asked before script sets text to clipboard.
# This is to avoid unwanted clipboard action/interference if user gets on to some other activity.
STDIN_TIME_TRIGGER=30
TCLIP_FILE_PATH=os.path.expanduser("~") + "/.tclip"

def main(argv):
   b_from_clip = None       # flag - get text from clipboard
   b_to_clip = None         # flag - set text to clipboard from t_to_clip_text
   t_to_clip_text = None    # text - to be set to clipboard when input directly on the command line
   b_to_clip_stdin = None   # flag - get text from stdin/pipe and set to clipboard
   b_to_clip_print = False  # flag - print the text (to console/stdout) being set to clipboard

   try:
      opts, args = getopt.getopt(argv, "hoI:ip")
   except getopt.GetoptError:
      printUsage()
      sys.exit(1)

   for opt, arg in opts:
      if opt =='-h':
         printUsage()
         sys.exit()
      elif opt == "-o":
         b_from_clip = True
      elif opt in ("-I"):
         b_to_clip = True 
         t_to_clip_text = str(arg)
      elif opt == "-i":
         b_to_clip_stdin = True
      elif opt == "-p":
         b_to_clip_print = True

   if b_from_clip == True:
      getClipboard()

   if b_to_clip == True:
      if b_to_clip_print == True:
         print(t_to_clip_text)
      setClipboard(t_to_clip_text)

   if b_to_clip_stdin == True:
      setClipboardFromStdin(b_to_clip_print)


def printUsage():
   print('Usage: ', str(sys.argv[0]), ' [ -h | -o | -i and -p | -I text ]')
   print('       -h  show this help and exit')
   print('       -o  print current text from clipboard')
   print('       -i  set current clipboard text with text from stdin')
   print('       -I  set current clipboard text with text provided in the arguments')
   print('       -p  print text being set to clipboard to stdout too')


def getClipboard():
   try:
      with open(TCLIP_FILE_PATH, 'r') as tclip_file:
         text = tclip_file.read()
         if text is not None:
            print(text)
   except IOError as e:
      sys.exit(0)


def setClipboard(arg):
   with open(TCLIP_FILE_PATH, 'w') as tclip_file:
      tclip_file.write("%s" % arg)


def setClipboardFromStdin(b_stdout_print):
   start_time=time.time()
   text=''
   while 1:
      try:
         line = sys.stdin.readline() 
         if b_stdout_print == True: 
            sys.stdout.write(line)
      except KeyboardInterrupt:
         sys.exit(1)
      if not line:
         break
      if text == '':
         text = line
      else:
         text += line 
   text = text[:-1]
   end_time = time.time() - start_time
   # If stdin time exceeds the trigger then check with user for confirmation.
   # This is because of time taken to run the script and user might be busy with 
   # other work involving copy paste.
   if end_time > STDIN_TIME_TRIGGER:
      print("\n-------------- User Attention Required -----------------")
      print("Time taken to get text from stdin exceeds ",STDIN_TIME_TRIGGER," seconds.")
      print("    Actual time taken: ",secondsToStr(end_time)," seconds.")
      print("    Length of text in buffer: ",len(text)," characters.")
      print("Do you want to continue and set the text to clipboard now?")
      continuerun = raw_input(" " * 30 + "default is yes [y|n|yes|no]: ")
      continuerun = continuerun.strip()
      if continuerun in ('y','Y','yes','YES',''):
         print("Continue to set clipboard with captured text.")
      elif continuerun in ('n','N','no','NO'):
         print("Skipping and not setting the clipboard text.")
         sys.exit()
      else:
         print("Invalid input. Skipping and not setting the clipboard text.")
         sys.exit(1)
   # This is where function to set clipboard text is called.
   setClipboard(text)


def secondsToStr(t):
    return "%d:%02d:%02d.%03d" % \
            reduce(lambda ll,b : divmod(ll[0],b) + ll[1:],
                       [(t*1000,),1000,60,60])


if not len(sys.argv) > 1:
   printUsage()
   sys.exit(1)

if __name__ == "__main__":
   main(sys.argv[1:])

