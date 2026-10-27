#!/usr/bin/env bash
set -euo pipefail

root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

fail() { echo "FAIL: $*" >&2; exit 1; }
expect_file() { test -f "$root/$1" || fail "missing $1"; }
expect_text() {
  local file="$1" pattern="$2"
  grep -Fq -- "$pattern" "$root/$file" || fail "missing [$pattern] in $file"
}

expect_file 00-databases.sql
expect_file 02-silver-canonical-facts.sql
expect_file 03-gold-daily-marts.sql
expect_file 04-validation.sql
expect_file README.md

test ! -e "$root/01-silver-source-views.sql" || fail "Silver source-view layer should be removed"
if grep -Rqs 'hms_silver\.v_' "$root"/*.sql "$root"/README.md; then
  fail "canonical facts still depend on removed Silver source views"
fi

if grep -qs 'hms_raw\.raw_' "$root"/*.sql "$root"/README.md; then
  fail "mart layer still references hms_raw.raw_*; raw tables use source PostgreSQL names"
fi

expect_text 00-databases.sql "CREATE DATABASE IF NOT EXISTS hms_silver"
expect_text 00-databases.sql "CREATE DATABASE IF NOT EXISTS hms_gold"
expect_text 02-silver-canonical-facts.sql "CREATE OR REPLACE VIEW hms_silver.ct_luot_kham"
expect_text 02-silver-canonical-facts.sql "CREATE OR REPLACE VIEW hms_silver.ct_dot_noi_tru"
expect_text 02-silver-canonical-facts.sql "toString(id) AS dot_noi_tru_key"
expect_text 02-silver-canonical-facts.sql "ifNull(benh_an_id, id)"
if grep -q 'benh_nhan_dot_dieu_tri_id' "$root/02-silver-canonical-facts.sql"; then
  fail "inpatient fact uses a non-existent inpatient key"
fi
expect_text 02-silver-canonical-facts.sql "CREATE OR REPLACE VIEW hms_silver.ct_don_thuoc"
expect_text 02-silver-canonical-facts.sql "CREATE OR REPLACE VIEW hms_silver.ct_dong_doanh_thu"
expect_text 02-silver-canonical-facts.sql "CREATE OR REPLACE VIEW hms_silver.ct_kham_benh"
expect_text 02-silver-canonical-facts.sql "CREATE OR REPLACE VIEW hms_silver.ct_chuyen_vien"
expect_text 02-silver-canonical-facts.sql "CREATE OR REPLACE VIEW hms_silver.ct_xac_nhan_chi_phi"
expect_text 02-silver-canonical-facts.sql "CREATE OR REPLACE VIEW hms_silver.ct_gioi_tinh_tiep_nhan"
expect_text 02-silver-canonical-facts.sql "CREATE OR REPLACE VIEW hms_silver.ct_doi_tuong_benh_nhan"
expect_text 02-silver-canonical-facts.sql "CREATE OR REPLACE VIEW hms_silver.ct_icd10"
expect_text 02-silver-canonical-facts.sql "thoi_gian_bat_dau"
expect_text 02-silver-canonical-facts.sql "xuat_xml"
expect_text 02-silver-canonical-facts.sql "arrayJoin"
expect_text 02-silver-canonical-facts.sql "ma_ly_do_tiep_nhan) = '02'"
expect_text 02-silver-canonical-facts.sql "ma_doi_tuong_lt) = '2'"
expect_text 02-silver-canonical-facts.sql "a.da_thanh_toan"
expect_text 02-silver-canonical-facts.sql "a.hoan_tra"
expect_text 02-silver-canonical-facts.sql "a.huy_hoa_don"
expect_text 02-silver-canonical-facts.sql "ma_loai_so = 'SBL'"
expect_text 03-gold-daily-marts.sql "CREATE OR REPLACE VIEW hms_gold.dm_luot_kham_ngay"
expect_text 03-gold-daily-marts.sql "CREATE OR REPLACE VIEW hms_gold.dm_don_thuoc_ngay"
expect_text 03-gold-daily-marts.sql "CREATE OR REPLACE VIEW hms_gold.dm_doanh_thu_ngay"
expect_text 03-gold-daily-marts.sql "CREATE OR REPLACE VIEW hms_gold.dm_kham_benh_ngay"
expect_text 03-gold-daily-marts.sql "CREATE OR REPLACE VIEW hms_gold.dm_chuyen_vien_ngay"
expect_text 03-gold-daily-marts.sql "CREATE OR REPLACE VIEW hms_gold.dm_xac_nhan_chi_phi_ngay"
expect_text 03-gold-daily-marts.sql "CREATE OR REPLACE VIEW hms_gold.dm_gioi_tinh_ngay"
expect_text 03-gold-daily-marts.sql "CREATE OR REPLACE VIEW hms_gold.dm_doi_tuong_benh_nhan_ngay"
expect_text 03-gold-daily-marts.sql "CREATE OR REPLACE VIEW hms_gold.dm_icd10"
expect_text 04-validation.sql "toDate({to_date:Date}) + 1 AS exclusive_to_date"
expect_text 03-gold-daily-marts.sql "previous_from"
if grep -Eiq 'AS +(benh_nhan_id|so_dien_thoai|dia_chi|ho_ten)\b' "$root/03-gold-daily-marts.sql"; then
  fail "Gold SQL exposes a patient identifier field"
fi

echo "PASS: mart SQL contract"
