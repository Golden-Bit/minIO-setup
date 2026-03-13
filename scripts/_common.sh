#!/usr/bin/env bash
# shellcheck shell=bash
# Funzioni condivise dagli script operativi del repository.

set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
ENV_FILE="${REPO_ROOT}/.env"

log() {
  printf '[INFO] %s\n' "$*"
}

warn() {
  printf '[WARN] %s\n' "$*" >&2
}

err() {
  printf '[ERROR] %s\n' "$*" >&2
}

require_command() {
  command -v "$1" >/dev/null 2>&1 || {
    err "Comando richiesto non trovato: $1"
    exit 1
  }
}

ensure_env_file() {
  if [[ ! -f "${ENV_FILE}" ]]; then
    err "File .env non trovato in ${REPO_ROOT}. Copia .env.example in .env e configuralo."
    exit 1
  fi
}

load_env() {
  ensure_env_file
  set -a
  # shellcheck disable=SC1090
  source "${ENV_FILE}"
  set +a
}

dc() {
  (cd "${REPO_ROOT}" && docker compose "$@")
}

container_is_running() {
  local container_name="${1:?container name mancante}"
  docker ps --format '{{.Names}}' | grep -Fxq "${container_name}"
}

compose_service_running() {
  local service_name="${1:?service name mancante}"
  local cid
  cid="$(cd "${REPO_ROOT}" && docker compose ps -q "${service_name}" 2>/dev/null || true)"
  [[ -n "${cid}" ]] && docker inspect -f '{{.State.Running}}' "${cid}" 2>/dev/null | grep -q '^true$'
}

health_url() {
  load_env
  printf '%s://%s:%s/minio/health/live\n' \
    "${MINIO_HEALTHCHECK_SCHEME}" \
    "${MINIO_HEALTHCHECK_HOST}" \
    "${MINIO_API_HOST_PORT}"
}

ready_url() {
  load_env
  printf '%s://%s:%s/minio/health/ready\n' \
    "${MINIO_HEALTHCHECK_SCHEME}" \
    "${MINIO_HEALTHCHECK_HOST}" \
    "${MINIO_API_HOST_PORT}"
}
