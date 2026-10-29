# Full dashboard HTTP API design

## Intent

Expose every existing aggregate Gold mart through a direct ClickHouse HTTP
handler for the lab dashboard. The dashboard needs complete operational
analytics without receiving a generic SQL interface or direct Raw/Silver data.

## Scope

Keep the three existing endpoints unchanged and add one endpoint for each of
the eight remaining Gold marts, for a total of eleven:

| Route | Gold mart | Result |
| --- | --- | --- |
| `/api/v1/dashboard-summary` | `dm_dashboard_ngay` | Consolidated daily KPI |
| `/api/v1/revenue-daily` | `dm_doanh_thu_ngay` | Daily revenue by group |
| `/api/v1/icd10` | `dm_icd10` | Daily ICD-10 statistics |
| `/api/v1/visits-daily` | `dm_luot_kham_ngay` | Admissions, examinations, emergencies |
| `/api/v1/examinations-daily` | `dm_kham_benh_ngay` | Daily examinations |
| `/api/v1/inpatient-daily` | `dm_noi_tru_ngay` | Admissions and discharges |
| `/api/v1/transfers-daily` | `dm_chuyen_vien_ngay` | Daily transfers |
| `/api/v1/prescriptions-daily` | `dm_don_thuoc_ngay` | Daily prescriptions |
| `/api/v1/cost-confirmations-daily` | `dm_xac_nhan_chi_phi_ngay` | Insurance cost confirmations and XML exports |
| `/api/v1/gender-daily` | `dm_gioi_tinh_ngay` | Daily gender aggregates |
| `/api/v1/patient-types-daily` | `dm_doi_tuong_benh_nhan_ngay` | Daily patient-type aggregates |

All handlers accept only `GET` with required `from_date` and `to_date` values
in `YYYY-MM-DD`. Each response is `JSONEachRow`, sorted deterministically,
rejects inverted date ranges, and limits a range to 366 days. The existing
profile still caps responses at 50,000 rows; ICD-10 retains its explicit
10,000-row limit.

## Non-goals

- No generic SQL endpoint for the browser.
- No Raw or Silver endpoints, patient-level records, write operations, or
  new filters/dimensions beyond the date range.
- No CORS, TLS, rate-limit, or reverse-proxy change; those remain deployment
  concerns outside the ClickHouse migration.

## Security model

`dashboard_api` receives `SELECT` only on dedicated `hms_gold.api_*` views.
Each view uses `SQL SECURITY DEFINER` under `dashboard_view_owner`, which has
`HOST NONE` and cannot authenticate. The owner needs the underlying view
dependencies to execute nested Gold/Silver views, but it is never the account
used by HTTP clients.

The expansion adds only the missing dependencies for gender and patient-type
aggregates:

- `hms_gold.dm_gioi_tinh_ngay`, `hms_gold.dm_doi_tuong_benh_nhan_ngay`
- `hms_silver.ct_gioi_tinh_tiep_nhan`, `hms_silver.ct_doi_tuong_benh_nhan`
- `hms_raw.benh_nhan_tiep_nhan`

Existing owner grants already cover `hms_raw.benh_nhan_dot_dieu_tri` and
`hms_raw.tiep_nhan`. Tests must confirm `dashboard_api` still has no Raw,
Silver, or normal Gold-mart grants.

## Implementation approach selected

One handler per Gold mart was selected over bundled KPI endpoints or generic
SQL. This makes the HTTP surface explicit, allows independent caching and
future endpoint retirement, and keeps grants narrowly scoped. A bundled
endpoint would return unnecessary fields; generic SQL would defeat the access
boundary.

## Changes and verification

- Extend `api/01-dashboard-api.sql` with eight API views, eight grants, eight
  handlers, and the three additional owner dependency grants.
- Extend `api/02-verify-dashboard-api.sql` to list all eleven handlers/views
  and execute a bounded sample query against each API view.
- Extend smoke and static SQL tests to call/assert every route, while retaining
  unauthenticated and raw-access denial checks.
- Extend `api/TESTING.md` and README deployment text with the eleven-route
  inventory and expected smoke coverage.
- Validate static contracts, shell syntax, whitespace, ClickHouse SQL parsing,
  then run the HTTP smoke test on the destination server.

## Open deployment consideration

The currently deployed server must receive the additional owner grants before
the two new demographic endpoints are queried. The migration is idempotent for
the user, views, and grants, but existing handlers may require the documented
replacement deployment procedure if ClickHouse does not allow recreating a
handler in place.
