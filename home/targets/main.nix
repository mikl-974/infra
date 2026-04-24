# Home Manager composition for the concrete target `main`.
#
# This host is intentionally simple for now: one real user, one reusable desktop
# role, and one explicit target composition.
{
  mfo = {
    imports = [
      ../users/mfo.nix
      ../roles/desktop-hyprland.nix
      ../roles/noctalia.nix
    ];
  };
}
