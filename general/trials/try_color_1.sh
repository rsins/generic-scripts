#!/bin/bash

FG_COL=( "" )
BG_COL=( "41" "42" "43" "44" "45" "46" "47" )

# Parameters:
#   - text
#   - positionX
#   - positionY
printAtPos()
{
   PrintText=$1
   TEXT_PositionX=$2
   TEXT_PositionY=$3

   tput cup $TEXT_PositionY $TEXT_PositionX
   printf "$PrintText"
}

# Parameters:
#   - text
#   - positionX
#   - positionY
#   - length
#   - bold [y/n]
#   - center [y/n]
#   - padding character
#   - Color Format
myprint() 
{
   PrintText=""

   TEXT_Value="$1"
   TEXT_PositionX=$2
   TEXT_PositionY=$3
   TEXT_Length=$4
   TEXT_Bold=$5
   TEXT_Center=$6
   TEXT_Padding="$7"
   TEXT_BG_FG_Format="$8"

   formattext PrintText "$TEXT_Value" $TEXT_Length "$TEXT_Center" "$TEXT_Padding"

   if test "$TEXT_Bold" = "y" -o "$TEXT_Bold" = "Y"
   then
   	  if test -z "$TEXT_BG_FG_Format"
   	  then
         tput smso
         printAtPos "$PrintText" $TEXT_PositionX $TEXT_PositionY
         tput rmso
      else
         printAtPos "${EINS}${TEXT_BG_FG_Format}${PrintText}\033[0m" $TEXT_PositionX $TEXT_PositionY
      fi
   else
      printAtPos "$PrintText" $TEXT_PositionX $TEXT_PositionY
   fi

}

