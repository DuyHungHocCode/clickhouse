\set ON_ERROR_STOP on
\if :{?peerdb_source_password}
\else
  \echo 'Run with: psql -v peerdb_source_password=... -f 03-postgres-publication.sql'
  \quit
\endif

DO $$
BEGIN
  IF NOT EXISTS (SELECT 1 FROM pg_roles WHERE rolname = 'peerdb_hms_user') THEN
    CREATE ROLE peerdb_hms_user LOGIN REPLICATION BYPASSRLS;
  END IF;
END $$;

ALTER ROLE peerdb_hms_user PASSWORD :'peerdb_source_password';
GRANT USAGE ON SCHEMA tenant_bvcahn TO peerdb_hms_user;
GRANT SELECT ON TABLE
  tenant_bvcahn.tiep_nhan,
  tenant_bvcahn.benh_nhan_tiep_nhan,
  tenant_bvcahn.benh_nhan_dot_dieu_tri,
  tenant_bvcahn.kb_kham_benh,
  tenant_bvcahn.kb_kham_benh_chuyen_vien,
  tenant_bvcahn.csyt_benh_an_dieu_tri,
  tenant_bvcahn.csyt_phieu_ra_vien,
  tenant_bvcahn.phieu_dich_vu_chi_tiet,
  tenant_bvcahn.csyt_yl_thuocvt,
  tenant_bvcahn.csyt_vien_phi_chung_tu,
  tenant_bvcahn.csyt_vien_phi_chung_tu_chi_tiet,
  tenant_bvcahn.dm_so_thu_hoa_don,
  tenant_bvcahn.dmc_ma_nhom_chi_phi,
  tenant_bvcahn.csyt_xac_nhan_chi_phi,
  tenant_bvcahn.csyt_xac_nhan_chi_phi_vien_phi,
  tenant_bvcahn.dmc_icd10,
  tenant_bvcahn.dm_nhom_icd10,
  tenant_bvcahn.dm_chuong_icd10,
  tenant_bvcahn.dmc_doi_tuong_kcb
TO peerdb_hms_user;

SELECT NOT EXISTS (
  SELECT 1 FROM pg_publication WHERE pubname = 'peerdb_hms_publication'
) AS create_publication \gset

\if :create_publication
CREATE PUBLICATION peerdb_hms_publication FOR TABLE
  tenant_bvcahn.tiep_nhan,
  tenant_bvcahn.benh_nhan_tiep_nhan,
  tenant_bvcahn.benh_nhan_dot_dieu_tri,
  tenant_bvcahn.kb_kham_benh,
  tenant_bvcahn.kb_kham_benh_chuyen_vien,
  tenant_bvcahn.csyt_benh_an_dieu_tri,
  tenant_bvcahn.csyt_phieu_ra_vien,
  tenant_bvcahn.phieu_dich_vu_chi_tiet,
  tenant_bvcahn.csyt_yl_thuocvt,
  tenant_bvcahn.csyt_vien_phi_chung_tu,
  tenant_bvcahn.csyt_vien_phi_chung_tu_chi_tiet,
  tenant_bvcahn.dm_so_thu_hoa_don,
  tenant_bvcahn.dmc_ma_nhom_chi_phi,
  tenant_bvcahn.csyt_xac_nhan_chi_phi,
  tenant_bvcahn.csyt_xac_nhan_chi_phi_vien_phi,
  tenant_bvcahn.dmc_icd10,
  tenant_bvcahn.dm_nhom_icd10,
  tenant_bvcahn.dm_chuong_icd10,
  tenant_bvcahn.dmc_doi_tuong_kcb;
\endif
