# Airbyte: PostgreSQL `tenant_bvcahn` → ClickHouse `hms_raw`

Tài liệu này nạp dữ liệu nghiệp vụ từ PostgreSQL vào ClickHouse bằng Airbyte, **không dùng CDC/WAL**, không cần quyền `REPLICATION`, publication hay replication slot.

Airbyte dùng phương thức PostgreSQL **Standard (xmin)**: có thể lấy bản ghi insert/update mới nhưng **không đồng bộ hard delete**. Mục tiêu trước mắt là initial sync và cập nhật theo lịch; không phải realtime.

> Không chạy Airbyte và PeerDB cùng ghi vào một bảng ClickHouse. Airbyte phải sở hữu các bảng direct-load của nó trong database `hms_raw`; không dùng các bảng `raw_*` có metadata `_peerdb_*` của PeerDB.

## 1. Điều kiện trước khi cấu hình

Chuẩn bị các thông tin sau, lưu ở password manager hoặc biến môi trường cục bộ — không commit vào Git:

| Thành phần | Giá trị cần có |
| --- | --- |
| PostgreSQL | host, port, database, user `airbyte_ro`, password, TLS/CA nếu có |
| PostgreSQL schema | `tenant_bvcahn` |
| ClickHouse | host, HTTP port (`8123` hoặc `8443`), database `hms_raw`, user `airbyte_user`, password |
| Airbyte UI | URL và tài khoản lấy từ `abctl local credentials` |

Từ **network của Airbyte** phải kết nối được đến cả PostgreSQL và ClickHouse. Nếu ClickHouse chạy cùng server, dùng IP private/Tailscale của server hoặc một hostname mà container/pod Airbyte truy cập được; không dùng `localhost` của máy chạy trình duyệt.

Kiểm tra Airbyte đã chạy:

```bash
abctl local credentials
kubectl --kubeconfig ~/.airbyte/abctl/abctl.kubeconfig \
  --namespace airbyte-abctl get pods
```

Nếu chưa có domain, truy cập UI qua SSH tunnel:

```bash
ssh -L 8000:127.0.0.1:8000 <user>@<airbyte-server>
```

Mở `http://localhost:8000` trên máy cá nhân.

## 2. Chuẩn bị PostgreSQL (do DBA thực hiện)

Tạo một user chỉ đọc. Ví dụ dưới đây giới hạn quyền đúng vào schema cần nạp; phần `GRANT SELECT` phải chỉ gồm 19 bảng ở mục 5.

```sql
CREATE USER airbyte_ro PASSWORD '<strong-password>';
GRANT CONNECT ON DATABASE <database_name> TO airbyte_ro;
GRANT USAGE ON SCHEMA tenant_bvcahn TO airbyte_ro;
```

Sau đó, DBA cấp `SELECT` cho đúng các bảng đã chọn. Có thể sinh/kiểm tra lệnh từ catalog PostgreSQL trước khi chạy:

```sql
SELECT format(
  'GRANT SELECT ON TABLE tenant_bvcahn.%I TO airbyte_ro;',
  table_name
)
FROM information_schema.tables
WHERE table_schema = 'tenant_bvcahn'
  AND table_name IN (
    'tiep_nhan',
    'benh_nhan_tiep_nhan',
    'benh_nhan_dot_dieu_tri',
    'kb_kham_benh',
    'kb_kham_benh_chuyen_vien',
    'csyt_benh_an_dieu_tri',
    'csyt_phieu_ra_vien',
    'phieu_dich_vu_chi_tiet',
    'csyt_yl_thuocvt',
    'csyt_vien_phi_chung_tu',
    'csyt_vien_phi_chung_tu_chi_tiet',
    'dm_so_thu_hoa_don',
    'dmc_ma_nhom_chi_phi',
    'csyt_xac_nhan_chi_phi',
    'csyt_xac_nhan_chi_phi_vien_phi',
    'dmc_icd10',
    'dm_nhom_icd10',
    'dm_chuong_icd10',
    'dmc_doi_tuong_kcb'
  )
ORDER BY table_name;
```

Không chạy các lệnh sau cho luồng này:

```sql
-- Không dùng cho Airbyte Standard (xmin):
ALTER USER airbyte_ro REPLICATION;
CREATE PUBLICATION ...;
SELECT pg_create_logical_replication_slot(...);
```

Airbyte cần bảng có primary key để chạy **Incremental | Append + Deduped** ở đích ClickHouse. Kiểm tra PK trước khi bật stream:

