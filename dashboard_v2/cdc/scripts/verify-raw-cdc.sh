#!/usr/bin/env bash
set -euo pipefail

root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
mode="${1:-static}"

if [[ "$mode" != "static" ]]; then
  echo "usage: $0 static" >&2
  exit 64
fi

for file in \
  "$root/compose.yaml" \
  "$root/.env.example" \
  "$root/sql/01-clickhouse-raw.sql" \
  "$root/sql/02-postgres-preflight.sql" \
  "$root/sql/03-postgres-publication.sql" \
  "$root/sql/04-peerdb-mirror.sql.template" \
  "$root/scripts/render-sql.py"; do
  [[ -f "$file" ]] || { echo "missing required CDC file: $file" >&2; exit 1; }
done

config="$(docker compose --env-file "$root/.env.example" -f "$root/compose.yaml" config --format json)"
CONFIG_JSON="$config" python3 - <<'PY'
import json
import os

config = json.loads(os.environ['CONFIG_JSON'])
services = set(config['services'])
expected = {
    'catalog', 'temporal', 'temporal-admin-tools', 'flow-migrate',
    'flow-api', 'flow-snapshot-worker', 'flow-worker', 'peerdb-server',
    'peerdb-ui', 'minio', 'minio-init',
}
assert services == expected, f'CDC services={sorted(services)}'
assert config['networks']['hms_cdc']['external'] is True
for service in ('flow-api', 'flow-snapshot-worker', 'flow-worker', 'minio'):
    assert 'hms_cdc' in config['services'][service]['networks'], service
print('CDC static configuration verification passed')
PY

python3 - "$root/sql/04-peerdb-mirror.sql.template" <<'PY'
from pathlib import Path
import re
import sys

text = Path(sys.argv[1]).read_text()
mappings = re.findall(r'^\s*tenant_bvcahn\.([a-z0-9_]+):([a-z0-9_]+),?$', text, re.M)
assert len(mappings) == 19, mappings
assert all(target.startswith('raw_') and '.' not in target for _, target in mappings)
assert 'soft_delete = true' in text
assert 'do_initial_copy = true' in text
print('CDC mirror mapping verification passed')
PY
