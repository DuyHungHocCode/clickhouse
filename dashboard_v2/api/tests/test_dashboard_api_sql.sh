#!/usr/bin/env bash
set -euo pipefail

root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
api_sql="${API_SQL:-$root/01-dashboard-api.sql}"
verify_sql="$root/02-verify-dashboard-api.sql"
silver_sql="$root/../mart/02-silver-canonical-facts.sql"

fail() { echo "FAIL: $*" >&2; exit 1; }
expect_file() { test -f "$1" || fail "missing $1"; }
expect_text() {
  local pattern="$1"
  grep -Fq -- "$pattern" "$api_sql" || fail "missing [$pattern] in 01-dashboard-api.sql"
}
expect_handler() {
  local name="$1" path="$2" view="$3" order_by="$4" handler_sql
  handler_sql="$(awk -v name="$name" '
    $0 == "CREATE HANDLER IF NOT EXISTS " name { capture=1 }
    capture { print }
    capture && $0 == "" { exit }
  ' "$api_sql")"

  test -n "$handler_sql" || fail "missing handler [$name]"
  printf '%s\n' "$handler_sql" | grep -Fq "URL '$path'" || fail "handler [$name] has wrong URL"
  printf '%s\n' "$handler_sql" | grep -Fq 'METHODS (GET)' || fail "handler [$name] must allow only GET"
  printf '%s\n' "$handler_sql" | grep -Fq "FROM hms_gold.$view" || fail "handler [$name] has wrong API view"
  printf '%s\n' "$handler_sql" | grep -Fq "throwIf(to_date < from_date, 'from_date must not be after to_date')" || fail "handler [$name] must reject inverted dates"
  printf '%s\n' "$handler_sql" | grep -Fq "throwIf(dateDiff('day', from_date, to_date) > 366, 'date range must not exceed 366 days')" || fail "handler [$name] must cap date range"
  printf '%s\n' "$handler_sql" | grep -Fq 'AND ngay < addDays(to_date, 1)' || fail "handler [$name] must include to_date"
  printf '%s\n' "$handler_sql" | grep -Fq "ORDER BY $order_by" || fail "handler [$name] has wrong ordering"
  printf '%s\n' "$handler_sql" | grep -Fq 'FORMAT JSONEachRow' || fail "handler [$name] must return JSONEachRow"
}
expect_api_view() {
  local name="$1" mart="$2" view_sql
  view_sql="$(awk -v name="$name" '
    $0 == "CREATE OR REPLACE VIEW hms_gold." name { capture=1 }
    capture { print }
    capture && $0 == "" { exit }
  ' "$api_sql")"

  test -n "$view_sql" || fail "missing API view [$name]"
  printf '%s\n' "$view_sql" | grep -Fq 'DEFINER = dashboard_view_owner' || fail "API view [$name] must use dashboard_view_owner"
  printf '%s\n' "$view_sql" | grep -Fq 'SQL SECURITY DEFINER' || fail "API view [$name] must use SQL SECURITY DEFINER"
  printf '%s\n' "$view_sql" | grep -Fq "AS SELECT * FROM hms_gold.$mart;" || fail "API view [$name] has wrong Gold mart"
  expect_text "GRANT SELECT ON hms_gold.$name TO dashboard_api;"
}

expect_file "$api_sql"
expect_file "$verify_sql"
expect_file "$silver_sql"

