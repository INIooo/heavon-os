# ====================================================================
#  HeavenOS - Based on Arch Linux XFCE (LinuxServer Webtop)
#  Lotus wallpaper ONLY - Baaki sab DELETE (folder structure intact)
# ====================================================================

FROM lscr.io/linuxserver/webtop:arch-xfce

LABEL maintainer="HeavenOS"
LABEL description="HeavenOS - Arch Linux XFCE (Lotus Only)"
LABEL version="1.4"

ENV PUID=1000
ENV PGID=1000
ENV TZ=Asia/Kolkata
ENV TITLE=HeavenOS

EXPOSE 3000

# ---- Lotus wallpaper copy karo -----------------------------------
COPY Lotus-Wallpaper-Upscaled16x.png /lotus-wallpaper.png

# ---- Sirf FILES delete karo, FOLDERS mat chhuo! ------------------
# XFCE ko /usr/share/backgrounds/xfce/ folder chahiye hota hai
RUN find /usr/share/backgrounds -type f -delete 2>/dev/null || true

# ---- XFCE wala folder aur Lotus wahi rakh do --------------------
RUN mkdir -p /usr/share/backgrounds/xfce && \
    cp /lotus-wallpaper.png /usr/share/backgrounds/xfce/lotus.png && \
    cp /lotus-wallpaper.png /defaults/bg.png

# ---- Custom startup script ---------------------------------------
COPY set-wallpaper.sh /custom-cont-init.d/99-heaven-wallpaper.sh
RUN chmod +x /custom-cont-init.d/99-heaven-wallpaper.sh

# ---- Entry Point (inherited from base image) ----------------------
