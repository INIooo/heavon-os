#!/bin/bash
# ====================================================================
#  HeavenOS - cont-init script (macOS Sonoma UI & Full App Suite)
# ====================================================================

WALLPAPER="/usr/share/backgrounds/lotus.png"
CONFIG_DIR="/config/.config/xfce4/xfconf/xfce-perchannel-xml"
AUTOSTART_DIR="/config/.config/autostart"
DESKTOP_DIR="/config/Desktop"
PLANK_DIR="/config/.config/plank/dock1/launchers"

# ---- Folders creation ---------------------------------------------
mkdir -p "$CONFIG_DIR"
mkdir -p "$AUTOSTART_DIR"
mkdir -p "$DESKTOP_DIR"
mkdir -p "$PLANK_DIR"

# ---- Purge any old/cached backgrounds except lotus.png -----------
find /usr/share/backgrounds/ -type f ! -name "lotus.png" -delete 2>/dev/null || true
find /usr/share/wallpapers/ -type f -delete 2>/dev/null || true
cp -f /lotus-wallpaper.png "$WALLPAPER" 2>/dev/null || true
cp -f /lotus-wallpaper.png /defaults/bg.png 2>/dev/null || true

# ---- Clear old cached desktop settings ---------------------------
rm -rf /config/.cache/xfce4/desktop 2>/dev/null || true

# ---- apply-wallpaper script system copy --------------------------
cp /apply-wallpaper.sh /usr/local/bin/apply-lotus-wallpaper.sh
chmod +x /usr/local/bin/apply-lotus-wallpaper.sh

# ---- XFCE Autostart entry (wallpaper enforcement) -----------------
cat > "$AUTOSTART_DIR/heaven-wallpaper.desktop" << 'EOF'
[Desktop Entry]
Type=Application
Name=HeavenOS Wallpaper
Exec=bash /usr/local/bin/apply-lotus-wallpaper.sh
Hidden=false
NoDisplay=false
X-GNOME-Autostart-enabled=true
EOF

# ---- Plank Dock Autostart ----------------------------------------
cat > "$AUTOSTART_DIR/plank.desktop" << 'EOF'
[Desktop Entry]
Type=Application
Name=Plank Dock
Exec=plank
Hidden=false
NoDisplay=false
X-GNOME-Autostart-enabled=true
EOF

# ====================================================================
#  HEAVENOS FILE UPLOADER SERVICE (Drag & Drop File Upload Portal)
# ====================================================================
cat > /usr/local/bin/heaven-uploader.py << 'PYEOF'
import os
import re
from http.server import HTTPServer, BaseHTTPRequestHandler

PORT = 8889
DEST_DIR = "/config/Desktop"
os.makedirs(DEST_DIR, exist_ok=True)

