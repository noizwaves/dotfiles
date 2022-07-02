{  config, lib, ... }:

let
  cfg = config.myOverrides.ssh;
in
{
  options = with lib; {
    myOverrides.ssh.enabled = mkOption {
      type = types.bool;
      default = true;
    };
  };

  config = {
    programs.ssh = {
      enable = cfg.enabled;
      extraOptionOverrides = {
        "IgnoreUnknown" = "UseKeychain";
      };
      matchBlocks = {
        popintosh = {
          hostname = "popintosh.nodes.noizwaves.cloud";
          user = "adam";
        };
        odroid = {
          hostname = "odroid.nodes.noizwaves.cloud";
          user = "cloud";
        };
        odroidpikvm = {
          hostname = "odroidpikvm.nodes.noizwaves.cloud";
          user = "root";
        };
        linode-us-west = {
          hostname = "linode-us-west.nodes.noizwaves.cloud";
          user = "cloud";
        };
        storagepi = {
          hostname = "storagepi.nodes.noizwaves.cloud";
          user = "pi";
        };
        tinkerpi = {
          hostname = "tinkerpi.nodes.noizwaves.cloud";
          user = "pi";
        };
        "ssh-zp-adam-neumann-pdx.gusto-dev.com" = {
          hostname = "ssh-zp-adam-neumann-pdx.gusto-dev.com";
          port = 3022;
          user = "root";
          forwardAgent = true;
          extraOptions = {
            "UseKeychain" = "true";
          };
        };
      };
    };
  };
}
