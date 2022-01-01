{ config, lib, ... }:

let
  cfg = config.myOverrides.git;
in {
  options = with lib; {
    myOverrides.git.email = mkOption {
      type = types.str;
      default = "noizwaves@users.noreply.github.com";
    };
  };

  config = {
    programs.git = {
      enable = true;
      userName = "Adam Neumann";
      userEmail = cfg.email;
      extraConfig = {
        core = { editor = "vim"; };
        init = { defaultBranch = "main"; };
        pull = { rebase = "true"; };
      };
      ignores = [
        "/.vscode/"
        "/.code/"
        "/.idea"

        "/.envrc"
        "/.nvmrc"

        "/my-scripts/"
      ];
    };

    programs.zsh.shellAliases = {
      gs = "git status";
      ga = "git add -p";
      gp = "git pull";
      gc = "git commit";
      gcan = "git commit --amend --no-edit";
      gcm = "git commit -m";
    };
  };
}
