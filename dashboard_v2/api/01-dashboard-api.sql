-- Apply with --param_dashboard_api_password from the destination secret store.
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

GRANT SELECT ON hms_gold.dm_dashboard_ngay TO dashboard_api;
GRANT SELECT ON hms_gold.dm_doanh_thu_ngay TO dashboard_api;
GRANT SELECT ON hms_gold.dm_icd10 TO dashboard_api;

CREATE HANDLER dashboard_summary
URL '/api/v1/dashboard-summary'
METHODS (GET)
AS
SELECT *
FROM hms_gold.dm_dashboard_ngay
WHERE ngay >= {from_date:Date}
  AND ngay < addDays({to_date:Date}, 1)
ORDER BY ngay
FORMAT JSONEachRow;

CREATE HANDLER revenue_daily
URL '/api/v1/revenue-daily'
METHODS (GET)
AS
SELECT *
FROM hms_gold.dm_doanh_thu_ngay
WHERE ngay >= {from_date:Date}
  AND ngay < addDays({to_date:Date}, 1)
ORDER BY ngay, nhom_doanh_thu
FORMAT JSONEachRow;

CREATE HANDLER icd10
URL '/api/v1/icd10'
METHODS (GET)
AS
SELECT *
FROM hms_gold.dm_icd10
WHERE ngay >= {from_date:Date}
  AND ngay < addDays({to_date:Date}, 1)
ORDER BY ngay, loai_thanh_toan, ma_icd10
LIMIT 10000
FORMAT JSONEachRow;
