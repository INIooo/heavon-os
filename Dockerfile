# ====================================================================
#  HeavenOS - Based on Ubuntu XFCE (LinuxServer Webtop)
#  v3.0 - Rock solid Ubuntu base for Cloud PC Service
# ====================================================================

FROM lscr.io/linuxserver/webtop:ubuntu-xfce

LABEL maintainer="HeavenOS"
LABEL description="HeavenOS - Ubuntu XFCE Base (Production Cloud PC)"
LABEL version="3.0"

ENV PUID=1000
ENV PGID=1000
ENV TZ=Asia/Kolkata
ENV TITLE=HeavenOS

EXPOSE 3000

# ---- Lotus wallpaper copy karo -----------------------------------
COPY Lotus-Wallpaper-Upscaled16x.png /lotus-wallpaper.png


# ---- Sirf FILES delete karo, XFCE folders intact rakho -----------
RUN find /usr/share/backgrounds -type f -delete 2>/dev/null || true

# ---- Sirf Lotus wahi rakho (XFCE ka exact folder) ----------------
RUN mkdir -p /usr/share/backgrounds/xfce && \
    cp /lotus-wallpaper.png /usr/share/backgrounds/xfce/lotus.png && \
    cp /lotus-wallpaper.png /defaults/bg.png

# ---- Scripts copy karo -------------------------------------------
COPY apply-wallpaper.sh /apply-wallpaper.sh
RUN chmod +x /apply-wallpaper.sh

# ---- cont-init script (desktop se pehle chalta hai) --------------
COPY set-wallpaper.sh /custom-cont-init.d/99-heaven-wallpaper.sh
RUN chmod +x /custom-cont-init.d/99-heaven-wallpaper.sh

# ---- Entry Point (inherited from base image) ----------------------
