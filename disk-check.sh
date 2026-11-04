#!/usr/bin/env bash
set -u

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LOG_FILE="$SCRIPT_DIR/logs/toolkit.log"

log() {
    mkdir -p "$SCRIPT_DIR/logs"
    printf '%s [disk-check] %s\n' "$(date '+%Y-%m-%d %H:%M:%S')" "$1" >> "$LOG_FILE"
}

invalid() {
    echo "Error: $1" >&2
    echo "Usage: $0 <threshold> [path]" >&2
    log "Invalid input: $1"
    exit 2
}

if [[ $# -lt 1 || $# -gt 2 ]]; then
    invalid "expected 1 or 2 arguments"
fi

threshold="$1"
path="${2:-/}"

if ! [[ "$threshold" =~ ^[0-9]{1,3}$ ]]; then
    invalid "threshold must be a whole number"
fi

threshold=$((10#$threshold))
if (( threshold < 1 || threshold > 100 )); then
    invalid "threshold must be between 1 and 100"
fi

if [[ ! -e "$path" ]]; then
    invalid "path does not exist: $path"
fi

echo "Threshold: $threshold  Path: $path"
