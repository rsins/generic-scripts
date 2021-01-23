#!/bin/bash -
#===============================================================================
#
#        AUTHOR: Ravi Singh (rsins), 
#   DESCRIPTION: Script to start or stop or restart the apps in certain order.
#                Assumption is hadoop and spark were installed on mac using brew.
#
#  REQUIREMENTS: ---
#         NOTES: ---
#       CREATED: 11/25/2018 10:28:03
#      REVISION: ---
#===============================================================================

if [ "`which hdfs`" == "" ]
then
	echo "** hadoop binary not found in path."
	exit 1
fi
if [ "`which spark-submit`" == "" ]
then
	echo "** spark binary not found in path."
	exit 1
fi

HADOOP_VERSION=`hdfs version 2>&1 | head -n 1 | awk -F' ' '{ print $NF}'`
HADOOP_VERSION_FOLDER=`ls -l $(which hdfs) | awk -F' ' '{print $NF}' | awk '{sub("../", "/usr/local/"); sub("/bin"," "); print $1}'`
HADOOP_INSTALL_FOLDER=${HADOOP_VERSION_FOLDER}

SPARK_VERSION=`spark-submit --version 2>&1 | grep version | head -n 1 | awk -F' ' '{ print $NF}'`
SPARK_VERSION_FOLDER=`ls -l $(which spark-submit) | awk -F' ' '{print $NF}' | awk '{sub("../", "/usr/local/"); sub("/bin"," "); print $1}'`
SPARK_INSTALL_FOLDER=${SPARK_VERSION_FOLDER}

echo ""
echo "Using Hadoop Version = ${HADOOP_VERSION}, Hadoop Install Folder = ${HADOOP_INSTALL_FOLDER}"
echo "Using Spark  Version = ${SPARK_VERSION}, Spark  Install Folder = ${SPARK_INSTALL_FOLDER}"

SCRIPT_FOLDER="$( cd "$( dirname "$0" )"; pwd -P )"   # Script Directory Path 

ACTIONS=("setup" "start" "stop" "restart")
APPS=("all" "hadoop" "spark")
RUN_MULTIPLE="REPEAT"

printLine() {
   printf '%.0s-' {1..50}
   printf '\n';
}

printArt() {
   printf '\n  [0;1;34;94m░█▀▄░█▀█░█░█░▀█▀[0;34m░░░█░█░█▀█░█▀█░▀[0;37m█▀░░░█▀▀░▀█▀░█▀█[0;1;30;90m░█▀▀░█░█[0m'
   printf '\n  [0;1;34;94m░█▀▄░█▀█[0;34m░▀▄▀░░█░░░░█▀▄░█[0;37m▀█░█░█░░█░░░░▀▀█[0;1;30;90m░░█░░█░█░█░█░█▀█[0m'
   printf '\n  [0;34m░▀░▀░▀░▀░░▀░░▀▀▀[0;37m░░░▀░▀░▀░▀░▀░▀░░[0;1;30;90m▀░░░░▀▀▀░▀▀▀░▀░▀[0;1;34;94m░▀▀▀░▀░▀[0m'
   printf '\n\n'
}

usage() {
   #echo "Usage $0 [" `joinArrayToStrings " | " ${ACTIONS[*]}` "] [" `joinArrayToStrings " | " ${APPS[*]}` "]"
   #echo "      or "
   #echo "      $0"
   echo
   echo "Usage 1) $0 <no parameters>"
   echo "      2) $0 ScriptAction AppName1 AppName2 . . ."
   echo "      3) $0 ScripAction AppName"
   echo "            ScripAction =>"
   for arrIndex in `seq 0 $((${#ACTIONS[*]} -1 ))`
   do
      echo "              $arrIndex) ${ACTIONS[arrIndex]}"
   done
   echo "            AppName =>"
   for arrIndex in `seq 0 $((${#APPS[*]} -1 ))`
   do
      echo "              $arrIndex) ${APPS[arrIndex]}"
   done
   echo
}

printOnlyParams() {
   if [ "$1" = "1" ]  # Only actions
   then
      for arrIndex in `seq 0 $((${#ACTIONS[*]} -1 ))`
      do
         printf "%s " "$arrIndex:${ACTIONS[arrIndex]}"
      done
   fi
   if [ "$1" = "2" ]  # Only applications
   then
      for arrIndex in `seq 0 $((${#APPS[*]} -1 ))`
      do
         printf "%s " "$arrIndex:${APPS[arrIndex]}"
      done
   fi
}

