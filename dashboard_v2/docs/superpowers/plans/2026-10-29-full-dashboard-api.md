# Full Dashboard HTTP API Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Expose all eleven aggregate Gold marts as date-bounded, read-only ClickHouse HTTP endpoints for the lab dashboard.

**Architecture:** Keep the existing security boundary: `dashboard_api` can select only dedicated `hms_gold.api_*` views; those views execute under the non-login `dashboard_view_owner`. Add eight API views and handlers, while adding only the three new nested-view dependency grants required for the gender and patient-type marts. Static tests enforce that the owner Raw grants exactly match the all-handler lineage; smoke tests call all routes and preserve denial checks.

**Tech Stack:** ClickHouse 26.10.2.103, SQL security-definer views, `CREATE HANDLER`, Bash, curl, jq.

**Spec:** `docs/superpowers/specs/2026-10-29-full-dashboard-api-design.md`

## Global Constraints

- Use only `GET`, `from_date:Date`, `to_date:Date`, `JSONEachRow`, deterministic ordering, a 366-day maximum, and inverted-range validation.
- Keep the existing three route and response contracts unchanged; every endpoint returns all current columns of its Gold mart.
- `dashboard_api` must receive no Raw, Silver, normal Gold-mart, write, or generic SQL privileges.
- `dashboard_view_owner` must remain `HOST NONE`; its direct Raw grants must exactly match the SQL lineage of all exposed views.
- Do not add dependencies, CORS, TLS, reverse-proxy configuration, patient-level endpoints, or write endpoints.

## Review Focus

- An existing handler must not be silently duplicated or make the migration unusable when the server already has the first three handlers; pin replacement/deployment behavior in Task 2.
- Date boundaries must include `to_date` and reject inverted or greater-than-366-day intervals on every new route; assert the standard predicate in Task 1.
- The two new demographic marts must execute through the owner with `benh_nhan_tiep_nhan`, but HTTP users must still receive `ACCESS_DENIED` for Raw/Silver SQL; cover grants in Task 1 and runtime denial in Task 3.
- Empty result sets are valid JSONEachRow responses; retain the smoke fixture assertion in Task 3.
- ICD-10 may exceed the normal dashboard-card volume; retain its explicit 10,000-row limit while all other handlers remain constrained by the profile limit; assert this in Task 1.

---

### Task 1: Define the eleven-endpoint API contract in static tests

**Files:**
- Modify: `api/tests/test_dashboard_api_sql.sh`
- Modify: `api/tests/test_smoke_dashboard_api.sh`

**Interfaces:**
- Consumes: endpoint inventory and constraints from the spec.
- Produces: test requirements for eleven `api_*` views, eleven routes, standard date validation, exact owner lineage grants, and the existing HTTP-denial contract.

- [ ] **Step 1: Write failing static assertions for the eight new route/view pairs**

Assert these exact route/view pairs: `visits-daily/api_visits_daily`,
`examinations-daily/api_examinations_daily`, `inpatient-daily/api_inpatient_daily`,
`transfers-daily/api_transfers_daily`, `prescriptions-daily/api_prescriptions_daily`,
`cost-confirmations-daily/api_cost_confirmations_daily`, `gender-daily/api_gender_daily`,
and `patient-types-daily/api_patient_types_daily`.

- [ ] **Step 2: Run the API static contract test to verify it fails**

Run: `bash api/tests/test_dashboard_api_sql.sh`

Expected: failure reporting a missing new route or API view.

- [ ] **Step 3: Extend exact nested-dependency assertions**

Require `ct_gioi_tinh_tiep_nhan`, `ct_doi_tuong_benh_nhan`, and
`hms_raw.benh_nhan_tiep_nhan` grants to `dashboard_view_owner`; extend the
lineage calculation to include both new Silver views.

- [ ] **Step 4: Extend the smoke contract fixture requirements**

Require `smoke-dashboard-api.sh` to request all eleven routes while preserving
the existing authenticated `SELECT 1`, unauthenticated `401/403`, and Raw,
Silver, and normal-Gold `ACCESS_DENIED` checks.

- [ ] **Step 5: Commit the failing-test contract**

```bash
git add api/tests/test_dashboard_api_sql.sh api/tests/test_smoke_dashboard_api.sh
git commit -m "test: define full dashboard API contract"
```

### Task 2: Add the eight API views and HTTP handlers

**Files:**
- Modify: `api/01-dashboard-api.sql`
- Modify: `api/02-verify-dashboard-api.sql`

**Interfaces:**
- Consumes: Task 1 static route, owner-grant, and validation requirements.
- Produces: eleven dedicated API views, eleven read-only handlers, and an admin verification query for all routes/views.

- [ ] **Step 1: Add the three owner dependency grants**