```sql
SELECT tc.table_name,
       string_agg(kcu.column_name, ', ' ORDER BY kcu.ordinal_position) AS primary_key
FROM information_schema.table_constraints tc
JOIN information_schema.key_column_usage kcu
  ON kcu.constraint_name = tc.constraint_name
 AND kcu.table_schema = tc.table_schema
WHERE tc.table_schema = 'tenant_bvcahn'
  AND tc.constraint_type = 'PRIMARY KEY'
GROUP BY tc.table_name
ORDER BY tc.table_name;
```

## 3. Chuẩn bị ClickHouse (do ClickHouse admin thực hiện)

Tạo database và user riêng. Airbyte cần tạo/sửa/xoá bảng direct-load để xử lý sync và schema evolution; không dùng user `admin` của dashboard.

```sql
CREATE DATABASE IF NOT EXISTS hms_raw;

CREATE USER IF NOT EXISTS airbyte_user
  IDENTIFIED WITH sha256_password BY '<strong-password>';

ALTER USER airbyte_user SETTINGS async_insert = 0;

GRANT CREATE, ALTER, TRUNCATE, INSERT, SELECT, DROP TABLE
ON hms_raw.* TO airbyte_user;
```

Xác nhận từ Airbyte server có thể tới ClickHouse HTTP port `8123` (hoặc HTTPS `8443`). Airbyte ClickHouse destination ghi trực tiếp vào bảng typed và có thể thay đổi schema khi nguồn thay đổi.

## 4. Tạo PostgreSQL source trong Airbyte UI

1. Đăng nhập Airbyte → **Sources** → **New source** → chọn **Postgres**.
2. Điền hostname (không có `http://`), port, database, user `airbyte_ro`, password.
3. Ở **Schemas**, chỉ nhập `tenant_bvcahn`.
4. Dùng SSL `require`, `verify-ca` hoặc `verify-full` nếu PostgreSQL hỗ trợ TLS. Chỉ chọn `disable` khi hai hệ thống nằm trong private network đã được bảo vệ.
5. Ở **Replication method**, chọn **Standard (xmin)**. Không chọn CDC và không điền publication/replication slot.
6. Bấm **Set up source** và chờ connection test thành công.

Nếu discover được 0 bảng, kiểm tra chính xác tên schema, `USAGE` trên schema và `SELECT` trên bảng. Nếu không kết nối được, kiểm tra hostname/port, `listen_addresses`, `pg_hba.conf` và firewall giữa Airbyte với PostgreSQL.

## 5. Tạo ClickHouse destination trong Airbyte UI

1. Vào **Destinations** → **New destination** → chọn **ClickHouse**.
2. Điền:

   | Trường | Giá trị |
   | --- | --- |
   | Host | hostname/IP ClickHouse, không kèm protocol |
   | Port | `8123` với HTTP hoặc `8443` với HTTPS |
   | Protocol | HTTP hoặc HTTPS tương ứng |
   | Database | `hms_raw` |
   | Username | `airbyte_user` |
   | Password | password của `airbyte_user` |
   | Enable JSON | bật nếu ClickHouse hỗ trợ JSON và muốn giữ object fields ở dạng JSON |

3. Bấm **Set up destination**. Nếu lỗi write/check, xác minh quyền user ClickHouse và `async_insert = 0`.

## 6. Tạo connection và chọn các stream

1. Vào **Connections** → **New connection**.
2. Chọn PostgreSQL source và ClickHouse destination vừa tạo.
3. Ở namespace/destination database, giữ đích là `hms_raw`.
4. Chỉ bật 19 stream sau:

   ```text
   tenant_bvcahn.tiep_nhan
   tenant_bvcahn.benh_nhan_tiep_nhan
   tenant_bvcahn.benh_nhan_dot_dieu_tri
   tenant_bvcahn.kb_kham_benh
   tenant_bvcahn.kb_kham_benh_chuyen_vien
   tenant_bvcahn.csyt_benh_an_dieu_tri
   tenant_bvcahn.csyt_phieu_ra_vien
   tenant_bvcahn.phieu_dich_vu_chi_tiet
   tenant_bvcahn.csyt_yl_thuocvt
   tenant_bvcahn.csyt_vien_phi_chung_tu
   tenant_bvcahn.csyt_vien_phi_chung_tu_chi_tiet
   tenant_bvcahn.dm_so_thu_hoa_don
   tenant_bvcahn.dmc_ma_nhom_chi_phi
   tenant_bvcahn.csyt_xac_nhan_chi_phi
   tenant_bvcahn.csyt_xac_nhan_chi_phi_vien_phi
   tenant_bvcahn.dmc_icd10
   tenant_bvcahn.dm_nhom_icd10
   tenant_bvcahn.dm_chuong_icd10
   tenant_bvcahn.dmc_doi_tuong_kcb
   ```

