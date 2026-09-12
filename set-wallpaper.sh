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
mkdir -p /usr/share/backgrounds/xfce /usr/share/xfce4/backdrops /defaults
find /usr/share/backgrounds/ -type f ! -name "lotus.png" -delete 2>/dev/null || true
find /usr/share/wallpapers/ -type f -delete 2>/dev/null || true
find /usr/share/images/ -type f -delete 2>/dev/null || true
find /usr/share/xfce4/ -name "*.png" -o -name "*.jpg" -o -name "*.jpeg" -o -name "*.svg" ! -name "lotus.png" -delete 2>/dev/null || true

cp -f /lotus-wallpaper.png "$WALLPAPER" 2>/dev/null || true
cp -f /lotus-wallpaper.png /usr/share/backgrounds/xfce/lotus.png 2>/dev/null || true
cp -f /lotus-wallpaper.png /usr/share/xfce4/backdrops/lotus.png 2>/dev/null || true
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

# ---- Startup Notice Autostart (DaVinci Resolve Optimization Note & Credits) ----
cat > "$AUTOSTART_DIR/heaven-notice.desktop" << 'EOF'
[Desktop Entry]
Type=Application
Name=HeavenOS Notice
Exec=zenity --info --title="HeavenOS" --text="Due to lack of optimisation, we couldn't include the following apps that we promised:\n\n1. DaVinci Resolve\n\n----------------------------------------\nCredits: Rohan2core and Prathamesh for programming" --width=450
Hidden=false
NoDisplay=false
X-GNOME-Autostart-enabled=true
EOF

# ---- Ubuntu Sound Theme Startup Sound Autostart ----
cat > "$AUTOSTART_DIR/heaven-sound.desktop" << 'EOF'
[Desktop Entry]
Type=Application
Name=HeavenOS Startup Sound
Exec=bash -c "sleep 1 && (canberra-gtk-play -i desktop-login 2>/dev/null || paplay /usr/share/sounds/ubuntu/stereo/desktop-login.ogg 2>/dev/null || aplay /usr/share/sounds/alsa/Front_Center.wav 2>/dev/null)"
Hidden=false
NoDisplay=false
X-GNOME-Autostart-enabled=true
EOF