Grant the two new Gold marts, their two Silver views, and
`hms_raw.benh_nhan_tiep_nhan` to `dashboard_view_owner`. Preserve existing
grants and keep every Raw grant addressed only to this `HOST NONE` user.

- [ ] **Step 2: Add eight dedicated security-definer API views and grants**

Create `hms_gold.api_*` views that project all columns from their corresponding
Gold mart, set `DEFINER = dashboard_view_owner SQL SECURITY DEFINER`, then
grant `SELECT` on only these eight views to `dashboard_api`.

- [ ] **Step 3: Add the eight handlers using the standard date contract**

Use the route/view pairs from Task 1, `throwIf(to_date < from_date, ...)`,
the 366-day `dateDiff` check, an inclusive `to_date` filter, and chronological
ordering by `ngay` (plus natural dimensions where present). Use `FORMAT
JSONEachRow`; do not add `LIMIT` except the existing ICD-10 handler's 10,000.

- [ ] **Step 4: Make handler deployment replacement explicit**

Use the ClickHouse-supported handler replacement syntax, or document a
separate one-time drop/create migration, so applying the expanded migration to
a server with the original three handlers has deterministic behavior.

- [ ] **Step 5: Extend admin verification**

Make `02-verify-dashboard-api.sql` list all eleven handlers/views and execute
a bounded `LIMIT 1` date-filtered read for every API view, so nested privilege
errors surface during deployment.

- [ ] **Step 6: Run static tests and ClickHouse parser verification**

Run: `bash api/tests/test_dashboard_api_sql.sh && docker run --rm --network none -i clickhouse/clickhouse-server:26.9.6.6 clickhouse format --multiquery --quiet < api/01-dashboard-api.sql`

Expected: both commands exit zero.

- [ ] **Step 7: Commit the API migration**

```bash
git add api/01-dashboard-api.sql api/02-verify-dashboard-api.sql api/tests/test_dashboard_api_sql.sh
git commit -m "feat: expose all dashboard gold marts"
```

### Task 3: Exercise and document all eleven endpoints

**Files:**
- Modify: `api/tests/smoke-dashboard-api.sh`
- Modify: `api/TESTING.md`
- Modify: `README.md`

**Interfaces:**
- Consumes: the complete route inventory from Task 2.
- Produces: a deployer can run one smoke command and find per-endpoint curl examples and expected security behavior.

- [ ] **Step 1: Extend the runtime smoke script**

Call all eleven endpoints with the supplied date range. Keep the ephemeral
curl config, empty-JSONEachRow acceptance, `SELECT 1` authentication check,
and all three `ACCESS_DENIED` checks.

- [ ] **Step 2: Update the testing guide inventory and commands**

Add the eight routes and their Gold-mart meaning to `api/TESTING.md`; make the
guide's expected smoke outcome say that all eleven routes were checked.

- [ ] **Step 3: Update README deployment wording**

Describe eleven handlers rather than three and link to the expanded testing
guide without duplicating curl instructions.

- [ ] **Step 4: Run the full local verification suite**

Run: `bash api/tests/test_dashboard_api_sql.sh && bash api/tests/test_smoke_dashboard_api.sh && bash mart/tests/test_mart_sql.sh && bash -n api/tests/smoke-dashboard-api.sh && git diff --check`

Expected: all contracts pass and no whitespace errors occur.

- [ ] **Step 5: Commit documentation and smoke coverage**

```bash
git add api/tests/smoke-dashboard-api.sh api/TESTING.md README.md
git commit -m "docs: cover all dashboard API endpoints"
```

### Task 4: Verify against the destination ClickHouse server

**Files:**
- No repository changes required.

**Interfaces:**
- Consumes: Task 2 migration and Task 3 smoke script.
- Produces: deployment evidence that all handlers are callable and the HTTP user cannot access restricted data.

- [ ] **Step 1: Apply the owner-grant/handler migration with the server secret**

Run `api/01-dashboard-api.sql` using the documented admin password and
`dashboard_api_password` parameter. Follow the replacement procedure chosen
in Task 2 if the three original handlers already exist.

- [ ] **Step 2: Run admin verification**

Run `api/02-verify-dashboard-api.sql` with a short known data range.

Expected: eleven handlers and views are listed; every bounded view query exits
without `ACCESS_DENIED`.

- [ ] **Step 3: Run HTTP smoke test**

Run: `CLICKHOUSE_URL=... DASHBOARD_API_USER=dashboard_api DASHBOARD_API_PASSWORD=... FROM_DATE=... TO_DATE=... api/tests/smoke-dashboard-api.sh`

Expected: `PASS: dashboard API smoke test`.

- [ ] **Step 4: Record the server result without committing secrets**

Report handler count, HTTP smoke result, and any exact missing-dependency error
without putting credentials in repository files or shell history.
