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

raw_status="$(curl --config "$curl_config" --silent --show-error --output /dev/null --write-out '%{http_code}' --get \
  --data-urlencode 'query=SELECT count() FROM hms_raw.benh_nhan_dot_dieu_tri' \
  "$base_url/")"
case "$raw_status" in
  2*) echo "dashboard API user can read hms_raw" >&2; exit 1 ;;
esac

echo "PASS: dashboard API smoke test"
