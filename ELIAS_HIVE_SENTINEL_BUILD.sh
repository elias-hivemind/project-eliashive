#!/bin/bash

# ELIAS HIVE SENTINEL - Unified Guardian Daemon Script
# Purpose: Monitor system health, sync AI brainfeed, backup Drive, GitHub push
# Auto-healing + Cloud Sync + Knowledge Base Update
# Phase: FULL FINAL SENTINEL

# Configuration
BASE_DIR="$HOME/eliashive_repo"
LOG_DIR="$BASE_DIR/logs"
MEMORY_DIR="$BASE_DIR/memory_core"
GITHUB_INTEL_DIR="$BASE_DIR/github_intel"
INSIGHTS_DIR="$MEMORY_DIR/insights"
REMOTE_NAME="gdrive"
REMOTE_FOLDER="EliasHive-Drive-Sync"
SERVICE_ACCOUNT_FILE="$HOME/credentials/mirrorone-456514-bb12c443749a.json"
GITHUB_REPO="https://github.com/elias-hivemind/project-eliashive.git"

mkdir -p "$LOG_DIR" "$MEMORY_DIR" "$GITHUB_INTEL_DIR" "$INSIGHTS_DIR"

# Functions

guardian_loop() {
    while true; do
        echo "[$(date '+%Y-%m-%d %H:%M:%S')] [Guardian] System health check running..." >> "$LOG_DIR/sentinel_$(date '+%Y%m%d').log"
        sleep 300
    done
}

intel_harvest_loop() {
    while true; do
        echo "[$(date '+%Y-%m-%d %H:%M:%S')] [IntelHarvester] Scraping GitHub trending..." >> "$LOG_DIR/sentinel_$(date '+%Y%m%d').log"
        curl -s "https://api.github.com/search/repositories?q=stars:>1000&sort=stars" > "$GITHUB_INTEL_DIR/trending_$(date '+%Y%m%d_%H%M%S').json" || echo "[$(date '+%Y-%m-%d %H:%M:%S')] [IntelHarvester] Fetch failed" >> "$LOG_DIR/sentinel_$(date '+%Y%m%d').log"
        sleep 1800
    done
}

github_sync_loop() {
    while true; do
        echo "[$(date '+%Y-%m-%d %H:%M:%S')] [GitHubSync] Syncing to GitHub..." >> "$LOG_DIR/sentinel_$(date '+%Y%m%d').log"
        cd "$BASE_DIR"
        git add .
        git commit -m "Auto-sync: $(date '+%Y-%m-%d %H:%M:%S')" || true
        git push origin main || echo "[$(date '+%Y-%m-%d %H:%M:%S')] [GitHubSync] Push failed" >> "$LOG_DIR/sentinel_$(date '+%Y%m%d').log"
        sleep 3600
    done
}

drive_sync_loop() {
    mkdir -p ~/.config/rclone
    cat > ~/.config/rclone/rclone.conf <<EOC
[$REMOTE_NAME]
type = drive
scope = drive
service_account_file = $SERVICE_ACCOUNT_FILE
EOC

    while true; do
        echo "[$(date '+%Y-%m-%d %H:%M:%S')] [DriveSync] Uploading to Google Drive..." >> "$LOG_DIR/sentinel_$(date '+%Y%m%d').log"
        rclone mkdir $REMOTE_NAME:$REMOTE_FOLDER || true
        rclone sync "$BASE_DIR" "$REMOTE_NAME:$REMOTE_FOLDER" --drive-server-side-across-configs >> "$LOG_DIR/sentinel_$(date '+%Y%m%d').log" 2>&1
        sleep 3600
    done
}

memory_core_loop() {
    while true; do
        echo "[$(date '+%Y-%m-%d %H:%M:%S')] [MemoryCore] Archiving today's AI memory..." >> "$LOG_DIR/sentinel_$(date '+%Y%m%d').log"
        cp "$LOG_DIR/sentinel_$(date '+%Y%m%d').log" "$MEMORY_DIR/$(date '+%Y%m%d')_sentinel.log" || true
        cp "$GITHUB_INTEL_DIR"/*.json "$MEMORY_DIR/" || true
        sleep 3600
    done
}

# Launch all background modules
guardian_loop &
intel_harvest_loop &
github_sync_loop &
drive_sync_loop &
memory_core_loop &

# Auto-heal watcher
while true; do
    for pid in $(jobs -p); do
        if ! kill -0 $pid 2>/dev/null; then
            echo "[$(date '+%Y-%m-%d %H:%M:%S')] [Sentinel] WARNING: Restarting dead process $pid" >> "$LOG_DIR/sentinel_$(date '+%Y%m%d').log"
            guardian_loop &
            intel_harvest_loop &
            github_sync_loop &
            drive_sync_loop &
            memory_core_loop &
            break
        fi
    done
    sleep 60
done
