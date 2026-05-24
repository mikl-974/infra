{ pkgs }:
[
  (pkgs.dotnetCorePackages.combinePackages [
    pkgs.dotnetCorePackages.sdk_10_0-bin
    pkgs.dotnetCorePackages.sdk_9_0-bin
  ])
]
