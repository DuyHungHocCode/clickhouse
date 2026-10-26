# Hospital Analytics Lab Infrastructure Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Dựng hạ tầng Docker Compose có thể kiểm chứng cho lab HMS: PostgreSQL logical replication source, PeerDB CDC runtime, ClickHouse single-node production-shaped và Superset, chạy full stack trên máy tối đa 16 GB RAM.

**Architecture:** Một file Compose định nghĩa các profile `source`, `cdc-core`, `bi` và `full`, cùng network/volume nội bộ. PostgreSQL mock được cấu hình logical replication để kiểm thử trước khi PeerDB chuyển sang PostgreSQL ngoài; ClickHouse bootstrap database/roles cho PeerDB và BI. PeerDB giữ nguyên các dependency cần thiết (catalog PostgreSQL, Temporal, Flow workers và MinIO) để đánh giá CDC thật; full profile chạy đồng thời trên máy tối đa 16 GB.

**Tech Stack:** Docker Compose v2, PostgreSQL, PeerDB OSS, Temporal, MinIO/S3-compatible stage, ClickHouse, Apache Superset, POSIX shell, SQL bootstrap scripts.

**Spec:** `docs/superpowers/specs/2026-10-26-hospital-analytics-lab-architecture-design.md`

## Global Constraints

- Chỉ dùng Docker Compose; không thêm Kafka, Spark, Flink, Airflow, dbt, Kubernetes hoặc Grafana.
- Giữ single-node ClickHouse và synthetic data only; không thêm PHI/PII thật.
- PeerDB phải sử dụng PostgreSQL Logical Replication, publication riêng và soft-delete CDC khi tạo mirror ở phase sau.
- Dùng Docker profiles `source`, `cdc-core`, `bi`, `full`; `full` là mode phát triển end-to-end trên máy có Docker memory 16 GiB.
- Persistent volumes bắt buộc cho source PostgreSQL, PeerDB catalog PostgreSQL, ClickHouse và Superset home.
- Chỉ bind các cổng web/SQL cần thiết vào `127.0.0.1`; passwords là local-lab secret trong `.env`, không commit.
- Không tạo data mart, mirror PeerDB, dữ liệu HMS, dashboard Superset hoặc migration business schema trong plan này.
- Không thêm dependency kiểm thử: verification là shell script dùng Docker CLI, `psql`, `clickhouse-client` và HTTP health endpoint trong container.
- Trong workspace này chỉ chạy static verification (`docker compose config`, shell syntax và policy assertions); runtime verification được chuyển sang máy đích.
- Workspace hiện không là Git repository; không commit cho đến khi người dùng khởi tạo Git.

## Review Focus

1. Docker profile dependency — chạy `source`, `cdc-core`, `bi`, hoặc `full` phải kéo đúng service cần thiết mà không vô tình khởi động Superset/PeerDB ở profile nhỏ.
2. PostgreSQL logical replication — `wal_level`, replication slots và senders phải có hiệu lực sau restart, không chỉ nằm trong file config.
3. Container network addressing — PeerDB phải kết nối `hms-postgres` và `clickhouse` bằng DNS nội bộ, không dùng `localhost`/host port.
4. Persistence — restart/recreate container không được mất catalog, database ClickHouse hay user/role bootstrap.
5. Resource failure — `full` yêu cầu Docker memory tối thiểu 12 GiB và khuyến nghị 16 GiB; `make doctor` phải báo rõ khi thấp hơn thay vì treo im lặng.

---

## File Structure

| File | Trách nhiệm |
|---|---|
| `.env.example` | Tất cả biến local secret, port bind, image tag và giới hạn cấu hình lab |
| `.gitignore` | Loại `.env`, local volumes/logs và Superset state khỏi version control tương lai |
| `compose.yaml` | Services, profiles, health checks, volumes, network và local-only port bindings |
| `Makefile` | Entry point ngắn cho profile lifecycle và verification |
| `config/postgres/postgresql.conf` | Logical replication và giới hạn nhẹ cho source HMS |
| `docker/postgres/init/00-databases-and-roles.sql` | Tạo `hms`, role owner/PeerDB và quyền database cơ sở |
| `docker/postgres/init/10-hms-schema.sql` | Tạo schema trống `hms` và bảng `hms.cdc_heartbeat`; không tạo nghiệp vụ HMS ở phase này |
| `docker/clickhouse/init/00-databases-and-roles.sql` | Tạo `peerdb`, `hms_raw`, `hms_core`, `hms_mart`, `hms_semantic`, `hms_ops`; role PeerDB/Superset tối thiểu |
| `docker/clickhouse/config/01-lab-settings.xml` | Giới hạn query/concurrency an toàn cho lab ClickHouse |
| `docker/peerdb/temporal-dynamicconfig/development-sql.yaml` | Cấu hình Temporal tối thiểu PeerDB upstream yêu cầu |
| `docker/peerdb/scripts/mirror-name-search.sh` | Entrypoint health-compatible của Temporal admin tools, lấy từ upstream PeerDB và giữ executable |
| `scripts/verify-infra.sh` | Assertions profile/service/health/SQL runtime, trả non-zero khi có lỗi |
| `scripts/doctor.sh` | Kiểm tra Docker Compose, RAM Docker và `.env` trước khi khởi động profile |
| `README.md` | Quick start, profile matrix, cổng local, recovery volume và giới hạn tài nguyên 16 GB |

