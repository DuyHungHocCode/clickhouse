# CDC PostgreSQL → ClickHouse RAW

Luồng này mirror 19 bảng `tenant_bvcahn` vào database ClickHouse `hms_raw`. Nó chưa tạo fact, mart hoặc dashboard.

## 1. Chuẩn bị source PostgreSQL

Trên máy có quyền quản trị PostgreSQL, đặt DSN vào shell rồi chạy preflight:

```bash
export HMS_SOURCE_DSN='postgresql://admin:password@host:5432/database'
psql "$HMS_SOURCE_DSN" -f dashboard_v2/cdc/sql/02-postgres-preflight.sql
```

Preflight phải pass trước khi tiếp tục. Nếu báo `wal_level`, `max_replication_slots` hoặc `max_wal_senders`, cấu hình PostgreSQL cần được sửa và restart bởi DBA.

Tạo CDC user và publication:

```bash
psql "$HMS_SOURCE_DSN" \
  -v peerdb_source_password='strong-source-password' \
  -f dashboard_v2/cdc/sql/03-postgres-publication.sql
```

## 2. Chuẩn bị ClickHouse và network Docker

```bash
cd dashboard_v2
set -a; . ./.env; set +a
docker compose up -d --force-recreate clickhouse
```

Lệnh trên tạo network Docker `hms_cdc`, để PeerDB kết nối ClickHouse bằng DNS `clickhouse:9000` mà không cần mở thêm port mạng.

## 3. Cấu hình và chạy PeerDB

```bash
cd dashboard_v2/cdc
cp .env.example .env
# Sửa HMS_SOURCE_* và toàn bộ password trong .env
set -a; . ./.env; set +a
./scripts/render-sql.py
```

Khởi động PeerDB:

```bash
docker compose --env-file .env up -d
```

UI PeerDB mặc định: `http://127.0.0.1:3000`.

## 4. Tạo ClickHouse RAW target và mirror

Chạy bootstrap ClickHouse từ thư mục `dashboard_v2`:

```bash
docker compose exec -T clickhouse \
  clickhouse-client --user admin --password "$CLICKHOUSE_PASSWORD" --multiquery \
  < cdc/rendered/01-clickhouse-raw.sql
```

Kết nối PeerDB SQL server rồi chạy template mirror đã render:

```bash
psql "host=127.0.0.1 port=9900 password=$PEERDB_PASSWORD"
\i rendered/04-peerdb-mirror.sql
```

Mirror `hms_pg_to_ch_raw` sẽ initial snapshot rồi theo dõi WAL. Đích có 19 bảng `hms_raw.raw_*` với metadata `_peerdb_version`, `_peerdb_is_deleted`, `_peerdb_synced_at`.

## 5. Kiểm tra

```bash
./scripts/verify-raw-cdc.sh static
```

Khi initial snapshot hoàn tất, kiểm tra bằng ClickHouse:

```sql
SELECT name, engine
FROM system.tables
WHERE database = 'hms_raw'
ORDER BY name;

SELECT count()
FROM hms_raw.raw_tiep_nhan FINAL
WHERE _peerdb_is_deleted = 0;
```

## Recovery

- PeerDB dừng nhưng WAL còn: chạy lại `docker compose --env-file .env up -d`.
- Replication slot invalid hoặc WAL đã bị dọn: không tự tạo mirror mới; chạy preflight, resnapshot mirror rồi đối soát lại function PostgreSQL.
- Không chạy `OPTIMIZE ... FINAL` để sửa correctness; latest-state query phải dùng `FINAL` cho đến khi phase canonical facts được triển khai.
