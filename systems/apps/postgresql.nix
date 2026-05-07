{ lib, config, hostVars, ... }:
let
  cfg = config.workstation.dev.postgresql;
in
{
  options.workstation.dev.postgresql.enable =
    lib.mkEnableOption "local PostgreSQL service for workstation development";

  config = lib.mkIf cfg.enable {
    services.postgresql = {
      enable = true;

      ensureDatabases = [ hostVars.username ];
      ensureUsers = [
        {
          name = hostVars.username;
          ensureDBOwnership = true;
          ensureClauses = {
            createdb = true;
            createrole = true;
          };
        }
      ];

      authentication = ''
        local all ${hostVars.username} peer
        host  all ${hostVars.username} 127.0.0.1/32 trust
        host  all ${hostVars.username} ::1/128      trust
      '';
    };

    environment.systemPackages = [ config.services.postgresql.finalPackage ];
  };
}
