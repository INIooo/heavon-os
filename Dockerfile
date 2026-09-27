# ====================================================================
#  HeavenOS - Based on Ubuntu XFCE (LinuxServer Webtop)
#  v8.5 - Ultra-Streamlined & Multi-OS Engine Optimized
# ====================================================================

FROM lscr.io/linuxserver/webtop:ubuntu-xfce

LABEL maintainer="HeavenOS"
LABEL description="HeavenOS - Ultra-Fast Ubuntu XFCE macOS Workstation"
LABEL version="8.5"

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

# ---- Single Consolidated Installation, Download, Extraction & Immediate Cleanup ----
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
        software-properties-common ca-certificates curl wget gnupg git aria2 && \
    add-apt-repository -y universe && \
    add-apt-repository -y multiverse && \
    wget -qO- https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor > /etc/apt/trusted.gpg.d/packages.microsoft.gpg && \
    echo "deb [arch=amd64,arm64,armhf signed-by=/etc/apt/trusted.gpg.d/packages.microsoft.gpg] https://packages.microsoft.com/repos/code stable main" > /etc/apt/sources.list.d/vscode.list && \
    wget -qO- https://dl.google.com/linux/linux_signing_key.pub | gpg --dearmor > /etc/apt/trusted.gpg.d/google-chrome.gpg && \
    echo "deb [arch=amd64 signed-by=/etc/apt/trusted.gpg.d/google-chrome.gpg] http://dl.google.com/linux/chrome/deb/ stable main" > /etc/apt/sources.list.d/google-chrome.list && \
    apt-get update && \
    apt-get install -y --no-install-recommends \
        gtk2-engines-murrine gtk2-engines-pixbuf plank \
        sound-theme-freedesktop ubuntu-sounds yaru-theme-sound \
        hicolor-icon-theme adwaita-icon-theme human-icon-theme gtk-update-icon-cache \
        libcanberra-gtk-module libcanberra-gtk3-module \
        pulseaudio-utils alsa-utils sox vorbis-tools \
        python3 python3-pip python3-venv nodejs \
        zenity thunar xfce4-terminal \
        onboard xinput xdotool libinput-tools \
        fonts-liberation libu2f-udev libvulkan1 xdg-utils libnspr4 libnss3 \
        gimp audacity vlc filezilla code blender krita kdenlive \
        wine wine64 winetricks cabextract \
        unar unrar p7zip-full p7zip-rar file-roller dmg2img hfsutils hfsprogs gdebi-core unzip && \
    mkdir -p /tmp/downloads /usr/share/themes /usr/share/icons && \
    (aria2c -s 16 -x 16 -k 1M -d /tmp/downloads -o chrome.deb "https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb" 2>/dev/null || true & \
     aria2c -s 16 -x 16 -k 1M -d /tmp/downloads -o discord.deb "https://discord.com/api/download?platform=linux&format=deb" 2>/dev/null || true & \
     git clone --depth 1 https://github.com/vinceliuice/WhiteSur-gtk-theme.git /tmp/WhiteSur-gtk 2>/dev/null || true & \
     git clone --depth 1 https://github.com/vinceliuice/WhiteSur-icon-theme.git /tmp/WhiteSur-icons 2>/dev/null || true) && wait && \
    dpkg -i /tmp/downloads/chrome.deb /tmp/downloads/discord.deb || apt-get install -fy && \
    (/tmp/WhiteSur-gtk/install.sh -d /usr/share/themes -c dark 2>/dev/null || (mkdir -p /usr/share/themes/WhiteSur-Dark && cp -r /tmp/WhiteSur-gtk/src/* /usr/share/themes/WhiteSur-Dark/ 2>/dev/null) || true) && \
    (/tmp/WhiteSur-icons/install.sh -d /usr/share/icons 2>/dev/null || (mkdir -p /usr/share/icons/WhiteSur && cp -r /tmp/WhiteSur-icons/src/* /usr/share/icons/WhiteSur/ 2>/dev/null) || true) && \
    gtk-update-icon-cache -f /usr/share/icons/WhiteSur 2>/dev/null || true && \
    gtk-update-icon-cache -f /usr/share/icons/hicolor 2>/dev/null || true && \
    rm -rf /tmp/downloads /tmp/WhiteSur-gtk /tmp/WhiteSur-icons /var/lib/apt/lists/* /var/tmp/* /tmp/* && \
    apt-get clean

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
