all:
	stow --ignore=com.googlecode.iterm2.plist --ignore=Stats.plist --target=$$HOME --restow */

all-devcontainers:
	stow --target=$$HOME --restow git starship zsh dotlocalbin

all-server:
	stow --target=$$HOME --restow git starship tmux zsh ssh dotlocalbin

all-devops:
	stow --target=$$HOME --restow git starship tmux zsh ssh dotlocalbin

delete:
	stow --ignore=com.googlecode.iterm2.plist --ignore=Stats.plist --target=$$HOME --delete */

brew:
	brew bundle --no-lock

brew-personal:
	brew bundle --file personal.Brewfile --no-lock

install-vscode-extensions:
	cat ~/Library/Application\ Support/Code/User/extensions.txt | xargs -L 1 code --install-extension

dump-vscode-extensions:
	code --list-extensions > ~/Library/Application\ Support/Code/User/extensions.txt