# ====================================================================
#  HEAVENOS MODERN CONTROL CENTER & FILE UPLOADER PORTAL (Port 8889)
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
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>HeavenOS - Cloud Control Center & Launchpad</title>
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <link href="https://fonts.googleapis.com/css2?family=Outfit:wght@300;400;500;600;700&display=swap" rel="stylesheet">
    <style>
        :root {
            --bg-color: #060913;
            --glass-bg: rgba(18, 25, 41, 0.72);
            --glass-border: rgba(255, 255, 255, 0.12);
            --glass-hover: rgba(255, 255, 255, 0.18);
            --accent-cyan: #38bdf8;
            --accent-purple: #818cf8;
            --accent-pink: #f472b6;
            --text-primary: #f8fafc;
            --text-secondary: #94a3b8;
        }

        * { box-sizing: border-box; margin: 0; padding: 0; }
        body {
            font-family: 'Outfit', sans-serif;
            background: radial-gradient(circle at 15% 15%, #10192d 0%, #060913 80%);
            color: var(--text-primary);
            min-height: 100vh;
            padding: 30px 20px;
            display: flex;
            justify-content: center;
            align-items: center;
        }

        .container {
            width: 100%;
            max-width: 960px;
            display: flex;
            flex-direction: column;
            gap: 24px;
        }

        /* Glass Panel */
        .glass-card {
            background: var(--glass-bg);
            backdrop-filter: blur(24px);
            -webkit-backdrop-filter: blur(24px);
            border: 1px solid var(--glass-border);
            border-radius: 20px;
            padding: 28px;
            box-shadow: 0 20px 50px rgba(0, 0, 0, 0.5), inset 0 1px 1px rgba(255, 255, 255, 0.1);
        }

        /* Header */
        .header {
            display: flex;
            align-items: center;
            justify-content: space-between;
            flex-wrap: wrap;
            gap: 16px;
        }

        .brand {
            display: flex;
            align-items: center;
            gap: 14px;
        }

        .brand-logo {
            width: 48px;
            height: 48px;
            background: linear-gradient(135deg, var(--accent-cyan), var(--accent-purple));
            border-radius: 14px;
            display: flex;
            align-items: center;
            justify-content: center;
            font-size: 26px;
            box-shadow: 0 0 20px rgba(56, 189, 248, 0.4);
        }

        .brand-info h1 {
            font-size: 22px;
            font-weight: 700;
            letter-spacing: -0.5px;
            background: linear-gradient(90deg, #ffffff, var(--accent-cyan));
            -webkit-background-clip: text;
            -webkit-text-fill-color: transparent;
        }

        .brand-info p {
            font-size: 13px;
            color: var(--text-secondary);
        }

        .badge-status {
            display: flex;
            align-items: center;
            gap: 8px;
            background: rgba(56, 189, 248, 0.1);
            border: 1px solid rgba(56, 189, 248, 0.3);
            padding: 6px 16px;
            border-radius: 30px;
            font-size: 13px;
            color: var(--accent-cyan);
            font-weight: 500;
        }

        .status-dot {
            width: 8px;
            height: 8px;
            background: #34d399;
            border-radius: 50%;
            box-shadow: 0 0 10px #34d399;
            animation: pulse 2s infinite;
        }

        @keyframes pulse {
            0%, 100% { transform: scale(1); opacity: 1; }
            50% { transform: scale(1.3); opacity: 0.6; }
        }

        /* Section Titles */
        .section-title {
            font-size: 16px;
            font-weight: 600;
            color: var(--text-secondary);
            margin-bottom: 16px;
            display: flex;
            align-items: center;
            gap: 8px;
            text-transform: uppercase;
            letter-spacing: 0.8px;
        }

        /* Sound FX Board */
        .sound-grid {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(180px, 1fr));
            gap: 14px;
        }

        .sound-btn {
            background: rgba(255, 255, 255, 0.04);
            border: 1px solid var(--glass-border);
            border-radius: 14px;
            padding: 16px;
            display: flex;
            align-items: center;
            gap: 12px;
            cursor: pointer;
            transition: all 0.25s ease;
            color: var(--text-primary);
        }

        .sound-btn:hover {
            background: rgba(56, 189, 248, 0.12);
            border-color: var(--accent-cyan);
            transform: translateY(-3px);
            box-shadow: 0 8px 20px rgba(56, 189, 248, 0.15);
        }

        .sound-btn .icon { font-size: 22px; }
        .sound-btn .label { font-size: 14px; font-weight: 500; }

        /* Drop Area */
        .drop-zone {
            border: 2px dashed rgba(56, 189, 248, 0.4);
            background: rgba(56, 189, 248, 0.03);
            border-radius: 16px;
            padding: 36px 20px;
            text-align: center;
            cursor: pointer;
            transition: all 0.3s ease;
        }

        .drop-zone:hover, .drop-zone.dragover {
            background: rgba(56, 189, 248, 0.1);
            border-color: var(--accent-cyan);
            transform: scale(1.01);
        }

        .drop-icon { font-size: 42px; margin-bottom: 12px; display: inline-block; }
        .drop-title { font-size: 16px; font-weight: 600; color: var(--text-primary); margin-bottom: 4px; }
        .drop-subtitle { font-size: 13px; color: var(--text-secondary); }

        .btn-upload {
            background: linear-gradient(135deg, var(--accent-cyan), var(--accent-purple));
            color: #ffffff;
            border: none;
            padding: 12px 32px;
            border-radius: 12px;
            font-size: 15px;
            font-weight: 600;
            cursor: pointer;
            margin-top: 18px;
            transition: all 0.25s ease;
            box-shadow: 0 6px 20px rgba(56, 189, 248, 0.3);
        }

        .btn-upload:hover {
            opacity: 0.92;
            transform: translateY(-2px);
            box-shadow: 0 10px 25px rgba(56, 189, 248, 0.4);
        }

        /* File Info & Progress */
        .file-list {
            margin-top: 16px;
            font-size: 13px;
            color: var(--text-secondary);
            text-align: left;
            background: rgba(0, 0, 0, 0.3);
            padding: 12px 16px;
            border-radius: 10px;
            display: none;
        }

        .progress-container {
            width: 100%;
            height: 8px;
            background: rgba(255, 255, 255, 0.1);
            border-radius: 4px;
            overflow: hidden;
            margin-top: 16px;
            display: none;
        }

        .progress-bar {
            height: 100%;
            background: linear-gradient(90deg, var(--accent-cyan), var(--accent-purple));
            width: 0%;
            transition: width 0.2s;
        }

        #statusMsg {
            margin-top: 14px;
            font-size: 14px;
            font-weight: 600;
            text-align: center;
        }
    </style>
