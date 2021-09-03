# ~/.config/shell_common/interactive.sh
# Common interactive shell config

# Use neovim for vim if present
[ -x "$(command -v nvim)" ] && alias vim="nvim" vimdiff="nvim -d"

# Aliases
alias v='vim'

# Be verbose & cautious for cp, mv, and rm
alias \
	cp="cp -iv" \
	mv="mv -iv" \
	rm="rm -vI"

# Colorize default commands
alias \
	ls="ls -hN --color=auto --group-directories-first" \
	grep="grep --color=auto" \
	diff="diff --color=auto" \
    ip="ip --color=auto"

# Kitty: automatically copy terminfo to servers on SSH
if [ $TERM = "xterm-kitty" ]; then
    alias ssh='kitty +kitten ssh'
fi