### Task 1: Compose skeleton, local configuration, and preflight checks

**Files:**
- Create: `.env.example`
- Create: `.gitignore`
- Create: `compose.yaml`
- Create: `Makefile`
- Create: `scripts/doctor.sh`
- Create: `scripts/verify-infra.sh`
- Create: `README.md`

**Interfaces:**
- Consumes: Docker Compose v2 and a user-copied `.env`.
- Produces: `make doctor`, `make config PROFILE=<source|cdc-core|bi|full>`, `make up PROFILE=…`, `make down PROFILE=…`, and `make verify PROFILE=…`.

- [ ] **Step 1: Write failing profile-config assertions in `scripts/verify-infra.sh`**

Assert `docker compose --profile "$PROFILE" config --format json` contains only the expected profile services, has no published host address other than `127.0.0.1`, and defines named volumes `hms_pg_data`, `peerdb_catalog_data`, `clickhouse_data`, `superset_home`.

- [ ] **Step 2: Run the profile-config assertion before Compose exists**

Run: `PROFILE=source ./scripts/verify-infra.sh config`

Expected: FAIL because `compose.yaml` and profile definitions do not exist.

- [ ] **Step 3: Implement the minimal Compose skeleton and commands**

Create four profile names with no default profile. Define the common network `hms_lab` and the four named volumes. Implement the Make targets exactly as produced above. `doctor.sh` must require Docker daemon access, Compose v2, a readable `.env`, and report Docker memory below 12 GiB as a blocking error for `full` and below 16 GiB as a warning. Document `cp .env.example .env` as the only setup command before `make doctor`.

- [ ] **Step 4: Run config and preflight verification**

Run: `cp -n .env.example .env && make doctor && make config PROFILE=source && make config PROFILE=cdc-core && make config PROFILE=bi && make config PROFILE=full`

Expected: Each command exits 0; no service starts; `full` requires 12 GiB and warns below 16 GiB.

- [ ] **Step 5: Commit**

Do not commit: the workspace has no Git repository. Record changed files in the implementation report.

### Task 2: PostgreSQL HMS source with logical replication readiness

**Files:**
- Modify: `compose.yaml`
- Create: `config/postgres/postgresql.conf`
- Create: `docker/postgres/init/00-databases-and-roles.sql`
- Create: `docker/postgres/init/10-hms-schema.sql`
- Modify: `scripts/verify-infra.sh`
- Modify: `README.md`

**Interfaces:**
- Consumes: `POSTGRES_*` and `PEERDB_SOURCE_*` variables from `.env`; `make up PROFILE=source` from Task 1.
- Produces: internal DNS endpoint `hms-postgres:5432`, database `hms`, role `peerdb_user`, schema `hms`, and table `hms.cdc_heartbeat` available to later CDC setup.

- [ ] **Step 1: Add failing PostgreSQL runtime assertions**

Add `verify_source()` that waits for service health then asserts: `SHOW wal_level` equals `logical`; `max_replication_slots >= 4`; `max_wal_senders > 1`; database `hms` exists; `peerdb_user` has `REPLICATION` and `BYPASSRLS`; schema/table `hms.cdc_heartbeat` exist; and source data volume survives `docker compose restart hms-postgres`.

- [ ] **Step 2: Run source verification before implementation**

Run: `make up PROFILE=source && make verify PROFILE=source`

Expected: FAIL because `hms-postgres` and its bootstrap SQL do not exist.

- [ ] **Step 3: Implement `hms-postgres`**