# Parameters:
#   - output variable
#   - input Text
#   - output length
#   - center [y/n]
#   - Padding Character
formattext()
{
   local __myresultvar=$1
   local myresult=""
   Text_inputText="$2"
   Text_outputLength=$3
   Text_Center="$4"
   Text_Padding="$5"

   if test ${#Text_inputText} -gt $Text_outputLength
   then
      myresult=${Text_inputText:0:$Text_outputLength}
   fi
   if test ${#Text_inputText} = $Text_outputLength
   then
      myresult=$Text_inputText
   fi
   if test ${#Text_inputText} -lt $Text_outputLength
   then
      if test "$Text_Center" = "y" -o "$Text_Center" = "Y"
      then
         LeftPaddingLen=`expr \( $Text_outputLength - ${#Text_inputText} \) / 2`
         RightPaddingLen=`expr $Text_outputLength - $LeftPaddingLen - ${#Text_inputText}`
         myresult=`printf %"${LeftPaddingLen}s" | tr " " "$Text_Padding"`
      else
         LeftPaddingLen=0
         myresult=""
         RightPaddingLen=`expr $Text_outputLength - $LeftPaddingLen - ${#Text_inputText}`
      fi
      
      myresult+=$Text_inputText
      myresult+=`printf %"${RightPaddingLen}s" | tr " " "$Text_Padding"`
   fi

   eval $__myresultvar="'$myresult'"
}

# Parameters:
#   - lowX
#   - maxX
#   - lowY
#   - maxY
#   - textFormat in bash terminal format E.g. \033[1;32m
#   - Fill or do not fill
drawRectangle() {
   lowX=$1
   maxX=$2
   lowY=$3
   maxY=$4
   bold=$5
   text_format=$6
   rect_fill=`if test -z "$7"; then echo "n"; else echo "$7"; fi`

   myprint "" $lowX $lowY `expr $maxX - $lowX + 1` $bold y " " "$text_format"
   myprint "" $lowX $maxY `expr $maxX - $lowX + 1` $bold y " " "$text_format"
   j=`expr $lowY + 1`
   while test $j -le `expr $maxY - 1`
   do
   	  if test "$rect_fill" = "y" -o "$rect_fill" = "Y"
   	  then
         formattext PrintText "" `expr $maxX - $lowX + 1` y " "
         PrintText="${EINS}${text_format}${PrintText}\033[0m"
   	  else
         formattext PrintText "" `expr $maxX - $lowX - 1` y " "
         PrintText="${EINS}${text_format} \033[0m${PrintText}${text_format} \033[0m"
      fi
      printAtPos "$PrintText" $lowX $j
      j=`expr $j + 1`
   done

   tput cup $lowY $lowX
}

try1() {
   BG_COL_IDX=`expr $RANDOM % ${#BG_COL[@]} `
   MENU_FORMAT="\033[${FG_COL[0]};${BG_COL[BG_COL_IDX]}m"
   clear 
   echo "Creating menu in text format. Press any key to continue."
   read -n 1 -s
   clear
   myprint ""              0  0  `tput cols` y y " " $MENU_FORMAT
   myprint "My Screen"     0  1  `tput cols` y y "_" $MENU_FORMAT
   myprint ""              0  2  `tput cols` y y " " $MENU_FORMAT
   myprint "  1. Option 1" 0  3  `tput cols` n n "." $MENU_FORMAT
   myprint "  2. Option 2" 0  4  `tput cols` n n "." $MENU_FORMAT
   myprint ""              0  5  `tput cols` n n "." $MENU_FORMAT
   myprint ""              0  6  `tput cols` n n "." $MENU_FORMAT
   myprint ""              0  7  `tput cols` n n "." $MENU_FORMAT
   myprint ""              0  8  `tput cols` n n "." $MENU_FORMAT
   myprint ""              0  9  `tput cols` n n "." $MENU_FORMAT
   myprint ""              0  10 `tput cols` n n "." $MENU_FORMAT
   myprint ""              0  11 `tput cols` n n "." $MENU_FORMAT
   myprint ""              0  12 `tput cols` n n "." $MENU_FORMAT
   myprint ""              0  13 `tput cols` n n "." $MENU_FORMAT
   myprint ""              0  14 `tput cols` n n "." $MENU_FORMAT
   myprint ""              0  15 `tput cols` n n "." $MENU_FORMAT
   myprint ""              0  16 `tput cols` n n "." $MENU_FORMAT
   myprint ""              0  22 `tput cols` n n "." $MENU_FORMAT
   read -n 1 -s
}

try2() {
   clear
   echo "Rectangle draw. Press any key to continue."
   echo "On next screen -"
   echo "   Use keys a,s,d,f to move top left point."
   echo "   Use keys h,j,k,l to move bottom right point."
   echo "   Use key c to clear screen."
   echo "   Use key r or SPACE to randomly resize rectangle."
   echo "   Use key q to quit."
   read -n 1 -s
   clear
   x1=10
   x2=50
   y1=10
   y2=30

   incrX=20
   incrY=5

   key="r"

   while true 
   do
      case $key in
         "c")
            clear
            ;;
         "r" | " " | "")
            x1=`tput cols`
            x1=`expr $x1 / 2`
            x1=`echo 0 $x1 $RANDOM | awk -F' ' '{y=""; x=$3/32767; while (y=="") {if (x*$2 > $1) {y=x*$2;} x=x/0.5;} printf "%d", y;}'` 
            x2=`tput cols`
            x2=`echo $x1 $x2 $RANDOM | awk -F' ' '{y=""; x=$3/32767; while (y=="") {if (x*$2 > $1) {y=x*$2;} x=x/0.5;} printf "%d", y;}'` 
            y1=`tput lines`
            y1=`expr $y1 / 2`
            y1=`echo 0 $y1 $RANDOM | awk -F' ' '{y=""; x=$3/32767; while (y=="") {if (x*$2 > $1) {y=x*$2;} x=x/0.5;} printf "%d", y;}'` 
            y2=`tput lines`
            y2=`echo $y1 $y2 $RANDOM | awk -F' ' '{y=""; x=$3/32767; while (y=="") {if (x*$2 > $1) {y=x*$2;} x=x/0.5;} printf "%d", y;}'` 
	    ;;
         "a")
            if test `expr $x1 - $incrX` -gt 0
   	    then
	    	x1=`expr $x1 - $incrX`
	    else
	        x1=0
	    fi
            ;;
         "s")
            if test `expr $y1 + $incrY` -lt $y2
	    then
	       y1=`expr $y1 + $incrY`
	    else
	       y1=$y2
	    fi
            ;;
         "d")
            if test `expr $y1 - $incrY` -gt 0
	    then
	       y1=`expr $y1 - $incrY`
	    else
	       y1=0
	    fi
            ;;
         "f")
            if test `expr $x1 + $incrX` -lt $x2
	    then
	       x1=`expr $x1 + $incrX`
	    else
	       x1=$x2
	    fi
            ;;
         "h")
            if test `expr $x2 - $incrX` -gt $x1
   	    then
	    	x2=`expr $x2 - $incrX`
	    else
	        x2=$x1
	    fi
            ;;
         "j")
            if test `expr $y2 + $incrY` -lt `tput lines`
	    then
	       y2=`expr $y2 + $incrY`
	    else
	       y2=`tput lines`
	    fi
            ;;
         "k")
            if test `expr $y2 - $incrY` -gt $y1
	    then
	       y2=`expr $y2 - $incrY`
	    else
	       y2=$y1
	    fi
            ;;
         "l")
            if test `expr $x2 + $incrX` -lt `tput cols`
	    then
	       x2=`expr $x2 + $incrX`
	    else
	       x2=`tput cols`
	    fi
            ;;
	 "q")
	    return
	    ;;
      esac

      BG_COL_IDX=`expr $RANDOM % ${#BG_COL[@]} `
      TEXT_FORMAT="\033[${FG_COL[0]};${BG_COL[BG_COL_IDX]}m"

	  fill_rect=`expr $RANDOM % 2 | awk '{if ( $1 == "0" ) print "y"; else print "n"; }'`
      drawRectangle $x1 $x2 $y1 $y2 y $TEXT_FORMAT $fill_rect
      read -n 1 -s key
   done
}

try3() {
   clear
   echo "Simple rectangle to cover full screen. Press any key to continue."
   read -n 1 -s
   clear;
   maxX=`tput cols`
   maxY=`tput lines`
   x1=0
   x2=$maxX
   y1=0
   y2=$maxY
   incrX=10
   incrY=5
   for i in 1 2 3
   do
      BG_COL_IDX=`expr $RANDOM % ${#BG_COL[@]} `
      TEXT_FORMAT="\033[${FG_COL[0]};${BG_COL[BG_COL_IDX]}m"

	  fill_rect=`expr $RANDOM % 2 | awk '{if ( $1 == "0" ) print "y"; else print "n"; }'`
      drawRectangle $x1 $x2 $y1 $y2 y $TEXT_FORMAT $fill_rect
      x1=`expr $x1 + $incrX`
      x2=`expr $x2 - $incrX`
      y1=`expr $y1 + $incrY`
      y2=`expr $y2 - $incrY`
   done

   read -n 1 -s
}

try1
try2
try3
clear

