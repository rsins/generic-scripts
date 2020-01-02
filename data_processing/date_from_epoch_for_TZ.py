#!/usr/bin/python
#***************************************************************************
# Author      : Ravi Kant Singh
# Description : Python script to generate epoch time for a given date
# Created     : 11 June 2018
#***************************************************************************

from collections import OrderedDict
import sys, os, getopt
import pytz


# ------------------ Global Constant Values -------------------------------
class globalConstants():
   REPORTING_TIMEZONES_ALL = "_ALL_"
   # Time Zone Information as per Reporting TZ zones
   REPORTING_TIMEZONES = OrderedDict([
                                       ("T1"  , "US/Pacific"          ),  
                                       ("T2"  , "Asia/Hong_Kong"      ),  
                                       ("T3"  , "Europe/London"       ),  
                                       ("T4"  , "US/Eastern"          )
                                    ])


# ------------------ Global Variables -------------------------------------
class globalVars():
   timeZoneAbr          = None  # Selected Timezone Abreviation
   timeZone             = None  # Selected Timezone
   reportingEpochTime   = None  # Epoch time for which date needs to be generated.
   printSilent          = False # Flag to indicate if needs to print only value.


# Main Logic is in this function
def main(argv):

   # Check script arguments
   checkScriptArguments(argv)

   if globalVars.timeZoneAbr == globalConstants.REPORTING_TIMEZONES_ALL:
      for (tz_abr, tz_name) in globalConstants.REPORTING_TIMEZONES.items():
         generateDateFromEpochTime(globalVars.reportingEpochTime, tz_abr, tz_name, globalVars.printSilent)
         if not globalVars.printSilent:
            print("")
   else:
      generateDateFromEpochTime(globalVars.reportingEpochTime, globalVars.timeZoneAbr, globalVars.timeZone, globalVars.printSilent)


def checkScriptArguments(argv):
   try:
      opts, args = getopt.getopt(argv, "hsae:t:z:")
   except getopt.GetoptError as err:
      print(str(err))
      printUsage()
      sys.exit(1)

   for opt, arg in opts:
      if opt =='-h':
         printUsage()
         sys.exit()
      if opt =='-s':
         globalVars.printSilent = True
      elif opt == "-e":
         globalVars.reportingEpochTime = str(arg)
      elif opt == "-a":
         if globalVars.timeZoneAbr:
            print(' * Use only one of -z or -t or -a. \n')
            printUsage()
            sys.exit(1)
         globalVars.timeZoneAbr = globalConstants.REPORTING_TIMEZONES_ALL
         globalVars.timeZone = globalVars.timeZoneAbr
      elif opt == "-z":
         if globalVars.timeZoneAbr:
            print(' * Use either -z or -t or -a. \n')
            printUsage()
            sys.exit(1)
         globalVars.timeZoneAbr = str(arg)
         globalVars.timeZone = globalVars.timeZoneAbr
      elif opt == "-t":
         if globalVars.timeZoneAbr:
            print(' * Use either -z or -t or -a. \n')
            printUsage()
            sys.exit(1)
         globalVars.timeZoneAbr = str(arg)
         if globalVars.timeZoneAbr.upper() in globalConstants.REPORTING_TIMEZONES.keys():
            globalVars.timeZoneAbr = globalVars.timeZoneAbr.upper()
            globalVars.timeZone = globalConstants.REPORTING_TIMEZONES[globalVars.timeZoneAbr]
         else:
            print('\n* Invalid timezone = ' +  globalVars.timeZoneAbr + "\n")
            printUsage()
            sys.exit(1)

   if globalVars.reportingEpochTime == None or globalVars.timeZone == None:
      print('\n* Either TimeZone or Epoch Time is missing.\n')
      printUsage()
      sys.exit(1)


def printUsage():
   print('Usage: ' + str(sys.argv[0]) + ' [ -h | -e epoch_time (ms) | -t <' + ",".join(globalConstants.REPORTING_TIMEZONES.keys()) + '> | -z <timezone string> | -a | -s ]')
   print('       -h  show this help and exit')
   print('       -e  reporting epoch time (ms) for which date needs to be generated')
   print('       -z  timezone string (use either -t or -z or -a)')
   print('       -t  timezone abreviation for epoch format (use either -t or -z or -a)' \
       + "\n                 -> "  \
       + "\n                 -> ".join([(str(x[0]) + " = " + str(x[1])) for x in globalConstants.REPORTING_TIMEZONES.items()]))
   print('       -a  all internally supported timezones [' + ", ".join(globalConstants.REPORTING_TIMEZONES.keys()) + "] (use either -t or -z or -a)")
   print('       -s  print only the output value')


def generateDateFromEpochTime(reportingEpochTime, timeZoneAbr, timeZone, printSilent):
   try:
      pytz.timezone(timeZone)
   except:
      print(' * Invalid timezone provided = ' + timeZone)
      sys.exit(1)

   dateCmd = ''
   if not printSilent:
      print('Timezone (' + timeZoneAbr + ')  = ' + timeZone + '')
      dateCmd  = 'printf "Epoch Time (ms) = ' + reportingEpochTime + '\n      Date Time = "; '

   if sys.platform == "darwin":
      dateCmd += 'env TZ=":' + timeZone + '"  date -j -f "%s" "' + str(int(reportingEpochTime)/1000) +  '" "+%Y-%m-%d %H:%M:%S %Z" '
   else:
      dateCmd += 'env TZ=":' + timeZone + '"  date -d "@' + str(int(reportingEpochTime)/1000) + '" "+%Y-%m-%d %H:%M:%S %Z" '

   # Run Date commands to get converted date from epoch time.
   os.system(dateCmd)


if __name__ == "__main__":
   main(sys.argv[1:])

