-- Apply with --param_dashboard_api_password from the destination secret store.
CREATE USER IF NOT EXISTS dashboard_view_owner
IDENTIFIED WITH no_password
HOST NONE;

GRANT SELECT ON hms_gold.dm_dashboard_ngay TO dashboard_view_owner;
GRANT SELECT ON hms_gold.dm_luot_kham_ngay TO dashboard_view_owner;
GRANT SELECT ON hms_gold.dm_kham_benh_ngay TO dashboard_view_owner;
GRANT SELECT ON hms_gold.dm_noi_tru_ngay TO dashboard_view_owner;
GRANT SELECT ON hms_gold.dm_don_thuoc_ngay TO dashboard_view_owner;
GRANT SELECT ON hms_gold.dm_xac_nhan_chi_phi_ngay TO dashboard_view_owner;
GRANT SELECT ON hms_gold.dm_chuyen_vien_ngay TO dashboard_view_owner;
GRANT SELECT ON hms_gold.dm_doanh_thu_ngay TO dashboard_view_owner;
GRANT SELECT ON hms_gold.dm_gioi_tinh_ngay TO dashboard_view_owner;
GRANT SELECT ON hms_gold.dm_doi_tuong_benh_nhan_ngay TO dashboard_view_owner;
GRANT SELECT ON hms_gold.dm_icd10 TO dashboard_view_owner;
GRANT SELECT ON hms_silver.ct_luot_kham TO dashboard_view_owner;
GRANT SELECT ON hms_silver.ct_kham_benh TO dashboard_view_owner;
GRANT SELECT ON hms_silver.ct_dot_noi_tru TO dashboard_view_owner;
GRANT SELECT ON hms_silver.ct_don_thuoc TO dashboard_view_owner;
GRANT SELECT ON hms_silver.ct_xac_nhan_chi_phi TO dashboard_view_owner;
GRANT SELECT ON hms_silver.ct_gioi_tinh_tiep_nhan TO dashboard_view_owner;
GRANT SELECT ON hms_silver.ct_doi_tuong_benh_nhan TO dashboard_view_owner;
GRANT SELECT ON hms_silver.ct_chuyen_vien TO dashboard_view_owner;
GRANT SELECT ON hms_silver.ct_chi_dinh_dich_vu TO dashboard_view_owner;
GRANT SELECT ON hms_silver.ct_dong_doanh_thu TO dashboard_view_owner;
GRANT SELECT ON hms_silver.ct_icd10 TO dashboard_view_owner;
-- Nested Silver views execute under this non-login definer, never dashboard_api.
GRANT SELECT ON hms_raw.benh_nhan_dot_dieu_tri TO dashboard_view_owner;
GRANT SELECT ON hms_raw.benh_nhan_tiep_nhan TO dashboard_view_owner;
GRANT SELECT ON hms_raw.csyt_benh_an_dieu_tri TO dashboard_view_owner;
GRANT SELECT ON hms_raw.csyt_phieu_ra_vien TO dashboard_view_owner;
GRANT SELECT ON hms_raw.csyt_vien_phi_chung_tu TO dashboard_view_owner;
GRANT SELECT ON hms_raw.csyt_vien_phi_chung_tu_chi_tiet TO dashboard_view_owner;
GRANT SELECT ON hms_raw.csyt_xac_nhan_chi_phi TO dashboard_view_owner;
GRANT SELECT ON hms_raw.csyt_xac_nhan_chi_phi_vien_phi TO dashboard_view_owner;
GRANT SELECT ON hms_raw.csyt_yl_thuocvt TO dashboard_view_owner;
GRANT SELECT ON hms_raw.dm_chuong_icd10 TO dashboard_view_owner;
GRANT SELECT ON hms_raw.dmc_icd10 TO dashboard_view_owner;
GRANT SELECT ON hms_raw.dmc_ma_nhom_chi_phi TO dashboard_view_owner;
GRANT SELECT ON hms_raw.dm_nhom_icd10 TO dashboard_view_owner;
GRANT SELECT ON hms_raw.dm_so_thu_hoa_don TO dashboard_view_owner;
GRANT SELECT ON hms_raw.kb_kham_benh TO dashboard_view_owner;
GRANT SELECT ON hms_raw.kb_kham_benh_chuyen_vien TO dashboard_view_owner;
GRANT SELECT ON hms_raw.phieu_dich_vu_chi_tiet TO dashboard_view_owner;
GRANT SELECT ON hms_raw.tiep_nhan TO dashboard_view_owner;

