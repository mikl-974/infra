{ pkgs, ... }:
{
  environment.systemPackages =
    (import ../../catalog/apps/opencode-desktop.nix { inherit pkgs; })
    ++ [
      (pkgs.writeShellScriptBin "opencode" ''
        exec ${pkgs.opencode-desktop}/bin/OpenCode "$@"
      '')
    ];
}
