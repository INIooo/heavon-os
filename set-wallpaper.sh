#!/bin/bash
# ====================================================================
#  HeavenOS - cont-init script (macOS Sonoma UI & Full App Suite)
# ====================================================================

WALLPAPER="/usr/share/backgrounds/lotus.png"
CONFIG_DIR="/config/.config/xfce4/xfconf/xfce-perchannel-xml"
AUTOSTART_DIR="/config/.config/autostart"
DESKTOP_DIR="/config/Desktop"
PLANK_DIR="/config/.config/plank/dock1/launchers"

# ---- Folders creation ---------------------------------------------
mkdir -p "$CONFIG_DIR"
mkdir -p "$AUTOSTART_DIR"
mkdir -p "$DESKTOP_DIR"
mkdir -p "$PLANK_DIR"

# ---- Purge any old/cached backgrounds except lotus.png -----------
find /usr/share/backgrounds/ -type f ! -name "lotus.png" -delete 2>/dev/null || true
find /usr/share/wallpapers/ -type f -delete 2>/dev/null || true
cp -f /lotus-wallpaper.png "$WALLPAPER" 2>/dev/null || true
cp -f /lotus-wallpaper.png /defaults/bg.png 2>/dev/null || true

# ---- Clear old cached desktop settings ---------------------------
rm -rf /config/.cache/xfce4/desktop 2>/dev/null || true

# ---- Custom Web Title Branding Overrides ---------------------------
find /usr/share/kasmvnc/www /defaults -name "*.html" -exec sed -i 's/<title>.*<\/title>/<title>HeavenOS Cloud Workstation ☁️<\/title>/g' {} 2>/dev/null \; || true

# ---- PulseAudio Auto-start for Audio Streaming --------------------
if ! pgrep -x "pulseaudio" > /dev/null; then
    pulseaudio --start --exit-idle-time=-1 2>/dev/null || true
fi

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

# ---- Plank Dock Autostart ----------------------------------------
cat > "$AUTOSTART_DIR/plank.desktop" << 'EOF'
[Desktop Entry]
Type=Application
Name=Plank Dock
Exec=plank
Hidden=false
NoDisplay=false
X-GNOME-Autostart-enabled=true
EOF

# ====================================================================
#  DESKTOP SHORTCUTS (Full HeavenOS App Suite)
# ====================================================================

cat > "$DESKTOP_DIR/Chrome.desktop" << 'EOF'
[Desktop Entry]
Version=1.0
Type=Application
Name=Google Chrome
Comment=Web Browser
Exec=google-chrome-stable --no-sandbox %U
Icon=google-chrome
Terminal=false
Categories=Network;WebBrowser;
StartupNotify=true
EOF
chmod +x "$DESKTOP_DIR/Chrome.desktop"

cat > "$DESKTOP_DIR/Discord.desktop" << 'EOF'
[Desktop Entry]
Version=1.0
Type=Application
Name=Discord
Comment=Chat & Voice
Exec=discord --no-sandbox
Icon=discord
Terminal=false
Categories=Network;InstantMessaging;
StartupNotify=true
EOF
chmod +x "$DESKTOP_DIR/Discord.desktop"

cat > "$DESKTOP_DIR/VSCode.desktop" << 'EOF'
[Desktop Entry]
Version=1.0
Type=Application
Name=VS Code
Comment=Visual Studio Code
Exec=code --no-sandbox
Icon=vscode
Terminal=false
Categories=Development;IDE;
StartupNotify=true
EOF
chmod +x "$DESKTOP_DIR/VSCode.desktop"

cat > "$DESKTOP_DIR/Blender.desktop" << 'EOF'
[Desktop Entry]
Version=1.0
Type=Application
Name=Blender
Comment=3D Creation Suite
Exec=blender
Icon=blender
Terminal=false
Categories=Graphics;3DGraphics;
StartupNotify=true
EOF
chmod +x "$DESKTOP_DIR/Blender.desktop"

cat > "$DESKTOP_DIR/GIMP.desktop" << 'EOF'
[Desktop Entry]
Version=1.0
Type=Application
Name=GIMP
Comment=Image Editor
Exec=gimp
Icon=gimp
Terminal=false
Categories=Graphics;2DGraphics;
StartupNotify=true
EOF
chmod +x "$DESKTOP_DIR/GIMP.desktop"

cat > "$DESKTOP_DIR/Audacity.desktop" << 'EOF'
[Desktop Entry]
Version=1.0
Type=Application
Name=Audacity
Comment=Audio Editor
Exec=audacity
Icon=audacity
Terminal=false
Categories=AudioVideo;Audio;
StartupNotify=true
EOF
chmod +x "$DESKTOP_DIR/Audacity.desktop"

cat > "$DESKTOP_DIR/VLC.desktop" << 'EOF'
[Desktop Entry]
Version=1.0
Type=Application
Name=VLC Player
Comment=Media Player
Exec=vlc
Icon=vlc
Terminal=false
Categories=AudioVideo;Player;
StartupNotify=true
EOF
chmod +x "$DESKTOP_DIR/VLC.desktop"

