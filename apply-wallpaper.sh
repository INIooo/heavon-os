#!/bin/bash
# ====================================================================
#  HeavenOS - Apply Lotus Wallpaper AFTER Desktop Loads
# ====================================================================

WALLPAPER="/usr/share/backgrounds/lotus.png"

# ---- Set wallpaper across monitor properties cleanly ---------------
if command -v xfconf-query &>/dev/null; then
    for monitor in "monitor0" "monitor1" "monitorVNC-0"; do
        xfconf-query -c xfce4-desktop \
            -p "/backdrop/screen0/$monitor/workspace0/last-image" \
            -s "$WALLPAPER" --create -t string 2>/dev/null || true
        xfconf-query -c xfce4-desktop \
            -p "/backdrop/screen0/$monitor/workspace0/image-style" \
            -s 5 --create -t int 2>/dev/null || true
        xfconf-query -c xfce4-desktop \
            -p "/backdrop/screen0/$monitor/workspace0/color-style" \
            -s 0 --create -t int 2>/dev/null || true
    done
    xfdesktop --reload 2>/dev/null || true
fi

echo "[HeavenOS] Permanent Lotus wallpaper applied!"
