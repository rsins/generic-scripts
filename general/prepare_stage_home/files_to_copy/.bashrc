# .bashrc

# Source global definitions
if [ -f /etc/bashrc ]; then
	. /etc/bashrc
fi

export TERM=xterm

# User specific aliases and functions
set -o vi
stty -ixon

alias vi='vim'
alias rm='rm -i'
alias ls='ls -G'
alias ll='ls -GFl'
alias ll.='ls -GFdl .*'
alias l.='ls -GFd .*'
alias la='ls -Ga'
alias lla='ls -Gla'

alias grep='grep --color=auto'
alias path='echo $PATH'

alias jd='java -jar ~/bin/jd-cli.jar'
alias jad='~/bin/jad/jad'
alias cfr='java -jar ~/bin/cfr_0_120.jar'
alias tig='$HOME/bin/local/bin/tig'


function paths {
   echo $PATH | awk -F':' 'BEGIN {print "";} {print "**** Total paths: " NF " ****"; for (w=1;w<=NF;w++) print "   " w "\t" $w;} END {print "";}'
}

function lineno {
   cat /dev/stdin | awk '{printf "%2i %s\n" , FNR , $0;}'
}

function menu {
   printf "\n* List of aliases & functions: \n"
   printf "%.0s-" {1..50}; echo
   set | grep "()" | grep -v "=" | grep -v "_" | awk '{print "function " $0;}'
   alias | awk -F'=' '{printf $1; gsub($1"=","",$0); print "\t" $0}'

   printf "\n* List of tools: \n"
   printf "%.0s-" {1..50}; echo
   ls ~/bin/

   printf "\n* List of scripts: \n"
   printf "%.0s-" {1..50}; echo
   find -P ~/scripts/ -name "*.sh" -type f -executable -print
   echo 
}

#------------------------------------------------------------
# Functions - Git Commands
#------------------------------------------------------------
# For Git branch in prompt.
function git_branch {
   if [ "$1" == "-p" ]
   then
      git branch 2> /dev/null | sed -e '/^[^*]/d' -e 's/* \(.*\)/ (\1)/'
   else
      git branch 2> /dev/null | sed -e '/^[^*]/d' -e 's/* \(.*\)/ \1/'
   fi
}

# Print the current level inside the shell
function cl {
   set | grep CURRENT_LEVEL | awk -F'=' '{if (NF == 2) {if ("'$1'" == "-n") {print $2;} else {if ($2 == 0) {print "You are in the root shell.";} print "Current Shell Level: " $2;} }}'
}

# Current shell level to indicate the level inside csh shells.
if test -z $CURRENT_LEVEL
then
   declare -x CURRENT_LEVEL=0
else
   # To handle the shell through telnet or through tmux
   if test -n "$TMUX" -a "$CURRENT_LEVEL" == "0" -a -z "$MYTMUXSHELL"
   then
      declare -x MYTMUXSHELL="$TMUX shell"
   else
      declare -x CURRENT_LEVEL=`expr $CURRENT_LEVEL + 1`
   fi
fi

# Handle normal shell and tmux shell
if [ "`cl -n`" -eq 0 -a -z "$MYTMUXSHELL" ]; then
   PS1='\[\033[0m\]\[\033[37m\][ \[\033[31m\]\u@\h\[\033[0m\] \[\033[33m\]\w\[\033[37m\] ]\n[ \[\033[34m\]$(date "+%a %b %d %Y %r %Z") | $(env TZ=":Asia/Calcutta" date "+%r %Z")\[\033[31m\]$(git_branch -p)\[\033[37m\] ] \[\033[0m\]'
else
   PS1='\[\033[0m\]\[\033[37m\][ \[\033[31m\]\u@\h\[\033[0m\] \[\033[33m\]\w\[\033[37m\] ]\n[ \[\033[36m\]level: \[\033[35m\]`cl -n`\[\033[0m\], \[\033[34m\]$(date "+%a %b %d %Y %r %Z") | $(env TZ=":Asia/Calcutta" date "+%r %Z")\[\033[31m\]$(git_branch -p)\[\033[37m\] ] \[\033[0m\]'
fi

# Function to echo the logging properties, use this to concatenate the logging.properties file
function logp {
echo 'logger.level=FINE
loggers=com.paypal
logger.com.paypal.level=FINE
logger.handlers = EbayLogFileHandler
handler.EbayLogFileHandler = com.ebay.kernel.logger.rt.EbayLogFileHandler
handler.EbayLogFileHandler.level=FINE
handler.EbayLogFileHandler.kernelLoggerOnly = false
handler.EbayLogFileHandler.pattern = ebay.log
handler.EbayLogFileHandler.limit = 5000000
handler.EbayLogFileHandler.count = 10
handler.EbayLogFileHandler.append = true
handler.EbayLogFileHandler.formatter = com.ebay.kernel.logger.rt.EbayLogFormatter
handler.EbayLogFileHandler.formatter.layoutpattern = %d %p - %m%n
handler.EbayLogFileHandler.encoding = UTF-8
'
}

