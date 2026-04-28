{ pkgs, ... }:
{
  home.packages = with pkgs; [
    foot
    rofi-wayland
    waybar
    swaybg
    mako
    wl-clipboard
    cliphist
    wlsunset
    grim
    slurp
    swaylock
    swayidle
    polkit_gnome
  ];

  home.file = {
    ".config/mango/config.conf".text = ''
      # MangoWM configuration
      theme=null
      
      # Window effects
      blur=1
      blur_optimized=1
      shadows=1
      border_radius=6
      
      # Appearance
      gaps=8
      gappih=5
      borderpx=4
      focuscolor=0xc9b890ff
      rootcolor=0x1d1b20ff
      bordercolor=0x444444ff
      
      # Animations
      animations=1
      animation_type_open=slide
      animation_duration_open=400
      animation_type_close=fade
      animation_duration_close=200
      
      # Input devices
      mouse_natural_scrolling=0
      tap_to_click=1
      mouse_acceleration_factor=5
      repeat_rate=25
      
      # Keybindings
      bind=SUPER,Return,spawn,${pkgs.foot}/bin/foot
      bind=SUPER,Space,spawn,${pkgs.rofi-wayland}/bin/rofi -show drun
      bind=SUPER,w,spawn,${pkgs.chromium}/bin/chromium
      bind=SUPER,e,spawn,${pkgs.thunar}/bin/thunar
      bind=SUPER,v,view,1
      bind=SUPER,q,killclient,
      bind=SUPER,m,quit,
      bind=SUPER,f,togglefullscreen,
      bind=SUPER,b,togglefloating,
      
      # Layout rules
      tagrule=id:1,layout_name:dwindle
      tagrule=id:2,layout_name:tall,
      tagrule=id:3,layout_name:scroller,
      
      # Focus
      focus_follow_active=1
      
      # Border
      border_side_width=4
      border_color_hidden=0x80736fff
      border_color_active=0xc9b890ff
      border_color_inactive=0x444444ff
      
      # Gap
      gap_horizontal=8
      gap_vertical=8
      
      # Window title
      font_title=""
      font_content=""
      border_top_width=0
      border_right_width=0
      border_bottom_width=0
      border_left_width=0
      
      # Tags
      tag_default_active_color=0xc9bfa1ff
      tag_default_color=0x444444ff
      tag_01_color=0xff7675ff
      tag_02_color=0x74c7c0ff
      tag_03_color=0x98c379ff
      tag_04_color=0x85c1e9ff
      tag_05_color=0xffd191ff
      tag_06_color=0xfe64afbff
      tag_07_color=0x99c792ffff
      tag_08_color=0x8838ddff
      tag_09_color=0xe67e22ff
      tag_10_color=0x1a85ff
      
      # Colors
      colors_active_fg=0xFFFFFFFF
      colors_inactive_fg=0xFFFFFFAA
      
      # Layer rules
      layerrule=animation_type_open:zoom,layer_name:rofi
      layerrule=animation_type_close:zoom,invert_rule=1,layer_name:rofi
      
      # Misc
      default_mfact=0.55
      window_gap=8
      gappih=5
      borderpx=4
    '';
  };

  home.file = {
    ".config/mango/autostart.sh".text = type = "text";
    ".config/mango/autostart.sh".text = ''
      #!/usr/bin/env bash
      # MangoWM autostart script
      
      # Status bar
      if command -v ${pkgs.waybar}/bin/waybar >/dev/null 2>&1; then
        ${pkgs.waybar}/bin/waybar &
      fi
      
      # Wallpaper
      if command -v ${pkgs.swaybg}/bin/swaybg >/dev/null 2>&1; then
        ${pkgs.swaybg}/bin/swaybg -i ${builtins.toPath "${config.home.username}/Pictures/wallpaper.jpg"}/wallpaper.jpg -m fill &
      elif command -v ${pkgs.swww}/bin/swww >/dev/null 2>&1; then
        ${pkgs.swww}/bin/swww img ${builtins.toPath "${config.home.username}/Pictures/wallpaper.jpg"}/wallpaper.jpg --mode fill &
      fi
      
      # Notifications
      if command -v ${pkgs.mako}/bin/mako >/dev/null 2>&1; then
        ${pkgs.mako}/bin/mako &
      elif command -v ${pkgs.swaync}/bin/swaync >/dev/null 2>&1; then
        ${pkgs.swaync}/bin/swaync &
      fi
      
      # Clipboard
      if command -v ${pkgs.wl-clipboard}/bin/wl-paste >/dev/null 2>&1 && command -v ${pkgs.cliphist}/bin/cliphist >/dev/null 2>&1; then
        ${pkgs.wl-clipboard}/bin/wl-paste --watch ${pkgs.cliphist}/bin/cliphist store &
      fi
      
      # Screen lock
      if command -v ${pkgs.swaylock}/bin/swaylock >/dev/null 2>&1; then
        ${pkgs.swaylock}/bin/swaylock &
      fi
      
      # Idle
      if command -v ${pkgs.swayidle}/bin/swayidle >/dev/null 2>&1; then
        ${pkgs.swayidle}/bin/swayidle '\
          ${pkgs.swaylock}/bin/swaylock \
          exec -- '${pkgs.swayidle}/bin/swayidle timeout 300 ${pkgs.systemd}/lib/systemd/systemd-inhibit /bin/true -i 300 ${pkgs.swayidle}/bin/swayidle timeout 600 ${pkgs.systemd}/lib/systemd/systemd-inhibit /bin/true -i 600 ${pkgs.swaylock}/bin/swaylock' \
        &
      fi
      
      # Night light
      if command -v ${pkgs.wlsunset}/bin/wlsunset >/dev/null 2>&1; then
        ${pkgs.wlsunset}/bin/wlsunset -l 39.9 -L 116.3 &
      fi
      
      # Auth agent
      if command -v ${pkgs.polkit_gnome}/libexec/polkit-gnome-authentication-agent-1 >/dev/null 2>&1; then
        ${pkgs.polkit_gnome}/libexec/polkit-gnome-authentication-agent-1 &
      fi
    '';
    ".config/mango/autostart.sh".source = null;
    ".config/mango/autostart.sh".executable = true;
  };
}
