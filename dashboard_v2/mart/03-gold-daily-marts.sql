-- Gold marts are intentionally views in phase 1. Convert to tables or
-- materialized views only after parity checks against PostgreSQL functions.

CREATE OR REPLACE VIEW hms_gold.dm_luot_kham_ngay AS
SELECT
    ngay_tiep_nhan AS ngay,
    sum(so_luot_tiep_nhan) AS so_luot_tiep_nhan,
    sum(is_kham_benh) AS so_luot_kham,
    sum(is_cap_cuu) AS so_luot_cap_cuu
FROM hms_silver.ct_luot_kham
GROUP BY ngay_tiep_nhan;

CREATE OR REPLACE VIEW hms_gold.dm_don_thuoc_ngay AS
SELECT
    ngay_don_thuoc AS ngay,
    count() AS so_don_thuoc
FROM hms_silver.ct_don_thuoc
GROUP BY ngay_don_thuoc;

CREATE OR REPLACE VIEW hms_gold.dm_noi_tru_ngay AS
SELECT
    ngay,
    sum(so_ca_vao_vien) AS so_ca_vao_vien,
    sum(so_ca_ra_vien) AS so_ca_ra_vien
FROM (
    SELECT ngay_vao_vien AS ngay, 1 AS so_ca_vao_vien, 0 AS so_ca_ra_vien
    FROM hms_silver.ct_dot_noi_tru
    WHERE ngay_vao_vien IS NOT NULL
    UNION ALL
    SELECT ngay_ra_vien AS ngay, 0 AS so_ca_vao_vien, 1 AS so_ca_ra_vien
    FROM hms_silver.ct_dot_noi_tru
    WHERE ngay_ra_vien IS NOT NULL
)
GROUP BY ngay;

CREATE OR REPLACE VIEW hms_gold.dm_doanh_thu_ngay AS
SELECT
    ngay_thu AS ngay,
    nhom_doanh_thu,
    sum(doanh_thu_thuan) AS tong_doanh_thu_thuan
FROM hms_silver.ct_dong_doanh_thu
GROUP BY ngay_thu, nhom_doanh_thu;

-- Query contract for the dashboard API. Use typed parameters in the client:
-- current:  ngay >= toDate(from_date) AND ngay < toDate(to_date) + 1
-- previous_from = from_date - (to_date - from_date + 1) days
-- previous_to   = from_date - 1 day
-- The current implementation deliberately omits bed capacity until the
-- source bed-plan tables are identified.
