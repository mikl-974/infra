{ ... }:
{
  home.stateVersion = "24.11";
  xdg.enable = true;

  # Dotfiles — raw applicative config files managed via symlinks.
  # The Nix modules install packages and enable system integrations.
  # Home Manager is responsible for linking the active user config files.
  home.file = {
    ".config/hypr/hyprland.conf".source = ../../dotfiles/hyprland/hyprland.conf;

    ".config/foot/foot.ini".source = ../../dotfiles/terminal/foot.ini;

    ".config/wofi/config".source = ../../dotfiles/launchers/config;
    ".config/wofi/style.css".source = ../../dotfiles/launchers/style.css;

    ".config/mako/config".source = ../../dotfiles/notifications/config;
  };
}
