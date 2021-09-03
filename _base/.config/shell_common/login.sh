# ~/.config/shell_common/login.sh
# Common login shell config

# Start Xorg if we're on a graphical session
if [[ -z $DISPLAY ]] && [[ $(tty) = /dev/tty1 ]]; then
    exec startx
fi
