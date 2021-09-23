# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
# Initialization code that may require console input (password prompts, [y/n]
# confirmations, etc.) must go above this block; everything else may go below.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

# If you come from bash you might have to change your $PATH.
# export PATH=$HOME/bin:/usr/local/bin:$PATH

# Path to your oh-my-zsh installation.
export ZSH_DISABLE_COMPFIX=true
export ZSH="$HOME/.oh-my-zsh"

# Set name of the theme to load. Optionally, if you set this to "random"
# it'll load a random theme each time that oh-my-zsh is loaded.
# See https://github.com/robbyrussell/oh-my-zsh/wiki/Themes
#ZSH_THEME="robbyrussell"
#ZSH_THEME="agnoster"
ZSH_THEME="powerlevel10k/powerlevel10k"

# Set list of themes to load
# Setting this variable when ZSH_THEME=random
# cause zsh load theme from this variable instead of
# looking in ~/.oh-my-zsh/themes/
# An empty array have no effect
# ZSH_THEME_RANDOM_CANDIDATES=( "robbyrussell" "agnoster" )

# Uncomment the following line to use case-sensitive completion.
# CASE_SENSITIVE="true"

# Uncomment the following line to use hyphen-insensitive completion. Case
# sensitive completion must be off. _ and - will be interchangeable.
# HYPHEN_INSENSITIVE="true"

# Uncomment the following line to disable bi-weekly auto-update checks.
# DISABLE_AUTO_UPDATE="true"

# Uncomment the following line to change how often to auto-update (in days).
# export UPDATE_ZSH_DAYS=13

# Uncomment the following line to disable colors in ls.
# DISABLE_LS_COLORS="true"

# Uncomment the following line to disable auto-setting terminal title.
# DISABLE_AUTO_TITLE="true"

# Uncomment the following line to enable command auto-correction.
# ENABLE_CORRECTION="true"

# Uncomment the following line to display red dots whilst waiting for completion.
# COMPLETION_WAITING_DOTS="true"

# Uncomment the following line if you want to disable marking untracked files
# under VCS as dirty. This makes repository status check for large repositories
# much, much faster.
# DISABLE_UNTRACKED_FILES_DIRTY="true"

# Uncomment the following line if you want to change the command execution time
# stamp shown in the history command output.
# The optional three formats: "mm/dd/yyyy"|"dd.mm.yyyy"|"yyyy-mm-dd"
# HIST_STAMPS="mm/dd/yyyy"

# Would you like to use another custom folder than $ZSH/custom?
# ZSH_CUSTOM=/path/to/new-custom-folder

# Which plugins would you like to load? (plugins can be found in ~/.oh-my-zsh/plugins/*)
# Custom plugins may be added to ~/.oh-my-zsh/custom/plugins/
# Example format: plugins=(rails git textmate ruby lighthouse)
# Add wisely, as too many plugins slow down shell startup.
plugins=(
  git
)

source $ZSH/oh-my-zsh.sh

# User configuration

# export MANPATH="/usr/local/man:$MANPATH"

# You may need to manually set your language environment
# export LANG=en_US.UTF-8

# Preferred editor for local and remote sessions
# if [[ -n $SSH_CONNECTION ]]; then
#   export EDITOR='vim'
# else
#   export EDITOR='mvim'
# fi

# Compilation flags
# export ARCHFLAGS="-arch x86_64"

# ssh
# export SSH_KEY_PATH="~/.ssh/rsa_id"

# Set personal aliases, overriding those provided by oh-my-zsh libs,
# plugins, and themes. Aliases can be placed here, though oh-my-zsh
# users are encouraged to define aliases within the ZSH_CUSTOM folder.
# For a full list of active aliases, run `alias`.
#
# Example aliases
# alias zshconfig="mate ~/.zshrc"
# alias ohmyzsh="mate ~/.oh-my-zsh"

#------------------------------------------------------------
# General Shell / Command line settings.
#------------------------------------------------------------
set -o vi                                # vi mode editing for command line
HISTSIZE=1000                            # in memory history number of lines
HISTFILESIZE=10000                       # in file history number of lines
HISTCONTROL=ignorespace:ignoredups       # no duplicate entries
setopt histappend                        # append to history, don't overwrite it
#shopt -s checkwinsize					 # check window size after each command
if [[ ":$PATH:" != *":${HOME}/scripts:"* ]]; then
   export PATH="/usr/local/sbin:/usr/local/opt/ncurses/bin:$PATH:${HOME}/scripts:/usr/local/bin"
fi
export PKG_CONFIG_PATH="/usr/local/opt/ncurses/lib/pkgconfig:/usr/local/lib/pkgconfig:/usr/local/lib"

# stty -ixany
stty -ixon >> /dev/null 2>&1 

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

