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

      # .NET devShell is consumed from foundation — no local duplication.
      # To add workstation-specific packages on top, extend it here.
      devShells = lib.genAttrs systems (system: {
        dotnet = foundation.devShells.${system}.dotnet;
      });
    };
}
