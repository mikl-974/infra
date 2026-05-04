{ pkgs, ... }:
{
  environment.systemPackages =
    (import ../../catalog/apps/opencode-desktop.nix { inherit pkgs; })
    ++ [
      (pkgs.writeShellScriptBin "opencode" ''
        export OC_FORCE_X11="''${OC_FORCE_X11:-1}"
        export GDK_BACKEND="''${GDK_BACKEND:-x11}"
        export XDG_SESSION_TYPE="''${XDG_SESSION_TYPE:-x11}"
        export WEBKIT_DISABLE_COMPOSITING_MODE="''${WEBKIT_DISABLE_COMPOSITING_MODE:-1}"
        export WEBKIT_DISABLE_DMABUF_RENDERER="''${WEBKIT_DISABLE_DMABUF_RENDERER:-1}"
        export GSK_RENDERER="''${GSK_RENDERER:-cairo}"
        export LD_LIBRARY_PATH="${pkgs.stdenv.cc.cc.lib}/lib''${LD_LIBRARY_PATH:+:''${LD_LIBRARY_PATH}}"
        unset WAYLAND_DISPLAY
        exec ${pkgs.opencode-desktop}/bin/OpenCode "$@"
      '')
    ];
}
