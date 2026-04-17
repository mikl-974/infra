{ pkgs }:
pkgs.mkShell {
  name = "dotnet";

  packages = with pkgs; [
    dotnet-sdk
    git
    curl
    jq
    openssl
    pkg-config
  ];
}
