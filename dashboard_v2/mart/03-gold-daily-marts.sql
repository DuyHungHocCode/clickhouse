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

CREATE OR REPLACE VIEW hms_gold.dm_kham_benh_ngay AS
SELECT
    ngay_kham AS ngay,
    count() AS so_luot_kham
FROM hms_silver.ct_kham_benh
GROUP BY ngay_kham;

CREATE OR REPLACE VIEW hms_gold.dm_chuyen_vien_ngay AS
SELECT
    ngay_chuyen_vien AS ngay,
    count() AS so_ca_chuyen_vien
FROM hms_silver.ct_chuyen_vien
GROUP BY ngay_chuyen_vien;

CREATE OR REPLACE VIEW hms_gold.dm_xac_nhan_chi_phi_ngay AS
SELECT
    ngay_xac_nhan AS ngay,
    count() AS so_xac_nhan_chi_phi_bhyt,
    sum(is_xuat_xml) AS so_xuat_xml
FROM hms_silver.ct_xac_nhan_chi_phi
GROUP BY ngay_xac_nhan;

CREATE OR REPLACE VIEW hms_gold.dm_gioi_tinh_ngay AS
SELECT
    ngay_tiep_nhan AS ngay,
    countIf(gioi_tinh = 'NAM') AS c_nam,
    countIf(gioi_tinh = 'NU') AS c_nu,
    countIf(gioi_tinh = 'CHUA_XAC_DINH') AS c_chua_xac_dinh
FROM hms_silver.ct_gioi_tinh_tiep_nhan
GROUP BY ngay_tiep_nhan;

CREATE OR REPLACE VIEW hms_gold.dm_doi_tuong_benh_nhan_ngay AS
SELECT
    ngay_tiep_nhan AS ngay,
    countIf(loai_doi_tuong = 'CAN_BO_CAND') AS c_can_bo_cand,
    countIf(loai_doi_tuong = 'NGUOI_DAN') AS c_nguoi_dan
FROM hms_silver.ct_doi_tuong_benh_nhan
GROUP BY ngay_tiep_nhan;

CREATE OR REPLACE VIEW hms_gold.dm_icd10 AS
SELECT
    ngay_ra AS ngay,
    ma_chuong_icd10,
    ten_chuong_icd10,
    ma_nhom_icd10,
    ten_nhom_icd10,
    ma_icd10,
    ten_benh,
    loai_thanh_toan,
    count() AS so_ban_ghi,
    uniqExact(ma_lk) AS so_luot_kcb,
    uniqExact(benh_nhan_id) AS so_benh_nhan
FROM hms_silver.ct_icd10
GROUP BY
    ngay_ra,
    ma_chuong_icd10,
    ten_chuong_icd10,
    ma_nhom_icd10,
    ten_nhom_icd10,
    ma_icd10,
    ten_benh,
    loai_thanh_toan;

CREATE OR REPLACE VIEW hms_gold.dm_dashboard_ngay AS
WITH all_measures AS (
    SELECT ngay, so_luot_tiep_nhan, 0 AS so_luot_kham, so_luot_cap_cuu, 0 AS so_ca_vao_vien, 0 AS so_ca_ra_vien, 0 AS so_ca_chuyen_vien, 0 AS so_don_thuoc, 0 AS so_chi_dinh_dich_vu, 0 AS so_xac_nhan_chi_phi_bhyt, 0 AS so_xuat_xml, toDecimal64(0, 2) AS tong_doanh_thu_thuan
    FROM hms_gold.dm_luot_kham_ngay
    UNION ALL
    SELECT ngay, 0, so_luot_kham, 0, 0, 0, 0, 0, 0, 0, 0, toDecimal64(0, 2)
    FROM hms_gold.dm_kham_benh_ngay
    UNION ALL
    SELECT ngay, 0, 0, 0, so_ca_vao_vien, so_ca_ra_vien, 0, 0, 0, 0, 0, toDecimal64(0, 2)
    FROM hms_gold.dm_noi_tru_ngay
    UNION ALL
    SELECT ngay, 0, 0, 0, 0, 0, so_ca_chuyen_vien, 0, 0, 0, 0, toDecimal64(0, 2)
    FROM hms_gold.dm_chuyen_vien_ngay
    UNION ALL
    SELECT ngay, 0, 0, 0, 0, 0, 0, so_don_thuoc, 0, 0, 0, toDecimal64(0, 2)
    FROM hms_gold.dm_don_thuoc_ngay
    UNION ALL
    SELECT ngay_chi_dinh AS ngay, 0, 0, 0, 0, 0, 0, 0, count(), 0, 0, toDecimal64(0, 2)
    FROM hms_silver.ct_chi_dinh_dich_vu
    GROUP BY ngay_chi_dinh
    UNION ALL
    SELECT ngay, 0, 0, 0, 0, 0, 0, 0, 0, so_xac_nhan_chi_phi_bhyt, so_xuat_xml, toDecimal64(0, 2)
    FROM hms_gold.dm_xac_nhan_chi_phi_ngay
    UNION ALL
    SELECT ngay, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, sum(tong_doanh_thu_thuan)
    FROM hms_gold.dm_doanh_thu_ngay
    GROUP BY ngay
)
SELECT
    ngay,
    sum(so_luot_tiep_nhan) AS so_luot_tiep_nhan,
    sum(so_luot_kham) AS so_luot_kham,
    sum(so_luot_cap_cuu) AS so_luot_cap_cuu,
    sum(so_ca_vao_vien) AS so_ca_vao_vien,
    sum(so_ca_ra_vien) AS so_ca_ra_vien,
    sum(so_ca_chuyen_vien) AS so_ca_chuyen_vien,
    sum(so_don_thuoc) AS so_don_thuoc,
    sum(so_chi_dinh_dich_vu) AS so_chi_dinh_dich_vu,
    sum(so_xac_nhan_chi_phi_bhyt) AS so_xac_nhan_chi_phi_bhyt,
    sum(so_xuat_xml) AS so_xuat_xml,
    sum(tong_doanh_thu_thuan) AS tong_doanh_thu_thuan
FROM all_measures
GROUP BY ngay;

-- Query contract for the dashboard API. Use typed parameters in the client:
-- current:  ngay >= toDate(from_date) AND ngay < toDate(to_date) + 1
-- previous_from = from_date - (to_date - from_date + 1) days
-- previous_to   = from_date - 1 day
-- The current implementation deliberately omits bed capacity until the
-- source bed-plan tables are identified.
