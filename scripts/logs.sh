#!/usr/bin/env bash
# shellcheck shell=bash
# Mostra i log del servizio MinIO.

set -euo pipefail
source "$(cd "$(dirname "$0")" && pwd)/_common.sh"

require_command docker
ensure_env_file

cd "${REPO_ROOT}"
docker compose logs -f --tail=200 minio
