#!/bin/bash
# ====================================================================
#  HeavenOS - Startup Script
#  Steps same as: how to start up.txt
#  Ye script Google Cloud Shell pe chalao
# ====================================================================

echo ""
echo "======================================================================"
echo "         HeavenOS - Arch Linux XFCE Desktop Launcher"
echo "         Wallpaper: Lotus (Permanent)"
echo "======================================================================"
echo ""

# ---- STEP 1: Check Docker ------------------------------------------
echo "[STEP 1] Docker check kar raha hoon..."
if ! command -v docker &> /dev/null; then
    echo "ERROR: Docker nahi mila! Google Cloud Shell pe Docker already hota hai."
    echo "       Google Cloud Shell pe jao: https://console.cloud.google.com/"
    exit 1
fi
echo "         Docker mil gaya!"
echo ""

# ---- STEP 2: HeavenOS Build karo (Lotus wallpaper ke saath) --------
echo "[STEP 2] HeavenOS image build kar raha hoon (Lotus wallpaper permanent set hogi)..."
echo "         Ye ek baar hoga, thoda time lagega..."
echo ""

docker build -t heaven-os .

if [ $? -ne 0 ]; then
    echo ""
    echo "ERROR: Docker build fail ho gaya!"
    echo "       Make sure Dockerfile aur Lotus-Wallpaper-Upscaled16x.png"
    echo "       ek hi folder mein hain."
    exit 1
fi

echo ""
echo "HeavenOS image successfully build ho gayi!"
echo ""

# ---- STEP 3: HeavenOS Container Run karo ---------------------------
echo "[STEP 3] HeavenOS container start kar raha hoon..."
echo ""

# Pehle se chal raha ho toh delete karo
docker rm -f heaven-os 2>/dev/null

docker run -d \
    --name=heaven-os \
    -p 8888:3000 \
    --shm-size="1gb" \
    -e PUID=1000 \
    -e PGID=1000 \
    -e TZ=Asia/Kolkata \
    -e TITLE=HeavenOS \
    heaven-os

if [ $? -ne 0 ]; then
    echo ""
    echo "ERROR: Container start nahi hua!"
    exit 1
fi

echo ""
echo "Container successfully start ho gaya!"
echo ""

# ---- STEP 4: Cloudflare Tunnel Download ---------------------------
echo "[STEP 4] Cloudflare Tunnel download kar raha hoon..."
echo ""

curl -L --output cloudflared \
    https://github.com/cloudflare/cloudflared/releases/latest/download/cloudflared-linux-amd64 \
    && chmod +x cloudflared

echo ""
echo "Cloudflared download ho gaya!"
echo ""

# ---- STEP 5: Public Link Generate karo ----------------------------
echo "[STEP 5] Public link generate kar raha hoon..."
echo "         3-5 seconds mein ek link dikhegi (trycloudflare.com)"
echo "         Ye link kisi bhi browser ya phone pe khul sakti hai!"
echo ""
echo "======================================================================"
echo "  IMPORTANT: Is terminal ko BAND MAT KARNA jab tak use karo"
echo "======================================================================"
echo ""

./cloudflared tunnel --url http://localhost:8888
