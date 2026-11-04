#!/usr/bin/env bash
set -u

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LOG_FILE="$SCRIPT_DIR/logs/toolkit.log"

log() {
    mkdir -p "$SCRIPT_DIR/logs"
    printf '%s [network-check] %s\n' "$(date '+%Y-%m-%d %H:%M:%S')" "$1" >> "$LOG_FILE"
}

invalid() {
    echo "Error: $1" >&2
    echo "Usage: $0 <hostname-or-ip> [port]" >&2
    log "Invalid input: $1"
    exit 2
}

is_valid_host() {
    local h="$1"
    [[ -n "$h" && ${#h} -le 253 ]] || return 1
    [[ "$h" != *..* ]] || return 1
    [[ "$h" =~ ^[A-Za-z0-9]([A-Za-z0-9.-]*[A-Za-z0-9])?$ ]]
}

is_valid_port() {
    local p="$1"
    [[ "$p" =~ ^[0-9]{1,5}$ ]] || return 1
    (( 10#$p >= 1 && 10#$p <= 65535 ))
}

if [[ $# -lt 1 || $# -gt 2 ]]; then
    invalid "expected 1 or 2 arguments"
fi

host="$1"
port="${2:-}"

is_valid_host "$host" || invalid "invalid hostname or IP address: $host"

if [[ $# -eq 2 ]]; then
    is_valid_port "$port" || invalid "port must be a whole number from 1 to 65535"
fi

log "Validated input: host=$host port=${port:-none}"
echo "Host: $host  Port: ${port:-none}"
