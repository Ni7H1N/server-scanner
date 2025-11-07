#!/usr/bin/env bash
# server-stats.sh — Basic server performance stats with optional extras
# Works on most Linux distros without extra packages.
# Usage: ./server-stats.sh [--no-color] [--details] [--help]

set -o errexit
set -o nounset
set -o pipefail

# --------------------------
# Config / Flags
# --------------------------
NO_COLOR=false
SHOW_DETAILS=false

for arg in "$@"; do
  case "$arg" in
    --no-color) NO_COLOR=true ;;
    --details) SHOW_DETAILS=true ;;
    -h|--help)
      cat <<'EOF'
server-stats.sh — Analyse server performance stats.

Usage:
  ./server-stats.sh [--no-color] [--details] [--help]

Outputs:
  - Total CPU usage
  - Total memory usage (free vs. used + %)
  - Total disk usage (free vs. used + %)
  - Top 5 processes by CPU usage
  - Top 5 processes by memory usage

Stretch (included; use --details for more verbose sections):
  - OS version
  - Uptime
  - Load average (1/5/15)
  - Logged-in users
  - Failed SSH login attempts (last 24h, best-effort)

Notes:
  - Run on Linux (not Windows/PowerShell).
  - No sudo required; some logs may be unreadable without elevated perms.
EOF
      exit 0
      ;;
    *)
      echo "Unknown option: $arg" >&2
      exit 2
      ;;
  esac
done

# --------------------------
# Colors
# --------------------------
if [ "$NO_COLOR" = false ] && [ -t 1 ]; then
  BOLD="$(tput bold || true)"
  DIM="$(tput dim || true)"
  RED="$(tput setaf 1 || true)"
  GREEN="$(tput setaf 2 || true)"
  YELLOW="$(tput setaf 3 || true)"
  BLUE="$(tput setaf 4 || true)"
  MAGENTA="$(tput setaf 5 || true)"
  CYAN="$(tput setaf 6 || true)"
  RESET="$(tput sgr0 || true)"
else
  BOLD=""; DIM=""; RED=""; GREEN=""; YELLOW=""; BLUE=""; MAGENTA=""; CYAN=""; RESET=""
fi

# --------------------------
# Helpers
# --------------------------
hr() { printf '%s\n' "------------------------------------------------------------"; }
h1() { printf '%b\n' "${BOLD}$*${RESET}"; }
h2() { printf '%b\n' "${CYAN}$*${RESET}"; }
ok() { printf '%b\n' "${GREEN}$*${RESET}"; }
warn() { printf '%b\n' "${YELLOW}$*${RESET}"; }
err() { printf '%b\n' "${RED}$*${RESET}"; }

to_human() {
  # bytes -> human readable
  local bytes="$1"
  awk -v b="$bytes" '
    function human(x) {
      split("B KB MB GB TB PB", u)
      for (i=5; i>=0; i--) {
        p = 1024^i
        if (x >= p) {
          printf("%.2f %s", x/p, u[i+1]); exit
        }
      }
      printf("%.2f B", x)
    }
    BEGIN { human(b) }'
}

pct() {
  # percent = num/den*100
  awk -v n="$1" -v d="$2" 'BEGIN { if (d==0) print "0.00"; else printf("%.2f", (n/d)*100) }'
}

# --------------------------
# CPU Usage (using /proc/stat deltas)
# --------------------------
cpu_usage_total() {
  # Read /proc/stat twice with 1s interval for accurate CPU %
  read -r cpu u1 n1 s1 id1 io1 ir1 si1 st1 _ < /proc/stat
  sleep 1
  read -r cpu u2 n2 s2 id2 io2 ir2 si2 st2 _ < /proc/stat

  local idle1=$((id1 + io1))
  local non1=$((u1 + n1 + s1 + ir1 + si1 + st1))
  local tot1=$((idle1 + non1))

  local idle2=$((id2 + io2))
  local non2=$((u2 + n2 + s2 + ir2 + si2 + st2))
  local tot2=$((idle2 + non2))

  local dtot=$((tot2 - tot1))
  local didle=$((idle2 - idle1))
  local used=$((dtot - didle))

  local p
  p=$(pct "$used" "$dtot")
  printf "%s" "$p"
}

# --------------------------
# Memory Usage (/proc/meminfo)
# --------------------------
memory_stats() {
  # Using MemTotal and MemAvailable (kernel provides realistic "available")
  local total_kb avail_kb used_kb pused
  total_kb=$(awk '/MemTotal:/ {print $2}' /proc/meminfo)
  avail_kb=$(awk '/MemAvailable:/ {print $2}' /proc/meminfo)
  used_kb=$(( total_kb - avail_kb ))
  pused=$(pct "$used_kb" "$total_kb")

  local total_b=$(( total_kb * 1024 ))
  local used_b=$(( used_kb * 1024 ))
  local avail_b=$(( avail_kb * 1024 ))

  printf "%s|%s|%s|%s\n" \
    "$total_b" "$used_b" "$avail_b" "$pused"
}

