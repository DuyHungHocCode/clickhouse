# ClickHouse local

```bash
cp .env.example .env
docker compose up -d
docker compose ps
```

- HTTP: `http://127.0.0.1:8123`
- Native: `127.0.0.1:9000`
- Database: `hms`
- User: `admin`

```bash
docker compose exec clickhouse clickhouse-client --user admin --password "$CLICKHOUSE_PASSWORD" --database hms
```

Stop without deleting data: `docker compose down`.
