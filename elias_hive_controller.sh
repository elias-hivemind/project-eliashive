#!/bin/bash

# ELIAS HIVE CONTROLLER — Manage Sentinel, API Bridge, Heartbeat

# === CONFIG ===
BASE_DIR="$HOME/eliashive_repo"
LOG_DIR="$BASE_DIR/logs"
MEMORY_CORE="$BASE_DIR/memory_core"
INSIGHTS_DIR="$MEMORY_CORE/insights"
GRAPH_DIR="$MEMORY_CORE/graph"
GITHUB_INTEL="$BASE_DIR/github_intel"
BACKUP_DIR="$BASE_DIR/backups"
API_DIR="$BASE_DIR/api_bridge"
SENTINEL_SCRIPT="$BASE_DIR/ELIAS_HIVE_SENTINEL_BUILD.sh"
BRAINFED_SCRIPT="$BASE_DIR/brainfeed.sh"
API_SCRIPT="$API_DIR/api_bridge.py"
AWS_CREDS="$HOME/.aws/credentials"

mkdir -p "$LOG_DIR" "$API_DIR"

log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" >> "$LOG_DIR/controller_$(date '+%Y%m%d').log"
}

check_dependencies() {
    local deps=("jq" "curl" "rclone" "flask")
    for dep in "${deps[@]}"; do
        if ! command -v "$dep" &> /dev/null; then
            echo "[INFO] Installing missing dependency: $dep"
            if [ "$dep" = "flask" ]; then pip3 install flask; else sudo yum install -y "$dep" || sudo apt-get install -y "$dep"; fi
        fi
    done
}

run_it() {
    log "RUN IT: Deploying Elias Hive Sentinel"
    chmod +x "$SENTINEL_SCRIPT" "$BRAINFED_SCRIPT"
    if ! pgrep -f "$SENTINEL_SCRIPT" > /dev/null; then
        nohup "$SENTINEL_SCRIPT" &> "$LOG_DIR/sentinel.out" &
        sleep 2
    fi
    echo "[✔] Sentinel launched. Monitoring tips:"
    echo "- tail -f $LOG_DIR/sentinel_$(date '+%Y%m%d').log"
    echo "- curl http://localhost:5050/insights"
}

status() {
    log "STATUS: Generating system snapshot"
    echo "---- Running Processes ----"
    ps aux | grep -E 'nova_guardian|intel_harvester|github_sync|drive_sync|brainfeed|api_bridge' | grep -v grep || echo "None"
    echo
    echo "---- Recent Logs ----"
    tail -n 5 "$LOG_DIR/sentinel_$(date '+%Y%m%d').log" 2>/dev/null || echo "No Sentinel logs."
    tail -n 5 "$LOG_DIR/api_bridge.log" 2>/dev/null || echo "No API logs."
}

start_api() {
    log "API: Launching Nova-Elias Bridge"
    if ! pgrep -f "$API_SCRIPT" > /dev/null; then
        bash "$BASE_DIR/install_eliasnova_api.sh"
        sleep 2
    fi
    echo "[✔] Nova↔Elias API Bridge running on port 5050"
}

restart() {
    log "RESTART: Restarting systems"
    pkill -f "$SENTINEL_SCRIPT" || true
    pkill -f "$API_SCRIPT" || true
    sleep 2
    nohup "$SENTINEL_SCRIPT" &> "$LOG_DIR/sentinel.out" &
    bash "$BASE_DIR/install_eliasnova_api.sh"
    echo "[✔] Systems Restarted"
}

case "${1,,}" in
    run) check_dependencies; run_it ;;
    status) status ;;
    api) start_api ;;
    restart) restart ;;
    *) echo "Usage: $0 [run|status|api|restart]"; exit 1 ;;
esac
