# HMS ClickHouse Data Mart

## Mục đích

Thư mục này triển khai lớp phân tích theo mô hình Bronze–Silver–Gold trên các bảng raw đã có trong `hms_raw`. Raw giữ tên bảng tương ứng PostgreSQL, không có tiền tố `raw_`; các cột nghiệp vụ giữ nguyên tên PostgreSQL. Cột do Airbyte tạo không được dùng trong business logic.

## Thứ tự chạy

```bash
clickhouse-client --user admin --password "$CLICKHOUSE_PASSWORD" --multiquery \
  < dashboard_v2/mart/00-databases.sql

clickhouse-client --user admin --password "$CLICKHOUSE_PASSWORD" --multiquery \
  < dashboard_v2/mart/02-silver-canonical-facts.sql

clickhouse-client --user admin --password "$CLICKHOUSE_PASSWORD" --multiquery \
  < dashboard_v2/mart/03-gold-daily-marts.sql
```

Sau đó chạy `04-validation.sql` với ngày đối soát thực tế.

## Các lớp

- Bronze: `hms_raw.<postgres_table>`, không sửa và không query dashboard trực tiếp.
- Silver canonical facts: `ct_luot_kham`, `ct_kham_benh`, `ct_dot_noi_tru`, `ct_chuyen_vien`, `ct_don_thuoc`, `ct_chi_dinh_dich_vu`, `ct_xac_nhan_chi_phi`, `ct_gioi_tinh_tiep_nhan`, `ct_doi_tuong_benh_nhan`, `ct_dong_doanh_thu`, `ct_icd10`; các fact đọc trực tiếp `hms_raw.<postgres_table> FINAL`.
- Gold: `dm_luot_kham_ngay`, `dm_kham_benh_ngay`, `dm_noi_tru_ngay`, `dm_chuyen_vien_ngay`, `dm_don_thuoc_ngay`, `dm_xac_nhan_chi_phi_ngay`, `dm_gioi_tinh_ngay`, `dm_doi_tuong_benh_nhan_ngay`, `dm_doanh_thu_ngay`, `dm_icd10`, `dm_dashboard_ngay`.

## Quy tắc giữ nguyên từ function PostgreSQL

- Cấp cứu: `ma_ly_do_tiep_nhan = '02'` hoặc có đợt điều trị với `ma_doi_tuong_lt = '2'`.
- Đơn thuốc: distinct `(khambenh_id, mauhososohoa_id)`.
- Doanh thu: đã thanh toán, không hoàn trả, không hủy hóa đơn, loại sổ `SBL`.
- Doanh thu: tiền cùng chi trả cộng tiền bệnh nhân tự thanh toán.
- Khoảng ngày: nửa mở, từ ngày bao gồm và ngày kết thúc loại trừ sau `to_date`.
- `dm_dashboard_ngay` là semantic mart đối soát `fn_dashboard_summary`; dashboard tự chọn current/previous period từ mart này.

## Bed capacity

Chưa tạo `dm_cong_suat_giuong_ngay` trong SQL chạy được vì danh sách raw hiện có chưa xác định bảng phân giường và bảng kế hoạch giường. Khi có đúng hai bảng và cột nối, mart phải có grain `ngày × cơ sở × khoa`, gồm `tong_ngay_giuong_su_dung` và `tong_ngay_giuong_ke_hoach`; công suất là tổng tử số chia tổng mẫu số.

## Tối ưu sau đối soát

Các view được chọn trước để dễ kiểm tra parity. Chỉ chuyển sang bảng `MergeTree` hoặc materialized view sau khi đối soát từng ngày với các function PostgreSQL và kiểm tra không nhân bản fact.
