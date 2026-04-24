# This file is sourced by /etc/nixos/configuration.nix on the OrbStack VM.
# It adds a oneshot systemd service that re-applies the flake-based
# `homelab` configuration on every boot, defeating OrbStack's automatic
# revert of /nix/var/nix/profiles/system to the lxc baseline.

{ config, pkgs, lib, ... }:
{
  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  systemd.services.infra-rebuild-on-boot = {
    description = "Re-apply NixOS flake config on boot (OrbStack reset workaround)";
    wantedBy = [ "multi-user.target" ];
    after    = [ "network-online.target" ];
    wants    = [ "network-online.target" ];
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
      TimeoutStartSec = "30min";
      Environment = [ "HOME=/root" ];
    };
    path = [ pkgs.git pkgs.nixos-rebuild config.nix.package ];
    script = ''
      set -eu
      REPO=/etc/infra
      if [ ! -d "$REPO/.git" ]; then
        echo "infra repo absent dans $REPO, rien à faire"
        exit 0
      fi
      CURRENT=$(readlink /run/current-system || true)
      case "$CURRENT" in
        *nixos-system-homelab-2[6-9]*|*nixos-system-homelab-[3-9]*)
          echo "homelab déjà actif: $CURRENT"
          exit 0
          ;;
      esac
      cd "$REPO"
      git config --global --add safe.directory "$REPO" || true
      git pull --ff-only || echo "git pull a échoué, on continue avec la révision locale"
      exec nixos-rebuild switch --impure --flake "$REPO#homelab"
    '';
  };
}
