# dotfiles

My configuration files.

These dotfiles are managed by
[GNU Stow](https://alexpearce.me/2016/02/managing-dotfiles-with-stow/). For Stow
to work correctly, this repository should be directly under `$HOME`, e.g.
`~/dotfiles`.

The top-level directories in this folder are Stow packages. Generally, each Stow
package corresponds to a single program. To install one of them, use
`stow some_package`.

Some tools use their own package manager to install plugins, which must be
installed manually:

- neovim: [packer.nvim](https://github.com/wbthomason/packer.nvim)
- zsh: [antigen](https://github.com/zsh-users/antigen)
- tmux: [tpm](https://github.com/tmux-plugins/tpm)

Binary dependencies should be installed through the system package manager, or
alternative package managers like [pipx](https://github.com/pypa/pipx).

A (non-exhaustive) list of shell tools I use:

- [entr](https://github.com/eradman/entr)
- [fd](https://github.com/sharkdp/fd)
- [fzf](https://github.com/junegunn/fzf)
- [ripgrep](https://github.com/BurntSushi/ripgrep)
