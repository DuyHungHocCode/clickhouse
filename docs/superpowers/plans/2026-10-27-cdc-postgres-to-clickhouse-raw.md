# PostgreSQL to ClickHouse RAW CDC Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Đồng bộ CDC 19 bảng PostgreSQL `tenant_bvcahn` vào `hms_raw.raw_*` trên ClickHouse qua PeerDB, có initial snapshot, soft-delete và kiểm chứng latest-state.

**Architecture:** PeerDB đọc PostgreSQL logical replication qua kết nối Tailscale, thực hiện snapshot nhất quán rồi tiếp tục đọc WAL. Target ClickHouse giữ mỗi bảng RAW với `ReplacingMergeTree` theo PostgreSQL primary key, `_peerdb_version`, `_peerdb_is_deleted` và `_peerdb_synced_at`; chưa tạo `ct_*`, `dm_*` hay dashboard trong task này.

**Tech Stack:** PostgreSQL logical replication, PeerDB OSS, ClickHouse 25.8, Docker Compose, Tailscale.

**Spec:** `docs/superpowers/specs/2026-10-27-clickhouse-data-mart-function-parity-design.md`

## Global Constraints

- Function PostgreSQL là chuẩn đối soát; không sửa logic nghiệp vụ trong phase RAW.
- Target PeerDB phải dùng database ClickHouse `hms_raw`; target table mapping không schema-qualified theo PeerDB.
- Raw table names dùng prefix `raw_`, ASCII không dấu, map một-một với bảng nguồn.
- Bật `soft_delete=true`; downstream chỉ đọc qua latest-state view ở phase sau.
- Raw `ORDER BY` giữ PostgreSQL primary key; không thêm cột mutable/date vào ordering key.
- Source schema là `tenant_bvcahn`; credentials/Tailscale IP chỉ nằm trong `.env` local, không commit.
- Không tạo `ct_*`, `dm_*`, Superset dataset, raw aggregate hay filter khoa/phòng trong task này.
- Không dùng Kafka, Spark, Flink hoặc orchestrator ngoài PeerDB.

## Review Focus

1. Missing/incorrect primary key or replica identity makes UPDATE/DELETE deduplication wrong.
2. PeerDB mapping to a schema-qualified ClickHouse target table creates tables outside `hms_raw` or fails.
3. A missing table from one function silently prevents a KPI from being reproduced.
4. CDC catch-up after PeerDB restart retains correctness and does not create duplicate latest rows.
5. WAL retention/replication slot growth can exhaust source PostgreSQL disk during a CDC outage.

---

## File Structure

| File | Responsibility |
|---|---|
| `dashboard_v2/cdc/.env.example` | PeerDB catalog, source PostgreSQL and ClickHouse connection variables; no real secrets |
| `dashboard_v2/cdc/compose.yaml` | Official PeerDB OSS runtime: catalog, Temporal, Flow API/workers, PeerDB UI/server and MinIO |
| `dashboard_v2/cdc/sql/01-clickhouse-raw.sql` | Create `hms_raw`, PeerDB CDC user and least-privilege grants |
| `dashboard_v2/cdc/sql/02-postgres-preflight.sql` | Read-only PK/replica identity/publication readiness audit for all source tables |
| `dashboard_v2/cdc/sql/03-postgres-publication.sql` | Dedicated publication and CDC reader grants, run only after preflight is clean |
| `dashboard_v2/cdc/sql/04-peerdb-mirror.sql.template` | `CREATE PEER` and 19-table `CREATE MIRROR` template with secrets substituted at execution time |
| `dashboard_v2/cdc/scripts/verify-raw-cdc.sh` | Checks mirror status, required raw tables, CDC metadata and latest-state row parity |
| `dashboard_v2/cdc/README.md` | Ordered operator runbook, source prerequisites, recovery and test commands |

## Raw Table Mapping

PeerDB target peer is configured with database `hms_raw`; mappings use only target table names.

