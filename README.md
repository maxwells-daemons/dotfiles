# dotfiles

My configuration files.

These dotfiles are managed by 
[GNU Stow](https://alexpearce.me/2016/02/managing-dotfiles-with-stow/).
For Stow to work correctly, this repository should be directly under 
`$HOME`, e.g. `~/dotfiles`.

The top-level directories in this folder are either configuration groups
or configuration for individual programs. Each can be installed
as a Stow package.

Groups are:
 - `_base`: Configuration relevant to basically every system.
 - `_bin`: Custom scripts, installed at `~/bin`.


## Shell configuration

Most of the shell configuration is shared between bash and zsh.
Common configuration is installed in `~/.config/shell_common` as part
of the `_base` group.

`~/.config/shell_common` includes:
 - `interactive.sh`: Configures all interactive shells. Aliases, terminfo, etc.
 - `login.sh`: Configures all login shells. Starts Xorg if we're on a graphical session.
 - `universal.sh`: Configures every shell. Environment variables, program settings, etc.
