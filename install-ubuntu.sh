#!/usr/bin/env bash
set -e

APTFILE_VERSION="1.2.0"
if ! command -v aptfile &> /dev/null; then
  echo "Installing aptfile..."
  sudo curl --silent -L -o /usr/local/bin/aptfile https://raw.githubusercontent.com/seatgeek/bash-aptfile/$APTFILE_VERSION/bin/aptfile
  sudo chmod +x /usr/local/bin/aptfile
fi

if ! command -v starship &> /dev/null; then
  echo "Installing Starship..."
  curl -sS https://starship.rs/install.sh | sudo sh -s -- --yes
fi

TREE_SITTER_VERSION="0.20.6"
if ! command -v tree-sitter &> /dev/null; then
  echo "Installing tree-sitter..."
  curl --silent -L -o tree-sitter-linux-x64.gz https://github.com/tree-sitter/tree-sitter/releases/download/v$TREE_SITTER_VERSION/tree-sitter-linux-x64.gz
  gunzip tree-sitter-linux-x64.gz
  chmod +x tree-sitter-linux-x64
  sudo mv tree-sitter-linux-x64 /usr/local/bin/tree-sitter
fi

# manually install because "package_from_url" doesn't understand git-delta missing package
GIT_DELTA_VERSION="0.13.0"
if ! command -v delta &> /dev/null; then
  echo "Installing git-delta..."
  curl --silent -L -o /tmp/git-delta.deb "https://github.com/dandavison/delta/releases/download/${GIT_DELTA_VERSION}/git-delta_${GIT_DELTA_VERSION}_amd64.deb"
  sudo dpkg -i /tmp/git-delta.deb
  rm /tmp/git-delta.deb
fi

sudo aptfile aptfile-common
sudo aptfile aptfile-amd64

if [ ! -d ~/.tmux/plugins/tpm ]; then
  echo "Installing tmux plugin manager..."
  git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm

  echo "Installing tmux plugins..."
  ~/.tmux/plugins/tpm/bin/install_plugins
fi

SHARE_DIR="${XDG_DATA_HOME:-$HOME/.local/share}"
VIM_PLUG="${SHARE_DIR}/nvim/site/autoload/plug.vim"
if [ ! -f $VIM_PLUG ]; then
  echo "Installing vim-plug..."
  VIM_PLUG_SRC=https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
  curl -fLo $VIM_PLUG --create-dirs $VIM_PLUG_SRC

  echo "Installing Neovim plugins..."
  nvim +PlugInstall +PlugUpdate +qall
fi

make

if command -v code &> /dev/null; then
  make install-vscode-extensions
fi