cat > "$DESKTOP_DIR/FileZilla.desktop" << 'EOF'
[Desktop Entry]
Version=1.0
Type=Application
Name=FileZilla
Comment=FTP Client
Exec=filezilla
Icon=filezilla
Terminal=false
Categories=Network;FileTransfer;
StartupNotify=true
EOF
chmod +x "$DESKTOP_DIR/FileZilla.desktop"

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
#  PLANK DOCK LAUNCHERS (macOS Dock)
# ====================================================================
cat > "$PLANK_DIR/Chrome.dockitem" << 'EOF'
[PlankDockItemPreferences]
Launcher=file:///config/Desktop/Chrome.desktop
EOF

cat > "$PLANK_DIR/Discord.dockitem" << 'EOF'
[PlankDockItemPreferences]
Launcher=file:///config/Desktop/Discord.desktop
EOF

cat > "$PLANK_DIR/VSCode.dockitem" << 'EOF'
[PlankDockItemPreferences]
Launcher=file:///config/Desktop/VSCode.desktop
EOF

cat > "$PLANK_DIR/Blender.dockitem" << 'EOF'
[PlankDockItemPreferences]
Launcher=file:///config/Desktop/Blender.desktop
EOF

cat > "$PLANK_DIR/GIMP.dockitem" << 'EOF'
[PlankDockItemPreferences]
Launcher=file:///config/Desktop/GIMP.desktop
EOF

cat > "$PLANK_DIR/Files.dockitem" << 'EOF'
[PlankDockItemPreferences]
Launcher=file:///config/Desktop/Files.desktop
EOF

cat > "$PLANK_DIR/Terminal.dockitem" << 'EOF'
[PlankDockItemPreferences]
Launcher=file:///config/Desktop/Terminal.desktop
EOF

# ====================================================================
#  macOS SONOMA UI CONFIGURATION (WhiteSur GTK & Icons + Traffic Lights)
# ====================================================================

# ---- XFCE Settings (GTK, Icon, Cursor, Traffic Light Buttons) ------
cat > "$CONFIG_DIR/xsettings.xml" << 'XSETEOF'
<?xml version="1.0" encoding="UTF-8"?>
<channel name="xsettings" version="1.0">
  <property name="Net" type="empty">
    <property name="ThemeName" type="string" value="WhiteSur-Dark"/>
    <property name="IconThemeName" type="string" value="WhiteSur"/>
    <property name="CursorThemeName" type="string" value="WhiteSur-cursors"/>
    <property name="EnableEventSounds" type="bool" value="false"/>
    <property name="EnableInputFeedbackSounds" type="bool" value="false"/>
  </property>
  <property name="Gtk" type="empty">
    <property name="FontName" type="string" value="Ubuntu 10"/>
    <property name="MonospaceFontName" type="string" value="Monospace 10"/>
    <property name="CursorThemeName" type="string" value="WhiteSur-cursors"/>
    <property name="DecorationLayout" type="string" value="close,minimize,maximize:"/>
  </property>
</channel>
XSETEOF

# ---- XFWM4 Window Manager (macOS Traffic Light Buttons on Left) ----
cat > "$CONFIG_DIR/xfwm4.xml" << 'WMEOF'
<?xml version="1.0" encoding="UTF-8"?>
<channel name="xfwm4" version="1.0">
  <property name="general" type="empty">
    <property name="theme" type="string" value="WhiteSur-Dark"/>
    <property name="button_layout" type="string" value="CMH|"/>
    <property name="title_alignment" type="string" value="center"/>
    <property name="title_font" type="string" value="Ubuntu Bold 10"/>
  </property>
</channel>
WMEOF

# ---- PERMANENT XFCE DESKTOP XML CONFIG -----------------------------
chattr -i "$CONFIG_DIR/xfce4-desktop.xml" 2>/dev/null || true
cat > "$CONFIG_DIR/xfce4-desktop.xml" << XMLEOF
<?xml version="1.0" encoding="UTF-8"?>
<channel name="xfce4-desktop" version="1.0">
  <property name="backdrop" type="empty">
    <property name="screen0" type="empty">
      <property name="monitor0" type="empty">
        <property name="workspace0" type="empty">
          <property name="color-style" type="int" value="0"/>
          <property name="image-style" type="int" value="5"/>
          <property name="last-image" type="string" value="$WALLPAPER"/>
        </property>
      </property>
      <property name="monitor1" type="empty">
        <property name="workspace0" type="empty">
          <property name="color-style" type="int" value="0"/>
          <property name="image-style" type="int" value="5"/>
          <property name="last-image" type="string" value="$WALLPAPER"/>
        </property>
      </property>
      <property name="monitorVNC-0" type="empty">
        <property name="workspace0" type="empty">
          <property name="color-style" type="int" value="0"/>
          <property name="image-style" type="int" value="5"/>
          <property name="last-image" type="string" value="$WALLPAPER"/>
        </property>
      </property>
    </property>
  </property>
</channel>
XMLEOF

# ---- Ownership fix -----------------------------------------------
chown -R abc:abc /config/ 2>/dev/null || true
chown abc:abc /usr/local/bin/apply-lotus-wallpaper.sh

echo "[HeavenOS] macOS Sonoma UI + WhiteSur Theme + Plank Dock Registered!"
