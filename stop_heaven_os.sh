#!/bin/bash
# ====================================================================
#  HeavenOS - Shutdown Script
#  Safely stop aur delete karo HeavenOS container
# ====================================================================

echo ""
echo "======================================================================"
echo "         HeavenOS - Shutdown"
echo "======================================================================"
echo ""

echo "[1] Cloudflare tunnel band karne ke liye Ctrl+C dabao (agar chal raha hai)"
echo ""
echo "[2] HeavenOS container stop aur delete ho raha hai..."

docker rm -f heaven-os

echo ""
echo "HeavenOS successfully band ho gaya!"
echo "Sab kuch clean hai."
echo "======================================================================"
