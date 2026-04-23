{ ... }:
{
  # Temporary compatibility fallback for legacy targets not yet migrated to home/targets/
  # (currently laptop and gaming).
  imports = [
    ./base.nix
    ../roles/desktop-hyprland.nix
  ];
}
