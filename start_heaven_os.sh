#!/bin/bash
# ====================================================================
#  HeavenOS - Startup Script (OPTIMIZED - fast launch)
# ====================================================================

echo ""
echo "======================================================================"
echo "         HeavenOS - Arch Linux XFCE Desktop Launcher"
echo "======================================================================"
echo ""

# ---- STEP 1: Check Docker ------------------------------------------
if ! command -v docker &> /dev/null; then
    echo "ERROR: Docker nahi mila! Google Cloud Shell pe jao."
    exit 1
fi

# ---- STEP 2: Image check - sirf pehli baar build hoga! ------------
if docker image inspect heaven-os &>/dev/null; then
    echo "[✓] HeavenOS image already hai — seedha launch ho raha hai!"
else
    echo "[!] Pehli baar hai — image build ho rahi hai (5-10 min)..."
    echo "    (Agli baar seedha launch hoga!)"
    echo ""
    docker build -t heaven-os .
    if [ $? -ne 0 ]; then
        echo "ERROR: Build fail! Check karo Dockerfile."
        exit 1
    fi
    echo "[✓] Image build ho gayi!"
fi

echo ""

# ---- STEP 3: Container run karo -----------------------------------
echo "[→] HeavenOS container start ho raha hai..."

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
    echo "ERROR: Container start nahi hua!"
    exit 1
fi

echo "[✓] Container start ho gaya!"
echo ""

# ---- STEP 4: Cloudflare Tunnel ------------------------------------
echo "[→] Cloudflare Tunnel download ho raha hai..."
curl -sL --output cloudflared \
    https://github.com/cloudflare/cloudflared/releases/latest/download/cloudflared-linux-amd64 \
    && chmod +x cloudflared
echo "[✓] Done!"
echo ""

# ---- STEP 5: Public link ------------------------------------------
echo "======================================================================"
echo "  Link aa rahi hai... Browser ya phone mein kholo!"
echo "  TERMINAL BAND MAT KARNA!"
echo "======================================================================"
echo ""

./cloudflared tunnel --url http://localhost:8888
