#!/usr/bin/env bash
# shellcheck shell=bash
# Stampa gli endpoint locali e, se configurati, quelli pubblici.

set -euo pipefail
source "$(cd "$(dirname "$0")" && pwd)/_common.sh"

ensure_env_file
load_env

cat <<EOF
=== Endpoint MinIO ===
Locale API S3    : http://${MINIO_HEALTHCHECK_HOST}:${MINIO_API_HOST_PORT}
Locale Console   : http://${MINIO_HEALTHCHECK_HOST}:${MINIO_CONSOLE_HOST_PORT}
Pubblico API S3  : ${MINIO_SERVER_URL:-<non configurato>}
Pubblica Console : ${MINIO_BROWSER_REDIRECT_URL:-<non configurato>}
Bucket domain    : ${MINIO_DOMAIN:-<non configurato>}
EOF
