#!/usr/bin/env python3
import os
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
OUT = ROOT / "rendered"

required = [
    "PEERDB_CLICKHOUSE_PASSWORD",
    "HMS_SOURCE_HOST",
    "HMS_SOURCE_PORT",
    "HMS_SOURCE_DATABASE",
    "HMS_SOURCE_USER",
    "HMS_SOURCE_PASSWORD",
]
missing = [name for name in required if not os.environ.get(name)]
if missing:
    raise SystemExit(f"Missing environment variables: {', '.join(missing)}")
if not os.environ["HMS_SOURCE_PORT"].isdigit():
    raise SystemExit("HMS_SOURCE_PORT must be numeric")

def sql_value(name: str) -> str:
    return os.environ[name].replace("'", "''")

replacements = {
    "__PEERDB_CLICKHOUSE_PASSWORD__": sql_value("PEERDB_CLICKHOUSE_PASSWORD"),
    "__HMS_SOURCE_HOST__": sql_value("HMS_SOURCE_HOST"),
    "__HMS_SOURCE_PORT__": os.environ["HMS_SOURCE_PORT"],
    "__HMS_SOURCE_DATABASE__": sql_value("HMS_SOURCE_DATABASE"),
    "__HMS_SOURCE_USER__": sql_value("HMS_SOURCE_USER"),
    "__HMS_SOURCE_PASSWORD__": sql_value("HMS_SOURCE_PASSWORD"),
}

OUT.mkdir(exist_ok=True)
for source_name in ("01-clickhouse-raw.sql", "04-peerdb-mirror.sql.template"):
    text = (ROOT / "sql" / source_name).read_text()
    for placeholder, value in replacements.items():
        text = text.replace(placeholder, value)
    target_name = source_name.replace(".template", "")
    (OUT / target_name).write_text(text)
    print(OUT / target_name)
