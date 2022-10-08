# dotfiles

My configuration files.

These dotfiles are managed by
[GNU Stow](https://alexpearce.me/2016/02/managing-dotfiles-with-stow/). For Stow
to work correctly, this repository should be directly under `$HOME`, e.g.
`~/dotfiles`.

The top-level directories in this folder are Stow packages. Generally, each Stow
package corresponds to a single program. To install one of them, use
`stow some_package`.

nvim must be bootstrapped by manually installing
[Packer](https://github.com/wbthomason/packer.nvim) and running `:PackerSync`.

Binary dependencies should be installed through the system package manager, or
alternative package managers like [pipx](https://github.com/pypa/pipx).

A (non-exhaustive) list of shell tools I use:

- [entr](https://github.com/eradman/entr)
- [fd](https://github.com/sharkdp/fd)
- [fzf](https://github.com/junegunn/fzf)
- [ripgrep](https://github.com/BurntSushi/ripgrep)
- [direnv](https://direnv.net/)
- [qalc](https://github.com/Qalculate/libqalculate)
- [jq](https://stedolan.github.io/jq/)
- [sd](https://github.com/chmln/sd)