class UploadHandler(BaseHTTPRequestHandler):
    def do_GET(self):
        self.send_response(200)
        self.send_header('Content-type', 'text/html')
        self.end_headers()
        html = '''<!DOCTYPE html>
<html>
<head>
    <title>HeavenOS File Drop</title>
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <style>
        * { box-sizing: border-box; }
        body { font-family: 'Segoe UI', Tahoma, sans-serif; background: #0b0f19; color: #e2e8f0; margin:0; padding: 20px; display:flex; justify-content:center; align-items:center; min-height:100vh; }
        .card { background: #161e2e; border: 1px solid #2d3748; padding: 35px; border-radius: 16px; width: 100%; max-width: 550px; text-align: center; box-shadow: 0 20px 30px rgba(0,0,0,0.5); }
        h2 { color: #38bdf8; font-size: 24px; margin-top: 0; margin-bottom: 8px; }
        p { color: #94a3b8; font-size: 14px; margin-bottom: 25px; }
        .drop-area { border: 2px dashed #38bdf8; background: rgba(56, 189, 248, 0.04); border-radius: 12px; padding: 40px 20px; cursor: pointer; transition: 0.3s; }
        .drop-area:hover, .drop-area.highlight { background: rgba(56, 189, 248, 0.12); border-color: #7dd3fc; }
        .icon { font-size: 48px; margin-bottom: 10px; display:block; }
        input[type="file"] { display: none; }
        .btn { background: linear-gradient(135deg, #0284c7, #2563eb); color: white; border: none; padding: 12px 28px; border-radius: 8px; font-size: 15px; font-weight: 600; cursor: pointer; margin-top: 20px; transition: 0.2s; box-shadow: 0 4px 12px rgba(2,132,199,0.3); }
        .btn:hover { opacity: 0.9; transform: translateY(-1px); }
        #status { margin-top: 20px; font-size: 14px; font-weight: 600; }
        .progress-bar { width: 100%; background: #1e293b; height: 8px; border-radius: 4px; overflow: hidden; margin-top: 15px; display: none; }
        .progress-fill { height: 100%; background: #38bdf8; width: 0%; transition: width 0.1s; }
        .file-info { margin-top: 15px; font-size: 13px; color: #a0aec0; text-align: left; background: #0f172a; padding: 10px; border-radius: 6px; display: none; }
    </style>
</head>
<body>
    <div class="card">
        <span class="icon">☁️</span>
        <h2>HeavenOS File Uploader</h2>
        <p>Upload video, audio, images, 3D models or editing files directly to your HeavenOS Desktop!</p>

        <div class="drop-area" id="dropArea" onclick="document.getElementById('fileInput').click()">
            📁 <br><b>Click to Choose Files</b> or Drag & Drop here
            <input type="file" id="fileInput" multiple onchange="handleFiles(this.files)">
        </div>

        <div class="file-info" id="fileInfo"></div>
        <div class="progress-bar" id="progressBar"><div class="progress-fill" id="progressFill"></div></div>
        <button class="btn" onclick="uploadFiles()">Upload Files</button>
        <div id="status"></div>
    </div>

    <script>
        let selectedFiles = [];
        const dropArea = document.getElementById('dropArea');

        ['dragenter', 'dragover', 'dragleave', 'drop'].forEach(eventName => {
            dropArea.addEventListener(eventName, preventDefaults, false);
        });

        function preventDefaults(e) { e.preventDefault(); e.stopPropagation(); }

        ['dragenter', 'dragover'].forEach(eventName => {
            dropArea.classList.add('highlight');
        });

        ['dragleave', 'drop'].forEach(eventName => {
            dropArea.classList.remove('highlight');
        });

        dropArea.addEventListener('drop', (e) => {
            let dt = e.dataTransfer;
            handleFiles(dt.files);
        });

        function handleFiles(files) {
            selectedFiles = Array.from(files);
            let info = document.getElementById('fileInfo');
            info.style.display = 'block';
            info.innerHTML = '<b>Selected Files:</b><br>' + selectedFiles.map(f => '• ' + f.name + ' (' + (f.size/1024/1024).toFixed(2) + ' MB)').join('<br>');
        }

        function uploadFiles() {
            if (!selectedFiles.length) { alert('Select at least one file!'); return; }
            let status = document.getElementById('status');
            let pBar = document.getElementById('progressBar');
            let pFill = document.getElementById('progressFill');

            status.style.color = '#38bdf8';
            status.innerText = 'Uploading...';
            pBar.style.display = 'block';

            let formData = new FormData();
            selectedFiles.forEach(f => formData.append('files', f));

            let xhr = new XMLHttpRequest();
            xhr.open('POST', '/upload', true);

            xhr.upload.onprogress = function(e) {
                if (e.lengthComputable) {
                    let percent = (e.loaded / e.total) * 100;
                    pFill.style.width = percent + '%';
                }
            };

            xhr.onload = function() {
                if (xhr.status == 200) {
                    status.style.color = '#4ade80';
                    status.innerText = '✅ Upload Successful! Files saved to Desktop.';
                    selectedFiles = [];
                    document.getElementById('fileInfo').style.display = 'none';
                    setTimeout(() => { pBar.style.display = 'none'; pFill.style.width = '0%'; }, 2000);
                } else {
                    status.style.color = '#f87171';
                    status.innerText = '❌ Upload Failed!';
                }
            };

            xhr.send(formData);
        }
    </script>
</body>
</html>'''
        self.wfile.write(html.encode('utf-8'))

    def do_POST(self):
        if self.path == '/upload':
            length = int(self.headers.get('Content-Length', 0))
            body = self.rfile.read(length)
            content_type = self.headers.get('Content-Type', '')
            
            boundary = content_type.split('boundary=')[-1].encode()
            parts = body.split(b'--' + boundary)
            
            for part in parts:
                if b'filename="' in part:
                    match = re.search(r'filename="([^"]+)"', part.decode('utf-8', errors='ignore'))
                    if match:
                        filename = os.path.basename(match.group(1))
                        header_end = part.find(b'\r\n\r\n')
                        if header_end != -1:
                            file_data = part[header_end + 4:].rstrip(b'\r\n')
                            filepath = os.path.join(DEST_DIR, filename)
                            with open(filepath, 'wb') as f:
                                f.write(file_data)
                            os.chmod(filepath, 0o777)
            
            self.send_response(200)
            self.end_headers()
            self.wfile.write(b"OK")