Add a `postgres` image service named `hms-postgres`, profiles `[source, cdc-core, full]`, a health check using `pg_isready`, persistent `hms_pg_data`, config mount, and an init directory mount. Bind the host SQL port only to `127.0.0.1:${HMS_POSTGRES_PORT}`. Configure `wal_level=logical`, `max_replication_slots=4`, `max_wal_senders=4`, `max_slot_wal_keep_size=1024MB`, and SCRAM authentication. Bootstrap only users, empty `hms` schema, and heartbeat table; do not create business tables yet.

- [ ] **Step 4: Run source verification and persistence check**

Run: `make up PROFILE=source && make verify PROFILE=source && docker compose --profile source restart hms-postgres && make verify PROFILE=source`

Expected: PASS; all logical replication checks and post-restart checks pass.

- [ ] **Step 5: Commit**

Do not commit: the workspace has no Git repository. Record changed files in the implementation report.

### Task 3: ClickHouse analytics node and least-privilege bootstrap

**Files:**
- Modify: `compose.yaml`
- Create: `docker/clickhouse/init/00-databases-and-roles.sql`
- Create: `docker/clickhouse/config/01-lab-settings.xml`
- Modify: `scripts/verify-infra.sh`
- Modify: `README.md`

**Interfaces:**
- Consumes: `CLICKHOUSE_*`, `PEERDB_CLICKHOUSE_*`, and `SUPERSET_CLICKHOUSE_*` variables from `.env`; `make up PROFILE=bi`.
- Produces: internal DNS endpoint `clickhouse:9000`, persistent `clickhouse_data`, named databases and two restricted principals usable by later CDC and BI tasks.

- [ ] **Step 1: Add failing ClickHouse assertions**

Add `verify_clickhouse()` which waits for ClickHouse health, asserts all five `hms_*` databases plus `peerdb` exist, checks `peerdb_user` can create/insert/select/drop only in `peerdb`, confirms `superset_user` has `SELECT` only on `hms_semantic`, and verifies data in `hms_ops` remains after container restart.

- [ ] **Step 2: Run ClickHouse verification before implementation**

Run: `make up PROFILE=bi && make verify PROFILE=bi`

Expected: FAIL because ClickHouse and bootstrap objects do not exist.

- [ ] **Step 3: Implement `clickhouse`**

Add a single-node ClickHouse service, profiles `[cdc-core, bi, full]`, HTTP/native ports bound only to loopback, persistent data volume, health check using `clickhouse-client`, bootstrap SQL mount and settings mount. Allocate a 6 GiB ClickHouse memory limit in `full` mode through environment/settings, but preserve Docker Compose portability by not hard-coding host-specific disk paths. Do not create marts or raw CDC tables. Give `peerdb_user` the PeerDB-required `peerdb.*` grants and `superset_user` only `SELECT` on `hms_semantic.*`.

- [ ] **Step 4: Run ClickHouse verification and persistence check**

Run: `make up PROFILE=bi && make verify PROFILE=bi && docker compose --profile bi restart clickhouse && make verify PROFILE=bi`

Expected: PASS; role grants and database persistence checks pass.

- [ ] **Step 5: Commit**

Do not commit: the workspace has no Git repository. Record changed files in the implementation report.

### Task 4: PeerDB CDC runtime profile

**Files:**
- Modify: `compose.yaml`
- Create: `docker/peerdb/temporal-dynamicconfig/development-sql.yaml`
- Create: `docker/peerdb/scripts/mirror-name-search.sh`
- Modify: `scripts/verify-infra.sh`
- Modify: `README.md`

**Interfaces:**
- Consumes: `hms-postgres:5432` from Task 2, `clickhouse:9000` from Task 3, PeerDB image tags and catalog/minio variables from `.env`.
- Produces: `make up PROFILE=cdc-core` starts PeerDB catalog, Temporal, Flow API, snapshot worker, flow worker, PeerDB server/UI and MinIO; UI is reachable only at `${PEERDB_UI_PORT}` on loopback.

- [ ] **Step 1: Add failing CDC-runtime assertions**

Add `verify_cdc_core()` that asserts the `cdc-core` profile starts exactly the source, ClickHouse and PeerDB dependency services, all required containers are healthy/running, PeerDB UI returns HTTP success, Flow API is reachable internally, and DNS resolution of `hms-postgres` and `clickhouse` works from `flow-api`.

- [ ] **Step 2: Run CDC runtime verification before implementation**

Run: `make up PROFILE=cdc-core && make verify PROFILE=cdc-core`

Expected: FAIL because PeerDB services are absent.

- [ ] **Step 3: Implement upstream-compatible PeerDB dependency graph**

