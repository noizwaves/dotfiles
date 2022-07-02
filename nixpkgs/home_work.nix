{ config, pkgs, ... }:

let
  symlinkTo = config.lib.file.mkOutOfStoreSymlink;
in {
  home.username = "adam.neumann";
  home.homeDirectory = "/Users/adam.neumann";

  imports = [
    ./base.nix
  ];

  home.file = {
    ".aliases".source = symlinkTo ../dotfiles/work/.aliases;
    ".zshrc.local".source = symlinkTo ../dotfiles/work/.zshrc.local;
    ".commands.local".source = symlinkTo ../dotfiles/work/.commands.local;
  };

  myOverrides.git= {
    email = "adam.neumann@gusto.com";
    enabled = false;
  };
}
