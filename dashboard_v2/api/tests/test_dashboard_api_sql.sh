#!/usr/bin/env bash
set -euo pipefail

root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
api_sql="$root/01-dashboard-api.sql"
verify_sql="$root/02-verify-dashboard-api.sql"
silver_sql="$root/../mart/02-silver-canonical-facts.sql"

fail() { echo "FAIL: $*" >&2; exit 1; }
expect_file() { test -f "$1" || fail "missing $1"; }
expect_text() {
  local pattern="$1"
  grep -Fq -- "$pattern" "$api_sql" || fail "missing [$pattern] in 01-dashboard-api.sql"
}

expect_file "$api_sql"
expect_file "$verify_sql"
expect_file "$silver_sql"

expect_text "URL '/api/v1/dashboard-summary'"
expect_text "URL '/api/v1/revenue-daily'"
expect_text "URL '/api/v1/icd10'"
expect_text "URL '/api/v1/visits-daily'"
expect_text "URL '/api/v1/examinations-daily'"
expect_text "URL '/api/v1/inpatient-daily'"
expect_text "URL '/api/v1/transfers-daily'"
expect_text "URL '/api/v1/prescriptions-daily'"
expect_text "URL '/api/v1/cost-confirmations-daily'"
expect_text "URL '/api/v1/gender-daily'"
expect_text "URL '/api/v1/patient-types-daily'"
expect_text "{from_date:Date}"
expect_text "{to_date:Date}"
expect_text "addDays(to_date, 1)"
expect_text "FORMAT JSONEachRow"
expect_text "readonly = 1"
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
expect_text "hms_gold.api_dashboard_summary"
expect_text "hms_gold.api_revenue_daily"
expect_text "hms_gold.api_icd10"
expect_text "hms_gold.api_visits_daily"
expect_text "hms_gold.api_examinations_daily"
expect_text "hms_gold.api_inpatient_daily"
expect_text "hms_gold.api_transfers_daily"
expect_text "hms_gold.api_prescriptions_daily"
expect_text "hms_gold.api_cost_confirmations_daily"
expect_text "hms_gold.api_gender_daily"
expect_text "hms_gold.api_patient_types_daily"
expect_text "throwIf(to_date < from_date"
expect_text "dateDiff('day', from_date, to_date) > 366"
expect_text "GRANT SELECT ON hms_gold.api_dashboard_summary TO dashboard_api"
expect_text "GRANT SELECT ON hms_gold.api_revenue_daily TO dashboard_api"
expect_text "GRANT SELECT ON hms_gold.api_icd10 TO dashboard_api"

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