5. Với stream có PK được Airbyte discover đúng, chọn **Incremental | Append + Deduped** và xác nhận PK trong stream configuration. Xmin theo dõi insert/update nên không cần chọn `updated_at` cursor.
6. Nếu bảng không có PK hoặc PK discover không đúng, chưa bật Append + Deduped. Tạm dùng **Full refresh | Overwrite** cho bảng đó, hoặc dừng để DBA xác nhận PK.
7. Ở giai đoạn đầu, chọn lịch **Manual**. Sau initial sync và đối soát xong, mới đặt lịch (ví dụ mỗi 6 giờ hoặc hàng ngày theo tải PostgreSQL).
8. Lưu connection. Airbyte sẽ tự tạo bảng đích; tên bảng thực tế hiển thị trong connection và phải được kiểm tra sau sync — không giả định đó là bảng PeerDB `raw_*`.

## 7. Chạy initial sync và theo dõi

1. Mở connection vừa tạo → bấm **Sync now**.
2. Theo dõi job cho đến trạng thái **Succeeded**; mở log của attempt nếu failed.
3. Không reset connection khi initial sync đang chạy. Nếu job fail, sửa nguyên nhân rồi dùng **Retry**; reset sẽ làm Airbyte quên state và đọc lại dữ liệu.

Kiểm tra các bảng Airbyte đã tạo:

```sql
SELECT database, name, engine, total_rows
FROM system.tables
WHERE database = 'hms_raw'
ORDER BY name;
```

Đối soát từng bảng với PostgreSQL. Thay `<airbyte_table>` bằng tên Airbyte tạo trong `system.tables`:

```sql
-- PostgreSQL
SELECT count(*) FROM tenant_bvcahn.tiep_nhan;

-- ClickHouse
SELECT count() FROM hms_raw.<airbyte_table> FINAL;
```

Với một bảng có PK, kiểm tra dedupe (thay các placeholder):

```sql
SELECT <primary_key>, count()
FROM hms_raw.<airbyte_table> FINAL
GROUP BY <primary_key>
HAVING count() > 1
LIMIT 20;
```

Không có kết quả là mong đợi. `FINAL` quan trọng với bảng dùng `ReplacingMergeTree`, vì dedupe vật lý có thể chưa merge xong.

Kiểm tra thời gian nạp gần nhất bằng cách xem schema bảng trước:

```sql
DESCRIBE TABLE hms_raw.<airbyte_table>;
```

Sau đó truy vấn cột timestamp Airbyte mà connector tạo (thường có tên chứa `airbyte`/`extracted_at`) nếu có. Không hard-code tên metadata trước khi `DESCRIBE`, vì connector version có thể thay đổi output schema.

## 8. Chuyển sang lịch chạy định kỳ

Sau khi các count/Pk đã đối soát:

1. Đặt schedule bảo thủ, bắt đầu từ mỗi 6 giờ hoặc hàng ngày.
2. Theo dõi vài lần chạy đầu trong Airbyte Jobs.
3. Khi có bảng mới hoặc đổi schema, DBA cấp quyền tối thiểu; sau đó refresh source schema và review stream trước khi bật.

Lưu ý schema evolution: ClickHouse destination có thể drop cột lịch sử khi cột đó bị xoá ở nguồn. Review thay đổi schema trước khi sync production.

## 9. Lỗi thường gặp

| Hiện tượng | Kiểm tra/fix |
| --- | --- |
| `Discovered zero tables` | `USAGE` cho `tenant_bvcahn`, `SELECT` cho đúng bảng, schema name chính xác |
| PostgreSQL connection refused | host/port, firewall, `listen_addresses`, `pg_hba.conf`; không dùng hostname chỉ truy cập được từ laptop |
| ClickHouse destination test fail | Airbyte server tới được 8123/8443; đúng protocol; user có quyền tạo/alter/drop/insert/select trên `hms_raw` |
| Duplicate thấy khi query | dùng `FINAL`; kiểm tra PK stream và sync mode là Append + Deduped |
| DELETE ở PostgreSQL vẫn còn ở ClickHouse | đúng giới hạn của Standard (xmin); cần CDC và quyền replication nếu sau này phải đồng bộ delete |
| Initial sync lâu | giữ Manual, chạy ngoài giờ cao điểm; bắt đầu từng nhóm bảng nếu PostgreSQL chịu tải kém |

## 10. Tham khảo chính thức

- [Airbyte Core quickstart và `abctl`](https://docs.airbyte.com/platform/using-airbyte/getting-started/oss-quickstart)
- [Airbyte PostgreSQL source — Standard (xmin), grants và CDC](https://docs.airbyte.com/integrations/sources/postgres)
- [Airbyte ClickHouse destination — network, permissions và deduplication](https://docs.airbyte.com/integrations/destinations/clickhouse)
