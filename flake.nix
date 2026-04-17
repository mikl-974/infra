{
  description = "Personal workstation environments (NixOS, Hyprland, dotfiles, devshells)";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-24.11";

    foundation = {
      url = "github:mikl-974/foundation";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { nixpkgs, foundation, ... }:
    let
      lib = nixpkgs.lib;
      systems = [ "x86_64-linux" ];

      # Foundation NixOS modules consumed by all workstation hosts.
      sharedModules = [
        foundation.nixosModules.networkingTailscale
      ];
    in
    {
      nixosConfigurations = {
        main = lib.nixosSystem {
          system = "x86_64-linux";
          modules = sharedModules ++ [ ./hosts/main/default.nix ];
        };

        laptop = lib.nixosSystem {
          system = "x86_64-linux";
          modules = sharedModules ++ [ ./hosts/laptop/default.nix ];
        };

        gaming = lib.nixosSystem {
          system = "x86_64-linux";
          modules = sharedModules ++ [ ./hosts/gaming/default.nix ];
        };
      };

      # .NET devShell is defined locally — this is a workstation-specific dev
      # environment, not a generic shared primitive. See devshells/dotnet.nix.
      devShells = lib.genAttrs systems (system:
        let pkgs = import nixpkgs { inherit system; };
        in {
          dotnet = import ./devshells/dotnet.nix { inherit pkgs; };
        }
      );
    };
}
