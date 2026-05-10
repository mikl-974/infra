{ ... }:
{
  home.stateVersion = "24.11";
  xdg.enable = true;
  xdg.configFile."mimeapps.list".force = true;
  xdg.mimeApps = {
    enable = true;
    defaultApplications = {

      # Liens web et protocoles
      "text/html" = [ "chromium-browser.desktop" ];
      "application/xhtml+xml" = [ "chromium-browser.desktop" ];
      "x-scheme-handler/http" = [ "chromium-browser.desktop" ];
      "x-scheme-handler/https" = [ "chromium-browser.desktop" ];
      "x-scheme-handler/about" = [ "chromium-browser.desktop" ];
      "x-scheme-handler/unknown" = [ "chromium-browser.desktop" ];
      
      # Gestionnaire de fichiers
      "inode/directory" = [ "thunar.desktop" ];

      # PDF
      "application/pdf" = [ "org.pwmt.zathura.desktop" ];

      # Images
      "image/png" = [ "imv.desktop" ];
      "image/jpeg" = [ "imv.desktop" ];
      "image/gif" = [ "imv.desktop" ];
      "image/webp" = [ "imv.desktop" ];
      "image/avif" = [ "imv.desktop" ];
      "image/svg+xml" = [ "imv.desktop" ];

      # Archives
      "application/zip" = [ "org.gnome.FileRoller.desktop" ];
      "application/x-7z-compressed" = [ "org.gnome.FileRoller.desktop" ];
      "application/x-rar-compressed" = [ "org.gnome.FileRoller.desktop" ];
      "application/x-tar" = [ "org.gnome.FileRoller.desktop" ];
      "application/gzip" = [ "org.gnome.FileRoller.desktop" ];
    };
  };  
  
  programs.chromium = {
    enable = true;
    commandLineArgs = [
      "--ozone-platform-hint=auto"
      "--ozone-platform=wayland"
      # Options recommandées pour MangoWC / Wayland
      "--enable-features=WaylandWindowDecorations,WebRTCPipeWireCapturer"
      "--enable-wayland-ime"
    ];
  };

  programs.home-manager.enable = true;
}
