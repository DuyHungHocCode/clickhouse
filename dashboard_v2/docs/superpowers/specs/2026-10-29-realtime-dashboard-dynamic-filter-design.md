# Realtime dashboard with dynamic filters design

## Goal

Build a lab-quality ClickHouse model for `/home/hungpd/Desktop/Gtel/dashboard/docs/metric.md`.
It must refresh operational metrics within 60 seconds and accept dynamic
combinations of date, facility, department/room, patient segment, gender, and
age-group filters. The browser receives aggregates or paginated drill-down data.

## Scope and fixed decisions

- This is a lab: authentication, tenant isolation, CORS/TLS, and row policies
  are out of scope. Values remain typed and allowlisted; no handler accepts SQL.
- “Realtime” means `data_as_of` is at most 60 seconds after the CDC commit has
  reached ClickHouse, not sub-second streaming.
- A department is the department/room of the business event, never a patient's
  later current department after transfer.
- Date ranges are at most 366 days. Unknown attribution is explicit as
  `UNKNOWN`, not silently assigned to another department.

## DDL evidence and CDC gap

| Requirement | DDL source |
| --- | --- |
| Facility | `ma_cskcb` on reception, examination, clinical, and invoice tables |
| Reception department/room | `tiep_nhan.khoa_tiep_nhan_id`, `phong_tiep_nhan_id` |
| Examination department/room | `kb_kham_benh.phong_ban_id`, `ma_khoa_dieu_tri` |
| Inpatient ward/bed | `csyt_benh_an_luu_tru[_chi_tiet]`, `dm_khoa`, `dm_phong`, `dm_giuong` |
| Segment | `benh_nhan_dot_dieu_tri.is_bhyt`, `ma_doi_tuong`, `ma_doi_tuong_lt` |
| Gender/age | `benh_nhan_tiep_nhan.ma_gioi_tinh`, `ngay_sinh` |
| Mortality/LOS | `csyt_benh_an_dieu_tri.tu_vong`, entry/discharge timestamps, `so_ngay_dieu_tri` |
| Revenue | `csyt_vien_phi_chung_tu[_chi_tiet]`, `dmc_ma_nhom_chi_phi` |
| Prescription threshold | `csyt_yl_thuocvt.gia_tt_id`, amount fields, eventual invoice-line mapping |

The existing PeerDB mirror lacks five tables required for dynamic
department/room/bed metrics. CDC must add:

```text
dm_khoa
dm_phong
dm_giuong
csyt_benh_an_luu_tru
csyt_benh_an_luu_tru_chi_tiet
```

`dmc_doi_tuong_kcb` is already mirrored. The `gia_tt_id` prescription-to-price
relationship must be profiled and reconciled before prescription amount buckets
are published.

## Approaches considered

1. Keep date-only Gold views and dynamically join Raw/Silver in handlers: easy
   but expensive and unable to calculate bed occupancy correctly.
2. One universal dashboard fact: mixes incompatible event grains and makes
   visit, revenue, and occupancy numbers wrong.
3. **Selected:** conformed dimensions, domain facts, and domain aggregates.
   Facts share filters but retain their natural event grain.

## Layer model

```text
L0 Raw CDC (ReplacingMergeTree)
  → L1 Silver current-state dimensions + domain facts
      → L2 Gold physical aggregates: rolling live window + closed history
          → L3 typed HTTP API → dashboard
```

### L0 Raw CDC

Keep PeerDB target tables immutable and use `FINAL` while deriving current
state. Never use `OPTIMIZE ... FINAL` as a correctness mechanism. Retain CDC
version and soft-delete metadata so every lower layer can be rebuilt.

### L1 Silver conformed dimensions

| Object | Grain | Required fields |
| --- | --- | --- |
| `dim_facility` | facility | `ma_cskcb`, display name if master data exists |
| `dim_department` | department | `khoa_id`, facility, code, name, planned beds |
| `dim_room` | room | `phong_id`, department, code, name |
| `dim_bed` | bed | `giuong_id`, department, room, active flag |
| `dim_patient_filter_at_encounter` | encounter | `tiep_nhan_id`, segment, gender, age group |

Age is computed at event date using fixed buckets `0_5`, `6_17`, `18_39`,
`40_59`, `60_PLUS`, `UNKNOWN`. Initial segment mapping is `BHYT`, `DICH_VU`,
`KHAC`, `UNKNOWN`; it must be a versioned lookup from the source codes.

### L1 Silver domain facts

Facts hold identifiers, event time/date, facility, conformed dimension keys,
and metric inputs. They contain no patient name, identifier, address, or phone.

| Fact | Grain | Primary source | Use |
| --- | --- | --- | --- |
| `fct_tiep_nhan` | encounter | `tiep_nhan` | reception, emergency, patient mix |
| `fct_kham_benh` | examination | `kb_kham_benh` | outpatient visits |
| `fct_noi_tru_stay` | ward-stay interval | `csyt_benh_an_luu_tru` | census/transfers |
| `fct_bed_stay` | bed interval | `csyt_benh_an_luu_tru_chi_tiet` | occupancy/bed-days |
| `fct_chuyen_vien` | transfer | transfer source + encounter mapping | transfers |
| `fct_revenue_line` | paid invoice line | invoice header/detail | revenue groups |
| `fct_prescription` | order | `csyt_yl_thuocvt` | count/value buckets |
| `fct_inpatient_outcome` | inpatient case | `csyt_benh_an_dieu_tri` | discharge, LOS, mortality |
| `fct_icd10` | diagnosis | existing ICD sources | ICD analysis |

