# ~/.config/zsh/.zshrc: settings for zsh interactive shells

# Set up homebrew
if [ -x /opt/homebrew/bin/brew ]
then
    eval "$(/opt/homebrew/bin/brew shellenv)" # Env vars
    FPATH="$(brew --prefix)/share/zsh/site-functions:${FPATH}" # Completions
    export PATH="/opt/homebrew/share:$PATH"
fi

# Load common shell config
emulate sh -c "source $HOME/.config/commonrc"

### Key bindings
bindkey -e # Use emacs line editing mode
bindkey "^[[1;5C" forward-word # Fix ctrl+left/right arrows
bindkey "^[[1;5D" backward-word

# Alt-backspace & ctrl-W: only delete word up to /
export WORDCHARS='' # Only alphanumeric spans are considered a single word
autoload -U select-word-style
select-word-style bash

### History
export HISTSIZE=10000 # Save 10K lines of history in memory
export SAVEHIST=1000000 # Save 1M lines of history in HISTFILE
setopt inc_append_history # Append to history, don't overwrite it
setopt share_history # Share history between sessions
setopt extended_history # Record timestamps in history
setopt hist_ignore_dups # Don't record duplicate lines in history
setopt hist_verify # When doing history expansion, fill instead of executing

### Completion
autoload -Uz compinit; compinit # Load completion scripts
_comp_options+=(globdots) # Show hidden files in completion

### Misc
unsetopt beep # Disable beep

# direnv integration
[ -x "$(command -v direnv)" ] && eval "$(direnv hook zsh)"
