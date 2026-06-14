{ inputs, pkgs, ... }:
{
  imports = [ inputs.mango.hmModules.mango ];

  wayland.windowManager.mango = {
    enable = true;
    extraConfig = ''
      # Colors
      rootcolor=0x201b14ff
      bordercolor=0x444444ff
      focuscolor=0xc9b890ff
      maximizescreencolor=0x89aa61ff
      urgentcolor=0xad401fff
      scratchpadcolor=0x516c93ff
      globalcolor=0xb153a7ff
      overlaycolor=0x14a57cff

      # Borders
      borderpx=1
      no_border_when_single=0

      # Gaps
      gappih=5
      gappiv=5
      gappoh=10
      gappov=10
      smartgaps=0

      # Opacity
      focused_opacity=0.9
      unfocused_opacity=0.75

      # Overview
      hotarea_size=10
      enable_hotarea=1
      ov_tab_mode=0
      overviewgappi=5
      overviewgappo=30

      # Scratchpad
      scratchpad_width_ratio=0.8
      scratchpad_height_ratio=0.9

      # Cursor
      cursor_size=24

      # Keyboard
      xkb_rules_layout=us
      xkb_rules_variant=altgr-intl
      xkb_rules_options=lv3:ralt_switch

      # Window effects
      blur = 1
      blur_optimized = 1
      shadows = 1
      border_radius = 8
      
      # Animations
      animations = 1
      animation_type_open = slide
      animation_duration_open = 300

      # Layout options: tile, scroller, grid, deck, monocle, center_tile, 
      # vertical_tile, vertical_scroller, vertical_grid, vertical_deck, 
      # right_tile, tgmix

      tagrule=id:1,layout_name:tile
      tagrule=id:2,layout_name:scroller
      tagrule=id:3,layout_name:grid
      tagrule=id:4,layout_name:monocle
      tagrule=id:5,layout_name:deck
      
      # Cycle through available layouts
      bind=SUPER,n,switch_layout
      
      # Tags
      bind=SUPER,1,view,1,0
      bind=SUPER,2,view,2,0
      bind=SUPER,3,view,3,0
      bind=SUPER,4,view,4,0
      bind=SUPER,5,view,5,0
      bind=SUPER,6,view,6,0
      bind=SUPER,7,view,7,0
      bind=SUPER,8,view,8,0
      bind=SUPER,9,view,9,0
      bind=SUPER+SHIFT,1,tag,1,0
      bind=SUPER+SHIFT,2,tag,2,0
      bind=SUPER+SHIFT,3,tag,3,0
      bind=SUPER+SHIFT,4,tag,4,0
      bind=SUPER+SHIFT,5,tag,5,0
      bind=SUPER+SHIFT,6,tag,6,0
      bind=SUPER+SHIFT,7,tag,7,0
      bind=SUPER+SHIFT,8,tag,8,0
      bind=SUPER+SHIFT,9,tag,9,0

      # Window management
      bind=SUPER,r,reload_config
      bind=SUPER,Return,spawn,${pkgs.foot}/bin/foot
      bind=SUPER,space,spawn,noctalia-shell ipc call launcher toggle
      bind=SUPER,v,spawn,noctalia-shell ipc call launcher clipboard
      bind=SUPER+SHIFT,S,spawn,noctalia-shell ipc call plugin:screen-shot-and-record screenshot
      bind=SUPER,c,spawn,noctalia-shell ipc call controlCenter toggle
      bind=SUPER,s,spawn,noctalia-shell ipc call sessionMenu toggle
      bind=SUPER,b,spawn,chromium
      bind=SUPER,e,spawn,thunar
      bind=SUPER,q,killclient,
      #bind=SUPER,m,quit
      bind=SUPER,h,focusdir,left
      bind=SUPER,l,focusdir,right
      bind=SUPER,k,focusdir,up
      bind=SUPER,j,focusdir,down
      bind=SUPER,Left,focusdir,left
      bind=SUPER,Right,focusdir,right
      bind=SUPER,Up,focusdir,up
      bind=SUPER,Down,focusdir,down
      bind=SUPER+CTRL,Left,focusmon,left
      bind=SUPER+CTRL,Right,focusmon,right
      bind=SUPER,f,togglefullscreen,
      bind=SUPER,backslash,togglefloating,

      # Shows/hides scratchpad
      bind=SUPER,z,toggle_scratchpad

      # Move focused window to the adjacent tag with horizontal arrows
      bind=SUPER+SHIFT,Left,tagtoleft,0
      bind=SUPER+SHIFT,Right,tagtoright,0
      bind=SUPER+CTRL+SHIFT,Left,tagmon,left,0
      bind=SUPER+CTRL+SHIFT,Right,tagmon,right,0

      # Swap focused window with window in specified direction
      bind=SUPER+SHIFT,Up,exchange_client,up
      bind=SUPER+SHIFT,Down,exchange_client,down

      # Move focused window to master position
      bind=SUPER,m,zoom,

      # Intelligently resize window avoiding collisions
      bind=SUPER+ALT,Left,smartresizewin,left
      bind=SUPER+ALT,Right,smartresizewin,right
      
      # Toggle overview mode
      bind=SUPER,Tab,toggleoverview,

      mousebind=SUPER,btn_left,moveresize,curmove
      mousebind=SUPER,btn_right,moveresize,curresize

      tagrule=id:1,layout_name:tile
      tagrule=id:2,layout_name:tile
      tagrule=id:3,layout_name:tile

      # Volume up
      bind=NONE,XF86AudioRaiseVolume,spawn,wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%+

      # Volume down
      bind=NONE,XF86AudioLowerVolume,spawn,wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-

      # Volume - Mute
      bind=NONE,XF86AudioMute,spawn,wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle

      bind=NONE,XF86Calculator,spawn,gnome-calculator

      # Luminosité (nécessite brightnessctl ou swayosd)
      bind=NONE,XF86MonBrightnessUp,spawn,swayosd-client --brightness raise
      bind=NONE,XF86MonBrightnessDown,spawn,swayosd-client --brightness lower

      # Rétroéclairage du clavier (spécifique au MX Keys)
      bind=NONE,XF86KbdBrightnessUp,spawn,brightnessctl --device='logitech_keyboard_backlight' set +10%
      bind=NONE,XF86KbdBrightnessDown,spawn,brightnessctl --device='logitech_keyboard_backlight' set 10%-
    '';

    autostart_sh = ''
      noctalia-shell &
      ${pkgs.mako}/bin/mako &
      ${pkgs.wl-clipboard}/bin/wl-paste --type text --watch ${pkgs.cliphist}/bin/cliphist store &
      ${pkgs.wl-clipboard}/bin/wl-paste --type image --watch ${pkgs.cliphist}/bin/cliphist store &
      ${pkgs.polkit_gnome}/libexec/polkit-gnome-authentication-agent-1 &
    '';

    systemd = {
      enable = true;
      xdgAutostart = true;
    };
  };

  home.packages = with pkgs; [

    # Core tools
    # rofi-wayland       # Application launcher
    foot               # Terminal
    # waybar             # Status bar

    # Desktop portals
    xdg-desktop-portal
    xdg-desktop-portal-wlr
    xdg-desktop-portal-gtk

    # Utilities
    wl-clipboard       # Clipboard
    cliphist          # Clipboard history
    grim              # Screenshots
    slurp             # Area selection
    swaylock          # Screen locker
    swayidle          # Idle manager
    wlsunset          # Night light

    # Media
    swaybg            # Wallpaper
    imv               # Image viewer
    mpv               # Video player

    # Notifications
    mako              # Or swaync
    libnotify         # notify-send
  ];
}
