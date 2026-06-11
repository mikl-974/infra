{ pkgs, ... }:
{
  imports = [
    ../../../../systems/profiles/workstation-common.nix
    ../../../../systems/users/root.nix
    ./user.nix
    ./capabilities.nix
  ];

  infra.security.sops = {
    enable = true;
  };

  infra.users.root = {
    enable = true;
    sopsFile = ../../../../secrets/common.yaml;
  };

  # Bootstrap password hash for the first NixOS install.
  # The host-specific sops file is currently not decryptable with the canonical
  # Age identity available in this repo, so keep the workstation installable and
  # rotate the password back into sops once the host is up.
  users.users.mfo.hashedPassword =
    "$y$j9T$84Kov0jVH3Bmj6ToiyqM8/$HNrOk4xunHbPOC4BKidk/7uyQym1ENr07p5uLYQV2M4";

  boot.loader.systemd-boot.configurationLimit = 3;

  nix.gc = {
    automatic = true;
    dates = "weekly";
  };

  systemd.services.nixos-prune-generations = {
    description = "Keep only the last 5 NixOS system generations";
    serviceConfig.Type = "oneshot";
    path = [ pkgs.nix ];
    script = ''
      nix-env --profile /nix/var/nix/profiles/system --delete-generations +5
    '';
    startAt = "weekly";
  };

}
