#!/usr/bin/env bash
set -e

LOCAL_BIN="$HOME/.local/bin"
TMP_DIR=$(mktemp -d)

echo "Installing dotfiles for devops"
mkdir -p "$LOCAL_BIN"

STARSHIP_VERSION=1.16.0
if [ ! -f "${LOCAL_BIN}/starship" ]; then
  echo "Installing Starship..."
  curl --silent -L -o "${TMP_DIR}/starship.tar.gz" https://github.com/starship/starship/releases/download/v${STARSHIP_VERSION}/starship-x86_64-unknown-linux-musl.tar.gz
  tar --directory "$TMP_DIR" -zxf "${TMP_DIR}/starship.tar.gz"
  mv "${TMP_DIR}/starship" "${LOCAL_BIN}/"
fi

GIT_DELTA_VERSION="0.16.5"
if [ ! -f "${LOCAL_BIN}/delta" ]; then
  echo "Installing git-delta..."
  curl --silent -L -o "${TMP_DIR}/git-delta.tar.gz" "https://github.com/dandavison/delta/releases/download/${GIT_DELTA_VERSION}/delta-${GIT_DELTA_VERSION}-x86_64-unknown-linux-musl.tar.gz"
  tar --directory "$TMP_DIR" -zxf "${TMP_DIR}/git-delta.tar.gz"
  mv "${TMP_DIR}/delta-${GIT_DELTA_VERSION}-x86_64-unknown-linux-musl/delta" "${LOCAL_BIN}/"
fi

FZF_VERSION="0.42.0"
if [ ! -f "${LOCAL_BIN}/fzf" ]; then
  echo "Installing fzf..."
  curl --silent -L -o "${TMP_DIR}/fzf.tar.gz" "https://github.com/junegunn/fzf/releases/download/${FZF_VERSION}/fzf-${FZF_VERSION}-linux_amd64.tar.gz"
  tar --directory "$TMP_DIR" -zxf "${TMP_DIR}/fzf.tar.gz"
  mv "${TMP_DIR}/fzf" "${LOCAL_BIN}/"
fi

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
