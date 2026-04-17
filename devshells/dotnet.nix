# Workstation .NET development shell.
#
# This shell is local to workstation — it is NOT a generic shared primitive.
# It represents the actual personal dev environment for this workstation:
# IDEs (Rider, WebStorm), Docker, and supporting CLI tooling live here.
#
# Do not move this to foundation. foundation hosts generic, server-side
# reusable modules. A personal dev workstation shell belongs here.
{ pkgs }:
pkgs.mkShell {
  packages = with pkgs; [
    dotnet-sdk
    git
    curl
    jq
    openssl
    pkg-config
    docker-client
  ];
}
