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

      settings = {
        wal_level = "logical";
        listen_addresses = lib.mkForce "*";
      };

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
        host  all electric 127.0.0.1/32   scram-sha-256
        host  all electric 10.88.0.0/16   scram-sha-256
        host  all electric 172.16.0.0/12  scram-sha-256
      '';
    };

    environment.systemPackages = [ config.services.postgresql.finalPackage ];
  };
}
