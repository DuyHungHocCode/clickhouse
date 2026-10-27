# Phân tích function PostgreSQL và ý nghĩa các lớp Silver/Gold

## 1. Mục đích tài liệu

Tài liệu này giải thích logic nghiệp vụ trong các function PostgreSQL tại `dashboard_v2/docs/function.md` và cách chuyển logic đó thành các bảng phân tích ClickHouse.

Phạm vi hiện tại:

- Bronze: các bảng nguồn trong `hms_raw`, giữ tên tương ứng PostgreSQL.
- Silver: các canonical fact `hms_silver.ct_*`.
- Gold: các data mart tổng hợp `hms_gold.dm_*`.

Nguyên tắc quan trọng: function PostgreSQL là chuẩn nghiệp vụ để đối soát; Silver là nơi chuẩn hóa grain và điều kiện; Gold là nơi tổng hợp cho dashboard.

## 2. Quy ước thời gian chung

Các function nhận khoảng ngày `[p_tu_ngay, p_den_ngay]` và dùng điều kiện:

```sql
date_column >= p_tu_ngay::timestamp
AND date_column < (p_den_ngay + 1)::timestamp
```

Đây là khoảng nửa mở. Ngày bắt đầu được tính, toàn bộ ngày kết thúc được tính, và thời điểm từ 00:00 ngày kế tiếp bị loại trừ.

Khi chuyển sang ClickHouse, giữ nguyên quy tắc:

```sql
ngay >= from_date
AND ngay < to_date + 1
```

Không dùng `BETWEEN` với timestamp vì dễ bỏ sót dữ liệu trong ngày kết thúc.

## 3. Nhóm function dùng chung

### 3.1. `fn_dashboard_count_base`

Đây là helper động nhận tên bảng, tên cột ngày, ngày bắt đầu và ngày kết thúc.

Logic:

1. Kiểm tra bảng có cột `bi_xoa` hay không.
2. Đếm bản ghi theo khoảng ngày nửa mở.
3. Nếu có `bi_xoa`, chỉ giữ bản ghi chưa xóa: `0`, `false` hoặc `f`.
4. Có một số ngoại lệ riêng cho bảng chi tiết dịch vụ.

Ý nghĩa: hệ thống cũ không giả định mọi bảng đều có cùng cơ chế xóa mềm.

Trong ClickHouse, logic này không nên tiếp tục tồn tại dưới dạng SQL động. Mỗi canonical fact phải ghi rõ nguồn, cột ngày, điều kiện xóa và khóa nghiệp vụ.

### 3.2. `fn_dashboard_summary`

Function này gọi toàn bộ KPI chính cho kỳ hiện tại và kỳ trước:

- tiếp nhận, cấp cứu, khám bệnh;
- vào viện, ra viện, chuyển viện;
- đơn thuốc, chỉ định dịch vụ;
- xác nhận chi phí BHYT, xuất XML;
- doanh thu.

Kỳ trước chỉ được tính tự động khi `p_tu_ngay = p_den_ngay`, tức chủ yếu phục vụ so sánh ngày hôm nay với ngày liền trước. Với khoảng nhiều ngày, lớp dashboard nên tự tính kỳ trước cùng số ngày.

## 4. Phân tích từng function nghiệp vụ

### 4.1. Tiếp nhận và khám bệnh

| Function | Nguồn | Logic | Ý nghĩa |
|---|---|---|---|
| `fn_dashboard_tiep_nhan` | `tiep_nhan` | Đếm theo `ngay_tiep_nhan` | Số lượt tiếp nhận vào hệ thống |
| `fn_dashboard_kham_benh` | `kb_kham_benh` | Đếm lượt khám theo ngày khám | Số lượt thực sự phát sinh hoạt động khám |
| `fn_dashboard_thong_ke_ngay` | function khám bệnh | Gọi `fn_dashboard_kham_benh(p_ngay,p_ngay)` | KPI nhanh cho một ngày |

`tiếp nhận` và `khám bệnh` không đồng nghĩa: một lượt có thể được tiếp nhận nhưng chưa phát sinh khám, và một lượt có thể có nhiều bản ghi chi tiết khám. Dashboard phải chọn đúng mẫu số tùy KPI.

Silver hiện tại: `hms_silver.ct_luot_kham`.

