# dotfiles

Cross-platform configuration for macOS & Linux, powered by Nix.

## Installation

### NixOS

1. Install NixOS 21.11 using dotfiles and `git clone https://github.com/noizwaves/dotfiles.git /etc/nixos`
1. Set up channels:
  1. `sudo nix-channel --add https://nixos.org/channels/nixos-21.11 nixos`
  1. `sudo nix-channel --add https://github.com/nix-community/home-manager/archive/master.tar.gz home-manager`
  1. `sudo nix-channel --update`
1. Install configuration `sudo nixos-rebuild switch`

Install future changes by running `ni`

### MacOS

1. Install Nix 2.3.16
1. `git clone https://github.com/noizwaves/dotfiles.git ~/workspace/dotfiles`
1. `ln -s ~/workspace/dotfiles/nixpkgs ~/.config/nixpkgs`
1. Set up channels:
  1. `nix-channel --add https://nixos.org/channels/nixos-21.11`
  1. `nix-channel --add https://github.com/nix-community/home-manager/archive/release-21.11.tar.gz home-manager`
  1. `nix-channel --update`
1. Install configuration via `home-manager update`

Install future changes by running `ni`.
