# HMS ClickHouse Data Mart Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task.

**Goal:** Build the first runnable Bronze/Silver/Gold ClickHouse data-mart layer for the existing HMS raw tables, preserving the business rules in `dashboard_v2/docs/function.md`.

**Architecture:** Treat `hms_raw.<postgres_table>` as Bronze. Create Silver views/facts with explicit business grain and Gold daily marts plus a summary view. Use ClickHouse views first so the logic is inspectable and can be converted to materialized tables after reconciliation.

**Tech Stack:** ClickHouse SQL, POSIX shell, Markdown; no new dependencies.

**Spec:** `docs/superpowers/specs/2026-10-27-hms-lakehouse-data-mart-design.md`

## Global Constraints

- Do not change the existing raw ingestion tables.
- Use the PostgreSQL function behavior as the KPI oracle.
- Keep patient identifiers out of Gold.
- Use half-open date ranges: `>= from_date` and `< to_date + 1 day`.
- Do not claim runtime validation until ClickHouse executes the SQL.

## Review Focus

- Raw tables may contain Airbyte metadata columns: Silver must not depend on those columns.
- `FINAL` must be used on ReplacingMergeTree raw tables during reconciliation.
- Joins must not multiply encounter or revenue facts.
- Revenue must retain paid, non-refunded, non-cancelled, `SBL` rules.
- The source does not expose a confirmed bed-plan schema in the supplied files; bed mart remains a documented placeholder until those tables are identified.

### Task 1: Add static SQL contract test

**Files:**
- Create: `dashboard_v2/mart/tests/test_mart_sql.sh`

- [ ] **Step 1: Write the failing test**

Assert that the expected SQL files, databases, fact names, mart names, revenue filters, half-open date convention, and Gold PII guard are present.

- [ ] **Step 2: Run the test to verify it fails**

Run `bash dashboard_v2/mart/tests/test_mart_sql.sh`; it must fail because the mart SQL files do not exist yet.

- [ ] **Step 3: Implement the smallest test helper**

Keep this as a shell assertion script with no external dependency.

### Task 2: Create database and Silver canonical facts

**Files:**
- Create: `dashboard_v2/mart/00-databases.sql`
- Modify: `dashboard_v2/mart/02-silver-canonical-facts.sql`

- [ ] **Step 1: Create `hms_silver` and `hms_gold`.
- [ ] **Step 2: Read source tables directly with `SELECT * FROM hms_raw.<postgres_table> FINAL` inside canonical fact queries.
- [ ] **Step 3: Keep raw/Airbyte metadata out of downstream SQL by selecting only business columns in canonical facts.
- [ ] **Step 4: Run the static contract test.

### Task 3: Create Silver canonical facts

**Files:**
- Create: `dashboard_v2/mart/02-silver-canonical-facts.sql`

- [ ] **Step 1: Define `ct_luot_kham` at one row per encounter.
- [ ] **Step 2: Define `ct_dot_noi_tru` at one row per admission/discharge episode.
- [ ] **Step 3: Define `ct_don_thuoc` at one row per `(khambenh_id, mauhososohoa_id)`.
- [ ] **Step 4: Define `ct_chi_dinh_dich_vu` at one row per service-detail record.
- [ ] **Step 5: Define `ct_dong_doanh_thu` at one row per paid revenue-detail record.
- [ ] **Step 6: Preserve current-state filters and the function-specific business predicates.
- [ ] **Step 7: Run the static contract test.

### Task 4: Create Gold daily marts and semantic summary

**Files:**
- Create: `dashboard_v2/mart/03-gold-daily-marts.sql`

- [ ] **Step 1: Create `dm_luot_kham_ngay` with encounter/admission/discharge measures.
- [ ] **Step 2: Create `dm_don_thuoc_ngay` and `dm_doanh_thu_ngay`.
- [ ] **Step 3: Create a parameterized summary query template with current/previous period metrics.
- [ ] **Step 4: Keep bed capacity out of executable SQL until source tables and columns are confirmed.
- [ ] **Step 5: Run the static contract test.

### Task 5: Add execution, reconciliation, and operations documentation

**Files:**
- Create: `dashboard_v2/mart/README.md`
- Create: `dashboard_v2/mart/04-validation.sql`
- Modify: `dashboard_v2/docs/data-mart-design.md`

- [ ] **Step 1: Document execution order and required ClickHouse credentials.
- [ ] **Step 2: Document `DESCRIBE`, row-count, uniqueness, and function-parity checks.
- [ ] **Step 3: Add validation queries for fact grain, revenue, and date boundaries.
- [ ] **Step 4: Document the current bed-mart blocker and the conversion path from views to materialized tables.
- [ ] **Step 5: Run the static test and inspect the final diff.

## Verification

- `bash dashboard_v2/mart/tests/test_mart_sql.sh` passes.
- If ClickHouse is available, run all SQL files in order with `clickhouse-client --multiquery` and execute `04-validation.sql`.
- If ClickHouse is unavailable, report that runtime execution remains pending; static validation is not a substitute.
