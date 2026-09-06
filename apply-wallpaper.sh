#!/bin/bash
# ====================================================================
#  HeavenOS - Apply Lotus Wallpaper AFTER Desktop Loads
#  Runs via XFCE Autostart (user session ke baad)
#  Fix: killall xfdesktop approach (Wayland bug workaround)
# ====================================================================

WALLPAPER="/lotus-wallpaper.png"

# Desktop + xfdesktop fully load hone tak wait karo
sleep 5

# ---- Known Property Set karo (VNC-0 monitor name in webtop) ------
xfconf-query -c xfce4-desktop \
    -p /backdrop/screen0/monitorVNC-0/workspace0/last-image \
    -s "$WALLPAPER" --create -t string 2>/dev/null

xfconf-query -c xfce4-desktop \
    -p /backdrop/screen0/monitorVNC-0/workspace0/image-style \
    -s 5 --create -t int 2>/dev/null

xfconf-query -c xfce4-desktop \
    -p /backdrop/screen0/monitorVNC-0/workspace0/color-style \
    -s 0 --create -t int 2>/dev/null

# ---- Sabhi existing last-image properties bhi update karo --------
xfconf-query -c xfce4-desktop -lv 2>/dev/null | grep "last-image" | \
    awk '{print $1}' | while read prop; do
        xfconf-query -c xfce4-desktop -p "$prop" -s "$WALLPAPER" 2>/dev/null
    done

# ---- THE KEY FIX: killall xfdesktop (Wayland workaround) ---------
# xfdesktop ko restart karo - wallpaper turant apply ho jayega
killall xfdesktop 2>/dev/null
sleep 1
DISPLAY=:1 xfdesktop &

echo "[HeavenOS] Lotus wallpaper applied via xfdesktop restart!"
