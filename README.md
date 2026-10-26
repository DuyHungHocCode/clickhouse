# HMS Analytics Lab

Docker Compose infrastructure for the Hospital Analytics lab. It runs a mock PostgreSQL source, PeerDB CDC runtime, single-node ClickHouse, and Apache Superset. The mock source will later be replaced by the external PostgreSQL connection details without changing ClickHouse layers.

## Start

```bash
cp .env.example .env
make doctor PROFILE=full
make up PROFILE=full
```

The Superset admin database is initialized only on the target machine after the service is running:

```bash
make up PROFILE=bi
make superset-init
```

## Profiles

| Profile | Services | Use |
|---|---|---|
| `source` | PostgreSQL mock | Source schema and CDC prerequisites |
| `cdc-core` | PostgreSQL, ClickHouse, PeerDB runtime | CDC integration and recovery |
| `bi` | ClickHouse, Superset | BI development |
| `full` | All services | End-to-end development; requires at least 12 GiB Docker memory, 16 GiB recommended |

Use `make down PROFILE=<profile>` to stop a profile. Docker named volumes persist until explicitly removed; do not use `docker compose down -v` unless you intend to erase lab state.

## Static verification in this workspace

This workspace deliberately does not start containers, pull images, or run CDC. Validate the Compose model only:

```bash
for profile in source cdc-core bi full; do
  PROFILE=$profile ./scripts/verify-infra.sh config
done
docker compose --profile full config -q
```

Run health, initialization, persistence, PeerDB mirror and CDC checks on the target machine after image pull.
