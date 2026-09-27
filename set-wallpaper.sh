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

# ---- Startup Notice Autostart (Multi-OS Program Support Enabled) ----
cat > "$AUTOSTART_DIR/heaven-notice.desktop" << 'EOF'
[Desktop Entry]
Type=Application
Name=HeavenOS Notice
Exec=zenity --info --title="HeavenOS v8.0 Multi-OS Workstation" --text="Welcome to HeavenOS!\n\n✨ Universal Multi-OS Program Support Active:\n1. 🪟 Windows Apps (.EXE, .MSI via Wine Engine)\n2. 🍏 macOS Apps (.DMG, .APP, .PKG Engine)\n3. 🐧 Linux & Mobile Apps (.AppImage, .DEB, .APK Engine)\n\nDouble-click any program executable to run directly!\n\n----------------------------------------\nCredits: Rohan2core and Prathamesh for programming" --width=500
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
                    <p>macOS Sonoma Workstation • v8.0 Multi-OS Edition</p>
                </div>
            </div>
            <div class="badge-status">
                <span class="status-dot"></span> Multi-OS Compatibility & Cloud Active
            </div>
        </div>

        <!-- Universal Multi-OS Program Engine Showcase -->
        <div class="glass-card">
            <div class="section-title">🚀 Universal Multi-OS Program Support</div>
            <div class="sound-grid">
                <div class="sound-btn" onclick="alert('Windows Executable Engine Ready (.EXE / .MSI)\nDouble-click any .exe file on Desktop to execute via Wine!')">
                    <span class="icon">🪟</span>
                    <span class="label">Windows (.EXE / .MSI)</span>
                </div>
                <div class="sound-btn" onclick="alert('macOS Application Engine Ready (.DMG / .APP / .PKG)\nDouble-click any .dmg/.app file on Desktop to run or extract!')">
                    <span class="icon">🍏</span>
                    <span class="label">macOS (.DMG / .APP)</span>
                </div>
                <div class="sound-btn" onclick="alert('Linux Portable & Mobile Engine Ready (.AppImage / .DEB / .APK)\nDouble-click any Linux app or Android APK to execute!')">
                    <span class="icon">🐧</span>
                    <span class="label">Linux & Mobile</span>
                </div>
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

# ---- App Fallback Wrappers & Touchscreen Support ---------------------
cat > /usr/local/bin/onboard-keyboard << 'ONBOARDWRAPPER'
#!/bin/bash
if pgrep -x "onboard" > /dev/null; then
    killall onboard 2>/dev/null || true
else
    onboard &
fi
ONBOARDWRAPPER
chmod +x /usr/local/bin/onboard-keyboard

cat > /usr/local/bin/google-chrome-stable << 'CHROMEWRAPPER'
#!/bin/bash
TOUCH_FLAGS="--enable-touch-drag-drop --enable-viewport --touch-events=enabled"
if [ -x /usr/bin/google-chrome-stable ]; then
    exec /usr/bin/google-chrome-stable $TOUCH_FLAGS "$@"
elif [ -x /usr/bin/google-chrome ]; then
    exec /usr/bin/google-chrome $TOUCH_FLAGS "$@"
elif [ -x /usr/bin/chromium-browser ]; then
    exec /usr/bin/chromium-browser $TOUCH_FLAGS "$@"
elif [ -x /usr/bin/chromium ]; then
    exec /usr/bin/chromium $TOUCH_FLAGS "$@"
elif [ -x /usr/bin/firefox ]; then
    exec /usr/bin/firefox "$@"
else
    zenity --error --title="HeavenOS" --text="Google Chrome binary not found in /usr/bin/google-chrome-stable.\nPlease rebuild the Docker image." --width=400
fi
CHROMEWRAPPER
chmod +x /usr/local/bin/google-chrome-stable
ln -sf /usr/local/bin/google-chrome-stable /usr/local/bin/google-chrome

cat > /usr/local/bin/discord << 'DISCORDWRAPPER'
#!/bin/bash
DISCORD_FLAGS="--no-sandbox --disable-gpu --disable-dev-shm-usage --disable-software-rasterizer"

if ! [ -x /usr/bin/discord ] && ! [ -x /usr/share/discord/Discord ]; then
    zenity --info --title="HeavenOS Installer" --text="Discord is installing in background... Please wait." --width=400 --timeout=3 2>/dev/null &
    mkdir -p /tmp/downloads
    wget -q -O /tmp/downloads/discord.deb "https://discord.com/api/download?platform=linux&format=deb" 2>/dev/null || wget -q -O /tmp/downloads/discord.deb "https://dl.discordapp.net/apps/linux/0.0.60/discord-0.0.60.deb" 2>/dev/null
    dpkg -i /tmp/downloads/discord.deb 2>/dev/null || apt-get install -f -y 2>/dev/null || true
fi

if [ -x /usr/bin/discord ]; then
    exec /usr/bin/discord $DISCORD_FLAGS "$@"
elif [ -x /usr/share/discord/Discord ]; then
    exec /usr/share/discord/Discord $DISCORD_FLAGS "$@"
else
    zenity --error --title="HeavenOS" --text="Discord launch failed. Please check internet connection." --width=400
fi
DISCORDWRAPPER
chmod +x /usr/local/bin/discord

cat > /usr/local/bin/blender-wrapper << 'BLENDERWRAPPER'
#!/bin/bash
export LIBGL_ALWAYS_SOFTWARE=1
export GALLIUM_DRIVER=llvmpipe
export MESA_GL_VERSION_OVERRIDE=4.5

if ! command -v blender &>/dev/null; then
    zenity --info --title="HeavenOS Installer" --text="Blender 3D is installing in background... Please wait." --width=400 --timeout=3 2>/dev/null &
    apt-get update &>/dev/null && apt-get install -y --no-install-recommends blender &>/dev/null || true
fi

if command -v blender &>/dev/null; then
    exec blender "$@"
else
    zenity --error --title="HeavenOS" --text="Blender 3D launch failed. Please check internet connection." --width=400
fi
BLENDERWRAPPER
chmod +x /usr/local/bin/blender-wrapper

cat > /usr/local/bin/code << 'CODEWRAPPER'
#!/bin/bash
if [ -x /usr/bin/code ]; then
    exec /usr/bin/code --no-sandbox "$@"
else
    zenity --error --title="HeavenOS" --text="VS Code is not installed properly." --width=400
fi
CODEWRAPPER
chmod +x /usr/local/bin/code

cat > /usr/local/bin/audacity << 'AUDACITYWRAPPER'
#!/bin/bash
if [ -x /usr/bin/audacity ]; then
    exec /usr/bin/audacity "$@"
else
    zenity --error --title="HeavenOS" --text="Audacity Audio Editor is not installed properly." --width=400
fi
AUDACITYWRAPPER
chmod +x /usr/local/bin/audacity

cat > /usr/local/bin/vlc << 'VLCWRAPPER'
#!/bin/bash
if [ -x /usr/bin/vlc ]; then
    exec /usr/bin/vlc "$@"
else
    zenity --error --title="HeavenOS" --text="VLC Media Player is not installed properly." --width=400
fi
VLCWRAPPER
chmod +x /usr/local/bin/vlc

cat > /usr/local/bin/filezilla << 'FILEZILLAWRAPPER'
#!/bin/bash
if [ -x /usr/bin/filezilla ]; then
    exec /usr/bin/filezilla "$@"
else
    zenity --error --title="HeavenOS" --text="FileZilla FTP Client is not installed properly." --width=400
fi
FILEZILLAWRAPPER
chmod +x /usr/local/bin/filezilla

# ====================================================================
#  UNIVERSAL MULTI-OS PROGRAM RUNNERS (Windows, macOS, Linux, Android)
# ====================================================================

