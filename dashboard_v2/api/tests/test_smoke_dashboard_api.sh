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
trap 'rm -rf "$empty_response_path"' EXIT
ln -s "$curl_fixture" "$empty_response_path/curl"

PATH="$empty_response_path:$PATH" \
CLICKHOUSE_URL='https://clickhouse.test:8443' \
DASHBOARD_API_USER='dashboard_api' \
DASHBOARD_API_PASSWORD='test-password' \
FROM_DATE=2026-10-01 \
TO_DATE=2026-10-31 \
"$smoke" >/dev/null || fail "smoke script rejected a valid empty JSONEachRow response"

echo "PASS: smoke preflight contract"
