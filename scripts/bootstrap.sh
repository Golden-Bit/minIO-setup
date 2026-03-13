#!/usr/bin/env bash
# shellcheck shell=bash
# Bootstrap idempotente di bucket, versioning e utente applicativo.
# Usa un container effimero basato su mc per evitare dipendenze sul sistema host.

set -euo pipefail
source "$(cd "$(dirname "$0")" && pwd)/_common.sh"

require_command docker
require_command curl
ensure_env_file
load_env

LIVE_URL="$(health_url)"
ATTEMPTS=30
SLEEP_SECONDS=2

log "Attendo che MinIO sia raggiungibile su ${LIVE_URL} ..."
for ((i=1; i<=ATTEMPTS; i++)); do
  if curl -fsS "${LIVE_URL}" >/dev/null 2>&1; then
    log "MinIO è disponibile. Procedo con il bootstrap."
    break
  fi

  if (( i == ATTEMPTS )); then
    err "MinIO non è raggiungibile dopo ${ATTEMPTS} tentativi."
    exit 1
  fi

  sleep "${SLEEP_SECONDS}"
done

log "Eseguo bootstrap tramite container mc effimero..."
dc run --rm --no-deps mc /opt/minio-setup/scripts/bootstrap-mc.sh
