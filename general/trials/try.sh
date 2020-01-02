#!/bin/bash

# Parameters:
#   - text
#   - positionX
#   - positionY
#   - length
#   - bold [y/n]
#   - center [y/n]
#   - padding character
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

   tput cup $TEXT_PositionY $TEXT_PositionX
   
   formattext PrintText "$TEXT_Value" $TEXT_Length "$TEXT_Center" "$TEXT_Padding"

   if test "$TEXT_Bold" = "y" -o "$TEXT_Bold" = "Y"
   then
      tput smso
      printf "$PrintText"
      tput rmso
   else
      printf "$PrintText"
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
drawRectangle() {
   lowX=$1
   maxX=$2
   lowY=$3
   maxY=$4
   bold=$5

   myprint "" $lowX $lowY `expr $maxX - $lowX ` $bold y " "
   myprint "" $lowX $maxY `expr $maxX - $lowX ` $bold y " "
   j=$lowY
   while test $j -le $maxY
   do
      myprint "" $lowX $j 1 $bold y " "
      myprint "" $maxX $j 1 $bold y " "
      j=`expr $j + 1`
   done

   tput cup $lowY $lowX
}

try1() {
   clear 
   echo "Creating menu in text format. Press any key to continue."
   read -n 1 -s
   clear
   myprint ""              0  0  `tput cols` y y " "
   myprint "My Screen"     0  1  `tput cols` y y "_"
   myprint ""              0  2  `tput cols` y y " "
   myprint "  1. Option 1" 0  3  `tput cols` n n "."
   myprint "  2. Option 2" 0  4  `tput cols` n n "."
   myprint ""              0  5  `tput cols` n n "."
   myprint ""              0  6  `tput cols` n n "."
   myprint ""              0  7  `tput cols` n n "."
   myprint ""              0  8  `tput cols` n n "."
   myprint ""              0  9  `tput cols` n n "."
   myprint ""              0  10 `tput cols` n n "."
   myprint ""              0  11 `tput cols` n n "."
   myprint ""              0  12 `tput cols` n n "."
   myprint ""              0  13 `tput cols` n n "."
   myprint ""              0  14 `tput cols` n n "."
   myprint ""              0  15 `tput cols` n n "."
   myprint ""              0  16 `tput cols` n n "."
   myprint ""              0  22 `tput cols` n n "."
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

      drawRectangle $x1 $x2 $y1 $y2 y
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
      drawRectangle $x1 $x2 $y1 $y2 y
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

