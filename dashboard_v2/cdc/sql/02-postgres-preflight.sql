\set ON_ERROR_STOP on

CREATE TEMP TABLE peerdb_expected_tables (table_name text PRIMARY KEY) ON COMMIT DROP;
INSERT INTO peerdb_expected_tables VALUES
('tiep_nhan'), ('benh_nhan_tiep_nhan'), ('benh_nhan_dot_dieu_tri'),
('kb_kham_benh'), ('kb_kham_benh_chuyen_vien'), ('csyt_benh_an_dieu_tri'),
('csyt_phieu_ra_vien'), ('phieu_dich_vu_chi_tiet'), ('csyt_yl_thuocvt'),
('csyt_vien_phi_chung_tu'), ('csyt_vien_phi_chung_tu_chi_tiet'),
('dm_so_thu_hoa_don'), ('dmc_ma_nhom_chi_phi'), ('csyt_xac_nhan_chi_phi'),
('csyt_xac_nhan_chi_phi_vien_phi'), ('dmc_icd10'), ('dm_nhom_icd10'),
('dm_chuong_icd10'), ('dmc_doi_tuong_kcb');

DO $$
DECLARE problem_tables text;
BEGIN
  IF current_setting('wal_level') <> 'logical' THEN
    RAISE EXCEPTION 'wal_level must be logical, got %', current_setting('wal_level');
  END IF;
  IF current_setting('max_replication_slots')::int < 2 THEN
    RAISE EXCEPTION 'max_replication_slots must be >= 2';
  END IF;
  IF current_setting('max_wal_senders')::int < 2 THEN
    RAISE EXCEPTION 'max_wal_senders must be >= 2';
  END IF;
  SELECT string_agg(e.table_name, ', ' ORDER BY e.table_name) INTO problem_tables
  FROM peerdb_expected_tables e
  LEFT JOIN pg_namespace n ON n.nspname = 'tenant_bvcahn'
  LEFT JOIN pg_class c ON c.relnamespace = n.oid AND c.relname = e.table_name AND c.relkind IN ('r','p')
  WHERE c.oid IS NULL
     OR NOT EXISTS (SELECT 1 FROM pg_index i WHERE i.indrelid = c.oid AND i.indisprimary)
     OR c.relreplident = 'n';
  IF problem_tables IS NOT NULL THEN
    RAISE EXCEPTION 'missing table, primary key, or replica identity: %', problem_tables;
  END IF;
END $$;

SELECT current_setting('wal_level') AS wal_level,
       current_setting('max_replication_slots') AS max_replication_slots,
       current_setting('max_wal_senders') AS max_wal_senders,
       current_setting('max_slot_wal_keep_size', true) AS max_slot_wal_keep_size;

SELECT e.table_name, c.relreplident
FROM peerdb_expected_tables e
JOIN pg_namespace n ON n.nspname = 'tenant_bvcahn'
JOIN pg_class c ON c.relnamespace = n.oid AND c.relname = e.table_name
ORDER BY e.table_name;
