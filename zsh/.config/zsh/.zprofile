# ~/.config/zsh/.zprofile: zsh settings set at login

# Load common shell settings
emulate sh -c "source $HOME/.config/shell_common"

# Setup homebrew
[ -x /opt/homebrew/bin/brew ] && eval "$(/opt/homebrew/bin/brew shellenv)"
