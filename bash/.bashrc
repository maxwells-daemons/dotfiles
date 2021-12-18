# ~/.bashrc: common and interactive config for bash shell

# First, load common shell config
source "$HOME/.config/commonrc"

# If not running interactively, don't do anything.
# Config specific to interactive bash shells follows.
[[ $- == *i* ]] || return

### Completion
# Enable extended completion
if [ -f /usr/share/bash-completion/bash_completion ]; then
	. /usr/share/bash-completion/bash_completion
elif [ -f /etc/bash_completion ]; then
	. /etc/bash_completion
fi

### History
# See: https://blog.sanctum.geek.nz/better-bash-history/

# Append to history instead of overwriting
shopt -s histappend

# Record multiline commands as single-line
shopt -s cmdhist

# Save 10K lines of history in memory and 1M lines in HISTFILE
export HISTSIZE=10000
export HISTFILESIZE=1000000

# Ignore duplicate lines, lines starting with space, and certain commands
export HISTCONTROL="ignoredups"
export HISTIGNORE="ls:bg:fg:pwd:clear:history:exit"

# Record commands as soon as they're used
PROMPT_COMMAND="history -a"

# Record timestamps: <date> <time> <command>
HISTTIMEFORMAT="%F %T "

### General settings
# Update LINES and COLUMNS on resize
shopt -s checkwinsize

# Set prompt
PS1='[\u@\h \W]\$ '
