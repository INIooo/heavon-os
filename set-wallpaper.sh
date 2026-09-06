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

# ---- KasmVNC WebSocket Origin Checks Override (Fixes WebSocket Disconnect) ---
find /etc/kasmvnc /defaults /config -name "*.yaml" -o -name "*.yml" 2>/dev/null | while read -r yfile; do
    if [ -f "$yfile" ]; then
        sed -i 's/check_origin: true/check_origin: false/g' "$yfile" 2>/dev/null || true
        sed -i 's/filter_same_origin: true/filter_same_origin: false/g' "$yfile" 2>/dev/null || true
    fi
done

# ---- Custom Web Title & Favicon Branding Overrides -----------------
cat > /usr/local/bin/heaven-branding.py << 'PYEOF'
import glob, os, re

title = os.getenv('TITLE', 'HeavenOS Cloud Workstation ☁️')
favicon_tag = '<link rel="icon" type="image/svg+xml" href="/favicon.svg"><link rel="shortcut icon" href="/favicon.svg">'

svg_content = '''<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 100 100">
  <rect width="100" height="100" rx="25" fill="#0f172a"/>
  <text x="50" y="68" font-size="60" text-anchor="middle">☁️</text>
</svg>'''

for d in ['/usr/share/kasmvnc/www', '/defaults']:
    if os.path.exists(d):
        try:
            with open(os.path.join(d, 'favicon.svg'), 'w', encoding='utf-8') as f:
                f.write(svg_content)
            with open(os.path.join(d, 'favicon.ico'), 'w', encoding='utf-8') as f:
                f.write(svg_content)
            with open(os.path.join(d, 'favicon.png'), 'w', encoding='utf-8') as f:
                f.write(svg_content)
        except Exception:
            pass

for root_dir in ['/usr/share/kasmvnc/www', '/defaults']:
    if not os.path.exists(root_dir): continue
    for filepath in glob.glob(root_dir + '/**/*.html', recursive=True):
        try:
            with open(filepath, 'r', encoding='utf-8', errors='ignore') as f:
                content = f.read()
            content = re.sub(r'<title>.*?</title>', f'<title>{title}</title>', content, flags=re.IGNORECASE)
            if '</head>' in content and 'favicon.svg' not in content:
                content = content.replace('</head>', f'{favicon_tag}</head>')
            with open(filepath, 'w', encoding='utf-8') as f:
                f.write(content)
        except Exception:
            pass
PYEOF
python3 /usr/local/bin/heaven-branding.py 2>/dev/null || true

# ---- PulseAudio Auto-start for Audio Streaming --------------------
if ! pgrep -x "pulseaudio" > /dev/null; then
    pulseaudio --start --exit-idle-time=-1 2>/dev/null || true
fi

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
#  HEAVENOS BIDIRECTIONAL FILE PORTAL (Upload & Download Server)
# ====================================================================
cat > /usr/local/bin/heaven-file-portal.py << 'PYEOF'
import os
import re
import urllib.parse
import mimetypes
from http.server import HTTPServer, BaseHTTPRequestHandler

PORT = 8889
DEST_DIR = "/config/Desktop"
os.makedirs(DEST_DIR, exist_ok=True)

