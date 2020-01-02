#!/bin/bash
# *******************************************************
# Built By   : Ravi Kant Singh
# Created On : 01 Aug 2013
# 
# Description: Script to help with connecting to a DB.
#
# sqlplus user/pwd@"(DESCRIPTION=(ADDRESS_LIST=(ADDRESS=(PROTOCOL=TCP)(HOST=<server>)(PORT=1522)))(CONNECT_DATA=(SID=<sid>)))"
#
# *******************************************************

read -p "Server Name: " SERVERNAME
read -p "Port Number: " PORTNUMBER
read -p "SID Name: " SIDNAME
read -p "User Name: " USERNAME
read -p "Password: " -s USERPASSWORD

echo 
echo "Connecting to DB=$SERVERNAME:$PORTNUMBER:$SIDNAME User=$USERNAME"

SCRIPT="sqlplus $USERNAME/$USERPASSWORD@\"(DESCRIPTION=(ADDRESS_LIST=(ADDRESS=(PROTOCOL=TCP)(HOST=$SERVERNAME)(PORT=$PORTNUMBER)))(CONNECT_DATA=(SID=$SIDNAME)))\""

echo ""
#echo "* `date`" | tee -a $HOME/.last_script_history
#echo "$SCRIPT"  | tee -a $HOME/.last_script_history
echo "* `date`"
echo "$SCRIPT"

$SCRIPT

