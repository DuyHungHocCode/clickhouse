#!/usr/bin/env bash
set -euo pipefail

mode="${1:-}"
profile="${PROFILE:-}"

if [[ "$mode" != "config" && "$mode" != "source" && "$mode" != "clickhouse" && "$mode" != "cdc-core" && "$mode" != "bi" ]]; then
  echo "usage: PROFILE=<source|cdc-core|bi|full> $0 <config|source|clickhouse|cdc-core|bi>" >&2
  exit 64
fi

case "$profile" in
  source|cdc-core|bi|full) ;;
  *) echo "invalid PROFILE: ${profile:-<empty>}" >&2; exit 64 ;;
esac

config="$(docker compose --profile "$profile" config --format json)"

CONFIG_JSON="$config" python3 - "$profile" <<'PY'
import json
import os
import sys

profile = sys.argv[1]
config = json.loads(os.environ["CONFIG_JSON"])
services = set(config.get("services", {}))
expected = {
    "source": {"hms-postgres"},
    "cdc-core": {
        "hms-postgres", "clickhouse", "peerdb-catalog", "temporal",
        "temporal-admin-tools", "flow-migrate", "flow-api",
        "flow-snapshot-worker", "flow-worker", "peerdb-server", "peerdb-ui", "minio",
    },
    "bi": {"clickhouse", "superset"},
    "full": {
        "hms-postgres", "clickhouse", "superset", "peerdb-catalog", "temporal",
        "temporal-admin-tools", "flow-migrate", "flow-api",
        "flow-snapshot-worker", "flow-worker", "peerdb-server", "peerdb-ui", "minio",
    },
}[profile]
assert services == expected, f"{profile} services={sorted(services)}, expected={sorted(expected)}"

volumes = set(config.get("volumes", {}))
required_volumes = {
    "source": {"hms_pg_data"},
    "cdc-core": {"hms_pg_data", "peerdb_catalog_data", "clickhouse_data"},
    "bi": {"clickhouse_data", "superset_home"},
    "full": {"hms_pg_data", "peerdb_catalog_data", "clickhouse_data", "superset_home"},
}[profile]
assert required_volumes <= volumes, f"missing volumes: {sorted(required_volumes - volumes)}"

for service, definition in config["services"].items():
    for port in definition.get("ports", []):
        published = port.get("host_ip", "")
        assert published == "127.0.0.1", f"{service} exposes port outside loopback: {published!r}"

print(f"config verification passed for {profile}")
PY

if [[ "$mode" == "source" ]]; then
  CONFIG_JSON="$config" python3 - <<'PY'
import json
import os

service = json.loads(os.environ["CONFIG_JSON"])["services"]["hms-postgres"]
assert service["image"].startswith("postgres:"), service["image"]
assert "-c" in service.get("command", []), service.get("command")
mounts = {volume["target"] for volume in service.get("volumes", [])}
assert "/etc/postgresql/postgresql.conf" in mounts, mounts
assert "/docker-entrypoint-initdb.d" in mounts, mounts
assert service.get("healthcheck", {}).get("test"), "missing healthcheck"
print("source static verification passed")
PY
fi

if [[ "$mode" == "clickhouse" ]]; then
  CONFIG_JSON="$config" python3 - <<'PY'
import json
import os

service = json.loads(os.environ["CONFIG_JSON"])["services"]["clickhouse"]
assert service["image"].startswith("clickhouse/clickhouse-server:"), service["image"]
mounts = {volume["target"] for volume in service.get("volumes", [])}
assert "/var/lib/clickhouse" in mounts, mounts
assert "/docker-entrypoint-initdb.d" in mounts, mounts
assert "/etc/clickhouse-server/config.d/01-lab-settings.xml" in mounts, mounts
assert int(service.get("mem_limit", 0)) == 6 * 1024 * 1024 * 1024, service.get("mem_limit")
assert service.get("healthcheck", {}).get("test"), "missing healthcheck"
assert len(service.get("ports", [])) == 2, service.get("ports")
print("clickhouse static verification passed")
PY
fi

if [[ "$mode" == "cdc-core" ]]; then
  CONFIG_JSON="$config" python3 - <<'PY'
import json
import os

services = json.loads(os.environ["CONFIG_JSON"])["services"]
assert services["peerdb-catalog"]["image"].startswith("postgres:"), services["peerdb-catalog"]["image"]
assert services["temporal"]["image"].startswith("temporalio/auto-setup:"), services["temporal"]["image"]
assert services["flow-api"]["image"].startswith("ghcr.io/peerdb-io/flow-api:"), services["flow-api"]["image"]
assert services["peerdb-server"]["image"].startswith("ghcr.io/peerdb-io/peerdb-server:"), services["peerdb-server"]["image"]
assert services["peerdb-ui"]["image"].startswith("ghcr.io/peerdb-io/peerdb-ui:"), services["peerdb-ui"]["image"]
assert services["flow-api"]["environment"]["PEERDB_CATALOG_HOST"] == "peerdb-catalog"
assert services["flow-api"]["environment"]["TEMPORAL_HOST_PORT"] == "temporal:7233"
assert services["peerdb-server"]["environment"]["PEERDB_FLOW_SERVER_ADDRESS"] == "grpc://flow-api:8112"
assert services["peerdb-ui"]["environment"]["PEERDB_FLOW_SERVER_HTTP"] == "http://flow-api:8113"
assert services["minio"].get("volumes"), "minio must persist data"
print("cdc-core static verification passed")
PY
fi

if [[ "$mode" == "bi" ]]; then
  CONFIG_JSON="$config" python3 - <<'PY'
import json
import os
import subprocess

services = json.loads(os.environ["CONFIG_JSON"])["services"]
assert set(services) == {"clickhouse", "superset"}, sorted(services)
superset = services["superset"]
assert superset["image"].startswith("apache/superset:"), superset["image"]
assert "/app/superset_home" in {volume["target"] for volume in superset.get("volumes", [])}
assert superset.get("healthcheck", {}).get("test"), "missing healthcheck"
assert len(superset.get("ports", [])) == 1, superset.get("ports")
bootstrap = subprocess.check_output(["make", "-n", "superset-init"], text=True)
assert "exec -T superset sh -c" in bootstrap, bootstrap
assert '"$SUPERSET_ADMIN_USERNAME"' in bootstrap, bootstrap
print("bi static verification passed")
PY
fi
