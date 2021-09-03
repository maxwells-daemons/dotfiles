# ~/.config/shell_common/universal.sh
# Common config for all shells

### Default programs
export EDITOR=vim
export BROWSER=google-chrome
export PAGER=less

### Set up XDG base directories
export XDG_CONFIG_HOME=~/.config
export XDG_CACHE_HOME=~/.cache
export XDG_DATA_HOME=~/.local/share
export XDG_DATA_DIRS=/usr/local/share:/usr/share
export XDG_CONFIG_DIRS=/etc/xdg

### Add ~/bin to PATH
export PATH=~/bin:$PATH

### Configure software
# Most of this just aims to move dotfiles from ~ to ~/.config

# Xorg
export XAUTHORITY=$XDG_RUNTIME_DIR/Xauthority
export XINITRC=$XDG_CONFIG_HOME/x11/xinitrc
export XSERVERRC=$XDG_CONFIG_HOME/x11/xserverrc
export XCOMPOSEFILE=$XDG_CONFIG_HOME/x11/xcompose
export XCOMPOSECACHE=$XDG_CACHE_HOME/x11/xcompose
alias startx="startx $XDG_CONFIG_HOME/x11/xinitrc -- $XDG_CONFIG_HOME/x11/xserverrc"

# readline
export INPUTRC=$XDG_CONFIG_HOME/inputrc

# wget
export WGETRC=$XDG_CONFIG_HOME/wgetrc

# GnuPG
export GNUPGHOME=$XDG_DATA_HOME/gnupg
alias gpg2="gpg2 --homedir $XDG_DATA_HOME/gnupg"

# CUDA
export CUDA_CACHE_PATH=$XDG_CACHE_HOME/nv

# Docker
export DOCKER_CONFIG=$XDG_CONFIG_HOME/docker

# Node.js
export NODE_REPL_HISTORY=$XDG_DATA_HOME/node_repl_history
export NPM_CONFIG_USERCONFIG=$XDG_CONFIG_HOME/npm/npmrc

# Python
export PYTHON_EGG_CACHE=$XDG_CACHE_HOME/python-eggs
export PYLINTHOME=$XDG_CACHE_HOME/pylint
export WORKON_HOME=$XDG_DATA_HOME/virtualenvs

# IPython/Jupyter
export IPYTHONDIR=$XDG_CONFIG_HOME/jupyter
export JUPYTER_CONFIG_DIR=$XDG_CONFIG_HOME/jupyter

# Rust
export CARGO_HOME=$XDG_DATA_HOME/cargo

# gdb
export GDBHISTFILE=$XDG_DATA_HOME/gdb/history
alias gdb="gdb -nh -x $XDG_CONFIG_HOME/gdb/init"

# go
export GOPATH=$XDG_DATA_HOME/go

# GTK
export GTK_RC_FILES="$XDG_CONFIG_HOME/gtk-1.0/gtkrc"
export GTK2_RC_FILES="$XDG_CONFIG_HOME/gtk-2.0/gtkrc"

# tmux
export TMUX_TMPDIR=$XDG_RUNTIME_DIR
