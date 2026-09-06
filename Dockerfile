# ====================================================================
#  HeavenOS - Based on Arch Linux XFCE (LinuxServer Webtop)
#  Lotus wallpaper PERMANENTLY LOCKED - koi change nahi kar sakta
# ====================================================================

FROM lscr.io/linuxserver/webtop:arch-xfce

LABEL maintainer="HeavenOS"
LABEL description="HeavenOS - Arch Linux XFCE Desktop (Lotus Wallpaper Locked)"
LABEL version="1.1"

ENV PUID=1000
ENV PGID=1000
ENV TZ=Asia/Kolkata
ENV TITLE=HeavenOS

EXPOSE 3000

# ---- Lotus wallpaper root pe rakhte hain (permanent location) -----
COPY Lotus-Wallpaper-Upscaled16x.png /lotus-wallpaper.png

# ---- Saare system wallpapers ko Lotus se replace karo -------------
# Wallpaper picker kholne pe sirf Lotus hi dikhega!
RUN cp /lotus-wallpaper.png /defaults/bg.png && \
    mkdir -p /usr/share/backgrounds/xfce && \
    cp /lotus-wallpaper.png /usr/share/backgrounds/xfce/xfce-verticals.png && \
    # Har wallpaper file ko Lotus se replace karo
    find /usr/share/backgrounds -type f \( -name "*.png" -o -name "*.jpg" \) \
      -exec cp /lotus-wallpaper.png {} \; 2>/dev/null || true

# ---- Custom startup script register karo -------------------------
# LinuxServer containers /custom-cont-init.d/ se scripts chalate hain
COPY set-wallpaper.sh /custom-cont-init.d/99-heaven-wallpaper.sh
RUN chmod +x /custom-cont-init.d/99-heaven-wallpaper.sh

# ---- XFCE Desktop Settings plugin hatao (right-click se change na ho sake) ---
# Agar koi chahta bhi hai toh GUI se wallpaper settings nahi milegi
RUN pacman -R --noconfirm xfce4-desktop 2>/dev/null || \
    pacman -Rdd --noconfirm xfdesktop 2>/dev/null || true

# ---- Entry Point (inherited from base image) ----------------------
