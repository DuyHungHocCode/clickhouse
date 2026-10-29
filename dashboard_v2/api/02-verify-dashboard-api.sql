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
WHERE name IN (
    'dashboard_summary', 'revenue_daily', 'icd10',
    'visits_daily', 'examinations_daily', 'inpatient_daily', 'transfers_daily',
    'prescriptions_daily', 'cost_confirmations_daily', 'gender_daily', 'patient_types_daily'
)
ORDER BY name;

SELECT name, create_table_query
FROM system.tables
WHERE database = 'hms_gold'
  AND name IN (
      'api_dashboard_summary', 'api_revenue_daily', 'api_icd10',
      'api_visits_daily', 'api_examinations_daily', 'api_inpatient_daily', 'api_transfers_daily',
      'api_prescriptions_daily', 'api_cost_confirmations_daily', 'api_gender_daily', 'api_patient_types_daily'
  )
ORDER BY name;

SELECT *
FROM hms_gold.api_dashboard_summary
WHERE ngay >= {from_date:Date}
  AND ngay < addDays({to_date:Date}, 1)
ORDER BY ngay;

SELECT * FROM hms_gold.api_revenue_daily WHERE ngay >= {from_date:Date} AND ngay < addDays({to_date:Date}, 1) ORDER BY ngay LIMIT 1;
SELECT * FROM hms_gold.api_icd10 WHERE ngay >= {from_date:Date} AND ngay < addDays({to_date:Date}, 1) ORDER BY ngay LIMIT 1;
SELECT * FROM hms_gold.api_visits_daily WHERE ngay >= {from_date:Date} AND ngay < addDays({to_date:Date}, 1) ORDER BY ngay LIMIT 1;
SELECT * FROM hms_gold.api_examinations_daily WHERE ngay >= {from_date:Date} AND ngay < addDays({to_date:Date}, 1) ORDER BY ngay LIMIT 1;
SELECT * FROM hms_gold.api_inpatient_daily WHERE ngay >= {from_date:Date} AND ngay < addDays({to_date:Date}, 1) ORDER BY ngay LIMIT 1;
SELECT * FROM hms_gold.api_transfers_daily WHERE ngay >= {from_date:Date} AND ngay < addDays({to_date:Date}, 1) ORDER BY ngay LIMIT 1;
SELECT * FROM hms_gold.api_prescriptions_daily WHERE ngay >= {from_date:Date} AND ngay < addDays({to_date:Date}, 1) ORDER BY ngay LIMIT 1;
SELECT * FROM hms_gold.api_cost_confirmations_daily WHERE ngay >= {from_date:Date} AND ngay < addDays({to_date:Date}, 1) ORDER BY ngay LIMIT 1;
SELECT * FROM hms_gold.api_gender_daily WHERE ngay >= {from_date:Date} AND ngay < addDays({to_date:Date}, 1) ORDER BY ngay LIMIT 1;
SELECT * FROM hms_gold.api_patient_types_daily WHERE ngay >= {from_date:Date} AND ngay < addDays({to_date:Date}, 1) ORDER BY ngay LIMIT 1;
