all:
	stow --ignore=com.googlecode.iterm2.plist --target=$$HOME --restow */

delete:
	stow --ignore=com.googlecode.iterm2.plist --target=$$HOME --delete */
