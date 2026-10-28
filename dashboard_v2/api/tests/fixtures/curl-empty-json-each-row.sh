#!/usr/bin/env bash
set -euo pipefail

write_status=0
raw_query=0

for argument in "$@"; do
  test "$argument" = '--write-out' && write_status=1
  case "$argument" in
    *hms_raw.benh_nhan_dot_dieu_tri*) raw_query=1 ;;
  esac
done

if test "$write_status" -eq 1; then
  if test "$raw_query" -eq 1; then
    printf '497'
  else
    printf '401'
  fi
fi
