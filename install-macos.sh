#!/usr/bin/env bash

echo "Installing dotfiles for macOS"

make brew

if [[ $(hostname) != "adam-neumann-"* ]]; then
  make brew-personal
fi

$(brew --prefix)/opt/fzf/install --key-bindings --completion --no-update-rc --no-bash --no-fish &> /dev/null

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

make install-vscode-extensions
