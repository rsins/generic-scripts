#!/bin/bash

START_LINE=""
END_LINE=""
NO_OF_LINES=""
FILE_NAME=""

function test_params()
{
   while getopts "n:s:e:f:l:h" opt; do
      case "$opt" in
         "n") check_other_params $opt
              START_LINE="${OPTARG}"
              END_LINE="${OPTARG}"
              ;;
         "s") check_other_params $opt
              START_LINE="${OPTARG}"
              if test "$NO_OF_LINES" != ""
              then
                 END_LINE=`expr $START_LINE + $NO_OF_LINES - 1`
              fi
              ;;
         "e") check_other_params $opt
              END_LINE="${OPTARG}"
              ;;
         "l") check_other_params $opt
              NO_OF_LINES="${OPTARG}"
              if test "$START_LINE" != ""
              then
                 END_LINE=`expr $START_LINE + $NO_OF_LINES - 1`
              fi
              ;;
         "f") FILE_NAME="${OPTARG}"
              ;;
         "h") show_usage
              ;;
           ?) show_usage
              exit 1
              ;;
      esac
   done

   if test "$START_LINE" = "" -o "$END_LINE" = ""
   then
      show_usage
      exit 1
   fi
}

function check_other_params()
{
   CURRENT_PARAM="$1"
   case "$CURRENT_PARAM" in
      "n") if test "$START_LINE" != "" -o "$END_LINE" != ""
           then
              echo "Ambiguous params provided along with '-${CURRENT_PARAM}'."
              show_usage
              exit 1
           fi
           ;;
      "s" | "e" | "l") if test "$END_LINE" != ""
           then
              echo "Ambiguous params provided along with '-${CURRENT_PARAM}'."
              show_usage
              exit 1
           fi
           ;;
         ?) show_usage
            exit 1
            ;;
   esac
}

function show_usage()
{
   echo 'Usage : ' `basename $0` ' -n line_number -s start_line_number -e end_line_number -l  no_of_lines -f file_name'
}

function get_lines()
{
   if test "$FILE_NAME" != ""
   then
      if test ! -f "$FILE_NAME"
      then
         echo "$FILE_NAME does not exist or is a directory."
      fi
   else
      FILE_NAME="/dev/stdin"
   fi
   
   # Copy file to temp file for further processing. This is to handle pipe flow.
   TEMP_FILE=/tmp/.get_lines_tmp
   cat $FILE_NAME > $TEMP_FILE

   # Get Number of lines in the file.
   FILE_LENGTH=`wc -l $TEMP_FILE | awk '{print $1}'`

   # Check for file length and the lines numbers to be printed.
   if [ $START_LINE -gt $FILE_LENGTH ]
   then
      return
   fi
   if [ $END_LINE -gt $FILE_LENGTH ]
   then
      END_LINE=$FILE_LENGTH
   fi

   # Get the Lines
   OUTPUT_LENGTH=`expr $END_LINE - $START_LINE + 1`
   head -n $END_LINE $TEMP_FILE | tail -n $OUTPUT_LENGTH

   #cat $FILE_NAME | head -n $END_LINE | tail -n $OUTPUT_LENGTH
}

test_params $@
get_lines