Gold hiện tại: `hms_gold.dm_luot_kham_ngay` với `so_luot_tiep_nhan`, `so_luot_kham`, `so_luot_cap_cuu`.

Lưu ý: Gold hiện nhóm theo ngày tiếp nhận. Nếu cần parity tuyệt đối với function khám bệnh theo ngày khám, cần bổ sung `ngay_kham` vào `ct_luot_kham` và tạo mart theo ngày khám.

### 4.2. Cấp cứu — `fn_dashboard_cap_cuu`

Logic:

```sql
count(DISTINCT tn.id)
FROM tiep_nhan tn
WHERE tn.ngay_tiep_nhan trong khoảng lọc
  AND (
    tn.ma_ly_do_tiep_nhan = '02'
    OR EXISTS (
      SELECT 1
      FROM benh_nhan_dot_dieu_tri bnddt
      WHERE bnddt.tiep_nhan_id = tn.id
        AND bnddt.ma_doi_tuong_lt = '2'
    )
  )
```

Một lượt tiếp nhận chỉ được tính một lần. Có hai cách nhận diện cấp cứu: mã lý do tiếp nhận hoặc mã đối tượng điều trị. Không được đếm trực tiếp số dòng `benh_nhan_dot_dieu_tri` vì một lượt có thể có nhiều dòng liên quan.

Silver hiện thực cờ `is_cap_cuu` ở grain lượt tiếp nhận. Gold cộng cờ này thành `so_luot_cap_cuu`.

### 4.3. Vào viện — `fn_dashboard_vao_vien`

Nguồn: `csyt_benh_an_dieu_tri`.

Logic: đếm bản ghi theo `ngay_vao_vien`, có áp dụng helper `fn_dashboard_count_base` và lọc xóa mềm nếu bảng có `bi_xoa`.

Ý nghĩa: số ca nhập viện trong ngày, không phải số bệnh nhân duy nhất trong kỳ dài.

Silver: `ct_dot_noi_tru` lấy event vào viện từ `csyt_benh_an_dieu_tri`.

Gold: `dm_noi_tru_ngay.so_ca_vao_vien`.

### 4.4. Ra viện — `fn_dashboard_ra_vien`

Nguồn: `csyt_phieu_ra_vien`.

Logic: đếm theo `thoi_gian_ra_vien` trong khoảng lọc.

Ý nghĩa: số hồ sơ ra viện trong ngày. Cần kiểm tra bản ghi cấp lại/hủy nếu nghiệp vụ thực tế có thể tạo nhiều phiếu cho cùng một bệnh án.

Silver: `ct_dot_noi_tru` nối `csyt_phieu_ra_vien.benh_an_id` với `csyt_benh_an_dieu_tri.id`.

Gold: `dm_noi_tru_ngay.so_ca_ra_vien`.

### 4.5. Chuyển viện — `fn_dashboard_chuyen_vien`

Nguồn: `kb_kham_benh_chuyen_vien`.

Logic: đếm theo `ngay_lap`.

Ý nghĩa: số hồ sơ/y lệnh chuyển viện được lập trong kỳ, không nhất thiết là số ca ra viện có disposition chuyển viện.

Đây là khác biệt cần giữ rõ: function hiện tại đếm hoạt động lập hồ sơ chuyển viện; KPI nội trú chuẩn có thể muốn đếm ca ra viện với kết quả chuyển viện. Hai KPI này không được tự động gộp.

### 4.6. Đơn thuốc — `fn_dashboard_don_thuoc`

Nguồn: `csyt_yl_thuocvt`.

Logic:

```sql
count(DISTINCT (khambenh_id, mauhososohoa_id))
WHERE ngay_chidinh trong khoảng lọc
```

Ý nghĩa: một đơn thuốc được nhận diện bằng cặp khóa khám bệnh và hồ sơ số hóa, không phải một dòng thuốc.

Silver: `ct_don_thuoc` gom các dòng thuốc về một dòng theo `(khambenh_id, mauhososohoa_id)` và giữ `so_dong_thuoc` để phân tích chi tiết.

Gold: `dm_don_thuoc_ngay` đếm số dòng Silver theo `ngay_don_thuoc`.

### 4.7. Chỉ định dịch vụ — `fn_dashboard_chi_dinh_dich_vu`

Nguồn: `phieu_dich_vu_chi_tiet`.

