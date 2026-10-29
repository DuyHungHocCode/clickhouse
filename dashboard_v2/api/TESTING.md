# Kiểm tra Dashboard HTTP API

Tài liệu này chạy từ máy có thể truy cập cổng HTTP ClickHouse. Mười một
endpoint được expose là:

| Endpoint | Dữ liệu |
| --- | --- |
| `/api/v1/dashboard-summary` | KPI tổng hợp theo ngày |
| `/api/v1/revenue-daily` | Doanh thu theo ngày và nhóm |
| `/api/v1/icd10` | Thống kê ICD-10 (tối đa 10.000 dòng) |
| `/api/v1/visits-daily` | Tiếp nhận, khám và cấp cứu theo ngày |
| `/api/v1/examinations-daily` | Lượt khám theo ngày |
| `/api/v1/inpatient-daily` | Vào viện và ra viện theo ngày |
| `/api/v1/transfers-daily` | Chuyển viện theo ngày |
| `/api/v1/prescriptions-daily` | Đơn thuốc theo ngày |
| `/api/v1/cost-confirmations-daily` | Xác nhận chi phí BHYT và xuất XML theo ngày |
| `/api/v1/gender-daily` | Thống kê giới tính theo ngày |
| `/api/v1/patient-types-daily` | Thống kê đối tượng bệnh nhân theo ngày |

Mỗi endpoint chỉ nhận `GET`, Basic Authentication, và hai query parameter bắt
buộc theo định dạng `YYYY-MM-DD`: `from_date`, `to_date`. Khoảng ngày tối đa
là 366 ngày và `from_date` không được sau `to_date`.

## 1. Khắc phục quyền đang thiếu (chỉ với server đã deploy bản cũ)

Lỗi `dashboard_view_owner ... ct_chi_dinh_dich_vu` là do view KPI tổng hợp đọc
trực tiếp bảng Silver này. Chạy **một lần** bằng tài khoản admin:

```bash
read -rsp 'ClickHouse admin password: ' CLICKHOUSE_PASSWORD; echo

docker compose exec -T clickhouse \
  clickhouse-client \
  --user admin \
  --password "$CLICKHOUSE_PASSWORD" \
  --multiquery <<'SQL'
GRANT SELECT ON hms_silver.ct_chi_dinh_dich_vu TO dashboard_view_owner;
GRANT SELECT ON hms_silver.ct_gioi_tinh_tiep_nhan TO dashboard_view_owner;
GRANT SELECT ON hms_silver.ct_doi_tuong_benh_nhan TO dashboard_view_owner;
GRANT SELECT ON hms_raw.benh_nhan_dot_dieu_tri TO dashboard_view_owner;
GRANT SELECT ON hms_raw.benh_nhan_tiep_nhan TO dashboard_view_owner;
GRANT SELECT ON hms_raw.csyt_benh_an_dieu_tri TO dashboard_view_owner;
GRANT SELECT ON hms_raw.csyt_phieu_ra_vien TO dashboard_view_owner;
GRANT SELECT ON hms_raw.csyt_vien_phi_chung_tu TO dashboard_view_owner;
GRANT SELECT ON hms_raw.csyt_vien_phi_chung_tu_chi_tiet TO dashboard_view_owner;
GRANT SELECT ON hms_raw.csyt_xac_nhan_chi_phi TO dashboard_view_owner;
GRANT SELECT ON hms_raw.csyt_xac_nhan_chi_phi_vien_phi TO dashboard_view_owner;
GRANT SELECT ON hms_raw.csyt_yl_thuocvt TO dashboard_view_owner;
GRANT SELECT ON hms_raw.dm_chuong_icd10 TO dashboard_view_owner;
GRANT SELECT ON hms_raw.dmc_icd10 TO dashboard_view_owner;
GRANT SELECT ON hms_raw.dmc_ma_nhom_chi_phi TO dashboard_view_owner;
GRANT SELECT ON hms_raw.dm_nhom_icd10 TO dashboard_view_owner;
GRANT SELECT ON hms_raw.dm_so_thu_hoa_don TO dashboard_view_owner;
GRANT SELECT ON hms_raw.kb_kham_benh TO dashboard_view_owner;
GRANT SELECT ON hms_raw.kb_kham_benh_chuyen_vien TO dashboard_view_owner;
GRANT SELECT ON hms_raw.phieu_dich_vu_chi_tiet TO dashboard_view_owner;
GRANT SELECT ON hms_raw.tiep_nhan TO dashboard_view_owner;
SQL
```

Batch này chỉ bổ sung quyền còn thiếu; nó không tạo route, API view hay grant
cho `dashboard_api`. Các quyền Raw chỉ thuộc `dashboard_view_owner` với
`HOST NONE`, không thuộc `dashboard_api`; API HTTP vì vậy vẫn chỉ đọc mười một
API view. Bản `api/01-dashboard-api.sql` trong source đã có các quyền này cho
các lần deploy mới.

