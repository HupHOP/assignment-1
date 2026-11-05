#!/usr/bin/env bash
set -u

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LOG_FILE="$SCRIPT_DIR/logs/toolkit.log"

log() {
    mkdir -p "$SCRIPT_DIR/logs"
    printf '%s [system-info] %s\n' "$(date '+%Y-%m-%d %H:%M:%S')" "$1" >> "$LOG_FILE"
}

row() {
    printf '%-18s: %s\n' "$1" "$2"
}

log "Collecting system information"

row "Hostname" "$(hostname)"
row "Current User" "$(id -un)"
row "Date/Time" "$(date '+%Y-%m-%d %H:%M:%S %Z')"
row "Kernel Version" "$(uname -r)"
row "Working Directory" "$(pwd)"
row "Uptime" "$(uptime -p)"
row "CPU Cores" "$(nproc)"
row "Operating System" "$(grep '^PRETTY_NAME' /etc/os-release | cut -d= -f2 | tr -d '"')"
row "CPU Model" "$(grep 'model name' /proc/cpuinfo | head -n 1 | cut -d: -f2)"
row "Memory" "$(free -h | awk '/^Mem:/ {print "Total: " $2 " | Used: " $3 " | Free: " $4}')"

log "System information displayed"