Logic: đếm theo `ngay_chi_dinh`, lọc `bi_xoa` nếu bảng có cột này.

Ý nghĩa: số dòng chỉ định dịch vụ, không phải số lượt bệnh nhân và không phải số phiếu chỉ định cấp cao.

Silver: `ct_chi_dinh_dich_vu`, một dòng cho một `id` chi tiết chỉ định.

Gold: `dm_dashboard_ngay.so_chi_dinh_dich_vu` tổng hợp theo ngày từ fact này. Có thể tách `dm_chi_dinh_dich_vu_ngay` riêng khi cần drill-down.

### 4.8. Xác nhận chi phí BHYT — `fn_dashboard_xac_nhan_chi_phi_bhyt`

Nguồn: `csyt_xac_nhan_chi_phi`.

Logic: đếm theo `ngay_xac_nhan`, có lọc xóa mềm tùy schema.

Ý nghĩa: số bản ghi xác nhận chi phí BHYT trong kỳ, không phải số tiền BHYT.

Silver: `ct_xac_nhan_chi_phi`. Gold: `dm_xac_nhan_chi_phi_ngay.so_xac_nhan_chi_phi_bhyt` và `dm_dashboard_ngay.so_xac_nhan_chi_phi_bhyt`.

### 4.9. Xuất XML — `fn_dashboard_xuat_xml`

Nguồn: `csyt_xac_nhan_chi_phi`.

Logic:

```sql
COALESCE(xuat_xml::text, '0') IN ('1','true','t')
AND ngay_xac_nhan trong khoảng lọc
```

Ý nghĩa: số hồ sơ đã đánh dấu xuất XML, không phải số file XML vật lý.

Silver giữ cờ `is_xuat_xml` trong `ct_xac_nhan_chi_phi`. Gold: `dm_xac_nhan_chi_phi_ngay.so_xuat_xml` và `dm_dashboard_ngay.so_xuat_xml`.

### 4.10. Doanh thu tổng — `fn_dashboard_doanh_thu`

Function này chỉ cộng kết quả của `fn_dashboard_doanh_thu_nguon_thu`. Đây là KPI tổng hợp, không phải nguồn dữ liệu độc lập.

### 4.11. Doanh thu theo nguồn thu — `fn_dashboard_doanh_thu_nguon_thu`

Nguồn và quan hệ:

```text
csyt_vien_phi_chung_tu a
  -> dm_so_thu_hoa_don sthd
  -> csyt_vien_phi_chung_tu_chi_tiet cvpctct
  -> dmc_ma_nhom_chi_phi dmncp
```

Điều kiện nghiệp vụ:

- `a.da_thanh_toan = 1`;
- `a.hoan_tra = 0`;
- `a.huy_hoa_don = 0`;
- `sthd.ma_loai_so = 'SBL'`;
- ngày lọc là `a.ngay_thu`;
- tiền = `thanh_tien_benh_nhan_cung_chi_tra + thanh_tien_benh_nhan_tu_thanh_toan`;
- nhóm không map được dùng `20. Khác`.

Ý nghĩa: doanh thu dashboard là doanh thu bệnh nhân đã thu và còn hiệu lực, không phải tổng giá niêm yết hay tổng phải thu.

Silver: `ct_dong_doanh_thu`, một dòng cho một dòng chi tiết doanh thu hợp lệ.

Gold: `dm_doanh_thu_ngay`, grain ngày × nhóm doanh thu.

Không được join `ct_dong_doanh_thu` trực tiếp với `ct_luot_kham` trong một query tổng hợp nếu không có khóa và grain rõ ràng, vì sẽ nhân doanh thu theo số lượt khám.

## 5. Các function phân tích nhân khẩu học và bệnh

### 5.1. `fn_dashboard_patient_gender`

Nguồn: `benh_nhan_tiep_nhan` join `tiep_nhan` theo `tiep_nhan_id`.

Logic:

- `ma_gioi_tinh = '2'`: nam theo quy ước function hiện tại;
- `ma_gioi_tinh = '1'`: nữ;
- null hoặc mã khác: chưa xác định;
- chỉ giữ `bi_xoa = 0` ở cả hai bảng;
- lọc ngày theo `tiep_nhan.ngay_tiep_nhan`.

