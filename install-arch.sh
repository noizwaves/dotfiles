#!/usr/bin/env bash
set -e

echo "Installing dotfiles for Arch"

# packages
sudo pacman -S --noconfirm \
  make \
  stow \
  tmux \
  wget \
  zsh \
  tree \
  atuin \
  ttf-jetbrains-mono-nerd \
  dust \
  wezterm \
  obsidian \
  syncthing

# yay for AUR
if ! command -v yay; then
  sudo pacman -S --needed --noconfirm base-devel git
  git clone https://aur.archlinux.org/yay.git
  pushd yay
  makepkg -si --noconfirm
  popd

  rm -rf yay
fi

# AUR packages
yay -S --needed --noconfirm \
  antigen-git \
  visual-studio-code-bin

if ! command -v cargo; then
  curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh
fi

if ! command -v mise; then
  curl --proto '=https' --tlsv1.2 -sSf https://mise.run | sh
fi

if ! command -v grab &>/dev/null; then
  curl --silent https://raw.githubusercontent.com/noizwaves/grab/main/install.sh | bash
fi
$HOME/.local/bin/grab --config-path grab/.grab install

# remove any defaults
rm -f $HOME/.gitconfig $HOME/.gitconfig_inc_gusto $HOME/.gitignore $HOME/.config/starship.toml $HOME/.zshenv $HOME/.zshrc

make

# ZSH me pls
sudo usermod --shell /usr/bin/zsh $(whoami)

if [ ! -d ~/.tmux/plugins/tpm ]; then
  echo "Installing tmux plugin manager..."
  git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm

  echo "Installing tmux plugins..."
  ~/.tmux/plugins/tpm/bin/install_plugins
fi

# TODO: neovim?

# VS Code is installed and running in a GUI (i.e. not a remote connection)
if (command -v code &> /dev/null) && (type Xorg &> /dev/null); then
  make install-vscode-extensions
fi