CREATE OR REPLACE VIEW hms_gold.api_dashboard_summary
DEFINER = dashboard_view_owner
SQL SECURITY DEFINER
AS SELECT * FROM hms_gold.dm_dashboard_ngay;

CREATE OR REPLACE VIEW hms_gold.api_revenue_daily
DEFINER = dashboard_view_owner
SQL SECURITY DEFINER
AS SELECT * FROM hms_gold.dm_doanh_thu_ngay;

CREATE OR REPLACE VIEW hms_gold.api_icd10
DEFINER = dashboard_view_owner
SQL SECURITY DEFINER
AS SELECT * FROM hms_gold.dm_icd10;

CREATE OR REPLACE VIEW hms_gold.api_visits_daily
DEFINER = dashboard_view_owner
SQL SECURITY DEFINER
AS SELECT * FROM hms_gold.dm_luot_kham_ngay;

CREATE OR REPLACE VIEW hms_gold.api_examinations_daily
DEFINER = dashboard_view_owner
SQL SECURITY DEFINER
AS SELECT * FROM hms_gold.dm_kham_benh_ngay;

CREATE OR REPLACE VIEW hms_gold.api_inpatient_daily
DEFINER = dashboard_view_owner
SQL SECURITY DEFINER
AS SELECT * FROM hms_gold.dm_noi_tru_ngay;

CREATE OR REPLACE VIEW hms_gold.api_transfers_daily
DEFINER = dashboard_view_owner
SQL SECURITY DEFINER
AS SELECT * FROM hms_gold.dm_chuyen_vien_ngay;

CREATE OR REPLACE VIEW hms_gold.api_prescriptions_daily
DEFINER = dashboard_view_owner
SQL SECURITY DEFINER
AS SELECT * FROM hms_gold.dm_don_thuoc_ngay;

CREATE OR REPLACE VIEW hms_gold.api_cost_confirmations_daily
DEFINER = dashboard_view_owner
SQL SECURITY DEFINER
AS SELECT * FROM hms_gold.dm_xac_nhan_chi_phi_ngay;

CREATE OR REPLACE VIEW hms_gold.api_gender_daily
DEFINER = dashboard_view_owner
SQL SECURITY DEFINER
AS SELECT * FROM hms_gold.dm_gioi_tinh_ngay;

CREATE OR REPLACE VIEW hms_gold.api_patient_types_daily
DEFINER = dashboard_view_owner
SQL SECURITY DEFINER
AS SELECT * FROM hms_gold.dm_doi_tuong_benh_nhan_ngay;

CREATE USER IF NOT EXISTS dashboard_api
IDENTIFIED WITH sha256_password BY {dashboard_api_password:String};

CREATE SETTINGS PROFILE IF NOT EXISTS dashboard_api_profile
SETTINGS
    readonly = 1 READONLY,
    max_execution_time = 10 MAX 10,
    max_memory_usage = 1073741824 MAX 1073741824,
    max_result_rows = 50000 MAX 50000,
    max_result_bytes = 10485760 MAX 10485760,
    max_rows_to_read = 10000000 MAX 10000000
TO dashboard_api;

CREATE QUOTA IF NOT EXISTS dashboard_api_quota
FOR INTERVAL 1 HOUR MAX
    queries = 600,
    errors = 20,
    result_rows = 1000000,
    result_bytes = 268435456,
    read_rows = 500000000,
    execution_time = 3600
TO dashboard_api;

