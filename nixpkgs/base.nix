{ config, pkgs, ... }:

{
  #home.username = "";
  #home.homeDirectory = "";

  imports = [
    ./fonts.nix
    ./git.nix
    ./kitty.nix
    ./neovim.nix
    ./ssh.nix
    ./starship.nix
    ./tmux.nix
    ./modules/tmux-sessionizer
    ./zsh.nix
  ];

  home.packages = with pkgs; [
    ripgrep
  ] ++ (if pkgs.stdenv.isLinux then with pkgs; [
    tdesktop
    lutris
  ] else []);

  programs.direnv = {
    enable = true;
    enableZshIntegration = true;
    nix-direnv.enable = true;
  };

  home.file = { 
    ".commands".source = ../dotfiles/commands;
  };

  nixpkgs.config.allowUnfree = true;
  home.stateVersion = "21.11";
  programs.home-manager.enable = true;
}
