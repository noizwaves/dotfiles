# dotfiles

## Install
```
make
```

### Manual Steps
1. Install dependencies below
1. Install tmux plugins (`<prefix>I`)
1. Install Neovim plugins (`:PlugInstall`)

## Uninstall
```
make delete
```

## Dependencies
```
git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm

sh -c 'curl -fLo "${XDG_DATA_HOME:-$HOME/.local/share}"/nvim/site/autoload/plug.vim --create-dirs \
       https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim'

/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

brew tap homebrew/cask-fonts

brew install stow

brew install git
brew install git-delta

brew install tmux

brew install neovim
brew install fzf
brew install ripgrep
brew install fd
brew install tree-sitter

brew install iterm2
brew install --cask font-jetbrains-mono-nerd-font

brew install antigen
brew install direnv
brew install starship

brew install --cask visual-studio-code
```
