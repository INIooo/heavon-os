#!/bin/bash
# ====================================================================
#  HeavenOS - Startup Script
# ====================================================================

echo ""
echo "======================================================================"
echo "         HeavenOS - Ubuntu XFCE Desktop Launcher"
echo "======================================================================"
echo ""

# Navigate to HeavenOS directory if needed
if [ -d "HeavenOS" ]; then
    cd HeavenOS
elif [ -d "heavon-os" ]; then
    cd heavon-os
fi

# ---- STEP 1: Check Docker ------------------------------------------
if ! command -v docker &> /dev/null; then
    echo "ERROR: Docker nahi mila! Google Cloud Shell pe jao."
    exit 1
fi

# ---- STEP 2: Build Image -------------------------------------------
echo "[→] Building / Updating HeavenOS Docker image..."
docker build -t heaven-os .
if [ $? -ne 0 ]; then
    echo "ERROR: Build fail! Check karo Dockerfile."
    exit 1
fi
echo "[✓] Image ready!"

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
    -e TITLE="HeavenOS Cloud Workstation ☁️" \
    heaven-os

if [ $? -ne 0 ]; then
    echo "ERROR: Container start nahi hua!"
    exit 1
fi

echo ""
echo "======================================================================"
echo "  [✓] HeavenOS Container Successfully Started!"
echo "  Access Link: http://localhost:8888 (Port 8888)"
echo "======================================================================"
echo ""
