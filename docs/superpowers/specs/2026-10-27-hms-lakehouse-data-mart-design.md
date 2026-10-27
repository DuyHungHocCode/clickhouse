# Thiết kế Lakehouse Data Mart cho HMS Dashboard

## 1. Mục tiêu

Thiết kế lớp phân tích trên dữ liệu đã có trong ClickHouse, lấy các function nghiệp vụ hiện có làm nguồn sự thật cho KPI. Mục tiêu là:

- Giữ nguyên ý nghĩa KPI hiện tại khi chuyển từ PostgreSQL sang ClickHouse.
- Tách dữ liệu theo grain rõ ràng để tránh đếm trùng do join và do dữ liệu thay đổi.
- Cho phép dashboard truy vấn trực tiếp các mart theo ngày, cơ sở, khoa/phòng và nhóm nghiệp vụ.
- Không đưa thông tin định danh bệnh nhân vào Gold mart.

Phạm vi giai đoạn này là phân tích và thiết kế data mart; chưa thiết kế CDC, API, frontend hoặc cơ chế refresh.

## 2. Kết luận kiến trúc

Nên dùng mô hình Medallion (Bronze–Silver–Gold), nhưng triển khai theo lớp logic trong ClickHouse:

```text
hms_raw.<postgres_table>      Bronze: source-aligned, giữ nguyên dữ liệu
        |
        v
hms_silver.ct_*               Silver: canonical facts theo grain nghiệp vụ, đọc trực tiếp Bronze với FINAL
        |
        v
hms_gold.dm_*                 Gold: aggregate theo ngày phục vụ dashboard
hms_gold.semantic_*           Gold: KPI, tỷ lệ, so sánh kỳ trước
```

Không nên tạo ba bản sao đầy đủ của mọi bảng. `hms_raw` hiện có được xem là Bronze; Silver chỉ chứa các bảng đã chuẩn hóa và cần cho phân tích; Gold chỉ chứa các mart và view phục vụ KPI.

Nếu sau này cần lakehouse đúng nghĩa trên object storage, Bronze có thể đẩy sang Parquet/Iceberg, nhưng mô hình phân lớp và grain dưới đây không thay đổi.

## 3. Đánh giá function nghiệp vụ hiện tại

Các function trong `dashboard_v2/docs/function.md` cho thấy bốn nhóm logic chính.

### 3.1. Lượt tiếp nhận và khám

Nguồn chính là `tiep_nhan`, với các mốc `ngay_tiep_nhan` và khóa `id`.

- `fn_dashboard_tiep_nhan`: đếm bản ghi theo `ngay_tiep_nhan`.
- `fn_dashboard_kham_benh`: đếm lượt khám theo ngày khám.
- `fn_dashboard_cap_cuu`: đếm distinct `tiep_nhan.id`, với điều kiện `ma_ly_do_tiep_nhan = '02'` hoặc có bản ghi nội trú liên quan với `ma_doi_tuong_lt = '2'`.
- `fn_dashboard_chuyen_vien`: đếm bản ghi `kb_kham_benh_chuyen_vien` theo `ngay_lap`.

Điểm quan trọng: cấp cứu không được đếm trực tiếp từ bảng chi tiết nội trú; phải tạo cờ cấp cứu ở grain lượt tiếp nhận rồi mới aggregate.

### 3.2. Nội trú

Các function dùng `csyt_benh_an_dieu_tri` cho vào viện và `csyt_phieu_ra_vien` cho ra viện. `benh_nhan_dot_dieu_tri` là bảng liên kết cần dùng để nối lượt tiếp nhận với đợt điều trị và xác định điều kiện cấp cứu.

Silver cần có một dòng cho mỗi đợt điều trị nội trú, gồm tối thiểu:

- khóa đợt điều trị và khóa lượt tiếp nhận;
- thời điểm vào viện, ra viện;
- trạng thái xác nhận;
- lý do/kết quả ra viện, gồm chuyển viện và tử vong;
- tổng ngày điều trị;
- cơ sở và khoa/phòng nếu có trong nguồn.

