#!/usr/bin/env bash
# shellcheck shell=bash
# Avvia MinIO in background usando Docker Compose.

set -euo pipefail
source "$(cd "$(dirname "$0")" && pwd)/_common.sh"

require_command docker
ensure_env_file

log "Avvio MinIO con Docker Compose..."
dc pull
dc up -d minio

log "Container attivi:"
dc ps
