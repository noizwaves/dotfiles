{ config, pkgs, ... }:

let
  symlinkTo = config.lib.file.mkOutOfStoreSymlink;
in {
  home.username = "adam";
  home.homeDirectory = if pkgs.stdenv.isDarwin then "/Users/adam" else "/home/adam";

  imports = [
    ./base.nix
  ];

  home.file = if pkgs.stdenv.isLinux then {
      # KDE configuration
      ".config/kwinrc".source = symlinkTo ../dotfiles/kwinrc;
      ".config/kglobalshortcutsrc".source = symlinkTo ../dotfiles/kglobalshortcutsrc;
    }
  else
    {
    };
}
