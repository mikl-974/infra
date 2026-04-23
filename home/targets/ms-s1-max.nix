{
  mfo = {
    imports = [
      ../users/mfo.nix
      ../roles/desktop-hyprland.nix
      ../roles/gaming-steam.nix
      ../roles/browser-chromium.nix
    ];
  };

  dfo = {
    imports = [
      ../users/dfo.nix
      ../roles/desktop-gnome.nix
      ../roles/gaming-lutris.nix
      ../roles/gaming-steam.nix
      ../roles/browser-firefox.nix
      ../roles/terminal-kitty.nix
    ];
  };
}