paramCheckUsage() {
   echo "All parameters should be correctly specified."
   usage
}

checkParams() {
   paramCount=$#
   scriptAction="$1"
   appName="$2"
   shift 
   otherParams=( "$@" )    # to be used if more than one app names are there in the input

   if [ $paramCount -eq 1 -a "$scriptAction" = "-h" ]
   then
      usage
      exit 0
   elif [ $paramCount -eq 1 -a "$scriptAction" = "-p1" ]
   then
      printOnlyParams 1
      exit 0
   elif [ $paramCount -eq 1 -a "$scriptAction" = "-p2" ]
   then
      printOnlyParams 2
      exit 0
   # Check if there are more than one apps in the input parameter
   elif [ $paramCount -gt 2 ]
   then
      appName="$RUN_MULTIPLE"
   fi

   if [  $paramCount -ge 1 ] && { [ "$scriptAction" = "" -o "$appName" = "" ]; } 
   then
      # Either both params to be supplied or no parameters.
      echo "At least two parameters are required."
      usage
      exit 1
   elif [ $paramCount = 0 ]
   then
      # ask user for parameters if none are there in input params
      getUserInput scriptAction ACTIONS[@] "Enter action number"
      getUserInput appName APPS[@] "Enter app number"
   else
      # Removing ':' if it came as part of bash auto-complete parameters.
      scriptAction=`sanitizeParam $scriptAction`
      appName=`sanitizeParam $appName`
      # Support index value instead of name too.
      if [ `isNumber $scriptAction` -eq 1 ]
      then
         scriptAction=${ACTIONS[$scriptAction]}
      fi
      if [ `isNumber $appName` -eq 1 ]
      then
         appName=${APPS[$appName]}
      fi
   fi

   # Check if the parameter is to run multiple scripts in order given in input.
   if [ "$appName" = "$RUN_MULTIPLE" ]
   then
      for appIndex in `seq 0 $((${#otherParams[@]} -1))`;
      do
         curParam="${otherParams[appIndex]}"
         curParam=`sanitizeParam $curParam`
         if [ `isNumber ${curParam}` -eq 1 ]
         then
            appIndexName="${APPS[curParam]}"
            if [ `arrayContainsElement "$appIndexName" APPS[@]` -eq 0 ]
            then
               paramCheckUsage
               exit 2
            fi
            otherParams[appIndex]="${appIndexName}"
         fi
      done
   else
      # Check if the options are within the specified values.
      if [    `arrayContainsElement "$scriptAction" ACTIONS[@]` -eq 0  \
           -o `arrayContainsElement "$appName" APPS[@]` -eq 0          \
         ]
      then
         paramCheckUsage
         exit 2
      fi
   fi
}

userConfirmation() {
   if [ "$appName" = "$RUN_MULTIPLE" ]
   then
      scriptMsg="$scriptAction ${otherParams[@]}"
   else
      scriptMsg="$scriptAction $appName"
   fi
   echo
   read -p "* $scriptMsg -> continue? [y|n] : " continue
   if [ "$continue" = "y" -o "$continue" = "Y" ]
   then
      printf "%s\n\n" "Continue script for $scriptMsg . . ."
   else
      printf "%s\n\n" "Exiting script . . ."
      exit 0
   fi
}

getUserInput() {
   varName="$1"
   arrOptions=("${!2}")
   promptMsg="$3"
   echo "-------------"
   for arrIndex in `seq 0 $((${#arrOptions[*]} -1 ))`
   do
      echo "$arrIndex) ${arrOptions[arrIndex]}"
   done
   read -p "$promptMsg : " index
   if [ `isNumber $index` -eq 1 ]
   then
      eval "$varName=${arrOptions[index]}"
   else
      eval "$varName="
   fi
}

arrayContainsElement() {
   value="$1"
   arrOptions=("${!2}")
   for element in "${arrOptions[@]}"
   do
      if [ "$element" = "$value" ]
      then
         echo 1
         return
      fi
   done
   echo 0
}

sanitizeParam() {
   echo "$1" | cut -d':' -f 1
}

isNumber() {
   if [[ "$1" =~ ^-?[0-9]+[.,]?[0-9]*$ ]]; then echo 1; else echo 0; fi
}

