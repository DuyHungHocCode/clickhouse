-- Run as an administrator after api/01-dashboard-api.sql.
SHOW GRANTS FOR dashboard_api;

SELECT name
FROM system.settings_profiles
WHERE name = 'dashboard_api_profile';

SELECT name
FROM system.quotas
WHERE name = 'dashboard_api_quota';

SELECT name, url, methods
FROM system.handlers
WHERE name IN ('dashboard_summary', 'revenue_daily', 'icd10')
ORDER BY name;

SELECT *
FROM hms_gold.dm_dashboard_ngay
WHERE ngay >= {from_date:Date}
  AND ngay < addDays({to_date:Date}, 1)
ORDER BY ngay;