class PortalHandler(BaseHTTPRequestHandler):
    def do_GET(self):
        parsed = urllib.parse.urlparse(self.path)
        path = parsed.path
        query = urllib.parse.parse_qs(parsed.query)

        # Handle File Download
        if path == '/download':
            file_name = query.get('file', [''])[0]
            file_name = os.path.basename(file_name)
            file_path = os.path.join(DEST_DIR, file_name)
            if file_name and os.path.isfile(file_path):
                self.send_response(200)
                mime, _ = mimetypes.guess_type(file_path)
                self.send_header('Content-Type', mime or 'application/octet-stream')
                self.send_header('Content-Disposition', f'attachment; filename="{file_name}"')
                self.send_header('Content-Length', str(os.path.getsize(file_path)))
                self.end_headers()
                with open(file_path, 'rb') as f:
                    self.wfile.write(f.read())
                return
            else:
                self.send_error(404, "File Not Found")
                return

        # Main Web Portal Page
        self.send_response(200)
        self.send_header('Content-type', 'text/html; charset=utf-8')
        self.end_headers()

        # Build File List HTML
        file_items = []
        if os.path.exists(DEST_DIR):
            for item in sorted(os.listdir(DEST_DIR)):
                full_p = os.path.join(DEST_DIR, item)
                if os.path.isfile(full_p) and not item.endswith('.desktop'):
                    size_mb = os.path.getsize(full_p) / (1024 * 1024)
                    size_str = f"{size_mb:.2f} MB" if size_mb >= 1 else f"{os.path.getsize(full_p)/1024:.1f} KB"
                    safe_name = urllib.parse.quote(item)
                    file_items.append(f'''
                    <div class="file-row">
                        <div class="file-name">📄 {item} <span class="file-size">({size_str})</span></div>
                        <div class="file-actions">
                            <a class="dl-btn" href="/download?file={safe_name}" download>📥 Download</a>
                            <button class="del-btn" onclick="deleteFile('{safe_name}')">🗑️</button>
                        </div>
                    </div>''')

        file_list_html = ''.join(file_items) if file_items else '<div class="empty">No uploaded files yet on Desktop</div>'

        html = f'''<!DOCTYPE html>
<html>
<head>
    <title>HeavenOS File Portal ☁️</title>
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <style>
        * {{ box-sizing: border-box; }}
        body {{ font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, sans-serif; background: #0b0f19; color: #e2e8f0; margin:0; padding: 25px; display:flex; justify-content:center; align-items:center; min-height:100vh; }}
        .card {{ background: #161e2e; border: 1px solid #2d3748; padding: 30px; border-radius: 18px; width: 100%; max-width: 620px; box-shadow: 0 25px 40px rgba(0,0,0,0.6); }}
        .header {{ text-align: center; margin-bottom: 25px; }}
        .icon {{ font-size: 42px; display:block; margin-bottom: 5px; }}
        h2 {{ color: #38bdf8; font-size: 24px; margin: 0 0 6px 0; }}
        p {{ color: #94a3b8; font-size: 14px; margin: 0; }}
        .section-title {{ font-size: 14px; font-weight: 700; color: #7dd3fc; margin: 25px 0 10px 0; text-transform: uppercase; letter-spacing: 0.5px; }}
        .drop-area {{ border: 2px dashed #38bdf8; background: rgba(56, 189, 248, 0.05); border-radius: 14px; padding: 30px 20px; text-align: center; cursor: pointer; transition: 0.3s; }}
        .drop-area:hover, .drop-area.highlight {{ background: rgba(56, 189, 248, 0.15); border-color: #7dd3fc; }}
        input[type="file"] {{ display: none; }}
        .btn {{ background: linear-gradient(135deg, #0284c7, #2563eb); color: white; border: none; padding: 12px 26px; border-radius: 8px; font-size: 15px; font-weight: 600; cursor: pointer; margin-top: 15px; width: 100%; transition: 0.2s; box-shadow: 0 4px 12px rgba(2,132,199,0.3); }}
        .btn:hover {{ opacity: 0.95; transform: translateY(-1px); }}
        #status {{ margin-top: 15px; font-size: 14px; font-weight: 600; text-align: center; }}
        .progress-bar {{ width: 100%; background: #1e293b; height: 8px; border-radius: 4px; overflow: hidden; margin-top: 12px; display: none; }}
        .progress-fill {{ height: 100%; background: #38bdf8; width: 0%; transition: width 0.1s; }}
        .file-info {{ margin-top: 12px; font-size: 13px; color: #a0aec0; text-align: left; background: #0f172a; padding: 10px; border-radius: 6px; display: none; }}
        .file-list {{ background: #0f172a; border: 1px solid #1e293b; border-radius: 12px; overflow: hidden; max-height: 250px; overflow-y: auto; }}
        .file-row {{ display: flex; justify-content: space-between; align-items: center; padding: 12px 16px; border-bottom: 1px solid #1e293b; }}
        .file-row:last-child {{ border-bottom: none; }}
        .file-name {{ font-size: 14px; color: #f1f5f9; overflow: hidden; text-overflow: ellipsis; white-space: nowrap; max-width: 350px; }}
        .file-size {{ font-size: 12px; color: #64748b; margin-left: 6px; }}
        .file-actions {{ display: flex; gap: 8px; align-items: center; }}
        .dl-btn {{ background: rgba(56, 189, 248, 0.15); color: #38bdf8; text-decoration: none; padding: 6px 12px; border-radius: 6px; font-size: 13px; font-weight: 600; transition: 0.2s; border: 1px solid rgba(56, 189, 248, 0.3); }}
        .dl-btn:hover {{ background: #0284c7; color: white; }}
        .del-btn {{ background: transparent; color: #ef4444; border: none; font-size: 15px; cursor: pointer; padding: 4px 8px; border-radius: 4px; transition: 0.2s; }}
        .del-btn:hover {{ background: rgba(239, 68, 68, 0.2); }}
        .empty {{ padding: 20px; text-align: center; color: #64748b; font-size: 14px; }}
    </style>
</head>
<body>
    <div class="card">
        <div class="header">
            <span class="icon">☁️</span>
            <h2>HeavenOS File Portal</h2>
            <p>Bidirectional File Transfer (Local PC ↔ Cloud PC)</p>
        </div>

        <div class="section-title">📤 Upload Files to Cloud PC</div>
        <div class="drop-area" id="dropArea" onclick="document.getElementById('fileInput').click()">
            📁 <br><b>Click to Choose Files</b> or Drag & Drop here
            <input type="file" id="fileInput" multiple onchange="handleFiles(this.files)">
        </div>

        <div class="file-info" id="fileInfo"></div>
        <div class="progress-bar" id="progressBar"><div class="progress-fill" id="progressFill"></div></div>
        <button class="btn" onclick="uploadFiles()">Upload to Cloud Desktop</button>
        <div id="status"></div>

        <div class="section-title">📥 Cloud PC Files (Click to Download)</div>
        <div class="file-list">
            {file_list_html}
        </div>
    </div>

    <script>
        let selectedFiles = [];
        const dropArea = document.getElementById('dropArea');

        ['dragenter', 'dragover', 'dragleave', 'drop'].forEach(e => dropArea.addEventListener(e, pDef, false));
        function pDef(e) {{ e.preventDefault(); e.stopPropagation(); }}
        ['dragenter', 'dragover'].forEach(e => dropArea.classList.add('highlight'));
        ['dragleave', 'drop'].forEach(e => dropArea.classList.remove('highlight'));

        dropArea.addEventListener('drop', (e) => handleFiles(e.dataTransfer.files));

        function handleFiles(files) {{
            selectedFiles = Array.from(files);
            let info = document.getElementById('fileInfo');
            info.style.display = 'block';
            info.innerHTML = '<b>Selected Files:</b><br>' + selectedFiles.map(f => '• ' + f.name + ' (' + (f.size/1024/1024).toFixed(2) + ' MB)').join('<br>');
        }}

        function uploadFiles() {{
            if (!selectedFiles.length) {{ alert('Select at least one file!'); return; }}
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

            xhr.upload.onprogress = function(e) {{
                if (e.lengthComputable) {{
                    let percent = (e.loaded / e.total) * 100;
                    pFill.style.width = percent + '%';
                }}
            }};

            xhr.onload = function() {{
                if (xhr.status == 200) {{
                    status.style.color = '#4ade80';
                    status.innerText = '✅ Upload Successful!';
                    setTimeout(() => location.reload(), 1000);
                }} else {{
                    status.style.color = '#f87171';
                    status.innerText = '❌ Upload Failed!';
                }}
            }};

            xhr.send(formData);
        }}

        function deleteFile(fileName) {{
            if (confirm('Delete ' + decodeURIComponent(fileName) + ' from Desktop?')) {{
                fetch('/delete?file=' + fileName, {{ method: 'POST' }})
                    .then(() => location.reload());
            }}
        }}
    </script>
</body>
</html>'''
        self.wfile.write(html.encode('utf-8'))

    def do_POST(self):
        parsed = urllib.parse.urlparse(self.path)
        path = parsed.path
        query = urllib.parse.parse_qs(parsed.query)

        if path == '/delete':
            file_name = query.get('file', [''])[0]
            file_name = os.path.basename(file_name)
            file_path = os.path.join(DEST_DIR, file_name)
            if file_name and os.path.isfile(file_path):
                os.remove(file_path)
            self.send_response(200)
            self.end_headers()
            self.wfile.write(b"OK")
            return

        if path == '/upload':
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
    server = HTTPServer(('0.0.0.0', PORT), PortalHandler)
    server.serve_forever()

