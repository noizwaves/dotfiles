# dotfiles

## Install
```
make
```

### Manual Steps
1. Install dependencies below
1. Install tmux plugins (`<prefix>I`)

## Uninstall
```
make delete
```

## Dependencies
```
git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm

/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

brew tap homebrew/cask-fonts

brew install stow

brew install git
brew install git-delta

brew install tmux
brew install fzf

brew install iterm2
brew install antigen
brew install direnv
brew install starship
brew install --cask font-jetbrains-mono-nerd-font
brew install --cask visual-studio-code
```