## 3. Xác minh migration bằng admin

Lệnh này phải chạy không có `ACCESS_DENIED`; nó kiểm tra user, profile, quota,
tất cả views/handlers và đọc thử từng API view.

```bash
docker compose exec -T clickhouse \
  clickhouse-client \
  --user admin \
  --password "$CLICKHOUSE_PASSWORD" \
  --param_from_date=2026-10-01 \
  --param_to_date=2026-10-31 \
  --multiquery < api/02-verify-dashboard-api.sql
```

## 4. Khai báo biến để test HTTP

Thay `CLICKHOUSE_URL` bằng host/port thực tế. Nếu dùng reverse proxy TLS, dùng
`https://...`; nếu gọi trực tiếp HTTP mặc định, dùng `http://host:8123`.

```bash
export CLICKHOUSE_URL='http://127.0.0.1:8123'
export DASHBOARD_API_USER='dashboard_api'
read -rsp 'dashboard_api password: ' DASHBOARD_API_PASSWORD; echo
export DASHBOARD_API_PASSWORD
export FROM_DATE='2026-10-01'
export TO_DATE='2026-10-31'

curl_config="$(mktemp)"
trap 'rm -f "$curl_config"' EXIT
chmod 600 "$curl_config"
printf 'user = "%s:%s"\n' "$DASHBOARD_API_USER" "$DASHBOARD_API_PASSWORD" > "$curl_config"
```

`curl_config` là file tạm, bị xóa khi đóng shell. Không thay nó bằng
`curl -u user:password` nếu đang chạy trên server nhiều người dùng, vì mật khẩu
có thể xuất hiện trong process list.

## 5. Gọi từng API

Kết quả được trả về dưới dạng `JSONEachRow`; `jq -s .` gom các dòng JSON thành
một mảng để dễ đọc. Mảng rỗng là hợp lệ khi khoảng ngày chưa có dữ liệu.

```bash
request_api() {
  curl --config "$curl_config" --fail-with-body --silent --show-error --get \
    --data-urlencode "from_date=$FROM_DATE" \
    --data-urlencode "to_date=$TO_DATE" \
    "$CLICKHOUSE_URL$1" | jq -s .
}

request_api '/api/v1/dashboard-summary'
request_api '/api/v1/revenue-daily'
request_api '/api/v1/icd10'
request_api '/api/v1/visits-daily'
request_api '/api/v1/examinations-daily'
request_api '/api/v1/inpatient-daily'
request_api '/api/v1/transfers-daily'
request_api '/api/v1/prescriptions-daily'
request_api '/api/v1/cost-confirmations-daily'
request_api '/api/v1/gender-daily'
request_api '/api/v1/patient-types-daily'
```

### Test contract cho từng API

Block sau gọi độc lập từng endpoint. Nếu khoảng ngày không có dữ liệu, kết quả
rỗng vẫn là hợp lệ; nếu có dữ liệu, test kiểm tra các field bắt buộc của Gold
mart tương ứng. Chạy block này sau khi đã khai báo biến ở phần **4**.

