#!/usr/bin/env bash
# diagnostic.sh - Diagnostic CLI
# Exit codes: 0 = success, 1 = runtime failure, 2 = invalid command/input
set -u

usage() {
    cat <<'EOF'
Usage: diagnostic <command> [arguments]

Commands:
  system           Display system information
  network <host>   Check connectivity to a host
  disk             Display disk information
  help             Show this help message

Exit codes:
  0  success
  1  operational/runtime failure
  2  invalid command or input
EOF
}

cmd_system() {
    local os_name="Unknown"
    if [[ -r /etc/os-release ]]; then
        os_name=$(. /etc/os-release && echo "${PRETTY_NAME:-$NAME}")
    fi
    echo "===== System Information ====="
    echo "Hostname:         $(hostname)"
    echo "Current user:     $(whoami)"
    echo "Date/Time:        $(date '+%Y-%m-%d %H:%M:%S %Z')"
    echo "Operating system: $os_name"
    echo "Kernel version:   $(uname -r)"
    echo "Architecture:     $(uname -m)"
    echo "Uptime:           $(uptime -p 2>/dev/null || cut -d' ' -f1 /proc/uptime)"
    echo "CPU cores:        $(nproc 2>/dev/null || echo unknown)"
    echo
    echo "----- Memory -----"
    if command -v free >/dev/null 2>&1; then
        free -h
    else
        grep -E 'MemTotal|MemAvailable' /proc/meminfo
    fi
}

cmd_disk() {
    echo "===== Disk Information ====="
    if ! df -h; then
        echo "Error: unable to read disk information" >&2
        return 1
    fi
}

cmd_network() {
    local host="${1:-}"
    if [[ -z "$host" ]]; then
        echo "Error: 'network' requires a host argument" >&2
        usage >&2
        return 2
    fi
    if ! [[ "$host" =~ ^[A-Za-z0-9]([A-Za-z0-9.:-]*[A-Za-z0-9])?$ ]]; then
        echo "Error: invalid host: $host" >&2
        return 2
    fi

    echo "===== Network Check: $host ====="
    local resolved
    resolved=$(getent ahosts "$host" 2>/dev/null | awk 'NR==1 {print $1}')
    if [[ -z "$resolved" ]]; then
        echo "Error: could not resolve host: $host" >&2
        return 1
    fi
    echo "Resolved address: $resolved"

    if command -v ping >/dev/null 2>&1; then
        if ping -c 1 -W 2 "$host" >/dev/null 2>&1; then
            echo "Ping: $host is reachable"
        else
            echo "Ping: $host did not respond" >&2
            return 1
        fi
    else
        echo "Ping: not available in this environment (host resolved OK)"
    fi
}

main() {
    if [[ $# -lt 1 ]]; then
        echo "Error: no command given" >&2
        usage >&2
        return 2
    fi

    local command="$1"
    shift

    case "$command" in
        system)  cmd_system ;;
        network) cmd_network "$@" ;;
        disk)    cmd_disk ;;
        help|-h|--help) usage ;;
        *)
            echo "Error: unknown command: $command" >&2
            usage >&2
            return 2
            ;;
    esac
}

main "$@"
exit $?