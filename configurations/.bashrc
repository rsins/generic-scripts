# .bashrc

# Source global definitions
# if [ -f /etc/bashrc ]; then
#	. /etc/bashrc
# fi

#------------------------------------------------------------
# General Shell / Command line settings.
#------------------------------------------------------------
set -o vi                                # vi mode editing for command line
HISTSIZE=1000                            # in memory history number of lines
HISTFILESIZE=10000                       # in file history number of lines
HISTCONTROL=ignorespace:ignoredups       # no duplicate entries
shopt -s histappend                      # append to history, don't overwrite it
shopt -s checkwinsize					 # check window size after each command
if [[ ":$PATH:" != *":~/scripts:"* ]]; then
   export PATH="/usr/local/sbin:/usr/local/opt/ncurses/bin:$PATH:~/scripts"
fi
export PKG_CONFIG_PATH="/usr/local/opt/ncurses/lib/pkgconfig:/usr/local/lib/pkgconfig:/usr/local/lib"
# stty -ixany
stty -ixon

export LC_ALL=en_US.UTF-8


#------------------------------------------------------------
# Aliases - General Commands and Scripts
#------------------------------------------------------------
alias vi=vim
alias rm='rm -i'
alias cp='cp -i'
alias mv='mv -i'
alias ls='ls -G'
alias ll='ls -GFl'
alias llh='ls -GFlh'
alias ll.='ls -GFdl .*'
alias l.='ls -GFd .*'
alias la='ls -Ga'
alias lla='ls -Gla'

alias -- -='cd -'
alias -- --='vim .'
alias md='mkdir -p'
alias rd=rmdir
alias d='dirs -v | head -10'

alias gits='git status'
alias gp='git_fetch_pull_merge'
alias grep='grep --color=auto'
alias path='echo $PATH'
alias tclip='$HOME/scripts/tclip.py'
alias avro='java -jar ~/bin/avro-tools-1.8.2.jar'

alias finder='open -a "Finder"'
alias numbers='open -a "Numbers"'
alias excel='open -a "Microsoft Excel"'

alias startRunAll='sudo spctl --master-enable'
alias stopRunAll='sudo spctl --master-disable'

# Java version handling.
export JAVA_HOME=`/usr/libexec/java_home -v 1.8`              # Default to Java 8
alias j13='export JAVA_HOME=`/usr/libexec/java_home -v 13`'
alias j8='export JAVA_HOME=`/usr/libexec/java_home -v 1.8`'
alias j='/usr/libexec/java_home -V'

#------------------------------------------------------------
# Aliases - Java Decompilers / Class Visualizers
#------------------------------------------------------------
alias cfr='java -jar $HOME/bin/java_decompiler/cfr/cfr-0.145.jar'
#alias jd='open -a JD-GUI $HOME/bin/java_decompiler/jd/JD-GUI.app'
#alias jd='java -jar $HOME/bin/java_decompiler/jd/JD-GUI.app/Contents/Resources/Java/jd-gui-1.4.0.jar'
alias jd='$HOME/scripts/convert_to_full_path_and_run.py $HOME/bin/java_decompiler/jd/JD-GUI.app/contents/MacOS/universalJavaApplicationStub.sh'
alias jdb='$HOME/scripts/convert_to_full_path_and_run.py -b $HOME/bin/java_decompiler/jd/JD-GUI.app/contents/MacOS/universalJavaApplicationStub.sh'
alias jad='$HOME/bin/java_decompiler/jad/jad'

alias cv='$HOME/bin/class-visualizer/clsvis.sh'

#------------------------------------------------------------
# Setup for Python
#------------------------------------------------------------
# Tab Autocompletion
export PYTHONSTARTUP=$HOME/.pythonrc.py


#------------------------------------------------------------
# Aliases - Text Editors
#------------------------------------------------------------
alias te='open -a TextEdit'
alias sl='open -a "Sublime Text"'


#------------------------------------------------------------
# Aliases - Maven Commands
#------------------------------------------------------------
alias mpci='mvnp -DskipTests -Dmaven.test.skip=true clean install'
alias mpcti='mvnp clean install'
alias mpdt='mvnp -DskipTests dependency:tree'
alias mpct='_JAVA_OPTIONS="-Xverify:none" MAVEN_OPTS="-XX:-UseSplitVerifier -noverify" mvnp cobertura:cobertura -Dcobertura.report.format=html'
alias mpjt='_JAVA_OPTIONS="-Xverify:none" MAVEN_OPTS="-XX:-UseSplitVerifier -noverify" mvnp clean test'


#------------------------------------------------------------
# Functions - Maven Commands
#------------------------------------------------------------
function mvnp () {
   SCRIPT="mvn -U ";

   # If only to show command
   if [[ "$@" = *"-sc"* || "$@" = *"-SC"* ]]
   then
       echo $SCRIPT ${@/-sc/};
   	   return
   fi

   echo ">" $SCRIPT $@;
   $SCRIPT $@
}


