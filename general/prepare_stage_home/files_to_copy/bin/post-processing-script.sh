#!/bin/bash
# ---------------------------------------------------------
# Post Processing script for setup home
# ---------------------------------------------------------

REMOVE_SCRIPT="N"
REMOVE_ARCHIVES="N"
SCRIPT_FILE="$0"
POST_PROCESSING_LOG=~/home_setup_post_processing.log

function check_arguments()
{
   while true; do
	  case "$1" in
	      "--remove-script"   ) REMOVE_SCRIPT="Y"   ; shift ;;
	      "--remove-archives" ) REMOVE_ARCHIVES="Y" ; shift ;;
	      "--"                ) shift ;;
	      "-"                 ) shift ;;
		  	                * ) break ;;
      esac
   done
}

function unarchive_and_remove_compressed_file()
{
   ARCHIVE_FILE="$1"
   TARGET_FOLDER="$2"

   echo "----------------------------------------------"   >> ${POST_PROCESSING_LOG} 
   echo " START - `date "+%Y-%m-%d %I:%M:%S %p %A"`    "   >> ${POST_PROCESSING_LOG} 
   echo "----------------------------------------------"   >> ${POST_PROCESSING_LOG} 

   cd "${TARGET_FOLDER}"
   echo "  > un-archiving ${ARCHIVE_FILE}"

   echo "----------------------------------------------"   >> ${POST_PROCESSING_LOG} 
   echo " Issuing tar extract command on ${ARCHIVE_FILE} " >> ${POST_PROCESSING_LOG} 
   echo "----------------------------------------------"   >> ${POST_PROCESSING_LOG} 
   tar -zxf "${ARCHIVE_FILE}"                              >> ${POST_PROCESSING_LOG} 2>&1

   if [ "$REMOVE_ARCHIVES" = "Y" ]
   then
      echo "  > removing archive file ${ARCHIVE_FILE}"
      rm -f "${ARCHIVE_FILE}"
   fi

}

function create_soft_links_to_user_local_bin_files()
{
    echo "  > Create soft links into ~/bin/ folder"
	ln -sf ~/bin/local/bin/tig 		~/bin/
	ln -sf ~/bin/local/bin/unzip 	~/bin/
	ln -sf ~/bin/local/bin/zip 		~/bin/
}

function remove_script()
{
   # Removing the post processing script (running script) file.
   echo "  > removing ${SCRIPT_FILE}"
   if [ "$REMOVE_SCRIPT" = "Y" ]
   then
      rm -f "$SCRIPT_FILE"
   fi
}

function main()
{
   # Un-archiving the local bin folder
   unarchive_and_remove_compressed_file ~/bin/local.tar.gz ~/bin/

   # Create link to $home/local/bin files in $home/bin folder
   create_soft_links_to_user_local_bin_files

   remove_script

   echo "* Post Processing Script Log stored at ${POST_PROCESSING_LOG}"
}

check_arguments $@
main | tee -a ${POST_PROCESSING_LOG}

