#!/bin/bash
# ====================================================================
#  HeavenOS - Apply Lotus Wallpaper AFTER Desktop Loads
# ====================================================================

WALLPAPER="/lotus-wallpaper.png"

# Desktop fully load hone tak wait karo
sleep 3

# ---- Monitor properties set karo -----------------------------------
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

# ---- Sabhi existing last-image / image-path properties update karo ---
xfconf-query -c xfce4-desktop -lv 2>/dev/null | grep -E "last-image|image-path" | \
    awk '{print $1}' | while read prop; do
        xfconf-query -c xfce4-desktop -p "$prop" -s "$WALLPAPER" 2>/dev/null
    done

# ---- Refresh xfdesktop --------------------------------------------
killall xfdesktop 2>/dev/null
sleep 1
DISPLAY=:1 xfdesktop &

echo "[HeavenOS] Permanent Lotus wallpaper applied!"
