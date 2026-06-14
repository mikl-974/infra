{ config, lib, pkgs, ... }:
let
  cfg = config.homelab.services.ollamaDarwin;
in
{
  options.homelab.services.ollamaDarwin = {
    enable = lib.mkEnableOption "Ollama service on Darwin";

    package = lib.mkOption {
      type = lib.types.package;
      default = pkgs.ollama;
      defaultText = "pkgs.ollama";
      description = "Ollama package used by the Darwin launchd service.";
    };

    host = lib.mkOption {
      type = lib.types.str;
      default = "0.0.0.0";
      description = "Address Ollama listens on. Use the Mac firewall/Tailscale policy to restrict access.";
    };

    port = lib.mkOption {
      type = lib.types.port;
      default = 11434;
      description = "Ollama listen port.";
    };
  };

  config = lib.mkIf cfg.enable {
    environment.systemPackages = [ cfg.package ];

    launchd.user.agents.ollama = {
      serviceConfig = {
        ProgramArguments = [ "${cfg.package}/bin/ollama" "serve" ];
        EnvironmentVariables = {
          OLLAMA_HOST = "${cfg.host}:${toString cfg.port}";
          OLLAMA_KEEP_ALIVE = "10m";
          OLLAMA_MAX_LOADED_MODELS = "1";
          OLLAMA_NUM_PARALLEL = "1";
        };
        KeepAlive = true;
        RunAtLoad = true;
        StandardOutPath = "/tmp/ollama.log";
        StandardErrorPath = "/tmp/ollama.error.log";
      };
    };
  };
}
