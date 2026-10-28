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

Stop without deleting data: `docker compose down`.
