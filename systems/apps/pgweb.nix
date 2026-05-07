{ lib, config, pkgs, hostVars, ... }:
let
  cfg = config.workstation.dev.pgweb;
  pgwebUrl = "postgresql://${hostVars.username}@127.0.0.1:5432/${hostVars.username}?sslmode=disable";
in
{
  options.workstation.dev.pgweb = {
    enable = lib.mkEnableOption "local pgweb UI for the workstation PostgreSQL service";

    port = lib.mkOption {
      type = lib.types.port;
      default = 5050;
      description = "Local TCP port used by pgweb.";
    };
  };

  config = lib.mkIf cfg.enable {
    assertions = [
      {
        assertion = config.workstation.dev.postgresql.enable;
        message = "workstation.dev.pgweb requires workstation.dev.postgresql.enable = true;";
      }
    ];

    environment.systemPackages = [ pkgs.pgweb ];

    systemd.services.pgweb = {
      description = "pgweb local PostgreSQL UI";
      wants = [ "postgresql.target" ];
      after = [ "postgresql.target" "network.target" ];
      wantedBy = [ "multi-user.target" ];
      path = [ pkgs.getent ];

      serviceConfig = {
        User = hostVars.username;
        ExecStart = lib.escapeShellArgs [
          "${pkgs.pgweb}/bin/pgweb"
          "--bind=127.0.0.1"
          "--listen=${toString cfg.port}"
          "--url"
          pgwebUrl
        ];
        Restart = "on-failure";
        RestartSec = "5s";
      };
    };
  };
}
