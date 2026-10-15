# dotfiles

![Screenshot of shell](shell.png)
![Screenshot of Vim](vim.png)

## Install
1. `./install`

## Uninstall
```
make delete
```

## Personal Agent Skills

Store shared skills in `agents/.agents/skills/<skill-name>/SKILL.md`, with any
supporting scripts, references, and assets alongside `SKILL.md`.

Run `make all` after adding a skill. Stow installs its files under
`~/.agents/skills`, where Codex discovers them. The final step links each skill
directory containing `SKILL.md` into `~/.claude/skills`, so Claude Code uses the
same files. It also links any other skills already in `~/.agents/skills`.

The linking step can be rerun with `sh agents/.local/bin/link-agent-skills`.
Existing symlinks are updated; a conflicting file or real directory causes an
error so its contents are preserved. Unrelated Claude skills are left alone.
After removing a skill, remove its Claude symlink as well.

## Features

### Cross-platform

Support for macOS, Ubuntu, and devcontainers.

### Feedback on Problems

Neovim's LSP diagnostic framework provides the core functionality.
The custom dictionary is stored at `~/.config/nvim/spell`.

Vim spell provides spell checking.
- `<Leader>s` to toggle spelling highlighting
- `zg` to add a word to the dictionary

[null-ls](https://github.com/jose-elias-alvarez/null-ls.nvim) provides diagnostic information using:
- [Vale](https://docs.errata.ai/) for writing

[Trouble](https://github.com/folke/trouble.nvim) provides a pretty list of problems.
- `:ToggleTrouble` to activate the list

## Updating Vim Plugins

Open Neovim and run `:PlugUpdate` to update all plugins managed by [vim-plug](https://github.com/junegunn/vim-plug).
To install newly added plugins, run `:PlugInstall`.

After removing plugins from the config, run `:PlugClean` to remove the installed files.

## VS Code Keyboard Shortcuts

- `Control+Option+Command+l`: go to line in GitHub
- `Control+Option+Command+c`: go to commit in GitHub

## Vim Keyboard Shortcuts

See [docs/neovim-keymap.md](docs/neovim-keymap.md) for the full custom keymap reference.