GRANT SELECT ON hms_gold.api_dashboard_summary TO dashboard_api;
GRANT SELECT ON hms_gold.api_revenue_daily TO dashboard_api;
GRANT SELECT ON hms_gold.api_icd10 TO dashboard_api;
GRANT SELECT ON hms_gold.api_visits_daily TO dashboard_api;
GRANT SELECT ON hms_gold.api_examinations_daily TO dashboard_api;
GRANT SELECT ON hms_gold.api_inpatient_daily TO dashboard_api;
GRANT SELECT ON hms_gold.api_transfers_daily TO dashboard_api;
GRANT SELECT ON hms_gold.api_prescriptions_daily TO dashboard_api;
GRANT SELECT ON hms_gold.api_cost_confirmations_daily TO dashboard_api;
GRANT SELECT ON hms_gold.api_gender_daily TO dashboard_api;
GRANT SELECT ON hms_gold.api_patient_types_daily TO dashboard_api;

-- Existing handlers keep their contract; IF NOT EXISTS makes this migration safe on the deployed lab server.
CREATE HANDLER IF NOT EXISTS dashboard_summary
URL '/api/v1/dashboard-summary'
METHODS (GET)
AS
WITH
    {from_date:Date} AS from_date,
    {to_date:Date} AS to_date
SELECT *
FROM hms_gold.api_dashboard_summary
WHERE throwIf(to_date < from_date, 'from_date must not be after to_date') = 0
  AND throwIf(dateDiff('day', from_date, to_date) > 366, 'date range must not exceed 366 days') = 0
  AND ngay >= from_date
  AND ngay < addDays(to_date, 1)
ORDER BY ngay
FORMAT JSONEachRow;

CREATE HANDLER IF NOT EXISTS revenue_daily
URL '/api/v1/revenue-daily'
METHODS (GET)
AS
WITH
    {from_date:Date} AS from_date,
    {to_date:Date} AS to_date
SELECT *
FROM hms_gold.api_revenue_daily
WHERE throwIf(to_date < from_date, 'from_date must not be after to_date') = 0
  AND throwIf(dateDiff('day', from_date, to_date) > 366, 'date range must not exceed 366 days') = 0
  AND ngay >= from_date
  AND ngay < addDays(to_date, 1)
ORDER BY ngay, nhom_doanh_thu
FORMAT JSONEachRow;

CREATE HANDLER IF NOT EXISTS icd10
URL '/api/v1/icd10'
METHODS (GET)
AS
WITH
    {from_date:Date} AS from_date,
    {to_date:Date} AS to_date
SELECT *
FROM hms_gold.api_icd10
WHERE throwIf(to_date < from_date, 'from_date must not be after to_date') = 0
  AND throwIf(dateDiff('day', from_date, to_date) > 366, 'date range must not exceed 366 days') = 0
  AND ngay >= from_date
  AND ngay < addDays(to_date, 1)
ORDER BY ngay, loai_thanh_toan, ma_icd10
LIMIT 10000
FORMAT JSONEachRow;

CREATE HANDLER IF NOT EXISTS visits_daily
URL '/api/v1/visits-daily'
METHODS (GET)
AS
WITH
    {from_date:Date} AS from_date,
    {to_date:Date} AS to_date
SELECT *
FROM hms_gold.api_visits_daily
WHERE throwIf(to_date < from_date, 'from_date must not be after to_date') = 0
  AND throwIf(dateDiff('day', from_date, to_date) > 366, 'date range must not exceed 366 days') = 0
  AND ngay >= from_date
  AND ngay < addDays(to_date, 1)
ORDER BY ngay
FORMAT JSONEachRow;

CREATE HANDLER IF NOT EXISTS examinations_daily
URL '/api/v1/examinations-daily'
METHODS (GET)
AS
WITH
    {from_date:Date} AS from_date,
    {to_date:Date} AS to_date
SELECT *
FROM hms_gold.api_examinations_daily
WHERE throwIf(to_date < from_date, 'from_date must not be after to_date') = 0
  AND throwIf(dateDiff('day', from_date, to_date) > 366, 'date range must not exceed 366 days') = 0
  AND ngay >= from_date
  AND ngay < addDays(to_date, 1)
