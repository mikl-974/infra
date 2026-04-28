{ ... }:
{
  imports = [
    ../desktop/default.nix
    ../bundles/desktop-apps.nix
    ../shell/default.nix
    ../theming/default.nix
  ];

  # MangoWM est le window manager utilisé sur ce poste.
  #
  # Configuration spécifique à MangoWM :
  # - Noctalia (theme système)
  # - Cloudflare WARP (client VPN desktop)
  #
  # Les applications quotidiennes sont incluses via ../bundles/desktop-apps.nix
  # La connectivité locale (Bluetooth, NetworkManager) est dans ../desktop/connectivity.nix

  # Cloudflare WARP: desktop-only VPN client. Kept in workstation because
  # it is a user-facing network tool, not a generic infrastructure primitive.
  workstation.desktop.warp.enable = true;

  # Noctalia est le theme système utilisé sur ce poste.
  # La configuration réelle du shell vit dans Home Manager via home/roles/noctalia.nix.
  workstation.theming.noctalia.enable = true;
}
