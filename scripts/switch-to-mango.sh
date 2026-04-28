#!/usr/bin/env bash
# MangoWM configuration for NixOS
# This script configures Mango to replace Hyprland

set -euo pipefail

MANGO_CONFIG_DIR="$HOME/.config/mango"
MANGO_CONFIG="$MANGO_CONFIG_DIR/config.conf"
MANGO_AUTOSTART="$MANGO_CONFIG_DIR/autostart.sh"

mkdir -p "$MANGO_CONFIG_DIR"

cat > "$MANGO_CONFIG" <<'EOF'
# MangoWM configuration
theme={null}

# Window effects
blur=0
shadows=0
border_radius=4

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

# Keybindings
bind=SUPER,Return,spawn,${HOME}/.nix-profile/bin/foot
bind=SUPER,space,spawn,${HOME}/.config/wofi/config
bind=SUPER,e,spawn,${HOME}/.local/share/steam/steam.sh --%U
bind=SUPER,q,killclient,
bind=SUPER,m,quit,
bind=SUPER,f,togglefullscreen,

# Layout rules
tagrule=id:1,layout_name:dwindle
tagrule=id:2,layout_name:tall,
EOF

cat > "$MANGO_AUTOSTART" <<'EOF'
#!/usr/bin/env bash
# MangoWM autostart script
set -euo pipefail

# Waybar - status bar
if command -v /run/current-system/sw/bin/waybar &>/dev/null; then
  /run/current-system/sw/bin/waybar &
fi

# Notifications
if command -v /run/current-system/sw/bin/mako &>/dev/null; then
  /run/current-system/sw/bin/mako &
fi

# Clipboard manager
if command -v /run/current-system/sw/bin/wl-paste &>/dev/null; then
  /run/current-system/sw/bin/wl-paste --watch /run/current-system/sw/bin/cliphist store &
fi

# Screen lock
if command -v /run/current-system/sw/bin/swaylock &>/dev/null; then
  /run/current-system/sw/bin/swaylock &
fi

# Idle
if command -v /run/current-system/sw/bin/swayidle &>/dev/null; then
  /run/current-system/sw/bin/swayidle 'sleep 300 /run/current-system/sw/bin/swaylock /run/current-system/sw/bin/systemctl --user inhibit idle /usr/bin/idle true 300 timeout 600 /run/current-system/sw/bin/systemctl --user inhibit idle /usr/bin/idle true 600 /run/current-system/sw/bin/swaylock' &
fi
EOF

chmod +x "$MANGO_AUTOSTART"
echo "MangoWM configuration installed to $MANGO_CONFIG"

EOF
chmod +x ~/.config/mango/mango-setup.bash
. ~/.config/mango/mango-setup.bash