```bash
set -euo pipefail

test_api() {
  local name="$1" path="$2" schema="$3" body
  body="$(curl --config "$curl_config" --fail-with-body --silent --show-error --get \
    --data-urlencode "from_date=$FROM_DATE" \
    --data-urlencode "to_date=$TO_DATE" \
    "$CLICKHOUSE_URL$path")"

  if test -z "$body"; then
    printf 'PASS: %s (không có dữ liệu trong khoảng ngày)\n' "$name"
    return
  fi

  printf '%s\n' "$body" | jq -s -e "$schema" >/dev/null
  printf 'PASS: %s\n' "$name"
}

test_api 'dashboard-summary' '/api/v1/dashboard-summary' \
  'all(.[]; has("ngay") and has("so_luot_tiep_nhan") and has("so_luot_kham") and has("so_luot_cap_cuu") and has("so_ca_vao_vien") and has("so_ca_ra_vien") and has("so_ca_chuyen_vien") and has("so_don_thuoc") and has("so_chi_dinh_dich_vu") and has("so_xac_nhan_chi_phi_bhyt") and has("so_xuat_xml") and has("tong_doanh_thu_thuan"))'

test_api 'revenue-daily' '/api/v1/revenue-daily' \
  'all(.[]; has("ngay") and has("nhom_doanh_thu") and has("tong_doanh_thu_thuan"))'

test_api 'icd10' '/api/v1/icd10' \
  'all(.[]; has("ngay") and has("ma_chuong_icd10") and has("ten_chuong_icd10") and has("ma_nhom_icd10") and has("ten_nhom_icd10") and has("ma_icd10") and has("ten_benh") and has("loai_thanh_toan") and has("so_ban_ghi") and has("so_luot_kcb") and has("so_benh_nhan"))'

test_api 'visits-daily' '/api/v1/visits-daily' \
  'all(.[]; has("ngay") and has("so_luot_tiep_nhan") and has("so_luot_kham") and has("so_luot_cap_cuu"))'

test_api 'examinations-daily' '/api/v1/examinations-daily' \
  'all(.[]; has("ngay") and has("so_luot_kham"))'

test_api 'inpatient-daily' '/api/v1/inpatient-daily' \
  'all(.[]; has("ngay") and has("so_ca_vao_vien") and has("so_ca_ra_vien"))'

test_api 'transfers-daily' '/api/v1/transfers-daily' \
  'all(.[]; has("ngay") and has("so_ca_chuyen_vien"))'

test_api 'prescriptions-daily' '/api/v1/prescriptions-daily' \
  'all(.[]; has("ngay") and has("so_don_thuoc"))'

test_api 'cost-confirmations-daily' '/api/v1/cost-confirmations-daily' \
  'all(.[]; has("ngay") and has("so_xac_nhan_chi_phi_bhyt") and has("so_xuat_xml"))'

test_api 'gender-daily' '/api/v1/gender-daily' \
  'all(.[]; has("ngay") and has("c_nam") and has("c_nu") and has("c_chua_xac_dinh"))'

test_api 'patient-types-daily' '/api/v1/patient-types-daily' \
  'all(.[]; has("ngay") and has("c_can_bo_cand") and has("c_nguoi_dan"))'
```

Kết quả mong đợi: 11 dòng `PASS`. Một endpoint trả HTTP non-2xx, JSON không
hợp lệ, hoặc thiếu field sẽ dừng block với exit code khác `0`.

## 6. Chạy toàn bộ smoke test

Script có sẵn gọi cả mười một API, kiểm tra JSON, yêu cầu authentication, và xác nhận
`dashboard_api` không thể đọc dữ liệu raw, silver, hoặc Gold không được expose.
Cần có `curl` và `jq`.

```bash
CLICKHOUSE_URL="$CLICKHOUSE_URL" \
DASHBOARD_API_USER="$DASHBOARD_API_USER" \
DASHBOARD_API_PASSWORD="$DASHBOARD_API_PASSWORD" \
FROM_DATE="$FROM_DATE" \
TO_DATE="$TO_DATE" \
api/tests/smoke-dashboard-api.sh
```

Kết quả mong đợi:

```text
PASS: dashboard API smoke test
```

## 7. Kiểm tra các trường hợp bị từ chối

Không gửi credential phải trả HTTP `401` hoặc `403`:

```bash
curl --silent --output /dev/null --write-out '%{http_code}\n' --get \
  --data-urlencode "from_date=$FROM_DATE" \
  --data-urlencode "to_date=$TO_DATE" \
  "$CLICKHOUSE_URL/api/v1/dashboard-summary"
```

Ngày đảo ngược hoặc khoảng ngày trên 366 ngày phải trả lỗi (non-2xx):

```bash
curl --config "$curl_config" --fail-with-body --silent --show-error --get \
  --data-urlencode 'from_date=2026-10-31' \
  --data-urlencode 'to_date=2026-10-01' \
  "$CLICKHOUSE_URL/api/v1/dashboard-summary"
```

Tài khoản API không được phép gửi SQL tùy ý để đọc raw data:

```bash
curl --config "$curl_config" --fail-with-body --silent --show-error --get \
  --data-urlencode 'query=SELECT count() FROM hms_raw.benh_nhan_dot_dieu_tri' \
  "$CLICKHOUSE_URL/"
```

Lệnh cuối phải thất bại và chứa `ACCESS_DENIED`.

## 8. Chẩn đoán khi API lỗi

Kiểm tra handler đã được tạo:

```bash
docker compose exec -T clickhouse \
  clickhouse-client --user admin --password "$CLICKHOUSE_PASSWORD" \
  --query "SELECT name, url, methods FROM system.handlers ORDER BY name"
```

Nếu lỗi chứa `dashboard_view_owner: Not enough privileges`, cấp đúng quyền được
nêu trong lỗi cho `dashboard_view_owner`; không cấp quyền đó cho
`dashboard_api`. Sau đó chạy lại phần **2**. Điều này giữ tài khoản được expose
qua HTTP chỉ có quyền đọc mười một API view.

Khi xong, xóa secret khỏi shell hiện tại:

```bash
unset CLICKHOUSE_PASSWORD DASHBOARD_API_PASSWORD
```
