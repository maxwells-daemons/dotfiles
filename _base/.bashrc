# === UNIVERSAL SECTION ===
# Configuration for all bash shells.

# Load common universal config
source ~/.config/shell_common/universal.sh

# Make completion file comply with XDG
export BASH_COMPLETION_USER_FILE=$XDG_CONFIG_HOME/bash-completion/bash_completion

### History
# See: https://blog.sanctum.geek.nz/better-bash-history/

# Make history file comply with XDG
# $XDG_DATA_HOME/bash must be created first. Dotdrop does this automatically.
export HISTFILE=$XDG_DATA_HOME/bash/history

# Append to history instead of overwriting
shopt -s histappend

# Save 10K lines of history in memory and 1M lines in HISTFILE
export HISTSIZE=10000
export HISTFILESIZE=1000000

# Ignore duplicate lines, lines starting with space, and certain commands
export HISTCONTROL=ignoreboth
export HISTIGNORE='ls:bg:fg:pwd:clear:history'

# Record commands as soon as they're used
PROMPT_COMMAND='history -a'

# Record timestamps: <date> <time> <command>
HISTTIMEFORMAT='%F %T '

# Record multiline commands as single-line
shopt -s cmdhist

# === INTERACTIVE SECTION ===
# Configuration for interactive bash shells.

# Exit if not interactive
[ -z "$PS1" ] && return

# Load common interactive config
source ~/.config/shell_common/interactive.sh

# Prompt
PS1='[\u@\h \W]\$ '

### Tab completion
# If advanced tab completion is available, turn it on.
# Completion scripts are automatically installed in: /usr/local/etc/bash_completion.d
if [ -f /etc/bash_completion ]; then
  source /etc/bash_completion
fi
