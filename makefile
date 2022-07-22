all:
	stow --ignore=com.googlecode.iterm2.plist --target=$$HOME --restow */

delete:
	stow --ignore=com.googlecode.iterm2.plist --target=$$HOME --delete */

brew:
	brew bundle --no-lock

brew-personal:
	brew bundle --file personal.Brewfile --no-lock