def run():
    server = HTTPServer(('0.0.0.0', PORT), UploadHandler)
    server.serve_forever()

if __name__ == '__main__':
    run()
PYEOF
chmod +x /usr/local/bin/heaven-uploader.py

# Start uploader daemon in background
if ! pgrep -f "heaven-uploader.py" > /dev/null; then
    python3 /usr/local/bin/heaven-uploader.py &
fi

# ====================================================================
#  DESKTOP SHORTCUTS (Full HeavenOS App Suite)
# ====================================================================

cat > "$DESKTOP_DIR/Upload Files.desktop" << 'EOF'
[Desktop Entry]
Version=1.0
Type=Application
Name=Upload Files
Comment=Drag & Drop File Upload Portal
Exec=google-chrome-stable --no-sandbox http://localhost:8889
Icon=folder-download
Terminal=false
Categories=Utility;FileTransfer;
StartupNotify=true
EOF
chmod +x "$DESKTOP_DIR/Upload Files.desktop"

cat > "$DESKTOP_DIR/Chrome.desktop" << 'EOF'
[Desktop Entry]
Version=1.0
Type=Application
Name=Google Chrome
Comment=Web Browser
Exec=google-chrome-stable --no-sandbox %U
Icon=google-chrome
Terminal=false
Categories=Network;WebBrowser;
StartupNotify=true
EOF
chmod +x "$DESKTOP_DIR/Chrome.desktop"

cat > "$DESKTOP_DIR/Discord.desktop" << 'EOF'
[Desktop Entry]
Version=1.0
Type=Application
Name=Discord
Comment=Chat & Voice
Exec=discord --no-sandbox
Icon=discord
Terminal=false
Categories=Network;InstantMessaging;
StartupNotify=true
EOF
chmod +x "$DESKTOP_DIR/Discord.desktop"

cat > "$DESKTOP_DIR/VSCode.desktop" << 'EOF'
[Desktop Entry]
Version=1.0
Type=Application
Name=VS Code
Comment=Visual Studio Code
Exec=code --no-sandbox
Icon=vscode
Terminal=false
Categories=Development;IDE;
StartupNotify=true
EOF
chmod +x "$DESKTOP_DIR/VSCode.desktop"

# ====================================================================
#  DAVINCI RESOLVE AUTO-INSTALLER & NATIVE APP LAUNCHER SCRIPT
# ====================================================================
cat > /usr/local/bin/install-davinci.py << 'PYEOF'
import os
import sys
import json
import urllib.request
import subprocess

print("=========================================================")
print("  HeavenOS - Automated DaVinci Resolve Installer App")
print("=========================================================")

# 1. Check for local uploaded installer package on Desktop first
local_pkg = None
for f in os.listdir("/config/Desktop"):
    if "DaVinci" in f and (f.endswith(".run") or f.endswith(".zip")):
        local_pkg = os.path.join("/config/Desktop", f)
        print(f"[HeavenOS] Detected local package on Desktop: {local_pkg}")
        break

