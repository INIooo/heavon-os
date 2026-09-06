#!/bin/bash
# ====================================================================
#  HeavenOS - cont-init script (runs before desktop starts)
#  Sets wallpaper + creates desktop icons
# ====================================================================

WALLPAPER="/lotus-wallpaper.png"
CONFIG_DIR="/config/.config/xfce4/xfconf/xfce-perchannel-xml"
AUTOSTART_DIR="/config/.config/autostart"
DESKTOP_DIR="/config/Desktop"
PANEL_CONFIG="$CONFIG_DIR/xfce4-panel.xml"

# ---- Folders banana -----------------------------------------------
mkdir -p "$CONFIG_DIR"
mkdir -p "$AUTOSTART_DIR"
mkdir -p "$DESKTOP_DIR"

# ====================================================================
#  TOP-LEFT SEARCH BAR (Whisker Menu) - Panel Config
# ====================================================================
# Sirf pehli baar create karo (user ne customize kia ho toh mat chhuo)
if [ ! -f "$PANEL_CONFIG" ]; then
cat > "$PANEL_CONFIG" << 'PANELEOF'
<?xml version="1.0" encoding="UTF-8"?>
<channel name="xfce4-panel" version="1.0">
  <property name="configver" type="int" value="2"/>
  <property name="panels" type="array">
    <value type="int" value="1"/>
  </property>
  <property name="panel-1" type="empty">
    <property name="position" type="string" value="p=6;x=0;y=0"/>
    <property name="length" type="uint" value="100"/>
    <property name="position-locked" type="bool" value="true"/>
    <property name="size" type="uint" value="30"/>
    <property name="plugin-ids" type="array">
      <value type="int" value="1"/>
      <value type="int" value="2"/>
      <value type="int" value="3"/>
      <value type="int" value="4"/>
      <value type="int" value="5"/>
    </property>
  </property>
  <property name="plugins" type="empty">
    <property name="plugin-1" type="string" value="whiskermenu"/>
    <property name="plugin-2" type="string" value="separator">
      <property name="expand" type="bool" value="true"/>
      <property name="style" type="uint" value="0"/>
    </property>
    <property name="plugin-3" type="string" value="systray"/>
    <property name="plugin-4" type="string" value="clock"/>
    <property name="plugin-5" type="string" value="showdesktop"/>
  </property>
</channel>
PANELEOF
fi

# ---- apply-wallpaper script system mein copy karo -----------------
cp /apply-wallpaper.sh /usr/local/bin/apply-lotus-wallpaper.sh
chmod +x /usr/local/bin/apply-lotus-wallpaper.sh

# ---- XFCE Autostart entry (wallpaper) ----------------------------
cat > "$AUTOSTART_DIR/heaven-wallpaper.desktop" << 'EOF'
[Desktop Entry]
Type=Application
Name=HeavenOS Wallpaper
Exec=bash /usr/local/bin/apply-lotus-wallpaper.sh
Hidden=false
NoDisplay=false
X-GNOME-Autostart-enabled=true
EOF

# ====================================================================
#  DESKTOP ICONS - Click karo, app khul jaye!
# ====================================================================

# ---- Blender Desktop Icon -----------------------------------------
cat > "$DESKTOP_DIR/Blender.desktop" << 'EOF'
[Desktop Entry]
Version=1.0
Type=Application
Name=Blender
Comment=3D Creation Suite - Latest Version
Exec=blender
Icon=blender
Terminal=false
Categories=Graphics;3DGraphics;
StartupNotify=true
EOF
chmod +x "$DESKTOP_DIR/Blender.desktop"

# ---- File Manager Desktop Icon ------------------------------------
cat > "$DESKTOP_DIR/Files.desktop" << 'EOF'
[Desktop Entry]
Version=1.0
Type=Application
Name=File Manager
Comment=Browse your files
Exec=thunar
Icon=system-file-manager
Terminal=false
Categories=Utility;FileManager;
StartupNotify=true
EOF
chmod +x "$DESKTOP_DIR/Files.desktop"

# ---- Terminal Desktop Icon ----------------------------------------
cat > "$DESKTOP_DIR/Terminal.desktop" << 'EOF'
[Desktop Entry]
Version=1.0
Type=Application
Name=Terminal
Comment=Open Terminal
Exec=xfce4-terminal
Icon=utilities-terminal
Terminal=false
Categories=System;TerminalEmulator;
StartupNotify=true
EOF
chmod +x "$DESKTOP_DIR/Terminal.desktop"

# ---- XML wallpaper config (fallback) -----------------------------
chattr -i "$CONFIG_DIR/xfce4-desktop.xml" 2>/dev/null || true
cat > "$CONFIG_DIR/xfce4-desktop.xml" << 'XMLEOF'
<?xml version="1.0" encoding="UTF-8"?>
<channel name="xfce4-desktop" version="1.0">
  <property name="backdrop" type="empty">
    <property name="screen0" type="empty">
      <property name="monitorVNC-0" type="empty">
        <property name="workspace0" type="empty">
          <property name="color-style" type="int" value="0"/>
          <property name="image-style" type="int" value="5"/>
          <property name="last-image" type="string" value="/lotus-wallpaper.png"/>
        </property>
      </property>
      <property name="monitor0" type="empty">
        <property name="workspace0" type="empty">
          <property name="color-style" type="int" value="0"/>
          <property name="image-style" type="int" value="5"/>
          <property name="last-image" type="string" value="/lotus-wallpaper.png"/>
        </property>
      </property>
    </property>
  </property>
</channel>
XMLEOF

# ====================================================================
#  APPS INSTALL (Background mein - OS instantly ready!)
# ====================================================================
# Blender pehle run pe background mein install hoga
# User OS use kar sakta hai install hote waqt!
if ! command -v blender &>/dev/null; then
    echo "[HeavenOS] Blender install ho raha hai background mein..."
    (pacman -Sy --noconfirm blender >> /var/log/heaven-install.log 2>&1 && \
     echo "[HeavenOS] Blender install complete!") &
fi

# ---- Ownership fix -----------------------------------------------
chown -R abc:abc /config/ 2>/dev/null || true
chown abc:abc /usr/local/bin/apply-lotus-wallpaper.sh

echo "[HeavenOS] Desktop icons + wallpaper autostart registered!"
echo "[HeavenOS] Blender background mein install ho raha hai (agar pehli baar hai)"
