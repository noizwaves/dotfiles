#!/usr/bin/env bash

APTFILE_VERSION="1.2.0"
if ! command -v aptfile &> /dev/null; then
  echo "Installing aptfile..."
  curl --silent -L -o /usr/local/bin/aptfile https://raw.githubusercontent.com/seatgeek/bash-aptfile/$APTFILE_VERSION/bin/aptfile
  chmod +x /usr/local/bin/aptfile
fi

# manually install because "package_from_url" doesn't understand git-delta missing package
GIT_DELTA_VERSION="0.13.0"
if ! command -v delta &> /dev/null; then
  echo "Installing git-delta..."
  curl --silent -L -o /tmp/git-delta.deb "https://github.com/dandavison/delta/releases/download/${GIT_DELTA_VERSION}/git-delta_${GIT_DELTA_VERSION}_arm64.deb"
  dpkg -i /tmp/git-delta.deb
  rm /tmp/git-delta.deb
fi

aptfile aptfile-common

# remove any defaults
rm -f $HOME/.gitconfig $HOME/.gitconfig_inc_gusto $HOME/.gitignore $HOME/.config/starship.toml $HOME/.zshenv $HOME/.zshrc

make all-devcontainers