Không tính “bệnh nhân nội trú” bằng cách cộng số lượt vào viện và số lượt ra viện. KPI này phải được tính bằng số admission overlap với khoảng lọc.

### 3.3. Đơn thuốc và chỉ định dịch vụ

- `fn_dashboard_don_thuoc` đếm distinct cặp `(khambenh_id, mauhososohoa_id)` từ `csyt_yl_thuocvt` theo `ngay_chidinh`.
- `fn_dashboard_chi_dinh_dich_vu` đếm bảng `phieu_dich_vu_chi_tiet` theo `ngay_chi_dinh`, có loại trừ bản ghi xóa nếu bảng có `bi_xoa`.

Do đó, grain của đơn thuốc không phải một dòng thuốc. Silver phải tạo `ct_don_thuoc` ở grain một đơn thuốc, sau đó Gold mới đếm đơn.

### 3.4. Doanh thu

`fn_dashboard_doanh_thu_nguon_thu` join:

```text
csyt_vien_phi_chung_tu
  -> dm_so_thu_hoa_don
  -> csyt_vien_phi_chung_tu_chi_tiet
  -> dmc_ma_nhom_chi_phi
```

Điều kiện nghiệp vụ:

- `da_thanh_toan = 1`;
- `hoan_tra = 0`;
- `huy_hoa_don = 0`;
- `dm_so_thu_hoa_don.ma_loai_so = 'SBL'`;
- thời gian lọc theo `csyt_vien_phi_chung_tu.ngay_thu`;
- doanh thu bằng `thanh_tien_benh_nhan_cung_chi_tra + thanh_tien_benh_nhan_tu_thanh_toan`;
- nhóm không map được dùng nhãn `20. Khác`.

Doanh thu phải được chuẩn hóa ở grain một dòng chi tiết đã thu tiền. Không join trực tiếp fact lượt khám với fact doanh thu trong Gold, vì sẽ nhân bản số tiền.

## 4. Phân lớp dữ liệu

### 4.1. Bronze — `hms_raw`

Bronze giữ dữ liệu gần nguồn nhất:

- `tiep_nhan`
- `benh_nhan_tiep_nhan`
- `benh_nhan_dot_dieu_tri`
- `kb_kham_benh`
- `kb_kham_benh_chuyen_vien`
- `csyt_benh_an_dieu_tri`
- `csyt_phieu_ra_vien`
- `phieu_dich_vu_chi_tiet`
- `csyt_yl_thuocvt`
- `csyt_vien_phi_chung_tu`
- `csyt_vien_phi_chung_tu_chi_tiet`
- `dm_so_thu_hoa_don`
- `dmc_ma_nhom_chi_phi`
- các bảng danh mục và xác nhận chi phí còn lại.

Bronze không chứa business rule. Chỉ cho phép chuẩn hóa tối thiểu về tên database, quyền truy cập và kiểu đọc. Không query dashboard trực tiếp từ Bronze.

### 4.2. Silver — `hms_silver`

Silver chỉ gồm canonical facts. Các fact đọc trực tiếp bảng Bronze với `FINAL`; không tạo thêm view `v_*_latest` vì hiện tại không có nhu cầu biến đổi cấu trúc nguồn.

#### Canonical facts

| Bảng | Grain | Nguồn chính | Vai trò |
|---|---|---|---|
| `ct_luot_kham` | 1 lượt tiếp nhận/khám | `tiep_nhan`, `kb_kham_benh`, `benh_nhan_tiep_nhan` | OPD, cấp cứu, xu hướng khám |
| `ct_dot_noi_tru` | 1 đợt điều trị | `benh_nhan_dot_dieu_tri`, `csyt_benh_an_dieu_tri`, `csyt_phieu_ra_vien` | vào/ra viện, overlap, LOS |
| `ct_don_thuoc` | 1 đơn thuốc | `csyt_yl_thuocvt` | đếm đơn và phân tích đơn |
| `ct_chi_dinh_dich_vu` | 1 dòng chỉ định | `phieu_dich_vu_chi_tiet` | số chỉ định |
| `ct_dong_doanh_thu` | 1 dòng doanh thu đã thu | 4 bảng doanh thu và danh mục | doanh thu theo ngày/nguồn thu |
| `ct_ngay_giuong` | 1 ngày × cơ sở × khoa × giường | bảng phân giường và kế hoạch giường | công suất giường |

