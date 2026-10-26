#!/usr/bin/env bash
set -euo pipefail

profile="${1:-full}"
case "$profile" in
  source|cdc-core|bi|full) ;;
  *) echo "invalid profile: $profile" >&2; exit 64 ;;
esac

[[ -r .env ]] || { echo "missing .env; run: cp .env.example .env" >&2; exit 1; }
docker info >/dev/null
docker compose version >/dev/null

memory_bytes="$(docker info --format '{{.MemTotal}}')"
memory_gib=$((memory_bytes / 1024 / 1024 / 1024))
echo "Docker memory: ${memory_gib} GiB"

if [[ "$profile" == "full" && "$memory_gib" -lt 12 ]]; then
  echo "full profile requires at least 12 GiB Docker memory" >&2
  exit 1
fi

if [[ "$memory_gib" -lt 16 ]]; then
  echo "warning: 16 GiB Docker memory is recommended for the full profile" >&2
fi
