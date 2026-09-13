# ====================================================================
#  HeavenOS - Based on Ubuntu XFCE (LinuxServer Webtop)
#  v7.0 - Ultra-Fast Build Optimized (< 100s Target)
# ====================================================================

FROM lscr.io/linuxserver/webtop:ubuntu-xfce

LABEL maintainer="HeavenOS"
LABEL description="HeavenOS - Ubuntu XFCE macOS Sonoma Workstation"
LABEL version="7.0"

ENV PUID=1000
ENV PGID=1000
ENV TZ=Asia/Kolkata
ENV TITLE=HeavenOS
ENV DEBIAN_FRONTEND=noninteractive
ENV FRAME_RATE=60
ENV CUSTOM_FRAME_RATE=60
ENV WEBTOP_FPS=60
ENV MAX_FPS=60
ENV GALLIUM_DRIVER=llvmpipe
ENV LP_NUM_THREADS=4

EXPOSE 3000

# ---- 1. Enable Repositories & Single Apt Update ------------------
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
    software-properties-common ca-certificates curl wget gnupg git aria2 && \
    add-apt-repository -y universe && \
    add-apt-repository -y multiverse && \
    sed -i 's/main/main universe multiverse/g' /etc/apt/sources.list 2>/dev/null || true && \
    wget -qO- https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor > /etc/apt/trusted.gpg.d/packages.microsoft.gpg && \
    echo "deb [arch=amd64,arm64,armhf signed-by=/etc/apt/trusted.gpg.d/packages.microsoft.gpg] https://packages.microsoft.com/repos/code stable main" > /etc/apt/sources.list.d/vscode.list && \
    wget -qO- https://dl.google.com/linux/linux_signing_key.pub | gpg --dearmor > /etc/apt/trusted.gpg.d/google-chrome.gpg && \
    echo "deb [arch=amd64 signed-by=/etc/apt/trusted.gpg.d/google-chrome.gpg] http://dl.google.com/linux/chrome/deb/ stable main" > /etc/apt/sources.list.d/google-chrome.list && \
    apt-get update

# ---- 2. High-Speed Parallel Download (Chrome, Discord, Natron, Postman, WhiteSur Themes) ----
RUN mkdir -p /tmp/downloads && \
    (aria2c -s 16 -x 16 -k 1M -d /tmp/downloads -o chrome.deb "https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb" 2>/dev/null || true & \
     aria2c -s 16 -x 16 -k 1M -d /tmp/downloads -o discord.deb "https://discord.com/api/download?platform=linux&format=deb" 2>/dev/null || true & \
     aria2c -s 16 -x 16 -k 1M -d /tmp/downloads -o natron.tgz "https://github.com/NatronGitHub/Natron/releases/download/v2.5.0/Natron-2.5.0-Linux-x86_64.tgz" 2>/dev/null || true & \
     aria2c -s 16 -x 16 -k 1M -d /tmp/downloads -o postman.tar.gz "https://dl.pstmn.io/download/latest/linux64" 2>/dev/null || true & \
     git clone --depth 1 https://github.com/vinceliuice/WhiteSur-gtk-theme.git /tmp/WhiteSur-gtk 2>/dev/null || true & \
     git clone --depth 1 https://github.com/vinceliuice/WhiteSur-icon-theme.git /tmp/WhiteSur-icons 2>/dev/null || true) && wait

# ---- 3. Base Utilities, Touchscreen & GUI Components --------------
RUN apt-get update && apt-get install -y \
    gtk2-engines-murrine gtk2-engines-pixbuf plank \
    sound-theme-freedesktop ubuntu-sounds yaru-theme-sound \
    libcanberra-gtk-module libcanberra-gtk3-module \
    pulseaudio-utils alsa-utils sox vorbis-tools \
    python3 python3-pip python3-venv nodejs \
    zenity thunar xfce4-terminal \
    onboard xinput xdotool libinput-tools \
    fonts-liberation libu2f-udev libvulkan1 xdg-utils libnspr4 libnss3 || apt-get install -fy

# ---- 4. Creative & Multimedia App Suite (Blender, GIMP, Kdenlive, etc.) ----
RUN apt-get update && apt-get install -y \
    blender gimp audacity vlc filezilla kdenlive krita code || apt-get install -fy

# ---- 5. Install Local Deb Packages (Chrome & Discord) -------------
RUN dpkg -i /tmp/downloads/chrome.deb /tmp/downloads/discord.deb || apt-get install -fy

# ---- 4. Install Themes, Extract Tarballs & Cleanup ---------------
RUN mkdir -p /usr/share/themes/WhiteSur-Dark /usr/share/icons/WhiteSur /opt/natron /opt/Postman && \
    cp -r /tmp/WhiteSur-gtk/src/* /usr/share/themes/WhiteSur-Dark/ 2>/dev/null || true && \
    cp -r /tmp/WhiteSur-icons/src/* /usr/share/icons/WhiteSur/ 2>/dev/null || true && \
    tar -xzf /tmp/downloads/natron.tgz -C /opt/natron --strip-components=1 2>/dev/null || true && \
    tar -xzf /tmp/downloads/postman.tar.gz -C /opt/ 2>/dev/null || true && \
    chmod +x /opt/natron/bin/Natron /opt/natron/Natron /opt/Postman/Postman 2>/dev/null || true && \
    (ln -sf /opt/natron/bin/Natron /usr/local/bin/natron 2>/dev/null || ln -sf /opt/natron/Natron /usr/local/bin/natron 2>/dev/null || true) && \
    ln -sf /opt/Postman/Postman /usr/local/bin/postman 2>/dev/null || true && \
    rm -rf /tmp/downloads /tmp/WhiteSur-gtk /tmp/WhiteSur-icons && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# ---- Lotus wallpaper system copy ---------------------------------
COPY Lotus-Wallpaper-Upscaled16x.png /lotus-wallpaper.png

# ---- Purge ALL default system wallpapers & keep ONLY Lotus -------
RUN rm -rf /usr/share/backgrounds/* /usr/share/wallpapers/* /usr/share/images/* /usr/share/xfce4/backdrops/* /defaults/bg.png 2>/dev/null || true && \
    mkdir -p /usr/share/backgrounds/xfce /usr/share/xfce4/backdrops /usr/share/wallpapers /defaults && \
    cp /lotus-wallpaper.png /usr/share/backgrounds/lotus.png && \
    cp /lotus-wallpaper.png /usr/share/backgrounds/xfce/lotus.png && \
    cp /lotus-wallpaper.png /usr/share/xfce4/backdrops/lotus.png && \
    cp /lotus-wallpaper.png /defaults/bg.png

# ---- Scripts copy ------------------------------------------------
COPY apply-wallpaper.sh /apply-wallpaper.sh
RUN chmod +x /apply-wallpaper.sh

# ---- cont-init script --------------------------------------------
COPY set-wallpaper.sh /custom-cont-init.d/99-heaven-wallpaper.sh
RUN chmod +x /custom-cont-init.d/99-heaven-wallpaper.sh