Trong bản triển khai đầu tiên, `ct_dot_noi_tru` được dựng từ hai event source `csyt_benh_an_dieu_tri` và `csyt_phieu_ra_vien`, sau đó gom về một dòng theo `benh_nhan_dot_dieu_tri_id` (fallback về `id`). Nếu dữ liệu thực tế có khóa episode khác, phải đổi mapping trước khi dùng KPI overlap.

Các fact phải mang các khóa phân tích đã chuẩn hóa: `ngay`, `ma_co_so`, `ma_khoa_phong`, `doi_tuong`, `gioi_tinh`, `nhom_tuoi` và `nhom_doanh_thu` nếu nguồn có thể xác định.

### 4.3. Gold — `hms_gold`

Gold là lớp dữ liệu ổn định cho dashboard, không phải nơi chứa logic join phức tạp.

| Mart | Grain đề xuất | Measures chính |
|---|---|---|
| `dm_luot_kham_ngay` | ngày × cơ sở × khoa × đối tượng × giới tính × nhóm tuổi × loại tiếp nhận | lượt ngoại trú, cấp cứu, nhập viện, ra viện, chuyển viện, tử vong, ngày điều trị |
| `dm_cong_suat_giuong_ngay` | ngày × cơ sở × khoa | ngày giường sử dụng, ngày giường kế hoạch |
| `dm_don_thuoc_ngay` | ngày × cơ sở × khoa × đối tượng | số đơn thuốc |
| `dm_doanh_thu_ngay` | ngày × cơ sở × khoa × nhóm doanh thu | doanh thu thuần |
| `dm_noi_tru_ngay` | ngày | số ca vào viện, số ca ra viện |
| `semantic_dashboard_summary` | một dòng cho khoảng lọc | KPI hiện tại, kỳ trước, tỷ lệ thay đổi |

`semantic_dashboard_summary` nên là view/query parameterized ở lớp phục vụ, không nhất thiết là bảng vật lý. Công thức so sánh kỳ trước dùng cùng số ngày; công suất giường dùng percentage point thay vì phần trăm thay đổi.

## 5. Mapping KPI từ function sang mart

| KPI hiện tại | Logic giữ nguyên | Nơi phục vụ mới |
|---|---|---|
| Tiếp nhận | count lượt theo `ngay_tiep_nhan` | `dm_luot_kham_ngay` |
| Khám bệnh | count lượt khám theo ngày khám | `dm_luot_kham_ngay` |
| Cấp cứu | distinct lượt tiếp nhận + điều kiện mã cấp cứu/nội trú | `ct_luot_kham.is_cap_cuu`, rồi `dm_luot_kham_ngay` |
| Vào viện | count admission theo `ngay_vao_vien` | `dm_luot_kham_ngay` |
| Ra viện | count discharge theo `ngay_ra_vien` | `dm_luot_kham_ngay` |
| Chuyển viện | discharge disposition chuyển viện | `dm_luot_kham_ngay` |
| Tử vong nội trú | discharge disposition tử vong | `dm_luot_kham_ngay` |
| Đơn thuốc | distinct `(khambenh_id, mauhososohoa_id)` | `dm_don_thuoc_ngay` |
| Chỉ định dịch vụ | count dòng theo `ngay_chi_dinh` | `dm_luot_kham_ngay` hoặc mart riêng |
| Doanh thu | tiền bệnh nhân đã thanh toán, chưa hoàn/hủy, loại sổ `SBL` | `dm_doanh_thu_ngay` |

