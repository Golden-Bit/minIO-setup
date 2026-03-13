#!/usr/bin/env bash
# shellcheck shell=bash
# Backup file-level della data directory di MinIO.
# Strategia: stop temporaneo del servizio per ottenere un archivio coerente.

set -euo pipefail
source "$(cd "$(dirname "$0")" && pwd)/_common.sh"

require_command docker
require_command tar
ensure_env_file
load_env

BACKUP_DIR_ABS="$(cd "${REPO_ROOT}" && mkdir -p "${BACKUP_DIR}" && cd "${BACKUP_DIR}" && pwd)"
DATA_DIR_ABS="$(cd "${REPO_ROOT}" && mkdir -p "${DATA_DIR}" && cd "${DATA_DIR}" && pwd)"
TIMESTAMP="$(date +%Y%m%d_%H%M%S)"
ARCHIVE_PATH="${BACKUP_DIR_ABS}/minio_data_${TIMESTAMP}.tar.gz"

WAS_RUNNING=false
if compose_service_running minio; then
  WAS_RUNNING=true
  log "MinIO è in esecuzione: arresto temporaneo per backup coerente."
  dc stop minio
fi

log "Creo archivio ${ARCHIVE_PATH} ..."
tar -C "${DATA_DIR_ABS}" -czf "${ARCHIVE_PATH}" .
log "Backup completato: ${ARCHIVE_PATH}"

if [[ "${WAS_RUNNING}" == true ]]; then
  log "Riavvio MinIO..."
  dc start minio
fi
