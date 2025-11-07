#!/usr/bin/env bash
set -euo pipefail
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
out="$("${ROOT}/server-stats.sh" --no-color)"
grep -q "Server Performance Stats" <<< "$out"
grep -q "Top 5 Processes by CPU" <<< "$out"
grep -q "Top 5 Processes by Memory" <<< "$out"
echo "Smoke test passed."