expect_text "readonly = 1"
expect_text "max_result_rows = 50000 MAX 50000"
expect_text "CREATE USER IF NOT EXISTS dashboard_view_owner"
expect_text "HOST NONE"
expect_text "GRANT SELECT ON hms_gold.dm_chuyen_vien_ngay TO dashboard_view_owner"
expect_text "GRANT SELECT ON hms_silver.ct_chuyen_vien TO dashboard_view_owner"
expect_text "GRANT SELECT ON hms_silver.ct_chi_dinh_dich_vu TO dashboard_view_owner"
expect_text "GRANT SELECT ON hms_silver.ct_gioi_tinh_tiep_nhan TO dashboard_view_owner"
expect_text "GRANT SELECT ON hms_silver.ct_doi_tuong_benh_nhan TO dashboard_view_owner"
expect_text "GRANT SELECT ON hms_raw.tiep_nhan TO dashboard_view_owner"
expect_text "GRANT SELECT ON hms_raw.benh_nhan_tiep_nhan TO dashboard_view_owner"
expect_text "GRANT SELECT ON hms_raw.phieu_dich_vu_chi_tiet TO dashboard_view_owner"
expect_text "GRANT SELECT ON hms_raw.csyt_vien_phi_chung_tu_chi_tiet TO dashboard_view_owner"
expect_text "GRANT SELECT ON hms_raw.dmc_icd10 TO dashboard_view_owner"
expect_text "DEFINER = dashboard_view_owner"
expect_text "SQL SECURITY DEFINER"
expect_api_view api_dashboard_summary dm_dashboard_ngay
expect_api_view api_revenue_daily dm_doanh_thu_ngay
expect_api_view api_icd10 dm_icd10
expect_api_view api_visits_daily dm_luot_kham_ngay
expect_api_view api_examinations_daily dm_kham_benh_ngay
expect_api_view api_inpatient_daily dm_noi_tru_ngay
expect_api_view api_transfers_daily dm_chuyen_vien_ngay
expect_api_view api_prescriptions_daily dm_don_thuoc_ngay
expect_api_view api_cost_confirmations_daily dm_xac_nhan_chi_phi_ngay
expect_api_view api_gender_daily dm_gioi_tinh_ngay
expect_api_view api_patient_types_daily dm_doi_tuong_benh_nhan_ngay

expect_handler dashboard_summary /api/v1/dashboard-summary api_dashboard_summary ngay
expect_handler revenue_daily /api/v1/revenue-daily api_revenue_daily 'ngay, nhom_doanh_thu'
expect_handler icd10 /api/v1/icd10 api_icd10 'ngay, loai_thanh_toan, ma_icd10'
expect_handler visits_daily /api/v1/visits-daily api_visits_daily ngay
expect_handler examinations_daily /api/v1/examinations-daily api_examinations_daily ngay
expect_handler inpatient_daily /api/v1/inpatient-daily api_inpatient_daily ngay
expect_handler transfers_daily /api/v1/transfers-daily api_transfers_daily ngay
expect_handler prescriptions_daily /api/v1/prescriptions-daily api_prescriptions_daily ngay
expect_handler cost_confirmations_daily /api/v1/cost-confirmations-daily api_cost_confirmations_daily ngay
expect_handler gender_daily /api/v1/gender-daily api_gender_daily ngay
expect_handler patient_types_daily /api/v1/patient-types-daily api_patient_types_daily ngay

icd10_handler="$(awk '
  $0 == "CREATE HANDLER IF NOT EXISTS icd10" { capture=1 }
  capture { print }
  capture && $0 == "" { exit }
' "$api_sql")"
printf '%s\n' "$icd10_handler" | grep -Fq 'LIMIT 10000' || fail "icd10 handler must limit results to 10000"

if grep -Eqi '\bINSERT\b|\bALTER TABLE\b' "$api_sql"; then
  fail "API SQL must not contain write operations"
fi

if grep 'TO dashboard_api' "$api_sql" | grep -Eqi 'hms_(raw|silver)|hms_gold\.dm_'; then
  fail "dashboard_api must only read dedicated API views"
fi

required_raw_grants="$(awk '
  /^CREATE OR REPLACE VIEW hms_silver\.ct_/ {
    name=$5
    sub("hms_silver\\.", "", name)
    keep=(name=="ct_luot_kham" || name=="ct_kham_benh" || name=="ct_dot_noi_tru" || name=="ct_chuyen_vien" || name=="ct_don_thuoc" || name=="ct_xac_nhan_chi_phi" || name=="ct_gioi_tinh_tiep_nhan" || name=="ct_doi_tuong_benh_nhan" || name=="ct_chi_dinh_dich_vu" || name=="ct_dong_doanh_thu" || name=="ct_icd10")
  }
  keep {
    while (match($0, /hms_raw\.[A-Za-z0-9_]+/)) {
      print substr($0, RSTART, RLENGTH)
      $0=substr($0, RSTART + RLENGTH)
    }
  }
' "$silver_sql" | sort -u)"
actual_raw_grants="$(sed -n 's/^GRANT SELECT ON \(hms_raw\.[A-Za-z0-9_]*\) TO dashboard_view_owner;.*/\1/p' "$api_sql" | sort -u)"
test "$actual_raw_grants" = "$required_raw_grants" || fail "dashboard_view_owner raw grants must exactly match API view dependencies"

if grep -Eqi "IDENTIFIED[[:space:]]+WITH[[:space:]]+sha256_password[[:space:]]+BY[[:space:]]+'" "$api_sql"; then
  fail "API SQL must not contain a literal dashboard password"
fi
