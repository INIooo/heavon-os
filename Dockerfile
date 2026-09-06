# ====================================================================
#  HeavenOS - Based on Arch Linux XFCE (LinuxServer Webtop)
#  Same image as described in: how to start up.txt
# ====================================================================

FROM lscr.io/linuxserver/webtop:arch-xfce

# ---- Labels --------------------------------------------------------
LABEL maintainer="HeavenOS"
LABEL description="HeavenOS - Arch Linux XFCE Desktop (Webtop)"
LABEL version="1.0"

# ---- Environment Variables -----------------------------------------
ENV PUID=1000
ENV PGID=1000
ENV TZ=Asia/Kolkata
ENV TITLE=HeavenOS

# ---- Default Port --------------------------------------------------
EXPOSE 3000

# ---- Wallpaper - PERMANENT SET ------------------------------------
# 1. Lotus wallpaper ko default location pe copy karo
COPY Lotus-Wallpaper-Upscaled16x.png /defaults/bg.png

# 2. Same wallpaper ko /usr/share me bhi rakhte hain (fallback)
COPY Lotus-Wallpaper-Upscaled16x.png /usr/share/backgrounds/heaven-lotus.png

# 3. XFCE wallpaper config permanently set karo
#    xfce4-desktop channel me image-path set ho rahi hai
RUN mkdir -p /defaults/.config/xfce4/xfconf/xfce-perchannel-xml && \
    cat > /defaults/.config/xfce4/xfconf/xfce-perchannel-xml/xfce4-desktop.xml << 'XFCE_CONFIG_EOF'
<?xml version="1.0" encoding="UTF-8"?>
<channel name="xfce4-desktop" version="1.0">
  <property name="backdrop" type="empty">
    <property name="screen0" type="empty">
      <property name="monitorVNC-0" type="empty">
        <property name="workspace0" type="empty">
          <property name="color-style" type="int" value="0"/>
          <property name="image-style" type="int" value="5"/>
          <property name="last-image" type="string" value="/usr/share/backgrounds/heaven-lotus.png"/>
        </property>
      </property>
      <property name="monitor0" type="empty">
        <property name="workspace0" type="empty">
          <property name="color-style" type="int" value="0"/>
          <property name="image-style" type="int" value="5"/>
          <property name="last-image" type="string" value="/usr/share/backgrounds/heaven-lotus.png"/>
        </property>
      </property>
    </property>
  </property>
</channel>
XFCE_CONFIG_EOF

# ---- Entry Point (inherited from base image) ----------------------
# Base image ka entrypoint use hoga (LinuxServer s6-overlay)
