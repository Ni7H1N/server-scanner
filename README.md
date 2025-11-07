# Server Scanner

Collects basic performance stats on any Linux host.

## Run
\`\`\`bash
./server-stats.sh            # color output
./server-stats.sh --details  # add per-mount disk table
./server-stats.sh --no-color # plain text
\`\`\`

## Notes
- Disk "Free %" is user-available space (root reserves excluded).
- Failed SSH counts are best-effort and may require elevated log access.