if local_pkg:
    if local_pkg.endswith(".zip"):
        print("[HeavenOS] Extracting uploaded .zip archive...")
        os.makedirs("/tmp/davinci", exist_ok=True)
        subprocess.run(["unzip", "-o", local_pkg, "-d", "/tmp/davinci"], check=True)
        for file in os.listdir("/tmp/davinci"):
            if file.endswith(".run"):
                run_file = os.path.join("/tmp/davinci", file)
                break
    else:
        run_file = local_pkg

    if run_file and os.path.exists(run_file):
        os.chmod(run_file, 0o755)
        print("[HeavenOS] Installing DaVinci Resolve App into /opt/resolve...")
        env = os.environ.copy()
        env["SKIP_PACKAGE_CHECK"] = "1"
        subprocess.run([run_file, "-i", "-y"], env=env, check=False)
        print("[HeavenOS] Installation complete!")
        sys.exit(0)

# 2. Automated Blackmagic API download
headers = {
    'User-Agent': 'Mozilla/5.0 (X11; Linux x86_64; rv:119.0) Gecko/20100101 Firefox/119.0',
    'Accept': 'application/json, text/plain, */*',
    'Content-Type': 'application/json',
    'Referer': 'https://www.blackmagicdesign.com/support/',
    'Origin': 'https://www.blackmagicdesign.com'
}

download_id = None

try:
    print("[HeavenOS] Fetching Linux release ID from Blackmagic API...")
    req = urllib.request.Request("https://www.blackmagicdesign.com/api/support/us/downloads", headers=headers)
    with urllib.request.urlopen(req) as resp:
        data = json.loads(resp.read().decode('utf-8'))
        for item in data.get('downloads', []):
            urls = item.get('urls', {})
            if 'linux' in urls:
                for l_item in urls['linux']:
                    title = l_item.get('downloadTitle', '') or item.get('name', '')
                    if 'DaVinci Resolve' in title and 'Studio' not in title:
                        download_id = l_item.get('downloadId') or item.get('downloadId')
                        print(f"[HeavenOS] Found Linux release: {title} (ID: {download_id})")
                        break
                if download_id:
                    break
except Exception as e:
    print(f"[HeavenOS] API query note: {e}")

if not download_id:
    print("[HeavenOS] ERROR: Could not find valid DaVinci Resolve release ID.")
    print("[HeavenOS] TIP: You can upload 'DaVinci_Resolve_*_Linux.run' or '.zip' using 'Upload Files' icon on Desktop!")
    sys.exit(1)

payload = json.dumps({
    "firstname": "HeavenOS",
    "lastname": "User",
    "email": "user@heavenos.app",
    "phone": "5555555555",
    "city": "New York",
    "state": "NY",
    "country": "us",
    "streetAddress": "123 Main Street",
    "zip": "10001",
    "hasAgreedToTerms": True,
    "product": "DaVinci Resolve"
}).encode('utf-8')

url = f"https://www.blackmagicdesign.com/api/register/us/download/{download_id}"
req = urllib.request.Request(url, data=payload, headers=headers, method='POST')

download_url = None
try:
    with urllib.request.urlopen(req) as resp:
        raw_resp = resp.read().decode('utf-8').strip()
        try:
            parsed = json.loads(raw_resp)
            if isinstance(parsed, dict):
                download_url = parsed.get("url") or parsed.get("downloadUrl") or parsed.get("link")
            elif isinstance(parsed, str):
                download_url = parsed
        except Exception:
            download_url = raw_resp.strip('"')
except Exception as e:
    print(f"[HeavenOS] Registration API Note: {e}")

if not download_url or not download_url.startswith("http"):
    print("[HeavenOS] ERROR: Registration API did not return download URL.")
    sys.exit(1)

print(f"[HeavenOS] Downloading DaVinci Resolve setup package...")
zip_path = "/tmp/DaVinci_Resolve.zip"
if os.path.exists(zip_path):
    os.remove(zip_path)

subprocess.run(["wget", "--user-agent=Mozilla/5.0", "--progress=bar:force", "-O", zip_path, download_url], check=True)

print("[HeavenOS] Unpacking setup files (this may take 1-2 mins)...")
os.makedirs("/tmp/davinci", exist_ok=True)
subprocess.run(["unzip", "-o", zip_path, "-d", "/tmp/davinci"], check=True)

run_file = None
for f in os.listdir("/tmp/davinci"):
    if f.endswith(".run"):
        run_file = os.path.join("/tmp/davinci", f)
        break

if not run_file:
    print("[HeavenOS] Error: .run installer file not found!")
    sys.exit(1)

os.chmod(run_file, 0o755)