#------------------------------------------------------------
# Functions - Git Commands
#------------------------------------------------------------
# For Git branch in prompt.
function git_branch () {
   if [ "$1" == "-p" ]
   then
      git branch 2> /dev/null | sed -e '/^[^*]/d' -e 's/* \(.*\)/ (\1)/'
   else
      git branch 2> /dev/null | sed -e '/^[^*]/d' -e 's/* \(.*\)/ \1/'
   fi
}

# For Git Update/Pull/Merge
# The source branch which needs to be merged into current branch is optional argument/parameter
function git_fetch_pull_merge () {
   if test "`git_branch`" == ""
   then
   	  echo "> Not a git repository folder."
   	  return
   fi

   # If input argument specifies the source branch to merge into current branch
   if test "$1" = ""
   then
      if [[ "`pwd`" = *"Core-R/code"* ]]
      then
         SCRIPT="git fetch --all ; git pull ; git merge upstream/master"
      else
         SCRIPT="git fetch --all ; git pull ; git merge upstream/develop"
      fi
   else
   	  if test "`git rev-parse --quiet --verify $1`" = ""
   	  then
   	  	 echo "> '$1' is not a correct branch name."
   	  	 return
      else
         SCRIPT="git fetch --all ; git pull ; git merge $1"
      fi
   fi
   echo ">" $SCRIPT;
   eval "$SCRIPT"
}


#------------------------------------------------------------
# Functions - General
#------------------------------------------------------------
# Mount the samba shared folder from virtual box
function mountvbox () {
   MOUNT_FOLDER="${HOME}/.vbox_share"
   MOUNT_MACHINE="<vbox ip>"
   SHARED_FOLDER="<shared folder name>"
   mkdir -p "${MOUNT_FOLDER}"
   if mount | grep "${MOUNT_FOLDER}" > /dev/null
   then
      echo "${MOUNT_FOLDER} -> Unmounting current mount"
      umount "${MOUNT_FOLDER}"
   fi
   echo "${MOUNT_FOLDER} -> Trying to mount smb://${MOUNT_MACHINE}/${SHARED_FOLDER}"
   mount -t smbfs "//<usr>:<pwd>@${MOUNT_MACHINE}/${SHARED_FOLDER}" "${MOUNT_FOLDER}"
   if [ $? -eq 0 ]
   then 
      echo "${MOUNT_FOLDER} -> Mount completed"
   else
      echo "${MOUNT_FOLDER} -> Mount process did not complete successfully"
   fi
}

function paths () {
   echo $PATH | awk -F':' 'BEGIN {print "";} {print "**** Total paths: " NF " ****"; for (w=1;w<=NF;w++) print "   " w "\t" $w;} END {print "";}'
}

# Add the line number to piped data
function lineno () {
   if [ -z "$@" ]
   then
      cat /dev/stdin | awk '{printf "%3i %s\n" , FNR , $0;}'
   else
      cat $@ | awk '{printf "%3i %s\n" , FNR , $0;}'
   fi
}

# Show all aliases, functions, scripts customized by me
function menu () {
   printf "\n* List of aliases & functions: \n"
   printf "%.0s-" {1..50}; echo
   set | grep "()" | grep -v "=" | grep -v "^_" | awk '{print "function " $0;}'
   alias | awk -F'=' '{printf $1; gsub($1"=","",$0); print "\t" $0}'

   printf "\n* List of tools: \n"
   printf "%.0s-" {1..50}; echo
   ls ~/bin/

   printf "\n* List of scripts: \n"
   printf "%.0s-" {1..50}; echo
   #find -P ~/scripts/ \( -iname \*.sh -o -iname \*.py \) -type f -perm +x -print 2> /dev/null
   for i in `find -P ~/scripts/ -type f \( -iname \*.sh -o -iname \*.py \) 2>/dev/null` ; do [ -x $i ] && echo $i ; done
   echo 
}


#------------------------------------------------------------
# Functions - For Prompt handling
#------------------------------------------------------------
# Print the current level inside the shell
function cl () {
   if test "$1" "==" "-n"
   then
   	   printf "$CURRENT_LEVEL"
   else
       if test "$CURRENT_LEVEL" "==" "0"
       then
   	       printf "You are in the root shell.\n"
       fi
   	   printf "Current Shell Level: $CURRENT_LEVEL\n"
   fi
}


#------------------------------------------------------------
# Scripts - To Handle Prompt and shell level
#------------------------------------------------------------
# Current shell level to indicate the level inside csh shells.
if test -z "$CURRENT_LEVEL"
then
   declare -x CURRENT_LEVEL=0
   declare -x CURRENT_LEVEL_PID=$$