alias mpip='pip --trusted-host pypi.org --trusted-host files.pythonhosted.org'
alias mpip3='pip3 --trusted-host pypi.org --trusted-host files.pythonhosted.org'

# Java version handling.
export JAVA_HOME=`/usr/libexec/java_home -v 1.8`              # Default to Java 8
alias jl='export JAVA_HOME=`/usr/libexec/java_home`'
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
   set | grep CURRENT_LEVEL | awk -F'=' '{if (NF == 2) {if ("'$1'" == "-n") {print $2;} else {if ($2 == 0) {print "You are in the root shell.";} print "Current Shell Level: " $2;} }}'
}


#------------------------------------------------------------
# Scripts - To Handle Prompt and shell level
#------------------------------------------------------------
# Current shell level to indicate the level inside csh shells.
if test -z $CURRENT_LEVEL
then
   declare -x CURRENT_LEVEL=0
else
   # To handle the shell through telnet or through tmux
   if test -n "$TMUX" -a "$CURRENT_LEVEL" "==" "0" -a -z "$MYTMUXSHELL"
   then
      declare -x MYTMUXSHELL="$TMUX shell"
   else
      declare -x CURRENT_LEVEL=`expr $CURRENT_LEVEL + 1`
   fi
fi

# Shell Prompt
# Handle normal shell and tmux shell
#export TZ=":Asia/Calcutta"
#if [ "`cl -n`" -eq 0 -a -z "$MYTMUXSHELL" ]; then
#        PS1='\[\033[0m\]\[\033[37m\][ \[\033[32m\]\u@\h\[\033[0m\] \[\033[33m\]\w\[\033[37m\] ] \n[ \[\033[34m\]\D{%a %b %d %Y %r %Z}\[\033[37m\]\[\033[31m\]$(git_branch -p)\[\033[00m\] ] \[\033[0m\]'
#else
#        PS1='\[\033[0m\]\[\033[37m\][ \[\033[32m\]\u@\h\[\033[0m\] \[\033[33m\]\w\[\033[37m\] ] \n[ \[\033[36m\]level: \[\033[35m\]`cl -n`\[\033[0m\], \[\033[34m\]\D{%a %b %d %Y %r %Z}\[\033[37m\]\[\033[31m\]$(git_branch -p)\[\033[00m\] ] \[\033[0m\]'
#fi


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
  
  # if [[ $(echo "$(tmux -V | cut -d" " -f2) >= 2.1" | tr -d [a-zA-Z] | bc) -eq 1 ]]
  # then
  #   ERROR_MSG="no server running on"
  # else
  #   ERROR_MSG="failed to connect to server: Connection refused"
  # fi

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
#if [ -f /usr/local/share/bash-completion/bash_completion ]; then
#  . /usr/local/share/bash-completion/bash_completion
#fi
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

# -- For Up and Down arror history search
autoload -U up-line-or-beginning-search
autoload -U down-line-or-beginning-search
zle -N up-line-or-beginning-search
zle -N down-line-or-beginning-search
bindkey "$terminfo[kcuu1]" up-line-or-beginning-search   # Up
bindkey "$terminfo[kcud1]" down-line-or-beginning-search # Down


# For tmux and resurrect plugin to work with zsh
#     https://github.com/tmux-plugins/tmux-resurrect/issues/248#issuecomment-759383846
# Add this in resurrect save.sh
#     local history_w='fc -lLn -64 >!'
bindkey "" end-of-line # Map end-of-line key in the same way as zprezto editor module to prevent issue with tmux-resurrect.
setopt CLOBBER # Allow pipe to existing file. Prevent issue with history save in tmux-resurrect.

# Example for my prompt in .p10k.sh
#  function prompt_shell_level() {
#    #if [ "`cl -n`" -eq 0 -a -z "$MYTMUXSHELL" ]; then
#    if [ "`cl -n`" -eq 0 ]; then
#    	# Do nothing.
#    else
#      p10k segment -f 208 -i '⌂' -t "level: `cl -n`"
#      #p10k segment -f 208 -i '📌' -t "level: `cl -n`"
#      #p10k segment -f 208 -i '🔗' -t "level: `cl -n`"
#    fi
#  }

# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh

test -e "${HOME}/.iterm2_shell_integration.zsh" && source "${HOME}/.iterm2_shell_integration.zsh"

# brew install zsh-syntax-highlighting
source /usr/local/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh

# -------------- Custom Plugins -------------
# brew install zsh-autosuggestions
source /usr/local/share/zsh-autosuggestions/zsh-autosuggestions.zsh

# brew install zsh-history-substring-search
source /usr/local/share/zsh-history-substring-search/zsh-history-substring-search.zsh
bindkey "$terminfo[kcuu1]" history-substring-search-up
bindkey "$terminfo[kcud1]" history-substring-search-down
