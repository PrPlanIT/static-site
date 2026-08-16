#!/bin/sh
set -eu

# Runtime-configurable (defaults are baked into the image ENV)
export LISTEN_PORT="${LISTEN_PORT:-8080}"
export LOG_LEVEL="${LOG_LEVEL:-warn}"
export WORKER_PROCESSES="${WORKER_PROCESSES:-auto}"

# Render config into /tmp so the container runs with a read-only root filesystem.
mkdir -p /tmp/conf.d
envsubst '${WORKER_PROCESSES} ${LOG_LEVEL}' \
    < /etc/nginx/nginx.conf.template > /tmp/nginx.conf
envsubst '${LISTEN_PORT}' \
    < /etc/nginx/conf.d/default.conf.template > /tmp/conf.d/default.conf

echo "static-site: serving /usr/share/nginx/html on :${LISTEN_PORT}"
exec nginx -c /tmp/nginx.conf -g "daemon off;"
