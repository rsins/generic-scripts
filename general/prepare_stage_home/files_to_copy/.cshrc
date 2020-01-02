# .cshrc

setenv TERM xterm

# User specific aliases and functions
set backslash_quote
bindkey -v

alias vi='vim'
alias rm 'rm -i'
alias ls 'ls -G'
alias ll 'ls -GFl'
alias ll. 'ls -GFdl .*'
alias l. 'ls -GFd .*'
alias la 'ls -Ga'
alias lla 'ls -Gla'

alias grep 'grep --color=auto'
alias path 'echo $PATH'

alias jd 'java -jar ~/bin/jd-cli.jar'
alias cfr 'java -jar ~/bin/cfr_0_120.jar'
alias tig '$HOME/bin/local/bin/tig'

alias paths 'echo $PATH | awk -F\':\' \'BEGIN {print \"\";} {print \"**** Total paths: \" NF \" ****\"; for (w=1;w<=NF;w++) print \"   \" w \"\\t\" $w;} END {print \"\";}\''

alias lineno 'cat /dev/stdin | awk \'{printf \"%2i %s\\n" , FNR , $0; }\''

alias menu ' set ll = "-------------------------------------------------"; printf "\n* List of aliases: \n" ; echo $ll ; alias ; printf "\n* List of tools: \n" ;  echo $ll; echo ;  ls ~/bin/ ;  printf "\n* List of scripts: \n" ;  echo $ll  ;  find -P ~/scripts/ -name "*.sh" -type f -print ;  echo ; unset ll; '

#function menu {
#   printf "\n* List of aliases & functions: \n"
#   printf "%.0s-" {1..50}; echo
#   set | grep "()" | grep -v "=" | grep -v "_" | awk '{print "function " $0;}'
#   alias | awk -F'=' '{printf $1; gsub($1"=","",$0); print "\t" $0}'

#   printf "\n* List of tools: \n"
#   printf "%.0s-" {1..50}; echo
#   ls ~/bin/

#   printf "\n* List of scripts: \n"
#   printf "%.0s-" {1..50}; echo
#   find -P ~/scripts/ -name "*.sh" -type f -executable -print
#   echo 
#}


# Print the current level inside the shell
alias cl 'if ( "\!*" == "-n" ) echo $CURRENT_LEVEL ; if ( "\!*" == "" && "$CURRENT_LEVEL" == "0" ) echo "You are in the root shell." ; if ( "\!*" == "" ) echo "Current Shell Level: $CURRENT_LEVEL"'

# Current shell level to indicate the level inside csh shells.
if ( ! $?CURRENT_LEVEL ) then
   setenv CURRENT_LEVEL 0
else
   setenv CURRENT_LEVEL "`expr $CURRENT_LEVEL + 1`"
endif

# Handle normal shell and tmux shell
setenv TZ ":Asia/Calcutta"
if ( "`cl -n`" == 0 ) then
   set prompt = "%{\e[37m%}[ %{\e[31m%}\u@\h%{\e[0m%} %{\e[33m%}\w%{\e[37m%} ]\n[ %{\e[34m%}%d %w %D %Y %p%{\e[37m%} ] %{\e[0m%}"
else
   set prompt = "%{\e[37m%}[ %{\e[31m%}%n@%m%{\e[0m%} %{\e[33m%}%~%{\e[37m%} ]\n[ %{\e[36m%}level: %{\e[35m%}`cl -n`%{\e[0m%}, %{\e[34m%}%d %w %D %Y %p%{\e[37m%} ] %{\e[0m%}"
endif

# Function to echo the logging properties, use this to concatenate the logging.properties file
alias logp 'echo logger.level=FINE ; echo loggers=com.paypal ; echo logger.com.paypal.level=FINE ; echo logger.handlers = EbayLogFileHandler ; echo handler.EbayLogFileHandler = com.ebay.kernel.logger.rt.EbayLogFileHandler ; echo handler.EbayLogFileHandler.level=FINE ; echo handler.EbayLogFileHandler.kernelLoggerOnly = false ; echo handler.EbayLogFileHandler.pattern = ebay.log ; echo handler.EbayLogFileHandler.limit = 5000000 ; echo handler.EbayLogFileHandler.count = 10 ; echo handler.EbayLogFileHandler.append = true ; echo handler.EbayLogFileHandler.formatter = com.ebay.kernel.logger.rt.EbayLogFormatter ; echo handler.EbayLogFileHandler.formatter.layoutpattern = %d %p - %m%n ; echo handler.EbayLogFileHandler.encoding = UTF-8 ; '

