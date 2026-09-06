# ====================================================================
#  HeavenOS - Based on Ubuntu XFCE (LinuxServer Webtop)
#  v4.0 - Permanent Lotus Wallpaper Only (All default wallpapers purged)
# ====================================================================

FROM lscr.io/linuxserver/webtop:ubuntu-xfce

LABEL maintainer="HeavenOS"
LABEL description="HeavenOS - Ubuntu XFCE Base with Permanent Lotus Wallpaper"
LABEL version="4.0"

ENV PUID=1000
ENV PGID=1000
ENV TZ=Asia/Kolkata
ENV TITLE=HeavenOS

EXPOSE 3000

# ---- Lotus wallpaper system mein copy karo -----------------------
COPY Lotus-Wallpaper-Upscaled16x.png /lotus-wallpaper.png

# ---- Purge ALL default system wallpapers & keep ONLY Lotus -------
RUN rm -rf /usr/share/backgrounds/* /usr/share/wallpapers/* /usr/share/images/* /defaults/bg.png 2>/dev/null || true && \
    mkdir -p /usr/share/backgrounds/xfce /usr/share/wallpapers /defaults && \
    cp /lotus-wallpaper.png /usr/share/backgrounds/lotus.png && \
    cp /lotus-wallpaper.png /usr/share/backgrounds/xfce/lotus.png && \
    cp /lotus-wallpaper.png /defaults/bg.png

# ---- Scripts copy karo -------------------------------------------
COPY apply-wallpaper.sh /apply-wallpaper.sh
RUN chmod +x /apply-wallpaper.sh

# ---- cont-init script (desktop start hone se pehle chalta hai) ---
COPY set-wallpaper.sh /custom-cont-init.d/99-heaven-wallpaper.sh
RUN chmod +x /custom-cont-init.d/99-heaven-wallpaper.sh
