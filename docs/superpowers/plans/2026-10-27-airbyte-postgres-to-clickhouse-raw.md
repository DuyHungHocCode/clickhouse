# Airbyte PostgreSQL to ClickHouse RAW Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Provide a safe, runnable Airbyte setup guide and repository-owned inventory for loading the 19 approved PostgreSQL business tables into ClickHouse `hms_raw` without CDC privileges.

**Architecture:** Airbyte Core is installed outside this Compose project by `abctl`; the repository holds no Airbyte platform secrets or generated state. The Postgres source uses `Standard (xmin)` rather than CDC/WAL. A versioned JSON inventory is the single source of truth for the selected source streams. A short Python validator verifies its schema and the expected 19-table set; the Vietnamese runbook uses the inventory to configure Airbyte's Postgres source and ClickHouse destination through the UI.

**Tech Stack:** Airbyte Core (`abctl`), Airbyte Postgres/ClickHouse connectors, JSON, Python standard library, Docker, ClickHouse SQL.

**Spec:** `docs/superpowers/specs/2026-10-27-airbyte-postgres-to-clickhouse-raw-design.md`

## Global Constraints

- Airbyte must use PostgreSQL `Standard (xmin)`, not CDC/WAL/logical replication.
- PostgreSQL credentials require only `USAGE` on `tenant_bvcahn` and `SELECT` on the 19 selected tables.
- Airbyte owns direct-load tables in ClickHouse `hms_raw`; never write to PeerDB `raw_*` tables.
- Do not modify or start `dashboard_v2/cdc` (PeerDB).
- Do not commit secrets, `abctl` state, or an Airbyte export containing credentials.
- Hard deletes are not synchronized.

## Review Focus

- Inventory missing, duplicated, or unexpected stream: validator must fail and identify it.
- Secrets accidentally placed in the checked-in sample environment file: validator must reject populated password fields.
- Operator chooses CDC in the Airbyte UI: runbook must explicitly select standard/incremental polling and call out the non-CDC setting.
- A stream has no suitable PK: runbook must prevent deduplicated destination sync and prescribe full-refresh overwrite only after operator review.
- Existing PeerDB and Airbyte both target the same table: runbook must identify this as prohibited and require an Airbyte-owned table namespace/prefix.

### Task 1: Add the Airbyte stream inventory and validation

**Files:**
- Create: `dashboard_v2/airbyte/streams.json`
- Create: `dashboard_v2/airbyte/scripts/validate_inventory.py`
- Create: `dashboard_v2/airbyte/tests/test_validate_inventory.py`

**Interfaces:**
- Consumes: `streams.json` containing `source_schema` and a `streams` array of objects with `source_table` and `primary_key`.
- Produces: `python3 dashboard_v2/airbyte/scripts/validate_inventory.py [path]`, exit code 0 only for exactly the expected 19 unique `tenant_bvcahn` table names; concise errors on stderr otherwise.

- [ ] **Step 1: Write the failing validator tests**

```python
def test_accepts_the_approved_19_streams(tmp_path): ...
def test_rejects_a_missing_or_unexpected_stream(tmp_path): ...
def test_rejects_empty_primary_key(tmp_path): ...
```

Use a valid fixture with the 19 source table names. The test's production change is the absent validator script.

- [ ] **Step 2: Run the test to verify it fails**

Run: `python3 -m unittest dashboard_v2.airbyte.tests.test_validate_inventory`

Expected: FAIL because `validate_inventory` cannot be imported.

- [ ] **Step 3: Implement the minimal `validate_inventory.py` validator**

Load JSON with the standard library. Compare the normalized table-name set to the constant approved set. Require `source_schema == "tenant_bvcahn"`, one stream per table, and a non-empty `primary_key` array. Print only the stream count on success; list validation failures on stderr and exit non-zero.

- [ ] **Step 4: Add `streams.json`**

Set `source_schema` to `tenant_bvcahn`; include each of the 19 source tables once. Set the real primary-key values only after the source DBA confirms them; use explicit `"REQUIRED_FROM_SOURCE_DBA"` placeholders so validation fails until the file is completed.

- [ ] **Step 5: Extend the tests for the checked-in placeholder state**

Assert the checked-in inventory fails with an error naming the unresolved primary-key fields, while a complete generated fixture passes. This makes the external source-schema dependency visible rather than silently assuming a key.

- [ ] **Step 6: Run the validator tests**

