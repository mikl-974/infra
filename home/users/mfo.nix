{ lib, pkgs, ... }:
let
  opencodeConfig = lib.recursiveUpdate
    (builtins.fromJSON (builtins.readFile ../../dotfiles/opencode/opencode.json))
    {
      mcp.playwright.command = [ "${pkgs.playwright-mcp}/bin/playwright-mcp" ];
    };
in {
  imports = [ ./base.nix ];

  home.username = "mfo";
  home.homeDirectory = "/home/mfo";
  home.sessionPath = [
    "$HOME/.local/bin"
  ];

  programs.noctalia-shell.settings = lib.mkForce ../../dotfiles/noctalia/mfo/settings.json;

  home.file = {
    ".config/noctalia/plugins.json".source = ../../dotfiles/noctalia/mfo/plugins.json;
    ".config/noctalia/plugins/tailscale/TailscaleIcon.qml".source = ../../dotfiles/noctalia/local-plugins/tailscale/TailscaleIcon.qml;
    ".config/noctalia/plugins/cloudflare-warp/CloudflareIcon.qml".source = ../../dotfiles/noctalia/local-plugins/cloudflare-warp/CloudflareIcon.qml;
    ".config/opencode/opencode.json".source = (pkgs.formats.json { }).generate "opencode.json" opencodeConfig;
    ".config/opencode/skills/vibe-notion/SKILL.md".source = ../../dotfiles/opencode/skills/vibe-notion/SKILL.md;
    ".local/share/opencode/opencode-launcher.sh".source = ../../dotfiles/opencode/opencode-launcher.sh;
    ".local/share/applications/OpenCode.desktop".source = ../../dotfiles/opencode/OpenCode.desktop;
  };
}
