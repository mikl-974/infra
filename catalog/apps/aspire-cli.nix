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
      version = "13.4.3";
      nugetName = "Aspire.Cli";
      nugetHash = "sha256-ZSuirGmyTp9p4R4XgRXlkuvKiuds/dmMelSRBBHDL2E=";
      nugetDeps = builtins.toFile "aspire-cli-nuget-deps.json" (builtins.toJSON [
        {
          pname = "Aspire.Cli.linux-x64";
          version = "13.4.3";
          hash = "sha256-SnmEdHt3c/Zeheoe0eawyiuC4z9fxo90yLP88Vg2Z5g=";
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
