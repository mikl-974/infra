# Home Manager composition for `mac-mini`.
# darwin-rebuild switch --flake /Users/mickael/Code/infra#mac-mini
{ ... }:
{
  mickael = { ... }:
    {
      imports = [
        ../modules/hermes-client.nix
      ];

      home.username = "mickael";
      home.homeDirectory = /Users/mickael;
      home.stateVersion = "24.11";

      programs.home-manager.enable = true;

      homelab.clients.hermes = {
        enable = true;
        sshHostAlias = "hermes-backend";
        backendHost = "ms-s1-max";
        backendUser = "mfo";
      };
    };
}
