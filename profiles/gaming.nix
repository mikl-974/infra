{ ... }:
{
  # Gaming profile — assembles the gaming role for a desktop workstation host.
  # Import this profile in hosts that are dedicated to or include a gaming setup.
  #
  # Requires: profiles/desktop-hyprland.nix (hardware.graphics, audio, compositor)
  imports = [
    ../modules/roles/gaming.nix
  ];
}