print("[HeavenOS] Installing DaVinci Resolve App into /opt/resolve...")
env = os.environ.copy()
env["SKIP_PACKAGE_CHECK"] = "1"
subprocess.run([run_file, "-i", "-y"], env=env, check=False)

print("=========================================================")
print("  DaVinci Resolve App Successfully Installed!")
print("=========================================================")
PYEOF
chmod +x /usr/local/bin/install-davinci.py


cat > /usr/local/bin/launch-davinci.sh << 'EOF'
#!/bin/bash
if [ -f "/opt/resolve/bin/resolve" ]; then
    export LD_PRELOAD=/usr/lib/x86_64-linux-gnu/libglib-2.0.so.0
    export MESA_GL_VERSION_OVERRIDE=4.5
    /opt/resolve/bin/resolve "$@"
else
    zenity --info --title="HeavenOS - DaVinci Resolve" --text="Downloading & Installing DaVinci Resolve App inside HeavenOS...\n\nPlease wait a few minutes while the installer completes." &
    xfce4-terminal --title="Installing DaVinci Resolve..." --command="bash -c 'python3 /usr/local/bin/install-davinci.py; if [ -f /opt/resolve/bin/resolve ]; then echo Starting DaVinci Resolve...; sleep 2; export LD_PRELOAD=/usr/lib/x86_64-linux-gnu/libglib-2.0.so.0; export MESA_GL_VERSION_OVERRIDE=4.5; /opt/resolve/bin/resolve; else echo Check log above. Press enter to exit; read; fi'" &
fi
EOF
chmod +x /usr/local/bin/launch-davinci.sh



cat > "$DESKTOP_DIR/DaVinci Resolve.desktop" << 'EOF'
[Desktop Entry]
Version=1.0
Type=Application
Name=DaVinci Resolve
Comment=Professional Video Editing & Color Correction
Exec=/usr/local/bin/launch-davinci.sh
Icon=video-display
Terminal=false
Categories=AudioVideo;Video;VideoEditing;
StartupNotify=true
EOF
chmod +x "$DESKTOP_DIR/DaVinci Resolve.desktop"

cat > "$DESKTOP_DIR/Blender.desktop" << 'EOF'
[Desktop Entry]
Version=1.0
Type=Application
Name=Blender
Comment=3D Creation Suite
Exec=blender
Icon=blender
Terminal=false
Categories=Graphics;3DGraphics;
StartupNotify=true
EOF
chmod +x "$DESKTOP_DIR/Blender.desktop"

cat > "$DESKTOP_DIR/GIMP.desktop" << 'EOF'
[Desktop Entry]
Version=1.0
Type=Application
Name=GIMP
Comment=Image Editor
Exec=gimp
Icon=gimp
Terminal=false
Categories=Graphics;2DGraphics;
StartupNotify=true
EOF
chmod +x "$DESKTOP_DIR/GIMP.desktop"

cat > "$DESKTOP_DIR/Audacity.desktop" << 'EOF'
[Desktop Entry]
Version=1.0
Type=Application
Name=Audacity
Comment=Audio Editor
Exec=audacity
Icon=audacity
Terminal=false
Categories=AudioVideo;Audio;
StartupNotify=true
EOF
chmod +x "$DESKTOP_DIR/Audacity.desktop"

cat > "$DESKTOP_DIR/VLC.desktop" << 'EOF'
[Desktop Entry]
Version=1.0
Type=Application
Name=VLC Player
Comment=Media Player
Exec=vlc
Icon=vlc
Terminal=false
Categories=AudioVideo;Player;
StartupNotify=true
EOF
chmod +x "$DESKTOP_DIR/VLC.desktop"

cat > "$DESKTOP_DIR/FileZilla.desktop" << 'EOF'
[Desktop Entry]
Version=1.0
Type=Application
Name=FileZilla
Comment=FTP Client
Exec=filezilla
Icon=filezilla
Terminal=false
Categories=Network;FileTransfer;
StartupNotify=true
EOF
chmod +x "$DESKTOP_DIR/FileZilla.desktop"

