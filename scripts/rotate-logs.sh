#!/usr/bin/env sh
set -eu

# Resolve project root (this script lives in server-scanner/scripts/)
SCRIPT_DIR=$(cd "$(dirname "$0")" && pwd)
ROOT_DIR=$(cd "$SCRIPT_DIR/.." && pwd)

TS=$(date -u +'%Y%m%dT%H%M%SZ')

# Ensure output dirs exist
mkdir -p "$ROOT_DIR/output" "$ROOT_DIR/output/runs"

# Run and save output (latest + timestamped)
"$ROOT_DIR/server-stats.sh" --details | tee "$ROOT_DIR/output/latest.txt" > "$ROOT_DIR/output/runs/$TS.txt"

echo "Wrote output/latest.txt and output/runs/$TS.txt"
