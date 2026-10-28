#!/usr/bin/env bash
set -euo pipefail

root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
api_sql="$root/01-dashboard-api.sql"
verify_sql="$root/02-verify-dashboard-api.sql"

fail() { echo "FAIL: $*" >&2; exit 1; }
expect_file() { test -f "$1" || fail "missing $1"; }
expect_text() {
  local pattern="$1"
  grep -Fq -- "$pattern" "$api_sql" || fail "missing [$pattern] in 01-dashboard-api.sql"
}

expect_file "$api_sql"
expect_file "$verify_sql"

expect_text "URL '/api/v1/dashboard-summary'"
expect_text "URL '/api/v1/revenue-daily'"
expect_text "URL '/api/v1/icd10'"
expect_text "{from_date:Date}"
expect_text "{to_date:Date}"
expect_text "addDays({to_date:Date}, 1)"
expect_text "FORMAT JSONEachRow"
expect_text "readonly = 1"
expect_text "GRANT SELECT ON hms_gold.dm_dashboard_ngay TO dashboard_api"
expect_text "GRANT SELECT ON hms_gold.dm_doanh_thu_ngay TO dashboard_api"
expect_text "GRANT SELECT ON hms_gold.dm_icd10 TO dashboard_api"

if grep -Eqi 'hms_(raw|silver)|\bINSERT\b|\bALTER TABLE\b' "$api_sql"; then
  fail "API SQL must only expose read-only Gold marts"
fi

if grep -Eqi "IDENTIFIED[[:space:]]+WITH[[:space:]]+sha256_password[[:space:]]+BY[[:space:]]+'" "$api_sql"; then
  fail "API SQL must not contain a literal dashboard password"
fi
