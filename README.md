# dotfiles

My configuration files.

These dotfiles are managed by 
[GNU Stow](https://alexpearce.me/2016/02/managing-dotfiles-with-stow/).
For Stow to work correctly, this repository should be directly under 
`$HOME`, e.g. `~/dotfiles`.

The top-level directories in this folder are Stow packages.
Generally, each Stow package corresponds to a single program.
To install one of them, use `stow some_package`.
