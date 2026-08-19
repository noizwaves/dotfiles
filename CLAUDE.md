# Dotfiles

Personal dotfiles repo using [GNU Stow](https://www.gnu.org/software/stow/) for symlink management. Each top-level directory is a stow package whose contents mirror `$HOME`.

## Structure

- Each directory (e.g., `zsh/`, `git/`, `starship/`, `ghostty/`) is a stow package
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
- **ghostty** — terminal emulator config
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

**Fix a wrong window icon** with a `.desktop` file in `kde/.local/share/applications/`. Two different lookups have to succeed, and an app whose Wayland `app_id` doesn't match its packaged entry can fail either one:

| Shows the icon | Matches on | Fix |
| --- | --- | --- |
| Taskbar (plasmashell) | `app_id`, falling back to a `StartupWMClass` search | Shadow the system entry with a same-named copy carrying the right `StartupWMClass` (`obsidian.desktop`) |
| Alt-tab switcher (KWin) | a file named literally `<app_id>.desktop` — no `StartupWMClass` search | Add an alias entry named after the `app_id` (`md.obsidian.Obsidian.desktop`, `com.fastmail.Fastmail.desktop`) |

Alias entries are `NoDisplay=true` so the launcher keeps showing one copy, and omit `MimeType` so the packaged entry stays the registered scheme handler. To read a window's real `app_id`, load a KWin script that prints `workspace.windowList()` via `qdbus6 org.kde.KWin /Scripting loadScript`, then check `journalctl --user` for its output. After adding a file run `make all` to stow it, then `kde-apply-settings` to rebuild the caches Plasma reads entries from. KWin caches a window's icon, so already-open windows may need restarting.

Notes:

- `xdg-mime default` is symlink-safe here only because its KDE code path needs the Qt5-era `qtpaths` binary, which isn't installed. If `qtpaths` ever lands on `PATH`, that path activates and replaces `~/.config/mimeapps.list` with a regular file. Symptom: changing a default no longer shows up in `git status`. Fix with `make all`
- These are laptop/Plasma-specific, but `make all` stows every package on every machine. Harmless elsewhere, just inert

## Dependency Updates

Renovate (`renovate.json5`) opens weekly draft PRs for the versions pinned in this repo:

- **grab tools** (`grab/.grab/config.yml`) — one custom manager per package, grouped into a single PR. `grab update` rewrites that file and would strip inline `# renovate:` comments, so the GitHub org/repo is duplicated into `renovate.json5`. **Adding a grab package means adding a matching entry there.**
- **mise tools** (`mise/.config/mise/config.toml`) — picked up by Renovate's native mise manager
- **install script pins** — annotated inline with `# renovate:` comments above each `*_VERSION=` line

Brewfiles and aptfiles have no Renovate manager and stay manual. Validate changes with `npx --package renovate@latest renovate-config-validator`.

## Neovim Config Verification

After editing files under `nvim/.config/nvim/`, the `verify-nvim-config` skill activates automatically to verify changes via a headless Neovim instance. The skill uses `nvim-server-start`, `nvim-server-stop`, and `nvim-server-verify` scripts in `.claude/skills/verify-nvim-config/bin/`.

## Git

- Commit directly to `main` in this repo — do not create branches (overrides the global `an--` branch-prefix convention) unless explicitly told otherwise
- Never use `git -C <path>` — all changes live in this directory; run git commands directly
