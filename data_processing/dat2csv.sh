#!/bin/bash -
#===============================================================================
#
#        AUTHOR: Ravi Singh (rsins), 
#   DESCRIPTION: Script to convert reporting data file to csv file.
#
#  REQUIREMENTS: ---
#         NOTES: ---
#       CREATED: 08/08/2018 13:27:47
#      REVISION: ---
#===============================================================================

SCRIPT_FOLDER="$( cd "$( dirname "$0" )"; pwd -P )"   # Script Directory Path 
set -o nounset                                        # Treat unset variables as an error

INFILE=
OUTFILE=
CONTINUE="FALSE"              # Flag to indicate if script needs to wait for user confirmation or not.
COL_DELIMITER="\007"          # Column delimeter in the input data file.

function printLine() {
   printf '%.0s-' {1..50}
   printf '\n';
}

function show_usage()
{
   echo 'Usage : ' `basename $0` ' [ -i input-file | -o output-file | -c | -h ]'
}

function test_params()
{
   while getopts "i:o:hc" opt; do
      case "$opt" in
         "i") INFILE="${OPTARG}"
              ;;
         "o") OUTFILE="${OPTARG}"
              ;;
         "c") CONTINUE="TRUE"
              ;;
     "h" | ?) show_usage
              exit 0
              ;;
      esac
   done

   if test "${INFILE}" = "" 
   then
   	  echo " * Input file name is required."
   	  echo ""
      show_usage
      exit 1
   fi

   if test "$OUTFILE" = ""
   then
      OUTFILE="${INFILE%.*}.csv"
   fi
}

function user_confirmation()
{
    if [ ! -f "${INFILE}" ]
    then
        echo " * Input file does not exist - '${INFILE}' "
        exit 1
    fi

    if [ "${INFILE}" == "${OUTFILE}" ]
    then
        echo " * Input and output files cannot be same - '${INFILE}' "
        exit 1
    fi

    echo
    printLine

    if [ -f "${OUTFILE}" ]
    then
        echo " * Output file already exists = '${OUTFILE}' "
    else
        echo " * Output file name  = '${OUTFILE}' "
    fi

    echo " * Input data file   = ${INFILE}"
    echo

    if [ "${CONTINUE}" == "TRUE" ]
    then
        echo "Continue..."
        return
    fi

    read -p "Continue? [y|Y|n|N]: " continue

    if test "$continue" = "y" -o "$continue" = "Y" -o "$continue" = "yes" -o "$continue" = "YES"
    then
       echo "Continue..."
    else
       echo "Exiting the script."
       exit
    fi
}

function data2csv() {
    inFile=$1
    outFile=$2
    cat "$inFile" | tr "${COL_DELIMITER}" "," > "${outFile}"
}


function main()
{
    inFile=$1
    outFile=$2

    data2csv "${inFile}" "${outFile}"

    echo
    echo " * ${outFile} created."
    echo
}

test_params $@
user_confirmation
main "${INFILE}" "${OUTFILE}"

