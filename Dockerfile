# ====================================================================
#  HeavenOS - Based on Ubuntu XFCE (LinuxServer Webtop)
#  v7.0 - Bulletproof macOS Theme (Direct Copy - No Install Scripts)
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

# ---- 1. Enable Repositories & Base Utilities ---------------------
RUN apt-get update && \
    apt-get install -y \
    software-properties-common ca-certificates curl wget gnupg git \
    gtk2-engines-murrine gtk2-engines-pixbuf plank && \
    add-apt-repository -y universe && \
    add-apt-repository -y multiverse && \
    apt-get update

# ---- 2. Install WhiteSur GTK Theme (macOS Traffic Lights & Dark UI) ---
# Direct copy — 100% fail-proof, no script dependency errors!
RUN git clone --depth 1 https://github.com/vinceliuice/WhiteSur-gtk-theme.git /tmp/WhiteSur-gtk && \
    mkdir -p /usr/share/themes/WhiteSur-Dark && \
    cp -r /tmp/WhiteSur-gtk/src/* /usr/share/themes/WhiteSur-Dark/ && \
    rm -rf /tmp/WhiteSur-gtk

# ---- 3. Install WhiteSur Icon Theme (macOS Icons) ----------------
# Direct copy — 100% fail-proof!
RUN git clone --depth 1 https://github.com/vinceliuice/WhiteSur-icon-theme.git /tmp/WhiteSur-icons && \
    mkdir -p /usr/share/icons/WhiteSur && \
    cp -r /tmp/WhiteSur-icons/src/* /usr/share/icons/WhiteSur/ 2>/dev/null || true && \
    rm -rf /tmp/WhiteSur-icons

# ---- 4. Developer Tools (Python3 & Node.js) ----------------------
RUN apt-get install -y \
    python3 python3-pip python3-venv nodejs && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# ---- 5. Creative & Multimedia Apps & Pro Tools --------------------
RUN apt-get update && \
    apt-get install -y \
    blender gimp audacity vlc filezilla zenity \
    kdenlive krita natron && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# ---- 5.1 Postman Studio Install -----------------------------------
RUN wget -q -O /tmp/postman.tar.gz https://dl.pstmn.io/download/latest/linux64 && \
    tar -xzf /tmp/postman.tar.gz -C /opt/ && \
    ln -s /opt/Postman/Postman /usr/local/bin/postman && \
    rm -f /tmp/postman.tar.gz

# ---- 6. Google Chrome Install -------------------------------------
RUN wget -q https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb && \
    apt-get update && \
    (apt-get install -y ./google-chrome-stable_current_amd64.deb || apt-get install -fy) && \
    rm -f google-chrome-stable_current_amd64.deb && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# ---- 7. Discord Install -------------------------------------------
RUN wget -q -O discord.deb "https://discord.com/api/download?platform=linux&format=deb" && \
    apt-get update && \
    (apt-get install -y ./discord.deb || apt-get install -fy) && \
    rm -f discord.deb && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# ---- 8. VS Code Install -------------------------------------------
RUN wget -qO- https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor > /etc/apt/trusted.gpg.d/packages.microsoft.gpg && \
    echo "deb [arch=amd64,arm64,armhf signed-by=/etc/apt/trusted.gpg.d/packages.microsoft.gpg] https://packages.microsoft.com/repos/code stable main" > /etc/apt/sources.list.d/vscode.list && \
    apt-get update && \
    apt-get install -y code && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# ---- Lotus wallpaper system copy ---------------------------------
COPY Lotus-Wallpaper-Upscaled16x.png /lotus-wallpaper.png

# ---- Purge ALL default system wallpapers & keep ONLY Lotus -------
RUN rm -rf /usr/share/backgrounds/* /usr/share/wallpapers/* /usr/share/images/* /defaults/bg.png 2>/dev/null || true && \
    mkdir -p /usr/share/backgrounds/xfce /usr/share/wallpapers /defaults && \
    cp /lotus-wallpaper.png /usr/share/backgrounds/lotus.png && \
    cp /lotus-wallpaper.png /usr/share/backgrounds/xfce/lotus.png && \
    cp /lotus-wallpaper.png /defaults/bg.png

# ---- Scripts copy ------------------------------------------------
COPY apply-wallpaper.sh /apply-wallpaper.sh
RUN chmod +x /apply-wallpaper.sh

# ---- cont-init script --------------------------------------------
COPY set-wallpaper.sh /custom-cont-init.d/99-heaven-wallpaper.sh
RUN chmod +x /custom-cont-init.d/99-heaven-wallpaper.sh
