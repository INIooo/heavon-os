#!/bin/bash
# ====================================================================
#  HeavenOS - Startup Script (60 FPS Performance Mode)
# ====================================================================

echo ""
echo "======================================================================"
echo "         HeavenOS - Ubuntu XFCE Desktop Launcher (60 FPS Mode)"
echo "======================================================================"
echo ""

# ---- STEP 1: Check Docker ------------------------------------------
if ! command -v docker &> /dev/null; then
    echo "ERROR: Docker nahi mila! Google Cloud Shell pe jao."
    exit 1
fi

# ---- STEP 2: Build Image -------------------------------------------
echo "[→] Building / Updating HeavenOS Docker image..."
export DOCKER_BUILDKIT=1
docker build -t heaven-os .
if [ $? -ne 0 ]; then
    echo "ERROR: Build fail! Check karo Dockerfile."
    exit 1
fi
echo "[✓] Image ready!"

echo ""

# ---- STEP 3: Container run karo (60 FPS Performance Tuned) -------
echo "[→] HeavenOS container start ho raha hai (60 FPS Mode)..."

docker rm -f heaven-os 2>/dev/null

docker run -d \
    --name=heaven-os \
    -p 8888:3000 \
    --shm-size="2gb" \
    -e PUID=1000 \
    -e PGID=1000 \
    -e TZ=Asia/Kolkata \
    -e TITLE=HeavenOS \
    -e CUSTOM_FRAME_RATE=60 \
    -e FRAME_RATE=60 \
    -e WEBTOP_FPS=60 \
    -e MAX_FPS=60 \
    heaven-os

if [ $? -ne 0 ]; then
    echo "ERROR: Container start nahi hua!"
    exit 1
fi

echo ""
echo "======================================================================"
echo "  [✓] HeavenOS Container Started in 60 FPS High-Performance Mode!"
echo "  Access Link: http://localhost:8888 (Port 8888)"
echo "======================================================================"
echo ""