</head>
<body>
    <div class="container">
        <!-- Top Glass Header -->
        <div class="glass-card header">
            <div class="brand">
                <div class="brand-logo">☁️</div>
                <div class="brand-info">
                    <h1>HeavenOS Control Center</h1>
                    <p>macOS Sonoma Workstation • v7.5 Dark Glass</p>
                </div>
            </div>
            <div class="badge-status">
                <span class="status-dot"></span> System Audio & Cloud Active
            </div>
        </div>

        <!-- Interactive Sound Effects Board -->
        <div class="glass-card">
            <div class="section-title">🔊 Sound Effects Board</div>
            <div class="sound-grid">
                <div class="sound-btn" onclick="playSound('startup')">
                    <span class="icon">🔔</span>
                    <span class="label">Startup Sound</span>
                </div>
                <div class="sound-btn" onclick="playSound('alert')">
                    <span class="icon">⚡</span>
                    <span class="label">Alert Tone</span>
                </div>
                <div class="sound-btn" onclick="playSound('notification')">
                    <span class="icon">💬</span>
                    <span class="label">Notification</span>
                </div>
                <div class="sound-btn" onclick="playSound('trash')">
                    <span class="icon">🗑️</span>
                    <span class="label">Trash Action</span>
                </div>
            </div>
        </div>

        <!-- Drag & Drop File Upload -->
        <div class="glass-card">
            <div class="section-title">📁 Drag & Drop Desktop Portal</div>
            <div class="drop-zone" id="dropZone" onclick="document.getElementById('fileInput').click()">
                <span class="drop-icon">📤</span>
                <div class="drop-title">Drop files here or click to browse</div>
                <div class="drop-subtitle">Upload videos, audio, images, code or 3D models straight to Desktop</div>
                <input type="file" id="fileInput" multiple style="display:none;" onchange="handleFiles(this.files)">
            </div>

            <div class="file-list" id="fileList"></div>
            <div class="progress-container" id="progressContainer">
                <div class="progress-bar" id="progressBar"></div>
            </div>
            <button class="btn-upload" onclick="uploadFiles()">Upload to HeavenOS Desktop</button>
            <div id="statusMsg"></div>
        </div>
    </div>

    <script>
        // Web Audio API Sound Synthesizer
        const audioCtx = new (window.AudioContext || window.webkitAudioContext)();

        function playSound(type) {
            if (audioCtx.state === 'suspended') audioCtx.resume();
            
            const now = audioCtx.currentTime;
            
            if (type === 'startup') {
                // Harmonic F# Major Startup Chime (F#3, C#4, F#4, A#4)
                const freqs = [185.00, 277.18, 369.99, 466.16];
                freqs.forEach(freq => {
                    const osc = audioCtx.createOscillator();
                    const gain = audioCtx.createGain();
                    osc.type = 'sine';
                    osc.frequency.setValueAtTime(freq, now);
                    
                    gain.gain.setValueAtTime(0.001, now);
                    gain.gain.linearRampToValueAtTime(0.15, now + 0.1);
                    gain.gain.exponentialRampToValueAtTime(0.0001, now + 3.0);
                    
                    osc.connect(gain);
                    gain.connect(audioCtx.destination);
                    osc.start(now);
                    osc.stop(now + 3.0);
                });
            } else if (type === 'alert') {
                // Dual tone alert
                [587.33, 880].forEach((freq, idx) => {
                    const osc = audioCtx.createOscillator();
                    const gain = audioCtx.createGain();
                    osc.type = 'triangle';
                    osc.frequency.setValueAtTime(freq, now + (idx * 0.08));
                    gain.gain.setValueAtTime(0.2, now + (idx * 0.08));
                    gain.gain.exponentialRampToValueAtTime(0.001, now + (idx * 0.08) + 0.3);
                    osc.connect(gain);
                    gain.connect(audioCtx.destination);
                    osc.start(now + (idx * 0.08));
                    osc.stop(now + (idx * 0.08) + 0.3);
                });
            } else if (type === 'notification') {
                // Bell chime
                const osc = audioCtx.createOscillator();
                const gain = audioCtx.createGain();
                osc.type = 'sine';
                osc.frequency.setValueAtTime(1046.50, now);
                gain.gain.setValueAtTime(0.25, now);
                gain.gain.exponentialRampToValueAtTime(0.001, now + 0.8);
                osc.connect(gain);
                gain.connect(audioCtx.destination);
                osc.start(now);
                osc.stop(now + 0.8);
            } else if (type === 'trash') {
                // Soft swoosh tone
                const osc = audioCtx.createOscillator();
                const gain = audioCtx.createGain();
                osc.type = 'sine';
                osc.frequency.setValueAtTime(300, now);
                osc.frequency.exponentialRampToValueAtTime(80, now + 0.25);
                gain.gain.setValueAtTime(0.2, now);
                gain.gain.exponentialRampToValueAtTime(0.001, now + 0.25);
                osc.connect(gain);
                gain.connect(audioCtx.destination);
                osc.start(now);
                osc.stop(now + 0.25);
            }
        }

        // Drag & Drop Handling
        let selectedFiles = [];
        const dropZone = document.getElementById('dropZone');

        ['dragenter', 'dragover', 'dragleave', 'drop'].forEach(evt => {
            dropZone.addEventListener(evt, e => { e.preventDefault(); e.stopPropagation(); });
        });

        ['dragenter', 'dragover'].forEach(evt => dropZone.classList.add('dragover'));
        ['dragleave', 'drop'].forEach(evt => dropZone.classList.remove('dragover'));

        dropZone.addEventListener('drop', e => handleFiles(e.dataTransfer.files));

        function handleFiles(files) {
            selectedFiles = Array.from(files);
            const list = document.getElementById('fileList');
            list.style.display = 'block';
            list.innerHTML = '<b>Selected Files:</b><br>' + selectedFiles.map(f => '• ' + f.name + ' (' + (f.size/1024/1024).toFixed(2) + ' MB)').join('<br>');
        }

        function uploadFiles() {
            if (!selectedFiles.length) { alert('Select at least one file to upload!'); return; }
            const status = document.getElementById('statusMsg');
            const progressContainer = document.getElementById('progressContainer');
            const progressBar = document.getElementById('progressBar');

            status.style.color = 'var(--accent-cyan)';
            status.innerText = 'Uploading...';
            progressContainer.style.display = 'block';

            let formData = new FormData();
            selectedFiles.forEach(f => formData.append('files', f));

            let xhr = new XMLHttpRequest();
            xhr.open('POST', '/upload', true);

            xhr.upload.onprogress = function(e) {
                if (e.lengthComputable) {
                    let percent = (e.loaded / e.total) * 100;
                    progressBar.style.width = percent + '%';
                }
            };

            xhr.onload = function() {
                if (xhr.status === 200) {
                    status.style.color = '#34d399';
                    status.innerText = '✅ Upload Successful! Files placed on HeavenOS Desktop.';
                    playSound('notification');
                    selectedFiles = [];
                    document.getElementById('fileList').style.display = 'none';
                    setTimeout(() => { progressContainer.style.display = 'none'; progressBar.style.width = '0%'; }, 2500);
                } else {
                    status.style.color = '#f87171';
                    status.innerText = '❌ Upload Failed!';
                    playSound('alert');
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

cat > "$DESKTOP_DIR/Kdenlive.desktop" << 'EOF'
[Desktop Entry]
Version=1.0
Type=Application
Name=Kdenlive
Comment=Non-Linear Video Editor
Exec=kdenlive
Icon=kdenlive
Terminal=false
Categories=AudioVideo;Video;VideoEditing;
StartupNotify=true
EOF
chmod +x "$DESKTOP_DIR/Kdenlive.desktop"

cat > "$DESKTOP_DIR/Krita.desktop" << 'EOF'
[Desktop Entry]
Version=1.0
Type=Application
Name=Krita
Comment=Digital Painting & Illustration
Exec=krita
Icon=krita
Terminal=false
Categories=Graphics;2DGraphics;RasterGraphics;
StartupNotify=true
EOF
chmod +x "$DESKTOP_DIR/Krita.desktop"

cat > "$DESKTOP_DIR/Natron.desktop" << 'EOF'
[Desktop Entry]
Version=1.0
Type=Application
Name=Natron
Comment=Node-based VFX Compositing Software
Exec=natron
Icon=natron
Terminal=false
Categories=Graphics;Video;
StartupNotify=true
EOF
chmod +x "$DESKTOP_DIR/Natron.desktop"

cat > "$DESKTOP_DIR/Postman.desktop" << 'EOF'
[Desktop Entry]
Version=1.0
Type=Application
Name=Postman
Comment=API Development & Testing Studio
Exec=postman
Icon=postman
Terminal=false
Categories=Development;IDE;
StartupNotify=true
EOF
chmod +x "$DESKTOP_DIR/Postman.desktop"

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

cat > "$PLANK_DIR/Postman.dockitem" << 'EOF'
[PlankDockItemPreferences]
Launcher=file:///config/Desktop/Postman.desktop
EOF

cat > "$PLANK_DIR/Kdenlive.dockitem" << 'EOF'
[PlankDockItemPreferences]
Launcher=file:///config/Desktop/Kdenlive.desktop
EOF

cat > "$PLANK_DIR/Krita.dockitem" << 'EOF'
[PlankDockItemPreferences]
Launcher=file:///config/Desktop/Krita.desktop
EOF

cat > "$PLANK_DIR/Natron.dockitem" << 'EOF'
[PlankDockItemPreferences]
Launcher=file:///config/Desktop/Natron.desktop
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
    <property name="SoundThemeName" type="string" value="ubuntu"/>
    <property name="CursorThemeName" type="string" value="WhiteSur-cursors"/>
    <property name="EnableEventSounds" type="bool" value="true"/>
    <property name="EnableInputFeedbackSounds" type="bool" value="true"/>
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

# ---- GTK3 CSS Override (macOS Sonoma Glassmorphism & UI Enhancements) ---
mkdir -p /config/.config/gtk-3.0
cat > /config/.config/gtk-3.0/gtk.css << 'CSSEOF'
/* macOS Sonoma Glassmorphic Base Theme */
window,
dialog,
headerbar,
.titlebar {
    border-radius: 14px 14px 0 0 !important;
    background-color: rgba(15, 23, 42, 0.92) !important;
    color: #f8fafc !important;
}

headerbar {
    border-bottom: 1px solid rgba(255, 255, 255, 0.08) !important;
    box-shadow: 0 1px 3px rgba(0, 0, 0, 0.3) !important;
}

/* macOS Sonoma Top Bar Translucent Styling */
.xfce4-panel,
panel-window {
    background-color: rgba(15, 23, 42, 0.75) !important;
    color: #f8fafc !important;
    border-bottom: 1px solid rgba(255, 255, 255, 0.12) !important;
    box-shadow: 0 4px 16px rgba(0, 0, 0, 0.4) !important;
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
    font-weight: 500 !important;
}

/* Modern Rounded Buttons & Hover Glows */
button.suggested-action {
    background: linear-gradient(135deg, #0284c7, #2563eb) !important;
    border-radius: 8px !important;
    border: none !important;
    color: #ffffff !important;
    font-weight: 600 !important;
    box-shadow: 0 4px 12px rgba(2, 132, 199, 0.3) !important;
}

button.suggested-action:hover {
    box-shadow: 0 6px 16px rgba(2, 132, 199, 0.45) !important;
}

/* Sleek Dark Scrollbars */
scrollbar slider {
    background-color: rgba(255, 255, 255, 0.2) !important;
    border-radius: 10px !important;
    min-width: 6px !important;
    min-height: 6px !important;
}

scrollbar slider:hover {
    background-color: rgba(56, 189, 248, 0.6) !important;
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

echo "[HeavenOS] macOS Sonoma UI + WhiteSur Theme + Plank Dock Registered!"