if __name__ == '__main__':
    run()
PYEOF
chmod +x /usr/local/bin/heaven-file-portal.py

# Start file portal daemon in background
if ! pgrep -f "heaven-file-portal.py" > /dev/null; then
    python3 /usr/local/bin/heaven-file-portal.py &
fi

# ====================================================================
#  HEAVENOS SPEEDTEST UTILITY SCRIPT
# ====================================================================
cat > /usr/local/bin/heaven-speedtest.sh << 'EOF'
#!/bin/bash
clear
echo "======================================================================"
echo "         ⚡ HEAVENOS CLOUD WORKSTATION SPEEDTEST ⚡"
echo "======================================================================"
echo ""
echo "[→] Testing Cloud PC Network Connection & Bandwidth..."
echo ""
if command -v speedtest-cli &>/dev/null; then
    speedtest-cli --simple
elif command -v speedtest &>/dev/null; then
    speedtest --simple
else
    echo "Running quick speed check via curl..."
    curl -s https://raw.githubusercontent.com/sivel/speedtest-cli/master/speedtest.py | python3 - --simple
fi
echo ""
echo "======================================================================"
echo "  [✓] HeavenOS Cloud Network Status: Ultra High-Speed Verified 🚀"
echo "======================================================================"
echo ""
read -p "Press [Enter] to exit..."
EOF
chmod +x /usr/local/bin/heaven-speedtest.sh