If an event has no authoritative department, store `UNKNOWN`. Revenue is
attributed to the order/service department only where an auditable relation
exists; otherwise retain `UNKNOWN` instead of manufacturing departmental totals.

### L2 Gold physical aggregates

All domain aggregates share this filter grain:

```text
ngay, ma_cskcb, khoa_id, phong_id,
doi_tuong_code, gioi_tinh_code, nhom_tuoi_code
```

| Aggregate | Measures |
| --- | --- |
| `agg_encounter_daily_dim` | receptions, outpatient visits, emergencies |
| `agg_inpatient_daily_dim` | admissions, discharges, active census, deaths, LOS numerator/denominator |
| `agg_bed_daily_dim` | occupied bed-hours/days, planned and available beds, occupancy numerator/denominator |
| `agg_revenue_daily_dim` | net revenue by revenue group |
| `agg_prescription_daily_dim` | count, total amount, ≤500,000 and >500,000 count/value |
| `agg_icd10_daily_dim` | ICD measures by hierarchy |

Bed occupancy comes from interval overlap: split each bed-stay at day boundaries,
sum occupied duration, then divide by `dm_khoa.giuong_ke_hoach × days`. If
planned capacity is absent, return `NULL` occupancy plus a quality flag, never
zero.

The lab has two physical Gold tiers:

- `*_live_31d`: refreshable aggregate tables rebuilt from Silver `FINAL` every
  60 seconds for the last 31 days, including late updates/deletes.
- `*_closed`: daily history; rebuild the trailing 31-day correction window
  before a date becomes immutable.

An API view unions both tiers without overlap. Browser reads therefore avoid
running `FINAL` joins. A future sub-second architecture requires append-only
before/after CDC deltas; do not use incremental aggregation directly on the
current ReplacingMergeTree mirrors.

## L3 typed dynamic-filter API

Every request carries all filters; empty string means “all”. A multiselect is a
CSV code list of at most 100 entries. Values are split and compared only against
fixed columns, never concatenated into SQL syntax.

```text
from_date, to_date                         required Date
facility_ids                               optional CSV String
department_ids, room_ids                   optional CSV String
patient_segments, gender_codes, age_groups optional CSV String
```

Every handler validates date order, a 366-day maximum, and list cardinality.
All responses include `data_as_of` from refresh metadata.

| API family | Output |
| --- | --- |
| `/api/v2/filter-options` | canonical filter codes, constrained by parent selection |
| `/api/v2/summary` | cards, previous-period delta, `data_as_of` |
| `/api/v2/timeseries` | visits, emergency, inpatient, revenue by day |
| `/api/v2/bed-utilization` | department occupancy, numerator/denominator, quality |
| `/api/v2/revenue` | revenue group, amount, ratio |
| `/api/v2/prescriptions` | count/value and threshold buckets |
| `/api/v2/icd10` | bounded ICD hierarchy output |
| `/api/v2/alerts` | threshold results and observed time |
| `/api/v2/drilldown/*` | domain-specific, cursor/limit, max 1,000 rows |

## Metric semantics and quality rules

| Metric | Rule |
| --- | --- |
| Visits | `fct_kham_benh`, excluding waiting states after source-status validation |
| Emergency | documented reception emergency mapping |
| Inpatient count | point-in-time census from active stay intervals, not admission count |
| Occupancy | occupied bed-days ÷ planned bed-days; `NULL` if capacity missing |
| Average LOS | discharged LOS sum ÷ discharged case count; explicitly choose zero-day policy |
| Mortality | `tu_vong = true`, attributed to ward at death interval where available |
| Revenue | paid, non-reversed invoice lines; retain SBL/payment parity rules |
| Prescription threshold | finalized amount only after `gia_tt_id` reconciliation |

Each Gold object needs daily PostgreSQL parity checks for facility-wide,
department-specific, `UNKNOWN`, and no-data scenarios. Each refresh records
source max CDC version/time, duration, rows, and `data_as_of`; a failed refresh
keeps the previous good snapshot and creates an alert row.

## Delivery phases

1. Expand CDC and profile the five missing tables plus prescription-money joins.
2. Create dimensions and Silver facts; prove joins do not multiply facts.
3. Create filter-complete Gold query views and run parity checks before storing
   aggregates.
4. Add rolling live and closed Gold aggregate tiers; measure freshness/runtime.
5. Add v2 APIs, filter options, refresh metadata, and bounded drill-down.
6. Add alert rules; consider a delta event stream only after lab parity is stable.

## Acceptance criteria

- Every applicable filter changes all relevant metrics consistently.
- A CDC update/delete within 31 days appears correctly after the next refresh.
- Dashboard queries Gold aggregates, not Raw/Silver `FINAL` views.
- `data_as_of`, `UNKNOWN`, no-data, and capacity-quality cases are explicit.
- Approved PostgreSQL parity holds before a metric is displayed.
