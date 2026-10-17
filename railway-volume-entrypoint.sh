#!/bin/sh
set -eu

# Railway mounts persistent volumes as root-owned directories. Fix ownership before
# the application drops privileges, so SQLite can create and atomically replace DB files.
DATA_PATH="${DATA_DIR:-/app/data}"
mkdir -p "$DATA_PATH"
chown -R node:node "$DATA_PATH"
chmod -R u+rwX "$DATA_PATH"

# The base runtime image uses this helper for heap limits and base-path checks.
# Preserve service environment, but use the non-root application account afterwards.
export HOME=/home/node
export USER=node
export LOGNAME=node
exec su --preserve-environment -s /bin/sh node -c 'exec /app/check-permissions.sh "$@"' sh "$@"
