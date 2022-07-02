{ config, lib, ... }:

let
  cfg = config.myOverrides.git;
in {
  options = with lib; {
    myOverrides.git.email = mkOption {
      type = types.str;
      default = "noizwaves@users.noreply.github.com";
    };
    myOverrides.git.enabled = mkOption {
      type = types.bool;
      default = true;
    };
  };

  config = {
    programs.git = {
      enable = cfg.enabled;
      userName = "Adam Neumann";
      userEmail = cfg.email;
      delta.enable = true;
      extraConfig = {
        core = { editor = "vim"; };
        init = { defaultBranch = "main"; };
        pull = { rebase = "true"; };
        push = { default = "current"; };
      };
      ignores = [
        "/.vscode/"
        "/.code/"
        "/.idea"

        "/.env"
        "/.envrc"
        "/.direnv/"

        "/.nvmrc"

        "/my-scripts/"
        ".DS_Store"
      ];
    };

    programs.zsh.shellAliases = {
      gs = "git status";
      ga = "git add -p";
      gp = "git pull";
      gc = "git commit";
      gca = "git commit --amend";
      gcan = "git commit --amend --no-edit";
      gcm = "git commit -m";
    };
  };
}