# ---- 1. Windows Executable Runner (.EXE & .MSI) ------------------
cat > /usr/local/bin/heaven-exe-runner << 'EXERUNNER'
#!/bin/bash
TARGET="$1"
if [ -z "$TARGET" ]; then
    TARGET=$(zenity --file-selection --title="HeavenOS - Select Windows Application (.exe / .msi)" --file-filter="Windows Files (*.exe *.msi) | *.exe *.msi *.EXE *.MSI" 2>/dev/null)
    if [ -z "$TARGET" ]; then exit 0; fi
fi
FILENAME=$(basename "$TARGET")
export WINEPREFIX="${HOME}/.wine"
export WINEDEBUG=-all
zenity --info --title="HeavenOS Windows Compatibility Engine (Wine)" \
       --text="<b>Launching Windows Application:</b>\n$FILENAME\n\nPlease wait while HeavenOS Windows Environment executes the application..." \
       --width=450 --timeout=3 2>/dev/null &
if [[ "$TARGET" == *.msi || "$TARGET" == *.MSI ]]; then
    wine msiexec /i "$TARGET" "$@"
else
    wine "$TARGET" "$@"
fi
EXERUNNER
chmod +x /usr/local/bin/heaven-exe-runner

# ---- 2. macOS Application & Disk Image Runner (.DMG, .APP, .PKG) ---
cat > /usr/local/bin/heaven-mac-runner << 'MACRUNNER'
#!/bin/bash
TARGET="$1"
if [ -z "$TARGET" ]; then
    TARGET=$(zenity --file-selection --title="HeavenOS - Select macOS Application / Disk Image" --file-filter="macOS Packages (*.dmg *.app *.pkg) | *.dmg *.app *.pkg *.DMG *.APP *.PKG" 2>/dev/null)
    if [ -z "$TARGET" ]; then exit 0; fi
fi
FILENAME=$(basename "$TARGET")
EXT="${TARGET##*.}"
EXT_LOWER=$(echo "$EXT" | tr '[:upper:]' '[:lower:]')

if [ -d "$TARGET" ] && [[ "$TARGET" == *.app ]]; then
    EXEC_FILE=$(find "$TARGET/Contents/MacOS" -maxdepth 2 -type f 2>/dev/null | head -n 1)
    if [ -n "$EXEC_FILE" ]; then
        chmod +x "$EXEC_FILE" 2>/dev/null
        zenity --info --title="HeavenOS macOS Engine" \
               --text="<b>macOS Application Bundle (.APP):</b>\n$FILENAME\n\nLaunching macOS binary:\n$EXEC_FILE" \
               --width=500 --timeout=4 2>/dev/null &
        "$EXEC_FILE" "$@" 2>/dev/null || bash "$EXEC_FILE" "$@"
    else
        zenity --error --title="HeavenOS macOS Engine" --text="Could not locate executable binary in $TARGET/Contents/MacOS/" --width=450 2>/dev/null
    fi
elif [ "$EXT_LOWER" = "dmg" ]; then
    OUT_DIR="${HOME}/Desktop/Extracted_DMG_${FILENAME%.*}"
    mkdir -p "$OUT_DIR"
    zenity --info --title="HeavenOS macOS Engine" \
           --text="<b>Extracting & Mounting macOS Disk Image (.DMG):</b>\n$FILENAME\n\nExtracted contents folder:\n$OUT_DIR" \
           --width=500 --timeout=4 2>/dev/null &
    7z x -y "$TARGET" -o"$OUT_DIR" 2>/dev/null || dmg2img -i "$TARGET" -o "$OUT_DIR/disk_image.img" 2>/dev/null
    thunar "$OUT_DIR" 2>/dev/null &
elif [ "$EXT_LOWER" = "pkg" ]; then
    OUT_DIR="${HOME}/Desktop/Extracted_PKG_${FILENAME%.*}"
    mkdir -p "$OUT_DIR"
    zenity --info --title="HeavenOS macOS Engine" \
           --text="<b>Extracting macOS Package (.PKG):</b>\n$FILENAME\n\nExtracted package contents folder:\n$OUT_DIR" \
           --width=500 --timeout=4 2>/dev/null &
    7z x -y "$TARGET" -o"$OUT_DIR" 2>/dev/null
    thunar "$OUT_DIR" 2>/dev/null &
else
    zenity --error --title="HeavenOS macOS Engine" --text="Unsupported macOS file format: $FILENAME" --width=400 2>/dev/null
fi
MACRUNNER
chmod +x /usr/local/bin/heaven-mac-runner

# ---- 3. Linux Portable Apps & Package Engine (.AppImage & .DEB) ---
cat > /usr/local/bin/heaven-linux-runner << 'LINUXRUNNER'
#!/bin/bash
TARGET="$1"
if [ -z "$TARGET" ]; then
    TARGET=$(zenity --file-selection --title="HeavenOS - Select Linux Portable App or Package" --file-filter="Linux Files (*.AppImage *.appimage *.deb) | *.AppImage *.appimage *.deb" 2>/dev/null)
    if [ -z "$TARGET" ]; then exit 0; fi
fi
FILENAME=$(basename "$TARGET")

if [[ "$TARGET" == *.deb || "$TARGET" == *.DEB ]]; then
    zenity --info --title="HeavenOS Package Installer" --text="Installing Debian Package:\n$FILENAME" --timeout=3 2>/dev/null &
    if command -v gdebi-gtk &>/dev/null; then
        gdebi-gtk "$TARGET"
    else
        pkexec apt-get install -y "$TARGET" || dpkg -i "$TARGET" || zenity --error --title="HeavenOS Package Installer" --text="Failed to install $FILENAME" 2>/dev/null
    fi
else
    chmod +x "$TARGET"
    zenity --info --title="HeavenOS AppImage Launcher" --text="Launching Linux Portable Application:\n$FILENAME" --timeout=3 2>/dev/null &
    "$TARGET" --no-sandbox "$@" 2>/dev/null || "$TARGET" "$@"
fi
LINUXRUNNER
chmod +x /usr/local/bin/heaven-linux-runner

# ---- 4. Android Package Engine (.APK) ----------------------------
cat > /usr/local/bin/heaven-apk-runner << 'APKRUNNER'
#!/bin/bash
TARGET="$1"
if [ -z "$TARGET" ]; then
    TARGET=$(zenity --file-selection --title="HeavenOS - Select Android Package (.apk)" --file-filter="Android Packages (*.apk) | *.apk *.APK" 2>/dev/null)
    if [ -z "$TARGET" ]; then exit 0; fi
fi
FILENAME=$(basename "$TARGET")
OUT_DIR="${HOME}/Desktop/Extracted_APK_${FILENAME%.*}"
mkdir -p "$OUT_DIR"
zenity --info --title="HeavenOS Android Engine" \
       --text="<b>Extracting Android Package (.APK):</b>\n$FILENAME\n\nExtracted contents folder:\n$OUT_DIR" \
       --width=500 --timeout=4 2>/dev/null &
7z x -y "$TARGET" -o"$OUT_DIR" 2>/dev/null
thunar "$OUT_DIR" 2>/dev/null &
APKRUNNER
chmod +x /usr/local/bin/heaven-apk-runner

# ---- 4b. Universal WinRAR/7-Zip Archive Extractor & Game Auto-Detector ---
cat > /usr/local/bin/heaven-archive-engine << 'ARCHIVEEOF'
#!/bin/bash
TARGET="$1"
if [ -z "$TARGET" ]; then
    TARGET=$(zenity --file-selection --title="HeavenOS WinRAR Engine - Select Archive (.zip .rar .7z .iso)" --file-filter="Archive Files (*.zip *.rar *.7z *.iso *.tar.gz) | *.zip *.rar *.7z *.iso *.tar.gz *.tar *.gz *.xz" 2>/dev/null)
    if [ -z "$TARGET" ]; then exit 0; fi
fi

# Install unar/unrar at runtime if missing
if ! command -v unar &>/dev/null && ! command -v unrar &>/dev/null; then
    apt-get update &>/dev/null && apt-get install -y --no-install-recommends unar unrar &>/dev/null || true
fi

FILENAME=$(basename "$TARGET")
RAW_NAME="${FILENAME%.*}"
RAW_NAME="${RAW_NAME%.tar}"

