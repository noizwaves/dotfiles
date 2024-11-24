#!/usr/bin/env bash

function farch() {
  local amd="$1"
  local arm="$2"

  case "$(arch)" in
    x86_64)
      echo $amd
      ;;
    aarch64)
      echo $arm
      ;;
    *)
      >&2 echo "Unsupported architecture: $(arch)"
      exit 1
  esac
}

export DEBIAN_FRONTEND=noninteractive

echo "Installing dotfiles for devcontainers"

APTFILE_VERSION="1.2.0"
if ! command -v aptfile &> /dev/null; then
  echo "Installing aptfile..."
  sudo curl --silent -L -o /usr/local/bin/aptfile https://raw.githubusercontent.com/seatgeek/bash-aptfile/$APTFILE_VERSION/bin/aptfile
  sudo chmod +x /usr/local/bin/aptfile
fi

sudo aptfile aptfile-common

if ! command -v grab &>/dev/null; then
  curl --silent https://raw.githubusercontent.com/noizwaves/grab/main/install.sh | bash
fi
grab --config-path grab/.grab install

# ZSH me pls
sudo usermod --shell /bin/zsh $(whoami)

# remove any defaults
rm -f $HOME/.gitconfig $HOME/.gitconfig_inc_gusto $HOME/.gitignore $HOME/.config/starship.toml $HOME/.zshenv $HOME/.zshrc

make all-devcontainers
