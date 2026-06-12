{ lib, pkgs, ... }:
let
  opencodeConfig = lib.recursiveUpdate
    (builtins.fromJSON (builtins.readFile ../../dotfiles/opencode/opencode.json))
    {
      mcp.playwright.command = [ "${pkgs.playwright-mcp}/bin/mcp-server-playwright" ];
      mcp.chrome-devtools.command = [ "${pkgs.nodejs_22}/bin/npx" "-y" "chrome-devtools-mcp@latest" ];
    };
  opencodeLauncher = pkgs.writeShellScript "opencode-launcher.sh" ''
    export OC_FORCE_X11="''${OC_FORCE_X11:-1}"
    export GDK_BACKEND="''${GDK_BACKEND:-x11}"
    export XDG_SESSION_TYPE="''${XDG_SESSION_TYPE:-x11}"
    export WEBKIT_DISABLE_COMPOSITING_MODE="''${WEBKIT_DISABLE_COMPOSITING_MODE:-1}"
    export WEBKIT_DISABLE_DMABUF_RENDERER="''${WEBKIT_DISABLE_DMABUF_RENDERER:-1}"
    export GSK_RENDERER="''${GSK_RENDERER:-cairo}"
    export PLAYWRIGHT_BROWSERS_PATH="${pkgs.playwright-driver.browsers}"
    export PLAYWRIGHT_SKIP_BROWSER_DOWNLOAD="1"

    for candidate in /run/current-system/sw/lib /nix/store/*gcc-*-lib/lib; do
    	if [ -e "$candidate/libstdc++.so.6" ]; then
			export LD_LIBRARY_PATH="$candidate''${LD_LIBRARY_PATH:+:''${LD_LIBRARY_PATH}}"
    		break
    	fi
    done

    unset WAYLAND_DISPLAY

    exec /run/current-system/sw/bin/opencode "$@"
  '';
in {
  imports = [ ./base.nix ];

  home.username = "mfo";
  home.homeDirectory = "/home/mfo";
  home.packages = [ pkgs.nssTools ];
  home.sessionPath = [
    "$HOME/.local/bin"
    "$HOME/.dotnet/tools"
  ];
  home.sessionVariables = {
    SSL_CERT_DIR = "$HOME/.aspnet/dev-certs/trust:${pkgs.cacert}/etc/ssl/certs";
  };

  programs.noctalia-shell.settings = lib.mkForce ../../dotfiles/noctalia/mfo/settings.json;

  home.file = {
    ".config/noctalia/plugins.json".source = ../../dotfiles/noctalia/mfo/plugins.json;
    ".config/noctalia/plugins/tailscale/TailscaleIcon.qml".source = ../../dotfiles/noctalia/local-plugins/tailscale/TailscaleIcon.qml;
    ".config/noctalia/plugins/cloudflare-warp/CloudflareIcon.qml".source = ../../dotfiles/noctalia/local-plugins/cloudflare-warp/CloudflareIcon.qml;
    ".config/opencode/opencode.json".source = (pkgs.formats.json { }).generate "opencode.json" opencodeConfig;
    ".config/opencode/agents" = {
      source = ../../dotfiles/opencode/agents;
      force = true;
    };
    ".codex/qwen3-coder.config.toml".source = ../../dotfiles/codex/qwen3-coder.config.toml;
    ".codex/model-catalogs/qwen3-coder-next.json".source = ../../dotfiles/codex/model-catalogs/qwen3-coder-next.json;
    ".local/share/opencode/opencode-launcher.sh".source = opencodeLauncher;
    ".local/share/applications/OpenCode.desktop".source = ../../dotfiles/opencode/OpenCode.desktop;
  };

  systemd.user.services.dotnet-dev-certs-trust = {
    Unit = {
      Description = "Trust the ASP.NET Core development certificate for this user";
      After = [ "graphical-session-pre.target" ];
      PartOf = [ "graphical-session.target" ];
    };

    Service = {
      Type = "oneshot";
      Environment = [
        "SSL_CERT_DIR=%h/.aspnet/dev-certs/trust:${pkgs.cacert}/etc/ssl/certs"
        "PATH=${pkgs.nssTools}/bin:/run/current-system/sw/bin"
      ];
      ExecStart = "${pkgs.dotnetCorePackages.sdk_10_0-bin}/bin/dotnet dev-certs https --trust --quiet";
    };

    Install.WantedBy = [ "graphical-session.target" ];
  };
}