Tên nhãn nam/nữ phải được giữ theo function hiện tại khi đối soát, dù quy ước mã cần được xác nhận lại với danh mục.

### 5.2. `fn_dashboard_patient_type`

Nguồn: `benh_nhan_dot_dieu_tri` join `tiep_nhan`.

Logic phân loại dựa trên `is_bhyt`, `ma_quyen_loi`, và nhóm không BHYT. Đây là phân loại đối tượng, không phải phân loại nguồn doanh thu. Function cũng lọc theo `tiep_nhan.ngay_tiep_nhan` và loại bản ghi xóa mềm.

### 5.3. `fn_dashboard_icd10_stats`

Function ICD-10 gom chẩn đoán từ nhiều nguồn, sau đó nối danh mục chương ICD-10, nhóm ICD-10, mã bệnh và tên bệnh.

Các measure trả về:

- `so_ban_ghi`: số bản ghi chẩn đoán;
- `so_luot_kcb`: số lượt khám/chữa bệnh;
- `so_benh_nhan`: số bệnh nhân duy nhất.

Đây không phải mart đếm đơn giản. Phải giữ ba grain riêng hoặc dùng aggregate state phù hợp để không biến `count(distinct benh_nhan_id)` thành số dòng.

Silver: `ct_icd10`, tách mã chính và mã kèm theo bằng dấu `;`, loại trùng mã trong cùng hồ sơ. Gold: `dm_icd10`, dùng `count()` cho bản ghi, `uniqExact(ma_lk)` cho lượt KCB và `uniqExact(benh_nhan_id)` cho bệnh nhân.

## 6. Ý nghĩa các bảng Silver hiện tại

### 6.1. `hms_silver.ct_luot_kham`

**Grain:** một dòng cho một `tiep_nhan_id`.

Cột chính:

- `tiep_nhan_id`: khóa lượt tiếp nhận;
- `ngay_tiep_nhan`: ngày dùng cho mart hiện tại;
- `is_cap_cuu`: cờ cấp cứu theo hai điều kiện của function;
- `is_kham_benh`: có bản ghi khám liên quan;
- `so_luot_tiep_nhan`: luôn bằng 1 để aggregate an toàn.

Đây là fact lượt, không phải bảng bệnh nhân. Không dùng để tính số bệnh nhân duy nhất nếu chưa có khóa bệnh nhân và quy tắc distinct rõ ràng.

### 6.2. `hms_silver.ct_dot_noi_tru`

**Grain:** một dòng cho một bệnh án/đợt nội trú.

Nguồn:

- `csyt_benh_an_dieu_tri.id` cho ngày vào viện;
- `csyt_phieu_ra_vien.benh_an_id` cho ngày ra viện.

Cột chính: `dot_noi_tru_key`, `ngay_vao_vien`, `ngay_ra_vien`.

> Bảng này mới đủ để tính số ca vào/ra theo ngày. Để tính bệnh nhân nội trú đang nằm trong một khoảng và LOS đầy đủ, cần bổ sung `tiep_nhan_id`, khoa, cơ sở, kết quả ra viện và số ngày điều trị.

### 6.3. `hms_silver.ct_don_thuoc`

**Grain:** một đơn thuốc theo `(khambenh_id, mauhososohoa_id)`.

Cột chính: khóa kép của đơn, `ngay_don_thuoc` là ngày sớm nhất của các dòng thuốc, và `so_dong_thuoc` là số dòng chi tiết trong đơn. Không cộng `so_dong_thuoc` để ra số đơn.

### 6.4. `hms_silver.ct_chi_dinh_dich_vu`

**Grain:** một dòng chi tiết chỉ định dịch vụ.

Hiện bảng giữ `chi_dinh_id` và `ngay_chi_dinh`, phù hợp với function đang đếm dòng. Nếu dashboard cần số phiếu chỉ định, phải xác định khóa phiếu cấp cha trước khi thêm measure.

### 6.5. `hms_silver.ct_dong_doanh_thu`

**Grain:** một dòng chi tiết doanh thu đã thu hợp lệ.

Cột chính: `chung_tu_id`, `chi_tiet_id`, `ngay_thu`, `nhom_doanh_thu`, `doanh_thu_thuan`.

Bảng này là nơi đã áp dụng toàn bộ điều kiện thanh toán của function. Gold chỉ được cộng `doanh_thu_thuan`, không lặp lại join nguồn.