joinArrayToStrings() 
{
   local d=$1; shift; echo -n "$1"; shift; printf "%s" "${@/#/$d}";
}

setupApp() {
   printLine
   if [ `arrayContainsElement "${1}" APPS[@]` -eq 1 ]
   then
      echo "# Checking settings for ${1} ..."
      "setup_${1}"
   fi
}

setup_all() {
	setup_hadoop
	setup_spark
}

setup_hadoop() {
   printLine
   echo "-> * Validating setup for hadoop." 
   hconf1=${HADOOP_INSTALL_FOLDER}/libexec/etc/hadoop/core-site.xml
   hconf2=${HADOOP_INSTALL_FOLDER}/libexec/etc/hadoop/hdfs-site.xml

   continue=Y
   # If called from startup then if conf file already exists then don't overwrite else create the conf file.
   if [ "$1" = "silent" -a -f "$hconf1" ]
   then
   	   continue=N
   elif [ -f "$hconf1" ]
   then
   	   read -p "* Conf file already exists '$hconf1' -> overwrite? [y/n] : " continue
   fi
   if [ "$continue" = "y" -o "$continue" = "Y" ]
   then
   	   echo "* Writing to $hconf1"
       cat > $hconf1 << CONFDATA
<?xml version="1.0" encoding="UTF-8"?>
<?xml-stylesheet type="text/xsl" href="configuration.xsl"?>
<configuration>
    <property>
        <name>fs.defaultFS</name>
        <value>hdfs://localhost:9010</value>
    </property>

    <property>
        <name>hadoop.tmp.dir</name>
        <value>/export/data/hadoop/dfs/tmp</value>
    </property>
</configuration>
CONFDATA
   fi

   continue=Y
   # If called from startup then if conf file already exists then don't overwrite else create the conf file.
   if [ "$1" = "silent" -a -f "$hconf2" ]
   then
   	   continue=N
   elif [ -f "$hconf2" ]
   then
   	   read -p "* Conf file already exists '$hconf2' -> overwrite? [y/n] : " continue
   fi
   if [ "$continue" = "y" -o "$continue" = "Y" ]
   then
   	   echo "* Writing to $hconf2"
       cat > $hconf2 << CONFDATA
<?xml version="1.0" encoding="UTF-8"?>
<?xml-stylesheet type="text/xsl" href="configuration.xsl"?>
<configuration>
    <property>
        <name>dfs.replication</name>
        <value>1</value>
    </property>

    <property>
        <name>dfs.namenode.name.dir</name>
        <value>file:///export/data/hadoop/dfs/namenode</value>
    </property>

    <property>
        <name>dfs.datanode.data.dir</name>
        <value>file:///export/data/hadoop/dfs/datanode</value>
    </property>
</configuration>
CONFDATA
   fi
}

setup_spark() {
   printLine
   echo "-> * Validating setup for spark." 
   sconf1=${SPARK_INSTALL_FOLDER}/libexec/conf/spark-defaults.conf
   sconf2=${SPARK_INSTALL_FOLDER}/libexec/conf/spark-env.sh

   continue=Y
   # If called from startup then if conf file already exists then don't overwrite else create the conf file.
   if [ "$1" = "silent" -a -f "$sconf1" ]
   then
   	   continue=N
   elif [ -f "$sconf1" ]
   then
   	   read -p "* Conf file already exists '$sconf1' -> overwrite? [y/n] : " continue
   fi
   if [ "$continue" = "y" -o "$continue" = "Y" ]
   then
   	   echo "* Writing to $sconf1"
       cat > $sconf1 << CONFDATA
spark.master                     spark://localhost:7077
spark.driver.memory              1g
spark.driver.cores               1
spark.executor.memory            1g
spark.eventLog.enabled           true
spark.eventLog.dir               hdfs://localhost:9010/spark/
spark.history.fs.logDirectory    hdfs://localhost:9010/spark/
spark.serializer                 org.apache.spark.serializer.KryoSerializer
spark.ui.port                    4040
spark.dynamicAllocation.enabled  false
spark.shuffle.service.enabled    false
CONFDATA
   fi

   continue=Y
   # If called from startup then if conf file already exists then don't overwrite else create the conf file.
   if [ "$1" = "silent" -a -f "$sconf2" ]
   then
   	   continue=N
   elif [ -f "$sconf2" ]
   then
   	   read -p "* Conf file already exists '$sconf2' -> overwrite? [y/n] : " continue
   fi
   if [ "$continue" = "y" -o "$continue" = "Y" ]
   then
   	   echo "* Writing to $sconf2"
       cat > $sconf2 << CONFDATA
HADOOP_CONF_DIR=${HADOOP_INSTALL_FOLDER}/libexec/etc/hadoop/
SPARK_MASTER_WEBUI_PORT=4444
SPARK_WORKER_CORES=2
SPARK_WORKER_MEMORY=2g
SPARK_EXECUTOR_MEMORY=1g
SPARK_EXECUTOR_CORES=1
SPARK_DRIVER_MEMOR=1g
SPARK_LOCAL_IP=localhost
SPARK_MASTER_PORT=7077
SPARK_MASTER_HOST=localhost
CONFDATA
   fi
}