| PostgreSQL source | ClickHouse RAW target | Function coverage |
|---|---|---|
| `tenant_bvcahn.tiep_nhan` | `raw_tiep_nhan` | tiếp nhận, cấp cứu, giới tính, đối tượng |
| `tenant_bvcahn.benh_nhan_tiep_nhan` | `raw_benh_nhan_tiep_nhan` | giới tính |
| `tenant_bvcahn.benh_nhan_dot_dieu_tri` | `raw_benh_nhan_dot_dieu_tri` | cấp cứu, đối tượng |
| `tenant_bvcahn.kb_kham_benh` | `raw_kb_kham_benh` | khám bệnh |
| `tenant_bvcahn.kb_kham_benh_chuyen_vien` | `raw_kb_kham_benh_chuyen_vien` | chuyển viện |
| `tenant_bvcahn.csyt_benh_an_dieu_tri` | `raw_csyt_benh_an_dieu_tri` | vào viện |
| `tenant_bvcahn.csyt_phieu_ra_vien` | `raw_csyt_phieu_ra_vien` | ra viện |
| `tenant_bvcahn.phieu_dich_vu_chi_tiet` | `raw_phieu_dich_vu_chi_tiet` | chỉ định dịch vụ |
| `tenant_bvcahn.csyt_yl_thuocvt` | `raw_csyt_yl_thuocvt` | đơn thuốc |
| `tenant_bvcahn.csyt_vien_phi_chung_tu` | `raw_csyt_vien_phi_chung_tu` | doanh thu |
| `tenant_bvcahn.csyt_vien_phi_chung_tu_chi_tiet` | `raw_csyt_vien_phi_chung_tu_chi_tiet` | doanh thu |
| `tenant_bvcahn.dm_so_thu_hoa_don` | `raw_dm_so_thu_hoa_don` | doanh thu |
| `tenant_bvcahn.dmc_ma_nhom_chi_phi` | `raw_dmc_ma_nhom_chi_phi` | doanh thu |
| `tenant_bvcahn.csyt_xac_nhan_chi_phi` | `raw_csyt_xac_nhan_chi_phi` | BHYT, XML, ICD-10 |
| `tenant_bvcahn.csyt_xac_nhan_chi_phi_vien_phi` | `raw_csyt_xac_nhan_chi_phi_vien_phi` | ICD-10 viện phí |
| `tenant_bvcahn.dmc_icd10` | `raw_dmc_icd10` | ICD-10 |
| `tenant_bvcahn.dm_nhom_icd10` | `raw_dm_nhom_icd10` | ICD-10 |
| `tenant_bvcahn.dm_chuong_icd10` | `raw_dm_chuong_icd10` | ICD-10 |
| `tenant_bvcahn.dmc_doi_tuong_kcb` | `raw_dmc_doi_tuong_kcb` | ICD-10 analytics |

### Task 1: Audit source PostgreSQL CDC readiness

**Files:**
- Create: `dashboard_v2/cdc/sql/02-postgres-preflight.sql`
- Create: `dashboard_v2/cdc/sql/03-postgres-publication.sql`
- Create: `dashboard_v2/cdc/README.md`

**Interfaces:**
- Consumes: PostgreSQL connection supplied by operator and the 19-table mapping above.
- Produces: a preflight result for every table; a dedicated `peerdb_hms_publication` and `peerdb_hms_user` only after all checks pass.

- [ ] **Step 1: Write the failing preflight assertion query**

The query must return `0` violations only if every mapped source table exists, has a primary key, and has a replica identity compatible with its primary key; it must also return `wal_level=logical`, at least one free replication slot and adequate WAL settings.

- [ ] **Step 2: Run preflight against the source PostgreSQL**

Run: `psql "$HMS_SOURCE_DSN" -f dashboard_v2/cdc/sql/02-postgres-preflight.sql`

Expected: Initial run may FAIL or report violations; do not create a publication or mirror until output is clean.

- [ ] **Step 3: Implement the source setup script**

Create `peerdb_hms_user` with `LOGIN REPLICATION BYPASSRLS`, source-schema `USAGE`, `SELECT` on exactly the 19 tables and `UPDATE` only on the heartbeat row/table if heartbeat is used. Create `peerdb_hms_publication` for exactly these tables. Do not use `FOR ALL TABLES`.

- [ ] **Step 4: Re-run preflight and inspect publication membership**

Run: `psql "$HMS_SOURCE_DSN" -f dashboard_v2/cdc/sql/02-postgres-preflight.sql && psql "$HMS_SOURCE_DSN" -c "SELECT * FROM pg_publication_tables WHERE pubname='peerdb_hms_publication' ORDER BY tablename"`

Expected: 19 eligible source tables and no out-of-scope table in the publication.

- [ ] **Step 5: Commit**

Commit source preflight and publication scripts with message `feat: add PostgreSQL CDC preflight`.

### Task 2: Prepare ClickHouse RAW target and CDC user

**Files:**
- Create: `dashboard_v2/cdc/sql/01-clickhouse-raw.sql`
- Modify: `dashboard_v2/compose.yaml`
- Modify: `dashboard_v2/.env.example`
- Modify: `dashboard_v2/README.md`

