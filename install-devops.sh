#!/usr/bin/env bash
set -e

LOCAL_BIN="$HOME/.local/bin"
TMP_DIR=$(mktemp -d)

echo "Installing dotfiles for devops"
mkdir -p "$LOCAL_BIN"

# TODO: bootstrap grab if missing
if ! command -v grab &> /dev/null; then
  echo "grab is missing; install manually"
  exit 1
fi
grab --config-path grab/.grab install

if ! command -v stow &> /dev/null; then
  echo "stow is missing; install with 'sudo yum install stow'"
  exit 1
fi

# remove any defaults
rm -f $HOME/.gitconfig $HOME/.gitconfig_inc_gusto $HOME/.gitignore $HOME/.config/starship.toml $HOME/.zshenv $HOME/.zshrc

make all-devops

# ZSH me pls
sudo usermod --shell /bin/zsh $(whoami)

if [ ! -d ~/.tmux/plugins/tpm ]; then
  echo "Installing tmux plugin manager..."
  git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm

  echo "Installing tmux plugins..."
  ~/.tmux/plugins/tpm/bin/install_plugins
fi
