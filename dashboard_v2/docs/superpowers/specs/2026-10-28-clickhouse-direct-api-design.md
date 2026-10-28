# Direct ClickHouse Analytics API — Design

## Intent

Expose the existing privacy-reviewed Gold marts as a small read-only HTTP API for a lab dashboard. ClickHouse owns query execution and endpoint definitions; no application backend is introduced.

## Goals

- Provide stable JSON endpoints for daily dashboard summary, daily revenue, and ICD-10 aggregations.
- Reuse `hms_gold.dm_dashboard_ngay`, `hms_gold.dm_doanh_thu_ngay`, and `hms_gold.dm_icd10`; never query `hms_raw` or `hms_silver` from an endpoint.
- Use typed date parameters and the repository's existing inclusive `from_date`/`to_date` public contract, implemented as a half-open interval internally.
- Give the dashboard a separate least-privilege ClickHouse identity with bounded query resources.
- Keep endpoint DDL, verification SQL, and run instructions in this repository.

## Non-goals

- No frontend, backend, API gateway, tenant isolation model, writes, caching layer, or public-production hardening.
- No conversion of Gold views into tables/materialized views; their current parity-first design remains unchanged.
- No runtime deployment or data-volume migration from this workstation.

## Constraints

- `compose.yaml` currently pins ClickHouse `25.8`; `CREATE HANDLER` needs ClickHouse `26.8` or newer.
- The destination server is unavailable during this work, so live handler execution is an acceptance step, not a local check.
- The existing HTTP port is bound to `100.90.202.114`; the API user must not be `admin` and browser CORS must be explicitly allowlisted.
- API responses must contain no patient identifiers. Gold marts are the sole data contract.

## Approaches considered

1. **Keep 25.8 and configure `http_handlers`.** Works, but endpoint definitions live in server config and require a server restart/config deployment.
2. **Upgrade to ClickHouse 26.8+ and use `CREATE HANDLER`.** Endpoint definitions are SQL DDL, deploy beside marts, inspectable through `system.handlers`, and do not add an application service. **Selected.**
3. **Add a dashboard backend.** Better for a public or multi-tenant product, but explicitly outside this lab's need.

## Chosen architecture

```text
Lab dashboard browser
  └─ HTTPS / HTTP Basic Auth (dedicated dashboard_api user)
       └─ ClickHouse HTTP interface :8123/:8443
            └─ named CREATE HANDLER endpoints
                 └─ hms_gold views
```

The upgrade pins a tested ClickHouse 26.8+ image version. A new `api/` SQL migration set creates `dashboard_api`, grants only `SELECT` on the three named Gold views, and gives it a read-only settings profile/limits and quota. `CREATE HANDLER` endpoints query those views using typed `Date` parameters and `JSONEachRow` output. The API defaults to a bounded date range and result size; individual clients cannot submit arbitrary SQL.

The same repository section also contains static checks and a destination-server smoke script. The smoke script is intentionally not run until the upgraded destination has a data-volume backup and Gold marts have been loaded.

## Endpoint contract

| Endpoint | Parameters | Source | Response |
|---|---|---|---|
| `GET /api/v1/dashboard-summary` | `from_date: Date`, `to_date: Date` | `hms_gold.dm_dashboard_ngay` | one JSON row per date |
| `GET /api/v1/revenue-daily` | `from_date: Date`, `to_date: Date` | `hms_gold.dm_doanh_thu_ngay` | one JSON row per date and revenue group |
| `GET /api/v1/icd10` | `from_date: Date`, `to_date: Date` | `hms_gold.dm_icd10` | bounded JSON rows ordered by date and ICD-10 dimensions |

Each endpoint uses `ngay >= {from_date:Date}` and `ngay < addDays({to_date:Date}, 1)`, matching `mart/04-validation.sql`.

## Security and operations decisions

- Generate the API password only on the destination server; keep it in its deployment secret store, not `.env`, SQL files, shell history, or documentation.
- Set the user to read-only and bound execution time, memory, result rows/bytes, and read rows. Attach a quota keyed by user (or IP if the lab has multiple callers).
- Restrict CORS to the dashboard's lab origin. Prefer a same-origin reverse proxy and TLS when the dashboard runs in a browser; a raw HTTP port is acceptable only on a trusted lab network.
- Back up the ClickHouse volume before upgrading. Do not roll an initialized 26.x data volume back to 25.8.
- Inspect `system.query_log`, `system.handlers`, `SHOW GRANTS`, and query resource metrics during acceptance.

## Acceptance criteria

- A ClickHouse 26.8+ instance accepts all API DDL after the existing mart setup.
- `dashboard_api` can call all three handlers but cannot read `hms_raw`, `hms_silver`, or arbitrary Gold objects.
- Valid typed date requests return parseable JSON and preserve half-open date boundaries.
- Missing/malformed dates, a too-large date range, and an unauthorized request fail predictably.
- The repository's static shell tests pass; destination smoke tests pass only after the target server is ready.
