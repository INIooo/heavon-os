# ====================================================================
#  HeavenOS - Based on Ubuntu XFCE (LinuxServer Webtop)
#  v5.3 - Fixed NodeSource npm conflict & apt dependencies
# ====================================================================

FROM lscr.io/linuxserver/webtop:ubuntu-xfce

LABEL maintainer="HeavenOS"
LABEL description="HeavenOS - Ubuntu XFCE Base with Full Application Suite"
LABEL version="5.3"

ENV PUID=1000
ENV PGID=1000
ENV TZ=Asia/Kolkata
ENV TITLE=HeavenOS
ENV DEBIAN_FRONTEND=noninteractive

EXPOSE 3000

# ---- 1. Enable Universe & Multiverse Repositories ----------------
RUN apt-get update && \
    apt-get install -y \
    software-properties-common ca-certificates curl wget gnupg git && \
    add-apt-repository -y universe && \
    add-apt-repository -y multiverse && \
    apt-get update

# ---- 2. Developer Tools (Python3 & Node.js) ----------------------
# Note: 'nodejs' package from NodeSource already includes 'npm'
RUN apt-get install -y \
    python3 python3-pip python3-venv nodejs && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# ---- 3. Creative & Multimedia Apps --------------------------------
RUN apt-get update && \
    apt-get install -y \
    blender gimp audacity vlc filezilla && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# ---- 4. Google Chrome Install -------------------------------------
RUN wget -q https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb && \
    apt-get update && \
    (apt-get install -y ./google-chrome-stable_current_amd64.deb || apt-get install -fy) && \
    rm -f google-chrome-stable_current_amd64.deb && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# ---- 5. Discord Install -------------------------------------------
RUN wget -q -O discord.deb "https://discord.com/api/download?platform=linux&format=deb" && \
    apt-get update && \
    (apt-get install -y ./discord.deb || apt-get install -fy) && \
    rm -f discord.deb && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# ---- 6. VS Code Install -------------------------------------------
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
