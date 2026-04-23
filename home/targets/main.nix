# Home Manager composition for the concrete target `main`.
#
# This host is intentionally simple for now: one real user, one reusable desktop
# role, and no hidden fallback to home/users/default.nix.
{
  mikl = {
    imports = [
      ../users/mikl.nix
      ../roles/desktop-hyprland.nix
    ];
  };
}
