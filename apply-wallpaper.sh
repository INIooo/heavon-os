#!/bin/bash
# ====================================================================
#  HeavenOS - Apply Lotus Wallpaper AFTER Desktop Loads
# ====================================================================

WALLPAPER="/usr/share/backgrounds/lotus.png"

# Wait for desktop session to launch
sleep 2

# ---- Set wallpaper across all monitor properties ------------------
for monitor in "monitor0" "monitor1" "monitorVNC-0"; do
    xfconf-query -c xfce4-desktop \
        -p "/backdrop/screen0/$monitor/workspace0/last-image" \
        -s "$WALLPAPER" --create -t string 2>/dev/null
    xfconf-query -c xfce4-desktop \
        -p "/backdrop/screen0/$monitor/workspace0/image-style" \
        -s 5 --create -t int 2>/dev/null
    xfconf-query -c xfce4-desktop \
        -p "/backdrop/screen0/$monitor/workspace0/color-style" \
        -s 0 --create -t int 2>/dev/null
done

# ---- Set any other existing last-image properties -----------------
xfconf-query -c xfce4-desktop -lv 2>/dev/null | grep -E "last-image|image-path" | \
    awk '{print $1}' | while read prop; do
        xfconf-query -c xfce4-desktop -p "$prop" -s "$WALLPAPER" 2>/dev/null
    done

# ---- Refresh xfdesktop --------------------------------------------
killall xfdesktop 2>/dev/null
sleep 1
DISPLAY=:1 xfdesktop &

echo "[HeavenOS] Permanent Lotus wallpaper applied!"
