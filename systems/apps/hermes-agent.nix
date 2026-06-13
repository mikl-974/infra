{ config, lib, pkgs, ... }:
let
  cfg = config.homelab.services.hermes;
  yaml = pkgs.formats.yaml { };
  defaultUser = "mfo";
  defaultHome = "/home/${defaultUser}/.hermes";
  defaultBinary = "/home/${defaultUser}/.local/bin/hermes";
  homeDirectory = dirOf cfg.home;
  binaryDirectory = dirOf cfg.binary;
  binaryRoot = dirOf binaryDirectory;
  workspacesRoot =
    if cfg.workspaces.root == null
    then "${cfg.home}/kanban/workspaces"
    else cfg.workspaces.root;
  basePath = [
    "/run/current-system/sw/bin"
    binaryDirectory
    "/nix/var/nix/profiles/default/bin"
    "/usr/local/bin"
    "/usr/bin"
    "/bin"
  ];
  serviceEnvironment = cfg.extraEnvironment // {
    HOME = homeDirectory;
    HERMES_HOME = cfg.home;
    HERMES_KANBAN_DISPATCH_IN_GATEWAY =
      if cfg.kanban.dispatchInGateway then "true" else "false";
    PATH = lib.mkForce (lib.concatStringsSep ":" (basePath ++ cfg.extraPath));
  } // lib.optionalAttrs cfg.workspaces.enable {
    HERMES_KANBAN_WORKSPACES_ROOT = workspacesRoot;
  };
  hermesDashboardSitecustomize = pkgs.writeTextDir "sitecustomize.py" ''
    import os
    import sys

    orig_argv = getattr(sys, "orig_argv", [])
    gateway_unit = os.environ.get("HERMES_NIX_GATEWAY_UNIT")

    if (
        gateway_unit
        and len(orig_argv) >= 5
        and orig_argv[1:4] == ["-m", "hermes_cli.main", "gateway"]
        and orig_argv[4] in {"start", "stop", "restart", "status"}
    ):
        action = orig_argv[4]
        extra_args = orig_argv[5:]
        os.execv(
            "${pkgs.systemd}/bin/systemctl",
            ["systemctl", action, gateway_unit, *extra_args],
        )
  '';
  hermesCli = pkgs.writeShellScriptBin "hermes" ''
    if [ "$#" -ge 2 ] && [ "$1" = "gateway" ]; then
      case "$2" in
        start)
          shift 2
          exec ${pkgs.systemd}/bin/systemctl start hermes-gateway.service "$@"
          ;;
        stop)
          shift 2
          exec ${pkgs.systemd}/bin/systemctl stop hermes-gateway.service "$@"
          ;;
        restart)
          shift 2
          exec ${pkgs.systemd}/bin/systemctl restart hermes-gateway.service "$@"
          ;;
        status)
          shift 2
          exec ${pkgs.systemd}/bin/systemctl status hermes-gateway.service "$@"
          ;;
      esac
    fi
    if [ "$#" -ge 1 ] && { [ "$1" = "dashboard" ] || [ "$1" = "desktop" ]; }; then
      export HERMES_NIX_GATEWAY_UNIT=hermes-gateway.service
      if [ -n "${"$"}PYTHONPATH" ]; then
        export PYTHONPATH=${lib.escapeShellArg hermesDashboardSitecustomize}:"${"$"}PYTHONPATH"
      else
        export PYTHONPATH=${lib.escapeShellArg hermesDashboardSitecustomize}
      fi
    fi
    exec ${lib.escapeShellArg cfg.binary} "$@"
  '';
  hermesDesktopScript = pkgs.writeShellScriptBin cfg.desktop.commandName ''
    export HOME=${lib.escapeShellArg homeDirectory}
    export HERMES_HOME=${lib.escapeShellArg cfg.home}
    export PATH=${lib.escapeShellArg (lib.concatStringsSep ":" (basePath ++ cfg.extraPath))}
    ${lib.optionalString cfg.workspaces.enable ''
      export HERMES_KANBAN_WORKSPACES_ROOT=${lib.escapeShellArg workspacesRoot}
    ''}
    if [ -d ${lib.escapeShellArg "${binaryRoot}/share/hermes-agent/web_dist"} ] && [ ! -d ${lib.escapeShellArg "${binaryRoot}/apps/desktop"} ]; then
      exec ${hermesCli}/bin/hermes dashboard "$@"
    fi
    exec ${hermesCli}/bin/hermes desktop "$@"
  '';
  hermesDesktopItem = pkgs.makeDesktopItem {
    name = "hermes";
    desktopName = "Hermes";
    exec = "${cfg.desktop.commandName} %U";
    icon = "hermes";
    comment = "The open source AI agent";
    categories = [ "Development" "Utility" ];
    terminal = false;
    startupWMClass = "Hermes";
  };
  hermesDesktopPackage = pkgs.symlinkJoin {
    name = "hermes-desktop-launcher";
    paths = [
      hermesDesktopScript
    ] ++ lib.optional cfg.desktop.installDesktopFile hermesDesktopItem;
  };
  rootConfigFile = yaml.generate "hermes-config.yaml" cfg.settings;
  enabledProfiles = lib.filterAttrs (_name: profile: profile.enable) cfg.profiles;
  installFile = source: target: ''
    ${pkgs.coreutils}/bin/install -D -m 0600 ${source} ${lib.escapeShellArg target}
    ${pkgs.coreutils}/bin/chown ${lib.escapeShellArg cfg.user}:users ${lib.escapeShellArg target}
  '';
  installProfile = name: profile:
    let
      profileDir = "${cfg.home}/profiles/${name}";
      profileYaml = yaml.generate "hermes-profile-${name}.yaml" {
        description = profile.description;
        description_auto = profile.descriptionAuto;
      };
      profileConfig = yaml.generate "hermes-profile-${name}-config.yaml" profile.settings;
      soulFile = pkgs.writeText "hermes-profile-${name}-SOUL.md" profile.soul;
    in
    ''
      ${pkgs.coreutils}/bin/install -d -m 0700 -o ${lib.escapeShellArg cfg.user} -g users ${lib.escapeShellArg profileDir}
      ${lib.optionalString (profile.description != null) (installFile profileYaml "${profileDir}/profile.yaml")}
      ${lib.optionalString (profile.settings != { }) (installFile profileConfig "${profileDir}/config.yaml")}
      ${lib.optionalString (profile.soul != null) (installFile soulFile "${profileDir}/SOUL.md")}
    '';
  managedConfigScript =
    lib.optionalString (cfg.settings != { }) (installFile rootConfigFile "${cfg.home}/config.yaml")
    + lib.concatStringsSep "\n" (lib.mapAttrsToList installProfile enabledProfiles);