**Interfaces:**
- Consumes: `CLICKHOUSE_PASSWORD`, `PEERDB_CLICKHOUSE_USER`, `PEERDB_CLICKHOUSE_PASSWORD` from local environment.
- Produces: database `hms_raw`, CDC user `peerdb_hms`, native TCP reachability from the PeerDB Docker network, and no permission on future `hms_core`, `hms_mart` or `hms_semantic` databases.

- [ ] **Step 1: Write failing ClickHouse privilege assertions**

Create assertions proving `peerdb_hms` can create/insert/select/drop/alter-add-column in `hms_raw`, use temporary S3 staging as PeerDB requires, and cannot read/create tables in `hms_core`.

- [ ] **Step 2: Run the assertions before bootstrap SQL exists**

Run: `clickhouse-client --user peerdb_hms --password "$PEERDB_CLICKHOUSE_PASSWORD" --query "SHOW DATABASES"`

Expected: FAIL because user/database have not been created.

- [ ] **Step 3: Implement target bootstrap and network connection**

Add `hms_raw` and the `peerdb_hms` user/grants. Make ClickHouse available to the PeerDB Compose network by a named external Docker network; retain Tailscale-only host port binding for human access. Do not pre-create `raw_*` tables: PeerDB must create them with CDC metadata/version semantics.

- [ ] **Step 4: Run privilege and connectivity checks**

Run: `clickhouse-client --user peerdb_hms --password "$PEERDB_CLICKHOUSE_PASSWORD" --query "CREATE TABLE hms_raw.cdc_permission_probe (id UInt8) ENGINE=MergeTree ORDER BY id; DROP TABLE hms_raw.cdc_permission_probe"`

Expected: PASS; an analogous `CREATE TABLE hms_core.denied ...` must FAIL.

- [ ] **Step 5: Commit**

Commit ClickHouse RAW bootstrap with message `feat: add ClickHouse raw CDC target`.

### Task 3: Deploy PeerDB OSS CDC runtime

**Files:**
- Create: `dashboard_v2/cdc/.env.example`
- Create: `dashboard_v2/cdc/compose.yaml`
- Create: `dashboard_v2/cdc/scripts/verify-raw-cdc.sh`
- Modify: `dashboard_v2/cdc/README.md`

**Interfaces:**
- Consumes: external Docker network containing service `clickhouse`; source PostgreSQL DSN/Tailscale address; PeerDB catalog/MinIO secrets from `cdc/.env`.
- Produces: PeerDB UI/server, Flow API, snapshot worker and flow worker running on the same Docker network as ClickHouse.

- [ ] **Step 1: Write failing runtime health assertions**

`verify-raw-cdc.sh health` must require PeerDB UI/API, catalog PostgreSQL, Temporal, MinIO and both workers to be running; it must test `clickhouse:9000` from Flow API rather than `localhost`.

- [ ] **Step 2: Run health assertions before PeerDB Compose exists**

Run: `dashboard_v2/cdc/scripts/verify-raw-cdc.sh health`

Expected: FAIL because PeerDB runtime does not exist.

- [ ] **Step 3: Implement PeerDB from its official OSS dependency graph**

Use catalog PostgreSQL, Temporal, `flow-migrate`, `flow-api`, `flow-snapshot-worker`, `flow-worker`, `peerdb-server`, `peerdb-ui` and MinIO. Pin all image tags. Attach only the Flow services that need ClickHouse to the named ClickHouse network. Expose PeerDB UI/server on loopback or the Tailscale IP only; do not expose catalog/Temporal/MinIO to the LAN.

- [ ] **Step 4: Run PeerDB health assertions**

Run: `docker compose --env-file .env -f dashboard_v2/cdc/compose.yaml up -d && dashboard_v2/cdc/scripts/verify-raw-cdc.sh health`

Expected: PASS; Flow API resolves `clickhouse` by Docker DNS and no mirror has been created yet.

- [ ] **Step 5: Commit**

Commit PeerDB runtime with message `feat: add PeerDB CDC runtime`.

### Task 4: Create peers and the 19-table initial-snapshot CDC mirror

**Files:**
- Create: `dashboard_v2/cdc/sql/04-peerdb-mirror.sql.template`
- Modify: `dashboard_v2/cdc/scripts/verify-raw-cdc.sh`
- Modify: `dashboard_v2/cdc/README.md`

**Interfaces:**
- Consumes: `peerdb_hms_user`, `peerdb_hms_publication`, ClickHouse peer `hms_raw`, and raw table mapping.
- Produces: mirror `hms_pg_to_ch_raw`, all 19 `hms_raw.raw_*` tables with `_peerdb_version`, `_peerdb_is_deleted`, `_peerdb_synced_at`.

