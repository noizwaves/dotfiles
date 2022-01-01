{ pkgs, ... }:
let
  dracula-kitty = pkgs.callPackage ./mypkgs/dracula-kitty.nix { };
in
{
  # kitty config inspired by https://youtu.be/434tljD-5C8?t=355
  programs.kitty = {
    enable = true;

    settings = {
      include = "${dracula-kitty}/dracula.conf";

      # Use `kitty --list-fonts` to show available font families
      # Use `fc-cache -f` to refresh font cache
      # - https://github.com/nix-community/home-manager/issues/520#issuecomment-451759097
      font_size = 14;

      # TODO: figure out why the nerd font causes symbols to not render well
      #font_family = "JetBrainsMono Nerd Font";
      font_family = "JetBrains Mono";

      # explicitly use symbols from NerdFont
      # from https://github.com/pecigonzalo/malob-nixpkgs/blob/master/modules/home/programs/kitty/extras.nix#L125
      symbol_map = "U+E5FA-U+E62B,U+E700-U+E7C5,U+F000-U+F2E0,U+E200-U+E2A9,U+F500-U+FD46,U+E300-U+E3EB,U+F400-U+F4A8,U+2665,U+26a1,U+F27C,U+E0A3,U+E0B4-U+E0C8,U+E0CA,U+E0CC-U+E0D2,U+E0D4,U+23FB-U+23FE,U+2B58,U+F300-U+F313,U+E000-U+E00D JetBrainsMono Nerd Font";

      cursor_blink_interval = 0;
      window_padding_width = 10;
      enable_audio_bell = false;

      hide_window_decorations = true;
    };

    extraConfig = ''
    map super+shift+] next_tab
    map super+shift+[ previous_tab
    map super+t new_tab
    map super+w close_tab
    '';
  };
}
