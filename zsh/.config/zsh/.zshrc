# ~/.config/zsh/.zshrc: settings for zsh interactive shells

# Set up homebrew
if [ -x /opt/homebrew/bin/brew ]
then
    eval "$(/opt/homebrew/bin/brew shellenv)" # Env vars
    FPATH="$(brew --prefix)/share/zsh/site-functions:${FPATH}" # Completions
fi

# Load common shell config
emulate sh -c "source $HOME/.config/commonrc"

# Plugins: managed through [antigen](https://github.com/zsh-users/antigen)
# NOTE: to bootstrap, install antigen into ZDOTDIR
#       (curl -L git.io/antigen > $ZDOTDIR/antigen.zsh)
# NOTE: Make sure to `antigen reset` after changing plugins.
#       Use `antigen help` to see available commands
if [ -f "$ZDOTDIR/antigen.zsh" ]
then
    export ADOTDIR="$XDG_CACHE_HOME/antigen" # Move antigen files to ~/.cache
    export ANTIGEN_AUTO_CONFIG=false  # Manually reset

    # Load antigen
    source "$ZDOTDIR/antigen.zsh"

    # Load plugins
    antigen bundle zsh-users/zsh-autosuggestions # Right-arrow autocompletion
    antigen bundle zsh-users/zsh-syntax-highlighting # Syntax highlighting
    antigen bundle zsh-users/zsh-history-substring-search # Up-arrow history search
    antigen bundle nojhan/liquidprompt # Prompt

    antigen apply
fi

### Key bindings
bindkey -e # Use emacs line editing mode
bindkey '^[[A' history-substring-search-up # Up arrow/down arrow to search history
bindkey '^[[B' history-substring-search-down

### History
export HISTFILE="$ZDOTDIR/.zsh_history" # Move histfile
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

# iterm2 integration
[ -e "${ZDOTDIR}/.iterm2_shell_integration.zsh" ] && source "${ZDOTDIR}/.iterm2_shell_integration.zsh"

# direnv integration
[ -x "$(command -v direnv)" ] && eval "$(direnv hook zsh)"