cat > "$DESKTOP_DIR/Files.desktop" << 'EOF'
[Desktop Entry]
Version=1.0
Type=Application
Name=File Manager
Comment=Browse your files
Exec=thunar
Icon=system-file-manager
Terminal=false
Categories=Utility;FileManager;
StartupNotify=true
EOF
chmod +x "$DESKTOP_DIR/Files.desktop"

cat > "$DESKTOP_DIR/Terminal.desktop" << 'EOF'
[Desktop Entry]
Version=1.0
Type=Application
Name=Terminal
Comment=Open Terminal
Exec=xfce4-terminal
Icon=utilities-terminal
Terminal=false
Categories=System;TerminalEmulator;
StartupNotify=true
EOF
chmod +x "$DESKTOP_DIR/Terminal.desktop"

# ====================================================================
#  PLANK DOCK LAUNCHERS (macOS Dock)
# ====================================================================
cat > "$PLANK_DIR/UploadFiles.dockitem" << 'EOF'
[PlankDockItemPreferences]
Launcher=file:///config/Desktop/Upload Files.desktop
EOF

cat > "$PLANK_DIR/Chrome.dockitem" << 'EOF'
[PlankDockItemPreferences]
Launcher=file:///config/Desktop/Chrome.desktop
EOF

cat > "$PLANK_DIR/Discord.dockitem" << 'EOF'
[PlankDockItemPreferences]
Launcher=file:///config/Desktop/Discord.desktop
EOF

cat > "$PLANK_DIR/VSCode.dockitem" << 'EOF'
[PlankDockItemPreferences]
Launcher=file:///config/Desktop/VSCode.desktop
EOF

cat > "$PLANK_DIR/DaVinciResolve.dockitem" << 'EOF'
[PlankDockItemPreferences]
Launcher=file:///config/Desktop/DaVinci Resolve.desktop
EOF

cat > "$PLANK_DIR/Blender.dockitem" << 'EOF'
[PlankDockItemPreferences]
Launcher=file:///config/Desktop/Blender.desktop
EOF

cat > "$PLANK_DIR/GIMP.dockitem" << 'EOF'
[PlankDockItemPreferences]
Launcher=file:///config/Desktop/GIMP.desktop
EOF

cat > "$PLANK_DIR/Files.dockitem" << 'EOF'
[PlankDockItemPreferences]
Launcher=file:///config/Desktop/Files.desktop
EOF

cat > "$PLANK_DIR/Terminal.dockitem" << 'EOF'
[PlankDockItemPreferences]
Launcher=file:///config/Desktop/Terminal.desktop
EOF


# ====================================================================
#  macOS SONOMA UI CONFIGURATION (WhiteSur GTK & Icons + Traffic Lights)
# ====================================================================

# ---- XFCE Settings (GTK, Icon, Cursor, Traffic Light Buttons) ------
cat > "$CONFIG_DIR/xsettings.xml" << 'XSETEOF'
<?xml version="1.0" encoding="UTF-8"?>
<channel name="xsettings" version="1.0">
  <property name="Net" type="empty">
    <property name="ThemeName" type="string" value="WhiteSur-Dark"/>
    <property name="IconThemeName" type="string" value="WhiteSur"/>
    <property name="CursorThemeName" type="string" value="WhiteSur-cursors"/>
    <property name="EnableEventSounds" type="bool" value="false"/>
    <property name="EnableInputFeedbackSounds" type="bool" value="false"/>
  </property>
  <property name="Gtk" type="empty">
    <property name="FontName" type="string" value="Ubuntu 10"/>
    <property name="MonospaceFontName" type="string" value="Monospace 10"/>
    <property name="CursorThemeName" type="string" value="WhiteSur-cursors"/>
    <property name="DecorationLayout" type="string" value="close,minimize,maximize:"/>
  </property>
</channel>
XSETEOF

# ---- 60 FPS PERFORMANCE & KASMVNC ENCODER TUNING ------------------
for conf in /etc/kasmvnc/kasmvnc.yaml /config/.vnc/kasmvnc.yaml /config/.kasmdock/kasmvnc.yaml; do
    if [ -f "$conf" ]; then
        sed -i 's/max_frame_rate: [0-9]*/max_frame_rate: 60/g' "$conf" 2>/dev/null || true
        sed -i 's/frame_rate: [0-9]*/frame_rate: 60/g' "$conf" 2>/dev/null || true
    fi
