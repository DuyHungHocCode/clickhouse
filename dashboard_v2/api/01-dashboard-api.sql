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
GRANT SELECT ON hms_gold.dm_icd10 TO dashboard_view_owner;
GRANT SELECT ON hms_silver.ct_luot_kham TO dashboard_view_owner;
GRANT SELECT ON hms_silver.ct_kham_benh TO dashboard_view_owner;
GRANT SELECT ON hms_silver.ct_dot_noi_tru TO dashboard_view_owner;
GRANT SELECT ON hms_silver.ct_don_thuoc TO dashboard_view_owner;
GRANT SELECT ON hms_silver.ct_xac_nhan_chi_phi TO dashboard_view_owner;
GRANT SELECT ON hms_silver.ct_chuyen_vien TO dashboard_view_owner;
GRANT SELECT ON hms_silver.ct_dong_doanh_thu TO dashboard_view_owner;
GRANT SELECT ON hms_silver.ct_icd10 TO dashboard_view_owner;

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

CREATE HANDLER dashboard_summary
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

CREATE HANDLER revenue_daily
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

CREATE HANDLER icd10
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
