#!/usr/bin/env bash
# shellcheck shell=bash
# Verifica lo stato live e ready di MinIO via endpoint HTTP ufficiali.

set -euo pipefail
source "$(cd "$(dirname "$0")" && pwd)/_common.sh"

require_command curl
ensure_env_file

LIVE_URL="$(health_url)"
READY_URL="$(ready_url)"

log "Controllo liveness: ${LIVE_URL}"
curl -fsS "${LIVE_URL}" >/dev/null

log "Controllo readiness: ${READY_URL}"
curl -fsS "${READY_URL}" >/dev/null

log "Healthcheck OK: MinIO risponde correttamente."
