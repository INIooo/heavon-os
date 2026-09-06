#!/bin/bash
# ====================================================================
#  HeavenOS - Apply Lotus Wallpaper AFTER Desktop Loads
#  Ye script XFCE Autostart se chalta hai (session ke baad)
# ====================================================================

# Desktop fully load hone tak wait karo
sleep 4

WALLPAPER="/lotus-wallpaper.png"

# Sabhi existing wallpaper properties ko Lotus se replace karo
xfconf-query -c xfce4-desktop -lv 2>/dev/null | grep "last-image" | awk '{print $1}' | while read prop; do
    xfconf-query -c xfce4-desktop -p "$prop" -s "$WALLPAPER"
done

# Sabhi common monitor names ke liye force set karo
for monitor in VNC-0 VNC0 monitor0 HDMI-1 screen Virtual-1 default; do
    xfconf-query -c xfce4-desktop \
        -p "/backdrop/screen0/monitor${monitor}/workspace0/last-image" \
        -s "$WALLPAPER" --create -t string 2>/dev/null || true
    xfconf-query -c xfce4-desktop \
        -p "/backdrop/screen0/monitor${monitor}/workspace0/image-style" \
        -s 5 --create -t int 2>/dev/null || true
    xfconf-query -c xfce4-desktop \
        -p "/backdrop/screen0/monitor${monitor}/workspace0/color-style" \
        -s 0 --create -t int 2>/dev/null || true
done

# Desktop reload karo - wallpaper turant apply ho jayega
xfdesktop --reload 2>/dev/null || true

echo "[HeavenOS] Lotus wallpaper applied via xfconf-query!"