ORDER BY ngay
FORMAT JSONEachRow;

CREATE HANDLER IF NOT EXISTS inpatient_daily
URL '/api/v1/inpatient-daily'
METHODS (GET)
AS
WITH
    {from_date:Date} AS from_date,
    {to_date:Date} AS to_date
SELECT *
FROM hms_gold.api_inpatient_daily
WHERE throwIf(to_date < from_date, 'from_date must not be after to_date') = 0
  AND throwIf(dateDiff('day', from_date, to_date) > 366, 'date range must not exceed 366 days') = 0
  AND ngay >= from_date
  AND ngay < addDays(to_date, 1)
ORDER BY ngay
FORMAT JSONEachRow;

CREATE HANDLER IF NOT EXISTS transfers_daily
URL '/api/v1/transfers-daily'
METHODS (GET)
AS
WITH
    {from_date:Date} AS from_date,
    {to_date:Date} AS to_date
SELECT *
FROM hms_gold.api_transfers_daily
WHERE throwIf(to_date < from_date, 'from_date must not be after to_date') = 0
  AND throwIf(dateDiff('day', from_date, to_date) > 366, 'date range must not exceed 366 days') = 0
  AND ngay >= from_date
  AND ngay < addDays(to_date, 1)
ORDER BY ngay
FORMAT JSONEachRow;

CREATE HANDLER IF NOT EXISTS prescriptions_daily
URL '/api/v1/prescriptions-daily'
METHODS (GET)
AS
WITH
    {from_date:Date} AS from_date,
    {to_date:Date} AS to_date
SELECT *
FROM hms_gold.api_prescriptions_daily
WHERE throwIf(to_date < from_date, 'from_date must not be after to_date') = 0
  AND throwIf(dateDiff('day', from_date, to_date) > 366, 'date range must not exceed 366 days') = 0
  AND ngay >= from_date
  AND ngay < addDays(to_date, 1)
ORDER BY ngay
FORMAT JSONEachRow;

CREATE HANDLER IF NOT EXISTS cost_confirmations_daily
URL '/api/v1/cost-confirmations-daily'
METHODS (GET)
AS
WITH
    {from_date:Date} AS from_date,
    {to_date:Date} AS to_date
SELECT *
FROM hms_gold.api_cost_confirmations_daily
WHERE throwIf(to_date < from_date, 'from_date must not be after to_date') = 0
  AND throwIf(dateDiff('day', from_date, to_date) > 366, 'date range must not exceed 366 days') = 0
  AND ngay >= from_date
  AND ngay < addDays(to_date, 1)
ORDER BY ngay
FORMAT JSONEachRow;

CREATE HANDLER IF NOT EXISTS gender_daily
URL '/api/v1/gender-daily'
METHODS (GET)
AS
WITH
    {from_date:Date} AS from_date,
    {to_date:Date} AS to_date
SELECT *
FROM hms_gold.api_gender_daily
WHERE throwIf(to_date < from_date, 'from_date must not be after to_date') = 0
  AND throwIf(dateDiff('day', from_date, to_date) > 366, 'date range must not exceed 366 days') = 0
  AND ngay >= from_date
  AND ngay < addDays(to_date, 1)
ORDER BY ngay
FORMAT JSONEachRow;

CREATE HANDLER IF NOT EXISTS patient_types_daily
URL '/api/v1/patient-types-daily'
METHODS (GET)
AS
WITH
    {from_date:Date} AS from_date,
    {to_date:Date} AS to_date
SELECT *
FROM hms_gold.api_patient_types_daily
WHERE throwIf(to_date < from_date, 'from_date must not be after to_date') = 0
  AND throwIf(dateDiff('day', from_date, to_date) > 366, 'date range must not exceed 366 days') = 0
  AND ngay >= from_date
  AND ngay < addDays(to_date, 1)
ORDER BY ngay
FORMAT JSONEachRow;
