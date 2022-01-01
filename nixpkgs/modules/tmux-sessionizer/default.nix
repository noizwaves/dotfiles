{ pkgs, ... }:

# tmux session management
# based upon ThePrimeagen's tmux-sessionizer
# https://github.com/ThePrimeagen/.dotfiles/blob/master/bin/.local/bin/tmux-sessionizer
let
  tmux-sessionizer = pkgs.writeShellScriptBin "tmux-sessionizer" ./tmux-sessionizer.sh;
in {
  home.packages = with pkgs; [
    fzf
    tmux-sessionizer
  ];
}
