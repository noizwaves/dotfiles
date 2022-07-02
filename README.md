# dotfiles

Cross-platform configuration for macOS & Linux, powered by Nix.

![Screenshot of shell prompt](shell_prompt.png)
![Screenshot of Vim](vim.png)

## Installation

### NixOS

1. Install NixOS 22.05 using dotfiles and `git clone https://github.com/noizwaves/dotfiles.git /etc/nixos`
1. Set up channels:
    1. `sudo nix-channel --add https://nixos.org/channels/nixos-22.05 nixos`
    1. `sudo nix-channel --add https://github.com/nix-community/home-manager/archive/master.tar.gz home-manager`
    1. `sudo nix-channel --update`
1. Install configuration `sudo nixos-rebuild switch`
1. `ln -s /etc/nixos ~/workspace/dotfiles`

Install future changes by running `ni`.

### MacOS

1. Install latest Nix
1. `git clone https://github.com/noizwaves/dotfiles.git ~/workspace/dotfiles`
1. `ln -s ~/workspace/dotfiles/nixpkgs ~/.config/nixpkgs`
1. Set up channels:
    1. `nix-channel --add https://nixos.org/channels/nixos-unstable nixpkgs`
    1. `nix-channel --add https://github.com/nix-community/home-manager/archive/release-unstable.tar.gz home-manager`
    1. `nix-channel --update`
1. `export NIX_PATH=${NIX_PATH:+$NIX_PATH:}$HOME/.nix-defexpr/channels:/nix/var/nix/profiles/per-user/root/channels`
1. `nix-shell '<home-manager>' -A install`
1. Install configuration via `home-manager switch`

Install future changes by running `ni`.

## Development

Writing style uses [Vale](https://docs.errata.ai/vale/cli).
To set up, run:

1. `vale sync` to download styles
1. Edit markdown files in Neovim

## Features

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

## Vim Keyboard Shortcuts

### Finding / Searching

- `<Leader>f`: live grep based find using Telescope
- `:FindInFolder "some/path"`: live grep based find within a folder using Telescope
- `<Leader>o`: find git tracked files using FZF

Within Telescope:
- `[n]p`: toggle preview panel

Within FZF:
- `<C-/>`: toggle preview panel
