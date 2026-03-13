#!/bin/sh
# Entrypoint MinIO custom.
# Scopo: evitare di passare variabili opzionali vuote al processo MinIO.

set -eu

# Unset delle variabili opzionali se non valorizzate.
[ -n "${MINIO_SERVER_URL:-}" ] || unset MINIO_SERVER_URL || true
[ -n "${MINIO_BROWSER_REDIRECT_URL:-}" ] || unset MINIO_BROWSER_REDIRECT_URL || true
[ -n "${MINIO_DOMAIN:-}" ] || unset MINIO_DOMAIN || true

exec minio server "${MINIO_DATA_DIR:-/data}" \
  --address ":9000" \
  --console-address ":9001"
