{
  description = "Personal workstation environments (NixOS, Hyprland, dotfiles, devshells)";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-24.11";
  };

  outputs = { nixpkgs, ... }:
    let
      lib = nixpkgs.lib;
      systems = [ "x86_64-linux" ];
      forAllSystems = f: lib.genAttrs systems (system: f (import nixpkgs { inherit system; }));
    in
    {
      nixosConfigurations = {
        main = lib.nixosSystem {
          system = "x86_64-linux";
          modules = [ ./hosts/main/default.nix ];
        };

        laptop = lib.nixosSystem {
          system = "x86_64-linux";
          modules = [ ./hosts/laptop/default.nix ];
        };

        gaming = lib.nixosSystem {
          system = "x86_64-linux";
          modules = [ ./hosts/gaming/default.nix ];
        };
      };

      devShells = forAllSystems (pkgs: {
        dotnet = import ./devshells/dotnet.nix { inherit pkgs; };
      });
    };
}