Run: `python3 -m unittest dashboard_v2.airbyte.tests.test_validate_inventory -v`

Expected: PASS; test confirms incomplete checked-in cursor/PK placeholders are rejected.

### Task 2: Add safe configuration defaults and an operator runbook

**Files:**
- Create: `dashboard_v2/airbyte/.env.example`
- Create: `dashboard_v2/airbyte/.gitignore`
- Create: `dashboard_v2/airbyte/README.md`
- Create: `dashboard_v2/airbyte/tests/test_runbook.py`
- Modify: `dashboard_v2/README.md`

**Interfaces:**
- Consumes: connection variables documented in `.env.example` and the selected stream inventory from Task 1.
- Produces: a Vietnamese procedure to install Airbyte with `abctl`, create source/destination/connections in the UI, run the initial sync, and verify it in ClickHouse.

- [ ] **Step 1: Write failing documentation-content tests**

```python
def test_runbook_forbids_cdc_and_documents_read_only_grants(): ...
def test_runbook_references_inventory_all_approved_tables_and_checks(): ...
def test_sample_environment_has_no_populated_secrets(): ...
```

Use plain file reads; assert headings, commands, the 19 table names, `USAGE`/`SELECT`, `abctl local install`, `hms_raw`, duplicate-PK and freshness SQL checks, and explicit hard-delete limitation.

- [ ] **Step 2: Run the documentation tests to verify they fail**

Run: `python3 -m unittest dashboard_v2.airbyte.tests.test_runbook -v`

Expected: FAIL because the Airbyte runbook and sample environment do not exist.

- [ ] **Step 3: Add `.env.example` and `.gitignore`**

Provide empty placeholders for host, port, database, user, password, ClickHouse endpoint, user and password. Ignore `.env` and local Airbyte exports/state. Do not add connection strings containing secrets.

- [ ] **Step 4: Write `dashboard_v2/airbyte/README.md`**

Document prerequisites, read-only PostgreSQL grants, `abctl` install/start and stop commands, UI fields for PostgreSQL `Standard (xmin)` (CDC disabled), ClickHouse destination using namespace `hms_raw`, stream selection via `streams.json`, PK resolution, a conservative schedule, initial sync, row-count/freshness/PK-duplicate verification SQL, recovery, and the hard-delete/PeerDB coexistence constraints. Link official Airbyte documentation and the repository inventory.

- [ ] **Step 5: Link the Airbyte runbook from `dashboard_v2/README.md`**

Add one short section pointing to the Airbyte directory and stating it is a non-CDC alternative to the existing PeerDB folder.

- [ ] **Step 6: Run documentation tests and static validation**

Run: `python3 -m unittest discover -s dashboard_v2/airbyte/tests -v && python3 dashboard_v2/airbyte/scripts/validate_inventory.py dashboard_v2/airbyte/streams.json`

Expected: tests PASS; the static validator exits non-zero specifically because cursor/PK values must come from the source DBA. This expected guard failure is documented, not a release failure.

### Task 3: Verify the repository artifacts without deploying infrastructure

**Files:**
- Verify: `dashboard_v2/airbyte/streams.json`
- Verify: `dashboard_v2/airbyte/README.md`
- Verify: `dashboard_v2/airbyte/.env.example`
- Verify: `dashboard_v2/README.md`

**Interfaces:**
- Consumes: all deliverables above.
- Produces: evidence that JSON parses, test suite passes, reference table set contains 19 entries, and no secrets were created.

- [ ] **Step 1: Validate JSON and count streams**

Run: `python3 -m json.tool dashboard_v2/airbyte/streams.json >/dev/null && python3 -c "import json; print(len(json.load(open('dashboard_v2/airbyte/streams.json'))['streams']))"`

Expected: exit 0 and `19`.

- [ ] **Step 2: Run the complete Airbyte artifact test suite**

Run: `python3 -m unittest discover -s dashboard_v2/airbyte/tests -v`

Expected: PASS with no failures.

- [ ] **Step 3: Inspect the changed file set**

Run: `git diff --check && git status --short -- dashboard_v2/airbyte dashboard_v2/README.md docs/superpowers`

Expected: no whitespace errors; only planned files plus the already-existing, unrelated changes remain.

- [ ] **Step 4: Do not install or start Airbyte**

`abctl local install` downloads images and creates a host-level Kubernetes cluster; leave that action to the operator following the runbook, unless separately authorized.
