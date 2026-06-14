{ config, lib, pkgs, inputs, ... }:
let
  cfg = config.homelab.clients.hermes;
  hermesCli = pkgs.runCommand "hermes-cli" { } ''
    mkdir -p "$out/bin"
    ln -s ${cfg.package}/bin/hermes "$out/bin/hermes"
  '';
in
{
  options.homelab.clients.hermes = {
    enable = lib.mkEnableOption "Hermes client integration";

    package = lib.mkOption {
      type = lib.types.package;
      default = inputs.hermes-agent.packages.${pkgs.stdenv.hostPlatform.system}.default;
      defaultText = "inputs.hermes-agent.packages.<system>.default";
      description = "Hermes package exposed as a CLI-only client.";
    };

    sshHostAlias = lib.mkOption {
      type = lib.types.str;
      default = "hermes-backend";
      description = "Local SSH alias used to reach the Hermes backend host.";
    };

    backendHost = lib.mkOption {
      type = lib.types.str;
      default = "ms-s1-max";
      description = "SSH HostName for the Hermes backend.";
    };

    backendUser = lib.mkOption {
      type = lib.types.str;
      default = "mfo";
      description = "SSH user for the Hermes backend.";
    };
  };

  config = lib.mkIf cfg.enable {
    home.packages = [
      hermesCli
      pkgs.openssh
    ];

    programs.ssh = {
      enable = true;
      enableDefaultConfig = false;
      settings.${cfg.sshHostAlias} = {
        hostname = cfg.backendHost;
        user = cfg.backendUser;
      };
    };

    programs.zsh = {
      enable = true;
      shellAliases = {
        hermes-remote = "ssh ${cfg.sshHostAlias} hermes";
        hermes-gateway-status = "ssh ${cfg.sshHostAlias} \"systemctl --user status hermes-gateway.service || systemctl status hermes-gateway.service\"";
        hermes-home = "ssh ${cfg.sshHostAlias} \"cd /home/${cfg.backendUser}/.hermes && pwd && ls -la\"";
      };
    };
  };
}