Add dedicated persistent `peerdb-catalog` PostgreSQL, Temporal, `temporal-admin-tools`, `flow-migrate`, `flow-api`, `flow-snapshot-worker`, `flow-worker`, `peerdb-server`, `peerdb-ui` and MinIO. Use compatible image versions captured in `.env.example`, upstream environment names, health/dependency conditions, and the exact upstream Temporal admin entrypoint support script. Give these services profiles `[cdc-core, full]`; set worker parallelism to one. Do not create a PeerDB mirror in this task.

- [ ] **Step 4: Run CDC runtime verification**

Run: `make up PROFILE=cdc-core && make verify PROFILE=cdc-core`

Expected: PASS; PeerDB UI and internal dependencies are available, while no mirror has been created.

- [ ] **Step 5: Commit**

Do not commit: the workspace has no Git repository. Record changed files in the implementation report.

### Task 5: Superset BI profile, profile isolation, and operator documentation

**Files:**
- Modify: `compose.yaml`
- Modify: `.env.example`
- Modify: `scripts/verify-infra.sh`
- Modify: `README.md`

**Interfaces:**
- Consumes: `clickhouse:8123` and `superset_user` from Task 3; Compose targets from Task 1.
- Produces: Superset at loopback `${SUPERSET_PORT}`, persistent `superset_home`, and documented operator commands for each profile.

- [ ] **Step 1: Add failing BI and isolation assertions**

Add `verify_bi()` that asserts `bi` starts ClickHouse and Superset but not PostgreSQL/PeerDB/Temporal/MinIO, Superset returns HTTP success after bootstrap, and `full` Compose config includes all expected services. Add a profile matrix assertion that documents resource expectations and rejects unknown `PROFILE` values.

- [ ] **Step 2: Run BI verification before implementation**

Run: `make up PROFILE=bi && make verify PROFILE=bi`

Expected: FAIL because Superset is absent and isolation assertion cannot pass.

- [ ] **Step 3: Implement minimal Superset service and documentation**

Add Superset with profiles `[bi, full]`, one web process, SQLite metadata in persistent `superset_home`, loopback-only host binding, an explicit bootstrap command, health check and a conservative memory limit. Do not add Redis, Celery, dashboard import, database connection registration or a custom Superset image. Document every profile, local endpoints, first-run bootstrap, stop/reset commands, volume preservation warning, and that `full` needs Docker memory of at least 12 GiB.

- [ ] **Step 4: Run full infrastructure verification**

Run: `make config PROFILE=source && make config PROFILE=cdc-core && make config PROFILE=bi && make config PROFILE=full && make up PROFILE=bi && make verify PROFILE=bi && make up PROFILE=cdc-core && make verify PROFILE=cdc-core`

Expected: All profile configurations pass. `bi` and `cdc-core` runtime verification pass independently; run `full` runtime verification when Docker memory is at least 12 GiB.

- [ ] **Step 5: Commit**

Do not commit: the workspace has no Git repository. Record changed files in the implementation report.

## Self-Review

### Spec coverage

- Docker profiles and 16 GB full-stack operation: Tasks 1, 4, 5.
- PostgreSQL logical replication and dedicated source role: Task 2.
- ClickHouse single node, logical databases and least privilege: Task 3.
- PeerDB CDC runtime dependencies and recovery-ready persistence: Task 4.
- Superset as sole BI layer: Task 5.
- No marts, synthetic business schema, mirror, dashboard or external processing stack before their phase: Global Constraints and each task scope.
- Health, persistence, local network exposure and resource caveat: Tasks 1–5.

No infrastructure requirement in the approved design is unassigned. The source business schema, CDC mirror, marts and dashboard are intentionally deferred to later implementation plans.

### Step scan and interface consistency

Every task writes its verification assertion before the corresponding service/configuration and exposes only named Compose/Make interfaces consumed by later tasks. `hms-postgres`, `clickhouse`, `peerdb_user`, `superset_user`, `PROFILE`, and named volumes are defined once and reused consistently.

### Review Focus coverage

1. Profile dependency/isolation: Tasks 1 and 5 assertions.
2. Effective logical replication values: Task 2 assertions after service start/restart.
3. Internal DNS addressing: Task 4 assertion from Flow API.
4. Persistence: Tasks 2 and 3 restart assertions; named volumes in Task 1.
5. Low memory: Task 1 doctor check and Task 5 conditional full-profile verification.

### Proportion

The plan specifies only infrastructure boundaries, exact files, commands and observable behavior. It deliberately avoids reproducing Compose YAML, SQL bodies or later data-model implementation.
