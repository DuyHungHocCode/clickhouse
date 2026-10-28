# Direct ClickHouse Analytics API Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Expose three existing Gold marts as authenticated, read-only ClickHouse HTTP endpoints for the lab dashboard.

**Architecture:** Upgrade the single ClickHouse container to a pinned 26.8+ release and define named endpoints with `CREATE HANDLER` in SQL. A dedicated API user receives only the selected Gold-view grants, read-only resource limits, and a quota. Static repository checks validate the migration text; a separate smoke script validates a deployed server.

**Tech Stack:** Docker Compose, ClickHouse 26.8+, ClickHouse SQL DDL, Bash, curl.

**Spec:** `docs/superpowers/specs/2026-10-28-clickhouse-direct-api-design.md`

## Global Constraints

- Do not add a frontend, backend, dependency, raw/silver permission, write endpoint, or arbitrary-SQL API.
- Keep the date contract inclusive at the public boundary and half-open internally.
- Do not store `dashboard_api` credentials in tracked files.
- Do not execute destination-server tests until its data volume is backed up and its Gold marts exist.
- Pin a concrete ClickHouse version at or above 26.8; do not use `latest`.

## Review Focus

- A caller must not access `hms_raw` or `hms_silver`; Task 2 verifies grants are Gold-view-only.
- An API date window includes `to_date` but not the following day; Task 2 asserts the exact predicate.
- A client must not alter SQL through query parameters; Task 2 asserts every input is a typed handler parameter.
- Dashboard responses must not expose patient identifiers; Task 2 checks only the existing Gold views are sources.
- Upgrade rollback must not reuse a 26.x-initialized volume on 25.8; Task 1 documents backup and rollback boundaries.

### Task 1: Make the ClickHouse runtime handler-capable

**Files:**
- Modify: `compose.yaml:3`
- Modify: `README.md`
- Modify: `.env.example`

**Consumes:** Current ClickHouse 25.8 Compose service and its persistent `clickhouse_data` volume.

**Produces:** A pinned ClickHouse 26.8+ lab image plus documented pre-upgrade backup, API-origin configuration, and no tracked API secret.

- [ ] **Step 1: Select the exact supported 26.x image tag for the destination server**

Choose a non-floating official `clickhouse/clickhouse-server:<version>` tag at or above `26.8` that has been approved for the destination's CPU architecture. Record that exact value in the PR/operations handoff.

- [ ] **Step 2: Update `compose.yaml` to use the selected image tag**

Keep all existing ports, healthcheck, network, and `clickhouse_data` volume unchanged. Do not add `latest`, init SQL mounts, or an API service.

- [ ] **Step 3: Document the destination upgrade and rollback boundary in `README.md`**

Add commands/instructions to stop the stack, take a host-level backup/snapshot of `clickhouse_data`, upgrade, verify `SELECT version()`, and restore the backup rather than downgrading the same volume.

- [ ] **Step 4: Add non-secret API environment documentation to `.env.example`**

Add `DASHBOARD_CORS_ORIGIN` as an example lab URL only. Do not add an API password; it is generated and retained on the destination server.

- [ ] **Step 5: Validate Compose syntax without starting containers**

Run: `docker compose -f compose.yaml config --no-interpolate`

Expected: exit code `0`; one ClickHouse service retains the HTTP and native port mappings.

- [ ] **Step 6: Commit**

```bash
git add compose.yaml README.md .env.example
git commit -m "chore: upgrade ClickHouse for HTTP handlers"
```

### Task 2: Define the constrained ClickHouse API schema

**Files:**
- Create: `api/01-dashboard-api.sql`
- Create: `api/02-verify-dashboard-api.sql`
- Create: `api/tests/test_dashboard_api_sql.sh`

**Consumes:** `hms_gold.dm_dashboard_ngay`, `hms_gold.dm_doanh_thu_ngay`, and `hms_gold.dm_icd10` created by `mart/03-gold-daily-marts.sql`.

**Produces:** `dashboard_api` identity, least-privilege role/limits/quota, and three named read-only handlers.

- [ ] **Step 1: Add static expectations to `api/tests/test_dashboard_api_sql.sh`**

Create a Bash test following the repository's `set -euo pipefail`/`expect_text` pattern. Assert the two new SQL files exist. Assert `01-dashboard-api.sql` contains all three handler URLs, `JSONEachRow`, typed `from_date:Date` and `to_date:Date`, the half-open `addDays(..., 1)` pattern, `readonly`, and grants for only the three named Gold views. Assert it has no `hms_raw`, `hms_silver`, `INSERT`, `ALTER TABLE`, or literal API password.

- [ ] **Step 2: Run the static test to verify it fails**

Run: `bash api/tests/test_dashboard_api_sql.sh`

Expected: FAIL because `api/01-dashboard-api.sql` and `api/02-verify-dashboard-api.sql` do not yet exist.

- [ ] **Step 3: Implement `api/01-dashboard-api.sql`**

Create a role/user sequence that creates `dashboard_api` with `IDENTIFIED WITH sha256_password BY {dashboard_api_password:String}`; the deployment invokes the file with a ClickHouse query parameter, so the secret never appears in the file. Grant only `SELECT` on the three named views. Apply a read-only settings profile or per-user settings that bounds execution time, memory, result rows/bytes, and read rows; define a quota appropriate to one lab dashboard.

Define these handlers with `METHODS (GET)` and `FORMAT JSONEachRow`:

