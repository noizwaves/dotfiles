# Dotfiles

Personal dotfiles repo using [GNU Stow](https://www.gnu.org/software/stow/) for symlink management. Each top-level directory is a stow package whose contents mirror `$HOME`.

## Structure

- Each directory (e.g., `zsh/`, `git/`, `starship/`, `wezterm/`) is a stow package
- `.stowrc` configures `--no-folding` (individual symlinks, not directory symlinks) and `--dotfiles`
- `install` script dispatches to platform-specific installers (macOS, Ubuntu, devcontainers, Arch, server)
- `personal.Brewfile` and `aptfile-*` manage package installs

## Key Packages

- **claude** — shared Claude Code config (`CLAUDE.md`, helper scripts in `.local/bin/`)
- **claude-personal** — personal `~/.claude/settings.json`
- **claude-work** — work `~/.claude/settings.json` (managed by Gusto plugin, this is the active one)
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

- **Always edit files in this repo**, not at their symlink destinations (e.g., edit `claude-work/.claude/settings.json` here, not `~/.claude/settings.json`)
- When adding a new config, create a new stow package directory mirroring the home directory path
- When adding or changing Neovim keymaps, update `docs/neovim-keymap.md` to keep the keymap reference in sync

## Git

- Never use `git -C <path>` — all changes live in this directory; run git commands directly
