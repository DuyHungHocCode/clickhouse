#!/usr/bin/env bash
set -euo pipefail

write_status=0
denied_query=0

for argument in "$@"; do
  test "$argument" = '--write-out' && write_status=1
  case "$argument" in
    *hms_raw.benh_nhan_dot_dieu_tri*|*hms_silver.ct_luot_kham*|*hms_gold.dm_luot_kham_ngay*) denied_query=1 ;;
  esac
done

if test "$write_status" -eq 1; then
  if test "$denied_query" -eq 1; then
    printf '%s\n500' "${CURL_FIXTURE_DENIAL_BODY:-server unavailable}"
  else
    printf '401'
  fi
elif printf '%s\n' "$*" | grep -Fq 'SELECT 1'; then
  printf '1'
fi
