# NordVPN via wgnord (WireGuard / NordLynx) shared infra module.
#
# Why wgnord and not the official daemon:
# - The proprietary `nordvpn` daemon is not packaged in the nixpkgs pin used by
#   this repo, whereas `wgnord` is. `wgnord` is a small POSIX-shell client that
#   talks to NordVPN's API and brings up a standard `wg-quick` tunnel against the
#   recommended NordLynx server, so it needs no out-of-tree packaging.
#
# Runtime model (manual, by design):
# - `wgnord` keeps its state in /var/lib/wgnord (auth token, credentials,
#   template). The nixpkgs package does NOT ship `template.conf`, which `wgnord c`
#   requires, so this module provisions it (copy-once, local edits survive).
# - One-time login, then connect/disconnect on demand:
#     sudo wgnord login -t <ACCESS_TOKEN>   # token from the NordVPN dashboard
#     sudo wgnord c Switzerland             # connect to a country
#     sudo wgnord d                          # disconnect
#
# Namespace matches the rest of the repo (`infra.networking.*`).
{ lib, pkgs, config, ... }:
let
  cfg = config.infra.networking.nordvpn;

  templateFile = pkgs.writeText "wgnord-template.conf" cfg.template;
in
{
  options.infra.networking.nordvpn = {
    enable = lib.mkEnableOption "NordVPN via wgnord (WireGuard/NordLynx) client";

    dns = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [ "103.86.96.100" "103.86.99.100" ];
      description = "DNS servers written into the wgnord WireGuard template (NordVPN's own resolvers by default).";
    };

    template = lib.mkOption {
      type = lib.types.lines;
      default = ''
        [Interface]
        PrivateKey = PRIVKEY
        Address = 10.5.0.2/32
        MTU = 1350
        DNS = ${lib.concatStringsSep " " cfg.dns}

        [Peer]
        PublicKey = SERVER_PUBKEY
        AllowedIPs = 0.0.0.0/0, ::/0
        Endpoint = SERVER_IP:51820
        PersistentKeepalive = 25
      '';
      description = ''
        wg-quick template used by wgnord. The PRIVKEY / SERVER_PUBKEY / SERVER_IP
        placeholders are substituted by `wgnord c` at connect time.
      '';
    };
  };

  config = lib.mkIf cfg.enable {
    environment.systemPackages = [ pkgs.wgnord pkgs.wireguard-tools ];

    # Full-tunnel WireGuard (AllowedIPs 0.0.0.0/0) trips strict reverse-path
    # filtering; relax it the same way NixOS's own wireguard module does.
    networking.firewall.checkReversePath = lib.mkDefault "loose";

    # Provision wgnord's state dir and the template.conf it needs to connect.
    # `C` copies once when the file is absent, so manual tweaks to the template
    # on the host are preserved across rebuilds.
    systemd.tmpfiles.settings."10-wgnord" = {
      "/var/lib/wgnord".d = {
        mode = "0700";
        user = "root";
        group = "root";
      };
      "/var/lib/wgnord/template.conf".C = {
        mode = "0600";
        user = "root";
        group = "root";
        argument = "${templateFile}";
      };
    };
  };
}
