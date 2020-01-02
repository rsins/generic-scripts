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
   timeZoneAbr        = None # Selected Timezone Abreviation
   timeZone           = None # Selected Timezone
   reportingDateStr   = None # Date string for which epoch date needs to be generated.
   printEpochRange    = None # Flag to indicate if needs to print start and end range for given date
   printSilent        = False # Flag to indicate if needs to print only value.


# Main Logic is in this function
def main(argv):

   # Check script arguments
   checkScriptArguments(argv)

   if globalVars.timeZoneAbr == globalConstants.REPORTING_TIMEZONES_ALL:
      for (tz_abr, tz_name) in globalConstants.REPORTING_TIMEZONES.items():
         generateEpochTimeFromDate(globalVars.printEpochRange, globalVars.reportingDateStr, tz_abr, tz_name, globalVars.printSilent)
         if not globalVars.printSilent:
            print("")
   else:
      generateEpochTimeFromDate(globalVars.printEpochRange, globalVars.reportingDateStr, globalVars.timeZoneAbr, globalVars.timeZone, globalVars.printSilent)


def checkScriptArguments(argv):
   try:
      opts, args = getopt.getopt(argv, "hsad:D:t:z:")
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
      elif opt == "-d":
         if globalVars.reportingDateStr:
            print(' * Use only one of -D or -d. \n')
            printUsage()
            sys.exit(1)
         globalVars.reportingDateStr = str(arg)
         globalVars.printEpochRange = True
      elif opt == "-D":
         if globalVars.reportingDateStr:
            print(' * Use only one of -D or -d. \n')
            printUsage()
            sys.exit(1)
         globalVars.reportingDateStr = str(arg)
         globalVars.printEpochRange = False
      elif opt == "-a":
         if globalVars.timeZoneAbr:
            print(' * Use only one of -z or -t or -a. \n')
            printUsage()
            sys.exit(1)
         globalVars.timeZoneAbr = globalConstants.REPORTING_TIMEZONES_ALL
         globalVars.timeZone = globalVars.timeZoneAbr
      elif opt == "-z":
         if globalVars.timeZoneAbr:
            print(' * Use only one of -z or -t or -a. \n')
            printUsage()
            sys.exit(1)
         globalVars.timeZoneAbr = str(arg)
         globalVars.timeZone = globalVars.timeZoneAbr
      elif opt == "-t":
         if globalVars.timeZoneAbr:
            print(' * Use only one of -z or -t or -a. \n')
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

   if globalVars.reportingDateStr == None or globalVars.timeZone == None:
      print('\n* Either TimeZone or Date is missing.\n')
      printUsage()
      sys.exit(1)


def printUsage():
   print('Usage: ' + str(sys.argv[0]) + ' [ -h | -d date (YYYY-MM-DD) | -D date_time (YYYY-MM-DD HH:MM:SS 24 hour format) | -t <' + ",".join(globalConstants.REPORTING_TIMEZONES.keys()) + '> | -z <timezone string> | -a | -s ]')
   print('       -h  show this help and exit')
   print('       -d  reporting date in "YYYY-MM-DD" format for which start & end of day epoch time needs to be generated (use either -d or -D)')
   print('       -D  reporting date in "YYYY-MM-DD HH:MM:SS" format for which epoch time needs to be generated (use either -d or -D)')
   print('       -z  timezone string (use either -t or -z or -a)')
   print('       -t  timezone abreviation for epoch format (use either -t or -z or -a)' \
       + "\n                 -> "  \
       + "\n                 -> ".join([(str(x[0]) + " = " + str(x[1])) for x in globalConstants.REPORTING_TIMEZONES.items()]))
   print('       -a  all internally supported timezones [' + ", ".join(globalConstants.REPORTING_TIMEZONES.keys()) + "] (use either -t or -z or -a)")
   print('       -s  print only the output value')


def generateEpochTimeFromDate(printEpochRange, reportingDateStr, timeZoneAbr, timeZone, printSilent):
   if printEpochRange:
      generateEpochTimeFromDate_Range(reportingDateStr, timeZoneAbr, timeZone, printSilent)
   else:
      generateEpochTimeFromDate_Single(reportingDateStr, timeZoneAbr, timeZone, printSilent)


def generateEpochTimeFromDate_Single(reportingDateStr, timeZoneAbr, timeZone, printSilent):
   year = reportingDateStr[0:4]
   month = reportingDateStr[5:7]
   day = reportingDateStr[8:10]
   time = reportingDateStr[12:19]

   try:
      pytz.timezone(timeZone)
   except:
      print(' * Invalid timezone provided = ' + timeZone)
      sys.exit(1)

   dateCmd = ''
   if not printSilent:
      print('Timezone (' + timeZoneAbr + ')   = ' + timeZone + '')
      dateCmd = 'printf "Date Time        = ' + reportingDateStr + '\nEpoch time in ms = "; '

   if sys.platform == "darwin":
      dateCmd += 'env TZ=":' + timeZone + '"  date -j -f "%Y-%m-%d %H:%M:%S" "' + year + '-' + month + '-' + day + ' ' + time + '" "+%s000" '
   else:
      dateCmd += 'env TZ=":' + timeZone + '"  date -d "' + month + '/' + day + '/' + year + ' ' + time + '" "+%s000" '

   # Run Date commands to get converted epoch time.
   os.system(dateCmd)


def generateEpochTimeFromDate_Range(reportingDateStr, timeZoneAbr, timeZone, printSilent):
   year = reportingDateStr[0:4]
   month = reportingDateStr[5:7]
   day = reportingDateStr[8:10]

   try:
      pytz.timezone(timeZone)
   except:
      print(' * Invalid timezone provided = ' + timeZone)
      sys.exit(1)

   dateCmdStart = ''
   dateCmdEnd = ''
   if not printSilent:
      print('Timezone (' + timeZoneAbr + ')  = ' + timeZone + '')
      dateCmdStart = 'printf "Start Date Time = ' + reportingDateStr[0:10] + ' 00:00:00, Epoch time in ms = "; '
      dateCmdEnd   = 'printf "End   Date Time = ' + reportingDateStr[0:10] + ' 23:59:59, Epoch time in ms = "; '

   if sys.platform == "darwin":
      dateCmdStart += 'env TZ=":' + timeZone + '"  date -j -f "%Y-%m-%d %H:%M:%S" "' + year + '-' + month + '-' + day + ' 00:00:00" "+%s000" '
      dateCmdEnd   += 'env TZ=":' + timeZone + '"  date -j -f "%Y-%m-%d %H:%M:%S" "' + year + '-' + month + '-' + day + ' 23:59:59" "+%s000" '
   else:
      dateCmdStart += 'env TZ=":' + timeZone + '"  date -d "' + month + '/' + day + '/' + year + ' 00:00:00" "+%s000" '
      dateCmdEnd   += 'env TZ=":' + timeZone + '"  date -d "' + month + '/' + day + '/' + year + ' 23:59:59" "+%s000" '

   # Run Date commands to get converted epoch time.
   os.system(dateCmdStart)
   os.system(dateCmdEnd)


if __name__ == "__main__":
   main(sys.argv[1:])

