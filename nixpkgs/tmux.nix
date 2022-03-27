{ ... }:
{
  programs.tmux = {
    enable = true;

    # so first tab starts on left num row
    baseIndex = 1;

    # eliminate wait when escaping out of modes in vim
    escapeTime = 0;

    # fix colors (like zsh auto completes)
    # https://unix.stackexchange.com/questions/1045/getting-256-colors-to-work-in-tmux
    terminal = "screen-256color";

    extraConfig = ''
    bind-key f run-shell "tmux neww tmux-sessionizer"
    bind-key r source-file ~/.config/tmux/tmux.conf \; display-message "Reloaded config"

    set -g mouse on
    '';
  };
}
