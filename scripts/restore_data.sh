#!/usr/bin/env bash
# shellcheck shell=bash
# Ripristina un backup della data directory MinIO.
# Uso: ./scripts/restore_data.sh ./backups/minio_data_xxx.tar.gz

set -euo pipefail
source "$(cd "$(dirname "$0")" && pwd)/_common.sh"

require_command docker
require_command tar
ensure_env_file
load_env

ARCHIVE_PATH="${1:-}"
if [[ -z "${ARCHIVE_PATH}" ]]; then
  err "Uso: $0 <path-archivio-backup.tar.gz>"
  exit 1
fi

if [[ ! -f "${ARCHIVE_PATH}" ]]; then
  err "Archivio non trovato: ${ARCHIVE_PATH}"
  exit 1
fi

BACKUP_DIR_ABS="$(cd "${REPO_ROOT}" && mkdir -p "${BACKUP_DIR}" && cd "${BACKUP_DIR}" && pwd)"
DATA_DIR_ABS="$(cd "${REPO_ROOT}" && mkdir -p "${DATA_DIR}" && cd "${DATA_DIR}" && pwd)"
PRE_RESTORE="${BACKUP_DIR_ABS}/pre_restore_$(date +%Y%m%d_%H%M%S).tar.gz"

WAS_RUNNING=false
if compose_service_running minio; then
  WAS_RUNNING=true
  log "Arresto MinIO prima del restore..."
  dc stop minio
fi

log "Creo backup preventivo della directory corrente: ${PRE_RESTORE}"
tar -C "${DATA_DIR_ABS}" -czf "${PRE_RESTORE}" .

log "Pulisco la data directory corrente..."
find "${DATA_DIR_ABS}" -mindepth 1 -maxdepth 1 -exec rm -rf {} +

log "Ripristino archivio ${ARCHIVE_PATH} ..."
tar -C "${DATA_DIR_ABS}" -xzf "${ARCHIVE_PATH}"

if [[ "${WAS_RUNNING}" == true ]]; then
  log "Riavvio MinIO..."
  dc start minio
fi

log "Restore completato con successo."