# --------------------------
# Disk Usage (df)
# --------------------------
disk_stats_total() {
  # Sum across all real filesystems (skip tmpfs, devtmpfs, squashfs, overlay? keep overlay since containers may use it)
  # We’ll use df -B1 for raw bytes then sum.
  local total used avail
  readarray -t lines < <(df -B1 -x tmpfs -x devtmpfs -x squashfs --output=size,used,avail,target | tail -n +2)

  total=0; used=0; avail=0
  for line in "${lines[@]}"; do
    # Trim leading spaces; parse first three columns
    sz=$(awk '{print $1}' <<< "$line")
    us=$(awk '{print $2}' <<< "$line")
    av=$(awk '{print $3}' <<< "$line")
    total=$((total + sz))
    used=$((used + us))
    avail=$((avail + av))
  done

  local pused
  pused=$(pct "$used" "$total")
  printf "%s|%s|%s|%s\n" "$total" "$used" "$avail" "$pused"
}

disk_toplines() {
  # Show per-mount breakdown (human)
  df -h -x tmpfs -x devtmpfs -x squashfs | awk 'NR==1 || NR>1 {print}'
}

# --------------------------
# Top Processes (ps)
# --------------------------
top5_cpu() {
  ps -eo pid,comm,%cpu,%mem --sort=-%cpu | awk 'NR==1 || NR<=6 {printf "%-8s %-24s %6s %6s\n", $1, $2, $3, $4}'
}
top5_mem() {
  ps -eo pid,comm,%mem,%cpu --sort=-%mem | awk 'NR==1 || NR<=6 {printf "%-8s %-24s %6s %6s\n", $1, $2, $3, $4}'
}

# --------------------------
# Extras
# --------------------------
os_version() {
  if [ -f /etc/os-release ]; then
    . /etc/os-release
    printf "%s %s\n" "${NAME:-Linux}" "${VERSION:-}"
  else
    uname -sr
  fi
}
uptime_h() { uptime -p 2>/dev/null || awk '{printf "up %.0f minutes\n", $1/60}' /proc/uptime; }
loadavg() { awk '{printf "%s %s %s\n", $1, $2, $3}' /proc/loadavg; }
logged_in_users() {
  local n
  n=$(who 2>/dev/null | wc -l || echo 0)
  printf "%s (%s)\n" "$n" "$(who 2>/dev/null | awk '{print $1}' | sort -u | xargs echo 2>/dev/null || true)"
}
failed_logins_24h() {
  # Count failed SSH logins over last 24h, best-effort. Numeric-only, no errors.
  local count=0 n=0

  if command -v journalctl >/dev/null 2>&1; then
    n=$(journalctl --since "24 hours ago" -u ssh.service -u sshd.service 2>/dev/null | grep -ci "Failed password" || true)
    count=$((count + n))
    # Broader sweep in case unit names differ
    n=$(journalctl --since "24 hours ago" 2>/dev/null | grep -ci "Failed password" || true)
    count=$((count + n))
  fi

  for f in /var/log/auth.log /var/log/secure; do
    if [ -r "$f" ]; then
      # Tail to avoid huge scans; grep -c returns a pure number
      n=$(tail -n 20000 "$f" 2>/dev/null | grep -ci "Failed password" || echo 0)
      count=$((count + n))
    fi
  done

  echo "$count"
}

# --------------------------
# Main
# --------------------------
main() {
  hr
  h1 "Server Performance Stats"
  printf "%b\n" "${DIM}$(date -u +"UTC %Y-%m-%d %H:%M:%S")${RESET}"
  hr

  # CPU
  h2 "CPU"
  cpu_pct="$(cpu_usage_total)"
  printf "Total CPU Usage: %b%s%%%b\n" "${BOLD}" "$cpu_pct" "${RESET}"
  hr

  # Memory
  h2 "Memory"
  IFS='|' read -r mem_total mem_used mem_avail mem_pused < <(memory_stats)
  printf "Total: %s\n" "$(to_human "$mem_total")"
  printf "Used:  %s (%s%%)\n" "$(to_human "$mem_used")" "$mem_pused"
  printf "Free:  %s (%s%%)\n" "$(to_human "$mem_avail")" "$(awk -v a="$mem_avail" -v t="$mem_total" 'BEGIN{ if(t==0) print "0.00"; else printf("%.2f",(a/t)*100) }')"
  hr

  # Disk
  h2 "Disk"
  IFS='|' read -r d_total d_used d_avail d_pused < <(disk_stats_total)
  printf "Total: %s\n" "$(to_human "$d_total")"
  printf "Used:  %s (%s%%)\n" "$(to_human "$d_used")" "$d_pused"
  printf "Free:  %s (%s%%)\n" "$(to_human "$d_avail")" "$(awk -v a="$d_avail" -v t="$d_total" 'BEGIN{ if(t==0) print "0.00"; else printf("%.2f",(a/t)*100) }')"
  if [ "$SHOW_DETAILS" = true ]; then
    printf "\nPer-mount breakdown:\n"
    disk_toplines
  fi
  hr

  # Top processes
  h2 "Top 5 Processes by CPU"
  top5_cpu
  hr
  h2 "Top 5 Processes by Memory"
  top5_mem
  hr

  # Extras
  h2 "System Details"
  printf "OS:           %s\n" "$(os_version)"
  printf "Uptime:       %s\n" "$(uptime_h)"
  printf "Load Avg:     %s (1/5/15 min)\n" "$(loadavg)"
  printf "Logged-in:    %s\n" "$(logged_in_users)"
  printf "Failed SSH logins (24h, best-effort): %s\n" "$(failed_logins_24h)"
  hr
  ok "Done."
}

main

