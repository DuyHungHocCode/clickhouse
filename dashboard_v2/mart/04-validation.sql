-- Run after the four setup files. Replace dates with the reconciliation window.

-- Raw/source availability.
SELECT database, name, engine, total_rows
FROM system.tables
WHERE database IN ('hms_raw', 'hms_silver', 'hms_gold')
ORDER BY database, name;

-- Half-open date boundary used by every dashboard query.
SELECT
    toDate({from_date:Date}) AS from_date,
    toDate({to_date:Date}) AS to_date,
    toDate({to_date:Date}) + 1 AS exclusive_to_date;

-- Canonical grain: no duplicate encounter keys.
SELECT tiep_nhan_id, count()
FROM hms_silver.ct_luot_kham
GROUP BY tiep_nhan_id
HAVING count() > 1
LIMIT 20;

-- Canonical prescription grain: one row per composite prescription key.
SELECT khambenh_id, mauhososohoa_id, count()
FROM hms_silver.ct_don_thuoc
GROUP BY khambenh_id, mauhososohoa_id
HAVING count() > 1
LIMIT 20;

-- Revenue should contain only paid, non-refunded, non-cancelled SBL rows.
SELECT ngay_thu, nhom_doanh_thu, sum(doanh_thu_thuan)
FROM hms_silver.ct_dong_doanh_thu
GROUP BY ngay_thu, nhom_doanh_thu
ORDER BY ngay_thu, nhom_doanh_thu;

-- Daily semantic mart: use this output to reconcile fn_dashboard_summary.
SELECT *
FROM hms_gold.dm_dashboard_ngay
WHERE ngay >= toDate({from_date:Date})
  AND ngay < toDate({to_date:Date}) + 1
ORDER BY ngay;

-- ICD-10 mart preserves the three different measures used by the function.
SELECT *
FROM hms_gold.dm_icd10
WHERE ngay >= toDate({from_date:Date})
  AND ngay < toDate({to_date:Date}) + 1
ORDER BY ngay, loai_thanh_toan, ma_icd10;

-- Gold must not contain direct patient identifiers.
SELECT name
FROM system.columns
WHERE database = 'hms_gold'
  AND (name ILIKE '%benh_nhan_id%' OR name ILIKE '%so_dien_thoai%'
       OR name ILIKE '%dia_chi%' OR name ILIKE '%ho_ten%');