- [ ] **Step 1: Write failing mirror-completeness assertions**

`verify-raw-cdc.sh mirror` must assert the mirror is running, all 19 raw tables exist, each has CDC metadata columns, engine `ReplacingMergeTree`, and no target table exists outside `hms_raw`.

- [ ] **Step 2: Run mirror assertions before creating the mirror**

Run: `dashboard_v2/cdc/scripts/verify-raw-cdc.sh mirror`

Expected: FAIL because `hms_pg_to_ch_raw` and `raw_*` tables do not exist.

- [ ] **Step 3: Implement the PeerDB peer/mirror SQL template**

Create a PostgreSQL peer pointing at external `tenant_bvcahn` and a ClickHouse peer whose default database is `hms_raw`. Create one CDC mirror with the 19 exact table mappings, `do_initial_copy=true`, `soft_delete=true`, `sync_interval=2`, publication `peerdb_hms_publication`, one snapshot table worker and one snapshot worker per table. Use a separately configured batch size only after baseline measurement.

- [ ] **Step 4: Create mirror and verify initial snapshot**

Run the rendered mirror SQL through PeerDB, then: `dashboard_v2/cdc/scripts/verify-raw-cdc.sh mirror`

Expected: PASS; all 19 raw tables exist, are receiving CDC metadata, and PeerDB reports initial sync completed.

- [ ] **Step 5: Commit**

Commit mirror template and verification script with message `feat: add HMS raw CDC mirror`.

### Task 5: Prove CDC mutation correctness and recovery

**Files:**
- Modify: `dashboard_v2/cdc/scripts/verify-raw-cdc.sh`
- Modify: `dashboard_v2/cdc/README.md`

**Interfaces:**
- Consumes: live mirror from Task 4 and an approved disposable source row/table for mutation tests.
- Produces: repeatable evidence that INSERT, UPDATE, DELETE and PeerDB restart preserve latest-state parity.

- [ ] **Step 1: Write failing latest-state parity test**

Use one disposable source record in a selected mapped table. The test must insert it, update a non-key field, delete it, and assert latest state in ClickHouse via `FINAL WHERE _peerdb_is_deleted=0` equals PostgreSQL at each step.

- [ ] **Step 2: Run the parity test before mutation support is implemented**

Run: `dashboard_v2/cdc/scripts/verify-raw-cdc.sh mutation`

Expected: FAIL until a safe test-table/record strategy is supplied and CDC catches up.

- [ ] **Step 3: Implement a non-destructive mutation test procedure**

Do not mutate real clinical/financial rows. Use a dedicated source heartbeat/test table added to the publication, or an explicitly approved disposable fixture. Record source commit timestamp, PeerDB arrival timestamp and max observed lag.

- [ ] **Step 4: Verify recovery**

Run: stop Flow worker, make an approved fixture update, restart worker, then execute `dashboard_v2/cdc/scripts/verify-raw-cdc.sh mutation`.

Expected: Latest-state parity passes with no duplicate active row and the replication slot remains valid.

- [ ] **Step 5: Commit**

Commit mutation/recovery verification with message `test: verify raw CDC mutation recovery`.

## Self-Review

### Spec coverage

- All 19 source tables from the function-parity design are mapped in this plan.
- The source uses logical replication, initial snapshot, CDC soft deletes and a single pipeline.
- Raw tables are isolated in `hms_raw`; canonical facts/marts are explicitly deferred.
- UPDATE/DELETE correctness, PeerDB recovery, WAL risk and reconciliation preconditions are included.
- ClickHouse uses raw ordering by source PK and no business-query optimization in RAW.

### Interface consistency

- Task 1 produces source role/publication used by Task 4.
- Task 2 produces `hms_raw`, `peerdb_hms` and Docker network used by Tasks 3–4.
- Task 3 produces a PeerDB runtime used by Task 4.
- Task 4 produces mirror/raw tables tested by Task 5.

### Review focus coverage

1. PK/replica identity: Task 1 preflight.
2. ClickHouse target naming: Task 4 mirror completeness assertion.
3. Function source-table completeness: mapping table plus Task 4 assertion.
4. Restart/duplicate behavior: Task 5.
5. WAL growth: Task 1 preflight and Task 5 slot validity check.

### Deliberate deferrals

- DDL for `ct_*`, `dm_*`, semantic views and dashboard datasets.
- Attribution policy for khoa/phòng.
- Metric extensions without an authoritative PostgreSQL function.
- Production HA, ClickHouse cluster and backup/restore drills.
