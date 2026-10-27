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
WHERE toString(ifNull(tn.bi_xoa, 0)) IN ('0', 'false', 'f');

CREATE OR REPLACE VIEW hms_silver.ct_dot_noi_tru AS
WITH events AS (
    SELECT
        toString(id) AS dot_noi_tru_key,
        toDate(ngay_vao_vien) AS ngay_vao_vien,
        CAST(NULL AS Nullable(Date)) AS ngay_ra_vien,
        'ADMISSION' AS loai_su_kien
    FROM hms_raw.csyt_benh_an_dieu_tri FINAL
    WHERE toString(ifNull(bi_xoa, 0)) IN ('0', 'false', 'f')
    UNION ALL
    SELECT
        toString(ifNull(benh_an_id, id)) AS dot_noi_tru_key,
        CAST(NULL AS Nullable(Date)) AS ngay_vao_vien,
        toDate(thoi_gian_ra_vien) AS ngay_ra_vien,
        'DISCHARGE' AS loai_su_kien
    FROM hms_raw.csyt_phieu_ra_vien FINAL
    WHERE toString(ifNull(bi_xoa, 0)) IN ('0', 'false', 'f')
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
WHERE toString(ifNull(bi_xoa, 0)) IN ('0', 'false', 'f');

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

CREATE OR REPLACE VIEW hms_silver.ct_kham_benh AS
SELECT
    id AS kham_benh_id,
    tiep_nhan_id,
    toDate(thoi_gian_bat_dau) AS ngay_kham
FROM hms_raw.kb_kham_benh FINAL
WHERE toString(ifNull(bi_xoa, 0)) IN ('0', 'false', 'f');

CREATE OR REPLACE VIEW hms_silver.ct_chuyen_vien AS
SELECT
    id AS chuyen_vien_id,
    toDate(ngay_lap) AS ngay_chuyen_vien
FROM hms_raw.kb_kham_benh_chuyen_vien FINAL
WHERE toString(ifNull(bi_xoa, 0)) IN ('0', 'false', 'f');

CREATE OR REPLACE VIEW hms_silver.ct_xac_nhan_chi_phi AS
SELECT
    id AS xac_nhan_chi_phi_id,
    toDate(ngay_xac_nhan) AS ngay_xac_nhan,
    toUInt8(toString(ifNull(xuat_xml, 0)) IN ('1', 'true', 't')) AS is_xuat_xml
FROM hms_raw.csyt_xac_nhan_chi_phi FINAL
WHERE toString(ifNull(bi_xoa, 0)) IN ('0', 'false', 'f');

CREATE OR REPLACE VIEW hms_silver.ct_gioi_tinh_tiep_nhan AS
SELECT
    bn.id AS benh_nhan_tiep_nhan_id,
    tn.id AS tiep_nhan_id,
    toDate(tn.ngay_tiep_nhan) AS ngay_tiep_nhan,
    multiIf(
        toString(bn.ma_gioi_tinh) = '2', 'NAM',
        toString(bn.ma_gioi_tinh) = '1', 'NU',
        'CHUA_XAC_DINH'
    ) AS gioi_tinh
FROM (SELECT * FROM hms_raw.benh_nhan_tiep_nhan FINAL) AS bn
INNER JOIN (SELECT * FROM hms_raw.tiep_nhan FINAL) AS tn ON tn.id = bn.tiep_nhan_id
WHERE toString(ifNull(bn.bi_xoa, 0)) IN ('0', 'false', 'f')
  AND toString(ifNull(tn.bi_xoa, 0)) IN ('0', 'false', 'f');

CREATE OR REPLACE VIEW hms_silver.ct_doi_tuong_benh_nhan AS
SELECT
    a.id AS dot_dieu_tri_id,
    toDate(tn.ngay_tiep_nhan) AS ngay_tiep_nhan,
    multiIf(
        a.is_bhyt = 1 AND toString(a.ma_quyen_loi) = '5', 'CAN_BO_CAND',
        (a.is_bhyt = 1 AND toString(a.ma_quyen_loi) IN ('1', '2', '3', '4')) OR a.is_bhyt = 0, 'NGUOI_DAN',
        'KHONG_XEP_LOAI'
    ) AS loai_doi_tuong
FROM (SELECT * FROM hms_raw.benh_nhan_dot_dieu_tri FINAL) AS a
INNER JOIN (SELECT * FROM hms_raw.tiep_nhan FINAL) AS tn ON tn.id = a.tiep_nhan_id
WHERE toString(ifNull(a.bi_xoa, 0)) IN ('0', 'false', 'f')
  AND toString(ifNull(tn.bi_xoa, 0)) IN ('0', 'false', 'f');

CREATE OR REPLACE VIEW hms_silver.ct_icd10 AS
WITH nguon AS (
    SELECT
        'BHYT' AS loai_thanh_toan,
        toDate(ngay_ra) AS ngay_ra,
        toString(ifNull(ma_benh_chinh, '')) AS ma_benh_chinh,
        toString(ifNull(ma_benh_kem_theo, '')) AS ma_benh_kem_theo,
        toString(ma_lk) AS ma_lk,
        benh_nhan_id
    FROM hms_raw.csyt_xac_nhan_chi_phi FINAL
    WHERE toString(ifNull(bi_xoa, 0)) IN ('0', 'false', 'f')
    UNION ALL
    SELECT
        'VIEN_PHI' AS loai_thanh_toan,
        toDate(ngay_ra) AS ngay_ra,
        toString(ifNull(ma_benh_chinh, '')) AS ma_benh_chinh,
        toString(ifNull(ma_benh_kem_theo, '')) AS ma_benh_kem_theo,
        toString(ma_lk) AS ma_lk,
        benh_nhan_id
    FROM hms_raw.csyt_xac_nhan_chi_phi_vien_phi FINAL
    WHERE toString(ifNull(bi_xoa, 0)) IN ('0', 'false', 'f')
), du_lieu_icd AS (
    SELECT
        loai_thanh_toan,
        ngay_ra,
        ma_lk,
        benh_nhan_id,
        arrayJoin(arrayDistinct(arrayFilter(x -> x != '', arrayMap(x -> upper(trimBoth(x)), arrayConcat([ma_benh_chinh], splitByChar(';', ma_benh_kem_theo)))))) AS ma_icd10
    FROM nguon
), danh_muc_icd AS (
    SELECT
        upper(trimBoth(toString(di.ma))) AS ma_icd10,
        toString(di.ten) AS ten_benh,
        toString(dni.ma) AS ma_nhom_icd10,
        toString(dni.ten) AS ten_nhom_icd10,
        toString(dci.ma) AS ma_chuong_icd10,
        toString(dci.ten) AS ten_chuong_icd10
    FROM (SELECT * FROM hms_raw.dmc_icd10 FINAL) AS di
    LEFT JOIN (SELECT * FROM hms_raw.dm_nhom_icd10 FINAL) AS dni ON dni.id = di.nhom_icd10_id
    LEFT JOIN (SELECT * FROM hms_raw.dm_chuong_icd10 FINAL) AS dci ON dci.ma = dni.chuong_icd10_ma
    WHERE toString(ifNull(di.bi_xoa, 0)) IN ('0', 'false', 'f')
)
SELECT
    dl.ngay_ra,
    coalesce(dm.ma_chuong_icd10, '') AS ma_chuong_icd10,
    coalesce(dm.ten_chuong_icd10, '') AS ten_chuong_icd10,
    coalesce(dm.ma_nhom_icd10, '') AS ma_nhom_icd10,
    coalesce(dm.ten_nhom_icd10, '') AS ten_nhom_icd10,
    dl.ma_icd10,
    coalesce(dm.ten_benh, '') AS ten_benh,
    dl.loai_thanh_toan,
    dl.ma_lk,
    dl.benh_nhan_id
FROM du_lieu_icd AS dl
LEFT JOIN danh_muc_icd AS dm ON dm.ma_icd10 = dl.ma_icd10;
