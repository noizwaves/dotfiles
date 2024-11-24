#!/usr/bin/env bash
set -e

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

echo "Installing dotfiles for Ubuntu"

APTFILE_VERSION="1.2.0"
if ! command -v aptfile &> /dev/null; then
  echo "Installing aptfile..."
  sudo curl --silent -L -o /usr/local/bin/aptfile https://raw.githubusercontent.com/seatgeek/bash-aptfile/$APTFILE_VERSION/bin/aptfile
  sudo chmod +x /usr/local/bin/aptfile
fi

# nerd fonts
mkdir -p ~/.local/share/fonts
NERD_FONT_VERSION="3.1.1"
if ! ls -al ~/.local/share/fonts | grep -v JetBrainsMono &> /dev/null; then
  curl -L -o nerdfont.zip https://github.com/ryanoasis/nerd-fonts/releases/download/v${NERD_FONT_VERSION}/JetBrainsMono.zip
  unzip nerdfont.zip ~/.local/share/fonts
  rm nerdfont.zip
fi

# keys for apt
curl -s https://syncthing.net/release-key.txt | sudo apt-key add -

sudo aptfile aptfile-common
sudo aptfile aptfile-personal
if [ "$(arch)" == "x86_64" ]; then
  sudo aptfile aptfile-amd64
fi

if ! command -v grab &>/dev/null; then
  curl --silent https://raw.githubusercontent.com/noizwaves/grab/main/install.sh | bash
fi
grab --config-path grab/.grab install

# remove any defaults
rm -f $HOME/.gitconfig $HOME/.gitconfig_inc_gusto $HOME/.gitignore $HOME/.config/starship.toml $HOME/.zshenv $HOME/.zshrc

make

# ZSH me pls
sudo usermod --shell /bin/zsh $(whoami)

# Configure Gnome desktop (with Kinto running)
dconf write /org/gnome/shell/keybindings/toggle-application-view "['<Alt>F1']"
dconf write /org/gnome/settings-daemon/plugins/media-keys/home "['']"
dconf write /org/gnome/settings-daemon/plugins/media-keys/email "['']"
dconf write /org/gnome/settings-daemon/plugins/media-keys/www "['']"
dconf write /org/gnome/settings-daemon/plugins/media-keys/terminal "['']"

# Configure Gnome dock
dconf write /org/gnome/shell/extensions/dash-to-dock/dock-fixed 'false'

if [ ! -d ~/.tmux/plugins/tpm ]; then
  echo "Installing tmux plugin manager..."
  git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm

  echo "Installing tmux plugins..."
  ~/.tmux/plugins/tpm/bin/install_plugins
fi

if command -v nvim &> /dev/null; then
  SHARE_DIR="${XDG_DATA_HOME:-$HOME/.local/share}"
  VIM_PLUG="${SHARE_DIR}/nvim/site/autoload/plug.vim"
  if [ ! -f $VIM_PLUG ]; then
    echo "Installing vim-plug..."
    VIM_PLUG_SRC=https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
    curl -fLo $VIM_PLUG --create-dirs $VIM_PLUG_SRC

    echo "Installing Neovim plugins..."
    nvim +PlugInstall +PlugUpdate +qall
  fi
fi

# VS Code is installed and running in a GUI (i.e. not a remote connection)
if (command -v code &> /dev/null) && (type Xorg &> /dev/null); then
  make install-vscode-extensions
fi