```sql
CREATE HANDLER dashboard_summary
URL '/api/v1/dashboard-summary'
METHODS (GET)
AS SELECT * FROM hms_gold.dm_dashboard_ngay
WHERE ngay >= {from_date:Date}
  AND ngay < addDays({to_date:Date}, 1)
ORDER BY ngay
FORMAT JSONEachRow;
```

Use the same typed-date predicate for `revenue_daily` over `dm_doanh_thu_ngay` and `icd10` over `dm_icd10`; give ICD-10 a fixed safe `LIMIT` and deterministic `ORDER BY ngay, loai_thanh_toan, ma_icd10`.

- [ ] **Step 4: Implement `api/02-verify-dashboard-api.sql`**

Add read-only inspection queries for `SHOW GRANTS FOR dashboard_api`, settings/quota visibility, `system.handlers`, and a handler result check. Use ClickHouse parameters for dates, never a hard-coded production date.

- [ ] **Step 5: Run the static test to verify it passes**

Run: `bash api/tests/test_dashboard_api_sql.sh`

Expected: PASS.

- [ ] **Step 6: Commit**

```bash
git add api/01-dashboard-api.sql api/02-verify-dashboard-api.sql api/tests/test_dashboard_api_sql.sh
git commit -m "feat: add read-only ClickHouse dashboard handlers"
```

### Task 3: Add destination-server deployment and smoke verification

**Files:**
- Create: `api/tests/smoke-dashboard-api.sh`
- Modify: `README.md`

**Consumes:** A running upgraded ClickHouse instance, applied marts, and API DDL from Task 2.

**Produces:** An operator-run deployment sequence and smoke test that proves endpoint behavior and least privilege on the destination server.

- [ ] **Step 1: Write the failing smoke-test preflight**

Create `api/tests/smoke-dashboard-api.sh` with `set -euo pipefail`. Require `CLICKHOUSE_URL`, `DASHBOARD_API_USER`, `DASHBOARD_API_PASSWORD`, `FROM_DATE`, and `TO_DATE`; exit with a clear error when any is absent. Use `curl --fail-with-body --silent --show-error` and a temporary credentials file or environment variable so credentials never enter a command URL or shell history.

- [ ] **Step 2: Define smoke assertions**

The script must require `jq`, call each endpoint with valid dates, and validate each `JSONEachRow` line through `jq -e .`. It must also assert `401`/`403` for missing credentials and assert the API identity cannot issue `SELECT * FROM hms_raw.<known_table>`.

- [ ] **Step 3: Implement the smallest smoke script that passes those assertions**

Keep the script target-agnostic: it connects only through `CLICKHOUSE_URL`, does not start Docker, and never prints the password. Make it executable.

- [ ] **Step 4: Document the deployment order in `README.md`**

Document: backup → Compose upgrade → run existing mart SQL in existing order → apply `api/01-dashboard-api.sql` as admin with `--param_dashboard_api_password` sourced from the server secret store → run `api/02-verify-dashboard-api.sql` → export smoke-test variables and run the script. Include one browser CORS caveat: restrict the origin or put the lab dashboard behind a same-origin reverse proxy; list `jq` as a smoke-test prerequisite.

- [ ] **Step 5: Run only local static checks**

Run: `bash -n api/tests/smoke-dashboard-api.sh && bash api/tests/test_dashboard_api_sql.sh && bash mart/tests/test_mart_sql.sh`

Expected: all three static checks exit `0`. Do not run the smoke script from this workstation.

- [ ] **Step 6: Commit**

```bash
git add api/tests/smoke-dashboard-api.sh README.md
git commit -m "docs: add ClickHouse dashboard API deployment checks"
```

### Task 4: Run destination acceptance after server access exists

**Files:**
- Verify: `compose.yaml`
- Verify: `mart/*.sql`
- Verify: `api/01-dashboard-api.sql`
- Verify: `api/02-verify-dashboard-api.sql`
- Verify: `api/tests/smoke-dashboard-api.sh`

**Consumes:** Backed-up ClickHouse data volume and destination-server access.

**Produces:** Evidence that the lab API runs on the intended server.

- [ ] **Step 1: Verify version and loaded marts**

Run `SELECT version()` and execute `api/02-verify-dashboard-api.sql` as the admin user after marts have loaded.

Expected: ClickHouse is 26.8+; all three handlers appear in `system.handlers`; the source Gold views exist.

- [ ] **Step 2: Run endpoint smoke tests with a generated API password**

Run: `CLICKHOUSE_URL=... DASHBOARD_API_USER=dashboard_api DASHBOARD_API_PASSWORD=... FROM_DATE=... TO_DATE=... api/tests/smoke-dashboard-api.sh`

Expected: all endpoint and privilege assertions pass.

- [ ] **Step 3: Verify resource limits and observe queries**

Issue an intentionally oversized date range within a controlled lab session; confirm the configured result/resource limit stops it. Inspect the corresponding `system.query_log` rows.

- [ ] **Step 4: Record outcome, not secrets**

Record target version, handler names, test date range, and pass/fail results in the deployment ticket/runbook. Never record endpoint credentials.

## Self-review

- **Spec coverage:** Tasks 1–4 respectively cover upgrade/rollback, endpoint and access SQL, repeatable deployment verification, and target-server acceptance.
- **No unnecessary software:** The plan adds SQL, shell checks, and documentation only; it deliberately omits a backend, a frontend, a proxy container, and mart materialization.
- **Boundary checks:** Static tests own source/typed-date/no-secret checks; live acceptance owns authentication, privileges, CORS/network, and resource behavior.
