#!/bin/bash

# It accepts first argument as number of columns to display colors.
# Else it calculates automatically based on screen size.

if [ -z $1 ]; then
	TAB_SIZE=`printf "a\tb" | expand | wc -c | xargs printf "%s %s" "-1 +" | xargs expr`
	TERM_LINE_SIZE=`tput cols`
    BREAK=`expr $TERM_LINE_SIZE / \( $TAB_SIZE + 9 \)`
else
    BREAK=$1
fi
for i in {0..255} ; do
    printf "\x1b[38;5;${i}mcolour${i} \t"
    if [ $(( i % $BREAK )) -eq $(($BREAK-1)) ] ; then
        printf "\n"
    fi
done
echo

