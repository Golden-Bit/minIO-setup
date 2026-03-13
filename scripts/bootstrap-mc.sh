#!/bin/sh
# Script eseguito DENTRO il container minio/mc.
# Si connette al servizio minio sulla rete docker-compose e applica bootstrap idempotente.

set -eu

if [ -z "${MINIO_ROOT_USER:-}" ] || [ -z "${MINIO_ROOT_PASSWORD:-}" ]; then
  echo "[ERROR] MINIO_ROOT_USER e MINIO_ROOT_PASSWORD sono obbligatori." >&2
  exit 1
fi

# Configura alias locale verso il container servizio 'minio'.
mc alias set local http://minio:9000 "$MINIO_ROOT_USER" "$MINIO_ROOT_PASSWORD"

echo "[INFO] Alias mc configurato verso http://minio:9000"

# Creazione bucket iniziali (se presenti).
if [ -n "${MINIO_DEFAULT_BUCKETS:-}" ]; then
  OLD_IFS="$IFS"
  IFS=','
  set -- ${MINIO_DEFAULT_BUCKETS}
  IFS="$OLD_IFS"

  for bucket in "$@"; do
    bucket_trimmed=$(printf '%s' "$bucket" | tr -d '[:space:]')
    [ -n "$bucket_trimmed" ] || continue

    echo "[INFO] Creo bucket se assente: $bucket_trimmed"
    mc mb --ignore-existing "local/$bucket_trimmed"

    if [ "${MINIO_ENABLE_VERSIONING:-false}" = "true" ]; then
      echo "[INFO] Abilito versioning su: $bucket_trimmed"
      mc version enable "local/$bucket_trimmed" >/dev/null 2>&1 || true
    fi
  done
else
  echo "[INFO] Nessun bucket iniziale configurato."
fi

# Creazione utente applicativo opzionale.
if [ -n "${MINIO_DEFAULT_USER:-}" ] && [ -n "${MINIO_DEFAULT_USER_PASSWORD:-}" ]; then
  echo "[INFO] Creo/aggiorno utente applicativo: ${MINIO_DEFAULT_USER}"
  mc admin user add local "$MINIO_DEFAULT_USER" "$MINIO_DEFAULT_USER_PASSWORD" >/dev/null 2>&1 || true

  POLICY_NAME="${MINIO_DEFAULT_USER_POLICY:-readwrite}"
  echo "[INFO] Associo policy built-in '${POLICY_NAME}' all'utente ${MINIO_DEFAULT_USER}"
  if ! mc admin policy attach local "$POLICY_NAME" --user "$MINIO_DEFAULT_USER" >/dev/null 2>&1; then
    echo "[ERROR] Impossibile associare la policy '${POLICY_NAME}' all'utente ${MINIO_DEFAULT_USER}." >&2
    exit 1
  fi
else
  echo "[INFO] Nessun utente applicativo configurato."
fi

echo "[INFO] Bootstrap completato."
