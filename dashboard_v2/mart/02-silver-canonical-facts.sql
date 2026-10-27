-- Canonical facts. Every view below has one declared grain; do not join these
-- facts to each other in Gold unless the grain is explicitly preserved.

CREATE OR REPLACE VIEW hms_silver.ct_luot_kham AS
WITH emergency AS (
    SELECT DISTINCT tiep_nhan_id
    FROM hms_raw.benh_nhan_dot_dieu_tri FINAL
    WHERE toString(ma_doi_tuong_lt) = '2'
)
SELECT
    tn.id AS tiep_nhan_id,
    toDate(tn.ngay_tiep_nhan) AS ngay_tiep_nhan,
    toUInt8(toString(tn.ma_ly_do_tiep_nhan) = '02' OR e.tiep_nhan_id IS NOT NULL) AS is_cap_cuu,
    toUInt8(kb.tiep_nhan_id IS NOT NULL) AS is_kham_benh,
    1 AS so_luot_tiep_nhan
FROM (SELECT * FROM hms_raw.tiep_nhan FINAL) AS tn
LEFT JOIN emergency e ON e.tiep_nhan_id = tn.id
LEFT JOIN (
    SELECT DISTINCT tiep_nhan_id
    FROM hms_raw.kb_kham_benh FINAL
) kb ON kb.tiep_nhan_id = tn.id
;

CREATE OR REPLACE VIEW hms_silver.ct_dot_noi_tru AS
WITH events AS (
    SELECT
        toString(ifNull(benh_nhan_dot_dieu_tri_id, id)) AS dot_noi_tru_key,
        toDate(ngay_vao_vien) AS ngay_vao_vien,
        CAST(NULL AS Nullable(Date)) AS ngay_ra_vien,
        'ADMISSION' AS loai_su_kien
    FROM hms_raw.csyt_benh_an_dieu_tri FINAL
    UNION ALL
    SELECT
        toString(ifNull(benh_nhan_dot_dieu_tri_id, id)) AS dot_noi_tru_key,
        CAST(NULL AS Nullable(Date)) AS ngay_vao_vien,
        toDate(thoi_gian_ra_vien) AS ngay_ra_vien,
        'DISCHARGE' AS loai_su_kien
    FROM hms_raw.csyt_phieu_ra_vien FINAL
)
SELECT
    dot_noi_tru_key,
    minIf(ngay_vao_vien, loai_su_kien = 'ADMISSION') AS ngay_vao_vien,
    maxIf(ngay_ra_vien, loai_su_kien = 'DISCHARGE') AS ngay_ra_vien
FROM events
GROUP BY dot_noi_tru_key;

CREATE OR REPLACE VIEW hms_silver.ct_don_thuoc AS
SELECT
    khambenh_id,
    mauhososohoa_id,
    min(toDate(ngay_chidinh)) AS ngay_don_thuoc,
    count() AS so_dong_thuoc
FROM hms_raw.csyt_yl_thuocvt FINAL
GROUP BY khambenh_id, mauhososohoa_id;

CREATE OR REPLACE VIEW hms_silver.ct_chi_dinh_dich_vu AS
SELECT
    id AS chi_dinh_id,
    toDate(ngay_chi_dinh) AS ngay_chi_dinh
FROM hms_raw.phieu_dich_vu_chi_tiet FINAL
;

CREATE OR REPLACE VIEW hms_silver.ct_dong_doanh_thu AS
SELECT
    a.id AS chung_tu_id,
    cvpctct.id AS chi_tiet_id,
    toDate(a.ngay_thu) AS ngay_thu,
    coalesce(dmncp.ten_khac, '20. Khác') AS nhom_doanh_thu,
    toDecimal64(coalesce(cvpctct.thanh_tien_benh_nhan_cung_chi_tra, 0), 2)
      + toDecimal64(coalesce(cvpctct.thanh_tien_benh_nhan_tu_thanh_toan, 0), 2) AS doanh_thu_thuan
FROM (SELECT * FROM hms_raw.csyt_vien_phi_chung_tu FINAL) AS a
LEFT JOIN (SELECT * FROM hms_raw.dm_so_thu_hoa_don FINAL) AS sthd ON sthd.id = a.so_thu_id
INNER JOIN (SELECT * FROM hms_raw.csyt_vien_phi_chung_tu_chi_tiet FINAL) AS cvpctct
    ON cvpctct.csyt_vien_phi_chung_tu_id = a.id
LEFT JOIN (SELECT * FROM hms_raw.dmc_ma_nhom_chi_phi FINAL) AS dmncp
    ON dmncp.id = cvpctct.ma_nhom_bhyt_id
WHERE toString(ifNull(a.da_thanh_toan, 0)) IN ('1', 'true', 't')
  AND toString(ifNull(a.hoan_tra, 0)) IN ('0', 'false', 'f')
  AND toString(ifNull(a.huy_hoa_don, 0)) IN ('0', 'false', 'f')
  AND sthd.ma_loai_so = 'SBL';
