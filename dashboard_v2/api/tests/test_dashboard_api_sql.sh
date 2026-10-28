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
expect_text "addDays(to_date, 1)"
expect_text "FORMAT JSONEachRow"
expect_text "readonly = 1"
expect_text "CREATE USER IF NOT EXISTS dashboard_view_owner"
expect_text "HOST NONE"
expect_text "GRANT SELECT ON hms_gold.dm_chuyen_vien_ngay TO dashboard_view_owner"
expect_text "GRANT SELECT ON hms_silver.ct_chuyen_vien TO dashboard_view_owner"
expect_text "DEFINER = dashboard_view_owner"
expect_text "SQL SECURITY DEFINER"
expect_text "hms_gold.api_dashboard_summary"
expect_text "hms_gold.api_revenue_daily"
expect_text "hms_gold.api_icd10"
expect_text "throwIf(to_date < from_date"
expect_text "dateDiff('day', from_date, to_date) > 366"
expect_text "GRANT SELECT ON hms_gold.api_dashboard_summary TO dashboard_api"
expect_text "GRANT SELECT ON hms_gold.api_revenue_daily TO dashboard_api"
expect_text "GRANT SELECT ON hms_gold.api_icd10 TO dashboard_api"

if grep -Eqi 'hms_raw|\bINSERT\b|\bALTER TABLE\b' "$api_sql"; then
  fail "API SQL must not expose raw data or write operations"
fi

if grep 'TO dashboard_api' "$api_sql" | grep -Eqi 'hms_(raw|silver)|hms_gold\.dm_'; then
  fail "dashboard_api must only read dedicated API views"
fi

if grep -Eqi "IDENTIFIED[[:space:]]+WITH[[:space:]]+sha256_password[[:space:]]+BY[[:space:]]+'" "$api_sql"; then
  fail "API SQL must not contain a literal dashboard password"
fi