## 6. Các điểm cần chốt trước khi viết SQL

Tài liệu function đủ để chốt business rule, nhưng chưa đủ để viết SQL ClickHouse an toàn. Cần lấy schema thực tế từ ClickHouse cho các bảng sau:

1. Khóa chính và cột thời gian của `hms_raw.tiep_nhan`, `hms_raw.kb_kham_benh`, `hms_raw.benh_nhan_dot_dieu_tri`.
2. Cột nối và trạng thái của `hms_raw.csyt_benh_an_dieu_tri`, `hms_raw.csyt_phieu_ra_vien`.
3. Cột chứa mã khoa/phòng, cơ sở, đối tượng và giới tính.
4. Cột xác định trạng thái bản ghi hiện hành/xóa và thứ tự phiên bản.
5. Cột nhóm tuổi hoặc ngày sinh; nếu chỉ có ngày sinh thì nhóm tuổi phải tính tại ngày khám.
6. Cột loại giường và số giường kế hoạch trong các bảng phân giường/kế hoạch giường. Hiện danh sách raw đang có chưa thấy rõ hai bảng này.
7. Kiểu dữ liệu thực tế của các cờ `da_thanh_toan`, `hoan_tra`, `huy_hoa_don`, `bi_xoa`.

Không nên đoán tên cột từ function PostgreSQL rồi triển khai thẳng trên ClickHouse; thay vào đó dùng `DESCRIBE TABLE` và lập mapping nguồn → Silver trước.

## 7. Thứ tự triển khai đề xuất

1. Xuất catalog `DESCRIBE TABLE` và số dòng của các raw table liên quan.
2. Lập bảng mapping khóa, thời gian, trạng thái và foreign key.
3. Tạo `ct_luot_kham`, `ct_dot_noi_tru`, `ct_don_thuoc`, `ct_chi_dinh_dich_vu`, `ct_dong_doanh_thu` đọc trực tiếp Bronze.
5. Đối soát từng fact với kết quả function PostgreSQL trên cùng một khoảng ngày.
6. Tạo `dm_luot_kham_ngay`, `dm_noi_tru_ngay` và `dm_doanh_thu_ngay` trước; đây là các mart có giá trị dashboard cao nhất.
7. Bổ sung giường sau khi xác nhận đủ bảng nguồn; không tạo mart công suất từ dữ liệu thiếu mẫu số.
8. Tạo semantic views cho summary, kỳ trước và các biểu đồ.

## 8. Nguyên tắc kiểm thử và đối soát

- Mỗi fact phải có kiểm tra uniqueness đúng grain.
- Mọi phép đếm có join phải kiểm tra trước/sau join để phát hiện nhân bản.
- Doanh thu phải đối soát tổng tiền và số dòng theo từng ngày, sau đó theo nhóm doanh thu.
- Cấp cứu phải đối soát distinct lượt tiếp nhận, không đối soát số dòng chi tiết.
- Công suất giường phải tính `sum(ngày sử dụng) / sum(ngày kế hoạch)`, không cộng hoặc trung bình các tỷ lệ.
- Khoảng ngày dùng dạng nửa mở: `>= from_date` và `< to_date + 1 day`.
- Không đưa tên, số điện thoại, địa chỉ hoặc định danh bệnh nhân vào Gold.

## 9. Kết luận

Bronze–Silver–Gold là lựa chọn phù hợp, với một điều chỉnh quan trọng: đây là phân lớp logic trong ClickHouse, không phải yêu cầu nhân ba dữ liệu vật lý. Raw hiện có là Bronze; Silver phải giải quyết current-state, chuẩn hóa và grain nghiệp vụ; Gold chỉ chứa mart phục vụ KPI. Các function hiện tại nên được dùng làm oracle để đối soát, không nên giữ nguyên kiểu query động trên bảng nguồn làm lớp phục vụ dashboard.
