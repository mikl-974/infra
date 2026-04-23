{ lib, config, ... }:
let
  cfg = config.infra.stacks.openclaw;
in
{
  options.infra.stacks.openclaw = {
    enable = lib.mkEnableOption "OpenClaw application stack";

    dataDir = lib.mkOption {
      type = lib.types.str;
      default = "/var/lib/openclaw";
      description = "Persistent OpenClaw application data directory.";
    };

    configDir = lib.mkOption {
      type = lib.types.str;
      default = "/etc/openclaw";
      description = "Host-local OpenClaw configuration directory.";
    };

    logDir = lib.mkOption {
      type = lib.types.str;
      default = "/var/log/openclaw";
      description = "Host-local OpenClaw log directory.";
    };
  };

  config = lib.mkIf cfg.enable {
    systemd.tmpfiles.rules = [
      "d ${cfg.dataDir} 0750 root root -"
      "d ${cfg.configDir} 0755 root root -"
      "d ${cfg.logDir} 0750 root root -"
    ];

    environment.etc."openclaw/stack-context".text = "openclaw\n";
  };
}
