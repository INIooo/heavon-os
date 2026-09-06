#!/bin/bash
# ====================================================================
#  HeavenOS - cont-init script (runs before desktop starts)
# ====================================================================

WALLPAPER="/lotus-wallpaper.png"
CONFIG_DIR="/config/.config/xfce4/xfconf/xfce-perchannel-xml"
AUTOSTART_DIR="/config/.config/autostart"

# ---- Folders banana -----------------------------------------------
mkdir -p "$CONFIG_DIR"
mkdir -p "$AUTOSTART_DIR"

# ---- apply-wallpaper script system mein copy karo -----------------
cp /apply-wallpaper.sh /usr/local/bin/apply-lotus-wallpaper.sh
chmod +x /usr/local/bin/apply-lotus-wallpaper.sh

# ---- XFCE Autostart entry create karo ----------------------------
# Ye desktop load hone ke baad automatically chalega
cat > "$AUTOSTART_DIR/heaven-wallpaper.desktop" << 'EOF'
[Desktop Entry]
Type=Application
Name=HeavenOS Wallpaper
Exec=bash /usr/local/bin/apply-lotus-wallpaper.sh
Hidden=false
NoDisplay=false
X-GNOME-Autostart-enabled=true
EOF

# ---- XML config bhi set karo (fallback) --------------------------
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

# ---- Ownership fix -----------------------------------------------
chown -R abc:abc /config/.config/ 2>/dev/null || true
chown abc:abc /usr/local/bin/apply-lotus-wallpaper.sh

echo "[HeavenOS] Autostart wallpaper script registered!"
