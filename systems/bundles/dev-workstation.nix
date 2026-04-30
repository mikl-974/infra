{ pkgs, ... }:
{
  imports = [
    ../apps/neovim.nix
    ../development/nix-ld.nix
  ];

  environment.systemPackages = import ../../catalog/bundles/dev-workstation.nix { inherit pkgs; };

  environment.sessionVariables = {
    PLAYWRIGHT_BROWSERS_PATH = "${pkgs.playwright-driver.browsers}";
    PLAYWRIGHT_SKIP_BROWSER_DOWNLOAD = "1";
  };
}