startApp() {
   printLine
   if [ `arrayContainsElement "${1}" APPS[@]` -eq 1 ]
   then
      echo "# starting ${1} ..."
      "start_${1}"
   fi
}

start_all() {
	start_hadoop
	start_spark
}

start_hadoop() {
   printLine
   # Check if any setup is required (due to update to software version)
   setup_hadoop silent
   echo "-> * ${HADOOP_INSTALL_FOLDER}/sbin/start-all.sh"
   ${HADOOP_INSTALL_FOLDER}/sbin/start-all.sh
   echo "-> * Hadoop UI = http://localhost:8088/ "
}

start_spark() {
   printLine
   # Check if any setup is required (due to update to software version)
   setup_spark silent
   echo "-> * ${SPARK_INSTALL_FOLDER}/libexec/sbin/start-all.sh"
   ${SPARK_INSTALL_FOLDER}/libexec/sbin/start-all.sh
   printLine
   echo "-> * ${SPARK_INSTALL_FOLDER}/libexec/sbin/start-history-server.sh"
   ${SPARK_INSTALL_FOLDER}/libexec/sbin/start-history-server.sh
   echo "-> * Spark Master  UI = http://localhost:4444/ "
   echo "-> * Spark History UI = http://localhost:18080/ "

}

stopApp() {
   printLine
   if [ `arrayContainsElement "${1}" APPS[@]` -eq 1 ]
   then
      echo "# stopping ${1} ..."
      "stop_${1}"
   fi
}

stop_all() {
	stop_spark
	stop_hadoop
}

stop_hadoop() {
   printLine
   echo "-> * ${HADOOP_INSTALL_FOLDER}/sbin/stop-all.sh"
   ${HADOOP_INSTALL_FOLDER}/sbin/stop-all.sh
}

stop_spark() {
   printLine
   echo "-> * ${SPARK_INSTALL_FOLDER}/libexec/sbin/stop-history-server.sh"
   ${SPARK_INSTALL_FOLDER}/libexec/sbin/stop-history-server.sh
   printLine
   echo "-> * ${SPARK_INSTALL_FOLDER}/libexec/sbin/stop-all.sh"
   ${SPARK_INSTALL_FOLDER}/libexec/sbin/stop-all.sh
}

main() {
   if [ "$appName" = "$RUN_MULTIPLE" ]
   then
      case "$scriptAction" in
         "setup")
            for appIndexName in "${otherParams[@]}"
            do
               setupApp "$appIndexName"
            done
            ;;
         "start")
            for appIndexName in "${otherParams[@]}"
            do
               startApp "$appIndexName"
            done
            ;;
         "stop")
            for appIndexName in "${otherParams[@]}"
            do
               stopApp "$appIndexName"
            done
            ;;
         "restart")
            for appIndexName in "${otherParams[@]}"
            do
               stopApp "$appIndexName"
            done
            printLine
            # Loop through in reverse to start the apps in reverse
            for (( idx=${#otherParams[@]} -1 ; idx >= 0 ; idx-- )) 
            do
               startApp "${otherParams[idx]}"
            done
            ;;
      esac
   else
      case "$scriptAction" in
         "setup")
            setupApp "$appName"
            ;;
         "start")
            startApp "$appName"
            ;;
         "stop")
            stopApp "$appName"
            ;;
         "restart")
            stopApp "$appName"
            printLine
            startApp "$appName"
            ;;
      esac
   fi
}

# -- Here starts the main activity --
printArt
checkParams $@
userConfirmation
main
