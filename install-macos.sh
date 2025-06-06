#!/usr/bin/env bash
set -e

echo "Installing dotfiles for macOS"

make brew

if [[ $(hostname) != "adam-neumann-"* ]]; then
  make brew-personal
fi

$(brew --prefix)/opt/fzf/install --key-bindings --completion --no-update-rc --no-bash --no-fish --no-zsh &> /dev/null

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

if ! command -v grab &>/dev/null; then
  curl --silent https://raw.githubusercontent.com/noizwaves/grab/main/install.sh | bash
fi
grab --config-path grab/.grab install

make

make install-vscode-extensions

osascript -e 'tell application "System Events" to tell appearance preferences to set dark mode to true'

# TODO: Configure Caps Lock as Escape
# TODO: Configure Use F1, F2, etc as standard function keys
# TODO: Configure Finder to show home directory by default

mkdir ~/Screenshots
defaults write com.apple.screencapture location "$HOME/Screenshots"
