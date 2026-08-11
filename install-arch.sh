#!/usr/bin/env bash
set -e

echo "Installing dotfiles for Arch"

if ! command -v grab &>/dev/null; then
  curl --silent https://raw.githubusercontent.com/noizwaves/grab/main/install.sh | bash
fi
$HOME/.local/bin/grab --config-path grab/.grab install

# remove any defaults
rm -f $HOME/.gitconfig $HOME/.gitconfig_inc_gusto $HOME/.gitignore $HOME/.config/starship.toml $HOME/.zshenv $HOME/.zshrc

make

# Arch is always a personal machine
make personal

# ZSH me pls
sudo usermod --shell /usr/bin/zsh $(whoami)

if [ ! -d ~/.tmux/plugins/tpm ]; then
  echo "Installing tmux plugin manager..."
  git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm

  echo "Installing tmux plugins..."
  ~/.tmux/plugins/tpm/bin/install_plugins
fi
