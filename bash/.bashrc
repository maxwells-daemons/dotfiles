# ~/.bashrc: contains all interactive and non-interactive shell configuration

###########################
# Non-interactive section #
###########################

# Setup XDG user directories, obeying defaults if set
export XDG_CONFIG_HOME=${XDG_CONFIG_HOME:-"$HOME/.config"}
export XDG_CACHE_HOME=${XDG_CACHE_HOME:-"$HOME/.cache"}
export XDG_DATA_HOME=${XDG_DATA_HOME:-"$HOME/.local/share"}
export XDG_STATE_HOME=${XDG_STATE_HOME:-"$HOME/.local/state"}
export XDG_RUNTIME_DIR=${XDG_RUNTIME_DIR:-"/run/user/$UID"}

# Default programs
export EDITOR=vim
export BROWSER=google-chrome
export PAGER=less

### Configure programs
# readline
export INPUTRC=$XDG_CONFIG_HOME/inputrc

#######################
# Interactive section #
#######################

# If not running interactively, don't do anything
[[ $- == *i* ]] || return

### Aliases
# Use neovim for vim if present
[ -x "$(command -v nvim)" ] && alias vim="nvim" vimdiff="nvim -d"

alias v="vim"

# Be verbose & cautious for cp, mv, and rm
alias \
    cp="cp -iv" \
    mv="mv -iv" \
    rm="rm -Iv"

# Colorize some commands
alias \
    ls="ls -hN --color=auto --group-directories-first" \
    grep="grep --color=auto" \
    diff="diff --color=auto" \
    ip="ip --color=auto"

# tmux -- use ~/.config/tmux/tmux.conf even for old tmux versions
alias tmux="tmux -f $XDG_CONFIG_HOME/tmux/tmux.conf"

# Kitty: automatically copy terminfo to servers on SSH
if [ $TERM = "xterm-kitty" ]; then
    alias ssh="kitty +kitten ssh"
fi

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