## 7. Ý nghĩa các bảng Gold hiện tại

### 7.1. `hms_gold.dm_luot_kham_ngay`

**Grain:** một dòng cho một ngày.

Measures: `so_luot_tiep_nhan`, `so_luot_kham`, `so_luot_cap_cuu`.

Dùng cho thẻ tổng quan và biểu đồ xu hướng ngày. Chưa phân rã theo cơ sở, khoa, giới tính hay đối tượng vì các khóa đó chưa được đưa vào `ct_luot_kham` hiện tại.

### 7.2. `hms_gold.dm_noi_tru_ngay`

**Grain:** một dòng cho một ngày.

Measures: `so_ca_vao_vien`, `so_ca_ra_vien`.

Đây là mart event theo ngày, không phải snapshot census. Nó chưa trả lời trực tiếp “đang có bao nhiêu bệnh nhân nội trú” trong một ngày.

### 7.3. `hms_gold.dm_don_thuoc_ngay`

**Grain:** một dòng cho một ngày.

Measure `so_don_thuoc` là số dòng trong `ct_don_thuoc`, tương đương distinct composite key của function.

### 7.4. `hms_gold.dm_doanh_thu_ngay`

**Grain:** ngày × nhóm doanh thu.

Measure `tong_doanh_thu_thuan` dùng cho tổng doanh thu và biểu đồ cơ cấu nguồn thu. Tổng toàn kỳ phải là tổng measure này sau khi lọc ngày.

## 8. Parity function và mart hiện tại

Đã có Silver/Gold tương ứng cho: tiếp nhận, khám bệnh theo `thoi_gian_bat_dau`, cấp cứu, vào/ra viện, chuyển viện, đơn thuốc, chỉ định dịch vụ, xác nhận chi phí BHYT, xuất XML, giới tính, loại đối tượng bệnh nhân, doanh thu và ICD-10.

`dm_dashboard_ngay` là semantic mart theo ngày tương ứng các cột current của `fn_dashboard_summary`. Dashboard tính kỳ trước bằng cách lấy khoảng ngày liền trước có cùng độ dài, thay vì chỉ hỗ trợ trường hợp một ngày như function cũ.

Phần chưa thể triển khai là công suất giường, vì bộ raw hiện tại chưa có bảng phân giường và bảng kế hoạch giường được xác nhận. Đây là thiếu dữ liệu nguồn, không phải thiếu logic chuyển đổi.

## 9. Quy tắc đối soát nghiệp vụ

Đối soát cùng một khoảng ngày:

1. `fn_dashboard_tiep_nhan` với `sum(dm_luot_kham_ngay.so_luot_tiep_nhan)`.
2. `fn_dashboard_cap_cuu` với `sum(dm_luot_kham_ngay.so_luot_cap_cuu)`.
3. `fn_dashboard_vao_vien` với `sum(dm_noi_tru_ngay.so_ca_vao_vien)`.
4. `fn_dashboard_ra_vien` với `sum(dm_noi_tru_ngay.so_ca_ra_vien)`.
5. `fn_dashboard_don_thuoc` với `sum(dm_don_thuoc_ngay.so_don_thuoc)`.
6. `fn_dashboard_doanh_thu` với `sum(dm_doanh_thu_ngay.tong_doanh_thu_thuan)`.

Nếu lệch, kiểm tra theo thứ tự: khoảng ngày, bản ghi xóa mềm, duplicate theo grain, điều kiện join, khác biệt ngày nghiệp vụ, và khác biệt giữa count dòng với count distinct.

## 10. Kết luận nghiệp vụ

Function PostgreSQL đang trộn ba trách nhiệm: đọc nguồn, áp dụng business rule và trả KPI cuối cùng.

Thiết kế Silver/Gold tách ba trách nhiệm đó:

- Silver trả lời “một bản ghi nghiệp vụ là gì?”;
- Gold trả lời “tổng hợp KPI theo ngày/nhóm là bao nhiêu?”;
- dashboard chỉ áp dụng bộ lọc và công thức trình bày, không tự join các fact khác grain.

Đây là điều kiện để KPI không bị nhân bản khi mở rộng từ tổng quan sang phân tích theo khoa, cơ sở, đối tượng hoặc nguồn thu.
