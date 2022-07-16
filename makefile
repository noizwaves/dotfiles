all:
	stow --target=$$HOME --restow */

delete:
	stow --target=$$HOME --delete */
