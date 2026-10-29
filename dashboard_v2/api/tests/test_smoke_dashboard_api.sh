#!/usr/bin/env bash
set -euo pipefail

root="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
smoke="$root/smoke-dashboard-api.sh"
curl_fixture="$root/fixtures/curl-empty-json-each-row.sh"

fail() { echo "FAIL: $*" >&2; exit 1; }

test -x "$smoke" || fail "missing executable smoke-dashboard-api.sh"
test -x "$curl_fixture" || fail "missing executable curl fixture"

set +e
output="$(env -u CLICKHOUSE_URL -u DASHBOARD_API_USER -u DASHBOARD_API_PASSWORD -u FROM_DATE -u TO_DATE "$smoke" 2>&1)"
status=$?
set -e

test "$status" -ne 0 || fail "smoke script accepted missing configuration"
printf '%s\n' "$output" | grep -Fq 'CLICKHOUSE_URL is required' || fail "smoke script did not report missing CLICKHOUSE_URL"

empty_response_path="$(mktemp -d)"
handler_log="$(mktemp)"
trap 'rm -rf "$empty_response_path" "$handler_log"' EXIT
ln -s "$curl_fixture" "$empty_response_path/curl"

run_smoke() {
  PATH="$empty_response_path:$PATH" \
  CLICKHOUSE_URL='https://clickhouse.test:8443' \
  DASHBOARD_API_USER='dashboard_api' \
  DASHBOARD_API_PASSWORD='test-password' \
  FROM_DATE=2026-10-01 \
  TO_DATE=2026-10-31 \
  "$smoke"
}

set +e
denial_output="$(run_smoke 2>&1)"
denial_status=$?
set -e
test "$denial_status" -ne 0 || fail "smoke script accepted an unrelated HTTP 500 as access denial"
printf '%s\n' "$denial_output" | grep -Fq 'ACCESS_DENIED' || fail "smoke script did not require ACCESS_DENIED"

CURL_FIXTURE_DENIAL_BODY='Code: 497. DB::Exception: ACCESS_DENIED' CURL_FIXTURE_LOG="$handler_log" run_smoke >/dev/null || fail "smoke script rejected valid access denials"

for endpoint in \
  '/api/v1/dashboard-summary' \
  '/api/v1/revenue-daily' \
  '/api/v1/icd10' \
  '/api/v1/visits-daily' \
  '/api/v1/examinations-daily' \
  '/api/v1/inpatient-daily' \
  '/api/v1/transfers-daily' \
  '/api/v1/prescriptions-daily' \
  '/api/v1/cost-confirmations-daily' \
  '/api/v1/gender-daily' \
  '/api/v1/patient-types-daily'; do
  grep -Fq "$endpoint" "$handler_log" || fail "smoke script did not request $endpoint"
done

echo "PASS: smoke preflight contract"