in
{
  options.homelab.services.hermes = {
    enable = lib.mkEnableOption "Hermes Agent integration";

    user = lib.mkOption {
      type = lib.types.str;
      default = defaultUser;
      description = "User account that runs Hermes services.";
    };

    home = lib.mkOption {
      type = lib.types.str;
      default = defaultHome;
      description = "Hermes state directory exposed as HERMES_HOME.";
    };

    binary = lib.mkOption {
      type = lib.types.str;
      default = defaultBinary;
      description = ''
        Absolute path to the hermes executable. This may point to a Nix package
        or to a user-managed install such as /home/mfo/.local/bin/hermes.
      '';
    };

    extraPath = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [ ];
      description = "Additional PATH entries appended to the Hermes service environment.";
    };

    extraEnvironment = lib.mkOption {
      type = lib.types.attrsOf lib.types.str;
      default = { };
      description = "Extra non-secret environment variables for Hermes services.";
    };

    settings = lib.mkOption {
      type = yaml.type;
      default = { };
      description = ''
        Non-secret Hermes root config written to HERMES_HOME/config.yaml.
        Runtime credentials and session stores must stay outside this attrset.
      '';
    };

    profiles = lib.mkOption {
      type = lib.types.attrsOf (lib.types.submodule {
        options = {
          enable = lib.mkOption {
            type = lib.types.bool;
            default = true;
            description = "Whether to materialize this Hermes profile.";
          };

          description = lib.mkOption {
            type = lib.types.nullOr lib.types.str;
            default = null;
            description = "Profile description written to profile.yaml.";
          };

          descriptionAuto = lib.mkOption {
            type = lib.types.bool;
            default = false;
            description = "Value for description_auto in profile.yaml.";
          };

          soul = lib.mkOption {
            type = lib.types.nullOr lib.types.lines;
            default = null;
            description = "Profile SOUL.md content.";
          };

          settings = lib.mkOption {
            type = yaml.type;
            default = { };
            description = "Non-secret profile config written to config.yaml.";
          };
        };
      });
      default = { };
      description = "Hermes profiles managed declaratively under HERMES_HOME/profiles.";
    };

    gateway.enable = lib.mkEnableOption "Hermes Gateway systemd service";

    workspaces = {
      enable = lib.mkEnableOption "explicit Hermes Kanban workspaces root";

      root = lib.mkOption {
        type = lib.types.nullOr lib.types.str;
        default = null;
        description = ''
          Directory exposed as HERMES_KANBAN_WORKSPACES_ROOT for dispatcher and
          desktop-launched Hermes processes. Defaults to
          <HERMES_HOME>/kanban/workspaces.
        '';
      };
    };

    desktop = {
      enable = lib.mkEnableOption "Hermes Desktop launcher";

      commandName = lib.mkOption {
        type = lib.types.str;
        default = "hermes-desktop";
        description = "Command installed in the system profile to start Hermes Desktop.";
      };

      installDesktopFile = lib.mkOption {
        type = lib.types.bool;
        default = true;
        description = "Install a desktop entry for graphical launchers.";
      };
    };

    kanban.dispatchInGateway = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = ''
        Whether this gateway owns the embedded Kanban dispatcher. Keep this true
        for exactly one Hermes gateway that touches a given kanban.db.
      '';
    };
  };

  config = lib.mkIf cfg.enable {
    assertions = [
      {
        assertion = lib.hasPrefix "/" cfg.home;
        message = "homelab.services.hermes.home must be an absolute path.";
      }
      {
        assertion = lib.hasPrefix "/" cfg.binary;
        message = "homelab.services.hermes.binary must be an absolute path.";
      }
      {
        assertion = !cfg.workspaces.enable || lib.hasPrefix "/" workspacesRoot;
        message = "homelab.services.hermes.workspaces.root must be an absolute path.";
      }
    ];

    systemd.services.hermes-gateway = lib.mkIf cfg.gateway.enable {
      description = "Hermes Agent Gateway";
      after = [ "network-online.target" ];
      wants = [ "network-online.target" ];
      wantedBy = [ "multi-user.target" ];
      unitConfig.Conflicts = "hermes-kanban-dispatcher.service";
      environment = serviceEnvironment;
      preStart = ''
        ${pkgs.coreutils}/bin/install -d -m 0700 "$HERMES_HOME"
        ${lib.optionalString cfg.workspaces.enable ''
          ${pkgs.coreutils}/bin/install -d -m 0700 "$HERMES_HOME/kanban"
          ${pkgs.coreutils}/bin/install -d -m 0700 "$HERMES_KANBAN_WORKSPACES_ROOT"
        ''}
        if [ ! -x "${cfg.binary}" ]; then
          echo "Hermes binary is not executable: ${cfg.binary}" >&2
          echo "Set homelab.services.hermes.binary to a valid hermes executable." >&2
          exit 1
        fi
      '';
      serviceConfig = {
        Type = "simple";
        User = cfg.user;
        WorkingDirectory = homeDirectory;
        ExecStart = "${cfg.binary} gateway run --replace";
        Restart = "on-failure";
        RestartSec = 5;
        StandardOutput = "journal";
        StandardError = "journal";
      };
    };

    systemd.tmpfiles.rules = lib.optionals cfg.workspaces.enable [
      "d ${cfg.home} 0700 ${cfg.user} users - -"
      "d ${workspacesRoot} 0700 ${cfg.user} users - -"
    ];

    system.activationScripts.hermes-agent-config = lib.mkIf (managedConfigScript != "") {
      text = ''
        ${pkgs.coreutils}/bin/install -d -m 0700 -o ${lib.escapeShellArg cfg.user} -g users ${lib.escapeShellArg cfg.home}
        ${lib.optionalString cfg.workspaces.enable ''
          ${pkgs.coreutils}/bin/install -d -m 0700 -o ${lib.escapeShellArg cfg.user} -g users ${lib.escapeShellArg "${cfg.home}/kanban"}
          ${pkgs.coreutils}/bin/install -d -m 0700 -o ${lib.escapeShellArg cfg.user} -g users ${lib.escapeShellArg workspacesRoot}
        ''}
        ${managedConfigScript}
      '';
    };

    environment.systemPackages = [ hermesCli ]
      ++ lib.optional cfg.desktop.enable hermesDesktopPackage;
  };
}
