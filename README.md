# dotfiles

![Screenshot of shell](shell.png)
![Screenshot of Vim](vim.png)

## Install
1. `./install`
1. Configure iTerm 2 to load preferences
  1. <kbd>Cmd+,</kbd>
  1. Navigate to `General > Preferences`
  1. Enable `Load preferences from a custom folder or URL`
  1. Set directory to `~/workspace/dotfiles/iterm2`
  1. Set `Save changes` to `Automatically`

## Uninstall
```
make delete
```

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