# ====================================================================
#  DESKTOP SHORTCUTS (Full HeavenOS App Suite)
# ====================================================================
rm -f "$DESKTOP_DIR/Upload Files.desktop" 2>/dev/null || true

cat > "$DESKTOP_DIR/File Portal.desktop" << 'EOF'
[Desktop Entry]
Version=1.0
Type=Application
Name=File Portal
Comment=Upload & Download Files (Local PC ↔ Cloud PC)
Exec=google-chrome-stable --no-sandbox http://localhost:8889
Icon=folder-download
Terminal=false
Categories=Utility;FileTransfer;
StartupNotify=true
EOF
chmod +x "$DESKTOP_DIR/File Portal.desktop"

cat > "$DESKTOP_DIR/Speedtest.desktop" << 'EOF'
[Desktop Entry]
Version=1.0
Type=Application
Name=Speedtest
Comment=Test High-Speed Cloud Internet Connection
Exec=xfce4-terminal -e "bash /usr/local/bin/heaven-speedtest.sh"
Icon=network-workgroup
Terminal=false
Categories=Network;Utility;
StartupNotify=true
EOF
chmod +x "$DESKTOP_DIR/Speedtest.desktop"

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
cat > "$PLANK_DIR/FilePortal.dockitem" << 'EOF'
[PlankDockItemPreferences]
Launcher=file:///config/Desktop/File Portal.desktop
EOF

cat > "$PLANK_DIR/Speedtest.dockitem" << 'EOF'
[PlankDockItemPreferences]
Launcher=file:///config/Desktop/Speedtest.desktop
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

# ---- XFWM4 Window Manager (macOS Traffic Light Buttons on Left) ----
cat > "$CONFIG_DIR/xfwm4.xml" << 'WMEOF'
<?xml version="1.0" encoding="UTF-8"?>
<channel name="xfwm4" version="1.0">
  <property name="general" type="empty">
    <property name="theme" type="string" value="WhiteSur-Dark"/>
    <property name="button_layout" type="string" value="CMH|"/>
    <property name="title_alignment" type="string" value="center"/>
    <property name="title_font" type="string" value="Ubuntu Bold 10"/>
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
chown abc:abc /usr/local/bin/heaven-file-portal.py 2>/dev/null || true
chown abc:abc /usr/local/bin/heaven-speedtest.sh 2>/dev/null || true

echo "[HeavenOS] macOS Sonoma UI + WhiteSur Theme + Plank Dock Registered!"
