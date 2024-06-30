#!/usr/bin/env bash
set -e

echo "Installing dotfiles for Arch"

# TODO: antigen 

# packages
sudo pacman -S --noconfirm \
  make \
  stow \
  tmux \
  wget \
  zsh \
  fzf \
  tree \
  direnv \
  ripgrep \
  atuin \
  starship \
  git-delta \
  ttf-jetbrains-mono-nerd

if ! command -v cargo; then
  curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh
fi

if ! command -v mise; then
  curl --proto '=https' --tlsv1.2 -sSf https://mise.run | sh
fi

# TODO: grab
# if ! command -v grab &> /dev/null; then
#   echo "grab is missing; install manually"
#   exit 1
# fi
# grab --config-path grab/.grab install

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
# if (command -v code &> /dev/null) && (type Xorg &> /dev/null); then
#   make install-vscode-extensions
# fi