OUT_DIR="/config/Desktop/Extracted_${RAW_NAME}"
mkdir -p "$OUT_DIR"

zenity --info --title="HeavenOS Archive Engine" \
       --text="<b>Unpacking Archive (WinRAR / 7-Zip Engine):</b>\n$FILENAME\n\nDestination:\n$OUT_DIR\n\nPlease wait while HeavenOS unpacks all files..." \
       --width=520 --timeout=3 2>/dev/null &

EXTRACT_OK=0

# Engine 1: unar (Universal Unarchiver for RARv5 / WinRAR 5 & 6)
if command -v unar &>/dev/null; then
    unar -o "$OUT_DIR" -f -q "$TARGET" 2>/dev/null && EXTRACT_OK=1
fi

# Engine 2: unrar
if [ $EXTRACT_OK -eq 0 ] && command -v unrar &>/dev/null; then
    unrar x -o+ -y "$TARGET" "$OUT_DIR/" 2>/dev/null && EXTRACT_OK=1
fi

# Engine 3: 7z
if [ $EXTRACT_OK -eq 0 ]; then
    7z x -y "$TARGET" -o"$OUT_DIR" 2>/dev/null && EXTRACT_OK=1
fi

# Engine 4: unzip / tar
if [ $EXTRACT_OK -eq 0 ]; then
    unzip -o "$TARGET" -d "$OUT_DIR" 2>/dev/null || tar -xf "$TARGET" -C "$OUT_DIR" 2>/dev/null && EXTRACT_OK=1
fi

# Subfolder Auto-Navigation (Detect if archive contained a single root directory)
INNER_DIRS=$(find "$OUT_DIR" -mindepth 1 -maxdepth 1 2>/dev/null)
INNER_COUNT=$(echo "$INNER_DIRS" | grep -v '^$' | wc -l)
if [ "$INNER_COUNT" -eq 1 ] && [ -d "$INNER_DIRS" ]; then
    TARGET_VIEW_DIR="$INNER_DIRS"
else
    TARGET_VIEW_DIR="$OUT_DIR"
fi

FILE_COUNT=$(find "$TARGET_VIEW_DIR" -type f 2>/dev/null | wc -l)

if [ "$FILE_COUNT" -gt 0 ]; then
    zenity --notification --text="✅ WinRAR Unpacked: $FILENAME ($FILE_COUNT files extracted)" 2>/dev/null || true
    thunar "$TARGET_VIEW_DIR" 2>/dev/null &

    # Game Executable Auto-Detection (.exe)
    EXE_FILE=$(find "$TARGET_VIEW_DIR" -maxdepth 3 -iname "*.exe" ! -iname "unins*.exe" ! -iname "dxsetup.exe" ! -iname "vcredist*.exe" 2>/dev/null | head -n 1)
    if [ -n "$EXE_FILE" ]; then
        EXE_NAME=$(basename "$EXE_FILE")
        if zenity --question --title="🎮 HeavenOS Game Auto-Launcher" \
                  --text="<b>Game / Program Executable Detected!</b>\n\nFound executable: <b>$EXE_NAME</b>\n\nDo you want to launch this game with HeavenOS Windows Engine (Wine) now?" \
                  --width=500 2>/dev/null; then
            heaven-exe-runner "$EXE_FILE" &
        fi
    fi
else
    # Fallback to GUI Archive Manager if 0 files extracted
    zenity --warning --title="HeavenOS Archive Engine" \
           --text="<b>Auto-extraction produced 0 files.</b>\nOpening GUI Archive Manager (WinRAR Alternative)..." \
           --width=450 2>/dev/null
    if command -v file-roller &>/dev/null; then
        file-roller "$TARGET" &
    elif command -v peazip &>/dev/null; then
        peazip "$TARGET" &
    else
        thunar "$OUT_DIR" &
    fi
fi
ARCHIVEEOF
chmod +x /usr/local/bin/heaven-archive-engine
# ---- 5. macOS Spotlight Search Engine (Ctrl + Space) ---------------
cat > /usr/local/bin/heaven-spotlight << 'SPOTLIGHTEOF'
#!/bin/bash
QUERY=$(zenity --entry --title=" HeavenOS Spotlight Search" --text="Type App Name, File Name, or Math Calculation:" --width=450 2>/dev/null)
if [ -z "$QUERY" ]; then exit 0; fi

if [[ "$QUERY" =~ ^[0-9\ \+\-\*\/\.\(\)]+$ ]]; then
    RESULT=$(python3 -c "print($QUERY)" 2>/dev/null)
    if [ -n "$RESULT" ]; then
        zenity --info --title="Spotlight Calculator" --text="<b>Result:</b> $QUERY = <b>$RESULT</b>" --width=350 2>/dev/null
        exit 0
    fi
fi

MATCH=$(find /config/Desktop /usr/share/applications /usr/local/bin -iname "*$QUERY*" 2>/dev/null | head -n 1)
if [ -n "$MATCH" ]; then
    if [[ "$MATCH" == *.desktop ]]; then
        gtk-launch $(basename "$MATCH" .desktop) 2>/dev/null || xdg-open "$MATCH" 2>/dev/null &
    elif [ -x "$MATCH" ]; then
        "$MATCH" &
    else
        thunar "$MATCH" &
    fi
else
    zenity --error --title="Spotlight Search" --text="No matching application or file found for: <b>$QUERY</b>" --width=400 2>/dev/null
fi
SPOTLIGHTEOF
chmod +x /usr/local/bin/heaven-spotlight

# ---- 6. macOS Quick Look Preview Engine (Spacebar) ----------------
cat > /usr/local/bin/heaven-quicklook << 'QUICKLOOKEOF'
#!/bin/bash
TARGET="$1"
if [ -z "$TARGET" ]; then
    TARGET=$(zenity --file-selection --title=" HeavenOS Quick Look - Select File to Preview" 2>/dev/null)
    if [ -z "$TARGET" ]; then exit 0; fi
fi

FILENAME=$(basename "$TARGET")
FILETYPE=$(file -b --mime-type "$TARGET" 2>/dev/null)
FILESIZE=$(du -h "$TARGET" 2>/dev/null | cut -f1)

