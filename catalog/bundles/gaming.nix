{ pkgs }:
  (import ../apps/steam.nix { inherit pkgs; })
  ++ (import ../apps/lutris.nix { inherit pkgs; })
  ++ (import ../apps/proton.nix { inherit pkgs; })
  ++ (import ../apps/wine.nix { inherit pkgs; })
