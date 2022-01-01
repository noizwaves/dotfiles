{ ... }:
{
  programs.ssh = {
    enable = true;
    matchBlocks = {
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
    };
  };
}