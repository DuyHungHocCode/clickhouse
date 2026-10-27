# DDL các bảng nghiệp vụ và enum

## Enum

```sql
CREATE TYPE tenant_bvcahn."ad_rule_type_enum" AS ENUM (
	'VALIDATION',
	'GATEWAY',
	'EVENT');

CREATE TYPE tenant_bvcahn."clients_clienttype_enum" AS ENUM (
	'public',
	'confidential',
	'bearer-only');

CREATE TYPE tenant_bvcahn."events_type_enum" AS ENUM (
	'LOGIN',
	'LOGIN_ERROR',
	'LOGOUT',
	'REGISTER',
	'UPDATE_PASSWORD',
	'RESET_PASSWORD',
	'VERIFY_EMAIL',
	'UPDATE_PROFILE',
	'TOKEN_EXCHANGE',
	'CLIENT_LOGIN',
	'CLIENT_LOGIN_ERROR',
	'USER_DISABLED',
	'USER_ENABLED',
	'USER_LOCKED',
	'USER_UNLOCKED',
	'ROLE_CREATED',
	'ROLE_UPDATED',
	'ROLE_DELETED',
	'CLIENT_CREATED',
	'CLIENT_UPDATED',
	'CLIENT_DELETED');
```

## Bảng

```sql
CREATE TABLE ad_column (
	id uuid DEFAULT gen_random_uuid() NOT NULL,
	table_id uuid NOT NULL,
	column_name text NOT NULL,
	"name" text NOT NULL,
	data_type text NOT NULL,
	is_mandatory_copy bool DEFAULT true NULL,
	is_key bool DEFAULT false NULL,
	is_unique bool DEFAULT false NULL,
	is_null bool DEFAULT true NULL,
	is_default bool DEFAULT false NULL,
	value_default text NULL,
	seq_no int4 NOT NULL,
	description text NULL,
	"version" text NOT NULL,
	ngay_tao timestamp DEFAULT now() NULL,
	nguoi_tao varchar NOT NULL,
	ngay_cap_nhat timestamp DEFAULT now() NULL,
	nguoi_cap_nhat varchar NOT NULL,
	data_type_modifier text NULL,
	ngay_xoa timestamp NULL,
	is_view bool DEFAULT false NULL,
	new_column_name text NULL,
	is_array bool DEFAULT false NULL,
	bi_xoa int2 DEFAULT 0 NULL,
	nguoi_xoa varchar NULL,
	is_create_ref bool DEFAULT false NULL, -- Tạo reference (FK) không
	data_table_ref varchar NULL, -- Bảng tham chiếu (FK)
	data_col_ref varchar NULL, -- Cột tham chiếu (FK)
	data_col_label varchar NULL,
	is_show_search bool DEFAULT true NULL,
	is_edit bool DEFAULT true NULL,
	CONSTRAINT ad_column_pkey PRIMARY KEY (id),
	CONSTRAINT ad_column_table_id_column_name_key UNIQUE (table_id, column_name)
);

CREATE TABLE ad_field (
	id uuid DEFAULT gen_random_uuid() NOT NULL,
	column_id uuid NULL,
	"name" text NOT NULL,
	required bool DEFAULT false NULL,
	ngay_xoa timestamp NULL,
	ngay_tao timestamp DEFAULT now() NULL,
	nguoi_tao varchar NOT NULL,
	ngay_cap_nhat timestamp DEFAULT now() NULL,
	nguoi_cap_nhat varchar NOT NULL,
	window_id uuid NOT NULL,
	placeholder varchar NULL,
	"label" varchar NULL,
	properties jsonb NULL,
	layout jsonb NULL,
	code varchar NOT NULL,
	"type" varchar(20) NOT NULL,
	"options" jsonb DEFAULT '[]'::jsonb NULL,
	ordinal int4 NULL,
	api_config jsonb NULL,
	bi_xoa int2 DEFAULT 0 NULL,
	nguoi_xoa varchar NULL,
	CONSTRAINT ad_field_pkey PRIMARY KEY (id),
	CONSTRAINT ad_field_window_id_code_key UNIQUE (window_id, code),
	CONSTRAINT ad_field_window_id_column_id_key UNIQUE (window_id, column_id)
);

CREATE TABLE ad_query (
	id uuid DEFAULT gen_random_uuid() NOT NULL,
	"name" varchar NOT NULL,
	code varchar(100) NOT NULL,
	"type" varchar(10) DEFAULT 'SIMPLE'::character varying NULL,
	table_id uuid NULL,
	ngay_xoa timestamp NULL,
	ngay_tao timestamp DEFAULT now() NULL,
	nguoi_tao varchar NOT NULL,
	ngay_cap_nhat timestamp DEFAULT now() NULL,
	nguoi_cap_nhat varchar NOT NULL,
	"sql" text NULL,
	count_sql text NULL,
	bi_xoa int2 DEFAULT 0 NULL,
	nguoi_xoa varchar NULL,
	is_pagination bool DEFAULT true NULL,
	access_type varchar(30) DEFAULT 'AUTHENTICATED'::character varying NOT NULL, -- Quyền truy cập: PUBLIC (không cần đăng nhập), AUTHENTICATED (cần JWT hợp lệ), ADMIN (cần JWT + role admin).
	CONSTRAINT ad_query_access_type_check CHECK (((access_type)::text = ANY (ARRAY[('PUBLIC'::character varying)::text, ('AUTHENTICATED'::character varying)::text, ('ADMIN'::character varying)::text]))),
	CONSTRAINT ad_query_code_key UNIQUE (code),
	CONSTRAINT ad_query_pkey PRIMARY KEY (id)
);

CREATE TABLE ad_query_bk (
	id uuid NULL,
	"name" varchar NULL,
	code varchar(100) NULL,
	"type" varchar(10) NULL,
	table_id uuid NULL,
	ngay_xoa timestamp NULL,
	ngay_tao timestamp NULL,
	nguoi_tao varchar NULL,
	ngay_cap_nhat timestamp NULL,
	nguoi_cap_nhat varchar NULL,
	"sql" text NULL,
	count_sql text NULL,
	paged_sql text NULL,
	bi_xoa int2 NULL,
	nguoi_xoa varchar NULL,
	is_pagination bool NULL,
	access_type varchar(30) NULL
);

CREATE TABLE ad_query_field (
	id uuid DEFAULT gen_random_uuid() NOT NULL,
	alias varchar(100) NULL, -- thông tin alias giao tiếp với FE
	code varchar(100) NOT NULL, -- chứa đầy đủ thông tin table-alias + table-column
	column_id uuid NULL,
	query_id uuid NOT NULL,
	ngay_xoa timestamp NULL,
	ngay_tao timestamp DEFAULT now() NULL,
	nguoi_tao varchar DEFAULT 'system'::character varying NOT NULL,
	ngay_cap_nhat timestamp DEFAULT now() NULL,
	nguoi_cap_nhat varchar DEFAULT 'system'::character varying NOT NULL,
	sort_operator varchar(10) NULL, -- ASC/DESC khi tham gia default ORDER BY; NULL = không default, chỉ sort khi client gửi.
	sortable bool DEFAULT true NOT NULL, -- Cho phép sort theo field này.
	filterable bool DEFAULT true NOT NULL, -- Cho phép filter động theo field này.
	allowed_filter_operators varchar(200) NULL, -- Danh sách operator cho filter, phân tách dấu phẩy: EQ,LIKE,GT,GTE,LT,LTE,IN,ILIKE.
	bi_xoa int2 DEFAULT 0 NULL,
	nguoi_xoa varchar NULL,
	sort_order int4 NULL, -- Thứ tự tăng dần trong default ORDER BY; NULL = nhóm cuối, tie-break id (UUID v7).
	CONSTRAINT ad_query_field_pkey PRIMARY KEY (id),
	CONSTRAINT ad_query_field_query_id_code_key UNIQUE (query_id, code)
);

CREATE TABLE ad_query_request (
	id uuid DEFAULT gen_random_uuid() NOT NULL,
	"name" varchar NULL,
	code varchar(100) NOT NULL,
	"type" varchar(10) DEFAULT 'TEXT'::character varying NULL,
	column_id uuid NULL,
	is_required bool DEFAULT false NULL,
	query_id uuid NOT NULL,
	ngay_xoa timestamp NULL,
	ngay_tao timestamp DEFAULT now() NULL,
	nguoi_tao varchar NOT NULL,
	ngay_cap_nhat timestamp DEFAULT now() NULL,
	nguoi_cap_nhat varchar NOT NULL,
	"operator" varchar(10) NULL,
	bi_xoa int2 DEFAULT 0 NULL,
	nguoi_xoa varchar NULL,
	value_expression varchar(1000) NULL, -- SpEL giá trị tham số. Biến: #context, #workspace, #user (không dùng #userInfo).
	CONSTRAINT ad_query_request_pkey PRIMARY KEY (id),
	CONSTRAINT ad_query_request_query_id_code_key UNIQUE (query_id, code)
);

CREATE TABLE ad_query_response (
	id uuid DEFAULT gen_random_uuid() NOT NULL,
	"name" varchar NULL,
	code varchar(100) NOT NULL,
	"type" varchar(10) DEFAULT 'TEXT'::character varying NULL,
	column_id uuid NULL,
	query_id uuid NOT NULL,
	ngay_xoa timestamp NULL,
	ngay_tao timestamp DEFAULT now() NULL,
	nguoi_tao varchar NOT NULL,
	ngay_cap_nhat timestamp DEFAULT now() NULL,
	nguoi_cap_nhat varchar NOT NULL,
	bi_xoa int2 DEFAULT 0 NULL,
	nguoi_xoa varchar NULL,
	CONSTRAINT ad_query_response_pkey PRIMARY KEY (id),
	CONSTRAINT ad_query_response_query_id_code_key UNIQUE (query_id, code)
);

CREATE TABLE ad_rule_set_module (
	id uuid DEFAULT gen_random_uuid() NOT NULL,
	rule_set_id varchar(255) NOT NULL,
	module_category_id uuid NOT NULL,
	bi_xoa int4 DEFAULT 0 NOT NULL,
	nguoi_tao varchar(100) NULL,
	ngay_tao timestamp DEFAULT CURRENT_TIMESTAMP NOT NULL,
	nguoi_cap_nhat varchar(100) NULL,
	ngay_cap_nhat timestamp DEFAULT CURRENT_TIMESTAMP NOT NULL,
	nguoi_xoa varchar(100) NULL,
	ngay_xoa timestamp NULL,
	CONSTRAINT ad_rule_set_module_pkey PRIMARY KEY (id),
	CONSTRAINT ad_rule_set_module_rule_set_id_module_category_id_key UNIQUE (rule_set_id, module_category_id)
);

CREATE TABLE ad_rule_sets (
	id uuid DEFAULT gen_random_uuid() NOT NULL,
	rule_set_id varchar(255) NOT NULL, -- Unique identifier for the rule set within tenant scope
	"name" varchar(255) NOT NULL,
	description varchar(1000) NULL,
	"type" tenant_bvcahn."ad_rule_type_enum" NOT NULL, -- Rule set type using ad_rule_type_enum: VALIDATION (validation rules), GATEWAY (workflow conditions), EVENT (event-driven rules)
	evaluation_mode varchar(20) DEFAULT 'ALL'::character varying NULL, -- How rules in this set are evaluated: ALL (AND), ANY (OR), FIRST_MATCH
	priority int4 DEFAULT 0 NULL,
	"version" int4 DEFAULT 1 NULL,
	bi_xoa int4 DEFAULT 0 NOT NULL,
	nguoi_tao varchar(100) NULL,
	ngay_tao timestamp DEFAULT CURRENT_TIMESTAMP NOT NULL,
	nguoi_cap_nhat varchar(100) NULL,
	ngay_cap_nhat timestamp DEFAULT CURRENT_TIMESTAMP NOT NULL,
	nguoi_xoa varchar(100) NULL,
	ngay_xoa timestamp NULL,
	CONSTRAINT ad_rule_sets_evaluation_mode_check CHECK (((evaluation_mode)::text = ANY (ARRAY[('ALL'::character varying)::text, ('ANY'::character varying)::text, ('FIRST_MATCH'::character varying)::text]))),
	CONSTRAINT ad_rule_sets_pkey PRIMARY KEY (id),
	CONSTRAINT ad_rule_sets_rule_set_id_key UNIQUE (rule_set_id),
	CONSTRAINT chk_ad_rule_sets_evaluation_mode CHECK (((evaluation_mode)::text = ANY (ARRAY[('ALL'::character varying)::text, ('ANY'::character varying)::text, ('FIRST_MATCH'::character varying)::text])))
);

CREATE TABLE ad_rules (
	id uuid DEFAULT gen_random_uuid() NOT NULL,
	rule_id varchar(255) NOT NULL,
	"name" varchar(255) NULL,
	description varchar(1000) NULL,
	"type" tenant_bvcahn."ad_rule_type_enum" NOT NULL, -- Rule type using ad_rule_type_enum: VALIDATION (validation rules), GATEWAY (workflow conditions), EVENT (event-driven rules)
	rule_set_id varchar(255) NULL,
	"expression" text NOT NULL, -- SpEL expression defining the rule logic
	priority int4 DEFAULT 0 NULL,
	error_message varchar(500) NULL,
	error_code varchar(100) NULL,
	field_name varchar(255) NULL, -- Field name for field-level validation rules
	action_bean varchar(255) NULL,
	action_method varchar(255) NULL,
	"version" int4 DEFAULT 1 NULL,
	bi_xoa int4 DEFAULT 0 NOT NULL,
	nguoi_tao varchar(100) NULL,
	ngay_tao timestamp DEFAULT CURRENT_TIMESTAMP NOT NULL,
	nguoi_cap_nhat varchar(100) NULL,
	ngay_cap_nhat timestamp DEFAULT CURRENT_TIMESTAMP NOT NULL,
	nguoi_xoa varchar(100) NULL,
	ngay_xoa timestamp NULL,
	CONSTRAINT ad_rules_pkey PRIMARY KEY (id),
	CONSTRAINT ad_rules_rule_id_key UNIQUE (rule_id)
);

CREATE TABLE ad_table (
	id uuid DEFAULT gen_random_uuid() NOT NULL,
	table_name text NOT NULL,
	"name" text NOT NULL,
	description text NULL,
	is_view bool DEFAULT false NULL,
	last_version text NOT NULL,
	is_version bool DEFAULT true NULL,
	access_level bpchar(1) DEFAULT '3'::bpchar NULL,
	entity_type text DEFAULT 'U'::text NULL,
	replication_type bpchar(1) DEFAULT 'L'::bpchar NULL,
	is_mandatory_copy bool DEFAULT true NULL,
	ngay_tao timestamp DEFAULT now() NULL,
	nguoi_tao varchar NOT NULL,
	ngay_cap_nhat timestamp DEFAULT now() NULL,
	nguoi_cap_nhat varchar NOT NULL,
	ngay_xoa timestamp NULL,
	group_id uuid NULL,
	new_table_name text NULL,
	bi_xoa int2 DEFAULT 0 NULL,
	nguoi_xoa varchar NULL,
	pin_to_menu bool DEFAULT false NULL,
	is_pin_form bool DEFAULT false NULL, -- Ghim biểu mẫu (form) vào cây menu
	CONSTRAINT ad_table_pkey PRIMARY KEY (id),
	CONSTRAINT ad_table_table_name_key UNIQUE (table_name)
);

CREATE TABLE ad_table_bieu_mau_map (
	id uuid DEFAULT gen_random_uuid() NOT NULL, -- UID của bảng
	ad_table_id uuid NOT NULL, -- ID danh mục (ad_table)
	bieu_mau_id uuid NOT NULL, -- ID biểu mẫu động (dm_bieu_mau_dong)
	nguoi_tao varchar NULL, -- Người tạo
	ngay_tao timestamp DEFAULT now() NULL, -- Ngày tạo
	nguoi_cap_nhat varchar NULL, -- Người cập nhật
	ngay_cap_nhat timestamp DEFAULT now() NULL, -- Ngày cập nhật
	CONSTRAINT ad_table_bieu_mau_map_ad_table_id_key UNIQUE (ad_table_id),
	CONSTRAINT ad_table_bieu_mau_map_pkey PRIMARY KEY (id)
);

CREATE TABLE ad_table_bk (
	id uuid NULL,
	table_name text NULL,
	"name" text NULL,
	description text NULL,
	is_view bool NULL,
	last_version text NULL,
	is_version bool NULL,
	access_level bpchar(1) NULL,
	entity_type text NULL,
	replication_type bpchar(1) NULL,
	is_mandatory_copy bool NULL,
	ngay_tao timestamp NULL,
	nguoi_tao varchar NULL,
	ngay_cap_nhat timestamp NULL,
	nguoi_cap_nhat varchar NULL,
	ngay_xoa timestamp NULL,
	group_id uuid NULL,
	new_table_name text NULL,
	bi_xoa int2 NULL,
	nguoi_xoa varchar NULL,
	pin_to_menu bool NULL,
	bieu_mau_id uuid NULL,
	is_pin_form bool NULL
);

CREATE TABLE ad_table_group (
	id uuid DEFAULT gen_random_uuid() NOT NULL,
	code varchar(20) NOT NULL,
	"name" varchar(100) NOT NULL,
	ngay_tao timestamp DEFAULT now() NOT NULL,
	nguoi_tao varchar NULL,
	ngay_cap_nhat timestamp DEFAULT now() NOT NULL,
	nguoi_cap_nhat varchar NULL,
	ngay_xoa timestamp NULL,
	bi_xoa int2 DEFAULT 0 NULL,
	nguoi_xoa varchar NULL,
	CONSTRAINT ad_table_group_code_key UNIQUE (code),
	CONSTRAINT ad_table_group_pkey PRIMARY KEY (id)
);

CREATE TABLE ad_window (
	id uuid DEFAULT gen_random_uuid() NOT NULL,
	ngay_xoa timestamp NULL,
	ngay_tao timestamp DEFAULT now() NULL,
	nguoi_tao varchar NOT NULL,
	ngay_cap_nhat timestamp DEFAULT now() NULL,
	nguoi_cap_nhat varchar NOT NULL,
	table_id uuid NULL,
	settings jsonb NULL,
	layout jsonb NULL,
	metadata jsonb NULL,
	validation jsonb NULL,
	bi_xoa int2 DEFAULT 0 NULL,
	nguoi_xoa varchar NULL,
	code varchar(25) NULL,
	title varchar(255) NULL,
	description text NULL,
	CONSTRAINT ad_window_code_key UNIQUE (code),
	CONSTRAINT ad_window_pkey PRIMARY KEY (id),
	CONSTRAINT ad_window_table_id_key UNIQUE (table_id)
);

CREATE TABLE adm_datarole (
	datarole_id numeric(15) NOT NULL,
	datarole_name varchar(100) NULL,
	company_id numeric(15) NULL,
	datarole_code varchar(100) NULL,
	giatri numeric(2) NULL,
	is_root numeric(1) NULL,
	CONSTRAINT adm_datarole_pkey PRIMARY KEY (datarole_id)
);

CREATE TABLE adm_datarole_dept (
	id numeric(15) NOT NULL,
	datarole_id numeric(15) NULL,
	org_id numeric(15) NULL,
	company_id numeric(15) NULL,
	CONSTRAINT adm_datarole_dept_pkey PRIMARY KEY (id)
);

CREATE TABLE adm_datarole_store (
	id numeric(10) NOT NULL,
	datarole_id numeric(10) NULL,
	store_id numeric(10) NULL,
	company_id numeric(10) NULL,
	CONSTRAINT adm_datarole_store_pkey PRIMARY KEY (id)
);

CREATE TABLE adm_user (
	user_id varchar(50) NOT NULL,
	user_name varchar(100) NULL,
	full_name varchar(255) NULL,
	CONSTRAINT adm_user_pkey PRIMARY KEY (user_id)
);

CREATE TABLE adm_user_datarole (
	id numeric(15) NOT NULL,
	user_id numeric(15) NULL,
	datarole_id numeric(15) NULL,
	company_id numeric(15) NULL,
	CONSTRAINT adm_user_datarole_pkey PRIMARY KEY (id)
);

CREATE TABLE b_count_locked (
	count int8 NULL
);

CREATE TABLE ban_hosobenhan (
	hosobenhanid varchar(50) NOT NULL,
	mabenhnhan varchar(50) NULL,
	sovaovien varchar(50) NULL,
	soluutru varchar(50) NULL,
	mahosobenhan varchar(50) NULL,
	tenbenhnhan varchar(255) NULL,
	ngaysinh timestamp NULL,
	tuoi int4 NULL,
	gioitinhid int4 NULL,
	diachi varchar(255) NULL,
	CONSTRAINT ban_hosobenhan_pkey PRIMARY KEY (hosobenhanid)
);

CREATE TABLE ban_loai_benhan (
	id uuid DEFAULT gen_random_uuid() NOT NULL,
	loaibenhanid varchar(50) NOT NULL,
	maloaibenhan varchar(50) NULL,
	ca_rpt_code varchar(100) NULL,
	ca_rpt_code_sum varchar(100) NULL,
	ca_phauthuat int2 NULL,
	tenloaibenhan varchar(255) NULL,
	ma_cskcb varchar(50) NULL,
	hoat_dong int2 DEFAULT 1 NULL,
	bi_xoa int2 DEFAULT 0 NULL,
	ngay_tao timestamp DEFAULT now() NULL,
	nguoi_tao varchar(50) NULL,
	ngay_cap_nhat timestamp DEFAULT now() NULL,
	nguoi_cap_nhat varchar(50) NULL,
	ngay_xoa timestamp NULL,
	nguoi_xoa varchar(50) NULL,
	CONSTRAINT ban_loai_benhan_pkey PRIMARY KEY (id)
);

CREATE TABLE benh_nhan (
	id uuid DEFAULT gen_random_uuid() NOT NULL,
	ma_cskcb varchar NOT NULL,
	ma_benh_nhan varchar NOT NULL,
	ten_benh_nhan varchar NOT NULL,
	nam_sinh int2 NOT NULL,
	ngay_sinh date NOT NULL,
	ma_gioi_tinh varchar NULL,
	so_dien_thoai varchar NULL,
	so_nha varchar NULL,
	ma_tinh varchar NULL,
	ma_xa varchar NULL,
	dia_chi_chi_tiet varchar NULL,
	ma_nghe_nghiep varchar NULL,
	ma_dan_toc varchar NULL,
	ma_quoc_tich varchar NULL,
	cccd varchar NULL,
	cccd_dia_chi varchar NULL,
	cccd_ngay_cap date NULL,
	cccd_noi_cap varchar NULL,
	ma_so_bhxh varchar NULL,
	benh_man_tinh varchar NULL,
	di_ung varchar NULL,
	ma_nhom_mau varchar NULL,
	ma_dieu_tri_hiv varchar NULL,
	ma_dieu_tri_lao varchar NULL,
	ma_yeu_to_rh varchar NULL,
	tu_vong int2 NULL,
	thoi_gian_tu_vong timestamp NULL,
	ma_nguyen_nhan_tu_vong varchar NULL,
	bi_xoa int2 DEFAULT 0 NOT NULL,
	ngay_xoa timestamp NULL,
	nguoi_xoa varchar(100) NULL,
	ngay_tao timestamp DEFAULT CURRENT_TIMESTAMP NULL,
	nguoi_tao varchar NULL,
	ngay_cap_nhat timestamp NULL,
	nguoi_cap_nhat varchar NULL,
	so_ho_chieu varchar NULL,
	CONSTRAINT benh_nhan_pkey PRIMARY KEY (id)
);

CREATE TABLE benh_nhan_bhyt (
	id uuid DEFAULT gen_random_uuid() NOT NULL,
	ma_cskcb varchar NOT NULL,
	ma_benh_nhan varchar NOT NULL,
	benh_nhan_id uuid NOT NULL,
	so_the varchar NULL,
	ma_benh_vien varchar NULL,
	ma_kcb_bd varchar NULL,
	ma_noi_sinh_song varchar NULL,
	bhyt_tu_ngay date NULL,
	bhyt_den_ngay date NULL,
	du_5_nam int2 NULL,
	du_5_nam_ngay date NULL,
	dct_6_thang int2 NULL,
	dct_ngay date NULL,
	bi_xoa int2 DEFAULT 0 NOT NULL,
	ngay_xoa timestamp NULL,
	nguoi_xoa varchar(100) NULL,
	ngay_tao timestamp DEFAULT CURRENT_TIMESTAMP NULL,
	nguoi_tao varchar NULL,
	ngay_cap_nhat timestamp NULL,
	nguoi_cap_nhat varchar NULL,
	ma_doi_tuong varchar NULL, -- Mã đối tượng (Xử lý nội bộ hệ thống)
	CONSTRAINT benh_nhan_bhyt_pkey PRIMARY KEY (id)
);

CREATE TABLE benh_nhan_dot_dieu_tri (
	id uuid DEFAULT gen_random_uuid() NOT NULL,
	ma_cskcb varchar NOT NULL,
	ma_tiep_nhan varchar NOT NULL,
	tiep_nhan_id uuid NOT NULL,
	is_bhyt int2 NULL,
	loai_the_tam varchar NULL,
	ma_quyen_loi varchar NULL,
	muc_huong numeric NULL,
	so_the varchar NULL,
	ma_benh_vien varchar NULL,
	ma_kcb_bd varchar NULL,
	ma_noi_sinh_song varchar NULL,
	bhyt_tu_ngay date NULL,
	bhyt_den_ngay date NULL,
	du_5_nam int2 NULL,
	du_5_nam_ngay date NULL,
	dct_6_thang int2 NULL,
	dct_ngay date NULL,
	dieu_tri_tu_ngay date NOT NULL,
	dieu_tri_den_ngay date NULL,
	trai_tuyen int2 NULL,
	ty_le_vuot_lcb numeric NULL,
	ty_le_trai_tuyen numeric NULL,
	gioi_han_vuot_lcb numeric NULL,
	luong_co_ban numeric NULL,
	ma_doi_tuong_lt varchar NULL, -- Mã đối tượng KCB (gửi lên cổng giám định BHYT)
	bi_xoa int2 DEFAULT 0 NOT NULL,
	ngay_xoa timestamp NULL,
	nguoi_xoa varchar(100) NULL,
	ngay_tao timestamp DEFAULT CURRENT_TIMESTAMP NULL,
	nguoi_tao varchar NULL,
	ngay_cap_nhat timestamp NULL,
	nguoi_cap_nhat varchar NULL,
	mien_cung_chi_tra int2 NULL,
	xac_nhan_bhyt int2 DEFAULT 0 NULL,
	ma_phan_loai_can_bo varchar NULL,
	ngay_mien_cung_chi_tra date NULL,
	ma_tuyen_kcb varchar NULL,
	ma_doi_tuong varchar NULL, -- Mã đối tượng (Xử lý nội bộ hệ thống)
	so_thang_tinh_vuot_dvktc numeric NULL,
	gioi_han_vuot_dvktc numeric NULL,
	muc_huong_trai_tuyen numeric NULL,
	dia_chi_bhyt varchar NULL,
	so_tien_cung_chi_tra_luy_ke numeric NULL,
	CONSTRAINT benh_nhan_dot_dieu_tri_pkey PRIMARY KEY (id)
);

CREATE TABLE benh_nhan_hen_kham (
	ho_ten varchar NOT NULL, -- Họ tên
	gioi_tinh varchar(1) NOT NULL, -- Giới tính
	ngay_sinh date NOT NULL, -- Ngày sinh
	cccd varchar(15) NULL, -- Số CCCD
	so_ho_chieu varchar(15) NULL, -- Số hộ chiếu
	so_dien_thoai varchar(25) NULL, -- Số điện thoại
	dia_chi varchar NULL, -- Địa chỉ
	benh_nhan_id uuid NULL, -- ID bệnh nhân
	id uuid DEFAULT gen_random_uuid() NOT NULL, -- Key của bảng
	ngay_tao timestamp DEFAULT now() NOT NULL, -- Ngày tạo
	nguoi_tao varchar(100) DEFAULT 'system'::character varying NOT NULL, -- Người tạo
	ngay_cap_nhat timestamp DEFAULT now() NOT NULL, -- Ngày cập nhật
	nguoi_cap_nhat varchar(100) DEFAULT 'system'::character varying NOT NULL, -- Người cập nhật
	bi_xoa int2 DEFAULT 0 NULL, -- Bị xóa mềm
	ngay_xoa timestamp NULL, -- Ngày xóa mềm
	nguoi_xoa varchar(100) NULL, -- Người xóa mềm
	ma_cskcb varchar(5) NULL, -- Mã cơ sở khám chữa bệnh
	so_dien_thoai_lien_he varchar(25) NULL, -- Số điện thoại liên hệ
	CONSTRAINT benh_nhan_hen_kham_pk_id PRIMARY KEY (id)
);

CREATE TABLE benh_nhan_ksk (
	id uuid DEFAULT gen_random_uuid() NOT NULL,
	ma_cskcb varchar NOT NULL,
	ma_benh_nhan varchar(100) NULL,
	ten_benh_nhan varchar(100) NOT NULL,
	nam_sinh int2 NOT NULL,
	ngay_sinh date NOT NULL,
	ma_gioi_tinh varchar NULL,
	so_dien_thoai varchar(11) NULL,
	ma_tinh varchar NULL,
	ma_xa varchar NULL,
	dia_chi_chi_tiet varchar(500) NULL,
	ma_tinh_lien_he varchar NULL,
	ma_xa_lien_he varchar NULL,
	dia_chi_lien_he_chi_tiet varchar NULL,
	ten_bo_phan varchar NULL,
	ma_nghe_nghiep varchar NULL,
	ma_dan_toc varchar NULL,
	ma_quoc_tich varchar NULL,
	ma_nhan_vien varchar(25) NULL,
	email varchar NULL,
	cccd varchar(25) NULL,
	cccd_dia_chi varchar NULL,
	cccd_ngay_cap date NULL,
	cccd_noi_cap varchar NULL,
	tien_su_benh varchar(500) NULL,
	tien_su_di_ung varchar(500) NULL,
	ghi_chu varchar(500) NULL,
	ma_hon_nhan varchar(100) NULL,
	ma_doi_tuong varchar(100) NULL,
	hop_dong_id uuid NOT NULL,
	goi_dich_vu_id uuid NOT NULL,
	is_trung int2 DEFAULT 0 NOT NULL,
	bi_xoa int2 DEFAULT 0 NOT NULL,
	ngay_xoa timestamp NULL,
	nguoi_xoa varchar(100) NULL,
	ngay_tao timestamp DEFAULT CURRENT_TIMESTAMP NULL,
	nguoi_tao varchar NULL,
	ngay_cap_nhat timestamp NULL,
	nguoi_cap_nhat varchar NULL,
	so_ho_chieu varchar NULL,
	ma_chi_phi_phat_sinh varchar(100) NOT NULL,
	stt varchar(5) NULL,
	is_confirm_trung int2 DEFAULT 0 NOT NULL,
	ma_nhom_mau varchar NULL,
	ngay_vao_lam_viec date NULL,
	ngay_du_kien_kham date NULL,
	ngay_du_kien_lay_mau date NULL,
	cong_ty_1 varchar(500) NULL,
	cong_ty_2 varchar(500) NULL,
	rh varchar NULL,
	vung_du_lieu varchar(20) DEFAULT 'VUNG_NGOAI'::character varying NOT NULL,
	CONSTRAINT benh_nhan_ksk_pkey PRIMARY KEY (id)
);

CREATE TABLE benh_nhan_ksk_change_log (
	id uuid DEFAULT gen_random_uuid() NOT NULL,
	table_name text NOT NULL,
	record_id text NOT NULL,
	"action" text NOT NULL,
	diff_data jsonb NOT NULL,
	changed_by text NULL,
	changed_at timestamp DEFAULT CURRENT_TIMESTAMP NULL,
	raw_sql text NULL,
	CONSTRAINT benh_nhan_ksk_change_log_pkey PRIMARY KEY (id)
);

CREATE TABLE benh_nhan_ksk_nghi_trung (
	id uuid DEFAULT gen_random_uuid() NOT NULL,
	ma_cskcb varchar NOT NULL,
	benh_nhan_ksk_id uuid NOT NULL,
	benh_nhan_id uuid NOT NULL,
	ma_benh_nhan varchar(100) NULL,
	is_trung int2 DEFAULT 0 NOT NULL,
	bi_xoa int2 DEFAULT 0 NOT NULL,
	ngay_xoa timestamp NULL,
	nguoi_xoa varchar(100) NULL,
	ngay_tao timestamp DEFAULT CURRENT_TIMESTAMP NULL,
	nguoi_tao varchar NULL,
	ngay_cap_nhat timestamp NULL,
	nguoi_cap_nhat varchar NULL,
	CONSTRAINT benh_nhan_ksk_nghi_trung_pkey PRIMARY KEY (id)
);

CREATE TABLE benh_nhan_ksk_tmp (
	id uuid DEFAULT gen_random_uuid() NOT NULL,
	ma_cskcb varchar NOT NULL,
	ma_benh_nhan varchar(100) NULL,
	ten_benh_nhan varchar(100) NOT NULL,
	nam_sinh int2 NOT NULL,
	ngay_sinh date NOT NULL,
	ma_gioi_tinh varchar NULL,
	so_dien_thoai varchar(11) NULL,
	ma_tinh varchar NULL,
	ma_xa varchar NULL,
	dia_chi_chi_tiet varchar(500) NULL,
	ma_tinh_lien_he varchar NULL,
	ma_xa_lien_he varchar NULL,
	dia_chi_lien_he_chi_tiet varchar NULL,
	ten_bo_phan varchar NULL,
	ma_nghe_nghiep varchar NULL,
	ma_dan_toc varchar NULL,
	ma_quoc_tich varchar NULL,
	ma_nhan_vien varchar(25) NULL,
	email varchar NULL,
	cccd varchar(25) NULL,
	cccd_dia_chi varchar NULL,
	cccd_ngay_cap date NULL,
	cccd_noi_cap varchar NULL,
	tien_su_benh varchar(500) NULL,
	tien_su_di_ung varchar(500) NULL,
	ghi_chu varchar(500) NULL,
	ma_hon_nhan varchar(100) NULL,
	ma_doi_tuong varchar(100) NULL,
	hop_dong_id uuid NOT NULL,
	goi_dich_vu_id uuid NULL,
	is_trung int2 DEFAULT 0 NOT NULL,
	bi_xoa int2 DEFAULT 0 NOT NULL,
	ngay_xoa timestamp NULL,
	nguoi_xoa varchar(100) NULL,
	ngay_tao timestamp DEFAULT CURRENT_TIMESTAMP NULL,
	nguoi_tao varchar NULL,
	ngay_cap_nhat timestamp NULL,
	nguoi_cap_nhat varchar NULL,
	so_ho_chieu varchar NULL,
	ma_chi_phi_phat_sinh varchar(100) NOT NULL,
	stt varchar(5) NULL,
	is_confirm_trung int2 DEFAULT 0 NOT NULL,
	ma_nhom_mau varchar NULL,
	ngay_vao_lam_viec date NULL,
	ngay_du_kien_kham date NULL,
	ngay_du_kien_lay_mau date NULL,
	cong_ty_1 varchar(500) NULL,
	cong_ty_2 varchar(500) NULL,
	trang_thai int2 DEFAULT 1 NOT NULL,
	error_message text NULL,
	has_nghi_trung int2 DEFAULT 0 NOT NULL,
	rh varchar NULL,
	kieu_lay_thong_tin int2 DEFAULT 1 NOT NULL, -- Kiểu lấy thông tin khi xác nhận nghi trùng: 1 = lấy theo bản ghi trùng trên hệ thống (bảng benh_nhan); 2 = lấy theo dòng import mới (tmp) và cập nhật vào bảng benh_nhan.
	CONSTRAINT benh_nhan_ksk_tmp_pkey PRIMARY KEY (id)
);

CREATE TABLE benh_nhan_ksk_tmp_nghi_trung (
	id uuid DEFAULT gen_random_uuid() NOT NULL,
	ma_cskcb varchar NOT NULL,
	benh_nhan_ksk_tmp_id uuid NOT NULL,
	benh_nhan_id uuid NOT NULL,
	ma_benh_nhan varchar(100) NULL,
	is_trung int2 DEFAULT 0 NOT NULL,
	bi_xoa int2 DEFAULT 0 NOT NULL,
	ngay_xoa timestamp NULL,
	nguoi_xoa varchar(100) NULL,
	ngay_tao timestamp DEFAULT CURRENT_TIMESTAMP NULL,
	nguoi_tao varchar NULL,
	ngay_cap_nhat timestamp NULL,
	nguoi_cap_nhat varchar NULL,
	CONSTRAINT benh_nhan_ksk_tmp_nghi_trung_pkey PRIMARY KEY (id)
);

CREATE TABLE benh_nhan_lich_kham (
	id uuid DEFAULT gen_random_uuid() NOT NULL,
	ma_cskcb varchar NOT NULL,
	ma_dat_hen varchar NOT NULL,
	ten_benh_nhan varchar NOT NULL,
	ngay_sinh date NOT NULL,
	ma_gioi_tinh varchar NOT NULL,
	ma_quoc_tich varchar NULL,
	ma_nghe_nghiep varchar NULL,
	ma_dan_toc varchar NULL,
	so_dien_thoai varchar NOT NULL,
	dia_chi_chi_tiet varchar NULL,
	ma_tinh varchar NULL,
	ma_xa varchar NULL,
	tam_tru varchar NULL,
	thoi_gian_dat_hen timestamp NULL,
	thoi_gian_hen timestamp NULL,
	CONSTRAINT benh_nhan_lich_kham_ma_dat_hen_ma_cskcb_key UNIQUE (ma_dat_hen, ma_cskcb),
	CONSTRAINT benh_nhan_lich_kham_pkey PRIMARY KEY (id)
);

CREATE TABLE benh_nhan_nguoi_lien_he (
	id uuid DEFAULT gen_random_uuid() NOT NULL,
	benh_nhan_id uuid NOT NULL,
	ma_benh_nhan varchar(50) NOT NULL,
	nguoi_lien_he_benh_nhan_id uuid NULL,
	ho_ten varchar(255) NOT NULL,
	ma_quan_he varchar(50) NULL,
	ma_gioi_tinh varchar(10) NULL,
	ngay_sinh date NULL,
	cccd varchar(20) NULL,
	cccd_ngay_cap date NULL,
	cccd_noi_cap varchar(500) NULL,
	ma_nghe_nghiep varchar(50) NULL,
	so_dien_thoai varchar(20) NULL,
	dia_chi varchar(500) NULL,
	ma_cskcb varchar(20) NULL,
	bi_xoa int2 DEFAULT 0 NOT NULL,
	ngay_xoa timestamp NULL,
	nguoi_xoa varchar(100) NULL,
	ngay_tao timestamp DEFAULT CURRENT_TIMESTAMP NULL,
	nguoi_tao varchar NULL,
	ngay_cap_nhat timestamp NULL,
	nguoi_cap_nhat varchar NULL,
	CONSTRAINT benh_nhan_nguoi_lien_he_pkey PRIMARY KEY (id)
);

CREATE TABLE benh_nhan_phieu (
	id uuid DEFAULT gen_random_uuid() NOT NULL,
	ma_phieu_benh uuid NULL,
	ten_phieu_benh varchar(255) NULL,
	benh_nhan_id uuid NULL,
	benh_nhan_tiep_nhan_id uuid NULL,
	khoa_tiep_nhan_id uuid NULL,
	data_json jsonb NULL,
	da_ky int2 DEFAULT 0 NOT NULL,
	ma_cskcb varchar(20) NOT NULL,
	bi_xoa int2 DEFAULT 0 NOT NULL,
	ngay_xoa timestamp NULL,
	nguoi_xoa varchar(100) NULL,
	ngay_tao timestamp DEFAULT CURRENT_TIMESTAMP NOT NULL,
	nguoi_tao varchar(100) NOT NULL,
	ngay_cap_nhat timestamp NOT NULL,
	nguoi_cap_nhat varchar(100) NOT NULL,
	data_xml text NULL,
	CONSTRAINT benh_nhan_phieu_pkey PRIMARY KEY (id)
);

CREATE TABLE benh_nhan_tiep_nhan (
	id uuid DEFAULT gen_random_uuid() NOT NULL,
	ma_cskcb varchar NULL,
	ma_benh_nhan varchar NOT NULL,
	benh_nhan_id uuid NOT NULL,
	ma_tiep_nhan varchar NOT NULL,
	tiep_nhan_id uuid NOT NULL,
	ten_benh_nhan varchar NULL,
	nam_sinh int2 NULL,
	ngay_sinh date NULL,
	ma_gioi_tinh varchar NULL,
	so_dien_thoai varchar(50) NULL,
	so_nha varchar NULL,
	ma_tinh varchar NULL,
	ma_xa varchar NULL,
	dia_chi_chi_tiet varchar NULL,
	ma_nghe_nghiep varchar NULL,
	ma_dan_toc varchar NULL,
	ma_quoc_tich varchar NULL,
	cccd varchar NULL,
	cccd_dia_chi varchar NULL,
	cccd_ngay_cap date NULL,
	bi_xoa int2 DEFAULT 0 NOT NULL,
	ngay_xoa timestamp NULL,
	nguoi_xoa varchar(100) NULL,
	ngay_tao timestamp DEFAULT CURRENT_TIMESTAMP NULL,
	nguoi_tao varchar NULL,
	ngay_cap_nhat timestamp NULL,
	nguoi_cap_nhat varchar NULL,
	cccd_noi_cap varchar NULL,
	so_ho_chieu varchar NULL,
	ma_so_bhxh varchar NULL,
	CONSTRAINT benh_nhan_tiep_nhan_pkey PRIMARY KEY (id)
);

CREATE TABLE business_change_log (
	id uuid DEFAULT gen_random_uuid() NOT NULL,
	table_name text NOT NULL,
	record_id text NOT NULL,
	"action" text NOT NULL,
	diff_data jsonb NOT NULL,
	changed_by text NULL,
	changed_at timestamp DEFAULT CURRENT_TIMESTAMP NULL,
	raw_sql text NULL,
	CONSTRAINT business_change_log_pkey PRIMARY KEY (id)
);

CREATE TABLE csyt_ba_chuyen_khoa_bong (
	id uuid DEFAULT gen_random_uuid() NOT NULL,
	benh_an_id uuid NOT NULL, -- FK csyt_benh_an_dieu_tri.id (UNIQUE)
	ma_cskcb varchar(50) NOT NULL,
	bo_ly_do_vao_vien text NULL, -- Lý do vào viện
	bo_vao_ngay_thu int4 NULL, -- Vào ngày thứ mấy của bệnh
	bo_qua_trinh_benh_ly text NULL, -- Quá trình bệnh lý
	bo_tien_su_ban_than text NULL, -- Tiền sử bản thân
	bo_tien_su_gia_dinh text NULL, -- Tiền sử gia đình
	bo_di_ung_co bool NULL, -- Dị ứng - Có
	bo_di_ung_thang int4 NULL, -- Dị ứng - Số tháng
	bo_ma_tuy_co bool NULL, -- Ma túy - Có
	bo_ma_tuy_thang int4 NULL, -- Ma túy - Số tháng
	bo_ruou_bia_co bool NULL, -- Rượu bia - Có
	bo_ruou_bia_thang int4 NULL, -- Rượu bia - Số tháng
	bo_thuoc_la_co bool NULL, -- Thuốc lá - Có
	bo_thuoc_la_thang int4 NULL, -- Thuốc lá - Số tháng
	bo_thuoc_lao_co bool NULL, -- Thuốc lào - Có
	bo_thuoc_lao_thang int4 NULL, -- Thuốc lào - Số tháng
	bo_khac_co bool NULL, -- Khác - Có
	bo_khac_thang int4 NULL, -- Khác - Số tháng
	bo_kham_toan_than text NULL, -- Khám toàn thân
	bo_kham_tuan_hoan text NULL, -- Khám tuần hoàn
	bo_kham_ho_hap text NULL, -- Khám hô hấp
	bo_kham_tieu_hoa text NULL, -- Khám tiêu hóa
	bo_kham_than_tiet_nieu_sinh_duc text NULL, -- Khám thận tiết niệu sinh dục
	bo_kham_than_kinh text NULL, -- Khám thần kinh
	bo_kham_co_xuong_khop text NULL, -- Khám cơ xương khớp
	bo_kham_noi_tiet_dinh_duong_khac text NULL, -- Khám nội tiết dinh dưỡng khác
	bo_can_lam_sang_can_lam text NULL, -- Các xét nghiệm cận lâm sàng cần làm
	bo_tom_tat_benh_an text NULL, -- Tóm tắt bệnh án
	bo_icd_benh_chinh_vao_khoa_code varchar(100) NULL, -- Mã ICD bệnh chính vào khoa
	bo_icd_benh_chinh_vao_khoa_name varchar(500) NULL, -- Tên bệnh chính vào khoa
	bo_icd_benh_kem_theo_vao_khoa_code varchar(100) NULL, -- Mã ICD bệnh kèm theo vào khoa
	bo_icd_benh_kem_theo_vao_khoa_name varchar(500) NULL, -- Tên bệnh kèm theo vào khoa
	bo_phan_biet_vao_khoa text NULL, -- Chẩn đoán phân biệt
	bo_tien_luong text NULL, -- Tiên lượng
	bo_huong_dieu_tri text NULL, -- Hướng điều trị
	bo_bac_si_tao_benh_an_ho_ten varchar(255) NULL, -- Họ tên bác sĩ tạo bệnh án
	bo_bac_si_tao_benh_an_thoi_gian timestamp NULL, -- Thời gian bác sĩ tạo bệnh án
	bo_ton_thuong_bong text NULL, -- Tổn thương bỏng
	bo_kham_sinh_duc text NULL, -- Khám sinh dục
	bi_xoa int2 DEFAULT 0 NOT NULL,
	ngay_tao timestamp NULL,
	nguoi_tao varchar(50) NULL,
	ngay_cap_nhat timestamp NULL,
	nguoi_cap_nhat varchar(50) NULL,
	ngay_xoa timestamp NULL,
	nguoi_xoa varchar(50) NULL,
	bo_thoi_gian_bi_bong timestamp NULL,
	CONSTRAINT csyt_ba_chuyen_khoa_bong_benh_an_id_key UNIQUE (benh_an_id),
	CONSTRAINT csyt_ba_chuyen_khoa_bong_pkey PRIMARY KEY (id)
);

CREATE TABLE csyt_ba_chuyen_khoa_da_lieu (
	id uuid DEFAULT gen_random_uuid() NOT NULL,
	benh_an_id uuid NOT NULL, -- FK csyt_benh_an_dieu_tri.id (UNIQUE)
	ma_cskcb varchar(50) NOT NULL,
	dl_ly_do_vao_vien text NULL, -- Lý do vào viện
	dl_ly_do_nhap_vien_id uuid NULL, -- ID lý do nhập viện
	dl_vao_ngay_thu int4 NULL, -- Vào ngày thứ mấy của bệnh
	dl_qua_trinh_benh_ly text NULL, -- Quá trình bệnh lý
	dl_tien_su_ban_than text NULL, -- Tiền sử bản thân
	dl_tien_su_gia_dinh text NULL, -- Tiền sử gia đình
	dl_di_ung_co bool NULL, -- Dị ứng - Có
	dl_di_ung_thang int4 NULL, -- Dị ứng - Số tháng
	dl_ma_tuy_co bool NULL, -- Ma túy - Có
	dl_ma_tuy_thang int4 NULL, -- Ma túy - Số tháng
	dl_ruou_bia_co bool NULL, -- Rượu bia - Có
	dl_ruou_bia_thang int4 NULL, -- Rượu bia - Số tháng
	dl_thuoc_la_co bool NULL, -- Thuốc lá - Có
	dl_thuoc_la_thang int4 NULL, -- Thuốc lá - Số tháng
	dl_thuoc_lao_co bool NULL, -- Thuốc lào - Có
	dl_thuoc_lao_thang int4 NULL, -- Thuốc lào - Số tháng
	dl_khac_co bool NULL, -- Khác - Có
	dl_khac_thang int4 NULL, -- Khác - Số tháng
	dl_kham_toan_than text NULL, -- Khám toàn thân
	dl_trieu_chung_co_nang text NULL, -- Triệu chứng cơ năng (đặc thù Da liễu)
	dl_thuong_ton_can_ban text NULL, -- Thương tổn căn bản (đặc thù Da liễu)
	dl_kham_tuan_hoan text NULL, -- Khám tuần hoàn
	dl_kham_ho_hap text NULL, -- Khám hô hấp
	dl_kham_tieu_hoa text NULL, -- Khám tiêu hóa
	dl_kham_than_tiet_nieu_sinh_duc text NULL, -- Khám thận tiết niệu sinh dục
	dl_kham_than_kinh text NULL, -- Khám thần kinh ngoại biên
	dl_kham_noi_tiet_dinh_duong_khac text NULL, -- Khám các cơ quan khác
	dl_can_lam_sang_can_lam text NULL, -- Các xét nghiệm cận lâm sàng cần làm
	dl_tom_tat_benh_an text NULL, -- Tóm tắt bệnh án
	dl_icd_benh_chinh_vao_khoa_code varchar(50) NULL, -- Mã ICD bệnh chính khi vào khoa
	dl_icd_benh_chinh_vao_khoa_name varchar(500) NULL, -- Tên bệnh chính khi vào khoa
	dl_icd_benh_kem_theo_vao_khoa_code varchar(200) NULL, -- Mã ICD bệnh kèm theo khi vào khoa
	dl_icd_benh_kem_theo_vao_khoa_name text NULL, -- Tên bệnh kèm theo khi vào khoa
	dl_phan_biet_vao_khoa text NULL, -- Chẩn đoán phân biệt
	dl_tien_luong text NULL, -- Tiên lượng
	dl_huong_dieu_tri text NULL, -- Hướng điều trị
	dl_bac_si_tao_benh_an_ho_ten varchar(255) NULL, -- Họ tên bác sĩ tạo bệnh án
	dl_bac_si_tao_benh_an_thoi_gian timestamp NULL, -- Thời gian bác sĩ tạo bệnh án
	bi_xoa int2 DEFAULT 0 NOT NULL,
	ngay_tao timestamp NULL,
	nguoi_tao varchar(50) NULL,
	ngay_cap_nhat timestamp NULL,
	nguoi_cap_nhat varchar(50) NULL,
	ngay_xoa timestamp NULL,
	nguoi_xoa varchar(50) NULL,
	CONSTRAINT csyt_ba_chuyen_khoa_da_lieu_benh_an_id_key UNIQUE (benh_an_id),
	CONSTRAINT csyt_ba_chuyen_khoa_da_lieu_pkey PRIMARY KEY (id)
);

CREATE TABLE csyt_ba_chuyen_khoa_huyet_hoc (
	id uuid DEFAULT gen_random_uuid() NOT NULL,
	benh_an_id uuid NOT NULL, -- FK csyt_benh_an_dieu_tri.id (UNIQUE)
	ma_cskcb varchar(50) NOT NULL,
	hh_ly_do_vao_vien text NULL, -- Lý do vào viện
	hh_vao_ngay_thu int4 NULL, -- Vào ngày thứ mấy của bệnh
	hh_qua_trinh_benh_ly text NULL, -- Quá trình bệnh lý
	hh_tien_su_ban_than text NULL, -- Tiền sử bản thân
	hh_di_ung_co bool NULL, -- Dị ứng - Có
	hh_di_ung_thang int4 NULL, -- Dị ứng - Số tháng
	hh_ma_tuy_co bool NULL, -- Ma túy - Có
	hh_ma_tuy_thang int4 NULL, -- Ma túy - Số tháng
	hh_ruou_bia_co bool NULL, -- Rượu bia - Có
	hh_ruou_bia_thang int4 NULL, -- Rượu bia - Số tháng
	hh_thuoc_la_co bool NULL, -- Thuốc lá - Có
	hh_thuoc_la_thang int4 NULL, -- Thuốc lá - Số tháng
	hh_thuoc_lao_co bool NULL, -- Thuốc lào - Có
	hh_thuoc_lao_thang int4 NULL, -- Thuốc lào - Số tháng
	hh_khac_co bool NULL, -- Khác - Có
	hh_khac_thang int4 NULL, -- Khác - Số tháng
	hh_kham_tuan_hoan text NULL, -- Khám tuần hoàn
	hh_kham_ho_hap text NULL, -- Khám hô hấp
	hh_kham_tieu_hoa text NULL, -- Khám tiêu hóa
	hh_kham_than_tiet_nieu_sinh_duc text NULL, -- Khám thận tiết niệu sinh dục
	hh_kham_than_kinh text NULL, -- Khám thần kinh
	hh_kham_noi_tiet_dinh_duong_khac text NULL, -- Khám nội tiết dinh dưỡng khác
	hh_can_lam_sang_can_lam text NULL, -- Các xét nghiệm cận lâm sàng cần làm
	hh_tom_tat_benh_an text NULL, -- Tóm tắt bệnh án
	hh_icd_benh_chinh_vao_khoa_code varchar(100) NULL, -- Mã ICD bệnh chính vào khoa
	hh_icd_benh_chinh_vao_khoa_name varchar(500) NULL, -- Tên bệnh chính vào khoa
	hh_icd_benh_kem_theo_vao_khoa_code varchar(100) NULL, -- Mã ICD bệnh kèm theo vào khoa
	hh_icd_benh_kem_theo_vao_khoa_name varchar(500) NULL, -- Tên bệnh kèm theo vào khoa
	hh_phan_biet_vao_khoa text NULL, -- Chẩn đoán phân biệt
	hh_tien_luong text NULL, -- Tiên lượng
	hh_huong_dieu_tri text NULL, -- Hướng điều trị
	hh_bac_si_tao_benh_an_ho_ten varchar(255) NULL, -- Họ tên bác sĩ tạo bệnh án
	hh_bac_si_tao_benh_an_thoi_gian timestamp NULL, -- Thời gian bác sĩ tạo bệnh án
	hh_tinh_than_nguoi_benh text NULL, -- Tinh thần người bệnh
	hh_hinh_dang_tu_the text NULL, -- Hình dáng tư thế
	hh_da_niem_mac text NULL, -- Da niêm mạc
	hh_trieu_chung_xuat_huyet text NULL, -- Triệu chứng xuất huyết
	hh_he_thong_long_toc_mong text NULL, -- Hệ thống lông tóc móng
	hh_trieu_chung_phu text NULL, -- Triệu chứng phù
	hh_tuyen_giap text NULL, -- Tuyến giáp
	hh_gan_kich_thuoc text NULL, -- Gan - Kích thước
	hh_gan_mat_do text NULL, -- Gan - Mật độ
	hh_gan_bo text NULL, -- Gan - Bờ
	hh_gan_mat_gan text NULL, -- Gan - Mặt gan
	hh_gan_dau text NULL, -- Gan - Đau
	hh_lach_kich_thuoc text NULL, -- Lách - Kích thước
	hh_lach_mat_do text NULL, -- Lách - Mật độ
	hh_lach_bo text NULL, -- Lách - Bờ
	hh_lach_mat_gan text NULL, -- Lách - Mặt lách
	hh_lach_dau text NULL, -- Lách - Đau
	hh_hach_vi_tri text NULL, -- Hạch - Vị trí
	hh_hach_kich_thuoc text NULL, -- Hạch - Kích thước
	hh_hach_so_luong text NULL, -- Hạch - Số lượng
	hh_hach_do_di_dong text NULL, -- Hạch - Độ di động
	hh_hach_dau text NULL, -- Hạch - Đau
	hh_xn_huyet_do bool NULL, -- XN Huyết đồ
	hh_xn_tuy_do bool NULL, -- XN Tủy đồ
	hh_xn_sinh_thiet_tuy bool NULL, -- XN Sinh thiết tủy
	hh_xn_sinh_thiet_hach bool NULL, -- XN Sinh thiết hạch
	hh_xn_dong_mau_toan_bo bool NULL, -- XN Đông máu toàn bộ
	hh_xn_dinh_luong_yeu_to_dong_mau bool NULL, -- XN Định lượng yếu tố đông máu
	hh_xn_dien_di_hst bool NULL, -- XN Điện di HST
	hh_xn_nhiem_sac_the bool NULL, -- XN Nhiễm sắc thể
	hh_xn_nhom_mau bool NULL, -- XN Nhóm máu
	hh_xn_coombs_test bool NULL, -- XN Coombs test
	hh_xn_khang_the_bat_thuong bool NULL, -- XN Kháng thể bất thường
	hh_xn_sinh_hoa bool NULL, -- XN Sinh hóa
	hh_xn_gpb bool NULL, -- XN Giải phẫu bệnh
	hh_xn_vi_sinh bool NULL, -- XN Vi sinh
	hh_xn_x_quang bool NULL, -- XN X-Quang
	hh_tm_khoi_hong_cau_so_lan int4 NULL, -- Truyền máu - Khối hồng cầu số lần
	hh_tm_hong_cau_rua_so_lan int4 NULL, -- Truyền máu - Hồng cầu rửa số lần
	hh_tm_khoi_tieu_cau_so_lan int4 NULL, -- Truyền máu - Khối tiểu cầu số lần
	hh_tm_khoi_bach_cau_hat_so_lan int4 NULL, -- Truyền máu - Khối bạch cầu hạt số lần
	hh_tm_huyet_tuong_so_lan int4 NULL, -- Truyền máu - Huyết tương số lần
	hh_tm_huyet_tuong_tuoi_dong_lanh_so_lan int4 NULL, -- Truyền máu - Huyết tương tươi đông lạnh số lần
	hh_tm_tua_viii_so_lan int4 NULL, -- Truyền máu - Tủa VIII số lần
	hh_tm_toan_phan_so_lan int4 NULL, -- Truyền máu - Toàn phần số lần
	bi_xoa int2 DEFAULT 0 NOT NULL,
	ngay_tao timestamp NULL,
	nguoi_tao varchar(50) NULL,
	ngay_cap_nhat timestamp NULL,
	nguoi_cap_nhat varchar(50) NULL,
	ngay_xoa timestamp NULL,
	nguoi_xoa varchar(50) NULL,
	hh_phan_ung_man_ngua bool NULL, -- Phản ứng truyền máu - Mẩn ngứa
	hh_phan_ung_sot_ret_run bool NULL, -- Phản ứng truyền máu - Sốt rét run
	hh_phan_ung_choang_phan_ve bool NULL, -- Phản ứng truyền máu - Choáng phản vệ
	hh_phan_ung_khac bool NULL, -- Phản ứng truyền máu - Khác
	CONSTRAINT csyt_ba_chuyen_khoa_huyet_hoc_benh_an_id_key UNIQUE (benh_an_id),
	CONSTRAINT csyt_ba_chuyen_khoa_huyet_hoc_pkey PRIMARY KEY (id)
);

CREATE TABLE csyt_ba_chuyen_khoa_mat_bpt (
	id uuid DEFAULT gen_random_uuid() NOT NULL,
	benh_an_id uuid NULL, -- FK csyt_benh_an_dieu_tri.id
	ma_cskcb varchar(50) NULL,
	mat_thoi_gian_xuat_hien_benh text NULL,
	mat_nguyen_nhan text NULL,
	mat_cac_phuong_phap_da_dieu_tri text NULL,
	mat_tien_su_tai_mat text NULL,
	mat_tien_su_toan_than text NULL,
	mat_gia_dinh_benh_mat text NULL,
	mat_gia_dinh_benh_toan_than text NULL,
	mat_tt_noi_tiet_binh_thuong bool NULL,
	mat_tt_noi_tiet_co_benh bool NULL,
	mat_tt_noi_tiet_mo_ta text NULL,
	mat_tt_than_kinh_binh_thuong bool NULL,
	mat_tt_than_kinh_co_benh bool NULL,
	mat_tt_than_kinh_mo_ta text NULL,
	mat_tt_tuan_hoan_binh_thuong bool NULL,
	mat_tt_tuan_hoan_co_benh bool NULL,
	mat_tt_tuan_hoan_mo_ta text NULL,
	mat_tt_ho_hap_binh_thuong bool NULL,
	mat_tt_ho_hap_co_benh bool NULL,
	mat_tt_ho_hap_mo_ta text NULL,
	mat_tt_tieu_hoa_binh_thuong bool NULL,
	mat_tt_tieu_hoa_co_benh bool NULL,
	mat_tt_tieu_hoa_mo_ta text NULL,
	mat_tt_co_xuong_khop_binh_thuong bool NULL,
	mat_tt_co_xuong_khop_co_benh bool NULL,
	mat_tt_co_xuong_khop_mo_ta text NULL,
	mat_tt_tiet_nieu_binh_thuong bool NULL,
	mat_tt_tiet_nieu_co_benh bool NULL,
	mat_tt_tiet_nieu_mo_ta text NULL,
	mat_tt_khac text NULL,
	mp_thi_luc_khong_kinh text NULL,
	mp_thi_luc_qua_lo text NULL,
	mp_thi_luc_co_chinh_kinh text NULL,
	mp_thi_luc_nhin_gan text NULL,
	mp_nhan_ap text NULL,
	mp_lac_van_nhan text NULL,
	mp_le_dao_nuoc_thoat_tot bool NULL,
	mp_le_dao_trao_le_quan_doi_dien bool NULL,
	mp_le_dao_trao_tai_cho bool NULL,
	mp_mi_mat_tinh_trang text NULL,
	mp_mi_mat_seo_sup text NULL,
	mp_mi_mat_khac text NULL,
	mp_mi_mat_u_mi bool NULL,
	mp_mi_mat_u_mi_tinh_chat text NULL,
	mp_mi_mat_u_mi_kich_thuoc text NULL,
	mp_mi_mat_u_mi_vi_tri text NULL,
	mp_mi_mat_quam int4 NULL,
	mp_mi_mat_quam_mi_tren text NULL,
	mp_mi_mat_quam_mi_duoi text NULL,
	mp_mi_mat_ho_mi bool NULL,
	mp_mi_mat_tre_mi bool NULL,
	mp_mi_mat_khuyet_mi text NULL,
	mp_mi_mat_tuyen_bo_mi text NULL,
	mp_mi_mat_ton_thuong_khac text NULL,
	mp_ket_mac_cuong_tu text NULL,
	mp_ket_mac_phu_ne bool NULL,
	mp_ket_mac_xuat_huyet bool NULL,
	mp_ket_mac_sung_hoa bool NULL,
	mp_ket_mac_nhu bool NULL,
	mp_ket_mac_hot bool NULL,
	mp_ket_mac_seo bool NULL,
	mp_ket_mac_tiet_to_mu bool NULL,
	mp_ket_mac_tiet_to_trong bool NULL,
	mp_ket_mac_gia_mac bool NULL,
	mp_ket_mac_bat_mau_fluor bool NULL,
	mp_ket_mac_u_tinh_chat text NULL,
	mp_ket_mac_u_vi_tri text NULL,
	mp_ket_mac_u_kich_thuoc text NULL,
	mp_ket_mac_cung_do text NULL,
	mp_ket_mac_chieu_cao_cau_dinh text NULL,
	mp_ket_mac_do_rong_cau_dinh text NULL,
	mp_ket_mac_ton_thuong_khac text NULL,
	mp_giac_mac_hinh_ve text NULL,
	mp_giac_mac_kich_thuoc text NULL,
	mp_giac_mac_hinh_dang text NULL,
	mp_giac_mac_bm_dang_cham bool NULL,
	mp_giac_mac_bm_phu_bong text NULL,
	mp_giac_mac_bm_mat_bieu_mo text NULL,
	mp_giac_mac_bm_mat_bieu_mo_vt text NULL,
	mp_giac_mac_bm_bo_nham_nho bool NULL,
	mp_giac_mac_bm_bo_ton text NULL,
	mp_giac_mac_bm_thoai_hoa_dai_bang bool NULL,
	mp_giac_mac_bm_lang_dong_thuoc bool NULL,
	mp_giac_mac_bm_ton_thuong_khac text NULL,
	mp_giac_mac_nm_phu text NULL,
	mp_giac_mac_nm_tham_lau text NULL,
	mp_giac_mac_nm_tham_lau_vung text NULL,
	mp_giac_mac_nm_tieu_mong text NULL,
	mp_giac_mac_nm_tieu_mong_vt text NULL,
	mp_giac_mac_nm_ton_thuong_khac text NULL,
	mp_giac_mac_nmd_nep_gap text NULL,
	mp_giac_mac_nmd_tua_sac_to bool NULL,
	mp_giac_mac_nmd_mu_mat_sau bool NULL,
	mp_giac_mac_nmd_xuat_tiet_mat_sau bool NULL,
	mp_giac_mac_nmd_guttata bool NULL,
	mp_giac_mac_nmd_ran_descemet bool NULL,
	mp_giac_mac_nmd_cuon_descemet bool NULL,
	mp_giac_mac_nmd_ton_thuong_khac text NULL,
	mp_giac_mac_doa_thung bool NULL,
	mp_giac_mac_ket_mong_mat bool NULL,
	mp_giac_mac_thung text NULL,
	mp_giac_mac_thung_seidel bool NULL,
	mp_giac_mac_thung_duong_kinh text NULL,
	mp_giac_mac_thung_bit text NULL,
	mp_giac_mac_cam_giac text NULL,
	mp_giac_mac_tan_mach_nong text NULL,
	mp_giac_mac_tan_mach_sau bool NULL,
	mp_giac_mac_tan_mach_muc_do text NULL,
	mp_giac_mac_vung_ria_suy_te_bao bool NULL,
	mp_giac_mac_vung_ria_thoai_hoa_gia bool NULL,
	mp_giac_mac_vung_ria_lang_dong_canxi bool NULL,
	mp_giac_mac_bat_thuong_khac text NULL,
	mp_cung_mac_viem text NULL,
	mp_cung_mac_viem_muc_do text NULL,
	mp_cung_mac_viem_thuong bool NULL,
	mp_cung_mac_gian_loi bool NULL,
	mp_cung_mac_tieu_mong bool NULL,
	mp_cung_mac_hoai_tu bool NULL,
	mp_cung_mac_chi_tiet_khac text NULL,
	mp_tien_phong_tinh_trang text NULL,
	mp_tien_phong_mu text NULL,
	mp_tien_phong_tyndall bool NULL,
	mp_tien_phong_mang_xuat_tiet bool NULL,
	mp_tien_phong_mau text NULL,
	mp_tien_phong_ton_thuong_khac text NULL,
	mp_mong_mat_nau_xop bool NULL,
	mp_mong_mat_xo_teo bool NULL,
	mp_mong_mat_cuong_tu bool NULL,
	mp_mong_mat_tan_mach bool NULL,
	mp_mong_mat_phoi bool NULL,
	mp_mong_mat_ket bool NULL,
	mp_dong_tu_duong_kinh text NULL,
	mp_dong_tu_hinh_dang text NULL,
	mp_dong_tu_vi_tri_dinh text NULL,
	mp_dong_tu_phan_xa text NULL,
	mp_dong_tu_ton_thuong_khac text NULL,
	mp_ttt_binh_thuong bool NULL,
	mp_ttt_hinh_thai_duc text NULL,
	mp_ttt_lech bool NULL,
	mp_ttt_iol text NULL,
	mp_ttt_iol_vi_tri text NULL,
	mp_ttt_ton_thuong_khac text NULL,
	mp_anh_dong_tu text NULL,
	mp_dich_kinh text NULL,
	mp_dich_kinh_ton_thuong_khac text NULL,
	mp_day_mat_gai_thi text NULL,
	mp_day_mat_gai_thi2 text NULL,
	mp_day_mat_gai_thi_cd text NULL,
	mp_day_mat_vong_mac text NULL,
	mp_day_mat_he_mach_mau text NULL,
	mp_day_mat_ton_thuong_khac text NULL,
	mt_thi_luc_khong_kinh text NULL,
	mt_thi_luc_qua_lo text NULL,
	mt_thi_luc_co_chinh_kinh text NULL,
	mt_thi_luc_nhin_gan text NULL,
	mt_nhan_ap text NULL,
	mt_lac_van_nhan text NULL,
	mt_le_dao_nuoc_thoat_tot bool NULL,
	mt_le_dao_trao_le_quan_doi_dien bool NULL,
	mt_le_dao_trao_tai_cho bool NULL,
	mt_mi_mat_tinh_trang text NULL,
	mt_mi_mat_seo_sup text NULL,
	mt_mi_mat_khac text NULL,
	mt_mi_mat_u_mi bool NULL,
	mt_mi_mat_u_mi_tinh_chat text NULL,
	mt_mi_mat_u_mi_kich_thuoc text NULL,
	mt_mi_mat_u_mi_vi_tri text NULL,
	mt_mi_mat_quam int4 NULL,
	mt_mi_mat_quam_mi_tren text NULL,
	mt_mi_mat_quam_mi_duoi text NULL,
	mt_mi_mat_ho_mi bool NULL,
	mt_mi_mat_tre_mi bool NULL,
	mt_mi_mat_khuyet_mi text NULL,
	mt_mi_mat_tuyen_bo_mi text NULL,
	mt_mi_mat_ton_thuong_khac text NULL,
	mt_ket_mac_cuong_tu text NULL,
	mt_ket_mac_phu_ne bool NULL,
	mt_ket_mac_xuat_huyet bool NULL,
	mt_ket_mac_sung_hoa bool NULL,
	mt_ket_mac_nhu bool NULL,
	mt_ket_mac_hot bool NULL,
	mt_ket_mac_seo bool NULL,
	mt_ket_mac_tiet_to_mu bool NULL,
	mt_ket_mac_tiet_to_trong bool NULL,
	mt_ket_mac_gia_mac bool NULL,
	mt_ket_mac_bat_mau_fluor bool NULL,
	mt_ket_mac_u_tinh_chat text NULL,
	mt_ket_mac_u_vi_tri text NULL,
	mt_ket_mac_u_kich_thuoc text NULL,
	mt_ket_mac_cung_do text NULL,
	mt_ket_mac_chieu_cao_cau_dinh text NULL,
	mt_ket_mac_do_rong_cau_dinh text NULL,
	mt_ket_mac_ton_thuong_khac text NULL,
	mt_giac_mac_hinh_ve text NULL,
	mt_giac_mac_kich_thuoc text NULL,
	mt_giac_mac_hinh_dang text NULL,
	mt_giac_mac_bm_dang_cham bool NULL,
	mt_giac_mac_bm_phu_bong text NULL,
	mt_giac_mac_bm_mat_bieu_mo text NULL,
	mt_giac_mac_bm_mat_bieu_mo_vt text NULL,
	mt_giac_mac_bm_bo_nham_nho bool NULL,
	mt_giac_mac_bm_bo_ton text NULL,
	mt_giac_mac_bm_thoai_hoa_dai_bang bool NULL,
	mt_giac_mac_bm_lang_dong_thuoc bool NULL,
	mt_giac_mac_bm_ton_thuong_khac text NULL,
	mt_giac_mac_nm_phu text NULL,
	mt_giac_mac_nm_tham_lau text NULL,
	mt_giac_mac_nm_tham_lau_vung text NULL,
	mt_giac_mac_nm_tieu_mong text NULL,
	mt_giac_mac_nm_tieu_mong_vt text NULL,
	mt_giac_mac_nm_ton_thuong_khac text NULL,
	mt_giac_mac_nmd_nep_gap text NULL,
	mt_giac_mac_nmd_tua_sac_to bool NULL,
	mt_giac_mac_nmd_mu_mat_sau bool NULL,
	mt_giac_mac_nmd_xuat_tiet_mat_sau bool NULL,
	mt_giac_mac_nmd_guttata bool NULL,
	mt_giac_mac_nmd_ran_descemet bool NULL,
	mt_giac_mac_nmd_cuon_descemet bool NULL,
	mt_giac_mac_nmd_ton_thuong_khac text NULL,
	mt_giac_mac_doa_thung bool NULL,
	mt_giac_mac_ket_mong_mat bool NULL,
	mt_giac_mac_thung text NULL,
	mt_giac_mac_thung_seidel bool NULL,
	mt_giac_mac_thung_duong_kinh text NULL,
	mt_giac_mac_thung_bit text NULL,
	mt_giac_mac_cam_giac text NULL,
	mt_giac_mac_tan_mach_nong text NULL,
	mt_giac_mac_tan_mach_sau bool NULL,
	mt_giac_mac_tan_mach_muc_do text NULL,
	mt_giac_mac_vung_ria_suy_te_bao bool NULL,
	mt_giac_mac_vung_ria_thoai_hoa_gia bool NULL,
	mt_giac_mac_vung_ria_lang_dong_canxi bool NULL,
	mt_giac_mac_bat_thuong_khac text NULL,
	mt_cung_mac_viem text NULL,
	mt_cung_mac_viem_muc_do text NULL,
	mt_cung_mac_viem_thuong bool NULL,
	mt_cung_mac_gian_loi bool NULL,
	mt_cung_mac_tieu_mong bool NULL,
	mt_cung_mac_hoai_tu bool NULL,
	mt_cung_mac_chi_tiet_khac text NULL,
	mt_tien_phong_tinh_trang text NULL,
	mt_tien_phong_mu text NULL,
	mt_tien_phong_tyndall bool NULL,
	mt_tien_phong_mang_xuat_tiet bool NULL,
	mt_tien_phong_mau text NULL,
	mt_tien_phong_ton_thuong_khac text NULL,
	mt_mong_mat_nau_xop bool NULL,
	mt_mong_mat_xo_teo bool NULL,
	mt_mong_mat_cuong_tu bool NULL,
	mt_mong_mat_tan_mach bool NULL,
	mt_mong_mat_phoi bool NULL,
	mt_mong_mat_ket bool NULL,
	mt_dong_tu_duong_kinh text NULL,
	mt_dong_tu_hinh_dang text NULL,
	mt_dong_tu_vi_tri_dinh text NULL,
	mt_dong_tu_phan_xa text NULL,
	mt_dong_tu_ton_thuong_khac text NULL,
	mt_ttt_binh_thuong bool NULL,
	mt_ttt_hinh_thai_duc text NULL,
	mt_ttt_lech bool NULL,
	mt_ttt_iol text NULL,
	mt_ttt_iol_vi_tri text NULL,
	mt_ttt_ton_thuong_khac text NULL,
	mt_anh_dong_tu text NULL,
	mt_dich_kinh text NULL,
	mt_dich_kinh_ton_thuong_khac text NULL,
	mt_day_mat_gai_thi text NULL,
	mt_day_mat_gai_thi2 text NULL,
	mt_day_mat_gai_thi_cd text NULL,
	mt_day_mat_vong_mac text NULL,
	mt_day_mat_he_mach_mau text NULL,
	mt_day_mat_ton_thuong_khac text NULL,
	can_lam_sang_can_lam text NULL,
	tom_tat_benh_an text NULL,
	tien_luong text NULL,
	huong_dieu_tri text NULL,
	mat_summary_lam_sang text NULL,
	mat_summary_nguyen_nhan text NULL,
	mat_summary_noi_khoa text NULL,
	mat_summary_is_phau_thuat bool NULL,
	mat_summary_is_thu_thuat bool NULL,
	mat_summary_tinh_trang_ra_vien text NULL,
	mat_thi_luc_ra_vien_khong_kinh_mp text NULL,
	mat_thi_luc_ra_vien_khong_kinh_mt text NULL,
	mat_thi_luc_ra_vien_co_kinh_mp text NULL,
	mat_thi_luc_ra_vien_co_kinh_mt text NULL,
	mat_nhan_ap_ra_vien_mp text NULL,
	mat_nhan_ap_ra_vien_mt text NULL,
	mat_summary_huong_dieu_tri_tiep text NULL,
	so_to_x_quang int4 NULL,
	so_to_ct_scanner int4 NULL,
	so_to_sieu_am int4 NULL,
	so_to_xet_nghiem int4 NULL,
	so_to_khac int4 NULL,
	ten_khac text NULL,
	so_to_toan_bo_ho_so int4 NULL,
	nguoi_giao_ho_so text NULL,
	nguoi_nhan_ho_so text NULL,
	thoi_gian_ky_ho_so timestamp NULL,
	bac_si_dieu_tri_ho_so text NULL,
	giam_doc_benh_vien_ho_ten text NULL,
	truong_khoa_ho_ten text NULL,
	truong_khoa_thoi_gian timestamp NULL,
	bac_si_tao_benh_an_ho_ten text NULL,
	bac_si_tao_benh_an_thoi_gian timestamp NULL,
	bi_xoa int2 DEFAULT 0 NOT NULL,
	ngay_tao timestamp NULL,
	nguoi_tao varchar(50) NULL,
	ngay_cap_nhat timestamp NULL,
	nguoi_cap_nhat varchar(50) NULL,
	ngay_xoa timestamp NULL,
	nguoi_xoa varchar(50) NULL,
	icd_benh_chinh_kl_code varchar(255) NULL, -- Mã ICD bệnh chính kết luận
	icd_benh_chinh_kl_name text NULL, -- Tên ICD bệnh chính kết luận
	icd_benh_kem_theo_kl_code varchar(255) NULL, -- Mã ICD bệnh kèm theo kết luận
	icd_benh_kem_theo_kl_name text NULL, -- Tên ICD bệnh kèm theo kết luận
	mp_le_dao_bom_le_quan int4 NULL,
	mt_le_dao_bom_le_quan int4 NULL,
	mp_mi_mat_viemp_bo_mi_chan_long_mi bool NULL, -- Mi mắt - Viêm bờ mi (chân lông mi) - mắt phải
	mt_mi_mat_viemp_bo_mi_chan_long_mi bool NULL, -- Mi mắt - Viêm bờ mi (chân lông mi) - mắt trái
	CONSTRAINT csyt_ba_chuyen_khoa_mat_bpt_pkey PRIMARY KEY (id)
);

CREATE TABLE csyt_ba_chuyen_khoa_mat_ct (
	id uuid DEFAULT gen_random_uuid() NOT NULL,
	benh_an_id uuid NOT NULL,
	ma_cskcb varchar(50) NOT NULL,
	thoi_gian_do timestamp NULL,
	mach int4 NULL,
	nhiet_do numeric(4, 1) NULL,
	huyet_ap_tam_thu int4 NULL,
	huyet_ap_tam_truong int4 NULL,
	spo2 int4 NULL,
	nhip_tho int4 NULL,
	can_nang numeric(5, 2) NULL,
	chieu_cao numeric(5, 2) NULL,
	bmi numeric(5, 2) NULL,
	vong_dau numeric(5, 2) NULL,
	vong_nguc numeric(5, 2) NULL,
	tri_giac text NULL,
	thang_diem_dau int4 NULL,
	tien_su_benh_code varchar(20) NULL,
	tien_su_benh_text text NULL,
	ban_than text NULL,
	gia_dinh text NULL,
	mp_thi_luc_vao_vien_khong_kinh text NULL,
	mp_thi_luc_vao_vien text NULL,
	mp_nhan_ap_vao_vien text NULL,
	mp_co_kinh text NULL,
	mp_mi_mat text NULL,
	mp_sup_mi text NULL,
	mp_sup_mi_do text NULL,
	mp_rach_mi text NULL,
	mp_le_quan text NULL,
	mp_dut_le_quan text NULL,
	mp_le_quan_vi_tri text NULL,
	mp_ket_mac text NULL,
	mp_ket_mac_xuat_huyet text NULL,
	mp_ket_mac_rach text NULL,
	mp_ket_mac_thieu_mau text NULL,
	mp_ket_mac_ton_thuong_khac text NULL,
	mp_ket_mac_mo_ta text NULL,
	mp_giac_mac text NULL,
	mp_giac_mac_seo text NULL,
	mp_giac_mac_di_vat text NULL,
	mp_ton_loan_sau_giac_mac text NULL,
	mp_giac_mac_ngam_mau text NULL,
	mp_giac_mac_abces text NULL,
	mp_giac_mac_trot text NULL,
	mp_giac_mac_loet text NULL,
	mp_giac_mac_rach_kich_thuoc text NULL,
	mp_giac_mac_rach_vi_tri text NULL,
	mp_giac_mac_rach_gon int2 DEFAULT 0 NULL,
	mp_giac_mac_nham_nho int2 DEFAULT 0 NULL,
	mp_giac_mac_mat_to_chuc int2 DEFAULT 0 NULL,
	mp_giac_mac_ket_to_chuc_noi_nhan int2 DEFAULT 0 NULL,
	mp_giac_mac_da_khau int2 DEFAULT 0 NULL,
	mp_giac_mac_dang_giu_phau int2 DEFAULT 0 NULL,
	mp_giac_mac_khong_dung_giac_phau int2 DEFAULT 0 NULL,
	mp_giac_mac_ton_thuong_khac text NULL,
	mp_cung_mac text NULL,
	mp_cung_mac_rach text NULL,
	mp_cung_mac_kich_thuoc text NULL,
	mp_cung_mac_vi_tri text NULL,
	mp_cung_mac_ton_thuong_khac text NULL,
	mp_tien_phong text NULL,
	mp_dich_chan_mong_mat text NULL,
	mp_mat_mong_mat text NULL,
	mp_thang_mong_mat text NULL,
	mp_dong_tui_kich_thuoc text NULL,
	mp_pmdt text NULL,
	mp_tien_phong_mu text NULL,
	mp_tien_phong_di_vat text NULL,
	mp_tien_phong_mau text NULL,
	mp_tien_phong_vi_tri text NULL,
	mp_tien_phong_ton_thuong_khac text NULL,
	mp_anh_dong_tu text NULL,
	mp_khong_quan_sat_duoc int2 DEFAULT 0 NULL,
	mp_the_thuy_tinh text NULL,
	mp_the_thuy_tinh_sa_lech text NULL,
	mp_ra_tien_phong text NULL,
	mp_vao_buong_dich_kinh text NULL,
	mp_the_thuy_tinh_viem_mu text NULL,
	mp_da_dat_iol text NULL,
	mp_the_thuy_tinh_ton_thuong_khac text NULL,
	mp_dich_kinh text NULL,
	mp_bong_dich_kinh_sau text NULL,
	mp_dich_kinh_di_vat text NULL,
	mp_dich_kinh_ton_thuong_khac text NULL,
	mp_vong_mac text NULL,
	mp_ho_mach text NULL,
	mp_dia_thi text NULL,
	mp_vong_mac_phu text NULL,
	mp_vong_mac_xuat_huyet text NULL,
	mp_bong_vong_mac text NULL,
	mp_bong_vong_mac_muc_do text NULL,
	mp_rach_vong_mac text NULL,
	mp_rach_vong_mac_so_luong int4 NULL,
	mp_hoc_mat text NULL,
	mp_hoc_mat_di_vat text NULL,
	mp_hoc_mat_vat_nhan text NULL,
	mp_nhan_cau text NULL,
	mp_nhan_cau_teo int2 DEFAULT 0 NULL,
	mp_nhan_cau_loi int2 DEFAULT 0 NULL,
	mp_nhan_cau_do_loi text NULL,
	mp_vi_tri_vet_dich text NULL,
	mp_hinh_thai text NULL,
	mp_di_vat text NULL,
	mp_di_vat_kich_thuoc text NULL,
	mp_di_vat_vi_tri text NULL,
	mp_ton_thuong_khac text NULL,
	mt_thi_luc_vao_vien_khong_kinh text NULL,
	mt_thi_luc_vao_vien text NULL,
	mt_nhan_ap_vao_vien text NULL,
	mt_co_kinh text NULL,
	mt_mi_mat text NULL,
	mt_sup_mi text NULL,
	mt_sup_mi_do text NULL,
	mt_rach_mi text NULL,
	mt_le_quan text NULL,
	mt_dut_le_quan text NULL,
	mt_le_quan_vi_tri text NULL,
	mt_ket_mac text NULL,
	mt_ket_mac_xuat_huyet text NULL,
	mt_ket_mac_rach text NULL,
	mt_ket_mac_thieu_mau text NULL,
	mt_ket_mac_ton_thuong_khac text NULL,
	mt_ket_mac_mo_ta text NULL,
	mt_giac_mac text NULL,
	mt_giac_mac_seo text NULL,
	mt_giac_mac_di_vat text NULL,
	mt_ton_loan_sau_giac_mac text NULL,
	mt_giac_mac_ngam_mau text NULL,
	mt_giac_mac_abces text NULL,
	mt_giac_mac_trot text NULL,
	mt_giac_mac_loet text NULL,
	mt_giac_mac_rach_kich_thuoc text NULL,
	mt_giac_mac_rach_vi_tri text NULL,
	mt_giac_mac_rach_gon int2 DEFAULT 0 NULL,
	mt_giac_mac_nham_nho int2 DEFAULT 0 NULL,
	mt_giac_mac_mat_to_chuc int2 DEFAULT 0 NULL,
	mt_giac_mac_ket_to_chuc_noi_nhan int2 DEFAULT 0 NULL,
	mt_giac_mac_da_khau int2 DEFAULT 0 NULL,
	mt_giac_mac_dang_giu_phau int2 DEFAULT 0 NULL,
	mt_giac_mac_khong_dung_giac_phau int2 DEFAULT 0 NULL,
	mt_giac_mac_ton_thuong_khac text NULL,
	mt_cung_mac text NULL,
	mt_cung_mac_rach text NULL,
	mt_cung_mac_kich_thuoc text NULL,
	mt_cung_mac_vi_tri text NULL,
	mt_cung_mac_ton_thuong_khac text NULL,
	mt_tien_phong text NULL,
	mt_dich_chan_mong_mat text NULL,
	mt_mat_mong_mat text NULL,
	mt_thang_mong_mat text NULL,
	mt_dong_tui_kich_thuoc text NULL,
	mt_pmdt text NULL,
	mt_tien_phong_mu text NULL,
	mt_tien_phong_di_vat text NULL,
	mt_tien_phong_mau text NULL,
	mt_tien_phong_vi_tri text NULL,
	mt_tien_phong_ton_thuong_khac text NULL,
	mt_anh_dong_tu text NULL,
	mt_khong_quan_sat_duoc int2 DEFAULT 0 NULL,
	mt_the_thuy_tinh text NULL,
	mt_the_thuy_tinh_sa_lech text NULL,
	mt_ra_tien_phong text NULL,
	mt_vao_buong_dich_kinh text NULL,
	mt_the_thuy_tinh_viem_mu text NULL,
	mt_da_dat_iol text NULL,
	mt_the_thuy_tinh_ton_thuong_khac text NULL,
	mt_dich_kinh text NULL,
	mt_bong_dich_kinh_sau text NULL,
	mt_dich_kinh_di_vat text NULL,
	mt_dich_kinh_ton_thuong_khac text NULL,
	mt_vong_mac text NULL,
	mt_ho_mach text NULL,
	mt_dia_thi text NULL,
	mt_vong_mac_phu text NULL,
	mt_vong_mac_xuat_huyet text NULL,
	mt_bong_vong_mac text NULL,
	mt_bong_vong_mac_muc_do text NULL,
	mt_rach_vong_mac text NULL,
	mt_rach_vong_mac_so_luong int4 NULL,
	mt_hoc_mat text NULL,
	mt_hoc_mat_di_vat text NULL,
	mt_hoc_mat_vat_nhan text NULL,
	mt_nhan_cau text NULL,
	mt_nhan_cau_teo int2 DEFAULT 0 NULL,
	mt_nhan_cau_loi int2 DEFAULT 0 NULL,
	mt_nhan_cau_do_loi text NULL,
	mt_vi_tri_vet_dich text NULL,
	mt_hinh_thai text NULL,
	mt_di_vat text NULL,
	mt_di_vat_kich_thuoc text NULL,
	mt_di_vat_vi_tri text NULL,
	mt_ton_thuong_khac text NULL,
	chua_co_bieu_hien_benh_ly int2 DEFAULT 0 NULL,
	benh_ly text NULL,
	cac_xet_nghiem_can_lam text NULL,
	tom_tat text NULL,
	chan_doan_benh_chinh_code varchar(20) NULL,
	chan_doan_benh_chinh_text text NULL,
	chan_doan_kem_theo_code text NULL,
	chan_doan_kem_theo_text text NULL,
	phan_biet text NULL,
	tien_luong text NULL,
	dieu_tri text NULL,
	thoi_gian_bac_si_tao_benh_an timestamp NULL,
	bac_si_tao_benh_an varchar(255) NULL,
	chan_doan_lam_sang text NULL,
	tong_ket_nguyen_nhan text NULL,
	qua_trinh_dieu_tri_noi_khoa text NULL,
	co_phau_thuat int2 DEFAULT 0 NULL,
	co_thu_thuat int2 DEFAULT 0 NULL,
	danh_sach_phau_thuat text NULL,
	tinh_trang_nguoi_benh_ra_vien text NULL,
	thi_luc_ra_vien_khong_kinh_mp text NULL,
	thi_luc_ra_vien_mt text NULL,
	nhan_ap_ra_vien_mp text NULL,
	nhan_ap_ra_vien_mt text NULL,
	co_kinh_ra_vien_mp text NULL,
	co_kinh_ra_vien_mt text NULL,
	huong_dieu_tri_tiep text NULL,
	so_to_x_quang int4 NULL,
	so_to_ct_scanner int4 NULL,
	so_to_sieu_am int4 NULL,
	so_to_xet_nghiem int4 NULL,
	so_to_khac int4 NULL,
	so_to_toan_bo_ho_so int4 NULL,
	nguoi_giao_ho_so varchar(255) NULL,
	nguoi_nhan_ho_so varchar(255) NULL,
	thoi_gian_giao_ho_so timestamp NULL,
	bac_si_dieu_tri varchar(255) NULL,
	bi_xoa int2 DEFAULT 0 NULL,
	ngay_tao timestamp DEFAULT CURRENT_TIMESTAMP NULL,
	nguoi_tao varchar(100) NULL,
	ngay_cap_nhat timestamp NULL,
	nguoi_cap_nhat varchar(100) NULL,
	ngay_xoa timestamp NULL, -- Ngày xóa
	nguoi_xoa varchar(50) NULL, -- Người xóa
	qua_trinh_benh_ly text NULL, -- Quá trình bệnh lý
	tien_su_mat text NULL, -- Tiền sử mắt
	tien_su_toan_than text NULL, -- Tiền sử toàn thân
	mat_thi_luc_khong_kinh_mp text NULL, -- Thị lực không kính mắt phải
	mat_thi_luc_khong_kinh_mt text NULL, -- Thị lực không kính mắt trái
	mat_thi_luc_co_kinh_mp text NULL,
	mat_thi_luc_co_kinh_mt text NULL,
	mat_nhan_ap_mp text NULL,
	mat_nhan_ap_mt text NULL,
	mat_thi_truong_mp text NULL,
	mat_thi_truong_mt text NULL,
	mp_mi_mat_binh_thuong int2 NULL,
	mp_mi_mat_tu_mau_sung_ne int2 NULL,
	mp_mi_mat_sup_mi int2 NULL,
	mp_mi_mat_sup_mi_do text NULL,
	mp_mi_mat_rach int2 NULL,
	mp_mi_mat_rach_loai text NULL,
	mp_mi_mat_rach_khau text NULL,
	mp_mi_mat_le_quan int2 NULL,
	mp_mi_mat_le_quan_loai text NULL,
	mp_mi_mat_le_quan_vi_tri text NULL,
	mp_mi_mat_seo_mi int2 NULL,
	mp_mi_mat_seo_mi_mo_ta text NULL,
	mp_mi_mat_ton_thuong_khac int2 NULL,
	mp_mi_mat_ton_thuong_khac_mo_ta text NULL,
	mp_ket_mac_binh_thuong int2 NULL,
	mp_ket_mac_cuong_tu int2 NULL,
	mp_ket_mac_cuong_tu_ct int2 NULL,
	mp_ket_mac_cuong_tu_mo_ta text NULL,
	mp_ket_mac_rach_km int2 NULL,
	mp_ket_mac_rach_km_mo_ta text NULL,
	mp_ket_mac_thieu_mau_mo_ta text NULL,
	mp_ket_mac_ton_thuong_khac_mo_ta text NULL,
	mp_hinh_ve_ton_thuong text NULL,
	mp_giac_mac_trong int2 NULL,
	mp_giac_mac_phu int2 NULL,
	mp_giac_mac_seo_mo_ta text NULL,
	mp_giac_mac_di_vat_mo_ta text NULL,
	mp_giac_mac_tua_mat_sau int2 NULL,
	mp_giac_mac_tua text NULL,
	mp_giac_mac_rach int2 NULL,
	mp_giac_mac_rach_loai text NULL,
	mp_giac_mac_rach_khau text NULL,
	mp_giac_mac_ton_thuong_khac_mo_ta text NULL,
	mp_cung_mac_binh_thuong int2 NULL,
	mp_cung_mac_gian_loi int2 NULL,
	mp_cung_mac_rach_loai text NULL,
	mp_cung_mac_rach_kich_thuoc varchar(100) NULL,
	mp_cung_mac_rach_vi_tri varchar(255) NULL,
	mp_cung_mac_ton_thuong_khac_mo_ta text NULL,
	mp_tien_phong_binh_thuong int2 NULL,
	mp_tien_phong_xep int2 NULL,
	mp_tien_phong_chat_ttt int2 NULL,
	mp_tien_phong_mu_mo_ta text NULL,
	mp_tien_phong_tyndall int2 NULL,
	mp_tien_phong_tyndall_mo_ta text NULL,
	mp_tien_phong_xuat_tiet int2 NULL,
	mp_tien_phong_xuat_tiet_mo_ta text NULL,
	mp_tien_phong_xuat_huyet int2 NULL,
	mp_tien_phong_xuat_huyet_muc_do text NULL,
	mp_tien_phong_di_vat_mo_ta text NULL,
	mp_tien_phong_ton_thuong_khac_mo_ta text NULL,
	mp_mong_mat_binh_thuong int2 NULL,
	mp_mong_mat_thoai_hoa int2 NULL,
	mp_mong_mat_dut_chan int2 NULL,
	mp_mong_mat_dut_chan_mo_ta text NULL,
	mp_mong_mat_mat int2 NULL,
	mp_mong_mat_mat_mo_ta text NULL,
	mp_mong_mat_thung int2 NULL,
	mp_mong_mat_thung_mo_ta text NULL,
	mp_mong_mat_dong_tu int2 NULL,
	mp_mong_mat_dong_tu_kich_thuoc text NULL,
	mp_mong_mat_pxdt int2 NULL,
	mp_mong_mat_pxdt_gia_tri int4 NULL,
	mp_mong_mat_tron int2 NULL,
	mp_mong_mat_meo int2 NULL,
	mp_mong_mat_dinh int2 NULL,
	mp_mong_mat_dinh_vi_tri text NULL,
	mp_mong_mat_gian_liet int2 NULL,
	mp_mong_mat_anh_dong_tu int2 NULL,
	mp_mong_mat_anh_dong_tu_mo_ta text NULL,
	mp_mong_mat_khong_quan_sat int2 NULL,
	mp_ttt_trong int2 NULL,
	mp_ttt_duc int2 NULL,
	mp_ttt_vo int2 NULL,
	mp_ttt_di_vat int2 NULL,
	mp_ttt_sa_lech int2 NULL,
	mp_ttt_ra_tien_phong int2 NULL,
	mp_ttt_vao_buong_dich_kinh int2 NULL,
	mp_ttt_viem_mu int2 NULL,
	mp_ttt_dat_iol int2 NULL,
	mp_ttt_dat_iol_mo_ta text NULL,
	mp_ttt_ton_thuong_khac int2 NULL,
	mp_ttt_ton_thuong_khac_mo_ta text NULL,
	mp_dich_kinh_duc int2 NULL,
	mp_dich_kinh_viem_mu int2 NULL,
	mp_dich_kinh_xuat_huyet int2 NULL,
	mp_dich_kinh_to_chuc_hoa int2 NULL,
	mp_dich_kinh_bong_sau int2 NULL,
	mp_dich_kinh_ton_thuong_khac_mo_ta text NULL,
	mp_vong_mac_he_mach int2 NULL,
	mp_vong_mac_he_mach_mo_ta text NULL,
	mp_vong_mac_dia_thi int2 NULL,
	mp_vong_mac_dia_thi_mo_ta text NULL,
	mp_vong_mac_phu_mo_ta text NULL,
	mp_vong_mac_xuat_huyet_mo_ta text NULL,
	mp_vong_mac_bong int2 NULL,
	mp_vong_mac_bong_co int4 NULL,
	mp_vong_mac_bong_muc_do varchar(255) NULL,
	mp_vong_mac_rach int2 NULL,
	mp_vong_mac_rach_co int4 NULL,
	mp_vong_mac_rach_so_luong text NULL,
	mp_vong_mac_rach_hinh_thai text NULL,
	mp_vong_mac_vi_tri_vet_rach int2 NULL,
	mp_vong_mac_vi_tri_vet_rach_mo_ta text NULL,
	mp_vong_mac_di_vat int2 NULL,
	mp_vong_mac_di_vat_kich_thuoc text NULL,
	mp_vong_mac_di_vat_vi_tri text NULL,
	mp_vong_mac_ton_thuong_khac int2 NULL,
	mp_vong_mac_ton_thuong_khac_mo_ta text NULL,
	mp_hinh_ve_vong_mac text NULL,
	mp_hoc_mat_binh_thuong int2 NULL,
	mp_hoc_mat_benh_ly int2 NULL,
	mp_hoc_mat_benh_ly_mo_ta text NULL,
	mp_hoc_mat_di_vat_mo_ta text NULL,
	mp_hoc_mat_van_nhan int2 NULL,
	mp_hoc_mat_van_nhan_binh_thuong int2 NULL,
	mp_hoc_mat_van_nhan_benh_ly int2 NULL,
	mp_hoc_mat_van_nhan_benh_ly_mo_ta text NULL,
	mp_hoc_mat_nhan_cau int2 NULL,
	mp_hoc_mat_nhan_cau_teo int2 NULL,
	mp_hoc_mat_nhan_cau_loi int2 NULL,
	mp_hoc_mat_nhan_cau_do_loi text NULL,
	mt_mi_mat_binh_thuong int2 NULL,
	mt_mi_mat_tu_mau_sung_ne int2 NULL,
	mt_mi_mat_sup_mi int2 NULL,
	mt_mi_mat_sup_mi_do text NULL,
	mt_mi_mat_rach int2 NULL,
	mt_mi_mat_rach_loai text NULL,
	mt_mi_mat_rach_khau text NULL,
	mt_mi_mat_le_quan int2 NULL,
	mt_mi_mat_le_quan_loai text NULL,
	mt_mi_mat_le_quan_vi_tri text NULL,
	mt_mi_mat_seo_mi int2 NULL,
	mt_mi_mat_seo_mi_mo_ta text NULL,
	mt_mi_mat_ton_thuong_khac int2 NULL,
	mt_mi_mat_ton_thuong_khac_mo_ta text NULL,
	mt_ket_mac_binh_thuong int2 NULL,
	mt_ket_mac_cuong_tu int2 NULL,
	mt_ket_mac_cuong_tu_ct int2 NULL,
	mt_ket_mac_cuong_tu_mo_ta text NULL,
	mt_ket_mac_rach_km int2 NULL,
	mt_ket_mac_rach_km_mo_ta text NULL,
	mt_ket_mac_thieu_mau_mo_ta text NULL,
	mt_ket_mac_ton_thuong_khac_mo_ta text NULL,
	mt_hinh_ve_ton_thuong text NULL,
	mt_giac_mac_trong int2 NULL,
	mt_giac_mac_phu int2 NULL,
	mt_giac_mac_seo_mo_ta text NULL,
	mt_giac_mac_di_vat_mo_ta text NULL,
	mt_giac_mac_tua_mat_sau int2 NULL,
	mt_giac_mac_tua text NULL,
	mt_giac_mac_rach int2 NULL,
	mt_giac_mac_rach_loai text NULL,
	mt_giac_mac_rach_khau text NULL,
	mt_giac_mac_ton_thuong_khac_mo_ta text NULL,
	mt_cung_mac_binh_thuong int2 NULL,
	mt_cung_mac_gian_loi int2 NULL,
	mt_cung_mac_rach_loai text NULL,
	mt_cung_mac_rach_kich_thuoc varchar(100) NULL,
	mt_cung_mac_rach_vi_tri varchar(255) NULL,
	mt_cung_mac_ton_thuong_khac_mo_ta text NULL,
	mt_tien_phong_binh_thuong int2 NULL,
	mt_tien_phong_xep int2 NULL,
	mt_tien_phong_chat_ttt int2 NULL,
	mt_tien_phong_mu_mo_ta text NULL,
	mt_tien_phong_tyndall int2 NULL,
	mt_tien_phong_tyndall_mo_ta text NULL,
	mt_tien_phong_xuat_tiet int2 NULL,
	mt_tien_phong_xuat_tiet_mo_ta text NULL,
	mt_tien_phong_xuat_huyet int2 NULL,
	mt_tien_phong_xuat_huyet_muc_do text NULL,
	mt_tien_phong_di_vat_mo_ta text NULL,
	mt_tien_phong_ton_thuong_khac_mo_ta text NULL,
	mt_mong_mat_binh_thuong int2 NULL,
	mt_mong_mat_thoai_hoa int2 NULL,
	mt_mong_mat_dut_chan int2 NULL,
	mt_mong_mat_dut_chan_mo_ta text NULL,
	mt_mong_mat_mat int2 NULL,
	mt_mong_mat_mat_mo_ta text NULL,
	mt_mong_mat_thung int2 NULL,
	mt_mong_mat_thung_mo_ta text NULL,
	mt_mong_mat_dong_tu int2 NULL,
	mt_mong_mat_dong_tu_kich_thuoc text NULL,
	mt_mong_mat_pxdt int2 NULL,
	mt_mong_mat_pxdt_gia_tri int4 NULL,
	mt_mong_mat_tron int2 NULL,
	mt_mong_mat_meo int2 NULL,
	mt_mong_mat_dinh int2 NULL,
	mt_mong_mat_dinh_vi_tri text NULL,
	mt_mong_mat_gian_liet int2 NULL,
	mt_mong_mat_anh_dong_tu int2 NULL,
	mt_mong_mat_anh_dong_tu_mo_ta text NULL,
	mt_mong_mat_khong_quan_sat int2 NULL,
	mt_ttt_trong int2 NULL,
	mt_ttt_duc int2 NULL,
	mt_ttt_vo int2 NULL,
	mt_ttt_di_vat int2 NULL,
	mt_ttt_sa_lech int2 NULL,
	mt_ttt_ra_tien_phong int2 NULL,
	mt_ttt_vao_buong_dich_kinh int2 NULL,
	mt_ttt_viem_mu int2 NULL,
	mt_ttt_dat_iol int2 NULL,
	mt_ttt_dat_iol_mo_ta text NULL,
	mt_ttt_ton_thuong_khac int2 NULL,
	mt_ttt_ton_thuong_khac_mo_ta text NULL,
	mt_dich_kinh_duc int2 NULL,
	mt_dich_kinh_viem_mu int2 NULL,
	mt_dich_kinh_xuat_huyet int2 NULL,
	mt_dich_kinh_to_chuc_hoa int2 NULL,
	mt_dich_kinh_bong_sau int2 NULL,
	mt_dich_kinh_ton_thuong_khac_mo_ta text NULL,
	mt_vong_mac_he_mach int2 NULL,
	mt_vong_mac_he_mach_mo_ta text NULL,
	mt_vong_mac_dia_thi int2 NULL,
	mt_vong_mac_dia_thi_mo_ta text NULL,
	mt_vong_mac_phu_mo_ta text NULL,
	mt_vong_mac_xuat_huyet_mo_ta text NULL,
	mt_vong_mac_bong int2 NULL,
	mt_vong_mac_bong_co int4 NULL,
	mt_vong_mac_bong_muc_do varchar(255) NULL,
	mt_vong_mac_rach int2 NULL,
	mt_vong_mac_rach_co int4 NULL,
	mt_vong_mac_rach_so_luong text NULL,
	mt_vong_mac_rach_hinh_thai text NULL,
	mt_vong_mac_vi_tri_vet_rach int2 NULL,
	mt_vong_mac_vi_tri_vet_rach_mo_ta text NULL,
	mt_vong_mac_di_vat int2 NULL,
	mt_vong_mac_di_vat_kich_thuoc text NULL,
	mt_vong_mac_di_vat_vi_tri text NULL,
	mt_vong_mac_ton_thuong_khac int2 NULL,
	mt_vong_mac_ton_thuong_khac_mo_ta text NULL,
	mt_hinh_ve_vong_mac text NULL,
	mt_hoc_mat_binh_thuong int2 NULL,
	mt_hoc_mat_benh_ly int2 NULL,
	mt_hoc_mat_benh_ly_mo_ta text NULL,
	mt_hoc_mat_di_vat_mo_ta text NULL,
	mt_hoc_mat_van_nhan int2 NULL,
	mt_hoc_mat_van_nhan_binh_thuong int2 NULL,
	mt_hoc_mat_van_nhan_benh_ly int2 NULL,
	mt_hoc_mat_van_nhan_benh_ly_mo_ta text NULL,
	mt_hoc_mat_nhan_cau int2 NULL,
	mt_hoc_mat_nhan_cau_teo int2 NULL,
	mt_hoc_mat_nhan_cau_loi int2 NULL,
	mt_hoc_mat_nhan_cau_do_loi text NULL,
	mat_toan_than_chua_bieu_hien text NULL,
	mat_toan_than_benh_ly text NULL,
	can_lam_sang_can_lam text NULL,
	tom_tat_benh_an text NULL,
	mat_summary_lam_sang text NULL, -- Tổng kết - Chẩn đoán lâm sàng
	mat_summary_nguyen_nhan text NULL, -- Tổng kết - Nguyên nhân
	mat_summary_noi_khoa text NULL,
	mat_summary_is_phau_thuat int2 NULL,
	mat_summary_is_thu_thuat int2 NULL,
	mat_summary_tinh_trang_ra_vien text NULL,
	mat_summary_huong_dieu_tri_tiep text NULL,
	mat_thi_luc_ra_vien_khong_kinh_mp text NULL,
	mat_thi_luc_ra_vien_khong_kinh_mt text NULL,
	mat_thi_luc_ra_vien_co_kinh_mp text NULL,
	mat_thi_luc_ra_vien_co_kinh_mt text NULL,
	mat_nhan_ap_ra_vien_mp text NULL,
	mat_nhan_ap_ra_vien_mt text NULL,
	ten_khac varchar(255) NULL,
	thoi_gian_ky_ho_so timestamp NULL,
	bac_si_dieu_tri_ho_so varchar(255) NULL,
	giam_doc_benh_vien_ho_ten varchar(255) NULL, -- Họ tên Giám đốc bệnh viện
	truong_khoa_ho_ten varchar(255) NULL, -- Họ tên Trưởng khoa
	truong_khoa_thoi_gian timestamp NULL,
	bac_si_tao_benh_an_ho_ten varchar(255) NULL, -- Họ tên Bác sĩ tạo bệnh án
	bac_si_tao_benh_an_thoi_gian timestamp NULL,
	tien_su_gia_dinh text NULL, -- Tiền sử gia đình
	CONSTRAINT csyt_ba_chuyen_khoa_mat_ct_pkey PRIMARY KEY (id)
);

CREATE TABLE csyt_ba_chuyen_khoa_mat_dm (
	id uuid DEFAULT gen_random_uuid() NOT NULL,
	benh_an_id uuid NULL, -- FK csyt_benh_an_dieu_tri.id
	ma_cskcb varchar(50) NULL,
	qua_trinh_benh_ly text NULL,
	tien_su_ban_than text NULL,
	tien_su_gia_dinh text NULL,
	mp_thi_luc_vv_khong_kinh text NULL,
	mt_thi_luc_vv_khong_kinh text NULL,
	mp_thi_luc_vv_co_kinh text NULL,
	mt_thi_luc_vv_co_kinh text NULL,
	mp_nhan_ap_vv text NULL,
	mt_nhan_ap_vv text NULL,
	mp_thi_truong text NULL,
	mt_thi_truong text NULL,
	mp_mi_mat text NULL,
	mp_mi_mat_benh_ly_khac text NULL,
	mp_ket_mac text NULL,
	mp_ket_mac_xuat_huyet bool NULL,
	mp_ket_mac_xuat_huyet_mo_ta text NULL,
	mp_ket_mac_seo_km bool NULL,
	mp_ket_mac_seo_km_mo_ta text NULL,
	mp_ket_mac_benh_ly_khac text NULL,
	mp_giac_mac text NULL,
	mp_giac_mac_tua text NULL,
	mp_giac_mac_vi_tri_tua text NULL,
	mp_giac_mac_seo_gm bool NULL,
	mp_giac_mac_benh_ly_khac text NULL,
	mp_cung_mac text NULL,
	mp_cung_mac_benh_ly_khac text NULL,
	mp_tien_phong text NULL,
	mp_tien_phong_xuat_huyet bool NULL,
	mp_tien_phong_xuat_huyet_do text NULL,
	mp_tien_phong_mu_xuat_tiet bool NULL,
	mp_tien_phong_mu_xuat_tiet_muc_do text NULL,
	mp_tien_phong_tyndall bool NULL,
	mp_tien_phong_tyndall_do text NULL,
	mp_tien_phong_goc text NULL,
	mp_tien_phong_ton_thuong_khac text NULL,
	mp_mong_mat text NULL,
	mp_mong_mat_tan_mach bool NULL,
	mp_mong_mat_tan_mach_mo_ta text NULL,
	mp_mong_mat_koeppi bool NULL,
	mp_mong_mat_koeppi_mo_ta text NULL,
	mp_mong_mat_busaca bool NULL,
	mp_mong_mat_busaca_mo_ta text NULL,
	mp_dong_tu_anh text NULL,
	mp_dong_tu_kich_thuoc text NULL,
	mp_dong_tu_tron bool NULL,
	mp_dong_tu_meo bool NULL,
	mp_dong_tu_dinh bool NULL,
	mp_dong_tu_vi_tri text NULL,
	mp_pxdt_co bool NULL,
	mp_pxdt_khong bool NULL,
	mp_pxdt_gian_liet bool NULL,
	mp_mong_mat_benh_ly_khac text NULL,
	mp_ttt_tinh_trang text NULL,
	mp_ttt_ton_that text NULL,
	mp_ttt_ton_thuong_khac text NULL,
	mp_dich_kinh_sach bool NULL,
	mp_dich_kinh_tyndall bool NULL,
	mp_dich_kinh_tyndall_mo_ta text NULL,
	mp_dich_kinh_viem_mu bool NULL,
	mp_dich_kinh_viem_mu_mo_ta text NULL,
	mp_dich_kinh text NULL,
	mp_dich_kinh_ton_thuong_khac text NULL,
	mp_vm_he_mach_binh_thuong bool NULL,
	mp_vm_tac_dm text NULL,
	mp_vm_tac_tm text NULL,
	mp_vm_viem_mao_mach bool NULL,
	mp_vm_tan_mach_vm bool NULL,
	mp_vm_tan_mach_hm text NULL,
	mp_vm_dia_thi text NULL,
	mp_vm_tan_mach_gai text NULL,
	mp_vm_hoang_diem text NULL,
	mp_vm_hd_phu text NULL,
	mp_vm_hd_lo_do text NULL,
	mp_vm_hd_lo_lop bool NULL,
	mp_vm_hd_gia_lo bool NULL,
	mp_vm_hd_seo text NULL,
	mp_vm_thoai_hoa text NULL,
	mp_vm_hinh_thai_thoai_hoa text NULL,
	mp_vm_xuat_huyet text NULL,
	mp_vm_xuat_tiet text NULL,
	mp_vm_bong_thanh_dich bool NULL,
	mp_vm_bong_bmst bool NULL,
	mp_vm_o_viem_hoat_tinh bool NULL,
	mp_vm_o_viem_seo bool NULL,
	mp_vm_o_viem_so_luong text NULL,
	mp_vm_o_viem_vi_tri text NULL,
	mp_vm_bong_vm bool NULL,
	mp_vm_bong_vm_muc_do text NULL,
	mp_vm_rach_vm bool NULL,
	mp_vm_rach_vm_so_luong text NULL,
	mp_vm_vi_tri_vet_rach text NULL,
	mp_vm_hinh_thai_rach text NULL,
	mp_vm_ton_thuong_phoi_hop text NULL,
	mp_vm_benh_ly_khac text NULL,
	mp_hoc_mat_binh_thuong bool NULL,
	mp_hoc_mat_benh_ly bool NULL,
	mp_hoc_mat_benh_ly_mo_ta text NULL,
	mp_hoc_mat_vat_nhan_binh_thuong bool NULL,
	mp_hoc_mat_vat_nhan_benh_ly bool NULL,
	mp_hoc_mat_vat_nhan_mo_ta text NULL,
	mt_mi_mat text NULL,
	mt_mi_mat_benh_ly_khac text NULL,
	mt_ket_mac text NULL,
	mt_ket_mac_xuat_huyet bool NULL,
	mt_ket_mac_xuat_huyet_mo_ta text NULL,
	mt_ket_mac_seo_km bool NULL,
	mt_ket_mac_seo_km_mo_ta text NULL,
	mt_ket_mac_benh_ly_khac text NULL,
	mt_giac_mac text NULL,
	mt_giac_mac_tua text NULL,
	mt_giac_mac_vi_tri_tua text NULL,
	mt_giac_mac_seo_gm bool NULL,
	mt_giac_mac_benh_ly_khac text NULL,
	mt_cung_mac text NULL,
	mt_cung_mac_benh_ly_khac text NULL,
	mt_tien_phong text NULL,
	mt_tien_phong_xuat_huyet bool NULL,
	mt_tien_phong_xuat_huyet_do text NULL,
	mt_tien_phong_mu_xuat_tiet bool NULL,
	mt_tien_phong_mu_xuat_tiet_muc_do text NULL,
	mt_tien_phong_tyndall bool NULL,
	mt_tien_phong_tyndall_do text NULL,
	mt_tien_phong_goc text NULL,
	mt_tien_phong_ton_thuong_khac text NULL,
	mt_mong_mat text NULL,
	mt_mong_mat_tan_mach bool NULL,
	mt_mong_mat_tan_mach_mo_ta text NULL,
	mt_mong_mat_koeppi bool NULL,
	mt_mong_mat_koeppi_mo_ta text NULL,
	mt_mong_mat_busaca bool NULL,
	mt_mong_mat_busaca_mo_ta text NULL,
	mt_dong_tu_anh text NULL,
	mt_dong_tu_kich_thuoc text NULL,
	mt_dong_tu_tron bool NULL,
	mt_dong_tu_meo bool NULL,
	mt_dong_tu_dinh bool NULL,
	mt_dong_tu_vi_tri text NULL,
	mt_pxdt_co bool NULL,
	mt_pxdt_khong bool NULL,
	mt_pxdt_gian_liet bool NULL,
	mt_mong_mat_benh_ly_khac text NULL,
	mt_ttt_tinh_trang text NULL,
	mt_ttt_ton_that text NULL,
	mt_ttt_ton_thuong_khac text NULL,
	mt_dich_kinh_sach bool NULL,
	mt_dich_kinh_tyndall bool NULL,
	mt_dich_kinh_tyndall_mo_ta text NULL,
	mt_dich_kinh_viem_mu bool NULL,
	mt_dich_kinh_viem_mu_mo_ta text NULL,
	mt_dich_kinh text NULL,
	mt_dich_kinh_ton_thuong_khac text NULL,
	mt_vm_he_mach_binh_thuong bool NULL,
	mt_vm_tac_dm text NULL,
	mt_vm_tac_tm text NULL,
	mt_vm_viem_mao_mach bool NULL,
	mt_vm_tan_mach_vm bool NULL,
	mt_vm_tan_mach_hm text NULL,
	mt_vm_dia_thi text NULL,
	mt_vm_tan_mach_gai text NULL,
	mt_vm_hoang_diem text NULL,
	mt_vm_hd_phu text NULL,
	mt_vm_hd_lo_do text NULL,
	mt_vm_hd_lo_lop bool NULL,
	mt_vm_hd_gia_lo bool NULL,
	mt_vm_hd_seo text NULL,
	mt_vm_thoai_hoa text NULL,
	mt_vm_hinh_thai_thoai_hoa text NULL,
	mt_vm_xuat_huyet text NULL,
	mt_vm_xuat_tiet text NULL,
	mt_vm_bong_thanh_dich bool NULL,
	mt_vm_bong_bmst bool NULL,
	mt_vm_o_viem_hoat_tinh bool NULL,
	mt_vm_o_viem_seo bool NULL,
	mt_vm_o_viem_so_luong text NULL,
	mt_vm_o_viem_vi_tri text NULL,
	mt_vm_bong_vm bool NULL,
	mt_vm_bong_vm_muc_do text NULL,
	mt_vm_rach_vm bool NULL,
	mt_vm_rach_vm_so_luong text NULL,
	mt_vm_vi_tri_vet_rach text NULL,
	mt_vm_hinh_thai_rach text NULL,
	mt_vm_ton_thuong_phoi_hop text NULL,
	mt_vm_benh_ly_khac text NULL,
	mt_hoc_mat_binh_thuong bool NULL,
	mt_hoc_mat_benh_ly bool NULL,
	mt_hoc_mat_benh_ly_mo_ta text NULL,
	mt_hoc_mat_vat_nhan_binh_thuong bool NULL,
	mt_hoc_mat_vat_nhan_benh_ly bool NULL,
	mt_hoc_mat_vat_nhan_mo_ta text NULL,
	mat_toan_than_chua_bieu_hien text NULL,
	mat_toan_than_benh_ly text NULL,
	mat_tt_tiet_nieu_binh_thuong bool NULL,
	mat_tt_tiet_nieu_co_benh bool NULL,
	mat_tt_tiet_nieu_mo_ta text NULL,
	can_lam_sang_can_lam text NULL,
	tom_tat_benh_an text NULL,
	tien_luong text NULL,
	huong_dieu_tri text NULL,
	mat_summary_lam_sang text NULL,
	mat_summary_nguyen_nhan text NULL,
	mat_summary_noi_khoa text NULL,
	mat_summary_is_phau_thuat bool NULL,
	mat_summary_is_thu_thuat bool NULL,
	mat_summary_tinh_trang_ra_vien text NULL,
	mat_thi_luc_ra_vien_khong_kinh_mp text NULL,
	mat_thi_luc_ra_vien_khong_kinh_mt text NULL,
	mat_thi_luc_ra_vien_co_kinh_mp text NULL,
	mat_thi_luc_ra_vien_co_kinh_mt text NULL,
	mat_nhan_ap_ra_vien_mp text NULL,
	mat_nhan_ap_ra_vien_mt text NULL,
	mat_summary_huong_dieu_tri_tiep text NULL,
	so_to_x_quang int4 NULL,
	so_to_ct_scanner int4 NULL,
	so_to_sieu_am int4 NULL,
	so_to_xet_nghiem int4 NULL,
	so_to_khac int4 NULL,
	ten_khac text NULL,
	so_to_toan_bo_ho_so int4 NULL,
	nguoi_giao_ho_so text NULL,
	nguoi_nhan_ho_so text NULL,
	thoi_gian_ky_ho_so timestamp NULL,
	bac_si_dieu_tri_ho_so text NULL,
	giam_doc_benh_vien_ho_ten text NULL,
	truong_khoa_ho_ten text NULL,
	truong_khoa_thoi_gian timestamp NULL,
	bac_si_tao_benh_an_ho_ten text NULL,
	bac_si_tao_benh_an_thoi_gian timestamp NULL,
	bi_xoa int2 DEFAULT 0 NOT NULL,
	ngay_tao timestamp NULL,
	nguoi_tao varchar(50) NULL,
	ngay_cap_nhat timestamp NULL,
	nguoi_cap_nhat varchar(50) NULL,
	ngay_xoa timestamp NULL,
	nguoi_xoa varchar(50) NULL,
	icd_benh_chinh_kl_code varchar(255) NULL, -- Mã ICD bệnh chính kết luận
	icd_benh_chinh_kl_name text NULL, -- Tên ICD bệnh chính kết luận
	icd_benh_kem_theo_kl_code varchar(255) NULL, -- Mã ICD bệnh kèm theo kết luận
	icd_benh_kem_theo_kl_name text NULL, -- Tên ICD bệnh kèm theo kết luận
	CONSTRAINT csyt_ba_chuyen_khoa_mat_dm_pkey PRIMARY KEY (id)
);

CREATE TABLE csyt_ba_chuyen_khoa_mat_glocom (
	id uuid DEFAULT gen_random_uuid() NOT NULL,
	benh_an_id uuid NULL, -- FK csyt_benh_an_dieu_tri.id
	ma_cskcb varchar(50) NULL,
	mat_ly_do_nhuc_mat text NULL,
	mat_ly_do_nhin text NULL,
	mat_ly_do_so_anh_sang text NULL,
	mat_ly_do_do_mat text NULL,
	mat_ly_do_toan_than text NULL,
	mat_ly_do_toan_than_khac text NULL,
	mat_ly_do_trieu_chung_khac text NULL,
	mat_qt_thoi_gian_xuat_hien text NULL,
	mat_qt_co_so_y_te text NULL,
	mat_qt_phuong_phap_dieu_tri text NULL,
	mp_pt_lan1_loai text NULL,
	mp_pt_lan1_thoi_diem timestamp NULL,
	mp_pt_lan1_noi text NULL,
	mp_pt_lan2_loai text NULL,
	mp_pt_lan2_thoi_diem timestamp NULL,
	mp_pt_lan2_noi text NULL,
	mp_pt_lan3_loai text NULL,
	mp_pt_lan3_thoi_diem timestamp NULL,
	mp_pt_lan3_noi text NULL,
	mp_pt_lan4_loai text NULL,
	mp_pt_lan4_thoi_diem timestamp NULL,
	mp_pt_lan4_noi text NULL,
	mt_pt_lan1_loai text NULL,
	mt_pt_lan1_thoi_diem timestamp NULL,
	mt_pt_lan1_noi text NULL,
	mt_pt_lan2_loai text NULL,
	mt_pt_lan2_thoi_diem timestamp NULL,
	mt_pt_lan2_noi text NULL,
	mt_pt_lan3_loai text NULL,
	mt_pt_lan3_thoi_diem timestamp NULL,
	mt_pt_lan3_noi text NULL,
	mt_pt_lan4_loai text NULL,
	mt_pt_lan4_thoi_diem timestamp NULL,
	mt_pt_lan4_noi text NULL,
	mat_qt_thuoc_duong_dung text NULL,
	mat_qt_thuoc_so_luong text NULL,
	mat_qt_thuoc_list text NULL, -- Danh sach thuoc da dung luu dang JSON.
	mat_qt_thuoc_khac text NULL,
	mat_qt_tien_trinh_dieu_tri text NULL,
	mat_ts_benh_mat text NULL,
	mat_ts_da_pt_mat bool NULL,
	mat_ts_da_pt_mat_mo_ta text NULL,
	mat_ts_benh_khac bool NULL,
	mat_ts_benh_khac_mo_ta text NULL,
	mat_ts_corticoid bool NULL,
	mat_ts_corticoid_ten_thuoc text NULL,
	mat_ts_corticoid_thoi_gian text NULL,
	mat_ts_corticoid_duong_dung text NULL,
	mat_ts_corticoid_chi_dinh text NULL,
	mat_ts_toan_than text NULL,
	mat_ts_toan_than_khac bool NULL,
	mat_ts_toan_than_khac_mo_ta text NULL,
	mat_ts_gia_dinh_glocom text NULL,
	mp_thi_luc_khong_kinh text NULL,
	mp_thi_luc_co_kinh text NULL,
	mp_nhan_ap text NULL,
	mp_mi_mat_sung_ne text NULL,
	mp_mi_mat_khac text NULL,
	mp_ket_mac_cuong_tu text NULL,
	mp_ket_mac_seo_mo_cu_khong bool NULL,
	mp_ket_mac_seo_mo_cu_co bool NULL,
	mp_ket_mac_seo_mo_cu_mo_ta text NULL,
	mp_ket_mac_bong_do text NULL,
	mp_giac_mac_trong_suot text NULL,
	mp_giac_mac_phu_ne_khong bool NULL,
	mp_giac_mac_phu_ne_co bool NULL,
	mp_giac_mac_phu_ne_muc_do text NULL,
	mp_giac_mac_do_day text NULL,
	mp_giac_mac_tua text NULL,
	mp_giac_mac_duong_kinh text NULL,
	mp_cung_mac_dan_loi text NULL,
	mp_cung_mac_seo_mo_khong bool NULL,
	mp_cung_mac_seo_mo_co bool NULL,
	mp_cung_mac_seo_mo_mo_ta text NULL,
	mp_tien_phong_do_sau text NULL,
	mp_tien_phong_herick text NULL,
	mp_goc_tien_phong_hinh text NULL,
	mp_goc_tien_phong_dau_hieu_khac text NULL,
	mp_mong_mat_mau_sac text NULL,
	mp_mong_mat_thoai_hoa_khong bool NULL,
	mp_mong_mat_thoai_hoa_co bool NULL,
	mp_mong_mat_thoai_hoa_mo_ta text NULL,
	mp_mong_mat_tan_mach text NULL,
	mp_dong_tu_hinh text NULL,
	mp_dong_tu_duong_kinh text NULL,
	mp_dong_tu_vien_sac_to text NULL,
	mp_dong_tu_phan_xa text NULL,
	mp_ttt_tinh_trang text NULL,
	mp_ttt_vi_tri text NULL,
	mp_dich_kinh text NULL,
	mp_day_mat_vong_mac text NULL,
	mp_day_mat_hoang_diem text NULL,
	mp_day_mat_tan_mach text NULL,
	mp_day_mat_xuat_huyet text NULL,
	mp_dia_thi_vien_tk text NULL,
	mp_dia_thi_vien_tk_vi_tri text NULL,
	mp_dia_thi_mau_sac text NULL,
	mp_dia_thi_cd text NULL,
	mp_dia_thi_mach_mau text NULL,
	mp_dia_thi_xuat_huyet text NULL,
	mp_dia_thi_teo_canh_gai text NULL,
	mp_van_nhan_lac text NULL,
	mp_nhan_cau text NULL,
	mp_hoc_mat text NULL,
	mt_thi_luc_khong_kinh text NULL,
	mt_thi_luc_co_kinh text NULL,
	mt_nhan_ap text NULL,
	mt_mi_mat_sung_ne text NULL,
	mt_mi_mat_khac text NULL,
	mt_ket_mac_cuong_tu text NULL,
	mt_ket_mac_seo_mo_cu_khong bool NULL,
	mt_ket_mac_seo_mo_cu_co bool NULL,
	mt_ket_mac_seo_mo_cu_mo_ta text NULL,
	mt_ket_mac_bong_do text NULL,
	mt_giac_mac_trong_suot text NULL,
	mt_giac_mac_phu_ne_khong bool NULL,
	mt_giac_mac_phu_ne_co bool NULL,
	mt_giac_mac_phu_ne_muc_do text NULL,
	mt_giac_mac_do_day text NULL,
	mt_giac_mac_tua text NULL,
	mt_giac_mac_duong_kinh text NULL,
	mt_cung_mac_dan_loi text NULL,
	mt_cung_mac_seo_mo_khong bool NULL,
	mt_cung_mac_seo_mo_co bool NULL,
	mt_cung_mac_seo_mo_mo_ta text NULL,
	mt_tien_phong_do_sau text NULL,
	mt_tien_phong_herick text NULL,
	mt_goc_tien_phong_hinh text NULL,
	mt_goc_tien_phong_dau_hieu_khac text NULL,
	mt_mong_mat_mau_sac text NULL,
	mt_mong_mat_thoai_hoa_khong bool NULL,
	mt_mong_mat_thoai_hoa_co bool NULL,
	mt_mong_mat_thoai_hoa_mo_ta text NULL,
	mt_mong_mat_tan_mach text NULL,
	mt_dong_tu_hinh text NULL,
	mt_dong_tu_duong_kinh text NULL,
	mt_dong_tu_vien_sac_to text NULL,
	mt_dong_tu_phan_xa text NULL,
	mt_ttt_tinh_trang text NULL,
	mt_ttt_vi_tri text NULL,
	mt_dich_kinh text NULL,
	mt_day_mat_vong_mac text NULL,
	mt_day_mat_hoang_diem text NULL,
	mt_day_mat_tan_mach text NULL,
	mt_day_mat_xuat_huyet text NULL,
	mt_dia_thi_vien_tk text NULL,
	mt_dia_thi_vien_tk_vi_tri text NULL,
	mt_dia_thi_mau_sac text NULL,
	mt_dia_thi_cd text NULL,
	mt_dia_thi_mach_mau text NULL,
	mt_dia_thi_xuat_huyet text NULL,
	mt_dia_thi_teo_canh_gai text NULL,
	mt_van_nhan_lac text NULL,
	mt_nhan_cau text NULL,
	mt_hoc_mat text NULL,
	mat_tt_noi_tiet_binh_thuong bool NULL,
	mat_tt_noi_tiet_co_benh bool NULL,
	mat_tt_noi_tiet_mo_ta text NULL,
	mat_tt_than_kinh_binh_thuong bool NULL,
	mat_tt_than_kinh_co_benh bool NULL,
	mat_tt_than_kinh_mo_ta text NULL,
	mat_tt_tuan_hoan_binh_thuong bool NULL,
	mat_tt_tuan_hoan_co_benh bool NULL,
	mat_tt_tuan_hoan_mo_ta text NULL,
	mat_tt_ho_hap_binh_thuong bool NULL,
	mat_tt_ho_hap_co_benh bool NULL,
	mat_tt_ho_hap_mo_ta text NULL,
	mat_tt_tieu_hoa_binh_thuong bool NULL,
	mat_tt_tieu_hoa_co_benh bool NULL,
	mat_tt_tieu_hoa_mo_ta text NULL,
	mat_tt_co_xuong_khop_binh_thuong bool NULL,
	mat_tt_co_xuong_khop_co_benh bool NULL,
	mat_tt_co_xuong_khop_mo_ta text NULL,
	mat_tt_tiet_nieu_binh_thuong bool NULL,
	mat_tt_tiet_nieu_co_benh bool NULL,
	mat_tt_tiet_nieu_mo_ta text NULL,
	mat_tt_khac text NULL,
	can_lam_sang_can_lam text NULL,
	mat_icd_benh_chinh_mp_code text NULL,
	mat_icd_benh_chinh_mp_name text NULL,
	mat_icd_benh_chinh_mt_code text NULL,
	mat_icd_benh_chinh_mt_name text NULL,
	mat_icd_kem_theo_mp_code text NULL,
	mat_icd_kem_theo_mp_name text NULL,
	mat_icd_kem_theo_mt_code text NULL,
	mat_icd_kem_theo_mt_name text NULL,
	mat_icd_toan_than_code text NULL,
	mat_icd_toan_than_name text NULL,
	mat_chi_dinh_dieu_tri text NULL,
	tien_luong text NULL,
	mat_icd_ra_vien_mp_code text NULL,
	mat_icd_ra_vien_mp_name text NULL,
	mat_icd_ra_vien_mt_code text NULL,
	mat_icd_ra_vien_mt_name text NULL,
	mat_rv_pp_phau_thuat bool NULL,
	mat_rv_pp_phau_thuat_mo_ta text NULL,
	mat_rv_pp_laser bool NULL,
	mat_rv_pp_laser_mo_ta text NULL,
	mat_rv_pp_thuoc bool NULL,
	mat_rv_pp_thuoc_mo_ta text NULL,
	mat_rv_tinh_trang_mp text NULL,
	mat_rv_tinh_trang_mt text NULL,
	mat_thi_luc_ra_vien_khong_kinh_mp text NULL,
	mat_thi_luc_ra_vien_khong_kinh_mt text NULL,
	mat_thi_luc_ra_vien_co_kinh_mp text NULL,
	mat_thi_luc_ra_vien_co_kinh_mt text NULL,
	mat_nhan_ap_ra_vien_mp text NULL,
	mat_nhan_ap_ra_vien_mt text NULL,
	mat_hdtt_theo_doi bool NULL,
	mat_hdtt_theo_doi_mo_ta text NULL,
	mat_hdtt_phau_thuat bool NULL,
	mat_hdtt_phau_thuat_mo_ta text NULL,
	mat_hdtt_laser bool NULL,
	mat_hdtt_laser_mo_ta text NULL,
	mat_hdtt_thuoc bool NULL,
	mat_hdtt_thuoc_mo_ta text NULL,
	so_to_x_quang int4 NULL,
	so_to_ct_scanner int4 NULL,
	so_to_sieu_am int4 NULL,
	so_to_xet_nghiem int4 NULL,
	so_to_khac int4 NULL,
	ten_khac text NULL,
	so_to_toan_bo_ho_so int4 NULL,
	nguoi_giao_ho_so text NULL,
	nguoi_nhan_ho_so text NULL,
	thoi_gian_ky_ho_so timestamp NULL,
	bac_si_dieu_tri_ho_so text NULL,
	giam_doc_benh_vien_ho_ten text NULL,
	truong_khoa_ho_ten text NULL,
	truong_khoa_thoi_gian timestamp NULL,
	bac_si_tao_benh_an_ho_ten text NULL,
	bac_si_tao_benh_an_thoi_gian timestamp NULL,
	bi_xoa int2 DEFAULT 0 NOT NULL,
	ngay_tao timestamp NULL,
	nguoi_tao varchar(50) NULL,
	ngay_cap_nhat timestamp NULL,
	nguoi_cap_nhat varchar(50) NULL,
	ngay_xoa timestamp NULL,
	nguoi_xoa varchar(50) NULL,
	CONSTRAINT csyt_ba_chuyen_khoa_mat_glocom_pkey PRIMARY KEY (id)
);

CREATE TABLE csyt_ba_chuyen_khoa_mat_lac (
	id uuid DEFAULT gen_random_uuid() NOT NULL,
	benh_an_id uuid NULL, -- FK csyt_benh_an_dieu_tri.id
	ma_cskcb varchar(50) NULL,
	mat_ly_do_vao_vien_lac bool NULL,
	mat_ly_do_vao_vien_sup_mi bool NULL,
	mat_ly_do_vao_vien_khac bool NULL,
	mat_lac_nguyen_nhan_bam_sinh bool NULL,
	mat_lac_nguyen_nhan_mac_phai bool NULL,
	mat_lac_nguyen_nhan_tu_bao_gio text NULL,
	mat_lac_trieu_chung text NULL,
	mat_lac_trieu_chung_khac bool NULL,
	mat_lac_trieu_chung_khac_mo_ta text NULL,
	mat_lac_dt_tap_nhuoc_thi bool NULL,
	mat_lac_dt_tap_nhuoc_thi_phuong_phap text NULL,
	mat_lac_dt_tap_nhuoc_thi_ket_qua text NULL,
	mat_lac_dt_phau_thuat bool NULL,
	mat_lac_dt_phau_thuat_phuong_phap text NULL,
	mat_lac_dt_phau_thuat_tot bool NULL,
	mat_lac_dt_phau_thuat_mo_non bool NULL,
	mat_lac_dt_phau_thuat_mo_non_mo_ta text NULL,
	mat_lac_dt_phau_thuat_mo_gia bool NULL,
	mat_lac_dt_phau_thuat_mo_gia_mo_ta text NULL,
	mat_lac_ts_ban_than_binh_thuong bool NULL,
	mat_lac_ts_ban_than_benh_ly bool NULL,
	mat_lac_ts_ban_than_mo_ta text NULL,
	mat_lac_ts_gia_dinh_khong bool NULL,
	mat_lac_ts_gia_dinh_co bool NULL,
	mat_lac_ts_gia_dinh_mo_ta text NULL,
	mat_thi_luc_khong_kinh_mp text NULL,
	mat_thi_luc_khong_kinh_mt text NULL,
	mat_thi_luc_co_kinh_mp text NULL,
	mat_thi_luc_co_kinh_mt text NULL,
	mat_khuc_xa_truoc_atropine_mp text NULL,
	mat_khuc_xa_truoc_atropine_mt text NULL,
	mat_khuc_xa_sau_atropine_mp text NULL,
	mat_khuc_xa_sau_atropine_mt text NULL,
	mp_soi_bong_dong_tu_hinh text NULL,
	mp_soi_bong_dong_tu_mo_ta text NULL,
	mt_soi_bong_dong_tu_hinh text NULL,
	mt_soi_bong_dong_tu_mo_ta text NULL,
	mp_van_nhan_ngoai_lai_hinh text NULL,
	mp_van_nhan_t_tren text NULL,
	mp_van_nhan_cb text NULL,
	mp_van_nhan_tn text NULL,
	mp_van_nhan_tt text NULL,
	mp_van_nhan_td text NULL,
	mp_van_nhan_cl text NULL,
	mt_van_nhan_ngoai_lai_hinh text NULL,
	mt_van_nhan_t_tren text NULL,
	mt_van_nhan_cb text NULL,
	mt_van_nhan_tn text NULL,
	mt_van_nhan_tt text NULL,
	mt_van_nhan_td text NULL,
	mt_van_nhan_cl text NULL,
	mp_van_nhan_noi_tai_binh_thuong bool NULL,
	mp_van_nhan_noi_tai_benh_ly bool NULL,
	mp_van_nhan_noi_tai_mo_ta text NULL,
	mt_van_nhan_noi_tai_binh_thuong bool NULL,
	mt_van_nhan_noi_tai_benh_ly bool NULL,
	mt_van_nhan_noi_tai_mo_ta text NULL,
	mat_diem_can_qui_tu_binh_thuong bool NULL,
	mat_diem_can_qui_tu_benh_ly bool NULL,
	mat_diem_can_qui_tu_mo_ta text NULL,
	mat_rgnc_khong bool NULL,
	mat_rgnc_co bool NULL,
	mat_rgnc_mo_ta text NULL,
	mat_rgnc_kieu text NULL,
	mat_rgnc_goc_ham_khong bool NULL,
	mat_rgnc_goc_ham_co bool NULL,
	mat_che_mat_tra_trong_ra bool NULL,
	mat_che_mat_tra_ngoai_vao bool NULL,
	mat_che_mat_tra_cheo bool NULL,
	mat_hinh_thai_tinh_chat_lac text NULL,
	mat_do_lac_hirschberg_truoc text NULL,
	mat_do_lac_hirschberg_sau text NULL,
	mat_do_lac_lang_kinh_truoc text NULL,
	mat_do_lac_lang_kinh_sau text NULL,
	mat_do_lac_nhin_gan text NULL,
	mat_do_lac_nhin_xa text NULL,
	mat_do_lac_nhin_len text NULL,
	mat_do_lac_nhin_xuong text NULL,
	mat_hoi_chung text NULL,
	mat_synoptophore_khach_quan text NULL,
	mat_synoptophore_chu_quan text NULL,
	mat_thi_giac_hai_mat_dong_thi bool NULL,
	mat_thi_giac_hai_mat_hop_thi bool NULL,
	mat_thi_giac_hai_mat_phu_thi bool NULL,
	mat_thi_giac_hai_mat_phu_thi_mo_ta text NULL,
	mat_bien_do_hop_thi text NULL,
	mat_tuong_ung_vong_mac_binh_thuong bool NULL,
	mat_tuong_ung_vong_mac_bat_binh_thuong bool NULL,
	mat_song_thi_khong bool NULL,
	mat_song_thi_co bool NULL,
	mat_song_thi_mo_ta text NULL,
	mat_tu_the_bu_tru_khong bool NULL,
	mat_tu_the_bu_tru_co bool NULL,
	mat_tu_the_bu_tru_mo_ta text NULL,
	mp_mi_mat_binh_thuong bool NULL,
	mp_mi_mat_benh_ly bool NULL,
	mp_mi_mat_sup_mi_muc_do text NULL,
	mp_mi_mat_epicanthus text NULL,
	mp_mi_mat_chuc_nang text NULL,
	mp_mi_mat_marcus_gunn text NULL,
	mp_mi_mat_dau_hieu_bell text NULL,
	mp_mi_mat_khac text NULL,
	mp_ket_mac_binh_thuong bool NULL,
	mp_ket_mac_benh_ly bool NULL,
	mp_ket_mac_benh_ly_mo_ta text NULL,
	mp_phan_truoc_binh_thuong bool NULL,
	mp_phan_truoc_benh_ly bool NULL,
	mp_phan_truoc_benh_ly_mo_ta text NULL,
	mp_phan_sau_binh_thuong bool NULL,
	mp_phan_sau_benh_ly bool NULL,
	mp_phan_sau_benh_ly_mo_ta text NULL,
	mp_dinh_thi text NULL,
	mt_mi_mat_binh_thuong bool NULL,
	mt_mi_mat_benh_ly bool NULL,
	mt_mi_mat_sup_mi_muc_do text NULL,
	mt_mi_mat_epicanthus text NULL,
	mt_mi_mat_chuc_nang text NULL,
	mt_mi_mat_marcus_gunn text NULL,
	mt_mi_mat_dau_hieu_bell text NULL,
	mt_mi_mat_khac text NULL,
	mt_ket_mac_binh_thuong bool NULL,
	mt_ket_mac_benh_ly bool NULL,
	mt_ket_mac_benh_ly_mo_ta text NULL,
	mt_phan_truoc_binh_thuong bool NULL,
	mt_phan_truoc_benh_ly bool NULL,
	mt_phan_truoc_benh_ly_mo_ta text NULL,
	mt_phan_sau_binh_thuong bool NULL,
	mt_phan_sau_benh_ly bool NULL,
	mt_phan_sau_benh_ly_mo_ta text NULL,
	mt_dinh_thi text NULL,
	mat_tt_noi_tiet_binh_thuong bool NULL,
	mat_tt_noi_tiet_co_benh bool NULL,
	mat_tt_noi_tiet_mo_ta text NULL,
	mat_tt_than_kinh_binh_thuong bool NULL,
	mat_tt_than_kinh_co_benh bool NULL,
	mat_tt_than_kinh_mo_ta text NULL,
	mat_tt_tuan_hoan_binh_thuong bool NULL,
	mat_tt_tuan_hoan_co_benh bool NULL,
	mat_tt_tuan_hoan_mo_ta text NULL,
	mat_tt_ho_hap_binh_thuong bool NULL,
	mat_tt_ho_hap_co_benh bool NULL,
	mat_tt_ho_hap_mo_ta text NULL,
	mat_tt_tieu_hoa_binh_thuong bool NULL,
	mat_tt_tieu_hoa_co_benh bool NULL,
	mat_tt_tieu_hoa_mo_ta text NULL,
	mat_tt_co_xuong_khop_binh_thuong bool NULL,
	mat_tt_co_xuong_khop_co_benh bool NULL,
	mat_tt_co_xuong_khop_mo_ta text NULL,
	mat_tt_tiet_nieu_binh_thuong bool NULL,
	mat_tt_tiet_nieu_co_benh bool NULL,
	mat_tt_tiet_nieu_mo_ta text NULL,
	mat_tt_khac text NULL,
	can_lam_sang_can_lam text NULL,
	mat_hdt_phuong_phap_chinh text NULL,
	mat_hdt_che_do_an_uong text NULL,
	mat_hdt_che_do_cham_soc text NULL,
	tien_luong text NULL,
	mat_summary_lam_sang text NULL,
	mat_summary_nguyen_nhan text NULL,
	mat_summary_noi_khoa text NULL,
	mat_summary_is_phau_thuat bool NULL,
	mat_summary_is_thu_thuat bool NULL,
	mat_summary_tinh_trang_ra_vien text NULL,
	mat_thi_luc_ra_vien_khong_kinh_mp text NULL,
	mat_thi_luc_ra_vien_khong_kinh_mt text NULL,
	mat_thi_luc_ra_vien_co_kinh_mp text NULL,
	mat_thi_luc_ra_vien_co_kinh_mt text NULL,
	mat_nhan_ap_ra_vien_mp text NULL,
	mat_nhan_ap_ra_vien_mt text NULL,
	mat_summary_huong_dieu_tri_tiep text NULL,
	so_to_x_quang int4 NULL,
	so_to_ct_scanner int4 NULL,
	so_to_sieu_am int4 NULL,
	so_to_xet_nghiem int4 NULL,
	so_to_khac int4 NULL,
	ten_khac text NULL,
	so_to_toan_bo_ho_so int4 NULL,
	nguoi_giao_ho_so text NULL,
	nguoi_nhan_ho_so text NULL,
	thoi_gian_ky_ho_so timestamp NULL,
	bac_si_dieu_tri_ho_so text NULL,
	giam_doc_benh_vien_ho_ten text NULL,
	truong_khoa_ho_ten text NULL,
	truong_khoa_thoi_gian timestamp NULL,
	bac_si_tao_benh_an_ho_ten text NULL,
	bac_si_tao_benh_an_thoi_gian timestamp NULL,
	bi_xoa int2 DEFAULT 0 NOT NULL,
	ngay_tao timestamp NULL,
	nguoi_tao varchar(50) NULL,
	ngay_cap_nhat timestamp NULL,
	nguoi_cap_nhat varchar(50) NULL,
	ngay_xoa timestamp NULL,
	nguoi_xoa varchar(50) NULL,
	icd_benh_chinh_kl_code varchar(255) NULL, -- Mã ICD bệnh chính kết luận
	icd_benh_chinh_kl_name text NULL, -- Tên ICD bệnh chính kết luận
	icd_benh_kem_theo_kl_code varchar(255) NULL, -- Mã ICD bệnh kèm theo kết luận
	icd_benh_kem_theo_kl_name text NULL, -- Tên ICD bệnh kèm theo kết luận
	CONSTRAINT csyt_ba_chuyen_khoa_mat_lac_pkey PRIMARY KEY (id)
);

CREATE TABLE csyt_ba_chuyen_khoa_mat_tre_em (
	id uuid DEFAULT gen_random_uuid() NOT NULL,
	benh_an_id uuid NOT NULL,
	ma_cskcb varchar(50) NOT NULL,
	mte_ly_do_vao_vien text NULL,
	mte_can_lam_sang_can_lam text NULL,
	mte_icd_benh_chinh_vao_khoa_code varchar(100) NULL,
	mte_icd_benh_chinh_vao_khoa_name text NULL,
	mte_icd_benh_kem_theo_vao_khoa_code text NULL,
	mte_icd_benh_kem_theo_vao_khoa_name text NULL,
	mte_phan_biet_vao_khoa text NULL,
	mte_tien_luong text NULL,
	mte_bac_si_tao_benh_an_ho_ten varchar(255) NULL,
	mte_bac_si_tao_benh_an_thoi_gian timestamp NULL,
	mte_mat_nn_bam_sinh bool DEFAULT false NULL,
	mte_mat_nn_mac_phai bool DEFAULT false NULL,
	mte_mat_nn_mac_phai_mo_ta text NULL,
	mte_mat_tc_nhin_mo bool DEFAULT false NULL,
	mte_mat_tc_dau_nhuc bool DEFAULT false NULL,
	mte_mat_tc_do_mat bool DEFAULT false NULL,
	mte_mat_tc_choi_mat bool DEFAULT false NULL,
	mte_mat_da_dieu_tri_noi_khoa bool DEFAULT false NULL,
	mte_mat_da_dieu_tri_phau_thuat bool DEFAULT false NULL,
	mte_mat_da_dieu_tri_mo_ta text NULL,
	mte_mat_ts_ban_than_binh_thuong bool DEFAULT false NULL,
	mte_mat_ts_ban_than_benh_ly bool DEFAULT false NULL,
	mte_mat_ts_ban_than_mo_ta text NULL,
	mte_mat_ts_gia_dinh_khong bool DEFAULT false NULL,
	mte_mat_ts_gia_dinh_co bool DEFAULT false NULL,
	mte_mat_ts_gia_dinh_mo_ta text NULL,
	mte_mat_ts_thai_nghen_khong bool DEFAULT false NULL,
	mte_mat_ts_thai_nghen_co bool DEFAULT false NULL,
	mte_mat_ts_thai_nghen_mo_ta text NULL,
	mte_mat_pt_tri_tue_binh_thuong bool DEFAULT false NULL,
	mte_mat_pt_tri_tue_benh_ly bool DEFAULT false NULL,
	mte_mat_pt_tri_tue_mo_ta text NULL,
	mte_mat_thi_luc_khong_kinh_mp varchar(100) NULL,
	mte_mat_thi_luc_khong_kinh_mt varchar(100) NULL,
	mte_mat_thi_luc_co_kinh_mp varchar(100) NULL,
	mte_mat_thi_luc_co_kinh_mt varchar(100) NULL,
	mte_mat_nhan_ap_mp varchar(100) NULL,
	mte_mat_nhan_ap_mt varchar(100) NULL,
	mte_mat_thi_truong_mp varchar(100) NULL,
	mte_mat_thi_truong_mt varchar(100) NULL,
	mte_mp_van_nhan_ngoai_lai_binh_thuong bool DEFAULT false NULL,
	mte_mp_van_nhan_ngoai_lai_mo_ta text NULL,
	mte_mt_van_nhan_ngoai_lai_binh_thuong bool DEFAULT false NULL,
	mte_mt_van_nhan_ngoai_lai_benh_ly bool DEFAULT false NULL,
	mte_mt_van_nhan_ngoai_lai_mo_ta text NULL,
	mte_mp_van_nhan_noi_tai_binh_thuong bool DEFAULT false NULL,
	mte_mp_van_nhan_noi_tai_benh_ly bool DEFAULT false NULL,
	mte_mp_van_nhan_noi_tai_mo_ta text NULL,
	mte_mt_van_nhan_noi_tai_binh_thuong bool DEFAULT false NULL,
	mte_mt_van_nhan_noi_tai_benh_ly bool DEFAULT false NULL,
	mte_mt_van_nhan_noi_tai_mo_ta text NULL,
	mte_mat_rung_giat_nhan_cau_khong bool DEFAULT false NULL,
	mte_mat_rung_giat_nhan_cau_co bool DEFAULT false NULL,
	mte_mat_rung_giat_nhan_cau_mo_ta text NULL,
	mte_mp_mi_mat_quam text NULL,
	mte_mp_mi_mat_epicanthus text NULL,
	mte_mp_mi_mat_sup_mi text NULL,
	mte_mp_mi_mat_u text NULL,
	mte_mp_mi_mat_khac text NULL,
	mte_mt_mi_mat_quam text NULL,
	mte_mt_mi_mat_epicanthus text NULL,
	mte_mt_mi_mat_sup_mi text NULL,
	mte_mt_mi_mat_u text NULL,
	mte_mt_mi_mat_khac text NULL,
	mte_mp_le_dao text NULL,
	mte_mt_le_dao text NULL,
	mte_mp_ket_mac_cuong_tu text NULL,
	mte_mp_ket_mac_xuat_huyet text NULL,
	mte_mp_ket_mac_xuat_tiet text NULL,
	mte_mp_ket_mac_u text NULL,
	mte_mp_ket_mac_khac text NULL,
	mte_mt_ket_mac_cuong_tu text NULL,
	mte_mt_ket_mac_xuat_huyet text NULL,
	mte_mt_ket_mac_xuat_tiet text NULL,
	mte_mt_ket_mac_u text NULL,
	mte_mt_ket_mac_khac text NULL,
	mte_mp_giac_mac_trong bool DEFAULT false NULL,
	mte_mp_giac_mac_seo_co bool DEFAULT false NULL,
	mte_mp_giac_mac_seo_mo_ta text NULL,
	mte_mp_giac_mac_loan_duong_co bool DEFAULT false NULL,
	mte_mp_giac_mac_loan_duong_mo_ta text NULL,
	mte_mp_giac_mac_thoai_hoa_co bool DEFAULT false NULL,
	mte_mp_giac_mac_thoai_hoa_mo_ta text NULL,
	mte_mp_giac_mac_phu_ne text NULL,
	mte_mp_giac_mac_u text NULL,
	mte_mp_giac_mac_tua text NULL,
	mte_mp_giac_mac_loet text NULL,
	mte_mp_giac_mac_loet2 text NULL,
	mte_mp_giac_mac_di_tat text NULL,
	mte_mp_giac_mac_duong_kinh text NULL,
	mte_mp_giac_mac_vung_ria text NULL,
	mte_mp_giac_mac_khac text NULL,
	mte_mt_giac_mac_trong bool DEFAULT false NULL,
	mte_mt_giac_mac_seo_mo_ta text NULL,
	mte_mt_giac_mac_loan_duong_co bool DEFAULT false NULL,
	mte_mt_giac_mac_loan_duong_mo_ta text NULL,
	mte_mt_giac_mac_thoai_hoa_co bool DEFAULT false NULL,
	mte_mt_giac_mac_thoai_hoa_mo_ta text NULL,
	mte_mt_giac_mac_phu_ne text NULL,
	mte_mt_giac_mac_u text NULL,
	mte_mt_giac_mac_tua text NULL,
	mte_mt_giac_mac_loet text NULL,
	mte_mt_giac_mac_loet2 text NULL,
	mte_mt_giac_mac_di_tat text NULL,
	mte_mt_giac_mac_duong_kinh text NULL,
	mte_mt_giac_mac_vung_ria text NULL,
	mte_mt_giac_mac_khac text NULL,
	mte_mp_cung_mac_dan_loi text NULL,
	mte_mp_cung_mac_seo_mo text NULL,
	mte_mp_cung_mac_cuong_tu text NULL,
	mte_mp_cung_mac_viem text NULL,
	mte_mp_cung_mac_khac text NULL,
	mte_mt_cung_mac_dan_loi text NULL,
	mte_mt_cung_mac_seo_mo text NULL,
	mte_mt_cung_mac_cuong_tu text NULL,
	mte_mt_cung_mac_viem text NULL,
	mte_mt_cung_mac_khac text NULL,
	mte_mp_tien_phong_do_sau text NULL,
	mte_mp_tien_phong_tyndall text NULL,
	mte_mp_tien_phong_mu text NULL,
	mte_mp_tien_phong_mau text NULL,
	mte_mp_tien_phong_goc text NULL,
	mte_mt_tien_phong_do_sau text NULL,
	mte_mt_tien_phong_tyndall text NULL,
	mte_mt_tien_phong_mu text NULL,
	mte_mt_tien_phong_mau text NULL,
	mte_mt_tien_phong_goc text NULL,
	mte_mp_mong_mat_mau_sac text NULL,
	mte_mp_mong_mat_thoai_hoa text NULL,
	mte_mp_mong_mat_tan_mach text NULL,
	mte_mp_mong_mat_cam_giac_the_mi text NULL,
	mte_mp_mong_mat_u text NULL,
	mte_mp_mong_mat_di_dang text NULL,
	mte_mt_mong_mat_mau_sac text NULL,
	mte_mt_mong_mat_thoai_hoa text NULL,
	mte_mt_mong_mat_tan_mach text NULL,
	mte_mt_mong_mat_cam_giac_the_mi text NULL,
	mte_mt_mong_mat_u text NULL,
	mte_mt_mong_mat_di_dang text NULL,
	mte_mp_dong_tu_hinh_dang text NULL,
	mte_mp_dong_tu_duong_kinh text NULL,
	mte_mp_dong_tu_vien_sac_to text NULL,
	mte_mp_dong_tu_phan_xa text NULL,
	mte_mp_dong_tu_di_dang text NULL,
	mte_mt_dong_tu_hinh_dang text NULL,
	mte_mt_dong_tu_duong_kinh text NULL,
	mte_mt_dong_tu_vien_sac_to text NULL,
	mte_mt_dong_tu_phan_xa text NULL,
	mte_mt_dong_tu_di_dang text NULL,
	mte_mp_the_thuy_tinh_binh_thuong bool DEFAULT false NULL,
	mte_mp_the_thuy_tinh_duc bool DEFAULT false NULL,
	mte_mp_the_thuy_tinh_lech bool DEFAULT false NULL,
	mte_mp_the_thuy_tinh_duc_toan_bo bool DEFAULT false NULL,
	mte_mp_the_thuy_tinh_duc_nhan bool DEFAULT false NULL,
	mte_mp_the_thuy_tinh_duc_bao bool DEFAULT false NULL,
	mte_mp_the_thuy_tinh_khac bool DEFAULT false NULL,
	mte_mt_the_thuy_tinh_binh_thuong bool DEFAULT false NULL,
	mte_mt_the_thuy_tinh_duc bool DEFAULT false NULL,
	mte_mt_the_thuy_tinh_lech bool DEFAULT false NULL,
	mte_mt_the_thuy_tinh_duc_toan_bo bool DEFAULT false NULL,
	mte_mt_the_thuy_tinh_duc_nhan bool DEFAULT false NULL,
	mte_mt_the_thuy_tinh_duc_bao bool DEFAULT false NULL,
	mte_mt_the_thuy_tinh_khac bool DEFAULT false NULL,
	mte_mp_dich_kinh_binh_thuong bool DEFAULT false NULL,
	mte_mp_dich_kinh_benh_ly_co bool DEFAULT false NULL,
	mte_mp_dich_kinh_benh_ly_mo_ta text NULL,
	mte_mt_dich_kinh_binh_thuong bool DEFAULT false NULL,
	mte_mt_dich_kinh_benh_ly_co bool DEFAULT false NULL,
	mte_mt_dich_kinh_benh_ly_mo_ta text NULL,
	mte_mp_day_mat_vong_mac text NULL,
	mte_mp_day_mat_hoang_diem text NULL,
	mte_mp_day_mat_mach_mau text NULL,
	mte_mp_day_mat_dia_thi text NULL,
	mte_mp_day_mat_u text NULL,
	mte_mt_day_mat_vong_mac text NULL,
	mte_mt_day_mat_hoang_diem text NULL,
	mte_mt_day_mat_mach_mau text NULL,
	mte_mt_day_mat_dia_thi text NULL,
	mte_mt_day_mat_u text NULL,
	mte_mp_nhan_cau_mem bool DEFAULT false NULL,
	mte_mp_nhan_cau_cang bool DEFAULT false NULL,
	mte_mp_nhan_cau_to bool DEFAULT false NULL,
	mte_mp_nhan_cau_nho bool DEFAULT false NULL,
	mte_mp_nhan_cau_teo bool DEFAULT false NULL,
	mte_mt_nhan_cau_mem bool DEFAULT false NULL,
	mte_mt_nhan_cau_cang bool DEFAULT false NULL,
	mte_mt_nhan_cau_to bool DEFAULT false NULL,
	mte_mt_nhan_cau_nho bool DEFAULT false NULL,
	mte_mt_nhan_cau_teo bool DEFAULT false NULL,
	mte_mat_tt_noi_tiet_binh_thuong bool DEFAULT false NULL,
	mte_mat_tt_noi_tiet_co_benh bool DEFAULT false NULL,
	mte_mat_tt_noi_tiet_mo_ta text NULL,
	mte_mat_tt_than_kinh_binh_thuong bool DEFAULT false NULL,
	mte_mat_tt_than_kinh_co_benh bool DEFAULT false NULL,
	mte_mat_tt_than_kinh_mo_ta text NULL,
	mte_mat_tt_tuan_hoan_binh_thuong bool DEFAULT false NULL,
	mte_mat_tt_tuan_hoan_co_benh bool DEFAULT false NULL,
	mte_mat_tt_tuan_hoan_mo_ta text NULL,
	mte_mat_tt_ho_hap_binh_thuong bool DEFAULT false NULL,
	mte_mat_tt_ho_hap_co_benh bool DEFAULT false NULL,
	mte_mat_tt_ho_hap_mo_ta text NULL,
	mte_mat_tt_tieu_hoa_binh_thuong bool DEFAULT false NULL,
	mte_mat_tt_tieu_hoa_co_benh bool DEFAULT false NULL,
	mte_mat_tt_tieu_hoa_mo_ta text NULL,
	mte_mat_tt_co_xuong_khop_binh_thuong bool DEFAULT false NULL,
	mte_mat_tt_co_xuong_khop_co_benh bool DEFAULT false NULL,
	mte_mat_tt_co_xuong_khop_mo_ta text NULL,
	mte_mat_tt_tiet_nieu_binh_thuong bool DEFAULT false NULL,
	mte_mat_tt_tiet_nieu_co_benh bool DEFAULT false NULL,
	mte_mat_tt_tiet_nieu_mo_ta text NULL,
	mte_mat_tt_khac text NULL,
	mte_mp_benh_chinh_vao_khoa_code varchar(100) NULL,
	mte_mp_benh_chinh_vao_khoa_name text NULL,
	mte_mt_benh_chinh_vao_khoa_code varchar(100) NULL,
	mte_mt_benh_chinh_vao_khoa_name text NULL,
	mte_mat_dieu_tri_phuong_phap_chinh text NULL,
	mte_mat_dieu_tri_che_do_an_uong text NULL,
	mte_mat_dieu_tri_che_do_cham_soc text NULL,
	mte_mat_summary_lam_sang text NULL,
	mte_mat_summary_nguyen_nhan text NULL,
	mte_mat_summary_noi_khoa text NULL,
	mte_mat_summary_ket_qua text NULL,
	mte_mat_summary_bien_chung_di_chung text NULL,
	mte_mat_summary_huong_dieu_tri_tiep text NULL,
	bi_xoa int2 DEFAULT 0 NULL,
	ngay_tao timestamp DEFAULT CURRENT_TIMESTAMP NULL,
	nguoi_tao varchar(100) NULL,
	ngay_cap_nhat timestamp NULL,
	nguoi_cap_nhat varchar(100) NULL,
	ngay_xoa timestamp NULL,
	nguoi_xoa varchar(100) NULL,
	CONSTRAINT csyt_ba_chuyen_khoa_mat_tre_em_pkey PRIMARY KEY (id)
);

CREATE TABLE csyt_ba_chuyen_khoa_ngoai (
	id uuid DEFAULT gen_random_uuid() NOT NULL,
	benh_an_id uuid NOT NULL, -- FK csyt_benh_an_dieu_tri.id (UNIQUE)
	ma_cskcb varchar(50) NOT NULL,
	tien_su_di_ung text NULL,
	tien_su_dieu_tri_truoc text NULL,
	kham_than_tiet_nieu_sinh_duc text NULL,
	kham_noi_tiet_dinh_duong_khac text NULL,
	nguyen_nhan_tu_vong text NULL,
	tom_tat_ket_qua_can_lam_sang text NULL,
	ten_khac varchar(500) NULL,
	bi_xoa int2 DEFAULT 0 NOT NULL,
	ngay_tao timestamp NULL,
	nguoi_tao varchar(50) NULL,
	ngay_cap_nhat timestamp NULL,
	nguoi_cap_nhat varchar(50) NULL,
	ngay_xoa timestamp NULL,
	nguoi_xoa varchar(50) NULL,
	ngoai_kham_ngoai_khoa text NULL,
	CONSTRAINT csyt_ba_chuyen_khoa_ngoai_benh_an_id_key UNIQUE (benh_an_id),
	CONSTRAINT csyt_ba_chuyen_khoa_ngoai_pkey PRIMARY KEY (id)
);

CREATE TABLE csyt_ba_chuyen_khoa_ngoai_tru (
	id uuid DEFAULT gen_random_uuid() NOT NULL,
	benh_an_id uuid NULL, -- FK csyt_benh_an_dieu_tri.id
	ma_cskcb varchar(50) NULL,
	qua_trinh_benh_ly text NULL,
	tien_su_ban_than text NULL,
	tien_su_gia_dinh text NULL,
	kham_toan_than text NULL,
	kham_tuan_hoan text NULL,
	kham_ho_hap text NULL,
	kham_tieu_hoa text NULL,
	kham_than_tiet_nieu_sinh_duc text NULL,
	kham_than_kinh text NULL,
	kham_co_xuong_khop text NULL,
	kham_tai_mui_hong text NULL,
	kham_rang_ham_mat text NULL,
	kham_mat text NULL,
	kham_noi_tiet_dinh_duong_khac text NULL,
	kham_cac_co_quan text NULL,
	can_lam_sang_can_lam text NULL,
	chan_doan_ban_dau text NULL,
	da_xu_ly text NULL,
	icd_chan_doan_ra_vien_code text NULL,
	icd_chan_doan_ra_vien_name text NULL,
	tom_tat_benh_an text NULL,
	tien_luong text NULL,
	huong_dieu_tri text NULL,
	tom_tat_ket_qua_can_lam_sang text NULL,
	icd_kem_theo_ra_vien_code text NULL,
	icd_kem_theo_ra_vien_name text NULL,
	phuong_phap_dieu_tri text NULL,
	huong_dieu_tri_tiep_theo text NULL,
	so_to_x_quang int4 NULL,
	so_to_ct_scanner int4 NULL,
	so_to_sieu_am int4 NULL,
	so_to_xet_nghiem int4 NULL,
	ten_khac text NULL,
	so_to_khac int4 NULL,
	so_to_toan_bo_ho_so int4 NULL,
	ghi_chu text NULL,
	nguoi_giao_ho_so text NULL,
	nguoi_nhan_ho_so text NULL,
	thoi_gian_ky_ho_so timestamp NULL,
	bac_si_dieu_tri_ho_so text NULL,
	giam_doc_benh_vien_ho_ten text NULL,
	truong_khoa_ho_ten text NULL,
	truong_khoa_thoi_gian timestamp NULL,
	bac_si_tao_benh_an_ho_ten text NULL,
	bac_si_tao_benh_an_thoi_gian timestamp NULL,
	bi_xoa int2 DEFAULT 0 NOT NULL,
	ngay_tao timestamp NULL,
	nguoi_tao varchar(50) NULL,
	ngay_cap_nhat timestamp NULL,
	nguoi_cap_nhat varchar(50) NULL,
	ngay_xoa timestamp NULL,
	nguoi_xoa varchar(50) NULL,
	CONSTRAINT csyt_ba_chuyen_khoa_ngoai_tru_pkey PRIMARY KEY (id)
);

CREATE TABLE csyt_ba_chuyen_khoa_ngt_phcn (
	id uuid DEFAULT gen_random_uuid() NOT NULL,
	benh_an_id uuid NOT NULL, -- FK csyt_benh_an_dieu_tri.id (UNIQUE)
	ma_cskcb varchar(50) NOT NULL,
	ngt_giay_chung_nhan_khuyet_tat int4 NULL,
	ngt_dang_khuyet_tat varchar(500) NULL,
	ngt_muc_do_khuyet_tat varchar(500) NULL,
	ngt_ly_do_vao_vien text NULL,
	ngt_vao_ngay_thu int4 NULL,
	ngt_kham_toan_than text NULL,
	ngt_can_lam_sang_can_lam text NULL,
	ngt_icd_benh_chinh_vao_khoa_code varchar(100) NULL,
	ngt_icd_benh_chinh_vao_khoa_name varchar(500) NULL,
	ngt_icd_benh_kem_theo_vao_khoa_code varchar(100) NULL,
	ngt_icd_benh_kem_theo_vao_khoa_name varchar(500) NULL,
	ngt_bac_si_tao_benh_an_ho_ten varchar(255) NULL,
	ngt_tien_su_di_ung text NULL,
	ngt_kham_cac_co_quan text NULL,
	ngt_chan_doan_ban_dau text NULL,
	ngt_da_xu_ly text NULL,
	ngt_icd_chan_doan_ra_vien_code varchar(100) NULL,
	ngt_icd_chan_doan_ra_vien_name varchar(500) NULL,
	ngt_icd_kem_theo_ra_vien_code varchar(100) NULL,
	ngt_icd_kem_theo_ra_vien_name varchar(500) NULL,
	bi_xoa int2 DEFAULT 0 NOT NULL,
	ngay_tao timestamp NULL,
	nguoi_tao varchar(50) NULL,
	ngay_cap_nhat timestamp NULL,
	nguoi_cap_nhat varchar(50) NULL,
	ngay_xoa timestamp NULL,
	nguoi_xoa varchar(50) NULL,
	CONSTRAINT csyt_ba_chuyen_khoa_ngt_phcn_benh_an_id_key UNIQUE (benh_an_id),
	CONSTRAINT csyt_ba_chuyen_khoa_ngt_phcn_pkey PRIMARY KEY (id)
);

CREATE TABLE csyt_ba_chuyen_khoa_ngt_rhm (
	id uuid DEFAULT gen_random_uuid() NOT NULL,
	benh_an_id uuid NOT NULL, -- FK csyt_benh_an_dieu_tri.id (UNIQUE)
	ma_cskcb varchar(50) NOT NULL,
	ngt_ly_do_vao_vien text NULL,
	ngt_vao_ngay_thu int4 NULL,
	ngt_kham_toan_than text NULL,
	ngt_tom_tat_benh_an text NULL,
	ngt_icd_benh_chinh_vao_khoa_code varchar(100) NULL,
	ngt_icd_benh_chinh_vao_khoa_name varchar(500) NULL,
	ngt_icd_benh_kem_theo_vao_khoa_code varchar(100) NULL,
	ngt_icd_benh_kem_theo_vao_khoa_name varchar(500) NULL,
	ngt_bac_si_tao_benh_an_ho_ten varchar(255) NULL,
	ngt_bac_si_tao_benh_an_thoi_gian timestamp NULL,
	ngt_icd_chan_doan_ra_vien_code varchar(100) NULL,
	ngt_icd_chan_doan_ra_vien_name varchar(500) NULL,
	ngt_icd_kem_theo_ra_vien_code varchar(100) NULL,
	ngt_icd_kem_theo_ra_vien_name varchar(500) NULL,
	ngt_kham_chuyen_khoa text NULL,
	ngt_hinh_anh_phai text NULL,
	ngt_hinh_anh_thang text NULL,
	ngt_hinh_anh_trai text NULL,
	ngt_hinh_anh_tren text NULL,
	ngt_hinh_anh_duoi text NULL,
	ngt_hinh_anh_phan_loai text NULL,
	ngt_chan_doan_khoa_kham_benh text NULL,
	ngt_da_xu_ly_tuyen_duoi text NULL,
	bi_xoa int2 DEFAULT 0 NOT NULL,
	ngay_tao timestamp NULL,
	nguoi_tao varchar(50) NULL,
	ngay_cap_nhat timestamp NULL,
	nguoi_cap_nhat varchar(50) NULL,
	ngay_xoa timestamp NULL,
	nguoi_xoa varchar(50) NULL,
	CONSTRAINT csyt_ba_chuyen_khoa_ngt_rhm_benh_an_id_key UNIQUE (benh_an_id),
	CONSTRAINT csyt_ba_chuyen_khoa_ngt_rhm_pkey PRIMARY KEY (id)
);

CREATE TABLE csyt_ba_chuyen_khoa_nhi_khoa (
	id uuid DEFAULT gen_random_uuid() NOT NULL,
	benh_an_id uuid NOT NULL, -- ID bệnh án tổng (FK to csyt_benh_an_dieu_tri)
	ma_cskcb varchar(50) NOT NULL,
	nk_ly_do_vao_vien text NULL,
	nk_qua_trinh_benh_ly text NULL,
	nk_tien_su_ban_than text NULL,
	nk_tien_su_gia_dinh text NULL,
	nk_kham_toan_than text NULL,
	nk_can_lam_sang_can_lam text NULL,
	nk_tom_tat_benh_an text NULL,
	nk_icd_benh_chinh_vao_khoa_code varchar(50) NULL,
	nk_icd_benh_chinh_vao_khoa_name text NULL,
	nk_phan_biet_vao_khoa text NULL,
	nk_tien_luong text NULL,
	nk_huong_dieu_tri text NULL,
	nk_bac_si_tao_benh_an_ho_ten text NULL,
	nk_bac_si_tao_benh_an_thoi_gian timestamp(6) NULL,
	nk_vao_ngay_thu int4 NULL, -- Vào viện ngày thứ mấy của bệnh
	nk_kham_tuan_hoan text NULL, -- Khám hệ tuần hoàn
	nk_kham_ho_hap text NULL, -- Khám hệ hô hấp
	nk_kham_tieu_hoa text NULL, -- Khám hệ tiêu hóa
	nk_kham_than_tiet_nieu_sinh_duc text NULL, -- Khám hệ thận - tiết niệu - sinh dục
	nk_kham_than_kinh text NULL, -- Khám hệ thần kinh
	nk_kham_co_xuong_khop text NULL, -- Khám hệ cơ - xương - khớp
	nk_kham_tai_mui_hong text NULL, -- Khám tai - mũi - họng
	nk_kham_rang_ham_mat text NULL, -- Khám răng - hàm - mặt
	nk_kham_mat text NULL, -- Khám mắt
	nk_kham_noi_tiet_dinh_duong_khac text NULL, -- Khám nội tiết, dinh dưỡng và các bệnh lý khác
	nk_icd_benh_kem_theo_vao_khoa_code text NULL, -- Mã ICD bệnh kèm theo vào khoa
	nk_icd_benh_kem_theo_vao_khoa_name text NULL, -- Tên ICD bệnh kèm theo vào khoa
	nk_con_thu_may text NULL, -- Con thứ mấy trong gia đình
	nk_tien_thai_para text NULL, -- Tiền thai para: SINH_DU_THANG / SINH_THIEU_THANG
	nk_tinh_trang_khi_sinh text NULL, -- Tình trạng khi sinh 
	nk_can_nang_luc_sinh text NULL, -- Cân nặng lúc sinh (kg)
	nk_di_tat_bam_sinh bool NULL, -- Có dị tật bẩm sinh không
	nk_cu_the_tat_bam_sinh text NULL, -- Cụ thể dị tật bẩm sinh
	nk_phat_trien_tinh_than text NULL, -- Phát triển về tinh thần
	nk_phat_trien_van_dong text NULL, -- Phát triển về vận động
	nk_cac_benh_ly_khac text NULL, -- Các bệnh lý khác
	nk_nuoi_duong text NULL, -- Nuôi dưỡng : 1=sữa mẹ, 2=sữa bò, 3=hỗn hợp
	nk_cai_sua_thang_thu text NULL, -- Cai sữa tháng thứ
	nk_cham_soc text NULL, -- Chăm sóc 1=tốt, 2=trung bình
	nk_da_tiem_chung text NULL, -- Đã tiêm chủng : 1-7 các loại vaccine
	nk_cu_the_benh_tiem_chung_khac text NULL, -- Cụ thể những bệnh tiêm chủng khác
	ngay_tao timestamp(6) DEFAULT CURRENT_TIMESTAMP NULL,
	nguoi_tao varchar(255) NULL,
	ngay_cap_nhat timestamp(6) NULL,
	nguoi_cap_nhat varchar(255) NULL,
	ngay_xoa timestamp(6) NULL,
	nguoi_xoa varchar(255) NULL,
	bi_xoa int2 DEFAULT 0 NULL,
	CONSTRAINT csyt_ba_chuyen_khoa_nhi_khoa_benh_an_id_key UNIQUE (benh_an_id),
	CONSTRAINT csyt_ba_chuyen_khoa_nhi_khoa_pkey PRIMARY KEY (id)
);

CREATE TABLE csyt_ba_chuyen_khoa_noi (
	id uuid DEFAULT gen_random_uuid() NOT NULL,
	benh_an_id uuid NOT NULL, -- FK csyt_benh_an_dieu_tri.id (UNIQUE — moi BA toi da 1 row BA Noi)
	ma_cskcb varchar(50) NOT NULL,
	tien_su_di_ung text NULL,
	tien_su_dieu_tri_truoc text NULL,
	the_trang varchar(200) NULL,
	da_niem_mac text NULL,
	hach_ngoai_bien text NULL,
	tuyen_giap text NULL,
	phu varchar(200) NULL,
	kham_than_tiet_nieu_sinh_duc text NULL, -- Khám gop than-tiet nieu va sinh duc theo form FE
	kham_noi_tiet_dinh_duong_khac text NULL, -- Khám noi tiet, dinh duong va cac kham khac
	tieng_tim text NULL,
	nhip_xoang bool NULL, -- TRUE = nhip xoang binh thuong, FALSE = loan nhip
	nghe_phoi text NULL,
	ran_phoi text NULL,
	gan text NULL,
	lach text NULL,
	chan_doan_so_bo text NULL,
	xn_sinh_hoa text NULL,
	xn_vi_sinh text NULL,
	xn_mien_dich text NULL,
	chan_doan_hinh_anh text NULL, -- Sieu am, X-quang, CT, MRI — text
	tham_do_chuc_nang text NULL, -- ECG, EEG, ho hap ky, dien co — text
	tom_tat_ket_qua_can_lam_sang text NULL,
	ke_hoach_dieu_tri text NULL,
	y_lenh_dieu_tri text NULL,
	tu_van_benh_nhan text NULL,
	che_do_hoat_dong text NULL,
	dieu_kien_tai_kham text NULL,
	ten_khac varchar(500) NULL,
	bi_xoa int2 DEFAULT 0 NOT NULL,
	ngay_tao timestamp NULL,
	nguoi_tao varchar(50) NULL,
	ngay_cap_nhat timestamp NULL,
	nguoi_cap_nhat varchar(50) NULL,
	ngay_xoa timestamp NULL,
	nguoi_xoa varchar(50) NULL,
	CONSTRAINT csyt_ba_chuyen_khoa_noi_benh_an_id_key UNIQUE (benh_an_id),
	CONSTRAINT csyt_ba_chuyen_khoa_noi_pkey PRIMARY KEY (id)
);

CREATE TABLE csyt_ba_chuyen_khoa_nt_nhi_yhct (
	id uuid DEFAULT gen_random_uuid() NOT NULL, -- Khóa chính
	benh_an_id uuid NOT NULL, -- FK csyt_benh_an_dieu_tri.id (UNIQUE)
	ma_cskcb varchar(50) NOT NULL, -- Mã cơ sở khám chữa bệnh
	nny_kham_toan_than text NULL, -- Khám toàn thân
	nny_kham_tuan_hoan text NULL, -- Khám tuần hoàn
	nny_kham_ho_hap text NULL, -- Khám hô hấp
	nny_kham_tieu_hoa text NULL, -- Khám tiêu hóa
	nny_kham_than_tiet_nieu_sinh_duc text NULL, -- Khám thận tiết niệu sinh dục
	nny_kham_than_kinh text NULL, -- Khám thần kinh
	nny_kham_co_xuong_khop text NULL, -- Khám cơ xương khớp
	nny_kham_tai_mui_hong text NULL, -- Khám tai mũi họng
	nny_kham_rang_ham_mat text NULL, -- Khám răng hàm mặt
	nny_kham_mat text NULL, -- Khám mắt
	nny_kham_noi_tiet_dinh_duong_khac text NULL, -- Khám nội tiết dinh dưỡng khác
	nny_tom_tat_benh_an text NULL, -- Tóm tắt bệnh án
	nny_icd_benh_chinh_vao_khoa_code varchar(100) NULL, -- Mã ICD bệnh chính vào khoa
	nny_icd_benh_chinh_vao_khoa_name varchar(500) NULL, -- Tên ICD bệnh chính vào khoa
	nny_icd_benh_kem_theo_vao_khoa_code varchar(100) NULL, -- Mã ICD bệnh kèm theo vào khoa
	nny_icd_benh_kem_theo_vao_khoa_name varchar(500) NULL, -- Tên ICD bệnh kèm theo vào khoa
	nny_phan_biet_vao_khoa text NULL, -- Chẩn đoán phân biệt vào khoa
	nny_tien_luong text NULL, -- Tiên lượng
	nny_huong_dieu_tri text NULL, -- Hướng điều trị
	nny_bac_si_tao_benh_an_thoi_gian timestamp NULL, -- Thời gian bác sĩ tạo bệnh án
	nny_ly_do_vao_vien_summary text NULL, -- Tóm tắt lý do vào viện
	nny_benh_su text NULL, -- Bệnh sử
	nny_can_lam_sang text NULL, -- Cận lâm sàng
	nny_phuong_duoc_yhct text NULL, -- Phương dược YHCT
	nny_phuong_phap_khong_dung_thuoc_yhct text NULL, -- Phương pháp không dùng thuốc YHCT
	nny_icd_yhct_noi_chuyen_code varchar(100) NULL, -- Mã ICD YHCT nơi chuyển
	nny_icd_yhct_noi_chuyen_name varchar(500) NULL, -- Tên ICD YHCT nơi chuyển
	nny_icd_yhct_kkb_code varchar(100) NULL, -- Mã ICD YHCT KKB
	nny_icd_yhct_kkb_name varchar(500) NULL, -- Tên ICD YHCT KKB
	nny_phau_thuat_yhct_vao_khoa bool DEFAULT false NULL, -- Có phẫu thuật YHCT vào khoa
	nny_thu_thuat_yhct_vao_khoa bool DEFAULT false NULL, -- Có thủ thuật YHCT vào khoa
	nny_icd_yhct_benh_chinh_code varchar(100) NULL, -- Mã ICD YHCT bệnh chính
	nny_icd_yhct_benh_chinh_name varchar(500) NULL, -- Tên ICD YHCT bệnh chính
	nny_icd_yhct_kem_theo_code varchar(100) NULL, -- Mã ICD YHCT kèm theo
	nny_icd_yhct_kem_theo_name varchar(500) NULL, -- Tên ICD YHCT kèm theo
	nny_icd_yhct_ra_vien_benh_chinh_code varchar(100) NULL, -- Mã ICD YHCT ra viện bệnh chính
	nny_icd_yhct_ra_vien_benh_chinh_name varchar(500) NULL, -- Tên ICD YHCT ra viện bệnh chính
	nny_icd_yhct_ra_vien_kem_theo_code varchar(100) NULL, -- Mã ICD YHCT ra viện kèm theo
	nny_icd_yhct_ra_vien_kem_theo_name varchar(500) NULL, -- Tên ICD YHCT ra viện kèm theo
	nny_icd_ra_vien_benh_chinh_code varchar(100) NULL, -- Mã ICD ra viện bệnh chính
	nny_icd_ra_vien_benh_chinh_name varchar(500) NULL, -- Tên ICD ra viện bệnh chính
	nny_icd_ra_vien_kem_theo_code varchar(100) NULL, -- Mã ICD ra viện kèm theo
	nny_icd_ra_vien_kem_theo_name varchar(500) NULL, -- Tên ICD ra viện kèm theo
	nny_icd_benh_chinh_vao_khoa_code_summary varchar(100) NULL, -- Tóm tắt mã ICD bệnh chính vào khoa
	nny_icd_benh_chinh_vao_khoa_name_summary varchar(500) NULL, -- Tóm tắt tên ICD bệnh chính vào khoa
	nny_icd_benh_kem_theo_vao_khoa_code_summary varchar(100) NULL, -- Tóm tắt mã ICD bệnh kèm theo vào khoa
	nny_icd_benh_kem_theo_vao_khoa_name_summary varchar(500) NULL, -- Tóm tắt tên ICD bệnh kèm theo vào khoa
	nny_icd_yhct_benh_chinh_vao_khoa_code_summary varchar(100) NULL, -- Tóm tắt mã ICD YHCT bệnh chính vào khoa
	nny_icd_yhct_benh_chinh_vao_khoa_name_summary varchar(500) NULL, -- Tóm tắt tên ICD YHCT bệnh chính vào khoa
	nny_icd_yhct_benh_kem_theo_vao_khoa_code_summary varchar(100) NULL, -- Tóm tắt mã ICD YHCT bệnh kèm theo vào khoa
	nny_icd_yhct_benh_kem_theo_vao_khoa_name_summary varchar(500) NULL, -- Tóm tắt tên ICD YHCT bệnh kèm theo vào khoa
	nny_phuong_phap_dieu_tri_hien_dai text NULL, -- Phương pháp điều trị hiện đại
	nny_phuong_phap_dieu_tri_yhct text NULL, -- Phương pháp điều trị YHCT
	nny_ket_qua_dieu_tri_summary int4 NULL, -- Tóm tắt kết quả điều trị
	nny_icd_ra_vien_benh_chinh_code_summary varchar(100) NULL, -- Tóm tắt mã ICD ra viện bệnh chính
	nny_icd_ra_vien_benh_chinh_name_summary varchar(500) NULL, -- Tóm tắt tên ICD ra viện bệnh chính
	nny_icd_ra_vien_kem_theo_code_summary varchar(100) NULL, -- Tóm tắt mã ICD ra viện kèm theo
	nny_icd_ra_vien_kem_theo_name_summary varchar(500) NULL, -- Tóm tắt tên ICD ra viện kèm theo
	nny_icd_yhct_ra_vien_benh_chinh_code_summary varchar(100) NULL, -- Tóm tắt mã ICD YHCT ra viện bệnh chính
	nny_icd_yhct_ra_vien_benh_chinh_name_summary varchar(500) NULL, -- Tóm tắt tên ICD YHCT ra viện bệnh chính
	nny_icd_yhct_ra_vien_kem_theo_code_summary varchar(100) NULL, -- Tóm tắt mã ICD YHCT ra viện kèm theo
	nny_icd_yhct_ra_vien_kem_theo_name_summary varchar(500) NULL, -- Tóm tắt tên ICD YHCT ra viện kèm theo
	nny_tinh_trang_ra_vien_summary text NULL, -- Tóm tắt tình trạng ra viện
	nny_vong_chan_hinh_thai text NULL, -- Vọng chẩn hình thái
	nny_vong_chan_than text NULL, -- Vọng chẩn thần
	nny_vong_chan_sac text NULL, -- Vọng chẩn sắc
	nny_vong_chan_trach text NULL, -- Vọng chẩn trạch
	nny_yhct_nt_vc_luoi_hinh_thai text NULL, -- Luỗi hình thái
	nny_yhct_nt_vc_luoi_chat text NULL, -- Luỗi chất
	nny_yhct_nt_vc_reu_luoi text NULL, -- Rêu luỗi
	nny_yhct_nt_vcn_tieng_noi text NULL, -- Văn chẩn tiếng nói
	nny_yhct_nt_vcn_hoi_tho text NULL, -- Văn chẩn hơi thở
	nny_yhct_nt_vcn_ho_bh text NULL, -- Văn chẩn ho bệnh
	nny_yhct_nt_vcn_ho_chi_tiet text NULL, -- Văn chẩn ho chi tiết
	nny_yhct_nt_vcn_o text NULL, -- Văn chẩn ợ
	nny_yhct_nt_vcn_nac text NULL, -- Văn chẩn nấc
	nny_yhct_nt_vcn_mui_co_the_bh text NULL, -- Văn chẩn mùi cơ thể bệnh
	nny_yhct_nt_vcn_mui_co_the_chi_tiet text NULL, -- Văn chẩn mùi cơ thể chi tiết
	nny_yhct_nt_vcn_chat_thai text NULL, -- Văn chẩn chất thải
	nny_yhct_nt_vch_han_nhiet_bh text NULL, -- Vấn chẩn hàn nhiệt bệnh
	nny_yhct_nt_vch_han_nhiet text NULL, -- Vấn chẩn hàn nhiệt
	nny_yhct_nt_vch_mo_hoi text NULL, -- Vấn chẩn mồ hôi
	nny_yhct_nt_vch_dau_mat_co_bh text NULL, -- Vấn chẩn đầu mắt cổ bệnh
	nny_yhct_nt_vch_dau_dau text NULL, -- Vấn chẩn đau đầu
	nny_yhct_nt_vch_hoa_mat_chong_mat text NULL, -- Vấn chẩn hoa mắt chóng mặt
	nny_yhct_nt_vch_mat text NULL, -- Vấn chẩn mắt
	nny_yhct_nt_vch_tai text NULL, -- Vấn chẩn tai
	nny_yhct_nt_vch_mui text NULL, -- Vấn chẩn mũi
	nny_yhct_nt_vch_hong text NULL, -- Vấn chẩn họng
	nny_yhct_nt_vch_co_vai text NULL, -- Vấn chẩn cổ vai
	nny_yhct_nt_vch_lung_bh text NULL, -- Vấn chẩn lưng bệnh
	nny_yhct_nt_vch_lung text NULL, -- Vấn chẩn lưng
	nny_yhct_nt_vch_nguc_bh text NULL, -- Vấn chẩn ngực bệnh
	nny_yhct_nt_vch_nguc text NULL, -- Vấn chẩn ngực
	nny_yhct_nt_vch_bung_bh text NULL, -- Vấn chẩn bụng bệnh
	nny_yhct_nt_vch_bung text NULL, -- Vấn chẩn bụng
	nny_yhct_nt_vch_chan_tay_bh text NULL, -- Vấn chẩn chân tay bệnh
	nny_yhct_nt_vch_chan_tay text NULL, -- Vấn chẩn chân tay
	nny_yhct_nt_vch_an_bh text NULL, -- Vấn chẩn ăn bệnh
	nny_yhct_nt_vch_an text NULL, -- Vấn chẩn ăn
	nny_yhct_nt_vch_uong_bh text NULL, -- Vấn chẩn uống bệnh
	nny_yhct_nt_vch_uong text NULL, -- Vấn chẩn uống
	nny_yhct_nt_vch_dai_tieu_tien_bh text NULL, -- Vấn chẩn đại tiểu tiện bệnh
	nny_yhct_nt_vch_tieu_tien text NULL, -- Vấn chẩn tiểu tiện
	nny_yhct_nt_vch_dai_tien text NULL, -- Vấn chẩn đại tiện
	nny_yhct_nt_vch_ngu_bh text NULL, -- Vấn chẩn ngủ bệnh
	nny_yhct_nt_vch_ngu text NULL, -- Vấn chẩn ngủ
	nny_yhct_nt_vch_sinh_duc_bh text NULL, -- Vấn chẩn sinh dục bệnh
	nny_yhct_nt_vch_nam_gioi text NULL, -- Vấn chẩn nam giới
	nny_yhct_nt_vch_kinh_nguyet_bh text NULL, -- Vấn chẩn kinh nguyệt bệnh
	nny_yhct_nt_vch_roi_loan_kinh_nguyet text NULL, -- Vấn chẩn rối loạn kinh nguyệt
	nny_yhct_nt_vch_thong_kinh text NULL, -- Vấn chẩn thống kinh
	nny_yhct_nt_vch_doi_ha_bh text NULL, -- Vấn chẩn đới hạ bệnh
	nny_yhct_nt_vch_doi_ha text NULL, -- Vấn chẩn đới hạ
	nny_yhct_nt_vch_yeu_to_lien_quan text NULL, -- Vấn chẩn yếu tố liên quan
	nny_yhct_nt_tc_xuc_chan_bh text NULL, -- Xúc chẩn xúc chẩn bệnh
	nny_yhct_nt_tc_co_xuong_khop_bh text NULL, -- Xúc chẩn cơ xương khớp bệnh
	nny_yhct_nt_tc_co_xuong_khop text NULL, -- Xúc chẩn cơ xương khớp
	nny_yhct_nt_tc_bung_bh text NULL, -- Xúc chẩn bụng bệnh
	nny_yhct_nt_tc_bung text NULL, -- Xúc chẩn bụng
	nny_yhct_nt_tc_mo_hoi_bh text NULL, -- Xúc chẩn mồ hôi bệnh
	nny_yhct_nt_tc_mo_hoi text NULL, -- Xúc chẩn mồ hôi
	nny_yhct_nt_tc_mach_chan text NULL, -- Xúc chẩn mạch chẩn
	nny_yhct_nt_tom_tat_tu_chan text NULL, -- Tóm tắt tứ chẩn
	nny_yhct_nt_bien_chung_luan_tri text NULL, -- Biện chứng luận trị
	nny_yhct_nt_benh_danh text NULL, -- Bệnh danh
	nny_yhct_nt_bat_cuong text NULL, -- Bát cương
	nny_yhct_nt_bat_cuong_chon text NULL, -- Bát cương chọn
	nny_yhct_nt_nguyen_nhan_chon text NULL, -- Nguyên nhân chọn
	nny_yhct_nt_tang_phu_chon text NULL, -- Tạng phủ chọn
	nny_yhct_nt_kinh_mach_chon text NULL, -- Kinh mạch chọn
	nny_yhct_nt_dinh_vi_benh_chon text NULL, -- Định vị bệnh chọn
	nny_con_thu_may varchar(100) NULL, -- Con thứ mấy
	nny_yhct_nhi_ts_du_thang text NULL, -- Tiền sử đủ tháng
	nny_yhct_nhi_ts_tinh_trang_de text NULL, -- Tiền sử tình trạng đẻ
	nny_yhct_nhi_ts_can_nang text NULL, -- Tiền sử cân nặng
	nny_yhct_nhi_ts_ngat_tho text NULL, -- Tiền sử ngạt thở
	nny_yhct_nhi_ts_rung_ron text NULL, -- Tiền sử rụng rốn
	nny_cai_sua_thang_thu varchar(100) NULL, -- Cai sữa tháng thứ mấy
	nny_yhct_nhi_ts_che_do_an_tren_1_tuoi varchar(100) NULL, -- Tiền sử chế độ ăn trên 1 tuổi
	nny_yhct_nhi_pd_biet_lay text NULL, -- Phát triển biết lẫy
	nny_yhct_nhi_pd_biet_bo text NULL, -- Phát triển biết bò
	nny_yhct_nhi_pd_biet_di text NULL, -- Phát triển biết đi
	nny_yhct_nhi_pd_biet_noi text NULL, -- Phát triển biết nói
	nny_yhct_nhi_pd_moc_rang text NULL, -- Phát triển mọc răng
	nny_yhct_nhi_pd_kinh_nguyet text NULL, -- Phát triển kinh nguyệt
	nny_yhct_nhi_da_tiem_chung text NULL, -- Đã tiêm chủng
	nny_yhct_nhi_benh_da_mac text NULL, -- Bệnh đã mắc
	nny_yhct_nhi_benh_da_mac_mo_ta text NULL, -- Mô tả bệnh đã mắc
	nny_yhct_nhi_benh_da_mac_ca_nhan text NULL, -- Bệnh đã mắc cá nhân
	nny_yhct_nhi_benh_da_mac_gia_dinh text NULL, -- Bệnh đã mắc gia đình
	nny_yhct_nhi_dac_diem_sinh_hoat text NULL, -- Đặc điểm sinh hoạt
	nny_yhct_nhi_tien_su_dac_biet text NULL, -- Tiền sử đặc biệt
	nny_yhct_nhi_vc_chi_tay_duong_di text NULL, -- Chỉ tay đường đi
	nny_yhct_nhi_vc_chi_tay_tinh_chat text NULL, -- Chỉ tay tính chất
	nny_yhct_nhi_vc_chi_tay_hinh_dang text NULL, -- Chỉ tay hình dáng
	nny_yhct_nhi_vc_chi_tay_mau_sac text NULL, -- Chỉ tay màu sắc
	nny_yhct_nhi_vcn_chat_thai_chi_tiet text NULL, -- Văn chẩn chất thải chi tiết
	nny_yhct_nhi_vch_mo_hoi_bh text NULL, -- Vấn chẩn mồ hôi bệnh
	nny_yhct_nhi_vch_mo_hoi_chi_tiet text NULL, -- Vấn chẩn mồ hôi chi tiết
	nny_yhct_nhi_tc_da text NULL, -- Xúc chẩn da
	nny_yhct_nhi_tc_thop text NULL, -- Xúc chẩn thóp
	nny_yhct_nhi_tc_tong_khan_phai text NULL, -- Xúc chẩn thốn khẩu phải
	nny_yhct_nhi_tc_tong_khan_trai text NULL, -- Xúc chẩn thốn khẩu trái
	nny_yhct_nhi_tc_vk_trai_thon text NULL, -- Xúc chẩn vĩ khẩu trái thốn
	nny_yhct_nhi_tc_vk_trai_quan text NULL, -- Xúc chẩn vĩ khẩu trái quan
	nny_yhct_nhi_tc_vk_trai_xich text NULL, -- Xúc chẩn vĩ khẩu trái xích
	nny_yhct_nhi_tc_vk_phai_thon text NULL, -- Xúc chẩn vĩ khẩu phải thốn
	nny_yhct_nhi_tc_vk_phai_quan text NULL, -- Xúc chẩn vĩ khẩu phải quan
	nny_yhct_nhi_tc_vk_phai_xich text NULL, -- Xúc chẩn vĩ khẩu phải xích
	nny_yhct_nhi_tc_mo_ta text NULL, -- Xúc chẩn mô tả
	nny_yhct_nhi_phuong_phap_khac text NULL, -- Phương pháp khác
	bi_xoa int2 DEFAULT 0 NOT NULL, -- 0 = chưa xóa, 1 = đã xóa mềm
	ngay_tao timestamp NULL, -- Ngày tạo bản ghi
	nguoi_tao varchar(50) NULL, -- Người tạo bản ghi
	ngay_cap_nhat timestamp NULL, -- Ngày cập nhật gần nhất
	nguoi_cap_nhat varchar(50) NULL, -- Người cập nhật gần nhất
	ngay_xoa timestamp NULL, -- Ngày xóa mềm
	nguoi_xoa varchar(50) NULL, -- Người thực hiện xóa mềm
	nny_yhct_nt_van_chan_mo_ta text NULL, -- Văn chẩn - Mô tả khác (nếu có)
	nny_yhct_nt_van_chan_hoi_mo_ta text NULL, -- Vấn chẩn - Mô tả khác (nếu có)
	nny_yhct_nt_vong_chan_mo_ta text NULL, -- Vọng chẩn - Mô tả thêm
	nny_nguyen_nhan_yhct_ra_vien_benh_chinh text NULL,
	nny_tai_bien_yhct int2 NULL,
	nny_bien_chung_yhct int2 NULL,
	nny_nguyen_nhan_ra_vien_benh_chinh text NULL,
	CONSTRAINT csyt_ba_chuyen_khoa_nt_nhi_yhct_benh_an_id_key UNIQUE (benh_an_id),
	CONSTRAINT csyt_ba_chuyen_khoa_nt_nhi_yhct_pkey PRIMARY KEY (id)
);

CREATE TABLE csyt_ba_chuyen_khoa_phcn (
	id uuid DEFAULT gen_random_uuid() NOT NULL,
	benh_an_id uuid NOT NULL, -- FK csyt_benh_an_dieu_tri.id (UNIQUE)
	ma_cskcb varchar(50) NOT NULL,
	phcn_giay_chung_nhan_khuyet_tat int4 NULL,
	phcn_dang_khuyet_tat varchar(500) NULL,
	phcn_muc_do_khuyet_tat varchar(500) NULL,
	phcn_ra_vien_van_dong_di_chuyen varchar(500) NULL,
	phcn_ra_vien_chuc_nang_sinh_hoat varchar(500) NULL,
	phcn_ra_vien_nhan_thuc varchar(500) NULL,
	phcn_ra_vien_chuc_nang_khac varchar(500) NULL,
	phcn_ra_vien_tham_gia_gia_dinh_xa_hoi varchar(500) NULL,
	phcn_ra_vien_yeu_to_moi_truong_ca_nhan varchar(500) NULL,
	phcn_ly_do_vao_vien text NULL,
	phcn_vao_ngay_thu int4 NULL,
	phcn_kham_toan_than text NULL,
	phcn_kham_co_xuong_khop text NULL,
	phcn_kham_noi_tiet_dinh_duong_khac text NULL,
	phcn_can_lam_sang_can_lam text NULL,
	phcn_tom_tat_benh_an text NULL,
	phcn_icd_benh_chinh_vao_khoa_code varchar(100) NULL,
	phcn_icd_benh_chinh_vao_khoa_name varchar(500) NULL,
	phcn_icd_benh_kem_theo_vao_khoa_code varchar(100) NULL,
	phcn_icd_benh_kem_theo_vao_khoa_name varchar(500) NULL,
	phcn_phan_biet_vao_khoa text NULL,
	phcn_bac_si_tao_benh_an_ho_ten varchar(255) NULL,
	phcn_bac_si_tao_benh_an_thoi_gian timestamp NULL,
	phcn_tien_su_di_ung text NULL,
	phcn_tinh_trang_dau text NULL,
	phcn_kham_tam_than_than_kinh text NULL,
	phcn_kho_khan_chinh_hoat_dong text NULL,
	phcn_muc_tieu_dieu_tri_phcn text NULL,
	phcn_chuong_trinh_can_thiep_phcn text NULL,
	phcn_dieu_tri_benh_kem_theo_cham_soc text NULL,
	bi_xoa int2 DEFAULT 0 NOT NULL,
	ngay_tao timestamp NULL,
	nguoi_tao varchar(50) NULL,
	ngay_cap_nhat timestamp NULL,
	nguoi_cap_nhat varchar(50) NULL,
	ngay_xoa timestamp NULL,
	nguoi_xoa varchar(50) NULL,
	CONSTRAINT csyt_ba_chuyen_khoa_phcn_benh_an_id_key UNIQUE (benh_an_id),
	CONSTRAINT csyt_ba_chuyen_khoa_phcn_pkey PRIMARY KEY (id)
);

CREATE TABLE csyt_ba_chuyen_khoa_phcn_nhi (
	id uuid DEFAULT gen_random_uuid() NOT NULL,
	benh_an_id uuid NOT NULL, -- FK csyt_benh_an_dieu_tri.id (UNIQUE)
	ma_cskcb varchar(50) NOT NULL,
	giay_chung_nhan_khuyet_tat int4 NULL,
	dang_khuyet_tat varchar(500) NULL,
	muc_do_khuyet_tat varchar(500) NULL,
	ra_vien_van_dong_di_chuyen text NULL,
	ra_vien_chuc_nang_sinh_hoat text NULL,
	ra_vien_nhan_thuc text NULL,
	ra_vien_chuc_nang_khac text NULL,
	ra_vien_tham_gia_gia_dinh_xa_hoi text NULL,
	ra_vien_yeu_to_moi_truong_ca_nhan text NULL,
	kham_than_tiet_nieu_sinh_duc text NULL,
	tien_su_san_khoa_sinh bool NULL,
	tien_su_san_khoa_som bool NULL,
	tien_su_san_khoa_say bool NULL,
	tien_su_san_khoa_song bool NULL,
	tuoi_me_khi_sinh_tre varchar(500) NULL,
	tinh_trang_suc_khoe_me_mang_thai text NULL,
	con_thu_may varchar(500) NULL,
	tuoi_thai_tuan int4 NULL,
	tuoi_thai_phan_loai int4 NULL,
	can_nang_luc_sinh varchar(500) NULL,
	can_nang_phan_loai int4 NULL,
	tinh_trang_khi_sinh int4 NULL,
	tinh_trang_sau_sinh text NULL,
	tiem_phong_vacxin text NULL,
	chi_dinh_dieu_tri_can_thiep text NULL,
	dieu_tri_benh_ly_kem_theo text NULL,
	che_do_cham_soc text NULL,
	hoi_nhap_xa_hoi text NULL,
	bi_xoa int2 DEFAULT 0 NOT NULL,
	ngay_tao timestamp NULL,
	nguoi_tao varchar(50) NULL,
	ngay_cap_nhat timestamp NULL,
	nguoi_cap_nhat varchar(50) NULL,
	ngay_xoa timestamp NULL,
	nguoi_xoa varchar(50) NULL,
	so_con_trong_gia_dinh int4 NULL, -- Tiền sử gia đình - Số con trong gia đình
	so_tre_co_bat_thuong int4 NULL, -- Tiền sử gia đình - Số trẻ có bất thường
	gia_dinh_nhiem_chat_doc_da_cam text NULL, -- Tiền sử gia đình - Gia đình có người nhiễm chất độc da cam
	CONSTRAINT csyt_ba_chuyen_khoa_phcn_nhi_benh_an_id_key UNIQUE (benh_an_id),
	CONSTRAINT csyt_ba_chuyen_khoa_phcn_nhi_pkey PRIMARY KEY (id)
);

CREATE TABLE csyt_ba_chuyen_khoa_phu_khoa (
	id uuid DEFAULT gen_random_uuid() NOT NULL,
	benh_an_id uuid NOT NULL,
	ma_cskcb varchar(50) NOT NULL,
	pk_ly_do_vao_vien text NULL,
	pk_ly_do_nhap_vien_id uuid NULL,
	pk_vao_ngay_thu int4 NULL,
	pk_qua_trinh_benh_ly text NULL,
	pk_tien_su_ban_than text NULL,
	pk_tien_su_gia_dinh text NULL,
	pk_bat_dau_thay_kinh_nam varchar(20) NULL,
	pk_bat_dau_thay_kinh_tuoi varchar(20) NULL,
	pk_tinh_chat_kinh_nguyet varchar(100) NULL,
	pk_so_ngay_thay_kinh varchar(20) NULL,
	pk_luong_kinh varchar(100) NULL,
	pk_kinh_lan_cuoi_ngay varchar(50) NULL,
	pk_dau_bung bool NULL,
	pk_thoi_gian_dau_bung int4 NULL, -- Thời gian đau bụng
	pk_lay_chong_nam varchar(20) NULL,
	pk_lay_chong_tuoi varchar(20) NULL,
	pk_het_kinh_nam varchar(20) NULL,
	pk_het_kinh_tuoi varchar(20) NULL,
	pk_benh_phu_khoa_da_dieu_tri text NULL,
	pk_tien_thai_para varchar(50) NULL,
	pk_kham_da_niem_mac text NULL,
	pk_kham_hach text NULL,
	pk_kham_vu text NULL,
	pk_kham_tuan_hoan text NULL,
	pk_kham_ho_hap text NULL,
	pk_kham_tieu_hoa text NULL,
	pk_kham_than_kinh text NULL,
	pk_kham_co_xuong_khop text NULL,
	pk_kham_than_tiet_nieu_sinh_duc text NULL,
	pk_kham_khac text NULL,
	pk_kham_sinh_duc_thu_phat text NULL,
	pk_kham_moi_lon text NULL,
	pk_kham_moi_be text NULL,
	pk_kham_am_vat text NULL,
	pk_kham_am_ho text NULL,
	pk_kham_mang_trinh text NULL,
	pk_kham_tang_sinh_mon text NULL,
	pk_kham_am_dao text NULL,
	pk_kham_co_tu_cung text NULL,
	pk_kham_than_tu_cung text NULL,
	pk_kham_phan_phu text NULL,
	pk_kham_cac_tui_cung text NULL,
	pk_can_lam_sang_can_lam text NULL,
	pk_tom_tat_benh_an text NULL,
	pk_icd_benh_chinh_vao_khoa_code varchar(50) NULL,
	pk_icd_benh_chinh_vao_khoa_name varchar(500) NULL,
	pk_icd_benh_kem_theo_vao_khoa_code varchar(200) NULL,
	pk_icd_benh_kem_theo_vao_khoa_name text NULL,
	pk_phan_biet_vao_khoa text NULL,
	pk_tien_luong text NULL,
	pk_huong_dieu_tri text NULL,
	pk_bac_si_tao_benh_an_ho_ten varchar(255) NULL,
	pk_bac_si_tao_benh_an_thoi_gian timestamp NULL,
	ngay_tao timestamp DEFAULT CURRENT_TIMESTAMP NULL,
	nguoi_tao varchar(255) NULL,
	ngay_cap_nhat timestamp NULL,
	nguoi_cap_nhat varchar(255) NULL,
	ngay_xoa timestamp NULL,
	nguoi_xoa varchar(255) NULL,
	bi_xoa int2 DEFAULT 0 NULL
);

CREATE TABLE csyt_ba_chuyen_khoa_rhm (
	id uuid DEFAULT gen_random_uuid() NOT NULL,
	benh_an_id uuid NOT NULL, -- FK csyt_benh_an_dieu_tri.id (UNIQUE)
	ma_cskcb varchar(50) NOT NULL,
	kham_da_mo_duoi_da text NULL,
	ten_khac varchar(500) NULL,
	hinh_anh_phai uuid NULL,
	hinh_anh_thang uuid NULL,
	hinh_anh_trai uuid NULL,
	hinh_anh_ham_tren_hong uuid NULL,
	hinh_anh_ham_duoi uuid NULL,
	hinh_anh_phan_loai_khe_ho uuid NULL,
	bi_xoa int2 DEFAULT 0 NOT NULL,
	ngay_tao timestamp NULL,
	nguoi_tao varchar(50) NULL,
	ngay_cap_nhat timestamp NULL,
	nguoi_cap_nhat varchar(50) NULL,
	ngay_xoa timestamp NULL,
	nguoi_xoa varchar(50) NULL,
	rhm_kham_ngoai_khoa text NULL,
	CONSTRAINT csyt_ba_chuyen_khoa_rhm_benh_an_id_key UNIQUE (benh_an_id),
	CONSTRAINT csyt_ba_chuyen_khoa_rhm_pkey PRIMARY KEY (id)
);

CREATE TABLE csyt_ba_chuyen_khoa_san (
	id uuid DEFAULT gen_random_uuid() NOT NULL,
	benh_an_id uuid NOT NULL, -- ID bệnh án tổng (FK to csyt_benh_an_dieu_tri)
	ma_cskcb varchar(50) NOT NULL,
	san_ly_do_vao_vien text NULL,
	san_vao_ngay_thu int4 NULL,
	san_tien_su_ban_than text NULL,
	san_tien_su_gia_dinh text NULL,
	san_kinh_cuoi_tu timestamp NULL,
	san_kinh_cuoi_den timestamp NULL,
	san_tuoi_thai varchar(50) NULL,
	san_kham_thai_tai varchar(255) NULL,
	san_tiem_phong_uon_van bool NULL,
	san_so_lan_tiem varchar(100) NULL,
	san_bat_dau_chuyen_da_tu timestamp NULL,
	san_dau_hieu_luc_dau text NULL,
	san_bien_chuyen text NULL,
	san_bat_dau_thay_kinh_nam varchar(100) NULL,
	san_bat_dau_thay_kinh_tuoi varchar(100) NULL,
	san_tinh_chat_kinh_nguyet varchar(100) NULL,
	san_chu_ky_kinh varchar(50) NULL,
	san_luong_kinh varchar(100) NULL,
	san_lay_chong_nam varchar(100) NULL,
	san_lay_chong_tuoi varchar(100) NULL,
	san_benh_phu_khoa_da_dieu_tri text NULL,
	san_tien_su_san_khoa_list jsonb NULL, -- Tiền sử sản khoa (JSONB array)
	san_kham_toan_trang text NULL,
	san_kham_tuan_hoan text NULL,
	san_kham_ho_hap text NULL,
	san_kham_tieu_hoa text NULL,
	san_kham_tiet_nieu text NULL,
	san_kham_bo_phan_khac text NULL,
	san_hinh_dang_tc varchar(100) NULL,
	san_tu_the varchar(100) NULL,
	san_chieu_cao_tc varchar(50) NULL,
	san_vong_bung varchar(50) NULL,
	san_con_co_tc varchar(100) NULL,
	san_tim_thai varchar(50) NULL,
	san_kham_vu text NULL,
	san_bung_co_seo_pt_cu bool NULL,
	san_chi_so_bishop varchar(50) NULL,
	san_am_ho text NULL,
	san_am_dao text NULL,
	san_tang_sinh_mon text NULL,
	san_co_tu_cung text NULL,
	san_phan_phu text NULL,
	san_mau_sac_nuoc_oi varchar(100) NULL,
	san_nuoc_oi_nhieu_it varchar(100) NULL,
	san_ngoi varchar(100) NULL,
	san_the varchar(100) NULL,
	san_kieu_the varchar(100) NULL,
	san_duong_kinh_nho_ha_ve varchar(50) NULL,
	san_tinh_trang_oi text NULL, -- Tình trạng ối (JSON array string: [1,2,3])
	san_oi_vo_luc timestamp NULL,
	san_oi_vo text NULL, -- Ối vỡ (JSON array string: [1,2])
	san_do_lot text NULL, -- Độ lọt (JSON array string: [1,2,3,4])
	san_can_lam_sang_can_lam text NULL,
	san_icd_benh_chinh_vao_khoa_code varchar(50) NULL,
	san_icd_benh_chinh_vao_khoa_name varchar(500) NULL,
	san_phan_biet_vao_khoa text NULL,
	san_tien_luong text NULL,
	san_phuong_phap_chinh text NULL,
	san_bac_si_tao_benh_an_ho_ten varchar(255) NULL,
	san_bac_si_tao_benh_an_thoi_gian timestamp NULL,
	san_ngay_de varchar(50) NULL,
	san_ngoi_thai varchar(100) NULL,
	san_cach_thuc_de varchar(255) NULL,
	san_kiem_soat_tu_cung varchar(255) NULL,
	san_tinh_hinh_phau_thuat text NULL,
	san_phuong_phap_phau_thuat text NULL,
	san_tre_so_sinh_so_luong text NULL,
	san_tre_so_sinh_gioi_tinh text NULL,
	san_tinh_trang_tre_so_sinh int4 NULL,
	san_vao_buong_de_luc timestamp NULL,
	san_nguoi_theo_doi_id uuid NULL,
	san_chuc_danh_nguoi_theo_doi varchar(255) NULL,
	san_de_luc timestamp NULL,
	san_apgar_1_phut varchar(100) NULL,
	san_apgar_5_phut varchar(100) NULL,
	san_apgar_10_phut varchar(100) NULL,
	san_can_nang_tre_so_sinh varchar(50) NULL,
	san_chieu_cao_tre_so_sinh varchar(50) NULL,
	san_vong_dau_tre_so_sinh varchar(50) NULL,
	san_con_don_thai text NULL,
	san_con_da_thai text NULL,
	san_tat_bam_sinh bool NULL,
	san_cu_the_tat_bam_sinh text NULL,
	san_co_hau_mon bool NULL,
	san_tinh_trang_tre_so_sinh_sau_de text NULL,
	san_xu_ly_ket_qua_tre_so_sinh text NULL,
	san_rau text NULL,
	san_rau_so_luc timestamp NULL,
	san_cach_so_rau varchar(255) NULL,
	san_mat_mang varchar(100) NULL,
	san_mat_mui varchar(100) NULL,
	san_banh_rau varchar(255) NULL,
	san_can_nang_rau varchar(50) NULL,
	san_cuong_rau_dai varchar(50) NULL,
	san_rau_cuon_co bool NULL,
	san_co_chay_mau_sau_so bool NULL,
	san_luong_mau_mat varchar(100) NULL,
	san_kiem_soat_tu_cung_so_rau bool NULL,
	san_xu_ly_ket_qua_so_rau text NULL,
	san_da_niem_mac text NULL,
	san_ly_do_can_thiep text NULL,
	san_phuong_phap_de text NULL,
	san_tang_sinh_mon_sau_de text NULL,
	san_phuong_phap_khau_loai_chi text NULL,
	san_co_tu_cung_sau_de text NULL,
	san_nguyen_nhan_benh_chinh text NULL,
	ngay_tao timestamp DEFAULT CURRENT_TIMESTAMP NULL,
	nguoi_tao varchar(255) NULL,
	ngay_cap_nhat timestamp NULL,
	nguoi_cap_nhat varchar(255) NULL,
	ngay_xoa timestamp NULL,
	nguoi_xoa varchar(255) NULL,
	bi_xoa int2 DEFAULT 0 NULL,
	CONSTRAINT csyt_ba_chuyen_khoa_san_benh_an_id_key UNIQUE (benh_an_id),
	CONSTRAINT csyt_ba_chuyen_khoa_san_pkey PRIMARY KEY (id)
);

CREATE TABLE csyt_ba_chuyen_khoa_so_sinh (
	id uuid DEFAULT gen_random_uuid() NOT NULL,
	benh_an_id uuid NOT NULL, -- FK csyt_benh_an_dieu_tri.id (UNIQUE)
	ma_cskcb varchar(50) NOT NULL,
	dien_bien_benh text NULL,
	oi_vo_thoi_gian timestamp NULL,
	oi_vo_mau_sac varchar(500) NULL,
	de_thoi_gian timestamp NULL,
	cach_de int4 NULL,
	ly_do_can_thiep_de text NULL,
	tinh_trang_khi_ra_doi int4 NULL,
	nguoi_do_de_id uuid NULL,
	apgar_1_phut varchar(50) NULL,
	apgar_5_phut varchar(50) NULL,
	apgar_10_phut varchar(50) NULL,
	can_nang_so_sinh varchar(50) NULL,
	tinh_trang_dinh_duong_sau_sinh text NULL,
	phuong_phap_hoi_sinh varchar(500) NULL,
	nguoi_chuyen_so_sinh_id uuid NULL,
	co_hau_mon bool NULL,
	di_tat_bam_sinh bool NULL,
	cu_the_di_tat text NULL,
	tinh_hinh_so_sinh_vao_khoa text NULL,
	tinh_trang_toan_than text NULL,
	mau_sac_da int4 NULL,
	mau_sac_da_khac varchar(500) NULL,
	nhip_tho varchar(50) NULL,
	nghe_phoi text NULL,
	nhip_tim varchar(50) NULL,
	chi_so_silverman int4 NULL,
	kham_bung text NULL,
	co_quan_sinh_duc_ngoai text NULL,
	phan_xa text NULL,
	truong_luc_co text NULL,
	chi_dinh_theo_doi text NULL,
	nhom_mau_me text NULL,
	tien_thai_para text NULL,
	chuc_danh_nguoi_chuyen_so_sinh text NULL,
	chuc_danh_nguoi_do_de text NULL,
	bi_xoa int2 DEFAULT 0 NOT NULL,
	ngay_tao timestamp NULL,
	nguoi_tao varchar(50) NULL,
	ngay_cap_nhat timestamp NULL,
	nguoi_cap_nhat varchar(50) NULL,
	ngay_xoa timestamp NULL,
	nguoi_xoa varchar(50) NULL,
	CONSTRAINT csyt_ba_chuyen_khoa_so_sinh_benh_an_id_key UNIQUE (benh_an_id),
	CONSTRAINT csyt_ba_chuyen_khoa_so_sinh_pkey PRIMARY KEY (id)
);

CREATE TABLE csyt_ba_chuyen_khoa_tam_than (
	id uuid DEFAULT gen_random_uuid() NOT NULL,
	benh_an_id uuid NOT NULL, -- FK csyt_benh_an_dieu_tri.id (UNIQUE)
	ma_cskcb varchar(50) NOT NULL,
	tt_ly_do_vao_vien text NULL, -- Lý do vào viện
	tt_ly_do_nhap_vien_id uuid NULL, -- ID lý do nhập viện
	tt_vao_ngay_thu int4 NULL, -- Vào ngày thứ mấy của bệnh
	tt_qua_trinh_benh_ly text NULL, -- Quá trình bệnh lý
	tt_tien_su_ban_than text NULL, -- Tiền sử bản thân
	tt_tien_su_gia_dinh text NULL, -- Tiền sử gia đình
	tt_di_ung_co bool NULL, -- Dị ứng có (0/1)
	tt_di_ung_thang int4 NULL, -- Dị ứng số tháng
	tt_ma_tuy_co bool NULL, -- Ma túy có (0/1)
	tt_ma_tuy_thang int4 NULL, -- Ma túy số tháng
	tt_ruou_bia_co bool NULL, -- Rượu bia có (0/1)
	tt_ruou_bia_thang int4 NULL, -- Rượu bia số tháng
	tt_thuoc_la_co bool NULL, -- Thuốc lá có (0/1)
	tt_thuoc_la_thang int4 NULL, -- Thuốc lá số tháng
	tt_thuoc_lao_co bool NULL, -- Thuốc lào có (0/1)
	tt_thuoc_lao_thang int4 NULL, -- Thuốc lào số tháng
	tt_khac_co bool NULL, -- Khác có (0/1)
	tt_khac_thang int4 NULL, -- Khác số tháng
	tt_kham_toan_than text NULL, -- Khám toàn thân
	tt_kham_tuan_hoan text NULL, -- Khám tuần hoàn
	tt_kham_ho_hap text NULL, -- Khám hô hấp
	tt_kham_tieu_hoa text NULL, -- Khám tiêu hóa
	tt_kham_than_tiet_nieu_sinh_duc text NULL, -- Khám thận tiết niệu sinh dục
	tt_kham_co_xuong_khop text NULL, -- Khám cơ xương khớp
	tt_kham_tai_mui_hong text NULL, -- Khám tai mũi họng
	tt_kham_rang_ham_mat text NULL, -- Khám răng hàm mặt
	tt_kham_mat text NULL, -- Khám mắt
	tt_kham_noi_tiet_dinh_duong_khac text NULL, -- Khám nội tiết dinh dưỡng khác
	tt_can_lam_sang_can_lam text NULL, -- Các xét nghiệm cận lâm sàng cần làm
	tt_tom_tat_benh_an text NULL, -- Tóm tắt bệnh án
	tt_kham_than_kinh_day_tk_so_nao text NULL, -- Khám thần kinh - Dây TK sọ não
	tt_kham_than_kinh_day_mat text NULL, -- Khám thần kinh - Đáy mắt
	tt_kham_than_kinh_van_dong text NULL, -- Khám thần kinh - Vận động
	tt_kham_than_kinh_truong_luc_co text NULL, -- Khám thần kinh - Trương lực cơ
	tt_kham_than_kinh_cam_giac text NULL, -- Khám thần kinh - Cảm giác
	tt_kham_than_kinh_phan_xa text NULL, -- Khám thần kinh - Phản xạ
	tt_kham_tam_than_bieu_hien_chung text NULL, -- Khám tâm thần - Biểu hiện chung
	tt_kham_tam_than_dinh_huong_khong_gian text NULL, -- Khám tâm thần - Định hướng không gian
	tt_kham_tam_than_dinh_huong_thoi_gian text NULL, -- Khám tâm thần - Định hướng thời gian
	tt_kham_tam_than_dinh_huong_ban_than text NULL, -- Khám tâm thần - Định hướng bản thân
	tt_kham_tam_than_tinh_cam_cam_xuc text NULL, -- Khám tâm thần - Tình cảm cảm xúc
	tt_kham_tam_than_tri_giac text NULL, -- Khám tâm thần - Tri giác
	tt_kham_tam_than_tu_duy_hinh_thuc text NULL, -- Khám tâm thần - Tư duy hình thức
	tt_kham_tam_than_tu_duy_noi_dung text NULL, -- Khám tâm thần - Tư duy nội dung
	tt_kham_tam_than_hanh_vi_co_y_chi text NULL, -- Khám tâm thần - Hành vi có ý chí
	tt_kham_tam_than_hanh_vi_ban_nang text NULL, -- Khám tâm thần - Hành vi bản năng
	tt_kham_tam_than_tri_nho_may_moc text NULL, -- Khám tâm thần - Trí nhớ máy móc
	tt_kham_tam_than_tri_nho_thong_hieu text NULL, -- Khám tâm thần - Trí nhớ thông hiểu
	tt_kham_tam_than_tri_nang_phan_tich text NULL, -- Khám tâm thần - Trí năng phân tích
	tt_kham_tam_than_tri_nang_tong_hop text NULL, -- Khám tâm thần - Trí năng tổng hợp
	tt_kham_tam_than_chu_y text NULL, -- Khám tâm thần - Chú ý
	tt_icd_benh_chinh_vao_khoa_code varchar(50) NULL, -- Mã ICD bệnh chính vào khoa
	tt_icd_benh_chinh_vao_khoa_name varchar(500) NULL, -- Tên ICD bệnh chính vào khoa
	tt_icd_benh_kem_theo_vao_khoa_code varchar(200) NULL, -- Mã ICD bệnh kèm theo vào khoa
	tt_icd_benh_kem_theo_vao_khoa_name text NULL, -- Tên ICD bệnh kèm theo vào khoa
	tt_phan_biet_vao_khoa text NULL, -- Chẩn đoán phân biệt vào khoa
	tt_tien_luong text NULL, -- Tiên lượng
	tt_huong_dieu_tri text NULL, -- Hướng điều trị
	tt_bac_si_tao_benh_an_ho_ten varchar(255) NULL, -- Họ tên bác sĩ tạo bệnh án
	tt_bac_si_tao_benh_an_thoi_gian timestamp NULL, -- Thời gian bác sĩ tạo bệnh án
	bi_xoa int2 DEFAULT 0 NOT NULL,
	ngay_tao timestamp NULL,
	nguoi_tao varchar(50) NULL,
	ngay_cap_nhat timestamp NULL,
	nguoi_cap_nhat varchar(50) NULL,
	ngay_xoa timestamp NULL,
	nguoi_xoa varchar(50) NULL,
	CONSTRAINT csyt_ba_chuyen_khoa_tam_than_benh_an_id_key UNIQUE (benh_an_id),
	CONSTRAINT csyt_ba_chuyen_khoa_tam_than_pkey PRIMARY KEY (id)
);

CREATE TABLE csyt_ba_chuyen_khoa_tmh (
	id uuid DEFAULT gen_random_uuid() NOT NULL,
	benh_an_id uuid NOT NULL, -- FK csyt_benh_an_dieu_tri.id (UNIQUE)
	ma_cskcb varchar(50) NOT NULL,
	kham_tai text NULL,
	kham_mui text NULL,
	kham_hong text NULL,
	kham_thanh_quan text NULL,
	thinh_luc_do text NULL,
	noi_soi_tai_mui_hong text NULL,
	chan_doan_so_bo text NULL,
	ten_khac varchar(500) NULL,
	hinh_anh_hong uuid NULL,
	bi_xoa int2 DEFAULT 0 NOT NULL,
	ngay_tao timestamp NULL,
	nguoi_tao varchar(50) NULL,
	ngay_cap_nhat timestamp NULL,
	nguoi_cap_nhat varchar(50) NULL,
	ngay_xoa timestamp NULL,
	nguoi_xoa varchar(50) NULL,
	hinh_anh_mang_nhi_phai uuid NULL, -- Hình ảnh màng nhĩ phải
	hinh_anh_mang_nhi_trai uuid NULL, -- Hình ảnh màng nhĩ trái
	hinh_anh_mui_truoc uuid NULL, -- Hình ảnh mũi trước
	hinh_anh_mui_sau uuid NULL, -- Hình ảnh mũi sau
	hinh_anh_thanh_quan uuid NULL, -- Hình ảnh thanh quản
	hinh_anh_co_nghieng_phai uuid NULL, -- Hình ảnh cổ nghiêng phải
	hinh_anh_co_nghieng_trai uuid NULL, -- Hình ảnh cổ nghiêng trái
	kham_da_mo_duoi_da text NULL, -- Khám da và mô dưới da
	tmh_kham_ngoai_khoa text NULL,
	CONSTRAINT csyt_ba_chuyen_khoa_tmh_benh_an_id_key UNIQUE (benh_an_id),
	CONSTRAINT csyt_ba_chuyen_khoa_tmh_pkey PRIMARY KEY (id)
);

CREATE TABLE csyt_ba_chuyen_khoa_truyen_nhiem (
	id uuid DEFAULT gen_random_uuid() NOT NULL,
	benh_an_id uuid NOT NULL,
	ma_cskcb varchar(50) NOT NULL,
	tn_ly_do_vao_vien text NULL,
	tn_vao_ngay_thu int4 NULL,
	tn_qua_trinh_benh_ly text NULL,
	tn_tien_su_ban_than text NULL,
	tn_tien_su_gia_dinh text NULL,
	tn_di_ung_co bool NULL,
	tn_di_ung_thang int4 NULL,
	tn_ma_tuy_co bool NULL,
	tn_ma_tuy_thang int4 NULL,
	tn_ruou_bia_co bool NULL,
	tn_ruou_bia_thang int4 NULL,
	tn_thuoc_la_co bool NULL,
	tn_thuoc_la_thang int4 NULL,
	tn_thuoc_lao_co bool NULL,
	tn_thuoc_lao_thang int4 NULL,
	tn_khac_co bool NULL,
	tn_khac_thang int4 NULL,
	tn_kham_toan_than text NULL,
	tn_kham_tuan_hoan text NULL,
	tn_kham_ho_hap text NULL,
	tn_kham_tieu_hoa text NULL,
	tn_kham_than_tiet_nieu_sinh_duc text NULL,
	tn_kham_than_kinh text NULL,
	tn_kham_co_xuong_khop text NULL,
	tn_kham_tai_mui_hong text NULL,
	tn_kham_rang_ham_mat text NULL,
	tn_kham_mat text NULL,
	tn_kham_noi_tiet_dinh_duong_khac text NULL,
	tn_can_lam_sang_can_lam text NULL,
	tn_tom_tat_benh_an text NULL,
	tn_icd_benh_chinh_vao_khoa_code varchar(50) NULL,
	tn_icd_benh_chinh_vao_khoa_name varchar(500) NULL,
	tn_icd_benh_kem_theo_vao_khoa_code varchar(200) NULL,
	tn_icd_benh_kem_theo_vao_khoa_name text NULL,
	tn_phan_biet_vao_khoa text NULL,
	tn_tien_luong text NULL,
	tn_huong_dieu_tri text NULL,
	tn_bac_si_tao_benh_an_ho_ten varchar(255) NULL,
	tn_bac_si_tao_benh_an_thoi_gian timestamp NULL,
	tn_dich_te text NULL,
	tn_benh_cap_tinh_luu_hanh text NULL,
	tn_da_song_noi_nao text NULL,
	tn_da_song_thoi_gian varchar(50) NULL,
	tn_moi_sinh text NULL,
	ngay_tao timestamp DEFAULT CURRENT_TIMESTAMP NULL,
	nguoi_tao varchar(255) NULL,
	ngay_cap_nhat timestamp NULL,
	nguoi_cap_nhat varchar(255) NULL,
	ngay_xoa timestamp NULL,
	nguoi_xoa varchar(255) NULL,
	bi_xoa int2 DEFAULT 0 NULL
);

CREATE TABLE csyt_ba_chuyen_khoa_tuyen_xa_phuong (
	id uuid DEFAULT gen_random_uuid() NOT NULL, -- Khóa chính
	benh_an_id uuid NOT NULL, -- FK csyt_benh_an_dieu_tri.id (UNIQUE)
	ma_cskcb varchar(50) NOT NULL, -- Mã cơ sở khám chữa bệnh
	txp_tom_tat_benh_an text NULL, -- Tóm tắt bệnh án
	txp_icd_benh_chinh_vao_khoa_code varchar(100) NULL, -- Mã ICD bệnh chính vào khoa
	txp_icd_benh_chinh_vao_khoa_name varchar(500) NULL, -- Tên ICD bệnh chính vào khoa
	txp_icd_benh_kem_theo_vao_khoa_code varchar(100) NULL, -- Mã ICD bệnh kèm theo vào khoa
	txp_icd_benh_kem_theo_vao_khoa_name varchar(500) NULL, -- Tên ICD bệnh kèm theo vào khoa
	txp_tien_luong text NULL, -- Tiên lượng
	txp_huong_dieu_tri text NULL, -- Hướng điều trị
	txp_bac_si_tao_benh_an_ho_ten varchar(255) NULL, -- Họ tên bác sĩ tạo bệnh án
	txp_bac_si_tao_benh_an_thoi_gian timestamp NULL, -- Thời gian bác sĩ tạo bệnh án
	txp_kham_cac_co_quan text NULL, -- Khám các cơ quan
	bi_xoa int2 DEFAULT 0 NOT NULL, -- 0 = chưa xóa, 1 = đã xóa mềm
	ngay_tao timestamp NULL, -- Ngày tạo bản ghi
	nguoi_tao varchar(50) NULL, -- Người tạo bản ghi
	ngay_cap_nhat timestamp NULL, -- Ngày cập nhật gần nhất
	nguoi_cap_nhat varchar(50) NULL, -- Người cập nhật gần nhất
	ngay_xoa timestamp NULL, -- Ngày xóa mềm
	nguoi_xoa varchar(50) NULL, -- Người thực hiện xóa mềm
	CONSTRAINT csyt_ba_chuyen_khoa_tuyen_xa_phuong_benh_an_id_key UNIQUE (benh_an_id),
	CONSTRAINT csyt_ba_chuyen_khoa_tuyen_xa_phuong_pkey PRIMARY KEY (id)
);

CREATE TABLE csyt_ba_chuyen_khoa_ung_buou (
	id uuid DEFAULT gen_random_uuid() NOT NULL,
	benh_an_id uuid NOT NULL, -- FK csyt_benh_an_dieu_tri.id (UNIQUE)
	ma_cskcb varchar(50) NOT NULL,
	ub_ly_do_vao_vien text NULL, -- Lý do vào viện
	ub_ly_do_nhap_vien_id uuid NULL, -- ID lý do nhập viện
	ub_vao_ngay_thu int4 NULL, -- Vào ngày thứ mấy của bệnh
	ub_qua_trinh_benh_ly text NULL, -- Quá trình bệnh lý
	ub_tien_su_ban_than text NULL, -- Tiền sử bản thân
	ub_tien_su_gia_dinh text NULL, -- Tiền sử gia đình
	ub_di_ung_co bool NULL, -- Dị ứng - Có
	ub_di_ung_thang int4 NULL, -- Dị ứng - Số tháng
	ub_ma_tuy_co bool NULL, -- Ma túy - Có
	ub_ma_tuy_thang int4 NULL, -- Ma túy - Số tháng
	ub_ruou_bia_co bool NULL, -- Rượu bia - Có
	ub_ruou_bia_thang int4 NULL, -- Rượu bia - Số tháng
	ub_thuoc_la_co bool NULL, -- Thuốc lá - Có
	ub_thuoc_la_thang int4 NULL, -- Thuốc lá - Số tháng
	ub_thuoc_lao_co bool NULL, -- Thuốc lào - Có
	ub_thuoc_lao_thang int4 NULL, -- Thuốc lào - Số tháng
	ub_khac_co bool NULL, -- Khác - Có
	ub_khac_thang int4 NULL, -- Khác - Số tháng
	ub_kham_toan_than text NULL, -- Khám toàn thân
	ub_kham_tuan_hoan text NULL, -- Khám tuần hoàn
	ub_kham_ho_hap text NULL, -- Khám hô hấp
	ub_kham_tieu_hoa text NULL, -- Khám tiêu hóa
	ub_kham_than_tiet_nieu_sinh_duc text NULL, -- Khám thận tiết niệu sinh dục
	ub_kham_than_kinh text NULL, -- Khám thần kinh
	ub_kham_co_xuong_khop text NULL, -- Khám cơ xương khớp
	ub_kham_tai_mui_hong text NULL, -- Khám tai mũi họng
	ub_kham_rang_ham_mat text NULL, -- Khám răng hàm mặt
	ub_kham_mat text NULL, -- Khám mắt
	ub_kham_noi_tiet_dinh_duong_khac text NULL, -- Khám nội tiết dinh dưỡng khác
	ub_can_lam_sang_can_lam text NULL, -- Các xét nghiệm cận lâm sàng cần làm
	ub_tom_tat_benh_an text NULL, -- Tóm tắt bệnh án
	ub_icd_benh_chinh_vao_khoa_code varchar(50) NULL, -- Mã ICD bệnh chính vào khoa
	ub_icd_benh_chinh_vao_khoa_name varchar(500) NULL, -- Tên bệnh chính vào khoa
	ub_icd_benh_kem_theo_vao_khoa_code varchar(200) NULL, -- Mã ICD bệnh kèm theo vào khoa
	ub_icd_benh_kem_theo_vao_khoa_name text NULL, -- Tên bệnh kèm theo vào khoa
	ub_phan_biet_vao_khoa text NULL, -- Chẩn đoán phân biệt
	ub_tien_luong text NULL, -- Tiên lượng
	ub_huong_dieu_tri text NULL, -- Hướng điều trị
	ub_bac_si_tao_benh_an_ho_ten varchar(255) NULL, -- Họ tên bác sĩ tạo bệnh án
	ub_bac_si_tao_benh_an_thoi_gian timestamp NULL, -- Thời gian bác sĩ tạo bệnh án
	ub_hanh_chinh_chan_doan_t varchar(20) NULL, -- Chẩn đoán hành chính - T
	ub_hanh_chinh_chan_doan_n varchar(20) NULL, -- Chẩn đoán hành chính - N
	ub_hanh_chinh_chan_doan_m varchar(20) NULL, -- Chẩn đoán hành chính - M
	ub_hanh_chinh_chan_doan_giai_doan varchar(50) NULL, -- Chẩn đoán hành chính - Giai đoạn
	ub_benh_an_chan_doan_t varchar(20) NULL, -- Chẩn đoán bệnh án - T
	ub_benh_an_chan_doan_n varchar(20) NULL, -- Chẩn đoán bệnh án - N
	ub_benh_an_chan_doan_m varchar(20) NULL, -- Chẩn đoán bệnh án - M
	ub_benh_an_chan_doan_giai_doan varchar(50) NULL, -- Chẩn đoán bệnh án - Giai đoạn
	ub_bo_phan_ton_thuong text NULL, -- Bộ phận tổn thương
	ub_hinh_anh_ton_thuong_1 text NULL, -- Hình ảnh tổn thương 1
	ub_hinh_anh_ton_thuong_2 text NULL, -- Hình ảnh tổn thương 2
	ub_hinh_anh_ton_thuong_3 text NULL, -- Hình ảnh tổn thương 3
	ub_hinh_anh_ton_thuong_4 text NULL, -- Hình ảnh tổn thương 4
	ub_mo_ta_ton_thuong text NULL, -- Mô tả tổn thương
	ub_kham_tiet_nieu text NULL, -- Khám tiết niệu
	ub_kham_sinh_duc text NULL, -- Khám sinh dục
	ub_tom_tat_xet_nghiem_mau text NULL, -- Tóm tắt xét nghiệm máu
	ub_tom_tat_x_quang text NULL, -- Tóm tắt X-quang
	ub_tom_tat_xet_nghiem_te_bao text NULL, -- Tóm tắt xét nghiệm tế bào
	ub_tom_tat_sieu_am text NULL, -- Tóm tắt siêu âm
	ub_tom_tat_xet_nghiem_blgp text NULL, -- Tóm tắt xét nghiệm bệnh lý giải phẫu
	ub_tom_tat_xet_nghiem_khac text NULL, -- Tóm tắt xét nghiệm khác
	ub_dieu_tri_triet_de bool NULL, -- Điều trị triệt để
	ub_dieu_tri_trieu_chung bool NULL, -- Điều trị triệu chứng
	ub_tia_xa_tien_phau_u text NULL, -- Tia xạ tiền phẫu - U
	ub_tia_xa_tien_phau_hach text NULL, -- Tia xạ tiền phẫu - Hạch
	ub_tia_xa_don_phau_u text NULL, -- Tia xạ đơn phẫu - U
	ub_tia_xa_don_phau_hach text NULL, -- Tia xạ đơn phẫu - Hạch
	ub_tia_xa_hau_phau_u text NULL, -- Tia xạ hậu phẫu - U
	ub_tia_xa_hau_phau_hach text NULL, -- Tia xạ hậu phẫu - Hạch
	ub_phau_thuat_ten text NULL, -- Tên phẫu thuật
	ub_hoa_chat_phac_do text NULL, -- Hóa chất phác đồ
	ub_so_dot varchar(50) NULL, -- Số đợt
	ub_dap_ung text NULL, -- Đáp ứng
	ub_dap_ung_khong_dap_ung bool NULL, -- Đáp ứng - Không đáp ứng
	ub_dap_ung_ban_phan bool NULL, -- Đáp ứng - Bán phần
	ub_dap_ung_hoan_toan bool NULL, -- Đáp ứng - Hoàn toàn
	ub_dieu_tri_khac text NULL, -- Điều trị khác
	bi_xoa int2 DEFAULT 0 NOT NULL,
	ngay_tao timestamp NULL,
	nguoi_tao varchar(50) NULL,
	ngay_cap_nhat timestamp NULL,
	nguoi_cap_nhat varchar(50) NULL,
	ngay_xoa timestamp NULL,
	nguoi_xoa varchar(50) NULL,
	CONSTRAINT csyt_ba_chuyen_khoa_ung_buou_benh_an_id_key UNIQUE (benh_an_id),
	CONSTRAINT csyt_ba_chuyen_khoa_ung_buou_pkey PRIMARY KEY (id)
);

CREATE TABLE csyt_ba_chuyen_khoa_yhct_ngt (
	id uuid DEFAULT gen_random_uuid() NOT NULL,
	benh_an_id uuid NOT NULL, -- FK csyt_benh_an_dieu_tri.id (UNIQUE)
	ma_cskcb varchar(50) NOT NULL,
	mo_ta_tien_su_ban_than text NULL, -- Mô tả tiền sử bản thân
	dac_diem_lien_quan_benh_tat text NULL, -- Đặc điểm liên quan bệnh tật
	benh_su text NULL, -- Bệnh sử (YHHĐ)
	phuong_phap_dieu_tri_yhct text NULL, -- Phương pháp điều trị YHCT
	phuong_duoc text NULL, -- Phương dược
	pp_dieu_tri_khong_dung_thuoc text NULL, -- Phương pháp điều trị không dùng thuốc
	thu_thuat_yhct_vao_khoa int2 NULL, -- Thủ thuật YHCT vào khoa (0/1)
	thu_thuat_vao_khoa int2 NULL, -- Thủ thuật vào khoa (0/1)
	vong_chan text NULL, -- I. Vọng chẩn
	van_chan text NULL, -- II. Văn chẩn
	van_chan_hoi text NULL, -- III. Vấn chẩn
	xuc_chan text NULL, -- IV. Xúc chẩn
	mach_tay_trai text NULL, -- Mạch tay trái
	mach_tay_phai text NULL, -- Mạch tay phải
	tom_tat_tu_chan text NULL, -- V. Tóm tắt tứ chẩn
	bien_chung_luan_tri text NULL, -- VI. Biện chứng luận trị
	benh_danh text NULL, -- VII.1. Bệnh danh
	bat_cuong text NULL, -- VII.2. Bát cương
	nguyen_nhan text NULL, -- VII.3. Nguyên nhân
	tang_phu text NULL, -- VII.4. Tạng phủ
	kinh_mach text NULL, -- VII.5. Kinh mạch
	dinh_vi_benh text NULL, -- VII.6. Định vị bệnh
	tom_tat_ket_qua_can_lam_sang text NULL, -- Tóm tắt kết quả cận lâm sàng
	huong_dieu_tri_tiep_theo text NULL, -- Hướng điều trị tiếp theo
	giam_doc_benh_vien_ho_ten text NULL, -- Họ tên giám đốc bệnh viện
	truong_khoa_ho_ten text NULL, -- Họ tên trưởng khoa
	bac_si_tao_benh_an_ho_ten text NULL, -- Họ tên bác sĩ tạo bệnh án
	nguoi_giao_ho_so text NULL, -- Người giao hồ sơ
	nguoi_nhan_ho_so text NULL, -- Người nhận hồ sơ
	ly_do_vao_vien_summary text NULL, -- Lý do vào viện (tổng kết)
	phuong_phap_dieu_tri_hien_dai text NULL, -- Phương pháp điều trị hiện đại
	icd_yhct_benh_chinh_code varchar(50) NULL, -- Mã ICD YHCT bệnh chính
	icd_yhct_benh_chinh_name varchar(500) NULL, -- Tên ICD YHCT bệnh chính
	icd_yhct_kem_theo_code varchar(200) NULL, -- Mã ICD YHCT kèm theo
	icd_yhct_kem_theo_name text NULL, -- Tên ICD YHCT kèm theo
	icd_benh_chinh_vao_khoa_code_summary varchar(50) NULL, -- Mã ICD bệnh chính vào khoa (tổng kết)
	icd_benh_chinh_vao_khoa_name_summary varchar(500) NULL, -- Tên ICD bệnh chính vào khoa (tổng kết)
	icd_benh_kem_theo_vao_khoa_code_summary varchar(200) NULL, -- Mã ICD kèm theo vào khoa (tổng kết)
	icd_benh_kem_theo_vao_khoa_name_summary text NULL, -- Tên ICD kèm theo vào khoa (tổng kết)
	icd_yhct_benh_chinh_vao_khoa_code_summary varchar(50) NULL, -- Mã ICD YHCT bệnh chính vào khoa (tổng kết)
	icd_yhct_benh_chinh_vao_khoa_name_summary varchar(500) NULL, -- Tên ICD YHCT bệnh chính vào khoa (tổng kết)
	icd_yhct_benh_kem_theo_vao_khoa_code_summary varchar(200) NULL, -- Mã ICD YHCT kèm theo vào khoa (tổng kết)
	icd_yhct_benh_kem_theo_vao_khoa_name_summary text NULL, -- Tên ICD YHCT kèm theo vào khoa (tổng kết)
	ket_qua_dieu_tri_summary int2 NULL, -- Kết quả điều trị (tổng kết)
	icd_ra_vien_benh_chinh_code_summary varchar(50) NULL, -- Mã ICD ra viện bệnh chính (tổng kết)
	icd_ra_vien_benh_chinh_name_summary varchar(500) NULL, -- Tên ICD ra viện bệnh chính (tổng kết)
	icd_ra_vien_kem_theo_code_summary varchar(200) NULL, -- Mã ICD ra viện kèm theo (tổng kết)
	icd_ra_vien_kem_theo_name_summary text NULL, -- Tên ICD ra viện kèm theo (tổng kết)
	icd_yhct_ra_vien_benh_chinh_code_summary varchar(50) NULL, -- Mã ICD YHCT ra viện bệnh chính (tổng kết)
	icd_yhct_ra_vien_benh_chinh_name_summary varchar(500) NULL, -- Tên ICD YHCT ra viện bệnh chính (tổng kết)
	icd_yhct_ra_vien_kem_theo_code_summary varchar(200) NULL, -- Mã ICD YHCT ra viện kèm theo (tổng kết)
	icd_yhct_ra_vien_kem_theo_name_summary text NULL, -- Tên ICD YHCT ra viện kèm theo (tổng kết)
	tinh_trang_ra_vien_summary text NULL, -- Tình trạng ra viện (tổng kết)
	bi_xoa int2 DEFAULT 0 NOT NULL,
	ngay_tao timestamp NULL,
	nguoi_tao varchar(50) NULL,
	ngay_cap_nhat timestamp NULL,
	nguoi_cap_nhat varchar(50) NULL,
	ngay_xoa timestamp NULL,
	nguoi_xoa varchar(50) NULL,
	icd_yhct_noi_chuyen_code varchar(50) NULL,
	icd_yhct_noi_chuyen_name varchar(500) NULL,
	icd_yhct_kkb_code varchar(50) NULL,
	icd_yhct_kkb_name varchar(500) NULL,
	phau_thuat_yhct_vao_khoa int2 NULL,
	thu_thuat_kkb int2 NULL,
	icd_yhct_ra_vien_benh_chinh_code varchar(50) NULL,
	icd_yhct_ra_vien_benh_chinh_name varchar(500) NULL,
	nguyen_nhan_yhct_ra_vien_benh_chinh text NULL,
	icd_yhct_ra_vien_kem_theo_code varchar(200) NULL,
	icd_yhct_ra_vien_kem_theo_name text NULL,
	tai_bien_yhct int2 NULL,
	bien_chung_yhct int2 NULL,
	nguyen_nhan_ra_vien_benh_chinh text NULL,
	CONSTRAINT csyt_ba_chuyen_khoa_yhct_ngt_benh_an_id_key UNIQUE (benh_an_id),
	CONSTRAINT csyt_ba_chuyen_khoa_yhct_ngt_pkey PRIMARY KEY (id)
);

CREATE TABLE csyt_ba_chuyen_khoa_yhct_nt (
	id uuid DEFAULT gen_random_uuid() NOT NULL,
	benh_an_id uuid NOT NULL, -- FK csyt_benh_an_dieu_tri.id (UNIQUE)
	ma_cskcb varchar(50) NOT NULL,
	tien_su_ban_than text NULL,
	tien_su_gia_dinh text NULL,
	kham_toan_than text NULL,
	kham_tuan_hoan text NULL,
	kham_ho_hap text NULL,
	kham_tieu_hoa text NULL,
	kham_co_xuong_khop text NULL,
	kham_tai_mui_hong text NULL,
	kham_rang_ham_mat text NULL,
	kham_mat text NULL,
	kham_noi_tiet_dinh_duong_khac text NULL,
	tom_tat_benh_an text NULL,
	tien_luong text NULL,
	huong_dieu_tri text NULL,
	tom_tat_ket_qua_can_lam_sang text NULL,
	huong_dieu_tri_tiep_theo text NULL,
	nguoi_giao_ho_so text NULL,
	nguoi_nhan_ho_so text NULL,
	giam_doc_benh_vien_ho_ten text NULL,
	truong_khoa_ho_ten text NULL,
	bac_si_tao_benh_an_ho_ten text NULL,
	benh_su text NULL,
	can_lam_sang text NULL,
	phuong_duoc_yhct text NULL,
	phuong_phap_khong_dung_thuoc_yhct text NULL,
	phau_thuat_yhct_vao_khoa int2 NULL,
	icd_yhct_benh_chinh_code varchar(50) NULL,
	icd_yhct_benh_chinh_name varchar(500) NULL,
	icd_yhct_kem_theo_code varchar(200) NULL,
	icd_yhct_kem_theo_name varchar(500) NULL,
	phuong_phap_dieu_tri_yhct text NULL,
	yhct_nt_vc_hinh_thai text NULL, -- I.1. Vọng chẩn - Hình thái (List codes)
	yhct_nt_vc_than text NULL, -- I.2. Vọng chẩn - Thần (List codes)
	yhct_nt_vc_sac text NULL, -- I.3. Vọng chẩn - Sắc (List codes)
	yhct_nt_vc_trach text NULL, -- I.4. Vọng chẩn - Trạch (List codes)
	yhct_nt_vc_luoi_hinh_thai text NULL, -- I.5. Vọng chẩn - Lưỡi hình thái (List codes)
	yhct_nt_vc_luoi_chat text NULL, -- I.5. Vọng chẩn - Lưỡi chất (List codes)
	yhct_nt_vc_reu_luoi text NULL, -- I.5. Vọng chẩn - Rêu lưỡi (List codes)
	yhct_nt_vong_chan_mo_ta text NULL, -- I.6. Vọng chẩn - Mô tả thêm
	yhct_nt_vcn_tieng_noi text NULL, -- II.1. Văn chẩn - Tiếng nói (List codes)
	yhct_nt_vcn_hoi_tho text NULL, -- II.2. Văn chẩn - Hơi thở (List codes)
	yhct_nt_vcn_ho_bh text NULL, -- II.3. Văn chẩn - Ho biểu hiện (List codes)
	yhct_nt_vcn_ho_chi_tiet text NULL, -- II.3. Văn chẩn - Ho chi tiết (List codes)
	yhct_nt_vcn_o text NULL, -- II.4. Văn chẩn - Ợ (List codes)
	yhct_nt_vcn_nac text NULL, -- II.5. Văn chẩn - Nấc (List codes)
	yhct_nt_vcn_mui_co_the_bh text NULL, -- II.6. Văn chẩn - Mùi cơ thể biểu hiện (List codes)
	yhct_nt_vcn_mui_co_the_chi_tiet text NULL, -- II.6. Văn chẩn - Mùi cơ thể chi tiết (List codes)
	yhct_nt_vcn_chat_thai text NULL, -- II.7. Văn chẩn - Chất thải (List codes)
	yhct_nt_van_chan_mo_ta text NULL, -- II.8. Văn chẩn - Mô tả thêm
	yhct_nt_vch_han_nhiet_bh text NULL, -- III.1. Vấn chẩn - Hàn nhiệt biểu hiện
	yhct_nt_vch_han_nhiet text NULL, -- III.1. Vấn chẩn - Hàn nhiệt chi tiết
	yhct_nt_vch_mo_hoi text NULL, -- III.2. Vấn chẩn - Mồ hôi
	yhct_nt_vch_dau_mat_co_bh text NULL, -- III.3. Vấn chẩn - Đau mắt có biểu hiện
	yhct_nt_vch_dau_dau text NULL, -- III.3. Vấn chẩn - Đau đầu
	yhct_nt_vch_hoa_mat_chong_mat text NULL,
	yhct_nt_vch_mat text NULL,
	yhct_nt_vch_tai text NULL,
	yhct_nt_vch_mui text NULL,
	yhct_nt_vch_hong text NULL,
	yhct_nt_vch_co_vai text NULL,
	yhct_nt_vch_lung_bh text NULL,
	yhct_nt_vch_lung text NULL,
	yhct_nt_vch_nguc_bh text NULL,
	yhct_nt_vch_nguc text NULL,
	yhct_nt_vch_bung_bh text NULL,
	yhct_nt_vch_bung text NULL,
	yhct_nt_vch_chan_tay_bh text NULL,
	yhct_nt_vch_chan_tay text NULL,
	yhct_nt_vch_an_bh text NULL,
	yhct_nt_vch_an text NULL,
	yhct_nt_vch_uong_bh text NULL,
	yhct_nt_vch_uong text NULL,
	yhct_nt_vch_dai_tieu_tien_bh text NULL,
	yhct_nt_vch_tieu_tien text NULL,
	yhct_nt_vch_dai_tien text NULL,
	yhct_nt_vch_ngu_bh text NULL,
	yhct_nt_vch_ngu text NULL,
	yhct_nt_vch_sinh_duc_bh text NULL,
	yhct_nt_vch_nam_gioi text NULL,
	yhct_nt_vch_nu_gioi_bh text NULL,
	yhct_nt_vch_kinh_nguyet_bh text NULL,
	yhct_nt_vch_roi_loan_kinh_nguyet text NULL,
	yhct_nt_vch_thong_kinh text NULL,
	yhct_nt_vch_doi_ha_bh text NULL,
	yhct_nt_vch_doi_ha text NULL,
	yhct_nt_vch_yeu_to_lien_quan text NULL,
	yhct_nt_van_chan_hoi_mo_ta text NULL,
	yhct_nt_tc_xuc_chan_bh text NULL, -- IV.1. Xúc chẩn - Biểu hiện
	yhct_nt_tc_co_xuong_khop_bh text NULL,
	yhct_nt_tc_co_xuong_khop text NULL,
	yhct_nt_tc_bung_bh text NULL,
	yhct_nt_tc_bung text NULL,
	yhct_nt_tc_mo_hoi_bh text NULL,
	yhct_nt_tc_mo_hoi text NULL,
	yhct_nt_tc_mach_chan text NULL, -- IV.2. Xúc chẩn - Mạch chẩn
	yhct_nt_tc_tong_khan_phai text NULL, -- IV.2. Xúc chẩn - Tổng khán phải
	yhct_nt_tc_tong_khan_trai text NULL, -- IV.2. Xúc chẩn - Tổng khán trái
	yhct_nt_tc_vi_khan_tay_trai text NULL,
	yhct_nt_tc_vi_khan_tay_phai text NULL,
	yhct_nt_tom_tat_tu_chan text NULL, -- V. Tóm tắt tứ chẩn
	yhct_nt_bien_chung_luan_tri text NULL, -- VI. Biện chứng luận trị
	yhct_nt_benh_danh text NULL, -- VII.1. Bệnh danh
	yhct_nt_bat_cuong text NULL, -- VII.2. Bát cương (text)
	yhct_nt_bat_cuong_chon text NULL, -- VII.2. Bát cương (List codes)
	yhct_nt_nguyen_nhan_chon text NULL, -- VII.3. Nguyên nhân (List codes)
	yhct_nt_tang_phu_chon text NULL, -- VII.4. Tạng phủ (List codes)
	yhct_nt_kinh_mach_chon text NULL, -- VII.5. Kinh mạch (List codes)
	yhct_nt_dinh_vi_benh_chon text NULL, -- VII.6. Định vị bệnh (List codes)
	mo_ta_tien_su_ban_than text NULL, -- Mô tả tiền sử bản thân (YHCT)
	dac_diem_lien_quan_benh_tat text NULL, -- Đặc điểm liên quan bệnh tật
	ly_do_vao_vien_summary text NULL, -- Lý do vào viện (tổng kết)
	phuong_phap_dieu_tri_hien_dai text NULL, -- Phương pháp điều trị hiện đại
	icd_benh_chinh_vao_khoa_code_summary varchar(50) NULL, -- Mã ICD bệnh chính vào khoa (tổng kết)
	icd_benh_chinh_vao_khoa_name_summary varchar(500) NULL, -- Tên ICD bệnh chính vào khoa (tổng kết)
	icd_benh_kem_theo_vao_khoa_code_summary varchar(200) NULL, -- Mã ICD kèm theo vào khoa (tổng kết)
	icd_benh_kem_theo_vao_khoa_name_summary text NULL, -- Tên ICD kèm theo vào khoa (tổng kết)
	icd_yhct_benh_chinh_vao_khoa_code_summary varchar(50) NULL, -- Mã ICD YHCT bệnh chính vào khoa (tổng kết)
	icd_yhct_benh_chinh_vao_khoa_name_summary varchar(500) NULL, -- Tên ICD YHCT bệnh chính vào khoa (tổng kết)
	icd_yhct_benh_kem_theo_vao_khoa_code_summary varchar(200) NULL, -- Mã ICD YHCT kèm theo vào khoa (tổng kết)
	icd_yhct_benh_kem_theo_vao_khoa_name_summary text NULL, -- Tên ICD YHCT kèm theo vào khoa (tổng kết)
	ket_qua_dieu_tri_summary int2 NULL, -- Kết quả điều trị (tổng kết)
	icd_ra_vien_benh_chinh_code_summary varchar(50) NULL, -- Mã ICD ra viện bệnh chính (tổng kết)
	icd_ra_vien_benh_chinh_name_summary varchar(500) NULL, -- Tên ICD ra viện bệnh chính (tổng kết)
	icd_ra_vien_kem_theo_code_summary varchar(200) NULL, -- Mã ICD ra viện kèm theo (tổng kết)
	icd_ra_vien_kem_theo_name_summary text NULL, -- Tên ICD ra viện kèm theo (tổng kết)
	icd_yhct_ra_vien_benh_chinh_code_summary varchar(50) NULL, -- Mã ICD YHCT ra viện bệnh chính (tổng kết)
	icd_yhct_ra_vien_benh_chinh_name_summary varchar(500) NULL, -- Tên ICD YHCT ra viện bệnh chính (tổng kết)
	icd_yhct_ra_vien_kem_theo_code_summary varchar(200) NULL, -- Mã ICD YHCT ra viện kèm theo (tổng kết)
	icd_yhct_ra_vien_kem_theo_name_summary text NULL, -- Tên ICD YHCT ra viện kèm theo (tổng kết)
	tinh_trang_ra_vien_summary text NULL, -- Tình trạng ra viện (tổng kết)
	bi_xoa int2 DEFAULT 0 NOT NULL,
	ngay_tao timestamp NULL,
	nguoi_tao varchar(50) NULL,
	ngay_cap_nhat timestamp NULL,
	nguoi_cap_nhat varchar(50) NULL,
	ngay_xoa timestamp NULL,
	nguoi_xoa varchar(50) NULL,
	icd_yhct_noi_chuyen_code varchar(50) NULL,
	icd_yhct_noi_chuyen_name varchar(500) NULL,
	icd_yhct_kkb_code varchar(50) NULL,
	icd_yhct_kkb_name varchar(500) NULL,
	thu_thuat_yhct_vao_khoa int2 NULL,
	thu_thuat_kkb int2 NULL,
	thu_thuat_vao_khoa int2 NULL,
	icd_yhct_ra_vien_benh_chinh_code varchar(50) NULL,
	icd_yhct_ra_vien_benh_chinh_name varchar(500) NULL,
	nguyen_nhan_yhct_ra_vien_benh_chinh text NULL,
	icd_yhct_ra_vien_kem_theo_code varchar(200) NULL,
	icd_yhct_ra_vien_kem_theo_name text NULL,
	tai_bien_yhct int2 NULL,
	bien_chung_yhct int2 NULL,
	nguyen_nhan_ra_vien_benh_chinh text NULL,
	yhct_nt_tc_vk_trai_thon text NULL,
	yhct_nt_tc_vk_trai_quan text NULL,
	yhct_nt_tc_vk_trai_xich text NULL,
	yhct_nt_tc_vk_phai_thon text NULL,
	yhct_nt_tc_vk_phai_quan text NULL,
	yhct_nt_tc_vk_phai_xich text NULL,
	CONSTRAINT csyt_ba_chuyen_khoa_yhct_nt_benh_an_id_key UNIQUE (benh_an_id),
	CONSTRAINT csyt_ba_chuyen_khoa_yhct_nt_pkey PRIMARY KEY (id)
);

CREATE TABLE csyt_benh_an_cho_chuyen_khoa (
	id uuid DEFAULT gen_random_uuid() NOT NULL,
	benh_an_id uuid NOT NULL,
	chuyen_khoa_id uuid NULL,
	chuyen_khoa_hien_tai_id uuid NULL,
	bs_dieu_tri_hien_tai_id uuid NULL,
	phong_ban_chuyen_di_id uuid NULL,
	thoi_gian_den timestamp(6) NULL,
	bac_si_dieu_tri_id uuid NULL,
	phong_benh_id uuid NULL,
	giuong_benh_id uuid NULL,
	ly_do_chuyen_khoa_id uuid NULL,
	tiep_nhan_id uuid NOT NULL,
	thoi_gian_chi_dinh timestamp(6) NULL,
	phong_ban_id uuid NULL,
	phong_ban_chuyen_den_id uuid NULL,
	phong_ban_truoc_id uuid NULL,
	trang_thai varchar(50) DEFAULT 'CHO'::character varying NOT NULL, -- CHO | DA_CHUYEN | HUY
	ly_do_ngung_chuyen_khoa varchar(500) NULL,
	chan_doan varchar(500) NULL,
	ngay_tao timestamp(6) DEFAULT now() NOT NULL,
	ngay_cap_nhat timestamp(6) NULL,
	nguoi_tao varchar(100) NULL,
	nguoi_cap_nhat varchar(100) NULL,
	nguoi_xoa varchar(100) NULL,
	bi_xoa int2 DEFAULT 0 NOT NULL,
	ma_cskcb varchar(50) NULL,
	ngay_xoa timestamp(6) NULL,
	CONSTRAINT csyt_benh_an_cho_chuyen_khoa_pkey PRIMARY KEY (id)
);

CREATE TABLE csyt_benh_an_cho_nhap_vien (
	id uuid DEFAULT gen_random_uuid() NOT NULL,
	benh_nhan_id uuid NOT NULL,
	tiep_nhan_id uuid NOT NULL,
	kham_benh_id uuid NULL,
	benh_an_id uuid NULL, -- Null cho đến khi BN được tiếp nhận vào khoa và cấp số bệnh án
	so_benh_an varchar(20) NULL,
	loai_benh_an varchar(50) NULL,
	ngay_nhap_vien date NULL, -- Ngày Chỉ định nhập viện
	thoi_gian_nhap_vien timestamp(6) NULL,
	noi_nhap_vien_id uuid NULL,
	bac_si_chi_dinh_id uuid NULL,
	ly_do_nhap_vien_id uuid NULL,
	khoa_dieu_tri_id uuid NULL,
	chuyen_khoa_id uuid NULL,
	loai_benh_an_id uuid NULL,
	icd_chan_doan varchar(50) NULL,
	chan_doan text NULL,
	cap_cuu bpchar(1) NULL,
	trang_thai varchar(20) DEFAULT 'CHO'::character varying NOT NULL, -- CHO | DA_TIEP_NHAN | HUY
	benh_vien_id varchar(10) NULL,
	icdphu_kham_benh varchar(400) NULL,
	ten_icdphu_kham_benh text NULL,
	ghi_chu text NULL,
	ngay_tao timestamp(6) DEFAULT now() NOT NULL,
	ngay_cap_nhat timestamp(6) NULL,
	nguoi_tao varchar(100) NULL,
	nguoi_cap_nhat varchar(100) NULL,
	nguoi_xoa varchar(100) NULL,
	bi_xoa int2 DEFAULT 0 NOT NULL,
	ma_cskcb varchar(50) NULL,
	ngay_xoa timestamp(6) NULL,
	ly_do_nhap_vien text NULL,
	loai_kcb_id uuid NULL,
	CONSTRAINT csyt_benh_an_cho_nhap_vien_pkey PRIMARY KEY (id)
);

CREATE TABLE csyt_benh_an_chuyen_khoa_lich_su (
	id uuid DEFAULT gen_random_uuid() NOT NULL,
	benh_an_id uuid NOT NULL,
	tiep_nhan_id uuid NOT NULL,
	hanh_dong varchar(20) NOT NULL, -- HUY: hủy bệnh án chuyên khoa; TAO_LAI: tạo lại bệnh án chuyên khoa
	loai_benh_an_id uuid NULL,
	loai_benh_an varchar(50) NOT NULL, -- Mã loại bệnh án tại thời điểm thực hiện hành động
	ly_do varchar(500) NULL, -- Lý do hủy; bắt buộc khi hành động là HUY
	khoa_thuc_hien_id uuid NULL,
	nguoi_thuc_hien varchar(50) NOT NULL,
	thoi_gian_thuc_hien timestamp DEFAULT CURRENT_TIMESTAMP NOT NULL,
	ma_cskcb varchar(50) NOT NULL,
	bi_xoa int2 DEFAULT 0 NOT NULL,
	ngay_tao timestamp NULL,
	nguoi_tao varchar(50) NULL,
	ngay_cap_nhat timestamp NULL,
	nguoi_cap_nhat varchar(50) NULL,
	ngay_xoa timestamp NULL,
	nguoi_xoa varchar(50) NULL,
	CONSTRAINT csyt_benh_an_chuyen_khoa_lich_su_pkey PRIMARY KEY (id)
);

CREATE TABLE csyt_benh_an_dieu_tri (
	id uuid DEFAULT gen_random_uuid() NOT NULL,
	so_benh_an varchar(50) NOT NULL,
	so_luu_tru varchar(50) NULL,
	loai_benh_an_id uuid NULL,
	loai_benh_an varchar(50) NULL,
	tiep_nhan_id uuid NOT NULL,
	benh_nhan_id uuid NOT NULL,
	doi_tuong_id uuid NULL,
	ngay_lap date NULL,
	thoi_gian_lap timestamp(6) NULL,
	noi_lap_id uuid NULL,
	nguoi_lap_id uuid NULL,
	bac_si_dieu_tri_id uuid NULL,
	dieu_duong_phu_trach_id uuid NULL,
	chuyen_khoa_id uuid NULL,
	khoa_chuyen_den_id uuid NULL, -- Khoa đang điều trị hiện tại, cập nhật mỗi lần chuyển khoa
	khoa_vao_id uuid NULL, -- Khoa tiếp nhận ban đầu
	ngay_vao_khoa date NULL,
	thoi_gian_vao_khoa timestamp(6) NULL,
	ngay_vao_vien date NULL,
	thoi_gian_vao_vien timestamp(6) NULL,
	lan_vao_vien int4 NULL,
	ly_do_nhap_vien_id uuid NULL,
	icd_vao_khoa varchar(50) NULL,
	chan_doan_vao_khoa text NULL,
	icd_kham_benh varchar(50) NULL,
	chan_doan_kham_benh text NULL,
	icd_benh_chinh varchar(50) NULL,
	icd_benh_phu varchar(200) NULL,
	ket_qua_dieu_tri_id uuid NULL,
	ngay_ra_vien date NULL,
	thoi_gian_ra_vien timestamp(6) NULL,
	khoa_ra_id uuid NULL,
	so_ngay_dieu_tri int4 NULL,
	chan_doan_ra_vien text NULL,
	mo_ta_tinh_trang_ra_vien text NULL,
	thu_thuat bool DEFAULT false NOT NULL,
	phau_thuat bool DEFAULT false NOT NULL,
	bien_chung bool DEFAULT false NOT NULL,
	so_cap_cuu varchar(50) NULL,
	tien_su_ban_than text NULL,
	tien_su_gia_dinh text NULL,
	kham_toan_than text NULL,
	qua_trinh_benh_ly text NULL,
	chieu_cao int4 NULL,
	can_nang int4 NULL,
	bmi int4 NULL,
	tien_luong text NULL,
	ke_hoach_dieu_tri text NULL,
	can_lam_sang text NULL,
	lam_sang text NULL,
	nguyen_nhan_tai_bien_id uuid NULL,
	tai_bien_dieu_tri bool DEFAULT false NOT NULL,
	giai_phau_benh int4 NULL,
	tinh_trang_giai_phau_benh_id uuid NULL,
	tu_vong bool DEFAULT false NOT NULL,
	ngay_tu_vong date NULL,
	thoi_gian_tu_vong timestamp(6) NULL,
	icd_tu_vong_id uuid NULL,
	nguyen_nhan_tu_vong_id uuid NULL,
	bac_si_ghi_nhan_tu_vong_id uuid NULL,
	bac_si_kham_nghiem_id uuid NULL,
	thoi_gian_kham_nghiem timestamp(6) NULL,
	ket_qua_kham_nghiem text NULL,
	thoi_gian_nhan_tu_thi timestamp(6) NULL,
	ly_do_xuat_vien_id uuid NULL,
	chuyen_vien_id uuid NULL,
	chuyen_den_benh_vien_id uuid NULL,
	icd_tuyen_duoi varchar(50) NULL,
	chan_doan_tuyen_duoi text NULL,
	xac_nhan_chi_phi_id uuid NULL,
	khoa_benh_an bool DEFAULT false NOT NULL,
	ngay_khoa_benh_an date NULL,
	thoi_gian_khoa_benh_an timestamp(6) NULL,
	nguoi_khoa_benh_an_id uuid NULL,
	ghi_chu text NULL,
	trang_thai varchar(50) NULL,
	benh_vien_id varchar(10) NULL,
	icdravien_chinh varchar(50) NULL,
	icdravien_phu text NULL,
	cdravien_chinh text NULL,
	cdravien_phu text NULL,
	icdphu_kham_benh text NULL,
	ten_icdphu_kham_benh text NULL,
	icd_phan_biet text NULL,
	chan_doan_icd_phan_biet text NULL,
	cap_cuu_duoi_4h bool DEFAULT false NOT NULL,
	so_giay_ra_vien varchar(50) NULL,
	ly_do_huy_xac_nhan_bhyt text NULL,
	ngay_du_kien_xuat_vien date NULL,
	thoi_gian_du_kien_xuat_vien timestamp(6) NULL,
	so_ngay_nghi int4 NULL,
	thoi_gian_nghi_tu timestamp(6) NULL,
	thoi_gian_nghi_den timestamp(6) NULL,
	cdra_yhct_icd_chinh_id uuid NULL,
	cdra_yhct_icd_chinh_text text NULL,
	cdra_yhct_icd_phu_id uuid NULL,
	cdra_yhct_icd_phu_text text NULL,
	cdra_yhct_icd_chinh_ma varchar(50) NULL,
	cdra_yhct_icd_phu_ma text NULL,
	giam_doc_id uuid NULL,
	truong_khoa_id uuid NULL,
	loai_kcb_id uuid NULL,
	ngay_tao_so_luu_tru date NULL,
	dieu_tri_ban_ngay bool DEFAULT false NOT NULL,
	dau_hieu_lam_sang_chinh text NULL,
	ngay_tao timestamp(6) DEFAULT now() NOT NULL,
	ngay_cap_nhat timestamp(6) NULL,
	nguoi_tao varchar(100) NULL,
	nguoi_cap_nhat varchar(100) NULL,
	nguoi_xoa varchar(100) NULL,
	bi_xoa int2 DEFAULT 0 NOT NULL,
	ma_cskcb varchar(50) NULL,
	ngay_xoa timestamp(6) NULL,
	ten_icd_benh_chinh text NULL, -- Ten chan doan benh chinh (di kem icd_benh_chinh la ma)
	icd_yhct_vao varchar(50) NULL, -- Ma ICD YHCT khi VAO khoa (phan biet voi cdra_yhct_* la khi RA vien)
	ten_icd_yhct_vao text NULL, -- Ten ICD YHCT khi VAO khoa
	bac_si_ket_luan_id uuid NULL,
	ly_do_vao_vien text NULL, -- Ly do vao vien (text tu do, dung kem ly_do_nhap_vien_id la combobox)
	vao_ngay_thu int4 NULL, -- Ngay thu may cua benh khi vao vien
	truc_tiep_vao int2 NULL, -- 1 = vao thang, 0 = chuyen tu noi khac
	noi_gioi_thieu text NULL, -- Noi gioi thieu/chuyen den (khi truc_tiep_vao = 0)
	loai_chuyen_vien varchar(50) NULL, -- Loai chuyen vien: vao/ra/chuyen tuyen tren/duoi …
	loai_ra_vien uuid NULL, -- ID xử trí (tham chiếu dm_xu_tri.id)
	hososohoa_id uuid NULL,
	ma_loai_ra_vien varchar(50) NULL, -- Mã loại ra viện (danh mục dmc_ma_loai_ra_vien) dùng cho hồ sơ liên thông — set khi bác sĩ xác nhận thông tin hồ sơ liên thông, đồng bộ với tiep_nhan.ma_loai_ra_vien.
	CONSTRAINT csyt_benh_an_dieu_tri_pkey PRIMARY KEY (id)
);

CREATE TABLE csyt_benh_an_dieu_tri_chi_tiet (
	id uuid DEFAULT gen_random_uuid() NOT NULL,
	benh_an_id uuid NOT NULL, -- UNIQUE — đảm bảo quan hệ 1-1 với csyt_benh_an_dieu_tri
	ly_do_vao_vien text NULL,
	qua_trinh_benh_ly text NULL,
	tien_su_ban_than text NULL,
	di_ung bpchar(1) NULL,
	ngay_di_ung int2 NULL,
	ma_tuy bpchar(1) NULL,
	ngay_ma_tuy int2 NULL,
	ruou_bia bpchar(1) NULL,
	ngay_ruou_bia int2 NULL,
	thuoc_la bpchar(1) NULL,
	ngay_thuoc_la int2 NULL,
	thuoc_lao bpchar(1) NULL,
	ngay_thuoc_lao int2 NULL,
	tien_su_khac bpchar(1) NULL,
	ngay_tien_su_khac int2 NULL,
	tien_su_gia_dinh text NULL,
	kham_benh_toan_than text NULL,
	chieu_cao numeric(25, 4) NULL,
	spo2 numeric(25, 4) NULL,
	mach int2 NULL,
	nhip_tho int2 NULL,
	nhiet_do numeric(25, 4) NULL,
	can_nang numeric(25, 4) NULL,
	huyet_ap_cao int2 NULL,
	huyet_ap_thap int2 NULL,
	kham_benh_bo_phan_ton_thuong text NULL,
	than_kinh text NULL,
	tuan_hoan text NULL,
	ho_hap text NULL,
	tieu_hoa text NULL,
	co_xuong_khop text NULL,
	tiet_nieu text NULL,
	sinh_duc text NULL,
	kham_benh_khac text NULL,
	mat text NULL,
	tai_mui_hong text NULL,
	rang_ham_mat text NULL,
	xet_nghiem_cls_can_lam text NULL,
	tom_tat_benh_an text NULL,
	kham_benh_tien_luong text NULL,
	huong_dan_dieu_tri text NULL,
	qua_trinh_blva_dien_bien_ls text NULL,
	xn_mau text NULL,
	xn_te_bao text NULL,
	xn_bl_gp text NULL,
	xn_x_quang text NULL,
	xn_sieu_am text NULL,
	cac_xn_khac text NULL,
	phuong_phap_dieu_tri text NULL,
	pp_tien_phau_tai_u text NULL,
	pp_tien_phau_tai_hach text NULL,
	pp_don_thuan_tai_u text NULL,
	pp_don_thuan_tai_hach text NULL,
	pp_phau_thuat text NULL,
	pp_hau_phau_tai_u text NULL,
	pp_hau_phau_tai_hach text NULL,
	pp_hoa_chat text NULL,
	pp_so_dot text NULL,
	pp_danh_gia_dap_ung text NULL,
	pp_dieu_tri_khac text NULL,
	tinh_trang_nguoi_benh_ra_vien text NULL,
	huong_dieu_tri_va_che_do_tiep_theo text NULL,
	so_to_x_quang int2 NULL,
	so_to_ct_scanner int2 NULL,
	so_to_sieu_am int2 NULL,
	so_to_xet_nghiem int2 NULL,
	so_to_khac int2 NULL,
	tong_so_to_ho_so int2 NULL,
	t_vao_vien text NULL,
	n_vao_vien text NULL,
	m_vao_vien text NULL,
	giai_doan_benh_luc_vao_vien text NULL,
	tai_bien_do_phau_thuat bpchar(1) NULL,
	tai_bien_do_gay_me bpchar(1) NULL,
	tai_bien_do_nhiem_khuan bpchar(1) NULL,
	tai_bien_khac bpchar(1) NULL,
	t_ra_vien text NULL,
	n_ra_vien text NULL,
	m_ra_vien text NULL,
	giai_doan_benh_luc_ra_vien text NULL,
	chan_doan_truoc_phau_thuat text NULL,
	chan_doan_sau_phau_thuat text NULL,
	kham_benh_benh_chinh text NULL,
	t_kham_benh text NULL,
	n_kham_benh text NULL,
	m_kham_benh text NULL,
	giai_doan_kham_benh text NULL,
	kham_benh_benh_kem_theo text NULL,
	kham_benh_phan_biet text NULL,
	tong_so_ngay_dieu_tri_sau_pt int4 NULL,
	tong_so_lan_phau_thuat int4 NULL,
	hinh_ve_hoac_anh text NULL,
	mo_ta_ton_thuong text NULL,
	loi_dan_thay_thuoc text NULL,
	ppdt text NULL,
	tinh_trang_thuong_tich_vao_vien text NULL,
	tinh_trang_thuong_tich_ra_vien text NULL,
	benh_vien_id varchar(10) NULL,
	cac_bo_phan text NULL,
	noi_dieu_tri_yhhd text NULL,
	vong_chan text NULL,
	van_chan text NULL,
	van_chan_1 text NULL,
	xuc_chan text NULL,
	mach_tay_trai text NULL,
	mach_tay_phai text NULL,
	tom_tat_tu_chan text NULL,
	bien_chung text NULL,
	noi_dieu_tri_yhct text NULL,
	benh_danh text NULL,
	bat_cuong text NULL,
	tang_phu text NULL,
	nguyen_nhan text NULL,
	phap_dieu_tri text NULL,
	phuong_thuoc text NULL,
	phuong_huyet text NULL,
	dieu_tri_ket_hop text NULL,
	che_do_dinh_duong text NULL,
	che_do_ho_ly text NULL,
	chuyen_khoa text NULL,
	chan_doan text NULL,
	tuyen_duoi text NULL,
	dieu_tri_tu_ngay timestamp(6) NULL,
	dieu_tri_den_ngay timestamp(6) NULL,
	check_quan_tam bool DEFAULT false NOT NULL,
	ghi_chu text NULL,
	noi_lam_viec text NULL,
	chan_doan_noi_gioi_thieu text NULL,
	thoi_gian_kham timestamp(6) NULL,
	xu_ly text NULL,
	thuoc_da_dung text NULL,
	original_name text NULL,
	loai_anh text NULL,
	loai_file_id text NULL,
	ten_file_dinh_kem text NULL,
	tinh_trang_ra_vien text NULL,
	kinh_mach text NULL,
	pp_dieu_tri_noi_tru text NULL,
	pp_dieu_tri_ngoai_tru text NULL,
	pp_dt_phau_thuat_thu_thuat text NULL,
	ngay_tao timestamp(6) DEFAULT now() NOT NULL,
	ngay_cap_nhat timestamp(6) NULL,
	nguoi_tao varchar(100) NULL,
	nguoi_cap_nhat varchar(100) NULL,
	nguoi_xoa varchar(100) NULL,
	bi_xoa int2 DEFAULT 0 NOT NULL,
	ma_cskcb varchar(50) NULL,
	ngay_xoa timestamp(6) NULL,
	ma_chan_doan_truoc_phau_thuat varchar(50) NULL,
	ma_chan_doan_sau_phau_thuat varchar(50) NULL,
	nguyen_nhan_tu_vong text NULL,
	kham_nghiem_tu_thi text NULL,
	tu_vong_do_benh bool NULL,
	tu_vong_do_tai_bien bool NULL,
	tu_vong_khac bool NULL,
	tu_vong_trong_24h bool NULL,
	tu_vong_trong_48h bool NULL,
	tu_vong_trong_72h bool NULL,
	tom_tat_ket_qua_can_lam_sang text NULL,
	ten_khac text NULL,
	nguoi_giao_ho_so text NULL,
	nguoi_nhan_ho_so text NULL,
	thoi_gian_ky_ho_so timestamp NULL,
	bac_si_dieu_tri_ho_so text NULL,
	giam_doc_benh_vien_ho_ten text NULL,
	truong_khoa_ho_ten text NULL,
	truong_khoa_thoi_gian timestamp NULL,
	tien_su_mat text NULL,
	tien_su_toan_than text NULL,
	huong_dieu_tri text NULL,
	bac_si_tao_benh_an_ho_ten text NULL,
	bac_si_tao_benh_an_thoi_gian timestamp NULL,
	kham_tam_than_than_kinh text NULL,
	kham_noi_tiet_dinh_duong_khac text NULL,
	kham_benh_id uuid NULL, -- ID công khám (tham chiếu kb_kham_benh.id) liên quan đến bệnh án điều trị ngoại trú mãn tính
	CONSTRAINT csyt_benh_an_dieu_tri_chi_tiet_benh_an_id_key UNIQUE (benh_an_id),
	CONSTRAINT csyt_benh_an_dieu_tri_chi_tiet_pkey PRIMARY KEY (id)
);

CREATE TABLE csyt_benh_an_dot_dieu_tri (
	id uuid DEFAULT gen_random_uuid() NOT NULL,
	ma_dot_dieu_tri varchar(30) NULL,
	ten_dot_dieu_tri varchar(200) NULL,
	benh_an_id uuid NOT NULL,
	benh_nhan_id uuid NOT NULL,
	tu_ngay date NULL,
	thoi_gian_tu_ngay timestamp(6) NULL,
	den_ngay date NULL,
	thoi_gian_den_ngay timestamp(6) NULL,
	bac_si_dieu_tri_id uuid NULL,
	khoa_dieu_tri_id uuid NULL,
	icd_chan_doan_dieu_tri_id uuid NULL,
	chan_doan_dieu_tri varchar(500) NULL,
	phuong_phap_dieu_tri varchar(500) NULL,
	loi_dan_bac_si varchar(500) NULL,
	icd_khi_ket_thuc_id uuid NULL,
	chan_doan_khi_ket_thuc varchar(500) NULL,
	ngay_tai_kham date NULL,
	thoi_gian_tai_kham timestamp(6) NULL,
	trang_thai bpchar(1) NULL,
	da_xac_nhan_bhyt int4 NULL,
	benh_vien_id varchar(10) NULL,
	tinh_trang_id uuid NULL,
	ket_qua_dieu_tri_id uuid NULL,
	vaokhoa_ds_ma_icdphu text NULL,
	vaokhoa_icdphu_text text NULL,
	stt_dot_dieu_tri int4 NULL, -- Số thứ tự đợt trong cùng 1 bệnh án, dùng để sắp xếp
	ngay_tao timestamp(6) DEFAULT now() NOT NULL,
	ngay_cap_nhat timestamp(6) NULL,
	nguoi_tao varchar(100) NULL,
	nguoi_cap_nhat varchar(100) NULL,
	nguoi_xoa varchar(100) NULL,
	bi_xoa int2 DEFAULT 0 NOT NULL,
	ma_cskcb varchar(50) NULL,
	ngay_xoa timestamp(6) NULL,
	CONSTRAINT csyt_benh_an_dot_dieu_tri_pkey PRIMARY KEY (id)
);

CREATE TABLE csyt_benh_an_giay_chung_sinh (
	id uuid DEFAULT gen_random_uuid() NOT NULL,
	benh_an_id uuid NOT NULL,
	nguoi_lap_id uuid NULL,
	ngay_lap timestamp(6) NULL,
	so int4 NULL,
	so_quyen int4 NULL,
	ho_ten_me varchar(500) NULL,
	ho_ten_tre_so_sinh varchar(500) NULL,
	dia_chi text NULL,
	cmnd varchar(500) NULL,
	noi_cap varchar(500) NULL,
	ngay_cap date NULL,
	dan_toc_id uuid NULL,
	ho_ten_cha varchar(500) NULL,
	thoi_gian_sinh timestamp(6) NULL,
	noi_sinh varchar(500) NULL,
	so_con int4 NULL,
	gioi_tinh_chung_sinh varchar(1) NULL,
	can_nang_chung_sinh numeric(18, 2) NULL,
	du_dinh_dat_ten varchar(500) NULL,
	ghi_chu text NULL,
	bhxh varchar(500) NULL, -- Số BHXH của mẹ — dùng để đăng ký BHYT cho trẻ sơ sinh
	benh_vien_id varchar(10) NULL,
	so_phieu_chung_sinh varchar(100) NULL,
	nguoi_do_de varchar(255) NULL,
	nguoi_do_de_id uuid NULL,
	thu_truong_id uuid NULL,
	ngay_tao timestamp(6) DEFAULT now() NOT NULL,
	ngay_cap_nhat timestamp(6) NULL,
	nguoi_tao varchar(100) NULL,
	nguoi_cap_nhat varchar(100) NULL,
	nguoi_xoa varchar(100) NULL,
	bi_xoa int2 DEFAULT 0 NOT NULL,
	ma_cskcb varchar(50) NULL,
	ngay_xoa timestamp(6) NULL,
	hososohoa_id uuid NULL, -- FK hồ sơ số hóa (csyt_mauhososohoa) mẫu Giấy chứng sinh (GIAY_CHUNG_SINH), tạo khi lưu để in/ký số.
	hososohoa_mth_id uuid NULL, -- FK hồ sơ số hóa (csyt_mauhososohoa) mẫu Giấy chứng sinh mang thai hộ (GIAY_CHUNG_SINH_MTH), tạo khi lưu để in/ký số.
	giayto_goc_id uuid NULL, -- FK sang bản gốc trong cùng bảng. NULL = bản gốc.
	so_lan_caplai int4 NULL, -- Số lần cấp lại (bản gốc = NULL, bản cấp lại đầu tiên = 1).
	lydo_caplai varchar(500) NULL, -- Lý do cấp lại (bắt buộc khi cấp lại).
	nguoi_caplai varchar(255) NULL, -- Username người thực hiện cấp lại.
	thoigian_caplai timestamp NULL, -- Thời điểm cấp lại.
	vo_mth_bhxh varchar(50) NULL,
	vo_mth_ho_ten varchar(500) NULL,
	vo_mth_ngay_sinh date NULL,
	vo_mth_ma_the_bhyt varchar(50) NULL,
	vo_mth_ma_quoc_tich varchar(50) NULL,
	vo_mth_ma_dan_toc varchar(50) NULL,
	vo_mth_loai_giay_to varchar(255) NULL,
	vo_mth_so_ddcn varchar(50) NULL,
	vo_mth_ngay_cap date NULL,
	vo_mth_noi_cap varchar(500) NULL,
	vo_mth_ma_tinh varchar(50) NULL,
	vo_mth_ma_xa varchar(50) NULL,
	vo_mth_noi_cu_tru text NULL,
	chong_mth_ho_ten varchar(500) NULL,
	chong_mth_ngay_sinh date NULL,
	chong_mth_ma_dan_toc varchar(50) NULL,
	chong_mth_loai_giay_to varchar(255) NULL,
	chong_mth_so_ddcn varchar(50) NULL,
	chong_mth_ngay_cap date NULL,
	chong_mth_noi_cap varchar(500) NULL,
	chong_mth_ma_tinh varchar(50) NULL,
	chong_mth_ma_xa varchar(50) NULL,
	chong_mth_noi_cu_tru text NULL,
	ma_benh_nhan varchar(50) NULL,
	ma_chung_tu varchar(50) NULL,
	so_seri varchar(50) NULL,
	ma_the_bhyt_me varchar(50) NULL,
	ma_quoc_tich_me varchar(50) NULL,
	loai_giay_to_me varchar(255) NULL,
	ma_tinh_me varchar(50) NULL,
	ma_xa_me varchar(50) NULL,
	ngay_sinh_cha date NULL,
	ma_dan_toc_cha varchar(50) NULL,
	loai_giay_to_cha varchar(255) NULL,
	so_ddcn_cha varchar(50) NULL,
	ngay_cap_cha date NULL,
	noi_cap_cha varchar(500) NULL,
	ma_the_tam varchar(50) NULL,
	lan_sinh int4 NULL,
	so_con_song int4 NULL,
	ma_tinh_noi_sinh varchar(50) NULL,
	ma_xa_noi_sinh varchar(50) NULL,
	tinh_trang_con text NULL,
	sinh_con_phau_thuat int2 NULL,
	sinh_con_duoi_32_tuan int2 NULL,
	la_cap_lai int2 NULL,
	ma_dinh_danh varchar(100) NULL,
	benh_nhan_id uuid NULL,
	ngay_sinh_me date NULL,
	ma_dan_toc_me varchar(50) NULL,
	CONSTRAINT csyt_benh_an_giay_chung_sinh_pkey PRIMARY KEY (id)
);

CREATE TABLE csyt_benh_an_luu_tru (
	id uuid DEFAULT gen_random_uuid() NOT NULL,
	benh_an_id uuid NOT NULL,
	doi_tuong_id uuid NULL,
	phong_ban_id uuid NULL,
	chuyen_khoa_id uuid NULL,
	ngay_vao date NULL,
	thoi_gian_vao timestamp(6) NULL,
	ly_do_vao_code varchar(30) NULL,
	phong_ban_chuyen_den_id uuid NULL, -- Phong ban (dich) chuyen den ID
	phong_ban_chuyen_di_id uuid NULL, -- Phong ban (nguon) chuyen di ID theo LUUTRU_PREV
	giuong_dat_truoc_id uuid NULL,
	ly_do_chuyen_khoa_id uuid NULL,
	luu_tru_prev uuid NULL, -- Linked list lộ trình chuyển khoa, trỏ đến bản ghi khoa trước
	luu_tru_current bpchar(1) DEFAULT '1'::bpchar NOT NULL, -- '1' = đang điều trị tại khoa này | '0' = đã rời khoa
	bac_si_dieu_tri_id uuid NULL,
	ngay_ra date NULL,
	thoi_gian_ra timestamp(6) NULL,
	ly_do_ra_id uuid NULL,
	ly_do_ra_code varchar(30) NULL,
	icd_ra_khoa varchar(50) NULL,
	chan_doan_ra_khoa varchar(500) NULL,
	benh_vien_id varchar(10) NULL,
	ngay_tao timestamp(6) DEFAULT now() NOT NULL,
	ngay_cap_nhat timestamp(6) NULL,
	nguoi_tao varchar(100) NULL,
	nguoi_cap_nhat varchar(100) NULL,
	nguoi_xoa varchar(100) NULL,
	bi_xoa int2 DEFAULT 0 NOT NULL,
	ma_cskcb varchar(50) NULL,
	ngay_xoa timestamp(6) NULL,
	phong_ban_dieu_tri_ket_hop_id uuid NULL, -- Phong ban dieu tri ket hop (song song)
	is_dieu_tri_ket_hop bool NULL, -- Danh dau luu tru dang dieu tri ket hop
	icd_kem_theo_ra_khoa varchar(50) NULL,
	ten_icd_kem_theo_ra_khoa varchar(500) NULL,
	thoi_gian_bat_dau_dtkh timestamp NULL, -- Thời điểm chỉ định ĐTKH (set 1 lần lúc chỉ định)
	thoi_gian_ket_thuc_dtkh timestamp NULL, -- NULL = đang ĐTKH; có giá trị = đã kết thúc ĐTKH
	CONSTRAINT csyt_benh_an_luu_tru_pkey PRIMARY KEY (id)
);

CREATE TABLE csyt_benh_an_luu_tru_chi_tiet (
	id uuid DEFAULT gen_random_uuid() NOT NULL,
	luu_tru_id uuid NOT NULL,
	khoa_dieu_tri_id uuid NULL,
	phong_ban_id uuid NULL,
	giuong_benh_id uuid NULL,
	giuong_benh_chuyen_den_id uuid NULL,
	ngay_vao date NULL,
	thoi_gian_vao timestamp(6) NULL,
	thoi_gian_du_kien_ra timestamp(6) NULL,
	ngay_ra date NULL,
	thoi_gian_ra timestamp(6) NULL,
	ly_do_id uuid NULL,
	doi_tuong_id uuid NULL,
	bao_phong bpchar(1) NULL,
	bao_giuong bpchar(1) NULL,
	giuong_tam bpchar(1) NULL,
	khong_tinh_tien bpchar(1) NULL,
	luu_tru_chi_tiet_prev uuid NULL, -- Linked list lịch sử đổi giường trong cùng 1 lần nằm khoa
	luu_tru_chi_tiet_current bpchar(1) DEFAULT '1'::bpchar NOT NULL,
	benh_vien_id varchar(10) NULL,
	so_ngay numeric(10, 2) NULL,
	loai_phau_thuat varchar(10) NULL,
	ghi_chu text NULL,
	ghep_giuong bpchar(1) NULL,
	giu_giuong bpchar(1) NULL,
	ngay_tao timestamp(6) DEFAULT now() NOT NULL,
	ngay_cap_nhat timestamp(6) NULL,
	nguoi_tao varchar(100) NULL,
	nguoi_cap_nhat varchar(100) NULL,
	nguoi_xoa varchar(100) NULL,
	bi_xoa int2 DEFAULT 0 NOT NULL,
	ma_cskcb varchar(50) NULL,
	ngay_xoa timestamp(6) NULL,
	CONSTRAINT csyt_benh_an_luu_tru_chi_tiet_pkey PRIMARY KEY (id)
);

CREATE TABLE csyt_bien_ban_hoi_chan (
	id uuid DEFAULT gen_random_uuid() NOT NULL,
	benh_an_id uuid NOT NULL, -- FK csyt_benh_an_dieu_tri.id
	tiep_nhan_id uuid NULL,
	benh_nhan_id uuid NULL,
	ma_cskcb varchar(50) NOT NULL,
	so_phieu varchar(50) NULL, -- So phieu hoi chan, vd 2026.HC.07569
	thoi_gian_tao_phieu timestamp NULL,
	nguoi_lap_id uuid NULL,
	bac_si_de_xuat_id uuid NULL,
	ly_do_hoi_chan text NULL,
	noi_hoi_chan varchar(200) NULL,
	to_dieu_tri_id uuid NULL,
	ap_dung_tu_ngay date NULL,
	ap_dung_den_ngay date NULL,
	ap_dung_so_ngay int4 NULL,
	ngay_hoi_chan timestamp NULL,
	khoa_hoi_chan_id uuid NULL,
	hinh_thuc varchar(50) NULL,
	phong_id uuid NULL,
	giuong_id uuid NULL,
	chan_doan text NULL,
	chan_doan_tuyen_duoi text NULL,
	yeu_cau_hoi_chan text NULL,
	giai_doan_benh text NULL,
	ma_benh_chinh varchar(50) NULL,
	ten_chan_doan_benh_chinh varchar(500) NULL,
	khoa_chan_doan_id uuid NULL,
	tom_tat_dien_bien text NULL,
	phan_loai_vet_mo varchar(50) NULL,
	phuong_phap_vo_cam varchar(50) NULL,
	chan_doan_nguyen_nhan_tien_luong text NULL,
	ly_do text NULL,
	cham_soc text NULL,
	ket_luan text NULL,
	huong_dieu_tri_tiep_theo text NULL,
	chu_toa_id uuid NULL,
	thu_ky_id uuid NULL,
	thanh_vien_tham_gia jsonb NULL, -- Mang JSON thanh vien tham gia (FE dinh nghia shape)
	thuoc_hoi_chan jsonb NULL, -- Mang JSON thuoc hoi chan (FE dinh nghia shape)
	bi_xoa int2 DEFAULT 0 NOT NULL,
	ngay_tao timestamp NULL,
	nguoi_tao varchar(50) NULL,
	ngay_cap_nhat timestamp NULL,
	nguoi_cap_nhat varchar(50) NULL,
	ngay_xoa timestamp NULL,
	nguoi_xoa varchar(50) NULL,
	hososohoa_id uuid NULL, -- FK csyt_mauhososohoa.id - Lien ket voi ho so so hoa de ky so va in phieu
	so_phieu_bien_ban_hoi_chan varchar(50) NULL,
	CONSTRAINT csyt_bien_ban_hoi_chan_pkey PRIMARY KEY (id)
);

CREATE TABLE csyt_ca_lam_viec (
	dm_thoi_gian_lam_viec_id uuid NULL,
	ma varchar NULL,
	ten varchar NULL,
	gio_bat_dau_buoi_sang time NULL,
	gio_ket_thuc_buoi_sang time NULL,
	gio_bat_dau_buoi_chieu time NULL,
	gio_ket_thuc_buoi_chieu time NULL,
	tu_ngay date NULL,
	den_ngay date NULL,
	trang_thai varchar(25) NULL,
	pham_vi_ap_dung varchar(25) NULL,
	id uuid DEFAULT gen_random_uuid() NOT NULL, -- Key của bảng
	ngay_tao timestamp DEFAULT now() NOT NULL, -- Ngày tạo
	nguoi_tao varchar DEFAULT 'system'::character varying NOT NULL, -- Người tạo
	ngay_cap_nhat timestamp DEFAULT now() NOT NULL, -- Ngày cập nhật
	nguoi_cap_nhat varchar DEFAULT 'system'::character varying NOT NULL, -- Người cập nhật
	bi_xoa int2 DEFAULT 0 NULL, -- Bị xóa mềm
	ngay_xoa timestamp NULL, -- Ngày xóa mềm
	nguoi_xoa varchar NULL, -- Người xóa mềm
	ma_cskcb varchar(25) NULL,
	nguoi_su_dung_id uuid NULL, -- Id người sử dụng
	CONSTRAINT csyt_ca_lam_viec_pkey PRIMARY KEY (id)
);

CREATE TABLE csyt_dmc_cap_ky_phieu (
	id uuid DEFAULT gen_random_uuid() NOT NULL,
	dmc_phieu_ky_so_id uuid NOT NULL,
	ma_vi_tri_ky varchar(50) NOT NULL,
	ten_vi_tri_ky varchar(255) NOT NULL,
	chuc_danh_ky varchar(100) NULL,
	thu_tu_ky int4 NOT NULL,
	loai_chu_ky varchar(50) NULL,
	toa_do_x_mac_dinh numeric(10, 2) NULL,
	toa_do_y_mac_dinh numeric(10, 2) NULL,
	trang_so_mac_dinh int4 DEFAULT 1 NULL,
	bat_buoc_ky int2 DEFAULT 1 NULL,
	hoat_dong int2 DEFAULT 1 NULL,
	ngay_tao timestamptz DEFAULT now() NULL,
	nguoi_tao_id uuid NULL,
	da_xoa int2 DEFAULT 0 NULL,
	CONSTRAINT csyt_dmc_cap_ky_phieu_pkey PRIMARY KEY (id)
);

CREATE TABLE csyt_dmc_chuc_danh (
	id uuid DEFAULT gen_random_uuid() NOT NULL,
	ma_chuc_danh varchar(50) NOT NULL,
	ten_chuc_danh varchar(255) NOT NULL,
	mo_ta text NULL,
	cap_bac_quan_ly int4 DEFAULT 0 NULL,
	loai_chuc_danh varchar(50) NULL,
	hoat_dong int2 DEFAULT 1 NULL,
	ngay_tao timestamptz DEFAULT now() NULL,
	nguoi_tao_id uuid NULL,
	ngay_cap_nhat timestamptz NULL,
	nguoi_cap_nhat_id uuid NULL,
	da_xoa int2 DEFAULT 0 NULL,
	CONSTRAINT csyt_dmc_chuc_danh_ma_chuc_danh_key UNIQUE (ma_chuc_danh),
	CONSTRAINT csyt_dmc_chuc_danh_pkey PRIMARY KEY (id)
);

CREATE TABLE csyt_don_thuoc_nha_thuoc_ct (
	id uuid DEFAULT gen_random_uuid() NOT NULL,
	ma_cskcb varchar NOT NULL,
	don_thuoc_nha_thuoc_id uuid NOT NULL,
	ylthuocvt_id uuid NULL,
	ref_id uuid NULL,
	ref_table varchar NULL,
	thuocvattuid numeric NOT NULL,
	ton_kho_ct_id numeric NULL,
	nhap_xuat_ct_id int8 NULL,
	cap_gia_tt_id uuid NULL,
	so_luong numeric NOT NULL,
	so_luong_con_lai numeric NOT NULL,
	don_gia_xuat numeric NULL,
	don_gia numeric NULL,
	thanh_tien_xuat numeric NULL,
	thanh_tien numeric NULL,
	ti_le_mien_giam numeric NULL,
	gia_tri_mien_giam numeric NULL,
	thanh_tien_sau_mien_giam numeric NULL,
	bi_xoa int2 DEFAULT 0 NOT NULL,
	ngay_tao timestamp DEFAULT CURRENT_TIMESTAMP NOT NULL,
	ngay_cap_nhat timestamp NULL,
	nguoi_tao varchar(100) NOT NULL,
	nguoi_cap_nhat varchar(100) NULL,
	ngay_xoa timestamp NULL,
	nguoi_xoa varchar(50) NULL,
	don_thuoc_ct_goc_id uuid NULL,
	kieu_xuat_thuoc_id uuid NULL,
	CONSTRAINT pl_csyt_don_thuoc_nha_thuoc_ct PRIMARY KEY (id)
);

CREATE TABLE csyt_hinh_thuc_thanh_toan (
	hinh_thuc_thanh_toan_id uuid NULL, -- FK dmc_hinh_thuc_thanh_toan.id
	ma_hinh_thuc varchar NULL, -- Mã hình thức thanh toán
	ten_hinh_thuc varchar NULL, -- Tên hình thức thanh toán
	csyt_vien_phi_chung_tu_id uuid NULL, -- FK csyt_vien_phi_chung_tu.id
	so_tien numeric DEFAULT 0 NULL, -- Số tiền thanh toán
	ma_ngan_hang varchar NULL, -- Mã ngân hàng
	ma_doi_soat varchar NULL, -- Mã đối soát
	ma_chuan_chi varchar NULL, -- Mã chuẩn chi
	pos varchar NULL, -- Thông tin máy POS
	ghi_chu varchar NULL, -- Ghi chú
	ma_cskcb varchar NULL, -- Mã cơ sở khám chữa bệnh
	id uuid DEFAULT gen_random_uuid() NOT NULL, -- Key của bảng
	ngay_tao timestamp DEFAULT now() NOT NULL, -- Ngày tạo
	nguoi_tao varchar DEFAULT 'system'::character varying NOT NULL, -- Người tạo
	ngay_cap_nhat timestamp DEFAULT now() NOT NULL, -- Ngày cập nhật
	nguoi_cap_nhat varchar DEFAULT 'system'::character varying NOT NULL, -- Người cập nhật
	bi_xoa int2 DEFAULT 0 NULL, -- Bị xóa mềm
	ngay_xoa timestamp NULL, -- Ngày xóa mềm
	nguoi_xoa varchar NULL, -- Người xóa mềm
	CONSTRAINT csyt_hinh_thuc_thanh_toan_pkey PRIMARY KEY (id)
);

CREATE TABLE csyt_hoa_don_dien_tu (
	id uuid DEFAULT gen_random_uuid() NOT NULL,
	ma_cskcb varchar(50) NULL,
	hoat_dong int2 DEFAULT 1 NULL,
	bi_xoa int2 DEFAULT 0 NULL,
	ngay_tao timestamp(6) DEFAULT now() NULL,
	nguoi_tao varchar(50) NULL,
	ngay_cap_nhat timestamp(6) DEFAULT now() NULL,
	nguoi_cap_nhat varchar(50) NULL,
	ngay_xoa timestamp(6) NULL,
	nguoi_xoa varchar(50) NULL,
	ghi_chu varchar(500) NULL,
	tiep_nhan_id uuid NULL,
	benh_an_id uuid NULL,
	dot_dieu_tri_id uuid NULL,
	benh_nhan_id uuid NULL,
	ho_ten varchar(250) NULL,
	dia_chi varchar(2000) NULL,
	ten_don_vi varchar(2000) NULL,
	dia_chi_don_vi varchar(2000) NULL,
	ma_so_thue varchar(50) NULL,
	email varchar(255) NULL,
	cccd varchar(20) NULL,
	so_giay_to varchar(20) NULL,
	so_dien_thoai varchar(20) NULL,
	hoa_don_goc_id uuid NULL,
	loai_hoa_don varchar(50) NOT NULL,
	trang_thai varchar(50) NOT NULL, -- Trạng thái hóa đơn:¶CHO_PHAT_HANH / DA_PHAT_HANH/ LOI_PHATHANH/ DA_DIEU_CHINH/ DA_THAY_THE / PHAT_HANH_LAI
	mau_so varchar(50) NULL,
	ky_hieu varchar(50) NULL,
	so_hoa_don varchar(50) NULL,
	ma_cqt varchar(100) NULL,
	ma_tra_cuu varchar(255) NULL,
	invoice_url text NULL,
	tong_tien_hang numeric NOT NULL,
	tong_tien_mien_giam numeric NOT NULL,
	tong_tien_thue numeric NOT NULL,
	tong_tien_thanh_toan numeric NOT NULL,
	nha_cung_cap varchar(100) NULL,
	external_invoice_id varchar(255) NULL,
	external_transaction_id varchar(255) NULL,
	ngay_phat_hanh timestamp NULL,
	ngay_huy timestamp NULL,
	loai_nghiep_vu varchar(50) NULL,
	ly_do_dieu_chinh varchar(500) NULL,
	invoice_xml text NULL,
	signed_xml text NULL,
	pdf_url text NULL,
	lan_gui_cqt int4 NULL,
	thoi_gian_gui_cqt timestamp NULL,
	thong_diep_loi text NULL,
	sys_req_time timestamp NULL,
	sys_resp_time int4 NULL,
	sys_resp_http_code varchar(50) NULL,
	sys_resp_code varchar(50) NULL,
	sys_resp_message varchar(50) NULL,
	sys_resp_details text NULL,
	hinhthuc_thanhtoan varchar(50) NULL,
	CONSTRAINT csyt_hoa_don_dien_tu_pkey PRIMARY KEY (id)
);

CREATE TABLE csyt_hoa_don_dien_tu_chi_tiet (
	id uuid DEFAULT gen_random_uuid() NOT NULL,
	ma_cskcb varchar(50) NULL,
	hoat_dong int2 DEFAULT 1 NULL,
	bi_xoa int2 DEFAULT 0 NULL,
	ngay_tao timestamp(6) DEFAULT now() NULL,
	nguoi_tao varchar(50) NULL,
	ngay_cap_nhat timestamp(6) DEFAULT now() NULL,
	nguoi_cap_nhat varchar(50) NULL,
	ngay_xoa timestamp(6) NULL,
	nguoi_xoa varchar(50) NULL,
	ghi_chu varchar(500) NULL,
	hoa_don_dien_tu_id uuid NOT NULL,
	hoa_don_goc_chi_tiet_id uuid NULL,
	loai_dieu_chinh varchar(50) NULL,
	csyt_vien_phi_chung_tu_id uuid NULL,
	csyt_vien_phi_chung_tu_chi_tiet_id uuid NULL,
	csyt_vien_phi_id uuid NULL,
	ref_id uuid NULL,
	ref_table varchar NULL,
	dich_vu_id uuid NULL,
	thuoc_vat_tu_id uuid NULL,
	loai_chi_phi varchar NULL,
	nhom_hoa_don_vien_phi_id uuid NULL,
	so_luong numeric NULL,
	don_gia numeric NULL,
	thanh_tien numeric NULL,
	tien_mien_giam numeric NOT NULL,
	gia_tri_hoa_don numeric NOT NULL,
	ty_le_thue numeric NULL,
	tien_thue numeric NULL,
	tong_tien_thanh_toan numeric NULL,
	so_luong_dieu_chinh numeric NULL,
	don_gia_dieu_chinh numeric NULL,
	gia_tri_dieu_chinh numeric NULL,
	ly_do_dieu_chinh varchar(500) NOT NULL,
	stt_hien_thi int4 NOT NULL,
	ma_hang varchar(100) NOT NULL,
	ten_hang varchar(1000) NOT NULL,
	don_vi_tinh varchar(100) NULL,
	ty_le_vat int4 DEFAULT 0 NULL,
	CONSTRAINT csyt_hoa_don_dien_tu_chi_tiet_pkey PRIMARY KEY (id)
);

CREATE TABLE csyt_kycap_hososohoa (
	kycap_id uuid DEFAULT gen_random_uuid() NOT NULL, -- ID ký cấp (PK)
	hoso_sohoa_id uuid NULL, -- ID phiếu số hóa hồ sơ liên kết (FK → csyt_mauhososohoa)
	khoa_id uuid NULL,
	phong_id uuid NULL,
	vi_tri_ky varchar(255) NULL, -- Snapshot tên vị trí tại thời điểm trình ký
	phuong_thuc_ky uuid NULL,
	nguoiky_id uuid NULL, -- ID người ký — ưu tiên; null → fallback theo chuc_danh_ky
	thogian_kyso timestamptz NULL,
	trangthai_kyso int2 DEFAULT 0 NULL, -- Trạng thái: 0=Chưa ký, 1=Đã ký, 2=Đã hủy
	url text NULL,
	nguoihuyky_id uuid NULL,
	thoigianhuy timestamptz NULL,
	loaihuyky varchar(50) NULL,
	lydohuy varchar(500) NULL,
	nguoitao_id uuid NULL,
	ngaytao timestamptz DEFAULT now() NULL,
	nguoihuy_id uuid NULL,
	ngayhuy timestamptz NULL,
	trinhky_id uuid NULL,
	loaitrinhky int2 DEFAULT 0 NULL,
	vitritrinh varchar(255) NULL,
	dinhdanhtrinh uuid NULL,
	dm_cau_hinh_ky_cap_id uuid NULL, -- FK → dm_cau_hinh_ky_cap — cấu hình ký cấp từ danh mục
	CONSTRAINT csyt_kycap_hososohoa_pkey PRIMARY KEY (kycap_id)
);

CREATE TABLE csyt_kycap_phieuin_baocao (
	kycap_id uuid DEFAULT gen_random_uuid() NOT NULL, -- ID ký cấp (PK)
	sohoa_phieuin_baocao_id uuid NULL, -- ID phiếu số hóa báo cáo liên kết
	khoa_id uuid NULL,
	phong_id uuid NULL,
	vi_tri_ky varchar(255) NULL, -- Snapshot tên vị trí tại thời điểm trình ký
	phuong_thuc_ky uuid NULL,
	nguoiky_id uuid NULL, -- ID người ký — ưu tiên; null → fallback theo chuc_danh_ky
	thogian_kyso timestamptz NULL,
	trangthai_kyso int2 DEFAULT 0 NULL, -- Trạng thái: 0=Chưa ký, 1=Đã ký, 2=Đã hủy
	url text NULL,
	nguoihuyky_id uuid NULL,
	thoigianhuy timestamptz NULL,
	loaihuyky varchar(50) NULL,
	lydohuy varchar(500) NULL,
	nguoitao_id uuid NULL,
	ngaytao timestamptz DEFAULT now() NULL,
	nguoihuy_id uuid NULL,
	ngayhuy timestamptz NULL,
	trinhky_id uuid NULL,
	loaitrinhky int2 DEFAULT 0 NULL,
	vitritrinh varchar(255) NULL,
	dinhdanhtrinh uuid NULL,
	dm_cau_hinh_ky_cap_id uuid NULL, -- FK → dm_cau_hinh_ky_cap — cấu hình ký cấp từ danh mục
	CONSTRAINT csyt_kycap_phieuin_baocao_pkey PRIMARY KEY (kycap_id)
);

CREATE TABLE csyt_mauhososohoa (
	hoso_sohoa_id uuid DEFAULT gen_random_uuid() NOT NULL,
	tiepnhan_id uuid NULL,
	benhan_id uuid NULL,
	maphieu_hoso varchar(255) NULL,
	loaiphieu int4 NULL,
	report_code varchar(255) NULL,
	hreport varchar(255) NULL,
	khambenh_id uuid NULL,
	luutru_id uuid NULL,
	khoa_id uuid NULL,
	phong_id uuid NULL,
	maphieunv varchar(255) NULL,
	trangthai_dongbo int4 DEFAULT 0 NULL,
	magiaodich varchar(255) NULL,
	malanchidinh varchar(255) NULL,
	phuongthucky varchar(255) NULL,
	nguoiky_id uuid NULL,
	thogian_kyso timestamptz NULL,
	trangthai_kyso int4 DEFAULT 0 NULL,
	nguoihuyky_id uuid NULL,
	thoigianhuy timestamptz NULL,
	loaihuyky int4 NULL,
	lydohuy text NULL,
	nguoitao_id uuid NULL,
	ngaytao timestamptz DEFAULT now() NULL,
	nguoihuy_id uuid NULL,
	ngayhuy timestamptz NULL,
	sign_data_link varchar(1000) NULL,
	sign_auth varchar(255) NULL,
	rpt_type varchar(255) NULL,
	params text NULL,
	format_type varchar(50) NULL,
	ten_nguoi_tao varchar(255) NULL,
	da_xoa int4 DEFAULT 0 NULL,
	ma_don_thuoc bpchar(50) NULL,
	trangthai_donthuoc_id numeric NULL,
	loi_dan text NULL,
	hoa_don_dien_tu_id uuid NULL,
	pttt_id uuid NULL,
	thuc_hien_dich_vu_id uuid NULL,
	la_filebosung int2 NULL,
	la_dongdau int2 DEFAULT 0 NULL,
	loai_don_thuoc_id int4 NULL,
	stt_loai_ke_don int4 NULL,
	dot_1_tu_ngay date NULL,
	dot_1_den_ngay date NULL,
	dot_2_tu_ngay date NULL,
	dot_2_den_ngay date NULL,
	dot_3_tu_ngay date NULL,
	dot_3_den_ngay date NULL,
	cach_sac_thuoc varchar NULL,
	cach_uong varchar NULL,
	luu_y varchar NULL,
	so_thang numeric NULL,
	tong_so_ngay_su_dung numeric NULL,
	so_ngay_su_dung_mot_thang numeric NULL,
	tu_ngay date NULL,
	den_ngay date NULL,
	stt_don_thuoc numeric NULL,
	CONSTRAINT csyt_mauhososohoa_pkey PRIMARY KEY (hoso_sohoa_id)
);

CREATE TABLE csyt_mauhososohoa_sign_log (
	id uuid NOT NULL,
	username varchar(50) NULL,
	serial_number varchar(50) NULL,
	cert_type varchar(50) NULL,
	nguoiky_id uuid NULL,
	hoso_sohoa_id uuid NULL,
	report_code varchar(100) NULL,
	sign_data_link_old varchar(1000) NULL,
	sign_data_link_new varchar(1000) NULL,
	content_data_old text NULL,
	content_data_new text NULL,
	status int4 DEFAULT 1 NOT NULL,
	is_deleted int4 DEFAULT 0 NOT NULL,
	create_date timestamp DEFAULT CURRENT_TIMESTAMP NOT NULL,
	update_date timestamp NULL,
	create_by varchar(50) NOT NULL,
	update_by varchar(50) NULL
);

CREATE TABLE csyt_mien_giam (
	id uuid DEFAULT gen_random_uuid() NOT NULL,
	ngay_tao timestamp DEFAULT now() NOT NULL,
	nguoi_tao varchar(100) DEFAULT 'system'::character varying NOT NULL,
	ngay_cap_nhat timestamp DEFAULT now() NOT NULL,
	nguoi_cap_nhat varchar(100) DEFAULT 'system'::character varying NOT NULL,
	bi_xoa int2 DEFAULT 0 NULL,
	ngay_xoa timestamp NULL,
	nguoi_xoa varchar(100) NULL,
	so_phieu_mien_giam varchar(30) NULL, -- Tự động gen theo quy tắc MG.YYMM999999
	tiep_nhan_id uuid NULL,
	dot_dieu_tri_id uuid NULL,
	benh_an_id uuid NULL,
	benh_nhan_id uuid NULL,
	loai_mien_giam int4 NULL, -- 1: Theo tỷ lệ, 2: Theo số tiền
	ty_le_mien_giam numeric(25, 4) NULL,
	gia_tri_mien_giam numeric(25, 4) NULL,
	ly_do_id uuid NULL,
	ghi_chu varchar(4000) NULL,
	duyet_mien_giam int2 NULL,
	duyet_tu_dong int2 NULL,
	ly_do_tu_choi varchar(4000) NULL,
	url varchar(4000) NULL,
	nguoi_lap_id uuid NULL,
	ngay_lap timestamp NULL,
	nguoi_duyet_id uuid NULL,
	ngay_duyet timestamp NULL,
	ma_cskcb varchar(10) NULL,
	ho_so_so_hoa_id uuid NULL,
	CONSTRAINT csyt_mien_giam_pk_id PRIMARY KEY (id)
);

CREATE TABLE csyt_mien_giam_ap_dung (
	id uuid DEFAULT gen_random_uuid() NOT NULL,
	ngay_tao timestamp DEFAULT now() NOT NULL,
	nguoi_tao varchar(100) DEFAULT 'system'::character varying NOT NULL,
	mien_giam_id uuid NOT NULL,
	tiep_nhan_id uuid NULL,
	dot_dieu_tri_id uuid NULL,
	ma_cskcb varchar(10) NULL,
	CONSTRAINT csyt_mien_giam_ap_dung_pk_id PRIMARY KEY (id),
	CONSTRAINT csyt_mien_giam_ap_dung_uq_mien_giam UNIQUE (mien_giam_id)
);

CREATE TABLE csyt_mien_giam_chi_tiet (
	id uuid DEFAULT gen_random_uuid() NOT NULL,
	ngay_tao timestamp DEFAULT now() NOT NULL,
	nguoi_tao varchar(100) DEFAULT 'system'::character varying NOT NULL,
	ngay_cap_nhat timestamp DEFAULT now() NOT NULL,
	nguoi_cap_nhat varchar(100) DEFAULT 'system'::character varying NOT NULL,
	bi_xoa int2 DEFAULT 0 NULL,
	ngay_xoa timestamp NULL,
	nguoi_xoa varchar(100) NULL,
	csyt_mien_giam_id uuid NULL,
	vien_phi_id uuid NULL,
	ref_table varchar(100) NULL,
	ty_le_mien_giam numeric(25, 4) NULL,
	gia_tri_mien_giam numeric(25, 4) NULL,
	ma_cskcb varchar(10) NULL,
	mien_giam_chi_tra numeric(25, 4) NULL,
	mien_giam_bhtn_chi_tra numeric(25, 4) NULL,
	mien_giam_cong_ty_chi_tra numeric(25, 4) NULL,
	mien_giam_the_hoi_vien_chi_tra numeric(25, 4) NULL,
	mien_giam_chuong_trinh_chi_tra numeric(25, 4) NULL,
	thanh_tien_benh_nhan_con_phai_thanh_toan numeric(25, 4) NULL,
	CONSTRAINT csyt_mien_giam_chi_tiet_pk_id PRIMARY KEY (id)
);

CREATE TABLE csyt_phieu_ban_giao_nb_chuyen_khoa (
	id uuid DEFAULT gen_random_uuid() NOT NULL,
	tiep_nhan_id uuid NULL,
	benh_an_id uuid NULL,
	ma_cskcb varchar(50) NOT NULL,
	so_phieu_ban_giao varchar(255) NULL,
	benh_an_cho_chuyen_khoa_id uuid NULL,
	khoa_id uuid NULL,
	phong_id uuid NULL,
	giuong_id uuid NULL,
	thoi_gian_lap timestamp NULL,
	nguoi_lap_id uuid NULL,
	ly_do_chuyen text NULL,
	ly_do_nhap_vien text NULL,
	dien_bien_benh text NULL,
	chan_doan text NULL,
	da_can_thiep text NULL,
	tinh_trang_hien_tai text NULL,
	ke_hoach_dieu_tri_tiep_theo text NULL,
	ngay_ban_giao timestamp NULL,
	khoa_ban_giao_id uuid NULL,
	bac_si_ban_giao_id uuid NULL,
	khoa_nhan_id uuid NULL,
	bac_si_nhan_id uuid NULL,
	bac_si_chi_dinh_id uuid NULL,
	chuyen_theo_yeu_cau_nguoi_benh bool DEFAULT false NULL,
	dieu_duong_khoa_chuyen_id uuid NULL,
	dieu_duong_khoa_nhan_id uuid NULL,
	tinh_trang_nguoi_benh varchar(20) NULL,
	muc_do_tinh_tao varchar(30) NULL,
	dau bool DEFAULT false NULL,
	thang_diem_dau int4 NULL,
	nguy_co_te_nga bool DEFAULT false NULL,
	thang_diem_nguy_co_te_nga int4 NULL,
	nhiet_do float8 NULL,
	mach int4 NULL,
	huyet_ap_tam_thu int4 NULL,
	huyet_ap_tam_truong int4 NULL,
	nhip_tho int4 NULL,
	spo2 int4 NULL,
	di_ung bool DEFAULT false NULL,
	di_ung_ghi_chu text NULL,
	duong_truyen_tinh_mach_ngoai_bien bool DEFAULT false NULL,
	duong_truyen_tinh_mach_ngoai_bien_noi_dat varchar(255) NULL,
	duong_truyen_tinh_mach_ngoai_bien_ngay_dat timestamp NULL,
	duong_truyen_dong_mach bool DEFAULT false NULL,
	duong_truyen_dong_mach_ngay_dat timestamp NULL,
	ong_thong_tieu bool DEFAULT false NULL,
	ong_thong_tieu_ngay_dat timestamp NULL,
	dan_luu bool DEFAULT false NULL,
	dan_luu_noi_dat_1 varchar(255) NULL,
	dan_luu_ngay_dat_1 timestamp NULL,
	dan_luu_noi_dat_2 varchar(255) NULL,
	dan_luu_ngay_dat_2 timestamp NULL,
	duong_truyen_khac text NULL,
	lieu_the_oxy bool DEFAULT false NULL,
	lieu_the_oxy_luu_luong float8 NULL,
	vet_loet_ti_de bool DEFAULT false NULL,
	vet_loet_ti_de_ghi_chu varchar(500) NULL,
	bang_vet_thuong bool DEFAULT false NULL,
	bang_vet_thuong_ghi_chu varchar(500) NULL,
	ngay_cat_chi timestamp NULL,
	dinh_duong varchar(255) NULL,
	dinh_duong_che_do_an varchar(255) NULL,
	van_dong varchar(30) NULL,
	bai_tiet varchar(30) NULL,
	thuoc_da_dieu_tri_trong_ngay bool DEFAULT false NULL,
	thuoc_da_dieu_tri_trong_ngay_luc timestamp NULL,
	thuoc_can_su_dung_tiep bool DEFAULT false NULL,
	thuoc_can_su_dung_tiep_luc timestamp NULL,
	tai_lieu_ho_so_benh_an bool DEFAULT false NULL,
	tai_lieu_vat_dung_ca_nhan bool DEFAULT false NULL,
	tai_lieu_khac varchar(500) NULL,
	is_bac_si bool NULL,
	bi_xoa int2 DEFAULT 0 NOT NULL,
	ngay_tao timestamp NULL,
	nguoi_tao varchar(50) NULL,
	ngay_cap_nhat timestamp NULL,
	nguoi_cap_nhat varchar(50) NULL,
	ngay_xoa timestamp NULL,
	nguoi_xoa varchar(50) NULL,
	CONSTRAINT csyt_phieu_ban_giao_nb_chuyen_khoa_pkey PRIMARY KEY (id)
);

CREATE TABLE csyt_phieu_cham_soc_cap_23 (
	id uuid DEFAULT gen_random_uuid() NOT NULL,
	benh_an_id uuid NOT NULL, -- FK csyt_benh_an_dieu_tri.id
	tiep_nhan_id uuid NULL,
	benh_nhan_id uuid NULL,
	to_dieu_tri_id uuid NULL,
	ma_cskcb varchar(50) NOT NULL,
	so_phieu varchar(50) NULL, -- So phieu cham soc, vd 2026.PCS.00001
	thoi_gian_tao_phieu timestamp NULL,
	nguoi_lap_id uuid NULL,
	nguoi_lap varchar(255) NULL,
	thoi_gian_vao_khoa timestamp NULL,
	ma_khoa varchar(50) NULL,
	ten_khoa varchar(255) NULL,
	ma_phong varchar(50) NULL,
	ten_phong varchar(255) NULL,
	giuong varchar(50) NULL,
	chan_doan text NULL,
	can_nang varchar(50) NULL,
	chieu_cao varchar(50) NULL,
	di_ung int2 NULL,
	co_tien_su_di_ung int2 NULL,
	mo_ta_di_ung text NULL,
	ghi_chu_ban_giao text NULL,
	bi_xoa int2 DEFAULT 0 NOT NULL,
	ngay_tao timestamp NULL,
	nguoi_tao varchar(50) NULL,
	ngay_cap_nhat timestamp NULL,
	nguoi_cap_nhat varchar(50) NULL,
	ngay_xoa timestamp NULL,
	nguoi_xoa varchar(50) NULL,
	che_do_cham_soc varchar(50) NULL, -- Chế độ chăm sóc (header).
	dieu_duong_id uuid NULL, -- ID điều dưỡng phụ trách phiếu.
	dieu_duong varchar(255) NULL, -- Tên điều dưỡng phụ trách phiếu.
	ngay_theo_doi timestamp NULL, -- Ngày theo dõi (phần Phiếu theo dõi và chăm sóc cấp 2-3).
	hososohoa_id uuid NULL,
	bieu_mau_ma varchar(50) NULL,
	source_type varchar(50) NULL,
	"version" varchar(50) NULL,
	che_do_cham_soc_id uuid NULL, -- ID chế độ chăm sóc (FK dm_che_do_cham_soc.id)
	thoi_gian_theo_doi_cham_soc timestamp NULL, -- Thời gian theo dõi chăm sóc
	kham_benh_id uuid NULL, -- ID khám bệnh, dùng trong trường hợp Điều trị ngoại trú mãn tính
	CONSTRAINT csyt_phieu_cham_soc_cap_23_pkey PRIMARY KEY (id)
);

CREATE TABLE csyt_phieu_cham_soc_cap_23_chan_doan (
	id uuid DEFAULT gen_random_uuid() NOT NULL,
	phieu_cham_soc_cap_23_id uuid NOT NULL, -- FK csyt_phieu_cham_soc_cap_23.id
	ma_cskcb varchar(50) NOT NULL,
	chan_doan_dieu_duong text NULL,
	muc_tieu_cham_soc text NULL,
	thu_tu int4 NULL,
	bi_xoa int2 DEFAULT 0 NOT NULL,
	ngay_tao timestamp NULL,
	nguoi_tao varchar(50) NULL,
	ngay_cap_nhat timestamp NULL,
	nguoi_cap_nhat varchar(50) NULL,
	ngay_xoa timestamp NULL,
	nguoi_xoa varchar(50) NULL,
	CONSTRAINT csyt_phieu_cham_soc_cap_23_chan_doan_pkey PRIMARY KEY (id)
);

CREATE TABLE csyt_phieu_cham_soc_cap_23_theo_doi (
	id uuid DEFAULT gen_random_uuid() NOT NULL,
	phieu_cham_soc_cap_23_id uuid NOT NULL, -- FK csyt_phieu_cham_soc_cap_23.id
	ma_cskcb varchar(50) NOT NULL,
	thoi_gian varchar(50) NULL, -- Gio theo doi, vd: 08:00, 14:30
	dieu_duong_thuc_hien_id uuid NULL,
	dieu_duong_thuc_hien varchar(255) NULL, -- Ten dieu duong thuc hien theo doi tai thoi diem nay
	phan_cap_cham_soc varchar(50) NULL, -- Phan cap cham soc tai thoi diem nay
	bi_xoa int2 DEFAULT 0 NOT NULL,
	ngay_tao timestamp NULL,
	nguoi_tao varchar(50) NULL,
	ngay_cap_nhat timestamp NULL,
	nguoi_cap_nhat varchar(50) NULL,
	ngay_xoa timestamp NULL,
	nguoi_xoa varchar(50) NULL,
	CONSTRAINT csyt_phieu_cham_soc_cap_23_theo_doi_pkey PRIMARY KEY (id)
);

CREATE TABLE csyt_phieu_cham_soc_cap_23_theo_doi_gia_tri (
	id uuid DEFAULT gen_random_uuid() NOT NULL,
	theo_doi_id uuid NOT NULL, -- FK csyt_phieu_cham_soc_cap_23_theo_doi.id
	ma_cskcb varchar(50) NOT NULL,
	nhom_code text NOT NULL, -- Ma nhom: CHI_SO_SINH_TON, TOAN_THAN, HO_HAP, TUAN_HOAN, THUC_HIEN_THUOC, etc.
	muc_con text NULL, -- Ten muc con dong, vd: Mach(Lan/phut), Da/Niem mac, Thuc hien thuoc X
	gia_tri text NULL, -- Gia tri cua muc, vd: 99, Hong am, Da thuc hien
	thu_tu int4 DEFAULT 0 NULL, -- Thu tu sap xep muc con trong nhom
	bi_xoa int2 DEFAULT 0 NOT NULL,
	ngay_tao timestamp NULL,
	nguoi_tao varchar(50) NULL,
	ngay_cap_nhat timestamp NULL,
	nguoi_cap_nhat varchar(50) NULL,
	ngay_xoa timestamp NULL,
	nguoi_xoa varchar(50) NULL,
	nhom_ten text NULL,
	nhom_cha_code text NULL,
	nhom_cha_ten text NULL,
	nhom_thu_tu int4 NULL,
	quy_uoc_ky_hieu text NULL, -- Quy ước ký hiệu dưới dạng JSON, áp dụng cho nhóm chẩn đoán
	CONSTRAINT csyt_phieu_cham_soc_cap_23_theo_doi_gia_tri_pkey PRIMARY KEY (id)
);

CREATE TABLE csyt_phieu_cham_soc_viem_phe_quan (
	id uuid DEFAULT gen_random_uuid() NOT NULL,
	benh_an_id uuid NOT NULL, -- FK csyt_benh_an_dieu_tri.id
	tiep_nhan_id uuid NULL,
	benh_nhan_id uuid NULL,
	to_dieu_tri_id uuid NULL,
	ma_cskcb varchar(50) NOT NULL,
	so_phieu varchar(50) NULL,
	thoi_gian_tao_phieu timestamp NULL,
	thoi_gian_vao_khoa timestamp NULL,
	ma_khoa varchar(50) NULL,
	ten_khoa varchar(255) NULL,
	ma_phong varchar(50) NULL,
	ten_phong varchar(255) NULL,
	giuong varchar(50) NULL,
	chan_doan text NULL,
	ma_icd varchar(50) NULL,
	di_ung int2 NULL,
	co_tien_su_di_ung int2 NULL,
	mo_ta_di_ung text NULL,
	dieu_duong_id uuid NULL,
	dieu_duong varchar(255) NULL,
	dieu_duong_truong_id uuid NULL,
	dieu_duong_truong varchar(255) NULL,
	ghi_chu text NULL,
	thoi_gian_luong_gia timestamp NULL, -- Moc ngay+gio = tieu de cot luong gia
	hososohoa_id uuid NULL,
	bi_xoa int2 DEFAULT 0 NOT NULL,
	ngay_tao timestamp NULL,
	nguoi_tao varchar(50) NULL,
	ngay_cap_nhat timestamp NULL,
	nguoi_cap_nhat varchar(50) NULL,
	ngay_xoa timestamp NULL,
	nguoi_xoa varchar(50) NULL,
	CONSTRAINT csyt_phieu_cham_soc_viem_phe_quan_pkey PRIMARY KEY (id)
);

CREATE TABLE csyt_phieu_cham_soc_viem_phe_quan_chan_doan (
	id uuid DEFAULT gen_random_uuid() NOT NULL,
	phieu_cham_soc_viem_phe_quan_id uuid NOT NULL, -- FK csyt_phieu_cham_soc_viem_phe_quan.id
	ma_cskcb varchar(50) NOT NULL,
	chan_doan_dieu_duong text NULL,
	muc_tieu text NULL,
	can_thiep text NULL,
	ap_dung bool DEFAULT false NULL, -- Van de co ap dung cho nguoi benh khong : true/false
	ket_qua varchar(20) NULL, -- Luong gia: DAT / DAT_MOT_PHAN / CHUA_DAT (1 ket qua / dong chan doan)
	thu_tu int4 NULL,
	bi_xoa int2 DEFAULT 0 NOT NULL,
	ngay_tao timestamp NULL,
	nguoi_tao varchar(50) NULL,
	ngay_cap_nhat timestamp NULL,
	nguoi_cap_nhat varchar(50) NULL,
	ngay_xoa timestamp NULL,
	nguoi_xoa varchar(50) NULL,
	CONSTRAINT csyt_phieu_cham_soc_viem_phe_quan_chan_doan_pkey PRIMARY KEY (id)
);

CREATE TABLE csyt_phieu_chan_doan_nguyen_nhan_tu_vong (
	id uuid NOT NULL,
	tiep_nhan_id uuid NOT NULL, -- FK tiep_nhan.id
	benh_nhan_id uuid NULL,
	khoa_id uuid NULL, -- Khoa tao phieu (FK dm_khoa.id)
	ma_cskcb varchar(50) NOT NULL,
	so_phieu varchar(50) NULL,
	thoi_gian_tu_vong timestamp NULL,
	noi_ghi_nhan_ca_benh text NULL,
	ho_ten_nguoi_than varchar(255) NULL,
	noi_chuyen_den text NULL,
	chan_doan_xac_dinh text NULL,
	ma_icd_chan_doan_xac_dinh varchar(50) NULL,
	chuoi_benh_ly text NULL, -- Phan A muc 1: JSON 4 dong a-d [{moTa, maIcd, tenIcd, thoiGian, donViThoiGian}]
	benh_ly_gop_phan text NULL, -- Phan A muc 2: JSON 1 dong {moTa, maIcd, tenIcd, thoiGian, donViThoiGian}
	co_phau_thuat varchar(20) NULL,
	ds_phau_thuat text NULL, -- Phan B cau 1: JSON [{tenPhauThuat, maPhauThuat, ngayPhauThuat}]
	giam_dinh_phap_y varchar(20) NULL,
	hinh_thuc_tu_vong text NULL, -- Phan B cau 3: JSON danh sach ma (chon nhieu)
	mo_ta_nguyen_nhan_ben_ngoai text NULL,
	ngay_xay_ra timestamp NULL,
	noi_xay_ra text NULL, -- Phan B cau 4: JSON danh sach ma (chon nhieu)
	dia_diem_khac text NULL,
	da_thai varchar(20) NULL,
	sinh_non varchar(20) NULL,
	tuoi_gio numeric(8, 1) NULL,
	tuan_thai numeric(5, 1) NULL,
	can_nang_khi_sinh numeric(8, 1) NULL,
	tuoi_me numeric(5, 1) NULL,
	benh_ly_cua_me text NULL,
	ma_icd_benh_ly_cua_me varchar(50) NULL,
	mang_thai varchar(20) NULL,
	thoi_diem_mang_thai text NULL, -- Phan B cau 6: JSON danh sach ma (chon nhieu)
	mang_thai_gop_phan varchar(20) NULL,
	ket_luan_nguyen_nhan_chinh text NULL,
	ma_icd_ket_luan varchar(50) NULL,
	nguoi_lap_phieu_id uuid NULL,
	nguoi_lap_phieu varchar(255) NULL,
	thu_truong_don_vi_id uuid NULL,
	thu_truong_don_vi varchar(255) NULL,
	hososohoa_id uuid NULL,
	bi_xoa int2 DEFAULT 0 NOT NULL,
	ngay_tao timestamp NULL,
	nguoi_tao varchar(50) NULL,
	ngay_cap_nhat timestamp NULL,
	nguoi_cap_nhat varchar(50) NULL,
	ngay_xoa timestamp NULL,
	nguoi_xoa varchar(50) NULL,
	CONSTRAINT csyt_phieu_chan_doan_nguyen_nhan_tu_vong_pkey PRIMARY KEY (id)
);

CREATE TABLE csyt_phieu_danh_gia_dinh_duong (
	id uuid DEFAULT gen_random_uuid() NOT NULL,
	benh_an_id uuid NULL,
	tiep_nhan_id uuid NOT NULL,
	benh_nhan_id uuid NOT NULL,
	ma_cskcb varchar(50) NOT NULL,
	so_phieu varchar(50) NULL, -- So phieu, vd DGDD000109/2026
	thoi_gian_tao_phieu timestamp NULL,
	nguoi_lap_id uuid NULL,
	nguoi_lap varchar(255) NULL,
	thoi_gian_vao_khoa timestamp NULL,
	ma_khoa varchar(50) NULL,
	ten_khoa varchar(255) NULL,
	ma_phong varchar(50) NULL,
	ten_phong varchar(255) NULL,
	giuong varchar(50) NULL,
	chan_doan text NULL,
	can_nang numeric(5, 2) NULL,
	chieu_cao numeric(5, 1) NULL,
	bmi numeric(4, 1) NULL, -- BE tinh: can_nang / (chieu_cao/100)^2, lam tron 1 chu so
	sut_can_3_thang varchar(20) NULL, -- KHONG | CO_KHONG_RO | CO
	so_kg_sut_can numeric(5, 2) NULL, -- Chi co gia tri khi sut_can_3_thang = CO
	ty_le_mat_can numeric(5, 2) NULL, -- Chi co gia tri khi sut_can_3_thang = CO
	diem_tinh_trang_dinh_duong int2 NULL, -- Phan I — cot Muc do tieu chi danh gia: 1 nhe | 2 trung binh | 3 nang
	diem_muc_do_benh_ly int2 NULL, -- Phan I — cot Muc do anh huong benh ly: 1 nhe | 2 trung binh | 3 nang
	diem_cong_tuoi int2 DEFAULT 0 NOT NULL, -- BE tinh: tuoi tai thoi_gian_tao_phieu >= 70 thi 1
	tong_diem_sang_loc int2 NULL, -- BE tinh: tong 3 diem tren, NULL khi chua chon muc nao
	ket_qua_sang_loc varchar(20) NULL, -- BE tinh: KHONG_NGUY_CO (< 3) | CO_NGUY_CO (>= 3)
	tieu_chi_sut_can bool NULL,
	tieu_chi_bmi_thap bool NULL,
	tieu_chi_teo_co bool NULL,
	tieu_chi_phu_ngoai_vi bool NULL,
	tieu_chi_an_giam bool NULL,
	tieu_chi_benh_ly_tieu_hoa bool NULL,
	chan_doan_sdd varchar(20) NULL, -- BE tinh: KHONG_SDD (ca 6 tieu chi = false) | SDD (>= 1 kieu hinh va >= 1 nguyen nhan)
	ke_hoach_dinh_duong jsonb DEFAULT '[]'::jsonb NOT NULL, -- Mang ma: BO_SUNG_DUONG_MIENG, DD_ONG_THONG, DD_TINH_MACH_BO_SUNG, DD_TINH_MACH_TOAN_PHAN, HOI_CHAN_DINH_DUONG
	hososohoa_id uuid NULL, -- FK csyt_mauhososohoa.hoso_sohoa_id — sinh luc tao phieu
	bi_xoa int2 DEFAULT 0 NOT NULL,
	ngay_tao timestamp NULL,
	nguoi_tao varchar(50) NULL,
	ngay_cap_nhat timestamp NULL,
	nguoi_cap_nhat varchar(50) NULL,
	ngay_xoa timestamp NULL,
	nguoi_xoa varchar(50) NULL,
	CONSTRAINT ck_pdgdd_chan_doan_sdd CHECK (((chan_doan_sdd IS NULL) OR ((chan_doan_sdd)::text = ANY (ARRAY[('KHONG_SDD'::character varying)::text, ('SDD'::character varying)::text])))),
	CONSTRAINT ck_pdgdd_diem_benh_ly CHECK (((diem_muc_do_benh_ly IS NULL) OR ((diem_muc_do_benh_ly >= 1) AND (diem_muc_do_benh_ly <= 3)))),
	CONSTRAINT ck_pdgdd_diem_tinh_trang CHECK (((diem_tinh_trang_dinh_duong IS NULL) OR ((diem_tinh_trang_dinh_duong >= 1) AND (diem_tinh_trang_dinh_duong <= 3)))),
	CONSTRAINT ck_pdgdd_ket_qua CHECK (((ket_qua_sang_loc IS NULL) OR ((ket_qua_sang_loc)::text = ANY (ARRAY[('KHONG_NGUY_CO'::character varying)::text, ('CO_NGUY_CO'::character varying)::text])))),
	CONSTRAINT ck_pdgdd_sut_can_3_thang CHECK (((sut_can_3_thang IS NULL) OR ((sut_can_3_thang)::text = ANY (ARRAY[('KHONG'::character varying)::text, ('CO_KHONG_RO'::character varying)::text, ('CO'::character varying)::text])))),
	CONSTRAINT csyt_phieu_danh_gia_dinh_duong_pkey PRIMARY KEY (id)
);

CREATE TABLE csyt_phieu_nhan_dinh_ban_dau (
	id uuid DEFAULT gen_random_uuid() NOT NULL,
	benh_an_id uuid NOT NULL, -- FK csyt_benh_an_dieu_tri.id
	tiep_nhan_id uuid NULL,
	benh_nhan_id uuid NULL,
	to_dieu_tri_id uuid NULL,
	ma_cskcb varchar(50) NOT NULL,
	so_phieu varchar(50) NULL,
	dieu_duong_id uuid NULL,
	dieu_duong varchar(255) NULL,
	dieu_duong_truong_id uuid NULL,
	dieu_duong_truong varchar(255) NULL,
	thoi_gian_tao_phieu timestamp NULL,
	thoi_gian_nhan_dinh timestamp NULL,
	khoa_id uuid NULL,
	phong_id uuid NULL,
	giuong_id uuid NULL,
	ma_icd_chan_doan varchar(50) NULL,
	icd_ten_chan_doan text NULL,
	ly_do_vao_vien text NULL,
	di_ung int2 NULL,
	co_tien_su_di_ung int2 NULL,
	mo_ta_di_ung text NULL,
	ts_tang_huyet_ap int2 NULL,
	ts_dai_thao_duong int2 NULL,
	ts_hen int2 NULL,
	ts_copd int2 NULL,
	ts_tim_mach int2 NULL,
	ts_khac text NULL,
	hut_thuoc_trang_thai varchar(20) NULL,
	hut_thuoc_bao_nam int4 NULL,
	pn_khoi_bep int2 NULL,
	pn_bui_nghe int2 NULL,
	pn_khac text NULL,
	nguoi_cham_soc_chinh varchar(255) NULL,
	quan_he varchar(100) NULL,
	dien_thoai varchar(20) NULL,
	nhan_dinh_co_quan text NULL,
	news2_diem int4 NULL,
	news2_muc varchar(20) NULL,
	morse_diem int4 NULL,
	morse_muc varchar(20) NULL,
	braden_diem int4 NULL,
	braden_muc varchar(20) NULL,
	dau_nrs_diem int4 NULL,
	dau_nrs_muc varchar(20) NULL,
	dd03_nguy_co varchar(20) NULL,
	phan_cap_cham_soc varchar(50) NULL,
	van_de_uu_tien text NULL,
	hososohoa_id uuid NULL,
	bi_xoa int2 DEFAULT 0 NOT NULL,
	ngay_tao timestamp NULL,
	nguoi_tao varchar(50) NULL,
	ngay_cap_nhat timestamp NULL,
	nguoi_cap_nhat varchar(50) NULL,
	ngay_xoa timestamp NULL,
	spo2_che_do_tho varchar(20) NULL,
	spo2_luu_luong_oxy numeric(5, 1) NULL,
	spo2 numeric(5, 1) NULL,
	nguoi_xoa varchar(50) NULL,
	CONSTRAINT csyt_phieu_nhan_dinh_ban_dau_pkey PRIMARY KEY (id)
);

CREATE TABLE csyt_phieu_ra_vien (
	id uuid DEFAULT gen_random_uuid() NOT NULL,
	ma_cskcb varchar(50) NOT NULL,
	tiep_nhan_id uuid NOT NULL,
	benh_nhan_id uuid NOT NULL,
	icd_chan_doan varchar(50) NULL,
	ten_chan_doan varchar(500) NULL,
	khoa_ra_vien_id uuid NULL,
	thoi_gian_vao_vien timestamp NULL,
	thoi_gian_ra_vien timestamp NULL,
	phuong_phap_dieu_tri text NULL,
	ghi_chu text NULL,
	bi_xoa int2 DEFAULT 0 NOT NULL,
	ngay_tao timestamp NULL,
	nguoi_tao varchar(50) NULL,
	ngay_cap_nhat timestamp NULL,
	nguoi_cap_nhat varchar(50) NULL,
	ngay_xoa timestamp NULL,
	nguoi_xoa varchar(50) NULL,
	benh_an_id uuid NULL,
	giayto_goc_id uuid NULL, -- FK sang bản gốc trong cùng bảng (bản cấp lại tham chiếu bản gốc). NULL = bản gốc.
	so_lan_caplai int4 NULL, -- Số lần cấp lại (bản gốc = NULL, bản cấp lại đầu tiên = 1).
	lydo_caplai varchar(500) NULL, -- Lý do cấp lại (bắt buộc khi cấp lại).
	nguoi_caplai varchar(255) NULL, -- Username người thực hiện cấp lại.
	thoigian_caplai timestamp NULL, -- Thời điểm cấp lại.
	so_phieu_ra_vien varchar(50) NULL,
	hososohoa_id uuid NULL,
	CONSTRAINT csyt_phieu_ra_vien_pkey PRIMARY KEY (id)
);

CREATE TABLE csyt_phieu_so_ket_dieu_tri (
	id uuid DEFAULT gen_random_uuid() NOT NULL,
	benh_an_id uuid NULL,
	ma_cskcb varchar(50) NOT NULL,
	so_phieu_so_ket varchar(50) NULL,
	thoi_gian_lap timestamp NULL,
	nguoi_lap_id uuid NULL,
	thoi_gian_vao_vien timestamp NULL,
	khoa_id uuid NULL,
	phong_id uuid NULL,
	giuong_id uuid NULL,
	ma_benh_chinh varchar(20) NULL,
	ten_chan_doan_benh_chinh varchar(500) NULL,
	dieu_tri_tu_ngay timestamp NULL,
	dieu_tri_den_ngay timestamp NULL,
	dien_bien_lam_sang text NULL,
	tom_tat_ket_qua_xet_nghiem_cls text NULL,
	qua_trinh_dieu_tri text NULL,
	danh_gia_ket_qua text NULL,
	huong_dieu_tri_tiep_va_tien_luong text NULL,
	bi_xoa int2 DEFAULT 0 NOT NULL,
	ngay_tao timestamp NULL,
	nguoi_tao varchar(50) NULL,
	ngay_cap_nhat timestamp NULL,
	nguoi_cap_nhat varchar(50) NULL,
	ngay_xoa timestamp NULL,
	nguoi_xoa varchar(50) NULL,
	hososohoa_id uuid NULL,
	tiep_nhan_id uuid NULL,
	truong_khoa_id uuid NULL,
	bac_si_dieu_tri_id uuid NULL,
	CONSTRAINT csyt_phieu_so_ket_dieu_tri_pkey PRIMARY KEY (id)
);

CREATE TABLE csyt_phieu_truyen_dich (
	id uuid DEFAULT gen_random_uuid() NOT NULL,
	ma_cskcb varchar(50) NOT NULL,
	tiep_nhan_id uuid NOT NULL,
	benh_nhan_id uuid NOT NULL,
	icd_chan_doan_id uuid NULL,
	chan_doan varchar(500) NULL,
	ma_bac_si_chi_dinh varchar(50) NULL,
	bac_si_chi_dinh_id uuid NULL,
	ngay_chi_dinh timestamp NULL,
	so_lan_truyen int4 NULL, -- So lan truyen — sinh ra cac dong trong csyt_phieu_truyen_dich_lan
	trang_thai varchar(50) NULL, -- CHO_THUC_HIEN / DA_THUC_HIEN / HUY
	ghi_chu text NULL,
	bi_xoa int2 DEFAULT 0 NOT NULL,
	ngay_tao timestamp NULL,
	nguoi_tao varchar(50) NULL,
	ngay_cap_nhat timestamp NULL,
	nguoi_cap_nhat varchar(50) NULL,
	ngay_xoa timestamp NULL,
	nguoi_xoa varchar(50) NULL,
	to_dieu_tri_id uuid NULL,
	khoa_tao_phieu_id uuid NULL,
	phong_id uuid NULL,
	giuong_id uuid NULL,
	so_phieu_truyen_dich varchar(50) NULL,
	hososohoa_id uuid NULL,
	bac_si_dieu_tri_id uuid NULL,
	dieu_duong_id uuid NULL,
	kham_benh_id uuid NULL,
	CONSTRAINT csyt_phieu_truyen_dich_pkey PRIMARY KEY (id)
);

CREATE TABLE csyt_phieu_truyen_dich_lan (
	id uuid DEFAULT gen_random_uuid() NOT NULL,
	ma_cskcb varchar(50) NOT NULL,
	phieu_truyen_dich_id uuid NOT NULL,
	stt int4 NULL,
	thuoc jsonb NULL, -- Mang JSON thuoc/dich (tham chieu DMC_THUOC_VAT_TU) — shape do FE dinh nghia
	duong_dung varchar(100) NULL,
	cach_dung text NULL,
	thoi_gian_bat_dau timestamp NULL,
	thoi_gian_ket_thuc timestamp NULL,
	toc_do numeric(10, 2) NULL, -- Toc do truyen (giot/phut)
	toc_do_theo varchar(50) NULL,
	luong_truyen numeric(12, 2) NULL,
	don_vi varchar(50) NULL,
	so_gio numeric(6, 2) NULL, -- So gio truyen
	ma_dieu_duong varchar(50) NULL,
	dieu_duong_id uuid NULL,
	ghi_chu text NULL,
	bi_xoa int2 DEFAULT 0 NOT NULL,
	ngay_tao timestamp NULL,
	nguoi_tao varchar(50) NULL,
	ngay_cap_nhat timestamp NULL,
	nguoi_cap_nhat varchar(50) NULL,
	ngay_xoa timestamp NULL,
	nguoi_xoa varchar(50) NULL,
	bac_si_chi_dinh_id uuid NULL,
	lan_truyen_thu int4 NULL,
	ma_bac_si_chi_dinh varchar(50) NULL,
	ngay_chi_dinh timestamp NULL,
	CONSTRAINT csyt_phieu_truyen_dich_lan_pkey PRIMARY KEY (id)
);

CREATE TABLE csyt_phieu_truyen_mau (
	id uuid DEFAULT gen_random_uuid() NOT NULL,
	ma_cskcb varchar(50) NOT NULL,
	tiep_nhan_id uuid NOT NULL,
	benh_nhan_id uuid NOT NULL,
	icd_chan_doan_id uuid NULL,
	chan_doan varchar(500) NULL,
	ma_bac_si_chi_dinh varchar(50) NULL,
	bac_si_chi_dinh_id uuid NULL,
	ngay_chi_dinh timestamp NULL,
	to_dieu_tri_id uuid NULL, -- FK kb_kham_benh.id (to dieu tri lien quan)
	khoa_tao_phieu_id uuid NULL, -- FK dm_khoa.id — snapshot khoa luc tao phieu (BN co the chuyen khoa sau)
	phong_id uuid NULL,
	giuong_id uuid NULL,
	so_lan_truyen int4 NULL, -- So lan truyen — sinh ra cac dong trong csyt_phieu_truyen_mau_lan
	trang_thai varchar(50) NULL, -- CHO_THUC_HIEN / DA_THUC_HIEN / HUY
	ghi_chu text NULL,
	bi_xoa int2 DEFAULT 0 NOT NULL,
	ngay_tao timestamp NULL,
	nguoi_tao varchar(50) NULL,
	ngay_cap_nhat timestamp NULL,
	nguoi_cap_nhat varchar(50) NULL,
	ngay_xoa timestamp NULL,
	nguoi_xoa varchar(50) NULL,
	so_phieu_truyen_mau varchar(50) NULL, -- Số phiếu truyền máu
	nguoi_benh_nhom_abo varchar(10) NULL, -- Nhóm máu ABO của người bệnh
	nguoi_benh_rh varchar(10) NULL, -- Rh của người bệnh
	ten_che_pham varchar(255) NULL, -- Tên chế phẩm máu
	so_luong int4 NULL, -- Số lượng chế phẩm
	don_vi_che_pham varchar(50) NULL, -- Đơn vị (ML)
	ma_so_don_vi_che_pham_mau_truyen varchar(100) NULL, -- Mã số đơn vị chế phẩm máu truyền
	ngay_lay_mau_dieu_che timestamp NULL, -- Ngày lấy máu/điều chế
	han_dung timestamp NULL, -- Hạn dùng chế phẩm
	che_pham_mau_nhom_abo varchar(10) NULL, -- Nhóm ABO của chế phẩm máu
	che_pham_mau_rh varchar(10) NULL, -- Rh của chế phẩm máu
	cac_xet_nghiem_khac jsonb NULL, -- JSON array các xét nghiệm khác [{id, ten}, ...]
	ket_qua_ong1_moi_truong_muoi varchar(255) NULL, -- Kết quả Ống 1 - Môi trường muối
	ket_qua_ong1_khang_globulin varchar(255) NULL, -- Kết quả Ống 1 - 37°C/Kháng Globulin
	ket_qua_ong2_moi_truong_muoi varchar(255) NULL, -- Kết quả Ống 2 - Môi trường muối
	ket_qua_ong2_khang_globulin varchar(255) NULL, -- Kết quả Ống 2 - 37°C/Kháng Globulin
	lan_truyen_mau_thu int4 NULL, -- Lần truyền máu thứ
	dinh_nhom_don_vi_mau_che_pham varchar(50) NULL, -- Định nhóm đơn vị máu/chế phẩm
	dinh_nhom_nguoi_nhan varchar(50) NULL, -- Định nhóm người nhận
	phan_ung_cheo_tai_giuong varchar(255) NULL, -- Phản ứng chéo tại giường
	bat_dau_truyen_hoi timestamp NULL, -- Thời gian bắt đầu truyền hồi
	ngung_truyen_hoi timestamp NULL, -- Thời gian ngừng truyền hồi
	so_luong_mau_thuc_te_da_truyen varchar(100) NULL, -- Số lượng máu thực tế đã truyền
	nhan_xet_qua_trinh text NULL, -- Nhận xét quá trình truyền máu
	che_pham_mau_id int4 NULL, -- FK dm_che_pham_mau.id — Chế phẩm máu
	hososohoa_id uuid NULL,
	bac_si_dieu_tri_id uuid NULL,
	dieu_duong_id uuid NULL,
	CONSTRAINT csyt_phieu_truyen_mau_pkey PRIMARY KEY (id)
);

CREATE TABLE csyt_phieu_truyen_mau_theo_doi (
	id uuid DEFAULT gen_random_uuid() NOT NULL,
	ma_cskcb varchar(50) NOT NULL,
	phieu_truyen_mau_id uuid NOT NULL,
	stt int4 NULL, -- Số thứ tự dòng theo dõi
	thoi_gian timestamp NULL, -- Thời gian theo dõi
	toc_do_truyen numeric(10, 2) NULL, -- Tốc độ truyền (giọt/phút)
	mau_sac_da_niem_mac varchar(255) NULL, -- Màu sắc da, niêm mạc
	nhip_tho int4 NULL, -- Nhịp thở (lần/phút)
	mach int4 NULL, -- Mạch (lần/phút)
	huyet_ap varchar(50) NULL, -- Huyết áp (mmHg)
	than_nhiet numeric(4, 1) NULL, -- Thân nhiệt (°C)
	dien_bien_khac text NULL, -- Những diễn biến khác
	bi_xoa int2 DEFAULT 0 NOT NULL,
	ngay_tao timestamp NULL,
	nguoi_tao varchar(50) NULL,
	ngay_cap_nhat timestamp NULL,
	nguoi_cap_nhat varchar(50) NULL,
	ngay_xoa timestamp NULL,
	nguoi_xoa varchar(50) NULL,
	CONSTRAINT csyt_phieu_truyen_mau_theo_doi_pkey PRIMARY KEY (id)
);

CREATE TABLE csyt_phieu_tu_van_gdsk (
	id uuid DEFAULT gen_random_uuid() NOT NULL,
	ma_cskcb varchar(50) NOT NULL,
	benh_an_id uuid NOT NULL,
	benh_nhan_id uuid NULL,
	tiep_nhan_id uuid NULL,
	to_dieu_tri_id uuid NULL,
	khoa_id uuid NULL,
	phong_id uuid NULL,
	giuong_id uuid NULL,
	so_phieu varchar(50) NULL,
	chan_doan text NULL,
	icd_chan_doan varchar(50) NULL,
	di_ung varchar(50) NULL,
	di_ung_chi_tiet text NULL,
	nguoi_tu_van_id uuid NULL,
	ho_khac_dom_ap_dung int2 NULL,
	ho_khac_dom_thoi_gian timestamp NULL,
	ho_khac_dom_doi_tuong varchar(50) NULL,
	ho_khac_dom_hinh_thuc varchar(50) NULL,
	ho_khac_dom_tiep_thu varchar(50) NULL,
	dinh_duong_ap_dung int2 NULL,
	dinh_duong_thoi_gian timestamp NULL,
	dinh_duong_doi_tuong varchar(50) NULL,
	dinh_duong_hinh_thuc varchar(50) NULL,
	dinh_duong_tiep_thu varchar(50) NULL,
	dung_thuoc_ap_dung int2 NULL,
	dung_thuoc_thoi_gian timestamp NULL,
	dung_thuoc_doi_tuong varchar(50) NULL,
	dung_thuoc_hinh_thuc varchar(50) NULL,
	dung_thuoc_tiep_thu varchar(50) NULL,
	tranh_khoi_bui_ap_dung int2 NULL,
	tranh_khoi_bui_thoi_gian timestamp NULL,
	tranh_khoi_bui_doi_tuong varchar(50) NULL,
	tranh_khoi_bui_hinh_thuc varchar(50) NULL,
	tranh_khoi_bui_tiep_thu varchar(50) NULL,
	tiem_phong_ap_dung int2 NULL,
	tiem_phong_thoi_gian timestamp NULL,
	tiem_phong_doi_tuong varchar(50) NULL,
	tiem_phong_hinh_thuc varchar(50) NULL,
	tiem_phong_tiep_thu varchar(50) NULL,
	kham_lai_ap_dung int2 NULL,
	kham_lai_thoi_gian timestamp NULL,
	kham_lai_doi_tuong varchar(50) NULL,
	kham_lai_hinh_thuc varchar(50) NULL,
	kham_lai_tiep_thu varchar(50) NULL,
	ban_giao_cas jsonb NULL,
	ra_vien_tinh int2 NULL,
	ra_vien_het_sot int2 NULL,
	ra_vien_giam_ho int2 NULL,
	sp_o2 float8 NULL,
	ra_vien_khac text NULL,
	van_de_dieu_duong varchar(50) NULL,
	van_de_dieu_duong_con text NULL,
	duong_truyen varchar(50) NULL,
	duong_truyen_khac text NULL,
	huong_dan_tu_van int2 NULL,
	huong_dan_phat_to int2 NULL,
	huong_dan_hen_tai_kham int2 NULL,
	hososohoa_id uuid NULL,
	bi_xoa int2 DEFAULT 0 NOT NULL,
	ngay_tao timestamp NULL,
	nguoi_tao varchar(50) NULL,
	ngay_cap_nhat timestamp NULL,
	nguoi_cap_nhat varchar(50) NULL,
	ngay_xoa timestamp NULL,
	nguoi_xoa varchar(50) NULL,
	CONSTRAINT csyt_phieu_tu_van_gdsk_pkey PRIMARY KEY (id)
);

CREATE TABLE csyt_sohoa_phieuin_baocao (
	sohoa_phieuin_baocao_id uuid DEFAULT gen_random_uuid() NOT NULL, -- ID phiếu số hóa (PK)
	ma_phieu varchar(100) NULL, -- Mã phiếu
	report_code varchar(100) NULL, -- Mã report
	hreport varchar(255) NULL, -- Mã HReport (template in)
	khoalap_id uuid NULL, -- ID khoa lập phiếu
	phonglap_id uuid NULL, -- ID phòng lập phiếu
	kholap_id uuid NULL, -- ID kho lập phiếu
	khoanhan_id uuid NULL, -- ID khoa nhận
	phongnhan_id uuid NULL, -- ID phòng nhận
	khonhan_id uuid NULL, -- ID kho nhận
	ky_bao_cao varchar(100) NULL, -- Kỳ báo cáo (tháng/quý/năm)
	ngay_lap timestamptz NULL, -- Ngày lập phiếu
	thoi_gian_lap_tu timestamptz NULL, -- Thời gian lập từ (khoảng thời gian báo cáo)
	thoi_gian_lap_den timestamptz NULL, -- Thời gian lập đến (khoảng thời gian báo cáo)
	loai_phieu int2 NULL, -- Loại phiếu: 04 = Báo cáo, 05 = Dược (lấy từ danh mục pl_bao_cao)
	ma_loai_phieu uuid NULL, -- Mã loại phiếu (FK)
	so_phieu_chung varchar(100) NULL, -- Số phiếu chung
	phuong_thuc_ky varchar(50) NULL, -- Phương thức ký (USB Token, SmartCA, ...)
	nguoiky_id int4 NULL, -- ID người ký
	thogian_kyso timestamptz NULL, -- Thời gian ký số
	trangthai_kyso int4 DEFAULT 0 NULL, -- Trạng thái ký số (0: Chưa ký, 1: Đã ký, 2: Đã hủy)
	url varchar(1000) NULL, -- Đường dẫn file đã ký
	nguoihuyky_id uuid NULL, -- ID người hủy ký
	thoigianhuy timestamptz NULL, -- Thời gian hủy ký
	loaihuyky varchar(50) NULL, -- Loại hủy ký
	lydohuy varchar(500) NULL, -- Lý do hủy ký
	nguoitao_id uuid NULL, -- ID người tạo bản ghi
	ngaytao timestamptz DEFAULT now() NULL, -- Ngày tạo bản ghi
	nguoihuy_id uuid NULL, -- ID người hủy bản ghi (soft delete)
	ngayhuy timestamptz NULL, -- Ngày hủy bản ghi (soft delete)
	da_xoa int4 DEFAULT 0 NULL,
	chung_tu_id varchar NULL,
	ma_lan_chi_dinh varchar(50) NULL,
	sign_auth varchar(255) NULL,
	rpt_type varchar(255) NULL,
	params varchar NULL,
	CONSTRAINT csyt_sohoa_phieuin_baocao_pkey PRIMARY KEY (sohoa_phieuin_baocao_id)
);

CREATE TABLE csyt_vien_phi (
	id uuid DEFAULT gen_random_uuid() NOT NULL, -- Key
	benh_nhan_id uuid NOT NULL, -- Bệnh nhân ID
	tiep_nhan_id uuid NOT NULL, -- Tiếp nhận ID
	benh_an_id uuid NULL, -- Bệnh án ID
	dot_dieu_tri_id uuid NULL, -- Đợt điều trị ID
	kham_benh_id uuid NULL, -- Khám bệnh ID
	ref_id uuid NOT NULL, -- ID các bảng: Dịch vụ, thuốc, phẫu thuật, cận lâm sàng, chứng từ dược ....
	ref_table varchar(100) NOT NULL, -- Tên bảng Dịch vụ, thuốc, phẫu thuật, cận lâm sàng, chứng từ dược ....
	dich_vu_id uuid NULL, -- Dịch vụ ID
	thuoc_vat_tu_id uuid NULL, -- Thuốc vật tư ID
	so_lo_nhap_id uuid NULL, -- Số lô nhập ID
	loai_chi_phi varchar(100) NULL, -- Loại chi phí: TT, STENT2, STENT3, STENT4 . .. 
	so_luong numeric NULL, -- Số lượng
	don_gia_benh_vien numeric NULL, -- Đơn giá bệnh viện
	thanh_tien_benh_vien numeric NULL, -- Thành tiền bệnh viện
	muc_huong numeric NULL, -- Mức hưởng
	don_gia_bhyt numeric NULL, -- Đơn giá Bảo hiểm y tế
	thanh_tien_bhyt numeric NULL, -- Thành tiền BHYT
	tyle_thanh_toan_dv numeric NULL, -- Tỷ lệ thanh toán dịch vụ
	tyle_thanh_toan_bh numeric NULL, -- Tyle_ThanhToan_BH
	tran_thanhtoan numeric NULL, -- Mức trần thanh toán
	vuot_tran int2 NULL, -- Vượt trần
	don_gia_bhyt_thanh_toan numeric DEFAULT 0 NULL, -- Đơn giá BHYT hỗ trợ thanh toán
	thanh_tien_bhyt_thanh_toan numeric DEFAULT 0 NULL, -- Thành tiền BHYT hỗ trợ thanh toán
	don_gia_benh_nhan_cung_chi_tra numeric DEFAULT 0 NULL, -- Đơn giá bệnh nhân cùng chi trả
	thanh_tien_benh_nhan_cung_chi_tra numeric DEFAULT 0 NULL, -- Thành tiền bệnh nhân cùng chi trả
	don_gia_benh_nhan_tu_thanh_toan numeric DEFAULT 0 NULL, -- Đơn giá bệnh nhân tự thanh toán
	thanh_tien_benh_nhan_tu_thanh_toan numeric DEFAULT 0 NULL, -- Thành tiền bệnh nhân tự thanh toán
	benh_nhan_thanh_toan numeric DEFAULT 0 NULL, -- Tổng giá trị bệnh nhân thanh toán
	benh_nhan_da_thanh_toan numeric DEFAULT 0 NULL, -- Bệnh nhân đã thanh toán
	benh_nhan_con_phai_thanh_toan numeric DEFAULT 0 NULL, -- Bệnh nhân còn phải thanh toán
	mien_giam_ty_le numeric DEFAULT 0 NULL, -- Tỷ lệ miễn giảm
	gia_tri_mien_giam numeric DEFAULT 0 NULL, -- Giá trị miễn giảm
	thanh_tien_mien_giam numeric DEFAULT 0 NULL, -- Thành tiền miễn giảm
	duoc_phep_thuc_hien int2 DEFAULT 0 NULL, -- Được phép thực hiện
	huy int2 DEFAULT 0 NULL, -- Trạng thái hủy
	da_thanh_toan_mot_phan int2 DEFAULT 0 NOT NULL, -- Đã thanh toán 1 phần
	da_thanh_toan_hoan_tat int2 DEFAULT 0 NOT NULL, -- Đã thanh toán hoàn tất
	da_thuc_hien int2 DEFAULT 0 NULL, -- Đã thực hiện
	khong_thu_tien int2 DEFAULT 0 NULL, -- Không thu tiền
	thu_tien_sau int2 DEFAULT 0 NULL, -- Thu tiền sau
	bhyt_tu_dong_tien int2 DEFAULT 0 NULL, -- BHYT tự đóng tiền
	vien_phi_chung_tu_id uuid NULL, -- ID chứng từ thu tiền
	loai_chung_tu varchar(100) NULL, -- Loại chứng từ thu: Tạm ứng, Thanh toán. . .
	ma_doi_tuong varchar NULL, -- Mã Đối tượng
	bhyt_dot_dieu_tri_id uuid NULL, -- BHYT đợt điều trị ID
	don_gia_benh_vien_ban_dau numeric DEFAULT 0 NULL, -- Đơn giá bệnh viện ban đầu
	don_gia_bhyt_ban_dau numeric DEFAULT 0 NULL, -- Đơn giá BHYT ban đầu
	ma_phong_ban_thuc_hien varchar NULL, -- Mã phòng ban thực hiện
	ma_phong_ban_chi_dinh varchar NULL, -- Mã phòng ban chỉ định
	hieu_luc int2 DEFAULT 1 NULL, -- Hiệu lực
	bi_xoa int2 DEFAULT 0 NULL, -- Bị xóa(0: Không; 1: Có )
	ngay_xoa timestamp NULL, -- Ngày xóa
	nguoi_xoa varchar(100) NULL, -- Người xóa
	ngay_tao timestamp DEFAULT now() NOT NULL, -- Ngày tạo dữ liệu
	nguoi_tao varchar(100) NOT NULL, -- Người tạo dữ liệu
	ngay_cap_nhat timestamp NULL, -- Ngày sửa dữ liệu
	nguoi_cap_nhat varchar(100) NULL, -- Người sửa dữ liệu
	ma_loai_gia varchar NULL,
	ma_cskcb varchar(255) NULL,
	phong_thuc_hien_id uuid NULL,
	phong_chi_dinh_id uuid NULL,
	gia_tt_id uuid NOT NULL,
	is_ksk int2 DEFAULT 0 NULL,
	is_goi_dv int2 DEFAULT 0 NULL,
	is_pt50 int2 DEFAULT 0 NULL,
	is_pt80 int2 DEFAULT 0 NULL,
	is_ghep02 int2 DEFAULT 0 NULL,
	is_ghep03 int2 DEFAULT 0 NULL,
	khan int2 DEFAULT 0 NULL,
	doi_tuong_id uuid NULL,
	nguon_ct uuid NULL,
	don_vi_chi_tra varchar(255) NULL,
	ma_nhom_bhyt_id uuid NULL,
	nhom_hdvp_id uuid NULL,
	loai_chung_tu_id uuid NULL,
	tyle_thanh_toan_id uuid NULL,
	ngt_dot_dieu_tri_id uuid NULL,
	loai_ke_don_id uuid NULL,
	loai_y_lenh_id uuid NULL,
	ylthuocvt_id uuid NULL,
	dauthauid uuid NULL,
	dauthauctid uuid NULL,
	is_chuyen int2 DEFAULT 0 NULL,
	nguoi_chuyen varchar(255) NULL,
	thoi_gian_chuyen timestamptz DEFAULT now() NULL,
	hososohoa_id uuid NULL,
	CONSTRAINT csyt_vien_phi_pkey PRIMARY KEY (id)
);

CREATE TABLE csyt_vien_phi_chung_tu (
	so_thu_id uuid NOT NULL,
	ma_phieu_thu varchar NOT NULL,
	tiep_nhan_id uuid NOT NULL,
	benh_an_id uuid NULL,
	dot_dieu_tri_id uuid NOT NULL,
	nguoi_lap_id uuid NOT NULL,
	noi_lap_id uuid NOT NULL,
	ngay_lap timestamp NOT NULL,
	nguoi_thu_id uuid NOT NULL,
	ngay_thu timestamp NOT NULL,
	noi_thu_id uuid NOT NULL,
	hoan_huy_chung_tu_id uuid NULL,
	ngay_huy timestamp NULL,
	nguoi_huy_id uuid NULL,
	tong_tien numeric DEFAULT 0 NOT NULL,
	loai_chung_tu_id uuid NOT NULL, -- Phiếu thu, tạm ứng, hoàn ứng, phiếu chi, phiếu thanh toán
	da_thanh_toan int4 DEFAULT 0 NOT NULL, -- 0: Chưa thanh toán; 1:Đã thanh toán
	huy_hoa_don int4 DEFAULT 0 NOT NULL, -- 0: Chưa hủy; 1: Đã hủy
	hoan_tra int4 DEFAULT 0 NOT NULL, -- 0: Không hoàn trả; 1: Đã hoàn trả
	doi_tuong_benh_nhan_id uuid NOT NULL,
	ty_le_mien_giam numeric NULL,
	tong_tien_mien_giam numeric NULL,
	id uuid DEFAULT gen_random_uuid() NOT NULL, -- Key của bảng
	ngay_tao timestamp DEFAULT now() NOT NULL, -- Ngày tạo
	nguoi_tao varchar DEFAULT 'system'::character varying NOT NULL, -- Người tạo
	ngay_cap_nhat timestamp DEFAULT now() NOT NULL, -- Ngày cập nhật
	nguoi_cap_nhat varchar DEFAULT 'system'::character varying NOT NULL, -- Người cập nhật
	bi_xoa int2 DEFAULT 0 NULL, -- Bị xóa mềm
	ngay_xoa timestamp NULL, -- Ngày xóa mềm
	nguoi_xoa varchar NULL, -- Người xóa mềm
	nguoi_gui_huy_id uuid NULL, -- Người gửi/hủy chứng từ
	ngay_gui_duyet_huy timestamp NULL, -- Ngày gửi duyệt hủy
	nguoi_duyet_huy_id uuid NULL,
	ngay_duyet_huy timestamp NULL, -- Ngày duyệt hủy chứng từ
	la_chuyen_ngoai_tru_vao_noi_tru int4 NULL, -- 0: Không; 1: Có
	la_thuoc_nha_thuoc int4 NULL, -- 0: Không; 1: Có
	ly_do_huy_id uuid NULL,
	dien_giai_huy varchar(255) NULL, -- Diễn giải hủy
	ghi_chu varchar(500) NULL,
	so_quyet_dinh varchar(50) NULL, -- Số quyết định
	ca_lam_viec_id uuid NULL, -- Id ca làm việc
	nguoi_ky_id uuid NULL, -- Id người ký
	ma_phieu_thu_lien_quan varchar(255) NULL, -- Mã phiếu thu liên quan
	csyt_vien_phi_chung_tu_lien_quan_id uuid NULL, -- Chứng từ liên quan ID
	so_phieu_thu varchar(255) NULL, -- Số phiếu thu
	trang_thai varchar(25) NULL, -- CHUA_THANH_TOAN,DA_THANH_TOAN,DA_HUY_THANH_TOAN,HOAN_THANH_TOAN
	ma_cskcb varchar(25) NULL, -- Mã cơ sở khám chữa bệnh
	thanh_tien_nhan numeric NULL, -- Thành tiền nhận
	thanh_tien_thua numeric NULL, -- Thành tiền thừa
	noi_huy_id uuid NULL, -- ID nơi hủy
	chung_tu_thanh_toan_id uuid NULL, -- Chứng từ thanh toán id
	CONSTRAINT csyt_vien_phi_chung_tu_pkey PRIMARY KEY (id),
	CONSTRAINT csyt_vien_phi_chung_tu_so_phieu_thu_key UNIQUE (so_phieu_thu)
);

CREATE TABLE csyt_vien_phi_chung_tu_chi_tiet (
	csyt_vien_phi_chung_tu_id uuid NOT NULL, -- Viện phí chứng từ ID
	csyt_vien_phi_id uuid NOT NULL, -- CSYT Viện phí ID
	ref_id uuid NOT NULL, -- Y lệnh dịch vụ ID
	ref_table varchar NOT NULL, -- Tên bảng lưu ID: Dịch vụ, thuốc vật tư
	dich_vu_id uuid NULL, -- Id dịch vụ
	thuoc_vat_tu_id uuid NULL, -- Id thuốc vật tư
	so_lo_nhap_id uuid NULL, -- Id số lô nhập
	loai_chi_phi varchar NULL, -- Loại chi phí: TT, STENT2, STENT3, STENT4 . ..
	gia_tt_id uuid NOT NULL,
	so_luong numeric DEFAULT 0 NOT NULL, -- Số lượng
	don_gia_benh_vien numeric DEFAULT 0 NOT NULL, -- Đơn giá bệnh viện
	thanh_tien_benh_vien numeric DEFAULT 0 NOT NULL, -- Thành tiền bệnh viện
	muc_huong numeric DEFAULT 0 NOT NULL, -- Mức hưởng
	don_gia_bhyt numeric DEFAULT 0 NOT NULL, -- Đơn giá bảo hiểm y tế
	thanh_tien_bhyt numeric DEFAULT 0 NOT NULL, -- Thành tiền BHYT
	ty_le_thanh_toan_dich_vu numeric DEFAULT 0 NOT NULL, -- Tỷ lệ thanh toán dịch vụ
	ty_le_thanh_toan_bhyt numeric DEFAULT 0 NOT NULL, -- Tỷ lệ thanh toán BHYT
	tran_thanh_toan numeric DEFAULT 0 NOT NULL, -- Mức trần thanh toán
	vuot_tran int4 DEFAULT 0 NOT NULL, -- 0: Không; 1: Vượt trần
	don_gia_bhyt_thanh_toan numeric DEFAULT 0 NOT NULL, -- Đơn giá BHYT hỗ trợ thanh toán
	thanh_tien_bhyt_thanh_toan numeric DEFAULT 0 NOT NULL, -- Thành tiền BHYT hỗ trợ thanh toán
	don_gia_benh_nhan_cung_chi_tra numeric DEFAULT 0 NOT NULL, -- Đơn giá bệnh nhân cùng chi trả
	thanh_tien_benh_nhan_cung_chi_tra numeric DEFAULT 0 NOT NULL, -- Thành tiền bệnh nhân cùng chi trả
	don_gia_benh_nhan_tu_thanh_toan numeric DEFAULT 0 NOT NULL, -- Đơn giá bệnh nhân tự thanh toán
	thanh_tien_benh_nhan_tu_thanh_toan numeric DEFAULT 0 NOT NULL, -- Thành tiền bệnh nhân tự thanh toán
	doi_tuong_id uuid NOT NULL, -- Id đối tượng
	dot_dieu_tri_id uuid NULL, -- Id đợt điều trị
	nguon_chi_tra_id uuid NULL, -- Nguồn chi trả
	don_vi_chi_tra varchar NULL, -- Đơn vị chi trả
	ma_nhom_bhyt_id uuid NULL, -- Mã nhóm BHYT 5937
	nhom_hoa_don_vien_phi_id uuid NULL, -- Nhóm hóa đơn viện phí
	noi_thuc_hien_id uuid NULL, -- Id phòng thực hiện
	noi_chi_dinh_id uuid NULL, -- Id nơi chỉ định
	ty_le_mien_giam numeric DEFAULT 0 NOT NULL, -- Tỷ lệ miễn giảm
	gia_tri_mien_giam numeric DEFAULT 0 NOT NULL, -- Giá trị miễn giảm
	thanh_tien_mien_giam numeric DEFAULT 0 NOT NULL, -- Thành tiền miễn giảm
	gia_tri_hoa_don numeric DEFAULT 0 NULL, -- Giá trị hóa đơn
	loai_y_lenh_id uuid NULL, -- Id loại y lệnh
	id uuid DEFAULT gen_random_uuid() NOT NULL, -- Key của bảng
	ngay_tao timestamp DEFAULT now() NOT NULL, -- Ngày tạo
	nguoi_tao varchar DEFAULT 'system'::character varying NOT NULL, -- Người tạo
	ngay_cap_nhat timestamp DEFAULT now() NOT NULL, -- Ngày cập nhật
	nguoi_cap_nhat varchar DEFAULT 'system'::character varying NOT NULL, -- Người cập nhật
	bi_xoa int2 DEFAULT 0 NULL, -- Bị xóa mềm
	ngay_xoa timestamp NULL, -- Ngày xóa mềm
	nguoi_xoa varchar NULL, -- Người xóa mềm
	CONSTRAINT csyt_vien_phi_chung_tu_chi_tiet_pkey PRIMARY KEY (id)
);

CREATE TABLE csyt_vien_phi_chung_tu_mapping (
	csyt_vien_phi_id uuid NOT NULL, -- ID lấy từ bảng csyt_vien_phi
	csyt_vien_phi_chung_tu_id uuid NOT NULL, -- ID lấy từ bảng csyt_vien_phi_chung_tu
	id uuid DEFAULT gen_random_uuid() NOT NULL, -- Key của bảng
	ngay_tao timestamp DEFAULT now() NOT NULL, -- Ngày tạo
	nguoi_tao varchar DEFAULT 'system'::character varying NOT NULL, -- Người tạo
	ngay_cap_nhat timestamp DEFAULT now() NOT NULL, -- Ngày cập nhật
	nguoi_cap_nhat varchar DEFAULT 'system'::character varying NOT NULL, -- Người cập nhật
	bi_xoa int2 DEFAULT 0 NULL, -- Bị xóa mềm
	ngay_xoa timestamp NULL, -- Ngày xóa mềm
	nguoi_xoa varchar NULL, -- Người xóa mềm
	CONSTRAINT csyt_vien_phi_chung_tu_mapping_pkey PRIMARY KEY (id)
);

CREATE TABLE csyt_vien_phi_log (
	id uuid DEFAULT gen_random_uuid() NOT NULL,
	benh_nhan_id uuid NULL,
	tiep_nhan_id uuid NULL,
	benh_an_id uuid NULL,
	dot_dieu_tri_id uuid NULL,
	kham_benh_id uuid NULL,
	ref_id uuid NULL,
	ref_table varchar(100) NULL,
	dich_vu_id uuid NULL,
	thuoc_vat_tu_id uuid NULL,
	so_lo_nhap_id uuid NULL,
	loai_chi_phi varchar(100) NULL,
	so_luong numeric NULL,
	don_gia_benh_vien numeric NULL,
	thanh_tien_benh_vien numeric NULL,
	muc_huong numeric NULL,
	don_gia_bhyt numeric NULL,
	thanh_tien_bhyt numeric NULL,
	tyle_thanh_toan_dv numeric NULL,
	tyle_thanh_toan_bh numeric NULL,
	tran_thanhtoan numeric NULL,
	vuot_tran int2 NULL,
	don_gia_bhyt_thanh_toan numeric NULL,
	thanh_tien_bhyt_thanh_toan numeric NULL,
	don_gia_benh_nhan_cung_chi_tra numeric NULL,
	thanh_tien_benh_nhan_cung_chi_tra numeric NULL,
	don_gia_benh_nhan_tu_thanh_toan numeric NULL,
	thanh_tien_benh_nhan_tu_thanh_toan numeric NULL,
	benh_nhan_thanh_toan numeric NULL,
	benh_nhan_da_thanh_toan numeric NULL,
	benh_nhan_con_phai_thanh_toan numeric NULL,
	mien_giam_ty_le numeric NULL,
	gia_tri_mien_giam numeric NULL,
	thanh_tien_mien_giam numeric NULL,
	duoc_phep_thuc_hien int2 NULL,
	huy int2 NULL,
	da_thanh_toan_mot_phan int2 NULL,
	da_thanh_toan_hoan_tat int2 NULL,
	da_thuc_hien int2 NULL,
	khong_thu_tien int2 NULL,
	thu_tien_sau int2 NULL,
	bhyt_tu_dong_tien int2 NULL,
	vien_phi_chung_tu_id uuid NULL,
	loai_chung_tu varchar(100) NULL,
	ma_doi_tuong varchar NULL,
	bhyt_dot_dieu_tri_id uuid NULL,
	don_gia_benh_vien_ban_dau numeric NULL,
	don_gia_bhyt_ban_dau numeric NULL,
	ma_phong_ban_thuc_hien varchar NULL,
	ma_phong_ban_chi_dinh varchar NULL,
	hieu_luc int2 NULL,
	bi_xoa int2 NULL,
	ngay_xoa timestamp NULL,
	nguoi_xoa varchar(100) NULL,
	ngay_tao timestamp NULL,
	nguoi_tao varchar(100) NULL,
	ngay_cap_nhat timestamp NULL,
	nguoi_cap_nhat varchar(100) NULL,
	ma_loai_gia varchar NULL,
	ma_cskcb varchar(255) NULL,
	phong_thuc_hien_id uuid NULL,
	phong_chi_dinh_id uuid NULL,
	csyt_vien_phi_id uuid NOT NULL
);

CREATE TABLE csyt_vitri_trinhky (
	id uuid DEFAULT gen_random_uuid() NOT NULL,
	hoso_sohoa_id uuid NOT NULL,
	dmc_cap_ky_phieu_id uuid NULL,
	ma_vi_tri_ky varchar(50) NOT NULL,
	ten_vi_tri_ky varchar(255) NOT NULL,
	chuc_danh_ky varchar(100) NULL,
	thu_tu_ky int4 NOT NULL,
	loai_chu_ky varchar(50) NULL,
	nguoiky_id uuid NULL,
	trang_thai_ky int4 DEFAULT 0 NULL,
	trang_so int4 DEFAULT 1 NULL,
	toa_do_x numeric(10, 2) NULL,
	toa_do_y numeric(10, 2) NULL,
	chieu_rong numeric(10, 2) NULL,
	chieu_cao numeric(10, 2) NULL,
	ngay_tao timestamptz DEFAULT now() NULL,
	nguoi_tao_id uuid NULL,
	ngay_cap_nhat timestamptz NULL,
	nguoi_cap_nhat_id uuid NULL,
	da_xoa int2 DEFAULT 0 NULL,
	CONSTRAINT csyt_vitri_trinhky_pkey PRIMARY KEY (id)
);

CREATE TABLE csyt_xac_nhan_chi_phi (
	so_xac_nhan varchar NULL, -- Số xác nhận
	ngay_xac_nhan date NULL, -- Ngày xác nhận
	thoi_gian_xac_nhan timestamp NULL, -- Thời gian xác nhận
	tiep_nhan_id uuid NULL, -- ID tiếp nhận
	benh_nhan_id uuid NULL, -- ID bệnh nhân
	ma_lk varchar NULL, -- Số tiếp nhận
	ma_benh_nhan varchar NULL, -- Mã bệnh nhân
	ho_ten varchar NULL, -- Họ tên bệnh nhân
	so_cccd varchar NULL, -- Số căn cước công dân
	ngay_sinh date NULL, -- Ngày sinh
	gioi_tinh varchar NULL, -- Giới tính
	nhom_mau varchar NULL, -- Nhóm máu
	ma_quoc_tich varchar NULL, -- Mã quốc tịch
	ma_dan_toc varchar NULL, -- Mã dân tộc
	ma_nghe_nghiep varchar NULL, -- Mã nghề nghiệp
	dia_chi varchar NULL, -- Địa chỉ
	ma_tinh_cu_tru varchar NULL, -- Mã tỉnh cư trú
	ma_xa_cu_tru varchar NULL, -- Mã xã cư trú
	dien_thoai varchar NULL, -- Số điện thoại
	ma_the_bhyt varchar NULL, -- Mã thẻ BHYT
	ma_dkbd varchar NULL, -- Mã đăng ký ban đầu
	id uuid DEFAULT gen_random_uuid() NOT NULL, -- Key của bảng
	ngay_tao timestamp DEFAULT now() NOT NULL, -- Ngày tạo
	nguoi_tao varchar DEFAULT 'system'::character varying NOT NULL, -- Người tạo
	ngay_cap_nhat timestamp DEFAULT now() NOT NULL, -- Ngày cập nhật
	nguoi_cap_nhat varchar DEFAULT 'system'::character varying NOT NULL, -- Người cập nhật
	bi_xoa int2 DEFAULT 0 NOT NULL, -- Bị xóa mềm
	ngay_xoa timestamp NULL, -- Ngày xóa mềm
	nguoi_xoa varchar NULL, -- Người xóa mềm
	gia_tri_the_tu date NULL, -- Giá trị thẻ từ
	gia_tri_the_den date NULL, -- Giá trị thẻ đến
	ngay_mien_cung_chi_tra date NULL, -- Ngày miễn cùng chi trả
	ly_do_vao_vien varchar(255) NULL, -- Lý do vào viện
	ly_do_vao_noi_tru varchar(255) NULL, -- Lý do vào nội trú
	ma_ly_do_vao_noi_tru varchar(25) NULL, -- Mã lý do vào nội trú
	chan_doan_vao varchar(255) NULL, -- Chẩn đoán vào
	chan_doan_ra_vien varchar(255) NULL, -- Chẩn đoán ra viện
	ma_benh_chinh varchar(25) NULL, -- Mã bệnh chính
	ma_benh_kem_theo varchar(25) NULL, -- Mã bệnh kèm theo
	ma_benh_yhct varchar(25) NULL, -- Mã bệnh y học cổ truyền
	ma_pttt_qt varchar(25) NULL, -- Mã phẫu thuật thủ thuật quốc tế
	ma_doi_tuong_kcb varchar(25) NULL, -- Mã đối tượng khám chữa bệnh
	ma_noi_di varchar(25) NULL, -- Mã nơi đi
	ma_noi_den varchar NULL, -- Mã nơi đến
	ma_tai_nan varchar(25) NULL, -- Mã tai nạn
	ngay_vao timestamp NULL, -- Ngày vào (Thời gian tiếp nhận)
	ngay_vao_noi_tru timestamp NULL, -- Ngày vào nội trú
	ngay_ra timestamp NULL, -- Ngày ra
	so_giay_chuyen_tuyen varchar(25) NULL, -- Số giấy chuyển tuyến
	so_ngay_dieu_tri int4 NULL, -- Số ngày điều trị
	phuong_phap_dieu_tri varchar(255) NULL, -- Phương pháp điều trị
	ket_qua_dieu_tri varchar(255) NULL, -- Kết quả điều trị
	ma_loai_ra_vien varchar(25) NULL, -- Mã loại ra viện
	ngay_thanh_toan timestamp NULL, -- Ngày thanh toán
	nam_quyet_toan int4 NULL, -- Năm quyết toán
	thang_quyet_toan int4 NULL, -- Tháng quyết toán
	ma_loai_kcb varchar(25) NULL, -- Mã loại khám chữa bệnh
	ma_khoa varchar(25) NULL, -- Mã khoa
	ma_cskcb varchar(25) NULL, -- Mã sơ sở khám chữa bệnh
	ma_khu_vuc varchar(25) NULL, -- Mã khu vực
	can_nang numeric NULL, -- Cân nặng
	can_nang_con numeric NULL, -- Cân nặng con
	ngay_du_nam_nam_lien_tuc date NULL, -- Ngày đủ năm năm liên tục
	ngay_tai_kham date NULL, -- Ngày tái khám
	ma_ho_so_benh_an varchar(25) NULL, -- Mã hồ sơ bệnh án
	ma_thu_truong_don_vi varchar(25) NULL, -- Mã thử trưởng đơn vị
	xuat_xml int2 NULL, -- Trạng thái xuất XML
	so_lan_xuat_xml int4 NULL, -- Số lần xuất XML
	ghi_chu varchar(500) NULL, -- Ghi chú
	benh_an_id uuid NULL, -- ID bảng benh_an
	ngt_dot_dieu_tri_id uuid NULL, -- ID bảng đợt điều trị ngoại trú
	loai_xac_nhan varchar(25) NULL, -- Loại hồ sơ (Xác nhận): NOI_TRU, NGOAI_TRU, DIEU_TRI_NGOAI_TRU
	dot_dieu_tri_id uuid NULL, -- ID đợt điều trị (bhyt, nội trú)
	thoi_gian_xuat_xml timestamp NULL,
	nguoi_xuat_xml varchar(50) NULL,
	thoi_gian_huy_xuat_xml timestamp NULL,
	nguoi_huy_xuat_xml varchar(50) NULL,
	CONSTRAINT csyt_xac_nhan_chi_phi_pkey PRIMARY KEY (id)
);

CREATE TABLE csyt_xac_nhan_chi_phi_chi_tiet (
	csyt_xac_nhan_chi_phi_id uuid NOT NULL, -- ID xác nhận chi phí
	csyt_vien_phi_id uuid NOT NULL, -- ID liên kết bảng csyt_vien_phi
	kham_benh_id uuid NULL, -- ID liên kết bảng kham_benh
	ref_id uuid NOT NULL, -- REF_ID
	ref_table varchar NOT NULL, -- REF_TABLE
	dich_vu_id uuid NULL, -- ID dịch vụ
	thuoc_vat_tu_id uuid NULL, -- ID thuốc vật tư
	so_lo_nhap_id uuid NULL, -- ID số lô nhập
	loai_chi_phi varchar NULL, -- Loại chi phí
	so_luong numeric DEFAULT 0 NOT NULL, -- Số lượng
	don_gia_benh_vien numeric DEFAULT 0 NOT NULL, -- Đơn giá bệnh viện
	thanh_tien_benh_vien numeric DEFAULT 0 NOT NULL, -- Thành tiền bệnh viện
	muc_huong numeric DEFAULT 0 NOT NULL, -- Mức hưởng
	don_gia_bhyt numeric DEFAULT 0 NOT NULL, -- Đơn giá bảo hiểm y tế
	thanh_tien_bhyt numeric DEFAULT 0 NOT NULL, -- Thành tiền BHYT
	ty_le_thanh_toan_dich_vu numeric DEFAULT 0 NOT NULL, -- Tỷ lệ thanh toán dịch vụ
	ty_le_thanh_toan_bhyt numeric DEFAULT 0 NOT NULL, -- Tỷ lệ thanh toán BHYT
	tran_thanh_toan numeric DEFAULT 0 NOT NULL, -- Mức trần thanh toán
	vuot_tran int2 DEFAULT 0 NOT NULL, -- Vượt trần
	don_gia_bhyt_thanh_toan numeric DEFAULT 0 NOT NULL, -- Đơn giá BHYT hỗ trợ thanh toán
	thanh_tien_bhyt_thanh_toan numeric DEFAULT 0 NOT NULL, -- Thành tiền BHYT hỗ trợ thanh toán
	don_gia_benh_nhan_cung_chi_tra numeric DEFAULT 0 NOT NULL, -- Đơn giá bệnh nhân cùng chi trả
	thanh_tien_benh_nhan_cung_chi_tra numeric DEFAULT 0 NOT NULL, -- Thành tiền bệnh nhân cùng chi trả
	don_gia_benh_nhan_tu_thanh_toan numeric DEFAULT 0 NOT NULL, -- Đơn giá bệnh nhân tự thanh toán
	thanh_tien_benh_nhan_tu_thanh_toan numeric DEFAULT 0 NOT NULL, -- Thành tiền bệnh nhân tự thanh toán
	benh_nhan_thanh_toan numeric DEFAULT 0 NOT NULL, -- Bệnh nhân thanh toán
	ty_le_mien_giam numeric DEFAULT 0 NOT NULL, -- Tỷ lệ miễn giảm
	gia_tri_mien_giam numeric DEFAULT 0 NOT NULL, -- Giá trị miễn giảm
	thanh_tien_mien_giam numeric DEFAULT 0 NOT NULL, -- Thành tiền miễn giảm
	huy int2 DEFAULT 0 NOT NULL, -- 0: false 1: true
	khong_thu_tien int2 DEFAULT 0 NOT NULL, -- 0: false¶1: true
	bhyt_tu_dong_tien int2 DEFAULT 0 NOT NULL, -- 0: false 1: true
	ma_doi_tuong varchar NULL, -- Mã đối tượng
	don_gia_benh_vien_ban_dau numeric DEFAULT 0 NOT NULL, -- Đơn giá bệnh viện ban đầu
	don_gia_bhyt_ban_dau numeric DEFAULT 0 NOT NULL, -- Đơn giá BHYT ban đầu
	ma_phong_ban_thuc_hien varchar NULL, -- Mã phòng ban thực hiện
	ma_phong_ban_chi_dinh varchar NULL, -- Mã phòng ban chỉ định
	hieu_luc int2 DEFAULT 0 NOT NULL, -- 0: false 1: true
	ma_loai_gia varchar NULL, -- Mã loại giá
	ma_cskcb varchar NULL, -- Mã cơ sở khám chữa bệnh
	phong_thuc_hien_id uuid NULL, -- ID liên kết bảng dm_phong
	phong_chi_dinh_id uuid NULL, -- ID liên kết bảng dm_phong
	gia_tt_id uuid NOT NULL, -- ID loại giá thanh toán
	is_ksk int2 DEFAULT 0 NOT NULL, -- 0: false 1: true
	is_goi_dv int2 DEFAULT 0 NOT NULL, -- 0: false 1: true
	is_pt50 int2 DEFAULT 0 NOT NULL, -- 0: false 1: true
	is_pt80 int2 DEFAULT 0 NOT NULL, -- 0: false 1: true
	is_ghep02 int2 DEFAULT 0 NOT NULL, -- 0: false 1: true
	is_ghep03 int2 DEFAULT 0 NOT NULL, -- 0: false 1: true
	khan int2 DEFAULT 0 NOT NULL, -- 0: false 1: true
	doi_tuong_id uuid NOT NULL, -- ID liên kết bảng dm_doi_tuong_benh_nhan
	nguon_chi_tra_id uuid NULL, -- ID nguồn chi trả
	don_vi_chi_tra varchar NULL, -- Đơn vị chi trả
	ma_nhom_bhyt_id uuid NULL, -- ID mã nhóm BHYT
	id uuid DEFAULT gen_random_uuid() NOT NULL, -- Key của bảng
	ngay_tao timestamp DEFAULT now() NOT NULL, -- Ngày tạo
	nguoi_tao varchar DEFAULT 'system'::character varying NOT NULL, -- Người tạo
	ngay_cap_nhat timestamp DEFAULT now() NOT NULL, -- Ngày cập nhật
	nguoi_cap_nhat varchar DEFAULT 'system'::character varying NOT NULL, -- Người cập nhật
	bi_xoa int2 DEFAULT 0 NULL, -- Bị xóa mềm
	ngay_xoa timestamp NULL, -- Ngày xóa mềm
	nguoi_xoa varchar NULL, -- Người xóa mềm
	dot_dieu_tri_id uuid NULL, -- ID đợt điều trị (BHYT, nội)
	ngt_dot_dieu_tri_id uuid NULL, -- ID đợt điều trị ngoại trú
	CONSTRAINT csyt_xac_nhan_chi_phi_chi_tiet_pkey PRIMARY KEY (id)
);

CREATE TABLE csyt_xac_nhan_chi_phi_vien_phi (
	so_xac_nhan varchar NULL, -- Số xác nhận
	ngay_xac_nhan date NULL, -- Ngày xác nhận
	thoi_gian_xac_nhan timestamp NULL, -- Thời gian xác nhận
	tiep_nhan_id uuid NULL, -- ID tiếp nhận
	benh_nhan_id uuid NULL, -- ID bệnh nhân
	ma_lk varchar NULL, -- Số tiếp nhận
	ma_benh_nhan varchar NULL, -- Mã bệnh nhân
	ho_ten varchar NULL, -- Họ tên bệnh nhân
	so_cccd varchar NULL, -- Số căn cước công dân
	ngay_sinh date NULL, -- Ngày sinh
	gioi_tinh varchar NULL, -- Giới tính
	nhom_mau varchar NULL, -- Nhóm máu
	ma_quoc_tich varchar NULL, -- Mã quốc tịch
	ma_dan_toc varchar NULL, -- Mã dân tộc
	ma_nghe_nghiep varchar NULL, -- Mã nghề nghiệp
	dia_chi varchar NULL, -- Địa chỉ
	ma_tinh_cu_tru varchar NULL, -- Mã tỉnh cư trú
	ma_xa_cu_tru varchar NULL, -- Mã xã cư trú
	dien_thoai varchar NULL, -- Số điện thoại
	ma_the_bhyt varchar NULL, -- Mã thẻ BHYT
	ma_dkbd varchar NULL, -- Mã đăng ký ban đầu
	id uuid DEFAULT gen_random_uuid() NOT NULL, -- Key của bảng
	ngay_tao timestamp DEFAULT now() NOT NULL, -- Ngày tạo
	nguoi_tao varchar DEFAULT 'system'::character varying NOT NULL, -- Người tạo
	ngay_cap_nhat timestamp DEFAULT now() NOT NULL, -- Ngày cập nhật
	nguoi_cap_nhat varchar DEFAULT 'system'::character varying NOT NULL, -- Người cập nhật
	bi_xoa int2 DEFAULT 0 NULL, -- Bị xóa mềm
	ngay_xoa timestamp NULL, -- Ngày xóa mềm
	nguoi_xoa varchar NULL, -- Người xóa mềm
	gia_tri_the_tu date NULL, -- Giá trị thẻ từ
	gia_tri_the_den date NULL, -- Giá trị thẻ đến
	ngay_mien_cung_chi_tra date NULL, -- Ngày miễn cùng chi trả
	ly_do_vao_vien varchar(255) NULL, -- Lý do vào viện
	ly_do_vao_noi_tru varchar(255) NULL, -- Lý do vào nội trú
	ma_ly_do_vao_noi_tru varchar(25) NULL, -- Mã lý do vào nội trú
	chan_doan_vao varchar(255) NULL, -- Chẩn đoán vào
	chan_doan_ra_vien varchar(255) NULL, -- Chẩn đoán ra viện
	ma_benh_chinh varchar(25) NULL, -- Mã bệnh chính
	ma_benh_kem_theo varchar(25) NULL, -- Mã bệnh kèm theo
	ma_benh_yhct varchar(25) NULL, -- Mã bệnh y học cổ truyền
	ma_pttt_qt varchar(25) NULL, -- Mã phẫu thuật thủ thuật quốc tế
	ma_doi_tuong_kcb varchar(25) NULL, -- Mã đối tượng khám chữa bệnh
	ma_noi_di varchar(25) NULL, -- Mã nơi đi
	ma_noi_den varchar NULL, -- Mã nơi đến
	ma_tai_nan varchar(25) NULL, -- Mã tai nạn
	ngay_vao date NULL, -- Ngày vào (Thời gian tiếp nhận)
	ngay_vao_noi_tru date NULL, -- Ngày vào nội trú
	ngay_ra date NULL, -- Ngày ra
	so_giay_chuyen_tuyen varchar(25) NULL, -- Số giấy chuyển tuyến
	so_ngay_dieu_tri int4 NULL, -- Số ngày điều trị
	phuong_phap_dieu_tri varchar(255) NULL, -- Phương pháp điều trị
	ket_qua_dieu_tri varchar(255) NULL, -- Kết quả điều trị
	ma_loai_ra_vien varchar(25) NULL, -- Mã loại ra viện
	ngay_thanh_toan date NULL, -- Ngày thanh toán
	nam_quyet_toan int4 NULL, -- Năm quyết toán
	thang_quyet_toan int4 NULL, -- Tháng quyết toán
	ma_loai_kcb varchar(25) NULL, -- Mã loại khám chữa bệnh
	ma_khoa varchar(25) NULL, -- Mã khoa
	ma_cskcb varchar(25) NULL, -- Mã sơ sở khám chữa bệnh
	ma_khu_vuc varchar(25) NULL, -- Mã khu vực
	can_nang numeric NULL, -- Cân nặng
	can_nang_con numeric NULL, -- Cân nặng con
	ngay_du_nam_nam_lien_tuc date NULL, -- Ngày đủ năm năm liên tục
	ngay_tai_kham date NULL, -- Ngày tái khám
	ma_ho_so_benh_an varchar(25) NULL, -- Mã hồ sơ bệnh án
	ma_thu_truong_don_vi varchar(25) NULL, -- Mã thử trưởng đơn vị
	xuat_xml int2 NULL, -- Trạng thái xuất XML
	so_lan_xuat_xml int4 NULL, -- Số lần xuất XML
	ghi_chu varchar(500) NULL, -- Ghi chú
	benh_an_id uuid NULL, -- ID bảng benh_an
	ngt_dot_dieu_tri_id uuid NULL, -- ID bảng đợt điều trị ngoại trú
	loai_xac_nhan varchar(25) NULL, -- Loại hồ sơ (Xác nhận): NOI_TRU, NGOAI_TRU, DIEU_TRI_NGOAI_TRU
	dot_dieu_tri_id uuid NULL, -- ID đợt điều trị (bhyt, nội trú)
	CONSTRAINT csyt_xac_nhan_chi_phi_vien_phi_pk_id PRIMARY KEY (id)
);

CREATE TABLE csyt_xac_nhan_chi_phi_vien_phi_chi_tiet (
	csyt_xac_nhan_chi_phi_id uuid NOT NULL, -- ID xác nhận chi phí
	csyt_vien_phi_id uuid NOT NULL, -- ID liên kết bảng csyt_vien_phi
	kham_benh_id uuid NULL, -- ID liên kết bảng kham_benh
	ref_id uuid NOT NULL, -- REF_ID
	ref_table varchar NOT NULL, -- REF_TABLE
	dich_vu_id uuid NULL, -- ID dịch vụ
	thuoc_vat_tu_id uuid NULL, -- ID thuốc vật tư
	so_lo_nhap_id uuid NULL, -- ID số lô nhập
	loai_chi_phi varchar NULL, -- Loại chi phí
	so_luong numeric DEFAULT 0 NOT NULL, -- Số lượng
	don_gia_benh_vien numeric DEFAULT 0 NOT NULL, -- Đơn giá bệnh viện
	thanh_tien_benh_vien numeric DEFAULT 0 NOT NULL, -- Thành tiền bệnh viện
	muc_huong numeric DEFAULT 0 NOT NULL, -- Mức hưởng
	don_gia_bhyt numeric DEFAULT 0 NOT NULL, -- Đơn giá bảo hiểm y tế
	thanh_tien_bhyt numeric DEFAULT 0 NOT NULL, -- Thành tiền BHYT
	ty_le_thanh_toan_dich_vu numeric DEFAULT 0 NOT NULL, -- Tỷ lệ thanh toán dịch vụ
	ty_le_thanh_toan_bhyt numeric DEFAULT 0 NOT NULL, -- Tỷ lệ thanh toán BHYT
	tran_thanh_toan numeric DEFAULT 0 NOT NULL, -- Mức trần thanh toán
	vuot_tran int2 DEFAULT 0 NOT NULL, -- Vượt trần
	don_gia_bhyt_thanh_toan numeric DEFAULT 0 NOT NULL, -- Đơn giá BHYT hỗ trợ thanh toán
	thanh_tien_bhyt_thanh_toan numeric DEFAULT 0 NOT NULL, -- Thành tiền BHYT hỗ trợ thanh toán
	don_gia_benh_nhan_cung_chi_tra numeric DEFAULT 0 NOT NULL, -- Đơn giá bệnh nhân cùng chi trả
	thanh_tien_benh_nhan_cung_chi_tra numeric DEFAULT 0 NOT NULL, -- Thành tiền bệnh nhân cùng chi trả
	don_gia_benh_nhan_tu_thanh_toan numeric DEFAULT 0 NOT NULL, -- Đơn giá bệnh nhân tự thanh toán
	thanh_tien_benh_nhan_tu_thanh_toan numeric DEFAULT 0 NOT NULL, -- Thành tiền bệnh nhân tự thanh toán
	benh_nhan_thanh_toan numeric DEFAULT 0 NOT NULL, -- Bệnh nhân thanh toán
	ty_le_mien_giam numeric DEFAULT 0 NOT NULL, -- Tỷ lệ miễn giảm
	gia_tri_mien_giam numeric DEFAULT 0 NOT NULL, -- Giá trị miễn giảm
	thanh_tien_mien_giam numeric DEFAULT 0 NOT NULL, -- Thành tiền miễn giảm
	huy int2 DEFAULT 0 NOT NULL, -- 0: false 1: true
	khong_thu_tien int2 DEFAULT 0 NOT NULL, -- 0: false¶1: true
	bhyt_tu_dong_tien int2 DEFAULT 0 NOT NULL, -- 0: false 1: true
	ma_doi_tuong varchar NULL, -- Mã đối tượng
	don_gia_benh_vien_ban_dau numeric DEFAULT 0 NOT NULL, -- Đơn giá bệnh viện ban đầu
	don_gia_bhyt_ban_dau numeric DEFAULT 0 NOT NULL, -- Đơn giá BHYT ban đầu
	ma_phong_ban_thuc_hien varchar NULL, -- Mã phòng ban thực hiện
	ma_phong_ban_chi_dinh varchar NULL, -- Mã phòng ban chỉ định
	hieu_luc int2 DEFAULT 0 NOT NULL, -- 0: false 1: true
	ma_loai_gia varchar NULL, -- Mã loại giá
	ma_cskcb varchar NULL, -- Mã cơ sở khám chữa bệnh
	phong_thuc_hien_id uuid NULL, -- ID liên kết bảng dm_phong
	phong_chi_dich_id uuid NULL, -- ID liên kết bảng dm_phong
	gia_tt_id uuid NOT NULL, -- ID loại giá thanh toán
	is_ksk int2 DEFAULT 0 NOT NULL, -- 0: false 1: true
	is_goi_dv int2 DEFAULT 0 NOT NULL, -- 0: false 1: true
	is_pt50 int2 DEFAULT 0 NOT NULL, -- 0: false 1: true
	is_pt80 int2 DEFAULT 0 NOT NULL, -- 0: false 1: true
	is_ghep02 int2 DEFAULT 0 NOT NULL, -- 0: false 1: true
	is_ghep03 int2 DEFAULT 0 NOT NULL, -- 0: false 1: true
	khan int2 DEFAULT 0 NOT NULL, -- 0: false 1: true
	doi_tuong_id uuid NOT NULL, -- ID liên kết bảng dm_doi_tuong_benh_nhan
	nguon_chi_tra_id uuid NULL, -- ID nguồn chi trả
	don_vi_chi_tra varchar NULL, -- Đơn vị chi trả
	ma_nhom_bhyt_id uuid NULL, -- ID mã nhóm BHYT
	id uuid DEFAULT gen_random_uuid() NOT NULL, -- Key của bảng
	ngay_tao timestamp DEFAULT now() NOT NULL, -- Ngày tạo
	nguoi_tao varchar DEFAULT 'system'::character varying NOT NULL, -- Người tạo
	ngay_cap_nhat timestamp DEFAULT now() NOT NULL, -- Ngày cập nhật
	nguoi_cap_nhat varchar DEFAULT 'system'::character varying NOT NULL, -- Người cập nhật
	bi_xoa int2 DEFAULT 0 NULL, -- Bị xóa mềm
	ngay_xoa timestamp NULL, -- Ngày xóa mềm
	nguoi_xoa varchar NULL, -- Người xóa mềm
	dot_dieu_tri_id uuid NULL, -- ID đợt điều trị (BHYT, nội)
	ngt_dot_dieu_tri_id uuid NULL, -- ID đợt điều trị ngoại trú
	CONSTRAINT csyt_xac_nhan_chi_phi_vien_phi_chi_tiet_pk_id PRIMARY KEY (id)
);

CREATE TABLE csyt_yeu_cau_tam_ung (
	id uuid DEFAULT gen_random_uuid() NOT NULL,
	ngay_tao timestamp DEFAULT now() NOT NULL,
	nguoi_tao varchar(100) DEFAULT 'system'::character varying NOT NULL,
	ngay_cap_nhat timestamp DEFAULT now() NOT NULL,
	nguoi_cap_nhat varchar(100) DEFAULT 'system'::character varying NOT NULL,
	bi_xoa int2 DEFAULT 0 NULL,
	ngay_xoa timestamp NULL,
	nguoi_xoa varchar(100) NULL,
	tiep_nhan_id uuid NULL,
	benh_an_id uuid NULL,
	dot_dieu_tri_id uuid NULL,
	so_phieu_tu varchar(50) NULL, -- Số phiếu yêu cầu tạm ứng
	nguoi_lap_phieu_id uuid NULL,
	ngay_lap_phieu timestamp NULL,
	so_tien_de_nghi_tu numeric(25, 4) NULL, -- Số tiền đề nghị tạm ứng
	is_dau_tien int2 NULL, -- Đánh dấu đây là yêu cầu tạm ứng đầu tiên
	csyt_vien_phi_chung_tu_id uuid NULL, -- ID hóa đơn chính thức liên quan
	so_tien_thanh_toan numeric(25, 4) NULL, -- Số tiền đã thanh toán theo yêu cầu tạm ứng
	so_phieu_thu varchar(50) NULL, -- Số phiếu thu được lập khi thu tiền
	ngay_thu timestamp NULL, -- Ngày, giờ thực hiện thu tiền
	ma_cskcb varchar(10) NULL,
	ho_so_so_hoa_id uuid NULL, -- ID hồ sơ số hóa
	ghi_chu varchar NULL,
	noi_lap_phieu_id uuid NULL, -- ID nơi tạo yêu cầu
	CONSTRAINT csyt_yeu_cau_tam_ung_pk_id PRIMARY KEY (id)
);

CREATE TABLE csyt_yl_thuocvt (
	ylthuocvt_id bigserial NOT NULL,
	tiep_nhan_id uuid NULL, -- ID tiếp nhận bệnh nhân (uuid)
	hoso_sohoa_id uuid NULL, -- ID hồ sơ số hóa (uuid)
	luutru_id uuid NULL,
	khambenh_id uuid NULL, -- ID lần khám bệnh (uuid)
	thuocvt_id int8 NULL, -- ID thuốc/vật tư
	ma_byt varchar(50) NULL,
	so_thutu_toa int4 NULL,
	tenthuoc varchar(500) NULL,
	ten_byt varchar(500) NULL,
	yl_dichvu_id uuid NULL,
	thautvt_id numeric NULL,
	so_luong_yc numeric NULL,
	donvichitra_id numeric NULL,
	bacsi_chidinh uuid NULL, -- ID bác sĩ chỉ định (uuid)
	ngay_chidinh timestamp NULL,
	ngay_thuchien timestamp NULL,
	solo_nhap_id int8 NULL,
	handung date NULL,
	so_ngay numeric NULL,
	sang numeric NULL,
	trua numeric NULL,
	chieu numeric NULL,
	toi numeric NULL,
	lieu_dung varchar(500) NULL,
	cach_dung varchar(500) NULL,
	thoi_gian_dung varchar(255) NULL,
	duong_dung varchar(255) NULL,
	kho_id int8 NULL,
	so_lan_tren_ngay numeric NULL,
	so_luong_tren_lan numeric NULL,
	ngay_tao timestamp DEFAULT now() NULL,
	ngay_cap_phat timestamp NULL,
	ngay_cap_nhat timestamp NULL,
	nguoi_cap_nhat_id uuid NULL, -- ID người cập nhật (uuid)
	ty_le_quy_doi int4 NULL,
	chung_tu_phatid int8 NULL,
	tinh_tien bool DEFAULT true NULL,
	so_ngay_sd_khang_sinh numeric NULL,
	mien_phi bool DEFAULT false NULL,
	y_lenh_id int8 NULL,
	hoi_chan_tx_id int8 NULL,
	csyt_tham_gia_id int8 NULL,
	bacsi_hoichan_id int8 NULL,
	nguoi_tao uuid NULL, -- ID người tạo y lệnh (uuid)
	hoichan_tuxa_id bool NULL,
	coso_yte_thamgia_id int8 NULL,
	trang_thai int4 NULL, -- Trạng thái y lệnh
	bacsi_hc_id int8 NULL,
	qd_thau_id int8 NULL,
	bhyt_ddt_id int8 NULL,
	bi_xoa bool DEFAULT false NULL,
	nguoi_xoa uuid NULL, -- ID người xóa (uuid)
	ngay_xoa timestamp NULL,
	mauhososohoa_id uuid NULL,
	id uuid DEFAULT gen_random_uuid() NULL,
	nhom_hdvp_id uuid NULL,
	nhom_ma_bhyt uuid NULL,
	dvt_id uuid NULL,
	don_vi_capphat_id uuid NULL,
	nguonct_id uuid NULL,
	loaikedon_id uuid NULL,
	loai_don_id uuid NULL,
	loai_tvt_id uuid NULL,
	gia_tt_id uuid NULL,
	phac_dodt_id uuid NULL,
	to_dieu_tri_id uuid NULL,
	loai_y_lenh_id int2 NULL,
	benh_an_id uuid NULL,
	thuc_hien_dich_vu_id uuid NULL,
	pttt_id uuid NULL,
	don_gia_tam_tinh numeric(15, 3) NULL,
	thanh_tien_tam_tinh numeric(20, 3) NULL,
	ds_dich_vu_chi_dinh _uuid NULL,
	ham_luong varchar NULL,
	hoat_chat varchar NULL,
	don_vi_tinh varchar NULL, -- Đơn vị tính của đơn mua ngoài
	so_thang numeric NULL,
	so_ngay_1_thang numeric NULL,
	cach_sac varchar NULL, -- YHCT: cách sắc thuốc
	ly_do_ke varchar NULL,
	khoi_luong numeric NULL,
	tu_ngay date NULL,
	den_ngay date NULL,
	khoi_luong_hu_hao numeric NULL,
	ty_le_hu_hao numeric NULL,
	CONSTRAINT csyt_yl_thuocvt_pkey PRIMARY KEY (ylthuocvt_id)
);

CREATE TABLE dan_muc_duong (
	stt int4 NULL,
	ma_duong varchar NULL,
	ten_duong_dung varchar NULL,
	ten_tieng_anh varchar NULL,
	ma_quy_dinh varchar NULL,
	ghi_chu varchar NULL,
	so_thu_tu_duong_dung int4 NULL,
	trang_thai_su_dung bool NULL,
	id uuid DEFAULT gen_random_uuid() NOT NULL,
	deleted_at timestamp NULL,
	created_at timestamp DEFAULT now() NOT NULL,
	created_by text NOT NULL,
	updated_at timestamp DEFAULT now() NOT NULL,
	updated_by text NOT NULL,
	CONSTRAINT dan_muc_duong_pkey PRIMARY KEY (id)
);

CREATE TABLE danh_muc_tu_vong (
	ma_nguyen_nhan varchar NULL, -- Mã nguyên nhân
	ten_nguyen_nhan varchar NULL, -- Tên nguyên nhân
	ghi_chu varchar NULL, -- Ghi chú
	phau_thuat bool NULL,
	su_dung bool NULL,
	id uuid DEFAULT gen_random_uuid() NOT NULL, -- Key của bảng
	ngay_tao timestamp DEFAULT now() NOT NULL, -- Ngày tạo
	nguoi_tao varchar DEFAULT 'system'::character varying NOT NULL, -- Người tạo
	ngay_cap_nhat timestamp DEFAULT now() NOT NULL, -- Ngày cập nhật
	nguoi_cap_nhat varchar DEFAULT 'system'::character varying NOT NULL, -- Người cập nhật
	bi_xoa int2 DEFAULT 0 NULL, -- Bị xóa mềm
	ngay_xoa timestamp NULL, -- Ngày xóa mềm
	nguoi_xoa varchar NULL, -- Người xóa mềm
	CONSTRAINT danh_muc_tu_vong_pkey PRIMARY KEY (id)
);

CREATE TABLE databasechangelog (
	id varchar(255) NOT NULL,
	author varchar(255) NOT NULL,
	filename varchar(255) NOT NULL,
	dateexecuted timestamp NOT NULL,
	orderexecuted int4 NOT NULL,
	exectype varchar(10) NOT NULL,
	md5sum varchar(35) NULL,
	description varchar(255) NULL,
	"comments" varchar(255) NULL,
	tag varchar(255) NULL,
	liquibase varchar(20) NULL,
	contexts varchar(255) NULL,
	labels varchar(255) NULL,
	deployment_id varchar(10) NULL
);

CREATE TABLE databasechangeloglock (
	id int4 NOT NULL,
	"locked" bool NOT NULL,
	lockgranted timestamp NULL,
	lockedby varchar(255) NULL,
	CONSTRAINT databasechangeloglock_pkey PRIMARY KEY (id)
);

CREATE TABLE debug_sql_log (
	id int8 NOT NULL,
	created_at timestamp DEFAULT now() NULL,
	proc_name text NULL,
	step text NULL,
	sql_text text NULL,
	CONSTRAINT debug_sql_log_pkey PRIMARY KEY (id)
);

CREATE TABLE dm_benh_pham (
	id uuid DEFAULT gen_random_uuid() NOT NULL,
	ma_benh_pham varchar NULL,
	ten_benh_pham varchar NULL,
	ten_khong_dau varchar NULL,
	su_dung bool NULL,
	stt int4 NULL,
	ngay_tao timestamp(6) DEFAULT now() NOT NULL,
	nguoi_tao text NOT NULL,
	ngay_cap_nhat timestamp(6) DEFAULT now() NOT NULL,
	nguoi_cap_nhat text NOT NULL,
	ma_cskcb varchar(50) NULL,
	nguoi_xoa varchar NULL,
	bi_xoa int2 DEFAULT 0 NULL,
	ngay_xoa timestamp(6) NULL
);

CREATE TABLE dm_bhyt_tl_temp (
	id uuid DEFAULT gen_random_uuid() NOT NULL,
	uid uuid NULL,
	request_id text NULL,
	lan_import int8 NULL,
	loai int2 NULL,
	thuocsd_icd_id uuid NULL,
	tyle_bhyt_tra uuid NULL,
	loaigia_id uuid NULL,
	bhyt_tt bool DEFAULT true NULL,
	hienthi_cb varchar NULL,
	ghi_chu varchar NULL,
	su_dung bool DEFAULT true NULL,
	loi varchar NULL,
	trang_thai int2 DEFAULT 1 NULL,
	ngay_tao timestamp DEFAULT now() NULL,
	CONSTRAINT dm_bhyt_tl_temp_pkey PRIMARY KEY (id)
);

CREATE TABLE dm_bhyt_tyle (
	ten_ty_le varchar NULL,
	ty_le int4 NULL,
	id uuid DEFAULT gen_random_uuid() NOT NULL, -- Key của bảng
	ngay_tao timestamp DEFAULT now() NOT NULL, -- Ngày tạo
	nguoi_tao varchar(100) DEFAULT 'system'::character varying NOT NULL, -- Người tạo
	ngay_cap_nhat timestamp DEFAULT now() NOT NULL, -- Ngày cập nhật
	nguoi_cap_nhat varchar(100) DEFAULT 'system'::character varying NOT NULL, -- Người cập nhật
	bi_xoa int2 DEFAULT 0 NULL, -- Bị xóa mềm
	ngay_xoa timestamp NULL, -- Ngày xóa mềm
	nguoi_xoa varchar(100) NULL, -- Người xóa mềm
	su_dung bool NULL,
	CONSTRAINT dm_bhyt_tyle_pkey PRIMARY KEY (id)
);

CREATE TABLE dm_biet_duoc_goc (
	ma_nhom varchar NOT NULL,
	ten_nhom varchar NOT NULL,
	ghi_chu varchar NULL,
	su_dung bool NULL,
	biet_duoc_id int4 NOT NULL,
	id uuid DEFAULT gen_random_uuid() NOT NULL,
	deleted_at timestamp NULL,
	created_at timestamp DEFAULT now() NOT NULL,
	created_by text NOT NULL,
	updated_at timestamp DEFAULT now() NOT NULL,
	updated_by text NOT NULL,
	CONSTRAINT dm_biet_duoc_goc_ma_nhom_key UNIQUE (ma_nhom),
	CONSTRAINT dm_biet_duoc_goc_pkey PRIMARY KEY (id)
);

CREATE TABLE dm_bieu_mau_dong (
	ma varchar(100) NOT NULL, -- mã
	ten varchar(100) NOT NULL, -- tên
	"type" varchar(100) NOT NULL,
	"schema" jsonb NOT NULL,
	id uuid DEFAULT gen_random_uuid() NOT NULL, -- Key của bảng
	ngay_tao timestamp DEFAULT now() NOT NULL, -- Ngày tạo
	nguoi_tao varchar(100) DEFAULT 'system'::character varying NOT NULL, -- Người tạo
	ngay_cap_nhat timestamp DEFAULT now() NOT NULL, -- Ngày cập nhật
	nguoi_cap_nhat varchar(100) DEFAULT 'system'::character varying NOT NULL, -- Người cập nhật
	bi_xoa int2 DEFAULT 0 NULL, -- Bị xóa mềm
	ngay_xoa timestamp NULL, -- Ngày xóa mềm
	nguoi_xoa varchar(100) NULL, -- Người xóa mềm
	hoat_dong int2 DEFAULT 1 NOT NULL,
	form_data jsonb NULL, -- Dữ liệu mặc định runtime (form.data) — merge khi load VFormRuntime; không lưu trong schema PersistedForm.
	"version" int4 DEFAULT 1 NOT NULL, -- Phiên bản nghiệp vụ. FORM: unique cùng ma, user sửa trên designer. MAPPING: luôn 1 (NOT NULL), không sửa UI.
	CONSTRAINT dm_bieu_mau_dong_pkey PRIMARY KEY (id)
);

CREATE TABLE dm_bieu_mau_dong_asset (
	ma varchar NOT NULL,
	ten varchar NULL,
	"type" varchar(45) DEFAULT 'function'::character varying NOT NULL, -- Loại: function | template | preset
	category varchar(100) NULL, -- Phân loại theo nhóm
	"schema" jsonb NULL, -- Nội dung asset — với function là {body, params}
	"version" int4 DEFAULT 1 NOT NULL,
	id uuid DEFAULT gen_random_uuid() NOT NULL, -- Key của bảng
	ngay_tao timestamp DEFAULT now() NOT NULL, -- Ngày tạo
	nguoi_tao varchar(100) DEFAULT 'system'::character varying NOT NULL, -- Người tạo
	ngay_cap_nhat timestamp DEFAULT now() NOT NULL, -- Ngày cập nhật
	nguoi_cap_nhat varchar(100) DEFAULT 'system'::character varying NOT NULL, -- Người cập nhật
	bi_xoa int2 DEFAULT 0 NULL, -- Bị xóa mềm
	ngay_xoa timestamp NULL, -- Ngày xóa mềm
	nguoi_xoa varchar(100) NULL, -- Người xóa mềm
	form_data jsonb NULL, -- Dữ liệu mẫu kèm template asset (type=template).
	CONSTRAINT dm_bieu_mau_dong_asset_pkey PRIMARY KEY (id)
);

CREATE TABLE dm_bieu_mau_dong_data (
	id uuid DEFAULT gen_random_uuid() NOT NULL,
	bieu_mau_id uuid NOT NULL, -- FK logic → dm_bieu_mau_dong.id (pin version lúc tạo phiếu).
	"data" jsonb NULL,
	bi_xoa int2 DEFAULT 0 NOT NULL,
	ngay_tao timestamptz DEFAULT now() NOT NULL,
	ngay_cap_nhat timestamptz DEFAULT now() NOT NULL,
	CONSTRAINT dm_bieu_mau_dong_data_pkey PRIMARY KEY (id)
);

CREATE TABLE dm_bieu_mau_instance_binding (
	id uuid DEFAULT gen_random_uuid() NOT NULL,
	source_type varchar(64) NOT NULL,
	source_id varchar(64) NOT NULL,
	bieu_mau_id uuid NOT NULL,
	bieu_mau_ma varchar(128) NOT NULL,
	form_data_type varchar(128) DEFAULT 'dm_bieu_mau_dong_data'::character varying NOT NULL,
	form_data_id uuid NULL,
	inline_data jsonb NULL,
	schema_override jsonb NULL,
	bi_xoa int2 DEFAULT 0 NOT NULL,
	ngay_tao timestamptz DEFAULT now() NOT NULL,
	ngay_cap_nhat timestamptz DEFAULT now() NOT NULL,
	nguoi_tao varchar(100) DEFAULT 'system'::character varying NOT NULL,
	nguoi_cap_nhat varchar(100) DEFAULT 'system'::character varying NOT NULL,
	ngay_xoa timestamptz NULL,
	nguoi_xoa varchar(100) NULL,
	CONSTRAINT dm_bieu_mau_instance_binding_pkey PRIMARY KEY (id, source_type)
);

CREATE TABLE dm_bieu_mau_instance_map (
	id uuid DEFAULT gen_random_uuid() NOT NULL,
	source_type varchar(64) NOT NULL, -- Loại nguồn (vd TO_DIEU_TRI, PHIEU_CHAM_SOC).
	source_id varchar(64) NOT NULL,
	bieu_mau_id uuid NOT NULL,
	bieu_mau_ma varchar(128) NOT NULL,
	form_data_type varchar(128) DEFAULT 'dm_bieu_mau_dong_data'::character varying NOT NULL, -- Tên bảng/store chứa JSONB — mặc định dm_bieu_mau_dong_data; có thể trỏ bảng nghiệp vụ.
	form_data_id uuid NOT NULL,
	bi_xoa int2 DEFAULT 0 NOT NULL,
	ngay_tao timestamptz DEFAULT now() NOT NULL,
	ngay_cap_nhat timestamptz DEFAULT now() NOT NULL,
	CONSTRAINT dm_bieu_mau_instance_map_pkey PRIMARY KEY (id)
);

CREATE TABLE dm_block_ksk (
	ma_khoi_ksk varchar NOT NULL, -- Mã khối khám sức khoẻ
	ten_khoi_ksk varchar NOT NULL, -- Tên mã khối khám sức khoẻ
	ten_truong_du_lieu varchar NULL, -- Tên trường dữ liệu
	ten_bang varchar NULL, -- Tên bảng
	loai_ma_khoi_ksk varchar NOT NULL, -- Loại mã khối khám sức khoẻ
	ma_khoi_ksk_cha varchar NULL, -- Mã khối khám sức khoẻ cha
	id uuid DEFAULT gen_random_uuid() NOT NULL, -- Key của bảng
	ngay_tao timestamp DEFAULT now() NOT NULL, -- Ngày tạo
	nguoi_tao varchar(100) DEFAULT 'system'::character varying NOT NULL, -- Người tạo
	ngay_cap_nhat timestamp DEFAULT now() NOT NULL, -- Ngày cập nhật
	nguoi_cap_nhat varchar(100) DEFAULT 'system'::character varying NOT NULL, -- Người cập nhật
	bi_xoa int2 DEFAULT 0 NULL, -- Bị xóa mềm
	ngay_xoa timestamp NULL, -- Ngày xóa mềm
	nguoi_xoa varchar(100) NULL, -- Người xóa mềm
	func_save varchar DEFAULT '(100)'::character varying NULL, -- Hàm lưu dữ liệu
	func_detail varchar DEFAULT '(100)'::character varying NULL, -- Hàm lấy dữ liệu
	ds_ma_loai_dich_vu _varchar NULL, -- Danh sách mã loại dịch vụ
	xml_tag_id varchar DEFAULT '(25)'::character varying NULL, -- Hàm lấy dữ liệu
	ma_dv_byt varchar(25) NULL, -- Mã dịch vụ BYT
	ma_chi_so_con_byt varchar NULL,
	CONSTRAINT dm_block_ksk_ma_khoi_ksk_key UNIQUE (ma_khoi_ksk),
	CONSTRAINT dm_block_ksk_pkey PRIMARY KEY (id)
);

CREATE TABLE dm_block_ksk_dich_vu_map (
	id uuid DEFAULT gen_random_uuid() NOT NULL,
	ma_cskcb varchar NOT NULL,
	ma_khoi_ksk varchar NOT NULL,
	dich_vu_ids _uuid DEFAULT ARRAY[]::uuid[] NOT NULL,
	chi_so_con_ids _uuid DEFAULT ARRAY[]::uuid[] NULL,
	ngay_tao timestamp DEFAULT now() NULL,
	nguoi_tao varchar NULL,
	ngay_cap_nhat timestamp DEFAULT now() NULL,
	nguoi_cap_nhat varchar NULL,
	bi_xoa int2 DEFAULT 0 NOT NULL,
	ngay_xoa timestamp NULL,
	nguoi_xoa varchar NULL,
	CONSTRAINT dm_block_ksk_dich_vu_map_pk PRIMARY KEY (id)
);

CREATE TABLE dm_block_ksk_nhan_vien_map (
	id uuid DEFAULT gen_random_uuid() NOT NULL,
	ma_cskcb varchar NOT NULL,
	ma_khoi_ksk varchar NOT NULL,
	report_code varchar NULL,
	nhan_vien_id uuid NOT NULL,
	ngay_tao timestamp DEFAULT now() NULL,
	nguoi_tao varchar NULL,
	ngay_cap_nhat timestamp DEFAULT now() NULL,
	nguoi_cap_nhat varchar NULL,
	bi_xoa int2 DEFAULT 0 NOT NULL,
	ngay_xoa timestamp NULL,
	nguoi_xoa varchar NULL,
	report_block_map_id uuid NOT NULL,
	CONSTRAINT dm_block_ksk_nhan_vien_map_pk PRIMARY KEY (id)
);

CREATE TABLE dm_block_ksk_report_code_map (
	report_code varchar NOT NULL, -- Report code
	block_code varchar NOT NULL, -- Mã khối khám
	id uuid DEFAULT gen_random_uuid() NOT NULL, -- Key của bảng
	ngay_tao timestamp DEFAULT now() NOT NULL, -- Ngày tạo
	nguoi_tao varchar DEFAULT 'system'::character varying NOT NULL, -- Người tạo
	ngay_cap_nhat timestamp DEFAULT now() NOT NULL, -- Ngày cập nhật
	nguoi_cap_nhat varchar DEFAULT 'system'::character varying NOT NULL, -- Người cập nhật
	bi_xoa int2 DEFAULT 0 NULL, -- Bị xóa mềm
	ngay_xoa timestamp NULL, -- Ngày xóa mềm
	nguoi_xoa varchar NULL, -- Người xóa mềm
	CONSTRAINT dm_block_ksk_report_code_map_pkey PRIMARY KEY (id)
);

CREATE TABLE dm_buong (
	ma_buong varchar(25) NOT NULL,
	ten_buong varchar(255) NOT NULL,
	id uuid DEFAULT gen_random_uuid() NOT NULL, -- Key của bảng
	ngay_tao timestamp DEFAULT now() NOT NULL, -- Ngày tạo
	nguoi_tao varchar(100) DEFAULT 'system'::character varying NOT NULL, -- Người tạo
	ngay_cap_nhat timestamp DEFAULT now() NOT NULL, -- Ngày cập nhật
	nguoi_cap_nhat varchar(100) DEFAULT 'system'::character varying NOT NULL, -- Người cập nhật
	bi_xoa int2 DEFAULT 0 NULL, -- Bị xóa mềm
	ngay_xoa timestamp NULL, -- Ngày xóa mềm
	nguoi_xoa varchar(100) NULL, -- Người xóa mềm
	CONSTRAINT dm_buong_pkey PRIMARY KEY (id)
);

CREATE TABLE dm_canh_bao_tvt (
	ten_canh_bao varchar NULL,
	canh_bao_id int4 NULL,
	su_dung bool DEFAULT true NULL,
	id uuid DEFAULT gen_random_uuid() NOT NULL, -- Key của bảng
	ngay_tao timestamp DEFAULT now() NOT NULL, -- Ngày tạo
	nguoi_tao varchar(100) DEFAULT 'system'::character varying NOT NULL, -- Người tạo
	ngay_cap_nhat timestamp DEFAULT now() NOT NULL, -- Ngày cập nhật
	nguoi_cap_nhat varchar(100) DEFAULT 'system'::character varying NOT NULL, -- Người cập nhật
	bi_xoa int2 DEFAULT 0 NULL, -- Bị xóa mềm
	ngay_xoa timestamp NULL, -- Ngày xóa mềm
	nguoi_xoa varchar(100) NULL, -- Người xóa mềm
	CONSTRAINT dm_canh_bao_tvt_pkey PRIMARY KEY (id)
);

CREATE TABLE dm_cap_do_tuong_tac (
	capdo int4 NULL,
	code varchar NULL,
	tencapdo varchar NULL,
	mota text NULL,
	id uuid DEFAULT gen_random_uuid() NOT NULL, -- Key của bảng
	ngay_tao timestamp DEFAULT now() NOT NULL, -- Ngày tạo
	nguoi_tao varchar DEFAULT 'system'::character varying NOT NULL, -- Người tạo
	ngay_cap_nhat timestamp DEFAULT now() NOT NULL, -- Ngày cập nhật
	nguoi_cap_nhat varchar DEFAULT 'system'::character varying NOT NULL, -- Người cập nhật
	bi_xoa int2 DEFAULT 0 NULL, -- Bị xóa mềm
	ngay_xoa timestamp NULL, -- Ngày xóa mềm
	nguoi_xoa varchar NULL, -- Người xóa mềm
	sudung bool NULL,
	CONSTRAINT dm_cap_do_tuong_tac_pkey PRIMARY KEY (id)
);

CREATE TABLE dm_cap_ky_phieu (
	id uuid DEFAULT gen_random_uuid() NOT NULL,
	dm_phieu_ky_so_id uuid NOT NULL,
	ma_cap_ky varchar(50) NOT NULL, -- Mã định danh cấp ký (VD: CAP_1, CAP_DUYET)
	ten_cap_ky varchar(255) NOT NULL, -- Tên hiển thị cấp ký
	thu_tu_ky int4 NOT NULL, -- Thứ tự cấp ký (ký cấp 1 xong mới đến cấp 2)
	bat_buoc_ky int2 DEFAULT 1 NULL, -- 1: Bắt buộc, 0: Tùy chọn (skip được)
	hoat_dong int2 DEFAULT 1 NULL,
	ngay_tao timestamptz DEFAULT now() NULL,
	nguoi_tao_id uuid NULL,
	CONSTRAINT dm_cap_ky_phieu_dm_phieu_ky_so_id_ma_cap_ky_key UNIQUE (dm_phieu_ky_so_id, ma_cap_ky),
	CONSTRAINT dm_cap_ky_phieu_pkey PRIMARY KEY (id)
);

CREATE TABLE dm_cau_hinh_in (
	ma_cskcb varchar NOT NULL, -- Mã cơ sở khám chữa bệnh
	per_row int4 NOT NULL, -- Số tem/hàng
	copy_num int4 NOT NULL, -- Số bản in
	id uuid DEFAULT gen_random_uuid() NOT NULL, -- Key của bảng
	ngay_tao timestamp DEFAULT now() NOT NULL, -- Ngày tạo
	nguoi_tao varchar(100) DEFAULT 'system'::character varying NOT NULL, -- Người tạo
	ngay_cap_nhat timestamp DEFAULT now() NOT NULL, -- Ngày cập nhật
	nguoi_cap_nhat varchar(100) DEFAULT 'system'::character varying NOT NULL, -- Người cập nhật
	bi_xoa int2 DEFAULT 0 NULL, -- Bị xóa mềm
	ngay_xoa timestamp NULL, -- Ngày xóa mềm
	nguoi_xoa varchar(100) NULL, -- Người xóa mềm
	CONSTRAINT dm_cau_hinh_in_pkey PRIMARY KEY (id)
);

CREATE TABLE dm_cau_hinh_kb_giai_phau_benh (
	id uuid DEFAULT gen_random_uuid() NOT NULL, -- Id của bảng chính
	ma varchar(50) NOT NULL, -- Mã của tế bào
	ten varchar(500) NOT NULL, -- Tên kết quả
	cap_do int4 NOT NULL, -- 1: Cha lớn, 2: Con, 3: Cháu...
	ma_cskcb varchar(100) NULL, -- Mã CSKCB
	ngay_tao timestamp DEFAULT now() NOT NULL, -- Ngày tạo
	nguoi_tao varchar(100) DEFAULT 'system'::character varying NOT NULL, -- Người tạo
	ngay_cap_nhat timestamp DEFAULT now() NOT NULL, -- Ngày cập nhật
	nguoi_cap_nhat varchar(100) DEFAULT 'system'::character varying NOT NULL, -- Người cập nhật
	bi_xoa int2 DEFAULT 0 NULL, -- Bị xóa mềm
	ngay_xoa timestamp NULL, -- Ngày xóa mềm
	nguoi_xoa varchar(100) NULL, -- Người xóa mềm
	CONSTRAINT dm_cau_hinh_kb_giai_phau_benh_pkey PRIMARY KEY (id)
);

CREATE TABLE dm_cau_hinh_ky_cap (
	ma_report varchar NOT NULL, -- Mã report
	vi_tri varchar(10) NULL, -- Vị trí
	mo_ta text NULL, -- Mô tả
	is_ky_nhom int2 NULL, -- Là ký nhóm
	ma_nhom varchar NULL, -- Mã nhóm
	id uuid DEFAULT gen_random_uuid() NOT NULL, -- Key của bảng
	ngay_tao timestamp DEFAULT now() NOT NULL, -- Ngày tạo
	nguoi_tao varchar DEFAULT 'system'::character varying NOT NULL, -- Người tạo
	ngay_cap_nhat timestamp DEFAULT now() NOT NULL, -- Ngày cập nhật
	nguoi_cap_nhat varchar DEFAULT 'system'::character varying NOT NULL, -- Người cập nhật
	bi_xoa int2 DEFAULT 0 NULL, -- Bị xóa mềm
	ngay_xoa timestamp NULL, -- Ngày xóa mềm
	nguoi_xoa varchar NULL, -- Người xóa mềm
	ma_loai_ky varchar(100) NULL, -- Mã loại ký số
	phieu_ky_so_id uuid NULL, -- FK: dmc_phieu_ky_so
	cap_ky int4 NULL, -- Cấp ký
	ma_cskcb varchar NULL,
	pl_bao_cao_id uuid NULL,
	ma_phuong_thuc_ky varchar NULL,
	dong_dau_don_vi int2 DEFAULT 0 NULL,
	la_doituong int2 NULL, -- 1: nhân viên; 2: bệnh nhân
	la_kychot int2 DEFAULT 0 NULL,
	ds_ma_nhom _varchar DEFAULT ARRAY[]::character varying[] NULL,
	ds_ma_phuong_thuc_ky _varchar DEFAULT ARRAY[]::character varying[] NULL,
	CONSTRAINT dm_cau_hinh_ky_cap_pkey PRIMARY KEY (id)
);

CREATE TABLE dm_cau_hinh_ky_so (
	ma_report varchar NOT NULL, -- Mã report
	ma_phuong_thuc_huy_ky varchar NULL, -- Mã phương thức hủy ký
	ma_phuong_thuc_ky_nhan_vien varchar NULL, -- Mã phương thức ký nhân viên
	ma_phuong_thuc_ky_benh_nhan varchar NULL, -- Mã phương thức ký bệnh nhân
	ma_phuong_thuc_ky_chot varchar NULL, -- Mã phương thức ký chốt
	dong_dau_don_vi int2 NULL, -- Đóng dấu đơn vị
	id uuid DEFAULT gen_random_uuid() NOT NULL, -- Key của bảng
	ngay_tao timestamp DEFAULT now() NOT NULL, -- Ngày tạo
	nguoi_tao varchar DEFAULT 'system'::character varying NOT NULL, -- Người tạo
	ngay_cap_nhat timestamp DEFAULT now() NOT NULL, -- Ngày cập nhật
	nguoi_cap_nhat varchar DEFAULT 'system'::character varying NOT NULL, -- Người cập nhật
	bi_xoa int2 DEFAULT 0 NULL, -- Bị xóa mềm
	ngay_xoa timestamp NULL, -- Ngày xóa mềm
	nguoi_xoa varchar NULL, -- Người xóa mềm
	phieu_ky_so_id uuid NULL, -- FK: dmc_phieu_ky_so
	ma_cskcb varchar NULL,
	pl_bao_cao_id uuid NULL,
	ma_loai_ky varchar NULL,
	CONSTRAINT dm_cau_hinh_ky_so_phieu_ky_so_id_key UNIQUE (phieu_ky_so_id),
	CONSTRAINT dm_cau_hinh_ky_so_pkey PRIMARY KEY (id)
);

CREATE TABLE dm_cau_hinh_loai_xe (
	ten_loai_xe varchar NULL,
	ma varchar(50) NOT NULL,
	stt int4 NULL,
	dinh_muc_nhien_lieu_min numeric NULL,
	dinh_muc_nhien_lieu_max numeric NULL,
	su_dung bool DEFAULT true NULL,
	ma_cskcb varchar(50) NULL,
	id uuid DEFAULT gen_random_uuid() NOT NULL, -- Key của bảng
	ngay_tao timestamp DEFAULT now() NOT NULL, -- Ngày tạo
	nguoi_tao varchar(100) DEFAULT 'system'::character varying NOT NULL, -- Người tạo
	ngay_cap_nhat timestamp DEFAULT now() NOT NULL, -- Ngày cập nhật
	nguoi_cap_nhat varchar(100) DEFAULT 'system'::character varying NOT NULL, -- Người cập nhật
	bi_xoa int2 DEFAULT 0 NULL, -- Bị xóa mềm
	ngay_xoa timestamp NULL, -- Ngày xóa mềm
	nguoi_xoa varchar(100) NULL, -- Người xóa mềm
	CONSTRAINT dm_cau_hinh_loai_xe_pkey PRIMARY KEY (id)
);

CREATE TABLE dm_chbc_nhom_bao_cao (
	ten_nhom varchar(255) NOT NULL,
	ma_nhom varchar(25) NOT NULL,
	ghi_chu varchar(255) NULL,
	id uuid DEFAULT gen_random_uuid() NOT NULL, -- Key của bảng
	ngay_tao timestamp DEFAULT now() NOT NULL, -- Ngày tạo
	nguoi_tao varchar(100) DEFAULT '''system'''::character varying NOT NULL, -- Người tạo
	ngay_cap_nhat timestamp DEFAULT now() NOT NULL, -- Ngày cập nhật
	nguoi_cap_nhat varchar(100) DEFAULT '''system'''::character varying NOT NULL, -- Người cập nhật
	bi_xoa int2 DEFAULT 0 NULL, -- Bị xóa mềm
	ngay_xoa timestamp NULL, -- Ngày xóa mềm
	nguoi_xoa varchar(100) NULL, -- Người xóa mềm
	su_dung int2 DEFAULT 1 NOT NULL,
	CONSTRAINT dm_chbc_nhom_bao_cao_pk_id PRIMARY KEY (id)
);

CREATE TABLE dm_che_do_an (
	ma_che_do_an varchar(25) NOT NULL,
	ten_che_do_an varchar(255) NOT NULL,
	id uuid DEFAULT gen_random_uuid() NOT NULL, -- Key của bảng
	ngay_tao timestamp DEFAULT now() NOT NULL, -- Ngày tạo
	nguoi_tao varchar(100) DEFAULT 'system'::character varying NOT NULL, -- Người tạo
	ngay_cap_nhat timestamp DEFAULT now() NOT NULL, -- Ngày cập nhật
	nguoi_cap_nhat varchar(100) DEFAULT 'system'::character varying NOT NULL, -- Người cập nhật
	bi_xoa int2 DEFAULT 0 NULL, -- Bị xóa mềm
	ngay_xoa timestamp NULL, -- Ngày xóa mềm
	nguoi_xoa varchar(100) NULL, -- Người xóa mềm
	CONSTRAINT dm_che_do_an_pkey PRIMARY KEY (id)
);

CREATE TABLE dm_che_do_cham_soc (
	ma_che_do_cham_soc varchar(25) NOT NULL,
	ten_che_do_cham_soc varchar(255) NOT NULL,
	id uuid DEFAULT gen_random_uuid() NOT NULL, -- Key của bảng
	ngay_tao timestamp DEFAULT now() NOT NULL, -- Ngày tạo
	nguoi_tao varchar(100) DEFAULT 'system'::character varying NOT NULL, -- Người tạo
	ngay_cap_nhat timestamp DEFAULT now() NOT NULL, -- Ngày cập nhật
	nguoi_cap_nhat varchar(100) DEFAULT 'system'::character varying NOT NULL, -- Người cập nhật
	bi_xoa int2 DEFAULT 0 NULL, -- Bị xóa mềm
	ngay_xoa timestamp NULL, -- Ngày xóa mềm
	nguoi_xoa varchar(100) NULL, -- Người xóa mềm
	CONSTRAINT dm_che_do_cham_soc_pkey PRIMARY KEY (id)
);

CREATE TABLE dm_che_do_dinh_duong (
	ten_che_do_dd varchar(255) NOT NULL,
	ma_che_do_dd varchar(25) NOT NULL,
	id uuid DEFAULT gen_random_uuid() NOT NULL, -- Key của bảng
	ngay_tao timestamp DEFAULT now() NOT NULL, -- Ngày tạo
	nguoi_tao varchar(100) DEFAULT 'system'::character varying NOT NULL, -- Người tạo
	ngay_cap_nhat timestamp DEFAULT now() NOT NULL, -- Ngày cập nhật
	nguoi_cap_nhat varchar(100) DEFAULT 'system'::character varying NOT NULL, -- Người cập nhật
	bi_xoa int2 DEFAULT 0 NULL, -- Bị xóa mềm
	ngay_xoa timestamp NULL, -- Ngày xóa mềm
	nguoi_xoa varchar(100) NULL, -- Người xóa mềm
	CONSTRAINT dm_che_do_dinh_duong_pkey PRIMARY KEY (id)
);

CREATE TABLE dm_chi_phi_phat_sinh (
	ma varchar NOT NULL, -- Mã chi phí phát sinh
	ten varchar NOT NULL, -- Tên chi phí phát sinh
	id uuid DEFAULT gen_random_uuid() NOT NULL, -- Key của bảng
	ngay_tao timestamp DEFAULT now() NOT NULL, -- Ngày tạo
	nguoi_tao varchar DEFAULT 'system'::character varying NOT NULL, -- Người tạo
	ngay_cap_nhat timestamp DEFAULT now() NOT NULL, -- Ngày cập nhật
	nguoi_cap_nhat varchar DEFAULT 'system'::character varying NOT NULL, -- Người cập nhật
	bi_xoa int2 DEFAULT 0 NULL, -- Bị xóa mềm
	ngay_xoa timestamp NULL, -- Ngày xóa mềm
	nguoi_xoa varchar NULL, -- Người xóa mềm
	CONSTRAINT dm_chi_phi_phat_sinh_ma_key UNIQUE (ma),
	CONSTRAINT dm_chi_phi_phat_sinh_pkey PRIMARY KEY (id)
);

CREATE TABLE dm_chong_chi_dinh (
	chong_chi_dinh_id int4 NULL,
	ten_chong_chi_dinh varchar NULL,
	su_dung bool DEFAULT true NULL,
	id uuid DEFAULT gen_random_uuid() NOT NULL, -- Key của bảng
	ngay_tao timestamp DEFAULT now() NOT NULL, -- Ngày tạo
	nguoi_tao varchar(100) DEFAULT 'system'::character varying NOT NULL, -- Người tạo
	ngay_cap_nhat timestamp DEFAULT now() NOT NULL, -- Ngày cập nhật
	nguoi_cap_nhat varchar(100) DEFAULT 'system'::character varying NOT NULL, -- Người cập nhật
	bi_xoa int2 DEFAULT 0 NULL, -- Bị xóa mềm
	ngay_xoa timestamp NULL, -- Ngày xóa mềm
	nguoi_xoa varchar(100) NULL, -- Người xóa mềm
	CONSTRAINT dm_chong_chi_dinh_pkey PRIMARY KEY (id)
);

CREATE TABLE dm_chuc_danh (
	ma int4 NOT NULL,
	tenchucdanh varchar NULL,
	nhomchucdanhid uuid NULL,
	cchn varchar NULL,
	diengiai text NULL,
	id uuid DEFAULT gen_random_uuid() NOT NULL,
	deleted_at timestamp NULL,
	created_at timestamp DEFAULT now() NOT NULL,
	created_by text NOT NULL,
	updated_at timestamp DEFAULT now() NOT NULL,
	updated_by text NOT NULL,
	CONSTRAINT dm_chuc_danh_id_key UNIQUE (id),
	CONSTRAINT dm_chuc_danh_ma_key UNIQUE (ma),
	CONSTRAINT dm_chuc_danh_pkey PRIMARY KEY (id)
);

CREATE TABLE dm_chuc_vu (
	ma int8 NULL,
	ten_chuc_vu varchar NOT NULL,
	id uuid DEFAULT gen_random_uuid() NOT NULL,
	ngay_tao timestamp DEFAULT now() NOT NULL,
	nguoi_tao varchar DEFAULT 'system'::character varying NOT NULL,
	ngay_cap_nhat timestamp DEFAULT now() NOT NULL,
	nguoi_cap_nhat varchar DEFAULT 'system'::character varying NOT NULL,
	bi_xoa int2 DEFAULT 0 NULL,
	ngay_xoa timestamp NULL,
	nguoi_xoa varchar NULL,
	nhom_ky_cap_id uuid NULL,
	CONSTRAINT dm_chuc_vu_id_key UNIQUE (id),
	CONSTRAINT dm_chuc_vu_pkey PRIMARY KEY (id)
);

CREATE TABLE dm_chuong_icd10 (
	ma int4 NULL, -- Mã
	ten varchar(500) NULL, -- Tên
	ten_en varchar(500) NULL, -- Tên tiếng anh
	sudung bool NULL, -- Sử dụng(0: Không; 1: Có)
	id uuid DEFAULT gen_random_uuid() NOT NULL,
	ngay_tao timestamp DEFAULT now() NOT NULL,
	nguoi_tao text NOT NULL,
	ngay_cap_nhat timestamp DEFAULT now() NOT NULL,
	nguoi_cap_nhat text NOT NULL,
	ma_cskcb varchar(100) NULL,
	bi_xoa int2 DEFAULT 0 NOT NULL,
	ngay_xoa timestamp NULL,
	nguoi_xoa varchar(100) NULL,
	CONSTRAINT dm_chuong_icd10_pkey PRIMARY KEY (id)
);

CREATE TABLE dm_chuong_icd9 (
	ma_chuong varchar NOT NULL,
	ten_chuong varchar NOT NULL,
	ten_tieng_anh varchar NULL,
	cap int4 NULL,
	ten_khong_dau varchar NULL,
	ghi_chu varchar NULL,
	su_dung bool NULL,
	id uuid DEFAULT gen_random_uuid() NOT NULL,
	ngay_tao timestamp DEFAULT now() NOT NULL,
	nguoi_tao varchar DEFAULT 'system'::character varying NOT NULL,
	ngay_cap_nhat timestamp DEFAULT now() NOT NULL,
	nguoi_cap_nhat varchar DEFAULT 'system'::character varying NOT NULL,
	bi_xoa int2 DEFAULT 0 NULL,
	ngay_xoa timestamp NULL,
	nguoi_xoa varchar NULL,
	cap_tren_id uuid NULL,
	ma_cskcb varchar(100) NULL,
	cap_tren_ten varchar(255) NULL,
	CONSTRAINT dm_chuong_icd9_ma_chuong_key UNIQUE (ma_chuong),
	CONSTRAINT dm_chuong_icd9_pkey PRIMARY KEY (id)
);

CREATE TABLE dm_chuong_icd9_cm (
	id uuid DEFAULT gen_random_uuid() NOT NULL,
	ma_benh_icd9 varchar(50) NOT NULL,
	ten_benh_icd9 varchar(255) NOT NULL,
	ten_tieng_anh varchar(255) NULL,
	ten_su_dung varchar(255) NULL,
	chuong_icd9_id uuid NULL,
	su_dung bool NULL,
	nguoi_tao varchar(100) DEFAULT 'system'::character varying NOT NULL,
	ngay_tao timestamp DEFAULT now() NOT NULL,
	nguoi_cap_nhat varchar(100) DEFAULT 'system'::character varying NOT NULL,
	ngay_cap_nhat timestamp DEFAULT now() NOT NULL,
	bi_xoa int2 DEFAULT 0 NULL,
	nguoi_xoa varchar(100) NULL,
	ngay_xoa timestamp NULL,
	mo_ta text NULL,
	ma_chuong_icd9 varchar(255) NULL,
	ten_chuong_icd9 text NULL,
	ma_nhom_chuong_cap_2 text NULL,
	ten_nhom_chuong_cap_2 text NULL,
	ma_nhom_chuong_cap_3 text NULL,
	ten_nhom_chuong_cap_3 text NULL,
	CONSTRAINT dm_chuong_icd9_cm_pkey PRIMARY KEY (id)
);

CREATE TABLE dm_chuongicd10 (
	icd_chuong_id int4 NULL,
	machuongicd int4 NULL,
	tenchuongicd varchar(500) NULL,
	tenchuongicd_en varchar(500) NULL,
	sudung bool NULL,
	id uuid DEFAULT gen_random_uuid() NOT NULL, -- Key của bảng
	deleted_at timestamp NULL, -- Ngày xóa mềm
	created_at timestamp DEFAULT now() NOT NULL, -- Ngày tạo
	created_by text NOT NULL, -- Người tạo
	updated_at timestamp DEFAULT now() NOT NULL, -- Ngày cập nhật
	updated_by text NOT NULL, -- Người cập nhật
	nguoi_xoa varchar(100) NULL, -- Người xóa mềm
	bi_xoa int2 DEFAULT 0 NULL, -- Bị xóa mềm
	CONSTRAINT dm_chuongicd10_pk_id PRIMARY KEY (id)
);

CREATE TABLE dm_chuyen_khoa (
	id uuid DEFAULT gen_random_uuid() NOT NULL, -- Key của bảng
	ma_chuyen_khoa varchar(25) NOT NULL,
	ten_chuyen_khoa varchar(255) NOT NULL,
	ghi_chu varchar(255) NULL,
	ten_khong_dau varchar(255) NULL,
	so_thu_tu int2 NULL,
	su_dung bool DEFAULT true NULL, -- Sử dụng
	bi_xoa int2 DEFAULT 0 NULL, -- Bị xóa mềm
	ngay_xoa timestamp NULL, -- Ngày xóa mềm
	ngay_tao timestamp DEFAULT now() NOT NULL, -- Ngày tạo
	nguoi_tao varchar(100) DEFAULT 'system'::character varying NOT NULL, -- Người tạo
	ngay_cap_nhat timestamp DEFAULT now() NOT NULL, -- Ngày cập nhật
	nguoi_cap_nhat varchar(100) DEFAULT 'system'::character varying NOT NULL, -- Người cập nhật
	nguoi_xoa varchar(100) NULL, -- Người xóa mềm
	CONSTRAINT dm_chuyen_khoa_ma_chuyen_khoa_key UNIQUE (ma_chuyen_khoa),
	CONSTRAINT dm_chuyen_khoa_pkey PRIMARY KEY (id)
);

CREATE TABLE dm_co_so_tu_truc (
	khoid varchar NULL,
	thuocvattuid varchar NULL,
	so_luong int4 NULL,
	id uuid DEFAULT gen_random_uuid() NOT NULL,
	deleted_at timestamp NULL,
	created_at timestamp DEFAULT now() NOT NULL,
	created_by text NOT NULL,
	updated_at timestamp DEFAULT now() NOT NULL,
	updated_by text NOT NULL,
	su_dung int2 DEFAULT 1 NULL,
	CONSTRAINT dm_co_so_tu_truc_id_key UNIQUE (id),
	CONSTRAINT dm_co_so_tu_truc_pkey PRIMARY KEY (id)
);

CREATE TABLE dm_cong_tich_hop (
	ma_cong_tich_hop varchar(25) NOT NULL, -- Mã cổng tích hợp
	ten_cong_tich_hop varchar(255) NOT NULL, -- Tên cổng tích hợp
	stt int4 NULL, -- Số thứ tự
	su_dung bool DEFAULT true NULL, -- Sử dụng
	id uuid DEFAULT gen_random_uuid() NOT NULL, -- Key của bảng
	ngay_tao timestamp DEFAULT now() NOT NULL, -- Ngày tạo
	nguoi_tao varchar(100) DEFAULT '''system'''::character varying NOT NULL, -- Người tạo
	ngay_cap_nhat timestamp DEFAULT now() NOT NULL, -- Ngày cập nhật
	nguoi_cap_nhat varchar(100) DEFAULT '''system'''::character varying NOT NULL, -- Người cập nhật
	bi_xoa int2 DEFAULT 0 NULL, -- Bị xóa mềm
	ngay_xoa timestamp NULL, -- Ngày xóa mềm
	nguoi_xoa varchar(100) NULL, -- Người xóa mềm
	CONSTRAINT dm_cong_tich_hop_pkey PRIMARY KEY (id)
);

CREATE TABLE dm_cong_viec (
	ten varchar NULL,
	ma varchar NULL,
	ma_cskcb varchar NULL,
	su_dung bool NULL,
	stt int4 NULL,
	id uuid DEFAULT gen_random_uuid() NOT NULL, -- Key của bảng
	ngay_tao timestamp DEFAULT now() NOT NULL, -- Ngày tạo
	nguoi_tao varchar(100) DEFAULT '''system'''::character varying NOT NULL, -- Người tạo
	ngay_cap_nhat timestamp DEFAULT now() NOT NULL, -- Ngày cập nhật
	nguoi_cap_nhat varchar(100) DEFAULT '''system'''::character varying NOT NULL, -- Người cập nhật
	bi_xoa int2 DEFAULT 0 NULL, -- Bị xóa mềm
	ngay_xoa timestamp NULL, -- Ngày xóa mềm
	nguoi_xoa varchar(100) NULL, -- Người xóa mềm
	CONSTRAINT dm_cong_viec_pk_id PRIMARY KEY (id)
);

CREATE TABLE dm_csyt_backup (
	macsyt varchar NULL,
	tencsyt varchar NULL,
	tinh int4 NULL,
	xa int4 NULL,
	tochuc_id int4 NULL,
	diachi_chitiet varchar NULL,
	loaihinh_id varchar NULL,
	hinhthuc_id int4 NULL,
	sudung bool NULL,
	id uuid DEFAULT gen_random_uuid() NOT NULL,
	deleted_at timestamp NULL,
	created_at timestamp DEFAULT now() NOT NULL,
	created_by text NOT NULL,
	updated_at timestamp DEFAULT now() NOT NULL,
	updated_by text NOT NULL,
	CONSTRAINT dm_csyt_backup_pkey PRIMARY KEY (id)
);

CREATE TABLE dm_csyt_dich_vu (
	csyt_id uuid NOT NULL,
	dich_vu_id uuid NOT NULL,
	id uuid DEFAULT gen_random_uuid() NOT NULL,
	deleted_at timestamp NULL,
	created_at timestamp DEFAULT now() NOT NULL,
	created_by text NOT NULL,
	updated_at timestamp DEFAULT now() NOT NULL,
	updated_by text NOT NULL,
	CONSTRAINT dm_csyt_dich_vu_pkey PRIMARY KEY (id)
);

CREATE TABLE dm_dang_bao_che (
	ten varchar NULL,
	id uuid DEFAULT gen_random_uuid() NOT NULL, -- Key của bảng
	ngay_tao timestamp DEFAULT now() NOT NULL, -- Ngày tạo
	nguoi_tao varchar DEFAULT 'system'::character varying NOT NULL, -- Người tạo
	ngay_cap_nhat timestamp DEFAULT now() NOT NULL, -- Ngày cập nhật
	nguoi_cap_nhat varchar DEFAULT 'system'::character varying NOT NULL, -- Người cập nhật
	bi_xoa int2 DEFAULT 0 NULL, -- Bị xóa mềm
	ngay_xoa timestamp NULL, -- Ngày xóa mềm
	nguoi_xoa varchar NULL, -- Người xóa mềm
	ma varchar(50) DEFAULT '1' NOT NULL,
	ghi_chu varchar(500) NULL,
	CONSTRAINT dm_dang_bao_che_pkey PRIMARY KEY (id)
);

CREATE TABLE dm_dich_vu_kt (
	id uuid DEFAULT gen_random_uuid() NOT NULL, -- Key của bảng
	ma_cskcb varchar(25) NULL, -- Mã CSKCB
	ma varchar(25) NOT NULL, -- Mã dịch vụ
	ma_byt varchar(25) NULL, -- Mã dùng chung
	ma_benh_vien varchar(25) NULL, -- Mã dịch vụ bệnh viện
	nhom_dich_vu_id uuid NULL, -- ID Nhóm dịch vụ
	ten_dich_vu varchar(255) NULL, -- Tên dịch vụ
	ten_byt varchar(255) NULL, -- Tên tương đương theo BYT
	ten_loinc varchar(255) NULL, -- Tên LOINC
	ma_tt_37 varchar(25) NULL, -- Mã thông tư 37
	ten_tt_37 varchar(255) NULL, -- Tên thông tư 37
	don_vi_tinh varchar(50) NULL, -- Đơn vị tính
	bhyt bool DEFAULT false NULL, -- Đánh dấu dịch vụ bhyt
	loai_goi int2 NULL, -- Combobox (Rỗng, Gói KSK, Tiêm chủng)
	ma_43_50 varchar(50) NULL, -- Mã thông tư 43-50
	phan_tuyen int2 NULL, -- Combobox (A, B, C, D, rỗng)
	loai_phau_thuat varchar(50) NULL, -- Loại đặc biệt, Loại I, Loại II, Loại III
	chuyen_khoa_id uuid NULL, -- FK: dm_chuyen_khoa
	nhom_bhyt_id uuid NULL, -- FK: dm_ma_nhom_chi_phi
	nhom_hdvp_id uuid NULL, -- FK: dm_nhom_hdvp
	report_cd varchar NULL, -- report Code
	report_kq varchar NULL, -- Report_KQ
	tg_chi_dinh timestamp DEFAULT now() NULL, -- Thời gian chỉ định
	loai_mbp_id uuid NULL, -- FJ: dm_loai_mau
	hoan_thanh bool DEFAULT false NULL, -- Tự động hoàn thành khi chỉ định
	check_kt_ba bool DEFAULT false NULL, -- Không check khi kết thúc HSBA
	ghep_thuoc bool DEFAULT false NULL, -- Ghép mã thuốc khi sử dụng thuốc đi kèm
	tach_hdvp bool DEFAULT false NULL, -- Tách hóa đơn
	khoang_cach numeric NULL, -- Khoảng cách
	nguon_ct_id uuid NULL, -- FK: dm_nguon_ct
	su_dung bool DEFAULT true NULL, -- Sử dụng
	khong_tra_kq bool DEFAULT false NULL, -- Dịch vụ không trả kết quả
	tra_kq_sau bool DEFAULT false NULL, -- Dịch vụ trả kết quả sau
	co_chi_so_con bool NULL, -- Có chỉ số con
	ngay_tao timestamp DEFAULT now() NOT NULL, -- Ngày tạo
	nguoi_tao varchar(100) DEFAULT 'system'::character varying NOT NULL, -- Người tạo
	ngay_cap_nhat timestamp DEFAULT now() NOT NULL, -- Ngày cập nhật
	nguoi_cap_nhat varchar(100) DEFAULT 'system'::character varying NOT NULL, -- Người cập nhật
	bi_xoa int2 DEFAULT 0 NULL, -- Bị xóa(0: Không; 1: Có)
	ngay_xoa timestamp NULL, -- Ngày xóa mềm
	nguoi_xoa text NULL, -- Người xóa
	ma_nhom_dich_vu varchar(25) NULL,
	duoc_chi_dinh_so_luong bool NULL, -- Dịch vụ được chỉ định số lượng lớn hơn 1
	thoi_gian_toi_thieu int4 NULL, -- Thời gian tối thiểu để thực hiện dịch vụ
	thoi_gian_toi_da int4 NULL, -- thời gian tối đa để thực hiện dịch vụ
	so_thu_tu int4 NULL,
	CONSTRAINT dm_dich_vu_kt_ma_cskcb_ma_key UNIQUE (ma_cskcb, ma),
	CONSTRAINT dm_dich_vu_kt_pk_id PRIMARY KEY (id)
);

CREATE TABLE dm_dich_vu_loai_gia (
	id uuid DEFAULT gen_random_uuid() NOT NULL,
	loai_gia_id uuid NOT NULL,
	so_qd_gia varchar(255) NULL,
	ngay_qd date NULL,
	dich_vu_id uuid NOT NULL,
	don_gia numeric NULL,
	stt int4 NULL,
	ngay_ap_dung date NULL,
	loai_hinh_ap_dung varchar(25) NULL,
	ngay_tao timestamp DEFAULT now() NOT NULL,
	nguoi_tao varchar(100) NOT NULL,
	ngay_cap_nhat timestamp DEFAULT now() NOT NULL,
	nguoi_cap_nhat varchar(100) NOT NULL,
	ma_cskcb varchar(100) NULL,
	bi_xoa int2 DEFAULT 0 NOT NULL,
	ngay_xoa timestamp NULL,
	nguoi_xoa varchar(100) NULL,
	ma_dich_vu varchar(25) NULL,
	ma_loai_gia varchar(25) NULL,
	ma_dich_vu_loai_gia varchar(50) NULL,
	su_dung int2 DEFAULT 0 NOT NULL,
	baseline int2 DEFAULT 0 NOT NULL,
	phu_thu int2 DEFAULT 0 NOT NULL,
	lan_phat_hanh int4 NULL,
	CONSTRAINT dm_dich_vu_loai_gia_pkey PRIMARY KEY (id)
);

CREATE TABLE dm_dich_vu_loai_gia_da_phat_hanh (
	loai_gia_id uuid NOT NULL, -- ID Loại giá
	so_qd_gia varchar(255) NULL, -- Số quyết định
	ngay_qd date NULL, -- Ngày quyết định
	dich_vu_id uuid NOT NULL, -- ID Dịch vụ
	don_gia numeric DEFAULT 0 NOT NULL, -- Đơn giá
	stt int4 DEFAULT 0 NOT NULL, -- Số thứ tự
	ngay_ap_dung date NOT NULL, -- Ngày áp dụng
	loai_hinh_ap_dung varchar(25) NULL, -- Loại hình áp dụng
	ma_cskcb varchar(100) NULL, -- Mã cơ sở khám chữa bệnh
	ma_dich_vu varchar(25) NOT NULL, -- Mã dịch vụ
	ma_loai_gia varchar(25) NOT NULL, -- Mã loại giá
	ma_dich_vu_loai_gia varchar(50) NOT NULL, -- Mã dịch vụ loại giá
	su_dung int2 DEFAULT 0 NOT NULL, -- 1: Hiệu lực 0: Không hiệu lực
	baseline int2 DEFAULT 0 NOT NULL, -- Giá baseline
	phu_thu int2 DEFAULT 0 NOT NULL, -- Phụ thu
	id uuid DEFAULT gen_random_uuid() NOT NULL, -- Key của bảng
	ngay_tao timestamp DEFAULT now() NOT NULL, -- Ngày tạo
	nguoi_tao varchar(100) DEFAULT 'system'::character varying NOT NULL, -- Người tạo
	ngay_cap_nhat timestamp DEFAULT now() NOT NULL, -- Ngày cập nhật
	nguoi_cap_nhat varchar(100) DEFAULT 'system'::character varying NOT NULL, -- Người cập nhật
	bi_xoa int2 DEFAULT 0 NULL, -- Bị xóa mềm
	ngay_xoa timestamp NULL, -- Ngày xóa mềm
	nguoi_xoa varchar(100) NULL, -- Người xóa mềm
	lan_phat_hanh int4 NULL, -- Lần phát hành
	dich_vu_loai_gia_id uuid NOT NULL, -- ID dịch vụ loại giá
	ngay_tiep_nhan date NULL, -- Áp dụng cho ngày tiếp nhận trước ngày
	CONSTRAINT dm_dich_vu_loai_gia_da_phat_hanh_pkey PRIMARY KEY (id)
);

CREATE TABLE dm_dich_vu_loai_gia_phat_hanh_log (
	loai_gia_id uuid NOT NULL, -- ID loại giáo
	so_qd_gia varchar(255) NULL, -- Số quyết định
	ngay_qd date NULL, -- Ngày quyết định
	dich_vu_id uuid NOT NULL, -- ID Dịch vụ
	don_gia numeric DEFAULT 0 NOT NULL, -- Đơn giá
	stt int4 DEFAULT 0 NOT NULL, -- Số thứ tự
	ngay_ap_dung date NULL, -- Ngày áp dụng
	loai_hinh_ap_dung varchar(25) NULL, -- Loại hình áp dụng
	ma_cskcb varchar(100) NULL, -- Mã cơ sở khám chữa bệnh
	ma_dich_vu varchar(25) NOT NULL, -- Mã dịch vụ
	ma_loai_gia varchar(25) NOT NULL, -- Mã loại giá
	ma_dich_vu_loai_gia varchar(100) NOT NULL, -- Mã dịch vụ loại giá
	su_dung int2 DEFAULT 0 NOT NULL, -- Sử dụng
	baseline int2 DEFAULT 0 NOT NULL, -- Baseline giá
	phu_thu int2 DEFAULT 0 NOT NULL, -- Phụ thu
	lan_phat_hanh int4 NULL, -- Lần phát hành
	dich_vu_loai_gia_id uuid NOT NULL, -- ID dịch vụ loại giá
	ngay_tiep_nhan date NULL, -- Ngày tiếp nhận
	id uuid DEFAULT gen_random_uuid() NOT NULL, -- Key của bảng
	ngay_tao timestamp DEFAULT now() NOT NULL, -- Ngày tạo
	nguoi_tao varchar(100) DEFAULT 'system'::character varying NOT NULL, -- Người tạo
	ngay_cap_nhat timestamp DEFAULT now() NOT NULL, -- Ngày cập nhật
	nguoi_cap_nhat varchar(100) DEFAULT 'system'::character varying NOT NULL, -- Người cập nhật
	bi_xoa int2 DEFAULT 0 NULL, -- Bị xóa mềm
	ngay_xoa timestamp NULL, -- Ngày xóa mềm
	nguoi_xoa varchar(100) NULL, -- Người xóa mềm
	thao_tac varchar(500) NULL, -- Thao tác
	CONSTRAINT dm_dich_vu_loai_gia_phat_hanh_log_pkey PRIMARY KEY (id)
);

CREATE TABLE dm_doi_tuong_benh_nhan (
	id uuid DEFAULT gen_random_uuid() NOT NULL, -- Key của bảng
	ma_cskcb varchar(25) NULL,
	ma varchar(25) NULL,
	ten varchar(255) NOT NULL,
	loai_benh_nhan_id int4 DEFAULT 0 NULL, -- 0: Không BHYT; 1: Có BHYT
	chuong_trinh_khuyen_mai int4 DEFAULT 0 NULL,
	nguon_chuong_trinh_id uuid NULL, -- ID Nguồn chương trình
	quyen_loi_id uuid NULL,
	tich_diem int4 NULL,
	ap_dung_tich_diem_id uuid NULL,
	mien_giam int4 NULL,
	thanh_tien_mien_giam numeric NULL,
	ap_dung_tu date NULL,
	ap_dung_den date NULL,
	ghi_chu varchar(255) NULL,
	bi_xoa int2 DEFAULT 0 NULL, -- Bị xóa mềm
	su_dung int4 DEFAULT 1 NULL, -- 0: Không sử dụng; 1: Sử dụng
	ngay_tao timestamp DEFAULT now() NOT NULL, -- Ngày tạo
	nguoi_tao varchar(100) DEFAULT 'system'::character varying NOT NULL, -- Người tạo
	ngay_cap_nhat timestamp DEFAULT now() NOT NULL, -- Ngày cập nhật
	nguoi_cap_nhat varchar(100) DEFAULT 'system'::character varying NOT NULL, -- Người cập nhật
	ngay_xoa timestamp NULL, -- Ngày xóa mềm
	nguoi_xoa varchar(100) NULL, -- Người xóa mềm
	khong_ap_ty_le_thanh_toan int2 DEFAULT 0 NULL,
	ngay_hieu_luc date NULL,
	CONSTRAINT dm_doi_tuong_benh_nhan_pkey PRIMARY KEY (id)
);

CREATE TABLE dm_doi_tuong_benh_nhan_don_thuoc_nha_thuoc (
	ten varchar NULL,
	id uuid DEFAULT gen_random_uuid() NOT NULL,
	ngay_tao timestamp DEFAULT now() NOT NULL,
	nguoi_tao varchar(100) DEFAULT '''system'''::character varying NOT NULL,
	ngay_cap_nhat timestamp DEFAULT now() NOT NULL,
	nguoi_cap_nhat varchar(100) DEFAULT '''system'''::character varying NOT NULL,
	bi_xoa int2 DEFAULT 0 NULL,
	ngay_xoa timestamp NULL,
	nguoi_xoa varchar(100) NULL,
	CONSTRAINT dm_doi_tuong_benh_nhan_don_thuoc_nha_thuoc_pk_id PRIMARY KEY (id)
);

CREATE TABLE dm_doi_tuong_gia_dich_vu (
	id uuid DEFAULT gen_random_uuid() NOT NULL,
	doi_tuong_benh_nhan_id uuid NULL,
	loai_gia_id uuid NULL,
	dich_vu_id uuid NULL,
	su_dung int2 DEFAULT 1 NULL,
	ngay_tao timestamp DEFAULT now() NOT NULL,
	nguoi_tao varchar(100) NOT NULL,
	ngay_cap_nhat timestamp DEFAULT now() NOT NULL,
	nguoi_cap_nhat varchar(100) NOT NULL,
	bi_xoa int2 DEFAULT 0 NOT NULL,
	ngay_xoa timestamp NULL,
	nguoi_xoa varchar(100) NULL,
	ma_cskcb varchar(25) NULL,
	ma_doi_tuong varchar(25) NULL,
	ma_loai_gia varchar(25) NULL,
	ma_dich_vu varchar(25) NULL,
	CONSTRAINT dm_doi_tuong_gia_dich_vu_pkey PRIMARY KEY (id)
);

CREATE TABLE dm_doi_tuong_loai_gia (
	id uuid DEFAULT gen_random_uuid() NOT NULL, -- Key
	ma_doi_tuong varchar(25) NULL, -- Mã đối tượng bệnh nhân
	gia_tt_id uuid NOT NULL, -- Giá thanh toán id
	ngay_tao timestamp DEFAULT now() NOT NULL,
	nguoi_tao varchar(100) NOT NULL,
	ngay_cap_nhat timestamp DEFAULT now() NOT NULL,
	nguoi_cap_nhat varchar(100) NOT NULL,
	ma_cskcb varchar(100) NULL,
	bi_xoa int2 DEFAULT 0 NOT NULL,
	ngay_xoa timestamp NULL,
	nguoi_xoa varchar(100) NULL,
	su_dung int2 DEFAULT 1 NULL,
	ma_gia_tt varchar(25) NULL,
	doi_tuong_id uuid NULL,
	ma_doi_tuong_loai_gia_tt varchar(50) NULL,
	CONSTRAINT dm_doi_tuong_loai_gia_pkey PRIMARY KEY (id)
);

CREATE TABLE dm_doi_tuong_thanh_toan_phat_sinh (
	ma varchar NOT NULL,
	ten varchar NOT NULL,
	id uuid DEFAULT gen_random_uuid() NOT NULL, -- Key của bảng
	ngay_tao timestamp DEFAULT now() NOT NULL, -- Ngày tạo
	nguoi_tao varchar DEFAULT 'system'::character varying NOT NULL, -- Người tạo
	ngay_cap_nhat timestamp DEFAULT now() NOT NULL, -- Ngày cập nhật
	nguoi_cap_nhat varchar DEFAULT 'system'::character varying NOT NULL, -- Người cập nhật
	bi_xoa int2 DEFAULT 0 NULL, -- Bị xóa mềm
	ngay_xoa timestamp NULL, -- Ngày xóa mềm
	nguoi_xoa varchar NULL, -- Người xóa mềm
	CONSTRAINT dm_doi_tuong_thanh_toan_phat_sinh_ma_key UNIQUE (ma),
	CONSTRAINT dm_doi_tuong_thanh_toan_phat_sinh_pkey PRIMARY KEY (id)
);

CREATE TABLE dm_don_vi_nhan (
	ten varchar NULL,
	ma varchar NULL,
	ghi_chu varchar NULL,
	su_dung bool NULL,
	id uuid DEFAULT gen_random_uuid() NOT NULL, -- Key của bảng
	ngay_tao timestamp DEFAULT now() NOT NULL, -- Ngày tạo
	nguoi_tao varchar(100) DEFAULT 'system'::character varying NOT NULL, -- Người tạo
	ngay_cap_nhat timestamp DEFAULT now() NOT NULL, -- Ngày cập nhật
	nguoi_cap_nhat varchar(100) DEFAULT 'system'::character varying NOT NULL, -- Người cập nhật
	bi_xoa int2 DEFAULT 0 NULL, -- Bị xóa mềm
	ngay_xoa timestamp NULL, -- Ngày xóa mềm
	nguoi_xoa varchar(100) NULL, -- Người xóa mềm
	CONSTRAINT dm_don_vi_nhan_pk_id PRIMARY KEY (id)
);

CREATE TABLE dm_don_vi_tinh (
	ma_don_vi_tinh varchar(25) NOT NULL,
	ten_don_vi_tinh varchar(255) NOT NULL,
	ten_tieng_anh varchar(255) NULL,
	ghi_chu text NULL,
	ten_khong_dau varchar(255) NULL,
	stt int2 NULL,
	su_dung bool DEFAULT true NULL,
	id uuid DEFAULT gen_random_uuid() NOT NULL, -- Key của bảng
	ngay_xoa timestamp NULL, -- Ngày xóa mềm
	ngay_tao timestamp DEFAULT now() NOT NULL, -- Ngày tạo
	nguoi_tao varchar(100) DEFAULT 'system'::character varying NOT NULL, -- Người tạo
	ngay_cap_nhat timestamp DEFAULT now() NOT NULL, -- Ngày cập nhật
	nguoi_cap_nhat varchar(100) DEFAULT 'system'::character varying NOT NULL, -- Người cập nhật
	nguoi_xoa varchar(100) NULL, -- Người xóa mềm
	bi_xoa int2 DEFAULT 0 NULL, -- Bị xóa mềm
	CONSTRAINT dm_don_vi_tinh_ma_don_vi_tinh_key UNIQUE (ma_don_vi_tinh),
	CONSTRAINT dm_don_vi_tinh_pkey PRIMARY KEY (id)
);

CREATE TABLE dm_duong_dung (
	ma_duong_dung varchar(25) NOT NULL,
	ten_duong_dung varchar(255) NOT NULL,
	ten_tieng_anh varchar(255) NULL,
	ma_quy_dinh varchar(25) NULL,
	ghi_chu text NULL,
	stt int2 NULL,
	su_dung bool DEFAULT true NULL,
	id uuid DEFAULT gen_random_uuid() NOT NULL, -- Key của bảng
	ngay_xoa timestamp NULL, -- Ngày xóa mềm
	ngay_tao timestamp DEFAULT now() NOT NULL, -- Ngày tạo
	nguoi_tao varchar(100) DEFAULT 'system'::character varying NOT NULL, -- Người tạo
	ngay_cap_nhat timestamp DEFAULT now() NOT NULL, -- Ngày cập nhật
	nguoi_cap_nhat varchar(100) DEFAULT 'system'::character varying NOT NULL, -- Người cập nhật
	nguoi_xoa varchar(100) NULL, -- Người xóa mềm
	bi_xoa int2 DEFAULT 0 NULL, -- Bị xóa mềm
	duongdungid serial4 NULL,
	deleted_at timestamp NULL,
	CONSTRAINT dm_duong_dung_ma_duong_dung_key UNIQUE (ma_duong_dung),
	CONSTRAINT dm_duong_dung_pkey PRIMARY KEY (id)
);

CREATE TABLE dm_dv_dvth (
	ma_dich_vu varchar(25) NOT NULL, -- Mã dịch vụ
	ma_chi_so varchar(100) NULL, -- Mã chỉ số
	ten_chi_so varchar(255) NULL, -- Tên chỉ số
	don_vi_tinh varchar(25) NULL, -- Đơn vị tính
	can_tren_nam varchar(255) NULL, -- Cận trên Nam
	can_tren_nu varchar(255) NULL, -- Cận trên Nữ
	can_duoi_nam varchar(255) NULL, -- Cận dưới Nam
	can_duoi_nu varchar(255) NULL, -- Cận dưới Nữ
	can_tren_te varchar(255) NULL, -- Cận trên trẻ em
	can_duoi_te varchar(255) NULL, -- Cận dưới trẻ em
	stt_phieu_in varchar(25) NULL, -- Thứ tự sắp xếp trên phiếu in
	stt_hien_thi varchar(25) NULL, -- Thứ tự sắp xếp khi thực hiện
	thanh_phan_loinc varchar(25) NULL, -- Thành phần LOINC
	thuoc_tinh_loinc varchar(25) NULL, -- Thuộc tính LOINC
	tg_loinc varchar(25) NULL, -- Thời gian LOINC
	pp_loinc varchar(25) NULL, -- Phương pháp  LOINC
	su_dung bool NULL, -- Trạng thái sử dụng
	id uuid DEFAULT gen_random_uuid() NOT NULL, -- Key của bảng
	ngay_tao timestamp DEFAULT now() NOT NULL, -- Ngày tạo
	nguoi_tao varchar(100) DEFAULT 'system'::character varying NOT NULL, -- Người tạo
	ngay_cap_nhat timestamp DEFAULT now() NOT NULL, -- Ngày cập nhật
	nguoi_cap_nhat varchar(100) DEFAULT 'system'::character varying NOT NULL, -- Người cập nhật
	bi_xoa int2 DEFAULT 0 NULL, -- Bị xóa mềm
	ngay_xoa timestamp NULL, -- Ngày xóa mềm
	nguoi_xoa varchar(100) NULL, -- Người xóa mềm
	dich_vu_id uuid NULL, -- Dịch vụ ID
	CONSTRAINT dm_dv_dvth_pkey PRIMARY KEY (id)
);

CREATE TABLE dm_emr_cau_hinh_phieu (
	id uuid DEFAULT gen_random_uuid() NOT NULL,
	ma_cskcb varchar(50) NOT NULL,
	bi_xoa int2 DEFAULT 0 NOT NULL,
	ma_loai_phieu varchar(50) NOT NULL,
	ten_loai_phieu varchar(255) NOT NULL,
	loai_node varchar(20) NOT NULL,
	ma_cha varchar(50) NULL,
	ma_module varchar(50) NULL,
	thu_tu int4 DEFAULT 0 NOT NULL,
	api_in_endpoint varchar(255) NULL,
	api_in_path_variable varchar(50) NULL,
	api_in_query_params text NULL,
	co_nhieu_phieu bool DEFAULT false NOT NULL,
	loai_bien_duong_dan varchar(50) NULL,
	ngay_tao timestamp(6) DEFAULT CURRENT_TIMESTAMP NULL,
	nguoi_tao varchar(50) NULL,
	ngay_cap_nhat timestamp(6) NULL,
	nguoi_cap_nhat varchar(50) NULL,
	ngay_xoa timestamp(6) NULL,
	nguoi_xoa varchar(50) NULL,
	CONSTRAINT chk_loai_node CHECK (((loai_node)::text = ANY (ARRAY[('FOLDER'::character varying)::text, ('PHIEU'::character varying)::text]))),
	CONSTRAINT dm_emr_cau_hinh_phieu_pkey PRIMARY KEY (id)
);

CREATE TABLE dm_gia_tt_xuat (
	id uuid DEFAULT gen_random_uuid() NOT NULL,
	loai_gia_id uuid NULL,
	co_chenh bool NULL,
	gia_tinh_chenh_id uuid NULL,
	tach_ban_ghi bool NULL,
	hoa_don_loai_xuat_id int4 NULL,
	pham_vi varchar(50) NULL,
	su_dung int2 NULL,
	ngay_tao timestamp DEFAULT now() NOT NULL,
	nguoi_tao varchar(100) NOT NULL,
	ngay_cap_nhat timestamp DEFAULT now() NOT NULL,
	nguoi_cap_nhat varchar(100) NOT NULL,
	ma_cskcb varchar(100) NULL,
	bi_xoa int2 DEFAULT 0 NOT NULL,
	ngay_xoa timestamp NULL,
	nguoi_xoa varchar(100) NULL,
	is_gia_ho_tro int2 DEFAULT 0 NULL,
	ma_loai_gia varchar(25) NULL,
	ma_loai_gia_tinh_chenh varchar(25) NULL,
	ma_gia_tt varchar(25) NULL,
	stt int4 DEFAULT 0 NOT NULL,
	CONSTRAINT dm_gia_tt_xuat_ma_cskcb_ma_loai_gia_ma_loai_gia_tinh_chenh_key UNIQUE (ma_cskcb, ma_loai_gia, ma_loai_gia_tinh_chenh),
	CONSTRAINT dm_gia_tt_xuat_ma_gia_tt_ma_cskcb_key UNIQUE (ma_gia_tt, ma_cskcb),
	CONSTRAINT dm_gia_tt_xuat_pkey PRIMARY KEY (id)
);

CREATE TABLE dm_gia_xang_theo_vung (
	vung_chi_dinh_xe_van_chuyen varchar(255) NULL,
	gia_xang_theo_vung numeric NULL,
	stt int4 NULL,
	ma varchar(50) NULL,
	su_dung bool DEFAULT true NULL,
	ma_cskcb varchar(50) NULL,
	id uuid DEFAULT gen_random_uuid() NOT NULL, -- Key của bảng
	ngay_tao timestamp DEFAULT now() NOT NULL, -- Ngày tạo
	nguoi_tao varchar(100) DEFAULT 'system'::character varying NOT NULL, -- Người tạo
	ngay_cap_nhat timestamp DEFAULT now() NOT NULL, -- Ngày cập nhật
	nguoi_cap_nhat varchar(100) DEFAULT 'system'::character varying NOT NULL, -- Người cập nhật
	bi_xoa int2 DEFAULT 0 NULL, -- Bị xóa mềm
	ngay_xoa timestamp NULL, -- Ngày xóa mềm
	nguoi_xoa varchar(100) NULL, -- Người xóa mềm
	CONSTRAINT dm_gia_xang_theo_vung_pkey PRIMARY KEY (id)
);

CREATE TABLE dm_giuong (
	ma_giuong varchar(25) NOT NULL, -- mã giường
	ten_giuong varchar(255) NOT NULL, -- Tên giường
	loai_giuong_id uuid NULL, -- Loại giường ID
	khoa_id uuid NULL, -- Khoa ID
	phong_id uuid NULL, -- Phòng ID
	ghep bool NULL, -- Ghép
	so_nguoi int4 NULL, -- Số người
	ttb_id uuid NULL, -- Trang thiết bị ID
	id uuid DEFAULT tenant_bvcahn.uuid_generate_v7() NOT NULL, -- Key của bảng
	ngay_tao timestamp DEFAULT now() NOT NULL, -- Ngày tạo
	nguoi_tao varchar(100) DEFAULT 'system'::character varying NOT NULL, -- Người tạo
	ngay_cap_nhat timestamp DEFAULT now() NOT NULL, -- Ngày cập nhật
	nguoi_cap_nhat varchar(100) DEFAULT 'system'::character varying NOT NULL, -- Người cập nhật
	bi_xoa int2 DEFAULT 0 NULL, -- Bị xóa mềm
	ngay_xoa timestamp NULL, -- Ngày xóa mềm
	nguoi_xoa varchar(100) NULL, -- Người xóa mềm
	CONSTRAINT dm_giuong_pkey PRIMARY KEY (id)
);

CREATE TABLE dm_goi_dich_vu (
	id uuid DEFAULT gen_random_uuid() NOT NULL,
	ma varchar(100) NOT NULL,
	ten varchar(255) NOT NULL,
	ngay_hieu_luc timestamp NOT NULL,
	ngay_het_han timestamp NOT NULL,
	loai_goi_id uuid NULL,
	gia_goi numeric NULL,
	so_ngay_gia_han int4 NULL,
	hinh_thuc_phan_bo_id uuid NULL,
	hinh_thuc_goi_id uuid NULL,
	hoat_dong int2 NULL,
	ma_cskcb varchar(10) NOT NULL,
	bi_xoa int2 DEFAULT 0 NOT NULL,
	ngay_tao timestamp DEFAULT CURRENT_TIMESTAMP NOT NULL,
	ngay_cap_nhat timestamp DEFAULT CURRENT_TIMESTAMP NOT NULL,
	nguoi_tao varchar(100) NULL,
	nguoi_cap_nhat varchar(100) NULL,
	ngay_xoa timestamp NULL,
	nguoi_xoa varchar(50) NULL,
	doi_tuong_id uuid NOT NULL,
	vung_du_lieu varchar(20) DEFAULT 'VUNG_NGOAI'::character varying NOT NULL,
	CONSTRAINT dm_goi_dich_vu_pk PRIMARY KEY (id)
);

CREATE TABLE dm_goi_thau (
	ma varchar NOT NULL,
	ten varchar NOT NULL,
	id uuid DEFAULT gen_random_uuid() NOT NULL,
	deleted_at timestamp NULL,
	created_at timestamp DEFAULT now() NOT NULL,
	created_by text NOT NULL,
	updated_at timestamp DEFAULT now() NOT NULL,
	updated_by text NOT NULL,
	goithauid int4 NULL,
	CONSTRAINT dm_goi_thau_id_key UNIQUE (id),
	CONSTRAINT dm_goi_thau_ma_key UNIQUE (ma),
	CONSTRAINT dm_goi_thau_pkey PRIMARY KEY (id)
);

CREATE TABLE dm_goidichvu_mau (
	magoi varchar NULL,
	tengoi varchar NULL,
	dichvu_id _uuid NULL,
	soluong int4 NULL,
	sudung bool NULL,
	id uuid DEFAULT gen_random_uuid() NOT NULL,
	ngay_tao timestamp DEFAULT now() NOT NULL,
	nguoi_tao varchar(100) DEFAULT '''system'''::character varying NOT NULL,
	ngay_cap_nhat timestamp DEFAULT now() NOT NULL,
	nguoi_cap_nhat varchar(100) DEFAULT '''system'''::character varying NOT NULL,
	bi_xoa int2 DEFAULT 0 NULL,
	ngay_xoa timestamp NULL,
	nguoi_xoa varchar(100) NULL,
	stt int4 NULL,
	CONSTRAINT dm_goidichvu_mau_pkey PRIMARY KEY (id)
);

CREATE TABLE dm_he_thong (
	ten_he_thong varchar NULL,
	ma_he_thong varchar NULL,
	su_dung bool DEFAULT true NULL,
	id uuid DEFAULT gen_random_uuid() NOT NULL, -- Key của bảng
	ngay_tao timestamp DEFAULT now() NOT NULL, -- Ngày tạo
	nguoi_tao varchar DEFAULT 'system'::character varying NOT NULL, -- Người tạo
	ngay_cap_nhat timestamp DEFAULT now() NOT NULL, -- Ngày cập nhật
	nguoi_cap_nhat varchar DEFAULT 'system'::character varying NOT NULL, -- Người cập nhật
	bi_xoa int2 DEFAULT 0 NULL, -- Bị xóa mềm
	ngay_xoa timestamp NULL, -- Ngày xóa mềm
	nguoi_xoa varchar NULL, -- Người xóa mềm
	CONSTRAINT dm_he_thong_ma_he_thong_key UNIQUE (ma_he_thong),
	CONSTRAINT dm_he_thong_pkey PRIMARY KEY (id)
);

CREATE TABLE dm_hinh_thuc_goi (
	ma varchar NOT NULL,
	id uuid DEFAULT gen_random_uuid() NOT NULL, -- Key của bảng
	ngay_tao timestamp DEFAULT now() NOT NULL, -- Ngày tạo
	nguoi_tao varchar DEFAULT 'system'::character varying NOT NULL, -- Người tạo
	ngay_cap_nhat timestamp DEFAULT now() NOT NULL, -- Ngày cập nhật
	nguoi_cap_nhat varchar DEFAULT 'system'::character varying NOT NULL, -- Người cập nhật
	bi_xoa int2 DEFAULT 0 NULL, -- Bị xóa mềm
	ngay_xoa timestamp NULL, -- Ngày xóa mềm
	nguoi_xoa varchar NULL, -- Người xóa mềm
	ten varchar(255) NULL,
	CONSTRAINT dm_hinh_thuc_goi_ma_key UNIQUE (ma),
	CONSTRAINT dm_hinh_thuc_goi_pkey PRIMARY KEY (id)
);

CREATE TABLE dm_hinh_thuc_hoi_chan (
	ma_nhom text NOT NULL,
	ma bpchar(1) NOT NULL,
	ten text NULL,
	id uuid DEFAULT gen_random_uuid() NOT NULL, -- Key của bảng
	ngay_tao timestamp DEFAULT now() NOT NULL, -- Ngày tạo
	nguoi_tao varchar(100) DEFAULT 'system'::character varying NOT NULL, -- Người tạo
	ngay_cap_nhat timestamp DEFAULT now() NOT NULL, -- Ngày cập nhật
	nguoi_cap_nhat varchar(100) DEFAULT 'system'::character varying NOT NULL, -- Người cập nhật
	bi_xoa int2 DEFAULT 0 NULL, -- Bị xóa mềm
	ngay_xoa timestamp NULL, -- Ngày xóa mềm
	nguoi_xoa varchar(100) NULL, -- Người xóa mềm
	CONSTRAINT dm_hinh_thuc_hoi_chan_pkey PRIMARY KEY (id)
);

CREATE TABLE dm_hinh_thuc_pt (
	ma_hinh_thuc_pt varchar NOT NULL,
	ten_hinh_thuc_pt varchar NULL,
	ghi_chu varchar NULL,
	su_dung bool NULL,
	id uuid DEFAULT gen_random_uuid() NOT NULL, -- Key của bảng
	ngay_tao timestamp DEFAULT now() NOT NULL, -- Ngày tạo
	nguoi_tao varchar DEFAULT 'system'::character varying NOT NULL, -- Người tạo
	ngay_cap_nhat timestamp DEFAULT now() NOT NULL, -- Ngày cập nhật
	nguoi_cap_nhat varchar DEFAULT 'system'::character varying NOT NULL, -- Người cập nhật
	bi_xoa int2 DEFAULT 0 NULL, -- Bị xóa mềm
	ngay_xoa timestamp NULL, -- Ngày xóa mềm
	nguoi_xoa varchar NULL, -- Người xóa mềm
	CONSTRAINT dm_hinh_thuc_pt_ma_hinh_thuc_pt_key UNIQUE (ma_hinh_thuc_pt),
	CONSTRAINT dm_hinh_thuc_pt_pkey PRIMARY KEY (id)
);

CREATE TABLE dm_hinh_thuc_thau (
	ma varchar NOT NULL,
	ten varchar NOT NULL,
	su_dung int2 DEFAULT 1 NOT NULL,
	id uuid DEFAULT gen_random_uuid() NOT NULL,
	deleted_at timestamp NULL,
	created_at timestamp DEFAULT now() NOT NULL,
	created_by text NOT NULL,
	updated_at timestamp DEFAULT now() NOT NULL,
	updated_by text NOT NULL,
	hinhthucthauid int4 NULL,
	CONSTRAINT dm_hinh_thuc_thau_id_key UNIQUE (id),
	CONSTRAINT dm_hinh_thuc_thau_ma_key UNIQUE (ma),
	CONSTRAINT dm_hinh_thuc_thau_pkey PRIMARY KEY (id)
);

CREATE TABLE dm_hinh_thuc_tiep_nhan (
	ma_hinh_thuc_tiep_nhan varchar NULL,
	ten_hinh_thuc_tiep_nhan varchar NULL,
	ten_khac varchar NULL,
	id uuid DEFAULT gen_random_uuid() NOT NULL,
	ngay_xoa timestamp NULL,
	ngay_tao timestamp DEFAULT now() NOT NULL,
	nguoi_tao text NOT NULL,
	ngay_cap_nhat timestamp DEFAULT now() NOT NULL,
	nguoi_cap_nhat text NOT NULL,
	ten_khong_dau varchar NULL,
	stt int2 NULL,
	su_dung bool DEFAULT true NULL,
	nguoi_xoa varchar(100) NULL,
	bi_xoa int2 DEFAULT 0 NULL,
	CONSTRAINT dm_hinh_thuc_tiep_nhan_pkey PRIMARY KEY (id)
);

CREATE TABLE dm_hinh_thuc_to_chuc (
	ma varchar NOT NULL, -- Mã hình thức tổ chức
	ten varchar NOT NULL, -- Tên hình thức tổ chức
	id uuid DEFAULT gen_random_uuid() NOT NULL, -- Key của bảng
	ngay_tao timestamp DEFAULT now() NOT NULL, -- Ngày tạo
	nguoi_tao varchar DEFAULT 'system'::character varying NOT NULL, -- Người tạo
	ngay_cap_nhat timestamp DEFAULT now() NOT NULL, -- Ngày cập nhật
	nguoi_cap_nhat varchar DEFAULT 'system'::character varying NOT NULL, -- Người cập nhật
	bi_xoa int2 DEFAULT 0 NULL, -- Bị xóa mềm
	ngay_xoa timestamp NULL, -- Ngày xóa mềm
	nguoi_xoa varchar NULL, -- Người xóa mềm
	CONSTRAINT dm_hinh_thuc_to_chuc_ma_key UNIQUE (ma),
	CONSTRAINT dm_hinh_thuc_to_chuc_pkey PRIMARY KEY (id)
);

CREATE TABLE dm_huyet (
	id uuid DEFAULT gen_random_uuid() NOT NULL, -- Key của bảng
	ma_huyet varchar(50) NULL, -- Mã dùng chung của huyệt
	ten_huyet_tv varchar(200) NULL, -- Tên huyệt (tiếng Việt)
	ten_huyet_qt varchar(200) NULL, -- Tên huyệt (quốc tế / Latin)
	ma_snomed_ct varchar(50) NULL, -- Mã tham chiếu SNOMED CT
	ma_quoc_te varchar(50) NULL, -- Mã quốc tế của huyệt
	ten_duong_kinh_tv varchar(200) NULL, -- Tên đường kinh (tiếng Việt)
	ten_duong_kinh_qt varchar(200) NULL, -- Tên đường kinh (quốc tế)
	ngay_tao timestamp(6) DEFAULT now() NOT NULL, -- Ngày tạo
	nguoi_tao varchar(100) DEFAULT 'system'::character varying NOT NULL, -- Người tạo
	ngay_cap_nhat timestamp(6) DEFAULT now() NOT NULL, -- Ngày cập nhật
	nguoi_cap_nhat varchar(100) DEFAULT 'system'::character varying NOT NULL, -- Người cập nhật
	ma_cskcb varchar(50) NULL, -- Mã cơ sở khám chữa bệnh
	nguoi_xoa varchar(100) NULL, -- Người xóa mềm
	bi_xoa int2 DEFAULT 0 NULL, -- Bị xóa mềm
	ngay_xoa timestamp(6) NULL, -- Ngày xóa mềm
	CONSTRAINT dm_huyet_pkey PRIMARY KEY (id)
);

CREATE TABLE dm_huyet_2 (
	ma_huyet varchar NULL, -- Mã dùng chung của huyệt
	ten_huyet_tv varchar NULL, -- Tên huyệt (tiếng Việt)
	ten_huyet_qt varchar NULL, -- Tên huyệt (quốc tế / Latin)
	ma_snomed_ct varchar NULL, -- Mã tham chiếu SNOMED CT
	ma_quoc_te varchar NULL, -- Mã quốc tế của huyệt
	ten_duong_kinh_tv varchar NULL, -- Tên đường kinh (tiếng Việt)
	ten_duong_kinh_qt varchar NULL, -- Tên đường kinh (quốc tế)
	ma_cskcb varchar NULL, -- Mã cơ sở khám chữa bệnh
	id uuid DEFAULT gen_random_uuid() NOT NULL, -- Key của bảng
	ngay_tao timestamp DEFAULT now() NOT NULL, -- Ngày tạo
	nguoi_tao varchar DEFAULT 'system'::character varying NOT NULL, -- Người tạo
	ngay_cap_nhat timestamp DEFAULT now() NOT NULL, -- Ngày cập nhật
	nguoi_cap_nhat varchar DEFAULT 'system'::character varying NOT NULL, -- Người cập nhật
	bi_xoa int2 DEFAULT 0 NULL, -- Bị xóa mềm
	ngay_xoa timestamp NULL, -- Ngày xóa mềm
	nguoi_xoa varchar NULL -- Người xóa mềm
);

CREATE TABLE dm_icd9_cm (
	ma_benh_icd9 varchar(50) NOT NULL,
	ten_benh_icd9 varchar(255) NULL,
	ten_tieng_anh varchar(255) NULL,
	ten_khong_dau varchar(255) NULL,
	ma_chuong_icd9 uuid NULL,
	ten_su_dung varchar(255) NULL,
	su_dung bool NULL,
	id uuid DEFAULT gen_random_uuid() NOT NULL, -- Key của bảng
	ngay_tao timestamp DEFAULT now() NOT NULL, -- Ngày tạo
	nguoi_tao varchar(100) DEFAULT 'system'::character varying NOT NULL, -- Người tạo
	ngay_cap_nhat timestamp DEFAULT now() NOT NULL, -- Ngày cập nhật
	nguoi_cap_nhat varchar(100) DEFAULT 'system'::character varying NOT NULL, -- Người cập nhật
	bi_xoa int2 DEFAULT 0 NULL, -- Bị xóa mềm
	ngay_xoa timestamp NULL, -- Ngày xóa mềm
	nguoi_xoa varchar(100) NULL, -- Người xóa mềm
	CONSTRAINT dm_icd9_cm_pk_id PRIMARY KEY (id)
);

CREATE TABLE dm_icd9_dich_vu_map (
	id uuid DEFAULT gen_random_uuid() NOT NULL,
	ma_benh_icd9 varchar(50) NOT NULL,
	ten_benh_icd9 varchar(255) NULL,
	ma_chuong_icd9 varchar(50) NULL,
	ten_chuong_icd9 varchar(255) NULL,
	ma_dich_vu varchar(50) NOT NULL,
	ten_dich_vu varchar(200) NULL,
	ma_cskcb varchar(20) NOT NULL,
	bi_xoa int2 DEFAULT 0 NOT NULL,
	ngay_xoa timestamp NULL,
	nguoi_xoa varchar(100) NULL,
	ngay_tao timestamp DEFAULT CURRENT_TIMESTAMP NOT NULL,
	nguoi_tao varchar(100) NOT NULL,
	ngay_cap_nhat timestamp NOT NULL,
	nguoi_cap_nhat varchar(100) NOT NULL,
	chuong_icd9_id uuid DEFAULT gen_random_uuid() NOT NULL,
	CONSTRAINT dm_icd9_dich_vu_map_pkey PRIMARY KEY (id)
);

CREATE TABLE dm_ket_qua_dieu_tri (
	id uuid DEFAULT gen_random_uuid() NOT NULL, -- Khóa chính
	ma_ket_qua_dieu_tri varchar(50) NULL, -- Mã kết quả điều trị
	ten_ket_qua_dieu_tri varchar(200) NULL, -- Tên kết quả điều trị
	ten_khong_dau varchar(200) NULL, -- Tên kết quả điều trị không dấu
	ghi_chu text NULL, -- Ghi chú
	stt int4 NULL, -- Thứ tự hiển thị
	su_dung bool NULL, -- Trạng thái sử dụng
	ngay_tao timestamp(6) DEFAULT now() NOT NULL, -- Ngày tạo bản ghi
	nguoi_tao varchar(100) NOT NULL, -- Người tạo
	ngay_cap_nhat timestamp(6) DEFAULT now() NOT NULL, -- Ngày cập nhật
	nguoi_cap_nhat varchar(100) NOT NULL, -- Người cập nhật
	ma_cskcb varchar(50) NULL, -- Mã cơ sở khám chữa bệnh
	nguoi_xoa varchar(100) NULL, -- Người thực hiện xóa
	bi_xoa int2 DEFAULT 0 NULL, -- Trạng thái xóa (0: chưa xóa, 1: đã xóa)
	ngay_xoa timestamp(6) NULL, -- Ngày xóa
	thoigian_luutru int4 NULL
);

CREATE TABLE dm_kho_duoc (
	id uuid DEFAULT gen_random_uuid() NOT NULL,
	ma_cskcb varchar(25) NOT NULL,
	ma_kho varchar(25) NOT NULL,
	ten_kho varchar(255) NOT NULL,
	pham_vi_ql int2 NULL,
	loai_kho_id uuid NULL,
	khoa_id uuid NULL,
	phong_id uuid NULL,
	phong_xtd int2 NULL,
	thoi_gian_xuat int2 NULL,
	nhap_kho_ncc bool NULL,
	su_dung bool NULL,
	nguoi_tao varchar DEFAULT 'system'::character varying NULL,
	ngay_tao timestamp DEFAULT now() NULL,
	nguoi_cap_nhat varchar DEFAULT 'system'::character varying NULL,
	ngay_cap_nhat timestamp DEFAULT now() NULL,
	bi_xoa int2 DEFAULT 0 NULL,
	nguoi_xoa varchar NULL,
	ngay_xoa timestamp DEFAULT now() NULL,
	CONSTRAINT dm_kho_duoc_ma_cskcb_ma_kho_key UNIQUE (ma_cskcb, ma_kho),
	CONSTRAINT dm_kho_duoc_pkey PRIMARY KEY (id)
);

CREATE TABLE dm_kho_kholk (
	kho_id int4 NOT NULL,
	kho_lk_id int4 NOT NULL,
	id uuid DEFAULT gen_random_uuid() NOT NULL,
	deleted_at timestamp NULL,
	created_at timestamp DEFAULT now() NOT NULL,
	created_by text NOT NULL,
	updated_at timestamp DEFAULT now() NOT NULL,
	updated_by text NOT NULL,
	CONSTRAINT dm_kho_kholk_pkey PRIMARY KEY (id)
);

CREATE TABLE dm_kho_ttb (
	ma_kho varchar(100) NULL, -- Mã kho
	ten_kho varchar(100) NULL, -- Tên kho
	thu_kho_id uuid NULL, -- Thủ kho id
	loai_kho_id uuid NULL, -- Loại kho id
	cskcb_id uuid NULL, -- Cơ sở khám chữa bệnh id
	khoa_id uuid NULL, -- Khoa id
	phong_id uuid NULL, -- Phòng id
	thoi_gian_xuat date NULL, -- Thời gian xuất
	su_dung bool NULL, -- Trạng thái sử dụng
	id uuid DEFAULT gen_random_uuid() NOT NULL, -- Key của bảng
	ngay_tao timestamp DEFAULT now() NOT NULL, -- Ngày tạo
	nguoi_tao varchar(100) DEFAULT 'system'::character varying NOT NULL, -- Người tạo
	ngay_cap_nhat timestamp DEFAULT now() NOT NULL, -- Ngày cập nhật
	nguoi_cap_nhat varchar(100) DEFAULT 'system'::character varying NOT NULL, -- Người cập nhật
	bi_xoa int2 DEFAULT 0 NULL, -- Bị xóa mềm
	ngay_xoa timestamp NULL, -- Ngày xóa mềm
	nguoi_xoa varchar(100) NULL, -- Người xóa mềm
	CONSTRAINT dm_kho_ttb_pkey PRIMARY KEY (id)
);

CREATE TABLE dm_khoa (
	id uuid DEFAULT gen_random_uuid() NOT NULL, -- Key của bảng
	ma_cskcb varchar(25) NOT NULL,
	ten_cskcb varchar(255) NOT NULL,
	ma_khoa varchar(25) NOT NULL,
	ten_khoa varchar(255) NOT NULL,
	ten_khoa_en varchar NULL,
	ma_khoa_byt varchar NULL,
	chuyen_khoa_id uuid NULL, -- FK: dmc_chuyen_khoa
	giuong_ke_hoach int4 NULL,
	giuong_thuc_ke int4 NULL,
	don_nguyen bool NULL,
	khoa_id_org uuid NULL, -- FK: dm_khoa
	dinh_dang_ltba varchar(255) NULL,
	stt_bc int2 NULL,
	stt_dash int2 NULL,
	phan_cap_cmkt int2 NULL,
	khoa_yhct bool NULL, -- Khoa y học cổ truyền
	phan_khu_id uuid NOT NULL,
	dia_chi varchar(255) NULL,
	truong_khoa_id uuid NULL, -- FK: dm_nhan_vien
	phu_trach_khoa_id uuid NULL, -- FK: dm_nhan_vien
	dieu_duong_truong_id uuid NULL, -- FK: dm_nhan_vien
	stt int2 NULL,
	su_dung bool DEFAULT true NULL,
	bi_xoa int2 DEFAULT 0 NULL, -- Bị xóa mềm
	ngay_xoa timestamp NULL, -- Ngày xóa mềm
	ngay_tao timestamp DEFAULT now() NOT NULL, -- Ngày tạo
	nguoi_tao varchar(100) DEFAULT 'system'::character varying NOT NULL, -- Người tạo
	ngay_cap_nhat timestamp DEFAULT now() NOT NULL, -- Ngày cập nhật
	nguoi_cap_nhat varchar(100) DEFAULT 'system'::character varying NOT NULL, -- Người cập nhật
	khoaid bigserial NULL, -- ID dùng cho module dược vật tư mapping
	nguoi_xoa varchar(100) NULL, -- Người xóa mềm
	so_giuong_hscc int4 NULL, -- Số giường hồi sức cấp cứu
	so_giuong_hstc int4 NULL, -- Số giường hồi sức tích cực
	so_ban_kham int4 NULL, -- Số bàn khám
	cap_khoa_truc_thuoc int4 NULL, -- Cấp khoa trực thuộc
	loai_khoa varchar(50) NULL,
	liendanh_lienket int4 NULL, -- Liên danh liên kết¶Dữ liệu bao gồm: 1: có liên doanh, liên kết; 2: không liên doanh, liên kết
	ma_chung varchar(50) NULL,
	CONSTRAINT dm_khoa_pkey PRIMARY KEY (id)
);

CREATE TABLE dm_khoa_dich_vu (
	khoa_id uuid NOT NULL,
	dich_vu_id uuid NOT NULL,
	csyt_dich_vu_id uuid NULL,
	id uuid DEFAULT gen_random_uuid() NOT NULL, -- Key của bảng
	ngay_xoa timestamp NULL, -- Ngày xóa mềm
	ngay_tao timestamp DEFAULT now() NOT NULL, -- Ngày tạo
	nguoi_tao varchar(100) DEFAULT 'system'::character varying NOT NULL, -- Người tạo
	ngay_cap_nhat timestamp DEFAULT now() NOT NULL, -- Ngày cập nhật
	nguoi_cap_nhat varchar(100) DEFAULT 'system'::character varying NOT NULL, -- Người cập nhật
	nguoi_xoa varchar(100) NULL, -- Người xóa mềm
	bi_xoa int2 DEFAULT 0 NULL, -- Bị xóa mềm
	CONSTRAINT dm_khoa_dich_vu_pkey PRIMARY KEY (id)
);

CREATE TABLE dm_khu_vuc (
	ma_khu_vuc varchar NOT NULL,
	ten_khu_vuc varchar NOT NULL,
	su_dung bool DEFAULT true NULL,
	id uuid DEFAULT gen_random_uuid() NOT NULL,
	deleted_at timestamp NULL,
	created_at timestamp DEFAULT now() NOT NULL,
	created_by text NOT NULL,
	updated_at timestamp DEFAULT now() NOT NULL,
	updated_by text NOT NULL,
	CONSTRAINT dm_khu_vuc_ma_khu_vuc_key UNIQUE (ma_khu_vuc),
	CONSTRAINT dm_khu_vuc_pkey PRIMARY KEY (id)
);

CREATE TABLE dm_kieu_hien_thi_mapping_dong (
	id uuid DEFAULT gen_random_uuid() NOT NULL, -- Key của bảng
	ngay_tao timestamp DEFAULT now() NOT NULL, -- Ngày tạo
	nguoi_tao varchar(100) DEFAULT 'system'::character varying NOT NULL, -- Người tạo
	ngay_cap_nhat timestamp DEFAULT now() NOT NULL, -- Ngày cập nhật
	nguoi_cap_nhat varchar(100) DEFAULT 'system'::character varying NOT NULL, -- Người cập nhật
	bi_xoa int2 DEFAULT 0 NULL, -- Bị xóa mềm
	ngay_xoa timestamp NULL, -- Ngày xóa mềm
	nguoi_xoa varchar(100) NULL, -- Người xóa mềm
	ma varchar(100) NOT NULL,
	ten varchar(100) NOT NULL,
	CONSTRAINT dm_kieu_hien_thi_mapping_dong_pkey PRIMARY KEY (id)
);

CREATE TABLE dm_kieu_in_phieu (
	ma varchar NOT NULL, -- Mã kiểu in phiếu
	ten varchar NULL, -- Tên kiểu in phiếu
	mo_ta text NULL, -- Mô tả kiểu in
	id uuid DEFAULT gen_random_uuid() NOT NULL, -- Key của bảng
	ngay_tao timestamp DEFAULT now() NOT NULL, -- Ngày tạo
	nguoi_tao varchar DEFAULT 'system'::character varying NOT NULL, -- Người tạo
	ngay_cap_nhat timestamp DEFAULT now() NOT NULL, -- Ngày cập nhật
	nguoi_cap_nhat varchar DEFAULT 'system'::character varying NOT NULL, -- Người cập nhật
	bi_xoa int2 DEFAULT 0 NULL, -- Bị xóa mềm
	ngay_xoa timestamp NULL, -- Ngày xóa mềm
	nguoi_xoa varchar NULL, -- Người xóa mềm
	is_platform int2 DEFAULT 1 NULL,
	CONSTRAINT dm_kieu_in_phieu_ma_key UNIQUE (ma),
	CONSTRAINT dm_kieu_in_phieu_pkey PRIMARY KEY (id)
);

CREATE TABLE dm_kieu_nhom_bao_cao (
	ma varchar NOT NULL,
	ten varchar NOT NULL,
	id uuid DEFAULT gen_random_uuid() NOT NULL, -- Key của bảng
	ngay_tao timestamp DEFAULT now() NOT NULL, -- Ngày tạo
	nguoi_tao varchar(100) DEFAULT '''system'''::character varying NOT NULL, -- Người tạo
	ngay_cap_nhat timestamp DEFAULT now() NOT NULL, -- Ngày cập nhật
	nguoi_cap_nhat varchar(100) DEFAULT '''system'''::character varying NOT NULL, -- Người cập nhật
	bi_xoa int2 DEFAULT 0 NULL, -- Bị xóa mềm
	ngay_xoa timestamp NULL, -- Ngày xóa mềm
	nguoi_xoa varchar(100) NULL, -- Người xóa mềm
	CONSTRAINT dm_kieu_nhom_bao_cao_pk_id PRIMARY KEY (id),
	CONSTRAINT dm_kieu_nhom_bao_cao_unique UNIQUE (ma)
);

CREATE TABLE dm_loai_bao_cao (
	ten_loai_bao_cao varchar NULL,
	ma_loai_bao_cao varchar NULL,
	id uuid DEFAULT gen_random_uuid() NOT NULL, -- Key của bảng
	ngay_tao timestamp DEFAULT now() NOT NULL, -- Ngày tạo
	nguoi_tao varchar DEFAULT 'system'::character varying NOT NULL, -- Người tạo
	ngay_cap_nhat timestamp DEFAULT now() NOT NULL, -- Ngày cập nhật
	nguoi_cap_nhat varchar DEFAULT 'system'::character varying NOT NULL, -- Người cập nhật
	bi_xoa int2 DEFAULT 0 NULL, -- Bị xóa mềm
	ngay_xoa timestamp NULL, -- Ngày xóa mềm
	nguoi_xoa varchar NULL, -- Người xóa mềm
	su_dung bool DEFAULT true NULL,
	loai_bao_cao_id int4 NULL,
	CONSTRAINT dm_loai_bao_cao_ma_loai_bao_cao_key UNIQUE (ma_loai_bao_cao),
	CONSTRAINT dm_loai_bao_cao_pkey PRIMARY KEY (id)
);

CREATE TABLE dm_loai_bao_cao_bhyt (
	ma varchar NOT NULL, -- Mã
	ten varchar NOT NULL, -- Tên báo cáo
	id uuid DEFAULT gen_random_uuid() NOT NULL, -- Key của bảng
	ngay_tao timestamp DEFAULT now() NOT NULL, -- Ngày tạo
	nguoi_tao varchar DEFAULT 'system'::character varying NOT NULL, -- Người tạo
	ngay_cap_nhat timestamp DEFAULT now() NOT NULL, -- Ngày cập nhật
	nguoi_cap_nhat varchar DEFAULT 'system'::character varying NOT NULL, -- Người cập nhật
	bi_xoa int2 DEFAULT 0 NULL, -- Bị xóa mềm
	ngay_xoa timestamp NULL, -- Ngày xóa mềm
	nguoi_xoa varchar NULL, -- Người xóa mềm
	loai_bao_cao varchar NULL,
	CONSTRAINT dm_loai_bao_cao_bhyt_pkey PRIMARY KEY (id)
);

CREATE TABLE dm_loai_benh_an (
	ma_loai_benh_an varchar(25) NOT NULL,
	ten_loai_benh_an varchar(255) NOT NULL,
	ghi_chu varchar(255) NULL,
	ten_khong_dau varchar(255) NULL,
	stt int4 NULL,
	su_dung bool NULL,
	id uuid DEFAULT gen_random_uuid() NOT NULL, -- Key của bảng
	ngay_tao timestamp DEFAULT now() NOT NULL, -- Ngày tạo
	nguoi_tao varchar(100) DEFAULT 'system'::character varying NOT NULL, -- Người tạo
	ngay_cap_nhat timestamp DEFAULT now() NOT NULL, -- Ngày cập nhật
	nguoi_cap_nhat varchar(100) DEFAULT 'system'::character varying NOT NULL, -- Người cập nhật
	bi_xoa int2 DEFAULT 0 NULL, -- Bị xóa mềm
	ngay_xoa timestamp NULL, -- Ngày xóa mềm
	nguoi_xoa varchar(100) NULL, -- Người xóa mềm
	thoigian_luutru int4 NULL,
	rpt_code varchar(255) NULL,
	rpt_code_ct varchar(255) NULL,
	rpt_code_tk varchar(255) NULL,
	is_phau_thuat int4 NULL,
	CONSTRAINT dm_loai_benh_an_pk_id PRIMARY KEY (id),
	CONSTRAINT dm_loai_benh_an_rpt_code_key UNIQUE (rpt_code)
);

CREATE TABLE dm_loai_chung_tu (
	ma varchar NULL, -- Mã loại chứng từ
	ten varchar NULL, -- Mã loại chứng từ
	ghi_chu varchar NULL, -- Ghi chú
	su_dung int4 DEFAULT 1 NOT NULL, -- 0: Không; 1: Có
	id uuid DEFAULT gen_random_uuid() NOT NULL, -- Key của bảng
	ngay_tao timestamp DEFAULT now() NOT NULL, -- Ngày tạo
	nguoi_tao varchar DEFAULT 'system'::character varying NOT NULL, -- Người tạo
	ngay_cap_nhat timestamp DEFAULT now() NOT NULL, -- Ngày cập nhật
	nguoi_cap_nhat varchar DEFAULT 'system'::character varying NOT NULL, -- Người cập nhật
	bi_xoa int2 DEFAULT 0 NULL, -- Bị xóa mềm
	ngay_xoa timestamp NULL, -- Ngày xóa mềm
	nguoi_xoa varchar NULL, -- Người xóa mềm
	CONSTRAINT dm_loai_chung_tu_ma_key UNIQUE (ma),
	CONSTRAINT dm_loai_chung_tu_pkey PRIMARY KEY (id)
);

CREATE TABLE dm_loai_dich_vu (
	ma_loai_dich_vu varchar NOT NULL,
	ten_loai_dich_vu varchar NOT NULL,
	ten_khong_dau varchar NULL,
	stt int2 NULL,
	su_dung bool DEFAULT true NULL,
	id uuid DEFAULT gen_random_uuid() NOT NULL, -- Key của bảng
	ngay_xoa timestamp NULL, -- Ngày xóa mềm
	ngay_tao timestamp DEFAULT now() NOT NULL, -- Ngày tạo
	nguoi_tao text NOT NULL, -- Người tạo
	ngay_cap_nhat timestamp DEFAULT now() NOT NULL, -- Ngày cập nhật
	nguoi_cap_nhat text NOT NULL, -- Người cập nhật
	nguoi_xoa varchar(100) NULL, -- Người xóa mềm
	bi_xoa int2 DEFAULT 0 NULL, -- Bị xóa mềm
	CONSTRAINT dm_loai_dich_vu_ma_loai_dich_vu_key UNIQUE (ma_loai_dich_vu),
	CONSTRAINT dm_loai_dich_vu_pkey PRIMARY KEY (id),
	CONSTRAINT dm_loai_dich_vu_ten_loai_dich_vu_key UNIQUE (ten_loai_dich_vu)
);

CREATE TABLE dm_loai_dich_vu_kt_xet_nghiem_mau (
	dich_vu_kt_id uuid NOT NULL,
	ma varchar(100) NOT NULL,
	ten varchar(500) NULL,
	id uuid DEFAULT gen_random_uuid() NOT NULL, -- Key của bảng
	ngay_tao timestamp DEFAULT now() NOT NULL, -- Ngày tạo
	nguoi_tao varchar(100) DEFAULT 'system'::character varying NOT NULL, -- Người tạo
	ngay_cap_nhat timestamp DEFAULT now() NOT NULL, -- Ngày cập nhật
	nguoi_cap_nhat varchar(100) DEFAULT 'system'::character varying NOT NULL, -- Người cập nhật
	bi_xoa int2 DEFAULT 0 NULL, -- Bị xóa mềm
	ngay_xoa timestamp NULL, -- Ngày xóa mềm
	nguoi_xoa varchar(100) NULL, -- Người xóa mềm
	CONSTRAINT dm_loai_dich_vu_kt_xet_nghiem_mau_pk_id PRIMARY KEY (id)
);

CREATE TABLE dm_loai_dieu_tri (
	id uuid DEFAULT gen_random_uuid() NOT NULL,
	ngay_tao timestamp DEFAULT now() NOT NULL,
	nguoi_tao varchar(100) DEFAULT 'system'::character varying NOT NULL,
	ngay_cap_nhat timestamp DEFAULT now() NOT NULL,
	nguoi_cap_nhat varchar(100) DEFAULT 'system'::character varying NOT NULL,
	bi_xoa int2 DEFAULT 0 NULL,
	ngay_xoa timestamp NULL,
	nguoi_xoa varchar(100) NULL,
	ma_cskcb varchar(25) NULL,
	ma_loai_dieu_tri varchar NOT NULL,
	ten_loai_dieu_tri varchar NOT NULL,
	ghi_chu text NULL,
	ten_khong_dau varchar NULL,
	so_thu_tu int4 NULL,
	su_dung bool DEFAULT true NOT NULL,
	ma_loai_kcb varchar NULL,
	CONSTRAINT dm_loai_dieu_tri_pk_id PRIMARY KEY (id)
);

CREATE TABLE dm_loai_duoc (
	stt int4 NULL,
	ma_phan_loai_duoc int4 NULL,
	ma_loai_duoc varchar NULL,
	cap int4 NULL,
	ten_loai_duoc varchar NULL,
	su_dung int2 NULL,
	id uuid DEFAULT gen_random_uuid() NOT NULL, -- Key của bảng
	ngay_tao timestamp DEFAULT now() NOT NULL, -- Ngày tạo
	nguoi_tao varchar(100) DEFAULT 'system'::character varying NOT NULL, -- Người tạo
	ngay_cap_nhat timestamp DEFAULT now() NOT NULL, -- Ngày cập nhật
	nguoi_cap_nhat varchar(100) DEFAULT 'system'::character varying NOT NULL, -- Người cập nhật
	bi_xoa int2 DEFAULT 0 NULL, -- Bị xóa mềm
	ngay_xoa timestamp NULL, -- Ngày xóa mềm
	nguoi_xoa varchar(100) NULL, -- Người xóa mềm
	CONSTRAINT dm_loai_duoc_pkey PRIMARY KEY (id)
);

CREATE TABLE dm_loai_duoc_atc (
	stt int4 NULL,
	ma_loai_duoc int4 NULL,
	atc_cap_1_ap_dung varchar NULL,
	ghi_chu_nghiep_vu varchar NULL,
	su_dung bool DEFAULT true NULL,
	id uuid DEFAULT gen_random_uuid() NOT NULL, -- Key của bảng
	ngay_tao timestamp DEFAULT now() NOT NULL, -- Ngày tạo
	nguoi_tao varchar(100) DEFAULT 'system'::character varying NOT NULL, -- Người tạo
	ngay_cap_nhat timestamp DEFAULT now() NOT NULL, -- Ngày cập nhật
	nguoi_cap_nhat varchar(100) DEFAULT 'system'::character varying NOT NULL, -- Người cập nhật
	bi_xoa int2 DEFAULT 0 NULL, -- Bị xóa mềm
	ngay_xoa timestamp NULL, -- Ngày xóa mềm
	nguoi_xoa varchar(100) NULL, -- Người xóa mềm
	ten_loai_duoc varchar(50) NULL,
	CONSTRAINT dm_loai_duoc_atc_pkey PRIMARY KEY (id)
);

CREATE TABLE dm_loai_gia (
	ma varchar(25) NULL, -- Mã loại giá
	ten varchar(255) NULL, -- Tên loại giá
	gia_xuat_thuoc int2 NULL,
	ghi_chu varchar(500) NULL,
	su_dung bool DEFAULT true NULL, -- Sử dụng( 0: Không; 1: Có)
	id uuid DEFAULT tenant_bvcahn.uuid_generate_v7() NOT NULL, -- Key của bảng
	ngay_xoa timestamp NULL, -- Ngày xóa mềm
	ngay_tao timestamp DEFAULT now() NOT NULL, -- Ngày tạo
	nguoi_tao varchar(100) DEFAULT 'system'::character varying NOT NULL, -- Người tạo
	ngay_cap_nhat timestamp DEFAULT now() NOT NULL, -- Ngày cập nhật
	nguoi_cap_nhat varchar(100) DEFAULT 'system'::character varying NOT NULL, -- Người cập nhật
	ma_cskcb varchar(255) NULL, -- Ma CSKCB
	nguoi_xoa varchar(100) NULL, -- Người xóa mềm
	bi_xoa int2 DEFAULT 0 NULL, -- Bị xóa mềm
	gia_xuat numeric NULL, -- Giá xuất
	loai_gia_id serial4 NULL, -- Mapping với bảng duc_thuocvattu
	co_chenh int2 DEFAULT 0 NULL, -- 0: Không, 1: Có
	is_gia_bhyt int2 DEFAULT 0 NULL, -- 0: Không, 1: Có
	CONSTRAINT dm_loai_gia_pkey PRIMARY KEY (id)
);

CREATE TABLE dm_loai_giay_to (
	id uuid DEFAULT gen_random_uuid() NOT NULL,
	ma varchar(25) NULL, -- Mã
	ten varchar(255) NULL, -- Tên
	sudung bool NULL, -- Sử dụng(0: Không; 1: Có)
	ngay_tao timestamp DEFAULT now() NOT NULL,
	nguoi_tao text NOT NULL,
	ngay_cap_nhat timestamp DEFAULT now() NOT NULL,
	nguoi_cap_nhat text NOT NULL,
	ma_cskcb varchar(100) NULL,
	bi_xoa int2 DEFAULT 0 NOT NULL,
	ngay_xoa timestamp NULL,
	nguoi_xoa varchar(100) NULL,
	CONSTRAINT dm_loai_giay_to_pkey PRIMARY KEY (id)
);

CREATE TABLE dm_loai_giuong (
	ten varchar(100) NULL,
	ma varchar(50) NULL,
	su_dung bool NULL,
	id uuid DEFAULT gen_random_uuid() NOT NULL, -- Key của bảng
	ngay_tao timestamp DEFAULT now() NOT NULL, -- Ngày tạo
	nguoi_tao varchar(100) DEFAULT '''system'''::character varying NOT NULL, -- Người tạo
	ngay_cap_nhat timestamp DEFAULT now() NOT NULL, -- Ngày cập nhật
	nguoi_cap_nhat varchar(100) DEFAULT '''system'''::character varying NOT NULL, -- Người cập nhật
	bi_xoa int2 DEFAULT 0 NULL, -- Bị xóa mềm
	ngay_xoa timestamp NULL, -- Ngày xóa mềm
	nguoi_xoa varchar(100) NULL, -- Người xóa mềm
	CONSTRAINT dm_loai_giuong_pk_id PRIMARY KEY (id)
);

CREATE TABLE dm_loai_goi (
	ma varchar NOT NULL,
	ten varchar NOT NULL,
	id uuid DEFAULT gen_random_uuid() NOT NULL, -- Key của bảng
	ngay_tao timestamp DEFAULT now() NOT NULL, -- Ngày tạo
	nguoi_tao varchar DEFAULT 'system'::character varying NOT NULL, -- Người tạo
	ngay_cap_nhat timestamp DEFAULT now() NOT NULL, -- Ngày cập nhật
	nguoi_cap_nhat varchar DEFAULT 'system'::character varying NOT NULL, -- Người cập nhật
	bi_xoa int2 DEFAULT 0 NULL, -- Bị xóa mềm
	ngay_xoa timestamp NULL, -- Ngày xóa mềm
	nguoi_xoa varchar NULL, -- Người xóa mềm
	CONSTRAINT dm_loai_goi_ma_key UNIQUE (ma),
	CONSTRAINT dm_loai_goi_pkey PRIMARY KEY (id)
);

CREATE TABLE dm_loai_hoi_dong_kiem_nhap (
	ten_loai varchar NULL,
	ma_loai int4 NULL,
	su_dung bool NULL,
	id uuid DEFAULT gen_random_uuid() NOT NULL,
	ngay_tao timestamp DEFAULT now() NOT NULL,
	nguoi_tao varchar(100) DEFAULT '''system'''::character varying NOT NULL,
	ngay_cap_nhat timestamp DEFAULT now() NOT NULL,
	nguoi_cap_nhat varchar(100) DEFAULT '''system'''::character varying NOT NULL,
	bi_xoa int2 DEFAULT 0 NULL,
	ngay_xoa timestamp NULL,
	nguoi_xoa varchar(100) NULL,
	CONSTRAINT dm_loai_hoi_dong_kiem_nhap_pkey PRIMARY KEY (id)
);

CREATE TABLE dm_loai_hop_dong (
	ma varchar NOT NULL,
	ten varchar NULL,
	hoat_dong int2 NOT NULL,
	id uuid DEFAULT gen_random_uuid() NOT NULL, -- Key của bảng
	ngay_tao timestamp DEFAULT now() NOT NULL, -- Ngày tạo
	nguoi_tao varchar DEFAULT 'system'::character varying NOT NULL, -- Người tạo
	ngay_cap_nhat timestamp DEFAULT now() NOT NULL, -- Ngày cập nhật
	nguoi_cap_nhat varchar DEFAULT 'system'::character varying NOT NULL, -- Người cập nhật
	bi_xoa int2 DEFAULT 0 NULL, -- Bị xóa mềm
	ngay_xoa timestamp NULL, -- Ngày xóa mềm
	nguoi_xoa varchar NULL, -- Người xóa mềm
	CONSTRAINT dm_loai_hop_dong_ma_key UNIQUE (ma),
	CONSTRAINT dm_loai_hop_dong_pkey PRIMARY KEY (id)
);

CREATE TABLE dm_loai_ke_don (
	id uuid DEFAULT gen_random_uuid() NOT NULL,
	ma_cskcb varchar(25) NULL,
	ma_loai_ke_don varchar(25) NOT NULL,
	ten_loai_ke_don varchar(255) NOT NULL,
	ghi_chu text NULL,
	so_thu_tu int4 NULL,
	su_dung bool DEFAULT true NOT NULL,
	bi_xoa int2 DEFAULT 0 NOT NULL,
	nguoi_tao varchar DEFAULT 'system'::character varying NULL,
	ngay_tao timestamp DEFAULT now() NULL,
	nguoi_cap_nhat varchar DEFAULT 'system'::character varying NULL,
	ngay_cap_nhat timestamp DEFAULT now() NULL,
	nguoi_xoa varchar NULL,
	ngay_xoa timestamp NULL,
	pq_loai_dieu_tri _varchar NULL,
	pq_doi_tuong_benh_nhan _varchar NULL,
	thu_tu_hien_thi int4 NULL, -- Số thứ tự hiển thị
	CONSTRAINT dm_loai_ke_don_ma_loai_ke_don_key UNIQUE (ma_loai_ke_don),
	CONSTRAINT dm_loai_ke_don_pkey PRIMARY KEY (id)
);

CREATE TABLE dm_loai_ky_so (
	ma varchar NOT NULL, -- Mã loại ký số
	ten varchar NULL, -- Tên loại ký số
	mo_ta text NULL, -- Mô tả
	id uuid DEFAULT gen_random_uuid() NOT NULL, -- Key của bảng
	ngay_tao timestamp DEFAULT now() NOT NULL, -- Ngày tạo
	nguoi_tao varchar DEFAULT 'system'::character varying NOT NULL, -- Người tạo
	ngay_cap_nhat timestamp DEFAULT now() NOT NULL, -- Ngày cập nhật
	nguoi_cap_nhat varchar DEFAULT 'system'::character varying NOT NULL, -- Người cập nhật
	bi_xoa int2 DEFAULT 0 NULL, -- Bị xóa mềm
	ngay_xoa timestamp NULL, -- Ngày xóa mềm
	nguoi_xoa varchar NULL, -- Người xóa mềm
	is_platform int2 DEFAULT 1 NULL,
	CONSTRAINT dm_loai_ky_so_ma_key UNIQUE (ma),
	CONSTRAINT dm_loai_ky_so_pkey PRIMARY KEY (id)
);

CREATE TABLE dm_loai_ly_do_nhap_xuat (
	ten_loai varchar NULL,
	ma_ly_do int4 NULL,
	su_dung bool DEFAULT true NULL, -- su_dung
	id uuid DEFAULT gen_random_uuid() NOT NULL, -- Key của bảng
	ngay_tao timestamp DEFAULT now() NOT NULL, -- Ngày tạo
	nguoi_tao varchar(100) DEFAULT 'system'::character varying NOT NULL, -- Người tạo
	ngay_cap_nhat timestamp DEFAULT now() NOT NULL, -- Ngày cập nhật
	nguoi_cap_nhat varchar(100) DEFAULT 'system'::character varying NOT NULL, -- Người cập nhật
	bi_xoa int2 DEFAULT 0 NULL, -- Bị xóa mềm
	ngay_xoa timestamp NULL, -- Ngày xóa mềm
	nguoi_xoa varchar(100) NULL, -- Người xóa mềm
	CONSTRAINT dm_loai_ly_do_nhap_xuat_pkey PRIMARY KEY (id)
);

CREATE TABLE dm_loai_mau (
	ma_loai varchar NULL,
	ten_loai varchar NULL,
	ghi_chu varchar NULL,
	su_dung bool NULL,
	id uuid DEFAULT gen_random_uuid() NOT NULL, -- Key của bảng
	ngay_tao timestamp DEFAULT now() NOT NULL, -- Ngày tạo
	nguoi_tao varchar(100) DEFAULT '''system'''::character varying NOT NULL, -- Người tạo
	ngay_cap_nhat timestamp DEFAULT now() NOT NULL, -- Ngày cập nhật
	nguoi_cap_nhat varchar(100) DEFAULT '''system'''::character varying NOT NULL, -- Người cập nhật
	bi_xoa int2 DEFAULT 0 NULL, -- Bị xóa mềm
	ngay_xoa timestamp NULL, -- Ngày xóa mềm
	nguoi_xoa varchar(100) NULL, -- Người xóa mềm
	CONSTRAINT dm_loai_mau_pk_id PRIMARY KEY (id)
);

CREATE TABLE dm_loai_nhom_bao_cao (
	id uuid DEFAULT gen_random_uuid() NOT NULL,
	ten_loai varchar(255) NOT NULL,
	ghi_chu varchar(255) NULL,
	ngay_tao timestamp DEFAULT now() NOT NULL,
	nguoi_tao varchar(100) DEFAULT 'system'::character varying NOT NULL,
	ngay_cap_nhat timestamp DEFAULT now() NOT NULL,
	nguoi_cap_nhat varchar(100) DEFAULT 'system'::character varying NOT NULL,
	bi_xoa int2 DEFAULT 0 NOT NULL,
	nguoi_xoa varchar(100) NULL,
	ngay_xoa timestamp NULL,
	su_dung int2 DEFAULT 0 NOT NULL,
	CONSTRAINT dm_loai_nhom_bao_cao_pkey PRIMARY KEY (id)
);

CREATE TABLE dm_loai_phan_khu (
	ma_loai_phan_khu varchar NOT NULL,
	ten_loai_phan_khu varchar NOT NULL,
	ghi_chu varchar NULL,
	stt int2 NULL,
	su_dung bool DEFAULT true NULL,
	id uuid DEFAULT gen_random_uuid() NOT NULL, -- Key của bảng
	ngay_xoa timestamp NULL, -- Ngày xóa mềm
	ngay_tao timestamp DEFAULT now() NOT NULL, -- Ngày tạo
	nguoi_tao text DEFAULT 'system'::text NOT NULL, -- Người tạo
	ngay_cap_nhat timestamp DEFAULT now() NOT NULL, -- Ngày cập nhật
	nguoi_cap_nhat text DEFAULT 'system'::text NOT NULL, -- Người cập nhật
	nguoi_xoa varchar(100) NULL, -- Người xóa mềm
	bi_xoa int2 DEFAULT 0 NULL, -- Bị xóa mềm
	CONSTRAINT dm_loai_phan_khu_ma_loai_phan_khu_key UNIQUE (ma_loai_phan_khu),
	CONSTRAINT dm_loai_phan_khu_pkey PRIMARY KEY (id)
);

CREATE TABLE dm_loai_phieu (
	ma varchar(100) NOT NULL, -- Mã loại phiếu
	ten varchar(100) NULL, -- Tên loại phiếu
	so_thu_tu_hsba int4 NULL, -- Số thứ tự hồ sơ bệnh án
	ma_loai_dieu_tri varchar(100) NULL, -- Mã loại điều trị
	mo_ta text NULL, -- Mô tả
	id uuid DEFAULT gen_random_uuid() NOT NULL, -- Key của bảng
	ngay_tao timestamp DEFAULT now() NOT NULL, -- Ngày tạo
	nguoi_tao varchar(100) DEFAULT 'system'::character varying NOT NULL, -- Người tạo
	ngay_cap_nhat timestamp DEFAULT now() NOT NULL, -- Ngày cập nhật
	nguoi_cap_nhat varchar(100) DEFAULT 'system'::character varying NOT NULL, -- Người cập nhật
	bi_xoa int2 DEFAULT 0 NULL, -- Bị xóa mềm
	ngay_xoa timestamp NULL, -- Ngày xóa mềm
	nguoi_xoa varchar(100) NULL, -- Người xóa mềm
	loai int2 NULL, -- 1 - Theo bệnh nhân ¶2 - Phiếu in khác và báo cáo.
	CONSTRAINT dm_loai_phieu_ma_key UNIQUE (ma),
	CONSTRAINT dm_loai_phieu_pkey PRIMARY KEY (id)
);

CREATE TABLE dm_loai_phieu_linh (
	ma_phieu_linh varchar NOT NULL,
	ten_phieu_linh varchar NOT NULL,
	ghi_chu text NULL,
	su_dung bool DEFAULT true NULL,
	id uuid DEFAULT gen_random_uuid() NOT NULL,
	deleted_at timestamp NULL,
	created_at timestamp DEFAULT now() NOT NULL,
	created_by text NOT NULL,
	updated_at timestamp DEFAULT now() NOT NULL,
	updated_by text NOT NULL,
	CONSTRAINT dm_loai_phieu_linh_ma_phieu_linh_key UNIQUE (ma_phieu_linh),
	CONSTRAINT dm_loai_phieu_linh_pkey PRIMARY KEY (id)
);

CREATE TABLE dm_loai_phieu_thanh_toan (
	ten varchar NULL, -- Tên loại phiếu thanh toán
	ma varchar NULL, -- Mã loại phiếu thanh toán
	ghi_chu varchar NULL, -- Ghi chú
	su_dung int4 DEFAULT 1 NOT NULL, -- 0: Không; 1: Có
	id uuid DEFAULT gen_random_uuid() NOT NULL, -- Key của bảng
	ngay_tao timestamp DEFAULT now() NOT NULL, -- Ngày tạo
	nguoi_tao varchar DEFAULT 'system'::character varying NOT NULL, -- Người tạo
	ngay_cap_nhat timestamp DEFAULT now() NOT NULL, -- Ngày cập nhật
	nguoi_cap_nhat varchar DEFAULT 'system'::character varying NOT NULL, -- Người cập nhật
	bi_xoa int2 DEFAULT 0 NULL, -- Bị xóa mềm
	ngay_xoa timestamp NULL, -- Ngày xóa mềm
	nguoi_xoa varchar NULL, -- Người xóa mềm
	ma_cskcb varchar(25) NULL, -- Mã cơ sở khám chữa bệnh
	CONSTRAINT dm_loai_phieu_thanh_toan_ma_key UNIQUE (ma),
	CONSTRAINT dm_loai_phieu_thanh_toan_pkey PRIMARY KEY (id)
);

CREATE TABLE dm_loai_phong_ban (
	ma_loai_phong_ban varchar(25) NOT NULL,
	ten_loai_phong_ban varchar(255) NOT NULL,
	ten_goi_khac varchar(255) NULL,
	ghi_chu varchar(255) NULL,
	ten_khong_dau varchar(255) NULL,
	stt int2 NULL,
	id uuid DEFAULT gen_random_uuid() NOT NULL, -- Key của bảng
	ngay_xoa timestamp NULL, -- Ngày xóa mềm
	ngay_tao timestamp DEFAULT now() NOT NULL, -- Ngày tạo
	nguoi_tao text NOT NULL, -- Người tạo
	ngay_cap_nhat timestamp DEFAULT now() NOT NULL, -- Ngày cập nhật
	nguoi_cap_nhat text NOT NULL, -- Người cập nhật
	su_dung bool DEFAULT true NULL,
	nguoi_xoa varchar(100) NULL, -- Người xóa mềm
	bi_xoa int2 DEFAULT 0 NULL, -- Bị xóa mềm
	CONSTRAINT dm_loai_phong_ban_ma_loai_phong_ban_key UNIQUE (ma_loai_phong_ban),
	CONSTRAINT dm_loai_phong_ban_pkey PRIMARY KEY (id),
	CONSTRAINT dm_loai_phong_ban_ten_loai_phong_ban_key UNIQUE (ten_loai_phong_ban)
);

CREATE TABLE dm_loai_pttt (
	ma_loai varchar NOT NULL,
	ten_loai varchar NOT NULL,
	thu_tu int2 NOT NULL,
	id uuid DEFAULT gen_random_uuid() NOT NULL, -- Key của bảng
	ngay_tao timestamp DEFAULT now() NOT NULL, -- Ngày tạo
	nguoi_tao varchar DEFAULT 'system'::character varying NOT NULL, -- Người tạo
	ngay_cap_nhat timestamp DEFAULT now() NOT NULL, -- Ngày cập nhật
	nguoi_cap_nhat varchar DEFAULT 'system'::character varying NOT NULL, -- Người cập nhật
	bi_xoa int2 DEFAULT 0 NULL, -- Bị xóa mềm
	ngay_xoa timestamp NULL, -- Ngày xóa mềm
	nguoi_xoa varchar NULL, -- Người xóa mềm
	su_dung bool NULL,
	CONSTRAINT dm_loai_pttt_pkey PRIMARY KEY (id)
);

CREATE TABLE dm_loai_so (
	ma varchar NOT NULL,
	ten varchar NULL,
	su_dung int4 NULL, -- 0: Không sử dụng; 1: Sử dụng
	ghi_chu varchar NULL,
	ma_cskcb varchar NULL, -- Mã cơ sở khám chữa bệnh
	id uuid DEFAULT gen_random_uuid() NOT NULL, -- Key của bảng
	ngay_tao timestamp DEFAULT now() NOT NULL, -- Ngày tạo
	nguoi_tao varchar DEFAULT 'system'::character varying NOT NULL, -- Người tạo
	ngay_cap_nhat timestamp DEFAULT now() NOT NULL, -- Ngày cập nhật
	nguoi_cap_nhat varchar DEFAULT 'system'::character varying NOT NULL, -- Người cập nhật
	bi_xoa int2 DEFAULT 0 NULL, -- Bị xóa mềm
	ngay_xoa timestamp NULL, -- Ngày xóa mềm
	nguoi_xoa varchar NULL, -- Người xóa mềm
	loai_chung_tu_id uuid NULL, -- ID loại chứng từ
	CONSTRAINT dm_loai_so_ma_key UNIQUE (ma),
	CONSTRAINT dm_loai_so_pkey PRIMARY KEY (id)
);

CREATE TABLE dm_loai_so_loai_phieu_thanh_toan (
	loai_so_id uuid NOT NULL, -- ID loại sổ
	loai_phieu_thanh_toan_id uuid NOT NULL, -- ID loại phiếu thanh toán
	id uuid DEFAULT gen_random_uuid() NOT NULL, -- Key của bảng
	ngay_tao timestamp DEFAULT now() NOT NULL, -- Ngày tạo
	nguoi_tao varchar DEFAULT 'system'::character varying NOT NULL, -- Người tạo
	ngay_cap_nhat timestamp DEFAULT now() NOT NULL, -- Ngày cập nhật
	nguoi_cap_nhat varchar DEFAULT 'system'::character varying NOT NULL, -- Người cập nhật
	bi_xoa int2 DEFAULT 0 NULL, -- Bị xóa mềm
	ngay_xoa timestamp NULL, -- Ngày xóa mềm
	nguoi_xoa varchar NULL, -- Người xóa mềm
	su_dung int4 DEFAULT 1 NOT NULL, -- 0: Không; 1: Có
	ma_cskcb varchar(25) NULL, -- Mã cơ sở khám chữa bệnh
	CONSTRAINT dm_loai_so_loai_phieu_thanh_toan_pkey PRIMARY KEY (id)
);

CREATE TABLE dm_loai_tai_khoan (
	id uuid DEFAULT gen_random_uuid() NOT NULL, -- Key của bảng
	ma varchar NOT NULL, -- Mã loại tài khoản
	ten varchar NOT NULL, -- Tên loại tài khoản.
	bi_xoa int2 DEFAULT 0 NOT NULL, -- Bị xóa mềm
	nguoi_tao varchar(100) DEFAULT 'system'::character varying NOT NULL, -- Người tạo
	ngay_tao timestamp DEFAULT CURRENT_TIMESTAMP NOT NULL, -- Ngày tạo
	nguoi_cap_nhat varchar(100) NULL, -- Người cập nhật
	ngay_cap_nhat timestamp DEFAULT CURRENT_TIMESTAMP NOT NULL, -- Ngày cập nhật
	nguoi_xoa varchar(100) NULL, -- Người xóa mềm
	ngay_xoa timestamp NULL, -- Ngày xóa mềm
	CONSTRAINT dm_loai_tai_khoan_ma_key UNIQUE (ma),
	CONSTRAINT dm_loai_tai_khoan_pkey PRIMARY KEY (id)
);

CREATE TABLE dm_loai_tuoi (
	maloai varchar(25) NULL,
	tenloai varchar(255) NULL,
	tenkhac varchar(255) NULL,
	tenkhongdau varchar(255) NULL,
	stt int4 NULL,
	sudung bool NULL,
	id uuid DEFAULT gen_random_uuid() NOT NULL,
	deleted_at timestamp NULL,
	ngay_tao timestamp DEFAULT now() NOT NULL,
	nguoi_tao text NOT NULL,
	ngay_cap_nhat timestamp DEFAULT now() NOT NULL,
	nguoi_cap_nhat text NOT NULL,
	ma_cskcb varchar(100) NULL,
	bi_xoa int2 DEFAULT 0 NOT NULL,
	ngay_xoa timestamp NULL,
	nguoi_xoa varchar(100) NULL,
	CONSTRAINT dm_loai_tuoi_pkey PRIMARY KEY (id)
);

CREATE TABLE dm_loai_uy_quyen_ky_so (
	id uuid DEFAULT gen_random_uuid() NOT NULL,
	bi_xoa int2 DEFAULT 0 NOT NULL,
	ma_cskcb varchar(50) NULL,
	ngay_tao timestamp DEFAULT now() NOT NULL,
	nguoi_tao varchar(50) NULL,
	ngay_cap_nhat timestamp DEFAULT now() NOT NULL,
	nguoi_cap_nhat varchar(50) NULL,
	ngay_xoa timestamp NULL,
	nguoi_xoa varchar(50) NULL,
	ma varchar(50) NOT NULL,
	ten varchar(255) NOT NULL,
	ghi_chu text NULL,
	su_dung int2 DEFAULT 1 NOT NULL,
	CONSTRAINT dm_loai_uy_quyen_ky_so_ma_key UNIQUE (ma),
	CONSTRAINT dm_loai_uy_quyen_ky_so_pkey PRIMARY KEY (id)
);

CREATE TABLE dm_loai_vai_tro (
	ma_loai_vai_tro varchar NOT NULL,
	ten_loai_vai_tro varchar NOT NULL,
	thu_tu int2 NOT NULL,
	id uuid DEFAULT gen_random_uuid() NOT NULL, -- Key của bảng
	ngay_tao timestamp DEFAULT now() NOT NULL, -- Ngày tạo
	nguoi_tao varchar DEFAULT 'system'::character varying NOT NULL, -- Người tạo
	ngay_cap_nhat timestamp DEFAULT now() NOT NULL, -- Ngày cập nhật
	nguoi_cap_nhat varchar DEFAULT 'system'::character varying NOT NULL, -- Người cập nhật
	bi_xoa int2 DEFAULT 0 NULL, -- Bị xóa mềm
	ngay_xoa timestamp NULL, -- Ngày xóa mềm
	nguoi_xoa varchar NULL, -- Người xóa mềm
	su_dung bool NULL,
	CONSTRAINT dm_loai_vai_tro_ma_loai_vai_tro_key UNIQUE (ma_loai_vai_tro),
	CONSTRAINT dm_loai_vai_tro_pkey PRIMARY KEY (id)
);

CREATE TABLE dm_loai_vet_mo (
	ma_loai_vet_mo varchar(50) NOT NULL,
	ten_loai_vet_mo varchar(255) NOT NULL,
	su_dung bool NULL,
	id uuid DEFAULT gen_random_uuid() NOT NULL,
	ngay_tao timestamp DEFAULT now() NOT NULL,
	nguoi_tao varchar(100) DEFAULT '''system'''::character varying NOT NULL,
	ngay_cap_nhat timestamp DEFAULT now() NOT NULL,
	nguoi_cap_nhat varchar(100) DEFAULT '''system'''::character varying NOT NULL,
	bi_xoa int2 DEFAULT 0 NULL,
	ngay_xoa timestamp NULL,
	nguoi_xoa varchar(100) NULL,
	CONSTRAINT dm_loai_vet_mo_pkey PRIMARY KEY (id)
);

CREATE TABLE dm_ly_do_chuyen_khoa (
	ma varchar(50) NOT NULL,
	ten varchar(255) NOT NULL,
	ghi_chu text NULL,
	id uuid DEFAULT gen_random_uuid() NOT NULL, -- Key của bảng
	ngay_tao timestamp DEFAULT now() NOT NULL, -- Ngày tạo
	nguoi_tao varchar(100) DEFAULT 'system'::character varying NOT NULL, -- Người tạo
	ngay_cap_nhat timestamp DEFAULT now() NOT NULL, -- Ngày cập nhật
	nguoi_cap_nhat varchar(100) DEFAULT 'system'::character varying NOT NULL, -- Người cập nhật
	bi_xoa int2 DEFAULT 0 NULL, -- Bị xóa mềm
	ngay_xoa timestamp NULL, -- Ngày xóa mềm
	nguoi_xoa varchar(100) NULL, -- Người xóa mềm
	CONSTRAINT dm_ly_do_chuyen_khoa_pkey PRIMARY KEY (id)
);

CREATE TABLE dm_ly_do_hoi_chan (
	ma_nhom text NOT NULL,
	ma bpchar(1) NOT NULL,
	ten text NULL,
	id uuid DEFAULT gen_random_uuid() NOT NULL, -- Key của bảng
	ngay_tao timestamp DEFAULT now() NOT NULL, -- Ngày tạo
	nguoi_tao varchar(100) DEFAULT 'system'::character varying NOT NULL, -- Người tạo
	ngay_cap_nhat timestamp DEFAULT now() NOT NULL, -- Ngày cập nhật
	nguoi_cap_nhat varchar(100) DEFAULT 'system'::character varying NOT NULL, -- Người cập nhật
	bi_xoa int2 DEFAULT 0 NULL, -- Bị xóa mềm
	ngay_xoa timestamp NULL, -- Ngày xóa mềm
	nguoi_xoa varchar(100) NULL, -- Người xóa mềm
	CONSTRAINT dm_ly_do_hoi_chan_pkey PRIMARY KEY (id)
);

CREATE TABLE dm_ly_do_huy_chung_tu (
	ten varchar NOT NULL, -- Tên lý do
	ma varchar NOT NULL, -- Mã lý do
	ghi_chu varchar NULL, -- Ghi chú
	id uuid DEFAULT gen_random_uuid() NOT NULL, -- Key của bảng
	ngay_tao timestamp DEFAULT now() NOT NULL, -- Ngày tạo
	nguoi_tao varchar DEFAULT 'system'::character varying NOT NULL, -- Người tạo
	ngay_cap_nhat timestamp DEFAULT now() NOT NULL, -- Ngày cập nhật
	nguoi_cap_nhat varchar DEFAULT 'system'::character varying NOT NULL, -- Người cập nhật
	bi_xoa int2 DEFAULT 0 NULL, -- Bị xóa mềm
	ngay_xoa timestamp NULL, -- Ngày xóa mềm
	nguoi_xoa varchar NULL, -- Người xóa mềm
	CONSTRAINT dm_ly_do_huy_chung_tu_pkey PRIMARY KEY (id)
);

CREATE TABLE dm_ly_do_nhap_vien (
	ma_ly_do_nhap_vien varchar(25) NOT NULL,
	ten_ly_do_nhap_vien varchar(255) NOT NULL,
	ghi_chu varchar(255) NULL,
	ten_khong_dau varchar(255) NULL,
	stt int4 NULL,
	su_dung bool NULL,
	id uuid DEFAULT gen_random_uuid() NOT NULL, -- Key của bảng
	ngay_tao timestamp DEFAULT now() NOT NULL, -- Ngày tạo
	nguoi_tao varchar(100) DEFAULT 'system'::character varying NOT NULL, -- Người tạo
	ngay_cap_nhat timestamp DEFAULT now() NOT NULL, -- Ngày cập nhật
	nguoi_cap_nhat varchar(100) DEFAULT 'system'::character varying NOT NULL, -- Người cập nhật
	bi_xoa int2 DEFAULT 0 NULL, -- Bị xóa mềm
	ngay_xoa timestamp NULL, -- Ngày xóa mềm
	nguoi_xoa varchar(100) NULL, -- Người xóa mềm
	CONSTRAINT dm_ly_do_nhap_vien_pkey PRIMARY KEY (id)
);

CREATE TABLE dm_ly_do_nhap_xuat (
	malydo varchar NOT NULL,
	tenlydo varchar NULL,
	ghi_chu text NULL,
	su_dung bool NOT NULL,
	id uuid DEFAULT gen_random_uuid() NOT NULL, -- Key của bảng
	ngay_tao timestamp DEFAULT now() NOT NULL, -- Ngày tạo
	nguoi_tao varchar DEFAULT 'system'::character varying NOT NULL, -- Người tạo
	ngay_cap_nhat timestamp DEFAULT now() NOT NULL, -- Ngày cập nhật
	nguoi_cap_nhat varchar DEFAULT 'system'::character varying NOT NULL, -- Người cập nhật
	bi_xoa int2 DEFAULT 0 NULL, -- Bị xóa mềm
	ngay_xoa timestamp NULL, -- Ngày xóa mềm
	nguoi_xoa varchar NULL, -- Người xóa mềm
	loai_ly_do int4 NULL, -- 0: nhập,¶1: xuất
	report_code varchar NULL,
	csytid int8 NULL,
	CONSTRAINT dm_ly_do_nhap_xuat_malydo_key UNIQUE (malydo),
	CONSTRAINT dm_ly_do_nhap_xuat_pkey PRIMARY KEY (id)
);

CREATE TABLE dm_ly_do_tiep_nhan (
	ma_ly_do_tn varchar(25) NOT NULL, -- Mã lý do tiếp nhận
	ten_ly_do_tn varchar(255) NOT NULL, -- Tên lý do tiếp nhận
	ten_khac varchar(255) NULL, -- Tên khác
	ten_khong_dau varchar(255) NULL, -- Tên không dấu
	stt int2 NULL, -- Số thứ tự
	su_dung bool DEFAULT true NULL, -- Sử dụng
	id uuid DEFAULT gen_random_uuid() NOT NULL, -- Key của bảng
	ngay_tao timestamp DEFAULT now() NOT NULL, -- Ngày tạo
	nguoi_tao varchar(100) DEFAULT 'system'::character varying NOT NULL, -- Người tạo
	ngay_cap_nhat timestamp DEFAULT now() NOT NULL, -- Ngày cập nhật
	nguoi_cap_nhat varchar(100) DEFAULT 'system'::character varying NOT NULL, -- Người cập nhật
	bi_xoa int2 DEFAULT 0 NULL, -- Bị xóa mềm
	ngay_xoa timestamp NULL, -- Ngày xóa mềm
	nguoi_xoa varchar(100) NULL, -- Người xóa mềm
	report_code varchar NULL, -- Report code KSK
	CONSTRAINT dm_ly_do_tiep_nhan_ma_ly_do_tn_key UNIQUE (ma_ly_do_tn),
	CONSTRAINT dm_ly_do_tiep_nhan_pkey PRIMARY KEY (id)
);

CREATE TABLE dm_ma_nhom_bhyt (
	ma_nhom varchar NOT NULL,
	ten_nhom varchar NOT NULL,
	ma_nhom_bang_ke varchar NULL,
	ten_nhom_bang_ke varchar NULL,
	so_qd varchar NULL,
	ngay_ap_dung date NULL,
	su_dung bool DEFAULT true NULL,
	id uuid DEFAULT gen_random_uuid() NOT NULL, -- Key của bảng
	ngay_xoa timestamp NULL, -- Ngày xóa mềm
	ngay_tao timestamp DEFAULT now() NOT NULL, -- Ngày tạo
	nguoi_tao text NOT NULL, -- Người tạo
	ngay_cap_nhat timestamp DEFAULT now() NOT NULL, -- Ngày cập nhật
	nguoi_cap_nhat text NOT NULL, -- Người cập nhật
	nguoi_xoa varchar(100) NULL, -- Người xóa mềm
	bi_xoa int2 DEFAULT 0 NULL, -- Bị xóa mềm
	nhom_bhyt_id serial4 NULL, -- Mapping với duc_thuocvattu
	CONSTRAINT dm_ma_nhom_bhyt_ma_nhom_key UNIQUE (ma_nhom),
	CONSTRAINT dm_ma_nhom_bhyt_pkey PRIMARY KEY (id)
);

CREATE TABLE dm_ma_nhom_dich_vu (
	ma_nhom_dich_vu varchar(25) NOT NULL,
	ten_nhom_dich_vu varchar(255) NOT NULL,
	ma_nhom_bhyt varchar(25) NOT NULL, -- FK: dmc_ma_nhom_bhyt
	ten_phieu_in varchar(255) NULL,
	ma_loai_dich_vu varchar(25) NOT NULL, -- FK: dm_loai_dich_vu
	ket_noi_ris_pacs bool NULL,
	la_nhom_con bool NULL,
	ma_nhom_cha varchar(25) NULL, -- FK: dm_ma_nhom_dich_vu
	report_cd varchar(25) NULL,
	report_kq varchar(25) NULL,
	su_dung bool DEFAULT true NULL,
	id uuid DEFAULT gen_random_uuid() NOT NULL, -- Key của bảng
	ngay_xoa timestamp NULL, -- Ngày xóa mềm
	ngay_tao timestamp DEFAULT now() NOT NULL, -- Ngày tạo
	nguoi_tao varchar(100) DEFAULT 'system'::character varying NOT NULL, -- Người tạo
	ngay_cap_nhat timestamp DEFAULT now() NOT NULL, -- Ngày cập nhật
	nguoi_cap_nhat varchar(100) DEFAULT 'system'::character varying NOT NULL, -- Người cập nhật
	nguoi_xoa varchar(100) NULL, -- Người xóa mềm
	bi_xoa int2 DEFAULT 0 NULL, -- Bị xóa mềm
	is_tach_phieu bool DEFAULT false NULL, -- Tách số phiếu riêng
	ma_cskcb varchar(100) NULL,
	ma_ket_noi_pacs varchar(255) NULL,
	CONSTRAINT dm_ma_nhom_dich_vu_ma_nhom_dich_vu_key UNIQUE (ma_nhom_dich_vu),
	CONSTRAINT dm_ma_nhom_dich_vu_pk_id PRIMARY KEY (id),
	CONSTRAINT dm_ma_nhom_dich_vu_ten_nhom_dich_vu_key UNIQUE (ten_nhom_dich_vu)
);

CREATE TABLE dm_ma_nhom_thau (
	ma varchar NOT NULL,
	ten varchar NOT NULL,
	id uuid DEFAULT gen_random_uuid() NOT NULL,
	deleted_at timestamp NULL,
	created_at timestamp DEFAULT now() NOT NULL,
	created_by text NOT NULL,
	updated_at timestamp DEFAULT now() NOT NULL,
	updated_by text NOT NULL,
	manhomthauid int4 NULL,
	CONSTRAINT dm_ma_nhom_thau_id_key UNIQUE (id),
	CONSTRAINT dm_ma_nhom_thau_ma_key UNIQUE (ma),
	CONSTRAINT dm_ma_nhom_thau_pkey PRIMARY KEY (id)
);

CREATE TABLE dm_mau (
	ma_mau varchar NULL,
	ten_mau varchar NULL,
	thanh_phan varchar NULL,
	donvitinh_id int2 NULL,
	nhom_mau_id uuid NULL,
	nhom_rh uuid NULL,
	so_mi int4 NULL,
	cong_dung varchar NULL,
	bhyt bool NULL,
	ma_bhyt varchar(25) NULL,
	su_dung bool NULL,
	id uuid DEFAULT gen_random_uuid() NOT NULL, -- Key của bảng
	ngay_tao timestamp DEFAULT now() NOT NULL, -- Ngày tạo
	nguoi_tao varchar(100) DEFAULT 'system'::character varying NOT NULL, -- Người tạo
	ngay_cap_nhat timestamp DEFAULT now() NOT NULL, -- Ngày cập nhật
	nguoi_cap_nhat varchar(100) DEFAULT 'system'::character varying NOT NULL, -- Người cập nhật
	bi_xoa int2 DEFAULT 0 NULL, -- Bị xóa mềm
	ngay_xoa timestamp NULL, -- Ngày xóa mềm
	nguoi_xoa varchar(100) NULL, -- Người xóa mềm
	mau_id int4 NULL,
	loai_ma_id uuid NULL,
	CONSTRAINT dm_mau_pkey PRIMARY KEY (id)
);

CREATE TABLE dm_mau_xml (
	ma varchar NOT NULL, -- Mã
	ten varchar NULL, -- Tên
	id uuid DEFAULT gen_random_uuid() NOT NULL, -- Key của bảng
	ngay_tao timestamp DEFAULT now() NOT NULL, -- Ngày tạo
	nguoi_tao varchar DEFAULT 'system'::character varying NOT NULL, -- Người tạo
	ngay_cap_nhat timestamp DEFAULT now() NOT NULL, -- Ngày cập nhật
	nguoi_cap_nhat varchar DEFAULT 'system'::character varying NOT NULL, -- Người cập nhật
	bi_xoa int2 DEFAULT 0 NULL, -- Bị xóa mềm
	ngay_xoa timestamp NULL, -- Ngày xóa mềm
	nguoi_xoa varchar NULL, -- Người xóa mềm
	mo_ta xml NULL,
	is_platform int2 DEFAULT 1 NULL,
	is_common int2 DEFAULT 0 NULL,
	thu_tuc varchar(500) NULL,
	thong_tu varchar(255) NULL,
	ngay_ban_hanh timestamp NULL,
	CONSTRAINT dm_mau_xml_ma_key UNIQUE (ma),
	CONSTRAINT dm_mau_xml_pkey PRIMARY KEY (id)
);

CREATE TABLE dm_mau_xml_field_mapping (
	id uuid DEFAULT gen_random_uuid() NOT NULL,
	ma_mau_xml varchar(100) NOT NULL,
	source_code varchar(100) NOT NULL,
	placeholder varchar(100) NOT NULL,
	column_name varchar(100) NULL,
	sql_expression text NULL,
	data_type varchar(50) NULL,
	format_pattern varchar(100) NULL,
	default_value text DEFAULT ''::text NULL,
	hoat_dong int2 DEFAULT 1 NULL,
	bi_xoa int2 DEFAULT 0 NULL,
	ngay_tao timestamp DEFAULT now() NULL,
	nguoi_tao varchar(100) NULL,
	final_expression text NULL,
	is_public int2 DEFAULT 1 NULL,
	CONSTRAINT dm_mau_xml_field_mapping_ma_mau_xml_placeholder_key UNIQUE (ma_mau_xml, placeholder),
	CONSTRAINT dm_mau_xml_field_mapping_pkey PRIMARY KEY (id)
);

CREATE TABLE dm_mau_xml_field_mapping_bk (
	id uuid NULL,
	ma_mau_xml varchar(100) NULL,
	source_code varchar(100) NULL,
	placeholder varchar(100) NULL,
	column_name varchar(100) NULL,
	sql_expression text NULL,
	data_type varchar(50) NULL,
	format_pattern varchar(100) NULL,
	default_value text NULL,
	hoat_dong int2 NULL,
	bi_xoa int2 NULL,
	ngay_tao timestamp NULL,
	nguoi_tao varchar(100) NULL,
	final_expression text NULL,
	is_public int2 NULL
);

CREATE TABLE dm_mau_xml_source (
	id uuid DEFAULT gen_random_uuid() NOT NULL,
	ma_mau_xml varchar(100) NOT NULL,
	source_code varchar(100) NOT NULL,
	table_name varchar(100) NOT NULL,
	filter_column varchar(100) NOT NULL,
	filter_param varchar(100) NOT NULL,
	order_by varchar(200) NULL,
	hoat_dong int2 DEFAULT 1 NULL,
	bi_xoa int2 DEFAULT 0 NULL,
	ngay_tao timestamp DEFAULT now() NULL,
	nguoi_tao varchar(100) NULL,
	source_type varchar(20) DEFAULT 'ONE'::character varying NOT NULL,
	extra_where text NULL,
	join_type varchar(20) DEFAULT 'LEFT'::character varying NULL,
	CONSTRAINT dm_mau_xml_source_ma_mau_xml_source_code_key UNIQUE (ma_mau_xml, source_code),
	CONSTRAINT dm_mau_xml_source_pkey PRIMARY KEY (id)
);

CREATE TABLE dm_nghe_nghiep (
	ma varchar(25) NULL,
	ten varchar(255) NULL,
	sudung bool NULL,
	id uuid DEFAULT gen_random_uuid() NOT NULL,
	ngay_tao timestamp DEFAULT now() NOT NULL,
	nguoi_tao text NOT NULL,
	ngay_cap_nhat timestamp DEFAULT now() NOT NULL,
	nguoi_cap_nhat text NOT NULL,
	ma_cskcb varchar(100) NULL,
	bi_xoa int2 DEFAULT 0 NOT NULL,
	ngay_xoa timestamp NULL,
	nguoi_xoa varchar(100) NULL,
	tu_tuoi int2 NULL,
	den_tuoi int2 NULL,
	CONSTRAINT dm_nghe_nghiep_pkey PRIMARY KEY (id)
);

CREATE TABLE dm_nguon_kinh_phi (
	ten varchar(255) NOT NULL, -- Tên nguồn kinh phí
	ma varchar(25) NOT NULL, -- Mã nguồn kinh phí
	ten_goi_khac varchar(255) NULL, -- Tên gọi khác
	ghi_chu varchar(255) NULL, -- Ghi chú
	ten_khong_dau varchar(255) NULL, -- Tên không dấu
	id uuid DEFAULT gen_random_uuid() NOT NULL, -- Key của bảng
	ngay_tao timestamp DEFAULT now() NOT NULL, -- Ngày tạo
	nguoi_tao varchar(100) DEFAULT '''system'''::character varying NOT NULL, -- Người tạo
	ngay_cap_nhat timestamp DEFAULT now() NOT NULL, -- Ngày cập nhật
	nguoi_cap_nhat varchar(100) DEFAULT '''system'''::character varying NOT NULL, -- Người cập nhật
	bi_xoa int2 DEFAULT 0 NULL, -- Bị xóa mềm
	ngay_xoa timestamp NULL, -- Ngày xóa mềm
	nguoi_xoa varchar(100) NULL, -- Người xóa mềm
	su_dung bool DEFAULT true NOT NULL, -- Sử dụng
	CONSTRAINT dm_nguon_kinh_phi_pk_id PRIMARY KEY (id)
);

CREATE TABLE dm_nguonct (
	manguonct varchar NULL, -- Nhập mã chương trình 
	tennguonct varchar NULL, -- Nhập tên chương trình
	loaithanhtoan int4 NULL, -- Nhập loại thanh toán
	loaimiengiam int4 NULL, -- Nhập loại miễn giảm 
	phamviapdung int4 NULL, -- Nhập phạm vi áp dụng 
	ghichu varchar NULL, -- Nhập ghi chú 
	sudung bool NULL, -- Chọn thông tin sử dụng hay không sử dụng
	id uuid DEFAULT gen_random_uuid() NOT NULL, -- Key của bảng
	ngay_xoa timestamp NULL, -- Ngày xóa mềm
	ngay_tao timestamp DEFAULT now() NOT NULL, -- Ngày tạo
	nguoi_tao text NOT NULL, -- Người tạo
	ngay_cap_nhat timestamp DEFAULT now() NOT NULL, -- Ngày cập nhật
	nguoi_cap_nhat text NOT NULL, -- Người cập nhật
	nguoi_xoa varchar NULL, -- Người xóa mềm
	bi_xoa int2 DEFAULT 0 NULL, -- Bị xóa mềm
	CONSTRAINT dm_nguonct_pkey PRIMARY KEY (id)
);

CREATE TABLE dm_nhan_vien (
	id uuid DEFAULT gen_random_uuid() NOT NULL, -- Key của bảng
	ma_cskcb varchar NULL,
	ma_nhan_vien varchar(50) NOT NULL,
	ten_nhan_vien varchar(255) NOT NULL,
	cccd varchar(25) NULL,
	ngay_sinh date NULL,
	ma_gioi_tinh varchar NULL,
	dia_chi text NULL,
	ma_dan_toc varchar(25) NULL,
	ma_nghe_nghiep varchar NULL,
	loai_nhan_vien varchar(100) NULL,
	cchn_ls varchar NULL,
	cchn_cls varchar NULL,
	so_bhxh varchar NULL,
	chuc_vu_id uuid NULL,
	chuc_danh_id uuid NULL,
	hoc_ham_id uuid NULL,
	hoc_vi_id uuid NULL,
	trinh_do_chuyen_mon_id uuid NULL,
	chuyen_khoa_id uuid NULL,
	khoa_id uuid NULL,
	phong_id uuid NULL,
	ten_phieu_in varchar NULL,
	su_dung bool DEFAULT true NULL,
	bi_xoa int2 DEFAULT 0 NOT NULL,
	ngay_tao timestamp DEFAULT now() NOT NULL, -- Ngày tạo
	nguoi_tao varchar(100) DEFAULT 'system'::character varying NOT NULL, -- Người tạo
	ngay_cap_nhat timestamp DEFAULT now() NOT NULL, -- Ngày cập nhật
	nguoi_cap_nhat varchar(100) DEFAULT 'system'::character varying NOT NULL, -- Người cập nhật
	ngay_xoa timestamp NULL, -- Ngày xóa mềm
	nguoi_xoa varchar(100) NULL, -- Người xóa mềm
	nhanvienid serial4 NULL, -- Dùng cho phân hệ dược
	ma_csyt_truc_thuoc varchar(25) NULL, -- Mã CSYT trực thuộc (dùng cho trường hợp Nhân viên ngoài viện - loai_nhan_vien = 04)
	hinh_thuc_ky_id uuid NULL, -- ID Hình thức ký
	email varchar(100) NULL, -- Email
	anh_chan_ky_b64 text NULL, -- Ảnh chân ký base64
	gioi_tinh int2 GENERATED ALWAYS AS (ma_gioi_tinh::smallint) STORED NULL, -- Gioi tinh (cu)
	can_bo_hd_id uuid NULL, -- Thông tin cán bộ hướng dẫn
	chu_ky_so varchar(255) NULL, -- Chữ ký số
	nguoi_huong_dan_id uuid NULL, -- Thông tin người hướng dẫn
	ma_danh_hieu_khen_thuong varchar(20) NULL, -- Mã danh hiệu khen thưởng
	la_dong_dau bool DEFAULT false NOT NULL, -- Nhân viên có được quyền đongs dấu hay không true có quyền, false không có quyền.
	CONSTRAINT dm_nhan_vien_ma_nhan_vien_key UNIQUE (ma_nhan_vien),
	CONSTRAINT dm_nhan_vien_pk_id PRIMARY KEY (id)
);

CREATE TABLE dm_nhan_vien_so_thu_hoa_don (
	nhan_vien_id uuid NOT NULL, -- Id nhân viên
	so_thu_id uuid NOT NULL, -- Id sổ thu
	ky_hieu varchar NOT NULL, -- Ký hiệu hóa đơn
	su_dung int4 NOT NULL, -- 0: Không; 1: Có
	id uuid DEFAULT gen_random_uuid() NOT NULL, -- Key của bảng
	ngay_tao timestamp DEFAULT now() NOT NULL, -- Ngày tạo
	nguoi_tao varchar DEFAULT 'system'::character varying NOT NULL, -- Người tạo
	ngay_cap_nhat timestamp DEFAULT now() NOT NULL, -- Ngày cập nhật
	nguoi_cap_nhat varchar DEFAULT 'system'::character varying NOT NULL, -- Người cập nhật
	bi_xoa int2 DEFAULT 0 NULL, -- Bị xóa mềm
	ngay_xoa timestamp NULL, -- Ngày xóa mềm
	nguoi_xoa varchar NULL, -- Người xóa mềm
	ma_cskcb varchar(25) NULL, -- Mã cơ sở KCB
	CONSTRAINT dm_nhan_vien_so_thu_hoa_don_pkey PRIMARY KEY (id)
);

CREATE TABLE dm_nhom_abc_ven (
	ma_nhom_abc_ven varchar NOT NULL,
	ten_nhom_abc_ven varchar NOT NULL,
	ghi_chu text NULL,
	su_dung bool NOT NULL,
	id uuid DEFAULT gen_random_uuid() NOT NULL,
	deleted_at timestamp NULL,
	created_at timestamp DEFAULT now() NOT NULL,
	created_by text NOT NULL,
	updated_at timestamp DEFAULT now() NOT NULL,
	updated_by text NOT NULL,
	nhomabcvenid int4 NOT NULL,
	CONSTRAINT dm_nhom_abc_ven_id_key UNIQUE (id),
	CONSTRAINT dm_nhom_abc_ven_ma_nhom_abc_ven_key UNIQUE (ma_nhom_abc_ven),
	CONSTRAINT dm_nhom_abc_ven_nhomabcvenid_key UNIQUE (nhomabcvenid),
	CONSTRAINT dm_nhom_abc_ven_pkey PRIMARY KEY (id)
);

CREATE TABLE dm_nhom_bao_cao (
	ma_nhom_bao_cao varchar NULL,
	ten_nhom_bao_cao varchar NULL,
	su_dung bool NULL,
	nhombaocaoid serial4 NULL,
	id uuid DEFAULT gen_random_uuid() NOT NULL, -- Key của bảng
	deleted_at timestamp NULL,
	ngay_tao timestamp DEFAULT now() NOT NULL, -- Ngày tạo
	nguoi_tao varchar(100) DEFAULT 'system'::character varying NOT NULL, -- Người tạo
	ngay_cap_nhat timestamp DEFAULT now() NOT NULL, -- Ngày cập nhật
	nguoi_cap_nhat varchar(100) DEFAULT 'system'::character varying NOT NULL, -- Người cập nhật
	bi_xoa int2 DEFAULT 0 NULL, -- Bị xóa mềm
	ngay_xoa timestamp NULL, -- Ngày xóa mềm
	nguoi_xoa varchar(100) NULL, -- Người xóa mềm
	CONSTRAINT dm_nhom_bao_cao_id_key UNIQUE (id),
	CONSTRAINT dm_nhom_bao_cao_ma_nhom_bao_cao_key UNIQUE (ma_nhom_bao_cao),
	CONSTRAINT dm_nhom_bao_cao_nhombaocaoid_key UNIQUE (nhombaocaoid),
	CONSTRAINT dm_nhom_bao_cao_pkey PRIMARY KEY (id),
	CONSTRAINT dm_nhom_bao_cao_ten_nhom_bao_cao_key UNIQUE (ten_nhom_bao_cao)
);

CREATE TABLE dm_nhom_bieu_mau_dong (
	ma varchar(100) NOT NULL, -- mã
	ten varchar(100) NOT NULL, -- tên
	mo_ta text NULL, -- mô tả
	id uuid DEFAULT gen_random_uuid() NOT NULL, -- Key của bảng
	ngay_tao timestamp DEFAULT now() NOT NULL, -- Ngày tạo
	nguoi_tao varchar(100) DEFAULT 'system'::character varying NOT NULL, -- Người tạo
	ngay_cap_nhat timestamp DEFAULT now() NOT NULL, -- Ngày cập nhật
	nguoi_cap_nhat varchar(100) DEFAULT 'system'::character varying NOT NULL, -- Người cập nhật
	bi_xoa int2 DEFAULT 0 NULL, -- Bị xóa mềm
	ngay_xoa timestamp NULL, -- Ngày xóa mềm
	nguoi_xoa varchar(100) NULL, -- Người xóa mềm
	CONSTRAINT dm_nhom_bieu_mau_dong_pkey PRIMARY KEY (id)
);

CREATE TABLE dm_nhom_chuc_danh (
	ma_chuc_danh varchar NOT NULL,
	ten_chuc_danh varchar NULL,
	su_dung bool DEFAULT false NULL,
	id uuid DEFAULT gen_random_uuid() NOT NULL,
	deleted_at timestamp NULL,
	created_at timestamp DEFAULT now() NOT NULL,
	created_by text NOT NULL,
	updated_at timestamp DEFAULT now() NOT NULL,
	updated_by text NOT NULL,
	CONSTRAINT dm_nhom_chuc_danh_ma_chuc_danh_key UNIQUE (ma_chuc_danh),
	CONSTRAINT dm_nhom_chuc_danh_pkey PRIMARY KEY (id)
);

CREATE TABLE dm_nhom_duoc (
	ma varchar(100) NULL,
	ten varchar(250) NULL,
	id uuid DEFAULT gen_random_uuid() NOT NULL, -- Key của bảng
	ngay_tao timestamp DEFAULT now() NOT NULL, -- Ngày tạo
	nguoi_tao varchar(100) DEFAULT 'system'::character varying NOT NULL, -- Người tạo
	ngay_cap_nhat timestamp DEFAULT now() NOT NULL, -- Ngày cập nhật
	nguoi_cap_nhat varchar(100) DEFAULT 'system'::character varying NOT NULL, -- Người cập nhật
	bi_xoa int2 DEFAULT 0 NULL, -- Bị xóa mềm
	ngay_xoa timestamp NULL, -- Ngày xóa mềm
	nguoi_xoa varchar(100) NULL, -- Người xóa mềm
	ma_atc_cap_1 varchar NULL,
	CONSTRAINT dm_nhom_duoc_pkey PRIMARY KEY (id)
);

CREATE TABLE dm_nhom_duoc_atc (
	stt int4 NULL,
	su_dung bool DEFAULT true NULL,
	id uuid DEFAULT gen_random_uuid() NOT NULL, -- Key của bảng
	ngay_tao timestamp DEFAULT now() NOT NULL, -- Ngày tạo
	nguoi_tao varchar(100) DEFAULT 'system'::character varying NOT NULL, -- Người tạo
	ngay_cap_nhat timestamp DEFAULT now() NOT NULL, -- Ngày cập nhật
	nguoi_cap_nhat varchar(100) DEFAULT 'system'::character varying NOT NULL, -- Người cập nhật
	bi_xoa int2 DEFAULT 0 NULL, -- Bị xóa mềm
	ngay_xoa timestamp NULL, -- Ngày xóa mềm
	nguoi_xoa varchar(100) NULL, -- Người xóa mềm
	ma_atc_cap1 varchar NULL,
	ten_nhom_thuoc varchar NULL,
	ten_nhom_atc_cap1 varchar NULL,
	ma_atc_cap_2 varchar DEFAULT '1' NOT NULL,
	CONSTRAINT dm_nhom_duoc_atc_pkey PRIMARY KEY (id)
);

CREATE TABLE dm_nhom_icd10 (
	icd_nhom_id int4 NULL,
	ma varchar(25) NULL,
	ten varchar(500) NULL,
	ten_en varchar(500) NULL,
	chuong_icd10_ma int4 NULL,
	sudung bool NULL,
	id uuid DEFAULT gen_random_uuid() NOT NULL,
	deleted_at timestamp NULL,
	ngay_tao timestamp DEFAULT now() NOT NULL,
	nguoi_tao text NOT NULL,
	ngay_cap_nhat timestamp DEFAULT now() NOT NULL,
	nguoi_cap_nhat text NOT NULL,
	ma_cskcb varchar(100) NULL,
	bi_xoa int2 DEFAULT 0 NOT NULL,
	ngay_xoa timestamp NULL,
	nguoi_xoa varchar(100) NULL,
	chuong_icd10_id uuid NULL,
	CONSTRAINT dm_nhom_icd10_pkey PRIMARY KEY (id)
);

CREATE TABLE dm_nhom_ky_cap (
	ma varchar NOT NULL, -- Mã nhóm ký cấp
	ten varchar NULL, -- Tên nhóm ký cấp
	mo_ta text NULL, -- Mô tả
	id uuid DEFAULT gen_random_uuid() NOT NULL, -- Key của bảng
	ngay_tao timestamp DEFAULT now() NOT NULL, -- Ngày tạo
	nguoi_tao varchar DEFAULT 'system'::character varying NOT NULL, -- Người tạo
	ngay_cap_nhat timestamp DEFAULT now() NOT NULL, -- Ngày cập nhật
	nguoi_cap_nhat varchar DEFAULT 'system'::character varying NOT NULL, -- Người cập nhật
	bi_xoa int2 DEFAULT 0 NULL, -- Bị xóa mềm
	ngay_xoa timestamp NULL, -- Ngày xóa mềm
	nguoi_xoa varchar NULL, -- Người xóa mềm
	is_platform int2 DEFAULT 1 NULL,
	CONSTRAINT dm_nhom_ky_cap_ma_key UNIQUE (ma),
	CONSTRAINT dm_nhom_ky_cap_pkey PRIMARY KEY (id)
);

CREATE TABLE dm_nhom_mau (
	id uuid DEFAULT gen_random_uuid() NOT NULL,
	deleted_at timestamp NULL,
	ngay_tao timestamp DEFAULT now() NOT NULL,
	nguoi_tao text NOT NULL,
	ngay_cap_nhat timestamp DEFAULT now() NOT NULL,
	nguoi_cap_nhat text NOT NULL,
	ma_cskcb varchar(100) NULL,
	bi_xoa int2 DEFAULT 0 NOT NULL,
	ngay_xoa timestamp NULL,
	nguoi_xoa varchar(100) NULL,
	CONSTRAINT dm_nhom_mau_pkey PRIMARY KEY (id)
);

CREATE TABLE dm_nhom_phieu (
	ma_nhom_phieu varchar(25) NOT NULL, -- Mã nhóm phiếu
	ten_nhom_phieu varchar(255) NOT NULL, -- Tên nhóm phiếu
	stt int4 NULL, -- Số thứ tự
	su_dung bool DEFAULT true NULL, -- Sử dụng
	id uuid DEFAULT gen_random_uuid() NOT NULL, -- Key của bảng
	ngay_tao timestamp DEFAULT now() NOT NULL, -- Ngày tạo
	nguoi_tao varchar(100) DEFAULT '''system'''::character varying NOT NULL, -- Người tạo
	ngay_cap_nhat timestamp DEFAULT now() NOT NULL, -- Ngày cập nhật
	nguoi_cap_nhat varchar(100) DEFAULT '''system'''::character varying NOT NULL, -- Người cập nhật
	bi_xoa int2 DEFAULT 0 NULL, -- Bị xóa mềm
	ngay_xoa timestamp NULL, -- Ngày xóa mềm
	nguoi_xoa varchar(100) NULL, -- Người xóa mềm
	CONSTRAINT dm_nhom_phieu_pkey PRIMARY KEY (id)
);

CREATE TABLE dm_nhom_phuong_thuc_ky_so (
	ma varchar NOT NULL, -- Mã nhóm
	id uuid DEFAULT gen_random_uuid() NOT NULL, -- Key của bảng
	ngay_tao timestamp DEFAULT now() NOT NULL, -- Ngày tạo
	nguoi_tao varchar DEFAULT 'system'::character varying NOT NULL, -- Người tạo
	ngay_cap_nhat timestamp DEFAULT now() NOT NULL, -- Ngày cập nhật
	nguoi_cap_nhat varchar DEFAULT 'system'::character varying NOT NULL, -- Người cập nhật
	bi_xoa int2 DEFAULT 0 NULL, -- Bị xóa mềm
	ngay_xoa timestamp NULL, -- Ngày xóa mềm
	nguoi_xoa varchar NULL, -- Người xóa mềm
	ma_phuong_thuc_ky_so varchar NULL,
	stt int4 NULL,
	CONSTRAINT dm_nhom_phuong_thuc_ky_so_pkey PRIMARY KEY (id)
);

CREATE TABLE dm_nhom_vat_tu_y_te (
	ma_nhom varchar NULL,
	ma_nhom_id int4 NULL,
	ten_nhom varchar NULL,
	su_dung bool NULL,
	id uuid DEFAULT gen_random_uuid() NOT NULL, -- Key của bảng
	ngay_tao timestamp DEFAULT now() NOT NULL, -- Ngày tạo
	nguoi_tao varchar(100) DEFAULT 'system'::character varying NOT NULL, -- Người tạo
	ngay_cap_nhat timestamp DEFAULT now() NOT NULL, -- Ngày cập nhật
	nguoi_cap_nhat varchar(100) DEFAULT 'system'::character varying NOT NULL, -- Người cập nhật
	bi_xoa int2 DEFAULT 0 NULL, -- Bị xóa mềm
	ngay_xoa timestamp NULL, -- Ngày xóa mềm
	nguoi_xoa varchar(100) NULL, -- Người xóa mềm
	CONSTRAINT dm_nhom_vat_tu_y_te_pkey PRIMARY KEY (id)
);

CREATE TABLE dm_nhomhdvp (
	ma_nhom_hdvp varchar NOT NULL,
	ten_nhom_hdvp varchar NOT NULL,
	ghi_chu varchar NULL,
	su_dung bool NULL,
	khoanmucid int4 NOT NULL,
	id uuid DEFAULT gen_random_uuid() NOT NULL,
	deleted_at timestamp NULL,
	created_at timestamp DEFAULT now() NOT NULL,
	created_by text NOT NULL,
	updated_at timestamp DEFAULT now() NOT NULL,
	updated_by text NOT NULL,
	CONSTRAINT dm_nhomhdvp_khoanmucid_key UNIQUE (khoanmucid),
	CONSTRAINT dm_nhomhdvp_ma_nhom_hdvp_key UNIQUE (ma_nhom_hdvp),
	CONSTRAINT dm_nhomhdvp_pkey PRIMARY KEY (id)
);

CREATE TABLE dm_nhommau_goidichvu (
	goidichvu_mau_id uuid NULL,
	nhommau_id uuid NULL,
	sudung bool NULL,
	id uuid DEFAULT gen_random_uuid() NOT NULL,
	ngay_tao timestamp DEFAULT now() NOT NULL,
	nguoi_tao varchar(100) DEFAULT '''system'''::character varying NOT NULL,
	ngay_cap_nhat timestamp DEFAULT now() NOT NULL,
	nguoi_cap_nhat varchar(100) DEFAULT '''system'''::character varying NOT NULL,
	bi_xoa int2 DEFAULT 0 NULL,
	ngay_xoa timestamp NULL,
	nguoi_xoa varchar(100) NULL,
	stt int4 NULL,
	CONSTRAINT dm_nhommau_goidichvu_pkey PRIMARY KEY (id)
);

CREATE TABLE dm_phac_do (
	ma_phac_do varchar(25) NOT NULL,
	ten_phac_do varchar(255) NOT NULL,
	id uuid DEFAULT gen_random_uuid() NOT NULL, -- Key của bảng
	ngay_tao timestamp DEFAULT now() NOT NULL, -- Ngày tạo
	nguoi_tao varchar(100) DEFAULT 'system'::character varying NOT NULL, -- Người tạo
	ngay_cap_nhat timestamp DEFAULT now() NOT NULL, -- Ngày cập nhật
	nguoi_cap_nhat varchar(100) DEFAULT 'system'::character varying NOT NULL, -- Người cập nhật
	bi_xoa int2 DEFAULT 0 NULL, -- Bị xóa mềm
	ngay_xoa timestamp NULL, -- Ngày xóa mềm
	nguoi_xoa varchar(100) NULL, -- Người xóa mềm
	CONSTRAINT dm_phac_do_pkey PRIMARY KEY (id)
);

CREATE TABLE dm_pham_vi_quan_ly_tvt (
	ten_pham_vi varchar NULL,
	pham_vi_id int4 NULL,
	su_dung bool DEFAULT true NULL,
	id uuid DEFAULT gen_random_uuid() NOT NULL, -- Key của bảng
	ngay_tao timestamp DEFAULT now() NOT NULL, -- Ngày tạo
	nguoi_tao varchar(100) DEFAULT 'system'::character varying NOT NULL, -- Người tạo
	ngay_cap_nhat timestamp DEFAULT now() NOT NULL, -- Ngày cập nhật
	nguoi_cap_nhat varchar(100) DEFAULT 'system'::character varying NOT NULL, -- Người cập nhật
	bi_xoa int2 DEFAULT 0 NULL, -- Bị xóa mềm
	ngay_xoa timestamp NULL, -- Ngày xóa mềm
	nguoi_xoa varchar(100) NULL, -- Người xóa mềm
	ma varchar NULL,
	CONSTRAINT dm_pham_vi_quan_ly_tvt_ma_key UNIQUE (ma),
	CONSTRAINT dm_pham_vi_quan_ly_tvt_pkey PRIMARY KEY (id)
);

CREATE TABLE dm_phan_he (
	ma varchar NOT NULL, -- Mã phân hệ
	ten varchar NOT NULL, -- Tên phân hệ.
	id uuid DEFAULT gen_random_uuid() NOT NULL, -- Key của bảng
	ngay_xoa timestamp NULL, -- Ngày xóa mềm
	ngay_tao timestamp DEFAULT now() NOT NULL, -- Ngày tạo
	nguoi_tao text NOT NULL, -- Người tạo
	ngay_cap_nhat timestamp DEFAULT now() NOT NULL, -- Ngày cập nhật
	nguoi_cap_nhat text NOT NULL, -- Người cập nhật
	nguoi_xoa varchar(100) NULL, -- Người xóa mềm
	bi_xoa int2 DEFAULT 0 NULL, -- Bị xóa mềm
	CONSTRAINT dm_phan_he_pkey PRIMARY KEY (id)
);

CREATE TABLE dm_phan_khu (
	ma_phan_khu varchar NOT NULL,
	ten_phan_khu varchar NOT NULL,
	loai_phan_khu_id uuid NULL,
	dia_chi varchar NULL,
	ghi_chu varchar NULL,
	su_dung bool DEFAULT true NULL,
	id uuid DEFAULT gen_random_uuid() NOT NULL, -- Key của bảng
	ngay_xoa timestamp NULL, -- Ngày xóa mềm
	ngay_tao timestamp DEFAULT now() NOT NULL, -- Ngày tạo
	nguoi_tao text DEFAULT 'system'::text NOT NULL, -- Người tạo
	ngay_cap_nhat timestamp DEFAULT now() NOT NULL, -- Ngày cập nhật
	nguoi_cap_nhat text DEFAULT 'system'::text NOT NULL, -- Người cập nhật
	nguoi_xoa varchar(100) NULL, -- Người xóa mềm
	bi_xoa int2 DEFAULT 0 NULL, -- Bị xóa mềm
	CONSTRAINT dm_phan_khu_ma_phan_khu_key UNIQUE (ma_phan_khu),
	CONSTRAINT dm_phan_khu_pkey PRIMARY KEY (id),
	CONSTRAINT dm_phan_khu_ten_phan_khu_key UNIQUE (ten_phan_khu)
);

CREATE TABLE dm_phan_khu_cd_phong_th (
	phan_khu_id uuid NOT NULL,
	phong_th_id uuid NOT NULL,
	id uuid DEFAULT gen_random_uuid() NOT NULL,
	deleted_at timestamp NULL,
	created_at timestamp DEFAULT now() NOT NULL,
	created_by text NOT NULL,
	updated_at timestamp DEFAULT now() NOT NULL,
	updated_by text NOT NULL,
	CONSTRAINT dm_phan_khu_cd_phong_th_pkey PRIMARY KEY (id)
);

CREATE TABLE dm_phan_loai_duoc (
	ma_phan_loai_duoc int4 NULL,
	id uuid DEFAULT gen_random_uuid() NOT NULL, -- Key của bảng
	ngay_tao timestamp DEFAULT now() NOT NULL, -- Ngày tạo
	nguoi_tao varchar(100) DEFAULT 'system'::character varying NOT NULL, -- Người tạo
	ngay_cap_nhat timestamp DEFAULT now() NOT NULL, -- Ngày cập nhật
	nguoi_cap_nhat varchar(100) DEFAULT 'system'::character varying NOT NULL, -- Người cập nhật
	bi_xoa int2 DEFAULT 0 NULL, -- Bị xóa mềm
	ngay_xoa timestamp NULL, -- Ngày xóa mềm
	nguoi_xoa varchar(100) NULL, -- Người xóa mềm
	ten_phan_loai_duoc varchar NULL,
	stt int4 NULL,
	su_dung int2 DEFAULT 1 NULL,
	CONSTRAINT dm_phan_loai_duoc_pkey PRIMARY KEY (id)
);

CREATE TABLE dm_phan_loai_kham (
	ma varchar(25) NOT NULL,
	ten varchar(255) NOT NULL,
	id uuid DEFAULT gen_random_uuid() NOT NULL, -- Key của bảng
	ngay_tao timestamp DEFAULT now() NOT NULL, -- Ngày tạo
	nguoi_tao varchar(100) DEFAULT 'system'::character varying NOT NULL, -- Người tạo
	ngay_cap_nhat timestamp DEFAULT now() NOT NULL, -- Ngày cập nhật
	nguoi_cap_nhat varchar(100) DEFAULT 'system'::character varying NOT NULL, -- Người cập nhật
	bi_xoa int2 DEFAULT 0 NULL, -- Bị xóa mềm
	ngay_xoa timestamp NULL, -- Ngày xóa mềm
	nguoi_xoa varchar(100) NULL, -- Người xóa mềm
	CONSTRAINT dm_phan_loai_kham_ma_key UNIQUE (ma),
	CONSTRAINT dm_phan_loai_kham_pkey PRIMARY KEY (id)
);

CREATE TABLE dm_phan_loai_thiet_bi (
	ten_phan_loai varchar(255) NOT NULL,
	ma_phan_loai varchar(255) NOT NULL,
	mo_ta text NULL,
	id uuid DEFAULT gen_random_uuid() NOT NULL, -- Key của bảng
	ngay_tao timestamp DEFAULT now() NOT NULL, -- Ngày tạo
	nguoi_tao varchar(100) DEFAULT '''system'''::character varying NOT NULL, -- Người tạo
	ngay_cap_nhat timestamp DEFAULT now() NOT NULL, -- Ngày cập nhật
	nguoi_cap_nhat varchar(100) DEFAULT '''system'''::character varying NOT NULL, -- Người cập nhật
	bi_xoa int2 DEFAULT 0 NULL, -- Bị xóa mềm
	ngay_xoa timestamp NULL, -- Ngày xóa mềm
	nguoi_xoa varchar(100) NULL, -- Người xóa mềm
	CONSTRAINT dm_phan_loai_thiet_bi_pk_id PRIMARY KEY (id)
);

CREATE TABLE dm_phanquyenkhothuoc (
	khoid int4 NULL,
	thuocid int4 NULL,
	id uuid DEFAULT gen_random_uuid() NOT NULL,
	deleted_at timestamp NULL,
	created_at timestamp DEFAULT now() NOT NULL,
	created_by text NOT NULL,
	updated_at timestamp DEFAULT now() NOT NULL,
	updated_by text NOT NULL,
	CONSTRAINT dm_phanquyenkhothuoc_pkey PRIMARY KEY (id)
);

CREATE TABLE dm_phieu_ky_so (
	id uuid DEFAULT gen_random_uuid() NOT NULL,
	ma_cskcb varchar(10) NULL,
	ma varchar(100) NOT NULL,
	ten varchar(100) NULL,
	ma_report varchar(100) NULL,
	ma_hreport varchar(100) NULL,
	ma_xml varchar(100) NULL,
	ma_kieu_in_phieu varchar(100) NULL,
	ham_lay_du_lieu varchar(100) NULL,
	ma_loai_phieu varchar(100) NULL,
	so_thu_tu_loai_phieu int4 NULL,
	so_thu_tu_hsba int4 NULL,
	bat_buoc_ky int2 DEFAULT 1 NULL,
	la_phieu_di_buong int2 DEFAULT 1 NULL,
	vi_tri varchar(100) NULL,
	mo_ta text NULL,
	ma_loai_ky varchar(100) NULL,
	ngay_tao timestamp DEFAULT now() NOT NULL,
	nguoi_tao varchar NOT NULL,
	ngay_cap_nhat timestamp DEFAULT now() NOT NULL,
	nguoi_cap_nhat varchar NOT NULL,
	bi_xoa int2 DEFAULT 0 NULL,
	ngay_xoa timestamp NULL,
	nguoi_xoa varchar NULL,
	hoat_dong int2 DEFAULT 1 NULL,
	is_platform int2 DEFAULT 0 NULL,
	loai_phieu numeric NULL,
	duoc_phep_cap_lai int2 DEFAULT 1 NULL,
	ky_theo_du_lieu_tao_phieu int2 DEFAULT 1 NULL,
	dong_dau_don_vi int2 DEFAULT 1 NULL,
	ma_phuong_thuc_huy_ky varchar NULL,
	ma_nhom_phieu varchar NULL,
	stt_trong_nhom_phieu int4 NULL,
	ma_cong_tich_hop varchar NULL,
	ma_loai_ho_so varchar NULL,
	ma_loai_file_ky varchar NULL,
	CONSTRAINT dm_phieu_ky_so_pkey PRIMARY KEY (id),
	CONSTRAINT dm_phieu_ky_so_unique UNIQUE (ma)
);

CREATE TABLE dm_phong (
	id uuid DEFAULT gen_random_uuid() NOT NULL, -- Key của bảng
	khoa_id uuid NOT NULL, -- FK: dm_khoa
	ma_phong varchar(25) NOT NULL,
	ten_phong varchar(255) NOT NULL,
	ten_tieng_anh varchar(255) NULL,
	ma_byt varchar(25) NULL,
	loai_phong_ban_id uuid NULL, -- FK: dm_loai_phong_ban
	ten_phong_hd varchar(255) NULL,
	kham_online bool DEFAULT false NULL,
	cong_kham_id uuid NULL, -- FK: dm_dich_vu
	phong_stt int2 NULL,
	phong_yhct bool DEFAULT false NULL,
	phan_khu_id uuid NOT NULL, -- FK: dm_phan_khu
	su_dung bool DEFAULT true NULL,
	bi_xoa int2 DEFAULT 0 NULL, -- Bị xóa mềm
	ngay_xoa timestamp NULL, -- Ngày xóa mềm
	ngay_tao timestamp DEFAULT now() NOT NULL, -- Ngày tạo
	nguoi_tao varchar(100) DEFAULT 'system'::character varying NOT NULL, -- Người tạo
	ngay_cap_nhat timestamp DEFAULT now() NOT NULL, -- Ngày cập nhật
	nguoi_cap_nhat varchar(100) DEFAULT 'system'::character varying NOT NULL, -- Người cập nhật
	nguoi_xoa varchar(100) NULL, -- Người xóa mềm
	phongid bigserial NULL, -- ID Phòng
	ma_cskcb varchar(25) NULL,
	dia_chi text NULL, -- Địa chỉ
	chuyen_khoa_id uuid NULL,
	CONSTRAINT dm_phong_pkey PRIMARY KEY (id)
);

CREATE TABLE dm_phong_ban_thdv (
	id_khoa uuid NULL,
	id_phong uuid NULL, -- Tên phòng
	id_dichvu uuid NULL, -- Tên dịch vụ
	id uuid DEFAULT gen_random_uuid() NOT NULL, -- Key của bảng
	ngay_tao timestamp DEFAULT now() NOT NULL, -- Ngày tạo
	nguoi_tao varchar(100) DEFAULT '''system'''::character varying NOT NULL, -- Người tạo
	ngay_cap_nhat timestamp DEFAULT now() NOT NULL, -- Ngày cập nhật
	nguoi_cap_nhat varchar(100) DEFAULT '''system'''::character varying NOT NULL, -- Người cập nhật
	bi_xoa int2 DEFAULT 0 NULL, -- Bị xóa mềm
	ngay_xoa timestamp NULL, -- Ngày xóa mềm
	nguoi_xoa varchar(100) NULL, -- Người xóa mềm
	CONSTRAINT dm_phong_ban_thdv_pkey PRIMARY KEY (id)
);

CREATE TABLE dm_phong_ban_thdv_map (
	id_khoa uuid NULL, -- Tên Khoa
	id_phong uuid NULL, -- Tên Phòng
	id_dichvu uuid NULL, -- Tên dịch vụ
	ghi_chu varchar(100) NULL, -- Ghi chú
	id uuid DEFAULT gen_random_uuid() NOT NULL, -- Key của bảng
	ngay_tao timestamp DEFAULT now() NOT NULL, -- Ngày tạo
	nguoi_tao varchar(100) DEFAULT 'system'::character varying NOT NULL, -- Người tạo
	ngay_cap_nhat timestamp DEFAULT now() NOT NULL, -- Ngày cập nhật
	nguoi_cap_nhat varchar(100) DEFAULT 'system'::character varying NOT NULL, -- Người cập nhật
	bi_xoa int2 DEFAULT 0 NULL, -- Bị xóa mềm
	ngay_xoa timestamp NULL, -- Ngày xóa mềm
	nguoi_xoa varchar(100) NULL, -- Người xóa mềm
	CONSTRAINT dm_phong_ban_thdv_map_pkey PRIMARY KEY (id)
);

CREATE TABLE dm_phong_dich_vu (
	khoa_id uuid NULL,
	dich_vu_id uuid NOT NULL,
	csyt_dich_vu_id uuid NULL,
	id uuid DEFAULT gen_random_uuid() NOT NULL, -- Key của bảng
	ngay_xoa timestamp NULL, -- Ngày xóa mềm
	ngay_tao timestamp DEFAULT now() NOT NULL, -- Ngày tạo
	nguoi_tao varchar(100) DEFAULT 'system'::character varying NOT NULL, -- Người tạo
	ngay_cap_nhat timestamp DEFAULT now() NOT NULL, -- Ngày cập nhật
	nguoi_cap_nhat varchar(100) DEFAULT 'system'::character varying NOT NULL, -- Người cập nhật
	phong_id uuid NOT NULL,
	nguoi_xoa varchar(100) NULL, -- Người xóa mềm
	bi_xoa int2 DEFAULT 0 NULL, -- Bị xóa mềm
	CONSTRAINT dm_phong_dich_vu_pkey PRIMARY KEY (id)
);

CREATE TABLE dm_phuong_phap_vo_cam (
	ma_pp_vc varchar NOT NULL,
	ten_pp_vc varchar NULL,
	ghi_chu varchar NULL,
	su_dung bool NULL,
	id uuid DEFAULT gen_random_uuid() NOT NULL, -- Key của bảng
	ngay_tao timestamp DEFAULT now() NOT NULL, -- Ngày tạo
	nguoi_tao varchar DEFAULT 'system'::character varying NOT NULL, -- Người tạo
	ngay_cap_nhat timestamp DEFAULT now() NOT NULL, -- Ngày cập nhật
	nguoi_cap_nhat varchar DEFAULT 'system'::character varying NOT NULL, -- Người cập nhật
	bi_xoa int2 DEFAULT 0 NULL, -- Bị xóa mềm
	ngay_xoa timestamp NULL, -- Ngày xóa mềm
	nguoi_xoa varchar NULL, -- Người xóa mềm
	CONSTRAINT dm_phuong_phap_vo_cam_ma_pp_vc_key UNIQUE (ma_pp_vc),
	CONSTRAINT dm_phuong_phap_vo_cam_pkey PRIMARY KEY (id),
	CONSTRAINT dm_phuong_phap_vo_cam_ten_pp_vc_key UNIQUE (ten_pp_vc)
);

CREATE TABLE dm_phuong_thuc_ky_so (
	ma varchar NOT NULL, -- Mã phương thức ký số
	ten varchar NULL, -- Tên phương thức ký số
	mo_ta text NULL, -- Mô tả
	id uuid DEFAULT gen_random_uuid() NOT NULL, -- Key của bảng
	ngay_tao timestamp DEFAULT now() NOT NULL, -- Ngày tạo
	nguoi_tao varchar DEFAULT 'system'::character varying NOT NULL, -- Người tạo
	ngay_cap_nhat timestamp DEFAULT now() NOT NULL, -- Ngày cập nhật
	nguoi_cap_nhat varchar DEFAULT 'system'::character varying NOT NULL, -- Người cập nhật
	bi_xoa int2 DEFAULT 0 NULL, -- Bị xóa mềm
	ngay_xoa timestamp NULL, -- Ngày xóa mềm
	nguoi_xoa varchar NULL, -- Người xóa mềm
	loai varchar(10) NULL, -- Hủy ký = 1¶Ký nhân viên = 2¶Ký bệnh nhân = 3¶Ký chốt = 4
	is_platform int2 DEFAULT 1 NULL,
	CONSTRAINT dm_phuong_thuc_ky_so_ma_key UNIQUE (ma),
	CONSTRAINT dm_phuong_thuc_ky_so_pkey PRIMARY KEY (id)
);

CREATE TABLE dm_pl_loai_nhom_bao_cao (
	ten text NOT NULL, -- Tên loại nhóm báo cáo
	ghi_chu text NULL, -- Ghi chú nhóm báo cáo
	id uuid DEFAULT gen_random_uuid() NOT NULL, -- Key của bảng
	ngay_tao timestamp DEFAULT now() NOT NULL, -- Ngày tạo
	nguoi_tao varchar(100) DEFAULT 'system'::character varying NOT NULL, -- Người tạo
	ngay_cap_nhat timestamp DEFAULT now() NOT NULL, -- Ngày cập nhật
	nguoi_cap_nhat varchar(100) DEFAULT 'system'::character varying NOT NULL, -- Người cập nhật
	bi_xoa int2 DEFAULT 0 NULL, -- Bị xóa mềm
	ngay_xoa timestamp NULL, -- Ngày xóa mềm
	nguoi_xoa varchar(100) NULL, -- Người xóa mềm
	CONSTRAINT dm_pl_loai_nhom_bao_cao_pkey PRIMARY KEY (id)
);

CREATE TABLE dm_pl_loai_nhom_bao_cao_type_map (
	loai_nhom_bao_cao_id uuid DEFAULT gen_random_uuid() NOT NULL,
	type_loai_nhom_bao_cao_id uuid DEFAULT gen_random_uuid() NOT NULL,
	CONSTRAINT dm_pl_loai_nhom_bao_cao_type_map_pkey PRIMARY KEY (loai_nhom_bao_cao_id, type_loai_nhom_bao_cao_id)
);

CREATE TABLE dm_pl_type_loai_nhom_bao_cao (
	ma varchar(50) NOT NULL, -- Mã kiểu nhóm
	ten text NOT NULL, -- Tên kiểu nhóm
	id uuid DEFAULT gen_random_uuid() NOT NULL, -- Key của bảng
	ngay_tao timestamp DEFAULT now() NOT NULL, -- Ngày tạo
	nguoi_tao varchar(100) DEFAULT 'system'::character varying NOT NULL, -- Người tạo
	ngay_cap_nhat timestamp DEFAULT now() NOT NULL, -- Ngày cập nhật
	nguoi_cap_nhat varchar(100) DEFAULT 'system'::character varying NOT NULL, -- Người cập nhật
	bi_xoa int2 DEFAULT 0 NULL, -- Bị xóa mềm
	ngay_xoa timestamp NULL, -- Ngày xóa mềm
	nguoi_xoa varchar(100) NULL, -- Người xóa mềm
	CONSTRAINT dm_pl_type_loai_nhom_bao_cao_pkey PRIMARY KEY (id)
);

CREATE TABLE dm_pp_giam_dau (
	ma varchar NOT NULL,
	ten varchar NULL,
	ghi_chu varchar NULL,
	su_dung bool NULL,
	id uuid DEFAULT gen_random_uuid() NOT NULL, -- Key của bảng
	ngay_tao timestamp DEFAULT now() NOT NULL, -- Ngày tạo
	nguoi_tao varchar DEFAULT 'system'::character varying NOT NULL, -- Người tạo
	ngay_cap_nhat timestamp DEFAULT now() NOT NULL, -- Ngày cập nhật
	nguoi_cap_nhat varchar DEFAULT 'system'::character varying NOT NULL, -- Người cập nhật
	bi_xoa int2 DEFAULT 0 NULL, -- Bị xóa mềm
	ngay_xoa timestamp NULL, -- Ngày xóa mềm
	nguoi_xoa varchar NULL, -- Người xóa mềm
	CONSTRAINT dm_pp_giam_dau_ma_key UNIQUE (ma),
	CONSTRAINT dm_pp_giam_dau_pkey PRIMARY KEY (id)
);

CREATE TABLE dm_pp_vo_cam (
	ma_pp_vo_cam varchar NULL,
	ten_pp_vo_cam varchar NULL,
	ghi_chu varchar NULL,
	ten_khong_dau varchar NULL,
	thu_tu int2 NULL,
	su_dung bool NULL,
	id uuid DEFAULT gen_random_uuid() NOT NULL, -- Key của bảng
	ngay_tao timestamp DEFAULT now() NOT NULL, -- Ngày tạo
	nguoi_tao varchar DEFAULT 'system'::character varying NOT NULL, -- Người tạo
	ngay_cap_nhat timestamp DEFAULT now() NOT NULL, -- Ngày cập nhật
	nguoi_cap_nhat varchar DEFAULT 'system'::character varying NOT NULL, -- Người cập nhật
	bi_xoa int2 DEFAULT 0 NULL, -- Bị xóa mềm
	ngay_xoa timestamp NULL, -- Ngày xóa mềm
	nguoi_xoa varchar NULL, -- Người xóa mềm
	CONSTRAINT dm_pp_vo_cam_ma_pp_vo_cam_key UNIQUE (ma_pp_vo_cam),
	CONSTRAINT dm_pp_vo_cam_pkey PRIMARY KEY (id)
);

CREATE TABLE dm_quy_doi_oxy_duoc_dung (
	ma_tvt varchar NOT NULL,
	don_vi_tinh int4 NOT NULL,
	so_luong int4 NULL,
	don_vi_quy_doi int4 NOT NULL,
	so_luong_tho int4 NULL,
	ten_bhyt varchar NULL,
	ghi_chu varchar NULL,
	su_dung int2 DEFAULT 1 NULL,
	id uuid DEFAULT gen_random_uuid() NOT NULL,
	deleted_at timestamp NULL,
	created_at timestamp DEFAULT now() NOT NULL,
	created_by text NOT NULL,
	updated_at timestamp DEFAULT now() NOT NULL,
	updated_by text NOT NULL,
	CONSTRAINT dm_quy_doi_oxy_duoc_dung_pkey PRIMARY KEY (id)
);

CREATE TABLE dm_reports (
	report_code varchar(500) NULL,
	report_path varchar(1000) NULL,
	id uuid DEFAULT gen_random_uuid() NOT NULL,
	deleted_at timestamp NULL,
	created_at timestamp DEFAULT now() NOT NULL,
	created_by text NOT NULL,
	updated_at timestamp DEFAULT now() NOT NULL,
	updated_by text NOT NULL,
	CONSTRAINT dm_reports_pkey PRIMARY KEY (id),
	CONSTRAINT dm_reports_report_code_key UNIQUE (report_code),
	CONSTRAINT dm_reports_report_path_key UNIQUE (report_path)
);

CREATE TABLE dm_reports_org (
	report_code varchar(500) NULL,
	report_path varchar(1000) NULL,
	org_code varchar(50) NULL,
	id uuid DEFAULT gen_random_uuid() NOT NULL,
	deleted_at timestamp NULL,
	created_at timestamp DEFAULT now() NOT NULL,
	created_by text NOT NULL,
	updated_at timestamp DEFAULT now() NOT NULL,
	updated_by text NOT NULL,
	CONSTRAINT dm_reports_org_pkey PRIMARY KEY (id)
);

CREATE TABLE dm_so_luong_ptv_toi_da (
	loai_pttt varchar(255) NOT NULL,
	so_nguoi_thuc_hien int4 NOT NULL,
	ghi_chu varchar(500) NULL,
	su_dung bool NULL,
	id uuid DEFAULT gen_random_uuid() NOT NULL, -- Key của bảng
	ngay_tao timestamp DEFAULT now() NOT NULL, -- Ngày tạo
	nguoi_tao varchar(100) DEFAULT 'system'::character varying NOT NULL, -- Người tạo
	ngay_cap_nhat timestamp DEFAULT now() NOT NULL, -- Ngày cập nhật
	nguoi_cap_nhat varchar(100) DEFAULT 'system'::character varying NOT NULL, -- Người cập nhật
	bi_xoa int2 DEFAULT 0 NULL, -- Bị xóa mềm
	ngay_xoa timestamp NULL, -- Ngày xóa mềm
	nguoi_xoa varchar(100) NULL, -- Người xóa mềm
	ma_vi_tri varchar NOT NULL,
	CONSTRAINT dm_so_luong_ptv_toi_da_pkey PRIMARY KEY (id)
);

CREATE TABLE dm_so_thu_hoa_don (
	loai_so_id uuid NOT NULL,
	ma_loai_so varchar NOT NULL,
	mau_so varchar NULL,
	ky_hieu varchar NULL,
	ngay_phat_hanh date NULL,
	so_bat_dau int4 NULL,
	so_ket_thuc int4 NULL,
	so_hien_tai int4 NULL,
	ghi_chu varchar NULL,
	su_dung int4 NULL, -- 0: Không sử dụng; 1:Sử dụng
	id uuid DEFAULT gen_random_uuid() NOT NULL, -- Key của bảng
	ngay_tao timestamp DEFAULT now() NOT NULL, -- Ngày tạo
	nguoi_tao varchar DEFAULT 'system'::character varying NOT NULL, -- Người tạo
	ngay_cap_nhat timestamp DEFAULT now() NOT NULL, -- Ngày cập nhật
	nguoi_cap_nhat varchar DEFAULT 'system'::character varying NOT NULL, -- Người cập nhật
	bi_xoa int2 DEFAULT 0 NULL, -- Bị xóa mềm
	ngay_xoa timestamp NULL, -- Ngày xóa mềm
	nguoi_xoa varchar NULL, -- Người xóa mềm
	ma_cskcb varchar(25) NULL,
	serial varchar(25) NULL,
	so_luong_phat_hanh int4 NULL, -- Số lượng phát hành
	ngay_het_han date NULL, -- Ngày hết hạn
	trang_thai varchar(25) NULL, -- NHAP: Nháp, DA_PHAT_HANH: đã phát hành, DA_KHOA: đã khóa, HUY: hủy
	don_vi_su_dung varchar(25) NULL, -- Đơn vị sử dụng
	CONSTRAINT dm_so_thu_hoa_don_pkey PRIMARY KEY (id)
);

CREATE TABLE dm_tai_khoan_tich_hop (
	loai_tich_hop varchar NOT NULL, -- Loại tài khoản tích hơp
	ma_cskcb varchar NOT NULL, -- Mã cơ sở khám chữa bệnh
	username varchar NOT NULL, -- Tài khoản dùng để authen
	"token" varchar NULL, -- token authen lấy được
	id_token varchar NULL, -- id_token
	"domain" varchar NOT NULL, -- Đường dẫn lấy authen
	endpoint varchar NULL, -- Đường dẫn lấy authen
	hoat_dong int2 DEFAULT 1 NOT NULL, -- hoat_dong
	id uuid DEFAULT gen_random_uuid() NOT NULL, -- Key của bảng
	ngay_tao timestamp DEFAULT now() NOT NULL, -- Ngày tạo
	nguoi_tao varchar(100) DEFAULT 'system'::character varying NOT NULL, -- Người tạo
	ngay_cap_nhat timestamp DEFAULT now() NOT NULL, -- Ngày cập nhật
	nguoi_cap_nhat varchar(100) DEFAULT 'system'::character varying NOT NULL, -- Người cập nhật
	bi_xoa int2 DEFAULT 0 NULL, -- Bị xóa mềm
	ngay_xoa timestamp NULL, -- Ngày xóa mềm
	nguoi_xoa varchar(100) NULL, -- Người xóa mềm
	"password" varchar(255) NOT NULL, -- password
	ten varchar(255) NULL, -- Tên loại tích hợp
	CONSTRAINT dm_tai_khoan_tich_hop_pkey PRIMARY KEY (id)
);

CREATE TABLE dm_tai_khoan_tich_hop_endpoint (
	tai_khoan_tich_hop_id uuid NOT NULL, -- Tài khoản tích hợp ID
	loai_tich_hop varchar(50) NOT NULL, -- Loại tích hợp
	ma_endpoint varchar(100) NOT NULL, -- Mã endpoint
	"method" varchar(20) DEFAULT 'POST'::character varying NOT NULL, -- method
	endpoint varchar NOT NULL, -- endpoint
	config jsonb NULL, -- config
	hoat_dong int2 DEFAULT 1 NOT NULL, -- hoat_dong
	id uuid DEFAULT gen_random_uuid() NOT NULL, -- Key của bảng
	ngay_tao timestamp DEFAULT now() NOT NULL, -- Ngày tạo
	nguoi_tao varchar(100) DEFAULT 'system'::character varying NOT NULL, -- Người tạo
	ngay_cap_nhat timestamp DEFAULT now() NOT NULL, -- Ngày cập nhật
	nguoi_cap_nhat varchar(100) DEFAULT 'system'::character varying NOT NULL, -- Người cập nhật
	bi_xoa int2 DEFAULT 0 NULL, -- Bị xóa mềm
	ngay_xoa timestamp NULL, -- Ngày xóa mềm
	nguoi_xoa varchar(100) NULL, -- Người xóa mềm
	CONSTRAINT dm_tai_khoan_tich_hop_endpoint_pkey PRIMARY KEY (id)
);

CREATE TABLE dm_tai_khoan_tich_hop_nguoi_dung (
	tai_khoan_tich_hop_id uuid NOT NULL, -- Tài khoản tích hợp ID
	loai_tich_hop varchar(50) NOT NULL, -- Loại tài khoản tích hợp
	ma_cskcb varchar(50) NOT NULL, -- ma_cskcb
	pl_user_id uuid NOT NULL, -- pl_user_id
	ho_ten_cb varchar(255) NOT NULL, -- ho_ten_cb
	cccd_cb varchar(30) NOT NULL, -- cccd_cb
	config jsonb NOT NULL, -- config
	active bool DEFAULT true NOT NULL, -- active
	id uuid DEFAULT gen_random_uuid() NOT NULL, -- Key của bảng
	ngay_tao timestamp DEFAULT now() NOT NULL, -- Ngày tạo
	nguoi_tao varchar(100) DEFAULT 'system'::character varying NOT NULL, -- Người tạo
	ngay_cap_nhat timestamp DEFAULT now() NOT NULL, -- Ngày cập nhật
	nguoi_cap_nhat varchar(100) DEFAULT 'system'::character varying NOT NULL, -- Người cập nhật
	bi_xoa int2 DEFAULT 0 NULL, -- Bị xóa mềm
	ngay_xoa timestamp NULL, -- Ngày xóa mềm
	nguoi_xoa varchar(100) NULL, -- Người xóa mềm
	username text NULL, -- Tài khoản
	"password" text NULL, -- password
	"token" text NULL, -- token đối với các bên sử dụng token cho từng account
	CONSTRAINT dm_tai_khoan_tich_hop_nguoi_dung_pkey PRIMARY KEY (id)
);

CREATE TABLE dm_test01 (
	ma varchar NOT NULL,
	ten varchar NULL,
	id uuid DEFAULT gen_random_uuid() NOT NULL, -- Key của bảng
	ngay_tao timestamp DEFAULT now() NOT NULL, -- Ngày tạo
	nguoi_tao varchar DEFAULT 'system'::character varying NOT NULL, -- Người tạo
	ngay_cap_nhat timestamp DEFAULT now() NOT NULL, -- Ngày cập nhật
	nguoi_cap_nhat varchar DEFAULT 'system'::character varying NOT NULL, -- Người cập nhật
	bi_xoa int2 DEFAULT 0 NULL, -- Bị xóa mềm
	ngay_xoa timestamp NULL, -- Ngày xóa mềm
	nguoi_xoa varchar NULL, -- Người xóa mềm
	CONSTRAINT dm_test01_ma_key UNIQUE (ma),
	CONSTRAINT dm_test01_pkey PRIMARY KEY (id)
);

CREATE TABLE dm_thoi_gian_lam_viec (
	ma varchar NOT NULL, -- Mã thời gian làm việc
	ten varchar NULL, -- Tên thời gian làm việc
	gio_bat_dau_buoi_sang time NULL, -- Giờ bắt đầu làm việc buổi sáng
	gio_ket_thuc_buoi_sang time NULL, -- Giờ kết thúc làm việc buổi sáng
	gio_bat_dau_buoi_chieu time NULL, -- Giờ bắt đầu làm việc buổi chiều
	gio_ket_thuc_buoi_chieu time NULL, -- Giờ kết thúc làm việc buổi chiều
	tu_ngay date NULL, -- Từ ngày
	den_ngay date NULL, -- Đến ngày
	ghi_chu varchar NULL, -- Ghi chú
	su_dung int4 DEFAULT 1 NOT NULL, -- 0: Không sử dụng; 1: Sử dụng
	ngoai_gio varchar(25) DEFAULT 'TRONG_GIO'::character varying NULL, -- TRONG_GIO: Trong giờ; NGOAI_GIO: Ngoài giờ
	id uuid DEFAULT gen_random_uuid() NOT NULL, -- Key của bảng
	ngay_tao timestamp DEFAULT now() NOT NULL, -- Ngày tạo
	nguoi_tao varchar DEFAULT 'system'::character varying NOT NULL, -- Người tạo
	ngay_cap_nhat timestamp DEFAULT now() NOT NULL, -- Ngày cập nhật
	nguoi_cap_nhat varchar DEFAULT 'system'::character varying NOT NULL, -- Người cập nhật
	bi_xoa int2 DEFAULT 0 NULL, -- Bị xóa mềm
	ngay_xoa timestamp NULL, -- Ngày xóa mềm
	nguoi_xoa varchar NULL, -- Người xóa mềm
	ma_cskcb varchar(25) NULL,
	CONSTRAINT dm_thoi_gian_lam_viec_ma_key UNIQUE (ma),
	CONSTRAINT dm_thoi_gian_lam_viec_pkey PRIMARY KEY (id)
);

CREATE TABLE dm_thuc_pham (
	ma varchar NOT NULL,
	ten varchar NOT NULL,
	nhom_thuc_pham_id uuid NOT NULL,
	don_vi_tinh_id uuid NOT NULL,
	don_vi_cung_cap_id uuid NOT NULL,
	nguon_goc varchar NULL,
	ghi_chu varchar NULL,
	su_dung bool NULL,
	id uuid DEFAULT gen_random_uuid() NOT NULL, -- Key của bảng
	ngay_tao timestamp DEFAULT now() NOT NULL, -- Ngày tạo
	nguoi_tao varchar DEFAULT 'system'::character varying NOT NULL, -- Người tạo
	ngay_cap_nhat timestamp DEFAULT now() NOT NULL, -- Ngày cập nhật
	nguoi_cap_nhat varchar DEFAULT 'system'::character varying NOT NULL, -- Người cập nhật
	bi_xoa int2 DEFAULT 0 NULL, -- Bị xóa mềm
	ngay_xoa timestamp NULL, -- Ngày xóa mềm
	nguoi_xoa varchar NULL, -- Người xóa mềm
	CONSTRAINT dm_thuc_pham_pkey PRIMARY KEY (id)
);

CREATE TABLE dm_thuocsd_icd_ct (
	thuocsd_icd_id uuid NULL,
	bhyt_tt bool DEFAULT true NULL,
	tyle_bhyt_tra uuid NULL,
	loaigia_id uuid NULL,
	hienthi_cb varchar NULL,
	ghichu varchar NULL,
	sudung bool DEFAULT true NULL,
	id uuid DEFAULT gen_random_uuid() NOT NULL, -- Key của bảng
	ngay_tao timestamp DEFAULT now() NOT NULL, -- Ngày tạo
	nguoi_tao varchar(100) DEFAULT 'system'::character varying NOT NULL, -- Người tạo
	ngay_cap_nhat timestamp DEFAULT now() NOT NULL, -- Ngày cập nhật
	nguoi_cap_nhat varchar(100) DEFAULT 'system'::character varying NOT NULL, -- Người cập nhật
	bi_xoa int2 DEFAULT 0 NULL, -- Bị xóa mềm
	ngay_xoa timestamp NULL, -- Ngày xóa mềm
	nguoi_xoa varchar(100) NULL, -- Người xóa mềm
	CONSTRAINT dm_thuocsd_icd_ct_pkey PRIMARY KEY (id)
);

CREATE TABLE dm_thuocsd_icd_ct_temp (
	id uuid DEFAULT gen_random_uuid() NOT NULL,
	uid uuid NULL,
	request_id text NULL,
	lan_import int8 NULL,
	loai int2 NULL,
	thuocsd_icd_id uuid NULL,
	tyle_bhyt_tra uuid NULL,
	loaigia_id uuid NULL,
	bhyt_tt bool DEFAULT true NULL,
	hienthi_cb varchar NULL,
	ghi_chu varchar NULL,
	su_dung bool DEFAULT true NULL,
	loi varchar NULL,
	trang_thai int2 DEFAULT 1 NULL,
	ngay_tao timestamp DEFAULT now() NULL,
	CONSTRAINT dm_thuocsd_icd_ct_temp_pkey PRIMARY KEY (id)
);

CREATE TABLE dm_thuocsd_tuoi (
	thuocvt_id int4 NULL,
	tuoi_tu int4 NULL,
	dvt_tu_id uuid NULL,
	tuoi_den int4 NULL,
	dvt_den_id uuid NULL,
	tinhtoan varchar NULL,
	bhyt_tt bool NULL,
	canhbao varchar NULL,
	ghichu varchar NULL,
	sudung bool DEFAULT true NULL,
	id uuid DEFAULT gen_random_uuid() NOT NULL, -- Key của bảng
	ngay_tao timestamp DEFAULT now() NOT NULL, -- Ngày tạo
	nguoi_tao varchar(100) DEFAULT 'system'::character varying NOT NULL, -- Người tạo
	ngay_cap_nhat timestamp DEFAULT now() NOT NULL, -- Ngày cập nhật
	nguoi_cap_nhat varchar(100) DEFAULT 'system'::character varying NOT NULL, -- Người cập nhật
	bi_xoa int2 DEFAULT 0 NULL, -- Bị xóa mềm
	ngay_xoa timestamp NULL, -- Ngày xóa mềm
	nguoi_xoa varchar(100) NULL, -- Người xóa mềm
	CONSTRAINT dm_thuocsd_tuoi_pkey PRIMARY KEY (id)
);

CREATE TABLE dm_thuocsd_tuoi_temp (
	id uuid DEFAULT gen_random_uuid() NOT NULL,
	request_id varchar(100) NOT NULL,
	uid uuid NOT NULL,
	lan_import int8 DEFAULT 1 NOT NULL,
	loai int2 DEFAULT 1 NOT NULL,
	thuoc_vat_tu_id int8 NULL,
	tuoi_tu int4 NULL,
	dvt_tu_id uuid NULL,
	tuoi_den int4 NULL,
	dvt_den_id uuid NULL,
	tinhtoan varchar(50) NULL,
	bhyt_tt bool NULL,
	canhbao varchar(500) NULL,
	ghichu varchar(1000) NULL,
	su_dung bool DEFAULT true NULL,
	trang_thai int2 DEFAULT 1 NOT NULL,
	loi varchar(2000) NULL,
	ngay_tao timestamp DEFAULT now() NOT NULL,
	CONSTRAINT dm_thuocsd_tuoi_temp_pkey PRIMARY KEY (id)
);

CREATE TABLE dm_tien_luong (
	ma varchar(255) NULL,
	ten varchar(255) NULL,
	su_dung bool NULL,
	id uuid DEFAULT gen_random_uuid() NOT NULL, -- Key của bảng
	ngay_tao timestamp DEFAULT now() NOT NULL, -- Ngày tạo
	nguoi_tao varchar(100) DEFAULT '''system'''::character varying NOT NULL, -- Người tạo
	ngay_cap_nhat timestamp DEFAULT now() NOT NULL, -- Ngày cập nhật
	nguoi_cap_nhat varchar(100) DEFAULT '''system'''::character varying NOT NULL, -- Người cập nhật
	bi_xoa int2 DEFAULT 0 NULL, -- Bị xóa mềm
	ngay_xoa timestamp NULL, -- Ngày xóa mềm
	nguoi_xoa varchar(100) NULL, -- Người xóa mềm
	CONSTRAINT dm_tien_luong_pk_id PRIMARY KEY (id)
);

CREATE TABLE dm_tinh_trang_hon_nhan (
	ma varchar NOT NULL, -- Mã tình trạng hôn nhân
	ten varchar NOT NULL, -- Tên tình trạng hôn nhân
	id uuid DEFAULT gen_random_uuid() NOT NULL, -- Key của bảng
	ngay_tao timestamp DEFAULT now() NOT NULL, -- Ngày tạo
	nguoi_tao varchar DEFAULT 'system'::character varying NOT NULL, -- Người tạo
	ngay_cap_nhat timestamp DEFAULT now() NOT NULL, -- Ngày cập nhật
	nguoi_cap_nhat varchar DEFAULT 'system'::character varying NOT NULL, -- Người cập nhật
	bi_xoa int2 DEFAULT 0 NULL, -- Bị xóa mềm
	ngay_xoa timestamp NULL, -- Ngày xóa mềm
	nguoi_xoa varchar NULL, -- Người xóa mềm
	CONSTRAINT dm_tinh_trang_hon_nhan_ma_key UNIQUE (ma),
	CONSTRAINT dm_tinh_trang_hon_nhan_pkey PRIMARY KEY (id)
);

CREATE TABLE dm_tinh_trang_thuoc_vt (
	ma varchar NULL,
	ten varchar NULL,
	su_dung bool DEFAULT true NULL,
	id uuid DEFAULT gen_random_uuid() NOT NULL, -- Key của bảng
	ngay_tao timestamp DEFAULT now() NOT NULL, -- Ngày tạo
	nguoi_tao varchar(100) DEFAULT '''system'''::character varying NOT NULL, -- Người tạo
	ngay_cap_nhat timestamp DEFAULT now() NOT NULL, -- Ngày cập nhật
	nguoi_cap_nhat varchar(100) DEFAULT '''system'''::character varying NOT NULL, -- Người cập nhật
	bi_xoa int2 DEFAULT 0 NULL, -- Bị xóa mềm
	ngay_xoa timestamp NULL, -- Ngày xóa mềm
	nguoi_xoa varchar(100) NULL, -- Người xóa mềm
	CONSTRAINT dm_tinh_trang_thuoc_vt_pk_id PRIMARY KEY (id)
);

CREATE TABLE dm_tinh_trang_tv (
	ma varchar NOT NULL,
	ten varchar NULL,
	su_dung bool NULL,
	id uuid DEFAULT tenant_bvcahn.uuid_generate_v7() NOT NULL, -- Key của bảng
	ngay_tao timestamp DEFAULT now() NOT NULL, -- Ngày tạo
	nguoi_tao varchar(100) DEFAULT '''system'''::character varying NOT NULL, -- Người tạo
	ngay_cap_nhat timestamp DEFAULT now() NOT NULL, -- Ngày cập nhật
	nguoi_cap_nhat varchar(100) DEFAULT '''system'''::character varying NOT NULL, -- Người cập nhật
	bi_xoa int2 DEFAULT 0 NULL, -- Bị xóa mềm
	ngay_xoa timestamp NULL, -- Ngày xóa mềm
	nguoi_xoa varchar(100) NULL, -- Người xóa mềm
	CONSTRAINT dm_tinh_trang_tv_pk_id PRIMARY KEY (id)
);

CREATE TABLE dm_to_chuc (
	ma varchar NOT NULL, -- Mã tổ chức CSYT
	ten varchar NOT NULL, -- Tên tổ chức CSYT
	id uuid DEFAULT gen_random_uuid() NOT NULL, -- Key của bảng
	ngay_tao timestamp DEFAULT now() NOT NULL, -- Ngày tạo
	nguoi_tao varchar DEFAULT 'system'::character varying NOT NULL, -- Người tạo
	ngay_cap_nhat timestamp DEFAULT now() NOT NULL, -- Ngày cập nhật
	nguoi_cap_nhat varchar DEFAULT 'system'::character varying NOT NULL, -- Người cập nhật
	bi_xoa int2 DEFAULT 0 NULL, -- Bị xóa mềm
	ngay_xoa timestamp NULL, -- Ngày xóa mềm
	nguoi_xoa varchar NULL, -- Người xóa mềm
	CONSTRAINT dm_to_chuc_ma_key UNIQUE (ma),
	CONSTRAINT dm_to_chuc_pkey PRIMARY KEY (id)
);

CREATE TABLE dm_to_chuc_csyt (
	id uuid DEFAULT gen_random_uuid() NOT NULL,
	ma_to_chuc_csyt varchar NOT NULL,
	ten_to_chuc_csyt varchar NOT NULL,
	su_dung bool DEFAULT true NOT NULL,
	bi_xoa int2 DEFAULT 0 NOT NULL,
	ngay_tao timestamp DEFAULT now() NOT NULL,
	nguoi_tao varchar DEFAULT 'system'::character varying NOT NULL,
	ngay_cap_nhat timestamp DEFAULT now() NOT NULL,
	nguoi_cap_nhat varchar DEFAULT 'system'::character varying NOT NULL,
	ngay_xoa timestamp NULL,
	nguoi_xoa varchar NULL,
	CONSTRAINT dm_to_chuc_csyt_ma_to_chuc_csyt_key UNIQUE (ma_to_chuc_csyt),
	CONSTRAINT dm_to_chuc_csyt_pkey PRIMARY KEY (id)
);

CREATE TABLE dm_tran_tvt_theo_goi (
	thuocvattuid int4 NOT NULL,
	ma_vat_tu varchar NULL,
	ten_vat_tu varchar NULL,
	don_vi_tinh varchar NULL,
	thong_tin_tvt_thanh_phan varchar NOT NULL,
	don_gia_tran_chia_le numeric NULL,
	don_gia_tran_theo_bo numeric NULL,
	don_gia_bhyt numeric NULL,
	don_gia_nhanh_dan numeric NULL,
	don_gia_dich_vu numeric NULL,
	don_gia_bhyt_dv numeric NULL,
	ghi_chu varchar NULL,
	su_dung int2 DEFAULT 1 NULL,
	id uuid DEFAULT gen_random_uuid() NOT NULL,
	deleted_at timestamp NULL,
	created_at timestamp DEFAULT now() NOT NULL,
	created_by text NOT NULL,
	updated_at timestamp DEFAULT now() NOT NULL,
	updated_by text NOT NULL,
	CONSTRAINT dm_tran_tvt_theo_goi_pkey PRIMARY KEY (id)
);

CREATE TABLE dm_trang_thai (
	ten_nghiep_vu varchar NULL,
	loai_trang_thai varchar NULL,
	ten_trang_thai text NULL,
	id uuid DEFAULT gen_random_uuid() NOT NULL,
	deleted_at timestamp NULL,
	created_at timestamp DEFAULT now() NOT NULL,
	created_by text NOT NULL,
	updated_at timestamp DEFAULT now() NOT NULL,
	updated_by text NOT NULL,
	ten_trang_thai_en varchar NULL,
	gia_tri varchar NULL,
	CONSTRAINT dm_trang_thai_id_key UNIQUE (id),
	CONSTRAINT dm_trang_thai_pkey PRIMARY KEY (id)
);

CREATE TABLE dm_trang_thai_phieu (
	ma varchar NOT NULL,
	ten varchar NOT NULL,
	trangthai int2 NOT NULL,
	su_dung bool NULL,
	id uuid DEFAULT gen_random_uuid() NOT NULL,
	deleted_at timestamp NULL,
	created_at timestamp DEFAULT now() NOT NULL,
	created_by text NOT NULL,
	updated_at timestamp DEFAULT now() NOT NULL,
	updated_by text NOT NULL,
	CONSTRAINT dm_trang_thai_phieu_ma_key UNIQUE (ma),
	CONSTRAINT dm_trang_thai_phieu_pkey PRIMARY KEY (id)
);

CREATE TABLE dm_trang_thai_quyet_dinh_thau (
	ma varchar NOT NULL,
	ten varchar NOT NULL,
	su_dung int2 DEFAULT 1 NOT NULL,
	id uuid DEFAULT gen_random_uuid() NOT NULL,
	deleted_at timestamp NULL,
	created_at timestamp DEFAULT now() NOT NULL,
	created_by text NOT NULL,
	updated_at timestamp DEFAULT now() NOT NULL,
	updated_by text NOT NULL,
	trangthaiquyetdinhthauid int4 NULL,
	CONSTRAINT dm_trang_thai_quyet_dinh_thau_id_key UNIQUE (id),
	CONSTRAINT dm_trang_thai_quyet_dinh_thau_id_key1 UNIQUE (id),
	CONSTRAINT dm_trang_thai_quyet_dinh_thau_ma_key UNIQUE (ma),
	CONSTRAINT dm_trang_thai_quyet_dinh_thau_ma_key1 UNIQUE (ma),
	CONSTRAINT dm_trang_thai_quyet_dinh_thau_pkey PRIMARY KEY (id)
);

CREATE TABLE dm_trang_thai_su_dung (
	ma_trang_thai_su_dung varchar(100) NULL, -- Mã trạng thái sử dụng
	ten_trang_thai_su_dung varchar(255) NULL, -- Tên trạng thái sử dụng
	ten_goi_khac varchar(255) NULL, -- Tên gọi khác
	ghi_chu varchar(255) NULL, -- Ghi chú
	su_dung bool NULL, -- Trạng thái sử dụng
	id uuid DEFAULT gen_random_uuid() NOT NULL, -- Key của bảng
	ngay_tao timestamp DEFAULT now() NOT NULL, -- Ngày tạo
	nguoi_tao varchar(100) DEFAULT 'system'::character varying NOT NULL, -- Người tạo
	ngay_cap_nhat timestamp DEFAULT now() NOT NULL, -- Ngày cập nhật
	nguoi_cap_nhat varchar(100) DEFAULT 'system'::character varying NOT NULL, -- Người cập nhật
	bi_xoa int2 DEFAULT 0 NULL, -- Bị xóa mềm
	ngay_xoa timestamp NULL, -- Ngày xóa mềm
	nguoi_xoa varchar(100) NULL, -- Người xóa mềm
	CONSTRAINT dm_trang_thai_su_dung_pkey PRIMARY KEY (id)
);

CREATE TABLE dm_trinh_do_chuyen_mon (
	ma int8 NULL,
	id uuid DEFAULT gen_random_uuid() NOT NULL,
	ngay_tao timestamp DEFAULT now() NOT NULL,
	nguoi_tao varchar DEFAULT 'system'::character varying NOT NULL,
	ngay_cap_nhat timestamp DEFAULT now() NOT NULL,
	nguoi_cap_nhat varchar DEFAULT 'system'::character varying NOT NULL,
	bi_xoa int2 DEFAULT 0 NULL,
	ngay_xoa timestamp NULL,
	nguoi_xoa varchar NULL,
	ten varchar NULL,
	nhom_trinh_do_chuyen_mon uuid NULL,
	CONSTRAINT dm_trinh_do_chuyen_mon_id_key UNIQUE (id),
	CONSTRAINT dm_trinh_do_chuyen_mon_ma_key UNIQUE (ma),
	CONSTRAINT dm_trinh_do_chuyen_mon_pkey PRIMARY KEY (id)
);

CREATE TABLE dm_tu_vong (
	ma_nguyen_nhan varchar NULL, -- Mã nguyên nhân
	ten_nguyen_nhan varchar NULL, -- Tên nguyên nhân
	ghi_chu varchar NULL, -- Ghi chú
	phau_thuat bool NULL,
	su_dung bool NULL,
	id uuid DEFAULT gen_random_uuid() NOT NULL, -- Key của bảng
	ngay_tao timestamp DEFAULT now() NOT NULL, -- Ngày tạo
	nguoi_tao varchar DEFAULT 'system'::character varying NOT NULL, -- Người tạo
	ngay_cap_nhat timestamp DEFAULT now() NOT NULL, -- Ngày cập nhật
	nguoi_cap_nhat varchar DEFAULT 'system'::character varying NOT NULL, -- Người cập nhật
	bi_xoa int2 DEFAULT 0 NULL, -- Bị xóa mềm
	ngay_xoa timestamp NULL, -- Ngày xóa mềm
	nguoi_xoa varchar NULL, -- Người xóa mềm
	CONSTRAINT dm_tu_vong_pkey PRIMARY KEY (id)
);

CREATE TABLE dm_tuoi_thuoc (
	ma_thuoc varchar NOT NULL,
	tuoi_tu int4 NOT NULL,
	don_vi_tuoi_tu varchar NOT NULL,
	tuoi_den int4 NOT NULL,
	don_vi_tuoi_den varchar NOT NULL,
	phep_so_sanh varchar NOT NULL,
	bhyt_thanh_toan int2 NOT NULL,
	canh_bao varchar NULL,
	ghi_chu varchar NULL,
	su_dung int2 DEFAULT 1 NULL,
	id uuid DEFAULT gen_random_uuid() NOT NULL,
	deleted_at timestamp NULL,
	created_at timestamp DEFAULT now() NOT NULL,
	created_by text NOT NULL,
	updated_at timestamp DEFAULT now() NOT NULL,
	updated_by text NOT NULL,
	CONSTRAINT dm_tuoi_thuoc_pkey PRIMARY KEY (id)
);

CREATE TABLE dm_tuyen_benh_vien (
	ma varchar NULL,
	ten varchar NULL,
	ghi_chu varchar NULL,
	ten_khong_dau varchar NULL,
	stt int4 NULL,
	id uuid DEFAULT gen_random_uuid() NOT NULL,
	deleted_at timestamp NULL,
	created_at timestamp DEFAULT now() NOT NULL,
	created_by text NOT NULL,
	updated_at timestamp DEFAULT now() NOT NULL,
	updated_by text NOT NULL,
	CONSTRAINT dm_tuyen_benh_vien_pkey PRIMARY KEY (id)
);

CREATE TABLE dm_tuyen_chuyen (
	ma_tuyen_chuyen varchar NOT NULL, -- Mã tuyến chuyển
	ten_tuyen_chuyen varchar NOT NULL, -- Tên tuyến chuyển
	su_dung bool DEFAULT true NULL, -- Sử dụng
	id uuid DEFAULT gen_random_uuid() NOT NULL, -- Key của bảng
	ngay_xoa timestamp NULL, -- Ngày xóa mềm
	ngay_tao timestamp DEFAULT now() NOT NULL, -- Ngày tạo
	nguoi_tao text NOT NULL, -- Người tạo
	ngay_cap_nhat timestamp DEFAULT now() NOT NULL, -- Ngày cập nhật
	nguoi_cap_nhat text NOT NULL, -- Người cập nhật
	nguoi_xoa varchar(100) NULL, -- Người xóa mềm
	bi_xoa int2 DEFAULT 0 NULL, -- Bị xóa mềm
	CONSTRAINT dm_tuyen_chuyen_ma_tuyen_chuyen_key UNIQUE (ma_tuyen_chuyen),
	CONSTRAINT dm_tuyen_chuyen_pkey PRIMARY KEY (id)
);

CREATE TABLE dm_tuyenchuyen (
	matuyenchuyen varchar NULL,
	tentuyenchuyen varchar NULL,
	sudung bool NULL,
	id uuid DEFAULT gen_random_uuid() NOT NULL,
	deleted_at timestamp NULL,
	created_at timestamp DEFAULT now() NOT NULL,
	created_by text NOT NULL,
	updated_at timestamp DEFAULT now() NOT NULL,
	updated_by text NOT NULL,
	CONSTRAINT dm_tuyenchuyen_pkey PRIMARY KEY (id)
);

CREATE TABLE dm_tvt_tuong_duong (
	ma_hoat_chat varchar NOT NULL,
	ten_hoat_chat varchar NOT NULL,
	ham_luong varchar NOT NULL,
	duong_dung varchar NOT NULL,
	thuocvattuid varchar NOT NULL,
	tenthuocvattu varchar NOT NULL,
	don_vi varchar NOT NULL,
	thu_tu_xuat_uu_tien int4 NULL,
	su_dung int2 DEFAULT 1 NULL,
	id uuid DEFAULT gen_random_uuid() NOT NULL,
	deleted_at timestamp NULL,
	created_at timestamp DEFAULT now() NOT NULL,
	created_by text NOT NULL,
	updated_at timestamp DEFAULT now() NOT NULL,
	updated_by text NOT NULL,
	CONSTRAINT dm_tvt_tuong_duong_pkey PRIMARY KEY (id)
);

CREATE TABLE dm_vai_tro_hoi_dong_kiem_nhap (
	ten_vai_tro varchar NULL,
	ma_vai_tro varchar NULL,
	su_dung bool NULL,
	id uuid DEFAULT gen_random_uuid() NOT NULL,
	ngay_tao timestamp DEFAULT now() NOT NULL,
	nguoi_tao varchar(100) DEFAULT '''system'''::character varying NOT NULL,
	ngay_cap_nhat timestamp DEFAULT now() NOT NULL,
	nguoi_cap_nhat varchar(100) DEFAULT '''system'''::character varying NOT NULL,
	bi_xoa int2 DEFAULT 0 NULL,
	ngay_xoa timestamp NULL,
	nguoi_xoa varchar(100) NULL,
	CONSTRAINT dm_vai_tro_hoi_dong_kiem_nhap_pkey PRIMARY KEY (id)
);

CREATE TABLE dm_vai_tro_kip_mo (
	ma_vai_tro_kip_mo varchar NOT NULL,
	ten_vai_tro_kip_mo varchar NULL,
	su_dung bool NULL,
	id uuid DEFAULT gen_random_uuid() NOT NULL, -- Key của bảng
	ngay_tao timestamp DEFAULT now() NOT NULL, -- Ngày tạo
	nguoi_tao varchar DEFAULT 'system'::character varying NOT NULL, -- Người tạo
	ngay_cap_nhat timestamp DEFAULT now() NOT NULL, -- Ngày cập nhật
	nguoi_cap_nhat varchar DEFAULT 'system'::character varying NOT NULL, -- Người cập nhật
	bi_xoa int2 DEFAULT 0 NULL, -- Bị xóa mềm
	ngay_xoa timestamp NULL, -- Ngày xóa mềm
	nguoi_xoa varchar NULL, -- Người xóa mềm
	loai_vai_tro uuid NULL,
	CONSTRAINT dm_vai_tro_kip_mo_ma_vai_tro_kip_mo_key UNIQUE (ma_vai_tro_kip_mo),
	CONSTRAINT dm_vai_tro_kip_mo_pkey PRIMARY KEY (id)
);

CREATE TABLE dm_van_phong_pham (
	ma_van_phong_pham varchar(25) NOT NULL, -- Mã văn phòng phẩm
	ten_van_phong_pham varchar(255) NOT NULL, -- Tên văn phòng phẩm
	ten_khong_dau varchar(255) NULL, -- Tên không dấu
	stt int4 NULL, -- Số thứ tự
	su_dung bool DEFAULT true NULL, -- Sử dụng
	id uuid DEFAULT gen_random_uuid() NOT NULL, -- Key của bảng
	ngay_tao timestamp DEFAULT now() NOT NULL, -- Ngày tạo
	nguoi_tao varchar(100) DEFAULT 'system'::character varying NOT NULL, -- Người tạo
	ngay_cap_nhat timestamp DEFAULT now() NOT NULL, -- Ngày cập nhật
	nguoi_cap_nhat varchar(100) DEFAULT 'system'::character varying NOT NULL, -- Người cập nhật
	bi_xoa int2 DEFAULT 0 NULL, -- Bị xóa mềm
	ngay_xoa timestamp NULL, -- Ngày xóa mềm
	nguoi_xoa varchar(100) NULL, -- Người xóa mềm
	don_vi_tinh varchar NULL, -- Đơn vị tính
	loai_van_phong_pham varchar NULL, -- Loại văn phòng phẩm
	CONSTRAINT dm_van_phong_pham_pkey PRIMARY KEY (id)
);

CREATE TABLE dm_vi_tri_thuc_hien_pttt (
	ma_vi_tri varchar(25) NULL,
	ten_vi_tri varchar(255) NULL,
	su_dung bool NULL,
	thu_tu int2 NULL,
	id uuid DEFAULT gen_random_uuid() NOT NULL, -- Key của bảng
	ngay_tao timestamp DEFAULT now() NOT NULL, -- Ngày tạo
	nguoi_tao varchar(100) DEFAULT 'system'::character varying NOT NULL, -- Người tạo
	ngay_cap_nhat timestamp DEFAULT now() NOT NULL, -- Ngày cập nhật
	nguoi_cap_nhat varchar(100) DEFAULT 'system'::character varying NOT NULL, -- Người cập nhật
	bi_xoa int2 DEFAULT 0 NULL, -- Bị xóa mềm
	ngay_xoa timestamp NULL, -- Ngày xóa mềm
	nguoi_xoa varchar(100) NULL, -- Người xóa mềm
	CONSTRAINT dm_vi_tri_thuc_hien_pttt_pkey PRIMARY KEY (id)
);

CREATE TABLE dm_vitri_ky_phieu (
	id uuid DEFAULT gen_random_uuid() NOT NULL,
	dm_cap_ky_phieu_id uuid NOT NULL,
	ma_vi_tri varchar(50) NOT NULL, -- Mã định danh vị trí ký (VD: DUOC_SI, THU_KHO)
	ten_vi_tri varchar(255) NOT NULL, -- Tên hiển thị vị trí ký
	chuc_danh_ky varchar(100) NULL, -- Role Code chức danh — fallback khi nguoiky_id null
	thu_tu_hien_thi int4 DEFAULT 1 NULL,
	loai_chu_ky varchar(50) NULL, -- Loại chữ ký: KyNhay, KyChinh, KyApprove
	toa_do_x_mac_dinh numeric(10, 2) NULL, -- Tọa độ X mặc định cho chữ ký trên PDF
	toa_do_y_mac_dinh numeric(10, 2) NULL, -- Tọa độ Y mặc định cho chữ ký trên PDF
	trang_so_mac_dinh int4 DEFAULT 1 NULL,
	bat_buoc int2 DEFAULT 1 NULL,
	hoat_dong int2 DEFAULT 1 NULL,
	ngay_tao timestamptz DEFAULT now() NULL,
	nguoi_tao_id uuid NULL,
	CONSTRAINT dm_vitri_ky_phieu_dm_cap_ky_phieu_id_ma_vi_tri_key UNIQUE (dm_cap_ky_phieu_id, ma_vi_tri),
	CONSTRAINT dm_vitri_ky_phieu_pkey PRIMARY KEY (id)
);

CREATE TABLE dm_xa (
	ma varchar(25) NOT NULL, -- Mã xã
	ten varchar(255) NOT NULL, -- Tên xã
	id uuid DEFAULT gen_random_uuid() NOT NULL, -- Key của bảng
	ngay_tao timestamp DEFAULT now() NOT NULL, -- Ngày tạo
	nguoi_tao varchar(100) DEFAULT 'system'::character varying NOT NULL, -- Người tạo
	ngay_cap_nhat timestamp DEFAULT now() NOT NULL, -- Ngày cập nhật
	nguoi_cap_nhat varchar(100) DEFAULT 'system'::character varying NOT NULL, -- Người cập nhật
	bi_xoa int2 DEFAULT 0 NULL, -- Bị xóa mềm
	ngay_xoa timestamp NULL, -- Ngày xóa mềm
	nguoi_xoa varchar(100) NULL, -- Người xóa mềm
	ma_tinh varchar NOT NULL, -- Mã tỉnh của xã đó.
	su_dung bool NOT NULL, -- Sử dụng
	CONSTRAINT dm_xa_pkey PRIMARY KEY (id)
);

CREATE TABLE dm_xu_tri (
	id uuid DEFAULT gen_random_uuid() NOT NULL, -- Key của bảng
	ma_xu_tri varchar(50) NULL, -- Mã xử trí
	ten_xu_tri varchar(200) NULL, -- Tên xử trí
	ten_khong_dau varchar(200) NULL, -- Tên xử trí không dấu
	ghi_chu text NULL, -- Ghi chú mô tả chi tiết xử trí
	loai_dieu_tri_id uuid NULL, -- FK dm_loai_dieu_tri
	stt int4 NULL, -- Thứ tự hiển thị
	su_dung bool NULL, -- Trạng thái sử dụng (true: đang dùng, false: ngưng dùng)
	ngay_tao timestamp DEFAULT now() NOT NULL, -- Ngày tạo
	nguoi_tao varchar(100) DEFAULT 'system'::character varying NOT NULL, -- Người tạo
	ngay_cap_nhat timestamp DEFAULT now() NOT NULL, -- Ngày cập nhật
	nguoi_cap_nhat varchar(100) DEFAULT 'system'::character varying NOT NULL, -- Người cập nhật
	ma_cskcb varchar(50) NULL, -- Mã cơ sở khám chữa bệnh
	nguoi_xoa varchar(100) NULL, -- Người xóa mềm
	bi_xoa int2 DEFAULT 0 NULL, -- Bị xóa mềm
	ngay_xoa timestamp NULL, -- Ngày xóa mềm
	CONSTRAINT dm_xu_tri_pkey PRIMARY KEY (id)
);

CREATE TABLE dm_xu_tri_ket_qua_dieu_tri (
	id uuid DEFAULT gen_random_uuid() NOT NULL, -- Key của bảng
	xu_tri_id uuid NULL, -- FK dm_xu_tri
	ket_qua_dieu_tri_id uuid NULL, -- Kết quả điều trị
	ngay_tao timestamp DEFAULT now() NOT NULL, -- Ngày tạo
	nguoi_tao varchar(100) DEFAULT 'system'::character varying NOT NULL, -- Người tạo
	ngay_cap_nhat timestamp DEFAULT now() NOT NULL, -- Ngày cập nhật
	nguoi_cap_nhat varchar(100) DEFAULT 'system'::character varying NOT NULL, -- Người cập nhật
	ma_cskcb varchar(50) NULL, -- Mã cskcb
	nguoi_xoa varchar(100) NULL, -- Người xóa mềm
	bi_xoa int2 DEFAULT 0 NULL, -- Bị xóa mềm
	ngay_xoa timestamp NULL, -- Ngày xóa mềm
	thoigian_luutru int4 NULL,
	CONSTRAINT dm_xu_tri_ket_qua_dieu_tri_pk_id PRIMARY KEY (id)
);

CREATE TABLE dmc_atc (
	ma_atc varchar NOT NULL,
	ten_atc varchar NOT NULL,
	ten_atc_en varchar NULL,
	ghi_chu text NULL,
	su_dung bool NULL,
	id uuid DEFAULT gen_random_uuid() NOT NULL,
	deleted_at timestamp NULL,
	created_at timestamp DEFAULT now() NOT NULL,
	created_by text NOT NULL,
	updated_at timestamp DEFAULT now() NOT NULL,
	updated_by text NOT NULL,
	CONSTRAINT dmc_atc_ma_atc_key UNIQUE (ma_atc),
	CONSTRAINT dmc_atc_pkey PRIMARY KEY (id)
);

CREATE TABLE dmc_benh_vien (
	ma varchar(25) NOT NULL, -- Mã cơ sở y tế
	ten varchar(255) NOT NULL, -- Tên cơ sở y tế
	tinh_id uuid NULL, -- FK: dmc_dia_phuong
	xa_id uuid NULL, -- FK: dmc_dia_phuong
	dia_chi text NULL, -- Địa chỉ chi tiết
	tuyen_id uuid NULL, -- FK: dmc_tuyen_benh_vien
	hang_id uuid NULL, -- FK: dmc_hang_benh_vien
	cap_chuyen_mon_kt int2 NULL, -- Cấp chuyên môn kỹ thuật
	ghi_chu text NULL, -- Ghi chú
	su_dung bool DEFAULT true NULL, -- Sử dụng
	id uuid DEFAULT gen_random_uuid() NOT NULL, -- Key của bảng
	ngay_tao timestamp DEFAULT now() NOT NULL, -- Ngày tạo
	nguoi_tao varchar(100) DEFAULT 'system'::character varying NOT NULL, -- Người tạo
	ngay_cap_nhat timestamp DEFAULT now() NOT NULL, -- Ngày cập nhật
	nguoi_cap_nhat varchar(100) DEFAULT 'system'::character varying NOT NULL, -- Người cập nhật
	bi_xoa int2 DEFAULT 0 NULL, -- Bị xóa mềm
	ngay_xoa timestamp NULL, -- Ngày xóa mềm
	nguoi_xoa varchar(100) NULL, -- Người xóa mềm
	tuyen varchar NULL, -- Tuyến bệnh viện
	hang varchar NULL,
	cap varchar NULL,
	stt int4 NULL, -- Số thứ tự
	ma_tinh varchar(2) NULL, -- Mã tỉnh
	ma_xa varchar(5) NULL, -- Mã xã
	CONSTRAINT dmc_benh_vien_ma_key UNIQUE (ma),
	CONSTRAINT dmc_benh_vien_pkey PRIMARY KEY (id)
);

CREATE TABLE dmc_benhnhan (
	benhnhanid numeric(10) NOT NULL,
	mahoadulieu numeric(10) NULL,
	mabenhnhan varchar(20) NULL,
	ngayhethanluutruhsba timestamp NULL,
	namhethanluutruhsba numeric(10) NULL,
	tenbenhnhan varchar(1200) NULL,
	ngaysinh timestamp NULL,
	namsinh numeric(10) NULL,
	gioitinhid numeric(1) NULL,
	nghenghiepid numeric(30) NULL,
	dantocid numeric(3) NULL,
	quocgiaid numeric(4) NULL,
	sonha varchar(1000) NULL,
	diabanid numeric(15) NULL,
	diaphuongid numeric(15) DEFAULT 0 NULL,
	noilamviec varchar(200) NULL,
	nguoithan varchar(120) NULL,
	tennguoithan varchar(400) NULL,
	dienthoainguoithan varchar(20) NULL,
	diachinguoithan varchar(400) NULL,
	cmnd varchar(60) NULL,
	noicapcmnd varchar(140) NULL,
	ngaycapcmnd timestamp NULL,
	ngaydangky timestamp NULL,
	sttdangky numeric(10) NULL,
	ngaycapnhat timestamp NULL,
	anhbenhnhan varchar(4000) NULL,
	kichthuocanh numeric(10) NULL,
	ghichu varchar(200) NULL,
	"version" timestamp NULL,
	sync_flag numeric(1) NULL,
	update_flag numeric(1) NULL,
	csytid int8 NULL,
	benhnhanchaid numeric(10) NULL,
	sdtbenhnhan varchar(20) NULL,
	tencongtybn varchar(2000) NULL,
	diachi_ctybn varchar(2000) NULL,
	masothue_ctybn varchar(2000) NULL,
	hssk_madd varchar(50) NULL,
	hssk_pass varchar(50) NULL,
	dotdieutringtid numeric(10) DEFAULT 0 NULL,
	ten_nganhang varchar(400) NULL,
	sotaikhoan varchar(80) NULL,
	email_ctybn varchar(200) NULL,
	anhqdhuu varchar(1000) NULL,
	xutri_cuoi numeric(3) DEFAULT 0 NULL,
	cap_tk_bn numeric(1) NULL,
	tennguoithan_bo varchar(400) NULL,
	tennguoithan_me varchar(400) NULL,
	anhthenganh varchar(4000) NULL,
	ngayqdhuu timestamp NULL,
	ngayvaodonvi timestamp NULL,
	nghetruocday varchar(2000) NULL,
	noiohientai varchar(2000) NULL,
	ho_ten_cha varchar(400) NULL,
	ho_ten_me varchar(400) NULL,
	tiensubanthan varchar(2000) NULL,
	chitietbn varchar(4000) NULL,
	benhnhanimport numeric(1) NULL,
	congtyid numeric(10) NULL,
	email_bn varchar(200) NULL,
	chucdanh_bn varchar(200) NULL,
	maluutrukhoa varchar(100) NULL,
	cmnd_nguoithan varchar(30) NULL,
	noicapcmnd_nguoithan varchar(200) NULL,
	ngaycapcmnd_nguoithan timestamp NULL,
	gio_sinh varchar(10) NULL,
	dienthoainguoithan_bo varchar(20) NULL,
	dienthoainguoithan_me varchar(20) NULL,
	nghenghiep_boid numeric(3) NULL,
	nghenghiep_meid numeric(3) NULL,
	hocvan_bo varchar(1000) NULL,
	hocvan_me varchar(1000) NULL,
	tk_lienket varchar(200) NULL,
	trinhdo_vanhoa varchar(1000) NULL,
	ngayravien timestamp DEFAULT now() NULL,
	ma_bhxh_cha varchar(1000) NULL,
	ma_bhxh_me varchar(1000) NULL,
	ngaysinh_bo timestamp NULL,
	ngaysinh_me timestamp NULL,
	madoituong_tiemchung varchar(50) NULL,
	nhommau varchar(5) NULL,
	rh varchar(2) NULL,
	ma_dv_qhnsach varchar(7) NULL,
	sohochieu varchar(20) NULL,
	ngaycap_hochieu timestamp NULL,
	ngayhethan_hochieu timestamp NULL,
	hddt_namsinh numeric(1) NULL,
	CONSTRAINT dmc_benhnhan_pkey PRIMARY KEY (benhnhanid)
);

CREATE TABLE dmc_cau_hinh_ky_cap (
	ma_report varchar NULL, -- Mã report
	vi_tri varchar(10) NULL, -- Vị trí
	mo_ta text NULL, -- Mô tả
	is_ky_nhom int2 NULL, -- Là ký nhóm
	ma_nhom varchar NULL, -- Mã nhóm
	id uuid DEFAULT gen_random_uuid() NOT NULL, -- Key của bảng
	ngay_tao timestamp DEFAULT now() NOT NULL, -- Ngày tạo
	nguoi_tao varchar DEFAULT 'system'::character varying NOT NULL, -- Người tạo
	ngay_cap_nhat timestamp DEFAULT now() NOT NULL, -- Ngày cập nhật
	nguoi_cap_nhat varchar DEFAULT 'system'::character varying NOT NULL, -- Người cập nhật
	bi_xoa int2 DEFAULT 0 NULL, -- Bị xóa mềm
	ngay_xoa timestamp NULL, -- Ngày xóa mềm
	nguoi_xoa varchar NULL, -- Người xóa mềm
	ma_loai_ky varchar(100) NULL, -- Mã loại ký số
	phieu_ky_so_id uuid NOT NULL, -- FK: dmc_phieu_ky_so
	cap_ky int4 NULL, -- Cấp ký
	CONSTRAINT dmc_cau_hinh_ky_cap_pkey PRIMARY KEY (id)
);

CREATE TABLE dmc_cau_hinh_ky_so (
	ma_report varchar NOT NULL, -- Mã report
	ma_phuong_thuc_huy_ky varchar NULL, -- Mã phương thức hủy ký
	ma_phuong_thuc_ky_nhan_vien varchar NULL, -- Mã phương thức ký nhân viên
	ma_phuong_thuc_ky_benh_nhan varchar NULL, -- Mã phương thức ký bệnh nhân
	ma_phuong_thuc_ky_chot varchar NULL, -- Mã phương thức ký chốt
	dong_dau_don_vi int2 NULL, -- Đóng dấu đơn vị
	id uuid DEFAULT gen_random_uuid() NOT NULL, -- Key của bảng
	ngay_tao timestamp DEFAULT now() NOT NULL, -- Ngày tạo
	nguoi_tao varchar DEFAULT 'system'::character varying NOT NULL, -- Người tạo
	ngay_cap_nhat timestamp DEFAULT now() NOT NULL, -- Ngày cập nhật
	nguoi_cap_nhat varchar DEFAULT 'system'::character varying NOT NULL, -- Người cập nhật
	bi_xoa int2 DEFAULT 0 NULL, -- Bị xóa mềm
	ngay_xoa timestamp NULL, -- Ngày xóa mềm
	nguoi_xoa varchar NULL, -- Người xóa mềm
	phieu_ky_so_id uuid NOT NULL, -- FK: dmc_phieu_ky_so
	CONSTRAINT dmc_cau_hinh_ky_so_ma_report_key UNIQUE (ma_report),
	CONSTRAINT dmc_cau_hinh_ky_so_pkey PRIMARY KEY (id)
);

CREATE TABLE dmc_cham_cong (
	ma_cham_cong varchar NOT NULL, -- Mã chấm công
	ten_cham_cong varchar NOT NULL, -- Tên chấm công
	ten_goi_khac varchar NULL, -- Tên gọi khác
	loai_cham_cong int2 NOT NULL, -- Loại chấm công
	thong_tin_huong_bhxh int2 NOT NULL, -- Thông tin hưởng BHXH
	thong_tin_huong_luong int2 NOT NULL, -- Thông tin hưởng lương
	pham_vi_su_dung int2 NOT NULL, -- Phạm vi sử dụng
	ghi_chu text NULL, -- Ghi chú
	ten_khong_dau varchar NULL, -- Tên không dấu
	su_dung bool DEFAULT true NULL, -- Sử dụng
	id uuid DEFAULT gen_random_uuid() NOT NULL, -- Key của bảng
	ngay_tao timestamp DEFAULT now() NOT NULL, -- Ngày tạo
	nguoi_tao varchar DEFAULT 'system'::character varying NOT NULL, -- Người tạo
	ngay_cap_nhat timestamp DEFAULT now() NOT NULL, -- Ngày cập nhật
	nguoi_cap_nhat varchar DEFAULT 'system'::character varying NOT NULL, -- Người cập nhật
	bi_xoa int2 DEFAULT 0 NULL, -- Bị xóa mềm
	ngay_xoa timestamp NULL, -- Ngày xóa mềm
	nguoi_xoa varchar NULL, -- Người xóa mềm
	CONSTRAINT dmc_cham_cong_ma_cham_cong_key UNIQUE (ma_cham_cong),
	CONSTRAINT dmc_cham_cong_pkey PRIMARY KEY (id)
);

CREATE TABLE dmc_chi_so_con_xet_nghiem (
	ma_byt varchar(100) NOT NULL, -- Mã bộ y tế (Đồng nhất với cột ma_byt trong bảng dm_dv_kt)
	ma_chi_so varchar(25) NOT NULL, -- Mã chỉ số
	ten_chi_so varchar(255) NOT NULL, -- Tên chỉ số
	don_vi_tinh varchar(25) NULL, -- Đơn vị tính
	tt_sap_xep_phieu_in varchar(25) NULL, -- Thứ tự sắp xếp trên phiếu in
	tt_sap_xep_thuc_hien varchar(25) NULL, -- Thứ tự sắp xếp khi thực hiện
	thanh_phan_loginc varchar(25) NULL, -- Thành phần LOINC
	thuoc_tinh_loinc varchar(25) NULL, -- Thuộc tính LOINC
	thoi_gian_loinc varchar(25) NULL, -- Thời gian LOINC
	phuong_phap_loinc varchar(25) NULL, -- Phương pháp LOINC
	su_dung bool NULL, -- Sử dụng
	id uuid DEFAULT gen_random_uuid() NOT NULL, -- Key của bảng
	ngay_tao timestamp DEFAULT now() NOT NULL, -- Ngày tạo
	nguoi_tao varchar(100) DEFAULT 'system'::character varying NOT NULL, -- Người tạo
	ngay_cap_nhat timestamp DEFAULT now() NOT NULL, -- Ngày cập nhật
	nguoi_cap_nhat varchar(100) DEFAULT 'system'::character varying NOT NULL, -- Người cập nhật
	bi_xoa int2 DEFAULT 0 NULL, -- Bị xóa mềm
	ngay_xoa timestamp NULL, -- Ngày xóa mềm
	nguoi_xoa varchar(100) NULL, -- Người xóa mềm
	ma_dich_vu varchar(25) NULL, -- Hiển thị thông tin mã dịch vụ,
	ma_cskcb varchar(100) NULL,
	CONSTRAINT dmc_chi_so_con_xet_nghiem_pk_id PRIMARY KEY (id)
);

CREATE TABLE dmc_chuc_danh (
	id uuid DEFAULT gen_random_uuid() NOT NULL, -- Key của bảng
	ma_chuc_danh varchar NOT NULL, -- Mã chức danh
	ten_chuc_danh varchar NOT NULL, -- Tên chức danh
	ten_goi_khac varchar NULL, -- Tên gọi khác
	nhom_dieu_tri_id uuid NULL, -- FK dmc_nhom_dieu_tri
	ghi_chu text NULL, -- Ghi chú
	ten_khong_dau varchar NULL, -- Tên không dấu
	su_dung bool DEFAULT true NULL, -- Sử dụng
	bi_xoa int2 DEFAULT 0 NULL, -- Bị xóa mềm
	ngay_tao timestamp DEFAULT now() NOT NULL, -- Ngày tạo
	nguoi_tao varchar(100) DEFAULT 'system'::character varying NOT NULL, -- Người tạo
	ngay_cap_nhat timestamp DEFAULT now() NOT NULL, -- Ngày cập nhật
	nguoi_cap_nhat varchar(100) DEFAULT 'system'::character varying NOT NULL, -- Người cập nhật
	ngay_xoa timestamp NULL, -- Ngày xóa mềm
	nguoi_xoa varchar(100) NULL, -- Người xóa mềm
	CONSTRAINT dmc_chuc_danh_ma_chuc_danh_key UNIQUE (ma_chuc_danh),
	CONSTRAINT dmc_chuc_danh_pkey PRIMARY KEY (id)
);

CREATE TABLE dmc_chuc_vu (
	id uuid DEFAULT gen_random_uuid() NOT NULL, -- Key của bảng
	ma_chuc_vu varchar NOT NULL, -- Mã chức vụ
	ten_chuc_vu varchar NOT NULL, -- Tên chức vụ
	ten_goi_khac varchar NULL, -- Tên gọi khác
	ghi_chu text NULL, -- Ghi chú
	ten_khong_dau varchar NULL, -- Tên không dấu
	su_dung bool DEFAULT true NULL, -- Sử dụng
	bi_xoa int2 DEFAULT 0 NULL, -- Bị xóa mềm
	ngay_tao timestamp DEFAULT now() NOT NULL, -- Ngày tạo
	nguoi_tao varchar(100) DEFAULT 'system'::character varying NOT NULL, -- Người tạo
	ngay_cap_nhat timestamp DEFAULT now() NOT NULL, -- Ngày cập nhật
	nguoi_cap_nhat varchar(100) DEFAULT 'system'::character varying NOT NULL, -- Người cập nhật
	ngay_xoa timestamp NULL, -- Ngày xóa mềm
	nguoi_xoa varchar(100) NULL, -- Người xóa mềm
	CONSTRAINT dmc_chuc_vu_ma_chuc_vu_key UNIQUE (ma_chuc_vu),
	CONSTRAINT dmc_chuc_vu_pkey PRIMARY KEY (id)
);

CREATE TABLE dmc_dan_toc (
	id uuid DEFAULT gen_random_uuid() NOT NULL, -- Key của bảng
	ma_dan_toc varchar NOT NULL,
	ten_dan_toc varchar NOT NULL,
	ten_goi_khac varchar NULL,
	ghi_chu varchar NULL,
	ten_khong_dau varchar NULL,
	su_dung bool DEFAULT true NOT NULL,
	bi_xoa int2 DEFAULT 0 NOT NULL, -- Bị xóa mềm
	nguoi_tao varchar(100) DEFAULT 'system'::character varying NOT NULL, -- Người tạo
	ngay_tao timestamp DEFAULT CURRENT_TIMESTAMP NULL, -- Ngày tạo
	nguoi_cap_nhat varchar(100) NULL, -- Người cập nhật
	ngay_cap_nhat timestamp DEFAULT CURRENT_TIMESTAMP NULL, -- Ngày cập nhật
	nguoi_xoa varchar(100) NULL, -- Người xóa mềm
	ngay_xoa timestamp NULL, -- Ngày xóa mềm
	CONSTRAINT dmc_dan_toc_ma_dan_toc_key UNIQUE (ma_dan_toc),
	CONSTRAINT dmc_dan_toc_pkey PRIMARY KEY (id)
);

CREATE TABLE dmc_danh_hieu_khen_thuong (
	ma varchar(20) NOT NULL,
	ten varchar(255) NOT NULL,
	id uuid DEFAULT gen_random_uuid() NOT NULL,
	ngay_tao timestamp DEFAULT now() NOT NULL,
	nguoi_tao varchar(100) DEFAULT 'system'::character varying NOT NULL,
	ngay_cap_nhat timestamp DEFAULT now() NOT NULL,
	nguoi_cap_nhat varchar(100) DEFAULT 'system'::character varying NOT NULL,
	bi_xoa int2 DEFAULT 0 NULL,
	ngay_xoa timestamp NULL,
	nguoi_xoa varchar(100) NULL,
	CONSTRAINT dmc_danh_hieu_khen_thuong_id PRIMARY KEY (id),
	CONSTRAINT dmc_danh_hieu_khen_thuong_ma UNIQUE (ma)
);

CREATE TABLE dmc_dia_diem (
	ma_dia_diem varchar NOT NULL,
	ten_dia_diem varchar NOT NULL,
	ghi_chu varchar NULL,
	su_dung bool DEFAULT true NOT NULL,
	id uuid DEFAULT gen_random_uuid() NOT NULL, -- Key của bảng
	ngay_tao timestamp DEFAULT now() NOT NULL, -- Ngày tạo
	nguoi_tao varchar DEFAULT 'system'::character varying NOT NULL, -- Người tạo
	ngay_cap_nhat timestamp DEFAULT now() NOT NULL, -- Ngày cập nhật
	nguoi_cap_nhat varchar DEFAULT 'system'::character varying NOT NULL, -- Người cập nhật
	bi_xoa int2 DEFAULT 0 NULL, -- Bị xóa mềm
	ngay_xoa timestamp NULL, -- Ngày xóa mềm
	nguoi_xoa varchar NULL, -- Người xóa mềm
	CONSTRAINT dmc_dia_diem_ma_dia_diem_key UNIQUE (ma_dia_diem),
	CONSTRAINT dmc_dia_diem_pkey PRIMARY KEY (id)
);

CREATE TABLE dmc_dia_phuong (
	ma_dia_phuong varchar(25) NULL,
	ten_dia_phuong varchar(255) NULL,
	id uuid DEFAULT gen_random_uuid() NOT NULL, -- Key của bảng
	ngay_xoa timestamp NULL, -- Ngày xóa mềm
	ngay_tao timestamp DEFAULT now() NOT NULL, -- Ngày tạo
	nguoi_tao varchar(100) DEFAULT 'system'::character varying NOT NULL, -- Người tạo
	ngay_cap_nhat timestamp DEFAULT now() NOT NULL, -- Ngày cập nhật
	nguoi_cap_nhat varchar(100) DEFAULT 'system'::character varying NOT NULL, -- Người cập nhật
	quoc_gia_id uuid NULL, -- FK bảng dmc_quocgia
	cap_id int4 NULL, -- Cấp (1=Tỉnh, 3=Xã)
	ten_day_du varchar(255) NULL, -- Tên đầy đủ
	ten_viet_tat varchar(255) NULL, -- Tên viết tắt của địa phương
	stt int2 NULL,
	su_dung bool DEFAULT true NULL,
	ma_dia_phuong_cha varchar(25) NULL, -- FK dmc_dia_phuong
	nguoi_xoa varchar(100) NULL, -- Người xóa mềm
	bi_xoa int2 DEFAULT 0 NULL, -- Bị xóa mềm
	CONSTRAINT dmc_dia_phuong_ma_dia_phuong_key UNIQUE (ma_dia_phuong),
	CONSTRAINT dmc_dia_phuong_pkey PRIMARY KEY (id)
);

CREATE TABLE dmc_doi_tuong_bhyt (
	id uuid DEFAULT gen_random_uuid() NOT NULL,
	ma varchar(25) NOT NULL,
	ten varchar(255) NOT NULL,
	quyen_loi_id uuid NULL,
	bhyt_van_chuyen int2 NULL,
	ghi_chu varchar(500) NULL,
	su_dung int2 DEFAULT 1 NULL,
	ngay_tao timestamp DEFAULT now() NOT NULL,
	nguoi_tao varchar(100) NOT NULL,
	ngay_cap_nhat timestamp DEFAULT now() NOT NULL,
	nguoi_cap_nhat varchar(100) NOT NULL,
	bi_xoa int2 DEFAULT 0 NOT NULL,
	ngay_xoa timestamp NULL,
	nguoi_xoa varchar(100) NULL,
	CONSTRAINT dmc_doi_tuong_bhyt_pkey PRIMARY KEY (id)
);

CREATE TABLE dmc_doi_tuong_kcb (
	ma varchar(25) NOT NULL,
	ten varchar(500) NOT NULL,
	su_dung bool DEFAULT true NULL,
	ma_cha varchar(25) NULL,
	hieu_luc_tu_ngay date NULL,
	hieu_luc_den_ngay date NULL,
	dien_giai text NULL,
	trich_dan text NULL,
	id uuid DEFAULT gen_random_uuid() NOT NULL, -- Key của bảng
	ngay_xoa timestamp NULL, -- Ngày xóa mềm
	ngay_tao timestamp DEFAULT now() NOT NULL, -- Ngày tạo
	nguoi_tao varchar(100) DEFAULT 'system'::character varying NOT NULL, -- Người tạo
	ngay_cap_nhat timestamp DEFAULT now() NOT NULL, -- Ngày cập nhật
	nguoi_cap_nhat varchar(100) DEFAULT 'system'::character varying NOT NULL, -- Người cập nhật
	nguoi_xoa varchar(100) NULL, -- Người xóa mềm
	bi_xoa int2 DEFAULT 0 NULL, -- Bị xóa mềm
	CONSTRAINT dmc_doi_tuong_kcb_ma_key UNIQUE (ma),
	CONSTRAINT dmc_doi_tuong_kcb_pkey PRIMARY KEY (id)
);

CREATE TABLE dmc_doi_tuong_kham_ksk (
	ma varchar(25) NOT NULL,
	ten varchar(255) NOT NULL,
	id uuid DEFAULT gen_random_uuid() NOT NULL, -- Key của bảng
	ngay_tao timestamp DEFAULT now() NOT NULL, -- Ngày tạo
	nguoi_tao varchar(100) DEFAULT 'system'::character varying NOT NULL, -- Người tạo
	ngay_cap_nhat timestamp DEFAULT now() NOT NULL, -- Ngày cập nhật
	nguoi_cap_nhat varchar(100) DEFAULT 'system'::character varying NOT NULL, -- Người cập nhật
	bi_xoa int2 DEFAULT 0 NULL, -- Bị xóa mềm
	ngay_xoa timestamp NULL, -- Ngày xóa mềm
	nguoi_xoa varchar(100) NULL, -- Người xóa mềm
	CONSTRAINT dmc_doi_tuong_kham_ksk_pkey PRIMARY KEY (id)
);

CREATE TABLE dmc_don_vi_dat_may (
	ma varchar(25) NOT NULL, -- Mã đơn vị đặt máy
	ten varchar(255) NOT NULL, -- Tên đơn vị đặt máy
	ten_goi_khac varchar(255) NULL, -- Tên gọi khác
	su_dung bool NULL, -- Trạng thái sử dụng
	id uuid DEFAULT gen_random_uuid() NOT NULL, -- Key của bảng
	ngay_tao timestamp DEFAULT now() NOT NULL, -- Ngày tạo
	nguoi_tao varchar(100) DEFAULT 'system'::character varying NOT NULL, -- Người tạo
	ngay_cap_nhat timestamp DEFAULT now() NOT NULL, -- Ngày cập nhật
	nguoi_cap_nhat varchar(100) DEFAULT 'system'::character varying NOT NULL, -- Người cập nhật
	bi_xoa int2 DEFAULT 0 NULL, -- Bị xóa mềm
	ngay_xoa timestamp NULL, -- Ngày xóa mềm
	nguoi_xoa varchar(100) NULL, -- Người xóa mềm
	CONSTRAINT dmc_don_vi_dat_may_pkey PRIMARY KEY (id)
);

CREATE TABLE dmc_gioi_tinh (
	ma_gioi_tinh varchar NOT NULL,
	ten_gioi_tinh varchar NOT NULL,
	su_dung bool DEFAULT true NULL,
	id uuid DEFAULT gen_random_uuid() NOT NULL, -- Key của bảng
	ngay_xoa timestamp NULL, -- Ngày xóa mềm
	ngay_tao timestamp DEFAULT now() NOT NULL, -- Ngày tạo
	nguoi_tao text NOT NULL, -- Người tạo
	ngay_cap_nhat timestamp DEFAULT now() NOT NULL, -- Ngày cập nhật
	nguoi_cap_nhat text NOT NULL, -- Người cập nhật
	nguoi_xoa varchar(100) NULL, -- Người xóa mềm
	bi_xoa int2 DEFAULT 0 NULL, -- Bị xóa mềm
	CONSTRAINT dmc_gioi_tinh_ma_gioi_tinh_key UNIQUE (ma_gioi_tinh),
	CONSTRAINT dmc_gioi_tinh_pkey PRIMARY KEY (id)
);

CREATE TABLE dmc_hang_benh_vien (
	ma_hang_benh_vien varchar NOT NULL, -- Mã hạng bệnh viện
	ten_hang_benh_vien varchar NOT NULL, -- Tên hạng bệnh viện
	ghi_chu varchar NULL,
	ten_khong_dau varchar NULL, -- Tên không dấu
	stt int4 NULL, -- Số thứ tự
	id uuid DEFAULT gen_random_uuid() NOT NULL, -- Key của bảng
	ngay_xoa timestamp NULL, -- Ngày xóa mềm
	ngay_tao timestamp DEFAULT now() NOT NULL, -- Ngày tạo
	nguoi_tao text NOT NULL, -- Người tạo
	ngay_cap_nhat timestamp DEFAULT now() NOT NULL, -- Ngày cập nhật
	nguoi_cap_nhat text NOT NULL, -- Người cập nhật
	su_dung bool DEFAULT true NULL,
	nguoi_xoa varchar(100) NULL, -- Người xóa mềm
	bi_xoa int2 DEFAULT 0 NULL, -- Bị xóa mềm
	CONSTRAINT dmc_hang_benh_vien_ma_hang_benh_vien_key UNIQUE (ma_hang_benh_vien),
	CONSTRAINT dmc_hang_benh_vien_pkey PRIMARY KEY (id)
);

CREATE TABLE dmc_hinh_thuc_chuyen_vien (
	ma_hinh_thuc_chuyen_tuyen varchar NOT NULL,
	ten_hinh_thuc_chuyen_tuyen varchar NOT NULL,
	su_dung bool DEFAULT true NULL,
	id uuid DEFAULT gen_random_uuid() NOT NULL, -- Key của bảng
	ngay_xoa timestamp NULL, -- Ngày xóa mềm
	ngay_tao timestamp DEFAULT now() NOT NULL, -- Ngày tạo
	nguoi_tao text NOT NULL, -- Người tạo
	ngay_cap_nhat timestamp DEFAULT now() NOT NULL, -- Ngày cập nhật
	nguoi_cap_nhat text NOT NULL, -- Người cập nhật
	nguoi_xoa varchar(100) NULL, -- Người xóa mềm
	bi_xoa int2 DEFAULT 0 NULL, -- Bị xóa mềm
	CONSTRAINT dmc_hinh_thuc_chuyen_vien_ma_hinh_thuc_chuyen_tuyen_key UNIQUE (ma_hinh_thuc_chuyen_tuyen),
	CONSTRAINT dmc_hinh_thuc_chuyen_vien_pkey PRIMARY KEY (id)
);

CREATE TABLE dmc_hinh_thuc_thanh_toan (
	ma varchar NOT NULL,
	ten varchar NULL,
	ten_khac varchar NULL,
	ghi_chu varchar NULL,
	ten_khong_dau varchar NULL,
	su_dung int4 DEFAULT 1 NOT NULL, -- 0:Không sử dụng; 1 : Sử dụng
	id uuid DEFAULT gen_random_uuid() NOT NULL, -- Key của bảng
	ngay_tao timestamp DEFAULT now() NOT NULL, -- Ngày tạo
	nguoi_tao varchar DEFAULT 'system'::character varying NOT NULL, -- Người tạo
	ngay_cap_nhat timestamp DEFAULT now() NOT NULL, -- Ngày cập nhật
	nguoi_cap_nhat varchar DEFAULT 'system'::character varying NOT NULL, -- Người cập nhật
	bi_xoa int2 DEFAULT 0 NULL, -- Bị xóa mềm
	ngay_xoa timestamp NULL, -- Ngày xóa mềm
	nguoi_xoa varchar NULL, -- Người xóa mềm
	CONSTRAINT dmc_hinh_thuc_thanh_toan_ma_key UNIQUE (ma),
	CONSTRAINT dmc_hinh_thuc_thanh_toan_pkey PRIMARY KEY (id)
);

CREATE TABLE dmc_hoc_ham (
	id uuid DEFAULT gen_random_uuid() NOT NULL, -- Key của bảng
	ma_hoc_ham varchar NOT NULL, -- Mã học hàm
	ten_hoc_ham varchar NOT NULL, -- Tên học hàm
	ten_goi_khac varchar NULL, -- Tên gọi khác
	ghi_chu text NULL, -- Ghi chú
	ten_khong_dau varchar NULL, -- Tên không dấu
	stt int2 NULL, -- Số thứ tự
	su_dung bool DEFAULT true NOT NULL, -- Sử dụng
	bi_xoa int2 DEFAULT 0 NOT NULL, -- Bị xóa mềm
	ngay_tao timestamp DEFAULT now() NOT NULL, -- Ngày tạo
	nguoi_tao varchar DEFAULT 'system'::character varying NOT NULL, -- Người tạo
	ngay_cap_nhat timestamp DEFAULT now() NOT NULL, -- Ngày cập nhật
	nguoi_cap_nhat varchar DEFAULT 'system'::character varying NOT NULL, -- Người cập nhật
	ngay_xoa timestamp NULL, -- Ngày xóa mềm
	nguoi_xoa varchar NULL, -- Người xóa mềm
	CONSTRAINT dmc_hoc_ham_ma_hoc_ham_key UNIQUE (ma_hoc_ham),
	CONSTRAINT dmc_hoc_ham_pkey PRIMARY KEY (id)
);

CREATE TABLE dmc_hoc_vi (
	id uuid DEFAULT gen_random_uuid() NOT NULL, -- Key của bảng
	ma_hoc_vi varchar NOT NULL, -- Mã học vị
	ten_hoc_vi varchar NOT NULL, -- Tên học vị
	ten_goi_khac varchar NULL, -- Tên gọi khác
	ghi_chu text NULL, -- Ghi chú
	ten_khong_dau varchar NULL, -- Tên không dấu
	stt int2 NULL, -- Số thứ tự
	su_dung bool DEFAULT true NOT NULL, -- Sử dụng
	bi_xoa int2 DEFAULT 0 NOT NULL, -- Bị xóa mềm
	ngay_tao timestamp DEFAULT now() NOT NULL, -- Ngày tạo
	nguoi_tao varchar DEFAULT 'system'::character varying NOT NULL, -- Người tạo
	ngay_cap_nhat timestamp DEFAULT now() NOT NULL, -- Ngày cập nhật
	nguoi_cap_nhat varchar DEFAULT 'system'::character varying NOT NULL, -- Người cập nhật
	ngay_xoa timestamp NULL, -- Ngày xóa mềm
	nguoi_xoa varchar NULL, -- Người xóa mềm
	CONSTRAINT dmc_hoc_vi_ma_hoc_vi_key UNIQUE (ma_hoc_vi),
	CONSTRAINT dmc_hoc_vi_pkey PRIMARY KEY (id)
);

CREATE TABLE dmc_icd10 (
	icd_id int4 NULL,
	ma varchar(25) NOT NULL,
	ten varchar(500) NOT NULL,
	ten_en varchar(500) NOT NULL,
	muc varchar(25) NULL,
	nhom_icd10_ma varchar(25) NULL,
	phannhom varchar(100) NULL,
	loai int4 NULL,
	benhtruyennhiem int4 NULL,
	khongdung_bhyt int4 NULL,
	benhchinh int4 NULL,
	benhkemtheo int4 NULL,
	sudung bool NULL,
	id uuid DEFAULT gen_random_uuid() NOT NULL,
	deleted_at timestamp NULL,
	ngay_tao timestamp DEFAULT now() NOT NULL,
	nguoi_tao text NOT NULL,
	ngay_cap_nhat timestamp DEFAULT now() NOT NULL,
	nguoi_cap_nhat text NOT NULL,
	ma_cskcb varchar(100) NULL,
	bi_xoa int2 DEFAULT 0 NOT NULL,
	ngay_xoa timestamp NULL,
	nguoi_xoa varchar(100) NULL,
	nhom_icd10_id uuid NULL,
	ten_khong_dau text NULL,
	ma_khoi text NULL,
	ten_khoi text NULL,
	ma_who text NULL,
	khong_khuyen_khich_benh_chinh text NULL,
	ma_tu_vong text NULL,
	ma_gioi_tinh_nu text NULL,
	ma_gioi_tinh_nam text NULL,
	khong_duoc_dung_benh_chinh text NULL,
	khong_duoc_su_dung_4_5_ky_tu text NULL,
	is_man_tinh int4 NULL,
	is_dieu_tri_dai_ngay int4 NULL,
	is_benh_bi_mat int4 NULL,
	is_khong_bhyt int4 NULL,
	CONSTRAINT dmc_icd10_pkey PRIMARY KEY (id)
);

CREATE TABLE dmc_icd_nghe_nghiep (
	ma varchar(25) NOT NULL, -- Mã
	ten varchar(255) NOT NULL, -- Tên
	ma_icd_10 varchar(25) NULL, -- Mã tham chiếu ICD 10
	ma_cha varchar(25) NULL, -- Mã cha
	stt int4 NULL, -- Số thứ tự
	su_dung bool DEFAULT true NULL, -- Sử dụng
	id uuid DEFAULT gen_random_uuid() NOT NULL, -- Key của bảng
	ngay_tao timestamp DEFAULT now() NOT NULL, -- Ngày tạo
	nguoi_tao varchar(100) DEFAULT 'system'::character varying NOT NULL, -- Người tạo
	ngay_cap_nhat timestamp DEFAULT now() NOT NULL, -- Ngày cập nhật
	nguoi_cap_nhat varchar(100) DEFAULT 'system'::character varying NOT NULL, -- Người cập nhật
	bi_xoa int2 DEFAULT 0 NULL, -- Bị xóa mềm
	ngay_xoa timestamp NULL, -- Ngày xóa mềm
	nguoi_xoa varchar(100) NULL, -- Người xóa mềm
	CONSTRAINT dmc_icd_nghe_nghiep_pkey PRIMARY KEY (id)
);

CREATE TABLE dmc_icd_yhct (
	ma varchar(25) NOT NULL,
	ten varchar(500) NOT NULL,
	ten_benh_yhct varchar(500) NOT NULL,
	icd10_ma varchar(25) NULL,
	ten_benh_yhct_en varchar(500) NOT NULL,
	id uuid DEFAULT gen_random_uuid() NOT NULL,
	deleted_at timestamp NULL,
	ngay_tao timestamp DEFAULT now() NOT NULL,
	nguoi_tao text NOT NULL,
	ngay_cap_nhat timestamp DEFAULT now() NOT NULL,
	nguoi_cap_nhat text NOT NULL,
	ma_cskcb varchar(100) NULL,
	bi_xoa int2 DEFAULT 0 NOT NULL,
	ngay_xoa timestamp NULL,
	nguoi_xoa varchar(100) NULL,
	icd10_id uuid NULL,
	icd_id int4 NULL,
	yhct_id int4 NULL,
	sudung bool NULL,
	CONSTRAINT dmc_icd_yhct_pkey PRIMARY KEY (id)
);

CREATE TABLE dmc_khu_vuc (
	ma_khu_vuc varchar NOT NULL,
	ten_khu_vuc varchar NOT NULL,
	su_dung bool DEFAULT true NULL,
	id uuid DEFAULT gen_random_uuid() NOT NULL, -- Key của bảng
	ngay_xoa timestamp NULL, -- Ngày xóa mềm
	ngay_tao timestamp DEFAULT now() NOT NULL, -- Ngày tạo
	nguoi_tao text NOT NULL, -- Người tạo
	ngay_cap_nhat timestamp DEFAULT now() NOT NULL, -- Ngày cập nhật
	nguoi_cap_nhat text NOT NULL, -- Người cập nhật
	nguoi_xoa varchar(100) NULL, -- Người xóa mềm
	bi_xoa int2 DEFAULT 0 NULL, -- Bị xóa mềm
	CONSTRAINT dmc_khu_vuc_ma_khu_vuc_key UNIQUE (ma_khu_vuc),
	CONSTRAINT dmc_khu_vuc_pkey PRIMARY KEY (id)
);

CREATE TABLE dmc_kq_xet_nghiem (
	ma_kq_xet_nghiem varchar NULL,
	ten_kq_xet_nghiem varchar NULL,
	ten_khac varchar NULL,
	ten_khong_dau varchar NULL,
	stt varchar NULL,
	su_dung bool NULL,
	id uuid DEFAULT gen_random_uuid() NOT NULL, -- Key của bảng
	ngay_tao timestamp DEFAULT now() NOT NULL, -- Ngày tạo
	nguoi_tao varchar(100) DEFAULT 'system'::character varying NOT NULL, -- Người tạo
	ngay_cap_nhat timestamp DEFAULT now() NOT NULL, -- Ngày cập nhật
	nguoi_cap_nhat varchar(100) DEFAULT 'system'::character varying NOT NULL, -- Người cập nhật
	bi_xoa int2 DEFAULT 0 NULL, -- Bị xóa mềm
	ngay_xoa timestamp NULL, -- Ngày xóa mềm
	nguoi_xoa varchar(100) NULL, -- Người xóa mềm
	CONSTRAINT dmc_kq_xet_nghiem_pk_id PRIMARY KEY (id)
);

CREATE TABLE dmc_ksk_hang_muc_kham_chi_tiet (
	ma_hang_muc varchar(25) NOT NULL, -- Mã hạng mục
	ten_hang_muc varchar(255) NOT NULL, -- Tên hạng mục
	ma_hang_muc_cha varchar(25) NULL, -- Mã hạng mục cha
	ma_nhom varchar(255) NULL, -- Mã nhóm
	stt int4 NULL,
	su_dung bool DEFAULT true NULL,
	id uuid DEFAULT gen_random_uuid() NOT NULL, -- Key của bảng
	ngay_tao timestamp DEFAULT now() NOT NULL, -- Ngày tạo
	nguoi_tao varchar(100) DEFAULT 'system'::character varying NOT NULL, -- Người tạo
	ngay_cap_nhat timestamp DEFAULT now() NOT NULL, -- Ngày cập nhật
	nguoi_cap_nhat varchar(100) DEFAULT 'system'::character varying NOT NULL, -- Người cập nhật
	bi_xoa int2 DEFAULT 0 NULL, -- Bị xóa mềm
	ngay_xoa timestamp NULL, -- Ngày xóa mềm
	nguoi_xoa varchar(100) NULL, -- Người xóa mềm
	ghi_chu text NULL, -- Ghi chú
	CONSTRAINT dmc_ksk_hang_muc_kham_chi_tiet_pkey PRIMARY KEY (id)
);

CREATE TABLE dmc_loai_csyt (
	ma_loai varchar NOT NULL,
	ten_loai varchar NOT NULL,
	ten_nhom varchar NULL,
	su_dung bool DEFAULT true NULL,
	id uuid DEFAULT gen_random_uuid() NOT NULL, -- Key của bảng
	ngay_xoa timestamp NULL, -- Ngày xóa mềm
	ngay_tao timestamp DEFAULT now() NOT NULL, -- Ngày tạo
	nguoi_tao text NOT NULL, -- Người tạo
	ngay_cap_nhat timestamp DEFAULT now() NOT NULL, -- Ngày cập nhật
	nguoi_cap_nhat text NOT NULL, -- Người cập nhật
	nguoi_xoa varchar(100) NULL, -- Người xóa mềm
	bi_xoa int2 DEFAULT 0 NULL, -- Bị xóa mềm
	CONSTRAINT dmc_loai_csyt_ma_loai_key UNIQUE (ma_loai),
	CONSTRAINT dmc_loai_csyt_pkey PRIMARY KEY (id)
);

CREATE TABLE dmc_loai_don_thuoc (
	ten_don varchar NOT NULL,
	su_dung bool DEFAULT true NOT NULL,
	ghi_chu text NULL,
	report_code varchar NOT NULL,
	loai_don_id serial4 NOT NULL, -- Mapping với duc_thuocvattu
	id uuid DEFAULT gen_random_uuid() NOT NULL, -- Key của bảng
	ngay_tao timestamp DEFAULT now() NOT NULL, -- Ngày tạo
	nguoi_tao varchar DEFAULT 'system'::character varying NOT NULL, -- Người tạo
	ngay_cap_nhat timestamp DEFAULT now() NOT NULL, -- Ngày cập nhật
	nguoi_cap_nhat varchar DEFAULT 'system'::character varying NOT NULL, -- Người cập nhật
	bi_xoa int2 DEFAULT 0 NULL, -- Bị xóa mềm
	ngay_xoa timestamp NULL, -- Ngày xóa mềm
	nguoi_xoa varchar NULL, -- Người xóa mềm
	ma_don varchar NOT NULL,
	ten_phieu varchar NULL,
	CONSTRAINT dmc_loai_don_thuoc_ma_don_key UNIQUE (ma_don),
	CONSTRAINT dmc_loai_don_thuoc_pkey PRIMARY KEY (id)
);

CREATE TABLE dmc_loai_hinh_to_chuc (
	ma_loai_hinh varchar NOT NULL,
	ten_loai_hinh varchar NOT NULL,
	ghi_chu text NULL,
	su_dung bool DEFAULT true NULL,
	id uuid DEFAULT gen_random_uuid() NOT NULL, -- Key của bảng
	ngay_xoa timestamp NULL, -- Ngày xóa mềm
	ngay_tao timestamp DEFAULT now() NOT NULL, -- Ngày tạo
	nguoi_tao text NOT NULL, -- Người tạo
	ngay_cap_nhat timestamp DEFAULT now() NOT NULL, -- Ngày cập nhật
	nguoi_cap_nhat text NOT NULL, -- Người cập nhật
	nguoi_xoa varchar(100) NULL, -- Người xóa mềm
	bi_xoa int2 DEFAULT 0 NULL, -- Bị xóa mềm
	CONSTRAINT dmc_loai_hinh_to_chuc_ma_loai_hinh_key UNIQUE (ma_loai_hinh),
	CONSTRAINT dmc_loai_hinh_to_chuc_pkey PRIMARY KEY (id)
);

CREATE TABLE dmc_loai_ksk (
	ma_loai_ksk varchar NOT NULL, -- Mã loại KSK
	ten_loai_ksk varchar NOT NULL, -- Tên loại KSK
	ten_khong_dau varchar NULL, -- Tên không dấu
	stt int4 NULL, -- Số thứ tự
	su_dung bool DEFAULT true NULL, -- Sử dụng
	id uuid DEFAULT gen_random_uuid() NOT NULL, -- Key của bảng
	ngay_tao timestamp DEFAULT now() NOT NULL, -- Ngày tạo
	nguoi_tao varchar DEFAULT 'system'::character varying NOT NULL, -- Người tạo
	ngay_cap_nhat timestamp DEFAULT now() NOT NULL, -- Ngày cập nhật
	nguoi_cap_nhat varchar DEFAULT 'system'::character varying NOT NULL, -- Người cập nhật
	bi_xoa int2 DEFAULT 0 NULL, -- Bị xóa mềm
	ngay_xoa timestamp NULL, -- Ngày xóa mềm
	nguoi_xoa varchar NULL, -- Người xóa mềm
	CONSTRAINT dmc_loai_ksk_ma_loai_ksk_key UNIQUE (ma_loai_ksk),
	CONSTRAINT dmc_loai_ksk_pkey PRIMARY KEY (id)
);

CREATE TABLE dmc_loai_nhan_vien (
	id uuid DEFAULT gen_random_uuid() NOT NULL, -- Key của bảng
	ma_loai_nhan_vien varchar NOT NULL, -- Mã loại nhân viên
	ten_loai_nhan_vien varchar NOT NULL, -- Tên loại nhân viên
	ten_goi_khac varchar NULL, -- Tên gọi khác
	ghi_chu text NULL, -- Ghi chú
	ten_khong_dau varchar NULL, -- Tên không dấu
	su_dung bool DEFAULT true NOT NULL, -- Sử dụng
	bi_xoa int2 DEFAULT 0 NOT NULL, -- Bị xóa mềm
	nguoi_tao varchar(100) DEFAULT 'system'::character varying NOT NULL, -- Người tạo
	ngay_tao timestamp DEFAULT CURRENT_TIMESTAMP NULL, -- Ngày tạo
	nguoi_cap_nhat varchar(100) NULL, -- Người cập nhật
	ngay_cap_nhat timestamp DEFAULT CURRENT_TIMESTAMP NULL, -- Ngày cập nhật
	nguoi_xoa varchar(100) NULL, -- Người xóa mềm
	ngay_xoa timestamp NULL, -- Ngày xóa mềm
	CONSTRAINT dmc_loai_nhan_vien_ma_loai_nhan_vien_key UNIQUE (ma_loai_nhan_vien),
	CONSTRAINT dmc_loai_nhan_vien_pkey PRIMARY KEY (id)
);

CREATE TABLE dmc_loai_tep_tin (
	ma_loai_tep varchar(25) NOT NULL, -- Mã loại tệp
	ten_loai_tep varchar(255) NOT NULL, -- Tên loại tệp
	stt int4 NULL, -- Số thứ tự
	su_dung bool DEFAULT true NULL, -- Sử dụng
	id uuid DEFAULT gen_random_uuid() NOT NULL, -- Key của bảng
	ngay_tao timestamp DEFAULT now() NOT NULL, -- Ngày tạo
	nguoi_tao varchar(100) DEFAULT '''system'''::character varying NOT NULL, -- Người tạo
	ngay_cap_nhat timestamp DEFAULT now() NOT NULL, -- Ngày cập nhật
	nguoi_cap_nhat varchar(100) DEFAULT '''system'''::character varying NOT NULL, -- Người cập nhật
	bi_xoa int2 DEFAULT 0 NULL, -- Bị xóa mềm
	ngay_xoa timestamp NULL, -- Ngày xóa mềm
	nguoi_xoa varchar(100) NULL, -- Người xóa mềm
	CONSTRAINT dmc_loai_tep_tin_pkey PRIMARY KEY (id)
);

CREATE TABLE dmc_loai_thuoc_vat_tu (
	ma_loai_tvt varchar NOT NULL,
	ten_loai_tvt varchar NOT NULL,
	kieu_xuat int4 NOT NULL,
	ghi_chu text NULL,
	su_dung bool NULL,
	loai_thuoc_vat_tu_id serial4 NOT NULL, -- Mapping với bảng duc_thuocvattu
	id uuid DEFAULT gen_random_uuid() NOT NULL, -- Key của bảng
	ngay_tao timestamp DEFAULT now() NOT NULL, -- Ngày tạo
	nguoi_tao varchar DEFAULT 'system'::character varying NOT NULL, -- Người tạo
	ngay_cap_nhat timestamp DEFAULT now() NOT NULL, -- Ngày cập nhật
	nguoi_cap_nhat varchar DEFAULT 'system'::character varying NOT NULL, -- Người cập nhật
	bi_xoa int2 DEFAULT 0 NULL, -- Bị xóa mềm
	ngay_xoa timestamp NULL, -- Ngày xóa mềm
	nguoi_xoa varchar NULL, -- Người xóa mềm
	report_code varchar NULL,
	CONSTRAINT dmc_loai_thuoc_vat_tu_pkey PRIMARY KEY (id)
);

CREATE TABLE dmc_loaiba_khoasd (
	khoa_id uuid NOT NULL,
	loai_benh_an_id uuid NOT NULL,
	ten_loai_benh_an varchar NULL,
	su_dung bool NULL,
	id uuid DEFAULT gen_random_uuid() NOT NULL, -- Key của bảng
	ngay_tao timestamp DEFAULT now() NOT NULL, -- Ngày tạo
	nguoi_tao varchar(100) DEFAULT '''system'''::character varying NOT NULL, -- Người tạo
	ngay_cap_nhat timestamp DEFAULT now() NOT NULL, -- Ngày cập nhật
	nguoi_cap_nhat varchar(100) DEFAULT '''system'''::character varying NOT NULL, -- Người cập nhật
	bi_xoa int2 DEFAULT 0 NULL, -- Bị xóa mềm
	ngay_xoa timestamp NULL, -- Ngày xóa mềm
	nguoi_xoa varchar(100) NULL, -- Người xóa mềm
	CONSTRAINT dmc_loaiba_khoasd_pk_id PRIMARY KEY (id)
);

CREATE TABLE dmc_loaikho (
	maloaikho varchar NOT NULL,
	tenloaikho varchar NOT NULL,
	tengoikhac varchar NULL,
	ghichu varchar NULL,
	tenkhongdau varchar NULL,
	stt int4 NULL,
	su_dung int4 NULL,
	id uuid DEFAULT gen_random_uuid() NOT NULL,
	deleted_at timestamp NULL,
	created_at timestamp DEFAULT now() NOT NULL,
	created_by text NOT NULL,
	updated_at timestamp DEFAULT now() NOT NULL,
	updated_by text NOT NULL,
	loaikhoid numeric NULL,
	CONSTRAINT dmc_loaikho_id_key UNIQUE (id),
	CONSTRAINT dmc_loaikho_maloaikho_key UNIQUE (maloaikho),
	CONSTRAINT dmc_loaikho_pkey PRIMARY KEY (id),
	CONSTRAINT dmc_loaikho_tenloaikho_key UNIQUE (tenloaikho)
);

CREATE TABLE dmc_loaituoi (
	maloai varchar NULL,
	tenloai varchar NULL,
	tenkhac varchar NULL,
	tenkhongdau varchar NULL,
	stt varchar NULL,
	sudung bool DEFAULT true NULL,
	id uuid DEFAULT gen_random_uuid() NOT NULL, -- Key của bảng
	ngay_tao timestamp DEFAULT now() NOT NULL, -- Ngày tạo
	nguoi_tao varchar(100) DEFAULT 'system'::character varying NOT NULL, -- Người tạo
	ngay_cap_nhat timestamp DEFAULT now() NOT NULL, -- Ngày cập nhật
	nguoi_cap_nhat varchar(100) DEFAULT 'system'::character varying NOT NULL, -- Người cập nhật
	bi_xoa int2 DEFAULT 0 NULL, -- Bị xóa mềm
	ngay_xoa timestamp NULL, -- Ngày xóa mềm
	nguoi_xoa varchar(100) NULL, -- Người xóa mềm
	CONSTRAINT dmc_loaituoi_pkey PRIMARY KEY (id)
);

CREATE TABLE dmc_luong_co_ban (
	id uuid DEFAULT gen_random_uuid() NOT NULL,
	so_qd varchar(25) NOT NULL,
	so_tien numeric NULL,
	ngay_ap_dung date NULL,
	ghi_chu varchar(500) NULL,
	hieu_luc int2 DEFAULT 1 NULL,
	ngay_tao timestamp DEFAULT now() NOT NULL,
	nguoi_tao varchar(100) NOT NULL,
	ngay_cap_nhat timestamp DEFAULT now() NOT NULL,
	nguoi_cap_nhat varchar(100) NOT NULL,
	bi_xoa int2 DEFAULT 0 NOT NULL,
	ngay_xoa timestamp NULL,
	nguoi_xoa varchar(100) NULL,
	CONSTRAINT dmc_luong_co_ban_pkey PRIMARY KEY (id)
);

CREATE TABLE dmc_ly_do_chuyen_vien (
	ma_ly_do_chuyen_vien varchar NOT NULL,
	ten_ly_do_chuyen_vien varchar NOT NULL,
	su_dung bool DEFAULT true NULL,
	id uuid DEFAULT gen_random_uuid() NOT NULL, -- Key của bảng
	ngay_xoa timestamp NULL, -- Ngày xóa mềm
	ngay_tao timestamp DEFAULT now() NOT NULL, -- Ngày tạo
	nguoi_tao text NOT NULL, -- Người tạo
	ngay_cap_nhat timestamp DEFAULT now() NOT NULL, -- Ngày cập nhật
	nguoi_cap_nhat text NOT NULL, -- Người cập nhật
	nguoi_xoa varchar(100) NULL, -- Người xóa mềm
	bi_xoa int2 DEFAULT 0 NULL, -- Bị xóa mềm
	CONSTRAINT dmc_ly_do_chuyen_vien_ma_ly_do_chuyen_vien_key UNIQUE (ma_ly_do_chuyen_vien),
	CONSTRAINT dmc_ly_do_chuyen_vien_pkey PRIMARY KEY (id)
);

CREATE TABLE dmc_ly_do_mien_giam (
	ma varchar(25) NOT NULL,
	ten varchar(255) NOT NULL,
	ten_khac varchar(255) NOT NULL,
	ghi_chu varchar NULL,
	ten_khong_dau varchar(255) NULL,
	su_dung int2 DEFAULT 1 NOT NULL,
	id uuid DEFAULT gen_random_uuid() NOT NULL,
	ngay_tao timestamp DEFAULT now() NOT NULL,
	nguoi_tao varchar(100) DEFAULT 'system'::character varying NOT NULL,
	ngay_cap_nhat timestamp DEFAULT now() NOT NULL,
	nguoi_cap_nhat varchar(100) DEFAULT 'system'::character varying NOT NULL,
	bi_xoa int2 DEFAULT 0 NULL,
	ngay_xoa timestamp NULL,
	nguoi_xoa varchar(100) NULL,
	CONSTRAINT dmc_ly_do_mien_giam_pk_id PRIMARY KEY (id)
);

CREATE TABLE dmc_ma_loai_kcb (
	ma_loai_kcb varchar(25) NOT NULL,
	ten_loai_kcb varchar(500) NOT NULL,
	qd_ban_hanh varchar(255) NULL,
	ngay_ban_hanh date NULL,
	ghi_chu text NULL,
	su_dung bool DEFAULT true NULL,
	id uuid DEFAULT gen_random_uuid() NOT NULL, -- Key của bảng
	ngay_xoa timestamp NULL, -- Ngày xóa mềm
	ngay_tao timestamp DEFAULT now() NOT NULL, -- Ngày tạo
	nguoi_tao varchar(100) DEFAULT 'system'::character varying NOT NULL, -- Người tạo
	ngay_cap_nhat timestamp DEFAULT now() NOT NULL, -- Ngày cập nhật
	nguoi_cap_nhat varchar(100) DEFAULT 'system'::character varying NOT NULL, -- Người cập nhật
	nguoi_xoa varchar(100) NULL, -- Người xóa mềm
	bi_xoa int2 DEFAULT 0 NULL, -- Bị xóa mềm
	bao_cao uuid NULL, -- Báo cáo bhyt
	param_url varchar(100) NULL, -- param truyền vào url
	CONSTRAINT dmc_ma_loai_kcb_ma_loai_kcb_key UNIQUE (ma_loai_kcb),
	CONSTRAINT dmc_ma_loai_kcb_pkey PRIMARY KEY (id)
);

CREATE TABLE dmc_ma_loai_ra_vien (
	ma_loai_ra_vien varchar NULL, -- Mã loại ra viện
	ten_loai_ra_vien varchar NULL, -- Tên loại ra viện
	ten_khong_dau varchar NULL, -- Tên không dấu
	stt int4 NULL, -- Số thứ tự
	su_dung bool NULL, -- Sử dụng
	ghi_chu varchar NULL, -- Ghi chú
	id uuid DEFAULT gen_random_uuid() NOT NULL, -- Key của bảng
	ngay_tao timestamp DEFAULT now() NOT NULL, -- Ngày tạo
	nguoi_tao varchar DEFAULT 'system'::character varying NOT NULL, -- Người tạo
	ngay_cap_nhat timestamp DEFAULT now() NOT NULL, -- Ngày cập nhật
	nguoi_cap_nhat varchar DEFAULT 'system'::character varying NOT NULL, -- Người cập nhật
	bi_xoa int2 DEFAULT 0 NULL, -- Bị xóa mềm
	ngay_xoa timestamp NULL, -- Ngày xóa mềm
	nguoi_xoa varchar NULL, -- Người xóa mềm
	CONSTRAINT dmc_ma_loai_ra_vien_ma_loai_ra_vien_key UNIQUE (ma_loai_ra_vien),
	CONSTRAINT dmc_ma_loai_ra_vien_pkey PRIMARY KEY (id),
	CONSTRAINT dmc_ma_loai_ra_vien_ten_loai_ra_vien_key UNIQUE (ten_loai_ra_vien)
);

CREATE TABLE dmc_ma_nhom_chi_phi (
	id uuid DEFAULT gen_random_uuid() NOT NULL,
	ma varchar(25) NOT NULL,
	ten varchar(255) NOT NULL,
	ten_khac varchar(255) NOT NULL,
	su_dung int2 DEFAULT 1 NULL,
	ngay_tao timestamp DEFAULT now() NOT NULL,
	nguoi_tao varchar(100) NOT NULL,
	ngay_cap_nhat timestamp DEFAULT now() NOT NULL,
	nguoi_cap_nhat varchar(100) NOT NULL,
	bi_xoa int2 DEFAULT 0 NOT NULL,
	ngay_xoa timestamp NULL,
	nguoi_xoa varchar(100) NULL,
	CONSTRAINT dmc_ma_nhom_chi_phi_pkey PRIMARY KEY (id)
);

CREATE TABLE dmc_ma_vi_tri_co_the (
	ma varchar(25) NOT NULL, -- Mã vị trí cơ thể
	ten varchar(255) NOT NULL, -- Tên vị trí cơ thể
	stt int4 NULL, -- Số thứ tự
	su_dung bool NULL, -- Trạng thái sử dụng
	id uuid DEFAULT gen_random_uuid() NOT NULL, -- Key của bảng
	ngay_tao timestamp DEFAULT now() NOT NULL, -- Ngày tạo
	nguoi_tao varchar(100) DEFAULT 'system'::character varying NOT NULL, -- Người tạo
	ngay_cap_nhat timestamp DEFAULT now() NOT NULL, -- Ngày cập nhật
	nguoi_cap_nhat varchar(100) DEFAULT 'system'::character varying NOT NULL, -- Người cập nhật
	bi_xoa int2 DEFAULT 0 NULL, -- Bị xóa mềm
	ngay_xoa timestamp NULL, -- Ngày xóa mềm
	nguoi_xoa varchar(100) NULL, -- Người xóa mềm
	CONSTRAINT dmc_ma_vi_tri_co_the_pkey PRIMARY KEY (id)
);

CREATE TABLE dmc_ngay_nghi (
	ma_ngay_nghi varchar NOT NULL, -- Mã ngày nghỉ
	ten_ngay_nghi varchar NOT NULL, -- Tên ngày nghỉ
	ngay date NULL, -- Ngày nghỉ
	loai_ngay_nghi int4 NULL, -- Loại ngày nghỉ id
	ghi_chu varchar NULL,
	su_dung bool NULL,
	id uuid DEFAULT gen_random_uuid() NOT NULL, -- Key của bảng
	ngay_tao timestamp DEFAULT now() NOT NULL, -- Ngày tạo
	nguoi_tao varchar DEFAULT 'system'::character varying NOT NULL, -- Người tạo
	ngay_cap_nhat timestamp DEFAULT now() NOT NULL, -- Ngày cập nhật
	nguoi_cap_nhat varchar DEFAULT 'system'::character varying NOT NULL, -- Người cập nhật
	bi_xoa int2 DEFAULT 0 NULL, -- Bị xóa mềm
	ngay_xoa timestamp NULL, -- Ngày xóa mềm
	nguoi_xoa varchar NULL, -- Người xóa mềm
	CONSTRAINT dmc_ngay_nghi_ma_ngay_nghi_key UNIQUE (ma_ngay_nghi),
	CONSTRAINT dmc_ngay_nghi_pkey PRIMARY KEY (id)
);

CREATE TABLE dmc_nghe_nghiep (
	id uuid DEFAULT gen_random_uuid() NOT NULL, -- Key của bảng
	ma_nghe_nghiep varchar(25) NOT NULL,
	ten_nghe_nghiep varchar(255) NOT NULL,
	cap_id int2 NULL,
	ma_cap_cha int2 NULL,
	ten_khong_dau varchar(255) NULL,
	stt int2 NULL,
	tuoi_nho_nhat int2 NULL,
	tuoi_lon_nhat int2 NULL,
	su_dung bool DEFAULT true NULL,
	bi_xoa int2 DEFAULT 0 NULL, -- Bị xóa mềm
	nguoi_tao varchar(100) DEFAULT 'system'::character varying NOT NULL, -- Người tạo
	ngay_tao timestamp DEFAULT now() NOT NULL, -- Ngày tạo
	nguoi_cap_nhat varchar(100) DEFAULT 'system'::character varying NOT NULL, -- Người cập nhật
	ngay_cap_nhat timestamp DEFAULT now() NOT NULL, -- Ngày cập nhật
	nguoi_xoa varchar(100) NULL, -- Người xóa mềm
	ngay_xoa timestamp NULL, -- Ngày xóa mềm
	ma_nghe_nghiep_bhxh text NULL, -- Mã nghề nghiệp BHXH
	tuoi_nho_nhat_expr varchar NULL, -- Biểu thức tuổi nhỏ nhất theo spring boot PeriodStyle¶VD:¶# Parsed as 3 Months and 5 Days using Simple Style¶app.scheduler.simple-interval=3m5d¶¶# Parsed as 1 Year and 2 Months using standard ISO-8601¶app.scheduler.iso-interval=P1Y2M
	tuoi_lon_nhat_expr varchar NULL, -- Biểu thức tuổi lớn nhất theo spring boot PeriodStyle¶VD:¶# Parsed as 3 Months and 5 Days using Simple Style¶app.scheduler.simple-interval=3m5d¶¶# Parsed as 1 Year and 2 Months using standard ISO-8601¶app.scheduler.iso-interval=P1Y2M
	ma_cap_cha_id uuid NULL, -- FK dmc_nghe_nghiep
	CONSTRAINT dmc_nghe_nghiep_ma_nghe_nghiep_key UNIQUE (ma_nghe_nghiep),
	CONSTRAINT dmc_nghe_nghiep_pkey PRIMARY KEY (id)
);

CREATE TABLE dmc_nguon_thiet_bi (
	ma_nguon_thiet_bi varchar(100) NULL, -- Mã nguồn thiết bị
	ten_nguon_thiet_bi varchar(255) NULL, -- Tên nguồn thiết bị
	ten_goi_khac varchar(255) NULL, -- Tên gọi khác
	ghi_chu varchar(255) NULL, -- Ghi chú
	ten_khong_dau varchar(255) NULL, -- Tên không dấu
	su_dung bool NULL, -- Sử dụng
	id uuid DEFAULT gen_random_uuid() NOT NULL, -- Key của bảng
	ngay_tao timestamp DEFAULT now() NOT NULL, -- Ngày tạo
	nguoi_tao varchar(100) DEFAULT 'system'::character varying NOT NULL, -- Người tạo
	ngay_cap_nhat timestamp DEFAULT now() NOT NULL, -- Ngày cập nhật
	nguoi_cap_nhat varchar(100) DEFAULT 'system'::character varying NOT NULL, -- Người cập nhật
	bi_xoa int2 DEFAULT 0 NULL, -- Bị xóa mềm
	ngay_xoa timestamp NULL, -- Ngày xóa mềm
	nguoi_xoa varchar(100) NULL, -- Người xóa mềm
	CONSTRAINT dmc_nguon_thiet_bi_pkey PRIMARY KEY (id)
);

CREATE TABLE dmc_nhom_dieu_tri (
	ma_nhom_dieu_tri varchar NOT NULL, -- Mã nhóm điều trị
	ten_nhom_dieu_tri varchar NOT NULL, -- Tên nhóm điều trị
	ten_goi_khac varchar NULL, -- Tên gọi khác
	ghi_chu text NULL, -- Ghi chú
	ten_khong_dau varchar NULL, -- Tên không dấu
	su_dung bool DEFAULT true NULL, -- Sử dụng
	id uuid DEFAULT gen_random_uuid() NOT NULL, -- Key của bảng
	ngay_tao timestamp DEFAULT now() NOT NULL, -- Ngày tạo
	nguoi_tao varchar DEFAULT 'system'::character varying NOT NULL, -- Người tạo
	ngay_cap_nhat timestamp DEFAULT now() NOT NULL, -- Ngày cập nhật
	nguoi_cap_nhat varchar DEFAULT 'system'::character varying NOT NULL, -- Người cập nhật
	bi_xoa int2 DEFAULT 0 NULL, -- Bị xóa mềm
	ngay_xoa timestamp NULL, -- Ngày xóa mềm
	nguoi_xoa varchar NULL, -- Người xóa mềm
	CONSTRAINT dmc_nhom_dieu_tri_ma_nhom_dieu_tri_key UNIQUE (ma_nhom_dieu_tri),
	CONSTRAINT dmc_nhom_dieu_tri_pkey PRIMARY KEY (id)
);

CREATE TABLE dmc_nhom_mau (
	ma_nhom_mau varchar(25) NOT NULL, -- Mã nhóm máu
	ten_nhom_mau varchar(255) NOT NULL, -- Tên nhóm máu
	ten_khac varchar(255) NULL, -- Tên khác
	ten_khong_dau varchar(255) NULL, -- Tên không dấu
	stt int4 NULL, -- Số thứ tự
	su_dung bool DEFAULT true NULL, -- Sử dụng
	id uuid DEFAULT gen_random_uuid() NOT NULL, -- Key của bảng
	ngay_tao timestamp DEFAULT now() NOT NULL, -- Ngày tạo
	nguoi_tao varchar(100) DEFAULT 'system'::character varying NOT NULL, -- Người tạo
	ngay_cap_nhat timestamp DEFAULT now() NOT NULL, -- Ngày cập nhật
	nguoi_cap_nhat varchar(100) DEFAULT 'system'::character varying NOT NULL, -- Người cập nhật
	bi_xoa int2 DEFAULT 0 NULL, -- Bị xóa mềm
	ngay_xoa timestamp NULL, -- Ngày xóa mềm
	nguoi_xoa varchar(100) NULL, -- Người xóa mềm
	ma_cskcb varchar(100) NULL,
	CONSTRAINT dmc_nhom_mau_ma_nhom_mau_key UNIQUE (ma_nhom_mau),
	CONSTRAINT dmc_nhom_mau_pk_id PRIMARY KEY (id)
);

CREATE TABLE dmc_nhom_ung_dung (
	ten varchar(100) NOT NULL, -- Tên
	ma varchar(100) NOT NULL, -- Mã
	mo_ta text NULL, -- Mô tả
	id uuid DEFAULT gen_random_uuid() NOT NULL, -- Key của bảng
	ngay_tao timestamp DEFAULT now() NOT NULL, -- Ngày tạo
	nguoi_tao varchar(100) DEFAULT 'system'::character varying NOT NULL, -- Người tạo
	ngay_cap_nhat timestamp DEFAULT now() NOT NULL, -- Ngày cập nhật
	nguoi_cap_nhat varchar(100) DEFAULT 'system'::character varying NOT NULL, -- Người cập nhật
	bi_xoa int2 DEFAULT 0 NULL, -- Bị xóa mềm
	ngay_xoa timestamp NULL, -- Ngày xóa mềm
	nguoi_xoa varchar(100) NULL, -- Người xóa mềm
	url varchar(255) NULL,
	CONSTRAINT dmc_nhom_ung_dung_pkey PRIMARY KEY (id)
);

CREATE TABLE dmc_nuocsanxuat (
	nuocsanxuatid numeric(10) NOT NULL,
	ma varchar(10) NULL,
	ten varchar(140) NULL,
	"version" timestamp NULL,
	sync_flag numeric(1) NULL,
	update_flag numeric(1) NULL,
	su_dung bool DEFAULT true NULL,
	CONSTRAINT dmc_nuocsanxuat_pkey PRIMARY KEY (nuocsanxuatid)
);

CREATE TABLE dmc_pham_vi (
	ten varchar(255) NOT NULL, -- Tên phạm vi
	ma varchar(25) NOT NULL, -- Mã phạm vi
	su_dung int2 DEFAULT 1 NOT NULL, -- Sử dụng
	id uuid DEFAULT gen_random_uuid() NOT NULL, -- Key của bảng
	ngay_tao timestamp DEFAULT now() NOT NULL, -- Ngày tạo
	nguoi_tao varchar(100) DEFAULT 'system'::character varying NOT NULL, -- Người tạo
	ngay_cap_nhat timestamp DEFAULT now() NOT NULL, -- Ngày cập nhật
	nguoi_cap_nhat varchar(100) DEFAULT 'system'::character varying NOT NULL, -- Người cập nhật
	bi_xoa int2 DEFAULT 0 NULL, -- Bị xóa mềm
	ngay_xoa timestamp NULL, -- Ngày xóa mềm
	nguoi_xoa varchar(100) NULL, -- Người xóa mềm
	CONSTRAINT dmc_pham_vi_pkey PRIMARY KEY (id)
);

CREATE TABLE dmc_phan_loai_can_bo (
	ma_phan_loai varchar NOT NULL,
	ten_phan_loai varchar NOT NULL,
	su_dung bool DEFAULT true NULL,
	id uuid DEFAULT gen_random_uuid() NOT NULL,
	deleted_at timestamp NULL,
	created_at timestamp DEFAULT now() NOT NULL,
	created_by text NOT NULL,
	updated_at timestamp DEFAULT now() NOT NULL,
	updated_by text NOT NULL,
	CONSTRAINT dmc_phan_loai_can_bo_ma_phan_loai_key UNIQUE (ma_phan_loai),
	CONSTRAINT dmc_phan_loai_can_bo_pkey PRIMARY KEY (id)
);

CREATE TABLE dmc_phieu_ksk (
	report_code varchar NULL, -- Mã phiếu - report code
	ten varchar(255) NOT NULL, -- Tên phiếu
	stt int4 NULL, -- Số thứ tự
	su_dung bool DEFAULT true NULL, -- Sử dụng
	id uuid DEFAULT gen_random_uuid() NOT NULL, -- Key của bảng
	ngay_tao timestamp DEFAULT now() NOT NULL, -- Ngày tạo
	nguoi_tao varchar(100) DEFAULT 'system'::character varying NOT NULL, -- Người tạo
	ngay_cap_nhat timestamp DEFAULT now() NOT NULL, -- Ngày cập nhật
	nguoi_cap_nhat varchar(100) DEFAULT 'system'::character varying NOT NULL, -- Người cập nhật
	bi_xoa int2 DEFAULT 0 NULL, -- Bị xóa mềm
	ngay_xoa timestamp NULL, -- Ngày xóa mềm
	nguoi_xoa varchar(100) NULL, -- Người xóa mềm
	ma_nhom_xep_loai varchar(25) NULL, -- Nhóm xếp loại KSK
	appid varchar NULL, -- App id lowcoder
	CONSTRAINT dmc_phieu_ksk_pkey PRIMARY KEY (id)
);

CREATE TABLE dmc_phieu_ky_so (
	id uuid DEFAULT gen_random_uuid() NOT NULL,
	ma varchar(100) NOT NULL,
	ten varchar(100) NULL,
	ma_report varchar(100) NULL,
	ma_hreport varchar(100) NULL,
	ma_xml varchar(100) NULL,
	ma_kieu_in_phieu varchar(100) NULL,
	ma_loai_phieu varchar(100) NULL,
	so_thu_tu_loai_phieu int4 NULL,
	so_thu_tu_hsba int4 NULL,
	bat_buoc_ky int2 NULL,
	la_phieu_di_buong int2 NULL,
	mo_ta text NULL,
	ma_loai_ky varchar(100) NULL,
	ngay_tao timestamp DEFAULT now() NOT NULL,
	nguoi_tao varchar NOT NULL,
	ngay_cap_nhat timestamp DEFAULT now() NOT NULL,
	nguoi_cap_nhat varchar NOT NULL,
	bi_xoa int2 DEFAULT 0 NULL,
	ngay_xoa timestamp NULL,
	nguoi_xoa varchar NULL,
	ham_lay_du_lieu varchar(100) NULL,
	hoat_dong int2 DEFAULT 1 NULL,
	CONSTRAINT dmc_phieu_ky_so_pkey PRIMARY KEY (id)
);

CREATE TABLE dmc_phuong_tien (
	ma varchar(50) NOT NULL,
	ten varchar(255) NOT NULL,
	id uuid DEFAULT gen_random_uuid() NOT NULL, -- Key của bảng
	ngay_tao timestamp DEFAULT now() NOT NULL, -- Ngày tạo
	nguoi_tao varchar(100) DEFAULT 'system'::character varying NOT NULL, -- Người tạo
	ngay_cap_nhat timestamp DEFAULT now() NOT NULL, -- Ngày cập nhật
	nguoi_cap_nhat varchar(100) DEFAULT 'system'::character varying NOT NULL, -- Người cập nhật
	bi_xoa int2 DEFAULT 0 NULL, -- Bị xóa mềm
	ngay_xoa timestamp NULL, -- Ngày xóa mềm
	nguoi_xoa varchar(100) NULL, -- Người xóa mềm
	CONSTRAINT dmc_phuong_tien_pkey PRIMARY KEY (id)
);

CREATE TABLE dmc_ppcb_yhct (
	ma_phuong_phap varchar NULL,
	phuong_phap varchar NOT NULL,
	ten_phuong_phap varchar NOT NULL,
	ghi_chu varchar NULL,
	su_dung bool NULL,
	id uuid DEFAULT gen_random_uuid() NOT NULL,
	deleted_at timestamp NULL,
	created_at timestamp DEFAULT now() NOT NULL,
	created_by text NOT NULL,
	updated_at timestamp DEFAULT now() NOT NULL,
	updated_by text NOT NULL,
	pp_che_bien int4 NOT NULL,
	CONSTRAINT dmc_ppcb_yhct_id_key UNIQUE (id),
	CONSTRAINT dmc_ppcb_yhct_ma_phuong_phap_key UNIQUE (ma_phuong_phap),
	CONSTRAINT dmc_ppcb_yhct_pkey PRIMARY KEY (id),
	CONSTRAINT dmc_ppcb_yhct_ten_phuong_phap_key UNIQUE (ten_phuong_phap)
);

CREATE TABLE dmc_quan_he_gia_dinh (
	ma_quan_he varchar NOT NULL,
	ten_quan_he varchar NOT NULL,
	su_dung bool DEFAULT true NULL,
	id uuid DEFAULT gen_random_uuid() NOT NULL, -- Key của bảng
	ngay_xoa timestamp NULL, -- Ngày xóa mềm
	ngay_tao timestamp DEFAULT now() NOT NULL, -- Ngày tạo
	nguoi_tao text NOT NULL, -- Người tạo
	ngay_cap_nhat timestamp DEFAULT now() NOT NULL, -- Ngày cập nhật
	nguoi_cap_nhat text NOT NULL, -- Người cập nhật
	ten_khac varchar(255) NULL,
	nguoi_xoa varchar(100) NULL, -- Người xóa mềm
	bi_xoa int2 DEFAULT 0 NULL, -- Bị xóa mềm
	CONSTRAINT dmc_quan_he_gia_dinh_ma_quan_he_key UNIQUE (ma_quan_he),
	CONSTRAINT dmc_quan_he_gia_dinh_pkey PRIMARY KEY (id)
);

CREATE TABLE dmc_quoc_gia (
	ma_quoc_gia varchar(25) NOT NULL, -- Mã quốc gia theo tiêu chuẩn quốc tế
	ten_quoc_gia varchar(255) NOT NULL, -- tên quốc gia
	id uuid DEFAULT gen_random_uuid() NOT NULL, -- Key của bảng
	ngay_xoa timestamp NULL, -- Ngày xóa mềm
	ngay_tao timestamp DEFAULT now() NOT NULL, -- Ngày tạo
	nguoi_tao text NOT NULL, -- Người tạo
	ngay_cap_nhat timestamp DEFAULT now() NOT NULL, -- Ngày cập nhật
	nguoi_cap_nhat text NOT NULL, -- Người cập nhật
	ten_khac text NULL,
	su_dung bool DEFAULT true NULL,
	nguoi_xoa varchar(100) NULL, -- Người xóa mềm
	bi_xoa int2 DEFAULT 0 NULL, -- Bị xóa mềm
	CONSTRAINT dmc_quoc_gia_ma_quoc_gia_key UNIQUE (ma_quoc_gia),
	CONSTRAINT dmc_quoc_gia_pkey PRIMARY KEY (id)
);

CREATE TABLE dmc_quyen_loi (
	id uuid DEFAULT gen_random_uuid() NOT NULL,
	ma varchar(25) NOT NULL,
	ten varchar(255) NOT NULL,
	muc_huong numeric NULL,
	ghi_chu varchar(500) NULL,
	su_dung int2 DEFAULT 1 NULL,
	ngay_tao timestamp DEFAULT now() NOT NULL,
	nguoi_tao varchar(100) NOT NULL,
	ngay_cap_nhat timestamp DEFAULT now() NOT NULL,
	nguoi_cap_nhat varchar(100) NOT NULL,
	bi_xoa int2 DEFAULT 0 NOT NULL,
	ngay_xoa timestamp NULL,
	nguoi_xoa varchar(100) NULL,
	CONSTRAINT dmc_quyen_loi_pkey PRIMARY KEY (id)
);

CREATE TABLE dmc_tai_nan_thuong_tich (
	ma_tai_nan varchar(50) NOT NULL,
	ten_tai_nan varchar(255) NOT NULL,
	ma_gui_bhxh varchar(50) NOT NULL,
	su_dung bool DEFAULT true NOT NULL,
	id uuid DEFAULT gen_random_uuid() NOT NULL, -- Key của bảng
	ngay_tao timestamp DEFAULT now() NOT NULL, -- Ngày tạo
	nguoi_tao varchar(100) DEFAULT 'system'::character varying NOT NULL, -- Người tạo
	ngay_cap_nhat timestamp DEFAULT now() NOT NULL, -- Ngày cập nhật
	nguoi_cap_nhat varchar(100) DEFAULT 'system'::character varying NOT NULL, -- Người cập nhật
	bi_xoa int2 DEFAULT 0 NULL, -- Bị xóa mềm
	ngay_xoa timestamp NULL, -- Ngày xóa mềm
	nguoi_xoa varchar(100) NULL, -- Người xóa mềm
	CONSTRAINT dmc_tai_nan_thuong_tich_ma_tai_nan_key UNIQUE (ma_tai_nan),
	CONSTRAINT dmc_tai_nan_thuong_tich_pkey PRIMARY KEY (id)
);

CREATE TABLE dmc_thuocsd_icd (
	thuoc_vat_tu_id int8 NULL,
	icd_id int4 NULL,
	chong_chi_dinh_id int4 NULL,
	ghi_chu varchar NULL,
	su_dung bool DEFAULT true NULL,
	id uuid DEFAULT gen_random_uuid() NOT NULL, -- Key của bảng
	ngay_tao timestamp DEFAULT now() NOT NULL, -- Ngày tạo
	nguoi_tao varchar(100) DEFAULT 'system'::character varying NOT NULL, -- Người tạo
	ngay_cap_nhat timestamp DEFAULT now() NOT NULL, -- Ngày cập nhật
	nguoi_cap_nhat varchar(100) DEFAULT 'system'::character varying NOT NULL, -- Người cập nhật
	bi_xoa int2 DEFAULT 0 NULL, -- Bị xóa mềm
	ngay_xoa timestamp NULL, -- Ngày xóa mềm
	nguoi_xoa varchar(100) NULL, -- Người xóa mềm
	ma_icd varchar NULL,
	CONSTRAINT dmc_thuocsd_icd_pkey PRIMARY KEY (id)
);

CREATE TABLE dmc_thuocsd_icd_temp (
	id uuid DEFAULT gen_random_uuid() NOT NULL,
	uid uuid NULL,
	request_id text NULL,
	lan_import int8 NULL,
	loai int2 NULL,
	thuoc_vat_tu_id int8 NULL,
	icd_id int4 NULL,
	chong_chi_dinh_id int4 NULL,
	ghi_chu varchar NULL,
	su_dung bool DEFAULT true NULL,
	loi varchar NULL,
	trang_thai int2 DEFAULT 1 NULL,
	ngay_tao timestamp DEFAULT now() NULL,
	ma_icd varchar NULL,
	CONSTRAINT dmc_thuocsd_icd_temp_pkey PRIMARY KEY (id)
);

CREATE TABLE dmc_thuocsd_tuoi_temp (
	id uuid DEFAULT gen_random_uuid() NOT NULL,
	request_id varchar(100) NOT NULL,
	uid uuid NOT NULL,
	lan_import int8 DEFAULT 1 NOT NULL,
	loai int2 DEFAULT 1 NOT NULL,
	thuoc_vat_tu_id int8 NULL,
	tuoi_tu int4 NULL,
	dvt_tu_id uuid NULL,
	tuoi_den int4 NULL,
	dvt_den_id uuid NULL,
	tinhtoan varchar(50) NULL,
	bhyt_tt bool NULL,
	canhbao varchar(500) NULL,
	ghichu varchar(1000) NULL,
	su_dung bool DEFAULT true NULL,
	trang_thai int2 DEFAULT 1 NOT NULL,
	loi varchar(2000) NULL,
	ngay_tao timestamp DEFAULT now() NOT NULL,
	CONSTRAINT dmc_thuocsd_tuoi_temp_pkey PRIMARY KEY (id)
);

CREATE TABLE dmc_tien_su_benh_khao_sat (
	id uuid DEFAULT gen_random_uuid() NOT NULL,
	nhom varchar(25) NULL,
	loai varchar(25) NOT NULL,
	ma varchar(25) NOT NULL,
	ten varchar(255) NOT NULL,
	ngay_tao timestamp DEFAULT now() NULL,
	nguoi_tao varchar(50) NULL,
	ngay_cap_nhat timestamp DEFAULT now() NULL,
	nguoi_cap_nhat varchar(50) NULL,
	bi_xoa int2 DEFAULT 0 NOT NULL,
	ngay_xoa timestamp NULL,
	nguoi_xoa varchar(50) NULL,
	stt int4 NULL,
	CONSTRAINT dmc_tien_su_benh_khao_sat_pkey PRIMARY KEY (id)
);

CREATE TABLE dmc_trang_thai_dieu_tri (
	ma varchar(20) NOT NULL,
	ten varchar(100) NOT NULL,
	id uuid DEFAULT gen_random_uuid() NOT NULL, -- Key của bảng
	ngay_tao timestamp DEFAULT now() NOT NULL, -- Ngày tạo
	nguoi_tao varchar(100) DEFAULT 'system'::character varying NOT NULL, -- Người tạo
	ngay_cap_nhat timestamp DEFAULT now() NOT NULL, -- Ngày cập nhật
	nguoi_cap_nhat varchar(100) DEFAULT 'system'::character varying NOT NULL, -- Người cập nhật
	bi_xoa int2 DEFAULT 0 NULL, -- Bị xóa mềm
	ngay_xoa timestamp NULL, -- Ngày xóa mềm
	nguoi_xoa varchar(100) NULL, -- Người xóa mềm
	su_dung bool NULL,
	CONSTRAINT dmc_trang_thai_dieu_tri_pkey PRIMARY KEY (id)
);

CREATE TABLE dmc_trang_thai_don_thuoc (
	id uuid DEFAULT gen_random_uuid() NOT NULL,
	ma varchar NOT NULL,
	ten varchar NOT NULL,
	bi_xoa int2 DEFAULT 0 NOT NULL,
	ngay_tao timestamp DEFAULT CURRENT_TIMESTAMP NOT NULL,
	ngay_cap_nhat timestamp DEFAULT CURRENT_TIMESTAMP NOT NULL,
	nguoi_tao varchar(100) NOT NULL,
	nguoi_cap_nhat varchar(100) NULL,
	ngay_xoa timestamp NULL,
	nguoi_xoa varchar(50) NULL,
	CONSTRAINT pk_dmc_trang_thai_don_thuoc PRIMARY KEY (id)
);

CREATE TABLE dmc_trang_thai_don_thuoc_nha_thuoc (
	id uuid DEFAULT gen_random_uuid() NOT NULL,
	ma varchar NOT NULL,
	ten varchar NOT NULL,
	bi_xoa int2 DEFAULT 0 NOT NULL,
	ngay_tao timestamp DEFAULT CURRENT_TIMESTAMP NOT NULL,
	ngay_cap_nhat timestamp DEFAULT CURRENT_TIMESTAMP NOT NULL,
	nguoi_tao varchar(100) NOT NULL,
	nguoi_cap_nhat varchar(100) NULL,
	ngay_xoa timestamp NULL,
	nguoi_xoa varchar(50) NULL,
	CONSTRAINT dmc_trang_thai_don_thuoc_nha_thuoc_unique UNIQUE (ma),
	CONSTRAINT pk_dmc_trang_thai_don_thuoc_nha_thuoc PRIMARY KEY (id)
);

CREATE TABLE dmc_trang_thai_hop_dong_ksk (
	ma varchar NOT NULL, -- Mã trạng thái KSK
	ten varchar NOT NULL, -- Tên trạng thái KSK
	ten_khong_dau varchar NULL, -- Tên không dấu
	stt int4 NULL, -- Số thứ tự
	su_dung bool DEFAULT true NULL, -- Sử dụng
	id uuid DEFAULT gen_random_uuid() NOT NULL, -- Key của bảng
	ngay_tao timestamp DEFAULT now() NOT NULL, -- Ngày tạo
	nguoi_tao varchar DEFAULT 'system'::character varying NOT NULL, -- Người tạo
	ngay_cap_nhat timestamp DEFAULT now() NOT NULL, -- Ngày cập nhật
	nguoi_cap_nhat varchar DEFAULT 'system'::character varying NOT NULL, -- Người cập nhật
	bi_xoa int2 DEFAULT 0 NULL, -- Bị xóa mềm
	ngay_xoa timestamp NULL, -- Ngày xóa mềm
	nguoi_xoa varchar NULL, -- Người xóa mềm
	CONSTRAINT dmc_trang_thai_hop_dong_ksk_ma_key UNIQUE (ma),
	CONSTRAINT dmc_trang_thai_hop_dong_ksk_pkey PRIMARY KEY (id)
);

CREATE TABLE dmc_trang_thai_kcb (
	ma varchar NOT NULL, -- Mã trạng thái
	ten varchar NOT NULL, -- Tên trạng thái
	su_dung bool DEFAULT true NULL, -- Sử dụng
	id uuid DEFAULT gen_random_uuid() NOT NULL, -- Key của bảng
	ngay_tao timestamp DEFAULT now() NOT NULL, -- Ngày tạo
	nguoi_tao varchar DEFAULT 'system'::character varying NOT NULL, -- Người tạo
	ngay_cap_nhat timestamp DEFAULT now() NOT NULL, -- Ngày cập nhật
	nguoi_cap_nhat varchar DEFAULT 'system'::character varying NOT NULL, -- Người cập nhật
	bi_xoa int2 DEFAULT 0 NULL, -- Bị xóa mềm
	ngay_xoa timestamp NULL, -- Ngày xóa mềm
	nguoi_xoa varchar NULL, -- Người xóa mềm
	CONSTRAINT dmc_trang_thai_kcb_ma_key UNIQUE (ma),
	CONSTRAINT dmc_trang_thai_kcb_pkey PRIMARY KEY (id)
);

CREATE TABLE dmc_trang_thai_ke_hoach (
	ma varchar(25) NOT NULL,
	ten varchar(255) NOT NULL,
	su_dung int2 NOT NULL,
	id uuid DEFAULT gen_random_uuid() NOT NULL, -- Key của bảng
	ngay_tao timestamp DEFAULT now() NOT NULL, -- Ngày tạo
	nguoi_tao varchar(100) DEFAULT 'system'::character varying NOT NULL, -- Người tạo
	ngay_cap_nhat timestamp DEFAULT now() NOT NULL, -- Ngày cập nhật
	nguoi_cap_nhat varchar(100) DEFAULT 'system'::character varying NOT NULL, -- Người cập nhật
	bi_xoa int2 DEFAULT 0 NULL, -- Bị xóa mềm
	ngay_xoa timestamp NULL, -- Ngày xóa mềm
	nguoi_xoa varchar(100) NULL, -- Người xóa mềm
	CONSTRAINT dmc_trang_thai_ke_hoach_pkey PRIMARY KEY (id)
);

CREATE TABLE dmc_trang_thai_ke_hoach_tong_hop (
	ma varchar(25) NOT NULL, -- mã
	ten varchar(255) NOT NULL, -- tên
	su_dung int2 DEFAULT 1 NOT NULL, -- su_dung
	id uuid DEFAULT gen_random_uuid() NOT NULL, -- Key của bảng
	ngay_tao timestamp DEFAULT now() NOT NULL, -- Ngày tạo
	nguoi_tao varchar(100) DEFAULT 'system'::character varying NOT NULL, -- Người tạo
	ngay_cap_nhat timestamp DEFAULT now() NOT NULL, -- Ngày cập nhật
	nguoi_cap_nhat varchar(100) DEFAULT 'system'::character varying NOT NULL, -- Người cập nhật
	bi_xoa int2 DEFAULT 0 NULL, -- Bị xóa mềm
	ngay_xoa timestamp NULL, -- Ngày xóa mềm
	nguoi_xoa varchar(100) NULL, -- Người xóa mềm
	CONSTRAINT dmc_trang_thai_ke_hoach_tong_hop_pkey PRIMARY KEY (id)
);

CREATE TABLE dmc_trang_thai_ky_so (
	ma int4 NOT NULL,
	ten varchar NULL,
	mo_ta text NULL,
	id uuid DEFAULT gen_random_uuid() NOT NULL,
	ngay_tao timestamp DEFAULT now() NOT NULL,
	nguoi_tao varchar DEFAULT 'system'::character varying NOT NULL,
	ngay_cap_nhat timestamp DEFAULT now() NOT NULL,
	nguoi_cap_nhat varchar DEFAULT 'system'::character varying NOT NULL,
	bi_xoa int2 DEFAULT 0 NULL,
	ngay_xoa timestamp NULL,
	nguoi_xoa varchar NULL,
	loai varchar(10) NULL,
	is_platform int2 DEFAULT 1 NULL,
	CONSTRAINT dmc_trang_thai_ky_so_pk_id PRIMARY KEY (id),
	CONSTRAINT dmc_trang_thai_ky_so_uk_ma UNIQUE (ma)
);

CREATE TABLE dmc_trang_thai_tiep_nhan (
	ma_trang_thai varchar NOT NULL,
	ten_trang_thai varchar NOT NULL,
	su_dung bool DEFAULT true NULL,
	id uuid DEFAULT gen_random_uuid() NOT NULL, -- Key của bảng
	ngay_xoa timestamp NULL, -- Ngày xóa mềm
	ngay_tao timestamp DEFAULT now() NOT NULL, -- Ngày tạo
	nguoi_tao text NOT NULL, -- Người tạo
	ngay_cap_nhat timestamp DEFAULT now() NOT NULL, -- Ngày cập nhật
	nguoi_cap_nhat text NOT NULL, -- Người cập nhật
	nguoi_xoa varchar(100) NULL, -- Người xóa mềm
	bi_xoa int2 DEFAULT 0 NULL, -- Bị xóa mềm
	CONSTRAINT dmc_trang_thai_tiep_nhan_ma_trang_thai_key UNIQUE (ma_trang_thai),
	CONSTRAINT dmc_trang_thai_tiep_nhan_pkey PRIMARY KEY (id)
);

CREATE TABLE dmc_trangthai (
	loai_id numeric(3) NULL,
	trangthai_id numeric(3) NULL,
	ten_trangthai varchar(4000) NULL,
	giatri_cu_bvtm numeric(5) NULL,
	ghichu varchar(200) NULL,
	id numeric(10) NOT NULL,
	sudung numeric(1) DEFAULT 0 NULL,
	CONSTRAINT dmc_trangthai_pkey PRIMARY KEY (id)
);

CREATE TABLE dmc_trinh_do_chuyen_mon (
	id uuid DEFAULT gen_random_uuid() NOT NULL, -- Key của bảng
	ma_trinh_do varchar NOT NULL, -- Mã trình độ
	ten_trinh_do varchar NOT NULL, -- Tên trình độ
	ten_goi_khac varchar NULL, -- Tên gọi khác
	ghi_chu text NULL, -- Ghi chú
	ten_khong_dau varchar NULL, -- Tên không dấu
	stt int2 NULL, -- Số thứ tự
	su_dung bool DEFAULT true NOT NULL, -- Sử dụng
	bi_xoa int2 DEFAULT 0 NOT NULL, -- Bị xóa mềm
	ngay_tao timestamp DEFAULT now() NOT NULL, -- Ngày tạo
	nguoi_tao varchar DEFAULT 'system'::character varying NOT NULL, -- Người tạo
	ngay_cap_nhat timestamp DEFAULT now() NOT NULL, -- Ngày cập nhật
	nguoi_cap_nhat varchar DEFAULT 'system'::character varying NOT NULL, -- Người cập nhật
	ngay_xoa timestamp NULL, -- Ngày xóa mềm
	nguoi_xoa varchar NULL, -- Người xóa mềm
	CONSTRAINT dmc_trinh_do_chuyen_mon_ma_trinh_do_key UNIQUE (ma_trinh_do),
	CONSTRAINT dmc_trinh_do_chuyen_mon_pkey PRIMARY KEY (id)
);

CREATE TABLE dmc_ttb_dv (
	ma_trang_thiet_bi uuid NOT NULL, -- Mã trang thiết bị
	ma_dich_vu uuid NOT NULL, -- Mã dịch vụ
	id uuid DEFAULT gen_random_uuid() NOT NULL, -- Key của bảng
	ngay_tao timestamp DEFAULT now() NOT NULL, -- Ngày tạo
	nguoi_tao varchar(100) DEFAULT 'system'::character varying NOT NULL, -- Người tạo
	ngay_cap_nhat timestamp DEFAULT now() NOT NULL, -- Ngày cập nhật
	nguoi_cap_nhat varchar(100) DEFAULT 'system'::character varying NOT NULL, -- Người cập nhật
	bi_xoa int2 DEFAULT 0 NULL, -- Bị xóa mềm
	ngay_xoa timestamp NULL, -- Ngày xóa mềm
	nguoi_xoa varchar(100) NULL, -- Người xóa mềm
	CONSTRAINT dmc_ttb_dv_pk_id PRIMARY KEY (id)
);

CREATE TABLE dmc_tuyen_benh_vien (
	ma_tuyen varchar(25) NOT NULL, -- Mã tuyến
	ten_tuyen varchar(255) NOT NULL, -- Tên tuyến
	ghi_chu varchar(255) NULL, -- Ghi chú 
	ten_khong_dau varchar(255) NULL, -- Tên không dấu
	stt int4 NULL, -- Số thứ tự hiển thị thông tin 
	su_dung bool DEFAULT true NULL, -- Sử dụng
	id uuid DEFAULT gen_random_uuid() NOT NULL, -- Key của bảng
	ngay_xoa timestamp NULL, -- Ngày xóa mềm
	ngay_tao timestamp DEFAULT now() NOT NULL, -- Ngày tạo
	nguoi_tao text NOT NULL, -- Người tạo
	ngay_cap_nhat timestamp DEFAULT now() NOT NULL, -- Ngày cập nhật
	nguoi_cap_nhat text NOT NULL, -- Người cập nhật
	nguoi_xoa varchar(100) NULL, -- Người xóa mềm
	bi_xoa int2 DEFAULT 0 NULL, -- Bị xóa mềm
	CONSTRAINT dmc_tuyen_benh_vien_ma_tuyen_key UNIQUE (ma_tuyen),
	CONSTRAINT dmc_tuyen_benh_vien_pkey PRIMARY KEY (id)
);

CREATE TABLE dmc_tuyen_kcb (
	ma_tuyen_kham varchar(25) NOT NULL,
	ten_tuyen_kham varchar(255) NOT NULL,
	is_trai_tuyen int2 NOT NULL, -- 1 = trái tuyến, 0 = đúng tuyến
	su_dung bool DEFAULT true NULL,
	id uuid DEFAULT gen_random_uuid() NOT NULL, -- Key của bảng
	ngay_xoa timestamp NULL, -- Ngày xóa mềm
	ngay_tao timestamp DEFAULT now() NOT NULL, -- Ngày tạo
	nguoi_tao text NOT NULL, -- Người tạo
	ngay_cap_nhat timestamp DEFAULT now() NOT NULL, -- Ngày cập nhật
	nguoi_cap_nhat text NOT NULL, -- Người cập nhật
	nguoi_xoa varchar(100) NULL, -- Người xóa mềm
	bi_xoa int2 DEFAULT 0 NULL, -- Bị xóa mềm
	muc_huong_ngoai_tru numeric NULL, -- Mức hưởng ngoại trú
	muc_huong_noi_tru numeric NULL, -- Mức hưởng nội trú
	CONSTRAINT dmc_tuyen_kcb_ma_tuyen_kham_key UNIQUE (ma_tuyen_kham),
	CONSTRAINT dmc_tuyen_kcb_pkey PRIMARY KEY (id)
);

CREATE TABLE dmc_ty_le_vat (
	id uuid DEFAULT gen_random_uuid() NOT NULL,
	ma varchar NULL,
	ten varchar NULL,
	ty_le_vat int4 NOT NULL,
	hieu_luc_tu date NULL,
	hieu_luc_den date NULL,
	su_dung bool NULL,
	ngay_tao date NULL,
	nguoi_tao int4 NULL,
	CONSTRAINT dmc_ty_le_vat_pkey PRIMARY KEY (id)
);

CREATE TABLE dmc_tyle_thanh_toan_dich_vu (
	id uuid DEFAULT gen_random_uuid() NOT NULL,
	ten_nhom_chi_phi varchar(255) NULL,
	ma_nhom_chi_phi varchar(25) NULL,
	ma varchar(25) NOT NULL,
	ten varchar(255) NOT NULL,
	ghi_chu varchar(255) NULL,
	tu_ngay date NULL,
	den_ngay date NULL,
	ngay_tao timestamp DEFAULT now() NOT NULL,
	nguoi_tao varchar(100) NOT NULL,
	ngay_cap_nhat timestamp DEFAULT now() NOT NULL,
	nguoi_cap_nhat varchar(100) NOT NULL,
	bi_xoa int2 DEFAULT 0 NOT NULL,
	ngay_xoa timestamp NULL,
	nguoi_xoa varchar(100) NULL,
	tyle numeric NULL,
	stt int4 NULL,
	so_tien numeric NULL,
	CONSTRAINT dmc_tyle_thanh_toan_dich_vu_pkey PRIMARY KEY (id)
);

CREATE TABLE dmc_ung_dung (
	ten varchar(100) NOT NULL, -- Tên ứng dụng
	ma varchar(100) NOT NULL, -- Mã ứng dụng; duy nhất với bản ghi chưa xóa
	mo_ta text NULL, -- Mô tả ứng dụng
	id uuid DEFAULT gen_random_uuid() NOT NULL, -- Khóa chính UUID của ứng dụng
	ngay_tao timestamp DEFAULT now() NOT NULL, -- Thời điểm tạo bản ghi
	nguoi_tao varchar(100) DEFAULT 'system'::character varying NOT NULL, -- Người tạo bản ghi
	ngay_cap_nhat timestamp DEFAULT now() NOT NULL, -- Thời điểm cập nhật gần nhất
	nguoi_cap_nhat varchar(100) DEFAULT 'system'::character varying NOT NULL, -- Người cập nhật gần nhất
	bi_xoa int2 DEFAULT 0 NULL, -- Bị xóa mềm
	ngay_xoa timestamp NULL, -- Thời điểm xóa mềm
	nguoi_xoa varchar(100) NULL, -- Người thực hiện xóa mềm
	url varchar NULL, -- Link truy cập ứng dụng
	CONSTRAINT dmc_ung_dung_pk_id PRIMARY KEY (id)
);

CREATE TABLE dmc_vai_tro_hoi_dong_ksk (
	ma_vai_tro varchar NOT NULL, -- Mã vai trò
	ten_vai_tro varchar NOT NULL, -- Tên vai trò
	ten_khong_dau varchar NULL, -- Tên không dấu
	stt int4 NULL, -- Số thứ tự
	su_dung bool DEFAULT true NULL, -- Sử dụng
	id uuid DEFAULT gen_random_uuid() NOT NULL, -- Key của bảng
	ngay_tao timestamp DEFAULT now() NOT NULL, -- Ngày tạo
	nguoi_tao varchar DEFAULT 'system'::character varying NOT NULL, -- Người tạo
	ngay_cap_nhat timestamp DEFAULT now() NOT NULL, -- Ngày cập nhật
	nguoi_cap_nhat varchar DEFAULT 'system'::character varying NOT NULL, -- Người cập nhật
	bi_xoa int2 DEFAULT 0 NULL, -- Bị xóa mềm
	ngay_xoa timestamp NULL, -- Ngày xóa mềm
	nguoi_xoa varchar NULL, -- Người xóa mềm
	CONSTRAINT dmc_vai_tro_hoi_dong_ksk_ma_vai_tro_key UNIQUE (ma_vai_tro),
	CONSTRAINT dmc_vai_tro_hoi_dong_ksk_pkey PRIMARY KEY (id)
);

CREATE TABLE dmc_vai_tro_kip_mo (
	ma_vai_tro_kip_mo varchar NULL,
	ten_vai_tro_kip_mo varchar NULL,
	su_dung bool NULL,
	id uuid DEFAULT gen_random_uuid() NOT NULL, -- Key của bảng
	ngay_tao timestamp DEFAULT now() NOT NULL, -- Ngày tạo
	nguoi_tao varchar DEFAULT 'system'::character varying NOT NULL, -- Người tạo
	ngay_cap_nhat timestamp DEFAULT now() NOT NULL, -- Ngày cập nhật
	nguoi_cap_nhat varchar DEFAULT 'system'::character varying NOT NULL, -- Người cập nhật
	bi_xoa int2 DEFAULT 0 NULL, -- Bị xóa mềm
	ngay_xoa timestamp NULL, -- Ngày xóa mềm
	nguoi_xoa varchar NULL, -- Người xóa mềm
	CONSTRAINT dmc_vai_tro_kip_mo_pkey PRIMARY KEY (id),
	CONSTRAINT dmc_vai_tro_kip_mo_ten_vai_tro_kip_mo_key UNIQUE (ten_vai_tro_kip_mo)
);

CREATE TABLE dmc_vat_tu_trang_thiet_bi (
	ma_trang_thiet_bi varchar(25) NOT NULL, -- Mã trang thiết bị
	ten_trang_thiet_bi varchar(255) NULL, -- Tên trang thiết bị
	ma_gui_bhxh varchar(25) NULL, -- Mã gửi BHXH
	ma_san_pham varchar(100) NULL, -- Chủng loại/ Mã sản phẩm
	so_luu_hanh varchar(255) NULL, -- Số lưu hành/ Giấy phép nhập
	don_vi_tinh varchar(225) NULL, -- Đơn vị tính
	tinh_nang_ky_thuat varchar(255) NULL, -- Tính năng kỹ thuật cơ bản
	khau_hao uuid NULL, -- Khấu hao
	loai_bao_hanh varchar(100) NULL, -- Loại bảo hành
	gioi_han_ca_chup int8 NULL, -- Giới hạn ca chụp
	ghi_chu varchar(255) NULL, -- Ghi chú
	loai_may uuid NULL, -- Loại máy
	loai_may_dat varchar(50) NULL, -- Loại máy đặt
	don_vi_dat_may uuid NULL, -- Đơn vị đặt máy
	khoa uuid NULL, -- Khoa
	phong uuid NULL, -- Phòng
	tg_thuc_hien varchar NULL, -- Thời gian thực hiện
	tong_so_ca int4 NULL, -- Tổng số ca
	su_dung bool NULL, -- Trạng thái sử dụng
	id uuid DEFAULT gen_random_uuid() NOT NULL, -- Key của bảng
	ngay_tao timestamp DEFAULT now() NOT NULL, -- Ngày tạo
	nguoi_tao varchar(100) DEFAULT 'system'::character varying NOT NULL, -- Người tạo
	ngay_cap_nhat timestamp DEFAULT now() NOT NULL, -- Ngày cập nhật
	nguoi_cap_nhat varchar(100) DEFAULT 'system'::character varying NOT NULL, -- Người cập nhật
	bi_xoa int2 DEFAULT 0 NULL, -- Bị xóa mềm
	ngay_xoa timestamp NULL, -- Ngày xóa mềm
	nguoi_xoa varchar(100) NULL, -- Người xóa mềm
	nuoc_san_xuat varchar(100) NULL, -- Nước sản xuất
	hang_san_xuat varchar(100) NULL, -- Hãng sản xuất
	phan_loai_thiet_bi varchar(255) NULL,
	thiet_bi_phuc_vu varchar NULL, -- Thiết  bị phục vụ theo
	thiet_bi_di_kem bool NULL, -- hiển thị là thiết bị phụ phục vụ xét nghiệm
	CONSTRAINT dmc_vat_tu_trang_thiet_bi_pk_id PRIMARY KEY (id)
);

CREATE TABLE dmc_xep_loai_ksk (
	ma_xep_loai_ksk varchar(25) NOT NULL, -- Mã xếp loại KSK
	ten_xep_loai_ksk varchar(255) NOT NULL, -- Tên xếp loại KSK
	ten_khong_dau varchar(255) NULL, -- Tên không dấu
	stt int4 NULL, -- Số thứ tự
	su_dung bool DEFAULT true NULL,
	id uuid DEFAULT gen_random_uuid() NOT NULL, -- Key của bảng
	ngay_tao timestamp DEFAULT now() NOT NULL, -- Ngày tạo
	nguoi_tao varchar(100) DEFAULT 'system'::character varying NOT NULL, -- Người tạo
	ngay_cap_nhat timestamp DEFAULT now() NOT NULL, -- Ngày cập nhật
	nguoi_cap_nhat varchar(100) DEFAULT 'system'::character varying NOT NULL, -- Người cập nhật
	bi_xoa int2 DEFAULT 0 NULL, -- Bị xóa mềm
	ngay_xoa timestamp NULL, -- Ngày xóa mềm
	nguoi_xoa varchar(100) NULL, -- Người xóa mềm
	ma_nhom varchar(25) NULL, -- Mã nhóm
	CONSTRAINT dmc_xep_loai_ksk_ma_xep_loai_ksk_key UNIQUE (ma_xep_loai_ksk),
	CONSTRAINT dmc_xep_loai_ksk_pkey PRIMARY KEY (id)
);

CREATE TABLE dmc_yeutorh (
	ma_yeu_to_rh varchar NULL,
	ten_yeu_to_rh varchar NULL,
	ten_khac varchar NULL,
	ten_khong_dau varchar NULL,
	stt varchar NULL,
	su_dung bool NULL,
	id uuid DEFAULT gen_random_uuid() NOT NULL, -- Key của bảng
	ngay_tao timestamp DEFAULT now() NOT NULL, -- Ngày tạo
	nguoi_tao varchar(100) DEFAULT 'system'::character varying NOT NULL, -- Người tạo
	ngay_cap_nhat timestamp DEFAULT now() NOT NULL, -- Ngày cập nhật
	nguoi_cap_nhat varchar(100) DEFAULT 'system'::character varying NOT NULL, -- Người cập nhật
	bi_xoa int2 DEFAULT 0 NULL, -- Bị xóa mềm
	ngay_xoa timestamp NULL, -- Ngày xóa mềm
	nguoi_xoa varchar(100) NULL, -- Người xóa mềm
	ma_cskcb varchar(100) NULL,
	CONSTRAINT dmc_yeutorh_pkey PRIMARY KEY (id)
);

CREATE TABLE don_vi_ksk (
	id uuid DEFAULT gen_random_uuid() NOT NULL,
	ma varchar(25) NOT NULL,
	ten varchar(255) NOT NULL,
	dia_chi varchar(500) NULL,
	so_dien_thoai varchar(10) NULL,
	email varchar(50) NULL,
	ma_so_thue varchar(25) NULL,
	giam_doc varchar(25) NULL,
	nguoi_lien_he varchar(25) NULL,
	sdt_lien_he varchar(10) NULL,
	hoat_dong int2 NULL,
	ma_cskcb varchar(10) NOT NULL,
	bi_xoa int2 DEFAULT 0 NOT NULL,
	ngay_tao timestamp DEFAULT CURRENT_TIMESTAMP NOT NULL,
	ngay_cap_nhat timestamp DEFAULT CURRENT_TIMESTAMP NOT NULL,
	nguoi_tao varchar(100) NULL,
	nguoi_cap_nhat varchar(100) NULL,
	ngay_xoa timestamp NULL,
	nguoi_xoa varchar(50) NULL,
	CONSTRAINT don_vi_ksk_pkey PRIMARY KEY (id)
);

CREATE TABLE duc_bao_cao_adr (
	baocaoadrid int8 DEFAULT nextval('tenant_bvcahn.duc_bao_cao_adr_id_seq'::regclass) NOT NULL,
	so_phieu varchar(50) NULL,
	nguoi_tao_id int4 NULL,
	noi_bao_cao varchar(255) NULL,
	ma_so_bao_cao_don_vi varchar(50) NULL,
	ma_so_bao_cao_trung_tam varchar(50) NULL,
	benh_nhan_id uuid NULL,
	tiep_nhan_id uuid NULL,
	ngay_xuat_hien_phan_ung timestamp NULL,
	can_nang varchar(50) NULL,
	phan_ung_sau_bao_lau varchar(255) NULL,
	mo_ta_bieu_hien_adr text NULL,
	cac_xet_nghiem text NULL,
	tien_su text NULL,
	cach_xu_tri text NULL,
	muc_do_tu_vong int4 DEFAULT 0 NULL,
	muc_do_de_doa_tinh_mang int4 DEFAULT 0 NULL,
	muc_do_nhap_vien int4 DEFAULT 0 NULL,
	muc_do_tan_tat_vinh_vien int4 DEFAULT 0 NULL,
	muc_do_di_tat_thai_nhi int4 DEFAULT 0 NULL,
	muc_do_khong_nghiem_trong int4 DEFAULT 0 NULL,
	ket_qua_tu_vong_adr int4 DEFAULT 0 NULL,
	ket_qua_tu_vong_khong_lq int4 DEFAULT 0 NULL,
	ket_qua_chua_hoi_phuc int4 DEFAULT 0 NULL,
	ket_qua_dang_hoi_phuc int4 DEFAULT 0 NULL,
	ket_qua_hoi_phuc_co_dc int4 DEFAULT 0 NULL,
	ket_qua_hoi_phuc_khong_dc int4 DEFAULT 0 NULL,
	ket_qua_khong_ro int4 DEFAULT 0 NULL,
	danh_gia_moi_lien_quan int4 NULL,
	danh_gia_moi_lien_quan_khac varchar(255) NULL,
	tham_dinh_thang_who int4 NULL,
	tham_dinh_thang_naranjo int4 NULL,
	tham_dinh_thang_khac int4 NULL,
	tham_dinh_thang_khac_ten varchar(255) NULL,
	binh_luan_can_bo_y_te text NULL,
	nguoi_bao_cao_ho_ten varchar(100) NULL,
	nguoi_bao_cao_nghe_nghiep varchar(100) NULL,
	nguoi_bao_cao_dien_thoai varchar(50) NULL,
	nguoi_bao_cao_email varchar(100) NULL,
	nguoi_bao_cao_chu_ky varchar(100) NULL,
	dang_bao_cao int4 NULL,
	ngay_bao_cao date NULL,
	di_gui_xac_nhan_don_vi int4 DEFAULT 0 NULL,
	di_phan_loai_thuoc_moi int4 DEFAULT 0 NULL,
	di_phan_loai_thuoc_cu int4 DEFAULT 0 NULL,
	di_phan_loai_nghiem_trong int4 DEFAULT 0 NULL,
	di_phan_loai_khong_nt int4 DEFAULT 0 NULL,
	di_co_trong_y_van int4 DEFAULT 0 NULL,
	di_nhap_csdl_quoc_gia int4 DEFAULT 0 NULL,
	di_nhap_vigiflow int4 DEFAULT 0 NULL,
	di_muc_de_doa_tu_vong int4 DEFAULT 0 NULL,
	di_muc_nhap_vien int4 DEFAULT 0 NULL,
	di_muc_gay_di_tat int4 DEFAULT 0 NULL,
	di_muc_lam_dung_thuoc int4 DEFAULT 0 NULL,
	di_gui_hoi_dong_tham_dinh int4 DEFAULT 0 NULL,
	di_ngay_gui_hoi_dong date NULL,
	di_gui_umc int4 DEFAULT 0 NULL,
	di_ngay_gui_umc date NULL,
	di_ket_qua_tham_dinh int4 NULL,
	di_ket_qua_tham_dinh_khac varchar(255) NULL,
	di_nguoi_quan_ly varchar(100) NULL,
	di_ngay_gui date NULL,
	di_chu_ky varchar(100) NULL,
	ma_cskcb varchar(50) NULL,
	bi_xoa int4 DEFAULT 0 NULL,
	ngay_tao timestamp DEFAULT now() NULL,
	nguoi_tao varchar(100) NULL,
	ngay_cap_nhat timestamp NULL,
	nguoi_cap_nhat varchar(100) NULL,
	id uuid DEFAULT gen_random_uuid() NOT NULL,
	ngay_xoa date NULL,
	nguoi_xoa varchar NULL,
	di_ket_qua_tham_dinh_chac_chan int4 NULL,
	di_ket_qua_tham_dinh_co_kha_nang int4 NULL,
	di_ket_qua_tham_dinh_co_the int4 NULL,
	di_ket_qua_tham_dinh_khong_chac_chan int4 NULL,
	di_ket_qua_tham_dinh_chua_phan_loai int4 NULL,
	di_ket_qua_tham_dinh_khong_the_phan_loai int4 NULL,
	CONSTRAINT duc_bao_cao_adr_pkey PRIMARY KEY (baocaoadrid)
);

CREATE TABLE duc_bao_cao_adr_ct (
	baocaoadrctid int8 DEFAULT nextval('tenant_bvcahn.duc_bao_cao_adr_ct_id_seq'::regclass) NOT NULL,
	bao_cao_adr_id int8 NOT NULL,
	loai_thuoc int2 NOT NULL,
	stt int2 NULL,
	thuocvattuid numeric NOT NULL,
	so_lo varchar(255) NULL,
	lieu_mot_lan varchar(255) NULL,
	so_lan_trong_ngay varchar(255) NULL,
	ngay_bat_dau date NULL,
	ngay_ket_thuc date NULL,
	ly_do_dung varchar(255) NULL,
	mt4_co int2 DEFAULT 0 NULL,
	mt4_khong int2 DEFAULT 0 NULL,
	mt4_khong_ngung int2 DEFAULT 0 NULL,
	mt4_khong_thong_tin int2 DEFAULT 0 NULL,
	mt5_co int2 DEFAULT 0 NULL,
	mt5_khong int2 DEFAULT 0 NULL,
	mt5_khong_tai_su_dung int2 DEFAULT 0 NULL,
	mt5_khong_thong_tin int2 DEFAULT 0 NULL,
	ngay_tao timestamp DEFAULT now() NULL,
	nguoi_tao varchar(200) NULL,
	id uuid DEFAULT gen_random_uuid() NOT NULL,
	ngay_xoa date NULL,
	bi_xoa int2 DEFAULT 0 NULL,
	CONSTRAINT duc_bao_cao_adr_ct_id_key UNIQUE (id),
	CONSTRAINT duc_bao_cao_adr_ct_pkey PRIMARY KEY (baocaoadrctid)
);

CREATE TABLE duc_bc_khangsinh_mau (
	id uuid DEFAULT gen_random_uuid() NOT NULL,
	stt_hoat_chat int4 NULL,
	ten_hoat_chat varchar(500) NULL,
	ma_atc varchar(50) NULL,
	stt_biet_duoc varchar(20) NULL,
	nong_do_ham_luong varchar(500) NULL,
	don_vi_dong_goi varchar(200) NULL,
	duong_dung varchar(200) NULL,
	is_default bool DEFAULT true NULL,
	ten_biet_duoc varchar(1000) NULL,
	nuoc_san_xuat varchar(500) NULL,
	so_luong numeric(18, 2) NULL,
	don_gia numeric(18, 2) NULL,
	thanh_tien numeric(18, 2) NULL,
	created_date timestamp DEFAULT now() NULL,
	CONSTRAINT duc_bc_khangsinh_mau_pkey PRIMARY KEY (id)
);

CREATE TABLE duc_cap_gia_don_gia (
	ma_doi_tuong varchar NOT NULL,
	don_gia_ref varchar NOT NULL, -- Đơn giá mapping tương ứng với cặp giá
	su_dung bool DEFAULT true NULL,
	ghi_chu varchar NULL,
	id uuid DEFAULT gen_random_uuid() NOT NULL, -- Key của bảng
	ngay_tao timestamp DEFAULT now() NOT NULL, -- Ngày tạo
	nguoi_tao varchar(100) DEFAULT 'system'::character varying NOT NULL, -- Người tạo
	ngay_cap_nhat timestamp DEFAULT now() NOT NULL, -- Ngày cập nhật
	nguoi_cap_nhat varchar(100) DEFAULT 'system'::character varying NOT NULL, -- Người cập nhật
	bi_xoa int2 DEFAULT 0 NULL, -- Bị xóa mềm
	ngay_xoa timestamp NULL, -- Ngày xóa mềm
	nguoi_xoa varchar(100) NULL, -- Người xóa mềm
	CONSTRAINT duc_cap_gia_don_gia_pk_id PRIMARY KEY (id)
);

CREATE TABLE duc_dauthau (
	dauthauid numeric(10) NOT NULL,
	trangthai numeric(10) NULL,
	ngaybd timestamp NULL,
	ngaykt timestamp NULL,
	nguoibd varchar(100) NULL,
	nguoikt varchar(100) NULL,
	"version" timestamp NULL,
	sync_flag numeric(1) NULL,
	update_flag numeric(1) NULL,
	nguoithuchien varchar(100) NULL,
	ngaythuchien timestamp NULL,
	csytid int8 NULL,
	mathau varchar(200) NULL,
	loaithau numeric(22) DEFAULT 1 NULL,
	ngayquyetdinh timestamp NULL,
	ten varchar(200) NULL,
	ngaycongbo varchar(100) NULL,
	mahethong varchar(50) NULL,
	khoaid numeric(22) NULL,
	phongid numeric(22) NULL,
	nguoithuchienid numeric(22) NULL,
	loai numeric(1) NULL,
	ngayravien timestamp DEFAULT now() NULL,
	ghichu varchar(2000) NULL,
	hinhthucthauid int4 NULL,
	g_nguoithuchienid uuid NULL,
	dauthaumapid uuid NULL,
	id uuid DEFAULT gen_random_uuid() NULL,
	khoa numeric(1) DEFAULT 0 NULL,
	loaidonvibanhanh varchar NULL, -- Loại đơn vị ban hành:¶1: Trung tâm mua sắm tập chung¶2: Tỉnh, thành phố¶3: Cơ sở khám chữa bệnh
	CONSTRAINT duc_dauthau_pkey PRIMARY KEY (dauthauid)
);

CREATE TABLE duc_dauthau_temp (
	dauthauid numeric(10) NOT NULL,
	trangthai numeric(10) NULL,
	ngaybd timestamp NULL,
	ngaykt timestamp NULL,
	nguoibd varchar(100) NULL,
	nguoikt varchar(100) NULL,
	"version" timestamp NULL,
	sync_flag numeric(1) NULL,
	update_flag numeric(1) NULL,
	nguoithuchien varchar(100) NULL,
	ngaythuchien timestamp NULL,
	csytid int8 NULL,
	mathau varchar(200) NULL,
	loaithau numeric(22) DEFAULT 1 NULL,
	ngayquyetdinh timestamp NULL,
	ten varchar(200) NULL,
	ngaycongbo varchar(100) NULL,
	mahethong varchar(50) NULL,
	khoaid numeric(22) NULL,
	phongid numeric(22) NULL,
	nguoithuchienid numeric(22) NULL,
	loai numeric(1) NULL,
	ngayravien timestamp DEFAULT now() NULL,
	ghichu varchar(2000) NULL,
	hinhthucthauid int4 NULL,
	g_nguoithuchienid uuid NULL,
	dauthaumapid uuid NULL,
	CONSTRAINT duc_dauthau_temp_pkey PRIMARY KEY (dauthauid)
);

CREATE TABLE duc_dauthauct (
	dauthauctid numeric(10) NOT NULL,
	kyid numeric(10) NULL,
	dauthauid numeric(10) NULL,
	thuocvattuid numeric(10) NULL,
	giadauthau numeric(15, 5) NULL,
	sldauthau numeric(15, 5) NULL,
	slthucnhap numeric(15, 5) NULL,
	"version" timestamp NULL,
	sync_flag numeric(1) NULL,
	update_flag numeric(1) NULL,
	nguoithuchien varchar(100) NULL,
	ngaythuchien timestamp NULL,
	csytid int8 NULL,
	goithau varchar(50) NULL,
	manhomthau varchar(50) NULL,
	sttdauthau varchar(50) NULL,
	sodangky varchar(500) NULL,
	sogoithau varchar(50) NULL,
	gianhap numeric(18, 5) NULL,
	khoa numeric(1) DEFAULT 0 NULL,
	hopdongdtid numeric(22) NULL,
	sttsudung numeric(22) NULL,
	tenmoithau varchar(200) NULL,
	tentrungthau varchar(200) NULL,
	quycach varchar(150) NULL,
	mahieuvattu varchar(150) NULL,
	hamluong varchar(500) NULL,
	taikhoan varchar(500) NULL,
	sohopdong varchar(500) NULL,
	sldieuchinh numeric(15, 2) NULL,
	tenbhyt varchar(1000) NULL,
	vat numeric(3) NULL,
	giabhyt numeric(15, 5) NULL,
	giadichvu numeric(15, 5) NULL,
	gianhandan numeric(15, 5) NULL,
	ghichu varchar(2000) NULL,
	solansudungtvt numeric(22) NULL,
	ngaykthl timestamp NULL,
	ngaybdhl timestamp NULL,
	thanhtien numeric(15, 5) NULL,
	tyle_qdthau varchar(100) NULL,
	dvt_thau varchar(100) NULL,
	masanpham varchar(200) NULL,
	vatxuat numeric(22) NULL,
	tylebhyt numeric(22) NULL,
	mamoithau varchar(200) NULL,
	quy_cach varchar(500) NULL,
	maso_byt varchar(500) NULL,
	ten_byt varchar(500) NULL,
	sldieuchinhgiam numeric(22) NULL,
	sldcgiambv numeric(22) NULL,
	sldieuchinhtang numeric(22) NULL,
	sldieuchinh20 numeric(22) NULL,
	sldctangbv numeric(22) NULL,
	duongdungid numeric(22) NULL,
	donvi_qdthau varchar(300) NULL,
	ngayravien timestamp DEFAULT now() NULL,
	giakehoach numeric(18, 5) NULL,
	thaughep varchar(500) NULL,
	mahoatchat varchar(300) NULL,
	soluong_cs2 numeric(15, 5) NULL,
	soluong_cs1 numeric(15, 5) NULL,
	soqd_pbdc varchar(500) NULL,
	ngayqd_pbdc timestamp NULL,
	nhacungcapid numeric NULL,
	donvitinhid numeric NULL,
	hangsanxuatid numeric NULL,
	nuocsanxuatid varchar NULL,
	trangthai numeric NULL,
	nguoikt text NULL,
	ngaykt timestamp NULL,
	mathuocbv varchar(200) NULL,
	nguonchuongtrinhid numeric NULL,
	bi_xoa int2 NULL,
	ngay_xoa timestamp NULL,
	nguoi_xoa varchar(50) NULL,
	id uuid DEFAULT gen_random_uuid() NULL,
	mathau_byt varchar NULL,
	CONSTRAINT duc_dauthauct_pkey PRIMARY KEY (dauthauctid)
);

CREATE TABLE duc_dauthauct_temp (
	id uuid DEFAULT gen_random_uuid() NOT NULL,
	mathuoc varchar NULL,
	tenthuoc varchar NULL,
	mahoatchat varchar NULL,
	tenhoatchat varchar NULL,
	donvitinh varchar NULL,
	sodangky varchar NULL,
	soluong numeric NULL,
	dongia numeric NULL,
	soluongdanhap numeric NULL,
	sogoithau varchar NULL,
	dauthauid numeric NULL,
	lanimport int4 NULL,
	trangthai int4 NULL,
	loi varchar NULL,
	"type" int4 NULL,
	machuongtrinh varchar NULL,
	updated_at timestamp DEFAULT now() NULL,
	tenchuongtrinh varchar NULL,
	mamanhomthau varchar NULL,
	manhomthau varchar NULL,
	magoithau varchar NULL,
	goithau varchar NULL,
	donvitinhid int4 NULL,
	dauthaumapid uuid NULL,
	nhacungcapid numeric NULL,
	nhacungcap varchar NULL,
	ngaybdhl timestamp NULL,
	ngaykthl timestamp NULL,
	mathau_byt varchar NULL,
	CONSTRAINT duc_dauthauct_temp_pkey PRIMARY KEY (id)
);

CREATE TABLE duc_dinhmuc_tuongduong (
	dinhmuc_tuongduongid numeric(22) NOT NULL,
	nhomtvt_tuongduongid numeric(22) NULL,
	khoid numeric(22) NULL,
	dinhmuc numeric(22) NULL,
	ngaytao timestamp DEFAULT now() NULL,
	nguoitao varchar(200) NULL,
	ngaybanhanh timestamp NULL,
	nguoibanhanh varchar(200) NULL,
	csytid int8 NULL,
	so_quyet_dinh varchar NULL,
	nam_ap_dung int4 NULL,
	nguoi_ky varchar NULL,
	CONSTRAINT duc_dinhmuc_tuongduong_pkey PRIMARY KEY (dinhmuc_tuongduongid)
);

CREATE TABLE duc_donggoi (
	donggoiid numeric(22) NOT NULL,
	soluong float8 NULL,
	donvitinhid numeric(10) NULL,
	donvitinhid_qd numeric(10) NULL,
	"version" timestamp NULL,
	sync_flag numeric(1) NULL,
	update_flag numeric(1) NULL,
	csytid int8 NULL,
	ngayravien timestamp DEFAULT now() NULL,
	CONSTRAINT duc_donggoi_pkey PRIMARY KEY (donggoiid)
);

CREATE TABLE duc_donvitinh (
	ma_dvt varchar NOT NULL,
	ten_dvt varchar NOT NULL,
	ten_tieng_anh varchar NULL,
	ghi_chu text NULL,
	ten_khong_dau varchar NULL,
	stt int2 NULL,
	su_dung bool DEFAULT true NULL,
	id uuid DEFAULT gen_random_uuid() NOT NULL,
	deleted_at timestamp NULL,
	created_at timestamp DEFAULT now() NOT NULL,
	created_by text NOT NULL,
	updated_at timestamp DEFAULT now() NOT NULL,
	updated_by text NOT NULL,
	donvitinhid int4 NOT NULL,
	sync_flag int2 NULL,
	update_flag int2 NULL,
	csytid int8 NULL,
	tylequydoilit numeric NULL,
	ngayravien timestamp DEFAULT now() NULL,
	CONSTRAINT duc_donvitinh_id_key UNIQUE (id),
	CONSTRAINT duc_donvitinh_ma_dvt_key UNIQUE (ma_dvt),
	CONSTRAINT duc_donvitinh_pkey PRIMARY KEY (id)
);

CREATE TABLE duc_dvt_quydoi (
	ma_quy_doi varchar NOT NULL, -- Mã
	nguoi_tao varchar(100) DEFAULT '''system'''::character varying NOT NULL, -- Người tạo
	nguoi_cap_nhat varchar(100) DEFAULT '''system'''::character varying NOT NULL, -- Người cập nhật
	ngay_xoa timestamp NULL, -- Ngày xóa mềm
	nguoi_xoa varchar(100) NULL, -- Người xóa mềm
	id uuid DEFAULT gen_random_uuid() NOT NULL, -- Key của bảng
	ngay_tao timestamp DEFAULT now() NOT NULL, -- Ngày tạo
	bi_xoa int2 DEFAULT 0 NULL, -- Bị xóa mềm
	ngay_cap_nhat timestamp DEFAULT now() NOT NULL, -- Ngày cập nhật
	sl_quanly int4 NULL,
	sl_capphat int4 NULL,
	quy_cach_dong_goi text NULL,
	su_dung bool NULL,
	donvitinhid int4 NOT NULL,
	donvitinhid_qd int4 NOT NULL,
	tyle_qd float4 NOT NULL,
	"version" timestamp NULL,
	sync_flag int2 NULL,
	update_flag int2 NULL,
	csytid int8 NOT NULL,
	id_quydoi serial4 NOT NULL,
	ngayravien timestamp DEFAULT CURRENT_TIMESTAMP NULL,
	CONSTRAINT duc_dvt_quydoi_pkey PRIMARY KEY (id)
);

CREATE TABLE duc_hangsanxuat (
	hangsanxuatid serial4 NOT NULL,
	hangsanxuatcode varchar NOT NULL,
	hangsanxuatname varchar NOT NULL,
	nuocsanxuatname varchar NULL,
	nuocsanxuatid varchar NULL,
	ghichu text NULL,
	sudung bool DEFAULT true NULL,
	csytid int8 NULL,
	id uuid DEFAULT gen_random_uuid() NOT NULL, -- Key của bảng
	ngay_tao timestamp DEFAULT now() NOT NULL, -- Ngày tạo
	nguoi_tao varchar(100) DEFAULT 'system'::character varying NOT NULL, -- Người tạo
	ngay_cap_nhat timestamp DEFAULT now() NOT NULL, -- Ngày cập nhật
	nguoi_cap_nhat varchar(100) DEFAULT 'system'::character varying NOT NULL, -- Người cập nhật
	bi_xoa int2 DEFAULT 0 NULL, -- Bị xóa mềm
	ngay_xoa timestamp NULL, -- Ngày xóa mềm
	nguoi_xoa varchar(100) NULL, -- Người xóa mềm
	CONSTRAINT duc_hangsanxuat_pk_id PRIMARY KEY (id)
);

CREATE TABLE duc_hangsanxuat_temp (
	id uuid DEFAULT gen_random_uuid() NOT NULL,
	uid varchar(100) NOT NULL,
	hid numeric NULL,
	loai int2 DEFAULT 2 NOT NULL,
	stt int4 NULL,
	hangsanxuat_id uuid NULL,
	hangsanxuatcode varchar(255) NULL,
	hangsanxuatname varchar(500) NULL,
	nuocsanxuatid varchar(50) NULL,
	nuocsanxuatname varchar(255) NULL,
	ghi_chu text NULL,
	sudung bool DEFAULT true NOT NULL,
	trangthai int2 DEFAULT 1 NOT NULL,
	loi text NULL,
	ngay_tao timestamp DEFAULT now() NOT NULL,
	CONSTRAINT duc_hangsanxuat_temp_pk PRIMARY KEY (id)
);

CREATE TABLE duc_hinhthuc (
	hinhthucid int4 NOT NULL,
	ma varchar NULL,
	ten varchar NULL,
	ghi_chu varchar NULL,
	"version" timestamp NULL,
	sync_flag int2 NULL,
	update_flag int2 NULL,
	su_dung int2 DEFAULT 1 NULL,
	id uuid DEFAULT gen_random_uuid() NOT NULL,
	deleted_at timestamp NULL,
	created_at timestamp DEFAULT now() NOT NULL,
	created_by text NOT NULL,
	updated_at timestamp DEFAULT now() NOT NULL,
	updated_by text NOT NULL,
	CONSTRAINT duc_hinhthuc_hinhthucid_key UNIQUE (hinhthucid),
	CONSTRAINT duc_hinhthuc_pkey PRIMARY KEY (id)
);

CREATE TABLE duc_hmis_phieudutru (
	hmis_phieudutru_id numeric(22) NOT NULL,
	ma_dk_kcb_tuyen4 numeric(22) NULL,
	ma_dk_kcb_tuyen3 numeric(22) NULL,
	ten_kho_yc varchar(150) NULL,
	ten_kho_duyet_yc varchar(150) NULL,
	ma_phieu varchar(200) NULL,
	ngay_tao_phieu varchar(10) NULL,
	loai_phieu varchar(1) DEFAULT '1'::character varying NULL,
	thanh_tien numeric(22) NULL,
	ghi_chu varchar(500) NULL,
	ngay_tao timestamp DEFAULT now() NULL,
	nguoi_tao varchar(250) NULL,
	nhapxuatid numeric(22) NULL,
	trangthaiid numeric(22) NULL,
	csytid int8 NULL,
	ngayravien timestamp DEFAULT now() NULL,
	khoid numeric(22) NULL,
	CONSTRAINT duc_hmis_phieudutru_pkey PRIMARY KEY (hmis_phieudutru_id)
);

CREATE TABLE duc_hoatchat (
	hoatchatid numeric(10) NOT NULL,
	mahoatchat varchar(300) NOT NULL,
	tenhoatchat varchar(2048) NULL,
	ds_mabenh varchar(200) NULL,
	"version" timestamp NULL,
	sync_flag numeric(1) NULL,
	update_flag numeric(1) NULL,
	csytid int8 NULL,
	stt05 numeric(22) NULL,
	atc varchar(100) NULL,
	lydo_id numeric(10) NULL,
	ghichu varchar(4000) NULL,
	ngayravien timestamp DEFAULT now() NULL,
	so_quyetdinh text NULL,
	tenhoatchat_en text NULL,
	trangthai text NULL,
	ngay_quyetdinh timestamp NULL,
	duongdungid numeric NULL,
	bi_xoa bool DEFAULT false NULL, -- trang thai xoa
	nguoi_xoa varchar NULL, -- Người thao tác xóa
	ngay_xoa timestamp NULL, -- Ngày xóa
	id uuid DEFAULT gen_random_uuid() NOT NULL,
	CONSTRAINT duc_hoatchat_pkey PRIMARY KEY (id)
);

CREATE TABLE duc_hoatchat_temp (
	hoatchatid uuid DEFAULT gen_random_uuid() NOT NULL,
	mahoatchat varchar(300) NULL,
	tenhoatchat varchar(2048) NULL,
	csytid int8 NULL,
	stt05 numeric(22) NULL,
	ghichu varchar(4000) NULL,
	so_quyetdinh text NULL,
	tenhoatchat_en text NULL,
	trangthai text NULL,
	ngay_quyetdinh timestamp NULL,
	duongdungid numeric NULL,
	trangthaiimport numeric DEFAULT 1 NULL, -- 1: Mới, 2: Thành công, 3: Lỗi
	lanimport numeric NULL,
	maimport uuid NULL,
	loi _text NULL,
	uid varchar NULL, -- Thông tin user thao tác import
	hoatchatid_update numeric NULL,
	CONSTRAINT duc_hoatchat_temp_pkey PRIMARY KEY (hoatchatid)
);

CREATE TABLE duc_hoi_chan (
	id uuid DEFAULT gen_random_uuid() NOT NULL,
	thoi_gian date DEFAULT CURRENT_DATE NOT NULL,
	benh_nhan_id uuid NULL,
	di_ung text NULL,
	shock_nhiem_khuan bool DEFAULT false NULL,
	nhiem_khuan_huyet bool DEFAULT false NULL,
	vp_cong_dong bool DEFAULT false NULL,
	vp_benh_vien bool DEFAULT false NULL,
	vp_tho_may bool DEFAULT false NULL,
	viem_mang_nao_tktu bool DEFAULT false NULL,
	nk_tiet_nieu bool DEFAULT false NULL,
	nk_o_bung bool DEFAULT false NULL,
	nk_da_mo_mem bool DEFAULT false NULL,
	benh_mac_kem_khac text NULL,
	tinh_trang_lam_sang text NULL,
	nhiet_do numeric(5, 2) NULL,
	bach_cau numeric(12, 2) NULL,
	crp numeric(12, 2) NULL,
	pct numeric(12, 2) NULL,
	thong_tin_khac text NULL,
	thanh_thao_creatinin numeric(12, 2) NULL,
	loc_mau_hd bool DEFAULT false NULL,
	loc_mau_lien_tuc bool DEFAULT false NULL,
	thoi_gian_y_kien date NULL,
	thong_nhat_su_dung_ks bool DEFAULT false NULL,
	y_kien_khac text NULL,
	trang_thai numeric(1) DEFAULT 0 NULL,
	ngay_ky timestamp NULL,
	nguoi_ky varchar(100) NULL,
	created_at timestamp DEFAULT CURRENT_TIMESTAMP NOT NULL,
	created_by varchar(100) NULL,
	updated_at timestamp DEFAULT CURRENT_TIMESTAMP NULL,
	updated_by varchar(100) NULL,
	csytid int8 NULL,
	tuoi varchar NULL,
	ho_ten varchar NULL,
	gioi_tinh varchar NULL,
	can_nang varchar NULL,
	khoa varchar NULL,
	ma_benh_an varchar NULL,
	CONSTRAINT duc_hoi_chan_pkey PRIMARY KEY (id)
);

CREATE TABLE duc_hoi_chan_ct (
	id uuid DEFAULT gen_random_uuid() NOT NULL,
	hoi_chan_id uuid NOT NULL,
	hoatchatid numeric NOT NULL,
	lieu_dung varchar NULL,
	khoang_cach_dung varchar NULL,
	cach_dung varchar NULL,
	thoi_gian numeric NULL,
	created_at timestamp DEFAULT CURRENT_TIMESTAMP NOT NULL,
	created_by varchar(100) NULL,
	updated_at timestamp DEFAULT CURRENT_TIMESTAMP NULL,
	updated_by varchar(100) NULL,
	CONSTRAINT duc_hoi_chan_ct_pkey PRIMARY KEY (id)
);

CREATE TABLE duc_hoidong_kiemnhap (
	hoidong_kiemnhap_id int4 NOT NULL,
	ma varchar NULL,
	ngaylap timestamp NULL,
	khoaid varchar NULL,
	csytid int8 NULL,
	nhapxuatid int4 NULL,
	stt int4 NULL,
	hoten varchar NULL,
	chucdanh varchar NULL,
	hinhthucid int4 NULL,
	noidung varchar NULL,
	ngayravien timestamp NULL,
	trangthai_hoatdong bpchar(1) DEFAULT '1'::bpchar NULL,
	ten_khong_dau varchar NULL,
	id uuid DEFAULT gen_random_uuid() NOT NULL,
	ngay_xoa timestamp NULL,
	ngay_tao timestamp DEFAULT now() NOT NULL,
	nguoi_tao varchar(100) DEFAULT 'system'::character varying NOT NULL,
	ngay_cap_nhat timestamp DEFAULT now() NOT NULL,
	nguoi_cap_nhat varchar(100) DEFAULT 'system'::character varying NOT NULL,
	su_dung int2 DEFAULT 1 NULL,
	loainx int2 NULL,
	nguoi_xoa varchar(100) NULL,
	bi_xoa int2 DEFAULT 0 NULL,
	nam int4 NULL,
	CONSTRAINT duc_hoidong_kiemnhap_hoidong_kiemnhap_id_key UNIQUE (hoidong_kiemnhap_id),
	CONSTRAINT duc_hoidong_kiemnhap_pkey PRIMARY KEY (id)
);

CREATE TABLE duc_hoidong_kiemnhapct (
	hoidong_kiemnhapctid numeric(22) NOT NULL,
	hoidong_kiemnhap_id numeric(22) NULL,
	stt numeric(22) DEFAULT 1 NULL,
	chucdanh varchar(200) NULL,
	hoten varchar(200) NULL,
	csytid int8 NULL,
	ngayravien timestamp DEFAULT now() NULL,
	ma_nhan_vien varchar(50) NULL,
	vai_tro_id uuid NULL,
	CONSTRAINT duc_hoidong_kiemnhapct_pkey PRIMARY KEY (hoidong_kiemnhapctid)
);

CREATE TABLE duc_hopdongdt (
	hopdongdtid numeric(22) NOT NULL,
	nhacungcapid numeric(22) NULL,
	sohopdong varchar(50) NULL,
	ngayky timestamp NULL,
	ngayhieuluc timestamp NULL,
	ngayketthuc timestamp NULL,
	ghichu varchar(600) NULL,
	nguoithuchien varchar(300) NULL,
	ngaythuchien timestamp NULL,
	nguoicapnhat varchar(300) NULL,
	ngaycapnhat timestamp NULL,
	csytid int8 NULL,
	ngayravien timestamp DEFAULT now() NULL,
	CONSTRAINT duc_hopdongdt_pkey PRIMARY KEY (hopdongdtid)
);

CREATE TABLE duc_kho (
	id uuid DEFAULT gen_random_uuid() NOT NULL,
	macskcb varchar(25) NULL,
	khoid numeric(10) NOT NULL,
	khoaid numeric(10) NULL,
	trangthai numeric(10) NULL,
	loaikho numeric(10) NULL,
	makho varchar(30) NULL,
	tenkho varchar(300) NULL,
	mathukho numeric(10) NULL,
	ghichu varchar(400) NULL,
	"version" timestamp NULL,
	loaibutt numeric(2) DEFAULT 0 NULL,
	sync_flag numeric(1) NULL,
	update_flag numeric(1) NULL,
	doituongbn numeric(10) DEFAULT 0 NULL,
	phongchidinh varchar(1000) NULL,
	dskhobutt varchar(2000) NULL,
	khomachidinh varchar(100) NULL,
	dangxuly numeric(10) NULL,
	nguoithuchien varchar(300) NULL,
	ngaythuchien timestamp DEFAULT now() NULL,
	csytid int8 NULL,
	captronggio numeric(1) DEFAULT 0 NULL,
	ngaytao timestamp NULL,
	nguoitao varchar(300) NULL,
	dsloaitvt varchar(30) NULL,
	dieutringoaitru numeric(22) DEFAULT 0 NULL,
	mienphi numeric(1) DEFAULT 0 NULL,
	chucdanhchuky varchar(100) DEFAULT 'Truong'::character varying NULL,
	bantructiep numeric(22) DEFAULT 0 NULL,
	ycduyetduoclamsang numeric(1) DEFAULT 0 NULL,
	phongid numeric(10) NULL,
	maphieulinh varchar(50) NULL,
	maphieubu varchar(50) NULL,
	dsdoituongbn varchar(50) NULL,
	haophi numeric(22) DEFAULT 0 NULL,
	macsyt numeric(10) NULL,
	dsloaidieutri varchar(200) NULL,
	dsloaithuoc varchar(200) NULL,
	dacbiet numeric(1) NULL,
	phongluu varchar(2000) NULL,
	stt numeric(3) NULL,
	ngayravien timestamp DEFAULT now() NULL,
	dichvu numeric(2) NULL,
	tuyenduoi numeric(2) NULL,
	khovacxin numeric(1) NULL,
	boduyetkt numeric(1) NULL,
	chuyenkho numeric(2) NULL,
	tutrucbu numeric(1) NULL,
	thaughep numeric(1) NULL,
	khonhapncc numeric NULL,
	su_dung numeric DEFAULT 1 NOT NULL,
	bi_xoa numeric(1) DEFAULT 0 NOT NULL,
	nguoi_xoa varchar(255) NULL,
	ngay_xoa timestamp NULL,
	lskholk _numeric DEFAULT '{}'::numeric[] NOT NULL, -- Danh sách kho liên kết
	pqkhoa _uuid DEFAULT '{}'::uuid[] NULL, -- Danh sách phân quyền khoa. dm_khoa
	pqphong _uuid DEFAULT '{}'::uuid[] NULL, -- Danh sách phân quyền phòng. dm_phong
	pqthuocvattu _numeric DEFAULT '{}'::numeric[] NULL, -- Phân quyền thuốc vật tư cho kho. duc_thuocvattu
	pqloaidieutri _uuid DEFAULT '{}'::uuid[] NULL, -- Phân quyền loại điều trị. dm_loai_dieu_tri
	pqloaikedon _uuid DEFAULT '{}'::uuid[] NULL, -- Phân quyền loại kê đơn. dm_loai_ke_don
	pqdoituongbenhnhan _uuid DEFAULT '{}'::uuid[] NULL, -- Phân quyền đối tượng bệnh nhân. dm_doi_tuong_benh_nhan
	dia_chi varchar NULL,
	CONSTRAINT duc_kho_id_key UNIQUE (id),
	CONSTRAINT duc_kho_pkey PRIMARY KEY (khoid)
);

CREATE TABLE duc_kiemke (
	kiemkeid numeric(10) NOT NULL,
	trangthai numeric(10) NULL,
	ngaybd timestamp NULL,
	ngaykt timestamp NULL,
	nguoibd varchar(60) NULL,
	nguoikt varchar(60) NULL,
	khoid numeric(10) NULL,
	"version" timestamp NULL,
	sync_flag numeric(1) NULL,
	update_flag numeric(1) NULL,
	ngaythuchien timestamp NULL,
	csytid int8 NULL,
	nguoithuchien varchar(200) NULL,
	nguoithuchien_new varchar(200) NULL,
	hoidongid numeric(22) NULL,
	nguonctid numeric(22) NULL,
	loaithuoc numeric(22) NULL,
	ngayravien timestamp DEFAULT now() NULL,
	sophieu varchar NULL,
	nguoithuchienid uuid NULL,
	CONSTRAINT duc_kiemke_pkey PRIMARY KEY (kiemkeid)
);

CREATE TABLE duc_kiemkect (
	"version" timestamp NULL,
	sync_flag numeric(1) NULL,
	update_flag numeric(1) NULL,
	kiemkectid numeric(10) NOT NULL,
	kyid numeric(10) NULL,
	kiemkeid numeric(10) NULL,
	khoid numeric(10) NULL,
	tonkhoid numeric(10) NULL,
	thuocvattuid numeric(10) NULL,
	ngaythuchien timestamp NULL,
	csytid int8 NULL,
	slkhadung numeric(15, 3) NULL,
	nguoithuchien varchar(200) NULL,
	sltonkho numeric(15, 3) NULL,
	sldauky numeric(15, 3) NULL,
	slthucte numeric(15, 3) NULL,
	slhongvo numeric(15, 3) NULL,
	slchenh numeric(15, 3) NULL,
	dieuchinhdl numeric(22) DEFAULT 0 NULL,
	gianhap numeric(16, 3) NULL,
	solo varchar(50) NULL,
	hansudung timestamp NULL,
	xuatvat numeric(15, 2) NULL,
	xuatgiaban numeric(16, 3) NULL,
	giabhyt numeric(16, 3) NULL,
	gianhandan numeric(16, 3) NULL,
	giadichvu numeric(16, 3) NULL,
	giatranbhyt numeric(16, 3) DEFAULT 0 NULL,
	dauthauctid numeric(22) NULL,
	solansudung numeric(15, 3) NULL,
	solansdtoida numeric(15, 3) NULL,
	slmatphamchat numeric(15, 3) NULL,
	slchamluanchuyen numeric(15, 3) NULL,
	slkhongsudung numeric(15, 3) NULL,
	slnhap numeric(15, 3) NULL,
	slxuat numeric(15, 3) NULL,
	lydolech varchar(400) NULL,
	phuonganxuly varchar(400) NULL,
	ghichu varchar(400) NULL,
	ngayravien timestamp DEFAULT now() NULL,
	tylequydoi numeric NULL,
	CONSTRAINT duc_kiemkect_pkey PRIMARY KEY (kiemkectid)
);

CREATE TABLE duc_kiemkect_temp (
	id uuid DEFAULT gen_random_uuid() NOT NULL,
	mathuocbv varchar(255) NULL,
	mathuoc varchar(255) NULL,
	tenthuoc varchar(255) NULL,
	hoatchat varchar(255) NULL,
	hamluong varchar(255) NULL,
	nuocsanxuat varchar(255) NULL,
	tenhangsanxuat varchar(255) NULL,
	sodangky varchar(255) NULL,
	soquyetdinhthau varchar(255) NULL,
	nguonchuongtrinhid int8 NULL,
	tennguonchuongtrinh varchar(255) NULL,
	tendonviquanly varchar(255) NULL,
	soluong numeric NULL,
	solo varchar(255) NULL,
	hansudung varchar(255) NULL,
	soluongthucte numeric NULL,
	soluongchenhlech numeric NULL,
	tonkhoid numeric NULL,
	thuocvattuid numeric NULL,
	maphieu varchar(255) NULL,
	flag_updated bool DEFAULT false NULL, -- false là chưa cập nhật, mặc định số lượng thực tế  =null
	dauthauctid numeric NULL,
	dongia numeric NULL,
	dongiavat numeric NULL,
	dauthauid int8 NULL,
	tylequydoi varchar NULL,
	goithau varchar NULL,
	nhomthau varchar NULL,
	xuatvat numeric NULL,
	CONSTRAINT duc_kiemkect_temp_pkey PRIMARY KEY (id)
);

CREATE TABLE duc_kyduoc (
	kyid numeric(10) NOT NULL,
	trangthai numeric(10) NULL,
	kieudulieu numeric(10) NULL,
	ngaybd timestamp NULL,
	ngaykt timestamp NULL,
	nguoibd varchar(200) NULL,
	nguoikt varchar(200) NULL,
	"version" timestamp NULL,
	sync_flag numeric(1) NULL,
	update_flag numeric(1) NULL,
	nguoithuchien varchar(200) NULL,
	ngaythuchien timestamp NULL,
	csytid int8 NULL,
	machotsolieu varchar(150) NULL,
	loaikhoa numeric(22) DEFAULT 1 NULL,
	dskho varchar(2000) NULL,
	ngayravien timestamp DEFAULT now() NULL,
	CONSTRAINT duc_kyduoc_pkey PRIMARY KEY (kyid)
);

CREATE TABLE duc_loai_thau (
	loaithauid int4 NOT NULL,
	ma varchar NULL,
	ten varchar NULL,
	ghichu varchar NULL,
	csytid int4 NULL,
	ngayravien timestamp NULL,
	loaithau int4 NULL,
	su_dung int2 NULL,
	stt int4 NULL,
	don_vi_ban_hanh varchar NULL,
	id uuid DEFAULT gen_random_uuid() NOT NULL, -- Key của bảng
	ngay_tao timestamp DEFAULT now() NOT NULL, -- Ngày tạo
	nguoi_tao varchar(100) DEFAULT 'system'::character varying NOT NULL, -- Người tạo
	ngay_cap_nhat timestamp DEFAULT now() NOT NULL, -- Ngày cập nhật
	nguoi_cap_nhat varchar(100) DEFAULT 'system'::character varying NOT NULL, -- Người cập nhật
	bi_xoa int2 DEFAULT 0 NULL, -- Bị xóa mềm
	ngay_xoa timestamp NULL, -- Ngày xóa mềm
	nguoi_xoa varchar(100) NULL, -- Người xóa mềm
	CONSTRAINT duc_loai_thau_pkey PRIMARY KEY (id)
);

CREATE TABLE duc_loaiphieu (
	id numeric(11) NULL,
	ten varchar(510) NULL,
	loaiphieuid numeric(22) NULL,
	hinhthucid numeric(10) NULL,
	ma varchar(30) NULL,
	csytid int8 NULL
);

CREATE TABLE duc_loaituongtacthuoc (
	loaituongtacthuocid numeric(3) NULL,
	ten varchar(200) NULL,
	mucdo numeric(22) NULL,
	duongdananh varchar(180) NULL,
	maunen varchar(10) NULL,
	mauchu varchar(10) NULL,
	csytid int8 NULL,
	ngayravien timestamp DEFAULT now() NULL,
	code varchar NULL, -- Mã cấp độ
	mota varchar(2000) NULL, -- Mô tả
	sudung bool DEFAULT true NULL,
	bi_xoa int4 DEFAULT 0 NULL
);

CREATE TABLE duc_loaitvt (
	loaitvtid numeric(22) NOT NULL,
	ma varchar(50) NULL,
	ten varchar(250) NULL,
	csytid int8 NOT NULL,
	stt numeric(22) DEFAULT NULL::numeric NULL,
	loaixuatthuocid numeric(4) NULL,
	phieu_xuat varchar(200) NULL,
	phieu_hoantra varchar(200) NULL,
	nhomloaitvtid numeric(22) DEFAULT 7 NULL,
	ngayravien timestamp DEFAULT now() NULL,
	CONSTRAINT duc_loaitvt_pkey PRIMARY KEY (loaitvtid)
);

CREATE TABLE duc_loaixuatthuoc (
	loaixuatthuocid numeric(4) NOT NULL,
	ten varchar(100) NULL,
	giatri varchar(200) NULL,
	csytid int8 NULL,
	ngayravien timestamp DEFAULT now() NULL,
	CONSTRAINT duc_loaixuatthuoc_pkey PRIMARY KEY (loaixuatthuocid)
);

CREATE TABLE duc_log_dauthau (
	log_dauthauid numeric(10) NOT NULL,
	dauthauid numeric(10) NULL,
	trangthai numeric(10) NULL,
	ngaybd timestamp NULL,
	ngaykt timestamp NULL,
	nguoibd varchar(100) NULL,
	nguoikt varchar(100) NULL,
	"version" timestamp NULL,
	sync_flag numeric(1) NULL,
	update_flag numeric(1) NULL,
	nguoithuchien varchar(100) NULL,
	ngaythuchien timestamp NULL,
	csytid int8 NULL,
	mathau varchar(200) NULL,
	loaithau numeric(22) DEFAULT 1 NULL,
	ngayquyetdinh timestamp NULL,
	ten varchar(200) NULL,
	ngaycongbo varchar(100) NULL,
	mahethong varchar(50) NULL,
	khoaid numeric(22) NULL,
	phongid numeric(22) NULL,
	nguoithuchienid numeric(22) NULL,
	ngayravien timestamp DEFAULT now() NULL,
	CONSTRAINT duc_log_dauthau_pkey PRIMARY KEY (log_dauthauid)
);

CREATE TABLE duc_log_dauthauct (
	log_dauthauctid numeric(10) NOT NULL,
	log_dauthauid numeric(10) NULL,
	dauthauctid numeric(10) NULL,
	kyid numeric(10) NULL,
	dauthauid numeric(10) NULL,
	thuocvattuid numeric(10) NULL,
	giadauthau numeric(15, 5) NULL,
	sldauthau numeric(15, 5) NULL,
	nhacungcapid numeric(10) NULL,
	slthucnhap numeric(15, 5) NULL,
	"version" timestamp NULL,
	sync_flag numeric(1) NULL,
	update_flag numeric(1) NULL,
	nguoithuchien varchar(100) NULL,
	ngaythuchien timestamp NULL,
	csytid int8 NULL,
	goithau varchar(50) NULL,
	manhomthau varchar(50) NULL,
	sttdauthau varchar(50) NULL,
	sodangky varchar(500) NULL,
	sogoithau varchar(50) NULL,
	sttsudung numeric(22) DEFAULT 1 NULL,
	hopdongdtid numeric(22) NULL,
	sldieuchinh numeric(22) NULL,
	gianhap numeric(22) NULL,
	khoa numeric(22) NULL,
	vat numeric(3) NULL,
	giabhyt numeric(15, 5) NULL,
	giadichvu numeric(15, 5) NULL,
	gianhandan numeric(15, 5) NULL,
	ghichu varchar(2000) NULL,
	mamoithau varchar(300) NULL,
	sohopdong varchar(300) NULL,
	sldieuchinhgiam numeric(22) NULL,
	sldcgiambv numeric(22) NULL,
	sldieuchinhtang numeric(22) NULL,
	sldieuchinh20 numeric(22) NULL,
	sldctangbv numeric(22) NULL,
	tylebhyt varchar(300) NULL,
	ngaykthd timestamp NULL,
	ngaybdhd timestamp NULL,
	tenmoithau varchar(2000) NULL,
	tyle_qdthau varchar(100) NULL,
	donvi_qdthau varchar(300) NULL,
	ngayravien timestamp DEFAULT now() NULL,
	giakehoach numeric(18, 5) NULL,
	thaughep varchar(500) NULL,
	soluong_cs2 numeric(15, 5) NULL,
	soluong_cs1 numeric(15, 5) NULL,
	soqd_pbdc varchar(500) NULL,
	ngayqd_pbdc timestamp NULL,
	vtyt_ktc_id uuid NULL,
	CONSTRAINT duc_log_dauthauct_pkey PRIMARY KEY (log_dauthauctid)
);

CREATE TABLE duc_log_thuocvattu (
	thuocvattuid numeric(10) NULL,
	ma varchar(100) NULL,
	manhom varchar(100) NULL,
	kieu numeric(10) NULL,
	kieudulieu numeric(10) NULL,
	loai varchar(10) NULL,
	ten varchar(500) NULL,
	tenkhoahoc varchar(500) NULL,
	donvitinhid numeric(10) NULL,
	donggoi varchar(400) NULL,
	hangsanxuatid numeric(10) NULL,
	nuocsanxuatid varchar NULL,
	nongdo varchar(1000) NULL,
	lieuluong varchar(1000) NULL,
	hoatchat varchar(1000) NULL,
	dangdung varchar(200) NULL,
	chuy varchar(400) NULL,
	thutuinphieu numeric(10) NULL,
	gianhap numeric(15, 2) NULL,
	giaban numeric(15, 2) NULL,
	vatnhap numeric(15, 2) NULL,
	vatban numeric(15, 2) NULL,
	canhbaosoluong numeric(10) NULL,
	canhbaohsd numeric(1) NULL,
	thuocvattuid_cha numeric(10) NULL,
	huongdansudung varchar(500) NULL,
	soluongngay numeric(15, 2) NULL,
	solo varchar(50) NULL,
	sodangky varchar(250) NULL,
	tylehuhao numeric(3) NULL,
	nhombhyt varchar NULL,
	nhomtkbaocao varchar(15) NULL,
	bietduoc varchar(200) NULL,
	atc varchar(100) NULL,
	nhombc varchar(15) NULL,
	khongchuyendoituonghaophi numeric(1) NULL,
	luonchuyendoituonghaophi numeric(1) NULL,
	sync_flag numeric(1) NULL,
	update_flag numeric(1) NULL,
	sttthuoc numeric(5) NULL,
	giavienphi numeric(15, 2) NULL,
	tyleloinhuannhandan numeric(15, 2) NULL,
	giabhyt numeric(15, 2) NULL,
	tyleloinhuannuocngoai numeric(15, 2) NULL,
	nguoicapnhat numeric(10) NULL,
	ngaycapnhat timestamp NULL,
	tyleloinhuan numeric(15, 2) NULL,
	gianhandan numeric(15, 2) NULL,
	tyleloinhuanbhyt numeric(15, 2) NULL,
	gianuocngoai numeric(15, 2) NULL,
	giatranbhyt numeric(15, 2) NULL,
	thuockhangsinh numeric(1) NULL,
	mahoatchat varchar(30) NULL,
	tuongtacthuoc varchar(1642) NULL,
	dsphongthuchien varchar(800) NULL,
	benhvienapthau varchar(200) NULL,
	nhacungcapid numeric(10) NULL,
	khoa numeric(1) NULL,
	khongnhapmoi numeric(1) NULL,
	nhomquycheid varchar NULL,
	nhombaocaoid numeric(10) NULL,
	nhomduoclyid numeric(10) NULL,
	nhomtieuduoclyid numeric(10) NULL,
	nhomquanlyid varchar NULL,
	nhomnghiencuuid numeric(10) NULL,
	nhomabcvenid numeric(10) NULL,
	goithau varchar(50) NULL,
	namcungung varchar(15) NULL,
	chephamyhct numeric(1) NULL,
	vithuocyhct numeric(1) NULL,
	thuoctanduoc numeric(1) NULL,
	sttdauthau varchar(50) NULL,
	nguonchuongtrinhid numeric(10) NULL,
	tenbyt varchar(400) NULL,
	cholanhdaoduyet varchar(10) NULL,
	danhsttdungthuoc numeric(5) NULL,
	duongdungid numeric(10) NULL,
	ghichu varchar(200) NULL,
	nguoithuchien varchar(400) NULL,
	ngaythuchien timestamp NULL,
	csytid int8 NULL,
	tylebhyt numeric(15, 2) NULL,
	nhom_mabhyt_id numeric(10) NULL,
	bhyttt numeric(15, 2) NULL,
	khoanmucid varchar NULL,
	mabyt varchar(30) NULL,
	tylehuhao_tmp numeric(6, 2) NULL,
	sldauky_tmp numeric(15, 2) NULL,
	thuochoatchat varchar(3000) NULL,
	dv_lamtron numeric(10) NULL,
	ketrunghoatchat numeric(22) NULL,
	log_thuocvattuid numeric(22) NULL,
	stt05 varchar(50) NULL,
	ngayhlbhyt timestamp NULL,
	tylebhytcu numeric(15, 2) NULL,
	mathau varchar(500) NULL,
	manhomthau varchar(50) NULL,
	sogoithau varchar(50) NULL,
	tt_khoa varchar(200) NULL,
	lydokhoathuoc varchar(500) NULL,
	ngayravien timestamp DEFAULT now() NULL,
	dangbaocheid uuid NULL,
	phanloaiduoc int4 NULL,
	manhomduoc varchar NULL,
	loaiduocatc varchar NULL,
	quy_cach_dong_goi varchar NULL
);

CREATE TABLE duc_lydohuiphieu (
	lydohuyphieuid numeric(10) NOT NULL,
	tenlydohuyphieu text NOT NULL,
	csytid int8 NOT NULL,
	CONSTRAINT duc_lydohuiphieu_pkey PRIMARY KEY (lydohuyphieuid)
);

CREATE TABLE duc_lydohuyphieu (
	lydohuyphieuid numeric(22) NULL,
	ma varchar(30) NULL,
	ten varchar(150) NULL,
	csytid int8 NULL,
	loai numeric(22) DEFAULT 1 NULL,
	ngayravien timestamp DEFAULT now() NULL
);

CREATE TABLE duc_ngay_nghi_le (
	id numeric(10) NULL,
	ngay timestamp NULL,
	noidung varchar(2000) NULL,
	csytid int8 NULL,
	ngayravien timestamp DEFAULT now() NULL
);

CREATE TABLE duc_nguonchuongtrinh (
	nguonchuongtrinhid serial4 NOT NULL,
	ma varchar NOT NULL,
	ten varchar NOT NULL,
	csytid int8 NULL,
	stt int8 NULL,
	loaimiengiam int4 NULL,
	loai_thanh_toan int4 NULL,
	apdung int4 NULL,
	ngayravien date DEFAULT now() NULL,
	nguonchitra int8 NULL,
	su_dung int2 NULL,
	ghichu varchar NULL,
	deleted_at timestamp NULL,
	daybhyt int2 NULL,
	id uuid DEFAULT gen_random_uuid() NOT NULL,
	ngay_tao timestamp DEFAULT now() NOT NULL,
	nguoi_tao varchar(100) DEFAULT '''system'''::character varying NOT NULL,
	ngay_cap_nhat timestamp DEFAULT now() NOT NULL,
	nguoi_cap_nhat varchar(100) DEFAULT '''system'''::character varying NOT NULL,
	bi_xoa int2 DEFAULT 0 NULL,
	ngay_xoa timestamp NULL,
	nguoi_xoa varchar(100) NULL,
	"version" varchar(50) NULL,
	sync_flag varchar(50) NULL,
	update_flag varchar(50) NULL,
	created_at varchar(50) NULL,
	created_by varchar(50) NULL,
	updated_at varchar(50) NULL,
	updated_by varchar(50) NULL,
	CONSTRAINT duc_nguonchuongtrinh_pk_id PRIMARY KEY (id)
);

CREATE TABLE duc_nhacungcap (
	nhacungcapid serial4 NOT NULL,
	ma varchar NOT NULL,
	ten varchar NOT NULL,
	diachi varchar NULL,
	dienthoai varchar NULL,
	ghichu varchar NULL,
	csytid int8 NULL,
	masothue varchar NULL,
	taikhoan varchar NULL,
	nganhang varchar NULL,
	khoa int2 DEFAULT 0 NULL,
	su_dung int2 DEFAULT 1 NULL,
	nguoi_tao varchar(100) DEFAULT 'system'::character varying NOT NULL, -- Người tạo
	nguoi_cap_nhat varchar(100) DEFAULT 'system'::character varying NOT NULL, -- Người cập nhật
	ngay_xoa timestamp NULL, -- Ngày xóa mềm
	nguoi_xoa varchar(100) NULL, -- Người xóa mềm
	id uuid DEFAULT gen_random_uuid() NOT NULL, -- Key của bảng
	ngay_tao timestamp DEFAULT now() NOT NULL, -- Ngày tạo
	bi_xoa int2 DEFAULT 0 NULL, -- Bị xóa mềm
	ngay_cap_nhat timestamp DEFAULT now() NOT NULL, -- Ngày cập nhật
	CONSTRAINT duc_nhacungcap_pk_id PRIMARY KEY (id)
);

CREATE TABLE duc_nhapthuoc (
	nhapthuocid numeric(10) NULL,
	kyid numeric(10) NULL,
	khoid numeric(10) NULL,
	phongluuid numeric(10) NULL,
	nhapxuatid numeric(10) NULL,
	trangthaiid numeric(10) NULL,
	ngayxuatthuoc timestamp NULL,
	ngaynhapthuoc timestamp NULL,
	sttnhapthuoc numeric(10) NULL,
	nguoinhapthuoc varchar(300) NULL,
	nhacungcapid numeric(10) NULL,
	khoaid numeric(6) NULL,
	phongid numeric(6) NULL,
	hinhthucid numeric(10) NULL,
	manhapxuat varchar(30) NULL,
	"version" timestamp NULL,
	sync_flag numeric(1) NULL,
	update_flag numeric(1) NULL,
	nguoithuchien varchar(300) NULL,
	ngaythuchien timestamp NULL,
	csytid int8 NULL,
	doiungid numeric(10) NULL
);

CREATE TABLE duc_nhapxuat (
	nhapxuatid numeric(10) NOT NULL,
	ma varchar(30) NULL,
	ngaynx timestamp NULL,
	hinhthucid numeric(2) NULL,
	kieu numeric(10) NULL,
	kyid numeric(10) NULL,
	nguoinx varchar(200) NULL,
	ngaycapnhat timestamp NULL,
	nguoicapnhat varchar(200) NULL,
	sochungtu varchar(50) NULL,
	ngaychungtu timestamp NULL,
	ngayylenh timestamp NULL,
	malienket varchar(50) NULL,
	sttphongluu varchar(5) NULL,
	khoa numeric(10) NULL,
	phieubuthieu numeric(10) NULL,
	xuattt numeric(10) NULL,
	nhacungcapid numeric(10) NULL,
	tendoitac varchar(100) NULL,
	tenkhachhang varchar(300) NULL,
	trangthaiid numeric(10) NULL,
	ngayketthuc timestamp NULL,
	kieudulieu numeric(10) NULL,
	loaithuoc numeric(10) NULL,
	daduyetphieu numeric(10) NULL,
	nguoiduyet varchar(300) NULL,
	noidungduyet varchar(400) NULL,
	ngayduyet timestamp NULL,
	dayeucau numeric(10) NULL,
	nguoixuly varchar(300) NULL,
	noidungxuly varchar(400) NULL,
	ngayxuly timestamp NULL,
	dahuy numeric(2) DEFAULT 0 NULL,
	nguoihuyphieu varchar(300) NULL,
	lydohuyphieu numeric(10) NULL,
	ngayhuyphieu timestamp NULL,
	dathutien numeric(10) NULL,
	nguoithutien varchar(300) NULL,
	lydothutien varchar(400) NULL,
	ngaythutien timestamp NULL,
	ghichu varchar(500) NULL,
	bacsi varchar(60) NULL,
	chandoan varchar(300) NULL,
	tongtien numeric(15, 2) NULL,
	tongtienphaitra numeric(15, 2) NULL,
	tongtiendatra numeric(15, 2) NULL,
	tongtienconno numeric(15, 2) NULL,
	ngaytratien timestamp NULL,
	chietkhau numeric(15, 2) NULL,
	tienthuevat numeric(15, 2) NULL,
	ketoanduocid numeric(10) NULL,
	dsdonthuoc varchar(400) NULL,
	masohoadon numeric(10) NULL,
	lanin numeric(10) NULL,
	maubenhphamid numeric(10) NULL,
	stt numeric(10) NULL,
	soquay numeric(10) NULL,
	cangoiloa numeric(10) NULL,
	khoaid numeric(10) NULL,
	phongid numeric(10) NULL,
	ngaysudungthuoc timestamp NULL,
	lanlinhthuoctrongngay numeric(10) NULL,
	ylenhlinhthuoc numeric(10) NULL,
	dangxuly numeric(10) NULL,
	khoid numeric(10) NULL,
	kiemkeid numeric(10) NULL,
	nguoithuchien varchar(300) NULL,
	ngaythuchien timestamp NULL,
	csytid int8 NULL,
	doiungid numeric(10) NULL,
	nhapxuatid_cha numeric(10) NULL,
	diachi varchar(400) NULL,
	nhapid numeric(10) NULL,
	xuatid numeric(10) NULL,
	dutruid numeric(22) NULL,
	dauthauid numeric(22) NULL,
	"version" timestamp NULL,
	sync_flag numeric(1) NULL,
	update_flag numeric(1) NULL,
	loaidonthuocid numeric(22) NULL,
	bnkhongnhanthuoc numeric(1) DEFAULT 0 NULL,
	mabangke varchar(200) NULL,
	kyhieu varchar(50) NULL,
	hosobenhanid numeric(22) NULL,
	dot_nhapxuatid numeric(22) NULL,
	nguoithuchienid numeric(22) NULL,
	hoidong_kiemnhapid numeric(22) NULL,
	nguoiduyetid numeric(22) NULL,
	namsinh varchar(50) NULL,
	gioitinh numeric(1) DEFAULT 0 NULL,
	diachi_nhm varchar(2000) NULL,
	noinhan varchar(1000) NULL,
	nguoinhan varchar(1000) NULL,
	khonhanid numeric(22) NULL,
	nguoinhanid numeric(22) NULL,
	sttnhapkho varchar(100) NULL,
	ngay_hoanthien_ct timestamp NULL,
	ngay_denhan_tt timestamp NULL,
	sohopdong varchar(2000) NULL,
	ngay_hd timestamp NULL,
	sohoadon varchar(100) NULL,
	cccd varchar(20) NULL,
	sohochieu varchar(20) NULL,
	maqhns varchar(200) NULL,
	mst varchar(20) NULL,
	ngaycaphochieu timestamp NULL,
	ngayhethanhochieu timestamp NULL,
	quocgiaid numeric(4) NULL,
	g_nguoithuchienid uuid NULL,
	nguoinxid int4 NULL,
	g_nguoiduyetid uuid NULL,
	g_nguoinxid uuid NULL,
	lydonhapxuatid uuid NULL, -- Lý do nhập xuất id
	hopdongid numeric(10) NULL,
	mauhososohoa_id uuid NULL,
	lydo varchar(500) NULL,
	bi_xoa int2 DEFAULT 0 NULL,
	ngay_xoa timestamp NULL,
	nguoi_xoa varchar(100) NULL,
	don_vi_nhan_id uuid NULL,
	tinh_trang_thuoc_vt_id uuid NULL,
	CONSTRAINT duc_nhapxuat_pkey PRIMARY KEY (nhapxuatid)
);

CREATE TABLE duc_nhapxuat_bk_20261708 (
	nhapxuatid numeric(10) NULL,
	ma varchar(30) NULL,
	ngaynx timestamp NULL,
	hinhthucid numeric(2) NULL,
	kieu numeric(10) NULL,
	kyid numeric(10) NULL,
	nguoinx varchar(200) NULL,
	ngaycapnhat timestamp NULL,
	nguoicapnhat varchar(200) NULL,
	sochungtu varchar(50) NULL,
	ngaychungtu timestamp NULL,
	ngayylenh timestamp NULL,
	malienket varchar(50) NULL,
	sttphongluu varchar(5) NULL,
	khoa numeric(10) NULL,
	phieubuthieu numeric(10) NULL,
	xuattt numeric(10) NULL,
	nhacungcapid numeric(10) NULL,
	tendoitac varchar(100) NULL,
	tenkhachhang varchar(300) NULL,
	trangthaiid numeric(10) NULL,
	ngayketthuc timestamp NULL,
	kieudulieu numeric(10) NULL,
	loaithuoc numeric(10) NULL,
	daduyetphieu numeric(10) NULL,
	nguoiduyet varchar(300) NULL,
	noidungduyet varchar(400) NULL,
	ngayduyet timestamp NULL,
	dayeucau numeric(10) NULL,
	nguoixuly varchar(300) NULL,
	noidungxuly varchar(400) NULL,
	ngayxuly timestamp NULL,
	dahuy numeric(2) NULL,
	nguoihuyphieu varchar(300) NULL,
	lydohuyphieu numeric(10) NULL,
	ngayhuyphieu timestamp NULL,
	dathutien numeric(10) NULL,
	nguoithutien varchar(300) NULL,
	lydothutien varchar(400) NULL,
	ngaythutien timestamp NULL,
	ghichu varchar(500) NULL,
	bacsi varchar(60) NULL,
	chandoan varchar(300) NULL,
	tongtien numeric(15, 2) NULL,
	tongtienphaitra numeric(15, 2) NULL,
	tongtiendatra numeric(15, 2) NULL,
	tongtienconno numeric(15, 2) NULL,
	ngaytratien timestamp NULL,
	chietkhau numeric(15, 2) NULL,
	tienthuevat numeric(15, 2) NULL,
	ketoanduocid numeric(10) NULL,
	dsdonthuoc varchar(400) NULL,
	masohoadon numeric(10) NULL,
	lanin numeric(10) NULL,
	maubenhphamid numeric(10) NULL,
	stt numeric(10) NULL,
	soquay numeric(10) NULL,
	cangoiloa numeric(10) NULL,
	khoaid numeric(10) NULL,
	phongid numeric(10) NULL,
	ngaysudungthuoc timestamp NULL,
	lanlinhthuoctrongngay numeric(10) NULL,
	ylenhlinhthuoc numeric(10) NULL,
	dangxuly numeric(10) NULL,
	khoid numeric(10) NULL,
	kiemkeid numeric(10) NULL,
	nguoithuchien varchar(300) NULL,
	ngaythuchien timestamp NULL,
	csytid int8 NULL,
	doiungid numeric(10) NULL,
	nhapxuatid_cha numeric(10) NULL,
	diachi varchar(400) NULL,
	nhapid numeric(10) NULL,
	xuatid numeric(10) NULL,
	dutruid numeric(22) NULL,
	dauthauid numeric(22) NULL,
	"version" timestamp NULL,
	sync_flag numeric(1) NULL,
	update_flag numeric(1) NULL,
	loaidonthuocid numeric(22) NULL,
	bnkhongnhanthuoc numeric(1) NULL,
	mabangke varchar(200) NULL,
	kyhieu varchar(50) NULL,
	hosobenhanid numeric(22) NULL,
	dot_nhapxuatid numeric(22) NULL,
	nguoithuchienid numeric(22) NULL,
	hoidong_kiemnhapid numeric(22) NULL,
	nguoiduyetid numeric(22) NULL,
	namsinh varchar(50) NULL,
	gioitinh numeric(1) NULL,
	diachi_nhm varchar(2000) NULL,
	noinhan varchar(1000) NULL,
	nguoinhan varchar(1000) NULL,
	khonhanid numeric(22) NULL,
	nguoinhanid numeric(22) NULL,
	sttnhapkho varchar(100) NULL,
	ngay_hoanthien_ct timestamp NULL,
	ngay_denhan_tt timestamp NULL,
	sohopdong varchar(2000) NULL,
	ngay_hd timestamp NULL,
	sohoadon varchar(100) NULL,
	cccd varchar(20) NULL,
	sohochieu varchar(20) NULL,
	maqhns varchar(200) NULL,
	mst varchar(20) NULL,
	ngaycaphochieu timestamp NULL,
	ngayhethanhochieu timestamp NULL,
	quocgiaid numeric(4) NULL,
	g_nguoithuchienid uuid NULL,
	nguoinxid int4 NULL,
	g_nguoiduyetid uuid NULL,
	g_nguoinxid uuid NULL,
	lydonhapxuatid uuid NULL,
	hopdongid numeric(10) NULL,
	mauhososohoa_id uuid NULL,
	lydo varchar(500) NULL,
	bi_xoa int2 NULL,
	ngay_xoa timestamp NULL,
	nguoi_xoa varchar(100) NULL
);

CREATE TABLE duc_nhapxuatct (
	nhapxuatctid numeric(10) NOT NULL,
	kyid numeric(10) NULL,
	kiemkeid numeric(10) NULL,
	tonkhoid numeric(10) NULL,
	thuocvattuid numeric(10) NULL,
	khoid numeric(10) NULL,
	nhapxuatid numeric(10) NULL,
	ma varchar(30) NULL,
	loai numeric(10) NULL,
	trangthaiid numeric(10) NULL,
	kieu numeric(10) NULL,
	ngaysudungthuoc timestamp NULL,
	nhacungcapid numeric(10) NULL,
	nguonchuongtrinhid numeric(10) NULL,
	ghichu varchar(500) NULL,
	khoaid numeric(6) NULL,
	phongid numeric(6) NULL,
	nguoidungid numeric(10) NULL,
	solo varchar(50) NULL,
	sodangky varchar(200) NULL,
	goithau varchar(50) NULL,
	hansudung timestamp NULL,
	xuatvat numeric(15, 2) NULL,
	xuatgiaban numeric(16, 3) NULL,
	ngaythang timestamp NULL,
	thanhtien numeric(20, 2) NULL,
	ngayduyet timestamp NULL,
	sotienduyet numeric(15, 2) NULL,
	vatduyet numeric(15, 2) NULL,
	ngaynhan timestamp NULL,
	sotiennhan numeric(15, 2) NULL,
	vatnhan numeric(15, 2) NULL,
	ngayketthuc timestamp NULL,
	sotienketthuc numeric(15, 2) NULL,
	vatketthuc numeric(15, 2) NULL,
	dahuy numeric(10) NULL,
	dichvuid numeric(10) NULL,
	dsdichvuid varchar(200) NULL,
	phieubuthieu numeric(10) NULL,
	ghichulinhthuoc varchar(400) NULL,
	"version" timestamp NULL,
	sync_flag numeric(1) NULL,
	update_flag numeric(1) NULL,
	tonkhoctid numeric(10) NULL,
	nguoithuchien varchar(300) NULL,
	ngaythuchien timestamp NULL,
	csytid int8 NULL,
	hinhthucid numeric(2) NULL,
	nhapxuatctid_cha numeric(10) NULL,
	giabhyt numeric(16, 3) NULL,
	gianhandan numeric(16, 3) NULL,
	giadichvu numeric(16, 3) NULL,
	giatranbhyt numeric(16, 3) DEFAULT 0 NULL,
	ngaynx timestamp DEFAULT now() NULL,
	gianhap numeric(20, 3) NULL,
	dauthauid numeric(22) NULL,
	dutruid numeric(22) NULL,
	dauthauctid numeric(22) NULL,
	sodukhadung numeric(17, 3) NULL,
	soluongduyet numeric(17, 3) NULL,
	soluongnhan numeric(17, 3) NULL,
	soluongketthuc numeric(17, 3) NULL,
	soluong numeric(17, 3) NULL,
	solansudung numeric(15) NULL,
	dvtnhanid numeric(22) NULL,
	chietkhau numeric(22) NULL,
	loaichietkhau numeric(1) DEFAULT 0 NULL,
	tylechietkhau numeric(22) NULL,
	giachietkhau numeric(22) NULL,
	ct_quydoi numeric NULL,
	"giabhyt_qĐ" numeric NULL,
	gianhandan_qd numeric NULL,
	giadichvu_qd numeric NULL,
	soluongquydoi numeric(17, 3) NULL, -- Số lượng quy đổi
	id uuid DEFAULT gen_random_uuid() NULL,
	ylthuocvt_id uuid NULL,
	da_hoan_tra int2 DEFAULT 0 NULL,
	nhapxuatctid_ktc numeric NULL, -- ID nhập xuất ct vật tư ktc cha
	ma_nhap varchar NULL,
	bi_xoa int2 DEFAULT 0 NULL,
	ngay_xoa timestamp NULL,
	nguoi_xoa varchar(100) NULL,
	CONSTRAINT duc_nhapxuatct_pkey PRIMARY KEY (nhapxuatctid)
);

CREATE TABLE duc_nhapxuatct_bk_20261708 (
	nhapxuatctid numeric(10) NULL,
	kyid numeric(10) NULL,
	kiemkeid numeric(10) NULL,
	tonkhoid numeric(10) NULL,
	thuocvattuid numeric(10) NULL,
	khoid numeric(10) NULL,
	nhapxuatid numeric(10) NULL,
	ma varchar(30) NULL,
	loai numeric(10) NULL,
	trangthaiid numeric(10) NULL,
	kieu numeric(10) NULL,
	ngaysudungthuoc timestamp NULL,
	nhacungcapid numeric(10) NULL,
	nguonchuongtrinhid numeric(10) NULL,
	ghichu varchar(500) NULL,
	khoaid numeric(6) NULL,
	phongid numeric(6) NULL,
	nguoidungid numeric(10) NULL,
	solo varchar(50) NULL,
	sodangky varchar(200) NULL,
	goithau varchar(50) NULL,
	hansudung timestamp NULL,
	xuatvat numeric(15, 2) NULL,
	xuatgiaban numeric(16, 3) NULL,
	ngaythang timestamp NULL,
	thanhtien numeric(20, 2) NULL,
	ngayduyet timestamp NULL,
	sotienduyet numeric(15, 2) NULL,
	vatduyet numeric(15, 2) NULL,
	ngaynhan timestamp NULL,
	sotiennhan numeric(15, 2) NULL,
	vatnhan numeric(15, 2) NULL,
	ngayketthuc timestamp NULL,
	sotienketthuc numeric(15, 2) NULL,
	vatketthuc numeric(15, 2) NULL,
	dahuy numeric(10) NULL,
	dichvuid numeric(10) NULL,
	dsdichvuid varchar(200) NULL,
	phieubuthieu numeric(10) NULL,
	ghichulinhthuoc varchar(400) NULL,
	"version" timestamp NULL,
	sync_flag numeric(1) NULL,
	update_flag numeric(1) NULL,
	tonkhoctid numeric(10) NULL,
	nguoithuchien varchar(300) NULL,
	ngaythuchien timestamp NULL,
	csytid int8 NULL,
	hinhthucid numeric(2) NULL,
	nhapxuatctid_cha numeric(10) NULL,
	giabhyt numeric(16, 3) NULL,
	gianhandan numeric(16, 3) NULL,
	giadichvu numeric(16, 3) NULL,
	giatranbhyt numeric(16, 3) NULL,
	ngaynx timestamp NULL,
	gianhap numeric(20, 3) NULL,
	dauthauid numeric(22) NULL,
	dutruid numeric(22) NULL,
	dauthauctid numeric(22) NULL,
	sodukhadung numeric(17, 3) NULL,
	soluongduyet numeric(17, 3) NULL,
	soluongnhan numeric(17, 3) NULL,
	soluongketthuc numeric(17, 3) NULL,
	soluong numeric(17, 3) NULL,
	solansudung numeric(15) NULL,
	dvtnhanid numeric(22) NULL,
	chietkhau numeric(22) NULL,
	loaichietkhau numeric(1) NULL,
	tylechietkhau numeric(22) NULL,
	giachietkhau numeric(22) NULL,
	ct_quydoi numeric NULL,
	"giabhyt_qĐ" numeric NULL,
	gianhandan_qd numeric NULL,
	giadichvu_qd numeric NULL,
	soluongquydoi numeric(17, 3) NULL,
	id uuid NULL,
	ylthuocvt_id uuid NULL,
	da_hoan_tra int2 NULL,
	nhapxuatctid_ktc numeric NULL,
	ma_nhap varchar NULL,
	bi_xoa int2 NULL,
	ngay_xoa timestamp NULL,
	nguoi_xoa varchar(100) NULL
);

CREATE TABLE duc_nhomtvt_tuongduong (
	nhomtvt_tuongduongid numeric(22) NOT NULL,
	ma varchar(50) NULL,
	ten varchar(600) NULL,
	csytid int8 NULL,
	thongtinnhom varchar(1000) NULL,
	ngayravien timestamp DEFAULT now() NULL,
	hoatchatid numeric NOT NULL,
	hamluong varchar NULL,
	sudung int4 DEFAULT 1 NULL,
	CONSTRAINT duc_nhomtvt_tuongduong_pkey PRIMARY KEY (nhomtvt_tuongduongid)
);

CREATE TABLE duc_phac_do_khang_sinh (
	id uuid DEFAULT gen_random_uuid() NOT NULL,
	ly_do varchar NULL,
	ten varchar NULL,
	ngay_tao timestamp DEFAULT now() NULL,
	hoi_chan_id uuid NULL,
	CONSTRAINT duc_phac_do_khang_sinh_pkey PRIMARY KEY (id)
);

CREATE TABLE duc_phatthuoc (
	phatthuocid numeric(10) NOT NULL,
	kyid numeric(10) NULL,
	khoid numeric(10) NULL,
	phongluuid numeric(10) NULL,
	nhapxuatid numeric(10) NULL,
	trangthaiid numeric(10) NULL,
	ngayxuatthuoc timestamp NULL,
	ngayphatthuoc timestamp NULL,
	sttphatthuoc numeric(5) NULL,
	nguoiphatthuoc varchar(300) NULL,
	nhacungcapid numeric(10) NULL,
	khoaid numeric(10) NULL,
	phongid numeric(10) NULL,
	hinhthucid numeric(10) NULL,
	manhapxuat varchar(30) NULL,
	"version" timestamp NULL,
	sync_flag numeric(1) NULL,
	update_flag numeric(1) NULL,
	nguoithuchien varchar(300) NULL,
	ngaythuchien timestamp NULL,
	csytid int8 NULL,
	doiungid numeric(10) NULL,
	CONSTRAINT duc_phatthuoc_pkey PRIMARY KEY (phatthuocid)
);

CREATE TABLE duc_phatthuoc_bk_20261708 (
	phatthuocid numeric(10) NULL,
	kyid numeric(10) NULL,
	khoid numeric(10) NULL,
	phongluuid numeric(10) NULL,
	nhapxuatid numeric(10) NULL,
	trangthaiid numeric(10) NULL,
	ngayxuatthuoc timestamp NULL,
	ngayphatthuoc timestamp NULL,
	sttphatthuoc numeric(5) NULL,
	nguoiphatthuoc varchar(300) NULL,
	nhacungcapid numeric(10) NULL,
	khoaid numeric(10) NULL,
	phongid numeric(10) NULL,
	hinhthucid numeric(10) NULL,
	manhapxuat varchar(30) NULL,
	"version" timestamp NULL,
	sync_flag numeric(1) NULL,
	update_flag numeric(1) NULL,
	nguoithuchien varchar(300) NULL,
	ngaythuchien timestamp NULL,
	csytid int8 NULL,
	doiungid numeric(10) NULL
);

CREATE TABLE duc_phuphi (
	phuphiid numeric(10) NULL,
	nhapxuatctid numeric(10) NULL,
	tonkhoctid numeric(10) NULL,
	thuocvattuid numeric(10) NULL,
	nhapxuatid numeric(10) NULL,
	csytid int8 NULL,
	ngayravien timestamp DEFAULT now() NULL,
	giabhyt numeric NULL,
	giavienphi numeric NULL,
	giadichvu numeric NULL
);

CREATE TABLE duc_phuphi_bk_20261708 (
	phuphiid numeric(10) NULL,
	nhapxuatctid numeric(10) NULL,
	tonkhoctid numeric(10) NULL,
	thuocvattuid numeric(10) NULL,
	nhapxuatid numeric(10) NULL,
	csytid int8 NULL,
	ngayravien timestamp NULL,
	giabhyt numeric NULL,
	giavienphi numeric NULL,
	giadichvu numeric NULL
);

CREATE TABLE duc_sodonthuoc_counter (
	id serial4 NOT NULL,
	ma_cskcb varchar(5) NOT NULL,
	nam int2 NOT NULL,
	counter int8 DEFAULT '-1'::integer NOT NULL,
	ngay_tao timestamp DEFAULT now() NOT NULL,
	ngay_cap_nhat timestamp DEFAULT now() NOT NULL,
	CONSTRAINT duc_sodonthuoc_counter_ma_cskcb_nam_key UNIQUE (ma_cskcb, nam),
	CONSTRAINT duc_sodonthuoc_counter_pkey PRIMARY KEY (id)
);

CREATE TABLE duc_thongke_hoachatvattu_xetnghiem (
	id uuid DEFAULT gen_random_uuid() NOT NULL, -- Khóa chính định danh dòng thống kê
	ngay_thong_ke timestamp NOT NULL, -- Ngày dữ liệu báo cáo
	dich_vu_kt_id uuid NULL, -- Mã dịch vụ kỹ thuật (Dùng để nhóm các loại xét nghiệm)
	ten_dich_vu_kt varchar NULL, -- Tên dịch vụ kỹ thuật
	ten_vat_tu_hoa_chat varchar(255) NULL, -- Tên hóa chất hoặc vật tư 
	vat_tu_hoa_chat_id uuid NULL, -- Id định danh của vật tư/hóa chất 
	ten_kho varchar(255) NULL, -- Tên kho quản lý
	kho_id uuid NULL, -- Id định danh của kho
	so_ca int4 DEFAULT 0 NULL, -- Tổng số ca ngày hôm đấy
	don_vi_cap_phat varchar(40) NULL, -- Đơn vị tính khi cấp phát sử dụng, vd: ML
	so_luong_su_dung int4 DEFAULT 0 NULL, -- Số lượng vật tư đã sử dụng
	so_luong_test int4 DEFAULT 0 NULL, -- Số lượng dùng để chạy QC/Calip
	don_vi_quan_ly varchar(40) NULL, -- Đơn vị tính khi quản lý nhập/xuất kho, vd: Chai, Hộp
	so_luong_quy_doi varchar(40) NULL, -- Số lượng quy đổi từ đơn vị cấp phát sang đơn vị quản lý
	thoi_gian_thong_ke timestamp DEFAULT now() NULL, -- Thời điểm hệ thống chạy tạo bản ghi này
	nguoi_thong_ke varchar(100) DEFAULT 'system'::character varying NOT NULL, -- Người thao tác hoặc hệ thống tự động
	da_xuat_kho bool DEFAULT false NULL, -- Trạng thái đánh dấu đã tạo phiếu xuất kho cho các vật tư này hay chưa
	so_phieu_xuat varchar(100) NULL, -- Mã/Số phiếu xuất kho thực tế sau khi xử lý
	ma_cskcb varchar(100) NULL, -- Mã cơ sở khám chữa bệnh
	khoa_id uuid NULL, -- Id khoa
	ten_khoa varchar(100) NULL, -- Tên khoa
	solo varchar(255) NULL, -- Số lô hóa chất thực hiện phiếu xuất kho
	CONSTRAINT duc_thongke_hoachatvattu_xetnghiem_pkey PRIMARY KEY (id)
);

CREATE TABLE duc_thongtin_mau (
	thongtin_mauid numeric(22) NOT NULL,
	tonkhoctid numeric(22) NULL,
	barcode varchar(50) NULL,
	matieucau varchar(50) NULL,
	nhommau varchar(2) NULL,
	rh varchar(1) NULL,
	hansudung timestamp NULL,
	csytid int8 NULL,
	tonkhoctid_tam numeric(22) NULL,
	daymau varchar(1000) NULL,
	user_id numeric(22) NULL,
	user_update varchar NULL,
	ngayravien timestamp DEFAULT now() NULL,
	ngaysanxuat timestamp NULL,
	thuocvattuid numeric(10) NULL,
	nhapxuatctid numeric NULL,
	dongia numeric NULL,
	id_goc uuid NULL,
	"user" uuid NULL,
	CONSTRAINT duc_thongtin_mau_pkey PRIMARY KEY (thongtin_mauid)
);

CREATE TABLE duc_thongtin_mau_temp (
	thongtin_mauid numeric(22) NOT NULL,
	tonkhoctid numeric(22) NULL,
	barcode varchar(50) NULL,
	matieucau varchar(50) NULL,
	nhommau varchar(2) NULL,
	rh varchar(1) NULL,
	hansudung timestamp NULL,
	csytid int8 NULL,
	tonkhoctid_tam numeric(22) NULL,
	daymau varchar(1000) NULL,
	user_id numeric(22) NULL,
	user_update varchar NULL,
	ngayravien timestamp DEFAULT now() NULL,
	ngaysanxuat timestamp NULL,
	thuocvattuid numeric(10) NULL,
	nhapxuatctid numeric NULL,
	dongia numeric NULL,
	id_goc uuid NULL,
	"user" uuid NULL,
	CONSTRAINT duc_thongtin_mau_temp_pkey PRIMARY KEY (thongtin_mauid)
);

CREATE TABLE duc_thuoc_icd (
	thuoc_icd_id numeric(22) NOT NULL,
	icd10id numeric(22) NULL,
	thuocvattuid numeric(22) NULL,
	duocphepke numeric(1) DEFAULT 1 NULL,
	dichvu numeric(1) DEFAULT 1 NULL,
	nhandan numeric(1) DEFAULT 1 NULL,
	bhyt numeric(1) DEFAULT 1 NULL,
	nuocngoai numeric(1) DEFAULT 1 NULL,
	csytid int8 NULL,
	sotuoithang numeric(6, 2) NULL,
	tuoithang numeric(1) NULL,
	sosanhtuoi varchar(5) NULL,
	ghichu varchar(1000) NULL,
	ngayravien timestamp DEFAULT now() NULL,
	CONSTRAINT duc_thuoc_icd_pkey PRIMARY KEY (thuoc_icd_id)
);

CREATE TABLE duc_thuoc_vat_tu_temp (
	thuocvattuid numeric(10) NULL,
	ma varchar(100) NULL,
	manhom varchar(100) NULL,
	kieu numeric(10) NULL,
	kieudulieu numeric(10) NULL,
	loai varchar(10) NULL,
	ten varchar(500) NULL,
	tenkhoahoc varchar(2048) NULL,
	donggoi varchar(400) NULL,
	nongdo varchar(500) NULL,
	lieuluong varchar(2048) NULL,
	hoatchat varchar(2048) NULL,
	dangdung varchar(200) NULL,
	chuy varchar(2000) NULL,
	thutuinphieu numeric(10) NULL,
	gianhap numeric(17, 4) DEFAULT 0 NULL,
	giaban numeric(16, 3) DEFAULT 0 NULL,
	vatnhap numeric(15, 2) DEFAULT 0 NULL,
	vatban numeric(15, 2) DEFAULT 0 NULL,
	canhbaosoluong numeric(10, 3) DEFAULT 0 NULL,
	canhbaohsd numeric(1) DEFAULT 0 NULL,
	thuocvattuid_cha numeric(10) NULL,
	huongdansudung varchar(500) NULL,
	soluongngay numeric(15, 2) NULL,
	solo varchar(50) NULL,
	sodangky varchar(520) NULL,
	tylehuhao numeric(3) DEFAULT 0 NULL,
	nhombhyt varchar NULL,
	nhomtkbaocao varchar(100) NULL,
	bietduoc varchar(200) NULL,
	atc varchar(100) NULL,
	nhombc varchar(100) NULL,
	khongchuyendoituonghaophi numeric(1) NULL,
	luonchuyendoituonghaophi numeric(5) NULL,
	sync_flag numeric(1) NULL,
	update_flag numeric(1) NULL,
	giavienphi numeric(16, 3) DEFAULT 0 NULL,
	tyleloinhuannhandan numeric(15, 2) DEFAULT 100 NULL,
	giabhyt numeric(16, 3) DEFAULT 0 NULL,
	tyleloinhuannuocngoai numeric(15, 2) DEFAULT 100 NULL,
	nguoicapnhat numeric(10) NULL,
	ngaycapnhat timestamp NULL,
	tyleloinhuan numeric(15, 2) DEFAULT 100 NULL,
	gianhandan numeric(16, 3) DEFAULT 0 NULL,
	tyleloinhuanbhyt numeric(15, 2) DEFAULT 100 NULL,
	gianuocngoai numeric(16, 3) DEFAULT 0 NULL,
	giatranbhyt numeric(16, 3) NULL,
	thuockhangsinh numeric(1) DEFAULT 0 NULL,
	mahoatchat varchar(300) NULL,
	tuongtacthuoc varchar(1642) NULL,
	dsphongthuchien varchar(800) NULL,
	benhvienapthau varchar(200) NULL,
	nhacungcapid numeric(10) NULL,
	khoa numeric(1) DEFAULT 0 NULL,
	khongnhapmoi numeric(1) NULL,
	nhomquycheid varchar NULL,
	nhombaocaoid numeric(10) NULL,
	nhomduoclyid numeric(10) NULL,
	nhomtieuduoclyid numeric(10) NULL,
	nhomnghiencuuid numeric(10) NULL,
	nhomabcvenid numeric(10) NULL,
	goithau varchar(50) NULL,
	namcungung varchar(100) NULL,
	chephamyhct numeric(1) DEFAULT 0 NULL,
	vithuocyhct numeric(1) DEFAULT 0 NULL,
	thuoctanduoc numeric(1) DEFAULT 1 NULL,
	sttdauthau varchar(50) NULL,
	nguonchuongtrinhid numeric(10) NULL,
	tenbyt varchar(2048) NULL,
	cholanhdaoduyet varchar(10) NULL,
	danhsttdungthuoc numeric(5) NULL,
	duongdungid numeric(10) NULL,
	ghichu varchar(200) NULL,
	nguoithuchien varchar(400) NULL,
	ngaythuchien timestamp NULL,
	csytid int8 NULL,
	tylebhyt numeric(15, 2) DEFAULT 0 NULL,
	nhom_mabhyt_id numeric(10) NULL,
	bhyttt numeric(15, 2) NULL,
	khoanmucid varchar NULL,
	tylehuhao_tmp numeric(6, 2) NULL,
	sldauky_tmp numeric(15, 2) NULL,
	thuochoatchat varchar(3000) NULL,
	dv_lamtron numeric(10) NULL,
	ketrunghoatchat numeric(22) DEFAULT 0 NULL,
	barcode varchar(50) NULL,
	mathau varchar(50) NULL,
	manhomthau varchar(50) NULL,
	donvitinhid_qd numeric(10) NULL,
	solansudung numeric(22) NULL,
	thuocphongxa numeric(2) NULL,
	duocphepkele numeric(1) DEFAULT 0 NULL,
	sogoithau varchar(50) NULL,
	stt05 varchar(50) NULL,
	songaysdkhangsinh numeric(22) DEFAULT 0 NULL,
	songayttbaohiem numeric(22) DEFAULT 0 NULL,
	sttthuoc varchar(10) NULL,
	tuoimin numeric(22) DEFAULT 0 NULL,
	tuoimax numeric(22) NULL,
	ngayhlbhyt timestamp NULL,
	tylebhytcu numeric(15, 2) NULL,
	nhomdieutriid numeric(22) NULL,
	tienchatgnht numeric(1) NULL,
	thuockedon numeric(1) NULL,
	kedonmuangoai numeric(1) DEFAULT 1 NULL,
	dauthauctid numeric(22) NULL,
	dmbyt numeric(1) DEFAULT 0 NULL,
	thuocnhieuhoatchat numeric(1) DEFAULT 0 NULL,
	khongtinhxnt numeric(1) DEFAULT 0 NULL,
	thangsobanle numeric(9, 4) NULL,
	ycsdkhangsinh numeric(1) DEFAULT 0 NULL,
	qltheotuimau numeric(1) DEFAULT 0 NULL,
	duocduyetle numeric(22) DEFAULT 0 NULL,
	thuoccorticoid numeric(1) NULL,
	thuocdieutrilao numeric(1) NULL,
	khonginhamluong numeric(1) NULL,
	slthau numeric(15, 3) NULL,
	loaithau numeric(22) NULL,
	hamluong varchar(2048) NULL,
	tontoithieu numeric(15, 3) NULL,
	slketheodot numeric(22, 3) NULL,
	slketheongay numeric(22, 3) NULL,
	mathuocbv varchar(200) NULL,
	ghepmaxml numeric(1) NULL,
	thanhtoanhaophi numeric(1) NULL,
	thuocchuyenkhoatamthan numeric(1) NULL,
	sogiayphep varchar(250) NULL,
	tenatc varchar(1000) NULL,
	thuocdacbiet numeric(1) NULL,
	dvt_uutien numeric(22) NULL,
	lydokhoathuoc varchar(500) NULL,
	giachenh numeric(1) NULL,
	ngayravien timestamp DEFAULT now() NULL,
	khongthanhtoanngoaitru numeric(2) NULL,
	tontoida numeric(15, 3) NULL,
	tuoithangmin numeric(1) NULL,
	tuoithangmax numeric(1) NULL,
	molnupiravir numeric(1) NULL,
	mahieusp varchar(600) NULL,
	ppchebien numeric(22) NULL,
	tenvtytthuongmai varchar(1000) NULL,
	ngayketthuc varchar(15) NULL,
	ngayketthuchd varchar(15) NULL,
	thaughep varchar(500) NULL,
	soquyetdinh numeric(1) NULL,
	ma_pp_chebien varchar(500) NULL,
	chiphituimau numeric(1) NULL,
	ma4750 varchar(50) NULL,
	tangnguyco numeric(1) NULL,
	khiytet numeric(1) NULL,
	mabyt varchar(255) NULL,
	teme numeric(22) NULL,
	vitamin numeric(22) NULL,
	thetich numeric(22) NULL,
	phamviquanly numeric(1) NULL,
	nhomphieulinh uuid NULL,
	slcaptoa numeric(15, 3) NULL,
	bi_xoa int2 DEFAULT 0 NULL,
	ngay_xoa timestamp NULL,
	nguoi_xoa varchar(50) NULL,
	nuocsanxuatid varchar NULL,
	hangsanxuatid numeric(10) NULL,
	donvitinhid numeric(10) NULL,
	doituonghaophi numeric(10) NULL,
	sudung bool DEFAULT true NULL,
	ma_duong_dung varchar(100) NULL,
	ten_duong_dung varchar(500) NULL,
	dangbaoche varchar(500) NULL,
	ten_biet_duoc_goc varchar(500) NULL,
	ma_nhom_bao_cao varchar(100) NULL,
	ten_nhom_bao_cao varchar(500) NULL,
	ma_nhom_abc_ven varchar(100) NULL,
	ten_nhom_abc_ven varchar(500) NULL,
	nuoc_san_xuat varchar(500) NULL,
	hang_san_xuat varchar(500) NULL,
	don_vi_quan_ly varchar(500) NULL,
	don_vi_cap_phat varchar(500) NULL,
	ma_nhom_khoan_muc varchar(100) NULL,
	nguon_chi_tra varchar(500) NULL,
	trangthai numeric(1) NULL,
	lanimport numeric(10) NULL,
	maimport uuid NULL,
	loi text NULL,
	uid varchar(100) NULL,
	thuocvattu_id_update numeric(10) NULL,
	id uuid DEFAULT gen_random_uuid() NOT NULL,
	ten_ppchebien varchar NULL,
	nhomquanlyid uuid NULL,
	dangbaocheid uuid NULL,
	phanloaiduoc int4 NULL,
	manhomduoc varchar NULL,
	loaiduocatc varchar NULL,
	quy_cach_dong_goi varchar NULL,
	tylevatid uuid NULL,
	CONSTRAINT duc_thuoc_vat_tu_temp_pkey PRIMARY KEY (id)
);

CREATE TABLE duc_thuocvattu (
	thuocvattuid numeric(10) NOT NULL,
	ma varchar(100) NULL,
	manhom varchar(100) NULL,
	kieu numeric(10) NULL,
	kieudulieu numeric(10) NULL,
	loai varchar(10) NULL,
	ten varchar(500) NULL,
	tenkhoahoc varchar(2048) NULL,
	donggoi varchar(400) NULL,
	nongdo varchar(500) NULL,
	lieuluong varchar(2048) NULL,
	hoatchat varchar(2048) NULL,
	dangdung varchar(200) NULL,
	chuy varchar(2000) NULL,
	thutuinphieu numeric(10) NULL,
	gianhap numeric(17, 4) DEFAULT 0 NULL,
	giaban numeric(16, 3) DEFAULT 0 NULL,
	vatnhap numeric(15, 2) DEFAULT 0 NULL,
	vatban numeric(15, 2) DEFAULT 0 NULL,
	canhbaosoluong numeric(10, 3) DEFAULT 0 NULL,
	canhbaohsd numeric(1) DEFAULT 0 NULL,
	thuocvattuid_cha numeric(10) NULL,
	huongdansudung varchar(500) NULL,
	soluongngay numeric(15, 2) NULL,
	solo varchar(50) NULL,
	sodangky varchar(520) NULL,
	tylehuhao numeric(3) DEFAULT 0 NULL,
	nhombhyt varchar NULL,
	nhomtkbaocao varchar(100) NULL,
	bietduoc varchar(200) NULL,
	atc varchar(100) NULL,
	nhombc varchar(100) NULL,
	khongchuyendoituonghaophi numeric(1) NULL,
	luonchuyendoituonghaophi numeric(5) NULL,
	sync_flag numeric(1) NULL,
	update_flag numeric(1) NULL,
	giavienphi numeric(16, 3) DEFAULT 0 NULL,
	tyleloinhuannhandan numeric(15, 2) DEFAULT 100 NULL,
	giabhyt numeric(16, 3) DEFAULT 0 NULL,
	tyleloinhuannuocngoai numeric(15, 2) DEFAULT 100 NULL,
	nguoicapnhat numeric(10) NULL,
	ngaycapnhat timestamp NULL,
	tyleloinhuan numeric(15, 2) DEFAULT 100 NULL,
	gianhandan numeric(16, 3) DEFAULT 0 NULL,
	tyleloinhuanbhyt numeric(15, 2) DEFAULT 100 NULL,
	gianuocngoai numeric(16, 3) DEFAULT 0 NULL,
	giatranbhyt numeric(16, 3) NULL,
	thuockhangsinh numeric(1) DEFAULT 0 NULL,
	mahoatchat varchar(300) NULL,
	tuongtacthuoc varchar(1642) NULL,
	dsphongthuchien varchar(800) NULL,
	benhvienapthau varchar(200) NULL,
	nhacungcapid numeric(10) NULL,
	khoa numeric(1) DEFAULT 0 NULL,
	khongnhapmoi numeric(1) NULL,
	nhomquycheid varchar NULL,
	nhombaocaoid numeric(10) NULL,
	nhomduoclyid numeric(10) NULL,
	nhomtieuduoclyid numeric(10) NULL,
	nhomnghiencuuid numeric(10) NULL,
	nhomabcvenid numeric(10) NULL,
	goithau varchar(50) NULL,
	namcungung varchar(100) NULL,
	chephamyhct numeric(1) DEFAULT 0 NULL,
	vithuocyhct numeric(1) DEFAULT 0 NULL,
	thuoctanduoc numeric(1) DEFAULT 1 NULL,
	sttdauthau varchar(50) NULL,
	nguonchuongtrinhid numeric(10) NULL,
	tenbyt varchar(2048) NULL,
	cholanhdaoduyet varchar(10) NULL,
	danhsttdungthuoc numeric(5) NULL,
	duongdungid numeric(10) NULL,
	ghichu varchar(200) NULL,
	nguoithuchien varchar(400) NULL,
	ngaythuchien timestamp NULL,
	csytid int8 NULL,
	tylebhyt numeric(15, 2) DEFAULT 0 NULL,
	nhom_mabhyt_id numeric(10) NULL,
	bhyttt numeric(15, 2) NULL,
	khoanmucid varchar NULL,
	tylehuhao_tmp numeric(6, 2) NULL,
	sldauky_tmp numeric(15, 2) NULL,
	thuochoatchat varchar(3000) NULL,
	dv_lamtron numeric(10) NULL,
	ketrunghoatchat numeric(22) DEFAULT 0 NULL,
	barcode varchar(50) NULL,
	mathau varchar(50) NULL,
	manhomthau varchar(50) NULL,
	donvitinhid_qd numeric(10) NULL,
	solansudung numeric(22) NULL,
	thuocphongxa numeric(2) NULL,
	duocphepkele numeric(1) DEFAULT 0 NULL,
	sogoithau varchar(50) NULL,
	stt05 varchar(50) NULL,
	songaysdkhangsinh numeric(22) DEFAULT 0 NULL,
	songayttbaohiem numeric(22) DEFAULT 0 NULL,
	sttthuoc varchar(10) NULL,
	tuoimin numeric(22) DEFAULT 0 NULL,
	tuoimax numeric(22) NULL,
	ngayhlbhyt timestamp NULL,
	tylebhytcu numeric(15, 2) NULL,
	nhomdieutriid numeric(22) NULL,
	tienchatgnht numeric(1) NULL,
	thuockedon numeric(1) NULL,
	kedonmuangoai numeric(1) DEFAULT 1 NULL,
	dauthauctid numeric(22) NULL,
	dmbyt numeric(1) DEFAULT 0 NULL,
	thuocnhieuhoatchat numeric(1) DEFAULT 0 NULL,
	khongtinhxnt numeric(1) DEFAULT 0 NULL,
	thangsobanle numeric(9, 4) NULL,
	ycsdkhangsinh numeric(1) DEFAULT 0 NULL,
	qltheotuimau numeric(1) DEFAULT 0 NULL,
	duocduyetle numeric(22) DEFAULT 0 NULL,
	thuoccorticoid numeric(1) NULL,
	thuocdieutrilao numeric(1) NULL,
	khonginhamluong numeric(1) NULL,
	slthau numeric(15, 3) NULL,
	loaithau numeric(22) NULL,
	hamluong varchar(2048) NULL,
	tontoithieu numeric(15, 3) NULL,
	slketheodot numeric(22, 3) NULL,
	slketheongay numeric(22, 3) NULL,
	mathuocbv varchar(200) NULL,
	ghepmaxml numeric(1) NULL,
	thanhtoanhaophi numeric(1) NULL,
	thuocchuyenkhoatamthan numeric(1) NULL,
	sogiayphep varchar(250) NULL,
	tenatc varchar(1000) NULL,
	thuocdacbiet numeric(1) NULL,
	dvt_uutien numeric(22) NULL,
	lydokhoathuoc varchar(500) NULL,
	giachenh numeric(1) NULL,
	ngayravien timestamp DEFAULT now() NULL,
	khongthanhtoanngoaitru numeric(2) NULL,
	tontoida numeric(15, 3) NULL,
	tuoithangmin numeric(1) NULL,
	tuoithangmax numeric(1) NULL,
	molnupiravir numeric(1) NULL,
	mahieusp varchar(600) NULL,
	ppchebien numeric(22) NULL,
	tenvtytthuongmai varchar(1000) NULL,
	ngayketthuc varchar(15) NULL,
	ngayketthuchd varchar(15) NULL,
	thaughep varchar(500) NULL,
	soquyetdinh numeric(1) NULL,
	ma_pp_chebien varchar(500) NULL,
	chiphituimau numeric(1) NULL,
	ma4750 varchar(50) NULL,
	tangnguyco numeric(1) NULL,
	khiytet numeric(1) NULL,
	mabyt varchar(255) NULL,
	teme numeric(22) NULL,
	vitamin numeric(22) NULL,
	thetich numeric(22) NULL,
	phamviquanly numeric(1) NULL,
	nhomphieulinh uuid NULL,
	slcaptoa numeric(15, 3) NULL,
	bi_xoa int2 DEFAULT 0 NULL,
	ngay_xoa timestamp NULL,
	nguoi_xoa varchar(50) NULL,
	nuocsanxuatid varchar NULL,
	hangsanxuatid numeric(10) NULL,
	donvitinhid numeric(10) NULL,
	doituonghaophi numeric(10) NULL,
	sudung bool DEFAULT true NULL,
	pqkhoa _uuid DEFAULT '{}'::uuid[] NULL,
	pqphong _uuid DEFAULT '{}'::uuid[] NULL,
	pqkho _numeric DEFAULT '{}'::numeric[] NULL,
	pqbacsi _uuid DEFAULT '{}'::uuid[] NULL,
	pqloaidieutri _uuid DEFAULT '{}'::uuid[] NULL,
	pqloaikedon _uuid DEFAULT '{}'::uuid[] NULL,
	pqdoituongbenhnhan _uuid DEFAULT '{}'::uuid[] NULL,
	pqthuocvattu _numeric DEFAULT '{}'::numeric[] NULL,
	id uuid DEFAULT gen_random_uuid() NULL,
	nhomquanlyid uuid NULL,
	dangbaocheid uuid NULL,
	stt_thuoc_tuong_duong int4 NULL,
	quy_cach_dong_goi varchar NULL,
	dshoatchat _varchar GENERATED ALWAYS AS (string_to_array(hoatchat::text, ','::text)) STORED NULL,
	manhomduoc varchar NULL, -- Mã DM nhóm dược
	phanloaiduoc int4 NULL, -- Phân loại dược
	loaiduocatc varchar NULL,
	tylevatid uuid NULL,
	nguong_so_luong numeric NULL,
	CONSTRAINT duc_thuocvattu_pkey PRIMARY KEY (thuocvattuid)
);

CREATE TABLE duc_thuocvattu_morong (
	thuocvattu_morongid numeric(22) NOT NULL,
	thuocvattuid numeric(22) NULL,
	dangbaoche varchar(200) NULL,
	nguongoc varchar(20) NULL,
	tenkhvithuoc varchar(200) NULL,
	tenkhcaycon varchar(300) NULL,
	tinhtrangduoclieu varchar(300) NULL,
	yeucausudung varchar(300) NULL,
	bophansudung varchar(100) NULL,
	tylehaohutchebien numeric(6, 3) NULL,
	chiphikhac numeric(15, 6) NULL,
	csytid int8 NULL,
	nguoicapnhat varchar(2000) NULL,
	ngaycapnhat timestamp NULL,
	nguoithuchien varchar(2000) NULL,
	ngaythuchien timestamp NULL,
	url varchar(1000) NULL,
	chidinh text NULL,
	anh1 text NULL,
	gia_thuocdongy numeric(15, 6) NULL,
	thuhoivolo numeric(1) NULL,
	phuongphapchebien numeric(1) NULL,
	tieuchuanchatluong varchar(2048) NULL,
	ngayravien timestamp DEFAULT now() NULL,
	tylenhacungcap numeric(6) NULL,
	tylebacsi numeric(6) NULL,
	loaihinh numeric(1) NULL,
	nguongcb numeric(22) NULL,
	tylequydoi varchar(100) NULL,
	mamoithau varchar(100) NULL,
	chongchidinh text NULL,
	urlccd varchar(1000) NULL,
	anh2 text NULL,
	thuocdoc numeric(1) NULL,
	dangthuoc numeric(1) NULL,
	lienthongdm numeric(1) NULL,
	cptbc numeric(1) NULL,
	ttlieudung varchar(4000) NULL,
	thongtinchitiet varchar(4000) NULL,
	cachdungthuoc varchar(2000) NULL,
	ttchidinh varchar(2000) NULL,
	ttchongchidinh varchar(2000) NULL,
	trinhbay varchar(2000) NULL,
	canhbao varchar(1000) NULL,
	tuongtacthuoc varchar(1000) NULL,
	anhhuonglx varchar(1000) NULL,
	tacdungkmongmuon varchar(1000) NULL,
	thaiky varchar(1000) NULL,
	qualieu varchar(1000) NULL,
	dactinh varchar(1000) NULL,
	congthuc varchar(1000) NULL,
	CONSTRAINT duc_thuocvattu_morong_pkey PRIMARY KEY (thuocvattu_morongid),
	CONSTRAINT duc_thuocvattu_morong_thuocvattuid_key UNIQUE (thuocvattuid)
);

CREATE TABLE duc_tieuhao_hoachatvattu_xetnghiem (
	id uuid DEFAULT gen_random_uuid() NOT NULL,
	dich_vu_kt_id uuid NULL, -- Id dịch vụ trong bảng dm_dich_vu_kt
	ten_dich_vu_kt varchar(255) NULL, -- Tên dịch vụ trong bảng dm_dich_vu_kt
	trang_thai_tieu_hao varchar(255) NULL, -- trạng thái tiêu hao hóa chất/vật tư
	vat_tu_dinhmuc_tieu_hao varchar(2000) NULL, -- Danh sách định vật tư , định mức tiêu hao 
	thoi_diem_tieu_hao timestamp NOT NULL, -- thời điểm tiêu hao
	kho_id uuid NULL, -- Id trong bảng duc_kho
	ten_kho varchar(100) NULL, -- thời điểm tiêu hao
	ngay_tao timestamp DEFAULT now() NOT NULL, -- Ngày tạo
	nguoi_tao varchar(100) DEFAULT 'system'::character varying NOT NULL, -- Người tạo
	ngay_cap_nhat timestamp DEFAULT now() NOT NULL, -- Ngày cập nhật
	nguoi_cap_nhat varchar(100) DEFAULT 'system'::character varying NOT NULL, -- Người cập nhật
	bi_xoa int2 DEFAULT 0 NULL, -- Bị xóa mềm
	ngay_xoa timestamp NULL, -- Ngày xóa mềm
	nguoi_xoa varchar(100) NULL, -- Người xóa mềm
	ma_cskcb varchar(100) NULL,
	khoa_id uuid NULL, -- Id khoa
	ten_khoa varchar(100) NULL, -- Tên khoa 
	thong_ke_id uuid NULL, -- id trong bảng duc_thongke
	CONSTRAINT duc_tieuhao_hoachatvattu_xetnghiem_pkey PRIMARY KEY (id)
);

CREATE TABLE duc_tonkho (
	tonkhoid numeric(10) NOT NULL,
	kyid numeric(10) NULL,
	khoid numeric(10) NULL,
	thuocvattuid numeric(10) NULL,
	tonkholichsu varchar(400) NULL,
	gianhap numeric(16, 3) NULL,
	giaban numeric(16, 3) NULL,
	giabanphantramnhap numeric(15, 2) NULL,
	loaixuatthuocid numeric(10) DEFAULT 1 NULL,
	chidinhphongluu numeric(10) NULL,
	loaicaidatgiaban numeric(10) NULL,
	vatnhap numeric(15, 2) NULL,
	vatban numeric(15, 2) NULL,
	canhbaosoluong numeric(10) NULL,
	canhbaohsd numeric(5) NULL,
	solo varchar(20) NULL,
	hansudung timestamp NULL,
	khoa numeric(10) DEFAULT 0 NULL,
	"version" timestamp NULL,
	phongluuid numeric(10) NULL,
	sodangky varchar(50) NULL,
	sltt numeric(15, 2) NULL,
	slbuthieu numeric(15, 2) NULL,
	tylehuhao numeric(15, 2) NULL,
	sync_flag numeric(1) NULL,
	update_flag numeric(1) NULL,
	kiemkeid numeric(10) NULL,
	nguoithuchien varchar(100) NULL,
	ngaythuchien timestamp NULL,
	csytid int8 NULL,
	loai numeric(1) DEFAULT 0 NULL,
	loaibutt numeric(2) DEFAULT 0 NULL,
	giabhyt numeric(16, 3) DEFAULT 0 NULL,
	gianhandan numeric(16, 3) DEFAULT 0 NULL,
	giadichvu numeric(16, 3) DEFAULT 0 NULL,
	giatranbhyt numeric(16, 3) DEFAULT 0 NULL,
	sldauky numeric(17, 5) NULL,
	sltonkho numeric(17, 5) NULL,
	slkhadung numeric(17, 5) NULL,
	sldauky_new numeric(15, 5) DEFAULT 0 NULL,
	ngayravien timestamp DEFAULT now() NULL,
	an_tvt numeric(22) NULL,
	sltonkho_qd numeric NULL,
	slkhadung_qd numeric NULL,
	bi_xoa int4 DEFAULT 0 NOT NULL, -- Bị xóa
	ct_quydoi numeric NULL,
	CONSTRAINT duc_tonkho_pkey PRIMARY KEY (tonkhoid)
);

CREATE TABLE duc_tonkho_bk_20261708 (
	tonkhoid numeric(10) NULL,
	kyid numeric(10) NULL,
	khoid numeric(10) NULL,
	thuocvattuid numeric(10) NULL,
	tonkholichsu varchar(400) NULL,
	gianhap numeric(16, 3) NULL,
	giaban numeric(16, 3) NULL,
	giabanphantramnhap numeric(15, 2) NULL,
	loaixuatthuocid numeric(10) NULL,
	chidinhphongluu numeric(10) NULL,
	loaicaidatgiaban numeric(10) NULL,
	vatnhap numeric(15, 2) NULL,
	vatban numeric(15, 2) NULL,
	canhbaosoluong numeric(10) NULL,
	canhbaohsd numeric(5) NULL,
	solo varchar(20) NULL,
	hansudung timestamp NULL,
	khoa numeric(10) NULL,
	"version" timestamp NULL,
	phongluuid numeric(10) NULL,
	sodangky varchar(50) NULL,
	sltt numeric(15, 2) NULL,
	slbuthieu numeric(15, 2) NULL,
	tylehuhao numeric(15, 2) NULL,
	sync_flag numeric(1) NULL,
	update_flag numeric(1) NULL,
	kiemkeid numeric(10) NULL,
	nguoithuchien varchar(100) NULL,
	ngaythuchien timestamp NULL,
	csytid int8 NULL,
	loai numeric(1) NULL,
	loaibutt numeric(2) NULL,
	giabhyt numeric(16, 3) NULL,
	gianhandan numeric(16, 3) NULL,
	giadichvu numeric(16, 3) NULL,
	giatranbhyt numeric(16, 3) NULL,
	sldauky numeric(17, 5) NULL,
	sltonkho numeric(17, 5) NULL,
	slkhadung numeric(17, 5) NULL,
	sldauky_new numeric(15, 5) NULL,
	ngayravien timestamp NULL,
	an_tvt numeric(22) NULL,
	sltonkho_qd numeric NULL,
	slkhadung_qd numeric NULL,
	bi_xoa int4 NULL,
	ct_quydoi numeric NULL
);

CREATE TABLE duc_tonkhoct (
	tonkhoctid numeric(10) NOT NULL,
	kyid numeric(10) NULL,
	kiemkeid numeric(10) NULL,
	khoid numeric(10) NULL,
	nhapxuatctid numeric(10) NULL,
	thuocvattuid numeric(10) NULL,
	ma varchar NULL,
	loai numeric(10) NULL,
	kieu numeric(2) NULL,
	trangthai numeric(2) NULL,
	ngaysudungthuoc timestamp NULL,
	solo varchar(50) NULL,
	sodangky varchar(200) NULL,
	goithau varchar(50) NULL,
	hansudung timestamp NULL,
	xuatvat numeric(15, 2) NULL,
	xuatgiaban numeric(16, 3) NULL,
	vat numeric(15, 2) NULL,
	thanhtien numeric(20, 2) NULL,
	dahuy numeric(1) NULL,
	ghichu varchar(200) NULL,
	"version" timestamp NULL,
	sync_flag numeric(1) NULL,
	update_flag numeric(1) NULL,
	csytid int8 NULL,
	nhapxuatid numeric(10) NULL,
	giabhyt numeric(16, 3) NULL,
	gianhandan numeric(16, 3) NULL,
	giadichvu numeric(16, 3) NULL,
	khoa numeric(10) NULL,
	giatranbhyt numeric(16, 3) DEFAULT 0 NULL,
	tonkhoid numeric(10) NULL,
	tonkhoctid_cha numeric(10) NULL,
	tonkhoctid_goc numeric(10) NULL,
	gianhap numeric(15, 4) NULL,
	dauthauctid numeric(22) NULL,
	sldauky numeric(17, 5) DEFAULT 0 NULL,
	slbandau numeric(15, 3) DEFAULT 0 NULL,
	sltonkho numeric(17, 5) NULL,
	slkhadung numeric(17, 5) NULL,
	solansudung numeric(15, 3) NULL,
	solansdtoida numeric(15, 3) NULL,
	sldauky_new numeric(15, 3) DEFAULT 0 NULL,
	nguoikhoa varchar(250) NULL,
	ngaykhoa timestamp NULL,
	nguoithuchien varchar(250) NULL,
	ngaythuchien timestamp DEFAULT now() NULL,
	nguonchuongtrinhid numeric(22) NULL,
	ngayravien timestamp DEFAULT now() NULL,
	ct_quydoi numeric NULL,
	"giabhyt_qĐ" numeric NULL,
	gianhandan_qd numeric NULL,
	giadichvu_qd numeric NULL,
	sltonkho_qd numeric NULL,
	slkhadung_qd numeric NULL,
	id uuid DEFAULT gen_random_uuid() NULL,
	tonkhoctid_ktc numeric NULL, -- Lưu ID vật tư KTC cha
	ma_nhap varchar NULL,
	CONSTRAINT duc_tonkhoct_pkey PRIMARY KEY (tonkhoctid)
);

CREATE TABLE duc_tonkhoct_bk_20261708 (
	tonkhoctid numeric(10) NULL,
	kyid numeric(10) NULL,
	kiemkeid numeric(10) NULL,
	khoid numeric(10) NULL,
	nhapxuatctid numeric(10) NULL,
	thuocvattuid numeric(10) NULL,
	ma varchar NULL,
	loai numeric(10) NULL,
	kieu numeric(2) NULL,
	trangthai numeric(2) NULL,
	ngaysudungthuoc timestamp NULL,
	solo varchar(50) NULL,
	sodangky varchar(200) NULL,
	goithau varchar(50) NULL,
	hansudung timestamp NULL,
	xuatvat numeric(15, 2) NULL,
	xuatgiaban numeric(16, 3) NULL,
	vat numeric(15, 2) NULL,
	thanhtien numeric(20, 2) NULL,
	dahuy numeric(1) NULL,
	ghichu varchar(200) NULL,
	"version" timestamp NULL,
	sync_flag numeric(1) NULL,
	update_flag numeric(1) NULL,
	csytid int8 NULL,
	nhapxuatid numeric(10) NULL,
	giabhyt numeric(16, 3) NULL,
	gianhandan numeric(16, 3) NULL,
	giadichvu numeric(16, 3) NULL,
	khoa numeric(10) NULL,
	giatranbhyt numeric(16, 3) NULL,
	tonkhoid numeric(10) NULL,
	tonkhoctid_cha numeric(10) NULL,
	tonkhoctid_goc numeric(10) NULL,
	gianhap numeric(15, 4) NULL,
	dauthauctid numeric(22) NULL,
	sldauky numeric(17, 5) NULL,
	slbandau numeric(15, 3) NULL,
	sltonkho numeric(17, 5) NULL,
	slkhadung numeric(17, 5) NULL,
	solansudung numeric(15, 3) NULL,
	solansdtoida numeric(15, 3) NULL,
	sldauky_new numeric(15, 3) NULL,
	nguoikhoa varchar(250) NULL,
	ngaykhoa timestamp NULL,
	nguoithuchien varchar(250) NULL,
	ngaythuchien timestamp NULL,
	nguonchuongtrinhid numeric(22) NULL,
	ngayravien timestamp NULL,
	ct_quydoi numeric NULL,
	"giabhyt_qĐ" numeric NULL,
	gianhandan_qd numeric NULL,
	giadichvu_qd numeric NULL,
	sltonkho_qd numeric NULL,
	slkhadung_qd numeric NULL,
	id uuid NULL,
	tonkhoctid_ktc numeric NULL,
	ma_nhap varchar NULL
);

CREATE TABLE duc_tonkhoct_temp (
	tonkhoctid numeric(10) NOT NULL,
	kyid numeric(10) NULL,
	kiemkeid numeric(10) NULL,
	khoid numeric(10) NULL,
	nhapxuatctid numeric(10) NULL,
	thuocvattuid numeric(10) NULL,
	ma varchar NULL,
	loai numeric(10) NULL,
	kieu numeric(2) NULL,
	trangthai numeric(2) NULL,
	ngaysudungthuoc timestamp NULL,
	solo varchar(50) NULL,
	sodangky varchar(200) NULL,
	goithau varchar(50) NULL,
	hansudung timestamp NULL,
	xuatvat numeric(15) NULL,
	xuatgiaban numeric(16, 3) NULL,
	vat numeric(15) NULL,
	thanhtien numeric(20, 3) NULL,
	dahuy numeric(1) NULL,
	ghichu varchar(200) NULL,
	"version" timestamp NULL,
	sync_flag numeric(1) NULL,
	update_flag numeric(1) NULL,
	csytid int8 NULL,
	nhapxuatid numeric(10) NULL,
	giabhyt numeric(16, 3) NULL,
	gianhandan numeric(16, 3) NULL,
	giadichvu numeric(16, 3) NULL,
	khoa numeric(10) NULL,
	giatranbhyt numeric(16, 3) DEFAULT 0 NULL,
	tonkhoid numeric(10) NULL,
	tonkhoctid_cha numeric(10) NULL,
	tonkhoctid_goc numeric(10) NULL,
	gianhap numeric(15, 3) NULL,
	dauthauctid numeric(22) NULL,
	sldauky numeric(17, 3) DEFAULT 0 NULL,
	slbandau numeric(15, 3) DEFAULT 0 NULL,
	sltonkho numeric(17, 3) NULL,
	slkhadung numeric(17, 3) NULL,
	solansudung numeric(15, 3) NULL,
	solansdtoida numeric(15, 3) NULL,
	sldauky_new numeric(15, 3) DEFAULT 0 NULL,
	nguoikhoa varchar(250) NULL,
	ngaykhoa timestamp NULL,
	nguoithuchien varchar(250) NULL,
	ngaythuchien timestamp DEFAULT now() NULL,
	nguonchuongtrinhid numeric(22) NULL,
	ngayravien timestamp DEFAULT now() NULL,
	ct_quydoi numeric NULL,
	"giabhyt_qĐ" numeric NULL,
	gianhandan_qd numeric NULL,
	giadichvu_qd numeric NULL,
	sltonkho_qd numeric NULL,
	slkhadung_qd numeric NULL,
	id uuid DEFAULT gen_random_uuid() NULL,
	loi varchar NULL,
	lan numeric NULL,
	loai_import numeric NULL,
	key_flag uuid NULL,
	CONSTRAINT duc_tonkhoct_temp_pkey PRIMARY KEY (tonkhoctid)
);

CREATE TABLE duc_trangthai (
	trangthaiid numeric(10) NOT NULL,
	ma varchar(10) NULL,
	ten varchar(200) NULL,
	loai numeric(2) NULL,
	ghi_chu varchar(200) NULL,
	"version" timestamp NULL,
	sync_flag numeric(1) NULL,
	update_flag numeric(1) NULL,
	duongdananh varchar(250) NULL,
	maunen varchar(10) DEFAULT '#FFFFFF'::character varying NULL,
	mauchu varchar(10) DEFAULT '#000000'::character varying NULL,
	CONSTRAINT duc_trangthai_pkey PRIMARY KEY (trangthaiid)
);

CREATE TABLE duc_tuongtac_atc (
	tuongtacatc_id numeric(22) NOT NULL,
	dsatc varchar(200) NULL,
	loai numeric(3) NULL, -- Loại tương tác
	noidung varchar(3000) NULL,
	csytid int8 NULL,
	hauqua varchar(1000) NULL, -- Hậu quả
	xutri varchar(3000) NULL, -- Xử trí
	chongchidinh varchar(1000) NULL, -- Chống chỉ định
	tlthamkhao varchar(1000) NULL, -- Tài liệu tham khảo
	ngayravien timestamp DEFAULT now() NULL,
	hoatchatdauid varchar(100) NULL, -- Hoạt chất đầu tiên
	hoatchatthuhai varchar(100) NULL, -- Hoạt chất thứ 2
	capdotuongtacid int4 NULL, -- Cấp độ tương tác
	coche varchar(3000) NULL, -- Cơ chế
	sudung int2 DEFAULT 1 NULL, -- Sử dụng¶0 là không¶1 là sử dụng
	ghichu varchar(3000) NULL, -- Ghi chú
	bi_xoa bool DEFAULT false NULL,
	ngayxoa date NULL, -- Ngày xóa
	kiemtratuongtac bool NULL,
	CONSTRAINT duc_tuongtac_atc_pkey PRIMARY KEY (tuongtacatc_id)
);

CREATE TABLE duc_tuongtac_atc_temp (
	tuongtacatc_id numeric(22) NULL,
	dsatc varchar(200) NULL,
	loai numeric(3) NULL,
	noidung varchar(3000) NULL,
	csytid int8 NULL,
	hauqua varchar(1000) NULL,
	xutri varchar(3000) NULL,
	chongchidinh varchar(1000) NULL,
	tlthamkhao varchar(1000) NULL,
	ngayravien timestamp DEFAULT now() NULL,
	hoatchatdauid varchar(100) NULL,
	hoatchatthuhai varchar(100) NULL,
	capdotuongtacid int4 NULL,
	coche varchar(3000) NULL,
	sudung int2 DEFAULT 1 NULL,
	ghichu varchar(3000) NULL,
	bi_xoa bool DEFAULT false NULL,
	ngayxoa date NULL,
	kiemtratuongtac bool NULL,
	id uuid DEFAULT gen_random_uuid() NOT NULL,
	loi _text NULL,
	trangthai int4 DEFAULT 1 NULL, -- Trạng thái: ¶1: Mới¶2: Lỗi¶3: Thành công
	uid uuid NULL,
	lanimport int8 NULL,
	request_id text NULL,
	CONSTRAINT duc_tuongtac_atc_temp_pkey PRIMARY KEY (id)
);

CREATE TABLE duc_tuongtac_hoatchat (
	tuongtac_hoatchatid numeric(22) NOT NULL,
	mahoatchat varchar(100) NULL,
	mahoatchat_tuongtac varchar(100) NULL,
	ghichu varchar(3000) NULL,
	loaituongtacid numeric(22) NULL,
	csytid int8 NULL,
	hau_qua varchar(500) NULL,
	xu_tri varchar(3000) NULL,
	chidinh varchar(500) NULL,
	tlthamkhao varchar(1000) NULL,
	ngayravien timestamp DEFAULT now() NULL,
	soquyetdinh varchar(2000) NULL,
	cochetuongtac varchar(2000) NULL,
	ngayqd timestamp NULL,
	CONSTRAINT duc_tuongtac_hoatchat_pkey PRIMARY KEY (tuongtac_hoatchatid)
);

CREATE TABLE duc_tuongtac_thuoc_log (
	id bigserial NOT NULL,
	tiepnhan_id uuid NOT NULL,
	dotdieutri_id uuid NULL,
	benhnhan_id uuid NULL,
	thuocvattuid_1 numeric NOT NULL,
	thuocvattuid_2 numeric NOT NULL,
	hoatchat_1 varchar NULL,
	hoatchat_2 varchar NULL,
	capdotuongtacid int4 NULL,
	mauhososohoa_id uuid NULL,
	nguoi_tao uuid NULL,
	ngay_tao timestamp DEFAULT now() NOT NULL,
	bi_xoa int2 DEFAULT 0 NOT NULL,
	ghi_chu varchar NULL,
	CONSTRAINT duc_tuongtac_thuoc_log_pkey PRIMARY KEY (id),
	CONSTRAINT duc_tuongtac_thuoc_log_tiepnhan_id_thuocvattuid_1_thuocvatt_key UNIQUE (tiepnhan_id, thuocvattuid_1, thuocvattuid_2)
);

CREATE TABLE duc_vtyt_ktc (
	id uuid DEFAULT gen_random_uuid() NOT NULL,
	stt_theo_thong_tu varchar(10) NULL,
	ma_so varchar(255) NULL,
	nhom_loai_vat_tu_y_te int4 NULL,
	don_vi_tinh_id numeric NULL,
	ghi_chu text NULL,
	so_tien numeric NULL,
	ty_le_phan_tram numeric NULL,
	quyet_dinh varchar(255) NULL,
	ngay_hieu_luc date NULL,
	pham_vi_bhyt bool NULL,
	stent bool NULL,
	thiet_bi_y_te_ki_thuat_cao bool NULL,
	thanh_toan_rieng_khong_ap_tran bool NULL,
	khong_thanh_toan_rieng bool NULL,
	nguoi_tao varchar NULL,
	ngay_tao timestamp DEFAULT now() NULL,
	ngay_cap_nhat timestamp NULL,
	nguoi_cap_nhat varchar NULL,
	bi_xoa int4 DEFAULT 0 NULL,
	nguoi_xoa varchar NULL,
	ngay_xoa timestamp NULL,
	nhom_vat_tu_y_te_id int4 NULL,
	ten_nhom_loai_vtyt text NULL,
	don_vi_tinh text NULL,
	is_bo bool DEFAULT false NULL,
	danh_sach_le _uuid NULL,
	ten_vat_tu_y_te varchar NULL,
	thuocvattuid int4 NULL,
	CONSTRAINT duc_vtyt_ktc_pkey PRIMARY KEY (id)
);

CREATE TABLE duc_vtyt_ktc_ct (
	id uuid DEFAULT gen_random_uuid() NOT NULL,
	vtyt_ktc_id uuid NULL,
	su_dung bool NULL,
	ma_bo_y_te varchar(255) NULL,
	ten_vat_tu varchar(1000) NULL,
	don_vi_tinh_id numeric NULL,
	hang_san_xuat_id numeric NULL,
	nuoc_san_xuat_id numeric NULL,
	dau_thau_id numeric NULL,
	so_tien numeric NULL,
	ty_le numeric NULL,
	pham_vi_bhyt bool NULL,
	stent bool NULL,
	thiet_bi_y_te_ki_thuat_cao bool NULL,
	thanh_toan_rieng_khong_ap_tran bool NULL,
	khong_thanh_toan_rieng bool NULL,
	nguoi_tao varchar NULL,
	ngay_tao timestamp DEFAULT now() NULL,
	ghi_chu varchar NULL,
	ngay_cap_nhat timestamp NULL,
	nguoi_cap_nhat varchar NULL,
	bi_xoa int4 DEFAULT 0 NULL,
	nguoi_xoa varchar NULL,
	ngay_xoa timestamp NULL,
	thuocvt_id uuid NULL,
	CONSTRAINT duc_vtyt_ktc_ct_pkey PRIMARY KEY (id)
);

CREATE TABLE duc_vtyt_ktc_temp (
	id uuid DEFAULT gen_random_uuid() NOT NULL,
	stt int8 NULL,
	stt_theo_thong_tu varchar(255) NULL,
	ma_so varchar(255) NULL,
	nhom_vat_tu_y_te varchar(255) NULL,
	nhom_loai_vat_tu_y_te varchar(255) NULL,
	don_vi_tinh_id varchar(255) NULL,
	ghi_chu text NULL,
	so_tien varchar(255) NULL,
	ty_le_phan_tram varchar(255) NULL,
	quyet_dinh varchar(255) NULL,
	ngay_hieu_luc varchar(255) NULL,
	pham_vi_bhyt varchar(50) NULL,
	stent varchar(50) NULL,
	thiet_bi_y_te_ki_thuat_cao varchar(50) NULL,
	thanh_toan_rieng_khong_ap_tran varchar(50) NULL,
	khong_thanh_toan_rieng varchar(50) NULL,
	bi_xoa varchar(50) NULL,
	loi text NULL,
	vatuyte_ktc_id uuid NULL,
	uid varchar(255) NULL,
	request_id text NULL,
	lan_import int8 NULL,
	type_import numeric NULL,
	status numeric DEFAULT 0 NULL,
	created_at timestamp DEFAULT now() NULL,
	updated_at timestamp DEFAULT now() NULL,
	CONSTRAINT duc_vtyt_ktc_temp_pkey PRIMARY KEY (id)
);

CREATE TABLE duc_xet_nghiem_vi_sinh (
	ten varchar NULL,
	id uuid DEFAULT gen_random_uuid() NOT NULL,
	benh_pham_id uuid NULL,
	ngay_cay timestamp NULL,
	ngay_tra timestamp NULL,
	ket_qua varchar NULL,
	hoi_chan_id uuid NULL,
	ngay_tao timestamp DEFAULT now() NULL,
	CONSTRAINT duc_xet_nghiem_vi_sinh_pkey PRIMARY KEY (id)
);

CREATE TABLE dutruct_temp (
	nhapxuatctid numeric(10) NOT NULL,
	kyid numeric(10) NULL,
	kiemkeid numeric(10) NULL,
	tonkhoid numeric(10) NULL,
	thuocvattuid numeric(10) NULL,
	khoid numeric(10) NULL,
	nhapxuatid numeric(10) NULL,
	ma varchar(30) NULL,
	loai numeric(10) NULL,
	trangthaiid numeric(10) NULL,
	kieu numeric(10) NULL,
	ngaysudungthuoc timestamp NULL,
	nhacungcapid numeric(10) NULL,
	nguonchuongtrinhid numeric(10) NULL,
	ghichu varchar(500) NULL,
	khoaid numeric(6) NULL,
	phongid numeric(6) NULL,
	nguoidungid numeric(10) NULL,
	solo varchar(50) NULL,
	sodangky varchar(200) NULL,
	goithau varchar(50) NULL,
	hansudung timestamp NULL,
	xuatvat numeric(15, 2) NULL,
	xuatgiaban numeric(16, 3) NULL,
	ngaythang timestamp NULL,
	thanhtien numeric(20, 2) NULL,
	ngayduyet timestamp NULL,
	sotienduyet numeric(15, 2) NULL,
	vatduyet numeric(15, 2) NULL,
	ngaynhan timestamp NULL,
	sotiennhan numeric(15, 2) NULL,
	vatnhan numeric(15, 2) NULL,
	ngayketthuc timestamp NULL,
	sotienketthuc numeric(15, 2) NULL,
	vatketthuc numeric(15, 2) NULL,
	dahuy numeric(10) NULL,
	dichvuid numeric(10) NULL,
	dsdichvuid varchar(200) NULL,
	phieubuthieu numeric(10) NULL,
	ghichulinhthuoc varchar(400) NULL,
	"version" timestamp NULL,
	sync_flag numeric(1) NULL,
	update_flag numeric(1) NULL,
	tonkhoctid numeric(10) NULL,
	nguoithuchien varchar(300) NULL,
	ngaythuchien timestamp NULL,
	csytid int8 NULL,
	hinhthucid numeric(2) NULL,
	nhapxuatctid_cha numeric(10) NULL,
	giabhyt numeric(16, 3) NULL,
	gianhandan numeric(16, 3) NULL,
	giadichvu numeric(16, 3) NULL,
	giatranbhyt numeric(16, 3) DEFAULT 0 NULL,
	ngaynx timestamp DEFAULT now() NULL,
	gianhap numeric(20, 6) NULL,
	dauthauid numeric(22) NULL,
	dutruid numeric(22) NULL,
	dauthauctid numeric(22) NULL,
	sodukhadung numeric(17, 5) NULL,
	soluongduyet numeric(17, 5) NULL,
	soluongnhan numeric(17, 5) NULL,
	soluongketthuc numeric(17, 5) NULL,
	soluong numeric(17, 5) NULL,
	solansudung numeric(15) NULL,
	dvtnhanid numeric(22) NULL,
	chietkhau numeric(22) NULL,
	loaichietkhau numeric(1) DEFAULT 0 NULL,
	tylechietkhau numeric(22) NULL,
	giachietkhau numeric(22) NULL,
	ct_quydoi numeric NULL,
	"giabhyt_qĐ" numeric NULL,
	gianhandan_qd numeric NULL,
	giadichvu_qd numeric NULL,
	soluongquydoi numeric(17, 5) NULL,
	id uuid DEFAULT gen_random_uuid() NULL,
	uid uuid NULL,
	CONSTRAINT dutruct_temp_pkey PRIMARY KEY (nhapxuatctid)
);

CREATE TABLE eclaim_checkin (
	ma_lk varchar(100) NULL,
	stt int4 NULL,
	ma_bn varchar(100) NULL,
	ho_ten varchar(255) NULL,
	so_cccd varchar NULL,
	ngay_sinh varchar(12) NULL,
	gioi_tinh varchar(1) NULL,
	ma_the_bhyt varchar(50) NULL,
	ma_dkbd varchar(25) NULL,
	gt_the_tu varchar(8) NULL,
	gt_the_den varchar(8) NULL,
	ma_doituong_kcb varchar(4) NULL,
	ngay_vao varchar(12) NULL,
	ngay_vao_noi_tru varchar(12) NULL,
	ly_do_vnt varchar NULL,
	ma_ly_do_vnt varchar(5) NULL,
	ma_loai_kcb varchar(2) NULL,
	ma_cskcb varchar(5) NULL,
	ma_dich_vu varchar(50) NULL,
	ten_dich_vu varchar(1024) NULL,
	ma_thuoc varchar(255) NULL,
	ten_thuoc varchar(1024) NULL,
	ma_vat_tu varchar(255) NULL,
	ten_vat_tu varchar(1024) NULL,
	ngay_yl varchar(12) NULL,
	du_phong varchar NULL,
	id uuid DEFAULT gen_random_uuid() NOT NULL,
	ngay_tao timestamp DEFAULT now() NOT NULL,
	nguoi_tao varchar(100) DEFAULT 'system'::character varying NOT NULL,
	ngay_cap_nhat timestamp DEFAULT now() NOT NULL,
	nguoi_cap_nhat varchar(100) DEFAULT 'system'::character varying NOT NULL,
	bi_xoa int2 DEFAULT 0 NULL,
	ngay_xoa timestamp NULL,
	nguoi_xoa varchar(100) NULL,
	tiep_nhan_id uuid NULL,
	export int2 NULL,
	so_lan int4 NULL,
	thoi_gian_checkin timestamp NULL,
	so_lan_checkin int4 NULL,
	CONSTRAINT eclaim_checkin_pk_id PRIMARY KEY (id)
);

CREATE TABLE eclaim_data_xml1 (
	id uuid DEFAULT gen_random_uuid() NOT NULL,
	ma_lk varchar(100) NOT NULL,
	stt varchar(10) NULL,
	ma_bn varchar(100) NOT NULL,
	ho_ten varchar(255) NOT NULL,
	so_cccd varchar(12) NULL,
	ngay_sinh varchar(12) NOT NULL,
	gioi_tinh varchar(1) NOT NULL,
	nhom_mau varchar(5) NULL,
	ma_quoctich varchar(3) NOT NULL,
	ma_dantoc varchar(2) NOT NULL,
	ma_nghe_nghiep varchar(5) NULL,
	dia_chi varchar(1024) NOT NULL,
	matinh_cu_tru varchar(3) NOT NULL,
	mahuyen_cu_tru varchar(3) NULL,
	maxa_cu_tru varchar(5) NULL,
	dien_thoai varchar(15) NULL,
	ma_the_bhyt varchar(255) NULL,
	ma_dkbd varchar(255) NOT NULL,
	gt_the_tu varchar(255) NOT NULL,
	gt_the_den varchar(255) NOT NULL,
	ngay_mien_cct varchar(12) NULL,
	ly_do_vv text NOT NULL,
	ly_do_vnt text NULL,
	ma_ly_do_vnt varchar(5) NULL,
	chan_doan_vao text NOT NULL,
	chan_doan_rv text NOT NULL,
	ma_benh_chinh varchar(7) NOT NULL,
	ma_benh_kt varchar(100) NULL,
	ma_benh_yhct varchar(150) NULL,
	ma_pttt_qt varchar(125) NULL,
	ma_doituong_kcb varchar(10) NOT NULL,
	ma_noi_di varchar(5) NULL,
	ma_noi_den varchar(5) NULL,
	ma_tai_nan varchar(50) NULL,
	ngay_vao varchar(24) NOT NULL,
	ngay_vao_noi_tru varchar(24) NULL,
	ngay_ra varchar(24) NOT NULL,
	giay_chuyen_tuyen varchar(50) NULL,
	so_ngay_dtri varchar(3) NOT NULL,
	pp_dieu_tri text NULL,
	ket_qua_dtri varchar(50) NOT NULL,
	ma_loai_rv varchar(50) NOT NULL,
	ghi_chu text NULL,
	ngay_ttoan varchar(12) NULL,
	t_thuoc numeric(15, 2) NOT NULL,
	t_vtyt numeric(15, 2) NOT NULL,
	t_tongchi_bv numeric(15, 2) NOT NULL,
	t_tongchi_bh numeric(15, 2) NOT NULL,
	t_bntt numeric(15, 2) NOT NULL,
	t_bncct numeric(15, 2) NOT NULL,
	t_bhtt numeric(15, 2) NOT NULL,
	t_nguonkhac numeric(15, 2) NOT NULL,
	t_bhtt_gdv numeric(15, 2) NOT NULL,
	nam_qt int4 NOT NULL,
	thang_qt int4 NOT NULL,
	ma_loai_kcb varchar(50) NOT NULL,
	ma_khoa varchar(50) NOT NULL,
	ma_cskcb varchar(5) NOT NULL,
	ma_khuvuc varchar(50) NULL,
	can_nang varchar(6) NULL,
	can_nang_con varchar(100) NULL,
	nam_nam_lien_tuc varchar(8) NULL,
	ngay_tai_kham varchar(50) NULL,
	ma_hsba varchar(100) NOT NULL,
	ma_ttdv varchar(255) NULL,
	du_phong text NULL,
	xacnhanchiphi_id uuid NULL,
	thoigiannhapnhan timestamp NULL,
	thoigianravien timestamp NULL,
	ngay_xuat_file timestamp NULL,
	tiepnhan_id uuid NULL,
	bi_xoa int2 DEFAULT 0 NOT NULL,
	nguoi_tao varchar(100) NULL,
	ngay_tao timestamp DEFAULT CURRENT_TIMESTAMP NULL,
	nguoi_cap_nhat varchar(100) NULL,
	ngay_cap_nhat timestamp DEFAULT CURRENT_TIMESTAMP NULL,
	nguoi_xoa varchar(100) NULL,
	ngay_xoa timestamp NULL,
	CONSTRAINT eclaim_data_xml1_pkey PRIMARY KEY (id)
);

CREATE TABLE eclaim_data_xml10 (
	tiep_nhan_id uuid NOT NULL, -- ID Tiếp nhận
	ma_lk varchar(100) NOT NULL, -- Mã liên kết
	so_seri varchar(200) NOT NULL, -- Số seri
	so_ct varchar(200) NOT NULL, -- Số chứng từ
	don_vi varchar(1024) NOT NULL, -- Đơn vị
	chan_doan_rv text NOT NULL, -- Chẩn đoán ra viện
	tu_ngay varchar(8) NOT NULL, -- Từ ngày (yyyymmdd)
	den_ngay varchar(8) NOT NULL, -- Đến ngày (yyyymmdd)
	ma_ttdv varchar(255) NOT NULL, -- Mã người ký
	ten_bs varchar(255) NOT NULL, -- Tên bác sĩ
	ma_bs varchar(255) NOT NULL, -- Mã bác sĩ
	ngay_ct varchar(8) NOT NULL, -- Ngày chứng từ (yyyymmdd)
	du_phong text NULL, -- Dữ liệu dự phòng
	id uuid DEFAULT gen_random_uuid() NOT NULL, -- Key của bảng
	ngay_tao timestamp DEFAULT now() NOT NULL, -- Ngày tạo
	nguoi_tao varchar(100) DEFAULT 'system'::character varying NOT NULL, -- Người tạo
	ngay_cap_nhat timestamp DEFAULT now() NOT NULL, -- Ngày cập nhật
	nguoi_cap_nhat varchar(100) DEFAULT 'system'::character varying NOT NULL, -- Người cập nhật
	bi_xoa int2 DEFAULT 0 NULL, -- Bị xóa mềm
	ngay_xoa timestamp NULL, -- Ngày xóa mềm
	nguoi_xoa varchar(100) NULL, -- Người xóa mềm
	so_ngay varchar(3) NOT NULL, -- Số ngày
	ngay_xuat_file timestamp NULL, -- Ngày xuất file
	CONSTRAINT eclaim_data_xml10_pkey PRIMARY KEY (id)
);

CREATE TABLE eclaim_data_xml11 (
	ma_lk varchar(100) NOT NULL, -- Là mã đợt điều trị duy nhất (dùng để liên kết giữa Bảng chỉ tiêu tổng hợp khám bệnh, chữa bệnh (bảng XML 1) và các bảng còn lại ban hành kèm theo Quyết định này trong một lần khám bệnh, chữa bệnh (PRIMARY KEY)).
	so_ct varchar(200) NOT NULL, -- Ghi số chứng từ, là mã lưu trữ giấy chứng nhận nghỉ việc hưởng BHXH tại cơ sở KBCB.
	so_seri varchar(200) NOT NULL, -- Ghi số định danh chứng từ (Giấy chứng nhận nghỉ việc hưởng BHXH) của mỗi đợt điều trị theo quy định của cơ sở KBCB.
	so_kcb varchar(200) NOT NULL, -- Ghi số chứng từ phục vụ việc quản lý nội bộ của cơ sở KBCB theo Phụ lục 07 Thông tư 18/2022/TT-BYT của Bộ trưởng Bộ Y tế.
	id uuid DEFAULT gen_random_uuid() NOT NULL, -- Key của bảng
	ngay_tao timestamp DEFAULT now() NOT NULL, -- Ngày tạo
	nguoi_tao varchar(100) DEFAULT 'system'::character varying NOT NULL, -- Người tạo
	ngay_cap_nhat timestamp DEFAULT now() NOT NULL, -- Ngày cập nhật
	nguoi_cap_nhat varchar(100) DEFAULT 'system'::character varying NOT NULL, -- Người cập nhật
	bi_xoa int2 DEFAULT 0 NULL, -- Bị xóa mềm
	ngay_xoa timestamp NULL, -- Ngày xóa mềm
	nguoi_xoa varchar(100) NULL, -- Người xóa mềm
	don_vi varchar(1024) NOT NULL, -- Ghi tên đơn vị của người hưởng BHXH.¶Lưu ý: ghi rõ đơn vị nơi người bệnh làm việc và đóng BHXH theo thông tin người đến khám cung cấp; trường hợp con ốm thì ghi đơn vị của cha/mẹ đang làm việc và đóng BHXH.
	ma_bhxh varchar(20) NOT NULL, -- Ghi mã số BHXH của người bệnh.
	ma_the_bhyt text NOT NULL, -- Ghi mã thẻ BHYT của người bệnh do cơ quan BHXH cấp. Có thể ghi nhiều mã (mỗi mã 15 ký tự) cách nhau bằng “;” khi trong quá trình điều trị đổi thẻ. Trường hợp người bệnh không KBCB BHYT thì để trống.
	chan_doan_rv text NOT NULL, -- Ghi đầy đủ chẩn đoán xác định bệnh chính, bệnh kèm theo và/hoặc triệu chứng/hội chứng tại thời điểm kết thúc KBCB. Phục vụ lập giấy CN nghỉ việc hưởng BHXH theo TT 18/2022/TT-BYT, trong đó: chẩn đoán mô tả cụ thể tình trạng sức khỏe hoặc ghi tên/mã bệnh; bệnh dài ngày ghi mã bệnh (chưa có mã thì ghi đủ tên bệnh theo TT 46/2016/TT-BYT); điều trị dưỡng thai ghi rõ cụm từ “dưỡng thai”.
	pp_dieutri text NOT NULL, -- Ghi phương pháp điều trị cho người bệnh: nội khoa, ngoại khoa, xoa trị, hóa trị hoặc xạ trị + nội khoa.
	ma_dinh_chi_thai int2 NULL, -- Ghi mã “1” là đình chỉ thai nghén, mã “0” là không đình chỉ thai nghén. Trường hợp đình chỉ thai nghén bắt buộc nhập Tuổi thaivà Nguyên nhân đình chỉ.
	nguyennhan_dinhchi text NULL, -- Ghi nguyên nhân đình chỉ thai nghén. Bắt buộc khi Mã đình chỉ thai = 1.
	tuoi_thai int4 NULL, -- Ghi tuổi thai thực tế (theo tuần), tuổi thai ≥ 1 và ≤ 42 tuần. Bắt buộckhi Mã đình chỉ thai = 1.
	so_ngay_nghi int4 NOT NULL, -- Ghi số ngày nghỉ căn cứ tình trạng sức khỏe người bệnh. Lưu ý giới hạn theo quy định (ví dụ tối đa 30 ngày/lần; trường hợp bệnh dài ngày/đặc thù áp dụng giới hạn theo quy định).
	tu_ngay varchar(8) NOT NULL, -- Ghi ngày bắt đầu hưởng chế độ theo định dạng yyyymmdd và phải trùng với ngày người bệnh đến khám.
	den_ngay varchar(8) NOT NULL, -- Ghi ngày kết thúc hưởng chế độ theo định dạng yyyymmdd.
	ho_ten_cha varchar(200) NULL, -- Ghi họ và tên cha (bố) của người bệnh (nếu có) trong trường hợp người bệnh là trẻ em dưới 07 tuổi; không có thì để trống.
	ho_ten_me varchar(255) NULL, -- Ghi họ và tên mẹ của người bệnh (nếu có) trong trường hợp người bệnh là trẻ em dưới 07 tuổi; không có thì để trống.
	ma_ttdv varchar(255) NOT NULL, -- Ghi mã của người đứng đầu cơ sở KBCB hoặc người được ủy quyền ký để cấp giấy CN nghỉ việc hưởng BHXH (mã hóa theo số GPHN).
	ma_bs varchar(255) NOT NULL, -- Ghi mã của Trưởng khoa/Trưởng phòng/Phó trưởng khoa/Phó trưởng phòng/Bác sỹ hành nghề KBCB ký tên theo quy định của Thủ trưởng cơ sở KBCB (mã hóa theo số GPHN).
	ngay_ct varchar(8) NOT NULL, -- Ghi ngày cấp chứng từ (Giấy CN nghỉ việc hưởng BHXH) theo định dạng yyyymmdd và phải trùng với ngày người lao động đến khám; nếu đợt khám kéo dài ≥ 2 ngày thì là ngày cuối cùng của đợt khám và được chỉ định nghỉ ngoại trú.
	ma_the_tam varchar(15) NULL, -- Ghi mã thẻ BHYT tạm thời của trẻ em sinh ra hoặc người hiến tạng chưa được BHXH cấp thẻ BHYT (tra cứu theo hướng dẫn).
	mau_so varchar(5) NOT NULL, -- Các cơ sở KBCB dùng chuỗi CT07 để xác định mẫu giấy; nếu không điền thì hệ thống tự điền CT07.
	du_phong text NULL, -- Trường dữ liệu dự phòng khi cần thiết.
	CONSTRAINT eclaim_data_xml11_pkey PRIMARY KEY (id)
);

CREATE TABLE eclaim_data_xml13 (
	ma_lk varchar(100) NOT NULL, -- Là mã đợt điều trị duy nhất (dùng để liên kết giữa Bảng chỉ tiêu tổng hợp khám bệnh, chữa bệnh (bảng XML 1) và các bảng còn lại ban hành kèm theo Quyết định này trong một lần khám bệnh, chữa bệnh (PRIMARY KEY))
	id uuid DEFAULT gen_random_uuid() NOT NULL, -- Key của bảng
	ngay_tao timestamp DEFAULT now() NOT NULL, -- Ngày tạo
	nguoi_tao varchar(100) DEFAULT 'system'::character varying NOT NULL, -- Người tạo
	ngay_cap_nhat timestamp DEFAULT now() NOT NULL, -- Ngày cập nhật
	nguoi_cap_nhat varchar(100) DEFAULT 'system'::character varying NOT NULL, -- Người cập nhật
	bi_xoa int2 DEFAULT 0 NULL, -- Bị xóa mềm
	ngay_xoa timestamp NULL, -- Ngày xóa mềm
	nguoi_xoa varchar(100) NULL, -- Người xóa mềm
	so_hoso varchar(50) NOT NULL, -- Ghi số hồ sơ giấy chuyển tuyến KBCB BHYT/giấy chuyển cơ sở KBCB do cơ sở KBCB quy định theo mẫu số 6 của Phụ lục ban hành kèm theo Nghị định 75/2023/NĐ-CP của Chính phủ
	so_chuyentuyen varchar(50) NOT NULL, -- Ghi số của sổ chuyển tuyến/chuyển cơ sở KBCB do cơ sở KBCB quy định theo mẫu số 6 của Phụ lục ban hành kèm theo Nghị định 75/2023/NĐ-CP của Chính phủ.
	giay_chuyen_tuyen varchar(50) NOT NULL, -- Ghi số giấy chuyển tuyến/chuyển cơ sở KBCB do cơ sở KBCB cấp theo mẫu số 6 của Phụ lục ban hành kèm theo Nghị định 75/2023/NĐ-CP của Chính phủ.
	ma_cskcb varchar(5) NOT NULL, -- Ghi mã cơ sở KBCB nơi cấp giấy chuyển tuyến/giấy chuyển cơ sở KBCB
	ma_noi_di varchar(100) NOT NULL, -- Ghi tương tự hướng dẫn tại trường MA_NOI_DI tại Bảng 1, trường hợp người bệnh được chuyển từ nhiều cơ sở KCB đến thì ghi lần lượt mã của từng cơ sở KCB, cách nhau bằng dấu chấm phẩy (;)
	ma_noi_den varchar(5) NOT NULL, -- Ghi theo hướng dẫn trường MA_NOI_DEN tại Bảng 1
	ho_ten varchar(255) NOT NULL, -- Ghi họ và tên của người bệnh được chuyển tuyến/chuyển cơ sở KBCB
	ngay_sinh varchar(12) NOT NULL,
	gioi_tinh varchar(10) NOT NULL, -- Giới tính
	ma_quoctich varchar(3) NOT NULL, -- Mã quốc tịch
	ma_dantoc varchar(2) NOT NULL, -- Mã dân tộc
	ma_nghe_nghiep varchar(5) NOT NULL, -- Mã nghề nghiệp
	dia_chi varchar(1024) NOT NULL, -- Địa chỉ
	ma_the_bhyt text NOT NULL, -- Mã thẻ BHYT
	gt_the_den text NOT NULL, -- Giá trị thẻ đến
	ngay_vao varchar(12) NOT NULL, -- Ngày vào
	ngay_vao_noi_tru varchar(12) NULL, -- Ngày vào nội trú
	ngay_ra varchar(12) NOT NULL, -- Ngày ra
	dau_hieu_ls text NOT NULL, -- Dấu hiệu lâm sàng
	chan_doan_rv text NOT NULL, -- Chẩn đoán ra viện
	qt_benhly text NOT NULL, -- Quá trình bệnh lý
	tomtat_kq text NOT NULL, -- Tóm tắt kết quả cận lâm sàng
	pp_dieutri text NOT NULL, -- Phương pháp điều trị
	ma_benh_chinh varchar(7) NOT NULL, -- Mã bệnh chính
	ma_benh_kt varchar(100) NULL, -- Mã bệnh kèm theo
	ma_benh_yhct varchar(255) NULL, -- Mã bệnh YHCT
	tinh_trang_ct text NOT NULL, -- Tình trạng chuyển tuyến
	ma_loai_rv varchar(25) NOT NULL, -- Mã loại ra viện
	ma_lydo_ct varchar(50) NOT NULL, -- Mã lý do chuyển tuyến
	huong_dieu_tri text NOT NULL, -- Hướng điều trị
	phuongtien_vc varchar(255) NOT NULL, -- Ghi phương tiện vận chuyển người bệnh khi thực hiện chuyển tuyến/chuyển cơ sở KBCB
	hoten_nguoi_ht varchar(255) NULL, -- Ghi họ tên người hộ tống (nếu có)
	chucdanh_nguoi_ht varchar(255) NULL, -- Ghi chức danh người hộ tống (nếu có)
	ma_bac_si varchar(255) NOT NULL, -- Ghi mã người hành nghề chỉ định chuyển tuyến/chuyển cơ sở KBCB (mã hóa theo số GPHN)¶Lưu ý: Trường hợp người hành nghề được huy động, điều động tham gia phòng, chống dịch hoặc thiên tai, thảm họa tại cơ sở KBCB khác, mã hoá theo nguyên tắc: MA_BAC_SI.HD.XXXXX, trong đó MA_BAC_SI ghi theo số GPHN của người hành nghề được điều động, XXXXX là mã cơ sở KCB nơi cử người hành nghề đi; trường hợp người hành nghề không đăng ký hành nghề nhưng được huy động thì XXXXX ghi 2 ký tự đầu là mã tỉnh nơi ra quyết định huy động, 3 ký tự sau ghi XXX.
	ma_ttdv varchar(255) NOT NULL, -- Ghi mã của người đứng đầu cơ sở KBCB hoặc người được người đứng đầu cơ sở KBCB ủy quyền được ký giấy chuyển tuyến KBCB BHYT/chuyển cơ sở KBCB (mã hoá theo số GPHN). Trường hợp không có GPHN thì ghi số căn cước công dân hoặc số định danh cá nhân.
	du_phong text NULL, -- Dự phòng
	CONSTRAINT eclaim_data_xml13_pkey PRIMARY KEY (id)
);

CREATE TABLE eclaim_data_xml14 (
	tiep_nhan_id uuid NOT NULL, -- ID tiếp nhận
	ma_lk varchar(100) NOT NULL, -- Mã liên kết
	so_giay_hen_kl varchar(50) NOT NULL, -- Số giấy hẹn khám lại
	ma_cskcb varchar(5) NOT NULL, -- Mã cơ sở khám chữa bệnh
	ho_ten varchar(255) NOT NULL, -- Họ tên
	ngay_sinh varchar(12) NOT NULL, -- Ngày sinh
	gioi_tinh varchar(1) NOT NULL, -- Giới tính
	dia_chi varchar(1024) NOT NULL, -- Địa chỉ
	ma_the_bhyt varchar(100) NOT NULL, -- Mã thẻ BHYT
	gt_the_den varchar(100) NOT NULL, -- Giá trị thẻ đến
	ngay_vao varchar(12) NOT NULL, -- Ngày vào
	ngay_vao_noi_tru varchar(12) NULL, -- Ngày vào nội trú
	ngay_ra varchar(12) NOT NULL, -- Ngày ra
	ngay_hen_kl varchar(8) NOT NULL, -- Ngày hẹn khám lại
	chan_doan_rv text NOT NULL, -- Chẩn đoán ra viện
	ma_benh_chinh varchar(7) NOT NULL, -- Mã bệnh chính
	ma_benh_kt varchar(100) NULL, -- Mã bệnh kèm theo
	ma_benh_yhct varchar(255) NULL, -- Mã bệnh y học cổ truyền
	ma_doi_tuong_kcb varchar(4) NOT NULL, -- Mã đối tượng khám chữa bệnh - benh_nhan_dot_dieu_tri.ma_doi_tuong_lt
	ma_bac_si varchar(255) NOT NULL, -- Mã bác sĩ
	ma_ttdv varchar(255) NOT NULL, -- Mã thủ trưởng đơn vị
	ngay_ct varchar(8) NOT NULL, -- Ngày chứng từ (yyyymmdd)
	du_phong text NULL, -- Dự phòng
	ngay_xuat_file timestamp NULL, -- Ngày xuất file
	id uuid DEFAULT gen_random_uuid() NOT NULL, -- Key của bảng
	ngay_tao timestamp DEFAULT now() NOT NULL, -- Ngày tạo
	nguoi_tao varchar(100) DEFAULT 'system'::character varying NOT NULL, -- Người tạo
	ngay_cap_nhat timestamp DEFAULT now() NOT NULL, -- Ngày cập nhật
	nguoi_cap_nhat varchar(100) DEFAULT 'system'::character varying NOT NULL, -- Người cập nhật
	bi_xoa int2 DEFAULT 0 NULL, -- Bị xóa mềm
	ngay_xoa timestamp NULL, -- Ngày xóa mềm
	nguoi_xoa varchar(100) NULL, -- Người xóa mềm
	CONSTRAINT eclaim_data_xml14_pkey PRIMARY KEY (id)
);

CREATE TABLE eclaim_data_xml2 (
	id uuid DEFAULT gen_random_uuid() NOT NULL,
	ma_lk varchar(100) NOT NULL,
	stt int4 NULL,
	ma_thuoc varchar(255) NOT NULL,
	ma_pp_chebien varchar(255) NULL,
	ma_cskcb_thuoc varchar(50) NULL,
	ma_nhom int4 NOT NULL,
	ten_thuoc varchar(1024) NOT NULL,
	don_vi_tinh varchar(50) NOT NULL,
	ham_luong varchar(1024) NULL,
	duong_dung varchar(4) NOT NULL,
	dang_bao_che varchar(1024) NULL,
	lieu_dung varchar(1024) NOT NULL,
	cach_dung varchar(1024) NULL,
	so_dang_ky varchar(255) NULL,
	tt_thau varchar(50) NULL,
	pham_vi int4 NOT NULL,
	tyle_tt_bh int4 NOT NULL,
	so_luong numeric(10, 2) NOT NULL,
	don_gia numeric(15, 2) NOT NULL,
	thanh_tien_bv numeric(15, 2) NOT NULL,
	thanh_tien_bh numeric(15, 2) NOT NULL,
	t_nguonkhac_nsnn numeric(15, 2) NULL,
	t_nguonkhac_vtnn numeric(15, 2) NULL,
	t_nguonkhac_vttn numeric(15, 2) NULL,
	t_nguonkhac_cl numeric(15, 2) NULL,
	t_nguonkhac numeric(15, 2) NULL,
	muc_huong int4 NULL,
	t_bntt numeric(15, 2) NULL,
	t_bncct numeric(15, 2) NULL,
	t_bhtt numeric(15, 2) NULL,
	ma_khoa varchar(50) NULL,
	ma_bac_si varchar(255) NULL,
	ma_dich_vu varchar(255) NULL,
	ngay_yl varchar(12) NULL,
	ngay_th_yl varchar(12) NULL,
	ma_pttt int4 NULL,
	nguon_ctra int4 NULL,
	vet_thuong_tp int4 NULL,
	du_phong text NULL,
	xacnhanchiphi_id uuid NULL,
	thoigianxacnhan timestamp NULL,
	tiepnhan_id uuid NULL,
	benhan_id uuid NULL,
	thoigianra timestamp NULL,
	bi_xoa int2 DEFAULT 0 NOT NULL,
	nguoi_tao varchar(100) NULL,
	ngay_tao timestamp DEFAULT CURRENT_TIMESTAMP NULL,
	nguoi_cap_nhat varchar(100) NULL,
	ngay_cap_nhat timestamp DEFAULT CURRENT_TIMESTAMP NULL,
	nguoi_xoa varchar(100) NULL,
	ngay_xoa timestamp NULL,
	CONSTRAINT eclaim_data_xml2_pkey PRIMARY KEY (id)
);

CREATE TABLE eclaim_data_xml3 (
	id uuid DEFAULT gen_random_uuid() NOT NULL,
	ma_lk varchar(100) NOT NULL,
	stt int4 NOT NULL,
	ma_dich_vu varchar(50) NOT NULL,
	ma_pttt_qt varchar(255) NULL,
	ma_vat_tu varchar(255) NULL,
	ma_nhom int4 NOT NULL,
	goi_vtyt varchar(3) NULL,
	ten_vat_tu varchar(1024) NULL,
	ten_dich_vu varchar(1024) NULL,
	ma_xang_dau varchar(20) NULL,
	don_vi_tinh varchar(50) NOT NULL,
	pham_vi int4 NOT NULL,
	so_luong numeric(10, 2) NOT NULL,
	don_gia_bv numeric(15, 2) NOT NULL,
	don_gia_bh numeric(15, 2) NOT NULL,
	tt_thau varchar(50) NULL,
	tyle_tt_dv int4 NOT NULL,
	tyle_tt_bh int4 NOT NULL,
	thanh_tien_bv numeric(15, 2) NOT NULL,
	thanh_tien_bh numeric(15, 2) NOT NULL,
	t_trantt numeric(15, 2) NULL,
	muc_huong varchar(25) NOT NULL,
	t_nguonkhac_nsnn numeric(15, 2) NOT NULL,
	t_nguonkhac_vtnn numeric(15, 2) NOT NULL,
	t_nguonkhac_vttn numeric(15, 2) NOT NULL,
	t_nguonkhac_cl numeric(15, 2) NOT NULL,
	t_nguonkhac numeric(15, 2) NOT NULL,
	t_bntt numeric(15, 2) NOT NULL,
	t_bncct numeric(15, 2) NOT NULL,
	t_bhtt numeric(15, 2) NOT NULL,
	ma_khoa varchar(50) NOT NULL,
	ma_giuong varchar(50) NULL,
	ma_bac_si varchar(255) NOT NULL,
	nguoi_thuc_hien varchar(255) NULL,
	ma_benh varchar(100) NULL,
	ma_benh_yhct varchar(150) NULL,
	ngay_yl varchar(12) NOT NULL,
	ngay_th_yl varchar(12) NULL,
	ngay_kq varchar(12) NULL,
	ma_pttt int4 NOT NULL,
	vet_thuong_tp int4 NULL,
	pp_vo_cam int4 NULL,
	vi_tri_th_dvkt int4 NULL,
	ma_may varchar(1024) NULL,
	ma_hieu_sp varchar(255) NULL,
	tai_su_dung int4 NULL,
	du_phong text NULL,
	xacnhanchiphi_id uuid NULL,
	thoigianxacnhan timestamp NULL,
	tiepnhan_id uuid NULL,
	benhan_id uuid NULL,
	thoigianra timestamp NULL,
	ref_id int4 NULL,
	bi_xoa int2 DEFAULT 0 NOT NULL,
	nguoi_tao varchar(100) NULL,
	ngay_tao timestamp DEFAULT CURRENT_TIMESTAMP NULL,
	nguoi_cap_nhat varchar(100) NULL,
	ngay_cap_nhat timestamp DEFAULT CURRENT_TIMESTAMP NULL,
	nguoi_xoa varchar(100) NULL,
	ngay_xoa timestamp NULL,
	CONSTRAINT eclaim_data_xml3_pkey PRIMARY KEY (id)
);

CREATE TABLE eclaim_data_xml4 (
	id uuid DEFAULT gen_random_uuid() NOT NULL,
	ma_lk varchar(100) NOT NULL,
	stt varchar(10) NULL,
	ma_dich_vu varchar(50) NULL,
	ma_chi_so varchar(255) NULL,
	ten_chi_so varchar(255) NOT NULL,
	gia_tri varchar(255) NULL,
	don_vi_do varchar(50) NULL,
	mo_ta text NULL,
	ket_luan text NULL,
	ngay_kq varchar(12) NULL,
	ma_bs_doc_kq varchar(255) NOT NULL,
	du_phong text NULL,
	tiepnhan_id uuid NOT NULL,
	bi_xoa int2 DEFAULT 0 NOT NULL,
	nguoi_tao varchar(100) NULL,
	ngay_tao timestamp DEFAULT CURRENT_TIMESTAMP NULL,
	nguoi_cap_nhat varchar(100) NULL,
	ngay_cap_nhat timestamp DEFAULT CURRENT_TIMESTAMP NULL,
	nguoi_xoa varchar(100) NULL,
	ngay_xoa timestamp NULL,
	CONSTRAINT eclaim_data_xml4_pkey PRIMARY KEY (id)
);

CREATE TABLE eclaim_data_xml5 (
	id uuid DEFAULT gen_random_uuid() NOT NULL,
	ma_lk varchar(100) NOT NULL,
	stt varchar(10) NULL,
	dien_bien_ls text NOT NULL,
	giai_doan_benh text NULL,
	hoi_chan text NULL,
	phau_thuat text NULL,
	thoi_diem_dbls varchar(12) NULL,
	nguoi_thuc_hien varchar(255) NOT NULL,
	du_phong text NULL,
	tiepnhan_id uuid NOT NULL,
	bi_xoa int2 DEFAULT 0 NOT NULL,
	nguoi_tao varchar(100) NULL,
	ngay_tao timestamp DEFAULT CURRENT_TIMESTAMP NULL,
	nguoi_cap_nhat varchar(100) NULL,
	ngay_cap_nhat timestamp DEFAULT CURRENT_TIMESTAMP NULL,
	nguoi_xoa varchar(100) NULL,
	ngay_xoa timestamp NULL,
	CONSTRAINT eclaim_data_xml5_pkey PRIMARY KEY (id)
);

CREATE TABLE eclaim_data_xml7 (
	id uuid DEFAULT gen_random_uuid() NOT NULL,
	ma_lk varchar(100) NOT NULL,
	so_luu_tru varchar(200) NULL,
	ma_yte varchar(200) NOT NULL,
	ma_khoa_rv varchar(200) NOT NULL,
	ngay_vao varchar(12) NOT NULL,
	ngay_ra varchar(12) NOT NULL,
	ma_dinh_chi_thai int2 NULL,
	nguyennhan_dinhchi text NULL,
	thoigian_dinhchi varchar(12) NULL,
	tuoi_thai int2 NULL,
	chan_doan_rv varchar(1500) NOT NULL,
	pp_dieutri text NOT NULL,
	ghi_chu varchar(1500) NULL,
	ma_ttdv varchar(255) NOT NULL,
	ma_bs varchar(255) NOT NULL,
	ten_bs varchar(255) NOT NULL,
	ngay_ct varchar(8) NOT NULL,
	ma_cha varchar(10) NULL,
	ma_me varchar(10) NULL,
	ma_the_tam varchar(15) NULL,
	ho_ten_cha varchar(255) NULL,
	ho_ten_me varchar(255) NULL,
	so_ngay_nghi int2 NULL,
	ngoaitru_tungay varchar(8) NULL,
	ngoaitru_denngay varchar(8) NULL,
	du_phong text NULL,
	tiepnhan_id uuid NOT NULL,
	bi_xoa int2 DEFAULT 0 NOT NULL,
	nguoi_tao varchar(100) NULL,
	ngay_tao timestamp DEFAULT CURRENT_TIMESTAMP NULL,
	nguoi_cap_nhat varchar(100) NULL,
	ngay_cap_nhat timestamp DEFAULT CURRENT_TIMESTAMP NULL,
	nguoi_xoa varchar(100) NULL,
	ngay_xoa timestamp NULL,
	CONSTRAINT eclaim_data_xml7_pkey PRIMARY KEY (id)
);

CREATE TABLE eclaim_data_xml8 (
	id uuid DEFAULT gen_random_uuid() NOT NULL,
	ma_lk varchar(100) NOT NULL,
	ma_loai_kcb varchar(10) NOT NULL,
	ho_ten_cha varchar(255) NULL,
	ho_ten_me varchar(255) NULL,
	nguoi_giam_ho varchar(255) NULL,
	don_vi varchar(1024) NULL,
	ngay_vao varchar(12) NOT NULL,
	ngay_ra varchar(12) NOT NULL,
	chan_doan_vao text NOT NULL,
	chan_doan_rv text NOT NULL,
	qt_benhly text NOT NULL,
	tomtat_kq text NULL,
	pp_dieutri text NOT NULL,
	ngay_sinhcon varchar(8) NULL,
	ngay_conchet varchar(8) NULL,
	so_conchet int2 NULL,
	ket_qua_dtri varchar(50) NOT NULL,
	ghi_chu text NULL,
	ma_ttdv varchar(255) NOT NULL,
	ngay_ct varchar(8) NOT NULL,
	ma_the_tam varchar(15) NULL,
	du_phong text NULL,
	tiepnhan_id uuid NULL,
	bi_xoa int2 DEFAULT 0 NOT NULL,
	nguoi_tao varchar(100) NULL,
	ngay_tao timestamp DEFAULT CURRENT_TIMESTAMP NULL,
	nguoi_cap_nhat varchar(100) NULL,
	ngay_cap_nhat timestamp DEFAULT CURRENT_TIMESTAMP NULL,
	nguoi_xoa varchar(100) NULL,
	ngay_xoa timestamp NULL,
	CONSTRAINT eclaim_data_xml8_pkey PRIMARY KEY (id)
);

CREATE TABLE eclaim_data_xml_mau_01dm (
	stt int4 NOT NULL, -- Số thứ tự
	ma_khoa varchar(50) NOT NULL, -- Mã khoa
	ten_khoa varchar(500) NOT NULL, -- Tên khoa
	ban_kham int4 DEFAULT 0 NULL, -- Số bàn khám
	giuong_pd int4 DEFAULT 0 NULL, -- Số giường
	giuong_tk int4 DEFAULT 0 NULL, -- Giường thực kê
	giuong_hstc int4 DEFAULT 0 NULL, -- Giường hồi sức tích cực
	giuong_hscc int4 DEFAULT 0 NULL, -- Giường hồi sức cấp cứu
	tu_ngay varchar(8) NOT NULL, -- Từ ngày
	den_ngay varchar(8) NULL, -- Đến ngày
	ma_cskcb varchar(5) NOT NULL, -- Mã cơ sở khám chữa bệnh
	loai_dong_bo varchar(25) NOT NULL, -- Loại đồng bộ (XML, EXCEL)
	ngay_dong_bo timestamp NOT NULL, -- Ngày đồng bộ
	khoa_id uuid NULL, -- FK dm_khoa.id
	id uuid DEFAULT gen_random_uuid() NOT NULL, -- Key của bảng
	ngay_tao timestamp DEFAULT now() NOT NULL, -- Ngày tạo
	nguoi_tao varchar(100) DEFAULT 'system'::character varying NOT NULL, -- Người tạo
	ngay_cap_nhat timestamp DEFAULT now() NOT NULL, -- Ngày cập nhật
	nguoi_cap_nhat varchar(100) DEFAULT 'system'::character varying NOT NULL, -- Người cập nhật
	bi_xoa int2 DEFAULT 0 NULL, -- Bị xóa mềm
	ngay_xoa timestamp NULL, -- Ngày xóa mềm
	nguoi_xoa varchar(100) NULL, -- Người xóa mềm
	CONSTRAINT eclaim_data_xml_mau_01dm_pkey PRIMARY KEY (id)
);

CREATE TABLE eclaim_data_xml_mau_02dm (
	stt int4 DEFAULT 0 NOT NULL, -- Số thứ tự
	ma_khoa varchar(100) NULL, -- Mã khoa
	ten_khoa varchar NULL, -- Tên khoa
	ho_ten varchar(250) NOT NULL, -- Họ tên
	gioi_tinh int2 DEFAULT 3 NOT NULL, -- Giới tính
	so_dinh_danh varchar(15) NOT NULL, -- Số định danh
	chucdanh_nn varchar(2) NULL, -- Chức danh nghề nghiệp
	vi_tri varchar(5) NULL, -- Vị trí
	macchn varchar(250) NULL, -- Mã chứng chỉ hành nghề
	ngaycap_cchn varchar(8) NULL, -- Ngày cấp chứng chỉ hành nghề
	noicap_cchn varchar(250) NULL, -- Nơi cấp chứng chỉ hành nghề
	phamvi_cm varchar(15) NULL, -- Phạm vi chuyên môn
	phamvi_cmbs varchar(50) NULL, -- Phạm vi chuyên môn bổ sung
	dvkt_khac varchar NULL, -- Dịch vụ kỹ thuật khác
	vb_phancong varchar(50) NULL, -- Văn bản phân công
	thoigian_dk int2 NULL, -- Thời gian đăng ký
	thoigian_ngay varchar(200) NULL, -- Thời gian ngày
	thoigian_tuan varchar(200) NULL, -- Thời gian tuần
	cskcb_khac varchar(30) NULL, -- Cơ sở khám chữa bệnh khác
	cskcb_cgkt varchar(5) NULL, -- Cơ sở khám bệnh chuyển giao kỹ thuật
	qd_cgkt varchar(50) NULL, -- Quyết định chuyển giao kỹ thuật
	tu_ngay varchar(8) NOT NULL, -- Từ ngày
	den_ngay varchar(8) NULL, -- Đến ngày
	ma_cskcb varchar(5) NOT NULL, -- Mã cơ sở khám chữa bệnh
	nhan_vien_id uuid NULL, -- ID Nhân viên
	loai_dong_bo varchar(25) NOT NULL, -- Loại đồng bộ (XML, EXCEL)
	ngay_dong_bo timestamp NOT NULL, -- Ngày đồng bộ
	id uuid DEFAULT gen_random_uuid() NOT NULL, -- Key của bảng
	ngay_tao timestamp DEFAULT now() NOT NULL, -- Ngày tạo
	nguoi_tao varchar(100) DEFAULT 'system'::character varying NOT NULL, -- Người tạo
	ngay_cap_nhat timestamp DEFAULT now() NOT NULL, -- Ngày cập nhật
	nguoi_cap_nhat varchar(100) DEFAULT 'system'::character varying NOT NULL, -- Người cập nhật
	bi_xoa int2 DEFAULT 0 NULL, -- Bị xóa mềm
	ngay_xoa timestamp NULL, -- Ngày xóa mềm
	nguoi_xoa varchar(100) NULL, -- Người xóa mềm
	CONSTRAINT eclaim_data_xml_mau_02dm_pkey PRIMARY KEY (id)
);

CREATE TABLE eclaim_data_xml_mau_03dm (
	stt int4 DEFAULT 0 NOT NULL, -- Số thứ tự
	ma_thuoc varchar(255) NOT NULL, -- Mã thuốc
	ten_hoat_chat varchar(1024) NOT NULL, -- Tên hoạt chất
	ten_thuoc varchar(1024) NOT NULL, -- Tên thuốc
	don_vi_tinh varchar(50) NOT NULL, -- Đơn vị tính
	ham_luong varchar(1024) NULL, -- Hàm lượng
	duong_dung varchar(255) NOT NULL, -- Đường dùng
	ma_duong_dung varchar(100) NOT NULL, -- Mã đường dùng
	dang_bao_che varchar(1024) NULL,
	so_dang_ky varchar(1024) NULL, -- Số đăng ký
	so_luong int4 DEFAULT 0 NOT NULL, -- Số lượng
	don_gia numeric(15, 3) DEFAULT 0 NOT NULL, -- Đơn giá
	don_gia_bh numeric(15, 3) DEFAULT 0 NOT NULL, -- Đơn giá BH
	quy_cach varchar(1024) NULL, -- Quy cách
	nha_sx varchar(1024) NOT NULL, -- Nhà sản xuất
	nuoc_sx varchar(100) NOT NULL, -- Nước sản xuất
	nha_thau varchar(1024) NULL, -- Nhà thầu
	tt_thau varchar(50) NULL, -- Thông tin thầu
	tu_ngay_hd varchar(8) NULL, -- Hợp đồng từ ngày
	den_ngay_hd varchar(8) NULL, -- Hợp đồng đến ngày
	ma_cskcb varchar(5) NOT NULL, -- Mã cơ sở khám chữa bệnh
	loai_thuoc int2 NULL, -- Loại thuốc
	loai_thau int2 NULL, -- Loại thầu
	ht_thau int2 NULL, -- Hình thức thầu
	ma_dvkt varchar(1024) NULL, -- Mã dịch vụ kỹ thuật
	tccl varchar(50) NULL, -- Tiêu chuẩn chất lượng
	bo_phan_vt int2 NULL, -- Bộ phận sử dụng vị thuốc
	ten_khoa_hoc varchar(500) NULL, -- Tên khoa học
	nguon_goc varchar(500) NULL, -- Nguồn gốc
	pp_chebien varchar(1024) NULL, -- Phương pháp chế biến
	ma_dl_cb varchar(3) NULL, -- Mã dược liệu chế biến
	tlhh_cb numeric(7, 3) NULL, -- Tỷ lệ hao hụt chế biến
	tlhh_bq numeric(7, 3) NULL, -- Tỷ lệ hao hụt bảo quản
	ma_cskcb_thuoc varchar(50) NULL, -- Mã cơ sở khám chữa bệnh chuyển thuốc đi
	tu_ngay varchar(8) NULL, -- Từ ngày
	den_ngay varchar(8) NULL, -- Đến ngày
	loai_dong_bo varchar(25) NULL, -- Loại đồng bộ (XML, EXCEL)
	ngay_dong_bo timestamp NULL, -- Ngày đồng bộ
	thuoc_vat_tu_id uuid NULL, -- ID thuốc vật tư
	id uuid DEFAULT gen_random_uuid() NOT NULL, -- Key của bảng
	ngay_tao timestamp DEFAULT now() NOT NULL, -- Ngày tạo
	nguoi_tao varchar(100) DEFAULT 'system'::character varying NOT NULL, -- Người tạo
	ngay_cap_nhat timestamp DEFAULT now() NOT NULL, -- Ngày cập nhật
	nguoi_cap_nhat varchar(100) DEFAULT 'system'::character varying NOT NULL, -- Người cập nhật
	bi_xoa int2 DEFAULT 0 NULL, -- Bị xóa mềm
	ngay_xoa timestamp NULL, -- Ngày xóa mềm
	nguoi_xoa varchar(100) NULL, -- Người xóa mềm
	ma_dl_nhap varchar(3) NULL, -- Mã dược liệu nhập
	CONSTRAINT eclaim_data_xml_mau_03dm_pkey PRIMARY KEY (id)
);

CREATE TABLE eclaim_data_xml_mau_04dm (
	stt int4 DEFAULT 0 NOT NULL, -- Số thứ tự
	ma_vat_tu varchar(50) NOT NULL, -- Mã vật tư
	nhom_vat_tu varchar(1024) NOT NULL, -- Nhóm vật tư
	ten_vat_tu varchar NOT NULL, -- Tên vật tư
	ma_hieu varchar(1024) NOT NULL, -- Mã hiệu
	so_luu_hanh varchar(20) NOT NULL, -- Số lưu hành
	tinhnang_kt varchar NOT NULL, -- Tính năng kỹ thuật
	quy_cach varchar(1024) NULL, -- Quy cách
	hang_sx varchar(1024) NULL, -- Tên hãng sản xuất
	nuoc_sx varchar(100) NULL, -- Tên nước sản xuất
	don_vi_tinh varchar(50) NOT NULL, -- Đơn vị tính
	don_gia numeric(15, 3) DEFAULT 0 NOT NULL,
	don_gia_bh numeric(15, 3) DEFAULT 0 NOT NULL, -- Đơn giá bảo hiểm
	tyle_tt_bh numeric(7, 3) DEFAULT 0 NOT NULL, -- Tỷ lệ thanh toán bảo hiểm
	so_luong int4 DEFAULT 0 NOT NULL, -- Số lượng
	dinh_muc int2 NULL, -- Định mức
	nha_thau varchar(1024) NULL, -- Nhà thầu
	tt_thau varchar(50) NULL, -- Thông tin thầu
	tu_ngay_hd varchar(8) NULL, -- Hợp đồng từ ngày
	den_ngay_hd varchar(8) NULL, -- Hợp đồng đến ngày
	ma_cskcb varchar(5) NOT NULL, -- Mã cơ sở khám chữa bệnh
	loai_thau int2 NULL, -- Loại thầu
	ht_thau int2 NULL, -- Hình thức thầu
	ma_cskcb_tbyt varchar(50) NULL, -- Mã cơ sở khám chữa bệnh chuyển thiết bị y tế đi
	tu_ngay varchar(8) NULL, -- Từ ngày
	den_ngay varchar(8) NULL, -- Đến ngày
	thuoc_vat_tu_id uuid NULL, -- ID Thuốc vật tự
	loai_dong_bo varchar(25) NULL, -- Loại đồng bộ
	ngay_dong_bo timestamp NULL, -- Ngày đồng bộ
	id uuid DEFAULT gen_random_uuid() NOT NULL, -- Key của bảng
	ngay_tao timestamp DEFAULT now() NOT NULL, -- Ngày tạo
	nguoi_tao varchar(100) DEFAULT '''system'''::character varying NOT NULL, -- Người tạo
	ngay_cap_nhat timestamp DEFAULT now() NOT NULL, -- Ngày cập nhật
	nguoi_cap_nhat varchar(100) DEFAULT '''system'''::character varying NOT NULL, -- Người cập nhật
	bi_xoa int2 DEFAULT 0 NULL, -- Bị xóa mềm
	ngay_xoa timestamp NULL, -- Ngày xóa mềm
	nguoi_xoa varchar(100) NULL, -- Người xóa mềm
	CONSTRAINT eclaim_data_xml_mau_04dm_pkey PRIMARY KEY (id)
);

CREATE TABLE eclaim_data_xml_mau_05dm (
	stt int4 DEFAULT 0 NOT NULL, -- Số thứ tự
	ma_dich_vu varchar(20) NOT NULL, -- Mã dịch vụ
	ten_dich_vu varchar NOT NULL, -- Tên dịch vụ
	ten_dvkt_gia varchar NOT NULL, -- Tên dịch vụ kỹ thuật phê duyệt gia (tên dùng chung)
	don_gia numeric DEFAULT 0 NOT NULL, -- Đơn giá
	quy_trinh varchar(50) NULL, -- Quy trình
	so_luong_cgkt int2 NULL, -- Số lượng chuyển giao kỹ thuật
	cskcb_cgkt varchar(5) NULL, -- Cơ sở khám chữa bệnh chuyển giao kỹ thuật
	cskcb_cls varchar(5) NULL, -- Cơ sở khám chữa bệnh thực hiện cận lâm sàng
	qd_dvkt varchar(50) NULL, -- Quyết định phê duyệt danh mục kỹ thuật
	qd_pd_gia varchar(50) NULL, -- Quyết định phê duyệt giá
	ghi_chu varchar NULL, -- Ghi chú
	tu_ngay varchar(8) NULL, -- Từ ngày
	den_ngay varchar(8) NULL, -- Đến ngày
	ma_cskcb varchar(5) NOT NULL, -- Mã cơ sở khám chữa bệnh
	gia_thanh_toan numeric DEFAULT 0 NOT NULL, -- Giá thanh toán
	dich_vu_id uuid NULL, -- ID dịch vụ
	loai_dong_bo varchar(25) NULL, -- Loại đồng bộ (XML, EXCEL)
	ngay_dong_bo timestamp NULL, -- Ngày đồng bộ
	id uuid DEFAULT gen_random_uuid() NOT NULL, -- Key của bảng
	ngay_tao timestamp DEFAULT now() NOT NULL, -- Ngày tạo
	nguoi_tao varchar(100) DEFAULT '''system'''::character varying NOT NULL, -- Người tạo
	ngay_cap_nhat timestamp DEFAULT now() NOT NULL, -- Ngày cập nhật
	nguoi_cap_nhat varchar(100) DEFAULT '''system'''::character varying NOT NULL, -- Người cập nhật
	bi_xoa int2 DEFAULT 0 NULL, -- Bị xóa mềm
	ngay_xoa timestamp NULL, -- Ngày xóa mềm
	nguoi_xoa varchar(100) NULL, -- Người xóa mềm
	CONSTRAINT eclaim_data_xml_mau_05dm_pkey PRIMARY KEY (id)
);

CREATE TABLE eclaim_data_xml_mau_06dm (
	stt int4 DEFAULT 0 NOT NULL, -- Số thứ tự
	ten_tb varchar NOT NULL, -- Tên thiết bị
	ky_hieu varchar(1024) NOT NULL, -- Ký hiệu
	congty_sx varchar(1024) NOT NULL, -- Công ty sản xuất
	nuoc_sx varchar(100) NOT NULL, -- Tên nước sản xuất
	nam_sx int2 NOT NULL, -- Năm sản xuất
	nam_sd int2 NOT NULL, -- Năm sử dụng
	ma_may varchar NOT NULL, -- Mã máy
	so_luu_hanh varchar(20) NOT NULL, -- Số lưu hành
	hd_tu varchar(8) NULL, -- Hợp đồng từ ngày
	hd_den varchar(8) NULL, -- Hợp đồng đến ngày
	tu_ngay varchar(8) NULL, -- Từ ngày
	den_ngay varchar(8) NULL, -- Đến ngày
	ma_cskcb varchar(5) NOT NULL, -- Mã cơ sở khám chữa bệnh
	thiet_bi_id uuid NULL, -- ID Thiết bị
	loai_dong_bo varchar(25) NULL, -- Loại đồng bộ (XML, EXCEL)
	ngay_dong_bo timestamp NULL, -- Ngày đồng bộ
	id uuid DEFAULT gen_random_uuid() NOT NULL, -- Key của bảng
	ngay_tao timestamp DEFAULT now() NOT NULL, -- Ngày tạo
	nguoi_tao varchar(100) DEFAULT 'system'::character varying NOT NULL, -- Người tạo
	ngay_cap_nhat timestamp DEFAULT now() NOT NULL, -- Ngày cập nhật
	nguoi_cap_nhat varchar(100) DEFAULT 'system'::character varying NOT NULL, -- Người cập nhật
	bi_xoa int2 DEFAULT 0 NULL, -- Bị xóa mềm
	ngay_xoa timestamp NULL, -- Ngày xóa mềm
	nguoi_xoa varchar(100) NULL, -- Người xóa mềm
	CONSTRAINT eclaim_data_xml_mau_06dm_pkey PRIMARY KEY (id)
);

CREATE TABLE eclaim_xml_export_job (
	id uuid DEFAULT gen_random_uuid() NOT NULL,
	status varchar(20) NOT NULL,
	total_items int4 DEFAULT 0 NOT NULL,
	processed_items int4 DEFAULT 0 NOT NULL,
	success_items int4 DEFAULT 0 NOT NULL,
	failed_items int4 DEFAULT 0 NOT NULL,
	imported_count int4 DEFAULT 0 NOT NULL,
	error_message text NULL,
	created_by varchar(100) NULL,
	created_at timestamp DEFAULT CURRENT_TIMESTAMP NOT NULL,
	started_at timestamp NULL,
	finished_at timestamp NULL,
	bi_xoa int2 DEFAULT 0 NOT NULL,
	CONSTRAINT eclaim_xml_export_job_pkey PRIMARY KEY (id)
);

CREATE TABLE eclaim_xml_export_job_detail (
	id uuid DEFAULT gen_random_uuid() NOT NULL,
	job_id uuid NOT NULL,
	tiep_nhan_id uuid NOT NULL,
	status varchar(20) NOT NULL,
	imported_count int4 DEFAULT 0 NOT NULL,
	file_name varchar(255) NULL,
	file_base64 text NULL,
	error_message text NULL,
	created_by varchar(100) NULL,
	created_at timestamp DEFAULT CURRENT_TIMESTAMP NOT NULL,
	started_at timestamp NULL,
	finished_at timestamp NULL,
	bi_xoa int2 DEFAULT 0 NOT NULL,
	file_id varchar(100) NULL,
	bucket_name varchar(255) NULL,
	storage_path varchar(1024) NULL,
	content_type varchar(255) NULL,
	download_url text NULL,
	ma_lk varchar(100) NULL,
	CONSTRAINT eclaim_xml_export_job_detail_pkey PRIMARY KEY (id)
);

CREATE TABLE eclaim_xml_mau_sync_log (
	ma_mau_xml varchar(20) NULL, -- Mã mẫu XML
	xml_key varchar(100) NULL, -- Key XML
	loai_dong_bo varchar(20) NOT NULL, -- Loại đồng bộ
	ma_cskcb varchar(5) NULL, -- Mã cơ sở khám chữa bệnh
	trang_thai varchar(20) NOT NULL, -- Trạng thái
	so_ban_ghi int4 NULL, -- Số bản ghi
	ten_file varchar(255) NULL, -- Tên file
	file_id uuid NULL, -- ID file
	ly_do_loi text NULL, -- Lý do lỗi
	nguoi_thuc_hien varchar(100) NULL, -- Người thực hiện
	bat_dau_luc timestamp DEFAULT CURRENT_TIMESTAMP NOT NULL, -- Bắt đầu lúc
	ket_thuc_luc timestamp NULL, -- Kết thúc lúc
	id uuid DEFAULT gen_random_uuid() NOT NULL, -- Key của bảng
	ngay_tao timestamp DEFAULT now() NOT NULL, -- Ngày tạo
	nguoi_tao varchar(100) DEFAULT 'system'::character varying NOT NULL, -- Người tạo
	ngay_cap_nhat timestamp DEFAULT now() NOT NULL, -- Ngày cập nhật
	nguoi_cap_nhat varchar(100) DEFAULT 'system'::character varying NOT NULL, -- Người cập nhật
	bi_xoa int2 DEFAULT 0 NULL, -- Bị xóa mềm
	ngay_xoa timestamp NULL, -- Ngày xóa mềm
	nguoi_xoa varchar(100) NULL, -- Người xóa mềm
	hososohoa_id uuid NULL, -- ID hồ sơ số hóa
	CONSTRAINT eclaim_xml_mau_sync_log_pkey PRIMARY KEY (id)
);

CREATE TABLE emr_de_nghi_cung_cap_hsba (
	id uuid DEFAULT gen_random_uuid() NOT NULL,
	ma_cskcb varchar(50) NULL,
	hoat_dong int2 DEFAULT 1 NULL,
	bi_xoa int2 DEFAULT 0 NULL,
	ngay_tao timestamp DEFAULT now() NULL,
	nguoi_tao varchar(50) NULL,
	ngay_cap_nhat timestamp DEFAULT now() NULL,
	nguoi_cap_nhat varchar(50) NULL,
	ngay_xoa timestamp NULL,
	nguoi_xoa varchar(50) NULL,
	so_de_nghi varchar(20) NOT NULL,
	tiep_nhan_id uuid NOT NULL,
	ngay_de_nghi date NOT NULL,
	loai_de_nghi int2 NOT NULL,
	loai_giay_to_id uuid NOT NULL,
	so_luong int4 DEFAULT 1 NOT NULL,
	cho_phep_doc_hsba bool DEFAULT false NOT NULL,
	muc_dich varchar(500) NOT NULL,
	doi_tuong_de_nghi int2 NOT NULL,
	ho_ten_de_nghi varchar(150) NOT NULL,
	quan_he_nguoi_de_nghi varchar(150) NULL,
	dia_chi varchar(500) NULL,
	so_cccd varchar(12) NULL,
	khong_co_cccd bool DEFAULT false NOT NULL,
	so_ho_chieu varchar(20) NULL,
	so_dien_thoai varchar(15) NULL,
	benh_nhan_id uuid NOT NULL,
	ma_nguoi_benh varchar(50) NULL,
	ten_nguoi_benh varchar(150) NULL,
	ngay_sinh date NULL,
	so_benh_an varchar(50) NULL,
	ngay_vao_vien date NULL,
	ngay_ra_vien date NULL,
	ngay_hen_tra timestamp NULL,
	noi_hen_tra_id uuid NULL,
	doi_tuong_nhan int2 NOT NULL,
	ho_ten_nguoi_nhan varchar(150) NULL,
	quan_he_nguoi_nhan varchar(150) NULL,
	hososohoa_id uuid NULL,
	noi_tiep_nhan_id uuid NULL,
	trang_thai int2 DEFAULT 0 NOT NULL,
	CONSTRAINT emr_de_nghi_cung_cap_hsba_pkey PRIMARY KEY (id)
);

CREATE TABLE emr_dm_cauhinh (
	id uuid DEFAULT gen_random_uuid() NOT NULL,
	bi_xoa int2 DEFAULT 0 NULL,
	ma_cskcb varchar(50) NULL,
	ngay_tao timestamp DEFAULT now() NULL,
	nguoi_tao varchar(50) NULL,
	ngay_cap_nhat timestamp DEFAULT now() NULL,
	nguoi_cap_nhat varchar(50) NULL,
	ngay_xoa timestamp NULL,
	nguoi_xoa varchar(50) NULL,
	ma_tham_so varchar(50) NOT NULL,
	ten_tham_so varchar(255) NOT NULL,
	gia_tri_mac_dinh varchar(50) NOT NULL,
	gia_tri_mong_muon varchar(255) NULL,
	mo_ta text NULL,
	CONSTRAINT emr_dm_cauhinh_ma_tham_so_key UNIQUE (ma_tham_so),
	CONSTRAINT emr_dm_cauhinh_pkey PRIMARY KEY (id)
);

CREATE TABLE emr_dm_kho (
	id uuid DEFAULT gen_random_uuid() NOT NULL,
	hoat_dong int2 DEFAULT 1 NULL,
	bi_xoa int2 DEFAULT 0 NULL,
	ngay_tao timestamp DEFAULT now() NULL,
	nguoi_tao varchar(50) NULL,
	ngay_cap_nhat timestamp DEFAULT now() NULL,
	nguoi_cap_nhat varchar(50) NULL,
	ngay_xoa timestamp NULL,
	nguoi_xoa varchar(50) NULL,
	ma_kho varchar(50) NOT NULL,
	ten_kho varchar(255) NOT NULL,
	mo_ta varchar(500) NULL,
	ma_cskcb varchar(50) NULL,
	CONSTRAINT emr_dm_kho_pkey PRIMARY KEY (id)
);

CREATE TABLE emr_dm_kho_hang (
	id uuid DEFAULT gen_random_uuid() NOT NULL,
	hoat_dong int2 DEFAULT 1 NULL,
	bi_xoa int2 DEFAULT 0 NULL,
	ngay_tao timestamp DEFAULT now() NULL,
	nguoi_tao varchar(50) NULL,
	ngay_cap_nhat timestamp DEFAULT now() NULL,
	nguoi_cap_nhat varchar(50) NULL,
	ngay_xoa timestamp NULL,
	nguoi_xoa varchar(50) NULL,
	kho_id uuid NOT NULL,
	ma_hang varchar(50) NOT NULL,
	mo_ta varchar(500) NULL,
	ma_cskcb varchar(50) NULL,
	CONSTRAINT emr_dm_kho_hang_pkey PRIMARY KEY (id)
);

CREATE TABLE emr_dm_kho_ke (
	id uuid DEFAULT gen_random_uuid() NOT NULL,
	hoat_dong int2 DEFAULT 1 NULL,
	bi_xoa int2 DEFAULT 0 NULL,
	ngay_tao timestamp DEFAULT now() NULL,
	nguoi_tao varchar(50) NULL,
	ngay_cap_nhat timestamp DEFAULT now() NULL,
	nguoi_cap_nhat varchar(50) NULL,
	ngay_xoa timestamp NULL,
	nguoi_xoa varchar(50) NULL,
	kho_id uuid NOT NULL,
	hang_id uuid NOT NULL,
	ma_ke varchar(50) NOT NULL,
	suc_chua_toi_da int4 NOT NULL,
	so_luong_ho_so int4 DEFAULT 0 NOT NULL,
	mo_ta varchar(500) NULL,
	ma_cskcb varchar(50) NULL,
	CONSTRAINT emr_dm_kho_ke_pkey PRIMARY KEY (id)
);

CREATE TABLE emr_giay_tom_tat_hsba (
	id uuid DEFAULT gen_random_uuid() NOT NULL,
	ma_cskcb varchar(50) NULL,
	bi_xoa int2 DEFAULT 0 NULL,
	ngay_tao timestamp DEFAULT now() NULL,
	nguoi_tao varchar(50) NULL,
	ngay_cap_nhat timestamp DEFAULT now() NULL,
	nguoi_cap_nhat varchar(50) NULL,
	ngay_xoa timestamp NULL,
	nguoi_xoa varchar(50) NULL,
	tiep_nhan_id uuid NOT NULL,
	benh_an_id uuid NOT NULL,
	hoso_goc_id uuid NULL,
	lan_caplai int2 DEFAULT 0 NULL,
	so_giayto varchar(50) NOT NULL,
	qt_benhly_dienbien_lamsang text NULL,
	tien_su_benh text NULL,
	dauhieu_lamsang text NULL,
	tomtat_xetnghiem_canlamsang text NULL,
	ppdt_noikhoa int2 NULL,
	ppdt_noikhoa_ghiro varchar(200) NULL,
	ppdt_pttt int2 NULL,
	ppdt_pttt_ghiro varchar(200) NULL,
	tinhtrang_ravien varchar(50) NULL,
	huong_dieutri varchar(50) NULL,
	lydo_caplai text NOT NULL,
	hososohoa_id uuid NULL,
	lydo_vaovien text NULL,
	CONSTRAINT emr_giay_tom_tat_hsba_pkey PRIMARY KEY (id)
);

CREATE TABLE emr_giay_trich_sao_benhan (
	id uuid DEFAULT gen_random_uuid() NOT NULL,
	ma_cskcb varchar(50) NULL,
	bi_xoa int2 DEFAULT 0 NULL,
	ngay_tao timestamp DEFAULT now() NULL,
	nguoi_tao varchar(50) NULL,
	ngay_cap_nhat timestamp DEFAULT now() NULL,
	nguoi_cap_nhat varchar(50) NULL,
	ngay_xoa timestamp NULL,
	nguoi_xoa varchar(50) NULL,
	tiep_nhan_id uuid NOT NULL,
	benh_an_id uuid NOT NULL,
	hoso_goc_id uuid NULL,
	lan_caplai int2 DEFAULT 0 NULL,
	so_giayto varchar(50) NOT NULL,
	lydo_vaovien text NULL,
	qt_benhly_dienbien_lamsang text NULL,
	tien_su_benh text NULL,
	dauhieu_lamsang text NULL,
	tomtat_xetnghiem_canlamsang text NULL,
	tinhtrang_ravien varchar(50) NULL,
	huong_dieutri varchar(50) NULL,
	lydo_caplai text NOT NULL,
	hososohoa_id uuid NULL,
	phuongphap_dieutri text NULL,
	CONSTRAINT emr_giay_trich_sao_benhan_pkey PRIMARY KEY (id)
);

CREATE TABLE emr_hl7_field (
	id uuid DEFAULT gen_random_uuid() NOT NULL,
	bi_xoa int2 DEFAULT 0 NULL,
	ma_cskcb varchar(50) NULL,
	ngay_tao timestamp DEFAULT now() NULL,
	nguoi_tao varchar(50) NULL,
	ngay_cap_nhat timestamp DEFAULT now() NULL,
	nguoi_cap_nhat varchar(50) NULL,
	ngay_xoa timestamp NULL,
	nguoi_xoa varchar(50) NULL,
	emr_hl7_resource_id uuid NULL,
	field_name text NOT NULL,
	description text NULL,
	CONSTRAINT emr_hl7_field_pkey PRIMARY KEY (id)
);

CREATE TABLE emr_hl7_mapping (
	id uuid DEFAULT gen_random_uuid() NOT NULL,
	bi_xoa int2 DEFAULT 0 NULL,
	ma_cskcb varchar(50) NULL,
	ngay_tao timestamp DEFAULT now() NULL,
	nguoi_tao varchar(50) NULL,
	ngay_cap_nhat timestamp DEFAULT now() NULL,
	nguoi_cap_nhat varchar(50) NULL,
	ngay_xoa timestamp NULL,
	nguoi_xoa varchar(50) NULL,
	emr_hl7_field_id uuid NULL,
	emr_hl7_resource_id uuid NULL,
	xml_3176_xpath text NOT NULL,
	description text NULL,
	CONSTRAINT emr_hl7_mapping_pkey PRIMARY KEY (id)
);

CREATE TABLE emr_hl7_resource (
	id uuid DEFAULT gen_random_uuid() NOT NULL,
	bi_xoa int2 DEFAULT 0 NULL,
	ma_cskcb varchar(50) NULL,
	ngay_tao timestamp DEFAULT now() NULL,
	nguoi_tao varchar(50) NULL,
	ngay_cap_nhat timestamp DEFAULT now() NULL,
	nguoi_cap_nhat varchar(50) NULL,
	ngay_xoa timestamp NULL,
	nguoi_xoa varchar(50) NULL,
	resource_name varchar(255) NOT NULL,
	description text NULL,
	CONSTRAINT emr_hl7_resource_pkey PRIMARY KEY (id)
);

CREATE TABLE emr_hoso_bosung (
	id uuid DEFAULT gen_random_uuid() NOT NULL,
	ma_cskcb varchar(50) NULL,
	bi_xoa int2 DEFAULT 0 NULL,
	ngay_tao timestamp DEFAULT now() NULL,
	nguoi_tao varchar(50) NULL,
	ngay_cap_nhat timestamp DEFAULT now() NULL,
	nguoi_cap_nhat varchar(50) NULL,
	ngay_xoa timestamp NULL,
	nguoi_xoa varchar(50) NULL,
	hososohoa_id uuid NULL,
	ten_file varchar(255) NULL,
	storage_path varchar(500) NOT NULL,
	file_id varchar(100) NULL,
	bucket_name varchar(255) NULL,
	content_type varchar(100) NULL,
	kich_thuoc int8 NULL,
	mo_ta text NULL,
	CONSTRAINT emr_hoso_bosung_pkey PRIMARY KEY (id)
);

CREATE TABLE emr_lichsu_capgiay (
	id uuid DEFAULT gen_random_uuid() NOT NULL,
	ma_cskcb varchar(50) NULL,
	bi_xoa int2 DEFAULT 0 NULL,
	ngay_tao timestamp DEFAULT now() NULL,
	nguoi_tao varchar(50) NULL,
	ngay_cap_nhat timestamp DEFAULT now() NULL,
	nguoi_cap_nhat varchar(50) NULL,
	ngay_xoa timestamp NULL,
	nguoi_xoa varchar(50) NULL,
	ma_benh_nhan varchar(50) NOT NULL,
	ten_benh_nhan varchar(255) NOT NULL,
	ngay_sinh date NULL,
	gioi_tinh varchar(10) NULL,
	dia_chi varchar(500) NULL,
	so_bhyt varchar(50) NULL,
	ma_tiep_nhan varchar(50) NULL,
	ngay_vao_vien date NULL,
	ngay_ra_vien date NULL,
	loai_giay_to varchar(50) NOT NULL,
	ten_loai_giay_to varchar(255) NULL,
	so_giay_goc varchar(50) NULL,
	lan_cap_lai int2 DEFAULT 1 NULL,
	ly_do_cap_lai varchar(500) NULL,
	thoi_gian_cap_lai timestamp NULL,
	ky_so int2 DEFAULT 0 NULL,
	CONSTRAINT emr_lichsu_capgiay_pkey PRIMARY KEY (id)
);

CREATE TABLE emr_lichsu_caplai_giayto (
	id uuid DEFAULT gen_random_uuid() NOT NULL,
	ma_cskcb varchar(50) NULL,
	bi_xoa int2 DEFAULT 0 NULL,
	ngay_tao timestamp DEFAULT now() NULL,
	nguoi_tao varchar(50) NULL,
	ngay_cap_nhat timestamp DEFAULT now() NULL,
	nguoi_cap_nhat varchar(50) NULL,
	ngay_xoa timestamp NULL,
	nguoi_xoa varchar(50) NULL,
	tiep_nhan_id uuid NOT NULL,
	benh_an_id uuid NULL,
	phieu_ky_so_id uuid NULL,
	bang_thamchieu varchar(100) NOT NULL,
	giayto_goc_id uuid NOT NULL,
	giayto_caplai_id uuid NOT NULL,
	so_giayto_goc varchar(255) NOT NULL,
	so_giayto_caplai varchar(255) NOT NULL,
	so_lan_caplai int2 NOT NULL,
	lydo_caplai varchar(500) NOT NULL,
	nguoi_caplai varchar(255) NOT NULL,
	thoigian_caplai timestamp NOT NULL,
	ky_so int2 DEFAULT 0 NULL,
	ma_benh_nhan varchar(50) NULL,
	ten_loai_giay_to varchar(255) NULL,
	hososohoa_id uuid NULL,
	CONSTRAINT emr_lichsu_caplai_giayto_pkey PRIMARY KEY (id)
);

CREATE TABLE emr_lichsu_giahan (
	id uuid DEFAULT gen_random_uuid() NOT NULL,
	ma_cskcb varchar(50) NULL,
	hoat_dong int2 DEFAULT 1 NULL,
	bi_xoa int2 DEFAULT 0 NULL,
	ngay_tao timestamp DEFAULT now() NULL,
	nguoi_tao varchar(50) NULL,
	ngay_cap_nhat timestamp DEFAULT now() NULL,
	nguoi_cap_nhat varchar(50) NULL,
	ngay_xoa timestamp NULL,
	nguoi_xoa varchar(50) NULL,
	phieu_bangiao_id uuid NULL,
	thoigian_luutru int4 NULL,
	ly_do varchar(500) NULL,
	phieu_bangiao_chitiet_id uuid NULL,
	CONSTRAINT emr_lichsu_giahan_pkey PRIMARY KEY (id)
);

CREATE TABLE emr_lichsu_xem_hsba (
	id uuid DEFAULT gen_random_uuid() NOT NULL,
	ma_cskcb varchar(50) NULL,
	hoat_dong int2 DEFAULT 1 NULL,
	bi_xoa int2 DEFAULT 0 NULL,
	ngay_tao timestamp DEFAULT now() NULL,
	nguoi_tao varchar(50) NULL,
	ngay_cap_nhat timestamp DEFAULT now() NULL,
	nguoi_cap_nhat varchar(50) NULL,
	ngay_xoa timestamp NULL,
	nguoi_xoa varchar(50) NULL,
	thoi_gian_bat_dau_xem timestamp DEFAULT now() NULL,
	thoi_gian_ket_thuc_xem timestamp NULL,
	nguoi_xem varchar(50) NULL,
	khoa_id uuid NULL,
	nguon_xem varchar(200) NULL,
	so_benh_an varchar(50) NULL,
	ma_nb varchar(50) NULL,
	ten_benh_nhan varchar(255) NULL,
	ma_loai_dieu_tri varchar(255) NULL,
	CONSTRAINT emr_lichsu_xem_hsba_pkey PRIMARY KEY (id)
);

CREATE TABLE emr_loaibenhan (
	id uuid DEFAULT gen_random_uuid() NOT NULL,
	loaibenhanid varchar(50) NOT NULL,
	rpt_code varchar(100) NULL,
	rpt_code_sum varchar(100) NULL,
	phauthuat int2 DEFAULT 0 NULL,
	tenloaibenhan varchar(255) NOT NULL,
	hoat_dong int2 DEFAULT 1 NULL,
	bi_xoa int2 DEFAULT 0 NULL,
	ngay_tao timestamp DEFAULT now() NULL,
	nguoi_tao varchar(50) NULL,
	ngay_cap_nhat timestamp DEFAULT now() NULL,
	nguoi_cap_nhat varchar(50) NULL,
	ngay_xoa timestamp NULL,
	nguoi_xoa varchar(50) NULL,
	CONSTRAINT emr_loaibenhan_pkey PRIMARY KEY (id)
);

CREATE TABLE emr_phieu_bangiao (
	id uuid DEFAULT gen_random_uuid() NOT NULL,
	ma_cskcb varchar(50) NULL,
	hoat_dong int2 DEFAULT 1 NULL,
	bi_xoa int2 DEFAULT 0 NULL,
	ngay_tao timestamp DEFAULT now() NULL,
	nguoi_tao varchar(50) NULL,
	ngay_cap_nhat timestamp DEFAULT now() NULL,
	nguoi_cap_nhat varchar(50) NULL,
	ngay_xoa timestamp NULL,
	nguoi_xoa varchar(50) NULL,
	so_phieu_bangiao varchar(50) NULL,
	thoi_gian_bangiao timestamp DEFAULT now() NOT NULL,
	khoa_phong_id uuid NOT NULL,
	nguoi_bangiao varchar(100) NOT NULL,
	ghi_chu varchar(1000) NULL,
	tong_so_ho_so int4 DEFAULT 0 NULL,
	trang_thai_phieu int2 DEFAULT 0 NULL, -- Trạng thái bàn giao:¶0-Chưa bàn giao (default)¶1-Đã bàn giao¶2-Từ chối,3-Hoàn thành,4-Đang xử lý
	ky_so text NULL,
	CONSTRAINT emr_phieu_bangiao_pkey PRIMARY KEY (id)
);

CREATE TABLE emr_phieu_bangiao_chitiet (
	id uuid DEFAULT gen_random_uuid() NOT NULL,
	ma_cskcb varchar(50) NULL,
	hoat_dong int2 DEFAULT 1 NULL,
	bi_xoa int2 DEFAULT 0 NULL,
	ngay_tao timestamp DEFAULT now() NULL,
	nguoi_tao varchar(50) NULL,
	ngay_cap_nhat timestamp DEFAULT now() NULL,
	nguoi_cap_nhat varchar(50) NULL,
	ngay_xoa timestamp NULL,
	nguoi_xoa varchar(50) NULL,
	phieu_bangiao_id uuid NOT NULL,
	stt int4 NULL,
	so_benh_an varchar(50) NULL,
	ma_nb varchar(50) NULL,
	ten_benh_nhan varchar(255) NULL,
	ngay_sinh date NULL,
	dia_chi_thuong_tru varchar(500) NULL,
	dan_toc varchar(100) NULL,
	so_bhyt varchar(50) NULL,
	ngay_vao_vien date NULL,
	chan_doan_vao_vien varchar(500) NULL,
	ngay_ra_vien date NULL,
	chan_doan_ra_vien varchar(500) NULL,
	loai_dieu_tri varchar(100) NULL,
	tinh_trang_ra_vien varchar(255) NULL,
	trang_thai_hsba int2 DEFAULT 0 NOT NULL,
	ly_do_tu_choi text NULL,
	nguoi_tiep_nhan varchar(100) NULL,
	thoi_gian_tiep_nhan timestamp(6) NULL,
	y_kien_tiep_nhan varchar(1000) NULL,
	ngay_luu_tru date NULL,
	da_luu_tru int2 NULL,
	so_luu_tru varchar(255) NULL,
	kho_id uuid NULL,
	kho_ke_id uuid NULL,
	kho_hang_id uuid NULL,
	ghi_chu_luu_tru varchar(1000) NULL,
	so_tiep_nhan varchar(50) NULL,
	loai_benh_an varchar(255) NULL,
	ngay_giahan date NULL,
	ma_loai_dieu_tri varchar(255) NULL,
	benh_an_id uuid NULL,
	tiep_nhan_id uuid NULL,
	CONSTRAINT emr_phieu_bangiao_chitiet_pkey PRIMARY KEY (id)
);

CREATE TABLE emr_phieu_muontra (
	id uuid DEFAULT gen_random_uuid() NOT NULL,
	ma_cskcb varchar(50) NULL,
	hoat_dong int2 DEFAULT 1 NULL,
	bi_xoa int2 DEFAULT 0 NULL,
	ngay_tao timestamp(6) DEFAULT now() NULL,
	nguoi_tao varchar(50) NULL,
	ngay_cap_nhat timestamp(6) DEFAULT now() NULL,
	nguoi_cap_nhat varchar(50) NULL,
	ngay_xoa timestamp(6) NULL,
	nguoi_xoa varchar(50) NULL,
	ma_phieu_muon varchar(25) NULL, -- Mã phiếu mượn, sinh tự động theo quy tắc hệ thống. VD: PM261125001
	ngay_muon timestamp(6) DEFAULT now() NOT NULL,
	nguoi_muon varchar(100) NOT NULL,
	nguoi_muon_id uuid NULL,
	khoa_phong_id uuid NOT NULL,
	ngay_hen_tra date NOT NULL,
	thuc_tap_hoc_viec int2 DEFAULT 0 NULL, -- 0: Không phải thực tập/học việc (default); 1: Thực tập/học việc
	nguoi_huong_dan varchar(255) NULL,
	nguoi_huong_dan_id uuid NULL,
	ly_do_muon varchar(500) NOT NULL,
	tong_so_ho_so int4 DEFAULT 0 NULL,
	trang_thai_phieu int2 DEFAULT 0 NULL, -- Trạng thái phiếu mượn:¶0-Chờ duyệt (default)¶1-Đã mượn¶2-Chờ trả¶3-Đã trả¶4-Quá hạn¶5-Từ chối
	ghi_chu_tra varchar(500) NULL, -- Ghi chú khi trả hồ sơ
	nguoi_xac_nhan_tra varchar(100) NULL, -- Người xác nhận đã nhận lại đủ hồ sơ
	nguoi_xac_nhan_tra_id uuid NULL,
	ngay_xac_nhan_tra timestamp(6) NULL, -- Ngày xác nhận trả đủ toàn bộ HSBA trong phiếu
	"type" int2 DEFAULT 0 NULL, -- Loại phiếu: 0-Phiếu mượn (default), 1-Phiếu trả
	phieu_muon_id uuid NULL, -- ID phiếu mượn gốc khi tạo phiếu trả (type=1); tham chiếu emr_phieu_muontra.id. NULL với phiếu mượn
	hososohoa_id uuid NULL,
	trang_thai_phe_duyet int2 DEFAULT 0 NULL,
	CONSTRAINT emr_phieu_muontra_pkey PRIMARY KEY (id)
);

CREATE TABLE emr_phieu_muontra_chitiet (
	id uuid DEFAULT gen_random_uuid() NOT NULL,
	ma_cskcb varchar(50) NULL,
	hoat_dong int2 DEFAULT 1 NULL,
	bi_xoa int2 DEFAULT 0 NULL,
	ngay_tao timestamp(6) DEFAULT now() NULL,
	nguoi_tao varchar(50) NULL,
	ngay_cap_nhat timestamp(6) DEFAULT now() NULL,
	nguoi_cap_nhat varchar(50) NULL,
	ngay_xoa timestamp(6) NULL,
	nguoi_xoa varchar(50) NULL,
	phieu_muon_id uuid NOT NULL, -- FK tham chiếu đến emr_phieu_muontra.id
	stt int4 NULL,
	so_luu_tru varchar(255) NULL, -- Số/mã lưu trữ hồ sơ trong kho
	so_benh_an varchar(50) NULL,
	ma_benh_nhan varchar(50) NULL,
	ten_benh_nhan varchar(255) NULL,
	loai_dieu_tri varchar(100) NULL,
	ngay_sinh date NULL,
	dia_chi_thuong_tru varchar(500) NULL,
	ngay_vao_vien date NULL,
	chan_doan_vao_vien varchar(500) NULL,
	ngay_ra_vien date NULL,
	chan_doan_ra_vien varchar(500) NULL,
	tinh_trang_ra_vien varchar(255) NULL,
	kho_id uuid NULL, -- FK tham chiếu đến emr_dm_kho.id
	kho_ke_id uuid NULL, -- FK tham chiếu đến emr_dm_kho_ke.id
	kho_hang_id uuid NULL, -- FK tham chiếu đến emr_dm_kho_hang.id
	trang_thai int2 DEFAULT 0 NULL, -- Trạng thái trả của từng HSBA: 0-Đang mượn (default), 1-Đã trả
	ngay_tra timestamp(6) NULL, -- Ngày giờ HSBA này được trả lại kho
	nguoi_tra varchar(100) NULL, -- Người thực hiện trả HSBA này
	nguoi_tra_id uuid NULL,
	chitiet_muon_id uuid NULL, -- ID dòng chi tiết phiếu mượn gốc được trả (emr_phieu_muontra_chitiet.id thuộc phiếu mượn). Chỉ áp dụng cho dòng thuộc phiếu trả; NULL với dòng phiếu mượn
	CONSTRAINT emr_phieu_muontra_chitiet_pkey PRIMARY KEY (id)
);

CREATE TABLE emr_ql_so_tuan_tu (
	id uuid DEFAULT gen_random_uuid() NOT NULL,
	loai_ho_so varchar(50) NOT NULL,
	don_vi_tang int4 DEFAULT 1 NOT NULL,
	gioi_han int4 DEFAULT 9999 NOT NULL,
	so_luong_so int4 DEFAULT 4 NOT NULL,
	stt int4 DEFAULT 0 NOT NULL,
	ngay_hien_tai date DEFAULT CURRENT_DATE NOT NULL,
	"type" bpchar(1) DEFAULT 'M'::bpchar NOT NULL,
	str_tuan_tu varchar(100) NULL,
	CONSTRAINT emr_ql_so_tuan_tu_loai_ho_so_key UNIQUE (loai_ho_so),
	CONSTRAINT emr_ql_so_tuan_tu_pkey PRIMARY KEY (id)
);

CREATE TABLE emr_uy_quyen_ky_so (
	id uuid DEFAULT gen_random_uuid() NOT NULL,
	ma_cskcb varchar(50) NULL,
	bi_xoa int2 DEFAULT 0 NOT NULL,
	ngay_tao timestamp DEFAULT now() NOT NULL,
	nguoi_tao varchar(50) NULL,
	ngay_cap_nhat timestamp DEFAULT now() NOT NULL,
	nguoi_cap_nhat varchar(50) NULL,
	ngay_xoa timestamp NULL,
	nguoi_xoa varchar(50) NULL,
	nguoi_uy_quyen_id uuid NOT NULL,
	trang_thai varchar(30) NOT NULL,
	tu_ngay date NOT NULL,
	den_ngay date NOT NULL,
	ly_do_huy varchar(500) NULL,
	ngay_huy timestamp NULL,
	ngay_ap_dung timestamp NULL,
	CONSTRAINT ck_emr_uqks_date CHECK ((den_ngay >= tu_ngay)),
	CONSTRAINT ck_emr_uqks_status CHECK (((trang_thai)::text = ANY (ARRAY[('SOAN_THAO'::character varying)::text, ('DA_XAC_NHAN'::character varying)::text, ('HIEU_LUC_MOT_PHAN'::character varying)::text, ('HIEU_LUC'::character varying)::text, ('HUY_BO'::character varying)::text, ('HET_HAN'::character varying)::text]))),
	CONSTRAINT emr_uy_quyen_ky_so_pkey PRIMARY KEY (id)
);

CREATE TABLE erdiagram (
	id int8 NOT NULL,
	rpt_code varchar(255) NOT NULL,
	rpt_name varchar(255) NOT NULL,
	format_type varchar(10) NOT NULL,
	report_template text NULL,
	status int4 NULL,
	record_type int2 NULL,
	company_id int8 NOT NULL,
	table_ref varchar(50) NOT NULL,
	field_ref varchar(50) NOT NULL,
	flag_ref varchar(50) NOT NULL,
	is_sign_level int2 NOT NULL,
	is_total_cancellation int2 NOT NULL,
	is_emr int2 NULL,
	is_sign_group int2 NULL,
	description varchar(2000) NULL,
	required_sign int2 NOT NULL,
	field_sort varchar(255) NULL,
	created_by int8 NULL,
	created_date timestamp NOT NULL,
	last_modified_by int8 NULL,
	last_modified_date timestamp NULL,
	CONSTRAINT erdiagram_pkey PRIMARY KEY (id)
);

CREATE TABLE hang_cho_kham_phong_kham (
	id uuid DEFAULT gen_random_uuid() NOT NULL,
	phong_kham_id uuid NULL,
	so_tt_kham int4 NOT NULL,
	thoi_gian_bat_dau timestamp NULL,
	thoi_gian_ket_thuc timestamp NULL,
	ma_cskcb varchar(25) NOT NULL,
	CONSTRAINT hang_cho_kham_phong_kham_ma_cskcb_so_tt_kham_key UNIQUE (ma_cskcb, so_tt_kham),
	CONSTRAINT hang_cho_kham_phong_kham_pkey PRIMARY KEY (id)
);

CREATE TABLE hang_cho_kham_stt (
	id uuid DEFAULT gen_random_uuid() NOT NULL,
	ma_cskcb varchar(25) NOT NULL,
	so_tt_da_boc int4 DEFAULT 0 NOT NULL,
	so_tt_dang_goi int4 DEFAULT 0 NOT NULL,
	CONSTRAINT hang_cho_kham_stt_ma_cskcb_key UNIQUE (ma_cskcb),
	CONSTRAINT hang_cho_kham_stt_pkey PRIMARY KEY (id)
);

CREATE TABLE hang_cho_kham_trang_thai (
	id uuid DEFAULT gen_random_uuid() NOT NULL,
	ma_trang_thai varchar(25) NOT NULL,
	ten_trang_thai varchar(100) NOT NULL,
	so_tt_kham int4 NOT NULL,
	ma_cskcb varchar(25) NULL,
	CONSTRAINT hang_cho_kham_trang_thai_ma_trang_thai_key UNIQUE (ma_trang_thai),
	CONSTRAINT hang_cho_kham_trang_thai_pkey PRIMARY KEY (id)
);

CREATE TABLE hinh_thuc_goi_kham (
	ma varchar NOT NULL,
	ten varchar NOT NULL,
	id uuid DEFAULT gen_random_uuid() NOT NULL, -- Key của bảng
	ngay_tao timestamp DEFAULT now() NOT NULL, -- Ngày tạo
	nguoi_tao varchar DEFAULT 'system'::character varying NOT NULL, -- Người tạo
	ngay_cap_nhat timestamp DEFAULT now() NOT NULL, -- Ngày cập nhật
	nguoi_cap_nhat varchar DEFAULT 'system'::character varying NOT NULL, -- Người cập nhật
	bi_xoa int2 DEFAULT 0 NULL, -- Bị xóa mềm
	ngay_xoa timestamp NULL, -- Ngày xóa mềm
	nguoi_xoa varchar NULL, -- Người xóa mềm
	CONSTRAINT hinh_thuc_goi_kham_ma_key UNIQUE (ma),
	CONSTRAINT hinh_thuc_goi_kham_pkey PRIMARY KEY (id)
);

CREATE TABLE hinh_thuc_phan_bo_ksk (
	ma varchar NOT NULL,
	ten varchar NOT NULL,
	id uuid DEFAULT gen_random_uuid() NOT NULL, -- Key của bảng
	ngay_tao timestamp DEFAULT now() NOT NULL, -- Ngày tạo
	nguoi_tao varchar DEFAULT 'system'::character varying NOT NULL, -- Người tạo
	ngay_cap_nhat timestamp DEFAULT now() NOT NULL, -- Ngày cập nhật
	nguoi_cap_nhat varchar DEFAULT 'system'::character varying NOT NULL, -- Người cập nhật
	bi_xoa int2 DEFAULT 0 NULL, -- Bị xóa mềm
	ngay_xoa timestamp NULL, -- Ngày xóa mềm
	nguoi_xoa varchar NULL, -- Người xóa mềm
	CONSTRAINT hinh_thuc_phan_bo_ksk_ma_key UNIQUE (ma),
	CONSTRAINT hinh_thuc_phan_bo_ksk_pkey PRIMARY KEY (id)
);

CREATE TABLE hoi_dong_ksk (
	id uuid DEFAULT gen_random_uuid() NOT NULL,
	ma varchar(25) NOT NULL,
	ten varchar(255) NOT NULL,
	loai_ksk_id uuid NOT NULL,
	hop_dong_id uuid NULL,
	ngay_bat_dau timestamp NULL,
	ngay_ket_thuc timestamp NULL,
	so_luong_du_kien int8 NULL,
	dieu_phoi_vien_id uuid NULL,
	ghi_chu text NULL,
	hoat_dong int2 NOT NULL,
	ma_cskcb varchar(10) NOT NULL,
	bi_xoa int2 DEFAULT 0 NOT NULL,
	ngay_tao timestamp DEFAULT CURRENT_TIMESTAMP NOT NULL,
	ngay_cap_nhat timestamp DEFAULT CURRENT_TIMESTAMP NOT NULL,
	nguoi_tao varchar(100) NULL,
	nguoi_cap_nhat varchar(100) NULL,
	ngay_xoa timestamp NULL,
	nguoi_xoa varchar(50) NULL,
	bac_si_phu_trach_id uuid NULL,
	CONSTRAINT hoi_dong_ksk_pkey PRIMARY KEY (id)
);

CREATE TABLE hop_dong_ksk (
	id uuid DEFAULT gen_random_uuid() NOT NULL,
	ke_hoach_ksk_id uuid NULL,
	so_hop_dong varchar NOT NULL,
	ngay_hop_dong date NOT NULL,
	tt_phat_sinh_id uuid NOT NULL,
	ngay_lay_mau date NOT NULL,
	ten_hop_dong varchar NOT NULL,
	don_vi_ksk_id uuid NOT NULL,
	gia_tri_hop_dong numeric NULL,
	tien_phat_sinh numeric NULL,
	nguoi_khoa varchar NULL,
	ngay_hieu_luc date NOT NULL,
	ngay_het_han date NULL,
	so_luong_nguoi_kham int4 NOT NULL,
	khoa int2 NOT NULL,
	ngay_khoa timestamp NULL,
	trang_thai_hop_dong_ma varchar NOT NULL,
	loai_hop_dong_id uuid NULL,
	kham_tu_ngay date NULL,
	kham_den_ngay date NULL,
	ti_le_giam numeric NULL,
	so_tien_giam numeric NULL,
	nhan_vien_sale_id uuid NULL,
	kham_trong_vien int2 NOT NULL,
	su_dung int2 NOT NULL,
	ma_cskcb varchar(10) NOT NULL,
	bi_xoa int2 DEFAULT 0 NOT NULL,
	ngay_tao timestamp DEFAULT CURRENT_TIMESTAMP NOT NULL,
	ngay_cap_nhat timestamp DEFAULT CURRENT_TIMESTAMP NOT NULL,
	nguoi_tao varchar(100) NOT NULL,
	nguoi_cap_nhat varchar(100) NULL,
	ngay_xoa timestamp NULL,
	nguoi_xoa varchar(50) NULL,
	kham_ngoai_vien int2 NOT NULL,
	hinh_thuc_phan_bo_id uuid NULL,
	ghi_chu varchar NULL,
	hoi_dong_id uuid NULL,
	vung_du_lieu varchar(20) DEFAULT 'VUNG_NGOAI'::character varying NOT NULL,
	CONSTRAINT hop_dong_ksk_pkey PRIMARY KEY (id)
);

CREATE TABLE hsba_phieu (
	id int8 NOT NULL,
	phieuid varchar(50) NULL,
	hosobenhanid int8 NULL,
	transaction_id varchar(255) NULL,
	loaiphieu int4 NULL,
	ma_phieu varchar(255) NULL,
	nguoi_ky int8 NULL,
	thoigian_ky timestamp NULL,
	nguoi_huy int8 NULL,
	thoigian_huy timestamp NULL,
	ngayravien timestamp NULL,
	status int2 NULL,
	json_data jsonb NULL,
	created_by int8 NULL,
	created_date timestamp NULL,
	last_modified_by int8 NULL,
	last_modified_date timestamp NULL,
	table_ref varchar(50) NOT NULL,
	comlumn_ref varchar(50) NOT NULL,
	flag_ref varchar(50) NOT NULL,
	khambenhid int8 NOT NULL,
	tiepnhanid int8 NOT NULL,
	sign_url varchar(300) NULL,
	param varchar(1000) NULL,
	format_type varchar(5) NULL,
	sign_level_curr int2 NULL,
	assignee_code_curr varchar(100) NULL,
	dl_kx varchar(300) NULL,
	trangthai_kx int2 NULL,
	service_code varchar(50) NULL,
	CONSTRAINT hsba_phieu_pkey PRIMARY KEY (id)
);

CREATE TABLE hsba_phieu_ky (
	id int8 NOT NULL,
	id_bangiao int8 NULL,
	hsba_phieuid int8 NOT NULL,
	hosobenhanid int8 NULL,
	khambenhid int8 NULL,
	tiepnhanid int8 NULL,
	ky_bangiao int2 NULL,
	dulieu_phieuky varchar(500) NULL,
	nguoiky int8 NOT NULL,
	ngayky timestamp NOT NULL,
	taikhoan_ky varchar(50) NULL,
	transaction_id varchar(50) NULL,
	assign_code varchar(50) NULL,
	status int2 NULL,
	CONSTRAINT hsba_phieu_ky_pkey PRIMARY KEY (id)
);

CREATE TABLE htg_log_action (
	log_action_id numeric(13) NULL,
	username varchar(50) NULL,
	ngaytao timestamp NULL,
	ngaycapnhat timestamp NULL,
	chucnang varchar(250) NULL,
	package varchar(30) NULL,
	"procedure" varchar(30) NULL,
	noidung text NULL,
	ketqua text NULL,
	trangthai numeric(10) NULL
);

CREATE TABLE htg_log_action_exp (
	log_action_id numeric(13) NULL,
	username varchar(50) NULL,
	ngaytao timestamp NULL,
	ngaycapnhat timestamp NULL,
	chucnang varchar(250) NULL,
	package varchar(30) NULL,
	"procedure" varchar(30) NULL,
	noidung text NULL,
	ketqua text NULL,
	trangthai numeric(10) NULL
);

CREATE TABLE htg_log_action_tmp (
	log_action_id numeric(13) NULL,
	username varchar(50) NULL,
	ngaytao timestamp NULL,
	ngaycapnhat timestamp NULL,
	chucnang varchar(250) NULL,
	package varchar(30) NULL,
	"procedure" varchar(30) NULL,
	noidung text NULL,
	ketqua text NULL,
	trangthai numeric(10) NULL
);

CREATE TABLE htg_log_config (
	loggingfunctionid numeric(22) NULL,
	package varchar(30) NULL,
	"procedure" varchar(30) NULL,
	islog numeric(1) DEFAULT 1 NULL,
	logwhenover numeric(3) DEFAULT 0 NULL
);

CREATE TABLE import_data_bhyt (
	stt int4 NULL,
	ma_bn text NULL,
	ho_ten text NULL,
	ngay_sinh text NULL,
	gioi_tinh text NULL,
	dia_chi text NULL,
	ma_the text NULL,
	ma_dkbd text NULL,
	gt_the_tu text NULL,
	gt_the_den text NULL,
	ma_benh text NULL,
	ma_benhkhac text NULL,
	ma_lydo_vvien text NULL,
	ma_noi_chuyen text NULL,
	ngay_vao text NULL,
	ngay_ra text NULL,
	so_ngay_dtri int4 NULL,
	ket_qua_dtri int4 NULL,
	tinh_trang_rv int4 NULL,
	t_tongchi numeric(18, 2) NULL,
	t_xn numeric(18, 2) NULL,
	t_cdha numeric(18, 2) NULL,
	t_thuoc numeric(18, 2) NULL,
	t_mau numeric(18, 2) NULL,
	t_pttt numeric(18, 2) NULL,
	t_vtyt numeric(18, 2) NULL,
	t_dvkt_tyle numeric(18, 2) NULL,
	t_thuoc_tyle numeric(18, 2) NULL,
	t_vtyt_tyle numeric(18, 2) NULL,
	t_kham numeric(18, 2) NULL,
	t_giuong numeric(18, 2) NULL,
	t_vchuyen numeric(18, 2) NULL,
	t_bntt numeric(18, 2) NULL,
	t_bhtt numeric(18, 2) NULL,
	t_ngoaids numeric(18, 2) NULL,
	ma_khoa text NULL,
	nam_qt int4 NULL,
	thang_qt int4 NULL,
	ma_khuvuc text NULL,
	ma_loaikcb text NULL,
	ma_cskcb text NULL,
	t_nguonkhac numeric(18, 2) NULL,
	ma_lk text NULL,
	ngay_yl date NULL,
	thoi_gian_yl timestamp NULL
);

CREATE TABLE import_data_bhyt_chi_tiet (
	stt text NULL,
	ma_lk text NULL,
	ten_benh_nhan text NULL,
	ngay_sinh text NULL,
	gioi_tinh text NULL,
	ngay_vao text NULL,
	ngay_ra text NULL,
	ma_chi_phi text NULL,
	ten_chi_phi text NULL,
	dvt text NULL,
	so_luong int4 NULL,
	don_gia_bhyt int4 NULL,
	don_gia_bv int4 NULL,
	muc_huong int4 NULL,
	ty_le_dv int4 NULL,
	ty_le_bh int4 NULL,
	thanh_tien_bv int4 NULL,
	thanh_tien_bh int4 NULL,
	tran_tt int4 NULL,
	bhyt_tt int4 NULL,
	nguon_khac int4 NULL,
	bn_tu_tra int4 NULL,
	bn_cung_chi_tra int4 NULL
);

CREATE TABLE kb_chuyen_khoa_mat (
	id uuid DEFAULT gen_random_uuid() NOT NULL,
	tiep_nhan_id uuid NULL,
	benh_nhan_id uuid NULL,
	ma_cskcb varchar(50) NULL,
	bac_si_thuc_hien_id uuid NULL,
	thoi_gian_kham timestamp NULL,
	phong_kham_id uuid NULL,
	thi_luc_mp_khong_kinh varchar(50) NULL,
	thi_luc_mp_co_kinh varchar(50) NULL,
	thi_luc_mp_kinh_lo varchar(50) NULL,
	thi_luc_mt_khong_kinh varchar(50) NULL,
	thi_luc_mt_co_kinh varchar(50) NULL,
	thi_luc_mt_kinh_lo varchar(50) NULL,
	khuc_xa_mp_sph_lan_1 numeric(10, 2) NULL,
	khuc_xa_mp_sph_lan_2 numeric(10, 2) NULL,
	khuc_xa_mp_sph_lan_3 numeric(10, 2) NULL,
	khuc_xa_mp_sph_avg numeric(10, 2) NULL,
	khuc_xa_mp_cyl_lan_1 numeric(10, 2) NULL,
	khuc_xa_mp_cyl_lan_2 numeric(10, 2) NULL,
	khuc_xa_mp_cyl_lan_3 numeric(10, 2) NULL,
	khuc_xa_mp_cyl_avg numeric(10, 2) NULL,
	khuc_xa_mp_ax_lan_1 numeric(10, 2) NULL,
	khuc_xa_mp_ax_lan_2 numeric(10, 2) NULL,
	khuc_xa_mp_ax_lan_3 numeric(10, 2) NULL,
	khuc_xa_mp_ax_avg numeric(10, 2) NULL,
	khuc_xa_mt_sph_lan_1 numeric(10, 2) NULL,
	khuc_xa_mt_sph_lan_2 numeric(10, 2) NULL,
	khuc_xa_mt_sph_lan_3 numeric(10, 2) NULL,
	khuc_xa_mt_sph_avg numeric(10, 2) NULL,
	khuc_xa_mt_cyl_lan_1 numeric(10, 2) NULL,
	khuc_xa_mt_cyl_lan_2 numeric(10, 2) NULL,
	khuc_xa_mt_cyl_lan_3 numeric(10, 2) NULL,
	khuc_xa_mt_cyl_avg numeric(10, 2) NULL,
	khuc_xa_mt_ax_lan_1 numeric(10, 2) NULL,
	khuc_xa_mt_ax_lan_2 numeric(10, 2) NULL,
	khuc_xa_mt_ax_lan_3 numeric(10, 2) NULL,
	khuc_xa_mt_ax_avg numeric(10, 2) NULL,
	se_r numeric(10, 2) NULL,
	se_l numeric(10, 2) NULL,
	pd numeric(10, 2) NULL,
	nhan_ap_mat_trai numeric(10, 2) NULL,
	nhan_ap_mat_phai numeric(10, 2) NULL,
	mi_mat_binh_thuong bool DEFAULT false NULL,
	mi_mat_co_quap bool DEFAULT false NULL,
	mi_mat_viem bool DEFAULT false NULL,
	mi_mat_phu_ne bool DEFAULT false NULL,
	mi_mat_tu_mau bool DEFAULT false NULL,
	ket_mac_binh_thuong bool DEFAULT false NULL,
	ket_mac_cuong_tu bool DEFAULT false NULL,
	ket_mac_xuat_huyet bool DEFAULT false NULL,
	giac_mac_trong bool DEFAULT false NULL,
	giac_mac_phu bool DEFAULT false NULL,
	giac_mac_seo bool DEFAULT false NULL,
	giac_mac_khac bool DEFAULT false NULL,
	tien_phong_do_sau varchar(100) NULL,
	tien_phong_goc varchar(100) NULL,
	tien_phong_nguy_co_dong_goc varchar(255) DEFAULT false NULL,
	mong_mat_binh_thuong bool DEFAULT false NULL,
	mong_mat_bat_thuong bool DEFAULT false NULL,
	mong_mat_mo_ta_bat_thuong text NULL,
	dong_tu_duong_kinh varchar(50) NULL,
	dong_tu_hinh_dang varchar(50) NULL,
	dong_tu_phan_xa_anh_sang varchar(100) NULL,
	thuy_tinh_the_duc bool DEFAULT false NULL,
	thuy_tinh_the_trong bool DEFAULT false NULL,
	thuy_tinh_the_lech bool DEFAULT false NULL,
	dich_kinh varchar(255) NULL,
	vong_mac varchar(255) NULL,
	chan_doan text NULL,
	don_kinh text NULL,
	don_thuoc text NULL,
	ngay_tao timestamp DEFAULT CURRENT_TIMESTAMP NULL,
	nguoi_tao varchar(50) NULL,
	ngay_cap_nhat timestamp NULL,
	nguoi_cap_nhat varchar(50) NULL,
	bi_xoa int2 DEFAULT 0 NULL,
	ngay_xoa timestamp NULL,
	nguoi_xoa varchar(50) NULL,
	CONSTRAINT kb_chuyen_khoa_mat_pkey PRIMARY KEY (id)
);

CREATE TABLE kb_chuyen_khoa_rhm (
	id uuid DEFAULT gen_random_uuid() NOT NULL,
	tiep_nhan_id uuid NOT NULL, -- ID tiếp nhận
	benh_nhan_id uuid NOT NULL, -- ID bệnh nhân
	ma_cskcb varchar(50) NOT NULL,
	ham_tren varchar(255) NULL, -- Hàm trên
	ham_duoi varchar(255) NULL, -- Hàm dưới
	tom_tat_ket_qua varchar(255) NULL, -- Tóm tắt kết quả
	phan_loai varchar(255) NULL, -- Phân loại
	ngay_tao timestamp DEFAULT CURRENT_TIMESTAMP NULL,
	nguoi_tao varchar(50) NULL,
	ngay_cap_nhat timestamp NULL,
	nguoi_cap_nhat varchar(50) NULL,
	bi_xoa int2 DEFAULT 0 NULL,
	ngay_xoa timestamp NULL,
	nguoi_xoa varchar(50) NULL,
	bac_si_id uuid NULL, -- ID bác sĩ khám
	thoi_gian_kham timestamp NULL, -- Thời gian thực hiện khám
	phong_kham_id uuid NULL, -- ID phòng khám
	CONSTRAINT kb_chuyen_khoa_rhm_pkey PRIMARY KEY (id)
);

CREATE TABLE kb_chuyen_khoa_tmh (
	id uuid DEFAULT gen_random_uuid() NOT NULL,
	tiep_nhan_id uuid NOT NULL, -- ID tiếp nhận
	benh_nhan_id uuid NOT NULL, -- ID bệnh nhân
	ma_cskcb varchar(50) NOT NULL,
	tinh_trang_tai_ngoai text NULL, -- Tình trạng tai ngoài
	thinh_luc text NULL, -- Thính lực chung
	thinh_luc_tai_trai text NULL, -- Thính lực tai trái
	thinh_luc_tai_phai text NULL, -- Thính lực tai phải
	do_thinh_luc text NULL, -- Kết quả đo thính lực
	do_thinh_luc_tai_trai text NULL, -- Đo thính lực tai trái
	do_thinh_luc_tai_phai text NULL, -- Đo thính lực tai phải
	noi_soi_tmh text NULL, -- Kết quả nội soi TMH
	tom_tat_ket_qua text NULL, -- Tóm tắt kết quả khám
	phan_loai varchar(50) NULL, -- Phân loại sức khỏe TMH (I, II, III, IV, V)
	ngay_tao timestamp DEFAULT CURRENT_TIMESTAMP NULL,
	nguoi_tao varchar(50) NULL,
	ngay_cap_nhat timestamp NULL,
	nguoi_cap_nhat varchar(50) NULL,
	bi_xoa int2 DEFAULT 0 NULL,
	ngay_xoa timestamp NULL,
	nguoi_xoa varchar(50) NULL,
	bac_si_id uuid NULL, -- ID bác sĩ khám
	thoi_gian_kham timestamp NULL, -- Thời gian thực hiện khám
	phong_kham_id uuid NULL, -- ID phòng khám
	CONSTRAINT kb_chuyen_khoa_tmh_pkey PRIMARY KEY (id)
);

CREATE TABLE kb_chuyen_khoa_yhct (
	id uuid DEFAULT gen_random_uuid() NOT NULL,
	tiep_nhan_id uuid NOT NULL, -- ID tiếp nhận
	benh_nhan_id uuid NOT NULL, -- ID bệnh nhân
	ma_cskcb varchar(50) NOT NULL,
	vong_chan text NULL, -- I. Vọng chẩn (nhìn)
	van_chan text NULL, -- II. Văn chẩn (nghe, ngửi)
	van_chan_hoi text NULL, -- III. Vấn chẩn (hỏi)
	xuc_chan text NULL,
	mach_chan text NULL,
	mach_tay_trai text NULL,
	mach_tay_phai text NULL,
	tom_tat_tu_chan text NULL, -- V. Tóm tắt tứ chẩn
	bien_chung_luan_tri text NULL, -- VI. Biện chứng luận trị
	benh_danh text NULL, -- Bệnh danh YHCT
	tang_phu text NULL, -- Tạng phủ
	kinh_mach text NULL, -- Kinh mạch
	dinh_vi_benh text NULL, -- Định vị bệnh (dinh, vệ, khí, huyết)
	dieu_tri_don_thuan_yhct text NULL,
	phap_dieu_tri text NULL,
	phuong_duoc text NULL,
	pp_dieu_tri_khong_dung_thuoc text NULL,
	dieu_tri_ket_hop_yhct text NULL,
	che_do_dinh_duong_tai_nha text NULL,
	che_do_ho_ly_tai_nha text NULL,
	tien_luong text NULL,
	ngay_tao timestamp DEFAULT CURRENT_TIMESTAMP NULL,
	nguoi_tao varchar(50) NULL,
	ngay_cap_nhat timestamp NULL,
	nguoi_cap_nhat varchar(50) NULL,
	bi_xoa int2 DEFAULT 0 NULL,
	ngay_xoa timestamp NULL,
	nguoi_xoa varchar(50) NULL,
	bac_si_id uuid NULL, -- ID bác sĩ khám
	thoi_gian_kham timestamp NULL, -- Thời gian thực hiện khám
	phong_kham_id uuid NULL, -- ID phòng khám
	CONSTRAINT kb_chuyen_khoa_yhct_pkey PRIMARY KEY (id)
);

CREATE TABLE kb_dau_hieu_sinh_ton (
	id uuid DEFAULT gen_random_uuid() NOT NULL, -- ID duy nhất (UUID v7)
	benh_nhan_id uuid NOT NULL, -- ID bệnh nhân
	tiep_nhan_id uuid NOT NULL, -- ID tiếp nhận
	thoi_gian_do timestamp NULL, -- Thời gian đo
	chieu_cao float8 NULL, -- Chiều cao (cm)
	can_nang float8 NULL, -- Cân nặng (kg)
	bmi float8 NULL, -- Chỉ số BMI
	ghi_chu text NULL,
	mach float8 NULL, -- Mạch (lần/phút)
	huyet_ap_tam_thu int4 NULL, -- Huyết áp tâm thu (mmHg)
	huyet_ap_tam_truong int4 NULL, -- Huyết áp tâm trương (mmHg)
	nhiet_do float8 NULL, -- Nhiệt độ (°C)
	nhip_tho float8 NULL, -- Nhịp thở (lần/phút)
	vong_bung float8 NULL,
	vong_dau float8 NULL,
	spo2 float8 NULL, -- SpO2 (%)
	thang_diem_dau int4 NULL,
	vong_nguc float8 NULL,
	tri_giac varchar(50) NULL,
	su_dung bool NULL,
	nguoi_tao varchar(100) NULL,
	ngay_tao timestamp NULL,
	nguoi_cap_nhat varchar(100) NULL,
	ngay_cap_nhat timestamp NULL,
	bi_xoa int2 DEFAULT 0 NOT NULL, -- Trạng thái xóa: 0-Chưa xóa, 1-Đã xóa
	nguoi_xoa varchar(100) NULL,
	ngay_xoa timestamp NULL,
	ma_cskcb varchar(20) NOT NULL, -- Mã cơ sở khám chữa bệnh
	phong_ban_id uuid NULL,
	do_dhst int2 NULL,
	CONSTRAINT kb_dau_hieu_sinh_ton_pkey PRIMARY KEY (id)
);

CREATE TABLE kb_dinh_muc_hoa_chat (
	id uuid DEFAULT gen_random_uuid() NOT NULL, -- Key của bảng
	ma_cskcb varchar(20) NULL,
	ma_may_xn uuid NULL, -- ID máy xét nghiệm (dmc_vat_tu_trang_thiet_bi.id)
	ma_dv uuid NULL, -- ID dịch vụ kỹ thuật (dm_dich_vu_kt.id)
	ma_hoa_chat numeric(10) NULL, -- ID hóa chất (duc_thuocvattu.thuocvattuid)
	dinh_muc varchar(40) NULL, -- Định mức
	so_lo varchar(40) NULL, -- Số lô
	ngay_ap_dung timestamp NULL, -- Ngày áp dụng
	ton int4 NULL, -- Tồn
	don_vi_quan_ly varchar(40) NULL, -- Đơn vị quản lý
	don_vi_cap_phat varchar(40) NULL, -- Đơn vị cấp phát
	ty_le_quy_doi varchar(40) NULL, -- Tỷ lệ quy đổi
	gia_tri_quy_doi varchar(40) NULL, -- Giá trị quy đổi
	khoa bool DEFAULT false NULL, -- Khóa
	su_dung bool DEFAULT true NULL, -- Sử dụng
	nguoi_tao varchar(255) NULL, -- Người tạo
	ngay_tao timestamp NULL, -- Ngày tạo
	nguoi_cap_nhat varchar(255) NULL, -- Người cập nhật
	ngay_cap_nhat timestamp NULL, -- Ngày cập nhật
	nguoi_xoa varchar(255) NULL, -- Người xóa mềm
	ngay_xoa timestamp NULL, -- Ngày xóa mềm
	bi_xoa int2 DEFAULT 0 NOT NULL, -- Bị xóa mềm
	ma_kho uuid NULL, -- ID kho (duc_kho.id)
	quy_tac_xuat varchar(40) NULL, -- Quy tắc xuất
	han_dung timestamp NULL, -- Hạn dùng
	thoi_diem_tieu_hao varchar(100) NULL, -- Thời điểm tiêu hao
	mo_ta text NULL, -- Mô tả
	khoa_id uuid NULL, -- ID khoa
	ten_khoa varchar(100) NULL, -- Tên khoa
	ma_khoa varchar(25) NULL, -- Mã khoa
	CONSTRAINT kb_dinh_muc_hoa_chat_pkey PRIMARY KEY (id)
);

CREATE TABLE kb_giay_nghi_huong_bhxh (
	id uuid DEFAULT gen_random_uuid() NOT NULL,
	tiep_nhan_id uuid NOT NULL,
	kham_benh_id uuid NULL,
	ma_cskcb varchar(50) NOT NULL,
	so_chung_tu varchar(100) NULL,
	ma varchar(100) NULL,
	so_seri varchar(100) NULL,
	so_kcb varchar(100) NULL,
	nguoi_cap varchar(255) NULL,
	so_ngay_nghi varchar(50) NULL,
	nghi_tu_ngay timestamp NULL,
	nghi_den_ngay timestamp NULL,
	ho_ten_me varchar(255) NULL,
	ho_ten_cha varchar(255) NULL,
	nguoi_than varchar(255) NULL,
	quan_he varchar(100) NULL,
	don_vi_lam_viec varchar(500) NULL,
	so_the_bhyt varchar(50) NULL,
	ma_bhxh varchar(50) NULL,
	ma_the_bhxh varchar(50) NULL,
	ma_the_tam varchar(50) NULL,
	dinh_chi_thai bool DEFAULT false NULL,
	thoi_gian_dinh_chi varchar(100) NULL,
	tuoi_thai varchar(50) NULL,
	ma_dinh_chi_thai varchar(50) NULL,
	ly_do_dinh_chi_thai varchar(500) NULL,
	phuong_phap_dieu_tri varchar(1000) NULL,
	chan_doan_ra_vien varchar(1000) NULL,
	ghi_chu text NULL,
	ma_thu_truong_dv varchar(60) NULL,
	ma_bac_si varchar(50) NULL,
	ngay_chung_tu timestamp NULL,
	ngay_tao timestamp DEFAULT CURRENT_TIMESTAMP NULL,
	nguoi_tao varchar(50) NULL,
	ngay_cap_nhat timestamp NULL,
	nguoi_cap_nhat varchar(50) NULL,
	bi_xoa int2 DEFAULT 0 NULL,
	ngay_xoa timestamp NULL,
	nguoi_xoa varchar(50) NULL,
	hososohoa_id uuid NULL,
	hososohoa_id_bhxh uuid NULL, -- ID hồ sơ số hóa - Giấy nghỉ hưởng BHXH
	hososohoa_id_duong_thai uuid NULL, -- ID hồ sơ số hóa - Giấy nghỉ dưỡng thai
	is_nghi_duong_thai bool DEFAULT false NULL, -- Phân biệt loại giấy: true = nghỉ dưỡng thai, false/null = nghỉ hưởng BHXH
	chan_doan_chinh varchar(100) NULL, -- Chẩn đoán chính
	ngay_ky_kinh_cuoi timestamp NULL,
	ngay_lap timestamp NULL,
	giayto_goc_id uuid NULL,
	lydo_caplai varchar(500) NULL,
	nguoi_caplai varchar(255) NULL,
	so_lan_caplai int2 NULL,
	thoigian_caplai timestamp NULL,
	benh_an_id uuid NULL, -- ID bệnh án điều trị (FK csyt_benh_an_dieu_tri), null = giấy tạo từ khám bệnh
	CONSTRAINT kb_giay_nghi_huong_bhxh_pkey PRIMARY KEY (id)
);

CREATE TABLE kb_khai_thac_di_ung (
	id uuid DEFAULT gen_random_uuid() NOT NULL,
	tiep_nhan_id uuid NOT NULL, -- ID tiếp nhận
	benh_nhan_id uuid NOT NULL, -- ID bệnh nhân
	ma_cskcb varchar(50) NOT NULL,
	ngay_tao timestamp DEFAULT CURRENT_TIMESTAMP NULL,
	nguoi_tao varchar(50) NULL,
	ngay_cap_nhat timestamp NULL,
	nguoi_cap_nhat varchar(50) NULL,
	bi_xoa int2 DEFAULT 0 NULL,
	ngay_xoa timestamp NULL,
	nguoi_xoa varchar(50) NULL,
	loai_di_ung varchar(100) NULL, -- Loại dị ứng (thuốc, hóa chất, thực phẩm, khác...)
	ma varchar(100) NULL, -- Mã dị ứng
	ten varchar(255) NULL, -- Tên chất gây dị ứng
	co_di_ung bool NULL, -- Có dị ứng hay không
	so_lan int4 NULL, -- Số lần dị ứng
	bieu_hien_lan_sang varchar(500) NULL, -- Biểu hiện lâm sàng
	ngay_phat_hien date NULL, -- Ngày phát hiện dị ứng
	ghi_chu varchar(500) NULL, -- Ghi chú
	ngay_khai_thac timestamp(6) DEFAULT CURRENT_TIMESTAMP NULL, -- Ngày khai thác
	CONSTRAINT kb_khai_thac_di_ung_pkey PRIMARY KEY (id)
);

CREATE TABLE kb_kham_benh (
	id uuid DEFAULT gen_random_uuid() NOT NULL,
	tiep_nhan_id uuid NOT NULL, -- FK; ¶Ref: tiep_nhan.id; ¶Desc: ID tiếp nhận (1-1)
	benh_nhan_id uuid NOT NULL,
	dau_hieu_sinh_ton_id uuid NULL, -- ID dấu hiệu sinh tồn
	yl_dichvu_id uuid NULL, -- Y lệnh dịch vụ ID
	dichvu_id uuid NULL, -- Dịch vụ ID
	ma_cskcb varchar(50) NOT NULL,
	ma_phong_ban varchar(50) NULL,
	ma_bac_si_kham varchar(50) NULL,
	thoi_gian_bat_dau timestamp NULL, -- Thời gian bắt đầu khám
	ly_do_kham text NULL,
	trieu_chung_lam_sang text NULL,
	qua_trinh_benh_ly text NULL, -- Quá trình bệnh lý
	kham_toan_than text NULL,
	cac_bo_phan text NULL,
	tien_su_ban_than text NULL, -- Tiền sử bản thân
	tien_su_gia_dinh text NULL, -- Tiền sử gia đình
	tom_tat_cls_id uuid NULL, -- Tóm tắt CLS ID
	tom_tat_cls text NULL, -- Tóm tắt CLS text
	chan_doan_so_bo text NULL,
	cham_soc text NULL, -- Chăm sóc
	kham_ket_hop_id uuid NULL, -- Khám kết hợp ID
	kham_chinh_id uuid NULL, -- ID khám chính
	nguoi_khoa varchar(100) NULL, -- Người khóa hồ sơ
	thoi_gian_ket_thuc timestamp NULL, -- Thời gian kết thúc khám
	hen_tai_kham_id uuid NULL, -- Hẹn tái khám ID
	ma_bac_si_ket_luan varchar(50) NULL, -- Mã bác sĩ kết luận
	ma_tinh_trang varchar(50) NULL, -- Mã tình trạng
	ket_luan text NULL, -- Kết luận
	chan_doan_benh_kem_theo text NULL, -- Chẩn đoán bệnh kèm theo
	ngay_tao timestamp DEFAULT CURRENT_TIMESTAMP NULL,
	nguoi_tao varchar(50) NULL,
	ngay_cap_nhat timestamp NULL,
	nguoi_cap_nhat varchar(50) NULL,
	bi_xoa int2 DEFAULT 0 NULL,
	ngay_xoa timestamp NULL,
	nguoi_xoa varchar(50) NULL,
	icd_benh_chinh_code varchar(50) NULL, -- Mã ICD bệnh chính
	icd_benh_chinh_name varchar(500) NULL, -- Tên ICD bệnh chính
	icd_benh_kem_theo_code varchar(500) NULL, -- Mã ICD bệnh kèm theo (nối bằng ;)
	icd_benh_kem_theo_name text NULL, -- Tên ICD bệnh kèm theo (nối bằng ;)
	chan_doan_yhct_code varchar(50) NULL, -- Mã chẩn đoán YHCT
	chan_doan_yhct_name varchar(500) NULL, -- Tên chẩn đoán YHCT
	phong_ban_id uuid NULL, -- ID phòng ban
	bac_si_kham_id uuid NULL, -- ID bác sĩ khám
	nguoi_khoa_id uuid NULL, -- ID người khóa hồ sơ
	bac_si_ket_luan_id uuid NULL, -- ID bác sĩ kết luận
	ma_dieu_duong varchar(50) NULL, -- Mã điều dưỡng
	dieu_duong_id uuid NULL, -- ID điều dưỡng
	egfr numeric(6, 2) NULL, -- Độ lọc cầu thận (mL/min/1.73m2)
	crcl numeric(6, 2) NULL, -- Độ thanh thải Creatinine (mL/min)
	ldl_cho numeric(5, 2) NULL, -- Chỉ số LDL Cholesterol
	ma_khoa_dieu_tri varchar(50) NULL, -- Mã khoa điều trị
	ma_chuyen_khoa varchar(50) NULL, -- Mã chuyên khoa
	noi_chuyen_den_id uuid NULL, -- ID nơi chuyển đến
	thoi_gian_nhap_vien timestamp NULL, -- Thời gian nhập viện
	so_tien_tam_ung numeric(15) NULL, -- Số tiền tạm ứng
	huong_xu_tri_id uuid NULL, -- UUID tham chiếu đến dm_xu_tri.id
	tai_nan_thuong_tich varchar(100) NULL,
	vi_tri_tai_nan varchar(50) NULL,
	hinh_thuc_ra_vien varchar(50) NULL,
	ghi_nhan_huy int2 DEFAULT 0 NOT NULL,
	is_khoa bool DEFAULT false NOT NULL,
	benh_an_id uuid NULL, -- Bệnh án ID
	luu_tru_id uuid NULL, -- Lưu trú ID
	dot_dieu_tri_id uuid NULL, -- Đợt điều trị ngoại trú ID
	dien_bien text NULL,
	loi_dan text NULL,
	che_do_cham_soc_id uuid NULL,
	trang_thai_thuc_hien varchar(50) NULL,
	phac_do_dieu_tri_id uuid NULL,
	chan_doan_so_bo_code varchar(50) NULL,
	chan_doan_so_bo_id uuid NULL,
	chan_doan_so_bo_name varchar(500) NULL,
	hososohoa_id uuid NULL,
	che_do_dinh_duong_id uuid NULL, -- FK chế độ dinh dưỡng — dm_che_do_dinh_duong
	che_do_an_id uuid NULL, -- FK chế độ ăn — dm_che_do_an
	nhom_mau varchar(50) NULL, -- Nhóm máu
	tien_luong text NULL, -- Tiên lượng
	cong_viec text NULL, -- Công việc
	di_ung_thuoc text NULL, -- Dị ứng thuốc
	so_phieu_to_dieu_tri varchar(50) NULL,
	ly_do_nhap_vien text NULL,
	bo_phan_bi_thuong text NULL,
	su_dung_ruou_bia varchar(10) NULL,
	chan_thuong_so_nao varchar(10) NULL,
	is_dieu_tri_ngt_man_tinh bool DEFAULT false NULL,
	che_do_dinh_duong text NULL, -- Chế độ dinh dưỡng (nhập text)
	CONSTRAINT kb_kham_benh_pkey PRIMARY KEY (id)
);

CREATE TABLE kb_kham_benh_chuyen_vien (
	id uuid DEFAULT gen_random_uuid() NOT NULL,
	ma_cskcb varchar(50) NOT NULL,
	so_giay_chuyen varchar(50) NULL,
	tiep_nhan_id uuid NULL,
	kham_benh_id uuid NULL, -- ID khám bệnh (FK)
	bac_si_ma varchar(50) NULL,
	benh_vien_chuyen_den_id uuid NULL, -- ID bệnh viện chuyển đến
	benh_vien_chuyen_den_ma varchar(50) NULL,
	ly_do_chuyen_id uuid NULL, -- ID lý do chuyển viện
	ly_do_chuyen_ma varchar(50) NULL,
	chan_doan text NULL, -- Chẩn đoán khi chuyển
	ngay_lap timestamp NULL,
	tom_tat_cls text NULL, -- Tóm tắt cận lâm sàng
	dau_hieu_lam_sang text NULL,
	tinh_trang text NULL,
	thuoc_da_dung text NULL, -- Thuốc đã dùng
	huong_dieu_tri text NULL, -- Hướng điều trị
	phuong_tien_id uuid NULL, -- ID phương tiện vận chuyển
	ly_do_huy text NULL,
	trang_thai bool DEFAULT true NULL, -- Trạng thái (true=active, false=hủy)
	thu_truong_don_vi_id uuid NULL,
	nguoi_ho_tong text NULL,
	cac_xet_nghiem text NULL,
	dieu_kien_chuyen_tuyen varchar(50) NULL,
	pp_phau_thuat text NULL, -- Phương pháp phẫu thuật
	thoi_gian_bat_dau_pt timestamp NULL,
	thoi_gian_ket_thuc_pt timestamp NULL,
	thoi_gian_chuyen_cskcb timestamp NULL,
	chuyen_kcb_1nam varchar(50) NULL, -- Chuyển KCB trong 1 năm
	chuyen_kcb_1nam_text text NULL,
	ngay_tao timestamp DEFAULT CURRENT_TIMESTAMP NULL,
	nguoi_tao varchar(50) NULL,
	ngay_cap_nhat timestamp NULL,
	nguoi_cap_nhat varchar(50) NULL,
	bi_xoa int2 DEFAULT 0 NULL,
	ngay_xoa timestamp NULL,
	nguoi_xoa varchar(50) NULL,
	ma_noi_lap varchar(50) NULL,
	ten_noi_lap varchar(255) NULL,
	ten_bac_si varchar(255) NULL,
	hososohoa_id uuid NULL,
	benh_an_id uuid NULL,
	CONSTRAINT kb_kham_benh_chuyen_vien_pkey PRIMARY KEY (id)
);

CREATE TABLE kb_kham_benh_hen_tai_kham (
	id uuid DEFAULT gen_random_uuid() NOT NULL,
	ma_cskcb varchar(50) NOT NULL,
	tiep_nhan_id uuid NULL,
	kham_benh_id uuid NULL, -- ID khám bệnh (FK)
	ngay_hen_kham date NULL, -- Ngày hẹn khám
	so_ngay_hen_kham int4 NULL, -- Số ngày hẹn khám (tính từ ngày khám)
	da_tiep_nhan bool DEFAULT false NULL, -- Đã tiếp nhận (true=bệnh nhân đã quay lại)
	thu_truong_don_vi_id int4 NULL, -- ID thủ trưởng đơn vị
	ghi_chu text NULL,
	ngay_tao timestamp DEFAULT CURRENT_TIMESTAMP NULL,
	nguoi_tao varchar(50) NULL,
	ngay_cap_nhat timestamp NULL,
	nguoi_cap_nhat varchar(50) NULL,
	bi_xoa int2 DEFAULT 0 NULL,
	ngay_xoa timestamp NULL,
	nguoi_xoa varchar(50) NULL,
	hososohoa_id uuid NULL,
	ma_chan_doan varchar(50) NULL,
	chan_doan varchar(255) NULL,
	ma_benh_kem_theo varchar(500) NULL,
	benh_kem_theo text NULL,
	benh_an_id uuid NULL,
	thoi_gian_hen_kham time NULL, -- Thời gian hẹn khám (HH:MM)
	trang_thai varchar(50) NULL, -- Trạng thái
	hinh_thuc_dat varchar(50) NULL, -- Hình thức đặt (BENH_NHAN_DAT, TONG_DAI_DAT, HEN_TAI_KHAM)
	hinh_thuc_kham varchar(50) NULL, -- Hình thức khám (TAI_PHONG_KHAM, TRUC_TUYEN)
	ly_do_kham varchar NULL, -- Lý do khám
	bac_si_kham_id uuid NULL, -- ID bác sĩ khám (FK dm_nhan_vien.id)
	benh_nhan_hen_kham_id uuid NULL, -- ID benh_nhan_hen_kham (FK benh_nhan_hen_kham.id)
	phong_id uuid NULL, -- ID phòng khám(FK dm_phong.id)
	ly_do_huy varchar NULL, -- Lý do hủy
	bac_si_hen_kham_id uuid NULL, -- ID bác sĩ hẹn khám (FK dm_nhan_vien.id)
	dich_vu_id uuid NULL, -- ID dịch vụ(FK dm_dich_vu_kt.id)
	nguoi_xac_nhan varchar(50) NULL, -- Username người xác nhận
	ngay_xac_nhan timestamp NULL, -- Ngày xác nhận
	nguoi_huy varchar(50) NULL, -- Username người hủy
	ngay_huy timestamp NULL, -- Ngày hủy
	ma_hen_kham varchar(50) NULL, -- Mã hẹn khám
	khoa_id uuid NULL, -- ID khoa
	chuyen_khoa_id uuid NULL, -- ID chuyên khoa(FK dm_chuyen_khoa.id)
	stt_kham int4 NULL, -- Số thứ tự khám
	CONSTRAINT kb_kham_benh_hen_tai_kham_pkey PRIMARY KEY (id)
);

CREATE TABLE kb_kham_benh_icd (
	id uuid DEFAULT gen_random_uuid() NOT NULL,
	kham_benh_id uuid NOT NULL, -- ID khám bệnh (FK)
	ma_cskcb varchar(50) NOT NULL,
	icd10_id uuid NULL, -- ID ICD-10 (FK -> dm_icd10)
	icd10_code varchar(20) NULL, -- Mã ICD-10
	icd10_name varchar(500) NULL, -- Tên ICD-10
	yhct_id uuid NULL, -- ID chẩn đoán YHCT (FK -> dm_yhct)
	yhct_code varchar(50) NULL, -- Mã chẩn đoán YHCT
	yhct_name varchar(500) NULL, -- Tên chẩn đoán YHCT
	la_benh_chinh bool DEFAULT false NOT NULL, -- Là bệnh chính (true) hoặc bệnh kèm theo (false)
	stt int4 NULL, -- Số thứ tự chẩn đoán
	ngay_tao timestamp DEFAULT CURRENT_TIMESTAMP NULL,
	nguoi_tao varchar(50) NULL,
	ngay_cap_nhat timestamp NULL,
	nguoi_cap_nhat varchar(50) NULL,
	bi_xoa int2 DEFAULT 0 NULL,
	ngay_xoa timestamp NULL,
	nguoi_xoa varchar(50) NULL,
	yhct_icd10_id uuid NULL, -- ID ICD-10 liên kết với chẩn đoán YHCT (FK -> dm_icd10)
	CONSTRAINT kb_kham_benh_icd_pkey PRIMARY KEY (id)
);

CREATE TABLE kb_kham_benh_vao_vien (
	id uuid DEFAULT gen_random_uuid() NOT NULL,
	tiep_nhan_id uuid NOT NULL, -- ID tiếp nhận
	benh_nhan_id uuid NOT NULL, -- ID bệnh nhân
	ma_cskcb varchar(50) NOT NULL, -- Mã cơ sở khám chữa bệnh
	khoa_nhap_vien_id int4 NULL, -- ID khoa nhập viện
	thoi_gian_kham timestamp NULL, -- Thời gian khám
	ly_do_nhap_vien text NULL, -- Lý do nhập viện
	chan_doan_gioi_thieu text NULL, -- Chẩn đoán giới thiệu
	qua_trinh_benh_ly text NULL, -- Quá trình bệnh lý
	tien_su_benh_gia_dinh text NULL, -- Tiền sử bệnh gia đình
	tien_su_benh_ban_than text NULL, -- Tiền sử bệnh bản thân
	toan_than text NULL, -- Toàn thân
	cac_bo_phan text NULL, -- Các bộ phận
	tom_tat_cls text NULL, -- Tóm tắt cận lâm sàng
	icd_benh_chinh_id uuid NULL, -- ID bệnh chính ICD
	chan_doan_benh_chinh_id int4 NULL, -- ID chẩn đoán bệnh chính
	icd_benh_kem_theo_id int4 NULL, -- ID bệnh kèm theo ICD
	chan_doan_benh_kem_theo text NULL, -- Chẩn đoán bệnh kèm theo
	chan_doan_yhct_id int4 NULL, -- ID chẩn đoán YHCT
	chan_doan_yhct text NULL, -- Chẩn đoán YHCT
	da_xu_ly text NULL, -- Đã xử lý
	mach numeric(10, 2) NULL, -- Mạch (lần/phút)
	nhiet_do numeric(5, 2) NULL, -- Nhiệt độ (°C)
	huyet_ap_h int4 NULL, -- Huyết áp tâm thu (mmHg)
	huyet_ap_l int4 NULL, -- Huyết áp tâm trương (mmHg)
	can_nang numeric(10, 2) NULL, -- Cân nặng (kg)
	bmi int4 NULL, -- Chỉ số BMI
	spo2 varchar(50) NULL, -- SpO2
	ngay_tao timestamp DEFAULT CURRENT_TIMESTAMP NULL,
	nguoi_tao varchar(50) NULL,
	ngay_cap_nhat timestamp NULL,
	nguoi_cap_nhat varchar(50) NULL,
	bi_xoa int2 DEFAULT 0 NULL,
	ngay_xoa timestamp NULL,
	nguoi_xoa varchar(50) NULL,
	ma_khoa_nhap_vien varchar(50) NULL,
	is_tien_su_di_ung bool DEFAULT false NULL,
	is_tien_su_ban_than bool DEFAULT false NULL,
	is_tien_su_gia_dinh bool DEFAULT false NULL,
	is_chan_doan_noi_khac bool DEFAULT false NULL,
	is_kham_toan_than_binh_thuong bool DEFAULT false NULL,
	chieu_cao numeric(10, 2) NULL,
	nhip_tho int4 NULL,
	y_kien_chuyen_khoa text NULL,
	ghi_chu text NULL,
	is_vao_gio_thu bool DEFAULT false NULL,
	vao_gio_thu varchar(50) NULL,
	is_vao_ngay_thu bool DEFAULT false NULL,
	vao_ngay_thu varchar(50) NULL,
	is_khong_ro bool DEFAULT false NULL,
	tien_su_di_ung text NULL,
	icd_benh_chinh_code varchar(50) NULL,
	icd_benh_chinh_name varchar(500) NULL,
	icd_benh_kem_theo_code varchar(50) NULL,
	icd_benh_kem_theo_name text NULL,
	chan_doan_yhct_code varchar(50) NULL,
	chan_doan_yhct_name varchar(500) NULL,
	kham_benh_id uuid NULL,
	hososohoa_id uuid NULL,
	benh_an_id uuid NULL,
	CONSTRAINT kb_kham_benh_vao_vien_pkey PRIMARY KEY (id)
);

CREATE TABLE kb_kham_thai (
	id uuid DEFAULT gen_random_uuid() NOT NULL, -- ID bản ghi (UUID v7)
	nguoi_tao varchar(255) NULL,
	ngay_tao timestamp NULL,
	nguoi_cap_nhat varchar(255) NULL,
	ngay_cap_nhat timestamp NULL,
	nguoi_xoa varchar(255) NULL,
	ngay_xoa timestamp NULL,
	bi_xoa int2 DEFAULT 0 NOT NULL, -- Trạng thái xóa: 0-Chưa xóa, 1-Đã xóa
	ma_cskcb varchar(20) NULL, -- Mã cơ sở khám chữa bệnh
	tiep_nhan_id uuid NOT NULL, -- ID tiếp nhận
	benh_nhan_id uuid NOT NULL, -- ID bệnh nhân
	bac_si_id uuid NULL, -- ID bác sĩ khám
	thoi_gian_kham timestamp NULL, -- Thời gian thực hiện khám
	phong_kham_id uuid NULL, -- ID phòng khám
	ngay_kham timestamp NULL, -- Ngày khám lần trước
	chan_doan text NULL, -- Chẩn đoán lần trước
	xu_tri text NULL, -- Xử trí lần trước
	ly_do_vao_vien text NULL, -- Lý do vào viện
	lan_co_thai_thu int2 NULL, -- Lần có thai thứ mấy
	so_lan_kham_thai int2 NULL, -- Số lần đã khám thai trong thai kỳ này
	ngay_dau_ky_kinh_cuoi date NULL, -- Ngày đầu của kỳ kinh cuối cùng
	tuoi_thai varchar(50) NULL, -- Tuổi thai hiện tại
	ngay_du_kien_sinh date NULL, -- Ngày dự kiến sinh
	dien_bien_lam_sang text NULL, -- Diễn biến lâm sàng trong thai kỳ
	so_mui_tiem_uon_van int2 NULL, -- Số mũi tiêm uốn ván đã tiêm
	toan_than varchar(20) NULL, -- Tình trạng toàn thân: BINH_THUONG, BAT_THUONG
	toan_than_note text NULL, -- Ghi chú chi tiết tình trạng toàn thân
	di_ung varchar(10) NULL, -- Tiền sử dị ứng: KHONG, CO
	di_ung_note text NULL, -- Ghi chú chi tiết dị ứng
	tien_su_benh varchar(10) NULL, -- Tiền sử bệnh tật nói chung: KHONG, CO
	benh_huyet_ap varchar(10) NULL, -- Tiền sử bệnh huyết áp: KHONG, CO
	benh_tim varchar(10) NULL, -- Tiền sử bệnh tim: KHONG, CO
	benh_ho_hap varchar(10) NULL, -- Tiền sử bệnh hô hấp: KHONG, CO
	benh_tuyen_giap varchar(10) NULL, -- Tiền sử bệnh tuyến giáp: KHONG, CO
	benh_than varchar(10) NULL, -- Tiền sử bệnh thận: KHONG, CO
	dai_thao_duong_bt varchar(10) NULL, -- Tiền sử đái tháo đường bản thân: KHONG, CO
	benh_khac text NULL, -- Các bệnh khác đã mắc
	thuoc_dang_dung varchar(10) NULL, -- Đang dùng thuốc gì: KHONG, CO
	thuoc_dang_dung_note text NULL, -- Ghi chú các loại thuốc đang dùng
	tien_su_phau_thuat varchar(10) NULL, -- Tiền sử phẫu thuật: KHONG, CO
	tien_su_phau_thuat_note text NULL, -- Ghi chú chi tiết phẫu thuật đã qua
	para int2 NULL, -- Chỉ số Para (Sinh-Sớm-Sảy-Sống)
	tien_su_san_khoa jsonb NULL, -- Chi tiết các lần sinh trước (JSONB)
	chu_ky_kinh varchar(20) NULL, -- Tính chất chu kỳ kinh: DEU, KHONG DEU
	chu_ky_kinh_so_ngay numeric NULL, -- Số ngày trung bình của chu kỳ kinh
	phau_thuat_phu_khoa varchar(10) NULL, -- Tiền sử phẫu thuật phụ khoa: KHONG, CO
	phau_thuat_phu_khoa_note text NULL, -- Ghi chú phẫu thuật phụ khoa
	khoi_u_buong_trung varchar(10) NULL, -- Có khối u buồng trứng: KHONG, CO
	khoi_u_tu_cung varchar(10) NULL, -- Có khối u tử cung: KHONG, CO
	sa_tang_chau varchar(10) NULL, -- Sa tầng chậu: KHONG, CO
	di_dang_sinh_duc varchar(10) NULL, -- Dị dạng sinh dục: KHONG, CO
	tang_sinh_mon varchar(10) NULL, -- Tình trạng tầng sinh môn: KHONG, CO
	benh_phu_khoa_da_mac_va_dieu_tri text NULL, -- Các bệnh phụ khoa đã mắc và quá trình điều trị
	tien_su_gia_dinh varchar(10) NULL, -- Tiền sử gia đình nói chung: KHONG, CO
	da_thai varchar(10) NULL, -- Gia đình có tiền sử đa thai: KHONG, CO
	di_dang varchar(10) NULL, -- Gia đình có tiền sử dị dạng: KHONG, CO
	benh_di_truyen varchar(10) NULL, -- Gia đình có bệnh di truyền: KHONG, CO
	dai_thao_duong_gd varchar(10) NULL, -- Gia đình có người đái tháo đường: KHONG, CO
	tang_huyet_ap varchar(10) NULL, -- Gia đình có người tăng huyết áp: KHONG, CO
	tien_su_gia_dinh_khac text NULL, -- Các tiền sử gia đình khác
	tinh_than varchar(20) NULL, -- Tình trạng tinh thần: TINH_TAO, HON_ME, KHAC
	protein_nieu varchar(10) NULL, -- Protein niệu (test nhanh khi khám): KHONG, CO
	protein_nieu_note text NULL, -- Ghi chú protein niệu
	khung_chau varchar(20) NULL, -- Tình trạng khung chậu: BINH_THUONG, BAT_THUONG
	khung_chau_note text NULL, -- Ghi chú khung chậu
	chieu_cao_tu_cung int2 NULL, -- Chiều cao tử cung (cm)
	vong_bung int2 NULL, -- Vòng bụng (cm)
	ngoi_thai varchar(20) NULL, -- Ngôi thai: BINH_THUONG, BAT_THUONG
	ngoi_thai_note text NULL, -- Ghi chú ngôi thai
	con_co_tu_cung varchar(10) NULL, -- Có cơn co tử cung: KHONG, CO
	tim_thai varchar(10) NULL, -- Có tim thai: KHONG, CO
	co_tu_cung varchar(10) NULL, -- Tình trạng cổ tử cung: DONG, XOA
	dau_oi varchar(20) NULL, -- Tình trạng đầu ối: PHONG, DET, QUA_LE, RI, VO
	nuoc_oi varchar(20) NULL, -- Màu sắc/tính chất nước ối: TRONG, XANH_BAN, LAN_MAU
	kham_benh_khac text NULL, -- Các khám xét khác
	tan_so int2 NULL, -- Tần số cơn co tử cung
	nhip_tim_thai int2 NULL, -- Nhịp tim thai (lần/phút)
	mo int2 NULL, -- Độ mở cổ tử cung (cm)
	xet_nghiem_cls _text NULL, -- Danh sách tên các loại XN CLS đã thực hiện (Array)
	thieu_mau varchar(10) NULL, -- Tình trạng thiếu máu (kết quả XN): KHONG, CO
	dong_mau varchar(20) NULL, -- Tình trạng đông máu: BINH_THUONG, BAT_THUONG
	duong_huyet varchar(20) NULL, -- Tình trạng đường huyết: BINH_THUONG, CAO
	hiv varchar(20) NULL, -- Kết quả HIV: AM_TINH, DUONG_TINH
	viem_gan_b varchar(20) NULL, -- Kết quả Viêm gan B: AM_TINH, DUONG_TINH
	giang_mai varchar(20) NULL, -- Kết quả Giang mai: AM_TINH, DUONG_TINH
	protein_nieu_cls varchar(20) NULL, -- Protein niệu (kết quả CLS): AM_TINH, DUONG_TINH
	tinh_trang varchar(20) NULL, -- Tình trạng thai trên siêu âm: BINH_THUONG, BAT_THUONG
	khac_cls text NULL, -- Ghi chú các kết quả CLS khác
	chan_doan_icd text NULL, -- Chẩn đoán xác định (mã ICD)
	ke_hoach_dieu_tri text NULL, -- Kế hoạch điều trị chi tiết
	huong_dieu_tri_tiep_theo text NULL, -- Hướng điều trị/theo dõi tiếp theo
	tu_van_suc_khoe text NULL, -- Nội dung đã tư vấn sức khỏe cho sản phụ
	tien_luong text NULL, -- Tiên lượng cuộc đẻ/thai kỳ
	hinh_thuc_sinh varchar(30) NULL, -- Dự kiến hình thức sinh: SINH_THUONG, SINH_CO_NGUY_CO, MO_LAY_THAI
	hen_tai_kham text NULL, -- Ngày/Nội dung hẹn tái khám
	luu_y text NULL, -- Các lưu ý đặc biệt khác
	nguoi_kham varchar(30) NULL, -- Vai trò người khám: BAC_SI_SAN_PHU_KHOA, HO_SINH, Y_SI_SAN_NHI, KHAC
	nguoi_kham_khac_note text NULL, -- Ghi chú tên/thông tin nếu chọn người khám Khác
	phu varchar(10) NULL, -- Phù (KHONG, CO)
	seo_mo_cu varchar(20) NULL, -- Sẹo mổ cũ (KHONG, CO, DAU_VET_MO)
	luc timestamp NULL, -- Thời gian lúc khám
	bac_si_kham_lan_truoc_id uuid NULL,
	hososohoa_id uuid NULL,
	tu_van_suc_khoe_note text NULL,
	CONSTRAINT kb_kham_thai_pkey PRIMARY KEY (id)
);

CREATE TABLE kb_kham_thai_copy1 (
	id uuid DEFAULT gen_random_uuid() NOT NULL, -- ID bản ghi (UUID v7)
	nguoi_tao varchar(255) NULL,
	ngay_tao timestamp(6) NULL,
	nguoi_cap_nhat varchar(255) NULL,
	ngay_cap_nhat timestamp(6) NULL,
	nguoi_xoa varchar(255) NULL,
	ngay_xoa timestamp(6) NULL,
	bi_xoa int2 DEFAULT 0 NOT NULL, -- Trạng thái xóa: 0-Chưa xóa, 1-Đã xóa
	ma_cskcb varchar(20) NULL, -- Mã cơ sở khám chữa bệnh
	tiep_nhan_id uuid NOT NULL, -- ID tiếp nhận
	benh_nhan_id uuid NOT NULL, -- ID bệnh nhân
	bac_si_id uuid NULL, -- ID bác sĩ khám
	thoi_gian_kham timestamp(6) NULL, -- Thời gian thực hiện khám
	phong_kham_id uuid NULL, -- ID phòng khám
	ngay_kham timestamp(6) NULL, -- Ngày khám lần trước
	chan_doan text NULL, -- Chẩn đoán lần trước
	xu_tri text NULL, -- Xử trí lần trước
	ly_do_vao_vien text NULL, -- Lý do vào viện
	lan_co_thai_thu int2 NULL, -- Lần có thai thứ mấy
	so_lan_kham_thai int2 NULL, -- Số lần đã khám thai trong thai kỳ này
	ngay_dau_ky_kinh_cuoi date NULL, -- Ngày đầu của kỳ kinh cuối cùng
	tuoi_thai varchar(50) NULL, -- Tuổi thai hiện tại
	ngay_du_kien_sinh date NULL, -- Ngày dự kiến sinh
	dien_bien_lam_sang text NULL, -- Diễn biến lâm sàng trong thai kỳ
	so_mui_tiem_uon_van int2 NULL, -- Số mũi tiêm uốn ván đã tiêm
	toan_than varchar(20) NULL, -- Tình trạng toàn thân: BINH_THUONG, BAT_THUONG
	toan_than_note text NULL, -- Ghi chú chi tiết tình trạng toàn thân
	di_ung varchar(10) NULL, -- Tiền sử dị ứng: KHONG, CO
	di_ung_note text NULL, -- Ghi chú chi tiết dị ứng
	tien_su_benh varchar(10) NULL, -- Tiền sử bệnh tật nói chung: KHONG, CO
	benh_huyet_ap varchar(10) NULL, -- Tiền sử bệnh huyết áp: KHONG, CO
	benh_tim varchar(10) NULL, -- Tiền sử bệnh tim: KHONG, CO
	benh_ho_hap varchar(10) NULL, -- Tiền sử bệnh hô hấp: KHONG, CO
	benh_tuyen_giap varchar(10) NULL, -- Tiền sử bệnh tuyến giáp: KHONG, CO
	benh_than varchar(10) NULL, -- Tiền sử bệnh thận: KHONG, CO
	dai_thao_duong_bt varchar(10) NULL, -- Tiền sử đái tháo đường bản thân: KHONG, CO
	benh_khac text NULL, -- Các bệnh khác đã mắc
	thuoc_dang_dung varchar(10) NULL, -- Đang dùng thuốc gì: KHONG, CO
	thuoc_dang_dung_note text NULL, -- Ghi chú các loại thuốc đang dùng
	tien_su_phau_thuat varchar(10) NULL, -- Tiền sử phẫu thuật: KHONG, CO
	tien_su_phau_thuat_note text NULL, -- Ghi chú chi tiết phẫu thuật đã qua
	para int2 NULL, -- Chỉ số Para (Sinh-Sớm-Sảy-Sống)
	tien_su_san_khoa jsonb NULL, -- Chi tiết các lần sinh trước (JSONB)
	chu_ky_kinh varchar(20) NULL, -- Tính chất chu kỳ kinh: DEU, KHONG DEU
	chu_ky_kinh_so_ngay numeric NULL, -- Số ngày trung bình của chu kỳ kinh
	phau_thuat_phu_khoa varchar(10) NULL, -- Tiền sử phẫu thuật phụ khoa: KHONG, CO
	phau_thuat_phu_khoa_note text NULL, -- Ghi chú phẫu thuật phụ khoa
	khoi_u_buong_trung varchar(10) NULL, -- Có khối u buồng trứng: KHONG, CO
	khoi_u_tu_cung varchar(10) NULL, -- Có khối u tử cung: KHONG, CO
	sa_tang_chau varchar(10) NULL, -- Sa tầng chậu: KHONG, CO
	di_dang_sinh_duc varchar(10) NULL, -- Dị dạng sinh dục: KHONG, CO
	tang_sinh_mon varchar(10) NULL, -- Tình trạng tầng sinh môn: KHONG, CO
	benh_phu_khoa_da_mac_va_dieu_tri text NULL, -- Các bệnh phụ khoa đã mắc và quá trình điều trị
	tien_su_gia_dinh varchar(10) NULL, -- Tiền sử gia đình nói chung: KHONG, CO
	da_thai varchar(10) NULL, -- Gia đình có tiền sử đa thai: KHONG, CO
	di_dang varchar(10) NULL, -- Gia đình có tiền sử dị dạng: KHONG, CO
	benh_di_truyen varchar(10) NULL, -- Gia đình có bệnh di truyền: KHONG, CO
	dai_thao_duong_gd varchar(10) NULL, -- Gia đình có người đái tháo đường: KHONG, CO
	tang_huyet_ap varchar(10) NULL, -- Gia đình có người tăng huyết áp: KHONG, CO
	tien_su_gia_dinh_khac text NULL, -- Các tiền sử gia đình khác
	tinh_than varchar(20) NULL, -- Tình trạng tinh thần: TINH_TAO, HON_ME, KHAC
	protein_nieu varchar(10) NULL, -- Protein niệu (test nhanh khi khám): KHONG, CO
	protein_nieu_note text NULL, -- Ghi chú protein niệu
	khung_chau varchar(20) NULL, -- Tình trạng khung chậu: BINH_THUONG, BAT_THUONG
	khung_chau_note text NULL, -- Ghi chú khung chậu
	chieu_cao_tu_cung int2 NULL, -- Chiều cao tử cung (cm)
	vong_bung int2 NULL, -- Vòng bụng (cm)
	ngoi_thai varchar(20) NULL, -- Ngôi thai: BINH_THUONG, BAT_THUONG
	ngoi_thai_note text NULL, -- Ghi chú ngôi thai
	con_co_tu_cung varchar(10) NULL, -- Có cơn co tử cung: KHONG, CO
	tim_thai varchar(10) NULL, -- Có tim thai: KHONG, CO
	co_tu_cung varchar(10) NULL, -- Tình trạng cổ tử cung: DONG, XOA
	dau_oi varchar(20) NULL, -- Tình trạng đầu ối: PHONG, DET, QUA_LE, RI, VO
	nuoc_oi varchar(20) NULL, -- Màu sắc/tính chất nước ối: TRONG, XANH_BAN, LAN_MAU
	kham_benh_khac text NULL, -- Các khám xét khác
	tan_so int2 NULL, -- Tần số cơn co tử cung
	nhip_tim_thai int2 NULL, -- Nhịp tim thai (lần/phút)
	mo int2 NULL, -- Độ mở cổ tử cung (cm)
	xet_nghiem_cls _text NULL, -- Danh sách tên các loại XN CLS đã thực hiện (Array)
	thieu_mau varchar(10) NULL, -- Tình trạng thiếu máu (kết quả XN): KHONG, CO
	dong_mau varchar(20) NULL, -- Tình trạng đông máu: BINH_THUONG, BAT_THUONG
	duong_huyet varchar(20) NULL, -- Tình trạng đường huyết: BINH_THUONG, CAO
	hiv varchar(20) NULL, -- Kết quả HIV: AM_TINH, DUONG_TINH
	viem_gan_b varchar(20) NULL, -- Kết quả Viêm gan B: AM_TINH, DUONG_TINH
	giang_mai varchar(20) NULL, -- Kết quả Giang mai: AM_TINH, DUONG_TINH
	protein_nieu_cls varchar(20) NULL, -- Protein niệu (kết quả CLS): AM_TINH, DUONG_TINH
	tinh_trang varchar(20) NULL, -- Tình trạng thai trên siêu âm: BINH_THUONG, BAT_THUONG
	khac_cls text NULL, -- Ghi chú các kết quả CLS khác
	chan_doan_icd text NULL, -- Chẩn đoán xác định (mã ICD)
	ke_hoach_dieu_tri text NULL, -- Kế hoạch điều trị chi tiết
	huong_dieu_tri_tiep_theo text NULL, -- Hướng điều trị/theo dõi tiếp theo
	tu_van_suc_khoe text NULL, -- Nội dung đã tư vấn sức khỏe cho sản phụ
	tien_luong text NULL, -- Tiên lượng cuộc đẻ/thai kỳ
	hinh_thuc_sinh varchar(30) NULL, -- Dự kiến hình thức sinh: SINH_THUONG, SINH_CO_NGUY_CO, MO_LAY_THAI
	hen_tai_kham text NULL, -- Ngày/Nội dung hẹn tái khám
	luu_y text NULL, -- Các lưu ý đặc biệt khác
	nguoi_kham varchar(30) NULL, -- Vai trò người khám: BAC_SI_SAN_PHU_KHOA, HO_SINH, Y_SI_SAN_NHI, KHAC
	nguoi_kham_khac_note text NULL, -- Ghi chú tên/thông tin nếu chọn người khám Khác
	phu varchar(10) NULL, -- Phù (KHONG, CO)
	seo_mo_cu varchar(20) NULL, -- Sẹo mổ cũ (KHONG, CO, DAU_VET_MO)
	luc timestamp(6) NULL, -- Thời gian lúc khám
	bac_si_kham_lan_truoc_id uuid NULL,
	CONSTRAINT kb_kham_thai_copy1_pkey PRIMARY KEY (id)
);

CREATE TABLE kb_luu_mau (
	id uuid DEFAULT gen_random_uuid() NOT NULL, -- ID duy nhất (UUID v7)
	loai_mau_luu varchar(50) NOT NULL, -- Loại mẫu lưu (KHAM_THAI, TMH, RHM, YHCT, v.v.)
	ten_mau_luu varchar(255) NOT NULL, -- Tên mẫu lưu
	ma_mau_luu varchar(100) NOT NULL, -- Mã mẫu lưu
	bo_phan_id uuid NULL, -- ID bộ phận/khoa
	ap_dung varchar(50) NOT NULL, -- Phạm vi áp dụng (TOAN_KHOA, TOAN_VIEN, CHI_MINH_TOI)
	noi_dung text NULL, -- Nội dung mẫu (JSON)
	nguoi_tao varchar(100) NULL,
	ngay_tao timestamp NULL,
	nguoi_cap_nhat varchar(100) NULL,
	ngay_cap_nhat timestamp NULL,
	bi_xoa int2 DEFAULT 0 NOT NULL, -- Trạng thái xóa: 0-Chưa xóa, 1-Đã xóa
	nguoi_xoa varchar(100) NULL,
	ngay_xoa timestamp NULL,
	ma_cskcb varchar(20) NOT NULL, -- Mã cơ sở khám chữa bệnh
	dich_vu_id uuid NULL,
	nhom_dich_vu_id uuid NULL,
	phan_loai_doi_tuong varchar(50) NULL, -- Phân loại đối tượng áp dụng:¶- DICH_VU: Áp dụng theo dịch vụ (dich_vu_id)¶- NHOM_DICH_VU: Áp dụng theo nhóm dịch vụ (nhom_dich_vu_id)¶- CHUYEN_KHOA: Áp dụng theo chuyên khoa¶- NGHIEP_VU: Áp dụng theo nghiệp vụ
	ds_chia_se_nhan_vien_id _uuid DEFAULT ARRAY[]::uuid[] NULL,
	su_dung int2 DEFAULT 1 NULL,
	CONSTRAINT kb_luu_mau_pkey PRIMARY KEY (id)
);

CREATE TABLE kb_thuc_hien_dich_vu (
	id uuid NOT NULL,
	tiep_nhan_id uuid NULL,
	benh_nhan_id uuid NULL,
	ma_cskcb varchar(50) NULL,
	phieu_dich_vu_id uuid NULL,
	ma_loai_phieu varchar(50) NULL,
	hang_doi_id uuid NULL,
	khu_thuc_hien_id uuid NULL,
	ma_khu_thuc_hien varchar(50) NULL,
	ten_khu_thuc_hien varchar(255) NULL,
	phong_thuc_hien_id uuid NULL,
	ma_phong_thuc_hien varchar(50) NULL,
	ten_phong_thuc_hien varchar(255) NULL,
	khoa_thuc_hien_id uuid NULL,
	ma_khoa_thuc_hien varchar(50) NULL,
	ten_khoa_thuc_hien varchar(255) NULL,
	trang_thai_thuc_hien varchar(50) NULL,
	idhash_id varchar(255) NULL,
	trang_thai_ky_so int4 NULL,
	ngay_tao timestamp(6) DEFAULT CURRENT_TIMESTAMP NULL,
	nguoi_tao varchar(50) NULL,
	ngay_cap_nhat timestamp(6) NULL,
	nguoi_cap_nhat varchar(50) NULL,
	bi_xoa int2 DEFAULT 0 NULL,
	ngay_xoa timestamp(6) NULL,
	nguoi_xoa varchar(50) NULL
);

CREATE TABLE kb_thuc_hien_dich_vu_chi_tiet (
	id uuid NOT NULL,
	phieu_dich_vu_chi_tiet_id uuid NULL,
	tiep_nhan_id uuid NULL,
	benh_an_id uuid NULL,
	benh_nhan_id uuid NULL,
	ma_cskcb varchar(50) NULL,
	nhom_dich_vu_id uuid NULL,
	dich_vu_id uuid NULL,
	dich_vu_th_id uuid NULL,
	thoi_gian_chup_phim timestamp(6) NULL,
	thoi_gian_lay_mau timestamp(6) NULL,
	thoi_gian_nhan_mau timestamp(6) NULL,
	ngay_gio_thuc_hien timestamp(6) NULL,
	vung_khao_sat varchar NULL,
	loai_film_id_1 uuid NULL,
	so_phim_su_dung_1 int4 NULL,
	loai_film_id_2 uuid NULL,
	so_phim_su_dung_2 int4 NULL,
	loai_film_id_3 uuid NULL,
	so_phim_su_dung_3 int4 NULL,
	bac_si_thuc_hien_id uuid NULL,
	bac_si_ket_luan_id uuid NULL,
	thoi_gian_doc_ket_qua timestamp(6) NULL,
	bac_si_doc_ket_qua_id uuid NULL,
	ky_thuat_vien_01_id uuid NULL,
	ky_thuat_vien_02_id uuid NULL,
	ky_thuat_vien_03_id uuid NULL,
	dieu_duong_id uuid NULL,
	is_gui_ngoai bool NULL,
	dai_the varchar NULL,
	vi_the varchar NULL,
	ban_luan varchar NULL,
	khuyen_nghi varchar NULL,
	so_block varchar NULL,
	so_mau varchar NULL,
	mo_ta varchar NULL,
	ket_qua varchar NULL,
	ket_luan varchar NULL,
	don_vi_tinh varchar NULL,
	chi_so_binh_thuong varchar NULL,
	ma_may varchar NULL,
	trang_thai varchar NULL,
	thoi_gian_khoa timestamp(6) NULL,
	is_khoa_du_lieu bool NULL,
	nguoi_khoa_id uuid NULL,
	anh_ket_qua varchar NULL,
	ngay_tao timestamp(6) DEFAULT CURRENT_TIMESTAMP NULL,
	nguoi_tao varchar(50) NULL,
	ngay_cap_nhat timestamp(6) NULL,
	nguoi_cap_nhat varchar(50) NULL,
	bi_xoa int2 DEFAULT 0 NULL,
	ngay_xoa timestamp(6) NULL,
	nguoi_xoa varchar(50) NULL,
	da_ghi_nhan bool NULL,
	ma_nhom_dich_vu varchar(50) NULL,
	xem_truoc_pacs varchar(500) NULL, -- URL xem trước ảnh từ PACS
	loi_dan varchar(500) NULL, -- lời dặn của bác sĩ
	tiem_can_quang int4 NULL, -- Đánh dấu tiệm cận quang
	sinh_thiet int4 NULL, -- Đánh dấu sinh thiết
	test_hp int4 NULL, -- Đánh dấu testhp
	thu_ky_y_khoa_id uuid NULL, -- Thư ký y khoa
	bac_si_gay_me_id uuid NULL, -- Bác sĩ gây mê id
	trang_thai_day_pacs varchar(50) NULL,
	ky_thuat_tham_kham varchar NULL,
	ca_chup_id varchar(200) NULL, -- sId của ca chụp
	hososohoa_id uuid NULL,
	anh_resize jsonb NULL, -- Danh sách ảnh kết quả đã resize (JSON)
	khuyen_nghi_text text NULL,
	mo_ta_text text NULL,
	ket_luan_text text NULL,
	trang_thai_doc varchar(50) DEFAULT 'CHUA_DOC'::character varying NULL, -- Trạng thái đọc kết quả của bác sĩ chỉ định: CHUA_DOC/DA_DOC
	thoi_gian_xac_nhan_doc timestamp NULL -- Thời gian bác sĩ chỉ định xác nhận đã đọc kết quả
);

CREATE TABLE kb_thuc_hien_dich_vu_chi_tiet_copy1 (
	id uuid NOT NULL,
	phieu_dich_vu_chi_tiet_id uuid NULL,
	tiep_nhan_id uuid NULL,
	benh_an_id uuid NULL,
	benh_nhan_id uuid NULL,
	ma_cskcb varchar(50) NULL,
	nhom_dich_vu_id uuid NULL,
	dich_vu_id uuid NULL,
	dich_vu_th_id uuid NULL,
	thoi_gian_chup_phim timestamp(6) NULL,
	thoi_gian_lay_mau timestamp(6) NULL,
	thoi_gian_nhan_mau timestamp(6) NULL,
	ngay_gio_thuc_hien timestamp(6) NULL,
	vung_khao_sat varchar NULL,
	loai_film_id_1 uuid NULL,
	so_phim_su_dung_1 int4 NULL,
	loai_film_id_2 uuid NULL,
	so_phim_su_dung_2 int4 NULL,
	loai_film_id_3 uuid NULL,
	so_phim_su_dung_3 int4 NULL,
	bac_si_thuc_hien_id uuid NULL,
	bac_si_ket_luan_id uuid NULL,
	thoi_gian_doc_ket_qua timestamp(6) NULL,
	bac_si_doc_ket_qua_id uuid NULL,
	ky_thuat_vien_01_id uuid NULL,
	ky_thuat_vien_02_id uuid NULL,
	ky_thuat_vien_03_id uuid NULL,
	dieu_duong_id uuid NULL,
	is_gui_ngoai bool NULL,
	dai_the varchar NULL,
	vi_the varchar NULL,
	ban_luan varchar NULL,
	khuyen_nghi varchar NULL,
	so_block varchar NULL,
	so_mau varchar NULL,
	mo_ta varchar NULL,
	ket_qua varchar NULL,
	ket_luan varchar NULL,
	don_vi_tinh varchar NULL,
	chi_so_binh_thuong varchar NULL,
	ma_may varchar NULL,
	trang_thai varchar NULL,
	thoi_gian_khoa timestamp(6) NULL,
	is_khoa_du_lieu bool NULL,
	nguoi_khoa_id uuid NULL,
	anh_ket_qua varchar NULL,
	ngay_tao timestamp(6) DEFAULT CURRENT_TIMESTAMP NULL,
	nguoi_tao varchar(50) NULL,
	ngay_cap_nhat timestamp(6) NULL,
	nguoi_cap_nhat varchar(50) NULL,
	bi_xoa int2 DEFAULT 0 NULL,
	ngay_xoa timestamp(6) NULL,
	nguoi_xoa varchar(50) NULL,
	da_ghi_nhan bool NULL,
	ma_nhom_dich_vu varchar(50) NULL,
	xem_truoc_pacs varchar(500) NULL, -- URL xem trước ảnh từ PACS
	loi_dan varchar(500) NULL, -- lời dặn của bác sĩ
	tiem_can_quang int4 NULL, -- Đánh dấu tiệm cận quang
	sinh_thiet int4 NULL, -- Đánh dấu sinh thiết
	test_hp int4 NULL, -- Đánh dấu testhp
	thu_ky_y_khoa_id uuid NULL, -- Thư ký y khoa
	bac_si_gay_me_id uuid NULL, -- Bác sĩ gây mê id
	trang_thai_day_pacs varchar(50) NULL,
	ky_thuat_tham_kham varchar NULL,
	ca_chup_id varchar(200) NULL, -- sId của ca chụp
	hososohoa_id uuid NULL,
	anh_resize jsonb NULL
);

CREATE TABLE kb_thuc_hien_dich_vu_chi_tiet_xet_nghiem (
	phieu_dich_vu_chi_tiet_id uuid NULL, -- Id phiếu dịch vu chi tiết
	nhom_dich_vu_id uuid NULL, -- Nhóm dịch vụ id
	dich_vu_th_id uuid NULL, -- Id dịch vụ thực hiện chỉ số con
	dich_vu_id uuid NULL, -- Id dịch vụ
	don_vi_tinh varchar(50) NULL, -- Đơn vị tính
	ket_qua text NULL, -- Kết quả
	ket_qua_nhap_tay text NULL, -- Kết quả nhập tay
	muc_binh_thuong varchar(255) NULL, -- Mức bình thường
	muc_binh_thuong_min varchar(255) NULL, -- Mức bình thường min
	muc_binh_thuong_max varchar(255) NULL, -- Mức bình thường max
	bat_thuong bool NULL, -- Bất thường
	thuc_hien_ben_ngoai bool NULL, -- Thực hiện bên ngoài
	ma_cskcb varchar(100) NULL, -- Mã CSKCB
	id uuid DEFAULT gen_random_uuid() NOT NULL, -- Key của bảng
	ngay_tao timestamp DEFAULT now() NOT NULL, -- Ngày tạo
	nguoi_tao varchar(100) DEFAULT 'system'::character varying NOT NULL, -- Người tạo
	ngay_cap_nhat timestamp DEFAULT now() NOT NULL, -- Ngày cập nhật
	nguoi_cap_nhat varchar(100) DEFAULT 'system'::character varying NOT NULL, -- Người cập nhật
	bi_xoa int2 DEFAULT 0 NULL, -- Bị xóa mềm
	ngay_xoa timestamp NULL, -- Ngày xóa mềm
	nguoi_xoa varchar(100) NULL, -- Người xóa mềm
	kb_xet_nghiem_id uuid NULL, -- id trong bảng kb_xet_nghiem
	chi_so_con_id uuid NULL, -- Lưu id của chỉ số con  lấy từ bảng dmc_chi_so_con_xet_nghiem
	thiet_bi_id uuid NULL, -- Id của bảng dmc_vat_tu_trang_thiet_bi
	ghi_chu varchar NULL, -- ghi chú chỉ số 
	dich_vu_kt_id uuid NULL, -- lấy id từ bảng dịch vụ kỹ thuật (dm_dich_vu_kt)
	thiet_bi_di_kem_id uuid NULL, -- Thiết bị đi kèm (id dmc_vat_tu_trang_thiet_bi)
	CONSTRAINT kb_thuc_hien_dich_vu_chi_tiet_xet_nghiem_pkey PRIMARY KEY (id)
);

CREATE TABLE kb_tien_su_benh (
	id uuid DEFAULT gen_random_uuid() NOT NULL,
	benh_nhan_id uuid NOT NULL,
	tiep_nhan_id uuid NULL, -- FK đến tiep_nhan - dùng để lấy thông tin tiếp nhận/khám bệnh
	loai_tien_su varchar(50) NULL, -- Loại tiền sử: TT32, QD831, TT62
	data_thong_tu_32 jsonb NULL, -- JSONB data cho Thông tư 32
	data_qd_831 jsonb NULL, -- JSONB data cho QĐ 831
	data_thong_tu_62 jsonb NULL, -- JSONB data cho Thông tư 62
	ma_cskcb varchar(50) NOT NULL,
	ngay_tao timestamp DEFAULT CURRENT_TIMESTAMP NULL,
	nguoi_tao varchar(255) NULL,
	ngay_cap_nhat timestamp NULL,
	nguoi_cap_nhat varchar(255) NULL,
	bi_xoa int2 DEFAULT 0 NULL,
	ngay_xoa timestamp NULL,
	nguoi_xoa varchar(255) NULL,
	data_thong_tu_36 jsonb NULL,
	is_ksk int2 DEFAULT 0 NULL,
	nguoi_ky varchar NULL,
	nguoi_ky_id uuid NULL,
	phuong_thuc_ky varchar(50) NULL,
	trang_thai_ky int2 DEFAULT 0 NULL,
	CONSTRAINT kb_tien_su_benh_pkey PRIMARY KEY (id)
);

CREATE TABLE kb_tu_vong (
	id uuid DEFAULT gen_random_uuid() NOT NULL,
	tiep_nhan_id uuid NOT NULL, -- ID tiếp nhận
	benh_nhan_id uuid NOT NULL, -- ID bệnh nhân
	kham_benh_id uuid NULL, -- ID khám bệnh (FK)
	ma_cskcb varchar(50) NOT NULL,
	thoi_gian_vao_vien timestamp NULL, -- Thời điểm vào viện
	thoi_gian_tu_vong timestamp NULL, -- Thời điểm tử vong
	thoi_gian_kiem_diem timestamp NULL, -- Thời điểm kiểm điểm tử vong
	ma_khoa varchar NULL, -- Mã khoa điều trị
	ten_khoa varchar(255) NULL, -- Tên khoa điều trị
	chu_toa varchar NULL, -- Mã người chủ tọa
	ten_chu_toa varchar(255) NULL, -- Tên người chủ tọa
	thu_ky varchar NULL, -- Mã người thư ký
	ten_thu_ky varchar(255) NULL, -- Tên người thư ký
	thanh_vien_tham_gia text NULL, -- Danh sách thành viên tham gia
	tom_tat text NULL, -- Tóm tắt quá trình bệnh và điều trị
	ket_luan text NULL, -- Kết luận của hội đồng
	ngay_tao timestamp DEFAULT CURRENT_TIMESTAMP NULL,
	nguoi_tao varchar(50) NULL,
	ngay_cap_nhat timestamp NULL,
	nguoi_cap_nhat varchar(50) NULL,
	bi_xoa int2 DEFAULT 0 NULL,
	ngay_xoa timestamp NULL,
	nguoi_xoa varchar(50) NULL,
	hososohoa_id uuid NULL, -- FK HSSH của "Biên bản tử vong" — ký số / in phiếu
	so_phieu_tu_vong varchar(50) NULL,
	benh_an_id uuid NULL,
	hososohoa_trich_id uuid NULL, -- FK HSSH của "Trích biên bản tử vong" — ký số / in phiếu (report code riêng)
	nguyen_nhan_tu_vong text NULL, -- Nguyên nhân chính gây tử vong
	tom_tat_benh_su text NULL, -- Tóm tắt bệnh sử
	tinh_trang_vao_vien text NULL, -- Tình trạng người bệnh lúc vào viện
	chan_doan text NULL, -- Chẩn đoán của cơ sở / khoa khám bệnh / khoa điều trị / khi tử vong / giải phẫu bệnh
	dien_bien_dieu_tri text NULL, -- JSON: tóm tắt diễn biến bệnh, quá trình điều trị, chăm sóc, kết quả theo khoa/thời gian
	dien_bien_khac text NULL, -- Diễn biến khác (tự nhập)
	nguyen_nhan_bai_hoc text NULL, -- Nguyên nhân khách quan, chủ quan, bài học kinh nghiệm trong quá trình điều trị, chăm sóc
	ngay_cap_giay_tu_vong timestamp NULL,
	quyen_so varchar(50) NULL,
	nguoi_ghi_giay varchar(255) NULL,
	quyen_so_ban_dau varchar(50) NULL,
	dchi_thuongtru text NULL, -- Địa chỉ thường trú
	matinh_thuongtru varchar(10) NULL, -- Mã tỉnh thường trú
	mahuyen_thuongtru varchar(10) NULL, -- Mã huyện thường trú
	maxa_thuongtru varchar(10) NULL, -- Mã xã thường trú
	loai_giayto varchar(100) NULL, -- Loại giấy tờ: 1=CCCD, 2=CMND, 3=Hộ chiếu, 4=Giấy khai sinh, 5=Giấy chứng sinh, 6=Không có giấy tờ
	tinh_trang_tu_vong int2 NULL, -- Tình trạng tử vong
	so_baotu_bd varchar(100) NULL, -- Số báo tử BĐ
	hososohoa_bao_tu_vong_id uuid NULL,
	ho_ten_nguoi_than varchar(255) NULL,
	giayto_goc_id uuid NULL,
	so_lan_caplai int4 NULL,
	lydo_caplai varchar(500) NULL,
	nguoi_caplai varchar(255) NULL,
	thoigian_caplai timestamp NULL,
	CONSTRAINT kb_tu_vong_pkey PRIMARY KEY (id)
);

CREATE TABLE kb_xet_nghiem (
	id uuid DEFAULT gen_random_uuid() NOT NULL, -- Khóa chính
	ma_cskcb varchar(50) NOT NULL, -- Mã cơ sở khám chữa bệnh
	tiep_nhan_id uuid NOT NULL, -- ID trong bảng tiep_nhan
	benh_nhan_id uuid NOT NULL, -- ID trong bảng benh_nhan
	sid_id uuid NOT NULL, -- ID trong bảng lst_sid
	loai_xet_nghiem_id uuid NOT NULL, -- ID trong bảng dm_ma_nhom_dich_vu
	ten_loai_xet_nghiem varchar(255) NOT NULL, -- Tên nhóm dịch vụ trong bảng dm_ma_nhom_dich_vu
	ngay_tao timestamp(6) DEFAULT CURRENT_TIMESTAMP NOT NULL, -- Ngày tạo bản ghi
	nguoi_tao text NOT NULL, -- Người tạo bản ghi
	ngay_sua timestamp(6) NULL, -- Ngày sửa bản ghi
	nguoi_sua text NULL, -- Người sửa bản ghi
	bi_xoa int2 DEFAULT 0 NULL, -- 0: chưa xóa, 1: đã xóa
	ngay_xoa timestamp(6) NULL, -- Ngày xóa bản ghi
	nguoi_xoa text NULL, -- Người xóa bản ghi
	ma_sid varchar(14) NOT NULL, -- Mã sid
	ngay_cap_nhat timestamp DEFAULT now() NOT NULL, -- Ngày cập nhật
	nguoi_cap_nhat varchar(100) DEFAULT 'system'::character varying NOT NULL, -- Người cập nhật
	ket_luan varchar(255) NULL, -- Kết luận
	nguoi_duyet_id uuid NULL, -- id trong bảng dm_nhan_vien
	ngay_duyet timestamp DEFAULT now() NULL, -- Ngày duyệt kết quả
	hososohoa_id uuid NULL, -- Hồ sơ số hóa id 
	nguoi_tu_choi text NULL, -- người từ chối kết quả
	ngay_tu_choi timestamp DEFAULT now() NULL, -- ngày từ chối kết quả
	ly_do_tu_choi text NULL, -- lý do từ chố dịch vụ xét nghiệm
	nguoi_ky uuid NULL,
	ngay_ky timestamp NULL,
	nguoi_doc_ket_qua_id uuid NULL,
	ngay_doc_ket_qua timestamp NULL,
	da_doc bool DEFAULT false NOT NULL, -- Trạng thái đã đọc kết quả xét nghiệm: true - đã đọc, false - chưa đọc
	CONSTRAINT kb_xet_nghiem_pkey PRIMARY KEY (id)
);

CREATE TABLE kb_xet_nghiem_giai_phau_benh (
	id uuid DEFAULT gen_random_uuid() NOT NULL, -- ID bản ghi
	kb_xet_nghiem_id uuid NULL, -- ID bảng kb_xet_nghiem
	phieu_dich_vu_chi_tiet_id uuid NULL, -- ID bảng phieu_dich_vu_chi_tiet
	loai_gpb int4 NULL, -- Phân loại luồng GPB (1: Sinh thiết, 2: Tế bào, 3: Chọc hút tế bào)
	nguoi_pha_benh_pham_id uuid NULL, -- ID người pha bệnh phẩm 
	ngay_pha_benh_pham timestamp NULL, -- Ngày giờ thực hiện pha bệnh phẩm
	nguoi_lam_tieu_ban_id uuid NULL, -- ID người làm tiêu bản
	ngay_lam_tieu_ban timestamp NULL, -- Ngày giờ làm tiêu bản
	so_manh int4 NULL, -- Số lượng mảnh bệnh phẩm
	phuong_phap_nhuom_id uuid NULL, -- ID phương pháp nhuộm
	dai_the text NULL, -- Mô tả đại thể (Kích thước, màu sắc, mật độ quan sát bằng mắt thường)
	vi_the text NULL, -- Mô tả vi thể (Cấu trúc mô/tế bào quan sát dưới kính hiển vi)
	tinh_chat_benh_pham varchar NULL, -- Tính chất của bệnh phẩm
	vi_tri_lay_mau_id uuid NULL, -- ID danh mục vị trí lấy mẫu trên cơ thể
	ma_te_bao varchar NULL, -- Lấy trong bảng dm_cau_hinh_kb_giai_phau_benh
	de_nghi varchar NULL, -- Đề nghị hướng điều trị hoặc xét nghiệm bổ sung
	ma_cskcb varchar(100) NULL, -- Mã cơ sở khám chữa bệnh 
	ngay_tao timestamp DEFAULT now() NOT NULL, -- Ngày tạo bản ghi
	nguoi_tao varchar(100) DEFAULT 'system'::character varying NOT NULL, -- Người tạo bản ghi
	ngay_cap_nhat timestamp DEFAULT now() NOT NULL, -- Ngày cập nhật cuối cùng
	nguoi_cap_nhat varchar(100) DEFAULT 'system'::character varying NOT NULL, -- Người cập nhật cuối cùng
	bi_xoa int2 DEFAULT 0 NULL, -- Trạng thái xóa mềm (0: Đang dùng, 1: Đã xóa)
	ngay_xoa timestamp NULL, -- Ngày thực hiện xóa mềm
	nguoi_xoa varchar(100) NULL, -- Tài khoản thực hiện xóa mềm
	CONSTRAINT kb_xet_nghiem_giai_phau_benh_pkey PRIMARY KEY (id)
);

CREATE TABLE kb_xet_nghiem_khang_sinh_do (
	khang_sinh_id uuid NULL,
	vi_khuan_id uuid NULL,
	phuong_phap_xet_nghiem_id uuid NULL,
	thiet_bi_id uuid NULL,
	kb_xet_nghiem_id uuid NULL,
	chi_so_mic varchar(100) NULL,
	chi_so_mic_duong varchar(100) NULL,
	phien_giai_s bool NULL,
	phien_giai_i bool NULL,
	phien_giai_r bool NULL,
	nong_do numeric(18, 2) NULL,
	muc_min numeric(18, 2) NULL,
	muc_max numeric(18, 2) NULL,
	id uuid DEFAULT gen_random_uuid() NOT NULL,
	ngay_tao timestamp DEFAULT now() NOT NULL,
	nguoi_tao varchar(100) DEFAULT 'system'::character varying NOT NULL,
	ngay_cap_nhat timestamp DEFAULT now() NOT NULL,
	nguoi_cap_nhat varchar(100) DEFAULT 'system'::character varying NOT NULL,
	bi_xoa int2 DEFAULT 0 NULL,
	ngay_xoa timestamp NULL,
	nguoi_xoa varchar(100) NULL,
	phieu_dich_vu_chi_tiet_id uuid NULL, -- Id bảng phieu_dich_vu_chi_tiet
	ma_cskcb varchar(100) NULL,
	CONSTRAINT kb_xet_nghiem_khang_sinh_do_pkey PRIMARY KEY (id)
);

CREATE TABLE kb_xet_nghiem_nhom_mau (
	id uuid DEFAULT gen_random_uuid() NOT NULL,
	kb_xet_nghiem_id uuid NULL,
	phieu_dich_vu_chi_tiet_id uuid NULL,
	dmc_nhom_mau_id uuid NULL,
	dmc_yeutorh_id uuid NULL,
	mo_ta varchar NULL,
	ma_cskcb varchar(100) NULL,
	ngay_tao timestamp DEFAULT now() NOT NULL,
	nguoi_tao varchar(100) DEFAULT 'system'::character varying NOT NULL,
	ngay_cap_nhat timestamp DEFAULT now() NOT NULL,
	nguoi_cap_nhat varchar(100) DEFAULT 'system'::character varying NOT NULL,
	bi_xoa int2 DEFAULT 0 NULL,
	ngay_xoa timestamp NULL,
	nguoi_xoa varchar(100) NULL,
	ky_thuat_id uuid NULL,
	may_xet_nghiem_id uuid NULL,
	nhiet_do int4 NULL,
	thoi_gian_u int4 NULL,
	muc_do_duong_tinh int4 NULL,
	ket_qua varchar(100) NULL,
	CONSTRAINT kb_xet_nghiem_nhom_mau_pkey PRIMARY KEY (id)
);

CREATE TABLE kb_xet_nghiem_tui_mau (
	id uuid DEFAULT gen_random_uuid() NOT NULL,
	benh_nhan_id uuid NULL,
	hoso_sohoa_id uuid NULL,
	ma_don_thuoc varchar(100) NULL,
	trang_thai varchar(100) NULL,
	nguoi_duyet varchar(100) NULL,
	ngay_duyet timestamp NULL,
	nguoi_huy_duyet varchar(100) NULL,
	ngay_huy_duyet timestamp NULL,
	ma_cskcb varchar(100) NULL,
	ngay_tao timestamp DEFAULT now() NOT NULL,
	nguoi_tao varchar(100) DEFAULT 'system'::character varying NOT NULL,
	ngay_cap_nhat timestamp DEFAULT now() NOT NULL,
	nguoi_cap_nhat varchar(100) DEFAULT 'system'::character varying NOT NULL,
	bi_xoa int2 DEFAULT 0 NULL,
	ngay_xoa timestamp NULL,
	nguoi_xoa varchar(100) NULL,
	CONSTRAINT kb_xet_nghiem_tui_mau_pkey PRIMARY KEY (id)
);

CREATE TABLE kb_xet_nghiem_tui_mau_chi_tiet (
	id uuid DEFAULT gen_random_uuid() NOT NULL,
	kb_xet_nghiem_tui_mau_id uuid NULL,
	mau_id uuid NULL,
	phieu_dich_vu_id uuid NULL,
	ton_kho_ct_id int8 NOT NULL,
	trang_thai varchar(100) NULL,
	ma_cskcb varchar(100) NULL,
	ngay_tao timestamp DEFAULT now() NOT NULL,
	nguoi_tao varchar(100) DEFAULT 'system'::character varying NOT NULL,
	ngay_cap_nhat timestamp DEFAULT now() NOT NULL,
	nguoi_cap_nhat varchar(100) DEFAULT 'system'::character varying NOT NULL,
	bi_xoa int2 DEFAULT 0 NULL,
	ngay_xoa timestamp NULL,
	nguoi_xoa varchar(100) NULL,
	CONSTRAINT kb_xet_nghiem_tui_mau_chi_tiet_pkey PRIMARY KEY (id)
);

CREATE TABLE kb_xet_nghiem_vi_sinh (
	id uuid DEFAULT gen_random_uuid() NOT NULL,
	kb_xet_nghiem_id uuid NULL,
	phieu_dich_vu_chi_tiet_id uuid NULL,
	dinh_tinh bool DEFAULT false NULL,
	ma_vi_khuan varchar NULL,
	mo_ta varchar NULL,
	ma_cskcb varchar(100) NULL,
	ngay_tao timestamp DEFAULT now() NOT NULL,
	nguoi_tao varchar(100) DEFAULT 'system'::character varying NOT NULL,
	ngay_cap_nhat timestamp DEFAULT now() NOT NULL,
	nguoi_cap_nhat varchar(100) DEFAULT 'system'::character varying NOT NULL,
	bi_xoa int2 DEFAULT 0 NULL,
	ngay_xoa timestamp NULL,
	nguoi_xoa varchar(100) NULL,
	CONSTRAINT kb_xet_nghiem_vi_sinh_pkey PRIMARY KEY (id)
);

CREATE TABLE kbh_bhyt (
	id uuid DEFAULT gen_random_uuid() NULL,
	hosobenhanid varchar(50) NULL,
	ma_bhyt varchar(50) NULL,
	bhyt_bd timestamp NULL,
	bhyt_kt timestamp NULL
);

CREATE TABLE kbh_khambenh (
	khambenhid numeric(10) NOT NULL,
	makhambenh varchar(20) NULL,
	sothutuid numeric(10) NULL,
	sothutu numeric(10) NULL,
	sothutuphongkhamid numeric(10) NULL,
	sothutuphongkham numeric(10) NULL,
	tiepnhanid numeric(10) NULL,
	hosobenhanid numeric(10) NULL,
	khambenhid_tiep numeric(10) NULL,
	khambenhid_cha numeric(10) NULL,
	trangthaikhambenh numeric(2) NULL,
	khoaid numeric(6) NULL,
	phongid numeric(6) NULL,
	giuong varchar(100) NULL,
	loaibenhanid numeric(10) NULL,
	nguoidungid numeric(10) NULL,
	benhnhanid numeric(10) NULL,
	doituongbenhnhanid numeric(3) NULL,
	bhyt_benhnhanid numeric(10) NULL,
	lydodenkham varchar(1000) NULL,
	yeucaukham varchar(1000) NULL,
	thoigianvaovien timestamp NULL,
	thoigianchuyenden timestamp NULL,
	chandoanvaovien varchar(2000) NULL,
	chandoantuyenduoi varchar(1000) NULL,
	machandoantuyenduoi varchar(10) NULL,
	manoigioithieu varchar(10) NULL,
	machandoanvaovien varchar(10) NULL,
	chandoanvaovien_kemtheo varchar(1000) NULL,
	machandoanvaovien_kemtheo varchar(30) NULL,
	chandoankkb varchar(4000) NULL,
	machandoankkb varchar(10) NULL,
	chandoanvaokhoa varchar(2000) NULL,
	machandoanvaokhoa varchar(20) NULL,
	chandoanvaokhoa_kemtheo varchar(4000) NULL,
	machandoanvaokhoa_kemtheo varchar(20) NULL,
	dathuchienthuthuat numeric(1) NULL,
	dathuchienphauthuat numeric(1) NULL,
	hinhthucvaovienid numeric(2) NULL,
	phongchuyendenid numeric(10) NULL,
	uutienkhamid numeric(2) NULL,
	noigioithieuid numeric(10) NULL,
	vaoviencungbenhlanthu numeric(3) NULL,
	thoigianravien timestamp NULL,
	chandoanravien varchar(2000) NULL,
	machandoanravien varchar(10) NULL,
	chandoanravien_kemtheo varchar(4000) NULL,
	machandoanravien_kemtheo varchar(50) NULL,
	chandoanravien_kemtheo1 varchar(1000) NULL,
	machandoanravien_kemtheo1 varchar(10) NULL,
	chandoanravien_kemtheo2 varchar(1000) NULL,
	machandoanravien_kemtheo2 varchar(10) NULL,
	xutrikhambenhid numeric(2) NULL,
	hinhthucravienid numeric(2) NULL,
	ketquadieutriid numeric(2) NULL,
	khoachuyendenid numeric(10) NULL,
	giuongchuyendenid numeric(10) NULL,
	giuongnguoinha varchar(500) NULL,
	benhvienchuyendenid numeric(10) NULL,
	bitaibien numeric(1) NULL,
	bibienchung numeric(1) NULL,
	giaiphaubenhid numeric(2) NULL,
	lydovaovien varchar(4000) NULL,
	vaongaythucuabenh numeric(3) NULL,
	quatrinhbenhly varchar(4000) NULL,
	tiensubenh_banthan varchar(4000) NULL,
	tiensubenh_giadinh varchar(4000) NULL,
	khambenh_toanthan varchar(4000) NULL,
	khambenh_mach varchar(20) NULL,
	khambenh_nhietdo varchar(20) NULL,
	khambenh_huyetap_low varchar(20) NULL,
	khambenh_huyetap_high varchar(20) NULL,
	khambenh_nhiptho varchar(20) NULL,
	khambenh_cannang varchar(20) NULL,
	khambenh_chieucao varchar(20) NULL,
	khambenh_vongnguc varchar(20) NULL,
	khambenh_vongdau varchar(20) NULL,
	khambenh_bophan varchar(4000) NULL,
	tomtatkqcanlamsang varchar(4000) NULL,
	chandoanbandau varchar(1000) NULL,
	machandoanbandau varchar(20) NULL,
	daxuly varchar(1000) NULL,
	chandoankhoakhambenh varchar(1000) NULL,
	daxulyotuyenduoi varchar(20) NULL,
	ghichu varchar(200) NULL,
	ngaytruyxuat timestamp NULL,
	trangthai_cls numeric(1) NULL,
	nguoicapnhat numeric(15) NULL,
	ngaycapnhat timestamp NULL,
	keylock numeric(10) NULL,
	cv_chuyenvien_hinhthucid numeric(2) NULL,
	cv_chuyenvien_lydoid numeric(2) NULL,
	cv_chuyendungtuyen numeric(2) NULL,
	cv_chuyenvuottuyen numeric(2) NULL,
	xetnghiemcanthuchienlai varchar(1000) NULL,
	loidanbacsi varchar(1000) NULL,
	"version" timestamp NULL,
	sync_flag numeric(1) NULL,
	update_flag numeric(1) NULL,
	csytid int8 NULL,
	giuongid numeric(22) NULL,
	bacsydieutriid numeric(15) NULL,
	daxoa numeric(1) DEFAULT 0 NULL,
	khambenh_nhommau varchar(20) NULL,
	khambenh_rh varchar(20) NULL,
	khambenhdtkhid numeric(22) NULL,
	quatrinhbenhly1 varchar(4000) NULL,
	tiensubenh_banthan1 varchar(4000) NULL,
	tiensubenh_giadinh1 varchar(4000) NULL,
	khambenh_toanthan1 varchar(4000) NULL,
	ghichu_benhchinh varchar(500) NULL,
	ghichu_khambenh varchar(4000) NULL,
	nguoixutriid numeric(22) NULL,
	ngayxutri timestamp NULL,
	ghichu_benhchinh_ravien varchar(500) NULL,
	chuyenkhamngt numeric(2) NULL,
	ghichu_benhkemtheo varchar(1000) NULL,
	khambenh_vongtay varchar(20) NULL,
	khambenh_cannangtc varchar(20) NULL,
	khambenhid_ntu numeric(10) NULL,
	ngayvaovien_ntu timestamp NULL,
	spo2 varchar(20) NULL,
	khammeid numeric(10) NULL,
	flag_capnhat_bachung numeric(1) NULL,
	sochuyentuyen varchar(400) NULL,
	khamlaitrongngay numeric(3) DEFAULT 0 NULL,
	benhan_dn numeric(22) NULL,
	tainanthuongtichid numeric(10) DEFAULT 0 NULL,
	loidan varchar(1000) NULL,
	badtntmantinh numeric(2) NULL,
	khambenh_tuoithai varchar(500) NULL,
	huongdtrtiep varchar(2000) NULL,
	cdcls varchar(4000) NULL,
	khambenh_spo2 varchar(10) NULL,
	khambenh_duonghuyet varchar(80) NULL,
	thiluc_khongkinh_mt varchar(40) NULL,
	thiluc_khongkinh_mp varchar(40) NULL,
	thiluc_cokinh_mt varchar(40) NULL,
	thiluc_cokinh_mp varchar(40) NULL,
	nhanap_mt varchar(40) NULL,
	nhanap_mp varchar(40) NULL,
	khomat_mt varchar(40) NULL,
	khomat_mp varchar(40) NULL,
	tgiantd_tn timestamp NULL,
	tgiantd_dn timestamp NULL,
	diem_nguyco_nga varchar(4000) NULL,
	sndieutri numeric(22) NULL,
	ngayketluan timestamp NULL,
	ghichu_tiepnhan varchar(2000) NULL,
	lydocapcuu numeric(3) NULL,
	khoadulieu numeric(1) NULL,
	sanlocdinhduong varchar(100) NULL,
	dtbnlao varchar(200) NULL,
	tiensubenh_thaisan varchar(200) NULL,
	khambenh_para varchar(50) NULL,
	bacsidieutriduocchon numeric(1) NULL,
	ischuyendtkh numeric(1) NULL,
	ten_chandoan_vao_chinh_yhct varchar(2000) NULL,
	ma_chandoan_vao_chinh_yhct varchar(10) NULL,
	ten_chandoan_ra_chinh_yhct varchar(2000) NULL,
	ma_chandoan_ra_chinh_yhct varchar(10) NULL,
	ten_chandoan_vao_kemtheo_yhct varchar(4000) NULL,
	ten_chandoan_ra_kemtheo_yhct varchar(4000) NULL,
	chedoanid numeric(22) NULL,
	chedochamsocid numeric(22) NULL,
	ghichu_chedoan varchar(1000) NULL,
	phongnamvienid numeric(10) NULL,
	isbenhnhannang numeric(22) NULL,
	khambenh_diuongthuoc varchar(50) NULL,
	ischuyendtntsangnoitru numeric(1) NULL,
	mo_benhan numeric(1) NULL,
	khambenhid_moba numeric(20) NULL,
	ngayravien timestamp DEFAULT now() NULL,
	ghichuthambenh text NULL,
	ngaythambenh timestamp NULL,
	bacsyravieniid numeric(15) NULL,
	bacsiravieniid numeric(15) NULL,
	bacsy_hotroid numeric(22) NULL,
	loairavien numeric(2) NULL,
	bsketthucid numeric(22) NULL,
	giaidoanbenh varchar(3000) NULL,
	dieuduongid numeric(15) NULL,
	khamthai_amho varchar(1200) NULL,
	khamthai_ngoi numeric(22) NULL,
	khamthai_conngo numeric(22) NULL,
	khamthai_timthai numeric(22) NULL,
	khamthai_bctc numeric(22) NULL,
	khamthai_spo2 varchar(10) NULL,
	khamthai_rh varchar(10) NULL,
	khamthai_nhommau varchar(10) NULL,
	khamthai_benhkhac varchar(4000) NULL,
	khamthai_noingoaikhoa varchar(4000) NULL,
	khamthai_vetmocu varchar(4000) NULL,
	khamthai_sanphukhoa varchar(4000) NULL,
	khamthai_diung varchar(4000) NULL,
	khamthai_tuoithai numeric(22) NULL,
	khamthai_ghichu varchar(4000) NULL,
	khamthai_ngoi_chuoi varchar(255) NULL,
	khamthai_conngo_chuoi varchar(255) NULL,
	khamthai_tuoithai_chuoi varchar(255) NULL,
	khamthai_slthai varchar(255) NULL,
	khamthai_dando varchar(4000) NULL,
	khamthai_oi varchar(1200) NULL,
	khamthai_nguyco varchar(1200) NULL,
	khamthai_khungchau varchar(1200) NULL,
	khamthai_cotucung varchar(1200) NULL,
	khamthai_amdao varchar(1200) NULL,
	khamthai_para varchar(10) NULL,
	loaidieutri numeric(1) NULL,
	khambenh_ppdieutri varchar(4000) NULL,
	ten_chandoan_phanbiet varchar(4000) NULL,
	khambenh_benhsu varchar(2000) NULL,
	dt_banngay numeric(22) NULL,
	khambenh_dokhucxamat varchar(200) NULL,
	dokhucxamat varchar(200) NULL,
	tomtatbenhan varchar(5) NULL,
	khambenh_cannangtc3 varchar(10) NULL,
	khambenh_vongcanhtay3 varchar(10) NULL,
	khambenh_vongcanhtay varchar(10) NULL,
	ngaykhoiphat timestamp NULL,
	ghichu_chuyen_dtkh varchar(255) NULL,
	lichmoid numeric(10) NULL,
	ketqua_dtkh varchar(2000) NULL,
	tenthelamsang varchar(500) NULL,
	mahoa_thelamsang varchar(50) NULL,
	CONSTRAINT kbh_khambenh_pkey PRIMARY KEY (khambenhid)
);

CREATE TABLE kbh_maubenhpham (
	maubenhphamid numeric(10) NOT NULL,
	maubenhphamtamthoi numeric(1) NULL,
	phieutonghopsuatanid numeric(10) NULL,
	kiemkethuocid numeric(10) NULL,
	tudongtinhngaygiuong numeric(10) NULL,
	mahoadulieu numeric(1) NULL,
	sessionid numeric(10) NULL,
	khambenhid numeric(10) NULL,
	phongkhamdangkyid numeric(10) NULL,
	benhnhanid numeric(10) NULL,
	tiepnhanid numeric(10) NULL,
	hosobenhanid numeric(10) NULL,
	dathutien numeric(1) NULL,
	datamung numeric(1) NULL,
	phieudieutriid numeric(10) NULL,
	sothutuchidinhcanlamsang numeric(10) NULL,
	sothutuid numeric(10) NULL,
	sothutu numeric(10) NULL,
	sothutudagoi numeric(10) NULL,
	sothutuid_laymau numeric(10) NULL,
	sothutu_laymau numeric(10) NULL,
	sothutudagoi_laymau numeric(10) NULL,
	khothuocid numeric(10) NULL,
	khoaid numeric(6) NULL,
	phongid numeric(6) NULL,
	buonggiuong varchar(100) NULL,
	nguoidungid numeric(10) NULL,
	khoachuyendenid numeric(6) NULL,
	phongchuyendenid numeric(6) NULL,
	phonglaymauid numeric(10) NULL,
	sophieu varchar(30) NULL,
	barcode varchar(100) NULL,
	loaimaubenhpham numeric(2) NULL,
	maubenhphamhaophi numeric(10) NULL,
	loaiphieumaubenhpham numeric(2) NULL,
	loainhommaubenhpham numeric(2) NULL,
	trangthaidulieumaubenhpham numeric(2) NULL,
	trangthaimaubenhpham_laymau numeric(2) NULL,
	trangthaiinmaubenhpham numeric(2) NULL,
	trangthaimaubenhpham numeric(2) NULL,
	ngaymaubenhpham timestamp NULL,
	ngaymaubenhpham_sudung timestamp NULL,
	ngaymaubenhpham_thuchien timestamp NULL,
	ngaymaubenhpham_laymau timestamp NULL,
	ngaymaubenhpham_hoanthanh timestamp NULL,
	daxoa numeric(1) NULL,
	ngayxoamaubenhpham timestamp NULL,
	nguoixoa varchar(400) NULL,
	nguoitao varchar(200) NULL,
	nguoicapnhatbarcode varchar(60) NULL,
	nguoicapnhat varchar(60) NULL,
	loidanbacsi varchar(4000) NULL,
	ngaycapnhatbarcode timestamp NULL,
	ngaycapnhat timestamp NULL,
	nguoiduyet numeric(10) NULL,
	nguoitrakq numeric(10) NULL,
	nguoithuchien numeric(10) NULL,
	phongid_traketqua numeric(10) NULL,
	sotraketqua numeric(10) NULL,
	datraketqua numeric(1) NULL,
	nguoitraketqua numeric(10) NULL,
	ngaymaubenhpham_trakq timestamp NULL,
	hl7_is numeric(10) NULL,
	hl7_isdatraketqua numeric(1) NULL,
	hl7_ngaymaubenhpham_trakq timestamp NULL,
	benhnhantpid numeric(10) NULL,
	doituong varchar(2) NULL,
	tenbenhnhan varchar(400) NULL,
	diachibenhnhan varchar(400) NULL,
	dienthoaibenhnhan varchar(30) NULL,
	ngaysinhbenhnhan timestamp NULL,
	gioitinhbenhnhan numeric(1) NULL,
	chandoan varchar(2000) NULL,
	machandoan varchar(10) NULL,
	ghichu varchar(4000) NULL,
	chitietghichu varchar(200) NULL,
	thoigiandukiencoketqua timestamp NULL,
	sodienthoaibaotinkhicoketqua varchar(12) NULL,
	dacodichvuthutien numeric(1) NULL,
	dacodichvuduyetcanlamsang numeric(1) NULL,
	"version" timestamp NULL,
	sync_flag numeric(1) NULL,
	update_flag numeric(1) NULL,
	csytid int8 NULL,
	dichvucha_id numeric(10) NULL,
	chandoan_kemtheo varchar(2000) NULL,
	maubenhphamcha_id numeric(10) NULL,
	slthang numeric(3) NULL,
	phieuhen numeric(1) DEFAULT 0 NULL,
	ngayhen timestamp NULL,
	songayhen numeric(3) NULL,
	loaidonthuoc numeric(2) NULL,
	solanchuyen numeric(10) NULL,
	chandoan_kemtheo_bd varchar(2000) NULL,
	ghichu_benhchinh varchar(500) NULL,
	thoigian_benhpham numeric(1) NULL,
	khoakethuoc numeric(6) NULL,
	phongkethuoc numeric(6) NULL,
	donthuocle numeric(22) NULL,
	trangthai_duyetduoc_cls numeric(1) NULL,
	noidung_duyetduoc_cls varchar(500) NULL,
	nguoi_duyetduoc_cls numeric(12) NULL,
	loaikedon numeric(2) NULL,
	nhomthuocle varchar(50) NULL,
	phieuduyetduocclsid numeric(22) NULL,
	phieuchungclsid numeric(22) NULL,
	maphieuchungclsid varchar(50) NULL,
	ngay_duyetduoc_cls timestamp NULL,
	ykienbacsy varchar(4000) NULL,
	kieukedon numeric(1) NULL,
	dinhduong varchar(10) NULL,
	nguoihoanthanh numeric(10) NULL,
	bule numeric(22) NULL,
	cachsacthuoc varchar(1600) NULL,
	cachuong varchar(1000) NULL,
	dieukienid varchar(20) NULL,
	donthuocphu numeric(1) NULL,
	khokeid numeric(10) NULL,
	ma_xac_thuc varchar(20) NULL,
	"options" varchar(30) NULL,
	nguoitao_cls numeric(12) NULL,
	bacsingoaipk numeric(12) NULL,
	tenbacsycd varchar(500) NULL,
	thukhac_nvdikem varchar(800) NULL,
	thukhac_noidua varchar(800) NULL,
	nguoilaymau numeric(12) NULL,
	tglaymau timestamp NULL,
	maubenhpham_linhmau numeric(15) NULL,
	daydtdt numeric(22) NULL,
	daybtkd numeric(22) NULL,
	trangthai_duyet_ngt numeric(22) NULL,
	ketugoi numeric(22) NULL,
	loainhommau numeric(2) NULL,
	flag_ca numeric(3) NULL,
	dieuduongpk numeric(12) NULL,
	ngay_ck numeric(3) NULL,
	loaike varchar(10) NULL,
	phongnamvienid numeric(10) NULL,
	id_ke numeric(22) NULL,
	id_goike numeric(12) NULL,
	dot_thu numeric(22) NULL,
	mn_tungay timestamp NULL,
	mn_toingay timestamp NULL,
	duyetmo numeric(1) NULL,
	consp numeric(1) NULL,
	songay_ke numeric(22) NULL,
	thuocdieutri varchar(4000) NULL,
	ngayravien timestamp DEFAULT now() NULL,
	loaibenhpham varchar(200) NULL,
	nguoigiaomau numeric(12) NULL,
	tggiaomau timestamp NULL,
	nguoinhanmau numeric(12) NULL,
	tgnhanmau timestamp NULL,
	duyetduoc_cls numeric(22) NULL,
	trangthaiphieudieutri numeric(2) NULL,
	param_hashed varchar(100) NULL,
	sophieu_dtdt varchar(30) NULL,
	hentraketqua numeric(1) NULL,
	loaithanhtoan numeric(22) NULL,
	loaiphieu numeric(1) NULL,
	trangthai_td numeric(1) NULL,
	machandoan_yhct varchar(4000) NULL,
	tglaymau2 timestamp NULL,
	nguoigiaomau2 varchar(200) NULL,
	noigiaomau varchar(2000) NULL,
	bschidinh varchar(200) NULL,
	daduyetthuchiencls numeric(1) NULL,
	trathuoc_duoc numeric(2) NULL,
	thuoc_suat_huy numeric(2) NULL,
	thuoc_xuat_huy numeric(2) NULL,
	hctuxa numeric(1) NULL,
	donvithamgia numeric(6) NULL,
	bacsythamgia numeric(6) NULL,
	machandoanicdyhct varchar(30) NULL,
	tenchandoanicdyhct varchar(300) NULL,
	tenchandoanicdyhct_kt varchar(2000) NULL,
	loaiphieuthuoc numeric(2) NULL,
	kemau numeric(2) NULL,
	daydtdt_med numeric(22) NULL,
	trans_med varchar(4000) NULL,
	qrcode varchar(4000) NULL,
	ngaydukien_thuchien timestamp NULL,
	dotkethuoc_ct varchar(4000) NULL,
	tinhtrangbn varchar(4000) NULL,
	vitri_laymau varchar(4000) NULL,
	tenthelamsang varchar(500) NULL,
	mahoa_thelamsang varchar(50) NULL,
	nguoi_kychot numeric(22) NULL,
	dvkbid_huy varchar(4000) NULL,
	CONSTRAINT kbh_maubenhpham_pkey PRIMARY KEY (maubenhphamid)
);

CREATE TABLE kbh_tiepnhan (
	tiepnhanid varchar(50) NOT NULL,
	matiepnhan varchar(50) NULL,
	hosobenhanid varchar(50) NULL,
	ngaytiepnhan timestamp NULL,
	ngay_ravien timestamp NULL,
	CONSTRAINT kbh_tiepnhan_pkey PRIMARY KEY (tiepnhanid)
);

CREATE TABLE ke_hoach_ksk (
	id uuid DEFAULT gen_random_uuid() NOT NULL,
	ma varchar NOT NULL,
	ten varchar NOT NULL,
	thoi_gian_bat_dau date NOT NULL,
	thoi_gian_ket_thuc date NOT NULL,
	tong_gia_dich_vu numeric NULL,
	so_goi_dich_vu int4 NULL,
	so_luong_dich_vu numeric NULL,
	so_luong_khach_hang numeric NULL,
	trang_thai_ke_hoach_ma varchar NOT NULL,
	su_dung int2 NOT NULL,
	ma_cskcb varchar(10) NOT NULL,
	bi_xoa int2 DEFAULT 0 NOT NULL,
	ngay_tao timestamp DEFAULT CURRENT_TIMESTAMP NOT NULL,
	ngay_cap_nhat timestamp DEFAULT CURRENT_TIMESTAMP NOT NULL,
	nguoi_tao varchar(100) NOT NULL,
	nguoi_cap_nhat varchar(100) NULL,
	ngay_xoa timestamp NULL,
	nguoi_xoa varchar(50) NULL,
	ghi_chu varchar NULL,
	thue_ngoai int2 DEFAULT 0 NOT NULL,
	don_vi_ksk_id uuid NOT NULL,
	trang_thai_tong_hop varchar(25) NULL,
	cap_duyet_id uuid NULL,
	CONSTRAINT ke_hoach_ksk_pkey PRIMARY KEY (id)
);

CREATE TABLE ke_hoach_ksk_du_tru_khac (
	id uuid DEFAULT gen_random_uuid() NOT NULL,
	ma_cskcb varchar NOT NULL,
	ke_hoach_ksk_id uuid NOT NULL,
	khoa_id uuid NOT NULL,
	phong_id uuid NULL,
	nguoi_tong_hop_id uuid NOT NULL,
	ngay_tong_hop timestamp NULL,
	de_xuat text NULL,
	nguoi_tao varchar(25) NULL,
	ngay_tao timestamp DEFAULT now() NULL,
	nguoi_cap_nhat varchar(25) NULL,
	ngay_cap_nhat timestamp DEFAULT now() NULL,
	bi_xoa int2 DEFAULT 0 NOT NULL,
	nguoi_xoa varchar(25) NULL,
	ngay_xoa timestamp NULL,
	cap_duyet_id uuid NULL,
	trang_thai_phe_duyet int2 NULL,
	so_phien_ban int4 DEFAULT 0 NULL,
	CONSTRAINT ke_hoach_ksk_du_tru_khac_pkey PRIMARY KEY (id)
);

CREATE TABLE ke_hoach_ksk_du_tru_may (
	id uuid DEFAULT gen_random_uuid() NOT NULL,
	ma_cskcb varchar NOT NULL,
	ke_hoach_ksk_id uuid NOT NULL,
	khoa_id uuid NOT NULL,
	phong_id uuid NULL,
	nguoi_tong_hop_id uuid NOT NULL,
	ngay_tong_hop timestamp NULL,
	nguoi_tao varchar(25) NULL,
	ngay_tao timestamp DEFAULT now() NULL,
	nguoi_cap_nhat varchar(25) NULL,
	ngay_cap_nhat timestamp DEFAULT now() NULL,
	bi_xoa int2 DEFAULT 0 NOT NULL,
	nguoi_xoa varchar(25) NULL,
	ngay_xoa timestamp NULL,
	cap_duyet_id uuid NULL,
	trang_thai_phe_duyet int2 NULL,
	so_phien_ban int4 DEFAULT 0 NULL,
	CONSTRAINT ke_hoach_ksk_du_tru_may_pkey PRIMARY KEY (id)
);

CREATE TABLE ke_hoach_ksk_du_tru_may_chi_tiet (
	id uuid DEFAULT gen_random_uuid() NOT NULL,
	ma_cskcb varchar NOT NULL,
	ke_hoach_ksk_id uuid NOT NULL,
	ke_hoach_ksk_du_tru_may_id uuid NOT NULL,
	stt int4 NULL,
	may_id uuid NOT NULL,
	so_luong int4 NOT NULL,
	ghi_chu text NULL,
	ngay_tao timestamp DEFAULT now() NULL,
	nguoi_tao varchar(25) NULL,
	ngay_cap_nhat timestamp DEFAULT now() NULL,
	nguoi_cap_nhat varchar(25) NULL,
	bi_xoa int2 DEFAULT 0 NOT NULL,
	nguoi_xoa varchar(25) NULL,
	ngay_xoa timestamp NULL,
	nguoi_tong_hop_id uuid NOT NULL,
	ngay_tong_hop timestamp NULL,
	CONSTRAINT ke_hoach_ksk_du_tru_may_chi_tiet_pkey PRIMARY KEY (id)
);

CREATE TABLE ke_hoach_ksk_du_tru_nhan_su (
	id uuid DEFAULT gen_random_uuid() NOT NULL,
	ma_cskcb varchar NOT NULL,
	ke_hoach_ksk_id uuid NOT NULL,
	khoa_id uuid NOT NULL,
	phong_id uuid NULL,
	nguoi_tong_hop_id uuid NOT NULL,
	ngay_tong_hop timestamp NULL,
	nguoi_tao varchar(25) NULL,
	ngay_tao timestamp DEFAULT now() NULL,
	nguoi_cap_nhat varchar(25) NULL,
	ngay_cap_nhat timestamp DEFAULT now() NULL,
	bi_xoa int2 DEFAULT 0 NOT NULL,
	nguoi_xoa varchar(25) NULL,
	ngay_xoa timestamp NULL,
	cap_duyet_id uuid NULL,
	trang_thai_phe_duyet int2 NULL,
	so_phien_ban int4 DEFAULT 0 NULL,
	CONSTRAINT ke_hoach_ksk_du_tru_nhan_su_pkey PRIMARY KEY (id)
);

CREATE TABLE ke_hoach_ksk_du_tru_nhan_su_chi_tiet (
	id uuid DEFAULT gen_random_uuid() NOT NULL,
	ma_cskcb varchar NOT NULL,
	ke_hoach_ksk_id uuid NOT NULL,
	ke_hoach_ksk_du_tru_nhan_su_id uuid NOT NULL,
	stt int4 NULL,
	vai_tro_id uuid NOT NULL,
	so_luong int4 NOT NULL,
	ghi_chu text NULL,
	ngay_tao timestamp DEFAULT now() NULL,
	nguoi_tao varchar(25) NULL,
	ngay_cap_nhat timestamp DEFAULT now() NULL,
	nguoi_cap_nhat varchar(25) NULL,
	bi_xoa int2 DEFAULT 0 NOT NULL,
	nguoi_xoa varchar(25) NULL,
	ngay_xoa timestamp NULL,
	nguoi_tong_hop_id uuid NOT NULL,
	ngay_tong_hop timestamp NULL,
	CONSTRAINT ke_hoach_ksk_du_tru_nhan_su_chi_tiet_pkey PRIMARY KEY (id)
);

CREATE TABLE ke_hoach_ksk_du_tru_thuoc (
	id uuid DEFAULT gen_random_uuid() NOT NULL,
	ma_cskcb varchar NOT NULL,
	ke_hoach_ksk_id uuid NOT NULL,
	khoa_id uuid NOT NULL,
	phong_id uuid NULL,
	nguoi_tong_hop_id uuid NOT NULL,
	ngay_tong_hop timestamp NULL,
	de_xuat text NULL,
	nguoi_tao varchar(25) NULL,
	ngay_tao timestamp DEFAULT now() NULL,
	nguoi_cap_nhat varchar(25) NULL,
	ngay_cap_nhat timestamp DEFAULT now() NULL,
	bi_xoa int2 DEFAULT 0 NOT NULL,
	nguoi_xoa varchar(25) NULL,
	ngay_xoa timestamp NULL,
	cap_duyet_id uuid NULL,
	trang_thai_phe_duyet int2 NULL,
	so_phien_ban int4 DEFAULT 0 NULL,
	CONSTRAINT ke_hoach_ksk_du_tru_thuoc_pkey PRIMARY KEY (id)
);

CREATE TABLE ke_hoach_ksk_du_tru_thuoc_chi_tiet (
	id uuid DEFAULT gen_random_uuid() NOT NULL,
	ma_cskcb varchar NOT NULL,
	ke_hoach_ksk_id uuid NOT NULL,
	ke_hoach_ksk_du_tru_thuoc_id uuid NOT NULL,
	stt int4 NULL,
	hoat_chat_id uuid NOT NULL,
	so_luong_don numeric NOT NULL,
	ty_le numeric NULL,
	so_luong_dich_vu int4 NOT NULL,
	so_luong_tong numeric NOT NULL,
	ghi_chu text NULL,
	ngay_tao timestamp DEFAULT now() NULL,
	nguoi_tao varchar(25) NULL,
	ngay_cap_nhat timestamp DEFAULT now() NULL,
	nguoi_cap_nhat varchar(25) NULL,
	bi_xoa int2 DEFAULT 0 NOT NULL,
	nguoi_xoa varchar(25) NULL,
	ngay_xoa timestamp NULL,
	nguoi_tong_hop_id uuid NOT NULL,
	nong_do_ham_luong varchar NULL,
	dang_bao_che varchar NULL,
	nhom_thuoc varchar NULL,
	ngay_tong_hop timestamp NULL,
	duong_dung varchar NULL,
	CONSTRAINT ke_hoach_ksk_du_tru_thuoc_chi_tiet_pkey PRIMARY KEY (id)
);

CREATE TABLE ke_hoach_ksk_du_tru_van_phong_pham (
	id uuid DEFAULT gen_random_uuid() NOT NULL,
	ma_cskcb varchar NOT NULL,
	ke_hoach_ksk_id uuid NOT NULL,
	khoa_id uuid NOT NULL,
	phong_id uuid NULL,
	nguoi_tong_hop_id uuid NOT NULL,
	ngay_tong_hop timestamp NULL,
	nguoi_tao varchar(25) NULL,
	ngay_tao timestamp DEFAULT now() NULL,
	nguoi_cap_nhat varchar(25) NULL,
	ngay_cap_nhat timestamp DEFAULT now() NULL,
	bi_xoa int2 DEFAULT 0 NOT NULL,
	nguoi_xoa varchar(25) NULL,
	ngay_xoa timestamp NULL,
	cap_duyet_id uuid NULL,
	trang_thai_phe_duyet int2 NULL,
	so_phien_ban int4 DEFAULT 0 NULL,
	CONSTRAINT ke_hoach_ksk_du_tru_van_phong_pham_pkey PRIMARY KEY (id)
);

CREATE TABLE ke_hoach_ksk_du_tru_van_phong_pham_chi_tiet (
	id uuid DEFAULT gen_random_uuid() NOT NULL,
	ma_cskcb varchar NOT NULL,
	ke_hoach_ksk_id uuid NOT NULL,
	ke_hoach_ksk_du_tru_van_phong_pham_id uuid NOT NULL,
	stt int4 NULL,
	van_phong_pham_id uuid NOT NULL,
	so_luong_don numeric NOT NULL,
	so_luong_dich_vu int4 NOT NULL,
	so_luong_tong numeric NOT NULL,
	ghi_chu text NULL,
	ngay_tao timestamp DEFAULT now() NULL,
	nguoi_tao varchar(25) NULL,
	ngay_cap_nhat timestamp DEFAULT now() NULL,
	nguoi_cap_nhat varchar(25) NULL,
	bi_xoa int2 DEFAULT 0 NOT NULL,
	nguoi_xoa varchar(25) NULL,
	ngay_xoa timestamp NULL,
	nguoi_tong_hop_id uuid NOT NULL,
	ngay_tong_hop timestamp NULL,
	CONSTRAINT ke_hoach_ksk_du_tru_van_phong_pham_chi_tiet_pkey PRIMARY KEY (id)
);

CREATE TABLE ke_hoach_ksk_du_tru_vtythc (
	id uuid DEFAULT gen_random_uuid() NOT NULL,
	ma_cskcb varchar NOT NULL,
	ke_hoach_ksk_id uuid NOT NULL,
	khoa_id uuid NOT NULL,
	phong_id uuid NULL,
	nguoi_tong_hop_id uuid NOT NULL,
	ngay_tong_hop timestamp NULL,
	de_xuat text NULL,
	nguoi_tao varchar(25) NULL,
	ngay_tao timestamp DEFAULT now() NULL,
	nguoi_cap_nhat varchar(25) NULL,
	ngay_cap_nhat timestamp DEFAULT now() NULL,
	bi_xoa int2 DEFAULT 0 NOT NULL,
	nguoi_xoa varchar(25) NULL,
	ngay_xoa timestamp NULL,
	cap_duyet_id uuid NULL,
	trang_thai_phe_duyet int2 NULL,
	so_phien_ban int4 DEFAULT 0 NULL,
	CONSTRAINT ke_hoach_ksk_du_tru_vtythc_pkey PRIMARY KEY (id)
);

CREATE TABLE ke_hoach_ksk_du_tru_vtythc_chi_tiet (
	id uuid DEFAULT gen_random_uuid() NOT NULL,
	ma_cskcb varchar NOT NULL,
	ke_hoach_ksk_id uuid NOT NULL,
	ke_hoach_ksk_du_tru_vtythc_id uuid NOT NULL,
	stt int4 NULL,
	vat_tu_id uuid NOT NULL,
	so_luong_don numeric NOT NULL,
	ty_le numeric NULL,
	so_luong_dich_vu int4 NOT NULL,
	so_luong_tong numeric NOT NULL,
	ghi_chu text NULL,
	ngay_tao timestamp DEFAULT now() NULL,
	nguoi_tao varchar(25) NULL,
	ngay_cap_nhat timestamp DEFAULT now() NULL,
	nguoi_cap_nhat varchar(25) NULL,
	bi_xoa int2 DEFAULT 0 NOT NULL,
	nguoi_xoa varchar(25) NULL,
	ngay_xoa timestamp NULL,
	nguoi_tong_hop_id uuid NULL,
	ngay_tong_hop timestamp NULL,
	CONSTRAINT ke_hoach_ksk_du_tru_vtythc_chi_tiet_pkey PRIMARY KEY (id)
);

CREATE TABLE ksk_chi_so_dac_thu (
	id uuid DEFAULT gen_random_uuid() NOT NULL,
	tiep_nhan_id uuid NOT NULL,
	benh_nhan_id uuid NOT NULL,
	ma_cskcb varchar(50) NULL,
	ket_qua varchar(255) NULL,
	loai varchar(50) NULL,
	ngay_luu timestamp NULL,
	nguoi_luu varchar NULL,
	ngay_ky timestamp NULL,
	nguoi_ky varchar NULL,
	pt_loai varchar(50) NULL,
	pt_ly_do text NULL,
	pt_ngay_luu timestamp NULL,
	pt_nguoi_luu varchar NULL,
	pt_ngay_ky timestamp NULL,
	pt_nguoi_ky varchar NULL,
	bi_xoa int2 DEFAULT 0 NOT NULL,
	ngay_xoa timestamp NULL,
	nguoi_xoa varchar(100) NULL,
	ngay_tao timestamp DEFAULT CURRENT_TIMESTAMP NULL,
	nguoi_tao varchar NULL,
	ngay_cap_nhat timestamp NULL,
	nguoi_cap_nhat varchar NULL,
	nguoi_luu_id uuid NULL,
	nguoi_ky_id uuid NULL,
	pt_nguoi_luu_id uuid NULL,
	pt_nguoi_ky_id uuid NULL,
	nghien_ma_tuy int2 NULL,
	mau_va_dang_toc int2 NULL,
	roi_loan_sac_to_da int2 NULL,
	bam_lo int2 NULL,
	bam_lo_mo_ta text NULL,
	seo_loi_co_keo int2 NULL,
	co_the_khong_co_dau_hieu_tieu_cuc int2 NULL,
	co_the_khong_co_dau_hieu_tieu_cuc_mo_ta text NULL,
	pt_nghien_ma_tuy int2 NULL,
	pt_mau_va_dang_toc int2 NULL,
	pt_roi_loan_sac_to_da int2 NULL,
	pt_bam_lo int2 NULL,
	pt_seo_loi_co_keo int4 NULL,
	pt_co_the_khong_co_dau_hieu_tieu_cuc int2 NULL,
	pt_co_the_khong_co_dau_hieu_tieu_cuc_mo_ta text NULL,
	pt_bam_lo_mo_ta text NULL,
	phuong_thuc_ky varchar(50) NULL, -- VGCA,SMARTCA,SIGNHUB
	trang_thai_ky int2 DEFAULT 0 NULL, -- 0: Chưa ký 1: Đã ký 2: Hủy ký
	pt_phuong_thuc_ky varchar(50) NULL, -- VGCA,SMARTCA,SIGNHUB
	pt_trang_thai_ky int2 DEFAULT 0 NULL, -- 0: Chưa ký 1: Đã ký 2: Hủy ký
	CONSTRAINT ksk_chi_so_dac_thu_pkey PRIMARY KEY (id)
);

CREATE TABLE ksk_dong_bo_dich_vu_thieu (
	id uuid DEFAULT gen_random_uuid() NOT NULL,
	ma_cskcb varchar(50) NOT NULL,
	ma_dich_vu varchar(255) NOT NULL,
	ma_nhom_dich_vu varchar(255) NULL,
	ten_nhom_dich_vu varchar(500) NULL,
	ma_goi varchar(255) NULL,
	so_hop_dong varchar(255) NULL,
	client_code varchar(255) NULL,
	trans_id varchar(255) NULL,
	ly_do varchar(50) NOT NULL,
	trang_thai varchar(20) DEFAULT 'PENDING'::character varying NOT NULL,
	payload jsonb DEFAULT '{}'::jsonb NOT NULL,
	so_lan_gap int4 DEFAULT 1 NOT NULL,
	lan_dau_gap timestamp DEFAULT now() NOT NULL,
	lan_cuoi_gap timestamp DEFAULT now() NOT NULL,
	ngay_xuat timestamp NULL,
	nguoi_xuat varchar(255) NULL,
	ngay_xu_ly timestamp NULL,
	nguoi_xu_ly varchar(255) NULL,
	bi_xoa int2 DEFAULT 0 NOT NULL,
	nguoi_tao varchar(255) NULL,
	ngay_tao timestamp DEFAULT now() NOT NULL,
	nguoi_cap_nhat varchar(255) NULL,
	ngay_cap_nhat timestamp NULL,
	ten_dich_vu varchar(255) NULL,
	ma_byt varchar(25) NULL,
	CONSTRAINT chk_ksk_dv_thieu_ly_do CHECK (((ly_do)::text = ANY (ARRAY[('DICH_VU_KHONG_TON_TAI'::character varying)::text, ('THIEU_GIA'::character varying)::text, ('THIEU_NOI_THUC_HIEN'::character varying)::text]))),
	CONSTRAINT chk_ksk_dv_thieu_trang_thai CHECK (((trang_thai)::text = ANY (ARRAY[('PENDING'::character varying)::text, ('EXPORTED'::character varying)::text, ('IMPORTED'::character varying)::text, ('IGNORED'::character varying)::text]))),
	CONSTRAINT ksk_dong_bo_dich_vu_thieu_pkey PRIMARY KEY (id)
);

CREATE TABLE ksk_dong_bo_log (
	id uuid DEFAULT gen_random_uuid() NOT NULL,
	ma_cskcb varchar(50) NOT NULL,
	trans_id varchar(255) NOT NULL,
	client_code varchar(255) NULL,
	sync_code varchar(255) NULL,
	checksum_algorithm varchar(50) NULL,
	check_sum varchar(255) NULL,
	request_payload jsonb NULL,
	response_payload jsonb NULL,
	status varchar(20) NOT NULL,
	response_code varchar(10) NULL,
	error_message text NULL,
	error_detail text NULL,
	request_time timestamptz NULL,
	response_time timestamptz NULL,
	duration_ms int8 DEFAULT 0 NOT NULL,
	nguoi_tao varchar(255) NULL,
	ngay_tao timestamp DEFAULT now() NOT NULL,
	CONSTRAINT chk_ksk_dong_bo_log_status CHECK (((status)::text = ANY (ARRAY[('SUCCESS'::character varying)::text, ('ERROR'::character varying)::text]))),
	CONSTRAINT ksk_dong_bo_log_pkey PRIMARY KEY (id)
);

CREATE TABLE ksk_hoi_benh (
	id uuid DEFAULT gen_random_uuid() NOT NULL,
	ma_cskcb varchar NULL,
	tiep_nhan_id uuid NOT NULL,
	benh_nhan_id uuid NOT NULL,
	trieu_chung_dau jsonb NULL,
	trieu_chung_co_nang jsonb NULL,
	nguoi_tao varchar NULL,
	ngay_tao timestamp DEFAULT now() NULL,
	nguoi_cap_nhat varchar NULL,
	ngay_cap_nhat timestamp DEFAULT now() NULL,
	bi_xoa int2 DEFAULT 0 NULL,
	nguoi_xoa varchar(100) NULL,
	ngay_xoa timestamp NULL,
	CONSTRAINT ksk_hoi_benh_pkey PRIMARY KEY (id)
);

CREATE TABLE ksk_ket_luan (
	id uuid DEFAULT gen_random_uuid() NOT NULL,
	tiep_nhan_id uuid NOT NULL,
	benh_nhan_id uuid NOT NULL,
	thoi_gian_ket_thuc timestamp NULL,
	bac_sy_ket_luan varchar(250) NULL, -- Mã nhân viên (dm_nhan_vien)
	ngay_ket_luan timestamp NULL,
	ket_luan varchar(250) NULL,
	ma_icd_chinh varchar(50) NULL,
	ten_icd_chinh varchar(250) NULL,
	ma_icd_kem_theo varchar(50) NULL,
	ten_icd_kem_theo varchar(250) NULL,
	ma_icd_yhct varchar(250) NULL,
	ten_icd_yhct varchar(250) NULL,
	phan_loai_suc_khoe varchar(50) NULL,
	ma_cskcb varchar(50) NOT NULL,
	hoso_sohoa_id uuid NULL,
	ngay_tao timestamp DEFAULT now() NULL,
	nguoi_tao varchar(100) NULL,
	ngay_cap_nhat timestamp DEFAULT now() NULL,
	nguoi_cap_nhat varchar(100) NULL,
	bi_xoa int2 DEFAULT 0 NOT NULL,
	ngay_xoa timestamp NULL,
	nguoi_xoa varchar(100) NULL,
	bac_sy_ket_luan_id uuid NULL, -- Nhân viên ID (dm_nhan_vien)
	kb_tien_su_benh_id uuid NULL,
	phuong_thuc_ky varchar(50) NULL, -- VGCA,SMARTCA,SIGNHUB
	trang_thai_ky int2 DEFAULT 0 NULL, -- 0: Chưa ký 1: Đã ký 2: Hủy ký
	ngay_ky timestamp NULL,
	nguoi_ky varchar NULL,
	nguoi_ky_id uuid NULL,
	trang_thai_dong_bo int2 DEFAULT 0 NULL,
	nhat_ky_dong_bo_id uuid NULL,
	thoi_gian_dong_bo timestamp NULL,
	dong_bo_so_lan_thu_lai int2 DEFAULT 0 NULL,
	huong_xu_tri_id uuid NULL,
	ly_do_kham text NULL,
	CONSTRAINT ksk_ket_luan_pkey PRIMARY KEY (id),
	CONSTRAINT ksk_ket_luan_tiep_nhan_id_benh_nhan_id_key UNIQUE (tiep_nhan_id, benh_nhan_id)
);

CREATE TABLE ksk_ket_qua_can_lam_sang (
	id uuid DEFAULT gen_random_uuid() NOT NULL,
	ma_cskcb varchar NOT NULL,
	block_code varchar NOT NULL,
	tiep_nhan_id uuid NOT NULL,
	benh_nhan_id uuid NOT NULL,
	block_value varchar NULL,
	danh_gia text NULL,
	phieu_dich_vu_chi_tiet_id uuid NULL,
	dich_vu_id uuid NULL,
	chi_so_con_id uuid NULL,
	nguoi_ky varchar NULL,
	nguoi_ky_id uuid NULL,
	ngay_ky timestamp NULL,
	phuong_thuc_ky varchar(50) NULL,
	trang_thai_ky int2 DEFAULT 0 NULL, -- 0 - Chưa ký, 1 - Đã ký, 2 - Hủy ký
	ngay_tao timestamp DEFAULT now() NULL,
	nguoi_tao varchar NULL,
	ngay_cap_nhat timestamp DEFAULT now() NULL,
	nguoi_cap_nhat varchar NULL,
	bi_xoa int2 DEFAULT 0 NOT NULL,
	ngay_xoa timestamp NULL,
	nguoi_xoa varchar NULL,
	nguoi_luu varchar NULL,
	nguoi_luu_id uuid NULL,
	pt_block_value varchar NULL,
	pt_danh_gia text NULL,
	CONSTRAINT ksk_ket_qua_can_lam_sang_pkey PRIMARY KEY (id)
);

CREATE TABLE ksk_kham_co_xuong_khop (
	id uuid DEFAULT gen_random_uuid() NOT NULL,
	tiep_nhan_id uuid NOT NULL,
	benh_nhan_id uuid NOT NULL,
	ket_qua varchar(255) NULL,
	loai varchar(50) NULL,
	ngay_luu timestamp NULL,
	nguoi_luu varchar NULL,
	ngay_ky timestamp NULL,
	nguoi_ky varchar NULL,
	pt_loai varchar(50) NULL,
	pt_ly_do text NULL,
	pt_ngay_luu timestamp NULL,
	pt_nguoi_luu varchar NULL,
	pt_ngay_ky timestamp NULL,
	pt_nguoi_ky varchar NULL,
	bi_xoa int2 DEFAULT 0 NOT NULL,
	ngay_xoa timestamp NULL,
	nguoi_xoa varchar(100) NULL,
	ngay_tao timestamp DEFAULT CURRENT_TIMESTAMP NULL,
	nguoi_tao varchar NULL,
	ngay_cap_nhat timestamp NULL,
	nguoi_cap_nhat varchar NULL,
	ma_cskcb varchar NULL,
	nguoi_luu_id uuid NULL,
	nguoi_ky_id uuid NULL,
	pt_nguoi_luu_id uuid NULL,
	pt_nguoi_ky_id uuid NULL,
	khong_thuc_hien bool DEFAULT false NULL,
	phuong_thuc_ky varchar(50) NULL, -- VGCA,SMARTCA,SIGNHUB
	trang_thai_ky int2 DEFAULT 0 NULL, -- 0: Chưa ký 1: Đã ký 2: Hủy ký
	pt_phuong_thuc_ky varchar(50) NULL, -- VGCA,SMARTCA,SIGNHUB
	pt_trang_thai_ky int2 DEFAULT 0 NULL, -- 0: Chưa ký 1: Đã ký 2: Hủy ký
	CONSTRAINT ksk_kham_co_xuong_khop_pkey PRIMARY KEY (id)
);

CREATE TABLE ksk_kham_da_lieu (
	id uuid DEFAULT gen_random_uuid() NOT NULL,
	tiep_nhan_id uuid NOT NULL,
	benh_nhan_id uuid NOT NULL,
	ket_qua varchar(255) NULL,
	loai varchar(50) NULL,
	ngay_luu timestamp NULL,
	nguoi_luu varchar NULL,
	ngay_ky timestamp NULL,
	nguoi_ky varchar NULL,
	pt_loai varchar(50) NULL,
	pt_ly_do text NULL,
	pt_ngay_luu timestamp NULL,
	pt_nguoi_luu varchar NULL,
	pt_ngay_ky timestamp NULL,
	pt_nguoi_ky varchar NULL,
	bi_xoa int2 DEFAULT 0 NOT NULL,
	ngay_xoa timestamp NULL,
	nguoi_xoa varchar(100) NULL,
	ngay_tao timestamp DEFAULT CURRENT_TIMESTAMP NULL,
	nguoi_tao varchar NULL,
	ngay_cap_nhat timestamp NULL,
	nguoi_cap_nhat varchar NULL,
	ma_cskcb varchar NULL,
	nguoi_luu_id uuid NULL,
	nguoi_ky_id uuid NULL,
	pt_nguoi_luu_id uuid NULL,
	pt_nguoi_ky_id uuid NULL,
	khong_thuc_hien bool DEFAULT false NULL,
	phuong_thuc_ky varchar(50) NULL, -- VGCA,SMARTCA,SIGNHUB
	trang_thai_ky int2 DEFAULT 0 NULL, -- 0: Chưa ký 1: Đã ký 2: Hủy ký
	pt_phuong_thuc_ky varchar(50) NULL, -- VGCA,SMARTCA,SIGNHUB
	pt_trang_thai_ky int2 DEFAULT 0 NULL, -- 0: Chưa ký 1: Đã ký 2: Hủy ký
	CONSTRAINT ksk_kham_da_lieu_pkey PRIMARY KEY (id)
);

CREATE TABLE ksk_kham_ho_hap (
	id uuid DEFAULT gen_random_uuid() NOT NULL,
	tiep_nhan_id uuid NOT NULL,
	benh_nhan_id uuid NOT NULL,
	ket_qua varchar(255) NULL,
	loai varchar(50) NULL,
	ngay_luu timestamp NULL,
	nguoi_luu varchar NULL,
	ngay_ky timestamp NULL,
	nguoi_ky varchar NULL,
	pt_loai varchar(50) NULL,
	pt_ly_do text NULL,
	pt_ngay_luu timestamp NULL,
	pt_nguoi_luu varchar NULL,
	pt_ngay_ky timestamp NULL,
	pt_nguoi_ky varchar NULL,
	bi_xoa int2 DEFAULT 0 NOT NULL,
	ngay_xoa timestamp NULL,
	nguoi_xoa varchar(100) NULL,
	ngay_tao timestamp DEFAULT CURRENT_TIMESTAMP NULL,
	nguoi_tao varchar NULL,
	ngay_cap_nhat timestamp NULL,
	nguoi_cap_nhat varchar NULL,
	ma_cskcb varchar NULL,
	nguoi_luu_id uuid NULL,
	nguoi_ky_id uuid NULL,
	pt_nguoi_luu_id uuid NULL,
	pt_nguoi_ky_id uuid NULL,
	khong_thuc_hien bool DEFAULT false NULL,
	phuong_thuc_ky varchar(50) NULL, -- VGCA,SMARTCA,SIGNHUB
	trang_thai_ky int2 DEFAULT 0 NULL, -- 0: Chưa ký 1: Đã ký 2: Hủy ký
	pt_phuong_thuc_ky varchar(50) NULL, -- VGCA,SMARTCA,SIGNHUB
	pt_trang_thai_ky int2 DEFAULT 0 NULL, -- 0: Chưa ký 1: Đã ký 2: Hủy ký
	long_nguc varchar NULL,
	nhip_tho numeric NULL,
	phoi varchar NULL,
	CONSTRAINT ksk_kham_ho_hap_pkey PRIMARY KEY (id)
);

CREATE TABLE ksk_kham_lam_sang_khac (
	ma_cskcb varchar NULL,
	nguoi_luu_id uuid NULL,
	nguoi_cap_nhat varchar NULL,
	ket_qua varchar(255) NULL,
	bi_xoa int2 DEFAULT 0 NOT NULL,
	pt_ngay_ky timestamp NULL,
	ngay_xoa timestamp NULL,
	ngay_tao timestamp DEFAULT CURRENT_TIMESTAMP NULL,
	nguoi_tao varchar NULL,
	nguoi_ky varchar NULL,
	loai varchar(50) NULL,
	pt_ngay_luu timestamp NULL,
	pt_nguoi_ky varchar NULL,
	benh_nhan_id uuid NOT NULL,
	id uuid DEFAULT gen_random_uuid() NOT NULL,
	pt_nguoi_luu varchar NULL,
	ngay_luu timestamp NULL,
	nguoi_xoa varchar(100) NULL,
	khong_thuc_hien bool DEFAULT false NULL,
	tiep_nhan_id uuid NOT NULL,
	nguoi_ky_id uuid NULL,
	nguoi_luu varchar NULL,
	pt_ly_do text NULL,
	pt_nguoi_luu_id uuid NULL,
	ngay_cap_nhat timestamp NULL,
	pt_nguoi_ky_id uuid NULL,
	ngay_ky timestamp NULL,
	pt_loai varchar(50) NULL,
	trieu_chung_co_nang jsonb NULL,
	trieu_chung_dau jsonb NULL,
	trieu_chung_khac jsonb NULL,
	phuong_thuc_ky varchar(50) NULL, -- VGCA,SMARTCA,SIGNHUB
	trang_thai_ky int2 DEFAULT 0 NULL, -- 0: Chưa ký 1: Đã ký 2: Hủy ký
	pt_phuong_thuc_ky varchar(50) NULL, -- VGCA,SMARTCA,SIGNHUB
	pt_trang_thai_ky int2 DEFAULT 0 NULL, -- 0: Chưa ký 1: Đã ký 2: Hủy ký
	CONSTRAINT ksk_kham_lam_sang_khac_pkey PRIMARY KEY (id)
);

CREATE TABLE ksk_kham_mat (
	id uuid DEFAULT gen_random_uuid() NOT NULL,
	tiep_nhan_id uuid NOT NULL,
	benh_nhan_id uuid NOT NULL,
	kk_mat_phai varchar(255) NULL,
	kk_mat_trai varchar(255) NULL,
	ck_mat_phai varchar(255) NULL,
	ck_mat_trai varchar(255) NULL,
	benh_mat varchar(255) NULL,
	loai varchar(50) NULL,
	ngay_luu timestamp NULL,
	nguoi_luu varchar NULL,
	ngay_ky timestamp NULL,
	nguoi_ky varchar NULL,
	bi_xoa int2 DEFAULT 0 NOT NULL,
	ngay_xoa timestamp NULL,
	nguoi_xoa varchar(100) NULL,
	ngay_tao timestamp DEFAULT CURRENT_TIMESTAMP NULL,
	nguoi_tao varchar NULL,
	ngay_cap_nhat timestamp NULL,
	nguoi_cap_nhat varchar NULL,
	ma_cskcb varchar NULL,
	nguoi_luu_id uuid NULL,
	nguoi_ky_id uuid NULL,
	pt_nguoi_luu_id uuid NULL,
	pt_nguoi_ky_id uuid NULL,
	pt_loai varchar(50) NULL,
	pt_ly_do varchar(255) NULL,
	pt_ngay_luu timestamp NULL,
	pt_nguoi_luu varchar NULL,
	pt_ngay_ky timestamp NULL,
	pt_nguoi_ky varchar NULL,
	nhin_xa_kk varchar NULL,
	nhin_xa_ck varchar NULL,
	thi_truong_ngang int2 NULL,
	thi_truong_dung int2 NULL,
	sac_giac_bt int2 NULL,
	mu_mau_toan_bo int2 NULL,
	mu_mau_do int2 NULL,
	mu_mau_xanh int2 NULL,
	mu_mau_vang int2 NULL,
	khong_thuc_hien bool DEFAULT false NULL,
	phuong_thuc_ky varchar(50) NULL, -- VGCA,SMARTCA,SIGNHUB
	trang_thai_ky int2 DEFAULT 0 NULL, -- 0: Chưa ký 1: Đã ký 2: Hủy ký
	pt_phuong_thuc_ky varchar(50) NULL, -- VGCA,SMARTCA,SIGNHUB
	pt_trang_thai_ky int2 DEFAULT 0 NULL, -- 0: Chưa ký 1: Đã ký 2: Hủy ký
	ket_qua varchar(255) NULL,
	nhan_ap varchar NULL,
	thuy_tinh_the varchar NULL,
	soi_day_mat varchar NULL,
	CONSTRAINT ksk_kham_mat_pkey PRIMARY KEY (id)
);

CREATE TABLE ksk_kham_ngoai_khoa (
	id uuid DEFAULT gen_random_uuid() NOT NULL,
	tiep_nhan_id uuid NOT NULL,
	benh_nhan_id uuid NOT NULL,
	ma_cskcb varchar(50) NULL,
	ket_qua varchar(255) NULL,
	loai varchar(50) NULL,
	ngay_luu timestamp NULL,
	nguoi_luu varchar NULL,
	ngay_ky timestamp NULL,
	nguoi_ky varchar NULL,
	pt_loai varchar(50) NULL,
	pt_ly_do text NULL,
	pt_ngay_luu timestamp NULL,
	pt_nguoi_luu varchar NULL,
	pt_ngay_ky timestamp NULL,
	pt_nguoi_ky varchar NULL,
	bi_xoa int2 DEFAULT 0 NOT NULL,
	ngay_xoa timestamp NULL,
	nguoi_xoa varchar(100) NULL,
	ngay_tao timestamp DEFAULT CURRENT_TIMESTAMP NULL,
	nguoi_tao varchar NULL,
	ngay_cap_nhat timestamp NULL,
	nguoi_cap_nhat varchar NULL,
	nguoi_luu_id uuid NULL,
	nguoi_ky_id uuid NULL,
	pt_nguoi_luu_id uuid NULL,
	pt_nguoi_ky_id uuid NULL,
	khong_thuc_hien bool DEFAULT false NULL,
	phuong_thuc_ky varchar(50) NULL, -- VGCA,SMARTCA,SIGNHUB
	trang_thai_ky int2 DEFAULT 0 NULL, -- 0: Chưa ký 1: Đã ký 2: Hủy ký
	pt_phuong_thuc_ky varchar(50) NULL, -- VGCA,SMARTCA,SIGNHUB
	pt_trang_thai_ky int2 DEFAULT 0 NULL, -- 0: Chưa ký 1: Đã ký 2: Hủy ký
	CONSTRAINT ksk_kham_ngoai_khoa_pkey PRIMARY KEY (id)
);

CREATE TABLE ksk_kham_noi_tiet (
	id uuid DEFAULT gen_random_uuid() NOT NULL,
	tiep_nhan_id uuid NOT NULL,
	benh_nhan_id uuid NOT NULL,
	ket_qua varchar(255) NULL,
	loai varchar(50) NULL,
	ngay_luu timestamp NULL,
	nguoi_luu varchar NULL,
	ngay_ky timestamp NULL,
	nguoi_ky varchar NULL,
	pt_loai varchar(50) NULL,
	pt_ly_do text NULL,
	pt_ngay_luu timestamp NULL,
	pt_nguoi_luu varchar NULL,
	pt_ngay_ky timestamp NULL,
	pt_nguoi_ky varchar NULL,
	bi_xoa int2 DEFAULT 0 NOT NULL,
	ngay_xoa timestamp NULL,
	nguoi_xoa varchar(100) NULL,
	ngay_tao timestamp DEFAULT CURRENT_TIMESTAMP NULL,
	nguoi_tao varchar NULL,
	ngay_cap_nhat timestamp NULL,
	nguoi_cap_nhat varchar NULL,
	ma_cskcb varchar NULL,
	nguoi_luu_id uuid NULL,
	nguoi_ky_id uuid NULL,
	pt_nguoi_luu_id uuid NULL,
	pt_nguoi_ky_id uuid NULL,
	khong_thuc_hien bool DEFAULT false NULL,
	phuong_thuc_ky varchar(50) NULL, -- VGCA,SMARTCA,SIGNHUB
	trang_thai_ky int2 DEFAULT 0 NULL, -- 0: Chưa ký 1: Đã ký 2: Hủy ký
	pt_phuong_thuc_ky varchar(50) NULL, -- VGCA,SMARTCA,SIGNHUB
	pt_trang_thai_ky int2 DEFAULT 0 NULL, -- 0: Chưa ký 1: Đã ký 2: Hủy ký
	CONSTRAINT ksk_kham_noi_tiet_pkey PRIMARY KEY (id)
);

CREATE TABLE ksk_kham_rang_ham_mat (
	id uuid DEFAULT gen_random_uuid() NOT NULL,
	tiep_nhan_id uuid NOT NULL,
	benh_nhan_id uuid NOT NULL,
	ham_tren varchar(255) NULL,
	ham_duoi varchar(255) NULL,
	tom_tat varchar(255) NULL,
	loai varchar(50) NULL,
	ngay_luu timestamp NULL,
	nguoi_luu varchar NULL,
	ngay_ky timestamp NULL,
	nguoi_ky varchar NULL,
	ngay_huy_ky timestamp NULL,
	nguoi_huy_ky varchar NULL,
	pt_loai varchar(50) NULL,
	pt_ly_do text NULL,
	pt_ngay_luu timestamp NULL,
	pt_nguoi_luu varchar NULL,
	pt_ngay_ky timestamp NULL,
	pt_nguoi_ky varchar NULL,
	bi_xoa int2 DEFAULT 0 NOT NULL,
	ngay_xoa timestamp NULL,
	nguoi_xoa varchar(100) NULL,
	ngay_tao timestamp DEFAULT CURRENT_TIMESTAMP NULL,
	nguoi_tao varchar NULL,
	ngay_cap_nhat timestamp NULL,
	nguoi_cap_nhat varchar NULL,
	ma_cskcb varchar NULL,
	nguoi_luu_id uuid NULL,
	nguoi_ky_id uuid NULL,
	pt_nguoi_luu_id uuid NULL,
	pt_nguoi_ky_id uuid NULL,
	khong_thuc_hien bool DEFAULT false NULL,
	phuong_thuc_ky varchar(50) NULL, -- VGCA,SMARTCA,SIGNHUB
	trang_thai_ky int2 DEFAULT 0 NULL, -- 0: Chưa ký 1: Đã ký 2: Hủy ký
	pt_phuong_thuc_ky varchar(50) NULL, -- VGCA,SMARTCA,SIGNHUB
	pt_trang_thai_ky int2 DEFAULT 0 NULL, -- 0: Chưa ký 1: Đã ký 2: Hủy ký
	CONSTRAINT ksk_kham_rang_ham_mat_pkey PRIMARY KEY (id)
);

CREATE TABLE ksk_kham_san_phu_khoa (
	id uuid DEFAULT gen_random_uuid() NOT NULL,
	tiep_nhan_id uuid NOT NULL,
	benh_nhan_id uuid NOT NULL,
	ket_qua varchar(255) NULL,
	loai varchar(50) NULL,
	ngay_luu timestamp NULL,
	nguoi_luu varchar NULL,
	ngay_ky timestamp NULL,
	nguoi_ky varchar NULL,
	pt_loai varchar(50) NULL,
	pt_ly_do text NULL,
	pt_ngay_luu timestamp NULL,
	pt_nguoi_luu varchar NULL,
	pt_ngay_ky timestamp NULL,
	pt_nguoi_ky varchar NULL,
	bi_xoa int2 DEFAULT 0 NOT NULL,
	ngay_xoa timestamp NULL,
	nguoi_xoa varchar(100) NULL,
	ngay_tao timestamp DEFAULT CURRENT_TIMESTAMP NULL,
	nguoi_tao varchar NULL,
	ngay_cap_nhat timestamp NULL,
	nguoi_cap_nhat varchar NULL,
	ma_cskcb varchar NULL,
	nguoi_luu_id uuid NULL,
	nguoi_ky_id uuid NULL,
	pt_nguoi_luu_id uuid NULL,
	pt_nguoi_ky_id uuid NULL,
	khong_thuc_hien bool DEFAULT false NULL,
	phuong_thuc_ky varchar(50) NULL, -- VGCA,SMARTCA,SIGNHUB
	trang_thai_ky int2 DEFAULT 0 NULL, -- 0: Chưa ký 1: Đã ký 2: Hủy ký
	pt_phuong_thuc_ky varchar(50) NULL, -- VGCA,SMARTCA,SIGNHUB
	pt_trang_thai_ky int2 DEFAULT 0 NULL, -- 0: Chưa ký 1: Đã ký 2: Hủy ký
	CONSTRAINT ksk_kham_san_phu_khoa_pkey PRIMARY KEY (id)
);

CREATE TABLE ksk_kham_san_phu_khoa_chi_tiet (
	id uuid DEFAULT gen_random_uuid() NOT NULL,
	ksk_kham_san_phu_khoa_id uuid NOT NULL,
	ma_hang_muc_cha varchar(25) NULL,
	ten_hang_muc_cha varchar(255) NULL,
	ma_hang_muc_con varchar(25) NULL,
	ten_hang_muc_con varchar(255) NULL,
	ket_qua varchar(255) NULL,
	ghi_chu text NULL,
	ma_cskcb varchar NULL,
	pt_ket_qua varchar(255) NULL,
	ngay_tao timestamp DEFAULT now() NULL,
	nguoi_tao varchar NULL,
	ngay_cap_nhat timestamp DEFAULT now() NULL,
	nguoi_cap_nhat varchar NULL,
	bi_xoa int2 DEFAULT 0 NULL,
	ngay_xoa timestamp NULL,
	nguoi_xoa varchar NULL,
	pt_ghi_chu text NULL,
	CONSTRAINT ksk_kham_san_phu_khoa_chi_tiet_pkey PRIMARY KEY (id)
);

CREATE TABLE ksk_kham_tai_mui_hong (
	id uuid DEFAULT gen_random_uuid() NOT NULL,
	tiep_nhan_id uuid NOT NULL,
	benh_nhan_id uuid NOT NULL,
	tai_trai_noi_thuong varchar(255) NULL,
	tai_trai_noi_tham varchar(255) NULL,
	tai_phai_noi_thuong varchar(255) NULL,
	tai_phai_noi_tham varchar(255) NULL,
	benh_tmh varchar(255) NULL,
	loai varchar(50) NULL,
	ngay_luu timestamp NULL,
	nguoi_luu varchar NULL,
	ngay_ky timestamp NULL,
	nguoi_ky varchar NULL,
	pt_loai varchar(50) NULL,
	pt_ly_do text NULL,
	pt_ngay_luu timestamp NULL,
	pt_nguoi_luu varchar NULL,
	pt_ngay_ky timestamp NULL,
	pt_nguoi_ky varchar NULL,
	bi_xoa int2 DEFAULT 0 NOT NULL,
	ngay_xoa timestamp NULL,
	nguoi_xoa varchar(100) NULL,
	ngay_tao timestamp DEFAULT CURRENT_TIMESTAMP NULL,
	nguoi_tao varchar NULL,
	ngay_cap_nhat timestamp NULL,
	nguoi_cap_nhat varchar NULL,
	ma_cskcb varchar NULL,
	nguoi_luu_id uuid NULL,
	nguoi_ky_id uuid NULL,
	pt_nguoi_luu_id uuid NULL,
	pt_nguoi_ky_id uuid NULL,
	khong_thuc_hien bool DEFAULT false NULL,
	phuong_thuc_ky varchar(50) NULL, -- VGCA,SMARTCA,SIGNHUB
	trang_thai_ky int2 DEFAULT 0 NULL, -- 0: Chưa ký 1: Đã ký 2: Hủy ký
	pt_phuong_thuc_ky varchar(50) NULL, -- VGCA,SMARTCA,SIGNHUB
	pt_trang_thai_ky int2 DEFAULT 0 NULL, -- 0: Chưa ký 1: Đã ký 2: Hủy ký
	ket_qua varchar(255) NULL,
	tai_ngoai varchar NULL,
	tai_trai_do_thinh_luc varchar NULL,
	tai_phai_do_thinh_luc varchar NULL,
	noi_soi_tmh varchar NULL,
	CONSTRAINT ksk_kham_tai_mui_hong_pkey PRIMARY KEY (id)
);

CREATE TABLE ksk_kham_tam_than (
	id uuid DEFAULT gen_random_uuid() NOT NULL,
	tiep_nhan_id uuid NOT NULL,
	benh_nhan_id uuid NOT NULL,
	ket_qua varchar(255) NULL,
	loai varchar(50) NULL,
	ngay_luu timestamp NULL,
	nguoi_luu varchar NULL,
	ngay_ky timestamp NULL,
	nguoi_ky varchar NULL,
	pt_loai varchar(50) NULL,
	pt_ly_do text NULL,
	pt_ngay_luu timestamp NULL,
	pt_nguoi_luu varchar NULL,
	pt_ngay_ky timestamp NULL,
	pt_nguoi_ky varchar NULL,
	bi_xoa int2 DEFAULT 0 NOT NULL,
	ngay_xoa timestamp NULL,
	nguoi_xoa varchar(100) NULL,
	ngay_tao timestamp DEFAULT CURRENT_TIMESTAMP NULL,
	nguoi_tao varchar NULL,
	ngay_cap_nhat timestamp NULL,
	nguoi_cap_nhat varchar NULL,
	ma_cskcb varchar NULL,
	nguoi_luu_id uuid NULL,
	nguoi_ky_id uuid NULL,
	pt_nguoi_luu_id uuid NULL,
	pt_nguoi_ky_id uuid NULL,
	khong_thuc_hien bool DEFAULT false NULL,
	phuong_thuc_ky varchar(50) NULL, -- VGCA,SMARTCA,SIGNHUB
	trang_thai_ky int2 DEFAULT 0 NULL, -- 0: Chưa ký 1: Đã ký 2: Hủy ký
	pt_phuong_thuc_ky varchar(50) NULL, -- VGCA,SMARTCA,SIGNHUB
	pt_trang_thai_ky int2 DEFAULT 0 NULL, -- 0: Chưa ký 1: Đã ký 2: Hủy ký
	CONSTRAINT ksk_kham_tam_than_pkey PRIMARY KEY (id)
);

CREATE TABLE ksk_kham_than_kinh (
	id uuid DEFAULT gen_random_uuid() NOT NULL,
	tiep_nhan_id uuid NOT NULL,
	benh_nhan_id uuid NOT NULL,
	ket_qua varchar(255) NULL,
	loai varchar(50) NULL,
	ngay_luu timestamp NULL,
	nguoi_luu varchar NULL,
	ngay_ky timestamp NULL,
	nguoi_ky varchar NULL,
	pt_loai varchar(50) NULL,
	pt_ly_do text NULL,
	pt_ngay_luu timestamp NULL,
	pt_nguoi_luu varchar NULL,
	pt_ngay_ky timestamp NULL,
	pt_nguoi_ky varchar NULL,
	bi_xoa int2 DEFAULT 0 NOT NULL,
	ngay_xoa timestamp NULL,
	nguoi_xoa varchar(100) NULL,
	ngay_tao timestamp DEFAULT CURRENT_TIMESTAMP NULL,
	nguoi_tao varchar NULL,
	ngay_cap_nhat timestamp NULL,
	nguoi_cap_nhat varchar NULL,
	ma_cskcb varchar NULL,
	nguoi_luu_id uuid NULL,
	nguoi_ky_id uuid NULL,
	pt_nguoi_luu_id uuid NULL,
	pt_nguoi_ky_id uuid NULL,
	khong_thuc_hien bool DEFAULT false NULL,
	phuong_thuc_ky varchar(50) NULL, -- VGCA,SMARTCA,SIGNHUB
	trang_thai_ky int2 DEFAULT 0 NULL, -- 0: Chưa ký 1: Đã ký 2: Hủy ký
	pt_phuong_thuc_ky varchar(50) NULL, -- VGCA,SMARTCA,SIGNHUB
	pt_trang_thai_ky int2 DEFAULT 0 NULL, -- 0: Chưa ký 1: Đã ký 2: Hủy ký
	CONSTRAINT ksk_kham_than_kinh_pkey PRIMARY KEY (id)
);

CREATE TABLE ksk_kham_than_tiet_nieu (
	id uuid DEFAULT gen_random_uuid() NOT NULL,
	tiep_nhan_id uuid NOT NULL,
	benh_nhan_id uuid NOT NULL,
	ket_qua varchar(255) NULL,
	loai varchar(50) NULL,
	ngay_luu timestamp NULL,
	nguoi_luu varchar NULL,
	ngay_ky timestamp NULL,
	nguoi_ky varchar NULL,
	pt_loai varchar(50) NULL,
	pt_ly_do text NULL,
	pt_ngay_luu timestamp NULL,
	pt_nguoi_luu varchar NULL,
	pt_ngay_ky timestamp NULL,
	pt_nguoi_ky varchar NULL,
	bi_xoa int2 DEFAULT 0 NOT NULL,
	ngay_xoa timestamp NULL,
	nguoi_xoa varchar(100) NULL,
	ngay_tao timestamp DEFAULT CURRENT_TIMESTAMP NULL,
	nguoi_tao varchar NULL,
	ngay_cap_nhat timestamp NULL,
	nguoi_cap_nhat varchar NULL,
	ma_cskcb varchar NULL,
	nguoi_luu_id uuid NULL,
	nguoi_ky_id uuid NULL,
	pt_nguoi_luu_id uuid NULL,
	pt_nguoi_ky_id uuid NULL,
	khong_thuc_hien bool DEFAULT false NULL,
	phuong_thuc_ky varchar(50) NULL, -- VGCA,SMARTCA,SIGNHUB
	trang_thai_ky int2 DEFAULT 0 NULL, -- 0: Chưa ký 1: Đã ký 2: Hủy ký
	pt_phuong_thuc_ky varchar(50) NULL, -- VGCA,SMARTCA,SIGNHUB
	pt_trang_thai_ky int2 DEFAULT 0 NULL, -- 0: Chưa ký 1: Đã ký 2: Hủy ký
	CONSTRAINT ksk_kham_than_tiet_nieu_pkey PRIMARY KEY (id)
);

CREATE TABLE ksk_kham_the_luc (
	id uuid DEFAULT gen_random_uuid() NOT NULL,
	tiep_nhan_id uuid NOT NULL,
	benh_nhan_id uuid NOT NULL,
	thoi_gian_do timestamp NULL,
	chieu_cao numeric NULL,
	can_nang numeric NULL,
	bmi numeric NULL,
	ghi_chu varchar(255) NULL,
	mach varchar NULL,
	ha_tam_thu numeric NULL,
	ha_tam_truong numeric NULL,
	nhiet_do numeric NULL,
	nhip_tho numeric NULL,
	spo2 numeric NULL,
	thang_diem_dau numeric NULL,
	vong_bung numeric NULL,
	vong_dau numeric NULL,
	vong_nguc numeric NULL,
	tri_giac_id uuid NULL,
	ngay_luu timestamp NULL,
	nguoi_luu varchar NULL,
	ngay_ky timestamp NULL,
	nguoi_ky varchar NULL,
	pt_loai varchar(50) NULL,
	pt_ly_do text NULL,
	pt_ngay_luu timestamp NULL,
	pt_nguoi_luu varchar NULL,
	pt_ngay_ky timestamp NULL,
	pt_nguoi_ky varchar NULL,
	bi_xoa int2 DEFAULT 0 NOT NULL,
	ngay_xoa timestamp NULL,
	nguoi_xoa varchar(100) NULL,
	ngay_tao timestamp DEFAULT CURRENT_TIMESTAMP NULL,
	nguoi_tao varchar NULL,
	ngay_cap_nhat timestamp NULL,
	nguoi_cap_nhat varchar NULL,
	ma_cskcb varchar NULL,
	nguoi_luu_id uuid NULL,
	nguoi_ky_id uuid NULL,
	pt_nguoi_luu_id uuid NULL,
	pt_nguoi_ky_id uuid NULL,
	khong_thuc_hien bool DEFAULT false NULL,
	phuong_thuc_ky varchar(50) NULL, -- VGCA,SMARTCA,SIGNHUB
	trang_thai_ky int2 DEFAULT 0 NULL, -- 0: Chưa ký 1: Đã ký 2: Hủy ký
	pt_phuong_thuc_ky varchar(50) NULL, -- VGCA,SMARTCA,SIGNHUB
	pt_trang_thai_ky int2 DEFAULT 0 NULL, -- 0: Chưa ký 1: Đã ký 2: Hủy ký
	loai varchar(50) NULL,
	da_niem_mac varchar NULL,
	luoi_hoi_tho varchar NULL,
	tinh_than varchar NULL,
	khac varchar NULL,
	hach_ngoai_vi varchar NULL,
	tri_giac varchar NULL,
	CONSTRAINT ksk_kham_the_luc_pkey PRIMARY KEY (id),
	CONSTRAINT ksk_kham_the_luc_tiep_nhan_id_benh_nhan_id_key UNIQUE (tiep_nhan_id, benh_nhan_id)
);

CREATE TABLE ksk_kham_tieu_hoa (
	id uuid DEFAULT gen_random_uuid() NOT NULL,
	tiep_nhan_id uuid NOT NULL,
	benh_nhan_id uuid NOT NULL,
	ket_qua varchar(255) NULL,
	loai varchar(50) NULL,
	ngay_luu timestamp NULL,
	nguoi_luu varchar NULL,
	ngay_ky timestamp NULL,
	nguoi_ky varchar NULL,
	pt_loai varchar(50) NULL,
	pt_ly_do text NULL,
	pt_ngay_luu timestamp NULL,
	pt_nguoi_luu varchar NULL,
	pt_ngay_ky timestamp NULL,
	pt_nguoi_ky varchar NULL,
	bi_xoa int2 DEFAULT 0 NOT NULL,
	ngay_xoa timestamp NULL,
	nguoi_xoa varchar(100) NULL,
	ngay_tao timestamp DEFAULT CURRENT_TIMESTAMP NULL,
	nguoi_tao varchar NULL,
	ngay_cap_nhat timestamp NULL,
	nguoi_cap_nhat varchar NULL,
	ma_cskcb varchar NULL,
	nguoi_luu_id uuid NULL,
	nguoi_ky_id uuid NULL,
	pt_nguoi_luu_id uuid NULL,
	pt_nguoi_ky_id uuid NULL,
	khong_thuc_hien bool DEFAULT false NULL,
	phuong_thuc_ky varchar(50) NULL, -- VGCA,SMARTCA,SIGNHUB
	trang_thai_ky int2 DEFAULT 0 NULL, -- 0: Chưa ký 1: Đã ký 2: Hủy ký
	pt_phuong_thuc_ky varchar(50) NULL, -- VGCA,SMARTCA,SIGNHUB
	pt_trang_thai_ky int2 DEFAULT 0 NULL, -- 0: Chưa ký 1: Đã ký 2: Hủy ký
	CONSTRAINT ksk_kham_tieu_hoa_pkey PRIMARY KEY (id)
);

CREATE TABLE ksk_kham_tim_mach (
	id uuid DEFAULT gen_random_uuid() NOT NULL,
	tiep_nhan_id uuid NOT NULL,
	benh_nhan_id uuid NOT NULL,
	ket_qua varchar(255) NULL,
	loai varchar(50) NULL,
	ngay_luu timestamp NULL,
	nguoi_luu varchar NULL,
	ngay_ky timestamp NULL,
	nguoi_ky varchar NULL,
	pt_loai varchar(50) NULL,
	pt_ly_do text NULL,
	pt_ngay_luu timestamp NULL,
	pt_nguoi_luu varchar NULL,
	pt_ngay_ky timestamp NULL,
	pt_nguoi_ky varchar NULL,
	bi_xoa int2 DEFAULT 0 NOT NULL,
	ngay_xoa timestamp NULL,
	nguoi_xoa varchar(100) NULL,
	ngay_tao timestamp DEFAULT CURRENT_TIMESTAMP NULL,
	nguoi_tao varchar NULL,
	ngay_cap_nhat timestamp NULL,
	nguoi_cap_nhat varchar NULL,
	ma_cskcb varchar NULL,
	nguoi_luu_id uuid NULL,
	nguoi_ky_id uuid NULL,
	pt_nguoi_luu_id uuid NULL,
	pt_nguoi_ky_id uuid NULL,
	mach numeric NULL,
	ha_tam_thu numeric NULL,
	ha_tam_truong numeric NULL,
	khong_thuc_hien bool DEFAULT false NULL,
	phuong_thuc_ky varchar(50) NULL, -- VGCA,SMARTCA,SIGNHUB
	trang_thai_ky int2 DEFAULT 0 NULL, -- 0: Chưa ký 1: Đã ký 2: Hủy ký
	pt_phuong_thuc_ky varchar(50) NULL, -- VGCA,SMARTCA,SIGNHUB
	pt_trang_thai_ky int2 DEFAULT 0 NULL, -- 0: Chưa ký 1: Đã ký 2: Hủy ký
	nhip_tim varchar NULL,
	tan_so_tim varchar NULL,
	tieng_tim varchar NULL,
	ha varchar NULL,
	khac varchar NULL,
	dong_mach varchar NULL,
	tinh_mach varchar NULL,
	benh_tm varchar NULL,
	CONSTRAINT ksk_kham_tim_mach_pkey PRIMARY KEY (id)
);

CREATE TABLE ksk_kham_tuan_hoan (
	id uuid DEFAULT gen_random_uuid() NOT NULL,
	tiep_nhan_id uuid NOT NULL,
	benh_nhan_id uuid NOT NULL,
	ma_cskcb varchar(50) NULL,
	ket_qua varchar(255) NULL,
	loai varchar(50) NULL,
	ngay_luu timestamp NULL,
	nguoi_luu varchar NULL,
	ngay_ky timestamp NULL,
	nguoi_ky varchar NULL,
	pt_loai varchar(50) NULL,
	pt_ly_do text NULL,
	pt_ngay_luu timestamp NULL,
	pt_nguoi_luu varchar NULL,
	pt_ngay_ky timestamp NULL,
	pt_nguoi_ky varchar NULL,
	bi_xoa int2 DEFAULT 0 NOT NULL,
	ngay_xoa timestamp NULL,
	nguoi_xoa varchar(100) NULL,
	ngay_tao timestamp DEFAULT CURRENT_TIMESTAMP NULL,
	nguoi_tao varchar NULL,
	ngay_cap_nhat timestamp NULL,
	nguoi_cap_nhat varchar NULL,
	nguoi_luu_id uuid NULL,
	nguoi_ky_id uuid NULL,
	pt_nguoi_luu_id uuid NULL,
	pt_nguoi_ky_id uuid NULL,
	khong_thuc_hien bool DEFAULT false NULL,
	phuong_thuc_ky varchar(50) NULL, -- VGCA,SMARTCA,SIGNHUB
	trang_thai_ky int2 DEFAULT 0 NULL, -- 0: Chưa ký 1: Đã ký 2: Hủy ký
	pt_phuong_thuc_ky varchar(50) NULL, -- VGCA,SMARTCA,SIGNHUB
	pt_trang_thai_ky int2 DEFAULT 0 NULL, -- 0: Chưa ký 1: Đã ký 2: Hủy ký
	CONSTRAINT ksk_kham_tuan_hoan_pkey PRIMARY KEY (id)
);

CREATE TABLE lich_su_chuyen_doi_tuong (
	id uuid DEFAULT gen_random_uuid() NOT NULL,
	ma_cskcb varchar(100) NULL, -- Mã cơ sở khám chữa bệnh
	nguoi_chuyen_ma varchar(100) NOT NULL, -- Người thực hiện chuyển BHYT
	doi_tuong_ma varchar(100) NOT NULL, -- Đối tượng chuyển
	thoi_gian_chuyen timestamp DEFAULT CURRENT_TIMESTAMP NOT NULL, -- Thời gian chuyển BHYT
	benh_nhan_ma varchar(100) NOT NULL, -- Mã bệnh nhân
	ghi_chu varchar(500) NOT NULL, -- Ghi chú
	bi_xoa int2 DEFAULT 0 NOT NULL, -- Bị xóa(0: Không; 1: Có )
	ngay_tao timestamp DEFAULT now() NOT NULL, -- Ngày tạo
	nguoi_tao varchar(100) NOT NULL, -- Người tạo
	ngay_cap_nhat timestamp DEFAULT now() NOT NULL, -- Ngày cập nhật
	nguoi_cap_nhat varchar(100) NOT NULL, -- Người cập nhật
	ngay_xoa timestamp NULL, -- Ngày xóa
	nguoi_xoa varchar(100) NULL, -- Người xóa
	doi_tuong_ma_cu varchar(100) NULL,
	CONSTRAINT lich_su_chuyen_doi_tuong_pkey PRIMARY KEY (id)
);

CREATE TABLE lich_su_tra_cuu_bhyt (
	id uuid DEFAULT gen_random_uuid() NOT NULL,
	ma_cskcb varchar(100) NOT NULL,
	ma_the varchar(100) NOT NULL,
	thoi_gian_kiem_tra timestamp NOT NULL,
	noi_dung_kiem_tra jsonb NULL,
	CONSTRAINT lich_su_tra_cuu_bhyt_pkey PRIMARY KEY (id)
);

CREATE TABLE lis_chi_so_may_xet_nghiem (
	ma_chi_so varchar(25) NOT NULL, -- Mã chỉ số
	ten_chi_so varchar(255) NOT NULL, -- Tên chỉ số
	su_dung bool NULL, -- Sử dụng
	id uuid DEFAULT gen_random_uuid() NOT NULL, -- Key của bảng
	ngay_tao timestamp DEFAULT now() NOT NULL, -- Ngày tạo
	nguoi_tao varchar(100) DEFAULT 'system'::character varying NOT NULL, -- Người tạo
	ngay_cap_nhat timestamp DEFAULT now() NOT NULL, -- Ngày cập nhật
	nguoi_cap_nhat varchar(100) DEFAULT 'system'::character varying NOT NULL, -- Người cập nhật
	bi_xoa int2 DEFAULT 0 NULL, -- Bị xóa mềm
	ngay_xoa timestamp NULL, -- Ngày xóa mềm
	nguoi_xoa varchar(100) NULL, -- Người xóa mềm
	CONSTRAINT lis_chi_so_may_xet_nghiem_pk_id PRIMARY KEY (id)
);

CREATE TABLE lis_dm_abchvhb (
	ma varchar(100) NULL, -- Mã
	id uuid DEFAULT gen_random_uuid() NOT NULL, -- Key của bảng
	ngay_tao timestamp DEFAULT now() NOT NULL, -- Ngày tạo
	nguoi_tao varchar(100) DEFAULT 'system'::character varying NOT NULL, -- Người tạo
	ngay_cap_nhat timestamp DEFAULT now() NOT NULL, -- Ngày cập nhật
	nguoi_cap_nhat varchar(100) DEFAULT 'system'::character varying NOT NULL, -- Người cập nhật
	bi_xoa int2 DEFAULT 0 NULL, -- Bị xóa mềm
	ngay_xoa timestamp NULL, -- Ngày xóa mềm
	nguoi_xoa varchar(100) NULL, -- Người xóa mềm
	CONSTRAINT lis_dm_abchvhb_pkey PRIMARY KEY (id)
);

CREATE TABLE lis_dm_benh_pham (
	ma varchar(25) NOT NULL, -- Mã bệnh phẩm
	ten varchar(255) NOT NULL, -- Tên bệnh phẩm
	stt int4 NULL, -- Số thứ tự
	su_dung bool NULL, -- Trạng thái sử dụng
	id uuid DEFAULT gen_random_uuid() NOT NULL, -- Key của bảng
	ngay_tao timestamp DEFAULT now() NOT NULL, -- Ngày tạo
	nguoi_tao varchar(100) DEFAULT 'system'::character varying NOT NULL, -- Người tạo
	ngay_cap_nhat timestamp DEFAULT now() NOT NULL, -- Ngày cập nhật
	nguoi_cap_nhat varchar(100) DEFAULT 'system'::character varying NOT NULL, -- Người cập nhật
	bi_xoa int2 DEFAULT 0 NULL, -- Bị xóa mềm
	ngay_xoa timestamp NULL, -- Ngày xóa mềm
	nguoi_xoa varchar(100) NULL, -- Người xóa mềm
	CONSTRAINT lis_dm_benh_pham_pkey PRIMARY KEY (id)
);

CREATE TABLE lis_dm_dich_vu_benh_pham (
	ma_dich_vu uuid NOT NULL, -- Id của bảng dm_dich_vu_kt
	ma_benh_pham uuid NOT NULL, -- Id của bảng dm_benh_pham
	id uuid DEFAULT gen_random_uuid() NOT NULL, -- Key của bảng
	ngay_tao timestamp DEFAULT now() NOT NULL, -- Ngày tạo
	nguoi_tao varchar(100) DEFAULT 'system'::character varying NOT NULL, -- Người tạo
	ngay_cap_nhat timestamp DEFAULT now() NOT NULL, -- Ngày cập nhật
	nguoi_cap_nhat varchar(100) DEFAULT 'system'::character varying NOT NULL, -- Người cập nhật
	bi_xoa int2 DEFAULT 0 NULL, -- Bị xóa mềm
	ngay_xoa timestamp NULL, -- Ngày xóa mềm
	nguoi_xoa varchar(100) NULL, -- Người xóa mềm
	CONSTRAINT lis_dm_dich_vu_benh_pham_pkey PRIMARY KEY (id)
);

CREATE TABLE lis_dm_khang_sinh (
	ma_khang_sinh varchar(25) NOT NULL, -- Mã kháng sinh
	ten_khang_sinh varchar(255) NOT NULL, -- Tên kháng sinh
	ma_loai_khang_sinh varchar(100) NULL, -- Mã loại kháng sinh
	ma_nhom_khang_sinh varchar(100) NULL, -- Mã nhóm kháng sinh
	su_dung bool NULL, -- Trạng thái sử dụng
	id uuid DEFAULT gen_random_uuid() NOT NULL, -- Key của bảng
	ngay_tao timestamp DEFAULT now() NOT NULL, -- Ngày tạo
	nguoi_tao varchar(100) DEFAULT 'system'::character varying NOT NULL, -- Người tạo
	ngay_cap_nhat timestamp DEFAULT now() NOT NULL, -- Ngày cập nhật
	nguoi_cap_nhat varchar(100) DEFAULT 'system'::character varying NOT NULL, -- Người cập nhật
	bi_xoa int2 DEFAULT 0 NULL, -- Bị xóa mềm
	ngay_xoa timestamp NULL, -- Ngày xóa mềm
	nguoi_xoa varchar(100) NULL, -- Người xóa mềm
	CONSTRAINT lis_dm_khang_sinh_pkey PRIMARY KEY (id),
	CONSTRAINT lis_dm_khang_sinh_ten_khang_sinh_key UNIQUE (ten_khang_sinh)
);

CREATE TABLE lis_dm_khau_hao (
	ma_khau_hao varchar(25) NOT NULL, -- Mã khấu hao
	ten_khau_hao varchar(255) NOT NULL, -- Tên khấu hao
	ten_goi_khac varchar(255) NULL, -- Tên gọi khác
	ten_khong_dau varchar(255) NULL, -- Tên không dấu
	tg_khau_hao int4 NULL, -- TG khấu hao
	tg_canh_bao int4 NULL, -- TG cảnh báo
	ghi_chu varchar(255) NULL, -- Ghi chú
	su_dung bool NULL, -- Trạng thái sử dụng
	id uuid DEFAULT gen_random_uuid() NOT NULL, -- Key của bảng
	ngay_tao timestamp DEFAULT now() NOT NULL, -- Ngày tạo
	nguoi_tao varchar(100) DEFAULT 'system'::character varying NOT NULL, -- Người tạo
	ngay_cap_nhat timestamp DEFAULT now() NOT NULL, -- Ngày cập nhật
	nguoi_cap_nhat varchar(100) DEFAULT 'system'::character varying NOT NULL, -- Người cập nhật
	bi_xoa int2 DEFAULT 0 NULL, -- Bị xóa mềm
	ngay_xoa timestamp NULL, -- Ngày xóa mềm
	nguoi_xoa varchar(100) NULL, -- Người xóa mềm
	CONSTRAINT lis_dm_khau_hao_pkey PRIMARY KEY (id)
);

CREATE TABLE lis_dm_loai_khang_sinh (
	ma_loai_khang_sinh varchar(25) NOT NULL, -- Mã loại kháng sinh
	ten_loai_khang_sinh varchar(255) NULL, -- Tên loại kháng sinh
	ten_khong_dau varchar(255) NULL, -- Tên không dấu
	so_thu_tu int4 NULL, -- Số thứ tự
	su_dung bool NULL, -- Trạng thái sử dụng
	id uuid DEFAULT gen_random_uuid() NOT NULL, -- Key của bảng
	ngay_tao timestamp DEFAULT now() NOT NULL, -- Ngày tạo
	nguoi_tao varchar(100) DEFAULT 'system'::character varying NOT NULL, -- Người tạo
	ngay_cap_nhat timestamp DEFAULT now() NOT NULL, -- Ngày cập nhật
	nguoi_cap_nhat varchar(100) DEFAULT 'system'::character varying NOT NULL, -- Người cập nhật
	bi_xoa int2 DEFAULT 0 NULL, -- Bị xóa mềm
	ngay_xoa timestamp NULL, -- Ngày xóa mềm
	nguoi_xoa varchar(100) NULL, -- Người xóa mềm
	CONSTRAINT lis_dm_loai_khang_sinh_pkey PRIMARY KEY (id)
);

CREATE TABLE lis_dm_may_chi_so_con (
	ma_trang_thiet_bi varchar(25) NOT NULL, -- Mã trang thiết bị
	ma_chi_so_con varchar(25) NOT NULL, -- Mã chỉ số con
	can_tren_nam varchar(25) NULL, -- Cận trên nam
	can_duoi_nam varchar(25) NULL, -- Cận  dưới nam
	can_tren_nu varchar(25) NULL, -- Cận trên nữ
	can_duoi_nu varchar(25) NULL, -- Cận dưới nữ
	can_tren_tre_em varchar(25) NULL, -- Cận trên trẻ em
	can_duoi_tre_em varchar(25) NULL, -- Cận dưới trẻ em
	id uuid DEFAULT gen_random_uuid() NOT NULL, -- Key của bảng
	ngay_tao timestamp DEFAULT now() NOT NULL, -- Ngày tạo
	nguoi_tao varchar(100) DEFAULT 'system'::character varying NOT NULL, -- Người tạo
	ngay_cap_nhat timestamp DEFAULT now() NOT NULL, -- Ngày cập nhật
	nguoi_cap_nhat varchar(100) DEFAULT 'system'::character varying NOT NULL, -- Người cập nhật
	bi_xoa int2 DEFAULT 0 NULL, -- Bị xóa mềm
	ngay_xoa timestamp NULL, -- Ngày xóa mềm
	nguoi_xoa varchar(100) NULL, -- Người xóa mềm
	ma_chi_so_xet_nghiem varchar(25) NOT NULL,
	su_dung bool NULL,
	thu_tu_sap_xep varchar(25) NULL,
	thanh_phan_loinc varchar(25) NULL,
	thuoc_tinh_loinc varchar(25) NULL,
	thoi_gian_loinc date NULL,
	phuong_phap_loinc varchar(25) NULL,
	CONSTRAINT lis_dm_may_chi_so_con_pk_id PRIMARY KEY (id)
);

CREATE TABLE lis_dm_nhom_khang_sinh (
	ma_nhom_khang_sinh varchar(25) NOT NULL, -- Mã nhóm kháng sinh
	ma_nhom_khang_sinh_do varchar(25) NOT NULL, -- Mã nhóm kháng sinh map
	ten_nhom_khang_sinh varchar(255) NULL, -- Tên nhóm kháng sinh
	su_dung bool NULL, -- Trạng thái sử dụng
	so_thu_tu int4 NULL, -- Số thứ tự
	gia_tri_min int4 NULL, -- Giá trị nhỏ nhất
	gia_tri_max int4 NULL, -- Giá trị lớn nhất
	id uuid DEFAULT gen_random_uuid() NOT NULL, -- Key của bảng
	ngay_tao timestamp DEFAULT now() NOT NULL, -- Ngày tạo
	nguoi_tao varchar(100) DEFAULT 'system'::character varying NOT NULL, -- Người tạo
	ngay_cap_nhat timestamp DEFAULT now() NOT NULL, -- Ngày cập nhật
	nguoi_cap_nhat varchar(100) DEFAULT 'system'::character varying NOT NULL, -- Người cập nhật
	bi_xoa int2 DEFAULT 0 NULL, -- Bị xóa mềm
	ngay_xoa timestamp NULL, -- Ngày xóa mềm
	nguoi_xoa varchar(100) NULL, -- Người xóa mềm
	CONSTRAINT lis_dm_nhom_khang_sinh_pkey PRIMARY KEY (id)
);

CREATE TABLE lis_dm_nhom_vi_khuan (
	ma_nhom_vi_khuan varchar(100) NOT NULL, -- Mã nhóm vi khuẩn
	ten_nhom_vi_khuan varchar(255) NOT NULL, -- Tên nhóm vi khuẩn
	ghi_chu varchar(255) NULL, -- Ghi chú
	so_thu_tu int4 NULL, -- Số thứ tự
	su_dung bool NULL, -- Sử dụng
	id uuid DEFAULT gen_random_uuid() NOT NULL, -- Key của bảng
	ngay_tao timestamp DEFAULT now() NOT NULL, -- Ngày tạo
	nguoi_tao varchar(100) DEFAULT 'system'::character varying NOT NULL, -- Người tạo
	ngay_cap_nhat timestamp DEFAULT now() NOT NULL, -- Ngày cập nhật
	nguoi_cap_nhat varchar(100) DEFAULT 'system'::character varying NOT NULL, -- Người cập nhật
	bi_xoa int2 DEFAULT 0 NULL, -- Bị xóa mềm
	ngay_xoa timestamp NULL, -- Ngày xóa mềm
	nguoi_xoa varchar(100) NULL, -- Người xóa mềm
	CONSTRAINT lis_dm_nhom_vi_khuan_pkey PRIMARY KEY (id)
);

CREATE TABLE lis_dm_phan_loai_trang_thiet_bi (
	ma varchar(25) NOT NULL, -- Mã
	ten varchar(200) NOT NULL, -- Tên
	ten_viet_tat varchar(200) NULL, -- Tên viết tắt
	id uuid DEFAULT gen_random_uuid() NOT NULL, -- Key của bảng
	ngay_tao timestamp DEFAULT now() NOT NULL, -- Ngày tạo
	nguoi_tao varchar(100) DEFAULT 'system'::character varying NOT NULL, -- Người tạo
	ngay_cap_nhat timestamp DEFAULT now() NOT NULL, -- Ngày cập nhật
	nguoi_cap_nhat varchar(100) DEFAULT 'system'::character varying NOT NULL, -- Người cập nhật
	bi_xoa int2 DEFAULT 0 NULL, -- Bị xóa mềm
	ngay_xoa timestamp NULL, -- Ngày xóa mềm
	nguoi_xoa varchar(100) NULL, -- Người xóa mềm
	su_dung bool NULL, -- Trạng thái sử dụng
	CONSTRAINT lis_dm_phan_loai_trang_thiet_bi_pk_id PRIMARY KEY (id)
);

CREATE TABLE lis_dm_phuong_phap_nhuom (
	ma_phuong_phap_nhuom varchar(25) NOT NULL, -- Mã phương pháp nhuộm
	ten_phuong_phap_nhuom varchar(255) NULL, -- Tên phương pháp nhuộm
	ghi_chu varchar(255) NULL, -- Ghi chú
	ten_khong_dau varchar(255) NULL, -- Tên không dấu
	so_thu_tu int4 NULL, -- Số thứ tự
	su_dung bool NULL, -- Trạng thái sử dụng
	id uuid DEFAULT gen_random_uuid() NOT NULL, -- Key của bảng
	ngay_tao timestamp DEFAULT now() NOT NULL, -- Ngày tạo
	nguoi_tao varchar(100) DEFAULT 'system'::character varying NOT NULL, -- Người tạo
	ngay_cap_nhat timestamp DEFAULT now() NOT NULL, -- Ngày cập nhật
	nguoi_cap_nhat varchar(100) DEFAULT 'system'::character varying NOT NULL, -- Người cập nhật
	bi_xoa int2 DEFAULT 0 NULL, -- Bị xóa mềm
	ngay_xoa timestamp NULL, -- Ngày xóa mềm
	nguoi_xoa varchar(100) NULL, -- Người xóa mềm
	CONSTRAINT lis_dm_phuong_phap_nhuom_pkey PRIMARY KEY (id)
);

CREATE TABLE lis_dm_phuong_phap_xet_nghiem (
	ma varchar(25) NOT NULL, -- Mã phương pháp xét nghiệm
	ten varchar(255) NULL, -- Tên phương pháp xét nghiệm
	ghi_chu varchar(255) NULL, -- Ghi chú
	ten_khong_dau varchar(255) NULL, -- Tên không dấu
	so_thu_tu int4 NULL, -- Số thứ tự
	su_dung bool NULL, -- Trạng thái sử dụng
	id uuid DEFAULT gen_random_uuid() NOT NULL, -- Key của bảng
	ngay_tao timestamp DEFAULT now() NOT NULL, -- Ngày tạo
	nguoi_tao varchar(100) DEFAULT 'system'::character varying NOT NULL, -- Người tạo
	ngay_cap_nhat timestamp DEFAULT now() NOT NULL, -- Ngày cập nhật
	nguoi_cap_nhat varchar(100) DEFAULT 'system'::character varying NOT NULL, -- Người cập nhật
	bi_xoa int2 DEFAULT 0 NULL, -- Bị xóa mềm
	ngay_xoa timestamp NULL, -- Ngày xóa mềm
	nguoi_xoa varchar(100) NULL, -- Người xóa mềm
	CONSTRAINT lis_dm_phuong_phap_xet_nghiem_pkey PRIMARY KEY (id)
);

CREATE TABLE lis_dm_tg_bao_hanh (
	ma varchar(25) NOT NULL, -- Mã TG bảo hành
	ten varchar(255) NOT NULL, -- Tên TG bảo hành
	lan_bao_hanh int4 NULL, -- Lần bảo hành
	thoi_gian int4 NULL, -- Thời gian
	don_vi_thoi_gian varchar(50) NULL, -- Đơn vị thời gian
	tinh_tu int4 NULL, -- Tính từ
	mau_canh_bao varchar(255) NULL, -- Mẫu cảnh báo
	ghi_chu varchar(255) NULL, -- Ghi chú
	su_dung bool NULL, -- Trạng thái sử dụng
	id uuid DEFAULT gen_random_uuid() NOT NULL, -- Key của bảng
	ngay_tao timestamp DEFAULT now() NOT NULL, -- Ngày tạo
	nguoi_tao varchar(100) DEFAULT 'system'::character varying NOT NULL, -- Người tạo
	ngay_cap_nhat timestamp DEFAULT now() NOT NULL, -- Ngày cập nhật
	nguoi_cap_nhat varchar(100) DEFAULT 'system'::character varying NOT NULL, -- Người cập nhật
	bi_xoa int2 DEFAULT 0 NULL, -- Bị xóa mềm
	ngay_xoa timestamp NULL, -- Ngày xóa mềm
	nguoi_xoa varchar(100) NULL, -- Người xóa mềm
	CONSTRAINT lis_dm_tg_bao_hanh_pkey PRIMARY KEY (id)
);

CREATE TABLE lis_dm_vi_khuan (
	ma_vi_khuan varchar(25) NOT NULL, -- Mã vi khuẩn
	ten_vi_khuan varchar(255) NOT NULL, -- Tên vi khuẩn
	nhom_vi_khuan_id uuid NULL, -- Id bảng lis_dm_nhom_vi_khuan
	ghi_chu text NULL, -- Ghi chú
	so_thu_tu int4 NULL, -- Số thứ tự
	su_dung bool NULL, -- Sử dụng
	id uuid DEFAULT gen_random_uuid() NOT NULL, -- Key của bảng
	ngay_tao timestamp DEFAULT now() NOT NULL, -- Ngày tạo
	nguoi_tao varchar(100) DEFAULT 'system'::character varying NOT NULL, -- Người tạo
	ngay_cap_nhat timestamp DEFAULT now() NOT NULL, -- Ngày cập nhật
	nguoi_cap_nhat varchar(100) DEFAULT 'system'::character varying NOT NULL, -- Người cập nhật
	bi_xoa int2 DEFAULT 0 NULL, -- Bị xóa mềm
	ngay_xoa timestamp NULL, -- Ngày xóa mềm
	nguoi_xoa varchar(100) NULL, -- Người xóa mềm
	CONSTRAINT lis_dm_vi_khuan_pkey PRIMARY KEY (id)
);

CREATE TABLE lis_map_dm_vi_khuan_khang_sinh (
	vi_khuan_id uuid NOT NULL, -- Id bảng danh mục vi khuẩn
	khang_sinh_id uuid NOT NULL, -- Id danh mục kháng sinh
	id uuid DEFAULT gen_random_uuid() NOT NULL, -- Key của bảng
	ngay_tao timestamp DEFAULT now() NOT NULL, -- Ngày tạo
	nguoi_tao varchar(100) DEFAULT 'system'::character varying NOT NULL, -- Người tạo
	ngay_cap_nhat timestamp DEFAULT now() NOT NULL, -- Ngày cập nhật
	nguoi_cap_nhat varchar(100) DEFAULT 'system'::character varying NOT NULL, -- Người cập nhật
	bi_xoa int2 DEFAULT 0 NULL, -- Bị xóa mềm
	ngay_xoa timestamp NULL, -- Ngày xóa mềm
	nguoi_xoa varchar(100) NULL, -- Người xóa mềm
	CONSTRAINT lis_map_dm_vi_khuan_khang_sinh_pkey PRIMARY KEY (id)
);

CREATE TABLE loai_goi_kham (
	ma varchar NOT NULL,
	ten varchar NOT NULL,
	id uuid DEFAULT gen_random_uuid() NOT NULL, -- Key của bảng
	ngay_tao timestamp DEFAULT now() NOT NULL, -- Ngày tạo
	nguoi_tao varchar DEFAULT 'system'::character varying NOT NULL, -- Người tạo
	ngay_cap_nhat timestamp DEFAULT now() NOT NULL, -- Ngày cập nhật
	nguoi_cap_nhat varchar DEFAULT 'system'::character varying NOT NULL, -- Người cập nhật
	bi_xoa int2 DEFAULT 0 NULL, -- Bị xóa mềm
	ngay_xoa timestamp NULL, -- Ngày xóa mềm
	nguoi_xoa varchar NULL, -- Người xóa mềm
	CONSTRAINT loai_goi_kham_ma_key UNIQUE (ma),
	CONSTRAINT loai_goi_kham_pkey PRIMARY KEY (id)
);

CREATE TABLE loai_thau (
	nam varchar NULL,
	id uuid DEFAULT gen_random_uuid() NOT NULL,
	deleted_at timestamp NULL,
	created_at timestamp DEFAULT now() NOT NULL,
	created_by text NOT NULL,
	updated_at timestamp DEFAULT now() NOT NULL,
	updated_by text NOT NULL,
	CONSTRAINT loai_thau_pkey PRIMARY KEY (id)
);

CREATE TABLE lst_sid (
	id uuid DEFAULT gen_random_uuid() NOT NULL, -- Khóa chính
	ma_cskcb varchar(50) NULL, -- Mã cơ sở khám chữa bệnh
	ma_sid varchar(14) NULL, -- Mã sid được cấp phát (tự động/thủ công)
	tiep_nhan_id uuid NOT NULL, -- ID trong bảng tiep_nhan
	benh_nhan_id uuid NULL, -- ID trong bảng benh_nhan
	phieu_dich_vu_id uuid NOT NULL, -- ID trong bảng phieu_dich_vu
	dich_vu_kt_id uuid NULL, -- ID trong bảng dich_vu_kt
	thoi_gian_lay_mau timestamp(6) NULL, -- Thời gian lấy máu
	thoi_gian_nhan_mau timestamp(6) NULL, -- Thời gian nhận máu
	nguoi_lay_mau_id uuid NULL, -- id trong bảng dm_nhan_vien
	ngay_tao timestamp(6) DEFAULT CURRENT_TIMESTAMP NULL,
	nguoi_tao varchar(50) NULL,
	ngay_cap_nhat timestamp(6) NULL,
	nguoi_cap_nhat varchar(50) NULL,
	bi_xoa int2 DEFAULT 0 NULL,
	ngay_xoa timestamp(6) NULL,
	nguoi_xoa varchar(50) NULL,
	ky_thuat_vien_01_id uuid NULL, -- ID kỹ thuật viên 01
	ky_thuat_vien_02_id uuid NULL, -- ID kỹ thuật viên 02
	ky_thuat_vien_03_id uuid NULL, -- ID kỹ thuật viên 03
	CONSTRAINT lst_sid_pkey PRIMARY KEY (id)
);

CREATE TABLE luoc_do_phau_thuat (
	ma_mau_luoc_do varchar(100) NULL,
	ten_mau_luoc_do varchar(255) NULL,
	luoc_do_phau_thuat_ten_bac_si varchar(255) NULL,
	luoc_do_phau_thuat_ma_bac_si varchar(255) NULL,
	luoc_do_phau_thuat_bac_si_id uuid NULL,
	id uuid DEFAULT gen_random_uuid() NOT NULL,
	ma_cskcb varchar(20) NOT NULL,
	bi_xoa int2 DEFAULT 0 NOT NULL,
	ngay_xoa timestamp NULL,
	nguoi_xoa varchar(100) NULL,
	ngay_tao timestamp DEFAULT CURRENT_TIMESTAMP NOT NULL,
	nguoi_tao varchar(100) NOT NULL,
	ngay_cap_nhat timestamp NOT NULL,
	nguoi_cap_nhat varchar(100) NOT NULL,
	CONSTRAINT luoc_do_phau_thuat_pkey PRIMARY KEY (id)
);

CREATE TABLE map_chi_so_con_dich_vu_kt (
	id_dich_vu_kt uuid NOT NULL, -- ID của bảng dịch vụ kĩ thuật (dich_vu_kt)
	id_chi_so_con uuid NOT NULL, -- ID của bảng chỉ số con (dmc_chi_so_con_xet_nghiem)
	id uuid DEFAULT gen_random_uuid() NOT NULL, -- Key của bảng
	ngay_tao timestamp DEFAULT now() NOT NULL, -- Ngày tạo
	nguoi_tao varchar(100) DEFAULT 'system'::character varying NOT NULL, -- Người tạo
	ngay_cap_nhat timestamp DEFAULT now() NOT NULL, -- Ngày cập nhật
	nguoi_cap_nhat varchar(100) DEFAULT 'system'::character varying NOT NULL, -- Người cập nhật
	bi_xoa int2 DEFAULT 0 NULL, -- Bị xóa mềm
	ngay_xoa timestamp NULL, -- Ngày xóa mềm
	nguoi_xoa varchar(100) NULL, -- Người xóa mềm
	an_chi_so_con bool DEFAULT false NOT NULL,
	ds_cau_hinh text NULL,
	CONSTRAINT map_chi_so_con_dich_vu_kt_pk_id PRIMARY KEY (id)
);

CREATE TABLE map_goi_dich_vu_dich_vu (
	id uuid DEFAULT gen_random_uuid() NOT NULL,
	goi_id uuid NOT NULL,
	dichvu_id uuid NOT NULL,
	so_luong numeric NOT NULL,
	cap_gia_id uuid NULL, -- Link FK id dm_gia_tt_xuat
	don_gia numeric NOT NULL,
	thanh_tien numeric NOT NULL,
	ti_le numeric NOT NULL,
	don_gia_phan_bo numeric NOT NULL,
	thanh_tien_phan_bo numeric NOT NULL,
	khoa_thuc_hien_id uuid NULL,
	phong_thuc_hien_id uuid NULL,
	gui_ngoai int2 NULL,
	ma_cskcb varchar(10) NOT NULL,
	ngay_tao timestamp DEFAULT CURRENT_TIMESTAMP NOT NULL,
	nguoi_tao varchar(100) NULL,
	nhom_dich_vu_id uuid NOT NULL,
	csyt_thuc_hien_id uuid NULL,
	CONSTRAINT map_goi_dich_vu_dich_vu_goi_id_dichvu_id_key UNIQUE (goi_id, dichvu_id),
	CONSTRAINT map_goi_dich_vu_dich_vu_pkey PRIMARY KEY (id)
);

CREATE TABLE map_hoi_dong_ksk_goi_kham (
	id uuid DEFAULT gen_random_uuid() NOT NULL,
	hoi_dong_id uuid NOT NULL,
	goi_kham_id uuid NOT NULL,
	ma_cskcb varchar(10) NOT NULL,
	ngay_tao timestamp DEFAULT CURRENT_TIMESTAMP NOT NULL,
	nguoi_tao varchar(100) NULL,
	CONSTRAINT map_hoi_dong_ksk_goi_kham_hoi_dong_id_goi_kham_id_key UNIQUE (hoi_dong_id, goi_kham_id),
	CONSTRAINT map_hoi_dong_ksk_goi_kham_pkey PRIMARY KEY (id)
);

CREATE TABLE map_hoi_dong_ksk_khoa_phong (
	id uuid DEFAULT gen_random_uuid() NOT NULL,
	hoi_dong_id uuid NOT NULL,
	khoa_id uuid NOT NULL,
	phong_id uuid NOT NULL,
	ngay_tao timestamp NULL,
	nguoi_tao varchar NULL,
	ma_cskcb varchar(10) NULL,
	CONSTRAINT map_hoi_dong_ksk_khoa_phong_hoi_dong_id_khoa_id_phong_id_key UNIQUE (hoi_dong_id, khoa_id, phong_id),
	CONSTRAINT map_hoi_dong_ksk_khoa_phong_pkey PRIMARY KEY (id)
);

CREATE TABLE map_hoi_dong_ksk_nhan_vien (
	id uuid DEFAULT gen_random_uuid() NOT NULL,
	hoi_dong_id uuid NOT NULL,
	nhan_vien_id uuid NOT NULL,
	vai_tro_id uuid NOT NULL,
	bac_si_ket_luan int2 NULL,
	hinh_thuc_ky_id uuid NULL,
	hoat_dong int2 NULL,
	ma_cskcb varchar(10) NOT NULL,
	ngay_tao timestamp DEFAULT CURRENT_TIMESTAMP NOT NULL,
	nguoi_tao varchar(100) NULL,
	CONSTRAINT map_hoi_dong_ksk_nhan_vien_nhan_vien_id_hoi_dong_id_key UNIQUE (nhan_vien_id, hoi_dong_id),
	CONSTRAINT map_hoi_dong_ksk_nhan_vien_pkey PRIMARY KEY (id)
);

CREATE TABLE map_hop_dong_ksk_dich_vu (
	id uuid DEFAULT gen_random_uuid() NOT NULL,
	hop_dong_id uuid NOT NULL,
	goi_dich_vu_id uuid NOT NULL,
	dich_vu_id uuid NOT NULL,
	khoa_thuc_hien_id uuid NULL,
	phong_thuc_hien_id uuid NULL,
	ma_cskcb varchar(10) NOT NULL,
	ngay_tao timestamp DEFAULT CURRENT_TIMESTAMP NOT NULL,
	nguoi_tao varchar(100) NULL,
	so_luong numeric NOT NULL,
	cap_gia_id uuid NULL,
	don_gia numeric NOT NULL,
	thanh_tien numeric NOT NULL,
	don_gia_phan_bo numeric NOT NULL,
	thanh_tien_phan_bo numeric NOT NULL,
	ti_le numeric NULL,
	gui_ngoai int2 NOT NULL,
	phat_sinh int2 NOT NULL,
	csyt_thuc_hien_id uuid NULL,
	nhom_dich_vu_id uuid NOT NULL,
	CONSTRAINT map_hop_dong_ksk_dich_vu_hop_dong_id_goi_dich_vu_id_dich_vu_key UNIQUE (hop_dong_id, goi_dich_vu_id, dich_vu_id, nhom_dich_vu_id),
	CONSTRAINT map_hop_dong_ksk_dich_vu_pkey PRIMARY KEY (id)
);

CREATE TABLE map_hop_dong_ksk_khach_hang (
	id uuid DEFAULT gen_random_uuid() NOT NULL,
	hop_dong_id uuid NOT NULL,
	benh_nhan_ksk_id uuid NOT NULL,
	tiep_nhan_id uuid NULL,
	dot_dieu_tri_id uuid NULL,
	ma_cskcb varchar(10) NOT NULL,
	ngay_tao timestamp DEFAULT CURRENT_TIMESTAMP NOT NULL,
	nguoi_tao varchar(100) NULL,
	goi_kham_id uuid NOT NULL,
	benh_nhan_id uuid NULL,
	CONSTRAINT map_hop_dong_ksk_khach_hang_pkey PRIMARY KEY (id)
);

CREATE TABLE map_ke_hoach_ksk_csyt_thuc_hien (
	id uuid DEFAULT gen_random_uuid() NOT NULL,
	ke_hoach_id uuid NOT NULL,
	csyt_thuc_hien_id uuid NOT NULL,
	CONSTRAINT map_ke_hoach_ksk_csyt_thuc_hi_ke_hoach_id_csyt_thuc_hien_id_key UNIQUE (ke_hoach_id, csyt_thuc_hien_id),
	CONSTRAINT map_ke_hoach_ksk_csyt_thuc_hien_pkey PRIMARY KEY (id)
);

CREATE TABLE map_ke_hoach_ksk_dich_vu (
	id uuid DEFAULT gen_random_uuid() NOT NULL,
	ke_hoach_id uuid NOT NULL,
	goi_dich_vu_id uuid NOT NULL,
	dich_vu_id uuid NOT NULL,
	khoa_thuc_hien_id uuid NULL,
	phong_thuc_hien_id uuid NULL,
	ma_cskcb varchar(10) NOT NULL,
	so_luong numeric NOT NULL,
	cap_gia_id uuid NOT NULL,
	don_gia numeric NOT NULL,
	thanh_tien numeric NOT NULL,
	nhom_dich_vu_id uuid NOT NULL,
	ngay_tao timestamp DEFAULT CURRENT_TIMESTAMP NOT NULL,
	nguoi_tao varchar(100) NOT NULL,
	phat_sinh int2 DEFAULT 0 NOT NULL, -- =0 -> Dịch vụ trong gói¶=1 -> Dịch vụ ngoài gói
	ma_nhom_dich_vu varchar NULL,
	ten_nhom_dich_vu varchar NULL,
	ma_dich_vu varchar NULL,
	ten_dich_vu varchar NULL,
	ti_le numeric NULL,
	ten_cap_gia varchar NULL,
	CONSTRAINT map_ke_hoach_ksk_dich_vu_ke_hoach_id_goi_dich_vu_id_dich_vu_key UNIQUE (ke_hoach_id, goi_dich_vu_id, dich_vu_id, nhom_dich_vu_id),
	CONSTRAINT map_ke_hoach_ksk_dich_vu_pkey PRIMARY KEY (id)
);

CREATE TABLE map_ke_hoach_ksk_dm_khoa (
	ke_hoach_ksk_id uuid NOT NULL,
	dm_khoa_id uuid NOT NULL,
	is_tong_hop int2 NULL,
	id uuid DEFAULT gen_random_uuid() NOT NULL,
	ngay_tao timestamp DEFAULT now() NOT NULL,
	nguoi_tao varchar(100) DEFAULT 'system'::character varying NOT NULL,
	ngay_cap_nhat timestamp DEFAULT now() NOT NULL,
	nguoi_cap_nhat varchar(100) DEFAULT 'system'::character varying NOT NULL,
	CONSTRAINT map_ke_hoach_ksk_dm_khoa_pkey PRIMARY KEY (id)
);

CREATE TABLE map_ke_hoach_ksk_doi_tuong_kham (
	id uuid DEFAULT gen_random_uuid() NOT NULL,
	ke_hoach_id uuid NOT NULL,
	doi_tuong_kham_id uuid NOT NULL,
	CONSTRAINT map_ke_hoach_ksk_doi_tuong_kh_ke_hoach_id_doi_tuong_kham_id_key UNIQUE (ke_hoach_id, doi_tuong_kham_id),
	CONSTRAINT map_ke_hoach_ksk_doi_tuong_kham_pkey PRIMARY KEY (id)
);

CREATE TABLE map_ke_hoach_ksk_goi_dich_vu (
	id uuid DEFAULT gen_random_uuid() NOT NULL,
	ke_hoach_id uuid NOT NULL,
	goi_dich_vu_id uuid NOT NULL,
	so_luong_khach_hang numeric NOT NULL,
	ma_goi_dich_vu varchar NULL,
	ten_goi_dich_vu varchar NULL,
	gia_goi_dich_vu numeric NULL,
	loai_goi_id uuid NULL,
	ten_loai_goi varchar NULL,
	CONSTRAINT map_ke_hoach_ksk_goi_dich_vu_ke_hoach_id_goi_dich_vu_id_key UNIQUE (ke_hoach_id, goi_dich_vu_id),
	CONSTRAINT map_ke_hoach_ksk_goi_dich_vu_pkey PRIMARY KEY (id)
);

CREATE TABLE map_ke_hoach_ksk_phan_loai_kham (
	id uuid DEFAULT gen_random_uuid() NOT NULL,
	ke_hoach_id uuid NOT NULL,
	phan_loai_kham_id uuid NOT NULL,
	CONSTRAINT map_ke_hoach_ksk_phan_loai_kh_ke_hoach_id_phan_loai_kham_id_key UNIQUE (ke_hoach_id, phan_loai_kham_id),
	CONSTRAINT map_ke_hoach_ksk_phan_loai_kham_pkey PRIMARY KEY (id)
);

CREATE TABLE map_ket_qua_vi_sinh_chung_vi_sinh (
	id uuid DEFAULT gen_random_uuid() NOT NULL, -- Khóa chính
	ket_qua_vi_sinh_nuoi_cay_id uuid NOT NULL, -- ID trong bảng ket_qua_vi_sinh_nuoi_cay
	vi_khuan_id uuid NOT NULL, -- ID trong bảng lis_dm_vi_khuan
	ma_vi_khuan varchar(50) NULL, -- Mã vi khuẩn trong bảng lis_dm_vi_khuan
	ten_vi_khuan varchar(255) NULL, -- Tên vi khuẩn trong bảng lis_dm_vi_khuan
	nhom_vi_khuan_id varchar(50) NULL, -- ID trong bảng lis_dm_ma_vi_khuan
	ma_nhom_vi_khuan varchar(50) NULL, -- Mã nhóm vi khuẩn trong bảng lis_dm_vi_khuan
	duong_tinh bool NULL, -- true: dương tính, false: âm tính
	mo_ta text NULL, -- Mô tả
	ket_qua text NULL, -- Kết luận
	ngay_duyet timestamp(6) NOT NULL, -- Ngày duyệt kết quả
	nguoi_duyet text NOT NULL, -- Người duyệt kết quả
	ngay_tao timestamp(6) DEFAULT CURRENT_TIMESTAMP NOT NULL, -- Ngày tạo bản ghi
	nguoi_tao text NOT NULL, -- Người tạo bản ghi
	ngay_sua timestamp(6) NULL, -- Ngày sửa bản ghi
	nguoi_sua text NULL, -- Người sửa bản ghi
	bi_xoa int2 DEFAULT 0 NULL, -- 0: chưa xóa, 1: đã xóa
	ngay_xoa timestamp(6) NULL, -- Ngày xóa bản ghi
	nguoi_xoa text NULL, -- Người xóa bản ghi
	CONSTRAINT map_ket_qua_vi_sinh_chung_vi_sinh_pkey PRIMARY KEY (id)
);

CREATE TABLE map_ma_nhom_dich_vu_ma_config (
	ma_nhom_dich_vu_id uuid NOT NULL,
	ma_nhom_dich_vu_config varchar(100) NOT NULL,
	mo_ta text NULL,
	id uuid DEFAULT gen_random_uuid() NOT NULL, -- Key của bảng
	ngay_tao timestamp DEFAULT now() NOT NULL, -- Ngày tạo
	nguoi_tao varchar(100) DEFAULT 'system'::character varying NOT NULL, -- Người tạo
	ngay_cap_nhat timestamp DEFAULT now() NOT NULL, -- Ngày cập nhật
	nguoi_cap_nhat varchar(100) DEFAULT 'system'::character varying NOT NULL, -- Người cập nhật
	bi_xoa int2 DEFAULT 0 NULL, -- Bị xóa mềm
	ngay_xoa timestamp NULL, -- Ngày xóa mềm
	nguoi_xoa varchar(100) NULL, -- Người xóa mềm
	CONSTRAINT map_ma_nhom_dich_vu_ma_config_pk_id PRIMARY KEY (id)
);

CREATE TABLE map_ma_phong_dia_chi (
	ma varchar NOT NULL,
	dia_chi varchar NULL,
	phan_khu_id uuid NULL,
	CONSTRAINT map_ma_phong_dia_chi_pkey PRIMARY KEY (ma)
);

CREATE TABLE map_sid_phieu_dich_vu_chi_tiet (
	id uuid DEFAULT gen_random_uuid() NOT NULL, -- Khóa chính
	ma_cskcb varchar(50) NOT NULL, -- Mã cơ sở khám chữa bệnh
	sid_id uuid NOT NULL, -- ID trong bảng lst_sid
	phieu_dich_vu_chi_tiet_id uuid NOT NULL, -- ID trong bảng phieu_dich_vu_chi_tiet
	dich_vu_id uuid NOT NULL, -- ID trong bảng dm_dich_vu_kt
	ten_dich_vu varchar(255) NULL, -- Tên dịch vụ trong bảng dm_dich_vu_kt
	ngay_tao timestamp(6) DEFAULT CURRENT_TIMESTAMP NULL, -- Ngày tạo bản ghi
	nguoi_tao text NULL, -- Người tạo bản ghi
	ngay_sua timestamp(6) NULL, -- Ngày sửa bản ghi
	nguoi_sua text NULL, -- Người sửa bản ghi
	bi_xoa int2 DEFAULT 0 NULL, -- 0: chưa xóa, 1: đã xóa
	ngay_xoa timestamp(6) NULL, -- Ngày xóa bản ghi
	nguoi_xoa text NULL, -- Người xóa bản ghi
	ngay_cap_nhat timestamp NULL, -- Ngày cập nhật bản ghi
	nguoi_cap_nhat varchar(100) NULL, -- Người cập nhật bản ghi
	ma_sid varchar(14) NULL, -- mã sid đã cấp phát
	CONSTRAINT map_sid_phieu_dich_vu_chi_tiet_pkey PRIMARY KEY (id)
);

CREATE TABLE minh_test_106 (
	noi_test_01 uuid NULL, -- test01
	noi_test_02 uuid NULL, -- test 02
	noi_test_03 varchar NULL, -- test03
	id uuid DEFAULT gen_random_uuid() NOT NULL, -- Key của bảng
	ngay_tao timestamp DEFAULT now() NOT NULL, -- Ngày tạo
	nguoi_tao varchar(100) DEFAULT 'system'::character varying NOT NULL, -- Người tạo
	ngay_cap_nhat timestamp DEFAULT now() NOT NULL, -- Ngày cập nhật
	nguoi_cap_nhat varchar(100) DEFAULT 'system'::character varying NOT NULL, -- Người cập nhật
	bi_xoa int2 DEFAULT 0 NULL, -- Bị xóa mềm
	ngay_xoa timestamp NULL, -- Ngày xóa mềm
	nguoi_xoa varchar(100) NULL, -- Người xóa mềm
	CONSTRAINT minh_test_106_pkey PRIMARY KEY (id)
);

CREATE TABLE minh_test_dm (
	id uuid DEFAULT gen_random_uuid() NOT NULL, -- Key của bảng
	ngay_tao timestamp DEFAULT now() NOT NULL, -- Ngày tạo
	nguoi_tao varchar(100) DEFAULT 'system'::character varying NOT NULL, -- Người tạo
	ngay_cap_nhat timestamp DEFAULT now() NOT NULL, -- Ngày cập nhật
	nguoi_cap_nhat varchar(100) DEFAULT 'system'::character varying NOT NULL, -- Người cập nhật
	bi_xoa int2 DEFAULT 0 NULL, -- Bị xóa mềm
	ngay_xoa timestamp NULL, -- Ngày xóa mềm
	nguoi_xoa varchar(100) NULL, -- Người xóa mềm
	ma_doi_tuong varchar NULL, -- Mã đối tượng
	ten_doi_tuong varchar NULL, -- Tên đối tượng
	so_luong int4 NULL, -- Số lượng
	don_gia numeric NULL, -- Đơn giá
	tien_truoc_thue numeric NULL, -- Tiền trước thuế
	thue_suat int2 NULL, -- Thuế suất (%)
	tien_thue numeric NULL, -- Tiền thuế
	tien_sau_thue numeric NULL, -- Tiền sau thuế
	gia_tri_nho_nhat int4 NULL, -- Giá trị nhỏ nhất
	gia_tri_lon_nhat int4 NULL, -- Giá trị lớn nhất
	phong_id uuid NULL, -- Phòng
	loai_doi_tuong varchar NULL, -- Loại đối tượng
	ly_do_khac text NULL, -- Lý do khác
	trang_thai_su_dung int2 NULL, -- Trạng thái sử dụng
	ngay_ngung date NULL, -- Ngày ngừng
	ngay_bat_dau date NULL, -- Ngày bắt đầu
	ngay_ket_thuc date NULL, -- Ngày kết thúc
	email_lien_he varchar NULL, -- Email liên hệ
	so_dien_thoai varchar NULL, -- Số điện thoại
	ma_so_thue bpchar(1) NULL, -- Mã số thuế
	mat_khau varchar NULL, -- Mật khẩu
	xac_nhan_mat_khau varchar NULL, -- Xác nhận mật khẩu
	so_thu_tu int4 NULL, -- Số thứ tự
	dong_y_dieu_khoan bool NULL, -- Đồng ý điều khoản
	ghi_chu text NULL, -- Ghi chú
	username varchar(200) NOT NULL, -- Tài khoản
	"password" varchar(255) NOT NULL, -- password
	phong_ban_id uuid NULL, -- Phòng ban
	phong_b_id uuid NULL, -- phòng b
	phong_c_id uuid NULL, -- phòng c
	CONSTRAINT minh_test_dm_pkey PRIMARY KEY (id)
);

CREATE TABLE minh_test_mapping (
	dt_mapping varchar(25) NULL,
	loai_gia_mapping uuid NULL,
	dmc_chuc_danh uuid NULL,
	id uuid DEFAULT gen_random_uuid() NOT NULL, -- Key của bảng
	ngay_tao timestamp DEFAULT now() NOT NULL, -- Ngày tạo
	nguoi_tao varchar(100) DEFAULT 'system'::character varying NOT NULL, -- Người tạo
	ngay_cap_nhat timestamp DEFAULT now() NOT NULL, -- Ngày cập nhật
	nguoi_cap_nhat varchar(100) DEFAULT 'system'::character varying NOT NULL, -- Người cập nhật
	bi_xoa int2 DEFAULT 0 NULL, -- Bị xóa mềm
	ngay_xoa timestamp NULL, -- Ngày xóa mềm
	nguoi_xoa varchar(100) NULL, -- Người xóa mềm
	CONSTRAINT minh_test_mapping_pkey PRIMARY KEY (id)
);

CREATE TABLE minh_test_mapping_3 (
	noi_bang_01 uuid NULL, -- Nối bảng 01
	noi_bang_02 uuid NULL, -- Nối bảng 03
	noi_bang_03 uuid NULL, -- Nối bảng 03
	id uuid DEFAULT gen_random_uuid() NOT NULL, -- Key của bảng
	ngay_tao timestamp DEFAULT now() NOT NULL, -- Ngày tạo
	nguoi_tao varchar(100) DEFAULT 'system'::character varying NOT NULL, -- Người tạo
	ngay_cap_nhat timestamp DEFAULT now() NOT NULL, -- Ngày cập nhật
	nguoi_cap_nhat varchar(100) DEFAULT 'system'::character varying NOT NULL, -- Người cập nhật
	bi_xoa int2 DEFAULT 0 NULL, -- Bị xóa mềm
	ngay_xoa timestamp NULL, -- Ngày xóa mềm
	nguoi_xoa varchar(100) NULL, -- Người xóa mềm
	CONSTRAINT minh_test_mapping_3_pkey PRIMARY KEY (id)
);

CREATE TABLE minh_test_menu (
	test01 uuid NULL,
	test02 uuid NULL,
	test03 varchar NULL,
	id uuid DEFAULT gen_random_uuid() NOT NULL, -- Key của bảng
	ngay_tao timestamp DEFAULT now() NOT NULL, -- Ngày tạo
	nguoi_tao varchar(100) DEFAULT 'system'::character varying NOT NULL, -- Người tạo
	ngay_cap_nhat timestamp DEFAULT now() NOT NULL, -- Ngày cập nhật
	nguoi_cap_nhat varchar(100) DEFAULT 'system'::character varying NOT NULL, -- Người cập nhật
	bi_xoa int2 DEFAULT 0 NULL, -- Bị xóa mềm
	ngay_xoa timestamp NULL, -- Ngày xóa mềm
	nguoi_xoa varchar(100) NULL, -- Người xóa mềm
	CONSTRAINT minh_test_menu_pkey PRIMARY KEY (id)
);

CREATE TABLE minh_test_menu_2 (
	test_01 uuid NULL,
	test_02 uuid NULL,
	test_03 varchar NULL,
	id uuid DEFAULT gen_random_uuid() NOT NULL, -- Key của bảng
	ngay_tao timestamp DEFAULT now() NOT NULL, -- Ngày tạo
	nguoi_tao varchar(100) DEFAULT 'system'::character varying NOT NULL, -- Người tạo
	ngay_cap_nhat timestamp DEFAULT now() NOT NULL, -- Ngày cập nhật
	nguoi_cap_nhat varchar(100) DEFAULT 'system'::character varying NOT NULL, -- Người cập nhật
	bi_xoa int2 DEFAULT 0 NULL, -- Bị xóa mềm
	ngay_xoa timestamp NULL, -- Ngày xóa mềm
	nguoi_xoa varchar(100) NULL, -- Người xóa mềm
	CONSTRAINT minh_test_menu_2_pkey PRIMARY KEY (id)
);

CREATE TABLE minh_test_mp2 (
	noi_bang_test_1 uuid NULL, -- Nối bảng test 1
	noi_bang_test_2 uuid NULL, -- Nối bảng test 2
	noi_bang_test_3 varchar NULL, -- Nối bảng test 3
	id uuid DEFAULT gen_random_uuid() NOT NULL, -- Key của bảng
	ngay_tao timestamp DEFAULT now() NOT NULL, -- Ngày tạo
	nguoi_tao varchar(100) DEFAULT 'system'::character varying NOT NULL, -- Người tạo
	ngay_cap_nhat timestamp DEFAULT now() NOT NULL, -- Ngày cập nhật
	nguoi_cap_nhat varchar(100) DEFAULT 'system'::character varying NOT NULL, -- Người cập nhật
	bi_xoa int2 DEFAULT 0 NULL, -- Bị xóa mềm
	ngay_xoa timestamp NULL, -- Ngày xóa mềm
	nguoi_xoa varchar(100) NULL, -- Người xóa mềm
	CONSTRAINT minh_test_mp2_pkey PRIMARY KEY (id)
);

CREATE TABLE mock_lich_su_kcb_bhyt (
	id uuid DEFAULT gen_random_uuid() NOT NULL,
	ma_the varchar(10) NOT NULL,
	ma_ho_so varchar(10) NOT NULL,
	ma_cskcb varchar(10) NOT NULL,
	ngay_vao timestamp NULL,
	ngay_ra timestamp NULL,
	tinh_trang varchar(1) NULL,
	kq_dieu_tri varchar(1) NULL,
	ly_do_vv varchar(1) NULL,
	temp_1 text NULL,
	temp_2 text NULL,
	temp_3 text NULL,
	temp_4 text NULL,
	temp_5 text NULL,
	CONSTRAINT mock_lich_su_kcb_bhyt_ma_the_ma_ho_so_key UNIQUE (ma_the, ma_ho_so),
	CONSTRAINT mock_lich_su_kcb_bhyt_pkey PRIMARY KEY (id)
);

CREATE TABLE mock_thong_tin_cskcb_bhyt (
	id uuid DEFAULT gen_random_uuid() NOT NULL,
	maketqua varchar(10) NULL, -- 200  Nhận thông tin thành công,  205  Sai định dạng tham số truyền vào,  206  Không tìm thấy thông tin cơ sở,  401  Lỗi xác thực tài khoản,  500  Lỗi server
	message text NULL,
	macskcb varchar(5) NOT NULL, -- Mã cơ sở khám chữa bện
	ten varchar(100) NULL, -- Tên cơ sở
	hang varchar(1) NULL, -- Hạng bệnh viện (0-đặc biệt, 1-hạng 1,2-hạng 2,3-hạng3,4- hạng 4,5-chưa phân hạng)
	tuyen varchar(1) NULL, -- Tuyến chuyên môn kỹ thuật (1-trung ương,2-tỉnh,3- huyện,4-xã)
	diachi text NULL, -- Địa chỉ
	tenchuquan varchar(100) NULL, -- Tên cơ quan chủ quản
	ngaysua date NULL, --  Ngày sửa
	macha varchar(5) NULL, -- Mã cơ sở cha
	hieuluc int2 DEFAULT 1 NULL, -- Hiệu lực (1 - có,0 - không)
	ngayngunghoatdong date NULL, -- Ngày ngừng hoạt động
	matinh varchar(2) NULL, -- Mã tỉnh
	mahuyen varchar(5) NULL, -- Mã huyệ
	CONSTRAINT mock_thong_tin_cskcb_bhyt_pkey PRIMARY KEY (id)
);

CREATE TABLE mock_thong_tin_the_bhyt (
	id uuid DEFAULT gen_random_uuid() NOT NULL,
	ma_ket_qua varchar NULL,
	ghi_chu text NULL,
	ma_the varchar(15) NOT NULL,
	ho_ten varchar(50) NOT NULL,
	ngay_sinh date NOT NULL,
	gioi_tinh varchar(5) NOT NULL,
	dia_chi text NULL,
	ma_dkbd varchar(5) NULL,
	cq_bhxh text NULL,
	gt_the_tu date NOT NULL,
	gt_the_den date NOT NULL,
	ma_kv varchar(5) NULL,
	ngay_du_5_nam date NULL,
	ma_so_bhxh varchar(15) NULL,
	ma_the_cu varchar(15) NULL,
	ma_the_moi varchar(15) NULL,
	gt_the_tu_moi date NULL,
	gt_the_den_moi date NULL,
	ma_dkbd_moi varchar(5) NULL,
	ten_dkbc_moi text NULL,
	CONSTRAINT mock_thong_tin_the_bhyt_ma_the_key UNIQUE (ma_the),
	CONSTRAINT mock_thong_tin_the_bhyt_pkey PRIMARY KEY (id)
);

CREATE TABLE nhom_loai_vat_tu_y_te (
	ma varchar NULL,
	nhom_vat_tu_y_te_id int4 NULL,
	loai_vat_tu_y_te_id int4 NULL,
	ten_loai_vat_tu_y_te varchar NULL,
	su_dung bool NULL,
	id uuid DEFAULT gen_random_uuid() NOT NULL, -- Key của bảng
	ngay_tao timestamp DEFAULT now() NOT NULL, -- Ngày tạo
	nguoi_tao varchar(100) DEFAULT 'system'::character varying NOT NULL, -- Người tạo
	ngay_cap_nhat timestamp DEFAULT now() NOT NULL, -- Ngày cập nhật
	nguoi_cap_nhat varchar(100) DEFAULT 'system'::character varying NOT NULL, -- Người cập nhật
	bi_xoa int2 DEFAULT 0 NULL, -- Bị xóa mềm
	ngay_xoa timestamp NULL, -- Ngày xóa mềm
	nguoi_xoa varchar(100) NULL, -- Người xóa mềm
	CONSTRAINT nhom_loai_vat_tu_y_te_pkey PRIMARY KEY (id)
);

CREATE TABLE nhom_nguoi_dung_user_map (
	nhom_nguoi_dung_id uuid NOT NULL,
	user_id uuid NOT NULL,
	id uuid DEFAULT gen_random_uuid() NOT NULL,
	ngay_tao timestamp DEFAULT now() NOT NULL,
	nguoi_tao varchar(100) DEFAULT 'system'::character varying NOT NULL,
	ngay_cap_nhat timestamp DEFAULT now() NOT NULL,
	nguoi_cap_nhat varchar(100) DEFAULT 'system'::character varying NOT NULL,
	bi_xoa int2 DEFAULT 0 NULL,
	ngay_xoa timestamp NULL,
	nguoi_xoa varchar(100) NULL,
	mo_ta varchar(500) NULL,
	CONSTRAINT nhom_nguoi_dung_user_map_pk_id PRIMARY KEY (id)
);

CREATE TABLE nhom_ung_dung_application_map (
	nhom_ung_dung_id uuid NOT NULL, -- Nhóm ứng dụng ID
	application_id uuid NOT NULL, -- Application ID
	id uuid DEFAULT gen_random_uuid() NOT NULL, -- Key của bảng
	ngay_tao timestamp DEFAULT now() NOT NULL, -- Ngày tạo
	nguoi_tao varchar(100) DEFAULT 'system'::character varying NOT NULL, -- Người tạo
	ngay_cap_nhat timestamp DEFAULT now() NOT NULL, -- Ngày cập nhật
	nguoi_cap_nhat varchar(100) DEFAULT 'system'::character varying NOT NULL, -- Người cập nhật
	bi_xoa int2 DEFAULT 0 NULL, -- Bị xóa mềm
	ngay_xoa timestamp NULL, -- Ngày xóa mềm
	nguoi_xoa varchar(100) NULL, -- Người xóa mềm
	CONSTRAINT nhom_ung_dung_application_map_pkey PRIMARY KEY (id)
);

CREATE TABLE nhom_ung_dung_danh_muc_map (
	id uuid DEFAULT gen_random_uuid() NOT NULL, -- UID của bảng
	id_danh_muc uuid NOT NULL, -- ID danh mục (ad_table)
	id_nhom_ung_dung uuid NOT NULL, -- ID nhóm ứng dụng (dmc_nhom_ung_dung)
	nguoi_tao varchar NULL, -- Người tạo
	ngay_tao timestamp DEFAULT now() NULL, -- Ngày tạo
	nguoi_cap_nhat varchar NULL, -- Người cập nhật
	ngay_cap_nhat timestamp DEFAULT now() NULL, -- Ngày cập nhật
	CONSTRAINT nhom_ung_dung_danh_muc_map_id_danh_muc_key UNIQUE (id_danh_muc),
	CONSTRAINT nhom_ung_dung_danh_muc_map_pkey PRIMARY KEY (id)
);

CREATE TABLE nhom_ung_dung_nhom_danh_muc_map (
	id uuid DEFAULT gen_random_uuid() NOT NULL, -- UID của bảng
	id_nhom_danh_muc uuid NOT NULL, -- ID nhóm danh mục (ad_table_group)
	id_nhom_ung_dung uuid NOT NULL, -- ID nhóm ứng dụng (dmc_nhom_ung_dung)
	nguoi_tao varchar NULL, -- Người tạo
	ngay_tao timestamp DEFAULT now() NULL, -- Ngày tạo
	nguoi_cap_nhat varchar NULL, -- Người cập nhật
	ngay_cap_nhat timestamp DEFAULT now() NULL, -- Ngày cập nhật
	CONSTRAINT nhom_ung_dung_nhom_danh_muc_map_id_nhom_danh_muc_key UNIQUE (id_nhom_danh_muc),
	CONSTRAINT nhom_ung_dung_nhom_danh_muc_map_pkey PRIMARY KEY (id)
);

CREATE TABLE org_organization (
	org_id varchar(50) NOT NULL,
	hospital_code varchar(50) NULL,
	org_code_bhyt varchar(50) NULL,
	org_name varchar(255) NULL,
	org_tel varchar(50) NULL,
	org_address varchar(255) NULL,
	parent_id varchar(50) NULL,
	CONSTRAINT org_organization_pkey PRIMARY KEY (org_id)
);

CREATE TABLE p_total (
	count int8 NULL
);

CREATE TABLE pb_da_lieu (
	tham_chieu_dm_khoa uuid NULL,
	tham_chieu_dm_phong bigserial NOT NULL,
	id uuid DEFAULT gen_random_uuid() NOT NULL, -- Key của bảng
	ngay_tao timestamp DEFAULT now() NOT NULL, -- Ngày tạo
	nguoi_tao varchar(100) DEFAULT 'system'::character varying NOT NULL, -- Người tạo
	ngay_cap_nhat timestamp DEFAULT now() NOT NULL, -- Ngày cập nhật
	nguoi_cap_nhat varchar(100) DEFAULT 'system'::character varying NOT NULL, -- Người cập nhật
	bi_xoa int2 DEFAULT 0 NULL, -- Bị xóa mềm
	ngay_xoa timestamp NULL, -- Ngày xóa mềm
	nguoi_xoa varchar(100) NULL, -- Người xóa mềm
	CONSTRAINT pb_da_lieu_pkey PRIMARY KEY (id)
);

CREATE TABLE phieu_dich_vu (
	id uuid DEFAULT gen_random_uuid() NOT NULL,
	tiep_nhan_id uuid NOT NULL,
	ma_cskcb varchar NULL,
	ma_tiep_nhan varchar NULL,
	stt int4 NULL,
	so_phieu_chi_dinh varchar NULL,
	barcode varchar NULL,
	ma_loai_phieu varchar NULL,
	report_in varchar NULL,
	ma_khoa_chi_dinh varchar NULL,
	ma_phong_chi_dinh varchar NULL,
	ma_nguoi_tao varchar NULL,
	ma_bac_si_chi_dinh varchar NULL,
	ngay_y_lenh timestamp NULL,
	ngay_thuc_hien_y_lenh timestamp NULL,
	ngay_kq timestamp NULL,
	ma_khu_thuc_hien varchar NULL,
	ma_khoa_thuc_hien varchar NULL,
	ma_phong_thuc_hien varchar NULL,
	ma_lan_chi_dinh int4 NULL,
	idhash varchar NULL,
	trang_thai_ky_so int2 NULL,
	bi_xoa int2 DEFAULT 0 NOT NULL,
	ngay_xoa timestamp NULL,
	nguoi_xoa varchar(100) NULL,
	ngay_tao timestamp DEFAULT CURRENT_TIMESTAMP NULL,
	nguoi_tao varchar NULL,
	ngay_cap_nhat timestamp NULL,
	nguoi_cap_nhat varchar NULL,
	khoa_chi_dinh_id uuid NULL,
	phong_chi_dinh_id uuid NULL,
	khu_thuc_hien_id uuid NULL,
	khoa_thuc_hien_id uuid NULL,
	phong_thuc_hien_id uuid NULL,
	is_ksk int2 DEFAULT 0 NOT NULL,
	ma_nhom_dich_vu varchar(50) NULL,
	hososohoa_id uuid NULL,
	bac_si_chi_dinh_id uuid NULL,
	benh_an_id uuid NULL,
	luu_tru_id uuid NULL,
	CONSTRAINT phieu_dich_vu_pkey PRIMARY KEY (id)
);

CREATE TABLE phieu_dich_vu_chi_tiet (
	id uuid DEFAULT gen_random_uuid() NOT NULL,
	ma_cskcb varchar NULL,
	ma_tiep_nhan varchar NULL,
	tiep_nhan_id uuid NOT NULL,
	ma_phieu_dich_vu varchar NULL,
	phieu_dich_vu_id uuid NOT NULL,
	ma_dich_vu varchar NULL,
	dich_vu_id uuid NULL,
	ma_nhom_dich_vu varchar NULL,
	so_luong numeric NULL,
	gia_tt_id uuid NULL,
	ten_dich_vu varchar NULL,
	ten_bhyt varchar NULL,
	ma_bac_si_chi_dinh varchar NULL,
	ngay_chi_dinh timestamp NULL,
	gui_thuc_hien int2 DEFAULT 0 NULL,
	ma_cskcb_thuc_hien varchar NULL,
	trang_thai_dich_vu varchar NULL,
	trang_thai_thuc_hien varchar NULL,
	bi_xoa int2 DEFAULT 0 NOT NULL,
	ngay_xoa timestamp NULL,
	nguoi_xoa varchar(100) NULL,
	ngay_tao timestamp DEFAULT CURRENT_TIMESTAMP NULL,
	nguoi_tao varchar NULL,
	ngay_cap_nhat timestamp NULL,
	nguoi_cap_nhat varchar NULL,
	thu_tien_sau int2 NULL,
	duoc_phep_thuc_hien int2 NULL,
	bhyt_tu_dong_tien int2 NULL,
	khan_cap int2 NULL,
	khong_thu_tien int2 NULL,
	benh_pham_id uuid NULL,
	ma_benh_pham varchar(50) NULL,
	ten_benh_pham varchar(50) NULL,
	ghi_chu text NULL,
	ngay_du_kien timestamp NULL,
	goi_dich_vu_id uuid NULL,
	ten_goi_dich_vu varchar(100) NULL,
	phac_do_id uuid NULL,
	ten_phac_do varchar(100) NULL,
	chan_doan_id uuid NULL,
	ma_chan_doan varchar(50) NULL,
	ten_chan_doan varchar(100) NULL,
	huyet text NULL,
	is_ksk int2 DEFAULT 0 NULL,
	duyet_pttt int2 DEFAULT 0 NULL,
	trang_thai_day_pacs varchar(50) NULL, -- trạng thái đẩy pacs
	bac_si_chi_dinh_id uuid NULL,
	kham_benh_id uuid NULL,
	benh_an_id uuid NULL,
	trang_thai_duyet_mo int4 DEFAULT 1 NULL,
	tyle_thanh_toan_dich_vu_id uuid NULL,
	ma_loai_xe varchar(50) NULL,
	dinh_muc_nhien_lieu numeric NULL,
	ma_vung_chi_dinh varchar(50) NULL,
	so_km numeric NULL,
	to_dieu_tri_id uuid NULL,
	mo_ta text NULL,
	CONSTRAINT phieu_dich_vu_chi_tiet_pkey PRIMARY KEY (id)
);

CREATE TABLE pl_application (
	id uuid DEFAULT gen_random_uuid() NOT NULL,
	"type" varchar(255) NULL,
	code varchar(100) NOT NULL,
	"name" varchar(255) NULL,
	description varchar(500) NULL,
	context_path varchar(255) NULL,
	hoat_dong int2 DEFAULT 1 NOT NULL,
	bi_xoa int2 DEFAULT 0 NOT NULL,
	ma_cskcb varchar(50) NULL,
	nguoi_tao varchar(100) NULL,
	ngay_tao timestamp DEFAULT CURRENT_TIMESTAMP NULL,
	nguoi_cap_nhat varchar(100) NULL,
	ngay_cap_nhat timestamp DEFAULT CURRENT_TIMESTAMP NULL,
	nguoi_xoa varchar(100) NULL,
	ngay_xoa timestamp NULL,
	service_name varchar(255) NULL,
	CONSTRAINT pl_application_code_type_key UNIQUE (code, type),
	CONSTRAINT pl_application_pkey PRIMARY KEY (id)
);

CREATE TABLE pl_application_feature (
	id uuid DEFAULT gen_random_uuid() NOT NULL,
	parent_id uuid NULL,
	application_id uuid NOT NULL,
	original_feature_id uuid NULL,
	is_original int2 DEFAULT 0 NOT NULL,
	is_platform int2 DEFAULT 0 NOT NULL,
	code varchar(100) NOT NULL,
	"name" varchar(255) NULL,
	description varchar(500) NULL,
	"path" varchar(255) NULL,
	hidden bool DEFAULT false NOT NULL,
	display_order int4 DEFAULT 10 NOT NULL,
	metadata jsonb NULL,
	hoat_dong int2 DEFAULT 1 NOT NULL,
	bi_xoa int2 DEFAULT 0 NOT NULL,
	ma_cskcb varchar(50) NULL,
	nguoi_tao varchar(100) NULL,
	ngay_tao timestamp DEFAULT CURRENT_TIMESTAMP NULL,
	nguoi_cap_nhat varchar(100) NULL,
	ngay_cap_nhat timestamp DEFAULT CURRENT_TIMESTAMP NULL,
	nguoi_xoa varchar(100) NULL,
	ngay_xoa timestamp NULL,
	phan_he_id uuid NULL, -- Thông tin phân hệ dùng để lọc
	CONSTRAINT pl_application_feature_pkey PRIMARY KEY (id),
	CONSTRAINT pl_application_feature_unique UNIQUE (code, application_id)
);

CREATE TABLE pl_application_feature_bk (
	id uuid NULL,
	parent_id uuid NULL,
	application_id uuid NULL,
	original_feature_id uuid NULL,
	is_original int2 NULL,
	is_platform int2 NULL,
	code varchar(100) NULL,
	"name" varchar(255) NULL,
	description varchar(500) NULL,
	"path" varchar(255) NULL,
	hidden bool NULL,
	display_order int4 NULL,
	metadata jsonb NULL,
	hoat_dong int2 NULL,
	bi_xoa int2 NULL,
	ma_cskcb varchar(50) NULL,
	nguoi_tao varchar(100) NULL,
	ngay_tao timestamp NULL,
	nguoi_cap_nhat varchar(100) NULL,
	ngay_cap_nhat timestamp NULL,
	nguoi_xoa varchar(100) NULL,
	ngay_xoa timestamp NULL,
	phan_he_id uuid NULL
);

CREATE TABLE pl_application_feature_function (
	id uuid DEFAULT gen_random_uuid() NOT NULL,
	"type" varchar(100) DEFAULT 'BUTTON'::character varying NULL,
	ma varchar(50) NOT NULL,
	operation_id varchar(255) NULL,
	ma_cskcb varchar(50) NULL,
	ten varchar(500) NOT NULL,
	description text NULL,
	"method" varchar(10) NULL,
	"path" varchar(500) NULL,
	metadata jsonb NULL,
	hoat_dong int2 DEFAULT 1 NOT NULL,
	bi_xoa int2 DEFAULT 0 NOT NULL,
	nguoi_tao varchar(100) NULL,
	ngay_tao timestamp DEFAULT CURRENT_TIMESTAMP NULL,
	nguoi_cap_nhat varchar(100) NULL,
	ngay_cap_nhat timestamp DEFAULT CURRENT_TIMESTAMP NULL,
	nguoi_xoa varchar(100) NULL,
	ngay_xoa timestamp NULL,
	pl_application_id uuid NULL, -- Nếu giá trị khác null thì function sẽ được handle cụ thể bởi 1 application X (ví dụ 1 api của BE), khi đó các application_feature (thường là FE) của application Y, trỏ để function này sẽ được sử dụng function này. Nhưng handle logic là application X.
	remote_url varchar NULL,
	component varchar NULL,
	CONSTRAINT pl_application_feature_functi_pl_application_id_type_ma_pat_key UNIQUE (pl_application_id, type, ma, path),
	CONSTRAINT pl_application_feature_function_pkey PRIMARY KEY (id)
);

CREATE TABLE pl_application_feature_function_config (
	id uuid DEFAULT gen_random_uuid() NOT NULL,
	function_id uuid NOT NULL,
	ten varchar NOT NULL,
	description varchar NULL,
	config jsonb NULL,
	action_type varchar NULL,
	"target" varchar NULL,
	next_node uuid NULL,
	prev_node uuid NULL,
	ngay_tao timestamp DEFAULT now() NOT NULL,
	nguoi_tao varchar DEFAULT 'system'::character varying NOT NULL,
	ngay_cap_nhat timestamp DEFAULT now() NOT NULL,
	nguoi_cap_nhat varchar DEFAULT 'system'::character varying NOT NULL,
	bi_xoa int2 DEFAULT 0 NULL,
	ngay_xoa timestamp NULL,
	nguoi_xoa varchar NULL,
	action_type_fe varchar NULL,
	target_fe varchar NULL,
	CONSTRAINT pl_application_feature_function_config_pkey PRIMARY KEY (id)
);

CREATE TABLE pl_application_feature_function_mapping (
	id uuid DEFAULT gen_random_uuid() NOT NULL,
	application_feature_id uuid NOT NULL,
	function_id uuid NOT NULL,
	nguoi_tao varchar(100) NOT NULL,
	ngay_tao timestamp DEFAULT CURRENT_TIMESTAMP NOT NULL,
	CONSTRAINT pl_application_feature_functi_application_feature_id_functi_key UNIQUE (application_feature_id, function_id),
	CONSTRAINT pl_application_feature_function_mapping_pkey PRIMARY KEY (id)
);

CREATE TABLE pl_application_feature_param_key (
	id uuid DEFAULT gen_random_uuid() NOT NULL,
	pl_app_feature_id uuid NOT NULL,
	ma varchar(255) NOT NULL,
	ten varchar(255) NOT NULL,
	mo_ta varchar(500) NOT NULL,
	bi_xoa int2 DEFAULT 0 NOT NULL,
	nguoi_tao varchar(100) DEFAULT 'system'::character varying NOT NULL,
	ngay_tao timestamp DEFAULT CURRENT_TIMESTAMP NULL,
	nguoi_cap_nhat varchar(100) NULL,
	ngay_cap_nhat timestamp DEFAULT CURRENT_TIMESTAMP NULL,
	nguoi_xoa varchar(100) NULL,
	ngay_xoa timestamp NULL,
	CONSTRAINT pl_application_feature_param_key_pkey PRIMARY KEY (id),
	CONSTRAINT pl_application_feature_param_key_unique UNIQUE (pl_app_feature_id, ma)
);

CREATE TABLE pl_application_feature_param_value (
	id uuid DEFAULT gen_random_uuid() NOT NULL,
	pl_app_feature_id uuid NOT NULL,
	pl_app_feature_key_id uuid NOT NULL,
	value varchar(255) NOT NULL,
	mo_ta varchar(300) NOT NULL,
	bi_xoa int2 DEFAULT 0 NOT NULL,
	nguoi_tao varchar(100) DEFAULT 'system'::character varying NOT NULL,
	ngay_tao timestamp DEFAULT CURRENT_TIMESTAMP NULL,
	nguoi_cap_nhat varchar(100) NULL,
	ngay_cap_nhat timestamp DEFAULT CURRENT_TIMESTAMP NULL,
	nguoi_xoa varchar(100) NULL,
	ngay_xoa timestamp NULL,
	CONSTRAINT pl_application_feature_param__pl_app_feature_id_pl_app_feat_key UNIQUE (pl_app_feature_id, pl_app_feature_key_id),
	CONSTRAINT pl_application_feature_param_value_pkey PRIMARY KEY (id)
);

CREATE TABLE pl_application_versioning (
	id uuid DEFAULT gen_random_uuid() NOT NULL, -- ID duy nhất của phiên bản
	application_id uuid NOT NULL, -- ID của ứng dụng sở hữu phiên bản này
	"version" varchar(15) DEFAULT 'v0.0.1'::character varying NOT NULL, -- Số phiên bản (vd: v1.0.0)
	description varchar(500) NULL, -- Mô tả về phiên bản này
	changelog text NULL, -- Nhật ký thay đổi của phiên bản
	bi_xoa int2 DEFAULT 0 NOT NULL,
	nguoi_phat_hanh varchar(100) NULL, -- Người phát hành phiên bản
	ngay_phat_hanh timestamp NULL, -- Thời gian phát hành phiên bản
	nguoi_tao varchar(100) NULL, -- Người tạo bản ghi
	ngay_tao timestamp DEFAULT CURRENT_TIMESTAMP NULL, -- Thời gian tạo bản ghi
	nguoi_cap_nhat varchar(100) NULL, -- Người cập nhật cuối cùng
	ngay_cap_nhat timestamp DEFAULT CURRENT_TIMESTAMP NULL, -- Thời gian cập nhật cuối cùng
	nguoi_xoa varchar(100) NULL,
	ngay_xoa timestamp NULL,
	CONSTRAINT pl_application_versioning_pkey PRIMARY KEY (id)
);

CREATE TABLE pl_bao_cao (
	id uuid DEFAULT gen_random_uuid() NOT NULL,
	ma_cskcb varchar NULL,
	ten varchar(255) NOT NULL,
	duong_dan text NULL,
	ma_report varchar(255) NOT NULL,
	ma_hreport varchar(255) NOT NULL,
	ma_xml varchar NOT NULL,
	ma_loai_ky varchar(25) NULL,
	loai_bao_cao int2 DEFAULT 1 NULL, -- 1 - Báo cáo ; 2 - Sub báo cáo
	pl_nhom_bao_cao_id uuid NOT NULL,
	thoi_gian_xem jsonb DEFAULT '[]'::jsonb NULL,
	mo_ta text NULL,
	dong_dau_don_vi int2 DEFAULT 0 NULL,
	bat_buoc_ky int2 DEFAULT 0 NULL,
	su_dung int2 DEFAULT 1 NULL,
	nguoi_tao varchar NULL,
	ngay_tao timestamp DEFAULT now() NULL,
	nguoi_cap_nhat varchar NULL,
	ngay_cap_nhat timestamp DEFAULT now() NULL,
	bi_xoa int2 DEFAULT 0 NULL,
	nguoi_xoa varchar NULL,
	ngay_xoa timestamp NULL,
	ma_phuong_thuc_ky varchar NULL,
	ham_lay_du_lieu text NULL,
	loai_phieu int2 NULL, -- Loại phiếu: 04 = Báo cáo, 05 = Dược
	ma_loai_phieu varchar(25) NULL,
	ma_phuong_thuc_huy_ky varchar NULL,
	ky_theo_du_lieu_tao_phieu int2 DEFAULT 1 NULL,
	ds_ma_don_vi _varchar DEFAULT ARRAY[]::character varying[] NULL,
	CONSTRAINT pl_bao_cao_pkey PRIMARY KEY (id)
);

CREATE TABLE pl_bao_cao_con_mapping (
	id uuid DEFAULT gen_random_uuid() NOT NULL,
	ten varchar NULL,
	pl_bao_cao_cha_id uuid NOT NULL,
	pl_bao_cao_con_id uuid NOT NULL,
	nguoi_tao varchar NULL,
	ngay_tao timestamp DEFAULT now() NULL,
	ghi_chu varchar NULL,
	ngay_cap_nhat timestamp NULL,
	nguoi_cap_nhat varchar NULL,
	bi_xoa int4 DEFAULT 0 NULL,
	nguoi_xoa varchar NULL,
	ngay_xoa timestamp NULL,
	ma_cskcb varchar NULL,
	CONSTRAINT pl_bao_cao_con_mapping_pkey PRIMARY KEY (id)
);

CREATE TABLE pl_cau_hinh_rule_nghiep_vu (
	ma_rule varchar(100) NOT NULL,
	ten_rule varchar(255) NULL,
	ma_cskcb varchar(5) NULL, -- Mã CSKCB
	phien_ban int4 DEFAULT 1 NOT NULL, -- Phiên bản rule
	noi_dung_rule jsonb NOT NULL, -- Nội dung rule dạng JSON
	mo_ta text NULL, -- Mô tả
	tu_ngay_hieu_luc date NULL, -- Ngày bắt đầu hiệu lực
	den_ngay_hieu_luc date NULL, -- Ngày kết thúc hiệu lực
	co_hieu_luc int2 DEFAULT 1 NOT NULL, -- Trạng thái hiệu lực
	id uuid DEFAULT gen_random_uuid() NOT NULL, -- Key của bảng
	ngay_tao timestamp DEFAULT now() NOT NULL, -- Ngày tạo
	nguoi_tao varchar(100) DEFAULT 'system'::character varying NOT NULL, -- Người tạo
	ngay_cap_nhat timestamp DEFAULT now() NOT NULL, -- Ngày cập nhật
	nguoi_cap_nhat varchar(100) DEFAULT 'system'::character varying NOT NULL, -- Người cập nhật
	bi_xoa int2 DEFAULT 0 NULL, -- Bị xóa mềm
	ngay_xoa timestamp NULL, -- Ngày xóa mềm
	nguoi_xoa varchar(100) NULL, -- Người xóa mềm
	CONSTRAINT pl_cau_hinh_rule_nghiep_vu_pk_id PRIMARY KEY (id)
);

CREATE TABLE pl_cskcb (
	id uuid DEFAULT gen_random_uuid() NOT NULL,
	ma_pl_tenant varchar(50) NOT NULL,
	ma varchar(50) NOT NULL,
	ten varchar(50) NOT NULL,
	ma_tinh varchar(50) NOT NULL,
	ma_xa varchar(50) NOT NULL,
	ma_to_chuc_csyt varchar(50) NOT NULL,
	dia_chi_chi_tiet text NULL,
	ma_loai_hinh_to_chuc varchar(50) NULL,
	ma_hinh_thuc_to_chuc varchar(50) NULL,
	hoat_dong int4 DEFAULT 1 NOT NULL,
	bi_xoa int4 DEFAULT 0 NOT NULL,
	ngay_tao timestamp DEFAULT now() NOT NULL,
	nguoi_tao varchar(100) NOT NULL,
	ngay_cap_nhat timestamp DEFAULT now() NOT NULL,
	nguoi_cap_nhat varchar(100) NULL,
	ngay_xoa timestamp NULL,
	nguoi_xoa varchar(100) NULL,
	don_vi_chu_quan varchar NULL,
	so_dien_thoai varchar NULL,
	csytid int8 NULL,
	thu_truong_don_vi_id uuid NULL,
	is_khambhyt_ngoai_tru_trai_tuyen int2 DEFAULT 0 NULL,
	ngay_hieu_luc date NULL,
	logo text NULL,
	con_dau text NULL,
	CONSTRAINT pl_cskcb_ma_key UNIQUE (ma),
	CONSTRAINT pl_cskcb_pkey PRIMARY KEY (id)
);

CREATE TABLE pl_file (
	id uuid DEFAULT gen_random_uuid() NOT NULL, -- ID duy nhat cua file
	bucket_id uuid DEFAULT gen_random_uuid() NOT NULL, -- FK den pl_file_bucket
	ma_cskcb varchar(25) DEFAULT 'ALL'::character varying NOT NULL, -- Ma CSKCB phuc vu doi chieu/audit; NOT NULL DEFAULT 'ALL'. Ghi file: neu request maCskcb = 'ALL' thi resolve tu security context.
	file_name varchar(500) NOT NULL, -- Ten file da duoc luu tru
	original_name varchar(500) NULL, -- Ten file goc khi upload
	content_type varchar(100) NULL, -- MIME type cua file
	file_size int8 NULL, -- Kich thuoc file (byte)
	checksum_sha256 varchar(64) NULL, -- Checksum SHA-256
	description varchar(1500) NULL, -- Mo ta file
	storage_path varchar(1000) NOT NULL, -- Duong dan luu tru/object key
	storage_provider varchar(50) DEFAULT 'minio'::character varying NULL, -- Nha cung cap storage
	bucket_name varchar(100) NULL, -- Ten bucket (denormalized)
	is_public bool DEFAULT false NULL, -- File co truy cap cong khai hay khong
	uploaded_by varchar(100) NULL, -- Nguoi upload
	bi_xoa int2 DEFAULT 0 NOT NULL, -- Trang thai xoa mem: 0 = chua bi xoa, 1 = da bi xoa
	nguoi_tao varchar(100) NULL,
	ngay_tao timestamp DEFAULT CURRENT_TIMESTAMP NOT NULL,
	nguoi_cap_nhat varchar(100) NULL,
	ngay_cap_nhat timestamp DEFAULT CURRENT_TIMESTAMP NOT NULL,
	nguoi_xoa varchar(100) NULL,
	ngay_xoa timestamp NULL,
	upload_error int2 DEFAULT 0 NOT NULL, -- 0 = OK; 1 = upload to storage (MinIO/S3) failed. Used with bi_xoa=1: record hidden from lists, retry job can find by upload_error=1. Do not use bi_xoa=-1.
	entity_type varchar(100) NULL, -- 1-N owned: loại entity sở hữu file (tên bảng nghiệp vụ, vd. benh_nhan). NULL = N-N mode (dùng pl_file_attachment).
	entity_id uuid NULL, -- 1-N owned: UUID entity sở hữu. Luôn set cùng entity_type. NULL nếu N-N.
	metadata jsonb DEFAULT '{}'::jsonb NULL, -- Thông số metadata đính kèm
	hoat_dong int2 DEFAULT 1 NOT NULL, -- Trạng thái hoạt động
	relation_type varchar(50) NULL, -- Loại file/loại tài liệu: DOCUMENT/CCCD
	CONSTRAINT pl_file_pkey PRIMARY KEY (id, bucket_id)
);

CREATE TABLE pl_file_attachment (
	id uuid DEFAULT gen_random_uuid() NOT NULL, -- ID duy nhat cua attachment
	ma_cskcb varchar(25) DEFAULT 'ALL'::character varying NOT NULL, -- Ma CSKCB phuc vu doi chieu/audit; NOT NULL DEFAULT 'ALL'. Ke thua tu pl_file khi tao attachment.
	file_id uuid NOT NULL, -- FK den pl_file (cùng bucket_id cho composite FK).
	bucket_id uuid NOT NULL, -- Denormalized tu pl_file.bucket_id; bat buoc cho FK (file_id, bucket_id) -> pl_file(id, bucket_id).
	entity_type varchar(100) NOT NULL, -- Loại entity (benh_nhan, pl_application, ...); trùng với tên bảng/entity liên quan.
	entity_id uuid NOT NULL, -- ID entity nghiệp vụ (UUID); entity_type = tên bảng tương ứng
	display_order int4 DEFAULT 10 NULL, -- Thu tu hien thi
	display_name varchar(250) NULL, -- Ten hien thi attachment (tu API createAttachment).
	description varchar(1500) NULL, -- Mo ta attachment
	bi_xoa int2 DEFAULT 0 NOT NULL, -- Trang thai xoa mem: 0 = chua bi xoa, 1 = da bi xoa
	nguoi_tao varchar(100) NULL,
	ngay_tao timestamp DEFAULT CURRENT_TIMESTAMP NOT NULL,
	nguoi_cap_nhat varchar(100) NULL,
	ngay_cap_nhat timestamp DEFAULT CURRENT_TIMESTAMP NOT NULL,
	nguoi_xoa varchar(100) NULL,
	ngay_xoa timestamp NULL,
	CONSTRAINT pl_file_attachment_entity_type_entity_id_file_id_key UNIQUE (entity_type, entity_id, file_id),
	CONSTRAINT pl_file_attachment_pkey PRIMARY KEY (id, entity_type)
);

CREATE TABLE pl_file_attachment_default (
	id uuid DEFAULT gen_random_uuid() NOT NULL,
	ma_cskcb varchar(25) DEFAULT 'ALL'::character varying NOT NULL,
	file_id uuid NOT NULL,
	bucket_id uuid NOT NULL,
	entity_type varchar(100) NOT NULL,
	entity_id uuid NOT NULL,
	display_order int4 DEFAULT 10 NULL,
	display_name varchar(250) NULL,
	description varchar(1500) NULL,
	bi_xoa int2 DEFAULT 0 NOT NULL,
	nguoi_tao varchar(100) NULL,
	ngay_tao timestamp DEFAULT CURRENT_TIMESTAMP NOT NULL,
	nguoi_cap_nhat varchar(100) NULL,
	ngay_cap_nhat timestamp DEFAULT CURRENT_TIMESTAMP NOT NULL,
	nguoi_xoa varchar(100) NULL,
	ngay_xoa timestamp NULL,
	CONSTRAINT pl_file_attachment_default_entity_type_entity_id_file_id_key UNIQUE (entity_type, entity_id, file_id),
	CONSTRAINT pl_file_attachment_default_pkey PRIMARY KEY (id, entity_type)
);

CREATE TABLE pl_file_attachment_pl_application (
	id uuid DEFAULT gen_random_uuid() NOT NULL,
	ma_cskcb varchar(25) DEFAULT 'ALL'::character varying NOT NULL,
	file_id uuid NOT NULL,
	bucket_id uuid NOT NULL,
	entity_type varchar(100) NOT NULL,
	entity_id uuid NOT NULL,
	display_order int4 DEFAULT 10 NULL,
	display_name varchar(250) NULL,
	description varchar(1500) NULL,
	bi_xoa int2 DEFAULT 0 NOT NULL,
	nguoi_tao varchar(100) NULL,
	ngay_tao timestamp DEFAULT CURRENT_TIMESTAMP NOT NULL,
	nguoi_cap_nhat varchar(100) NULL,
	ngay_cap_nhat timestamp DEFAULT CURRENT_TIMESTAMP NOT NULL,
	nguoi_xoa varchar(100) NULL,
	ngay_xoa timestamp NULL,
	CONSTRAINT pl_file_attachment_pl_applica_entity_type_entity_id_file_id_key UNIQUE (entity_type, entity_id, file_id),
	CONSTRAINT pl_file_attachment_pl_application_pkey PRIMARY KEY (id, entity_type)
);

CREATE TABLE pl_file_bucket (
	id uuid DEFAULT gen_random_uuid() NOT NULL, -- ID duy nhat cua bucket
	bucket_name varchar(100) NOT NULL, -- Ten bucket/container (nhieu business_code co the trung bucket_name)
	display_name varchar(255) NULL, -- Ten hien thi cua bucket
	business_code varchar(100) NULL, -- Ma nghiep vu de resolve bucket (SERVICE_MODULE, TENANT, DOCUMENT,...)
	storage_provider varchar(50) DEFAULT 'minio'::character varying NULL, -- Nha cung cap storage (minio, aws-s3, local,...)
	region varchar(50) NULL, -- Region cua storage provider
	endpoint_url varchar(500) NULL, -- Custom endpoint URL cho S3-compatible
	is_public bool DEFAULT false NULL, -- Bucket co cho phep truy cap cong khai hay khong
	description text NULL, -- Mo ta bucket
	bi_xoa int2 DEFAULT 0 NOT NULL, -- Trang thai xoa mem: 0 = chua bi xoa, 1 = da bi xoa
	ma_cskcb varchar(50) DEFAULT 'ALL'::character varying NOT NULL, -- Ma CSKCB; 'ALL' = bucket dung chung (tat ca co so). Request maCskcb = 'ALL' thi tra bucket co ma_cskcb = 'ALL'. NOT NULL DEFAULT 'ALL'.
	nguoi_tao varchar(100) NULL, -- Nguoi tao ban ghi
	ngay_tao timestamp DEFAULT CURRENT_TIMESTAMP NOT NULL, -- Thoi gian tao ban ghi
	nguoi_cap_nhat varchar(100) NULL, -- Nguoi cap nhat cuoi cung
	ngay_cap_nhat timestamp DEFAULT CURRENT_TIMESTAMP NOT NULL, -- Thoi gian cap nhat cuoi cung
	nguoi_xoa varchar(100) NULL, -- Nguoi xoa mem
	ngay_xoa timestamp NULL, -- Thoi gian xoa mem
	storage_created bool DEFAULT false NOT NULL, -- Danh dau bucket logic da duoc tao/xac thuc tren storage vat ly (MinIO/S3) hay chua. false = chua dong bo/that bai, true = da dong bo.
	storage_created_at timestamp NULL, -- Thoi diem tao/xac thuc bucket tren storage vat ly thanh cong gan nhat.
	storage_last_error text NULL, -- Thong diep loi dong bo gan nhat khi tao/xac thuc bucket that bai. Null khi lan dong bo gan nhat thanh cong.
	allowed_mime_types varchar(500) DEFAULT '*'::character varying NULL, -- Danh sach MIME types cho phep (cach nhau dau phay); * = tat ca; ho tro wildcard image/*
	max_file_size_bytes int8 DEFAULT 104857600 NULL, -- Kich thuoc file toi da (bytes) cho bucket nay. NULL = dung cau hinh global his.storage.upload.max-file-size
	obj_key_prefix varchar(100) NULL, -- Prefix trong object key (vd. documents, patient-record). Null = khong them prefix. Doc lap voi bucket_name.
	allow_overwrite bool DEFAULT false NOT NULL, -- Khi true: upload ghi đè bản ghi trùng (bucket_id, storage_path) - upsert. Dùng cho redeploy (vd. ZIP FE module).
	not_use_date_segment bool DEFAULT false NOT NULL, -- Khi true: object key dạng prefix/path/filename (không segment ngày). Khi false: prefix/yyyyMMdd/filename.
	entity_type varchar(100) NULL, -- Khi set: gia tri duy nhat dung cho attachment entity_type; request co the bo hoac gui de xac minh khop.
	CONSTRAINT pl_file_bucket_pkey PRIMARY KEY (id)
);

CREATE TABLE pl_file_default (
	id uuid DEFAULT gen_random_uuid() NOT NULL,
	bucket_id uuid DEFAULT gen_random_uuid() NOT NULL,
	ma_cskcb varchar(25) DEFAULT 'ALL'::character varying NOT NULL,
	file_name varchar(500) NOT NULL,
	original_name varchar(500) NULL,
	content_type varchar(100) NULL,
	file_size int8 NULL,
	checksum_sha256 varchar(64) NULL,
	description varchar(1500) NULL,
	storage_path varchar(1000) NOT NULL,
	storage_provider varchar(50) DEFAULT 'minio'::character varying NULL,
	bucket_name varchar(100) NULL,
	is_public bool DEFAULT false NULL,
	uploaded_by varchar(100) NULL,
	bi_xoa int2 DEFAULT 0 NOT NULL,
	nguoi_tao varchar(100) NULL,
	ngay_tao timestamp DEFAULT CURRENT_TIMESTAMP NOT NULL,
	nguoi_cap_nhat varchar(100) NULL,
	ngay_cap_nhat timestamp DEFAULT CURRENT_TIMESTAMP NOT NULL,
	nguoi_xoa varchar(100) NULL,
	ngay_xoa timestamp NULL,
	upload_error int2 DEFAULT 0 NOT NULL,
	entity_type varchar(100) NULL,
	entity_id uuid NULL,
	CONSTRAINT pl_file_default_pkey PRIMARY KEY (id, bucket_id)
);

CREATE TABLE pl_file_fe_modules (
	id uuid DEFAULT gen_random_uuid() NOT NULL,
	bucket_id uuid DEFAULT gen_random_uuid() NOT NULL,
	ma_cskcb varchar(25) DEFAULT 'ALL'::character varying NOT NULL,
	file_name varchar(500) NOT NULL,
	original_name varchar(500) NULL,
	content_type varchar(100) NULL,
	file_size int8 NULL,
	checksum_sha256 varchar(64) NULL,
	description varchar(1500) NULL,
	storage_path varchar(1000) NOT NULL,
	storage_provider varchar(50) DEFAULT 'minio'::character varying NULL,
	bucket_name varchar(100) NULL,
	is_public bool DEFAULT false NULL,
	uploaded_by varchar(100) NULL,
	bi_xoa int2 DEFAULT 0 NOT NULL,
	nguoi_tao varchar(100) NULL,
	ngay_tao timestamp DEFAULT CURRENT_TIMESTAMP NOT NULL,
	nguoi_cap_nhat varchar(100) NULL,
	ngay_cap_nhat timestamp DEFAULT CURRENT_TIMESTAMP NOT NULL,
	nguoi_xoa varchar(100) NULL,
	ngay_xoa timestamp NULL,
	upload_error int2 DEFAULT 0 NOT NULL,
	entity_type varchar(100) NULL,
	entity_id uuid NULL,
	CONSTRAINT pl_file_fe_modules_pkey PRIMARY KEY (id, bucket_id)
);

CREATE TABLE pl_module_category (
	id uuid DEFAULT gen_random_uuid() NOT NULL, -- ID duy nhất của category
	code varchar(100) NOT NULL, -- Mã category (UPPERCASE, không dấu)
	"name" varchar(255) NOT NULL, -- Tên category (hiển thị)
	description text NULL, -- Mô tả category
	is_system bool DEFAULT false NULL, -- Category hệ thống (không thể xóa)
	bi_xoa int2 DEFAULT 0 NOT NULL, -- Trạng thái xóa: 0 = chưa bị xóa, 1 = đã bị xóa
	ngay_tao timestamp DEFAULT CURRENT_TIMESTAMP NOT NULL, -- Thời gian tạo bản ghi
	ngay_cap_nhat timestamp DEFAULT CURRENT_TIMESTAMP NOT NULL, -- Thời gian cập nhật cuối cùng
	nguoi_tao varchar(100) NULL, -- Người tạo bản ghi
	nguoi_cap_nhat varchar(100) NULL, -- Người cập nhật cuối cùng
	CONSTRAINT pl_module_category_code_key UNIQUE (code),
	CONSTRAINT pl_module_category_pkey PRIMARY KEY (id)
);

CREATE TABLE pl_nhom_bao_cao (
	id uuid DEFAULT gen_random_uuid() NOT NULL,
	ma varchar(25) NOT NULL,
	ten varchar(255) NOT NULL,
	ma_he_thong varchar NOT NULL,
	ma_loai_bao_cao varchar NOT NULL,
	nguoi_tao varchar NULL,
	ngay_tao timestamp DEFAULT now() NULL,
	nguoi_cap_nhat varchar NULL,
	ngay_cap_nhat timestamp DEFAULT now() NULL,
	bi_xoa int2 DEFAULT 0 NULL,
	nguoi_xoa varchar NULL,
	ngay_xoa timestamp NULL,
	su_dung int4 DEFAULT 0 NULL,
	mo_ta varchar NULL,
	ma_cskcb varchar NULL,
	CONSTRAINT pl_nhom_bao_cao_pkey PRIMARY KEY (id)
);

CREATE TABLE pl_nhom_chuc_nang (
	id uuid DEFAULT gen_random_uuid() NOT NULL,
	ma varchar(100) NOT NULL,
	ten varchar(255) NOT NULL,
	parent_id uuid NULL,
	feature_id uuid NULL,
	phan_he_id uuid NULL,
	stt int4 NULL,
	mo_ta varchar(1000) NULL,
	context_path varchar(255) NULL, -- Base context path truy cập nhóm chức năng
	ma_cskcb varchar(50) NULL, -- Nhóm chức năng thuộc cskcb nào?
	is_platform int2 DEFAULT 0 NOT NULL,
	hoat_dong int2 DEFAULT 1 NOT NULL,
	bi_xoa int2 DEFAULT 0 NOT NULL,
	ngay_tao timestamp DEFAULT now() NOT NULL,
	nguoi_tao varchar(100) NOT NULL,
	ngay_cap_nhat timestamp DEFAULT now() NOT NULL,
	nguoi_cap_nhat varchar(100) NULL,
	ngay_xoa timestamp NULL,
	nguoi_xoa varchar(100) NULL,
	application_id uuid NULL,
	nhom_ung_dung_id uuid NULL,
	ma_ung_dung varchar(25) NULL,
	CONSTRAINT pl_nhom_chuc_nang_pkey PRIMARY KEY (id),
	CONSTRAINT pl_nhom_chuc_nang_unique UNIQUE (ma)
);

CREATE TABLE pl_nhom_chuc_nang_bk (
	id uuid NULL,
	ma varchar(100) NULL,
	ten varchar(255) NULL,
	parent_id uuid NULL,
	feature_id uuid NULL,
	phan_he_id uuid NULL,
	stt int4 NULL,
	mo_ta varchar(1000) NULL,
	context_path varchar(255) NULL,
	ma_cskcb varchar(50) NULL,
	is_platform int2 NULL,
	hoat_dong int2 NULL,
	bi_xoa int2 NULL,
	ngay_tao timestamp NULL,
	nguoi_tao varchar(100) NULL,
	ngay_cap_nhat timestamp NULL,
	nguoi_cap_nhat varchar(100) NULL,
	ngay_xoa timestamp NULL,
	nguoi_xoa varchar(100) NULL,
	application_id uuid NULL
);

CREATE TABLE pl_nhom_chuc_nang_ung_dung_mapping (
	id uuid DEFAULT gen_random_uuid() NOT NULL,
	ma_nhom_chuc_nang varchar(100) NOT NULL, -- Mã tham chiếu đến pl_nhom_chuc_nang.ma
	ma_ung_dung varchar(100) NOT NULL, -- Mã tham chiếu đến dmc_ung_dung.ma
	ngay_tao timestamp DEFAULT now() NOT NULL,
	nguoi_tao varchar(100) DEFAULT 'system'::character varying NOT NULL,
	CONSTRAINT uq_pl_nhom_chuc_nang_ung_dung UNIQUE (ma_nhom_chuc_nang, ma_ung_dung)
);

CREATE TABLE pl_nhom_nguoi_dung (
	id uuid DEFAULT gen_random_uuid() NOT NULL,
	ma_cskcb varchar(50) NULL,
	ma varchar(100) NOT NULL,
	ten varchar(255) NOT NULL,
	feature_default varchar(50) NULL,
	hoat_dong int2 DEFAULT 1 NOT NULL,
	bi_xoa int2 DEFAULT 0 NOT NULL,
	ngay_tao timestamp DEFAULT now() NOT NULL,
	nguoi_tao varchar(100) NOT NULL,
	ngay_cap_nhat timestamp DEFAULT now() NOT NULL,
	nguoi_cap_nhat varchar(100) NULL,
	ngay_xoa timestamp NULL,
	nguoi_xoa varchar(100) NULL,
	nhom_ung_dung_id uuid NULL,
	CONSTRAINT pl_nhom_nguoi_dung_pkey PRIMARY KEY (id)
);

CREATE TABLE pl_nhom_nguoi_dung_bao_cao_mapping (
	nguoi_tao varchar NULL,
	ngay_tao timestamp NULL,
	pl_bao_cao_id uuid DEFAULT gen_random_uuid() NOT NULL,
	pl_nhom_nguoi_dung_id uuid DEFAULT gen_random_uuid() NOT NULL,
	CONSTRAINT pl_nhom_nguoi_dung_bao_cao_mapping_pkey PRIMARY KEY (pl_nhom_nguoi_dung_id, pl_bao_cao_id)
);

CREATE TABLE pl_nhom_nguoi_dung_nhom_chucnang_mapping (
	pl_nhom_nguoi_dung_id uuid DEFAULT gen_random_uuid() NOT NULL,
	pl_nhom_chuc_nang_id uuid DEFAULT gen_random_uuid() NOT NULL,
	nguoi_tao varchar(100) DEFAULT 'system'::character varying NOT NULL,
	ngay_tao timestamp DEFAULT now() NOT NULL,
	CONSTRAINT pl_nhom_nguoi_dung_nhom_chucnang_mapping_pkey PRIMARY KEY (pl_nhom_nguoi_dung_id, pl_nhom_chuc_nang_id)
);

CREATE TABLE pl_nhom_nguoi_dung_nhom_chucnang_mapping_bk (
	pl_nhom_nguoi_dung_id uuid NULL,
	pl_nhom_chuc_nang_id uuid NULL,
	nguoi_tao varchar(100) NULL,
	ngay_tao timestamp NULL
);

CREATE TABLE pl_nhom_nguoi_dung_ung_dung_mapping (
	id uuid DEFAULT gen_random_uuid() NOT NULL,
	ma_nhom_nguoi_dung varchar(100) NOT NULL,
	ma_ung_dung varchar(100) NOT NULL,
	ngay_tao timestamp DEFAULT now() NOT NULL,
	nguoi_tao varchar(100) DEFAULT 'system'::character varying NOT NULL,
	CONSTRAINT uq_pl_nhom_nguoi_dung_ung_dung UNIQUE (ma_nhom_nguoi_dung, ma_ung_dung)
);

CREATE TABLE pl_package (
	id uuid DEFAULT gen_random_uuid() NOT NULL,
	ma varchar(50) NOT NULL,
	ten varchar(50) NOT NULL,
	loai_hinh_to_chuc varchar(50) NOT NULL,
	loai_benh_vien varchar(50) NOT NULL,
	hang varchar(50) NOT NULL,
	tuyen varchar(50) NOT NULL,
	hoat_dong int2 DEFAULT 1 NOT NULL,
	bi_xoa int2 DEFAULT 0 NOT NULL,
	ngay_xoa timestamp NULL,
	nguoi_xoa varchar(100) NULL,
	ngay_tao timestamp DEFAULT now() NULL,
	nguoi_tao varchar(100) NULL,
	ngay_cap_nhat timestamp DEFAULT now() NULL,
	nguoi_cap_nhat varchar(100) NULL,
	CONSTRAINT pl_package_ma_key UNIQUE (ma),
	CONSTRAINT pl_package_pkey PRIMARY KEY (id)
);

CREATE TABLE pl_package_nhom_chuc_nang_mapping (
	id uuid DEFAULT gen_random_uuid() NOT NULL,
	pl_package_id uuid NOT NULL,
	pl_nhom_chuc_nang_id uuid NOT NULL,
	nguoi_tao varchar(100) NOT NULL,
	ngay_tao timestamp DEFAULT now() NOT NULL,
	CONSTRAINT pl_package_nhom_chuc_nang_map_pl_package_id_pl_nhom_chuc_na_key UNIQUE (pl_package_id, pl_nhom_chuc_nang_id),
	CONSTRAINT pl_package_nhom_chuc_nang_mapping_pkey PRIMARY KEY (id)
);

CREATE TABLE pl_quy_trinh_phe_duyet (
	id uuid DEFAULT gen_random_uuid() NOT NULL,
	ma_cskcb varchar NOT NULL,
	ma varchar(25) NOT NULL,
	ten varchar(255) NOT NULL,
	ngay_cap_nhat timestamp NULL,
	nguoi_xoa varchar(25) NULL,
	ngay_tao timestamp NULL,
	bi_xoa int2 DEFAULT 0 NOT NULL,
	ngay_xoa timestamp NULL,
	su_dung int2 DEFAULT 1 NULL,
	nguoi_tao varchar(25) NULL,
	nguoi_cap_nhat varchar(25) NULL,
	func_phe_duyet varchar NULL,
	func_gui_duyet varchar NULL,
	bang_ap_dung _varchar NULL,
	cap_duyet_toi_thieu int2 NULL,
	pl_application_feature_id uuid NULL,
	CONSTRAINT pl_quy_trinh_phe_duyet_pk PRIMARY KEY (id)
);

CREATE TABLE pl_quy_trinh_phe_duyet_bang_nghiep_vu_map (
	id uuid DEFAULT gen_random_uuid() NOT NULL,
	pl_application_feature_id uuid NOT NULL,
	table_name varchar NOT NULL,
	column_name varchar NULL,
	ngay_tao timestamp DEFAULT now() NULL,
	nguoi_tao varchar NULL,
	ngay_cap_nhat timestamp DEFAULT now() NULL,
	nguoi_cap_nhat varchar NULL,
	bi_xoa int2 DEFAULT 0 NULL,
	ngay_xoa timestamp NULL,
	nguoi_xoa varchar NULL,
	pl_application_feature_name varchar NULL,
	CONSTRAINT pl_quy_trinh_phe_duyet_bang_nghiep_vu_map_pk PRIMARY KEY (id)
);

CREATE TABLE pl_quy_trinh_phe_duyet_buoc_duyet_nguoi_duyet (
	id uuid DEFAULT gen_random_uuid() NOT NULL,
	ma_cskcb varchar NOT NULL,
	pl_quy_trinh_phe_duyet_id uuid NOT NULL,
	pl_quy_trinh_phe_duyet_buoc_duyet_id uuid NOT NULL,
	chuc_vu_id uuid NULL,
	nhan_vien_id uuid NOT NULL,
	nguoi_tao varchar(25) NULL,
	ngay_tao timestamp DEFAULT now() NULL,
	nguoi_cap_nhat varchar(25) NULL,
	ngay_cap_nhat timestamp DEFAULT now() NULL,
	bi_xoa int2 DEFAULT 0 NOT NULL,
	nguoi_xoa varchar(25) NULL,
	ngay_xoa timestamp NULL,
	CONSTRAINT pl_quy_trinh_phe_duyet_buoc_duyet_nguoi_duyet_pkey PRIMARY KEY (id)
);

CREATE TABLE pl_quy_trinh_phe_duyet_cap_duyet (
	id uuid DEFAULT gen_random_uuid() NOT NULL,
	ma_cskcb varchar NOT NULL,
	pl_quy_trinh_phe_duyet_id uuid NOT NULL,
	cap int4 NULL,
	width int4 DEFAULT 600 NULL,
	height int4 DEFAULT 130 NULL,
	position_x int4 DEFAULT 0 NULL,
	position_y int4 DEFAULT 0 NULL,
	nguoi_tao varchar(25) NULL,
	ngay_tao timestamp DEFAULT now() NULL,
	nguoi_cap_nhat varchar(25) NULL,
	ngay_cap_nhat timestamp DEFAULT now() NULL,
	bi_xoa int2 DEFAULT 0 NOT NULL,
	nguoi_xoa varchar(25) NULL,
	ngay_xoa timestamp NULL,
	CONSTRAINT pl_quy_trinh_phe_duyet_cap_duyet_pk PRIMARY KEY (id)
);

CREATE TABLE pl_tenant (
	id uuid DEFAULT gen_random_uuid() NOT NULL,
	ma varchar(50) NOT NULL,
	ten varchar(255) NOT NULL,
	hoat_dong int4 DEFAULT 1 NOT NULL,
	ngay_xoa timestamp NULL,
	nguoi_xoa varchar(100) NULL,
	ngay_tao timestamp DEFAULT now() NOT NULL,
	nguoi_tao varchar(100) NULL,
	ngay_cap_nhat timestamp DEFAULT now() NOT NULL,
	nguoi_cap_nhat varchar(100) NULL,
	ma_hop_dong varchar(100) NULL,
	goi_hop_dong varchar(50) NULL,
	ngay_ky timestamp NULL,
	thoi_gian_hieu_luc timestamp NULL,
	ngay_thu_nghiem timestamp NULL,
	ngay_van_hanh_chinh_thuc timestamp NULL,
	thoi_gian_ket_thuc_bao_hanh timestamp NULL,
	schema_name varchar NOT NULL,
	CONSTRAINT pl_tenant_pkey PRIMARY KEY (id),
	CONSTRAINT pl_tenant_schema_name_key UNIQUE (schema_name)
);

CREATE TABLE pl_tham_so_bao_cao (
	id uuid DEFAULT gen_random_uuid() NOT NULL,
	pl_bao_cao_id uuid NOT NULL,
	ma varchar NOT NULL,
	ten varchar NOT NULL,
	ten_truong varchar NOT NULL,
	loai_truong varchar NOT NULL,
	load_theo_truong uuid NULL,
	gia_tri_mac_dinh varchar NULL,
	stt int4 NULL,
	hoat_dong int2 DEFAULT 1 NULL,
	query_code varchar NULL,
	ngay_tao timestamp NULL,
	nguoi_tao varchar NULL,
	ngay_cap_nhat timestamp NULL,
	nguoi_cap_nhat varchar NULL,
	bi_xoa int2 DEFAULT 1 NULL,
	nguoi_xoa varchar NULL,
	ngay_xoa timestamp NULL,
	properties jsonb NULL,
	layout jsonb NULL,
	"options" jsonb DEFAULT '[]'::jsonb NULL,
	api_config jsonb NULL,
	tra_cuu bool NOT NULL,
	loai_gia_tri_mac_dinh int2 NOT NULL,
	ten_gia_tri_mac_dinh varchar NULL,
	ma_cskcb varchar NULL,
	bat_buoc bool DEFAULT false NULL,
	chon_nhieu bool DEFAULT false NULL,
	CONSTRAINT pl_tham_so_bao_cao_pkey PRIMARY KEY (id)
);

CREATE TABLE pl_tham_so_he_thong (
	id uuid DEFAULT gen_random_uuid() NOT NULL,
	ma_tham_so varchar(50) NOT NULL,
	ten_tham_so varchar(255) NOT NULL,
	gia_tri_mac_dinh varchar(100) NOT NULL,
	mo_ta_tham_so text NULL,
	mo_ta_tham_so_lien_quan text NULL,
	trang_thai varchar(50) NOT NULL,
	bi_xoa int2 DEFAULT 0 NOT NULL,
	ngay_xoa timestamp NULL,
	nguoi_xoa varchar(100) NULL,
	ngay_tao timestamp DEFAULT CURRENT_TIMESTAMP NULL,
	nguoi_tao varchar NULL,
	ngay_cap_nhat timestamp NULL,
	nguoi_cap_nhat varchar NULL,
	nhom varchar(70) NULL,
	gia_tri_tham_so varchar NOT NULL, -- Các giá trị áp dụng cho  tham số. Nếu nhiều giá trị các giá trị phân cách nhau bằng dấu ||
	public_fe int2 DEFAULT 0 NOT NULL, -- Chỉ public ra các tham số cho FE
	is_private int2 DEFAULT 0 NOT NULL, -- Đối với các tham số cấu hình key, token thì nếu is_private = 1 thì trả giatri dạng *****
	ngay_ap_dung date DEFAULT CURRENT_TIMESTAMP NOT NULL,
	app_id varchar(100) NULL,
	title varchar(500) NULL,
	CONSTRAINT pl_tham_so_he_thong_pkey PRIMARY KEY (id)
);

CREATE TABLE pl_tham_so_he_thong_cskcb (
	id uuid DEFAULT gen_random_uuid() NOT NULL,
	tenant varchar(20) NOT NULL,
	ma_cskcb varchar(20) NOT NULL,
	ma_tham_so varchar(50) NOT NULL,
	gia_tri varchar(100) NOT NULL,
	bi_xoa int2 DEFAULT 0 NOT NULL,
	ngay_xoa timestamp NULL,
	nguoi_xoa varchar(100) NULL,
	ngay_tao timestamp DEFAULT CURRENT_TIMESTAMP NOT NULL,
	nguoi_tao varchar NULL,
	ngay_cap_nhat timestamp NULL,
	nguoi_cap_nhat varchar NULL,
	nhom varchar(70) NULL,
	description text NULL,
	ngay_ap_dung date DEFAULT CURRENT_TIMESTAMP NOT NULL,
	CONSTRAINT pl_tham_so_he_thong_cskcb_pkey PRIMARY KEY (id)
);

CREATE TABLE pl_thiet_bi_phuc_vu (
	ma_nhom_dich_vu varchar(25) NULL,
	ten varchar(255) NULL,
	ten_viet_tat varchar(25) NULL,
	thiet_bi_phuc_vu_id uuid NULL,
	su_dung bool DEFAULT false NOT NULL,
	id uuid DEFAULT gen_random_uuid() NOT NULL, -- Key của bảng
	ngay_tao timestamp DEFAULT now() NOT NULL, -- Ngày tạo
	nguoi_tao varchar(100) DEFAULT '''system'''::character varying NOT NULL, -- Người tạo
	ngay_cap_nhat timestamp DEFAULT now() NOT NULL, -- Ngày cập nhật
	nguoi_cap_nhat varchar(100) DEFAULT '''system'''::character varying NOT NULL, -- Người cập nhật
	bi_xoa int2 DEFAULT 0 NULL, -- Bị xóa mềm
	ngay_xoa timestamp NULL, -- Ngày xóa mềm
	nguoi_xoa varchar(100) NULL, -- Người xóa mềm
	CONSTRAINT pl_thiet_bi_phuc_vu_pk_id PRIMARY KEY (id)
);

CREATE TABLE pl_trang_thai_quy_trinh_phe_duyet (
	id uuid DEFAULT gen_random_uuid() NOT NULL,
	ma_cskcb varchar NOT NULL,
	pl_quy_trinh_phe_duyet_id uuid NOT NULL,
	pl_quy_trinh_phe_duyet_cap_gui_duyet_id uuid NOT NULL,
	ref_id uuid NOT NULL,
	ref_table varchar NOT NULL,
	pl_quy_trinh_phe_duyet_cap_phe_duyet_id uuid NOT NULL,
	trang_thai_phe_duyet int2 DEFAULT 0 NULL,
	nguoi_tao varchar(25) NULL,
	ngay_xoa timestamp NULL,
	ngay_tao timestamp DEFAULT now() NULL,
	ngay_cap_nhat timestamp DEFAULT now() NULL,
	nguoi_cap_nhat varchar(25) NULL,
	nguoi_xoa varchar(25) NULL,
	bi_xoa int2 DEFAULT 0 NOT NULL,
	khoa_gui_duyet_id uuid NULL,
	phong_gui_duyet_id uuid NULL,
	nguoi_gui_duyet_id uuid NULL,
	khoa_phe_duyet_id uuid NULL,
	phong_phe_duyet_id uuid NULL,
	nguoi_phe_duyet_id uuid NULL,
	ly_do text NULL,
	cap_gui_duyet int2 NULL,
	cap_phe_duyet int2 NULL,
	CONSTRAINT pl_trang_thai_quy_trinh_phe_duyet_pk PRIMARY KEY (id)
);

CREATE TABLE pl_user (
	id uuid DEFAULT gen_random_uuid() NOT NULL,
	ma varchar(50) NOT NULL,
	ma_cskcb varchar(50) NULL,
	tai_khoan_id varchar(40) NOT NULL, -- ID của user trên KC
	ten varchar(100) NOT NULL,
	ten_dang_nhap varchar(100) NOT NULL,
	dm_nhan_vien_id uuid NULL,
	ma_pl_tenant varchar(100) NOT NULL,
	ma_nhom_nguoi_dung varchar(50) NOT NULL,
	email varchar(255) NULL,
	ho varchar(100) NULL,
	ten_rieng varchar(100) NULL,
	loai_tai_khoan varchar(255) NULL,
	ten_phap_nhan varchar(255) NULL,
	hoat_dong int2 DEFAULT 1 NOT NULL,
	bi_xoa int2 DEFAULT 0 NOT NULL,
	ngay_xoa timestamp NULL,
	nguoi_xoa varchar(100) NULL,
	ngay_tao timestamp DEFAULT CURRENT_TIMESTAMP NOT NULL,
	nguoi_tao varchar(100) NULL,
	ngay_cap_nhat timestamp DEFAULT now() NOT NULL,
	nguoi_cap_nhat varchar(100) NULL,
	CONSTRAINT pl_user_ma_key UNIQUE (ma),
	CONSTRAINT pl_user_pkey PRIMARY KEY (id),
	CONSTRAINT pl_user_tai_khoan_id_key UNIQUE (tai_khoan_id),
	CONSTRAINT pl_user_ten_dang_nhap_key UNIQUE (ten_dang_nhap)
);

CREATE TABLE pl_user_sys_nhom_quyen_du_lieu_mapping (
	id uuid DEFAULT gen_random_uuid() NOT NULL,
	pl_user_id uuid NOT NULL,
	sys_nhom_quyen_du_lieu_id uuid NOT NULL,
	nguoi_tao varchar(100) NOT NULL,
	ngay_tao timestamp DEFAULT now() NOT NULL,
	CONSTRAINT pl_user_sys_nhom_quyen_du_lieu_mapping_pkey PRIMARY KEY (id)
);

CREATE TABLE process_log (
	log varchar NULL,
	step varchar NULL,
	id uuid DEFAULT gen_random_uuid() NOT NULL,
	code numeric NULL,
	CONSTRAINT process_log_pkey PRIMARY KEY (id)
);

CREATE TABLE pttt_cau_hinh_phu_cap (
	id uuid DEFAULT gen_random_uuid() NOT NULL,
	ma_cskcb varchar(20) NOT NULL,
	ngay_bat_dau_ap_dung date NULL,
	ngay_ket_thuc_ap_dung date NULL,
	trang_thai varchar(50) NULL,
	hieu_luc bool DEFAULT false NOT NULL,
	su_dung bool DEFAULT false NOT NULL,
	bi_xoa int2 DEFAULT 0 NOT NULL,
	ngay_xoa timestamp NULL,
	nguoi_xoa varchar(100) NULL,
	ngay_tao timestamp DEFAULT CURRENT_TIMESTAMP NOT NULL,
	nguoi_tao varchar(100) NOT NULL,
	ngay_cap_nhat timestamp NOT NULL,
	nguoi_cap_nhat varchar(100) NOT NULL,
	loai_nhom_dich_vu varchar(50) NULL,
	CONSTRAINT pttt_cau_hinh_phu_cap_pkey PRIMARY KEY (id)
);

CREATE TABLE pttt_cau_hinh_phu_cap_vai_tro (
	id uuid DEFAULT gen_random_uuid() NOT NULL,
	ma_cskcb varchar(20) NOT NULL,
	pttt_cau_hinh_phu_cap_id uuid NOT NULL,
	ma_loai_vai_tro varchar(255) NOT NULL,
	phu_cap jsonb NOT NULL,
	bi_xoa int2 DEFAULT 0 NOT NULL,
	ngay_xoa timestamp NULL,
	nguoi_xoa varchar(100) NULL,
	ngay_tao timestamp DEFAULT CURRENT_TIMESTAMP NOT NULL,
	nguoi_tao varchar(100) NOT NULL,
	ngay_cap_nhat timestamp NOT NULL,
	nguoi_cap_nhat varchar(100) NOT NULL,
	CONSTRAINT pttt_cau_hinh_phu_cap_vai_tro_pkey PRIMARY KEY (id)
);

CREATE TABLE pttt_dich_vu_dinh_kem (
	id uuid DEFAULT gen_random_uuid() NOT NULL,
	phieu_duyet_mo_id uuid NOT NULL,
	dich_vu_id uuid NOT NULL,
	phieu_dich_vu_id uuid NOT NULL,
	ten_dich_vu varchar(255) NULL,
	ma_dich_vu varchar(50) NULL,
	ma_cskcb varchar(20) NOT NULL,
	bi_xoa int2 DEFAULT 0 NOT NULL,
	ngay_xoa timestamp NULL,
	nguoi_xoa varchar(100) NULL,
	ngay_tao timestamp DEFAULT CURRENT_TIMESTAMP NOT NULL,
	nguoi_tao varchar(100) NOT NULL,
	ngay_cap_nhat timestamp NOT NULL,
	nguoi_cap_nhat varchar(100) NOT NULL,
	phieu_dich_vu_chi_tiet_id uuid NULL,
	nhom_dich_vu_id uuid NULL,
	ten_nhom_dich_vu varchar(255) NULL,
	ma_nhom_dich_vu varchar(100) NULL,
	icd9_id uuid NULL,
	ten_benh_icd9 varchar(255) NULL,
	ma_benh_icd9 varchar(100) NULL,
	dm_loai_pttt_id uuid NULL,
	ma_dm_loai_pttt varchar(100) NULL,
	ten_dm_loai_pttt varchar(255) NULL,
	CONSTRAINT pttt_dich_vu_dinh_kem_pkey PRIMARY KEY (id)
);

CREATE TABLE pttt_dm_cong_thuc_che_bien (
	id uuid DEFAULT gen_random_uuid() NOT NULL, -- UID của bảng
	ma_cong_thuc varchar(25) NULL, -- Mã công thức chế biến
	ten_cong_thuc varchar(255) NULL, -- Tên công thức chế biến
	phuong_thuc_che_bien int4 NULL, -- Phương thức chế biến (FK → DMC_PhuongThucCheBien)
	ma_thanh_pham int4 NULL, -- Mã thành phẩm (FK → DM_ThanhPham)
	ten_thanh_pham varchar(255) NULL, -- Tên thành phẩm
	so_luong_dau_ra int4 NULL, -- Số lượng đầu ra
	su_dung bool NULL, -- Trạng thái sử dụng: true-Đang dùng, false-Không dùng
	ma_cskcb varchar(20) NULL, -- Mã cơ sở khám chữa bệnh
	nguoi_tao varchar(255) NULL, -- Người tạo
	ngay_tao timestamp NULL, -- Ngày tạo
	nguoi_cap_nhat varchar(255) NULL, -- Người cập nhật
	ngay_cap_nhat timestamp NULL, -- Ngày cập nhật
	nguoi_xoa varchar(255) NULL, -- Người xóa
	ngay_xoa timestamp NULL, -- Ngày xóa
	bi_xoa int2 DEFAULT 0 NOT NULL, -- Bị xóa: 0-Chưa xóa, 1-Đã xóa (soft delete)
	CONSTRAINT pttt_dm_cong_thuc_che_bien_pkey PRIMARY KEY (id)
);

CREATE TABLE pttt_dm_cong_thuc_che_bien_ct (
	id uuid DEFAULT gen_random_uuid() NOT NULL, -- UID của bảng
	cong_thuc_che_bien_id uuid NOT NULL, -- FK → pttt_dm_cong_thuc_che_bien.id
	ma_thuc_pham int4 NULL, -- Mã thực phẩm (FK → danh mục thực phẩm)
	ten_thuc_pham varchar(255) NULL, -- Tên thực phẩm
	so_luong_dau_vao numeric(18, 4) NULL, -- Số lượng đầu vào
	don_gia numeric(18, 4) NULL, -- Đơn giá
	thanh_tien int4 NULL, -- Thành tiền (= số lượng × đơn giá)
	ma_cskcb varchar(20) NULL,
	nguoi_tao varchar(255) NULL,
	ngay_tao timestamp NULL,
	nguoi_cap_nhat varchar(255) NULL,
	ngay_cap_nhat timestamp NULL,
	nguoi_xoa varchar(255) NULL,
	ngay_xoa timestamp NULL,
	bi_xoa int2 DEFAULT 0 NOT NULL, -- Bị xóa: 0-Chưa xóa, 1-Đã xóa (soft delete)
	CONSTRAINT pttt_dm_cong_thuc_che_bien_ct_pkey PRIMARY KEY (id)
);

CREATE TABLE pttt_dm_loai_suat_an (
	id uuid DEFAULT gen_random_uuid() NOT NULL, -- UID của bảng
	ma_loai_suat_an varchar(25) NULL, -- Mã loại suất ăn
	ten_loai_suat_an varchar(255) NULL, -- Tên loại suất ăn
	ghi_chu varchar(50) NULL, -- Ghi chú
	su_dung bool NULL, -- Trạng thái sử dụng: true-Đang dùng, false-Không dùng
	ma_cskcb varchar(20) NULL, -- Mã cơ sở khám chữa bệnh
	nguoi_tao varchar(255) NULL, -- Người tạo
	ngay_tao timestamp NULL, -- Ngày tạo
	nguoi_cap_nhat varchar(255) NULL, -- Người cập nhật
	ngay_cap_nhat timestamp NULL, -- Ngày cập nhật
	nguoi_xoa varchar(255) NULL, -- Người xóa
	ngay_xoa timestamp NULL, -- Ngày xóa
	bi_xoa int2 DEFAULT 0 NOT NULL, -- Bị xóa: 0-Chưa xóa, 1-Đã xóa (soft delete)
	CONSTRAINT pttt_dm_loai_suat_an_pkey PRIMARY KEY (id)
);

CREATE TABLE pttt_dm_nhom_thanh_pham (
	id uuid DEFAULT gen_random_uuid() NOT NULL, -- UID của bảng
	ma_nhom varchar(25) NULL, -- Mã nhóm thành phẩm
	ten_nhom varchar(255) NULL, -- Tên nhóm thành phẩm
	ghi_chu varchar(255) NULL, -- Ghi chú
	su_dung bool NULL, -- Trạng thái sử dụng: true-Đang dùng, false-Không dùng
	ma_cskcb varchar(20) NULL, -- Mã cơ sở khám chữa bệnh
	nguoi_tao varchar(255) NULL, -- Người tạo
	ngay_tao timestamp NULL, -- Ngày tạo
	nguoi_cap_nhat varchar(255) NULL, -- Người cập nhật
	ngay_cap_nhat timestamp NULL, -- Ngày cập nhật
	nguoi_xoa varchar(255) NULL, -- Người xóa
	ngay_xoa timestamp NULL, -- Ngày xóa
	bi_xoa int2 DEFAULT 0 NOT NULL, -- Bị xóa: 0-Chưa xóa, 1-Đã xóa (soft delete)
	CONSTRAINT pttt_dm_nhom_thanh_pham_pkey PRIMARY KEY (id)
);

CREATE TABLE pttt_dm_phuong_thuc_che_bien (
	id uuid DEFAULT gen_random_uuid() NOT NULL, -- UID của bảng
	ma_phuong_thuc varchar(25) NULL, -- Mã phương thức chế biến
	ten_phuong_thuc varchar(255) NULL, -- Tên phương thức chế biến
	loai_phuong_thuc varchar(255) NULL, -- Loại phương thức
	dieu_kien_thuc_hien varchar(255) NULL, -- Điều kiện thực hiện
	loai_thiet_bi_nha_bep int4 NULL, -- Loại thiết bị nhà bếp sử dụng (FK → DM_ThietBiNhaBep)
	ghi_chu text NULL, -- Ghi chú
	su_dung bool NULL, -- Trạng thái sử dụng: true-Đang dùng, false-Không dùng
	ma_cskcb varchar(20) NULL, -- Mã cơ sở khám chữa bệnh
	nguoi_tao varchar(255) NULL, -- Người tạo
	ngay_tao timestamp NULL, -- Ngày tạo
	nguoi_cap_nhat varchar(255) NULL, -- Người cập nhật
	ngay_cap_nhat timestamp NULL, -- Ngày cập nhật
	nguoi_xoa varchar(255) NULL, -- Người xóa
	ngay_xoa timestamp NULL, -- Ngày xóa
	bi_xoa int2 DEFAULT 0 NOT NULL, -- Bị xóa: 0-Chưa xóa, 1-Đã xóa (soft delete)
	CONSTRAINT pttt_dm_phuong_thuc_che_bien_pkey PRIMARY KEY (id)
);

CREATE TABLE pttt_dm_so_luong_ptv (
	chuyen_khoa_id uuid NULL,
	ma_chuyen_khoa varchar(100) NULL,
	ten_chuyen_khoa varchar(255) NULL,
	nhom_dich_vu_id uuid NULL,
	ma_nhom_dich_vu varchar(100) NULL,
	ten_nhom_dich_vu varchar(255) NULL,
	tong_loai_db int4 DEFAULT 0 NULL,
	tong_loai_i int4 DEFAULT 0 NULL,
	tong_loai_ii int4 DEFAULT 0 NULL,
	tong_loai_iii int4 DEFAULT 0 NULL,
	su_dung bool DEFAULT false NULL,
	id uuid DEFAULT gen_random_uuid() NOT NULL,
	ma_cskcb varchar(20) NOT NULL,
	bi_xoa int2 DEFAULT 0 NOT NULL,
	ngay_xoa timestamp NULL,
	nguoi_xoa varchar(100) NULL,
	ngay_tao timestamp DEFAULT CURRENT_TIMESTAMP NOT NULL,
	nguoi_tao varchar(100) NOT NULL,
	ngay_cap_nhat timestamp NOT NULL,
	nguoi_cap_nhat varchar(100) NOT NULL,
	ghi_chu text NULL
);

CREATE TABLE pttt_dm_so_luong_ptv_chi_tiet (
	pttt_dm_so_luong_ptv_id uuid NULL,
	vai_tro_kip_mo_id uuid NULL,
	ma_vai_tro_kip_mo varchar(100) NULL,
	ten_vai_tro_kip_mo varchar(255) NULL,
	id uuid DEFAULT gen_random_uuid() NOT NULL,
	ma_cskcb varchar(20) NOT NULL,
	bi_xoa int2 DEFAULT 0 NOT NULL,
	ngay_xoa timestamp NULL,
	nguoi_xoa varchar(100) NULL,
	ngay_tao timestamp DEFAULT CURRENT_TIMESTAMP NOT NULL,
	nguoi_tao varchar(100) NOT NULL,
	ngay_cap_nhat timestamp NOT NULL,
	nguoi_cap_nhat varchar(100) NOT NULL,
	loai_pttt_id uuid NULL,
	ma_loai_pttt varchar(100) NULL,
	ten_loai_pttt varchar(255) NULL,
	so_luong int4 DEFAULT 0 NULL
);

CREATE TABLE pttt_dm_thuc_pham (
	id uuid DEFAULT gen_random_uuid() NOT NULL, -- UID của bảng
	ma_thuc_pham varchar(25) NULL, -- Mã thực phẩm
	ten_thuc_pham varchar(255) NULL, -- Tên thực phẩm
	nhom_thuc_pham int4 NULL, -- Nhóm thực phẩm (FK → pttt_dm_nhom_thanh_pham)
	don_vi_tinh int4 NULL, -- Đơn vị tính (FK → DM_DonViTinh)
	don_vi_cung_cap int4 NULL, -- Đơn vị cung cấp (FK → DM_DonViCungCap)
	nguon_goc_thuc_pham varchar(255) NULL, -- Nguồn gốc thực phẩm
	ghi_chu varchar(255) NULL, -- Ghi chú
	su_dung bool NULL, -- Trạng thái sử dụng: true-Đang dùng, false-Không dùng
	ma_cskcb varchar(20) NULL, -- Mã cơ sở khám chữa bệnh
	nguoi_tao varchar(255) NULL, -- Người tạo
	ngay_tao timestamp NULL, -- Ngày tạo
	nguoi_cap_nhat varchar(255) NULL, -- Người cập nhật
	ngay_cap_nhat timestamp NULL, -- Ngày cập nhật
	nguoi_xoa varchar(255) NULL, -- Người xóa
	ngay_xoa timestamp NULL, -- Ngày xóa
	bi_xoa int2 DEFAULT 0 NOT NULL, -- Bị xóa: 0-Chưa xóa, 1-Đã xóa (soft delete)
	CONSTRAINT pttt_dm_thuc_pham_pkey PRIMARY KEY (id)
);

CREATE TABLE pttt_ekip_mau (
	id uuid DEFAULT gen_random_uuid() NOT NULL,
	ma_cskcb varchar(20) NOT NULL,
	ten_ekip_mau varchar(150) NOT NULL,
	mo_ta varchar(500) NULL,
	bi_xoa int2 DEFAULT 0 NOT NULL,
	ngay_xoa timestamp NULL,
	nguoi_xoa varchar(100) NULL,
	ngay_tao timestamp DEFAULT CURRENT_TIMESTAMP NOT NULL,
	nguoi_tao varchar(100) NOT NULL,
	ngay_cap_nhat timestamp NOT NULL,
	nguoi_cap_nhat varchar(100) NOT NULL,
	chuyen_khoa_id uuid NULL,
	ma_loai_dich_vu varchar(100) NULL,
	CONSTRAINT pttt_ekip_mau_pkey PRIMARY KEY (id)
);

CREATE TABLE pttt_ekip_mau_chi_tiet (
	id uuid DEFAULT gen_random_uuid() NOT NULL,
	ma_cskcb varchar(20) NOT NULL,
	ekip_mau_id uuid NOT NULL,
	vai_tro_id uuid NOT NULL,
	vai_tro varchar NOT NULL,
	bac_si_id uuid NOT NULL,
	bac_si varchar NOT NULL,
	khoa_id uuid NULL,
	khoa varchar NOT NULL,
	chuc_danh_id uuid NULL,
	chuc_danh varchar NULL,
	thu_tu int4 NULL,
	bi_xoa int2 DEFAULT 0 NOT NULL,
	ngay_xoa timestamp NULL,
	nguoi_xoa varchar(100) NULL,
	ngay_tao timestamp DEFAULT CURRENT_TIMESTAMP NULL,
	nguoi_tao varchar NULL,
	ngay_cap_nhat timestamp NULL,
	nguoi_cap_nhat varchar NULL,
	CONSTRAINT pttt_ekip_mau_chi_tiet_pkey PRIMARY KEY (id)
);

CREATE TABLE pttt_ekip_mo (
	id uuid DEFAULT gen_random_uuid() NOT NULL,
	ma_cskcb varchar(20) NOT NULL,
	phieu_duyet_mo_id uuid NULL,
	vai_tro_id uuid NULL,
	vai_tro varchar NULL,
	bac_si_id uuid NULL,
	bac_si varchar NULL,
	khoa_id uuid NULL,
	khoa varchar NULL,
	chuc_danh_id uuid NULL,
	chuc_danh varchar NULL,
	thu_tu int4 NULL,
	bi_xoa int2 DEFAULT 0 NOT NULL,
	ngay_xoa timestamp NULL,
	nguoi_xoa varchar(100) NULL,
	ngay_tao timestamp DEFAULT CURRENT_TIMESTAMP NULL,
	nguoi_tao varchar NULL,
	ngay_cap_nhat timestamp NULL,
	nguoi_cap_nhat varchar NULL,
	CONSTRAINT pttt_ekip_mo_pkey PRIMARY KEY (id)
);

CREATE TABLE pttt_phieu_duyet_mo (
	id uuid DEFAULT gen_random_uuid() NOT NULL,
	ma_cskcb varchar(20) NOT NULL,
	ma_lich varchar(50) NULL,
	benh_nhan_id uuid NOT NULL,
	benh_nhan_dot_dieu_tri_id uuid NOT NULL,
	benh_nhan_ten varchar(255) NULL,
	benh_nhan_ngay_sinh date NULL,
	benh_nhan_gioi_tinh varchar(10) NULL,
	ma_dieu_tri varchar(50) NULL,
	ma_yeu_cau varchar(50) NULL,
	khoa_yeu_cau_id uuid NOT NULL,
	khoa_yeu_cau varchar(100) NULL,
	nguoi_yeu_cau_id uuid NULL,
	nguoi_yeu_cau varchar(100) NULL,
	yeu_cau_du_tru varchar(1000) NULL,
	thoi_gian_y_lenh timestamp NULL,
	chan_doan_chinh varchar(1000) NULL,
	chan_doan_phu varchar(1000) NULL,
	phuong_phap_id uuid NOT NULL,
	phuong_phap varchar(200) NULL,
	vo_cam_id uuid NOT NULL,
	vo_cam varchar(200) NULL,
	cach_thuc varchar(500) NOT NULL,
	phong_thuc_hien_id uuid NOT NULL,
	phong_thuc_hien varchar(200) NULL,
	thoi_gian_du_kien_bat_dau timestamp NOT NULL,
	thoi_gian_du_kien_ket_thuc timestamp NOT NULL,
	ghi_chu varchar(1000) NULL,
	trang_thai varchar(20) NOT NULL,
	nguoi_duyet_id uuid NULL,
	nguoi_duyet varchar(100) NULL,
	thoi_gian_duyet timestamp NULL,
	bi_xoa int2 DEFAULT 0 NOT NULL,
	ngay_xoa timestamp NULL,
	nguoi_xoa varchar(100) NULL,
	ngay_tao timestamp DEFAULT CURRENT_TIMESTAMP NOT NULL,
	nguoi_tao varchar(100) NOT NULL,
	ngay_cap_nhat timestamp NOT NULL,
	nguoi_cap_nhat varchar(100) NOT NULL,
	tiep_nhan_id uuid DEFAULT gen_random_uuid() NOT NULL,
	phieu_dich_vu_id uuid DEFAULT gen_random_uuid() NOT NULL,
	bac_si_id uuid DEFAULT gen_random_uuid() NOT NULL,
	dich_vu_id uuid DEFAULT gen_random_uuid() NOT NULL,
	ten_dich_vu varchar(100) NULL,
	ma_dich_vu varchar(50) NULL,
	phieu_dich_vu_chi_tiet_id uuid NULL,
	bac_si_chi_dinh_id uuid NULL,
	ma_benh_nhan varchar(100) NULL,
	so_benh_an varchar(100) NULL,
	so_phieu varchar(100) NULL,
	ngay_sinh varchar(100) NULL,
	gioi_tinh varchar(100) NULL,
	chuyen_khoa_id uuid NULL,
	ma_loai_dich_vu varchar(100) NULL,
	benh_an_id uuid NULL,
	kham_benh_id uuid NULL,
	ma_loai_pttt varchar(100) NULL,
	ten_loai_pttt varchar(100) NULL,
	is_check_ptv bool DEFAULT false NOT NULL,
	CONSTRAINT pttt_phieu_duyet_mo_pkey PRIMARY KEY (id)
);

CREATE TABLE pttt_phieu_nhap_lieu (
	id uuid DEFAULT gen_random_uuid() NOT NULL,
	ma_bieu_mau varchar(50) NULL,
	tiep_nhan_id uuid NULL,
	khoa_id uuid NULL,
	phong_id uuid NULL,
	benh_nhan_id uuid NULL,
	ten_benh_nhan varchar(255) NULL,
	json_data jsonb NULL,
	trang_thai_ky_so varchar(25) DEFAULT 'CHO_KY'::character varying NULL,
	ngay_thuc_hien timestamp NULL,
	ngay_phau_thuat timestamp NULL,
	nguoi_ky varchar(100) NULL,
	ngay_ky timestamp NULL,
	nguoi_duyet varchar(100) NULL,
	ngay_duyet timestamp NULL,
	ma_cskcb varchar(20) NOT NULL,
	bi_xoa int2 DEFAULT 0 NOT NULL,
	ngay_xoa timestamp NULL,
	nguoi_xoa varchar(100) NULL,
	ngay_tao timestamp DEFAULT CURRENT_TIMESTAMP NOT NULL,
	nguoi_tao varchar(100) NOT NULL,
	ngay_cap_nhat timestamp NOT NULL,
	nguoi_cap_nhat varchar(100) NOT NULL,
	hososohoa_id uuid NULL,
	CONSTRAINT pttt_phieu_nhap_lieu_pkey PRIMARY KEY (id)
);

CREATE TABLE pttt_so_thu_tu_ngay (
	id uuid DEFAULT gen_random_uuid() NOT NULL,
	ngay varchar(6) NOT NULL,
	loai varchar(50) NOT NULL,
	gia_tri_hien_tai int8 NOT NULL,
	CONSTRAINT pttt_so_thu_tu_ngay_ngay_loai_key UNIQUE (ngay, loai)
);

CREATE TABLE pttt_trinh_tu_ket_luan (
	id uuid DEFAULT gen_random_uuid() NOT NULL,
	pttt_tuong_trinh_id uuid NULL,
	chan_doan_chi_tiet_id uuid NULL,
	ten_chan_doan_chi_tiet varchar(100) NULL,
	ma_chan_doan_chi_tiet varchar(255) NULL,
	thiet_bi_id uuid NULL,
	ten_thiet_bi varchar(100) NULL,
	ma_thiet_bi varchar(255) NULL,
	nguyen_nhan_tai_nan_id uuid NULL,
	ten_nguyen_nhan_tai_nan varchar(100) NULL,
	ma_nguyen_nhan_tai_nan varchar(255) NULL,
	thoi_gian_tai_bien timestamp NULL,
	thoi_gian_tu_vong timestamp NULL,
	tai_bien bool DEFAULT false NULL,
	tu_vong bool DEFAULT false NULL,
	dien_bien_sau_mo varchar(4000) NULL,
	ket_qua varchar(4000) NULL,
	mau_luoc_do_phau_thuat_id uuid NULL,
	ma_mau_luoc_do varchar(100) NULL,
	ten_mau_luoc_do varchar(255) NULL,
	mau_luoc_do_phau_thuat_bac_si_id uuid NULL,
	mau_luoc_do_phau_thuat_ten_bac_si varchar(255) NULL,
	mau_luoc_do_phau_thuat_ma_bac_si varchar(255) NULL,
	mau_trinh_tu_phau_thuat_id uuid NULL,
	ma_mau_trinh_tu varchar(100) NULL,
	ten_mau_trinh_tu varchar(255) NULL,
	mau_trinh_tu_phau_thuat_bac_si_id uuid NULL,
	mau_trinh_tu_phau_thuat_ten_bac_si varchar(255) NULL,
	mau_trinh_tu_phau_thuat_ma_bac_si varchar(255) NULL,
	ma_cskcb varchar(20) NOT NULL,
	bi_xoa int2 DEFAULT 0 NOT NULL,
	ngay_xoa timestamp NULL,
	nguoi_xoa varchar(100) NULL,
	ngay_tao timestamp DEFAULT CURRENT_TIMESTAMP NOT NULL,
	nguoi_tao varchar(100) NOT NULL,
	ngay_cap_nhat timestamp NOT NULL,
	nguoi_cap_nhat varchar(100) NOT NULL,
	nguyen_nhan_tu_vong_id uuid NULL,
	ten_nguyen_nhan_tu_vong varchar(255) NULL,
	ma_nguyen_nhan_tu_vong varchar(100) NULL,
	noi_dung text DEFAULT ''::text NULL,
	phan_loai_vet_mo_id uuid NULL,
	ma_phan_loai_vet_mo varchar(100) NULL,
	ten_phan_loai_vet_mo varchar(100) NULL,
	giai_phau_benh bool DEFAULT false NULL
);

CREATE TABLE pttt_tt_tu_truc_temp (
	id uuid DEFAULT gen_random_uuid() NOT NULL,
	tuong_trinh_id uuid NOT NULL,
	ma_cskcb varchar(50) NOT NULL,
	thuoc_id uuid NOT NULL,
	ma_thuoc varchar(50) NOT NULL,
	ten_thuoc varchar(255) NOT NULL,
	hoat_chat varchar(255) NULL,
	ham_luong varchar(100) NULL,
	loai_thuoc varchar(100) NULL,
	don_vi_tinh varchar(50) NOT NULL,
	kho_ke varchar(100) NOT NULL,
	nguon_thuoc varchar(100) NULL,
	loai_gia varchar(50) NOT NULL,
	don_gia numeric(18, 2) NOT NULL,
	ti_le int4 DEFAULT 100 NULL,
	thanh_tien numeric(18, 2) NOT NULL,
	so_ngay int4 NULL,
	sang int4 DEFAULT 0 NULL,
	trua int4 DEFAULT 0 NULL,
	chieu int4 DEFAULT 0 NULL,
	toi int4 DEFAULT 0 NULL,
	so_luong int4 NOT NULL,
	lieu_dung varchar(255) NULL,
	cach_dung varchar(255) NULL,
	thoi_diem_dung varchar(100) NULL,
	thoi_gian_chi_dinh timestamp NOT NULL,
	bac_si_chi_dinh varchar(150) NOT NULL,
	bi_xoa int2 DEFAULT 0 NOT NULL,
	ngay_tao timestamp DEFAULT CURRENT_TIMESTAMP NULL,
	nguoi_tao varchar(100) NULL,
	ngay_cap_nhat timestamp NULL,
	nguoi_cap_nhat varchar(100) NULL,
	CONSTRAINT pttt_tt_tu_truc_temp_pkey PRIMARY KEY (id)
);

CREATE TABLE pttt_tuong_trinh (
	id uuid DEFAULT gen_random_uuid() NOT NULL,
	phieu_duyet_mo_id uuid NULL,
	ngay_thuc_hien_du_kien timestamp NULL,
	phuong_phap_vo_cam_id uuid NULL,
	phuong_phap_phau_thuat_id uuid NULL,
	ty_le_thanh_toan_dich_vu varchar(255) DEFAULT ''::character varying NULL,
	thoi_gian_bat_dau timestamp NULL,
	ngay_rut_chi timestamp NULL,
	ngay_duyet_mo timestamp NULL,
	hinh_thuc_phau_thuat_id uuid NULL,
	phuong_phap_giam_dau_id uuid NULL,
	ong_dan_luu varchar(255) DEFAULT ''::character varying NULL,
	thoi_gian_ket_thuc timestamp NULL,
	mach varchar(255) DEFAULT ''::character varying NULL,
	huyet_ap varchar(255) DEFAULT ''::character varying NULL,
	nhip_tho varchar(255) DEFAULT ''::character varying NULL,
	chieu_cao varchar(255) DEFAULT ''::character varying NULL,
	nhiet_do varchar(255) DEFAULT ''::character varying NULL,
	can_nang varchar(255) DEFAULT ''::character varying NULL,
	chan_doan_chinh varchar(255) DEFAULT ''::character varying NULL,
	chan_doan_phu varchar(255) DEFAULT ''::character varying NULL,
	danh_gia_tong_trang varchar(255) DEFAULT ''::character varying NULL,
	chan_doan_chi_tiet varchar(255) DEFAULT ''::character varying NULL,
	thiet_bi varchar(255) DEFAULT ''::character varying NULL,
	dien_bien_sau_mo varchar(255) DEFAULT ''::character varying NULL,
	dich_vu_dinh_kem jsonb NULL,
	muc_huong varchar(255) DEFAULT ''::character varying NULL,
	tai_bien bool DEFAULT false NULL,
	thoi_gian_tai_bien timestamp NULL,
	nguyen_nhan_tai_nan varchar(255) DEFAULT ''::character varying NULL,
	tu_vong bool DEFAULT false NULL,
	thoi_gian_tu_vong timestamp NULL,
	nguyen_nhan_tu_vong varchar(255) DEFAULT ''::character varying NULL,
	ket_qua varchar(255) DEFAULT ''::character varying NULL,
	trinh_tu varchar(100) DEFAULT ''::character varying NULL,
	noi_dung text DEFAULT ''::text NULL,
	luoc_do varchar(100) DEFAULT ''::character varying NULL,
	trang_thai_phieu varchar(100) DEFAULT ''::character varying NULL,
	ma_cskcb varchar(20) NOT NULL,
	bi_xoa int2 DEFAULT 0 NOT NULL,
	ngay_xoa timestamp NULL,
	nguoi_xoa varchar(100) NULL,
	ngay_tao timestamp DEFAULT CURRENT_TIMESTAMP NOT NULL,
	nguoi_tao varchar(100) NOT NULL,
	ngay_cap_nhat timestamp NOT NULL,
	nguoi_cap_nhat varchar(100) NOT NULL,
	benh_nhan_id uuid NULL,
	ten_benh_nhan varchar(255) NULL,
	ma_benh_nhan varchar(100) NULL,
	so_benh_an varchar(100) NULL,
	cccd varchar(20) NULL,
	ngay_sinh varchar(50) NULL,
	nam_sinh varchar(50) NULL,
	dia_chi varchar(1000) NULL,
	doi_tuong_id uuid NULL,
	ma_doi_tuong_bhyt varchar(100) NULL,
	ten_doi_tuong_bhyt varchar(255) NULL,
	ap_dung_tu_ngay timestamp NULL,
	ap_dung_den_ngay timestamp NULL,
	bac_si_dieu_tri_id uuid NULL,
	ten_bac_si_dieu_tri varchar(255) NULL,
	ma_bac_si_dieu_tri varchar(255) NULL,
	ma_trang_thai_benh_nhan_dieu_tri varchar(100) NULL,
	ten_trang_thai_benh_nhan_dieu_tri varchar(255) NULL,
	khoa_id uuid NULL,
	ten_khoa varchar(255) NULL,
	ma_khoa varchar(100) NULL,
	phong_id uuid NULL,
	ten_phong varchar(255) NULL,
	ma_phong varchar(100) NULL,
	giuong_id varchar(100) NULL,
	ten_giuong varchar(255) NULL,
	ma_giuong varchar(100) NULL,
	khoa_chi_dinh_id uuid NULL,
	ten_khoa_chi_dinh varchar(255) NULL,
	ma_khoa_chi_dinh varchar(100) NULL,
	bac_si_chi_dinh_id varchar(100) NULL,
	ten_bac_si_chi_dinh varchar(100) NULL,
	ma_bac_si_chi_dinh varchar(100) NULL,
	ngay_chi_dinh varchar(50) NULL,
	chan_doan_benh_chinh varchar(1000) NULL,
	chan_doan_benh_kem_theo varchar(1000) NULL,
	phieu_dich_vu_id uuid NULL,
	ma_phieu_dich_vu_chi_tiet varchar(100) NULL,
	ten_phieu_dich_vu_chi_tiet varchar(255) NULL,
	dich_vu_chi_tiet_id uuid NULL,
	ma_trang_thai_duyet_mo int4 NULL,
	phong_thuc_hien_id uuid NULL,
	ten_phong_thuc_hien varchar(255) NULL,
	ma_phong_thuc_hien varchar(100) NULL,
	chi_so_bmi varchar(50) NULL,
	dm_loai_pttt_id uuid NULL,
	ma_dm_loai_pttt varchar(100) NULL,
	ten_dm_loai_pttt varchar(255) NULL,
	mau_trinh_tu_phau_thuat_id uuid NULL,
	ma_mau_trinh_tu varchar(100) NULL,
	ten_mau_trinh_tu varchar(255) NULL,
	mau_trinh_tu_phau_thuat_bac_si_id uuid NULL,
	mau_trinh_tu_phau_thuat_ten_bac_si varchar(255) NULL,
	mau_trinh_tu_phau_thuat_ma_bac_si varchar(255) NULL,
	mau_luoc_do_phau_thuat_id uuid NULL,
	ma_mau_luoc_do varchar(100) NULL,
	ten_mau_luoc_do varchar(255) NULL,
	mau_luoc_do_phau_thuat_bac_si_id uuid NULL,
	mau_luoc_do_phau_thuat_ten_bac_si varchar(255) NULL,
	mau_luoc_do_phau_thuat_ma_bac_si varchar(255) NULL,
	mo_cap_cuu varchar(100) NULL,
	duyet_mo varchar(100) NULL,
	so_dien_thoai varchar(100) NULL,
	gioi_tinh varchar(100) NULL,
	ma_gioi_tinh varchar(100) NULL,
	ten_gioi_tinh varchar(100) NULL,
	tyle_thanh_toan_dich_vu_id uuid NULL,
	ten_thanh_toan varchar(255) NULL,
	ma_thanh_toan varchar(100) NULL,
	pttt_tyle_thanh_toan_dich_vu_id uuid NULL,
	pttt_ten_thanh_toan varchar(255) NULL,
	pttt_ma_thanh_toan varchar(100) NULL,
	tu_vong_id uuid NULL,
	ma_nguyen_nhan_tu_vong varchar(100) NULL,
	ten_nguyen_nhan_tu_vong varchar(255) NULL,
	trang_thiet_bi_id uuid NULL,
	ma_trang_thiet_bi varchar(100) NULL,
	ten_trang_thiet_bi varchar(255) NULL,
	icd9_id uuid NULL,
	ma_chuong_icd9 varchar(100) NULL,
	ten_chuong_icd9 varchar(255) NULL,
	tai_nan_thuong_tich_id uuid NULL,
	ma_tai_nan_thuong_tich varchar(100) NULL,
	ten_tai_nan_thuong_tich varchar(255) NULL,
	so_the_bhyt varchar(50) NULL,
	ten_phuong_phap_vo_cam varchar(100) NULL,
	ma_phuong_phap_vo_cam varchar(50) NULL,
	so_phieu varchar(50) NULL,
	khoa_thuc_hien_id uuid NULL,
	ma_khoa_thuc_hien varchar(100) NULL,
	ten_khoa_thuc_hien varchar(255) NULL,
	vi_tri_thuc_hien_pttt_id uuid NULL,
	ten_vi_tri_thuc_hien_pttt varchar(255) NULL,
	ma_vi_tri_thuc_hien_pttt varchar(100) NULL,
	tiep_nhan_id uuid NULL,
	hososohoa_id uuid NULL,
	kham_benh_id uuid NULL,
	phan_loai_vet_mo_id uuid NULL,
	ma_phan_loai_vet_mo varchar(100) NULL,
	ten_phan_loai_vet_mo varchar(100) NULL,
	giai_phau_benh int4 NULL,
	giuong_dieu_tri_id uuid NULL,
	ma_giuong_dieu_tri varchar(100) NULL,
	ten_giuong_dieu_tri varchar(255) NULL,
	phong_dieu_tri_id uuid NULL,
	ten_phong_dieu_tri varchar(100) NULL,
	ma_phong_dieu_tri varchar(255) NULL,
	khoa_dieu_tri_id uuid NULL,
	ma_khoa_dieu_tri varchar(100) NULL,
	ten_khoa_dieu_tri varchar(255) NULL,
	loai_dich_vu_id uuid NULL,
	ma_loai_dich_vu varchar(100) NULL,
	ten_loai_dich_vu varchar(255) NULL,
	ten_phuong_phap_phau_thuat varchar(255) NULL,
	ma_phuong_phap_phau_thuat varchar(100) NULL,
	trang_thai_ky_so varchar(100) NULL,
	benh_an_id uuid NULL,
	CONSTRAINT pttt_tuong_trinh_pkey PRIMARY KEY (id)
);

CREATE TABLE pttt_tuong_trinh_dich_vu (
	id uuid DEFAULT gen_random_uuid() NOT NULL,
	pttt_tuong_trinh_id uuid NULL,
	phieu_dich_vu_chi_tiet_id uuid NULL,
	ma_cskcb varchar(20) NOT NULL,
	bi_xoa int2 DEFAULT 0 NOT NULL,
	ngay_xoa timestamp NULL,
	nguoi_xoa varchar(100) NULL,
	ngay_tao timestamp DEFAULT CURRENT_TIMESTAMP NOT NULL,
	nguoi_tao varchar(100) NOT NULL,
	ngay_cap_nhat timestamp NOT NULL,
	nguoi_cap_nhat varchar(100) NOT NULL,
	ten_dich_vu varchar(255) NULL,
	ma_dich_vu varchar(100) NULL,
	ty_le_thanh_toan_dich_vu_id uuid NULL,
	ma_ty_le_thanh_toan_dich_vu varchar(255) NULL,
	ten_ty_le_thanh_toan_dich_vu varchar(100) NULL,
	nhom_dich_vu_id uuid NULL,
	ten_nhom_dich_vu varchar(255) NULL,
	ma_nhom_dich_vu varchar(100) NULL,
	icd9_id uuid NULL,
	ten_benh_icd9 varchar(255) NULL,
	ma_benh_icd9 varchar(100) NULL,
	dm_loai_pttt_id uuid NULL,
	ma_dm_loai_pttt varchar(100) NULL,
	ten_dm_loai_pttt varchar(255) NULL,
	CONSTRAINT pttt_tuong_trinh_dich_vu_pkey PRIMARY KEY (id)
);

CREATE TABLE pttt_tuong_trinh_ekip_mo (
	id uuid DEFAULT gen_random_uuid() NOT NULL,
	tuong_trinh_id uuid NOT NULL,
	vai_tro_id uuid NULL,
	ten_vai_tro varchar NULL,
	bac_si_id uuid NULL,
	ten_bac_si varchar NULL,
	khoa_id uuid NULL,
	ten_khoa varchar NULL,
	chuc_danh_id uuid NULL,
	ten_chuc_danh varchar NULL,
	thu_tu int4 NULL,
	ma_cskcb varchar(20) NOT NULL,
	bi_xoa int2 DEFAULT 0 NOT NULL,
	ngay_xoa timestamp NULL,
	nguoi_xoa varchar(100) NULL,
	ngay_tao timestamp DEFAULT CURRENT_TIMESTAMP NOT NULL,
	nguoi_tao varchar(100) NOT NULL,
	ngay_cap_nhat timestamp NOT NULL,
	nguoi_cap_nhat varchar(100) NOT NULL,
	trang_thai_duyet varchar(20) NULL,
	nguoi_duyet varchar(100) NULL,
	ngay_duyet timestamp NULL,
	nguoi_huy_duyet varchar(100) NULL,
	ngay_huy_duyet timestamp NULL,
	CONSTRAINT pttt_tuong_trinh_ekip_mo_pkey PRIMARY KEY (id)
);

CREATE TABLE pttt_tuong_trinh_file_hinh_anh (
	id uuid DEFAULT gen_random_uuid() NOT NULL,
	pttt_tuong_trinh_id uuid NOT NULL,
	file_id uuid NOT NULL,
	ma_cskcb varchar(20) NOT NULL,
	bi_xoa int2 DEFAULT 0 NOT NULL,
	ngay_xoa timestamp NULL,
	nguoi_xoa varchar(100) NULL,
	ngay_tao timestamp DEFAULT CURRENT_TIMESTAMP NOT NULL,
	nguoi_tao varchar(100) NOT NULL,
	ngay_cap_nhat timestamp NOT NULL,
	nguoi_cap_nhat varchar(100) NOT NULL,
	is_check bool DEFAULT false NULL,
	mo_ta text DEFAULT ''::text NULL,
	CONSTRAINT pttt_tuong_trinh_file_hinh_anh_pkey PRIMARY KEY (id)
);

CREATE TABLE pttt_tuong_trinh_mau_luoc_do_phau_thuat (
	pttt_tuong_trinh_id uuid NULL,
	ma_mau_luoc_do varchar(100) NULL,
	ten_mau_luoc_do varchar(255) NULL,
	mau_luoc_do_phau_thuat_ten_bac_si varchar(255) NULL,
	mau_luoc_do_phau_thuat_ma_bac_si varchar(100) NULL,
	mau_luoc_do_phau_thuat_bac_si_id uuid NULL,
	id uuid DEFAULT gen_random_uuid() NOT NULL,
	ma_cskcb varchar(20) NOT NULL,
	bi_xoa int2 DEFAULT 0 NOT NULL,
	ngay_xoa timestamp NULL,
	nguoi_xoa varchar(100) NULL,
	ngay_tao timestamp DEFAULT CURRENT_TIMESTAMP NOT NULL,
	nguoi_tao varchar(100) NOT NULL,
	ngay_cap_nhat timestamp NOT NULL,
	nguoi_cap_nhat varchar(100) NOT NULL,
	CONSTRAINT pttt_tuong_trinh_mau_luoc_do_phau_thuat_pkey PRIMARY KEY (id)
);

CREATE TABLE pttt_tuong_trinh_mau_luoc_do_phau_thuat_file (
	pttt_tuong_trinh_mau_luoc_do_phau_thuat_id uuid NULL,
	file_id uuid NOT NULL,
	is_check bool DEFAULT false NULL,
	mo_ta text DEFAULT ''::text NULL,
	id uuid DEFAULT gen_random_uuid() NOT NULL,
	ma_cskcb varchar(20) NOT NULL,
	bi_xoa int2 DEFAULT 0 NOT NULL,
	ngay_xoa timestamp NULL,
	nguoi_xoa varchar(100) NULL,
	ngay_tao timestamp DEFAULT CURRENT_TIMESTAMP NOT NULL,
	nguoi_tao varchar(100) NOT NULL,
	ngay_cap_nhat timestamp NOT NULL,
	nguoi_cap_nhat varchar(100) NOT NULL,
	CONSTRAINT pttt_tuong_trinh_mau_luoc_do_phau_thuat_file_pkey PRIMARY KEY (id)
);

CREATE TABLE pttt_tuong_trinh_mau_trinh_tu_phau_thuat (
	pttt_tuong_trinh_id uuid NULL,
	ma_mau_trinh_tu varchar(100) NULL,
	ten_mau_trinh_tu varchar(255) NULL,
	mau_trinh_tu_phau_thuat_ten_bac_si varchar(255) NULL,
	mau_trinh_tu_phau_thuat_ma_bac_si varchar(100) NULL,
	mau_trinh_tu_phau_thuat_bac_si_id uuid NULL,
	id uuid DEFAULT gen_random_uuid() NOT NULL,
	ma_cskcb varchar(20) NOT NULL,
	bi_xoa int2 DEFAULT 0 NOT NULL,
	ngay_xoa timestamp NULL,
	nguoi_xoa varchar(100) NULL,
	ngay_tao timestamp DEFAULT CURRENT_TIMESTAMP NOT NULL,
	nguoi_tao varchar(100) NOT NULL,
	ngay_cap_nhat timestamp NOT NULL,
	nguoi_cap_nhat varchar(100) NOT NULL,
	trinh_tu_phau_thuat_noi_dung text NULL,
	mau_trinh_tu_phau_thuat varchar(100) NULL,
	CONSTRAINT pttt_tuong_trinh_mau_trinh_tu_phau_thuat_pkey PRIMARY KEY (id)
);

CREATE TABLE ql_so_tuan_tu (
	prefix varchar(100) NOT NULL,
	so_hien_tai int4 DEFAULT 0 NOT NULL,
	ref_table varchar(100) NULL,
	id uuid DEFAULT gen_random_uuid() NOT NULL,
	ngay_tao timestamp DEFAULT now() NOT NULL,
	nguoi_tao varchar(100) DEFAULT 'system'::character varying NOT NULL,
	ngay_cap_nhat timestamp DEFAULT now() NOT NULL,
	nguoi_cap_nhat varchar(100) DEFAULT 'system'::character varying NOT NULL,
	bi_xoa int2 DEFAULT 0 NULL,
	ngay_xoa timestamp NULL,
	nguoi_xoa varchar(100) NULL,
	ma_cskcb varchar(5) NULL,
	CONSTRAINT ql_so_tuan_tu_pkey PRIMARY KEY (id),
	CONSTRAINT ql_so_tuan_tu_prefix_ref_table_ma_cskcb_key UNIQUE (prefix, ref_table, ma_cskcb)
);

CREATE TABLE r_soluongtmp (
	"coalesce" numeric NULL
);

CREATE TABLE sample_module_doi_tuong (
	id uuid DEFAULT gen_random_uuid() NOT NULL,
	ma varchar(25) NULL, -- Mã đối tượng
	ten varchar(255) NULL, -- Tên đối tượng
	nhomdoituong_id numeric NULL, -- Nhóm đối tượng id
	nhomthe varchar(255) NULL, -- Nhóm thẻ
	muc_huong numeric NULL, -- Mức hưởng
	tyle_vuot_lcb numeric NULL, -- Tỷ lệ vượt lương cơ bản
	tyle_traituyen numeric NULL, -- Tỷ lệ trái tuyến
	gioihan_vuot_lcb numeric NULL, -- Giới hạn vượt lương cơ bản
	luong_coso numeric NULL, -- Lương cơ sở
	gioihan_vuot_dvktc numeric NULL, -- Giới hạn vượt dịch vụ kỹ thuật chính
	tyle_thuoc_ut numeric NULL, -- Tỷ lệ thuốc
	chiphingoai_bhyt numeric NULL, -- Chi phí ngoài BHYT
	sudung bool NULL, -- Sử dụng(0: Không; 1: Có)
	ngay_tao timestamp DEFAULT CURRENT_TIMESTAMP NOT NULL, -- Ngày tạo dữ liệu
	nguoi_tao text NOT NULL, -- Người tạo dữ liệu
	ngay_cap_nhat timestamp DEFAULT CURRENT_TIMESTAMP NOT NULL, -- Ngày sửa dữ liệu
	nguoi_cap_nhat text NOT NULL, -- Người sửa dữ liệu
	ma_cskcb varchar(100) NULL,
	bi_xoa int2 DEFAULT 0 NOT NULL,
	ngay_xoa timestamp NULL,
	nguoi_xoa varchar(100) NULL,
	is_bhyt int2 NULL,
	CONSTRAINT sample_module_doi_tuong_pkey PRIMARY KEY (id)
);

CREATE TABLE sample_orders (
	id int8 GENERATED ALWAYS AS IDENTITY( INCREMENT BY 1 MINVALUE 1 MAXVALUE 9223372036854775807 START 1 CACHE 1 NO CYCLE) NOT NULL,
	order_number varchar(50) NOT NULL,
	user_id int8 NOT NULL,
	description varchar(500) NULL,
	amount numeric(10, 2) NOT NULL,
	status varchar(20) DEFAULT 'PENDING'::character varying NOT NULL,
	created_at timestamp DEFAULT CURRENT_TIMESTAMP NOT NULL,
	updated_at timestamp DEFAULT CURRENT_TIMESTAMP NOT NULL,
	CONSTRAINT sample_orders_order_number_key UNIQUE (order_number),
	CONSTRAINT sample_orders_pkey PRIMARY KEY (id)
);

CREATE TABLE sig_certificate (
	id uuid DEFAULT gen_random_uuid() NOT NULL,
	provider_name varchar(200) NULL,
	provider_code varchar(50) NOT NULL,
	username varchar(50) NULL,
	serial_number varchar(50) NOT NULL,
	cert_type varchar(50) NULL,
	cert_subject varchar(500) NULL,
	cert_valid_from date NULL,
	cert_valid_to date NULL,
	cert_status varchar(10) NOT NULL,
	cert_otp_key varchar(500) NULL,
	sign_image text NULL,
	status int4 DEFAULT 1 NOT NULL,
	is_deleted int4 DEFAULT 0 NOT NULL,
	create_date timestamp DEFAULT CURRENT_TIMESTAMP NOT NULL,
	update_date timestamp NULL,
	create_by varchar(50) NOT NULL,
	update_by varchar(50) NULL,
	regis_cert text NULL, -- public key
	ejbca_cert text NULL,
	regis_private_key text NULL,
	cccd varchar(50) NULL,
	loai_hinh varchar(50) NULL
);

CREATE TABLE sig_certificate_khoa (
	id uuid NOT NULL,
	certificate_id uuid NOT NULL,
	khoa_id uuid NOT NULL,
	is_deleted int4 DEFAULT 0 NOT NULL,
	create_date timestamp DEFAULT CURRENT_TIMESTAMP NOT NULL,
	update_date timestamp NULL,
	create_by varchar(50) NOT NULL,
	update_by varchar(50) NULL
);

CREATE TABLE sinh_ma_tu_dong (
	id uuid DEFAULT gen_random_uuid() NOT NULL,
	loai_ma varchar NOT NULL,
	ma_cskcb varchar NULL,
	ngay_hien_tai date NULL,
	ngay varchar NULL,
	thang varchar NULL,
	nam varchar NULL,
	stt_hien_tai numeric NOT NULL,
	bi_xoa int2 DEFAULT 0 NOT NULL,
	ngay_xoa timestamp NULL,
	nguoi_xoa varchar(100) NULL,
	ngay_tao timestamp DEFAULT CURRENT_TIMESTAMP NULL,
	nguoi_tao varchar NULL,
	ngay_cap_nhat timestamp NULL,
	nguoi_cap_nhat varchar NULL,
	CONSTRAINT sinh_ma_tu_dong_pkey PRIMARY KEY (id)
);

CREATE TABLE sys_account (
	id uuid DEFAULT gen_random_uuid() NOT NULL,
	ten_dang_nhap varchar(100) NOT NULL,
	ma_cskcb varchar(50) NULL,
	mat_khau varchar(255) NOT NULL,
	hoat_dong int4 DEFAULT 1 NOT NULL,
	bi_xoa int2 DEFAULT 0 NOT NULL,
	ngay_tao timestamp DEFAULT now() NOT NULL,
	nguoi_tao varchar(100) NOT NULL,
	ngay_cap_nhat timestamp DEFAULT now() NOT NULL,
	nguoi_cap_nhat varchar(100) NULL,
	ngay_xoa timestamp NULL,
	nguoi_xoa varchar(100) NULL,
	CONSTRAINT sys_account_pkey PRIMARY KEY (id),
	CONSTRAINT sys_account_ten_dang_nhap_key UNIQUE (ten_dang_nhap)
);

CREATE TABLE sys_bang_tham_chieu (
	id uuid DEFAULT gen_random_uuid() NOT NULL,
	bang_tham_chieu varchar(100) NOT NULL,
	cot_tham_chieu varchar(100) NOT NULL,
	bang_su_dung varchar(100) NOT NULL,
	cot_su_dung varchar(100) NOT NULL,
	ngay_tao timestamp DEFAULT CURRENT_TIMESTAMP NULL,
	nguoi_tao text NULL,
	ngay_cap_nhap timestamp DEFAULT CURRENT_TIMESTAMP NULL,
	nguoi_cap_nhap text NULL,
	su_dung bool DEFAULT true NULL,
	bi_xoa int2 DEFAULT 0 NULL,
	CONSTRAINT sys_bang_tham_chieu_pkey PRIMARY KEY (id)
);

CREATE TABLE sys_log_3rd (
	id uuid DEFAULT gen_random_uuid() NOT NULL,
	ma_cskcb varchar(50) NULL,
	created_at timestamp(6) DEFAULT now() NULL,
	created_by varchar(100) NULL,
	note varchar(500) NULL,
	transaction_id varchar(255) NULL,
	service_code varchar(255) NOT NULL,
	request_account varchar(255) NOT NULL,
	request_count int2 DEFAULT 1 NULL,
	request_url varchar(1000) NULL,
	"method" varchar(10) NULL,
	request_payload text NULL,
	response_payload text NULL,
	response_time int4 NULL,
	response_http_code varchar(50) NULL,
	response_code varchar(20) NULL,
	response_message varchar(1000) NULL,
	is_test bool DEFAULT false NULL,
	is_3rd_deleted bool DEFAULT false NULL,
	CONSTRAINT sys_log_3rd_pkey PRIMARY KEY (id)
);

CREATE TABLE sys_nhat_ky_dong_bo_vung_trong (
	id uuid DEFAULT gen_random_uuid() NOT NULL,
	loai varchar NOT NULL,
	trang_thai int2 DEFAULT 0 NULL,
	yeu_cau jsonb NULL,
	phan_hoi jsonb NULL,
	chi_tiet_loi text NULL,
	correlation_id varchar NULL,
	thoi_gian_dong_bo timestamp DEFAULT now() NULL,
	CONSTRAINT ksk_nhat_ky_dong_bo_pk PRIMARY KEY (id)
);

CREATE TABLE sys_nhom_quyen_du_lieu (
	id uuid DEFAULT gen_random_uuid() NOT NULL,
	ma_cskcb varchar(50) NULL,
	ma varchar(50) NOT NULL,
	ten varchar(50) NOT NULL,
	ghi_chu text NULL,
	hoat_dong int2 DEFAULT 1 NOT NULL,
	bi_xoa int2 DEFAULT 0 NOT NULL,
	ngay_tao timestamp DEFAULT now() NOT NULL,
	nguoi_tao varchar(100) NOT NULL,
	ngay_cap_nhat timestamp DEFAULT now() NOT NULL,
	nguoi_cap_nhat varchar(100) NULL,
	ngay_xoa timestamp NULL,
	nguoi_xoa varchar(100) NULL,
	nhom_ung_dung_id uuid NULL,
	CONSTRAINT sys_nhom_quyen_du_lieu_pkey PRIMARY KEY (id),
	CONSTRAINT sys_nhom_quyen_du_lieu_ten_key UNIQUE (ten)
);

CREATE TABLE sys_nhom_quyen_dulieu_dtg_benhnhan_mapping (
	sys_nhom_quyen_du_lieu_id uuid DEFAULT gen_random_uuid() NOT NULL,
	dm_dtg_benhnhan_id uuid DEFAULT gen_random_uuid() NOT NULL,
	dm_dtg_benhnhan_ma varchar NOT NULL,
	nguoi_tao varchar(100) DEFAULT 'system'::character varying NOT NULL,
	ngay_tao timestamp DEFAULT now() NOT NULL,
	CONSTRAINT sys_nhom_quyen_dulieu_dtg_benhnhan_mapping_pkey PRIMARY KEY (sys_nhom_quyen_du_lieu_id, dm_dtg_benhnhan_id)
);

CREATE TABLE sys_nhom_quyen_dulieu_kho_duoc_mapping (
	sys_nhom_quyen_du_lieu_id uuid DEFAULT gen_random_uuid() NOT NULL,
	dm_kho_duoc_id uuid DEFAULT gen_random_uuid() NOT NULL,
	nguoi_tao varchar(100) DEFAULT 'system'::character varying NOT NULL,
	ngay_tao timestamp DEFAULT now() NOT NULL,
	dm_kho_duoc_ma varchar NULL,
	CONSTRAINT sys_nhom_quyen_dulieu_kho_duoc_mapping_pkey PRIMARY KEY (sys_nhom_quyen_du_lieu_id, dm_kho_duoc_id)
);

CREATE TABLE sys_nhom_quyen_dulieu_khoa_mapping (
	sys_nhom_quyen_du_lieu_id uuid DEFAULT gen_random_uuid() NOT NULL,
	dm_khoa_id uuid DEFAULT gen_random_uuid() NOT NULL,
	nguoi_tao varchar(100) DEFAULT 'system'::character varying NOT NULL,
	ngay_tao timestamp DEFAULT now() NOT NULL,
	dm_khoa_ma varchar NULL,
	CONSTRAINT sys_nhom_quyen_dulieu_khoa_mapping_pkey PRIMARY KEY (sys_nhom_quyen_du_lieu_id, dm_khoa_id)
);

CREATE TABLE sys_nhom_quyen_dulieu_loai_ke_don_mapping (
	sys_nhom_quyen_du_lieu_id uuid DEFAULT gen_random_uuid() NOT NULL,
	dm_loai_ke_don_id uuid DEFAULT gen_random_uuid() NOT NULL,
	dm_loai_ke_don_ma varchar NOT NULL,
	nguoi_tao varchar(100) DEFAULT 'system'::character varying NOT NULL,
	ngay_tao timestamp DEFAULT now() NOT NULL,
	CONSTRAINT sys_nhom_quyen_dulieu_loai_ke_don_mapping_pkey PRIMARY KEY (sys_nhom_quyen_du_lieu_id, dm_loai_ke_don_id)
);

CREATE TABLE sys_nhom_quyen_dulieu_phong_mapping (
	sys_nhom_quyen_du_lieu_id uuid DEFAULT gen_random_uuid() NOT NULL,
	dm_phong_id uuid DEFAULT gen_random_uuid() NOT NULL,
	nguoi_tao varchar(100) DEFAULT 'system'::character varying NOT NULL,
	ngay_tao timestamp DEFAULT now() NOT NULL,
	dm_phong_ma varchar NULL,
	CONSTRAINT sys_nhom_quyen_dulieu_phong_mapping_pkey PRIMARY KEY (sys_nhom_quyen_du_lieu_id, dm_phong_id)
);

CREATE TABLE sys_user_workspace (
	id varchar(40) NOT NULL, -- Session ID (sid), dùng làm key cache và PK
	tai_khoan_id varchar(40) NULL,
	pl_user_id uuid NOT NULL,
	ma_tenant varchar(100) NOT NULL,
	ma_cskcb varchar(100) NOT NULL,
	ma_khoa varchar(100) NULL, -- Mã khoa đã chọn; id/uuid resolve qua dm_khoa khi đọc
	ma_phong varchar(100) NULL, -- Mã phòng đã chọn; id/uuid resolve qua dm_phong khi đọc
	khoa_uuid uuid NULL, -- UUID khoa đã chọn (dm_khoa.id); dùng cho query/join
	phong_uuid uuid NULL, -- UUID phòng đã chọn (dm_phong.id); dùng cho query/join
	ca_lam_viec_id uuid NULL, -- ID ca làm việc (tham chiếu csyt_ca_lam_viec.id; FK thêm sau nếu cần)
	payload jsonb DEFAULT '{}'::jsonb NULL, -- Metadata mở rộng theo phiên; put/get theo key
	nguoi_tao varchar(100) DEFAULT 'system'::character varying NOT NULL,
	ngay_tao timestamp DEFAULT CURRENT_TIMESTAMP NOT NULL,
	nguoi_cap_nhat varchar(100) NULL,
	ngay_cap_nhat timestamp DEFAULT CURRENT_TIMESTAMP NOT NULL,
	da_dang_xuat bool DEFAULT false NOT NULL, -- true khi user đã logout workspace theo sid (revoke)
	ngay_dang_xuat timestamp NULL, -- Thời điểm đánh dấu logout workspace
	ma_nhom_ung_dung varchar(100) NULL,
	ma_ung_dung varchar(100) NULL, -- Mã ứng dụng
	CONSTRAINT sys_user_workspace_pkey PRIMARY KEY (id)
);

CREATE TABLE tai_khoan_tich_hop (
	id uuid DEFAULT gen_random_uuid() NOT NULL,
	loai_tich_hop varchar(50) NOT NULL,
	ma_cskcb varchar(50) NOT NULL,
	username varchar(100) NOT NULL,
	"password" varchar(255) NOT NULL,
	"token" text NULL,
	id_token varchar(255) NULL,
	"domain" varchar(255) NOT NULL,
	endpoint varchar(255) NOT NULL,
	hoat_dong int2 DEFAULT 1 NOT NULL,
	bi_xoa int2 DEFAULT 0 NOT NULL,
	ngay_xoa timestamp NULL,
	nguoi_xoa varchar(100) NULL,
	ngay_tao timestamp DEFAULT CURRENT_TIMESTAMP NOT NULL,
	nguoi_tao varchar(100) NULL,
	ngay_cap_nhat timestamp DEFAULT now() NOT NULL,
	nguoi_cap_nhat varchar(100) NULL,
	CONSTRAINT tai_khoan_tich_hop_loai_tich_hop_ma_cskcb_username_endpoint_key UNIQUE (loai_tich_hop, ma_cskcb, username, endpoint),
	CONSTRAINT tai_khoan_tich_hop_pkey PRIMARY KEY (id)
);

CREATE TABLE temp_icd10 (
	text_1 varchar(500) NULL, -- STT
	text_2 varchar(500) NULL, -- STT CHƯƠNG
	text_3 varchar(500) NULL, -- PHẠM VI MÃ NHÓM BỆNH
	text_4 varchar(500) NULL, -- CHAPTER NAME
	text_5 varchar(500) NULL, -- TÊN CHƯƠNG
	text_6 varchar(500) NULL, -- MÃ KHỐI
	text_7 varchar(500) NULL, -- BLOCK NAME
	text_8 varchar(500) NULL, -- TÊN KHỐI
	text_9 varchar(500) NULL, -- MÃ TIỂU KHỐI CẤP 1
	text_10 varchar(500) NULL, -- FIRST SUB-DIVISION NAME
	text_11 varchar(500) NULL, -- TÊN TIỂU KHỐI CẤP 1
	text_12 varchar(500) NULL, -- MÃ TIỂU KHỐI CẤP 2
	text_13 varchar(500) NULL, -- SECOND SUB-DIVISION NAME
	text_14 varchar(500) NULL, -- TÊN TIỂU KHỐI CẤP 2
	text_15 varchar(500) NULL, -- MÃ NHÓM BỆNH 3 KÝ TỰ
	text_16 varchar(500) NULL, -- 3-CHARACTER SUB-CATEGORY NAME
	text_17 varchar(500) NULL, -- TÊN NHÓM BỆNH 3 KÝ TỰ
	text_18 varchar(500) NULL, -- MÃ BỆNH
	text_19 varchar(500) NULL, -- MÃ BỆNH KHÔNG DẤU
	text_20 varchar(500) NULL, -- DISEASE NAME WHO 2019 (ENGLISH)
	text_21 varchar(500) NULL, -- ADDITIONAL CODING GUIDANCE WHO 2019 (ENGLISH)
	text_22 varchar(500) NULL, -- TÊN BỆNH
	text_23 varchar(500) NULL, -- HƯỚNG DẪN MÃ HÓA BỔ SUNG CỦA WHO 2019
	text_24 varchar(500) NULL, -- MÃ KHÔNG ĐƯỢC DÙNG LÀ BỆNH CHÍNH
	text_25 varchar(500) NULL, -- MÃ KHÔNG KHUYẾN KHÍCH DÙNG LÀ BỆNH CHÍNH
	text_26 varchar(500) NULL, -- MÃ KHÔNG ĐƯỢC SỬ DỤNG VÌ CÓ MÃ 4 HOẶC 5 KÝ TỰ CỤ THỂ HƠN
	text_27 varchar(500) NULL, -- CHỈ SỬ DỤNG MÃ HÓA NGUYÊN NHÂN TỬ VONG
	text_28 varchar(500) NULL, -- CÁC MÃ BỆNH CHỈ CÓ HOẶC CHỦ YẾU CÓ Ở NỮ GIỚI
	text_29 varchar(500) NULL, -- CÁC MÃ BỆNH CHỈ CÓ HOẶC CHỦ YẾU CÓ Ở NAM GIỚI
	text_30 varchar(500) NULL -- Cột dữ liệu 30
);

CREATE TABLE tes_321 (
	test_col text NULL, -- test_col
	id uuid DEFAULT gen_random_uuid() NOT NULL, -- Key của bảng
	ngay_tao timestamp DEFAULT now() NOT NULL, -- Ngày tạo
	nguoi_tao varchar(100) DEFAULT 'system'::character varying NOT NULL, -- Người tạo
	ngay_cap_nhat timestamp DEFAULT now() NOT NULL, -- Ngày cập nhật
	nguoi_cap_nhat varchar(100) DEFAULT 'system'::character varying NOT NULL, -- Người cập nhật
	bi_xoa int2 DEFAULT 0 NULL, -- Bị xóa mềm
	ngay_xoa timestamp NULL, -- Ngày xóa mềm
	nguoi_xoa varchar(100) NULL, -- Người xóa mềm
	test_col_2 varchar(100) NOT NULL, -- Test cột 2
	CONSTRAINT tes_321_pkey PRIMARY KEY (id)
);

CREATE TABLE tesssting123 (
	tesssting123 uuid NULL,
	id uuid DEFAULT gen_random_uuid() NOT NULL, -- Key của bảng
	ngay_tao timestamp DEFAULT now() NOT NULL, -- Ngày tạo
	nguoi_tao varchar(100) DEFAULT 'system'::character varying NOT NULL, -- Người tạo
	ngay_cap_nhat timestamp DEFAULT now() NOT NULL, -- Ngày cập nhật
	nguoi_cap_nhat varchar(100) DEFAULT 'system'::character varying NOT NULL, -- Người cập nhật
	bi_xoa int2 DEFAULT 0 NULL, -- Bị xóa mềm
	ngay_xoa timestamp NULL, -- Ngày xóa mềm
	nguoi_xoa varchar(100) NULL, -- Người xóa mềm
	CONSTRAINT tesssting123_pkey PRIMARY KEY (id)
);

CREATE TABLE tesst (
	tesst varchar NULL,
	id uuid DEFAULT gen_random_uuid() NOT NULL, -- Key của bảng
	ngay_tao timestamp DEFAULT now() NOT NULL, -- Ngày tạo
	nguoi_tao varchar(100) DEFAULT 'system'::character varying NOT NULL, -- Người tạo
	ngay_cap_nhat timestamp DEFAULT now() NOT NULL, -- Ngày cập nhật
	nguoi_cap_nhat varchar(100) DEFAULT 'system'::character varying NOT NULL, -- Người cập nhật
	bi_xoa int2 DEFAULT 0 NULL, -- Bị xóa mềm
	ngay_xoa timestamp NULL, -- Ngày xóa mềm
	nguoi_xoa varchar(100) NULL, -- Người xóa mềm
	CONSTRAINT tesst_pkey PRIMARY KEY (id)
);

CREATE TABLE tesst123 (
	tesst123 uuid NULL,
	id uuid DEFAULT gen_random_uuid() NOT NULL, -- Key của bảng
	ngay_tao timestamp DEFAULT now() NOT NULL, -- Ngày tạo
	nguoi_tao varchar(100) DEFAULT '''system'''::character varying NOT NULL, -- Người tạo
	ngay_cap_nhat timestamp DEFAULT now() NOT NULL, -- Ngày cập nhật
	nguoi_cap_nhat varchar(100) DEFAULT '''system'''::character varying NOT NULL, -- Người cập nhật
	bi_xoa int2 DEFAULT 0 NULL, -- Bị xóa mềm
	ngay_xoa timestamp NULL, -- Ngày xóa mềm
	nguoi_xoa varchar(100) NULL, -- Người xóa mềm
	CONSTRAINT tesst123_pkey PRIMARY KEY (id)
);

CREATE TABLE tesst_123 (
	tesst_123 varchar NULL,
	id uuid DEFAULT gen_random_uuid() NOT NULL, -- Key của bảng
	ngay_tao timestamp DEFAULT now() NOT NULL, -- Ngày tạo
	nguoi_tao varchar(100) DEFAULT 'system'::character varying NOT NULL, -- Người tạo
	ngay_cap_nhat timestamp DEFAULT now() NOT NULL, -- Ngày cập nhật
	nguoi_cap_nhat varchar(100) DEFAULT 'system'::character varying NOT NULL, -- Người cập nhật
	bi_xoa int2 DEFAULT 0 NULL, -- Bị xóa mềm
	ngay_xoa timestamp NULL, -- Ngày xóa mềm
	nguoi_xoa varchar(100) NULL, -- Người xóa mềm
	CONSTRAINT tesst_123_pkey PRIMARY KEY (id)
);

CREATE TABLE tesst_123_thang (
	aaa uuid NULL,
	id uuid DEFAULT gen_random_uuid() NOT NULL, -- Key của bảng
	ngay_tao timestamp DEFAULT now() NOT NULL, -- Ngày tạo
	nguoi_tao varchar(100) DEFAULT 'system'::character varying NOT NULL, -- Người tạo
	ngay_cap_nhat timestamp DEFAULT now() NOT NULL, -- Ngày cập nhật
	nguoi_cap_nhat varchar(100) DEFAULT 'system'::character varying NOT NULL, -- Người cập nhật
	bi_xoa int2 DEFAULT 0 NULL, -- Bị xóa mềm
	ngay_xoa timestamp NULL, -- Ngày xóa mềm
	nguoi_xoa varchar(100) NULL, -- Người xóa mềm
	CONSTRAINT tesst_123_thang_pkey PRIMARY KEY (id)
);

CREATE TABLE tesst_123abcs (
	tesst_123abcs varchar NULL,
	id uuid DEFAULT gen_random_uuid() NOT NULL, -- Key của bảng
	ngay_tao timestamp DEFAULT now() NOT NULL, -- Ngày tạo
	nguoi_tao varchar(100) DEFAULT 'system'::character varying NOT NULL, -- Người tạo
	ngay_cap_nhat timestamp DEFAULT now() NOT NULL, -- Ngày cập nhật
	nguoi_cap_nhat varchar(100) DEFAULT 'system'::character varying NOT NULL, -- Người cập nhật
	bi_xoa int2 DEFAULT 0 NULL, -- Bị xóa mềm
	ngay_xoa timestamp NULL, -- Ngày xóa mềm
	nguoi_xoa varchar(100) NULL, -- Người xóa mềm
	CONSTRAINT tesst_123abcs_pkey PRIMARY KEY (id)
);

CREATE TABLE test01 (
	test01 varchar NULL, -- Test01
	id uuid DEFAULT gen_random_uuid() NOT NULL, -- Key của bảng
	ngay_tao timestamp DEFAULT now() NOT NULL, -- Ngày tạo
	nguoi_tao varchar(100) DEFAULT 'system'::character varying NOT NULL, -- Người tạo
	ngay_cap_nhat timestamp DEFAULT now() NOT NULL, -- Ngày cập nhật
	nguoi_cap_nhat varchar(100) DEFAULT 'system'::character varying NOT NULL, -- Người cập nhật
	bi_xoa int2 DEFAULT 0 NULL, -- Bị xóa mềm
	ngay_xoa timestamp NULL, -- Ngày xóa mềm
	nguoi_xoa varchar(100) NULL, -- Người xóa mềm
	CONSTRAINT test01_pkey PRIMARY KEY (id)
);

CREATE TABLE test123 (
	test123 varchar NULL,
	id uuid DEFAULT gen_random_uuid() NOT NULL, -- Key của bảng
	ngay_tao timestamp DEFAULT now() NOT NULL, -- Ngày tạo
	nguoi_tao varchar(100) DEFAULT 'system'::character varying NOT NULL, -- Người tạo
	ngay_cap_nhat timestamp DEFAULT now() NOT NULL, -- Ngày cập nhật
	nguoi_cap_nhat varchar(100) DEFAULT 'system'::character varying NOT NULL, -- Người cập nhật
	bi_xoa int2 DEFAULT 0 NULL, -- Bị xóa mềm
	ngay_xoa timestamp NULL, -- Ngày xóa mềm
	nguoi_xoa varchar(100) NULL, -- Người xóa mềm
	CONSTRAINT test123_pkey PRIMARY KEY (id)
);

CREATE TABLE test1234 (
	test1235 varchar NULL,
	id uuid DEFAULT gen_random_uuid() NOT NULL, -- Key của bảng
	ngay_tao timestamp DEFAULT now() NOT NULL, -- Ngày tạo
	nguoi_tao varchar(100) DEFAULT 'system'::character varying NOT NULL, -- Người tạo
	ngay_cap_nhat timestamp DEFAULT now() NOT NULL, -- Ngày cập nhật
	nguoi_cap_nhat varchar(100) DEFAULT 'system'::character varying NOT NULL, -- Người cập nhật
	bi_xoa int2 DEFAULT 0 NULL, -- Bị xóa mềm
	ngay_xoa timestamp NULL, -- Ngày xóa mềm
	nguoi_xoa varchar(100) NULL, -- Người xóa mềm
	CONSTRAINT test1234_pkey PRIMARY KEY (id)
);

CREATE TABLE test1235 (
	test1235 varchar NULL,
	id uuid DEFAULT gen_random_uuid() NOT NULL, -- Key của bảng
	ngay_tao timestamp DEFAULT now() NOT NULL, -- Ngày tạo
	nguoi_tao varchar(100) DEFAULT 'system'::character varying NOT NULL, -- Người tạo
	ngay_cap_nhat timestamp DEFAULT now() NOT NULL, -- Ngày cập nhật
	nguoi_cap_nhat varchar(100) DEFAULT 'system'::character varying NOT NULL, -- Người cập nhật
	bi_xoa int2 DEFAULT 0 NULL, -- Bị xóa mềm
	ngay_xoa timestamp NULL, -- Ngày xóa mềm
	nguoi_xoa varchar(100) NULL, -- Người xóa mềm
	CONSTRAINT test1235_pkey PRIMARY KEY (id)
);

CREATE TABLE test6666 (
	test6666 varchar NULL,
	id uuid DEFAULT gen_random_uuid() NOT NULL, -- Key của bảng
	ngay_tao timestamp DEFAULT now() NOT NULL, -- Ngày tạo
	nguoi_tao varchar(100) DEFAULT 'system'::character varying NOT NULL, -- Người tạo
	ngay_cap_nhat timestamp DEFAULT now() NOT NULL, -- Ngày cập nhật
	nguoi_cap_nhat varchar(100) DEFAULT 'system'::character varying NOT NULL, -- Người cập nhật
	bi_xoa int2 DEFAULT 0 NULL, -- Bị xóa mềm
	ngay_xoa timestamp NULL, -- Ngày xóa mềm
	nguoi_xoa varchar(100) NULL, -- Người xóa mềm
	CONSTRAINT test6666_pkey PRIMARY KEY (id)
);

CREATE TABLE test6666123 (
	test6666123 varchar NULL,
	id uuid DEFAULT gen_random_uuid() NOT NULL, -- Key của bảng
	ngay_tao timestamp DEFAULT now() NOT NULL, -- Ngày tạo
	nguoi_tao varchar(100) DEFAULT 'system'::character varying NOT NULL, -- Người tạo
	ngay_cap_nhat timestamp DEFAULT now() NOT NULL, -- Ngày cập nhật
	nguoi_cap_nhat varchar(100) DEFAULT 'system'::character varying NOT NULL, -- Người cập nhật
	bi_xoa int2 DEFAULT 0 NULL, -- Bị xóa mềm
	ngay_xoa timestamp NULL, -- Ngày xóa mềm
	nguoi_xoa varchar(100) NULL, -- Người xóa mềm
	CONSTRAINT test6666123_pkey PRIMARY KEY (id)
);

CREATE TABLE test_1 (
	test varchar NULL,
	id uuid DEFAULT gen_random_uuid() NOT NULL, -- Key của bảng
	ngay_tao timestamp DEFAULT now() NOT NULL, -- Ngày tạo
	nguoi_tao varchar(100) DEFAULT 'system'::character varying NOT NULL, -- Người tạo
	ngay_cap_nhat timestamp DEFAULT now() NOT NULL, -- Ngày cập nhật
	nguoi_cap_nhat varchar(100) DEFAULT 'system'::character varying NOT NULL, -- Người cập nhật
	bi_xoa int2 DEFAULT 0 NULL, -- Bị xóa mềm
	ngay_xoa timestamp NULL, -- Ngày xóa mềm
	nguoi_xoa varchar(100) NULL, -- Người xóa mềm
	CONSTRAINT test_1_pkey PRIMARY KEY (id)
);

CREATE TABLE test_1234 (
	test_1234 varchar NULL,
	id uuid DEFAULT gen_random_uuid() NOT NULL, -- Key của bảng
	ngay_tao timestamp DEFAULT now() NOT NULL, -- Ngày tạo
	nguoi_tao varchar(100) DEFAULT 'system'::character varying NOT NULL, -- Người tạo
	ngay_cap_nhat timestamp DEFAULT now() NOT NULL, -- Ngày cập nhật
	nguoi_cap_nhat varchar(100) DEFAULT 'system'::character varying NOT NULL, -- Người cập nhật
	bi_xoa int2 DEFAULT 0 NULL, -- Bị xóa mềm
	ngay_xoa timestamp NULL, -- Ngày xóa mềm
	nguoi_xoa varchar(100) NULL, -- Người xóa mềm
	CONSTRAINT test_1234_pkey PRIMARY KEY (id)
);

CREATE TABLE test_123456 (
	test_123456 uuid NULL, -- test_123456
	id uuid DEFAULT gen_random_uuid() NOT NULL, -- Key của bảng
	ngay_tao timestamp DEFAULT now() NOT NULL, -- Ngày tạo
	nguoi_tao varchar(100) DEFAULT 'system'::character varying NOT NULL, -- Người tạo
	ngay_cap_nhat timestamp DEFAULT now() NOT NULL, -- Ngày cập nhật
	nguoi_cap_nhat varchar(100) DEFAULT 'system'::character varying NOT NULL, -- Người cập nhật
	bi_xoa int2 DEFAULT 0 NULL, -- Bị xóa mềm
	ngay_xoa timestamp NULL, -- Ngày xóa mềm
	nguoi_xoa varchar(100) NULL, -- Người xóa mềm
	CONSTRAINT test_123456_pkey PRIMARY KEY (id)
);

CREATE TABLE test_1234567 (
	test_123456 uuid NULL, -- test_123456
	test_12345 uuid NULL, -- test_123456
	test_1234 text NULL, -- test_123456
	id uuid DEFAULT gen_random_uuid() NOT NULL, -- Key của bảng
	ngay_tao timestamp DEFAULT now() NOT NULL, -- Ngày tạo
	nguoi_tao varchar(100) DEFAULT 'system'::character varying NOT NULL, -- Người tạo
	ngay_cap_nhat timestamp DEFAULT now() NOT NULL, -- Ngày cập nhật
	nguoi_cap_nhat varchar(100) DEFAULT 'system'::character varying NOT NULL, -- Người cập nhật
	bi_xoa int2 DEFAULT 0 NULL, -- Bị xóa mềm
	ngay_xoa timestamp NULL, -- Ngày xóa mềm
	nguoi_xoa varchar(100) NULL, -- Người xóa mềm
	CONSTRAINT test_1234567_pkey PRIMARY KEY (id)
);

CREATE TABLE test_123456789 (
	test varchar(100) NOT NULL, -- test
	id uuid DEFAULT gen_random_uuid() NOT NULL, -- Key của bảng
	ngay_tao timestamp DEFAULT now() NOT NULL, -- Ngày tạo
	nguoi_tao varchar(100) DEFAULT 'system'::character varying NOT NULL, -- Người tạo
	ngay_cap_nhat timestamp DEFAULT now() NOT NULL, -- Ngày cập nhật
	nguoi_cap_nhat varchar(100) DEFAULT 'system'::character varying NOT NULL, -- Người cập nhật
	bi_xoa int2 DEFAULT 0 NULL, -- Bị xóa mềm
	ngay_xoa timestamp NULL, -- Ngày xóa mềm
	nguoi_xoa varchar(100) NULL, -- Người xóa mềm
	CONSTRAINT test_123456789_pkey PRIMARY KEY (id)
);

CREATE TABLE test_danh_muc (
	test_danh_muc uuid NOT NULL, -- Tên danh mục
	id uuid DEFAULT gen_random_uuid() NOT NULL, -- Key của bảng
	ngay_tao timestamp DEFAULT now() NOT NULL, -- Ngày tạo
	nguoi_tao varchar(100) DEFAULT 'system'::character varying NOT NULL, -- Người tạo
	ngay_cap_nhat timestamp DEFAULT now() NOT NULL, -- Ngày cập nhật
	nguoi_cap_nhat varchar(100) DEFAULT 'system'::character varying NOT NULL, -- Người cập nhật
	bi_xoa int2 DEFAULT 0 NULL, -- Bị xóa mềm
	ngay_xoa timestamp NULL, -- Ngày xóa mềm
	nguoi_xoa varchar(100) NULL, -- Người xóa mềm
	my_varchar varchar(25) NULL, -- Test cột kiểu mảng
	CONSTRAINT test_danh_muc_pkey PRIMARY KEY (id)
);

CREATE TABLE test_danh_muc_01 (
	ten varchar(100) NOT NULL, -- ten
	ma varchar(100) NOT NULL, -- ma
	id uuid DEFAULT gen_random_uuid() NOT NULL, -- Key của bảng
	ngay_tao timestamp DEFAULT now() NOT NULL, -- Ngày tạo
	nguoi_tao varchar(100) DEFAULT 'system'::character varying NOT NULL, -- Người tạo
	ngay_cap_nhat timestamp DEFAULT now() NOT NULL, -- Ngày cập nhật
	nguoi_cap_nhat varchar(100) DEFAULT 'system'::character varying NOT NULL, -- Người cập nhật
	bi_xoa int2 DEFAULT 0 NULL, -- Bị xóa mềm
	ngay_xoa timestamp NULL, -- Ngày xóa mềm
	nguoi_xoa varchar(100) NULL, -- Người xóa mềm
	CONSTRAINT test_danh_muc_01_pkey PRIMARY KEY (id)
);

CREATE TABLE test_danh_muc_02 (
	ten varchar(100) NOT NULL, -- ten
	ma varchar(100) NOT NULL, -- ma
	id uuid DEFAULT gen_random_uuid() NOT NULL, -- Key của bảng
	ngay_tao timestamp DEFAULT now() NOT NULL, -- Ngày tạo
	nguoi_tao varchar(100) DEFAULT 'system'::character varying NOT NULL, -- Người tạo
	ngay_cap_nhat timestamp DEFAULT now() NOT NULL, -- Ngày cập nhật
	nguoi_cap_nhat varchar(100) DEFAULT 'system'::character varying NOT NULL, -- Người cập nhật
	bi_xoa int2 DEFAULT 0 NULL, -- Bị xóa mềm
	ngay_xoa timestamp NULL, -- Ngày xóa mềm
	nguoi_xoa varchar(100) NULL, -- Người xóa mềm
	CONSTRAINT test_danh_muc_02_pkey PRIMARY KEY (id)
);

CREATE TABLE test_danh_muc_03 (
	ten varchar(100) NOT NULL, -- ten
	ma varchar(100) NOT NULL, -- ma
	id uuid DEFAULT gen_random_uuid() NOT NULL, -- Key của bảng
	ngay_tao timestamp DEFAULT now() NOT NULL, -- Ngày tạo
	nguoi_tao varchar(100) DEFAULT 'system'::character varying NOT NULL, -- Người tạo
	ngay_cap_nhat timestamp DEFAULT now() NOT NULL, -- Ngày cập nhật
	nguoi_cap_nhat varchar(100) DEFAULT 'system'::character varying NOT NULL, -- Người cập nhật
	bi_xoa int2 DEFAULT 0 NULL, -- Bị xóa mềm
	ngay_xoa timestamp NULL, -- Ngày xóa mềm
	nguoi_xoa varchar(100) NULL, -- Người xóa mềm
	ma_dinh_cu varchar NULL, -- Mã định cư
	CONSTRAINT test_danh_muc_03_pkey PRIMARY KEY (id)
);

CREATE TABLE test_dm_001 (
	ma_test varchar NOT NULL,
	ten_test varchar NULL,
	id uuid DEFAULT gen_random_uuid() NOT NULL, -- Key của bảng
	ngay_tao timestamp DEFAULT now() NOT NULL, -- Ngày tạo
	nguoi_tao varchar DEFAULT 'system'::character varying NOT NULL, -- Người tạo
	ngay_cap_nhat timestamp DEFAULT now() NOT NULL, -- Ngày cập nhật
	nguoi_cap_nhat varchar DEFAULT 'system'::character varying NOT NULL, -- Người cập nhật
	bi_xoa int2 DEFAULT 0 NULL, -- Bị xóa mềm
	ngay_xoa timestamp NULL, -- Ngày xóa mềm
	nguoi_xoa varchar NULL, -- Người xóa mềm
	ghi_chu varchar NULL,
	test_big_serial bigserial NOT NULL,
	test_char bpchar(25) DEFAULT 'A'::bpchar NULL,
	test_text text DEFAULT 'ABC'::text NULL,
	test_jsonb jsonb DEFAULT '[]'::jsonb NULL,
	test_numeric numeric(10) DEFAULT 15 NULL,
	test_boolean bool DEFAULT true NULL,
	CONSTRAINT test_dm_001_ma_test_key UNIQUE (ma_test),
	CONSTRAINT test_dm_001_pkey PRIMARY KEY (id)
);

CREATE TABLE test_mapping_108 (
	test01_id uuid NULL, -- Bảng test 01
	test03_id varchar NULL,
	id uuid DEFAULT gen_random_uuid() NOT NULL, -- Key của bảng
	ngay_tao timestamp DEFAULT now() NOT NULL, -- Ngày tạo
	nguoi_tao varchar(100) DEFAULT 'system'::character varying NOT NULL, -- Người tạo
	ngay_cap_nhat timestamp DEFAULT now() NOT NULL, -- Ngày cập nhật
	nguoi_cap_nhat varchar(100) DEFAULT 'system'::character varying NOT NULL, -- Người cập nhật
	bi_xoa int2 DEFAULT 0 NULL, -- Bị xóa mềm
	ngay_xoa timestamp NULL, -- Ngày xóa mềm
	nguoi_xoa varchar(100) NULL, -- Người xóa mềm
	CONSTRAINT test_mapping_108_pkey PRIMARY KEY (id)
);

CREATE TABLE test_menu_1 (
	test_menu_1 varchar(100) NULL, -- test_menu_1
	id uuid DEFAULT gen_random_uuid() NOT NULL, -- Key của bảng
	ngay_tao timestamp DEFAULT now() NOT NULL, -- Ngày tạo
	nguoi_tao varchar(100) DEFAULT 'system'::character varying NOT NULL, -- Người tạo
	ngay_cap_nhat timestamp DEFAULT now() NOT NULL, -- Ngày cập nhật
	nguoi_cap_nhat varchar(100) DEFAULT 'system'::character varying NOT NULL, -- Người cập nhật
	bi_xoa int2 DEFAULT 0 NULL, -- Bị xóa mềm
	ngay_xoa timestamp NULL, -- Ngày xóa mềm
	nguoi_xoa varchar(100) NULL, -- Người xóa mềm
	CONSTRAINT test_menu_1_pkey PRIMARY KEY (id)
);

CREATE TABLE test_menu_2 (
	test_menu_1 varchar(100) NULL, -- test_menu_1
	id uuid DEFAULT gen_random_uuid() NOT NULL, -- Key của bảng
	ngay_tao timestamp DEFAULT now() NOT NULL, -- Ngày tạo
	nguoi_tao varchar(100) DEFAULT 'system'::character varying NOT NULL, -- Người tạo
	ngay_cap_nhat timestamp DEFAULT now() NOT NULL, -- Ngày cập nhật
	nguoi_cap_nhat varchar(100) DEFAULT 'system'::character varying NOT NULL, -- Người cập nhật
	bi_xoa int2 DEFAULT 0 NULL, -- Bị xóa mềm
	ngay_xoa timestamp NULL, -- Ngày xóa mềm
	nguoi_xoa varchar(100) NULL, -- Người xóa mềm
	CONSTRAINT test_menu_2_pkey PRIMARY KEY (id)
);

CREATE TABLE test_menu_3 (
	test_menu_1 varchar(100) NULL, -- test_menu_1
	id uuid DEFAULT gen_random_uuid() NOT NULL, -- Key của bảng
	ngay_tao timestamp DEFAULT now() NOT NULL, -- Ngày tạo
	nguoi_tao varchar(100) DEFAULT 'system'::character varying NOT NULL, -- Người tạo
	ngay_cap_nhat timestamp DEFAULT now() NOT NULL, -- Ngày cập nhật
	nguoi_cap_nhat varchar(100) DEFAULT 'system'::character varying NOT NULL, -- Người cập nhật
	bi_xoa int2 DEFAULT 0 NULL, -- Bị xóa mềm
	ngay_xoa timestamp NULL, -- Ngày xóa mềm
	nguoi_xoa varchar(100) NULL, -- Người xóa mềm
	CONSTRAINT test_menu_3_pkey PRIMARY KEY (id)
);

CREATE TABLE test_menu_4 (
	test_menu_2 varchar(100) NULL, -- test_menu_1
	id uuid DEFAULT gen_random_uuid() NOT NULL, -- Key của bảng
	ngay_tao timestamp DEFAULT now() NOT NULL, -- Ngày tạo
	nguoi_tao varchar(100) DEFAULT 'system'::character varying NOT NULL, -- Người tạo
	ngay_cap_nhat timestamp DEFAULT now() NOT NULL, -- Ngày cập nhật
	nguoi_cap_nhat varchar(100) DEFAULT 'system'::character varying NOT NULL, -- Người cập nhật
	bi_xoa int2 DEFAULT 0 NULL, -- Bị xóa mềm
	ngay_xoa timestamp NULL, -- Ngày xóa mềm
	nguoi_xoa varchar(100) NULL, -- Người xóa mềm
	CONSTRAINT test_menu_4_pkey PRIMARY KEY (id)
);

CREATE TABLE test_menu_5 (
	test_menu_2 varchar(100) NULL, -- test_menu_1
	id uuid DEFAULT gen_random_uuid() NOT NULL, -- Key của bảng
	ngay_tao timestamp DEFAULT now() NOT NULL, -- Ngày tạo
	nguoi_tao varchar(100) DEFAULT 'system'::character varying NOT NULL, -- Người tạo
	ngay_cap_nhat timestamp DEFAULT now() NOT NULL, -- Ngày cập nhật
	nguoi_cap_nhat varchar(100) DEFAULT 'system'::character varying NOT NULL, -- Người cập nhật
	bi_xoa int2 DEFAULT 0 NULL, -- Bị xóa mềm
	ngay_xoa timestamp NULL, -- Ngày xóa mềm
	nguoi_xoa varchar(100) NULL, -- Người xóa mềm
	CONSTRAINT test_menu_5_pkey PRIMARY KEY (id)
);

CREATE TABLE test_menu_6 (
	test_menu_2 varchar(100) NULL, -- test_menu_1
	id uuid DEFAULT gen_random_uuid() NOT NULL, -- Key của bảng
	ngay_tao timestamp DEFAULT now() NOT NULL, -- Ngày tạo
	nguoi_tao varchar(100) DEFAULT 'system'::character varying NOT NULL, -- Người tạo
	ngay_cap_nhat timestamp DEFAULT now() NOT NULL, -- Ngày cập nhật
	nguoi_cap_nhat varchar(100) DEFAULT 'system'::character varying NOT NULL, -- Người cập nhật
	bi_xoa int2 DEFAULT 0 NULL, -- Bị xóa mềm
	ngay_xoa timestamp NULL, -- Ngày xóa mềm
	nguoi_xoa varchar(100) NULL, -- Người xóa mềm
	CONSTRAINT test_menu_6_pkey PRIMARY KEY (id)
);

CREATE TABLE test_menu_7 (
	test_menu_2 varchar(100) NULL, -- test_menu_1
	id uuid DEFAULT gen_random_uuid() NOT NULL, -- Key của bảng
	ngay_tao timestamp DEFAULT now() NOT NULL, -- Ngày tạo
	nguoi_tao varchar(100) DEFAULT 'system'::character varying NOT NULL, -- Người tạo
	ngay_cap_nhat timestamp DEFAULT now() NOT NULL, -- Ngày cập nhật
	nguoi_cap_nhat varchar(100) DEFAULT 'system'::character varying NOT NULL, -- Người cập nhật
	bi_xoa int2 DEFAULT 0 NULL, -- Bị xóa mềm
	ngay_xoa timestamp NULL, -- Ngày xóa mềm
	nguoi_xoa varchar(100) NULL, -- Người xóa mềm
	CONSTRAINT test_menu_7_pkey PRIMARY KEY (id)
);

CREATE TABLE test_menu_8 (
	t varchar NULL,
	id uuid DEFAULT gen_random_uuid() NOT NULL, -- Key của bảng
	ngay_tao timestamp DEFAULT now() NOT NULL, -- Ngày tạo
	nguoi_tao varchar(100) DEFAULT 'system'::character varying NOT NULL, -- Người tạo
	ngay_cap_nhat timestamp DEFAULT now() NOT NULL, -- Ngày cập nhật
	nguoi_cap_nhat varchar(100) DEFAULT 'system'::character varying NOT NULL, -- Người cập nhật
	bi_xoa int2 DEFAULT 0 NULL, -- Bị xóa mềm
	ngay_xoa timestamp NULL, -- Ngày xóa mềm
	nguoi_xoa varchar(100) NULL, -- Người xóa mềm
	CONSTRAINT test_menu_8_pkey PRIMARY KEY (id)
);

CREATE TABLE test_menu_9 (
	"1" varchar NULL,
	id uuid DEFAULT gen_random_uuid() NOT NULL, -- Key của bảng
	ngay_tao timestamp DEFAULT now() NOT NULL, -- Ngày tạo
	nguoi_tao varchar(100) DEFAULT 'system'::character varying NOT NULL, -- Người tạo
	ngay_cap_nhat timestamp DEFAULT now() NOT NULL, -- Ngày cập nhật
	nguoi_cap_nhat varchar(100) DEFAULT 'system'::character varying NOT NULL, -- Người cập nhật
	bi_xoa int2 DEFAULT 0 NULL, -- Bị xóa mềm
	ngay_xoa timestamp NULL, -- Ngày xóa mềm
	nguoi_xoa varchar(100) NULL, -- Người xóa mềm
	CONSTRAINT test_menu_9_pkey PRIMARY KEY (id)
);

CREATE TABLE test_menu_danh_muc (
	test_cot_dan_muc varchar(100) NOT NULL, -- Cột danh mục
	id uuid DEFAULT gen_random_uuid() NOT NULL, -- Key của bảng
	ngay_tao timestamp DEFAULT now() NOT NULL, -- Ngày tạo
	nguoi_tao varchar(100) DEFAULT 'system'::character varying NOT NULL, -- Người tạo
	ngay_cap_nhat timestamp DEFAULT now() NOT NULL, -- Ngày cập nhật
	nguoi_cap_nhat varchar(100) DEFAULT 'system'::character varying NOT NULL, -- Người cập nhật
	bi_xoa int2 DEFAULT 0 NULL, -- Bị xóa mềm
	ngay_xoa timestamp NULL, -- Ngày xóa mềm
	nguoi_xoa varchar(100) NULL, -- Người xóa mềm
	CONSTRAINT test_menu_danh_muc_pkey PRIMARY KEY (id)
);

CREATE TABLE test_mp_m_1 (
	"1" uuid NULL,
	"2" uuid NULL,
	"3" varchar NULL,
	id uuid DEFAULT gen_random_uuid() NOT NULL, -- Key của bảng
	ngay_tao timestamp DEFAULT now() NOT NULL, -- Ngày tạo
	nguoi_tao varchar(100) DEFAULT 'system'::character varying NOT NULL, -- Người tạo
	ngay_cap_nhat timestamp DEFAULT now() NOT NULL, -- Ngày cập nhật
	nguoi_cap_nhat varchar(100) DEFAULT 'system'::character varying NOT NULL, -- Người cập nhật
	bi_xoa int2 DEFAULT 0 NULL, -- Bị xóa mềm
	ngay_xoa timestamp NULL, -- Ngày xóa mềm
	nguoi_xoa varchar(100) NULL, -- Người xóa mềm
	CONSTRAINT test_mp_m_1_pkey PRIMARY KEY (id)
);

CREATE TABLE test_view_form (
	test_view_form varchar NULL,
	id uuid DEFAULT gen_random_uuid() NOT NULL, -- Key của bảng
	ngay_tao timestamp DEFAULT now() NOT NULL, -- Ngày tạo
	nguoi_tao varchar(100) DEFAULT 'system'::character varying NOT NULL, -- Người tạo
	ngay_cap_nhat timestamp DEFAULT now() NOT NULL, -- Ngày cập nhật
	nguoi_cap_nhat varchar(100) DEFAULT 'system'::character varying NOT NULL, -- Người cập nhật
	bi_xoa int2 DEFAULT 0 NULL, -- Bị xóa mềm
	ngay_xoa timestamp NULL, -- Ngày xóa mềm
	nguoi_xoa varchar(100) NULL, -- Người xóa mềm
	CONSTRAINT test_view_form_pkey PRIMARY KEY (id)
);

CREATE TABLE thang_test (
	test_111 varchar NULL,
	id uuid DEFAULT gen_random_uuid() NOT NULL, -- Key của bảng
	ngay_tao timestamp DEFAULT now() NOT NULL, -- Ngày tạo
	nguoi_tao varchar(100) DEFAULT 'system'::character varying NOT NULL, -- Người tạo
	ngay_cap_nhat timestamp DEFAULT now() NOT NULL, -- Ngày cập nhật
	nguoi_cap_nhat varchar(100) DEFAULT 'system'::character varying NOT NULL, -- Người cập nhật
	bi_xoa int2 DEFAULT 0 NULL, -- Bị xóa mềm
	ngay_xoa timestamp NULL, -- Ngày xóa mềm
	nguoi_xoa varchar(100) NULL, -- Người xóa mềm
	CONSTRAINT thang_test_pkey PRIMARY KEY (id)
);

CREATE TABLE thang_test1 (
	cot_test_danh_muc_01 uuid NULL, -- dm01
	cot_test_danh_muc_02 uuid NULL, -- dm02
	cot_test_danh_muc_03 varchar NULL, -- dm03
	id uuid DEFAULT gen_random_uuid() NOT NULL, -- Key của bảng
	ngay_tao timestamp DEFAULT now() NOT NULL, -- Ngày tạo
	nguoi_tao varchar(100) DEFAULT 'system'::character varying NOT NULL, -- Người tạo
	ngay_cap_nhat timestamp DEFAULT now() NOT NULL, -- Ngày cập nhật
	nguoi_cap_nhat varchar(100) DEFAULT 'system'::character varying NOT NULL, -- Người cập nhật
	bi_xoa int2 DEFAULT 0 NULL, -- Bị xóa mềm
	ngay_xoa timestamp NULL, -- Ngày xóa mềm
	nguoi_xoa varchar(100) NULL, -- Người xóa mềm
	CONSTRAINT thang_test1_pkey PRIMARY KEY (id)
);

CREATE TABLE tiep_nhan (
	id uuid DEFAULT gen_random_uuid() NOT NULL,
	ma_cskcb varchar NOT NULL,
	ma_tiep_nhan varchar NOT NULL,
	ma_benh_nhan varchar NOT NULL,
	benh_nhan_id uuid NOT NULL,
	ma_doi_tuong varchar NOT NULL,
	ma_nguoi_tiep_nhan varchar NOT NULL,
	thoi_gian_tiep_nhan date DEFAULT CURRENT_DATE NOT NULL,
	ly_do_den_kham text NULL,
	ma_ly_do_tiep_nhan varchar NULL,
	ma_hinh_thuc_tiep_nhan varchar NOT NULL,
	ma_loai_giay_to varchar NULL,
	ma_noi_gioi_thieu varchar NULL,
	so_chuyen_tuyen varchar NULL,
	ngay_chuyen_tuyen date NULL,
	ma_hinh_thuc_chuyen_tuyen varchar NULL,
	ma_ly_do_chuyen_tuyen varchar NULL,
	ma_nguoi_gioi_thieu varchar NULL,
	ma_icd_noi_gioi_thieu varchar NULL,
	chan_doan_noi_gioi_thieu text NULL,
	ma_icd_yhct varchar NULL,
	benh_yhct varchar NULL,
	khoa int2 NULL, -- Khóa bản ghi (0/1)
	ma_nguoi_khoa varchar NULL,
	thoi_gian_khoa date NULL,
	thong_tin_cong_bhyt varchar NULL,
	ma_trang_thai_kcb varchar DEFAULT 'DA_TIEP_DON'::character varying NULL, -- Trạng thái phiếu tiếp đón. Mặc định là DA_TIEP_DON
	ma_loai_kcb varchar NULL,
	so_ngay_dieu_tri int4 NULL,
	ma_pp_dieu_tri varchar NULL,
	ma_kq_dieu_tri varchar NULL,
	ma_loai_ra_vien varchar NULL,
	ma_xac_nhan_chi_phi varchar NULL,
	ngay_vao date NULL,
	ngay_ra date NULL,
	ngay_thanh_toan date NULL,
	co_so_dien_thoai int2 NULL,
	co_cccd int2 NULL,
	co_bh_tu_nguyen int2 NULL,
	co_uu_tien int2 NULL,
	co_sinh_tai_vien int2 NULL,
	bi_xoa int2 DEFAULT 0 NOT NULL,
	ngay_xoa timestamp NULL,
	nguoi_xoa varchar(100) NULL,
	ngay_tao timestamp DEFAULT CURRENT_TIMESTAMP NULL,
	nguoi_tao varchar NULL,
	ngay_cap_nhat timestamp NULL,
	nguoi_cap_nhat varchar NULL,
	ngay_tiep_nhan timestamp DEFAULT CURRENT_TIMESTAMP NULL,
	ten_nguoi_gioi_thieu varchar NULL,
	trang_thai_xml int2 DEFAULT 0 NULL,
	csyt_xac_nhan_chi_phi_id uuid NULL,
	so_benh_an varchar NULL,
	phong_tiep_nhan_id uuid NULL,
	ma_phong_tiep_nhan varchar NULL,
	khoa_tiep_nhan_id uuid NULL,
	ma_khoa_tiep_nhan varchar NULL,
	ma_khoa_dieu_tri varchar NULL,
	pp_dieu_tri text NULL,
	CONSTRAINT tiep_nhan_pkey PRIMARY KEY (id)
);

CREATE TABLE tmp_param (
	func text NULL,
	param text NULL,
	created_date timestamp DEFAULT now() NULL
);

CREATE TABLE trinh_tu_phau_thuat (
	ma_mau_trinh_tu varchar(100) NULL,
	ten_mau_trinh_tu varchar(255) NULL,
	trinh_tu_phau_thuat_ten_bac_si varchar(255) NULL,
	trinh_tu_phau_thuat_ma_bac_si varchar(255) NULL,
	trinh_tu_phau_thuat_bac_si_id uuid NULL,
	id uuid DEFAULT gen_random_uuid() NOT NULL,
	ma_cskcb varchar(20) NOT NULL,
	bi_xoa int2 DEFAULT 0 NOT NULL,
	ngay_xoa timestamp NULL,
	nguoi_xoa varchar(100) NULL,
	ngay_tao timestamp DEFAULT CURRENT_TIMESTAMP NOT NULL,
	nguoi_tao varchar(100) NOT NULL,
	ngay_cap_nhat timestamp NOT NULL,
	nguoi_cap_nhat varchar(100) NOT NULL,
	CONSTRAINT trinh_tu_phau_thuat_pkey PRIMARY KEY (id)
);

CREATE TABLE ttb_thiet_bi_tai_san (
	id uuid DEFAULT gen_random_uuid() NOT NULL, -- Khóa chính
	so_serial varchar(100) NULL, -- Số serial định danh duy nhất của máy
	dm_vattu_ttb_id uuid NULL, -- ID trong bảng dmc_vat_tu_trang_thiet_bi
	thiet_bi_cha_id uuid NULL, -- ID trong bảng ttb_thiet_bi_tai_san (thiết bị cha)
	phan_loai varchar(100) NULL, -- Phân loại tài sản / trang thiết bị
	model varchar(100) NULL, -- Model thiết bị
	hang_san_xuat varchar(100) NULL, -- Hãng sản xuất
	nuoc_san_xuat varchar(100) NULL, -- Nước sản xuất
	don_vi_tinh varchar(50) NULL, -- Đơn vị tính
	so_luong int4 NULL, -- Số lượng
	don_gia_chua_thue numeric(15, 3) NULL, -- Đơn giá chưa thuế
	thanh_tien_chua_thue numeric(15, 3) NULL, -- Thành tiền chưa thuế
	vat numeric(5, 2) NULL, -- Thuế suất VAT (%)
	don_gia_sau_vat numeric(15, 3) NULL, -- Đơn giá sau thuế (sau VAT)
	thanh_tien_sau_vat numeric(15, 3) NULL, -- Thành tiền sau thuế (sau VAT)
	khau_hao_id uuid NULL, -- ID trong bảng lis_dm_khau_hao
	so_lo varchar(100) NULL, -- Số lô sản xuất / nhập kho
	nguon_kinh_phi_id uuid NULL, -- ID trong bảng dm_nguonct
	quyet_dinh_thau varchar(100) NULL, -- Số quyết định phê duyệt kết quả thầu
	han_bao_hanh date NULL, -- Ngày hết hạn bảo hành
	han_doi_tra date NULL, -- Ngày hết hạn đổi trả
	ghi_chu text NULL, -- Ghi chú / Thông tin bổ sung
	trang_thai varchar(100) NULL, -- Trạng thái tài sản (vd: Đang dùng, Hỏng, Thanh lý...)
	kho_ttb_id uuid NULL, -- ID trong bảng dm_kho_trangthietbi
	ma_cskcb varchar(50) NULL, -- Mã cơ sở khám chữa bệnh
	phieu_nhap_id uuid NULL, -- ID trong bảng ttb_phieu_nhap_kho
	chi_tiet_phieu_nhap_id uuid NULL, -- ID trong bảng ttb_chi_tiet_phieu_nhap_kho
	ngay_tao timestamp(6) DEFAULT CURRENT_TIMESTAMP NULL, -- Ngày tạo bản ghi
	nguoi_tao varchar(50) NULL, -- Mã người tạo bản ghi
	ngay_cap_nhat timestamp(6) NULL, -- Ngày cập nhật bản ghi gần nhất
	nguoi_cap_nhat varchar(50) NULL, -- Mã người cập nhật bản ghi gần nhất
	bi_xoa int2 DEFAULT 0 NULL, -- Trạng thái xóa (0: Hoạt động, 1: Đã xóa)
	ngay_xoa timestamp(6) NULL, -- Ngày xóa bản ghi
	nguoi_xoa varchar(50) NULL, -- Mã người thực hiện xóa
	CONSTRAINT ttb_thiet_bi_tai_san_pkey PRIMARY KEY (id)
);

CREATE TABLE v_cls_payload (
	jsonb_build_object jsonb NULL
);

CREATE TABLE v_count (
	count int8 NULL
);

CREATE TABLE v_current_column_def (
	table_catalog information_schema."sql_identifier" COLLATE "C" NULL,
	table_schema information_schema."sql_identifier" COLLATE "C" NULL,
	table_name information_schema."sql_identifier" COLLATE "C" NULL,
	column_name information_schema."sql_identifier" COLLATE "C" NULL,
	ordinal_position information_schema."cardinal_number" NULL,
	column_default information_schema."character_data" COLLATE "C" NULL,
	is_nullable information_schema."yes_or_no" COLLATE "C" NULL,
	data_type information_schema."character_data" COLLATE "C" NULL,
	character_maximum_length information_schema."cardinal_number" NULL,
	character_octet_length information_schema."cardinal_number" NULL,
	numeric_precision information_schema."cardinal_number" NULL,
	numeric_precision_radix information_schema."cardinal_number" NULL,
	numeric_scale information_schema."cardinal_number" NULL,
	datetime_precision information_schema."cardinal_number" NULL,
	interval_type information_schema."character_data" COLLATE "C" NULL,
	interval_precision information_schema."cardinal_number" NULL,
	character_set_catalog information_schema."sql_identifier" COLLATE "C" NULL,
	character_set_schema information_schema."sql_identifier" COLLATE "C" NULL,
	character_set_name information_schema."sql_identifier" COLLATE "C" NULL,
	collation_catalog information_schema."sql_identifier" COLLATE "C" NULL,
	collation_schema information_schema."sql_identifier" COLLATE "C" NULL,
	collation_name information_schema."sql_identifier" COLLATE "C" NULL,
	domain_catalog information_schema."sql_identifier" COLLATE "C" NULL,
	domain_schema information_schema."sql_identifier" COLLATE "C" NULL,
	domain_name information_schema."sql_identifier" COLLATE "C" NULL,
	udt_catalog information_schema."sql_identifier" COLLATE "C" NULL,
	udt_schema information_schema."sql_identifier" COLLATE "C" NULL,
	udt_name information_schema."sql_identifier" COLLATE "C" NULL,
	scope_catalog information_schema."sql_identifier" COLLATE "C" NULL,
	scope_schema information_schema."sql_identifier" COLLATE "C" NULL,
	scope_name information_schema."sql_identifier" COLLATE "C" NULL,
	maximum_cardinality information_schema."cardinal_number" NULL,
	dtd_identifier information_schema."sql_identifier" COLLATE "C" NULL,
	is_self_referencing information_schema."yes_or_no" COLLATE "C" NULL,
	is_identity information_schema."yes_or_no" COLLATE "C" NULL,
	identity_generation information_schema."character_data" COLLATE "C" NULL,
	identity_start information_schema."character_data" COLLATE "C" NULL,
	identity_increment information_schema."character_data" COLLATE "C" NULL,
	identity_maximum information_schema."character_data" COLLATE "C" NULL,
	identity_minimum information_schema."character_data" COLLATE "C" NULL,
	identity_cycle information_schema."yes_or_no" COLLATE "C" NULL,
	is_generated information_schema."character_data" COLLATE "C" NULL,
	generation_expression information_schema."character_data" COLLATE "C" NULL,
	is_updatable information_schema."yes_or_no" COLLATE "C" NULL
);

CREATE TABLE v_gia_tri (
	"coalesce" text NULL
);

CREATE TABLE v_ho_tro_bhyt (
	is_gia_ho_tro int2 NULL
);

CREATE TABLE v_tiepnhan_id (
	tiepnhan_id uuid NULL
);

CREATE TABLE v_xml01_tong_hop_chi_phi (
	tiepnhan_id uuid NULL,
	ma_lk varchar(100) NULL,
	tong_tien_bv numeric NULL,
	tong_tien_bh numeric NULL,
	tong_tien_bntt numeric NULL,
	tong_tien_bncct numeric NULL,
	tong_tien_nguonkhac numeric NULL,
	t_thuoc numeric NULL,
	t_vtyt numeric NULL,
	t_bhtt numeric NULL,
	t_bhtt_gdv numeric NULL
);

CREATE TABLE v_xml05_dien_bien_lam_sang (
	tiep_nhan_id uuid NULL,
	ma_lk varchar NULL,
	stt int8 NULL,
	dien_bien_ls text NULL,
	giai_doan_benh text NULL,
	hoi_chan text NULL,
	phau_thuat text NULL,
	thoi_diem_dbls timestamp NULL,
	nguoi_thuc_hien text NULL,
	du_phong text NULL
);

CREATE TABLE v_xml07_giay_ra_vien (
	tiep_nhan_id uuid NULL,
	ma_lk varchar NULL,
	so_luu_tru varchar(50) NULL,
	ma_yte varchar NULL,
	ma_khoa_rv varchar(25) NULL,
	ngay_vao text NULL,
	ngay_ra text NULL,
	ma_dinh_chi_thai varchar(50) NULL,
	nguyennhan_dinhchi varchar(500) NULL,
	thoigian_dinhchi text NULL,
	tuoi_thai varchar(50) NULL,
	chan_doan_rv varchar(500) NULL,
	pp_dieutri text NULL,
	ghi_chu text NULL,
	ma_ttdv text NULL,
	ma_bs varchar NULL,
	ten_bs varchar NULL,
	ngay_ct timestamp(6) NULL,
	ma_cha text NULL,
	ma_me text NULL,
	ma_the_tam text NULL,
	ho_ten_cha varchar(255) NULL,
	ho_ten_me varchar(255) NULL,
	so_ngay_nghi int4 NULL,
	ngoaitru_tungay timestamp(6) NULL,
	ngoaitru_denngay timestamp(6) NULL,
	du_phong text NULL
);

CREATE TABLE v_xml08_tom_tat_ho_so_benh_an (
	tiep_nhan_id uuid NULL,
	ma_lk varchar NULL,
	ma_loai_kcb varchar NULL,
	ho_ten_cha varchar(255) NULL,
	ho_ten_me varchar(255) NULL,
	nguoi_giam_ho varchar(255) NULL,
	don_vi varchar(500) NULL,
	ngay_vao text NULL,
	ngay_ra text NULL,
	chan_doan_vao varchar(500) NULL,
	chan_doan_rv varchar(500) NULL,
	qt_benhly text NULL,
	tomtat_kq text NULL,
	pp_dieutri text NULL,
	ngay_sinhcon text NULL,
	ngay_conchet text NULL,
	so_conchet text NULL,
	ket_qua_dtri varchar NULL,
	ghi_chu text NULL,
	ma_ttdv text NULL,
	ngay_ct text NULL,
	ma_the_tam text NULL,
	du_phong text NULL
);

CREATE TABLE v_xml10_giay_chung_nhan_nghi_duong_thai (
	tiep_nhan_id uuid NULL,
	ma_lk varchar NULL,
	so_seri varchar NULL,
	so_ct varchar(100) NULL,
	so_ngay varchar(50) NULL,
	don_vi varchar(500) NULL,
	chan_doan_rv varchar(1000) NULL,
	tu_ngay text NULL,
	den_ngay text NULL,
	ma_ttdv varchar(60) NULL,
	ten_bs varchar NULL,
	ma_bs varchar(50) NULL,
	ngay_ct text NULL,
	du_phong text NULL
);

CREATE TABLE v_xml11_giay_chung_nhan_nghi_viec_bhxh (
	tiep_nhan_id uuid NULL,
	ma_lk varchar NULL,
	so_ct varchar NULL,
	so_seri varchar NULL,
	so_kcb varchar NULL,
	don_vi varchar(500) NULL,
	ma_bhxh varchar(50) NULL,
	ma_the_bhyt varchar(50) NULL,
	chan_doan_rv varchar(1000) NULL,
	pp_dieutri varchar(1000) NULL,
	ma_dinh_chi_thai varchar(50) NULL,
	nguyennhan_dinhchi varchar(500) NULL,
	tuoi_thai varchar(50) NULL,
	so_ngay_nghi varchar(50) NULL,
	tu_ngay text NULL,
	den_ngay text NULL,
	ho_ten_cha varchar(255) NULL,
	ho_ten_me varchar(255) NULL,
	ma_ttdv text NULL,
	ma_bs varchar(50) NULL,
	ngay_ct text NULL,
	ma_the_tam varchar(50) NULL,
	mau_so text NULL,
	du_phong text NULL
);

CREATE TABLE v_xml13_giay_chuyen_tuyen (
	tiep_nhan_id uuid NULL,
	ma_lk text NULL,
	so_hoso varchar NULL,
	so_chuyentuyen text NULL,
	giay_chuyen_tuyen text NULL,
	ma_cskcb text NULL,
	ma_noi_di text NULL,
	ma_noi_den text NULL,
	ho_ten text NULL,
	ngay_sinh text NULL,
	gioi_tinh text NULL,
	ma_quoctich text NULL,
	ma_dantoc text NULL,
	ma_nghe_nghiep text NULL,
	dia_chi text NULL,
	ma_the_bhyt text NULL,
	gt_the_den text NULL,
	ngay_vao text NULL,
	ngay_vao_noi_tru text NULL,
	ngay_ra text NULL,
	dau_hieu_ls text NULL,
	chan_doan_rv text NULL,
	qt_benhly text NULL,
	tomtat_kq text NULL,
	pp_dieutri text NULL,
	ma_benh_chinh text NULL,
	ma_benh_kt text NULL,
	ma_benh_yhct text NULL,
	ten_dich_vu text NULL,
	ten_thuoc text NULL,
	pp_dieu_tri text NULL,
	ma_loai_rv text NULL,
	ma_lydo_ct text NULL,
	huong_dieu_tri text NULL,
	phuongtien_vc text NULL,
	hoten_nguoi_ht text NULL,
	chucdanh_nguoi_ht text NULL,
	ma_bac_si text NULL,
	ma_ttdv text NULL,
	du_phong text NULL
);

CREATE TABLE v_xml13_giay_chuyen_tuyen_test (
	tiep_nhan_id uuid NULL,
	ma_lk text NULL,
	so_hoso varchar NULL,
	so_chuyentuyen text NULL,
	giay_chuyen_tuyen text NULL,
	ma_cskcb text NULL,
	ma_noi_di text NULL,
	ma_noi_den text NULL,
	ho_ten text NULL,
	ngay_sinh text NULL,
	gioi_tinh text NULL,
	ma_quoctich text NULL,
	ma_dantoc text NULL,
	ma_nghe_nghiep text NULL,
	dia_chi text NULL,
	ma_the_bhyt text NULL,
	gt_the_den text NULL,
	ngay_vao text NULL,
	ngay_vao_noi_tru text NULL,
	ngay_ra text NULL,
	dau_hieu_ls text NULL,
	chan_doan_rv text NULL,
	qt_benhly text NULL,
	tomtat_kq text NULL,
	pp_dieutri text NULL,
	ma_benh_chinh text NULL,
	ma_benh_kt text NULL,
	ma_benh_yhct text NULL,
	ten_dich_vu text NULL,
	ten_thuoc text NULL,
	pp_dieu_tri text NULL,
	ma_loai_rv text NULL,
	ma_lydo_ct text NULL,
	huong_dieu_tri text NULL,
	phuongtien_vc text NULL,
	hoten_nguoi_ht text NULL,
	chucdanh_nguoi_ht text NULL,
	ma_bac_si text NULL,
	ma_ttdv text NULL,
	du_phong text NULL
);

CREATE TABLE v_xml14_giay_hen_kham_lai (
	tiep_nhan_id uuid NULL,
	ma_lk varchar NULL,
	so_giay_hen_kl text NULL,
	ma_cskcb varchar NULL,
	ho_ten varchar NULL,
	ngay_sinh text NULL,
	gioi_tinh varchar NULL,
	dia_chi varchar NULL,
	ma_the_bhyt text NULL,
	gt_the_den text NULL,
	ngay_vao text NULL,
	ngay_vao_noi_tru text NULL,
	ngay_ra text NULL,
	ngay_hen_kl text NULL,
	chan_doan_rv varchar NULL,
	ma_benh_chinh varchar(50) NULL,
	ma_benh_kt varchar NULL,
	ma_benh_yhct varchar(50) NULL,
	ma_doi_tuong_kcb text NULL,
	ma_bac_si varchar(50) NULL,
	ma_ttdv varchar NULL,
	ngay_ct text NULL,
	du_phong text NULL
);

CREATE TABLE v_xml_mau_01dm_bo_phan_chuyen_mon (
	stt int8 NULL,
	ma_khoa varchar(25) NULL,
	ten_khoa varchar(255) NULL,
	ban_kham int4 NULL,
	giuong_pd int4 NULL,
	giuong_tk int4 NULL,
	giuong_hstc int4 NULL,
	giuong_hscc int4 NULL,
	tu_ngay text NULL,
	den_ngay varchar NULL,
	ma_cskcb varchar(25) NULL,
	khoa_id uuid NULL
);

CREATE TABLE v_xml_mau_02dm_nhan_luc_kcb (
	stt int8 NULL,
	ma_khoa varchar(25) NULL,
	ten_khoa varchar(255) NULL,
	ho_ten varchar NULL,
	gioi_tinh int2 NULL,
	so_dinh_danh varchar NULL,
	chucdanh_nn int4 NULL,
	vi_tri varchar NULL,
	macchn varchar NULL,
	ngaycap_cchn varchar NULL,
	noicap_cchn varchar NULL,
	phamvi_cm varchar NULL,
	phamvi_cmbs varchar NULL,
	dvkt_khac varchar NULL,
	vb_phancong varchar NULL,
	thoigian_dk int2 NULL,
	thoigian_ngay varchar NULL,
	thoigian_tuan varchar NULL,
	cskcb_khac varchar NULL,
	cskcb_cgkt varchar NULL,
	qd_cgkt varchar NULL,
	tu_ngay varchar NULL,
	den_ngay varchar NULL,
	ma_cskcb varchar(50) NULL,
	nhan_vien_id uuid NULL
);

CREATE TABLE v_xml_mau_03dm_thuoc_mau_che_pham_mau (
	stt int8 NULL,
	ma_thuoc varchar(100) NULL,
	ten_hoat_chat varchar(2048) NULL,
	ten_thuoc varchar(500) NULL,
	don_vi_tinh varchar NULL,
	ham_luong varchar(2048) NULL,
	duong_dung varchar NULL,
	ma_duong_dung varchar NULL,
	dang_bao_che varchar NULL,
	so_dang_ky varchar(500) NULL,
	so_luong numeric(15, 5) NULL,
	don_gia numeric(15, 5) NULL,
	don_gia_bh numeric(15, 5) NULL,
	quy_cach varchar NULL,
	nha_sx varchar NULL,
	nuoc_sx varchar(140) NULL,
	nha_thau varchar NULL,
	tt_thau text NULL,
	tu_ngay_hd text NULL,
	den_ngay_hd text NULL,
	ma_cskcb varchar(50) NULL,
	loai_thuoc int2 NULL,
	loai_thau numeric(22) NULL,
	ht_thau int4 NULL,
	ma_dvkt varchar NULL,
	tccl varchar NULL,
	bo_phan_vt int2 NULL,
	ten_khoa_hoc varchar NULL,
	nguon_goc varchar NULL,
	pp_chebien varchar(500) NULL,
	ma_dl_nhap varchar NULL,
	ma_dl_cb varchar NULL,
	tlhh_cb numeric(3) NULL,
	tlhh_bq numeric(3) NULL,
	ma_cskcb_thuoc varchar NULL,
	tu_ngay text NULL,
	den_ngay text NULL,
	thuoc_vat_tu_id uuid NULL
);

CREATE TABLE v_xml_mau_04dm_thiet_bi_y_te (
	stt int8 NULL,
	ma_vat_tu varchar(100) NULL,
	nhom_vat_tu varchar NULL,
	ten_vat_tu varchar(500) NULL,
	ma_hieu varchar NULL,
	so_luu_hanh varchar NULL,
	tinhnang_kt varchar NULL,
	quy_cach varchar NULL,
	hang_sx varchar NULL,
	nuoc_sx varchar(140) NULL,
	don_vi_tinh varchar NULL,
	don_gia numeric(15, 5) NULL,
	don_gia_bh numeric(15, 5) NULL,
	tyle_tt_bh numeric(22) NULL,
	so_luong numeric(15, 5) NULL,
	dinh_muc numeric(22) NULL,
	nha_thau varchar NULL,
	tt_thau text NULL,
	tu_ngay_hd text NULL,
	den_ngay_hd text NULL,
	ma_cskcb varchar(50) NULL,
	loai_thau numeric(22) NULL,
	ht_thau int4 NULL,
	ma_cskcb_tbyt varchar NULL,
	tu_ngay text NULL,
	den_ngay text NULL,
	thuoc_vat_tu_id uuid NULL
);

CREATE TABLE v_xml_mau_05dm_dich_vu_kcb (
	stt int8 NULL,
	ma_dich_vu varchar(25) NULL,
	ten_dich_vu varchar(255) NULL,
	ten_dvkt_gia varchar(255) NULL,
	don_gia numeric NULL,
	quy_trinh varchar NULL,
	so_luong_cgkt int2 NULL,
	cskcb_cgkt varchar NULL,
	cskcb_cls varchar NULL,
	qd_dvkt varchar NULL,
	qd_pd_gia varchar NULL,
	ghi_chu varchar NULL,
	tu_ngay varchar NULL,
	den_ngay varchar NULL,
	ma_cskcb varchar(25) NULL,
	gia_thanh_toan numeric NULL,
	dich_vu_id uuid NULL
);

CREATE TABLE v_xml_mau_06dm_thiet_bi_dvkt (
	stt int8 NULL,
	ten_tb varchar(255) NULL,
	ky_hieu varchar NULL,
	congty_sx varchar(255) NULL,
	nuoc_sx varchar NULL,
	nam_sx int2 NULL,
	nam_sd int2 NULL,
	ma_may varchar(25) NULL,
	so_luu_hanh varchar(255) NULL,
	hd_tu varchar NULL,
	hd_den varchar NULL,
	tu_ngay varchar NULL,
	den_ngay varchar NULL,
	ma_cskcb varchar(25) NULL,
	thiet_bi_id uuid NULL
);

CREATE TABLE csyt_don_thuoc_nha_thuoc (
	id uuid DEFAULT gen_random_uuid() NOT NULL,
	ma_cskcb varchar NOT NULL,
	tiep_nhan_id uuid NULL,
	loai_nhap_xuat varchar NOT NULL,
	ma_lan_chi_dinh varchar NULL,
	ma_don_thuoc_nha_thuoc varchar NULL,
	ma_don_thuoc varchar NULL,
	id_don_ban uuid NULL,
	ho_so_so_hoa_id uuid NULL,
	sohoa_phieuin_baocao_id uuid NULL,
	nguoi_mua_hang varchar NOT NULL,
	sdt_nmh varchar NULL,
	cccd_nmh varchar NULL,
	ngay_sinh_nmh date NULL,
	gioi_tinh_nmh varchar NULL,
	dia_chi_nmh text NULL,
	quoc_tich_nmh varchar NULL,
	tong_tien numeric NOT NULL,
	tong_tien_xuat numeric NULL,
	ti_le_chiet_khau numeric NULL,
	tong_tien_chiet_khau numeric NULL,
	tong_tien_tt numeric NOT NULL,
	lan_ban int4 NULL,
	ref_id uuid NULL,
	ref_table varchar NULL,
	trang_thai_ma varchar NOT NULL,
	vp_chung_tu_id uuid NULL,
	hoa_don_dien_tu_id uuid NULL,
	kho_id numeric NULL,
	nguoi_duyet varchar(255) NULL,
	nguoi_ban varchar(255) NULL,
	ngay_duyet timestamp NULL,
	bi_xoa int2 DEFAULT 0 NOT NULL,
	hinh_thuc_thanh_toan_id uuid NULL,
	ngay_tao timestamp DEFAULT CURRENT_TIMESTAMP NOT NULL,
	ngay_cap_nhat timestamp NULL,
	nguoi_tao varchar(100) NOT NULL,
	nguoi_cap_nhat varchar(100) NULL,
	ngay_xoa timestamp NULL,
	nguoi_xoa varchar(50) NULL,
	don_ban_id uuid NULL,
	ly_do_tra varchar NULL,
	ghi_chu varchar NULL,
	lap_hoa_don_dieu_chinh bool DEFAULT false NULL,
	nhapxuatid numeric NULL,
	ghi_chu_nhap_kho varchar NULL,
	doi_tuong_benh_nhan_don_thuoc_nha_thuoc_id uuid NULL,
	bac_si_ke_don_id uuid NULL,
	CONSTRAINT pk_csyt_don_thuoc_nha_thuoc PRIMARY KEY (id),
	CONSTRAINT fk_csyt_don_thuoc_nha_thuoc_kho FOREIGN KEY (kho_id) REFERENCES duc_kho(khoid),
	CONSTRAINT fk_csyt_don_thuoc_nha_thuoc_trang_thai FOREIGN KEY (trang_thai_ma) REFERENCES dmc_trang_thai_don_thuoc_nha_thuoc(ma)
);

CREATE TABLE dm_loai_nhom_bao_cao_dm_kieu_nhom_map (
	id uuid DEFAULT gen_random_uuid() NOT NULL,
	loai_nhom_bao_cao_id uuid NOT NULL,
	ma_kieu_nhom varchar(255) NOT NULL,
	ngay_tao timestamp DEFAULT now() NOT NULL,
	nguoi_tao varchar(100) DEFAULT 'system'::character varying NOT NULL,
	CONSTRAINT dm_loai_nhom_bao_cao_dm_kieu_nhom_map_pkey PRIMARY KEY (id),
	CONSTRAINT uq_map_loai_kieu UNIQUE (ma_kieu_nhom, loai_nhom_bao_cao_id),
	CONSTRAINT fk_map_kieu_nhom FOREIGN KEY (ma_kieu_nhom) REFERENCES dm_kieu_nhom_bao_cao(ma) ON DELETE CASCADE,
	CONSTRAINT fk_map_loai_nhom_bao_cao FOREIGN KEY (loai_nhom_bao_cao_id) REFERENCES dm_loai_nhom_bao_cao(id) ON DELETE CASCADE
);

CREATE TABLE emr_uy_quyen_ky_so_chi_tiet (
	id uuid DEFAULT gen_random_uuid() NOT NULL,
	ma_cskcb varchar(50) NULL,
	bi_xoa int2 DEFAULT 0 NOT NULL,
	ngay_tao timestamp DEFAULT now() NOT NULL,
	nguoi_tao varchar(50) NULL,
	ngay_cap_nhat timestamp DEFAULT now() NOT NULL,
	nguoi_cap_nhat varchar(50) NULL,
	ngay_xoa timestamp NULL,
	nguoi_xoa varchar(50) NULL,
	uy_quyen_ky_so_id uuid NOT NULL,
	nguoi_duoc_uy_quyen_id uuid NOT NULL,
	khoa_id uuid NULL,
	loai_uy_quyen varchar(100) NOT NULL,
	tu_ngay date NOT NULL,
	den_ngay date NOT NULL,
	trang_thai varchar(30) NOT NULL,
	ly_do_ket_thuc varchar(500) NULL,
	CONSTRAINT ck_emr_uqks_ct_date CHECK ((den_ngay >= tu_ngay)),
	CONSTRAINT ck_emr_uqks_ct_status CHECK (((trang_thai)::text = ANY (ARRAY[('SOAN_THAO'::character varying)::text, ('DA_XAC_NHAN'::character varying)::text, ('HIEU_LUC'::character varying)::text, ('HUY_BO'::character varying)::text, ('HET_HAN'::character varying)::text, ('KET_THUC'::character varying)::text]))),
	CONSTRAINT emr_uy_quyen_ky_so_chi_tiet_pkey PRIMARY KEY (id),
	CONSTRAINT emr_uy_quyen_ky_so_chi_tiet_uy_quyen_ky_so_id_fkey FOREIGN KEY (uy_quyen_ky_so_id) REFERENCES emr_uy_quyen_ky_so(id)
);

CREATE TABLE pl_nhom_nguoi_dung_function_mapping (
	id uuid DEFAULT gen_random_uuid() NOT NULL,
	nhom_nguoi_dung_id uuid NOT NULL,
	function_id uuid NOT NULL,
	ngay_tao timestamp DEFAULT now() NOT NULL,
	nguoi_tao varchar(100) DEFAULT 'system'::character varying NOT NULL,
	ngay_cap_nhat timestamp DEFAULT now() NOT NULL,
	nguoi_cap_nhat varchar(100) DEFAULT 'system'::character varying NOT NULL,
	bi_xoa int2 DEFAULT 0 NULL,
	ngay_xoa timestamp NULL,
	nguoi_xoa varchar(100) NULL,
	CONSTRAINT pl_nhom_nguoi_dung_function_mapping_pk_id PRIMARY KEY (id),
	CONSTRAINT pl_nhom_nguoi_dung_function_mapping_unique UNIQUE (nhom_nguoi_dung_id, function_id),
	CONSTRAINT pl_nhom_nguoi_dung_function_mapping_pl_application_feature_func FOREIGN KEY (function_id) REFERENCES pl_application_feature_function(id),
	CONSTRAINT pl_nhom_nguoi_dung_function_mapping_pl_nhom_nguoi_dung_fk FOREIGN KEY (nhom_nguoi_dung_id) REFERENCES pl_nhom_nguoi_dung(id)
);

CREATE TABLE pl_quy_trinh_phe_duyet_buoc_duyet (
	id uuid DEFAULT gen_random_uuid() NOT NULL,
	ma_cskcb varchar NOT NULL,
	pl_quy_trinh_phe_duyet_id uuid NOT NULL,
	stt int2 NOT NULL,
	ten varchar(255) NULL,
	khoa_id uuid NULL,
	phong_id uuid NULL,
	so_nguoi_duyet int4 NULL,
	ngay_tao timestamp DEFAULT now() NULL,
	nguoi_tao varchar(25) NULL,
	ngay_cap_nhat timestamp DEFAULT now() NULL,
	nguoi_cap_nhat varchar(25) NULL,
	bi_xoa int2 DEFAULT 0 NOT NULL,
	ngay_xoa timestamp NULL,
	nguoi_xoa varchar(25) NULL,
	chuc_vu_id uuid NULL,
	cap int2 NOT NULL,
	width int4 DEFAULT 150 NULL,
	height int4 DEFAULT 60 NULL,
	position_x int4 DEFAULT 0 NULL,
	position_y int4 DEFAULT 0 NULL,
	mo_ta text NULL,
	khoa_ids _uuid DEFAULT ARRAY[]::uuid[] NULL,
	chuc_vu_ids _uuid DEFAULT ARRAY[]::uuid[] NULL,
	nhan_vien_ids _uuid DEFAULT ARRAY[]::uuid[] NULL,
	CONSTRAINT pl_quy_trinh_phe_duyet_buoc_duyet_pk PRIMARY KEY (id),
	CONSTRAINT pl_quy_trinh_phe_duyet_buoc_duyet_pl_quy_trinh_phe_duyet_id_fk FOREIGN KEY (pl_quy_trinh_phe_duyet_id) REFERENCES pl_quy_trinh_phe_duyet(id)
);

CREATE TABLE pl_quy_trinh_phe_duyet_quan_he (
	id uuid DEFAULT gen_random_uuid() NOT NULL,
	ma_cskcb varchar NOT NULL,
	pl_quy_trinh_phe_duyet_id uuid NOT NULL,
	cap_duyet_nguon_id uuid NOT NULL,
	cap_duyet_dich_id uuid NOT NULL,
	ngay_tao timestamp DEFAULT now() NULL,
	nguoi_tao varchar(25) NULL,
	ngay_cap_nhat timestamp DEFAULT now() NULL,
	nguoi_cap_nhat varchar(25) NULL,
	bi_xoa int2 DEFAULT 0 NOT NULL,
	ngay_xoa timestamp NULL,
	nguoi_xoa varchar(25) NULL,
	CONSTRAINT pl_quy_trinh_phe_duyet_quan_he_pk PRIMARY KEY (id),
	CONSTRAINT pl_quy_trinh_phe_duyet_quan_he_pl_quy_trinh_phe_duyet_id_fk FOREIGN KEY (pl_quy_trinh_phe_duyet_id) REFERENCES pl_quy_trinh_phe_duyet(id)
);

CREATE TABLE sys_nhom_quyen_dulieu_loai_dieu_tri_mapping (
	sys_nhom_quyen_du_lieu_id uuid DEFAULT gen_random_uuid() NOT NULL,
	dm_loai_dieu_tri_id uuid DEFAULT gen_random_uuid() NOT NULL,
	dm_loai_dieu_tri_ma varchar NULL,
	nguoi_tao varchar(100) DEFAULT 'system'::character varying NOT NULL,
	ngay_tao timestamp DEFAULT now() NOT NULL,
	CONSTRAINT sys_nhom_quyen_dulieu_loai_dieu_tri_mapping_pkey PRIMARY KEY (sys_nhom_quyen_du_lieu_id, dm_loai_dieu_tri_id),
	CONSTRAINT sys_nhom_quyen_dulieu_loai_dieu_tri_mapping_dm_loai_dieu_tri_fk FOREIGN KEY (dm_loai_dieu_tri_id) REFERENCES dm_loai_dieu_tri(id)
);

CREATE TABLE dm_chbc_nhom_bao_cao_dm_loai_nhom_bao_cao_map (
	id uuid DEFAULT gen_random_uuid() NOT NULL,
	loai_bao_cao_id uuid NOT NULL,
	nhom_bao_cao_id uuid NOT NULL,
	ngay_tao timestamp DEFAULT now() NOT NULL,
	nguoi_tao varchar(100) DEFAULT 'system'::character varying NOT NULL,
	bi_xoa int2 DEFAULT 0 NOT NULL,
	ngay_xoa timestamp NULL,
	nguoi_xoa varchar(100) NULL,
	su_dung int2 DEFAULT 1 NOT NULL,
	CONSTRAINT dm_nhom_bao_cao_dm_loai_nhom_bao_cao_map_pkey PRIMARY KEY (id),
	CONSTRAINT uq_chbc_map_nhom_loai UNIQUE (loai_bao_cao_id, nhom_bao_cao_id)
);
```
