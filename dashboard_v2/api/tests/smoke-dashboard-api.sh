#!/usr/bin/env bash
set -euo pipefail

require_env() {
  local name="$1"
  test -n "${!name:-}" || { echo "$name is required" >&2; exit 1; }
}

for name in CLICKHOUSE_URL DASHBOARD_API_USER DASHBOARD_API_PASSWORD FROM_DATE TO_DATE; do
  require_env "$name"
done

command -v curl >/dev/null || { echo "curl is required" >&2; exit 1; }
command -v jq >/dev/null || { echo "jq is required" >&2; exit 1; }

escape_curl_config() {
  sed 's/\\/\\\\/g; s/"/\\"/g'
}

curl_config="$(mktemp)"
trap 'rm -f "$curl_config"' EXIT
chmod 600 "$curl_config"
printf 'user = "%s:%s"\n' \
  "$(printf '%s' "$DASHBOARD_API_USER" | escape_curl_config)" \
  "$(printf '%s' "$DASHBOARD_API_PASSWORD" | escape_curl_config)" > "$curl_config"

base_url="${CLICKHOUSE_URL%/}"

authenticated_body="$(curl --config "$curl_config" --fail-with-body --silent --show-error --get \
  --data-urlencode 'query=SELECT 1' \
  "$base_url/")"
test "$authenticated_body" = '1' || { echo "dashboard API authentication check failed" >&2; exit 1; }

request_handler() {
  local path="$1"
  local body

  body="$(curl --config "$curl_config" --fail-with-body --silent --show-error --get \
    --data-urlencode "from_date=$FROM_DATE" \
    --data-urlencode "to_date=$TO_DATE" \
    "$base_url$path")"

  test -z "$body" || printf '%s\n' "$body" | jq -e . >/dev/null
}

request_handler '/api/v1/dashboard-summary'
request_handler '/api/v1/revenue-daily'
request_handler '/api/v1/icd10'

unauthenticated_status="$(curl --silent --show-error --output /dev/null --write-out '%{http_code}' --get \
  --data-urlencode "from_date=$FROM_DATE" \
  --data-urlencode "to_date=$TO_DATE" \
  "$base_url/api/v1/dashboard-summary")"
case "$unauthenticated_status" in
  401|403) ;;
  *) echo "expected 401 or 403 without credentials, got $unauthenticated_status" >&2; exit 1 ;;
esac

expect_access_denied() {
  local query="$1" response body status

  response="$(curl --config "$curl_config" --silent --show-error --write-out $'\n%{http_code}' --get \
    --data-urlencode "query=$query" \
    "$base_url/")"
  status="${response##*$'\n'}"
  body="${response%$'\n'*}"

  case "$status" in
    4*|5*) ;;
    *) echo "expected denied query to fail, got HTTP $status" >&2; exit 1 ;;
  esac
  printf '%s\n' "$body" | grep -Fq 'ACCESS_DENIED' || { echo "expected ACCESS_DENIED, got: $body" >&2; exit 1; }
}

expect_access_denied 'SELECT count() FROM hms_raw.benh_nhan_dot_dieu_tri'
expect_access_denied 'SELECT count() FROM hms_silver.ct_luot_kham'
expect_access_denied 'SELECT count() FROM hms_gold.dm_luot_kham_ngay'

echo "PASS: dashboard API smoke test"