else
   # To handle the shell through telnet or through tmux
   if test -n "$TMUX" -a "$CURRENT_LEVEL" "==" "0" -a -z "$MYTMUXSHELL"
   then
      declare -x MYTMUXSHELL="$TMUX shell"
      declare -x CURRENT_LEVEL_PID=$$
   elif test "$CURRENT_LEVEL_PID" "!=" "$$"
   then
      declare -x CURRENT_LEVEL=`expr $CURRENT_LEVEL + 1`
      declare -x CURRENT_LEVEL_PID=$$
   fi
fi

# Shell Prompt
# Handle normal shell and tmux shell
export TZ=":Asia/Calcutta"
if [ "`cl -n`" -eq 0 -a -z "$MYTMUXSHELL" ]; then
        PS1='\[\033[0m\]\[\033[37m\][ \[\033[32m\]\u@\h\[\033[0m\] \[\033[33m\]\w\[\033[37m\] ] \n[ \[\033[34m\]\D{%a %b %d %Y %r %Z}\[\033[37m\]\[\033[31m\]$(git_branch -p)\[\033[00m\] ] \[\033[0m\]'
else
        PS1='\[\033[0m\]\[\033[37m\][ \[\033[32m\]\u@\h\[\033[0m\] \[\033[33m\]\w\[\033[37m\] ] \n[ \[\033[36m\]level: \[\033[35m\]`cl -n`\[\033[0m\], \[\033[34m\]\D{%a %b %d %Y %r %Z}\[\033[37m\]\[\033[31m\]$(git_branch -p)\[\033[00m\] ] \[\033[0m\]'
fi


#------------------------------------------------------------
# Functions - Tmux Commands
#------------------------------------------------------------
# To reconnect to detached tmux sessions.
function tx () {
  WAIT_TIME=2

  if [ ! -z "$TMUX" ]
  then
     echo "Already inside tmux session."
     return 
  fi
  
  ERROR_MSG_1="no server running on"
  ERROR_MSG_2="error connecting to"

  dettached_session_count=`tmux ls 2>&1 | grep -v attached | grep -v "${ERROR_MSG_1}" | grep -v "${ERROR_MSG_2}" | wc -l`
  total_session_count=`tmux ls 2>&1 | grep -v "${ERROR_MSG_1}" | grep -v "${ERROR_MSG_2}" | wc -l`

  if test ${total_session_count} -eq 1 && test "$1" = "attach" -o "$1" = "a" -o "$1" = "-a"
  then
     tmux attach
     return
  elif test ${total_session_count} -eq 0 -o ${dettached_session_count} -eq 0
  then
     echo "No existing Session in detached mode."
     sleep $WAIT_TIME
     tmux
     return
  elif test ${dettached_session_count} -eq 1
  then
     session_no=`tmux ls 2>&1 | grep -v attached | awk -F':' '{print $1;}'`
     echo "One session in detached mode found. Attaching to session_no = ${session_no}"
     sleep $WAIT_TIME
     tmux attach -t ${session_no}
     return
  elif test ${dettached_session_count} -gt 1
  then
     echo "Following tmux sessions are dettached:"
     tmux ls 2>&1 | grep -v attached | awk -F':' '{print "Session # " $1 "\t -> \t " $0;}'
     echo
     read -p "Please enter the session number to connect to: " session_no
     if test "${session_no}" = ""
     then
        echo "Invalid entry."
        return
     fi
     tmux attach -t ${session_no}
     return
  fi
}

# START brew bash completion
if [ -f /usr/local/share/bash-completion/bash_completion ]; then
  . /usr/local/share/bash-completion/bash_completion
fi
# END brew bash completion

#------------------------------------------------------------
# Settings - NVM and NodeJS
#------------------------------------------------------------
# nvm and nodejs settings
#export NVM_INST="/usr/local/opt/nvm"
#export NVM_DIR="$HOME/.nvm"
#. "${NVM_INST}/nvm.sh"
#. "${NVM_INST}/etc/bash_completion.d/nvm"
#. "/usr/local/opt/nvm/nvm.sh"


# Do the custom exports, not required for all sessions.
#function export_custom () {
#   export PYTHONPATH=/usr/local/lib/python2.7/site-packages/
#   export M2_HOME=/usr/local/Cellar/maven/3.3.9/libexec
#   export JAVA_HOME=/Library/Java/JavaVirtualMachines/jdk1.8.0_121.jdk/Contents/Home/jre
#}

# export JAVA_HOME=/usr/java/jdk1.6.0_23
# export GRAILS_HOME=/usr/local/grails-2.2.2
# export PATH=$JAVA_HOME/bin:$GRAILS_HOME/bin:$PATH
# export JAVA_OPTS="-Xms512m -Xmx1g -XX:MaxPermSize=512m"

