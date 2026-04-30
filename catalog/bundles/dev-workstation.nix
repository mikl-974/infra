{ pkgs }:
  (import ./dev.nix { inherit pkgs; })
  ++ (import ../apps/dev-cli.nix { inherit pkgs; })
  ++ (import ../apps/aspire-cli.nix { inherit pkgs; })
  ++ (import ../apps/typescript.nix { inherit pkgs; })
  ++ (import ../apps/playwright.nix { inherit pkgs; })
