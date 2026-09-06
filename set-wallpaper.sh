#!/bin/bash
# ====================================================================
#  HeavenOS - Force Lotus Wallpaper on EVERY BOOT
#  Runs automatically via /custom-cont-init.d/
# ====================================================================

WALLPAPER="/lotus-wallpaper.png"
CONFIG_DIR="/config/.config/xfce4/xfconf/xfce-perchannel-xml"

# ---- Step 1: Config folder banana --------------------------------
mkdir -p "$CONFIG_DIR"

# ---- Step 2: XFCE Desktop XML force karo -------------------------
# Sabhi possible monitor names ke liye wallpaper set karo
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
      <property name="monitorHDMI-1" type="empty">
        <property name="workspace0" type="empty">
          <property name="color-style" type="int" value="0"/>
          <property name="image-style" type="int" value="5"/>
          <property name="last-image" type="string" value="/lotus-wallpaper.png"/>
        </property>
      </property>
      <property name="monitorscreen" type="empty">
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

# ---- Step 3: System ke SAARE wallpapers replace karo Lotus se ----
# Ab wallpaper picker kholo toh sirf Lotus dikhega!
find /usr/share/backgrounds -type f \( -name "*.png" -o -name "*.jpg" -o -name "*.jpeg" \) \
  -exec cp "$WALLPAPER" {} \; 2>/dev/null || true

# XFCE default wallpaper folder bhi replace
find /usr/share/xfce4 -name "*.png" -o -name "*.jpg" 2>/dev/null | \
  xargs -I{} cp "$WALLPAPER" {} 2>/dev/null || true

# /defaults bg bhi
cp "$WALLPAPER" /defaults/bg.png 2>/dev/null || true

# ---- Step 4: Config ownership fix karo ---------------------------
chown -R abc:abc /config/.config/ 2>/dev/null || true

# ---- Step 5: Wallpaper file READ-ONLY karo -----------------------
# Koi file delete ya change nahi kar payega
chmod 444 "$WALLPAPER"
chmod 444 /defaults/bg.png 2>/dev/null || true

# ---- Step 6: XML file bhi LOCK karo --------------------------------
chmod 444 "$CONFIG_DIR/xfce4-desktop.xml"

echo "[HeavenOS] Lotus wallpaper permanently set aur locked!"
