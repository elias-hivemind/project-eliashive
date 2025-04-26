#!/bin/bash

# ELIAS BRAINFEED - Intelligence Analysis Script
# Purpose: Analyze GitHub intel for AI-specific trends and generate weekly reports

# Configuration
BASE_DIR="$HOME/eliashive_repo"
GITHUB_INTEL="$BASE_DIR/github_intel"
MEMORY_CORE="$BASE_DIR/memory_core"
INSIGHTS_DIR="$MEMORY_CORE/insights"
LOG_DIR="$BASE_DIR/logs"
mkdir -p "$INSIGHTS_DIR" "$LOG_DIR"

# Ensure jq is installed
if ! command -v jq &> /dev/null; then
    echo "[INFO] jq not found — installing..." >> "$LOG_DIR/brainfeed_$(date '+%Y%m%d').log"
    sudo yum install -y jq >> "$LOG_DIR/brainfeed_$(date '+%Y%m%d').log" 2>&1 || sudo apt-get install -y jq >> "$LOG_DIR/brainfeed_$(date '+%Y%m%d').log" 2>&1
fi

# Log function
log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" >> "$LOG_DIR/brainfeed_$(date '+%Y%m%d').log"
}

# Analyze AI-specific trends
analyze_trending() {
    log "Analyzing trending AI repositories"
    local latest_intel="$GITHUB_INTEL/trending_$(date '+%Y%m%d')*.json"
    if compgen -G "$latest_intel" > /dev/null; then
        jq -r '.items | sort_by(.stargazers_count) | reverse | .[:5] | .[] | "\(.name) (\(.stargazers_count) stars)"' "$latest_intel" > "$INSIGHTS_DIR/top_ai_repos_$(date '+%Y%m%d').txt"
        jq -r '.items[] | select(.topics[]? | test("nlp|natural-language-processing|computer-vision|machine-learning")) | "\(.name):\(.topics)"' "$latest_intel" > "$INSIGHTS_DIR/ai_subfields_$(date '+%Y%m%d').txt"
        jq -r '.items[] | select(.description | test("pytorch|tensorflow|keras|llm|large language model"; "i")) | "\(.name):\(.description)"' "$latest_intel" > "$INSIGHTS_DIR/ai_frameworks_$(date '+%Y%m%d').txt"
        jq -r '.items[] | .language // "Unknown"' "$latest_intel" | sort | uniq -c | sort -nr > "$INSIGHTS_DIR/language_trends_$(date '+%Y%m%d').txt"
        log "Generated AI repos, subfields, frameworks, and language trends"
    else
        log "No trending data available for analysis"
    fi
}

# Check for deprecated tools
check_deprecated() {
    log "Checking for deprecated AI tools"
    local latest_intel="$GITHUB_INTEL/trending_$(date '+%Y%m%d')*.json"
    if compgen -G "$latest_intel" > /dev/null; then
        jq -r '.items[] | select(.pushed_at < "'$(date -d '6 months ago' --iso-8601)'") | "\(.name) (Last updated: \(.pushed_at))"' "$latest_intel" > "$INSIGHTS_DIR/deprecated_$(date '+%Y%m%d').txt"
        log "Generated deprecated tools report"
    fi
}

# Generate weekly summary
weekly_summary() {
    log "Generating weekly AI trend summary"
    local week=$(date '+%Y%U')
    local summary_file="$INSIGHTS_DIR/weekly_trends_$week.json"
    if [ -f "$summary_file" ]; then
        log "Weekly summary already exists for $week"
        return
    fi
    local recent_intel="$GITHUB_INTEL/trending_$(date -d '7 days ago' '+%Y%m%d')*.json"
    if compgen -G "$recent_intel" > /dev/null; then
        jq -s '{ "week": "'$week'", "top_repos": [.[].items | sort_by(.stargazers_count) | reverse | .[:3] | .[].name], "top_subfields": [.[].items[].topics[]? | select(test("nlp|computer-vision"))] | unique }' $recent_intel > "$summary_file"
        log "Generated weekly summary at $summary_file"
    fi
}

# Main analysis loop
main() {
    log "Brainfeed: Starting AI intelligence analysis"
    analyze_trending
    check_deprecated
    weekly_summary
    log "Brainfeed: Analysis complete"
}

main
