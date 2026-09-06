#!/bin/bash
# ====================================================================
#  HeavenOS - Multi-Tenant Manager & Deployment Script
#  Manage isolated Cloud PCs for multiple clients
# ====================================================================

ACTION="$1"
CLIENT_NAME="$2"
PORT="$3"

# Handle shorthand syntax: `bash create_client_pc.sh rahul 8888`
if [[ "$ACTION" != "create" && "$ACTION" != "list" && "$ACTION" != "stop" && "$ACTION" != "delete" && "$ACTION" != "tunnel" && -n "$ACTION" && -n "$CLIENT_NAME" ]]; then
    PORT="$CLIENT_NAME"
    CLIENT_NAME="$ACTION"
    ACTION="create"
fi

show_usage() {
    echo ""
    echo "======================================================================"
    echo "  HeavenOS Multi-Tenant Cloud PC Manager"
    echo "======================================================================"
    echo "  Usage:"
    echo "    1. Create Cloud PC : bash create_client_pc.sh create <client_name> <port>"
    echo "                         (shorthand: bash create_client_pc.sh <client_name> <port>)"
    echo "    2. List Clients    : bash create_client_pc.sh list"
    echo "    3. Stop Client     : bash create_client_pc.sh stop <client_name>"
    echo "    4. Delete Client   : bash create_client_pc.sh delete <client_name>"
    echo "    5. Public Tunnel   : bash create_client_pc.sh tunnel <client_name>"
    echo ""
    echo "  Examples:"
    echo "    bash create_client_pc.sh rahul 8888"
    echo "    bash create_client_pc.sh amit 8889"
    echo "    bash create_client_pc.sh list"
    echo "    bash create_client_pc.sh stop rahul"
    echo "    bash create_client_pc.sh delete rahul"
    echo "    bash create_client_pc.sh tunnel rahul"
    echo "======================================================================"
    echo ""
}

if [ -z "$ACTION" ]; then
    show_usage
    exit 1
fi

case "$ACTION" in
    list)
        echo ""
        echo "======================================================================"
        echo "  Active HeavenOS Client Workstations"
        echo "======================================================================"
        docker ps --filter "name=heaven-os" --format "table {{.Names}}\t{{.Ports}}\t{{.Status}}"
        echo "======================================================================"
        echo ""
        ;;

    stop)
        if [ -z "$CLIENT_NAME" ]; then
            echo "ERROR: Client name required! Example: bash create_client_pc.sh stop rahul"
            exit 1
        fi
        CONTAINER_NAME="heaven-os-${CLIENT_NAME}"
        echo "[→] Stopping Cloud PC for ${CLIENT_NAME} (${CONTAINER_NAME})..."
        docker stop "${CONTAINER_NAME}"
        echo "[✓] Stopped ${CONTAINER_NAME}!"
        ;;

    delete)
        if [ -z "$CLIENT_NAME" ]; then
            echo "ERROR: Client name required! Example: bash create_client_pc.sh delete rahul"
            exit 1
        fi
        CONTAINER_NAME="heaven-os-${CLIENT_NAME}"
        echo "[→] Removing Cloud PC for ${CLIENT_NAME} (${CONTAINER_NAME})..."
        docker rm -f "${CONTAINER_NAME}"
        echo "[✓] Deleted ${CONTAINER_NAME}!"
        ;;

    tunnel)
        if [ -z "$CLIENT_NAME" ]; then
            echo "ERROR: Client name required! Example: bash create_client_pc.sh tunnel rahul"
            exit 1
        fi
        CONTAINER_NAME="heaven-os-${CLIENT_NAME}"
        HOST_PORT=$(docker port "${CONTAINER_NAME}" 3000 2>/dev/null | head -n 1 | cut -d: -f2)
        if [ -z "$HOST_PORT" ]; then
            echo "ERROR: Could not find active port for container ${CONTAINER_NAME}!"
            exit 1
        fi
        echo "======================================================================"
        echo "  Launching Cloudflare Tunnel for ${CLIENT_NAME} (Port ${HOST_PORT})..."
        echo "  Press Ctrl+C to stop tunnel."
        echo "======================================================================"
        curl -L --output cloudflared https://github.com/cloudflare/cloudflared/releases/latest/download/cloudflared-linux-amd64 2>/dev/null
        chmod +x cloudflared
        ./cloudflared tunnel --url "http://localhost:${HOST_PORT}"
        ;;

    create)
        if [ -z "$CLIENT_NAME" ] || [ -z "$PORT" ]; then
            echo "ERROR: Missing client name or port!"
            show_usage
            exit 1
        fi

        CONTAINER_NAME="heaven-os-${CLIENT_NAME}"

        echo ""
        echo "======================================================================"
        echo "  Deploying Isolated HeavenOS Cloud PC for: ${CLIENT_NAME}"
        echo "  Target Port: ${PORT}"
        echo "======================================================================"
        echo ""

        # Navigate to directory if needed
        if [ -d "HeavenOS" ]; then
            cd HeavenOS
        elif [ -d "heavon-os" ]; then
            cd heavon-os
        fi

        # Ensure image exists or build it
        if ! docker image inspect heaven-os &>/dev/null; then
            echo "[→] Building HeavenOS Docker image..."
            docker build -t heaven-os .
        fi

        echo "[→] Starting container: ${CONTAINER_NAME} on Port ${PORT}..."

        docker rm -f "${CONTAINER_NAME}" 2>/dev/null

        docker run -d \
            --name="${CONTAINER_NAME}" \
            -p "${PORT}:3000" \
            --shm-size="1gb" \
            -e PUID=1000 \
            -e PGID=1000 \
            -e TZ=Asia/Kolkata \
            -e TITLE="HeavenOS - ${CLIENT_NAME}" \
            heaven-os

        if [ $? -ne 0 ]; then
            echo "ERROR: Failed to launch Cloud PC for ${CLIENT_NAME}!"
            exit 1
        fi

        echo ""
        echo "======================================================================"
        echo "  [✓] HeavenOS Cloud PC Successfully Launched for: ${CLIENT_NAME}"
        echo "  Access Link: http://localhost:${PORT}"
        echo "  Container Name: ${CONTAINER_NAME}"
        echo "  Browser Title: HeavenOS - ${CLIENT_NAME}"
        echo "======================================================================"
        echo ""
        ;;

    *)
        show_usage
        exit 1
        ;;
esac
