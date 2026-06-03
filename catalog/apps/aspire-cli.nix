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
      version = "13.4.0";
      nugetName = "Aspire.Cli";
      nugetHash = "sha256-VifjAp+pym6RenIlf4hpw/NhvOr+S9P5h+1Y//DfPB4=";
      nugetDeps = builtins.toFile "aspire-cli-nuget-deps.json" (builtins.toJSON [
        {
          pname = "Aspire.Cli.linux-x64";
          version = "13.4.0";
          hash = "sha256-6pE00hjm4C44iVCoJ4/fWQEx4qYrcCPJ19diOFA4YG8=";
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
