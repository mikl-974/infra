{ ... }:
{
  imports = [
    ../modules/desktop/default.nix
    ../modules/apps/default.nix
    ../modules/shell/default.nix
    ../modules/theming/default.nix
  ];

  # Cloudflare WARP: desktop-only VPN client. Kept in workstation because
  # it is a user-facing network tool, not a generic infrastructure primitive.
  workstation.desktop.warp.enable = true;
}
