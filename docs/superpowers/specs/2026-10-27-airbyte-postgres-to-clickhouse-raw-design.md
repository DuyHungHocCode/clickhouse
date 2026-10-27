# Airbyte PostgreSQL → ClickHouse RAW

## Intent

Nạp dữ liệu nghiệp vụ từ PostgreSQL `tenant_bvcahn` vào ClickHouse để dashboard có dữ liệu trước mắt, không phụ thuộc quyền quản trị PostgreSQL hay logical replication.

## Goals

- Chạy Airbyte self-managed tách khỏi Docker Compose của dashboard bằng `abctl`.
- Đọc 19 bảng đã có trong mirror PeerDB hiện tại và ghi vào ClickHouse database `hms_raw`.
- Dùng PostgreSQL `Standard (xmin)` để incremental inserts/updates mà không cần WAL, publication hay cursor thời gian; lịch chạy do Airbyte quản lý.
- Cung cấp hướng dẫn, biến môi trường mẫu và checklist kiểm tra để vận hành bằng một user PostgreSQL chỉ có `USAGE` schema + `SELECT` bảng.

## Non-goals

- Không thay đổi hay xoá `dashboard_v2/cdc` (PeerDB) và không chạy hai pipeline ghi vào cùng bảng `raw_*`.
- Không dùng PostgreSQL CDC, publication, replication slot, WAL hoặc quyền `REPLICATION`.
- Không sửa data mart/dashboard trong lần này.

## Constraints and data contract

- Source: `tenant_bvcahn`; destination: ClickHouse `hms_raw`.
- Chọn đúng 19 bảng hiện có trong `dashboard_v2/cdc/sql/04-peerdb-mirror.sql.template`: `tiep_nhan`, `benh_nhan_tiep_nhan`, `benh_nhan_dot_dieu_tri`, `kb_kham_benh`, `kb_kham_benh_chuyen_vien`, `csyt_benh_an_dieu_tri`, `csyt_phieu_ra_vien`, `phieu_dich_vu_chi_tiet`, `csyt_yl_thuocvt`, `csyt_vien_phi_chung_tu`, `csyt_vien_phi_chung_tu_chi_tiet`, `dm_so_thu_hoa_don`, `dmc_ma_nhom_chi_phi`, `csyt_xac_nhan_chi_phi`, `csyt_xac_nhan_chi_phi_vien_phi`, `dmc_icd10`, `dm_nhom_icd10`, `dm_chuong_icd10`, `dmc_doi_tuong_kcb`.
- Airbyte creates and owns its direct-load tables. Do not point it at PeerDB's `raw_*` tables, whose metadata and version semantics are PeerDB-specific.
- Each selected stream needs an operator-confirmed primary key for ClickHouse deduplication. A stream without one uses a scheduled full refresh overwrite only after the operator accepts its cost.
- Incremental polling does not observe hard deletes. Deletes are out of scope until CDC privileges are available.

## Approaches considered

1. **Incremental polling + Airbyte ClickHouse destination (selected):** needs only read access, delivers a current-state table with Airbyte's PK/cursor-based deduplication, and meets the initial-load goal. It cannot propagate deletes.
2. **Scheduled full refresh overwrite:** also needs only read access, but rescans every table and is unsuitable as the default for potentially large transactional tables.
3. **Airbyte PostgreSQL CDC:** captures deletes but still requires logical replication and `REPLICATION`, which is the constraint this change removes.

## Implementation outline

- Add `dashboard_v2/airbyte/` with a `.env.example`, stream inventory, and Vietnamese runbook.
- Document a one-command validation script that rejects missing connection variables and records the 19-stream inventory without storing secrets.
- The runbook installs/runs Airbyte via `abctl`, creates PostgreSQL `Standard (xmin)` and ClickHouse connections in the UI, selects the 19 streams, sets namespace `hms_raw`, and configures each stream's PK and schedule.
- The runbook explicitly stops/does not start the PeerDB mirror before an Airbyte connection targets data used by the dashboard.

## Acceptance checks

- Static validation confirms all 19 selected stream names and required settings exist in the repository's Airbyte inventory.
- Operator can follow the runbook with a read-only PostgreSQL user and a ClickHouse writer account to complete an initial sync.
- The runbook checks destination row counts, latest `_airbyte_extracted_at`, and duplicate PKs with ClickHouse queries.