done

# ---- XFWM4 Window Manager (macOS Traffic Lights + 60 FPS VSync) ---
cat > "$CONFIG_DIR/xfwm4.xml" << 'WMEOF'
<?xml version="1.0" encoding="UTF-8"?>
<channel name="xfwm4" version="1.0">
  <property name="general" type="empty">
    <property name="theme" type="string" value="WhiteSur-Dark"/>
    <property name="button_layout" type="string" value="CMH|"/>
    <property name="title_alignment" type="string" value="center"/>
    <property name="title_font" type="string" value="Ubuntu Bold 10"/>
    <property name="use_compositing" type="bool" value="true"/>
    <property name="unredirect_overlays" type="bool" value="true"/>
    <property name="vblank_mode" type="string" value="off"/>
    <property name="box_resize" type="bool" value="true"/>
    <property name="box_move" type="bool" value="true"/>
  </property>
</channel>
WMEOF

# ---- REMOVE ALL XFCE PANELS (Keep only macOS Plank Dock at bottom) --
rm -f "$CONFIG_DIR/xfce4-panel.xml"
cat > "$CONFIG_DIR/xfce4-panel.xml" << 'PANELXML'
<?xml version="1.0" encoding="UTF-8"?>
<channel name="xfce4-panel" version="1.0">
  <property name="configver" type="int" value="2"/>
  <property name="panels" type="array"/>
</channel>
PANELXML

# ---- GTK3 CSS Override (macOS Translucent Top Bar & No White Box) ---
mkdir -p /config/.config/gtk-3.0
cat > /config/.config/gtk-3.0/gtk.css << 'CSSEOF'
/* macOS Sonoma Top Bar Translucent Styling */
.xfce4-panel,
panel-window {
    background-color: rgba(15, 23, 42, 0.85) !important;
    color: #f8fafc !important;
    border-bottom: 1px solid rgba(255, 255, 255, 0.1) !important;
}

/* Remove white background box from top-left button & all panel buttons */
.xfce4-panel button,
.xfce4-panel button:hover,
.xfce4-panel button:checked,
.xfce4-panel button:active,
#applicationsmenu-button,
#whiskermenu-button,
.xfce4-panel .flat {
    background: transparent !important;
    background-color: transparent !important;
    border: none !important;
    box-shadow: none !important;
    color: #f8fafc !important;
}
CSSEOF

# ---- PERMANENT XFCE DESKTOP XML CONFIG -----------------------------
chattr -i "$CONFIG_DIR/xfce4-desktop.xml" 2>/dev/null || true
cat > "$CONFIG_DIR/xfce4-desktop.xml" << XMLEOF
<?xml version="1.0" encoding="UTF-8"?>
<channel name="xfce4-desktop" version="1.0">
  <property name="backdrop" type="empty">
    <property name="screen0" type="empty">
      <property name="monitor0" type="empty">
        <property name="workspace0" type="empty">
          <property name="color-style" type="int" value="0"/>
          <property name="image-style" type="int" value="5"/>
          <property name="last-image" type="string" value="$WALLPAPER"/>
        </property>
      </property>
      <property name="monitor1" type="empty">
        <property name="workspace0" type="empty">
          <property name="color-style" type="int" value="0"/>
          <property name="image-style" type="int" value="5"/>
          <property name="last-image" type="string" value="$WALLPAPER"/>
        </property>
      </property>
      <property name="monitorVNC-0" type="empty">
        <property name="workspace0" type="empty">
          <property name="color-style" type="int" value="0"/>
          <property name="image-style" type="int" value="5"/>
          <property name="last-image" type="string" value="$WALLPAPER"/>
        </property>
      </property>
    </property>
  </property>
</channel>
XMLEOF

# ---- Ownership fix -----------------------------------------------
chown -R abc:abc /config/ 2>/dev/null || true
chown abc:abc /usr/local/bin/apply-lotus-wallpaper.sh
chown abc:abc /usr/local/bin/heaven-uploader.py
chown abc:abc /usr/local/bin/launch-davinci.sh
chown abc:abc /usr/local/bin/install-davinci.py

echo "[HeavenOS] macOS Sonoma UI + WhiteSur Theme + Plank Dock Registered!"
