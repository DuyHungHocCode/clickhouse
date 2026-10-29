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

## Nâng ClickHouse để chạy HTTP handlers

`CREATE HANDLER` cần ClickHouse 26.8 trở lên. Compose đang pin
`26.10.2.103`; không đổi sang `latest` để deployment tái lập được.

Trên server đích, sao lưu volume trước khi nâng. Không chạy ClickHouse 25.8
với volume đã được ClickHouse 26.x mở hoặc nâng cấp.

```bash
docker compose down
# Tạo snapshot/backup cấp host cho Docker volume clickhouse_data tại đây.
docker compose pull clickhouse
docker compose up -d
docker compose exec clickhouse clickhouse-client --user admin --password "$CLICKHOUSE_PASSWORD" --query 'SELECT version()'
```

Nếu phải quay lui, dừng stack, phục hồi snapshot volume đã tạo trước khi nâng,
rồi khởi động lại bằng image 25.8 cũ. Không downgrade trên cùng volume.

Các endpoint dashboard sẽ được khai báo bởi SQL trong `api/`, sau khi các mart
đã được tạo. Khi dashboard chạy trên origin khác, đặt CORS/TLS ở reverse proxy
của server đích; không mở rộng CORS trực tiếp trong Compose này.

## Deploy API dashboard ở server đích

Chạy các mart theo thứ tự trong `mart/README.md` trước, rồi nạp password API
từ secret store của server vào biến `DASHBOARD_API_PASSWORD`. Không đưa password
vào file SQL, `.env`, lệnh đã lưu trong shell history, hoặc ticket triển khai.

```bash
docker compose exec -T clickhouse clickhouse-client \
  --user admin --password "$CLICKHOUSE_PASSWORD" \
  --param_dashboard_api_password "$DASHBOARD_API_PASSWORD" \
  --multiquery < api/01-dashboard-api.sql

docker compose exec -T clickhouse clickhouse-client \
  --user admin --password "$CLICKHOUSE_PASSWORD" \
  --param_from_date=2026-10-01 --param_to_date=2026-10-31 \
  --multiquery < api/02-verify-dashboard-api.sql
```

Smoke test cần `curl` và `jq`; chỉ chạy từ máy có thể kết nối đến ClickHouse:

```bash
CLICKHOUSE_URL='https://clickhouse.example:8443' \
DASHBOARD_API_USER='dashboard_api' \
DASHBOARD_API_PASSWORD="$DASHBOARD_API_PASSWORD" \
FROM_DATE=2026-10-01 TO_DATE=2026-10-31 \
api/tests/smoke-dashboard-api.sh
```

Migration tạo mười một handler. Có thể chạy lại để bổ sung handler chưa có nhờ
`CREATE HANDLER IF NOT EXISTS`; nếu cần đổi SQL của một handler đang tồn tại,
dùng `ALTER HANDLER <name> AS ...` trong migration riêng.

Smoke test kiểm tra mười một handler, JSON response, authentication bắt buộc và việc
`dashboard_api` bị từ chối khi đọc raw data. Nó không chạy trong máy phát triển
này vì ClickHouse đích chưa sẵn sàng.

Xem [hướng dẫn gọi và test từng HTTP API](api/TESTING.md) để có lệnh `curl`,
kiểm tra quyền và chẩn đoán lỗi `ACCESS_DENIED`.

Stop without deleting data: `docker compose down`.
