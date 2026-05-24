{ pkgs }:
let
  aspire-cli = pkgs.callPackage (
    {
      lib,
      buildDotnetGlobalTool,
      dotnetCorePackages,
    }:
    buildDotnetGlobalTool {
      pname = "aspire-cli";
      version = "13.3.4";
      nugetName = "Aspire.Cli";
      nugetHash = "sha256-PlQDx73lokIH8GdTI/OXshke47J9Dqqa6zVC/BFcJ6Y=";
      nugetDeps = builtins.toFile "aspire-cli-nuget-deps.json" (builtins.toJSON [
        {
          pname = "Aspire.Cli.linux-x64";
          version = "13.3.4";
          hash = "sha256-Ww3TlBNGqZFkp2GKKVxdw4O4R1gJEL/G294gAonK+8o=";
          installable = true;
        }
      ]);
      dotnet-sdk = dotnetCorePackages.sdk_10_0-bin;
      executables = [ "aspire" ];

      meta = {
        description = "Command line tool for Aspire developers";
        homepage = "https://github.com/microsoft/aspire";
        downloadPage = "https://www.nuget.org/packages/Aspire.Cli";
        license = lib.licenses.mit;
        mainProgram = "aspire";
        platforms = lib.platforms.linux;
      };
    }
  ) { };
in
[
  aspire-cli
]
