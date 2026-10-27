# Thiết kế data mart — HMS dashboard

## Mục tiêu

Phục vụ dashboard trong `docs/metric.md`: 8 KPI tổng quan, biểu đồ xu hướng, công suất giường, cơ cấu lượt khám, đơn thuốc, doanh thu và cảnh báo. Thiết kế ưu tiên số liệu đúng khi trạng thái HMS bị UPDATE/DELETE.

```text
PostgreSQL CDC → raw_* → v_*_moi_nhat → ct_* → dm_* → dashboard
```

- `raw_*`: bảng CDC do PeerDB ghi; có `_peerdb_version`, `_peerdb_is_deleted`.
- `v_*_moi_nhat`: view đọc `FINAL` và lọc `_peerdb_is_deleted = 0`.
- `ct_*`: một bản ghi nghiệp vụ ở trạng thái mới nhất.
- `dm_*`: data mart aggregate theo ngày, phục vụ filter và biểu đồ.

Không aggregate trực tiếp từ `raw_*`: một UPDATE được CDC biểu diễn bằng version mới, nên dễ count/sum trùng.

## Dimensions dùng chung

| Dimension | Key | Thuộc tính dashboard |
|---|---|---|
| `d_ngay` | `ngay` | ngày, tháng, quý, năm, số ngày trong tháng |
| `d_co_so` | `ma_co_so` | cơ sở |
| `d_khoa_phong` | `ma_khoa_phong` | khoa/phòng, cơ sở |
| `d_doi_tuong` | `doi_tuong` | BHYT, dịch vụ, yêu cầu, khám sức khỏe, khác |
| `d_nhom_nguoi_benh` | encounter-level | giới tính, nhóm tuổi tại ngày khám |
| `d_nhom_doanh_thu` | `nhom_doanh_thu` | khám, giường, xét nghiệm, CĐHA, thủ thuật, thuốc, vật tư |

Không đưa tên, số điện thoại, địa chỉ hoặc định danh bệnh nhân vào mart dashboard.

## Canonical facts

| Fact | Grain | Nguồn HMS tối thiểu | Dùng cho |
|---|---|---|---|
| `ct_luot_kham` | 1 lượt tiếp nhận/khám | `encounter`, patient, khoa, cơ sở | OPD, ED, cơ cấu lượt khám, xu hướng |
| `ct_dot_noi_tru` | 1 đợt điều trị nội trú | `admission`, encounter | nội trú, ra viện, chuyển viện, tử vong, LOS |
| `ct_ngay_giuong` | ngày × khoa × cơ sở | bed assignment, giường kế hoạch | công suất giường |
| `ct_don_thuoc` | 1 đơn thuốc | prescription, encounter | phân tích đơn thuốc |
| `ct_dong_doanh_thu` | 1 dòng doanh thu | billing item, encounter | doanh thu tài chính, nguồn thu |

`fact_bed_day` tách một khoảng nằm viện qua từng ngày. Ví dụ nằm từ 23:00 ngày 01 đến 02:00 ngày 03 tạo bed-day cho ngày 01, 02, 03; occupancy luôn tính từ tổng tử số/mẫu số, không cộng hay trung bình tỷ lệ.

## Data marts

### 1. `dm_luot_kham_ngay`

**Grain:** `ngay × ma_co_so × ma_khoa_phong × doi_tuong × gioi_tinh × nhom_tuoi × loai_tiep_nhan`.

| Measure | Quy tắc |
|---|---|
| `so_luot_ngoai_tru` | `OPD`, không `WAITING`/`CANCELLED` |
| `so_luot_cap_cuu` | `ED`, không `WAITING`/`CANCELLED` |
| `so_ca_nhap_vien` | admission xác nhận vào khoa |
| `so_ca_ra_vien` | ra viện trong ngày |
| `so_ca_chuyen_vien` | discharge disposition = `TRANSFER` |
| `so_ca_tu_vong_noi_tru` | discharge disposition = `DEATH` |
| `tong_ngay_dieu_tri` | tổng số ngày điều trị của ca ra viện |

### 2. `dm_cong_suat_giuong_ngay`

**Grain:** `ngay × ma_co_so × ma_khoa_phong`.

| Measure | Quy tắc |
|---|---|
| `tong_ngay_giuong_su_dung` | tổng thời gian sử dụng giường quy đổi ngày |
| `tong_ngay_giuong_ke_hoach` | giường kế hoạch × số ngày trong kỳ |
| `so_giuong_dang_dung` | số giường đang dùng tại thời điểm refresh |
| `so_giuong_con_trong` | giường kế hoạch trừ số đang dùng |

