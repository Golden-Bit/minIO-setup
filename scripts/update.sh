#!/usr/bin/env bash
# shellcheck shell=bash
# Aggiornamento controllato delle immagini Docker.
# Assunzione: hai già cambiato i tag in .env dopo aver verificato le release notes.

set -euo pipefail
source "$(cd "$(dirname "$0")" && pwd)/_common.sh"

require_command docker
ensure_env_file

log "Aggiorno immagini e ricreo i container..."
dc pull
dc up -d --force-recreate minio

dc ps
log "Aggiornamento completato. Esegui ./scripts/healthcheck.sh per verifica finale."
