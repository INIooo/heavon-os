#!/bin/bash
# ====================================================================
#  HeavenOS - cont-init script (runs before desktop starts)
#  Purges default wallpapers and enforces Lotus Wallpaper permanently
# ====================================================================

WALLPAPER="/lotus-wallpaper.png"
CONFIG_DIR="/config/.config/xfce4/xfconf/xfce-perchannel-xml"
AUTOSTART_DIR="/config/.config/autostart"
DESKTOP_DIR="/config/Desktop"

# ---- Folders creation ---------------------------------------------
mkdir -p "$CONFIG_DIR"
mkdir -p "$AUTOSTART_DIR"
mkdir -p "$DESKTOP_DIR"

# ---- Wipe any system default wallpapers & replace with Lotus ------
find /usr/share/backgrounds/ -type f ! -name "lotus.png" -exec cp "$WALLPAPER" {} \; 2>/dev/null || true
cp "$WALLPAPER" /defaults/bg.png 2>/dev/null || true

# ---- apply-wallpaper script system copy --------------------------
cp /apply-wallpaper.sh /usr/local/bin/apply-lotus-wallpaper.sh
chmod +x /usr/local/bin/apply-lotus-wallpaper.sh

# ---- XFCE Autostart entry (wallpaper enforcement) -----------------
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
#  DESKTOP SHORTCUTS
# ====================================================================

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

# ====================================================================
#  PERMANENT XFCE DESKTOP XML CONFIG
# ====================================================================
chattr -i "$CONFIG_DIR/xfce4-desktop.xml" 2>/dev/null || true
cat > "$CONFIG_DIR/xfce4-desktop.xml" << 'XMLEOF'
<?xml version="1.0" encoding="UTF-8"?>
<channel name="xfce4-desktop" version="1.0">
  <property name="backdrop" type="empty">
    <property name="screen0" type="empty">
      <property name="monitor0" type="empty">
        <property name="workspace0" type="empty">
          <property name="color-style" type="int" value="0"/>
          <property name="image-style" type="int" value="5"/>
          <property name="last-image" type="string" value="/lotus-wallpaper.png"/>
        </property>
      </property>
      <property name="monitor1" type="empty">
        <property name="workspace0" type="empty">
          <property name="color-style" type="int" value="0"/>
          <property name="image-style" type="int" value="5"/>
          <property name="last-image" type="string" value="/lotus-wallpaper.png"/>
        </property>
      </property>
      <property name="monitorVNC-0" type="empty">
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

# ---- Ownership fix -----------------------------------------------
chown -R abc:abc /config/ 2>/dev/null || true
chown abc:abc /usr/local/bin/apply-lotus-wallpaper.sh

echo "[HeavenOS] Permanent Lotus Wallpaper Config Registered!"