```text
cong_suat_giuong = sum(tong_ngay_giuong_su_dung) / nullIf(sum(tong_ngay_giuong_ke_hoach), 0)
```

Mart này không nhận filter giới tính, tuổi hoặc đối tượng vì các filter đó làm sai mẫu số giường kế hoạch.

### 3. `dm_don_thuoc_ngay`

**Grain:** `ngay_ke_don × ma_co_so × ma_khoa_phong × doi_tuong × gioi_tinh × nhom_tuoi × nhom_gia_tri_don`.

| Measure | Quy tắc |
|---|---|
| `so_don` | đơn `ISSUED`/`DISPENSED`, loại `CANCELLED` |
| `tong_tien_don` | tổng tiền đơn |
| `nhom_gia_tri_don` | `DEN_500K` nếu ≤ 500.000; `TREN_500K` nếu > 500.000 |

### 4. `dm_doanh_thu_ngay`

**Grain:** `ngay_ghi_nhan × ma_co_so × ma_khoa_phong × doi_tuong × gioi_tinh × nhom_tuoi × nhom_doanh_thu`.

| Measure | Quy tắc |
|---|---|
| `so_dong_doanh_thu` | số billing item hợp lệ |
| `tong_tien_goc` | tổng amount POSTED trước reversal |
| `tong_tien_dieu_chinh` | amount reversal/VOID hợp lệ |
| `tong_doanh_thu_thuan` | `tong_tien_goc - tong_tien_dieu_chinh` |

Dashboard mặc định dùng `net_amount` của doanh thu đã ghi nhận (`POSTED`), không phải tiền thực thu.

## Mapping KPI dashboard

| KPI | Mart/fact | Công thức |
|---|---|---|
| Lượt khám | `dm_luot_kham_ngay` | `sum(so_luot_ngoai_tru)` |
| Bệnh nhân nội trú | `ct_dot_noi_tru` | count admission overlap kỳ, loại chờ xác nhận |
| Cấp cứu | `dm_luot_kham_ngay` | `sum(so_luot_cap_cuu)` |
| Chuyển viện | `dm_luot_kham_ngay` | `sum(so_ca_chuyen_vien)` |
| Công suất giường | `dm_cong_suat_giuong_ngay` | `sum(tong_ngay_giuong_su_dung) / sum(tong_ngay_giuong_ke_hoach)` |
| Ngày điều trị TB | `dm_luot_kham_ngay` | `sum(tong_ngay_dieu_tri) / sum(so_ca_ra_vien)` |
| Tử vong nội trú | `dm_luot_kham_ngay` | `sum(so_ca_tu_vong_noi_tru)` |
| Doanh thu tài chính | `dm_doanh_thu_ngay` | `sum(tong_doanh_thu_thuan)` |

## So sánh kỳ trước

Với `[from_date, to_date]`, kỳ trước là khoảng liền trước có cùng số ngày:

```text
previous_to   = from_date - 1 day
previous_from = previous_to - (to_date - from_date)
change_pct    = (current - previous) / nullIf(previous, 0)
```

Với công suất giường, hiển thị thay đổi bằng **percentage point**, không dùng `change_pct`.

## Thứ tự triển khai ngắn nhất

1. `hms_raw.tiep_nhan`, `hms_raw.benh_nhan_dot_dieu_tri`, `hms_raw.csyt_benh_an_dieu_tri`, `hms_raw.csyt_phieu_ra_vien`, `hms_raw.csyt_yl_thuocvt`, `hms_raw.csyt_vien_phi_chung_tu` và các bảng chi tiết liên quan.
2. `v_*_moi_nhat` và kiểm chứng UPDATE/DELETE không trùng số liệu.
3. `ct_luot_kham`, `ct_dot_noi_tru`, `ct_ngay_giuong`, `ct_don_thuoc`, `ct_dong_doanh_thu`.
4. Bốn `dm_*_ngay` ở trên.
5. Semantic views cho từng KPI/chart, rồi mới kết nối dashboard.

## Giả định cần xác nhận trước báo cáo chính thức

- Nội trú trong kỳ là admission episode hay unique patient.
- Ngày điều trị theo calendar-day, midnight census hay quy định BHYT.
- Doanh thu là ghi nhận, hóa đơn hay thực thu.
- Khoa của doanh thu là khoa khám, khoa thực hiện dịch vụ hay khoa ra viện.
