#!/usr/bin/env bash
# shellcheck shell=bash
# Ferma MinIO senza rimuovere i dati persistenti.

set -euo pipefail
source "$(cd "$(dirname "$0")" && pwd)/_common.sh"

require_command docker
ensure_env_file

log "Arresto dello stack MinIO..."
dc down
