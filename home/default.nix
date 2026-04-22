{ ... }:
{
  home.stateVersion = "24.11";
  xdg.enable = true;

  # Dotfiles — raw applicative config files managed via symlinks.
  # The Nix modules install packages and enable system integrations.
  # Home Manager is responsible for linking the active user config files.
  home.file = {
    ".config/hypr/hyprland.conf".source = ../dotfiles/hypr/hyprland.conf;

    ".config/foot/foot.ini".source = ../dotfiles/foot/foot.ini;

    ".config/wofi/config".source = ../dotfiles/wofi/config;
    ".config/wofi/style.css".source = ../dotfiles/wofi/style.css;

    ".config/mako/config".source = ../dotfiles/mako/config;
  };
}
