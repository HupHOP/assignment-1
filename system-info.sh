#!/usr/bin/env bash
set -u

row() {
    printf '%-18s: %s\n' "$1" "$2"
}

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

