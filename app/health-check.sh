#!/usr/bin/env bash
# health-check.sh - Verify the diagnostic tool works
if /app/diagnostic.sh help >/dev/null 2>&1; then
    echo "healthy"
    exit 0
fi
echo "unhealthy" >&2
exit 1