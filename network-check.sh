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

status=0

log "Starting network check: host=$host port=${port:-none}"
echo "Network check for: $host"

resolved="$(getent ahosts "$host" | awk 'NR==1 {print $1}')"
if [[ -z "$resolved" ]]; then
    echo "Resolution: FAILED - could not resolve $host" >&2
    log "Could not resolve $host"
    exit 1
fi
echo "Resolved address: $resolved"
log "Resolved $host to $resolved"

if ! command -v ping >/dev/null 2>&1; then
    echo "Ping: skipped (ping is not installed)"
    log "ping not installed, skipped ICMP check"
elif ping -c 2 -W 2 -- "$host" >/dev/null 2>&1; then
    echo "Ping: host is reachable"
    log "Ping to $host succeeded"
else
    echo "Ping: no reply from $host" >&2
    log "Ping to $host failed"
    status=1
fi

echo "Network interfaces:"
ip -brief address | sed 's/^/  /'
log "Displayed network interface information"

if [[ -n "$port" ]]; then
    if timeout 5 bash -c 'exec 3<>"/dev/tcp/$1/$2"' _ "$host" "$port" 2>/dev/null; then
        echo "TCP port $port on $host: OPEN"
        log "TCP $host:$port is open"
    else
        echo "TCP port $port on $host: CLOSED or unreachable" >&2
        log "TCP $host:$port is closed or unreachable"
        status=1
    fi
fi

if (( status == 0 )); then
    echo "Result: all checks passed"
    log "Check for $host finished: PASS"
else
    echo "Result: one or more checks failed" >&2
    log "Check for $host finished: FAIL"
fi
exit "$status"
