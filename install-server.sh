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

echo "Installing dotfiles for server"

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

# manually install because "package_from_url" doesn't understand git-delta missing package
GIT_DELTA_VERSION="0.13.0"
if ! command -v delta &> /dev/null; then
  echo "Installing git-delta..."
  curl --silent -L -o /tmp/git-delta.deb "https://github.com/dandavison/delta/releases/download/${GIT_DELTA_VERSION}/git-delta_${GIT_DELTA_VERSION}_$(farch amd64 arm64).deb"
  sudo dpkg -i /tmp/git-delta.deb
  rm /tmp/git-delta.deb
fi

sudo aptfile aptfile-common

# ZSH me pls
sudo usermod --shell /bin/zsh $(whoami)

# remove any defaults
rm -f $HOME/.gitconfig $HOME/.gitconfig_inc_gusto $HOME/.gitignore $HOME/.config/starship.toml $HOME/.zshenv $HOME/.zshrc

make all-server
