# Dotfiles

Personal dotfiles repo using [GNU Stow](https://www.gnu.org/software/stow/) for symlink management. Each top-level directory is a stow package whose contents mirror `$HOME`.

## Structure

- Each directory (e.g., `zsh/`, `git/`, `starship/`, `wezterm/`) is a stow package
- `.stowrc` configures `--no-folding` (individual symlinks, not directory symlinks) and `--dotfiles`
- `install` script dispatches to platform-specific installers (macOS, Ubuntu, devcontainers, Arch, server)
- `personal.Brewfile` and `aptfile-*` manage package installs

## Key Packages

- **zsh** — shell config (`.zshenv`)
- **git** — git includes (Gusto-specific `.gitconfig_inc_gusto`)
- **starship** — prompt config (standard + monorepo variants)
- **wezterm** — terminal emulator config (Lua + Dracula theme)
- **nvim** — Neovim spell dictionary
- **ssh** — SSH config (work config, rc)
- **tmux** — tmux-sessionizer script
- **direnv** — direnvrc
- **vscode** — extensions list and snippets
- **grab** — grab repository definitions
- **gdev** — gdev-pull helper script

## Editing Tips

- When adding a new config, create a new stow package directory mirroring the home directory path
