#!/bin/bash
# ----------------------------------------------------------------------
# This script sets ssh keys and also copies few files/folders to the
# target machine to prepare it for password less login and command line
# customizations.
# ----------------------------------------------------------------------

MACHINE_NAME=""

SCRIPT_FOLDER="$( cd "$( dirname "$0" )"; pwd -P )" 
FILE_FOLDER="files_to_copy"
FILES_TO_COPY="\
   ${SCRIPT_FOLDER}/${FILE_FOLDER}/.bashrc      \
   ${SCRIPT_FOLDER}/${FILE_FOLDER}/.cshrc       \
   ${SCRIPT_FOLDER}/${FILE_FOLDER}/.inputrc     \
   ${SCRIPT_FOLDER}/${FILE_FOLDER}/.screenrc    \
   ${SCRIPT_FOLDER}/${FILE_FOLDER}/.tigrc       \
   ${SCRIPT_FOLDER}/${FILE_FOLDER}/.vimrc       \
   ${SCRIPT_FOLDER}/${FILE_FOLDER}/.vim/        \
   ${SCRIPT_FOLDER}/${FILE_FOLDER}/bin/         \
   ${SCRIPT_FOLDER}/${FILE_FOLDER}/scripts/     \
"

function printLine() {
   printf '%.0s-' {1..50}
   printf '\n';
}

function show_usage()
{
   echo 'Usage : ' `basename $0` ' [ -h | -m stage_machine_name ]'
}

function test_params()
{
   while getopts "m:h" opt; do
      case "$opt" in
         "m") MACHINE_NAME="${OPTARG}"
              ;;
     "h" | ?) show_usage
              exit 0
              ;;
      esac
   done

   if test "$MACHINE_NAME" = "" 
   then
      show_usage
      exit 1
   fi
}

function user_confirmation()
{
   echo
   printLine
   echo "Following values to be used:"
   echo "MACHINE_NAME   = $MACHINE_NAME"
   echo "FILES_TO_COPY  = `echo $FILES_TO_COPY | awk '{ print $1; for (i=2; i<=NF; i++) print "\t\t "$i }'`"
   echo
   read -p "Continue? [y|Y|n|N]: " continue

   if test "$continue" = "y" -o "$continue" = "Y" -o "$continue" = "yes" -o "$continue" = "YES"
   then
      echo "Continue..."
   else
      echo "Exiting the script."
      exit
   fi
}

function copy_ssh_keys()
{
   printLine
   remote_machine=$1
   echo "* Copying ssh keys to remote machine - $1"
   ssh-copy-id -i ~/.ssh/id_rsa.pub $remote_machine
   
   #ssh $remote_machine << REMOTE_SCRIPT_HERE
   #  echo " > " mkdir -p ~/.ssh 
   #  mkdir -p ~/.ssh 
   #  echo " >  Adding ssh keys to ~/.ssh/authorized_keys"
   #  echo `cat ${SCRIPT_FOLDER}/${FILE_FOLDER}/.ssh/authorized_keys` >> ~/.ssh/authorized_keys 
   #  uniq ~/.ssh/authorized_keys > ~/.ssh/authorized_keys
   #  echo " > " chmod 600 ~/.ssh/authorized_keys
   #  chmod 600 ~/.ssh/authorized_keys
   #  echo " > " chmod 700 ~/.ssh
   #  chmod 700 ~/.ssh
   #REMOTE_SCRIPT_HERE
}

function copy_other_files()
{
   printLine
   remote_machine=$1
   echo "* Copying other files remote machine - $1"
   echo "* Files being copied : "
   echo $FILES_TO_COPY | awk '{ for (i=1; i<=NF; i++) print "\t"$i }'

   #remote_home=$(ssh $remote_machine 'echo ~/')
   remote_home='~/'
   echo
   echo "  > " scp -r $FILES_TO_COPY ${remote_machine}:${remote_home}
   scp -r $FILES_TO_COPY ${remote_machine}:${remote_home}
}

function post_processing_scripts()
{
   printLine
   remote_machine=$1
   echo "* Running post processing scripts on remote machine - $1"

   ssh -T $remote_machine 'bash ~/bin/post-processing-script.sh -- --remove-archives --remove-script'
}

function main()
{
   remote_machine=$1
   copy_ssh_keys $remote_machine
   copy_other_files $remote_machine
   post_processing_scripts $remote_machine

   printLine
   echo
   echo "* All activities completed."
   echo
}

test_params $@
user_confirmation
main $MACHINE_NAME

