# ~/.config/zsh/.zshrc: settings for zsh interactive shells

# First, load common shell config
emulate sh -c "source $HOME/.config/commonrc"

# Use emacs line editing mode
bindkey -e

# iterm2 integration, when available
test -e "${ZDOTDIR}/.iterm2_shell_integration.zsh" && source "${ZDOTDIR}/.iterm2_shell_integration.zsh"
