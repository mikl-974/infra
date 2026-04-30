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
      version = "13.2.4";
      nugetName = "Aspire.Cli";
      nugetHash = "sha256-DAvmH9AWp/i1dUnigfy4a19CSjXxJxZ782f5ltSNHxw=";
      dotnet-sdk = dotnetCorePackages.sdk_10_0;
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
