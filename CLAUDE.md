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
- **kde** — KDE settings (see [KDE Configuration](#kde-configuration))
- **grab** — grab repository definitions
- **gdev** — gdev-pull helper script

## Editing Tips

- **Always edit files in this repo**, not at their symlink destinations (e.g., edit `claude-work/.claude/settings.json` here, not `~/.claude/settings.json`)
- When adding a new config, create a new stow package directory mirroring the home directory path
- **After adding or removing files**, remind the user to re-stow so new symlinks are created (edits to existing files propagate automatically via the existing symlink). The command is `make all` (or `make work`/`make personal` for claude settings)
- When adding or changing Neovim keymaps, update `docs/neovim-keymap.md` to keep the keymap reference in sync

## KDE Configuration

KDE settings are managed two ways. Pick based on how noisy the target file is.

**Stow the whole file** when it only changes when you deliberately change a setting. KConfig (System Settings, `kwriteconfig6`) writes *through* symlinks rather than replacing them, so a stowed config stays linked and edits land straight in this repo. Currently stowed:

- `kde/.config/mimeapps.list` — default applications, keyed by mimetype (`application/pdf`) or URL scheme (`x-scheme-handler/https`). Covers browser, mail, file manager, and per-filetype handlers
- `kde/.config/powerdevilrc` — power management: AC/battery power profiles and brightness

**Pin individual keys via `kde/.local/bin/kde-apply-settings`** when Plasma rewrites the file during ordinary use. `kdeglobals` is the standing example — it carries colour scheme data, widget style, and a `[KFileDialog Settings]` block that records file-dialog sort order and geometry, so stowing it buries real settings in churn. Add a `kwriteconfig6` line to the script instead. It runs from `install-arch.sh` and is safe to re-run any time.

Notes:

- `xdg-mime default` is symlink-safe here only because its KDE code path needs the Qt5-era `qtpaths` binary, which isn't installed. If `qtpaths` ever lands on `PATH`, that path activates and replaces `~/.config/mimeapps.list` with a regular file. Symptom: changing a default no longer shows up in `git status`. Fix with `make all`
- These are laptop/Plasma-specific, but `make all` stows every package on every machine. Harmless elsewhere, just inert

## Neovim Config Verification

After editing files under `nvim/.config/nvim/`, the `verify-nvim-config` skill activates automatically to verify changes via a headless Neovim instance. The skill uses `nvim-server-start`, `nvim-server-stop`, and `nvim-server-verify` scripts in `.claude/skills/verify-nvim-config/bin/`.

## Git

- Commit directly to `main` in this repo — do not create branches (overrides the global `an--` branch-prefix convention) unless explicitly told otherwise
- Never use `git -C <path>` — all changes live in this directory; run git commands directly