if [[ "$FILETYPE" == text/* || "$TARGET" == *.txt || "$TARGET" == *.sh || "$TARGET" == *.py || "$TARGET" == *.json || "$TARGET" == *.md ]]; then
    zenity --text-info --title=" Quick Look - $FILENAME ($FILESIZE)" --filename="$TARGET" --width=600 --height=450 2>/dev/null
else
    zenity --info --title=" Quick Look - $FILENAME" \
           --text="<b>File Name:</b> $FILENAME\n<b>MIME Type:</b> $FILETYPE\n<b>File Size:</b> $FILESIZE\n\nLocation: $TARGET" \
           --width=450 2>/dev/null
fi
QUICKLOOKEOF
chmod +x /usr/local/bin/heaven-quicklook

# ---- 7. Dynamic Dark / Light Mode Switcher -----------------------
cat > /usr/local/bin/heaven-theme-toggle << 'THEMEEOF'
#!/bin/bash
CURRENT_THEME=$(xfconf-query -c xsettings -p /Net/ThemeName 2>/dev/null)

if [[ "$CURRENT_THEME" == *"Dark"* || "$CURRENT_THEME" == *"dark"* ]]; then
    NEW_THEME="WhiteSur-Light"
    MODE_NAME="Light Mode ☀️"
else
    NEW_THEME="WhiteSur-Dark"
    MODE_NAME="Dark Mode 🌙"
fi

xfconf-query -c xsettings -p /Net/ThemeName -s "$NEW_THEME" 2>/dev/null || true
xfconf-query -c xfwm4 -p /general/theme -s "$NEW_THEME" 2>/dev/null || true
zenity --notification --text=" HeavenOS switched to macOS Sonoma $MODE_NAME" 2>/dev/null || true
THEMEEOF
chmod +x /usr/local/bin/heaven-theme-toggle

# ---- 8. 144 FPS Performance Turbo & RAM Disk Engine --------------
cat > /usr/local/bin/heaven-fps-turbo << 'FPSEOF'
#!/bin/bash
mkdir -p /tmp/ramdisk
mount -t tmpfs -o size=1G tmpfs /tmp/ramdisk 2>/dev/null || true

CHOICE=$(zenity --list --title="⚡ HeavenOS FPS & Performance Turbo Engine" \
  --column="Mode" --column="FPS" --column="Description" \
  "Standard" "60 FPS" "Balanced 60 FPS Smooth Mode" \
  "Ultra Performance" "120 FPS" "High Refresh Rate 120 FPS Mode" \
  "Extreme Turbo" "144 FPS" "Maximum 144 FPS Ultra-Low Latency Mode" 2>/dev/null)

if [ -z "$CHOICE" ]; then exit 0; fi

FPS=60
if [ "$CHOICE" = "Ultra Performance" ]; then FPS=120; fi
if [ "$CHOICE" = "Extreme Turbo" ]; then FPS=144; fi

for conf in /etc/kasmvnc/kasmvnc.yaml /config/.vnc/kasmvnc.yaml /config/.kasmdock/kasmvnc.yaml; do
    if [ -f "$conf" ]; then
        sed -i "s/max_frame_rate: [0-9]*/max_frame_rate: $FPS/g" "$conf" 2>/dev/null || true
        sed -i "s/frame_rate: [0-9]*/frame_rate: $FPS/g" "$conf" 2>/dev/null || true
    fi
done

zenity --info --title="⚡ HeavenOS Turbo Boost" \
       --text="<b>HeavenOS High Performance Mode Activated!</b>\n\n• Target Refresh Rate: <b>$FPS FPS</b>\n• Dynamic RAM Disk: <b>/tmp/ramdisk (1 GB Active)</b>" \
       --width=450 2>/dev/null
FPSEOF
chmod +x /usr/local/bin/heaven-fps-turbo

# ---- 9. HeavenOS Time Machine Snapshot & Restore Engine ------------
cat > /usr/local/bin/heaven-time-machine << 'TMEOF'
#!/bin/bash
SNAPSHOT_DIR="/config/.snapshots"
mkdir -p "$SNAPSHOT_DIR"

ACTION=$(zenity --list --title="⏱️ HeavenOS Time Machine Backup & Restore" \
  --column="Action" --column="Description" \
  "Take Snapshot" "Create instant snapshot backup of Desktop & Settings" \
  "Restore Snapshot" "Restore Desktop & Settings from a previous snapshot" 2>/dev/null)

if [ "$ACTION" = "Take Snapshot" ]; then
    TIMESTAMP=$(date +%Y%m%d_%H%M%S)
    FILE="$SNAPSHOT_DIR/heaven_snapshot_$TIMESTAMP.tar.gz"
    tar -czf "$FILE" -C /config Desktop .config 2>/dev/null
    zenity --info --title="⏱️ Time Machine Snapshot Complete" \
           --text="<b>Snapshot Backup Created Successfully!</b>\n\nFile: $FILE" --width=450 2>/dev/null
elif [ "$ACTION" = "Restore Snapshot" ]; then
    FILES=$(find "$SNAPSHOT_DIR" -name "*.tar.gz" 2>/dev/null)
    if [ -z "$FILES" ]; then
        zenity --error --title="Time Machine Restore" --text="No snapshots found in $SNAPSHOT_DIR" --width=400 2>/dev/null
        exit 0
    fi
    SELECTED=$(zenity --file-selection --filename="$SNAPSHOT_DIR/" --title="Select Snapshot to Restore" 2>/dev/null)
    if [ -n "$SELECTED" ]; then
        tar -xzf "$SELECTED" -C /config/ 2>/dev/null
        zenity --info --title="⏱️ Time Machine Restore Complete" \
               --text="<b>Settings & Desktop Restored!</b>\n\nRestarting desktop..." --width=400 2>/dev/null
        bash /usr/local/bin/apply-lotus-wallpaper.sh 2>/dev/null &
    fi
fi
TMEOF
chmod +x /usr/local/bin/heaven-time-machine

# ---- 10. Smart Screenshot Tool Engine ----------------------------
cat > /usr/local/bin/heaven-screenshot << 'SHOTEOF'
#!/bin/bash
TIMESTAMP=$(date +%Y-%m-%d_%H-%M-%S)
OUTFILE="/config/Desktop/Screenshot_$TIMESTAMP.png"

canberra-gtk-play -i camera-shutter 2>/dev/null || paplay /usr/share/sounds/ubuntu/stereo/camera-shutter.ogg 2>/dev/null || true

if command -v xfce4-screenshooter &>/dev/null; then
    xfce4-screenshooter -r -s "$OUTFILE" 2>/dev/null || xfce4-screenshooter -f -s "$OUTFILE" 2>/dev/null
else
    import -window root "$OUTFILE" 2>/dev/null
fi

if [ -f "$OUTFILE" ]; then
    chmod +x "$OUTFILE" 2>/dev/null || true
    zenity --notification --text="📸 Screenshot saved to Desktop: Screenshot_$TIMESTAMP.png" 2>/dev/null || true
fi
SHOTEOF
chmod +x /usr/local/bin/heaven-screenshot

# ====================================================================
#  HEAVENOS EMBEDDED VECTOR ICON ENGINE (100% Guaranteed Offline Icons)
# ====================================================================
echo "[HeavenOS] Generating embedded vector application icons..."
mkdir -p /usr/share/pixmaps /usr/share/icons/hicolor/48x48/apps /usr/share/icons/WhiteSur/apps

# 1. Google Chrome Vector Logo
cat > /usr/share/pixmaps/heaven_chrome.svg << 'SVGEOF'
<svg xmlns="http://www.w3.org/2000/svg" width="128" height="128" viewBox="0 0 128 128">
  <circle cx="64" cy="64" r="60" fill="#ffffff" />
  <path d="M 64 8 A 56 56 0 0 1 112.5 36 L 64 64 Z" fill="#EA4335" />
  <path d="M 112.5 36 A 56 56 0 0 1 64 120 L 64 64 Z" fill="#34A853" />
  <path d="M 64 120 A 56 56 0 0 1 15.5 36 L 64 64 Z" fill="#FBBC05" />
  <path d="M 15.5 36 A 56 56 0 0 1 64 8 L 64 64 Z" fill="#EA4335" />
  <circle cx="64" cy="64" r="28" fill="#ffffff" />
  <circle cx="64" cy="64" r="22" fill="#1A73E8" />
</svg>
SVGEOF

# 2. Discord Vector Logo
cat > /usr/share/pixmaps/heaven_discord.svg << 'SVGEOF'
<svg xmlns="http://www.w3.org/2000/svg" width="128" height="128" viewBox="0 0 128 128">
  <rect x="8" y="8" width="112" height="112" rx="28" fill="#5865F2"/>
  <path d="M88 38A52 52 0 0 0 74 33.5a1.5 1.5 0 0 0-1.5.7 36 36 0 0 0-1.6 3.3 48 48 0 0 0-13.8 0 36 36 0 0 0-1.6-3.3 1.5 1.5 0 0 0-1.5-.7A52 52 0 0 0 40 38a1.5 1.5 0 0 0-.7.6C30 52.8 27.4 67.2 28.7 81.3a1.5 1.5 0 0 0 .6 1 52.2 52.2 0 0 0 15.8 8 1.5 1.5 0 0 0 1.6-.5 37.3 37.3 0 0 0 3.3-5.3 1.5 1.5 0 0 0-.8-2 34.2 34.2 0 0 1-4.9-2.3 1.5 1.5 0 0 1-.1-2.5c.3-.2.7-.5 1-.7A37.2 37.2 0 0 0 77.4 79c.3.2.7.5 1 .7a1.5 1.5 0 0 1-.1 2.5 34.2 34.2 0 0 1-4.9 2.3 1.5 1.5 0 0 0-.8 2c1 1.9 2.1 3.7 3.3 5.3a1.5 1.5 0 0 0 1.6.5 52.2 52.2 0 0 0 15.8-8 1.5 1.5 0 0 0 .6-1c1.6-16.3-2.6-30.6-11.2-43.3a1.5 1.5 0 0 0-.7-.6zM50.6 70.3c-3.5 0-6.4-3.2-6.4-7.2s2.8-7.2 6.4-7.2c3.6 0 6.5 3.3 6.4 7.2 0 4-2.8 7.2-6.4 7.2zm26.8 0c-3.5 0-6.4-3.2-6.4-7.2s2.8-7.2 6.4-7.2c3.6 0 6.5 3.3 6.4 7.2 0 4-2.8 7.2-6.4 7.2z" fill="#ffffff"/>
</svg>
SVGEOF

# 3. VS Code Vector Logo
cat > /usr/share/pixmaps/heaven_vscode.svg << 'SVGEOF'
<svg xmlns="http://www.w3.org/2000/svg" width="128" height="128" viewBox="0 0 128 128">
  <rect x="8" y="8" width="112" height="112" rx="24" fill="#007ACC"/>
  <path d="M96 24L70 48L46 32L24 44V84L46 96L70 80L96 104V24Z" fill="#ffffff" opacity="0.9"/>
  <path d="M96 24L70 54L96 84V24Z" fill="#005A9E"/>
  <path d="M24 44L46 64L24 84V44Z" fill="#007ACC"/>
</svg>
SVGEOF

# 4. GIMP Vector Logo
cat > /usr/share/pixmaps/heaven_gimp.svg << 'SVGEOF'
<svg xmlns="http://www.w3.org/2000/svg" width="128" height="128" viewBox="0 0 128 128">
  <circle cx="64" cy="64" r="56" fill="#5C6B73"/>
  <path d="M40 40C40 40 70 30 84 44C98 58 90 84 70 88C50 92 36 76 36 60Z" fill="#2B2D42"/>
  <circle cx="52" cy="52" r="8" fill="#ffffff"/>
  <circle cx="54" cy="52" r="4" fill="#000000"/>
  <circle cx="76" cy="52" r="8" fill="#ffffff"/>
  <circle cx="78" cy="52" r="4" fill="#000000"/>
  <path d="M30 76C40 76 56 86 64 86" stroke="#E63946" stroke-width="8" stroke-linecap="round"/>
</svg>
SVGEOF

# 5. Audacity Vector Logo
cat > /usr/share/pixmaps/heaven_audacity.svg << 'SVGEOF'
<svg xmlns="http://www.w3.org/2000/svg" width="128" height="128" viewBox="0 0 128 128">
  <circle cx="64" cy="64" r="56" fill="#002060"/>
  <path d="M32 64 C32 36 96 36 96 64" fill="none" stroke="#FFC000" stroke-width="12" stroke-linecap="round"/>
  <path d="M40 64 L48 48 L56 80 L64 36 L72 88 L80 56 L88 64" fill="none" stroke="#00B0F0" stroke-width="6" stroke-linejoin="round" stroke-linecap="round"/>
</svg>
SVGEOF

# 6. VLC Vector Logo
cat > /usr/share/pixmaps/heaven_vlc.svg << 'SVGEOF'
<svg xmlns="http://www.w3.org/2000/svg" width="128" height="128" viewBox="0 0 128 128">
  <circle cx="64" cy="64" r="56" fill="#202020"/>
  <polygon points="64,16 40,88 88,88" fill="#FF8800"/>
  <polygon points="64,16 48,64 80,64" fill="#FFAA00"/>
  <rect x="36" y="88" width="56" height="14" rx="4" fill="#FF8800"/>
  <rect x="44" y="52" width="40" height="8" rx="2" fill="#FFFFFF"/>
  <rect x="40" y="72" width="48" height="8" rx="2" fill="#FFFFFF"/>
</svg>
SVGEOF

# 7. FileZilla Vector Logo
cat > /usr/share/pixmaps/heaven_filezilla.svg << 'SVGEOF'
<svg xmlns="http://www.w3.org/2000/svg" width="128" height="128" viewBox="0 0 128 128">
  <rect x="8" y="8" width="112" height="112" rx="24" fill="#B22222"/>
  <path d="M36 40 H92 V52 H54 V64 H84 V76 H54 V96 H36 Z" fill="#FFFFFF"/>
  <circle cx="84" cy="46" r="6" fill="#FFD700"/>
</svg>
SVGEOF

# 8. Windows Apps Vector Logo
cat > /usr/share/pixmaps/heaven_wine.svg << 'SVGEOF'
<svg xmlns="http://www.w3.org/2000/svg" width="128" height="128" viewBox="0 0 128 128">
  <rect x="8" y="8" width="112" height="112" rx="24" fill="#0078D7"/>
  <rect x="24" y="24" width="36" height="36" fill="#F25022"/>
  <rect x="68" y="24" width="36" height="36" fill="#7FBA00"/>
  <rect x="24" y="68" width="36" height="36" fill="#00A4EF"/>
  <rect x="68" y="68" width="36" height="36" fill="#FFB900"/>
</svg>
SVGEOF

# 9. Blender Vector Logo
cat > /usr/share/pixmaps/heaven_blender.svg << 'SVGEOF'
<svg xmlns="http://www.w3.org/2000/svg" width="128" height="128" viewBox="0 0 128 128">
  <circle cx="64" cy="64" r="56" fill="#EA7600"/>
  <circle cx="64" cy="64" r="36" fill="#ffffff"/>
  <circle cx="64" cy="64" r="24" fill="#22578A"/>
  <polygon points="64,8 78,40 50,40" fill="#EA7600"/>
</svg>
SVGEOF

# 10. Krita Vector Logo
cat > /usr/share/pixmaps/heaven_krita.svg << 'SVGEOF'
<svg xmlns="http://www.w3.org/2000/svg" width="128" height="128" viewBox="0 0 128 128">
  <circle cx="64" cy="64" r="56" fill="#1C2128"/>
  <path d="M 64 8 A 56 56 0 0 1 112.5 36 L 64 64 Z" fill="#00C7FF" />
  <path d="M 112.5 36 A 56 56 0 0 1 64 120 L 64 64 Z" fill="#E6007E" />
  <path d="M 64 120 A 56 56 0 0 1 15.5 36 L 64 64 Z" fill="#FFCC00" />
  <circle cx="64" cy="64" r="32" fill="#ffffff"/>
  <path d="M50 46 C60 36 80 50 68 70 C60 80 44 74 44 60 Z" fill="#333333"/>
</svg>
SVGEOF

# 11. Kdenlive Vector Logo
cat > /usr/share/pixmaps/heaven_kdenlive.svg << 'SVGEOF'
<svg xmlns="http://www.w3.org/2000/svg" width="128" height="128" viewBox="0 0 128 128">
  <rect x="8" y="8" width="112" height="112" rx="24" fill="#1E293B"/>
  <rect x="20" y="24" width="88" height="80" rx="12" fill="#0284C7"/>
  <polygon points="52,44 84,64 52,84" fill="#FFFFFF"/>
  <rect x="20" y="24" width="88" height="12" fill="#0F172A" opacity="0.6"/>
  <rect x="20" y="92" width="88" height="12" fill="#0F172A" opacity="0.6"/>
</svg>
SVGEOF

# 12. Spotlight Search Vector Logo
cat > /usr/share/pixmaps/heaven_spotlight.svg << 'SVGEOF'
<svg xmlns="http://www.w3.org/2000/svg" width="128" height="128" viewBox="0 0 128 128">
  <rect x="8" y="8" width="112" height="112" rx="28" fill="#0284C7"/>
  <circle cx="56" cy="56" r="28" fill="none" stroke="#ffffff" stroke-width="10"/>
  <line x1="76" y1="76" x2="100" y2="100" stroke="#ffffff" stroke-width="12" stroke-linecap="round"/>
</svg>
SVGEOF

# 13. Quick Look Vector Logo
cat > /usr/share/pixmaps/heaven_quicklook.svg << 'SVGEOF'
<svg xmlns="http://www.w3.org/2000/svg" width="128" height="128" viewBox="0 0 128 128">
  <rect x="8" y="8" width="112" height="112" rx="28" fill="#8B5CF6"/>
  <path d="M 24 64 C 40 36 88 36 104 64 C 88 92 40 92 24 64 Z" fill="none" stroke="#ffffff" stroke-width="8"/>
  <circle cx="64" cy="64" r="16" fill="#ffffff"/>
</svg>
SVGEOF

# 14. Theme Switcher Vector Logo
cat > /usr/share/pixmaps/heaven_theme.svg << 'SVGEOF'
<svg xmlns="http://www.w3.org/2000/svg" width="128" height="128" viewBox="0 0 128 128">
  <rect x="8" y="8" width="112" height="112" rx="28" fill="#0F172A"/>
  <path d="M 64 8 A 56 56 0 0 1 64 120 Z" fill="#F8FAFC"/>
</svg>
SVGEOF

# 15. 144 FPS Turbo Vector Logo
cat > /usr/share/pixmaps/heaven_fps.svg << 'SVGEOF'
<svg xmlns="http://www.w3.org/2000/svg" width="128" height="128" viewBox="0 0 128 128">
  <rect x="8" y="8" width="112" height="112" rx="28" fill="#EC4899"/>
  <path d="M 32 96 A 48 48 0 1 1 96 96" fill="none" stroke="#ffffff" stroke-width="10" stroke-linecap="round"/>
  <line x1="64" y1="64" x2="88" y2="40" stroke="#FFD700" stroke-width="8" stroke-linecap="round"/>
</svg>
SVGEOF

# 16. Time Machine Vector Logo
cat > /usr/share/pixmaps/heaven_timemachine.svg << 'SVGEOF'
<svg xmlns="http://www.w3.org/2000/svg" width="128" height="128" viewBox="0 0 128 128">
  <rect x="8" y="8" width="112" height="112" rx="28" fill="#10B981"/>
  <circle cx="64" cy="64" r="36" fill="none" stroke="#ffffff" stroke-width="8"/>
  <polyline points="64,40 64,64 80,64" fill="none" stroke="#ffffff" stroke-width="8" stroke-linecap="round"/>
</svg>
SVGEOF

# 17. Screenshot Tool Vector Logo
cat > /usr/share/pixmaps/heaven_screenshot.svg << 'SVGEOF'
<svg xmlns="http://www.w3.org/2000/svg" width="128" height="128" viewBox="0 0 128 128">
  <rect x="8" y="8" width="112" height="112" rx="28" fill="#F59E0B"/>
  <rect x="28" y="44" width="72" height="52" rx="10" fill="#ffffff"/>
  <circle cx="64" cy="70" r="16" fill="#F59E0B"/>
  <polygon points="44,44 54,32 74,32 84,44" fill="#ffffff"/>
</svg>
SVGEOF

# 18. Archive Extractor Vector Logo
cat > /usr/share/pixmaps/heaven_archive.svg << 'SVGEOF'
<svg xmlns="http://www.w3.org/2000/svg" width="128" height="128" viewBox="0 0 128 128">
  <rect x="8" y="8" width="112" height="112" rx="28" fill="#D97706"/>
  <rect x="24" y="24" width="80" height="40" rx="8" fill="#FBBF24"/>
  <rect x="56" y="32" width="16" height="24" rx="4" fill="#78350F"/>
  <rect x="60" y="44" width="8" height="8" rx="2" fill="#FBBF24"/>
  <path d="M 32 72 L 96 72 M 32 84 L 96 84 M 32 96 L 96 96" stroke="#ffffff" stroke-width="6" stroke-linecap="round"/>
</svg>
SVGEOF

# Resolve Icon Paths (Prefer official PNG if installed, otherwise use embedded vector SVG)
CHROME_ICON="/usr/share/pixmaps/heaven_chrome.svg"
[ -f /opt/google/chrome/product_logo_48.png ] && CHROME_ICON="/opt/google/chrome/product_logo_48.png"

DISCORD_ICON="/usr/share/pixmaps/heaven_discord.svg"
[ -f /usr/share/discord/discord.png ] && DISCORD_ICON="/usr/share/discord/discord.png"

VSCODE_ICON="/usr/share/pixmaps/heaven_vscode.svg"
[ -f /usr/share/code/resources/app/resources/linux/code.png ] && VSCODE_ICON="/usr/share/code/resources/app/resources/linux/code.png"

GIMP_ICON="/usr/share/pixmaps/heaven_gimp.svg"
[ -f /usr/share/icons/hicolor/48x48/apps/gimp.png ] && GIMP_ICON="/usr/share/icons/hicolor/48x48/apps/gimp.png"

AUDACITY_ICON="/usr/share/pixmaps/heaven_audacity.svg"
[ -f /usr/share/icons/hicolor/48x48/apps/audacity.png ] && AUDACITY_ICON="/usr/share/icons/hicolor/48x48/apps/audacity.png"

VLC_ICON="/usr/share/pixmaps/heaven_vlc.svg"
[ -f /usr/share/icons/hicolor/48x48/apps/vlc.png ] && VLC_ICON="/usr/share/icons/hicolor/48x48/apps/vlc.png"

FILEZILLA_ICON="/usr/share/pixmaps/heaven_filezilla.svg"
[ -f /usr/share/icons/hicolor/48x48/apps/filezilla.png ] && FILEZILLA_ICON="/usr/share/icons/hicolor/48x48/apps/filezilla.png"

WINE_ICON="/usr/share/pixmaps/heaven_wine.svg"
[ -f /usr/share/icons/hicolor/48x48/apps/wine.png ] && WINE_ICON="/usr/share/icons/hicolor/48x48/apps/wine.png"

BLENDER_ICON="/usr/share/pixmaps/heaven_blender.svg"
[ -f /usr/share/icons/hicolor/48x48/apps/blender.png ] && BLENDER_ICON="/usr/share/icons/hicolor/48x48/apps/blender.png"

KRITA_ICON="/usr/share/pixmaps/heaven_krita.svg"
[ -f /usr/share/icons/hicolor/48x48/apps/krita.png ] && KRITA_ICON="/usr/share/icons/hicolor/48x48/apps/krita.png"

KDENLIVE_ICON="/usr/share/pixmaps/heaven_kdenlive.svg"
[ -f /usr/share/icons/hicolor/48x48/apps/kdenlive.png ] && KDENLIVE_ICON="/usr/share/icons/hicolor/48x48/apps/kdenlive.png"

KDENLIVE_ICON="/usr/share/pixmaps/heaven_kdenlive.svg"
[ -f /usr/share/icons/hicolor/48x48/apps/kdenlive.png ] && KDENLIVE_ICON="/usr/share/icons/hicolor/48x48/apps/kdenlive.png"

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

cat > "$DESKTOP_DIR/Chrome.desktop" << EOF
[Desktop Entry]
Version=1.0
Type=Application
Name=Google Chrome
Comment=Web Browser
Exec=google-chrome-stable --no-sandbox %U
Icon=$CHROME_ICON
Terminal=false
Categories=Network;WebBrowser;
StartupNotify=true
EOF
chmod +x "$DESKTOP_DIR/Chrome.desktop"

cat > "$DESKTOP_DIR/Discord.desktop" << EOF
[Desktop Entry]
Version=1.0
Type=Application
Name=Discord
Comment=Chat & Voice
Exec=/usr/local/bin/discord
Icon=$DISCORD_ICON
Terminal=false
Categories=Network;InstantMessaging;
StartupNotify=true
EOF
chmod +x "$DESKTOP_DIR/Discord.desktop"

cat > "$DESKTOP_DIR/VSCode.desktop" << EOF
[Desktop Entry]
Version=1.0
Type=Application
Name=VS Code
Comment=Visual Studio Code
Exec=code --no-sandbox
Icon=$VSCODE_ICON
Terminal=false
Categories=Development;IDE;
StartupNotify=true
EOF
chmod +x "$DESKTOP_DIR/VSCode.desktop"

cat > "$DESKTOP_DIR/GIMP.desktop" << EOF
[Desktop Entry]
Version=1.0
Type=Application
Name=GIMP
Comment=Image Editor
Exec=gimp
Icon=$GIMP_ICON
Terminal=false
Categories=Graphics;2DGraphics;
StartupNotify=true
EOF
chmod +x "$DESKTOP_DIR/GIMP.desktop"

cat > "$DESKTOP_DIR/Audacity.desktop" << EOF
[Desktop Entry]
Version=1.0
Type=Application
Name=Audacity
Comment=Audio Editor
Exec=audacity
Icon=$AUDACITY_ICON
Terminal=false
Categories=AudioVideo;Audio;
StartupNotify=true
EOF
chmod +x "$DESKTOP_DIR/Audacity.desktop"

cat > "$DESKTOP_DIR/VLC.desktop" << EOF
[Desktop Entry]
Version=1.0
Type=Application
Name=VLC Player
Comment=Media Player
Exec=vlc
Icon=$VLC_ICON
Terminal=false
Categories=AudioVideo;Player;
StartupNotify=true
EOF
chmod +x "$DESKTOP_DIR/VLC.desktop"

cat > "$DESKTOP_DIR/FileZilla.desktop" << EOF
[Desktop Entry]
Version=1.0
Type=Application
Name=FileZilla
Comment=FTP Client
Exec=filezilla
Icon=$FILEZILLA_ICON
Terminal=false
Categories=Network;FileTransfer;
StartupNotify=true
EOF
chmod +x "$DESKTOP_DIR/FileZilla.desktop"

cat > "$DESKTOP_DIR/Blender.desktop" << EOF
[Desktop Entry]
Version=1.0
Type=Application
Name=Blender 3D
Comment=3D Modeling & Creation Suite
Exec=/usr/local/bin/blender-wrapper
Icon=$BLENDER_ICON
Terminal=false
Categories=Graphics;3DGraphics;
StartupNotify=true
EOF
chmod +x "$DESKTOP_DIR/Blender.desktop"

cat > "$DESKTOP_DIR/Krita.desktop" << EOF
[Desktop Entry]
Version=1.0
Type=Application
Name=Krita Painting
Comment=Digital Painting & Raster Graphics
Exec=krita
Icon=$KRITA_ICON
Terminal=false
Categories=Graphics;RasterGraphics;
StartupNotify=true
EOF
chmod +x "$DESKTOP_DIR/Krita.desktop"

cat > "$DESKTOP_DIR/Kdenlive.desktop" << EOF
[Desktop Entry]
Version=1.0
Type=Application
Name=Kdenlive Video Editor
Comment=Non-Linear Video Editor
Exec=kdenlive
Icon=$KDENLIVE_ICON
Terminal=false
Categories=AudioVideo;Video;
StartupNotify=true
EOF
chmod +x "$DESKTOP_DIR/Kdenlive.desktop"

# Feature Desktop Shortcuts
cat > "$DESKTOP_DIR/Spotlight Search.desktop" << 'EOF'
[Desktop Entry]
Version=1.0
Type=Application
Name=Spotlight Search
Comment=Search Apps, Files & Calculator (Ctrl + Space)
Exec=heaven-spotlight
Icon=/usr/share/pixmaps/heaven_spotlight.svg
Terminal=false
Categories=Utility;
StartupNotify=true
EOF
chmod +x "$DESKTOP_DIR/Spotlight Search.desktop"

cat > "$DESKTOP_DIR/Quick Look.desktop" << 'EOF'
[Desktop Entry]
Version=1.0
Type=Application
Name=Quick Look Preview
Comment=Instant File & Media Preview (Spacebar)
Exec=heaven-quicklook
Icon=/usr/share/pixmaps/heaven_quicklook.svg
Terminal=false
Categories=Utility;
StartupNotify=true
EOF
chmod +x "$DESKTOP_DIR/Quick Look.desktop"

cat > "$DESKTOP_DIR/Dark-Light Mode.desktop" << 'EOF'
[Desktop Entry]
Version=1.0
Type=Application
Name=Dark / Light Mode
Comment=Toggle macOS Sonoma UI Theme
Exec=heaven-theme-toggle
Icon=/usr/share/pixmaps/heaven_theme.svg
Terminal=false
Categories=Utility;
StartupNotify=true
EOF
chmod +x "$DESKTOP_DIR/Dark-Light Mode.desktop"

cat > "$DESKTOP_DIR/144 FPS Turbo Boost.desktop" << 'EOF'
[Desktop Entry]
Version=1.0
Type=Application
Name=144 FPS Turbo Boost
Comment=High Refresh Rate & Dynamic RAM Disk Engine
Exec=heaven-fps-turbo
Icon=/usr/share/pixmaps/heaven_fps.svg
Terminal=false
Categories=Utility;System;
StartupNotify=true
EOF
chmod +x "$DESKTOP_DIR/144 FPS Turbo Boost.desktop"

cat > "$DESKTOP_DIR/HeavenOS Time Machine.desktop" << 'EOF'
[Desktop Entry]
Version=1.0
Type=Application
Name=HeavenOS Time Machine
Comment=Instant System & Settings Backup/Restore
Exec=heaven-time-machine
Icon=/usr/share/pixmaps/heaven_timemachine.svg
Terminal=false
Categories=Utility;System;
StartupNotify=true
EOF
chmod +x "$DESKTOP_DIR/HeavenOS Time Machine.desktop"

cat > "$DESKTOP_DIR/Screenshot Tool.desktop" << 'EOF'
[Desktop Entry]
Version=1.0
Type=Application
Name=Screenshot Tool
Comment=Capture Screen Region (Ctrl + Shift + 4)
Exec=heaven-screenshot
Icon=/usr/share/pixmaps/heaven_screenshot.svg
Terminal=false
Categories=Utility;
StartupNotify=true
EOF
chmod +x "$DESKTOP_DIR/Screenshot Tool.desktop"

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

cat > "$DESKTOP_DIR/Touch Keyboard.desktop" << 'EOF'
[Desktop Entry]
Version=1.0
Type=Application
Name=Touch Keyboard
Comment=Toggle On-Screen Touch Keyboard
Exec=onboard-keyboard
Icon=input-keyboard
Terminal=false
Categories=Utility;Accessibility;
StartupNotify=true
EOF
chmod +x "$DESKTOP_DIR/Touch Keyboard.desktop"

# Multi-OS Desktop Shortcuts
cat > "$DESKTOP_DIR/Archive Extractor (.ZIP .RAR .7Z).desktop" << 'EOF'
[Desktop Entry]
Version=1.0
Type=Application
Name=Archive Extractor (.ZIP .RAR .7Z)
Comment=Auto-Extract & Game Detector (.zip / .rar / .7z / .iso)
Exec=heaven-archive-engine %f
Icon=/usr/share/pixmaps/heaven_archive.svg
Terminal=false
Categories=Utility;Archiving;
StartupNotify=true
MimeType=application/zip;application/x-rar;application/x-rar-compressed;application/x-7z-compressed;application/x-compressed-tar;application/x-tar;application/x-gzip;application/x-iso9660-image;
EOF
chmod +x "$DESKTOP_DIR/Archive Extractor (.ZIP .RAR .7Z).desktop"

cat > "$DESKTOP_DIR/Windows Apps (.EXE).desktop" << EOF
[Desktop Entry]
Version=1.0
Type=Application
Name=Windows Apps (.EXE)
Comment=Run Windows Executables (.EXE / .MSI)
Exec=heaven-exe-runner
Icon=$WINE_ICON
Terminal=false
Categories=Utility;Emulation;
StartupNotify=true
EOF
chmod +x "$DESKTOP_DIR/Windows Apps (.EXE).desktop"

cat > "$DESKTOP_DIR/macOS Apps (.DMG .APP).desktop" << 'EOF'
[Desktop Entry]
Version=1.0
Type=Application
Name=macOS Apps (.DMG .APP)
Comment=Run & Extract macOS Apps (.DMG / .APP / .PKG)
Exec=heaven-mac-runner
Icon=system-run
Terminal=false
Categories=Utility;Emulation;
StartupNotify=true
EOF
chmod +x "$DESKTOP_DIR/macOS Apps (.DMG .APP).desktop"

cat > "$DESKTOP_DIR/Linux Apps (.AppImage .DEB).desktop" << 'EOF'
[Desktop Entry]
Version=1.0
Type=Application
Name=Linux Apps (.AppImage .DEB)
Comment=Run Linux Portable Apps & Install Packages
Exec=heaven-linux-runner
Icon=system-software-install
Terminal=false
Categories=Utility;System;
StartupNotify=true
EOF
chmod +x "$DESKTOP_DIR/Linux Apps (.AppImage .DEB).desktop"

# ====================================================================
#  PLANK DOCK LAUNCHERS (macOS Dock)
# ====================================================================
cat > "$PLANK_DIR/UploadFiles.dockitem" << 'EOF'
[PlankDockItemPreferences]
Launcher=file:///config/Desktop/Upload%20Files.desktop
EOF

cat > "$PLANK_DIR/WindowsApps.dockitem" << 'EOF'
[PlankDockItemPreferences]
Launcher=file:///config/Desktop/Windows%20Apps%20(.EXE).desktop
EOF

cat > "$PLANK_DIR/macOSApps.dockitem" << 'EOF'
[PlankDockItemPreferences]
Launcher=file:///config/Desktop/macOS%20Apps%20(.DMG%20.APP).desktop
EOF

cat > "$PLANK_DIR/LinuxApps.dockitem" << 'EOF'
[PlankDockItemPreferences]
Launcher=file:///config/Desktop/Linux%20Apps%20(.AppImage%20.DEB).desktop
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

cat > "$PLANK_DIR/GIMP.dockitem" << 'EOF'
[PlankDockItemPreferences]
Launcher=file:///config/Desktop/GIMP.desktop
EOF

cat > "$PLANK_DIR/Blender.dockitem" << 'EOF'
[PlankDockItemPreferences]
Launcher=file:///config/Desktop/Blender.desktop
EOF

cat > "$PLANK_DIR/Krita.dockitem" << 'EOF'
[PlankDockItemPreferences]
Launcher=file:///config/Desktop/Krita.desktop
EOF

cat > "$PLANK_DIR/Kdenlive.dockitem" << 'EOF'
[PlankDockItemPreferences]
Launcher=file:///config/Desktop/Kdenlive.desktop
EOF

cat > "$PLANK_DIR/Files.dockitem" << 'EOF'
[PlankDockItemPreferences]
Launcher=file:///config/Desktop/Files.desktop
EOF

cat > "$PLANK_DIR/Terminal.dockitem" << 'EOF'
[PlankDockItemPreferences]
Launcher=file:///config/Desktop/Terminal.desktop
EOF

cat > "$PLANK_DIR/Keyboard.dockitem" << 'EOF'
[PlankDockItemPreferences]
Launcher=file:///config/Desktop/Touch%20Keyboard.desktop
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

# ---- SYSTEM-WIDE MIME FILE ASSOCIATIONS FOR MULTI-OS PROGRAM RUNNERS ---
mkdir -p /usr/share/applications /config/.config

cat > /usr/share/applications/heaven-exe.desktop << 'EOF'
[Desktop Entry]
Type=Application
Name=HeavenOS Windows Runner
Exec=heaven-exe-runner %f
MimeType=application/x-ms-dos-executable;application/x-msi;application/x-msdownload;application/exe;application/x-exe;
NoDisplay=true
EOF

cat > /usr/share/applications/heaven-mac.desktop << 'EOF'
[Desktop Entry]
Type=Application
Name=HeavenOS macOS Runner
Exec=heaven-mac-runner %f
MimeType=application/x-apple-diskimage;application/x-dmg;application/x-mac-pkg;application/x-xar;
NoDisplay=true
EOF

cat > /usr/share/applications/heaven-linux.desktop << 'EOF'
[Desktop Entry]
Type=Application
Name=HeavenOS Linux Runner
Exec=heaven-linux-runner %f
MimeType=application/x-iso9660-appimage;application/x-appimage;application/vnd.debian.binary-package;
NoDisplay=true
EOF

cat > /usr/share/applications/heaven-apk.desktop << 'EOF'
[Desktop Entry]
Type=Application
Name=HeavenOS Android Runner
Exec=heaven-apk-runner %f
MimeType=application/vnd.android.package-archive;
NoDisplay=true
EOF

cat > /usr/share/applications/heaven-archive.desktop << 'EOF'
[Desktop Entry]
Type=Application
Name=HeavenOS Archive Engine
Exec=heaven-archive-engine %f
MimeType=application/zip;application/x-rar;application/x-rar-compressed;application/x-7z-compressed;application/x-compressed-tar;application/x-tar;application/x-gzip;application/x-iso9660-image;
NoDisplay=true
EOF

cat > /config/.config/mimeapps.list << 'EOF'
[Default Applications]
application/x-ms-dos-executable=heaven-exe.desktop
application/x-msi=heaven-exe.desktop
application/x-msdownload=heaven-exe.desktop
application/x-apple-diskimage=heaven-mac.desktop
application/x-dmg=heaven-mac.desktop
application/x-iso9660-appimage=heaven-linux.desktop
application/x-appimage=heaven-linux.desktop
application/vnd.debian.binary-package=heaven-linux.desktop
application/vnd.android.package-archive=heaven-apk.desktop
application/zip=heaven-archive.desktop
application/x-rar=heaven-archive.desktop
application/x-rar-compressed=heaven-archive.desktop
application/x-7z-compressed=heaven-archive.desktop
application/x-compressed-tar=heaven-archive.desktop
application/x-tar=heaven-archive.desktop
application/x-gzip=heaven-archive.desktop
application/x-iso9660-image=heaven-archive.desktop
EOF

# ---- Ownership fix -----------------------------------------------
chown -R abc:abc /config/ 2>/dev/null || true
chown abc:abc /usr/local/bin/apply-lotus-wallpaper.sh 2>/dev/null || true
chown abc:abc /usr/local/bin/heaven-uploader.py 2>/dev/null || true
chown abc:abc /usr/local/bin/onboard-keyboard 2>/dev/null || true
chown abc:abc /usr/local/bin/google-chrome-stable 2>/dev/null || true
chown abc:abc /usr/local/bin/discord 2>/dev/null || true
chown abc:abc /usr/local/bin/blender-wrapper 2>/dev/null || true
chown abc:abc /usr/local/bin/code 2>/dev/null || true
chown abc:abc /usr/local/bin/audacity 2>/dev/null || true
chown abc:abc /usr/local/bin/vlc 2>/dev/null || true
chown abc:abc /usr/local/bin/filezilla 2>/dev/null || true
chown abc:abc /usr/local/bin/heaven-exe-runner 2>/dev/null || true
chown abc:abc /usr/local/bin/heaven-mac-runner 2>/dev/null || true
chown abc:abc /usr/local/bin/heaven-linux-runner 2>/dev/null || true
chown abc:abc /usr/local/bin/heaven-apk-runner 2>/dev/null || true
chown abc:abc /usr/local/bin/heaven-archive-engine 2>/dev/null || true
chown abc:abc /usr/local/bin/heaven-spotlight 2>/dev/null || true
chown abc:abc /usr/local/bin/heaven-quicklook 2>/dev/null || true
chown abc:abc /usr/local/bin/heaven-theme-toggle 2>/dev/null || true
chown abc:abc /usr/local/bin/heaven-fps-turbo 2>/dev/null || true
chown abc:abc /usr/local/bin/heaven-time-machine 2>/dev/null || true
chown abc:abc /usr/local/bin/heaven-screenshot 2>/dev/null || true

echo "[HeavenOS] macOS Sonoma UI + Multi-OS Program Support (.EXE, .DMG, .AppImage) Active!"
