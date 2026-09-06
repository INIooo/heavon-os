#!/bin/bash
# ====================================================================
#  HeavenOS - Force Lotus Wallpaper - NUCLEAR LOCK
#  Runs on EVERY boot via /custom-cont-init.d/
# ====================================================================

WALLPAPER="/lotus-wallpaper.png"
CONFIG_DIR="/config/.config/xfce4/xfconf/xfce-perchannel-xml"
XML_FILE="$CONFIG_DIR/xfce4-desktop.xml"

echo "[HeavenOS] Setting Lotus wallpaper..."

# ---- Step 1: Config folder banana --------------------------------
mkdir -p "$CONFIG_DIR"

# ---- Step 2: Agar XML pehle se immutable hai toh unlock karo -----
chattr -i "$XML_FILE" 2>/dev/null || true

# ---- Step 3: XFCE Desktop XML force karo -------------------------
cat > "$XML_FILE" << 'XMLEOF'
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
    </property>
  </property>
</channel>
XMLEOF

# ---- Step 4: XML file IMMUTABLE karo (chattr +i) ------------------
# Ab koi bhi - root bhi - is file ko change nahi kar sakta!
chown abc:abc "$XML_FILE"
chattr +i "$XML_FILE"

# ---- Step 5: Ownership fix karo ----------------------------------
chown -R abc:abc /config/.config/ 2>/dev/null || true

# ---- Step 6: Lotus file bhi lock karo ----------------------------
chattr +i "$WALLPAPER" 2>/dev/null || true

echo "[HeavenOS] Lotus wallpaper LOCKED with chattr +i! No one can change it."
