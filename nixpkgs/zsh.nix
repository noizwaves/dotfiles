{ lib, pkgs, ... }:
{
  programs.zsh = {
    enable = true;
    enableAutosuggestions = true;
    enableCompletion = true;

    sessionVariables = {
      # Treat path parts as separate words
      WORDCHARS = "";
    };

    shellAliases = {
      "rc" = "source ~/.zshrc; echo 'Reloaded config'";
      "ni" = if pkgs.stdenv.isDarwin then "home-manager switch" else "sudo nixos-rebuild switch --cores 0";
    };

    initExtra = ''
    bindkey -s ^f "tmux-sessionizer\n"

    # from https://github.com/kovidgoyal/kitty/issues/838#issuecomment-770328902
    # fix option+arrow word moving in kitty
    bindkey "\e[1;3D" backward-word # ⌥←
    bindkey "\e[1;3C" forward-word # ⌥→
    '' + (lib.optionalString pkgs.stdenv.isDarwin ''
    # ensure home-manager is on path for macOS systems
    export NIX_PATH=$NIX_PATH:$HOME/.nix-defexpr/channels

    # fix option+arrow word moving in iterm
    bindkey "\e\e[D" backward-word # ⌥←
    bindkey "\e\e[C" forward-word # ⌥→

    # execute any local overrides if present
    [ -f "$HOME/.zshrc.local" ] && source "$HOME/.zshrc.local"

    # execute any aliases files if present
    [ -f "$HOME/.aliases" ] && source "$HOME/.aliases"

    # load custom commands
    [ -f "$HOME/.commands" ] && source "$HOME/.commands"
    '');
  };
}
