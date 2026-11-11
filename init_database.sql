-- ====================================================================
-- DATABASE INITIALIZATION & SEED SCRIPT FOR BOOKSTORE MANAGEMENT SYSTEM
-- Project: SWD392 (Team PS06)
-- Target RDBMS: Microsoft SQL Server 2019+ (T-SQL)
-- Database Name: BookStoreDB
-- Total Tables: 33 tables (UML 2.5 ERD) + 1 audit_logs = 34 tables
-- Sample Data: 15 Books & 5-7 sample records per table
-- ====================================================================

-- 1. Create Database if not exists
IF NOT EXISTS (SELECT 1 FROM sys.databases WHERE name = 'BookStoreDB')
BEGIN
    CREATE DATABASE BookStoreDB COLLATE Latin1_General_100_CI_AS_SC_UTF8;
END;
GO

USE BookStoreDB;
GO

-- ====================================================================
-- PHẦN I: ĐỊNH NGHĨA CẤU TRÚC 34 BẢNG (DDL)
-- ====================================================================

-- --------------------------------------------------------------------
-- 1. PHÂN HỆ TÀI KHOẢN, PHÂN QUYỀN & ĐỊA CHỈ (Users, Roles, Addresses)
-- --------------------------------------------------------------------

-- 1.1. Bảng roles (Vai trò)
IF OBJECT_ID('dbo.roles', 'U') IS NULL
CREATE TABLE dbo.roles (
    id BIGINT IDENTITY(1,1) PRIMARY KEY,
    role_name VARCHAR(50) NOT NULL UNIQUE,
    description NVARCHAR(255) NULL
);
GO

-- 1.2. Bảng users (Tài khoản người dùng)
IF OBJECT_ID('dbo.users', 'U') IS NULL
CREATE TABLE dbo.users (
    id BIGINT IDENTITY(1,1) PRIMARY KEY,
    email VARCHAR(150) NOT NULL UNIQUE,
    password_hash VARCHAR(255) NULL,
    full_name NVARCHAR(100) NOT NULL,
    phone_number VARCHAR(15) NULL,
    avatar_url VARCHAR(500) NULL,
    gender NVARCHAR(10) NULL,
    dob DATE NULL,
    google_id VARCHAR(100) NULL,
    auth_provider VARCHAR(20) NOT NULL DEFAULT 'LOCAL',
    email_verification_token VARCHAR(255) NULL,
    is_email_verified BIT NOT NULL DEFAULT 0,
    reset_password_token VARCHAR(255) NULL,
    reset_password_token_expiry DATETIME2 NULL,
    status VARCHAR(20) NOT NULL DEFAULT 'ACTIVE',
    is_deleted BIT NOT NULL DEFAULT 0,
    created_at DATETIME2 NOT NULL DEFAULT GETDATE(),
    updated_at DATETIME2 NOT NULL DEFAULT GETDATE()
);
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = 'UQ_users_google_id' AND object_id = OBJECT_ID('dbo.users'))
BEGIN
    CREATE UNIQUE NONCLUSTERED INDEX UQ_users_google_id
    ON dbo.users(google_id)
    WHERE google_id IS NOT NULL;
END
GO

-- 1.3. Bảng user_roles (Phân quyền Người dùng - Vai trò)
IF OBJECT_ID('dbo.user_roles', 'U') IS NULL
CREATE TABLE dbo.user_roles (
    user_id BIGINT NOT NULL,
    role_id BIGINT NOT NULL,
    assigned_at DATETIME2 NOT NULL DEFAULT GETDATE(),
    PRIMARY KEY (user_id, role_id),
    CONSTRAINT FK_user_roles_user FOREIGN KEY (user_id) REFERENCES dbo.users(id) ON DELETE CASCADE,
    CONSTRAINT FK_user_roles_role FOREIGN KEY (role_id) REFERENCES dbo.roles(id) ON DELETE CASCADE
);
GO

-- 1.4. Bảng user_addresses (Sổ địa chỉ người dùng)
IF OBJECT_ID('dbo.user_addresses', 'U') IS NULL
CREATE TABLE dbo.user_addresses (
    id BIGINT IDENTITY(1,1) PRIMARY KEY,
    user_id BIGINT NOT NULL,
    recipient_name NVARCHAR(100) NOT NULL,
    recipient_phone VARCHAR(15) NOT NULL,
    province_city NVARCHAR(100) NOT NULL,
    district NVARCHAR(100) NOT NULL,
    ward NVARCHAR(100) NOT NULL,
    street_address NVARCHAR(255) NOT NULL,
    is_default BIT NOT NULL DEFAULT 0,
    created_at DATETIME2 NOT NULL DEFAULT GETDATE(),
    CONSTRAINT FK_user_addresses_user FOREIGN KEY (user_id) REFERENCES dbo.users(id) ON DELETE CASCADE
);
GO

-- --------------------------------------------------------------------
-- 2. PHÂN HỆ SÁCH, TÁC GIẢ, NXB, THỂ LOẠI (Catalog & Metadata)
-- --------------------------------------------------------------------

-- 2.1. Bảng publishers (Nhà xuất bản)
IF OBJECT_ID('dbo.publishers', 'U') IS NULL
CREATE TABLE dbo.publishers (
    id BIGINT IDENTITY(1,1) PRIMARY KEY,
    name NVARCHAR(150) NOT NULL UNIQUE,
    email VARCHAR(100) NULL,
    phone_number VARCHAR(20) NULL,
    address NVARCHAR(255) NULL,
    is_deleted BIT NOT NULL DEFAULT 0
);
GO

-- 2.2. Bảng authors (Tác giả)
IF OBJECT_ID('dbo.authors', 'U') IS NULL
CREATE TABLE dbo.authors (
    id BIGINT IDENTITY(1,1) PRIMARY KEY,
    name NVARCHAR(150) NOT NULL,
    biography NVARCHAR(MAX) NULL,
    is_deleted BIT NOT NULL DEFAULT 0
);
GO

-- 2.3. Bảng categories (Danh mục sách)
IF OBJECT_ID('dbo.categories', 'U') IS NULL
CREATE TABLE dbo.categories (
    id BIGINT IDENTITY(1,1) PRIMARY KEY,
    name NVARCHAR(100) NOT NULL UNIQUE,
    parent_id BIGINT NULL,
    description NVARCHAR(500) NULL,
    is_deleted BIT NOT NULL DEFAULT 0,
    CONSTRAINT FK_categories_parent FOREIGN KEY (parent_id) REFERENCES dbo.categories(id)
);
GO

-- 2.4. Bảng genres (Thể loại nội dung sách - Tách độc lập)
IF OBJECT_ID('dbo.genres', 'U') IS NULL
CREATE TABLE dbo.genres (
    id BIGINT IDENTITY(1,1) PRIMARY KEY,
    name NVARCHAR(100) NOT NULL UNIQUE,
    description NVARCHAR(500) NULL,
    is_deleted BIT NOT NULL DEFAULT 0
);
GO

-- 2.5. Bảng books (Thông tin đầu sách)
IF OBJECT_ID('dbo.books', 'U') IS NULL
CREATE TABLE dbo.books (
    id BIGINT IDENTITY(1,1) PRIMARY KEY,
    isbn VARCHAR(20) NOT NULL UNIQUE,
    title NVARCHAR(255) NOT NULL,
    description NVARCHAR(MAX) NULL,
    publisher_id BIGINT NOT NULL,
    publication_year INT NOT NULL,
    cover_type NVARCHAR(50) NOT NULL DEFAULT N'Bìa mềm',
    page_count INT NULL,
    dimensions VARCHAR(50) NULL,
    weight_gram INT NULL,
    cost_price DECIMAL(18,2) NOT NULL DEFAULT 0.00,
    original_price DECIMAL(18,2) NOT NULL,
    sale_price DECIMAL(18,2) NOT NULL,
    image_url VARCHAR(500) NULL,
    status VARCHAR(20) NOT NULL DEFAULT 'ACTIVE',
    created_by BIGINT NULL,
    updated_by BIGINT NULL,
    is_deleted BIT NOT NULL DEFAULT 0,
    created_at DATETIME2 NOT NULL DEFAULT GETDATE(),
    updated_at DATETIME2 NOT NULL DEFAULT GETDATE(),
    CONSTRAINT FK_books_publisher FOREIGN KEY (publisher_id) REFERENCES dbo.publishers(id),
    CONSTRAINT FK_books_created_by FOREIGN KEY (created_by) REFERENCES dbo.users(id),
    CONSTRAINT FK_books_updated_by FOREIGN KEY (updated_by) REFERENCES dbo.users(id)
);
GO

-- 2.6. Bảng book_categories (Liên kết Sách - Danh mục)
IF OBJECT_ID('dbo.book_categories', 'U') IS NULL
CREATE TABLE dbo.book_categories (
    book_id BIGINT NOT NULL,
    category_id BIGINT NOT NULL,
    PRIMARY KEY (book_id, category_id),
    CONSTRAINT FK_book_categories_book FOREIGN KEY (book_id) REFERENCES dbo.books(id) ON DELETE CASCADE,
    CONSTRAINT FK_book_categories_category FOREIGN KEY (category_id) REFERENCES dbo.categories(id) ON DELETE CASCADE
);
GO

-- 2.7. Bảng book_authors (Liên kết Sách - Tác giả)
IF OBJECT_ID('dbo.book_authors', 'U') IS NULL
CREATE TABLE dbo.book_authors (
    book_id BIGINT NOT NULL,
    author_id BIGINT NOT NULL,
    PRIMARY KEY (book_id, author_id),
    CONSTRAINT FK_book_authors_book FOREIGN KEY (book_id) REFERENCES dbo.books(id) ON DELETE CASCADE,
    CONSTRAINT FK_book_authors_author FOREIGN KEY (author_id) REFERENCES dbo.authors(id) ON DELETE CASCADE
);
GO

-- 2.8. Bảng book_genres (Liên kết Sách - Thể loại)
IF OBJECT_ID('dbo.book_genres', 'U') IS NULL
CREATE TABLE dbo.book_genres (
    book_id BIGINT NOT NULL,
    genre_id BIGINT NOT NULL,
    PRIMARY KEY (book_id, genre_id),
    CONSTRAINT FK_book_genres_book FOREIGN KEY (book_id) REFERENCES dbo.books(id) ON DELETE CASCADE,
    CONSTRAINT FK_book_genres_genre FOREIGN KEY (genre_id) REFERENCES dbo.genres(id) ON DELETE CASCADE
);
GO

-- 2.9. Bảng book_images (Album ảnh sách)
IF OBJECT_ID('dbo.book_images', 'U') IS NULL
CREATE TABLE dbo.book_images (
    id BIGINT IDENTITY(1,1) PRIMARY KEY,
    book_id BIGINT NOT NULL,
    image_url VARCHAR(500) NOT NULL,
    is_primary BIT NOT NULL DEFAULT 0,
    display_order INT NOT NULL DEFAULT 0,
    CONSTRAINT FK_book_images_book FOREIGN KEY (book_id) REFERENCES dbo.books(id) ON DELETE CASCADE
);
GO

-- 2.10. Bảng book_price_history (Lịch sử biến động giá)
IF OBJECT_ID('dbo.book_price_history', 'U') IS NULL
CREATE TABLE dbo.book_price_history (
    id BIGINT IDENTITY(1,1) PRIMARY KEY,
    book_id BIGINT NOT NULL,
    old_sale_price DECIMAL(18,2) NOT NULL,
    new_sale_price DECIMAL(18,2) NOT NULL,
    changed_by_user_id BIGINT NOT NULL,
    note NVARCHAR(255) NULL,
    changed_at DATETIME2 NOT NULL DEFAULT GETDATE(),
    CONSTRAINT FK_book_price_history_book FOREIGN KEY (book_id) REFERENCES dbo.books(id) ON DELETE CASCADE,
    CONSTRAINT FK_book_price_history_user FOREIGN KEY (changed_by_user_id) REFERENCES dbo.users(id)
);
GO

-- --------------------------------------------------------------------
-- 3. PHÂN HỆ KHO BÃI, NHẬP HÀNG & THẺ KHO (Inventory & Logistics)
-- --------------------------------------------------------------------

-- 3.1. Bảng inventories (Tồn kho sách)
IF OBJECT_ID('dbo.inventories', 'U') IS NULL
CREATE TABLE dbo.inventories (
    id BIGINT IDENTITY(1,1) PRIMARY KEY,
    book_id BIGINT NOT NULL UNIQUE,
    stock_quantity INT NOT NULL DEFAULT 0,
    reserved_quantity INT NOT NULL DEFAULT 0,
    low_stock_threshold INT NOT NULL DEFAULT 5,
    updated_by BIGINT NULL,
    updated_at DATETIME2 NOT NULL DEFAULT GETDATE(),
    CONSTRAINT FK_inventories_book FOREIGN KEY (book_id) REFERENCES dbo.books(id) ON DELETE CASCADE,
    CONSTRAINT FK_inventories_updated_by FOREIGN KEY (updated_by) REFERENCES dbo.users(id)
);
GO

-- 3.2. Bảng goods_receipts (Phiếu nhập kho)
IF OBJECT_ID('dbo.goods_receipts', 'U') IS NULL
CREATE TABLE dbo.goods_receipts (
    id BIGINT IDENTITY(1,1) PRIMARY KEY,
    receipt_code VARCHAR(50) NOT NULL UNIQUE,
    publisher_id BIGINT NOT NULL,
    created_by_user_id BIGINT NOT NULL,
    approved_by_user_id BIGINT NULL,
    total_amount DECIMAL(18,2) NOT NULL DEFAULT 0.00,
    status VARCHAR(20) NOT NULL DEFAULT 'PENDING',
    note NVARCHAR(500) NULL,
    created_at DATETIME2 NOT NULL DEFAULT GETDATE(),
    approved_at DATETIME2 NULL,
    CONSTRAINT FK_goods_receipts_publisher FOREIGN KEY (publisher_id) REFERENCES dbo.publishers(id),
    CONSTRAINT FK_goods_receipts_created_by FOREIGN KEY (created_by_user_id) REFERENCES dbo.users(id),
    CONSTRAINT FK_goods_receipts_approved_by FOREIGN KEY (approved_by_user_id) REFERENCES dbo.users(id)
);
GO

-- 3.3. Bảng goods_receipt_items (Chi tiết phiếu nhập kho)
IF OBJECT_ID('dbo.goods_receipt_items', 'U') IS NULL
CREATE TABLE dbo.goods_receipt_items (
    id BIGINT IDENTITY(1,1) PRIMARY KEY,
    receipt_id BIGINT NOT NULL,
    book_id BIGINT NOT NULL,
    quantity INT NOT NULL,
    import_price DECIMAL(18,2) NOT NULL,
    subtotal DECIMAL(18,2) NOT NULL,
    CONSTRAINT FK_goods_receipt_items_receipt FOREIGN KEY (receipt_id) REFERENCES dbo.goods_receipts(id) ON DELETE CASCADE,
    CONSTRAINT FK_goods_receipt_items_book FOREIGN KEY (book_id) REFERENCES dbo.books(id)
);
GO

-- 3.4. Bảng stock_movements (Thẻ kho - Lịch sử xuất/nhập/kiểm kê)
IF OBJECT_ID('dbo.stock_movements', 'U') IS NULL
CREATE TABLE dbo.stock_movements (
    id BIGINT IDENTITY(1,1) PRIMARY KEY,
    book_id BIGINT NOT NULL,
    movement_type VARCHAR(30) NOT NULL,
    quantity_change INT NOT NULL,
    balance_after INT NOT NULL,
    reference_code VARCHAR(50) NULL,
    note NVARCHAR(255) NULL,
    created_by_user_id BIGINT NOT NULL,
    created_at DATETIME2 NOT NULL DEFAULT GETDATE(),
    CONSTRAINT FK_stock_movements_book FOREIGN KEY (book_id) REFERENCES dbo.books(id),
    CONSTRAINT FK_stock_movements_user FOREIGN KEY (created_by_user_id) REFERENCES dbo.users(id)
);
GO

-- --------------------------------------------------------------------
-- 4. PHÂN HỆ GIỎ HÀNG & DANH SÁCH YÊU THÍCH (Cart & Wishlist)
-- --------------------------------------------------------------------

-- 4.1. Bảng carts (Giỏ hàng người dùng)
IF OBJECT_ID('dbo.carts', 'U') IS NULL
CREATE TABLE dbo.carts (
    id BIGINT IDENTITY(1,1) PRIMARY KEY,
    user_id BIGINT NOT NULL UNIQUE,
    updated_at DATETIME2 NOT NULL DEFAULT GETDATE(),
    CONSTRAINT FK_carts_user FOREIGN KEY (user_id) REFERENCES dbo.users(id) ON DELETE CASCADE
);
GO

-- 4.2. Bảng cart_items (Chi tiết sản phẩm trong giỏ)
IF OBJECT_ID('dbo.cart_items', 'U') IS NULL
CREATE TABLE dbo.cart_items (
    id BIGINT IDENTITY(1,1) PRIMARY KEY,
    cart_id BIGINT NOT NULL,
    book_id BIGINT NOT NULL,
    quantity INT NOT NULL DEFAULT 1,
    is_selected BIT NOT NULL DEFAULT 1,
    created_at DATETIME2 NOT NULL DEFAULT GETDATE(),
    CONSTRAINT UQ_cart_items UNIQUE (cart_id, book_id),
    CONSTRAINT FK_cart_items_cart FOREIGN KEY (cart_id) REFERENCES dbo.carts(id) ON DELETE CASCADE,
    CONSTRAINT FK_cart_items_book FOREIGN KEY (book_id) REFERENCES dbo.books(id)
);
GO

-- 4.3. Bảng wishlists (Sách yêu thích)
IF OBJECT_ID('dbo.wishlists', 'U') IS NULL
CREATE TABLE dbo.wishlists (
    id BIGINT IDENTITY(1,1) PRIMARY KEY,
    user_id BIGINT NOT NULL,
    book_id BIGINT NOT NULL,
    created_at DATETIME2 NOT NULL DEFAULT GETDATE(),
    CONSTRAINT UQ_wishlists UNIQUE (user_id, book_id),
    CONSTRAINT FK_wishlists_user FOREIGN KEY (user_id) REFERENCES dbo.users(id) ON DELETE CASCADE,
    CONSTRAINT FK_wishlists_book FOREIGN KEY (book_id) REFERENCES dbo.books(id)
);
GO

-- --------------------------------------------------------------------
-- 5. PHÂN HỆ MÃ GIẢM GIÁ & VOUCHER (Vouchers & Usages)
-- --------------------------------------------------------------------

-- 5.1. Bảng vouchers (Mã khuyến mãi)
IF OBJECT_ID('dbo.vouchers', 'U') IS NULL
CREATE TABLE dbo.vouchers (
    id BIGINT IDENTITY(1,1) PRIMARY KEY,
    code VARCHAR(50) NOT NULL UNIQUE,
    discount_type VARCHAR(20) NOT NULL, -- 'PERCENT', 'FIXED_AMOUNT'
    discount_value DECIMAL(18,2) NOT NULL,
    max_discount_amount DECIMAL(18,2) NULL,
    min_order_value DECIMAL(18,2) NOT NULL DEFAULT 0.00,
    usage_limit INT NOT NULL DEFAULT 100,
    used_count INT NOT NULL DEFAULT 0,
    usage_limit_per_user INT NOT NULL DEFAULT 1,
    start_date DATETIME2 NOT NULL,
    end_date DATETIME2 NOT NULL,
    status VARCHAR(20) NOT NULL DEFAULT 'ACTIVE',
    created_by BIGINT NULL,
    is_deleted BIT NOT NULL DEFAULT 0,
    CONSTRAINT FK_vouchers_created_by FOREIGN KEY (created_by) REFERENCES dbo.users(id)
);
GO

-- --------------------------------------------------------------------
-- 6. PHÂN HỆ ĐƠN HÀNG, THANH TOÁN & GIAO HÀNG (Orders & Logistics)
-- --------------------------------------------------------------------

-- 6.1. Bảng orders (Đơn đặt hàng)
IF OBJECT_ID('dbo.orders', 'U') IS NULL
CREATE TABLE dbo.orders (
    id BIGINT IDENTITY(1,1) PRIMARY KEY,
    order_code VARCHAR(50) NOT NULL UNIQUE,
    user_id BIGINT NOT NULL,
    recipient_name NVARCHAR(100) NOT NULL,
    recipient_phone VARCHAR(15) NOT NULL,
    shipping_address NVARCHAR(500) NOT NULL,
    total_book_amount DECIMAL(18,2) NOT NULL,
    shipping_fee DECIMAL(18,2) NOT NULL DEFAULT 0.00,
    voucher_id BIGINT NULL,
    discount_amount DECIMAL(18,2) NOT NULL DEFAULT 0.00,
    final_amount DECIMAL(18,2) NOT NULL,
    payment_method VARCHAR(20) NOT NULL DEFAULT 'COD',
    payment_status VARCHAR(20) NOT NULL DEFAULT 'PENDING',
    status VARCHAR(30) NOT NULL DEFAULT 'PENDING',
    customer_note NVARCHAR(500) NULL,
    cancel_reason NVARCHAR(255) NULL,
    created_at DATETIME2 NOT NULL DEFAULT GETDATE(),
    updated_at DATETIME2 NOT NULL DEFAULT GETDATE(),
    CONSTRAINT FK_orders_user FOREIGN KEY (user_id) REFERENCES dbo.users(id),
    CONSTRAINT FK_orders_voucher FOREIGN KEY (voucher_id) REFERENCES dbo.vouchers(id)
);
GO

-- 6.2. Bảng order_items (Chi tiết món hàng trong đơn)
IF OBJECT_ID('dbo.order_items', 'U') IS NULL
CREATE TABLE dbo.order_items (
    id BIGINT IDENTITY(1,1) PRIMARY KEY,
    order_id BIGINT NOT NULL,
    book_id BIGINT NOT NULL,
    book_title NVARCHAR(255) NOT NULL,
    quantity INT NOT NULL,
    unit_price DECIMAL(18,2) NOT NULL,
    subtotal DECIMAL(18,2) NOT NULL,
    CONSTRAINT FK_order_items_order FOREIGN KEY (order_id) REFERENCES dbo.orders(id) ON DELETE CASCADE,
    CONSTRAINT FK_order_items_book FOREIGN KEY (book_id) REFERENCES dbo.books(id)
);
GO

-- 6.3. Bảng order_status_history (Lịch sử trạng thái đơn hàng)
IF OBJECT_ID('dbo.order_status_history', 'U') IS NULL
CREATE TABLE dbo.order_status_history (
    id BIGINT IDENTITY(1,1) PRIMARY KEY,
    order_id BIGINT NOT NULL,
    status VARCHAR(30) NOT NULL,
    note NVARCHAR(255) NULL,
    changed_by_user_id BIGINT NULL,
    created_at DATETIME2 NOT NULL DEFAULT GETDATE(),
    CONSTRAINT FK_order_status_history_order FOREIGN KEY (order_id) REFERENCES dbo.orders(id) ON DELETE CASCADE,
    CONSTRAINT FK_order_status_history_user FOREIGN KEY (changed_by_user_id) REFERENCES dbo.users(id)
);
GO

-- 6.4. Bảng payment_transactions (Giao dịch thanh toán)
IF OBJECT_ID('dbo.payment_transactions', 'U') IS NULL
CREATE TABLE dbo.payment_transactions (
    id BIGINT IDENTITY(1,1) PRIMARY KEY,
    order_id BIGINT NOT NULL,
    payment_method VARCHAR(20) NOT NULL,
    amount DECIMAL(18,2) NOT NULL,
    transaction_code VARCHAR(100) NULL,
    status VARCHAR(20) NOT NULL DEFAULT 'PENDING',
    gateway_response NVARCHAR(MAX) NULL,
    paid_at DATETIME2 NULL,
    created_at DATETIME2 NOT NULL DEFAULT GETDATE(),
    CONSTRAINT FK_payment_transactions_order FOREIGN KEY (order_id) REFERENCES dbo.orders(id) ON DELETE CASCADE
);
GO

-- 6.5. Bảng shipping_orders (Vận đơn giao hàng)
IF OBJECT_ID('dbo.shipping_orders', 'U') IS NULL
CREATE TABLE dbo.shipping_orders (
    id BIGINT IDENTITY(1,1) PRIMARY KEY,
    order_id BIGINT NOT NULL UNIQUE,
    carrier_name NVARCHAR(100) NOT NULL,
    tracking_code VARCHAR(100) NOT NULL,
    shipping_fee DECIMAL(18,2) NOT NULL DEFAULT 0.00,
    status VARCHAR(30) NOT NULL DEFAULT 'READY_TO_PICK',
    estimated_delivery_date DATE NULL,
    created_at DATETIME2 NOT NULL DEFAULT GETDATE(),
    updated_at DATETIME2 NOT NULL DEFAULT GETDATE(),
    CONSTRAINT FK_shipping_orders_order FOREIGN KEY (order_id) REFERENCES dbo.orders(id) ON DELETE CASCADE
);
GO

-- 6.6. Bảng voucher_usages (Lịch sử sử dụng voucher)
IF OBJECT_ID('dbo.voucher_usages', 'U') IS NULL
CREATE TABLE dbo.voucher_usages (
    id BIGINT IDENTITY(1,1) PRIMARY KEY,
    voucher_id BIGINT NOT NULL,
    user_id BIGINT NOT NULL,
    order_id BIGINT NOT NULL,
    discount_amount DECIMAL(18,2) NOT NULL,
    used_at DATETIME2 NOT NULL DEFAULT GETDATE(),
    CONSTRAINT FK_voucher_usages_voucher FOREIGN KEY (voucher_id) REFERENCES dbo.vouchers(id),
    CONSTRAINT FK_voucher_usages_user FOREIGN KEY (user_id) REFERENCES dbo.users(id),
    CONSTRAINT FK_voucher_usages_order FOREIGN KEY (order_id) REFERENCES dbo.orders(id)
);
GO

-- --------------------------------------------------------------------
-- 7. PHÂN HỆ ĐÁNH GIÁ, ĐỔI TRẢ, THÔNG BÁO & KIỂM TOÁN (Post-Sales & Logs)
-- --------------------------------------------------------------------

-- 7.1. Bảng reviews (Đánh giá & Nhận xét sách)
IF OBJECT_ID('dbo.reviews', 'U') IS NULL
CREATE TABLE dbo.reviews (
    id BIGINT IDENTITY(1,1) PRIMARY KEY,
    user_id BIGINT NOT NULL,
    book_id BIGINT NOT NULL,
    order_id BIGINT NOT NULL,
    rating TINYINT NOT NULL CHECK (rating BETWEEN 1 AND 5),
    comment NVARCHAR(MAX) NULL,
    status VARCHAR(20) NOT NULL DEFAULT 'APPROVED',
    moderated_by_user_id BIGINT NULL,
    created_at DATETIME2 NOT NULL DEFAULT GETDATE(),
    updated_at DATETIME2 NOT NULL DEFAULT GETDATE(),
    CONSTRAINT UQ_reviews_user_book_order UNIQUE (user_id, book_id, order_id),
    CONSTRAINT FK_reviews_user FOREIGN KEY (user_id) REFERENCES dbo.users(id),
    CONSTRAINT FK_reviews_book FOREIGN KEY (book_id) REFERENCES dbo.books(id),
    CONSTRAINT FK_reviews_order FOREIGN KEY (order_id) REFERENCES dbo.orders(id),
    CONSTRAINT FK_reviews_moderated_by FOREIGN KEY (moderated_by_user_id) REFERENCES dbo.users(id)
);
GO

-- 7.2. Bảng return_requests (Yêu cầu trả hàng & hoàn tiền)
IF OBJECT_ID('dbo.return_requests', 'U') IS NULL
CREATE TABLE dbo.return_requests (
    id BIGINT IDENTITY(1,1) PRIMARY KEY,
    order_id BIGINT NOT NULL,
    user_id BIGINT NOT NULL,
    reason NVARCHAR(500) NOT NULL,
    evidence_image_url VARCHAR(500) NULL,
    total_refund_amount DECIMAL(18,2) NOT NULL,
    status VARCHAR(20) NOT NULL DEFAULT 'PENDING',
    staff_note NVARCHAR(500) NULL,
    processed_by_user_id BIGINT NULL,
    created_at DATETIME2 NOT NULL DEFAULT GETDATE(),
    processed_at DATETIME2 NULL,
    CONSTRAINT FK_return_requests_order FOREIGN KEY (order_id) REFERENCES dbo.orders(id),
    CONSTRAINT FK_return_requests_user FOREIGN KEY (user_id) REFERENCES dbo.users(id),
    CONSTRAINT FK_return_requests_processed_by FOREIGN KEY (processed_by_user_id) REFERENCES dbo.users(id)
);
GO

-- 7.3. Bảng return_items (Chi tiết sách trong yêu cầu trả hàng)
IF OBJECT_ID('dbo.return_items', 'U') IS NULL
CREATE TABLE dbo.return_items (
    id BIGINT IDENTITY(1,1) PRIMARY KEY,
    return_request_id BIGINT NOT NULL,
    book_id BIGINT NOT NULL,
    quantity INT NOT NULL,
    refund_price DECIMAL(18,2) NOT NULL,
    CONSTRAINT FK_return_items_request FOREIGN KEY (return_request_id) REFERENCES dbo.return_requests(id) ON DELETE CASCADE,
    CONSTRAINT FK_return_items_book FOREIGN KEY (book_id) REFERENCES dbo.books(id)
);
GO

-- 7.4. Bảng notifications (Nội dung thông báo)
IF OBJECT_ID('dbo.notifications', 'U') IS NULL
CREATE TABLE dbo.notifications (
    id BIGINT IDENTITY(1,1) PRIMARY KEY,
    title NVARCHAR(200) NOT NULL,
    message NVARCHAR(MAX) NOT NULL,
    type VARCHAR(20) NOT NULL DEFAULT 'SYSTEM',
    reference_id BIGINT NULL,
    created_at DATETIME2 NOT NULL DEFAULT GETDATE()
);
GO

-- 7.5. Bảng user_notifications (Trạng thái đọc thông báo của User)
IF OBJECT_ID('dbo.user_notifications', 'U') IS NULL
CREATE TABLE dbo.user_notifications (
    id BIGINT IDENTITY(1,1) PRIMARY KEY,
    notification_id BIGINT NOT NULL,
    user_id BIGINT NOT NULL,
    is_read BIT NOT NULL DEFAULT 0,
    read_at DATETIME2 NULL,
    CONSTRAINT FK_user_notif_notification FOREIGN KEY (notification_id) REFERENCES dbo.notifications(id) ON DELETE CASCADE,
    CONSTRAINT FK_user_notif_user FOREIGN KEY (user_id) REFERENCES dbo.users(id) ON DELETE CASCADE
);
GO

-- 7.6. Bảng audit_logs (Nhật ký kiểm toán hệ thống)
IF OBJECT_ID('dbo.audit_logs', 'U') IS NULL
CREATE TABLE dbo.audit_logs (
    id BIGINT IDENTITY(1,1) PRIMARY KEY,
    user_id BIGINT NULL,
    action VARCHAR(50) NOT NULL,
    entity_name VARCHAR(50) NOT NULL,
    entity_id BIGINT NULL,
    ip_address VARCHAR(45) NULL,
    old_value NVARCHAR(MAX) NULL,
    new_value NVARCHAR(MAX) NULL,
    created_at DATETIME2 NOT NULL DEFAULT GETDATE(),
    CONSTRAINT FK_audit_logs_user FOREIGN KEY (user_id) REFERENCES dbo.users(id)
);
GO

-- ====================================================================
-- PHẦN II: DỮ LIỆU MẪU BAN ĐẦU (SEED DATA - 15 SÁCH & 5-7 BẢN GHI/BẢNG)
-- ====================================================================

-- 1. Chèn Bảng roles (4 vai trò)
SET IDENTITY_INSERT dbo.roles ON;
IF NOT EXISTS (SELECT 1 FROM dbo.roles WHERE id = 1)
INSERT INTO dbo.roles (id, role_name, description) VALUES
(1, 'ADMIN', N'Quản trị viên toàn quyền hệ thống'),
(2, 'STAFF', N'Nhân viên bán hàng và xử lý đơn'),
(3, 'INVENTORY_STAFF', N'Nhân viên quản lý kho và nhập sách'),
(4, 'BUYER', N'Khách hàng mua sách');
SET IDENTITY_INSERT dbo.roles OFF;
GO

-- 2. Chèn Bảng users (7 tài khoản thực tế)
SET IDENTITY_INSERT dbo.users ON;
IF NOT EXISTS (SELECT 1 FROM dbo.users WHERE id = 1)
INSERT INTO dbo.users (id, email, password_hash, full_name, phone_number, avatar_url, gender, dob, auth_provider, is_email_verified, status) VALUES
(1, 'admin@bookstore.com', '$2a$12$e8Yy8n8R2uG3X/gZlD1g3.N6Y0F41t9pU8C5S7o5O9f8m4s8m6n3.', N'Trần Thành Trung (Admin)', '0901234567', '/static/avatars/admin.png', N'Nam', '1995-05-15', 'LOCAL', 1, 'ACTIVE'),
(2, 'staff.hien@bookstore.com', '$2a$12$e8Yy8n8R2uG3X/gZlD1g3.N6Y0F41t9pU8C5S7o5O9f8m4s8m6n3.', N'Phạm Dương Thế Hiển (Staff)', '0978974912', '/static/avatars/staff_hien.png', N'Nam', '1998-08-20', 'LOCAL', 1, 'ACTIVE'),
(3, 'staff.truyen@bookstore.com', '$2a$12$e8Yy8n8R2uG3X/gZlD1g3.N6Y0F41t9pU8C5S7o5O9f8m4s8m6n3.', N'Nguyễn Thị Mỹ Truyện (Kho)', '0942380704', '/static/avatars/staff_truyen.png', N'Nữ', '1999-11-07', 'LOCAL', 1, 'ACTIVE'),
(4, 'buyer.trung@gmail.com', '$2a$12$e8Yy8n8R2uG3X/gZlD1g3.N6Y0F41t9pU8C5S7o5O9f8m4s8m6n3.', N'Trần Thành Trung', '0866760449', '/static/avatars/buyer_trung.png', N'Nam', '2001-01-10', 'LOCAL', 1, 'ACTIVE'),
(5, 'buyer.khang@gmail.com', '$2a$12$e8Yy8n8R2uG3X/gZlD1g3.N6Y0F41t9pU8C5S7o5O9f8m4s8m6n3.', N'Diệp Vĩ Khang', '0977757253', '/static/avatars/buyer_khang.png', N'Nam', '2001-04-12', 'LOCAL', 1, 'ACTIVE'),
(6, 'buyer.xuyen@gmail.com', '$2a$12$e8Yy8n8R2uG3X/gZlD1g3.N6Y0F41t9pU8C5S7o5O9f8m4s8m6n3.', N'Đào Thị Mỹ Xuyên', '0975035545', '/static/avatars/buyer_xuyen.png', N'Nữ', '2002-09-25', 'LOCAL', 1, 'ACTIVE'),
(7, 'buyer.hoangyen@gmail.com', '$2a$12$e8Yy8n8R2uG3X/gZlD1g3.N6Y0F41t9pU8C5S7o5O9f8m4s8m6n3.', N'Lê Hoàng Yến', '0912345678', '/static/avatars/buyer_yen.png', N'Nữ', '2000-12-05', 'LOCAL', 1, 'ACTIVE');
SET IDENTITY_INSERT dbo.users OFF;
GO

-- 3. Chèn Bảng user_roles (Gán quyền)
IF NOT EXISTS (SELECT 1 FROM dbo.user_roles WHERE user_id = 1 AND role_id = 1)
INSERT INTO dbo.user_roles (user_id, role_id) VALUES
(1, 1), -- Admin
(2, 2), -- Staff
(3, 3), -- Inventory Staff
(4, 4), -- Buyer
(5, 4), -- Buyer
(6, 4), -- Buyer
(7, 4); -- Buyer
GO

-- 4. Chèn Bảng user_addresses (6 địa chỉ mẫu)
SET IDENTITY_INSERT dbo.user_addresses ON;
IF NOT EXISTS (SELECT 1 FROM dbo.user_addresses WHERE id = 1)
INSERT INTO dbo.user_addresses (id, user_id, recipient_name, recipient_phone, province_city, district, ward, street_address, is_default) VALUES
(1, 4, N'Trần Thành Trung', '0866760449', N'TP. Hồ Chí Minh', N'Quận 1', N'Phường Bến Nghé', N'Số 12 Lê Duẩn', 1),
(2, 4, N'Trần Thành Trung (Cơ quan)', '0866760449', N'TP. Hồ Chí Minh', N'Quận 7', N'Phường Tân Phong', N'Số 45 Nguyễn Thị Thập', 0),
(3, 5, N'Diệp Vĩ Khang', '0977757253', N'Đà Nẵng', N'Quận Hải Châu', N'Phường Thạch Thang', N'Số 88 Bạch Đằng', 1),
(4, 6, N'Đào Thị Mỹ Xuyên', '0975035545', N'Hà Nội', N'Quận Cầu Giấy', N'Phường Dịch Vọng', N'Số 102 Cầu Giấy', 1),
(5, 6, N'Đào Thị Mỹ Xuyên (Nhà riêng)', '0975035545', N'Hà Nội', N'Quận Hoàn Kiếm', N'Phường Hàng Bài', N'Số 26 Hàng Bài', 0),
(6, 7, N'Lê Hoàng Yến', '0912345678', N'Hải Phòng', N'Quận Ngô Quyền', N'Phường Máy Chai', N'Số 15 Lạc Viên', 1);
SET IDENTITY_INSERT dbo.user_addresses OFF;
GO

-- 5. Chèn Bảng publishers (6 Nhà xuất bản)
SET IDENTITY_INSERT dbo.publishers ON;
IF NOT EXISTS (SELECT 1 FROM dbo.publishers WHERE id = 1)
INSERT INTO dbo.publishers (id, name, email, phone_number, address) VALUES
(1, N'NXB Trẻ', 'contact@nxbtre.com.vn', '02839316289', N'161B Lý Chính Thắng, P. Võ Thị Sáu, Q.3, TP.HCM'),
(2, N'NXB Kim Đồng', 'info@nxbkimdong.com.vn', '02439434730', N'55 Quang Trung, Q. Hai Bà Trưng, Hà Nội'),
(3, N'NXB Tổng Hợp TP.HCM', 'tonghop@nxbhcm.com.vn', '02838225340', N'62 Nguyễn Thị Minh Khai, Q.1, TP.HCM'),
(4, N'NXB Hội Nhà Văn', 'nxbhoinhavan@gmail.com', '02438222135', N'65 Nguyễn Du, Q. Hai Bà Trưng, Hà Nội'),
(5, N'NXB Văn Học', 'nxbvanhoc@hn.vnn.vn', '02438252111', N'18 Nguyễn Trường Tộ, Ba Đình, Hà Nội'),
(6, N'NXB Phụ Nữ Việt Nam', 'truyenthongnxbpn@gmail.com', '02439710798', N'39 Hàng Chuối, Q. Hai Bà Trưng, Hà Nội');
SET IDENTITY_INSERT dbo.publishers OFF;
GO

-- 6. Chèn Bảng authors (13 Tác giả nổi tiếng)
SET IDENTITY_INSERT dbo.authors ON;
IF NOT EXISTS (SELECT 1 FROM dbo.authors WHERE id = 1)
INSERT INTO dbo.authors (id, name, biography) VALUES
(1, N'Nguyễn Nhật Ánh', N'Nhà văn nổi tiếng Việt Nam gắn liền với nhiều tác phẩm tuổi học trò và thanh xuân trong trẻo.'),
(2, N'Nguyễn Ngọc Tư', N'Nữ nhà văn tài năng miền Tây Nam Bộ với giọng văn mộc mạc, đậm chất trữ tình và nỗi niềm trắc ẩn.'),
(3, N'Dale Carnegie', N'Tác giả, nhà thuyết trình lỗi lạc người Mỹ, cha đẻ của các tác phẩm đối nhân xử thế kinh điển.'),
(4, N'Paulo Coelho', N'Tiểu thuyết gia lừng danh người Brazil, tác giả cuốn sách huyền thoại Nhà Giả Kim bán chạy toàn cầu.'),
(5, N'Haruki Murakami', N'Nhà văn Nhật Bản nổi tiếng thế giới với phong cách hiện thực huyền ảo và nỗi cô đơn thời hiện đại.'),
(6, N'J.K. Rowling', N'Nữ văn sĩ người Anh, tác giả của bộ tiểu thuyết giả tưởng kinh điển thế giới Harry Potter.'),
(7, N'George Orwell', N'Nhà văn, nhà báo kiệt xuất người Anh với những trang viết sâu sắc về xã hội và tự do con người.'),
(8, N'Tô Hoài', N'Cây đại thụ của nền văn học Việt Nam, tác giả của truyện đồng thoại Dế Mèn Phiêu Lưu Ký.'),
(9, N'Rosie Nguyễn', N'Tác giả, giảng viên yoga và người truyền cảm hứng sống, học tập tích cực cho thế hệ trẻ Việt Nam.'),
(10, N'Robert Kiyosaki', N'Doanh nhân, nhà đầu tư và tác giả bộ sách tài chính cá nhân nổi tiếng Rich Dad Poor Dad.'),
(11, N'Vũ Trọng Phụng', N'Cây bút hiện thực phê phán xuất sắc của văn học Việt Nam với ngòi bút trào phúng sắc sảo.'),
(12, N'Hector Malot', N'Văn hào Pháp với những áng văn lay động lòng người về tình mẫu tử và lòng kiên trì vượt khó.'),
(13, N'Arthur Conan Doyle', N'Nhà văn trinh thám vĩ đại người Scotland, cha đẻ của tượng đài thám tử Sherlock Holmes.');
SET IDENTITY_INSERT dbo.authors OFF;
GO

-- 7. Chèn Bảng categories (6 Danh mục)
SET IDENTITY_INSERT dbo.categories ON;
IF NOT EXISTS (SELECT 1 FROM dbo.categories WHERE id = 1)
INSERT INTO dbo.categories (id, name, description) VALUES
(1, N'Văn học', N'Tiểu thuyết, truyện ngắn, thơ ca và các tác phẩm văn học trong nước, quốc tế'),
(2, N'Kinh tế - Kỹ năng', N'Sách phát triển bản thân, kinh doanh, khởi nghiệp, tài chính và kỹ năng làm việc'),
(3, N'Thiếu nhi', N'Truyện tranh, đồng thoại, bách khoa tri thức nuôi dưỡng tâm hồn trẻ em'),
(4, N'Khoa học - Công nghệ', N'Khám phá vũ trụ, công nghệ thông tin, trí tuệ nhân tạo và kỹ thuật'),
(5, N'Lịch sử - Triết học', N'Nghiên cứu lịch sử văn minh, triết học phương Đông và phương Tây'),
(6, N'Tâm lý - Đời sống', N'Tâm lý học ứng dụng, chữa lành, chăm sóc sức khỏe tinh thần và phong cách sống');
SET IDENTITY_INSERT dbo.categories OFF;
GO

-- 8. Chèn Bảng genres (7 Thể loại nội dung - Chuẩn UML 2.5)
SET IDENTITY_INSERT dbo.genres ON;
IF NOT EXISTS (SELECT 1 FROM dbo.genres WHERE id = 1)
INSERT INTO dbo.genres (id, name, description) VALUES
(1, N'Tiểu thuyết', N'Tác phẩm văn xuôi tự sự dài hơi miêu tả số phận nhân vật và bức tranh xã hội'),
(2, N'Kỹ năng sống', N'Hướng dẫn rèn luyện tư duy tích cực, thấu hiểu bản thân và giao tiếp hiệu quả'),
(3, N'Truyện ngắn', N'Câu chuyện ngắn gọn, súc tích, phản ánh những lát cắt sâu sắc của cuộc đời'),
(4, N'Kỳ ảo (Fantasy)', N'Không gian thần thoại, phép thuật nhiệm màu và thế giới siêu nhiên kỳ thú'),
(5, N'Trinh thám', N'Vụ án ly kỳ, điều tra logic, giải mã bí ẩn với tình tiết bất ngờ cuốn hút'),
(6, N'Tài chính cá nhân', N'Chiến lược quản lý tiền tệ, đầu tư thông minh và tự do tài chính'),
(7, N'Văn học kinh điển', N'Những kiệt tác văn chương bất hủ có giá trị vượt thời gian');
SET IDENTITY_INSERT dbo.genres OFF;
GO

-- 9. Chèn Bảng books (ĐÚNG 15 ĐẦU SÁCH THEO YÊU CẦU)
SET IDENTITY_INSERT dbo.books ON;
IF NOT EXISTS (SELECT 1 FROM dbo.books WHERE id = 1)
INSERT INTO dbo.books (id, isbn, title, description, publisher_id, publication_year, cover_type, page_count, dimensions, weight_gram, cost_price, original_price, sale_price, image_url, status, created_by) VALUES
(1, '9786041001015', N'Mắt Biếc', N'Câu chuyện tình đẹp nhưng đượm buồn của Ngạn và Hà Lan nơi làng Đo Đo mộng mơ.', 1, 2019, N'Bìa mềm', 300, '13 x 20 cm', 350, 70000.00, 110000.00, 99000.00, '/static/books/mat_biec.jpg', 'ACTIVE', 1),
(2, '9786041001022', N'Tôi Thấy Hoa Vàng Trên Cỏ Xanh', N'Những mẩu chuyện tuổi thơ hồn nhiên, trong trẻo nơi làng quê nghèo miền Trung.', 1, 2020, N'Bìa mềm', 378, '13 x 20 cm', 420, 80000.00, 125000.00, 112500.00, '/static/books/hoa_vang.jpg', 'ACTIVE', 1),
(3, '9786041001039', N'Cánh Đồng Bất Tận', N'Tập truyện ngắn khắc họa sâu sắc số phận lênh đênh của những người dân vùng châu thổ sông nước.', 1, 2018, N'Bìa mềm', 220, '13 x 20.5 cm', 280, 55000.00, 85000.00, 76500.00, '/static/books/canh_dong_bat_tan.jpg', 'ACTIVE', 1),
(4, '9786045890011', N'Đắc Nhân Tâm', N'Nghệ thuật đối nhân xử thế, thu phục lòng người và dẫn lối thành công vĩ đại nhất mọi thời đại.', 3, 2021, N'Bìa mềm', 320, '14.5 x 20.5 cm', 380, 50000.00, 86000.00, 77400.00, '/static/books/dac_nhan_tam.jpg', 'ACTIVE', 1),
(5, '9786045890028', N'Quẳng Gánh Lo Đi Và Vui Sống', N'Bí quyết vượt qua nỗi âu lo, làm chủ cảm xúc và sống hạnh phúc trọn vẹn mỗi ngày.', 3, 2021, N'Bìa mềm', 304, '14.5 x 20.5 cm', 360, 52000.00, 88000.00, 79200.00, '/static/books/quang_ganh_lo_di.jpg', 'ACTIVE', 1),
(6, '9786049890035', N'Nhà Giả Kim', N'Hành trình theo đuổi vận mệnh và bài học chiêm nghiệm sâu sắc về giấc mơ của chàng chăn cừu Santiago.', 4, 2022, N'Bìa mềm', 228, '13 x 20.5 cm', 270, 48000.00, 79000.00, 71100.00, '/static/books/nha_gia_kim.jpg', 'ACTIVE', 1),
(7, '9786049890042', N'Rừng Na Uy', N'Kiệt tác văn chương khắc họa nỗi cô đơn và sự trưởng thành đầy trăn trở của giới trẻ Nhật Bản.', 4, 2020, N'Bìa mềm', 552, '14 x 20.5 cm', 600, 90000.00, 145000.00, 130500.00, '/static/books/rung_na_uy.jpg', 'ACTIVE', 1),
(8, '9786041001046', N'Harry Potter và Hòn Đá Phù Thủy', N'Cánh cửa mở ra trường Hogwarts huyền bí và cuộc đối đầu nghẹt thở của cậu bé Harry Potter.', 1, 2022, N'Bìa mềm', 368, '14 x 20 cm', 430, 95000.00, 160000.00, 144000.00, '/static/books/harry_potter_1.jpg', 'ACTIVE', 1),
(9, '9786049540018', N'1984', N'Tiểu thuyết viễn tưởng cảnh báo sâu sắc về sự giám sát và khát vọng tự do của con người.', 5, 2021, N'Bìa mềm', 412, '14 x 20.5 cm', 470, 75000.00, 120000.00, 108000.00, '/static/books/1984.jpg', 'ACTIVE', 1),
(10, '9786042001012', N'Dế Mèn Phiêu Lưu Ký', N'Cuộc chu du kỳ thú và những bài học nhân ái sâu sắc của chú Dế Mèn dũng cảm.', 2, 2022, N'Bìa mềm', 188, '14.5 x 20.5 cm', 240, 35000.00, 60000.00, 54000.00, '/static/books/de_men.jpg', 'ACTIVE', 1),
(11, '9786049890059', N'Tuổi Trẻ Đáng Giá Bao Nhiêu?', N'Cuốn sách thắp lên ngọn lửa nhiệt huyết, định hướng đam mê và phát triển bản thân cho giới trẻ.', 4, 2021, N'Bìa mềm', 292, '14 x 20.5 cm', 350, 55000.00, 90000.00, 81000.00, '/static/books/tuoi_tre.jpg', 'ACTIVE', 1),
(12, '9786041001053', N'Cha Giàu Cha Nghèo (Tập 1)', N'Tư duy tài chính đột phá để tiền bạc làm việc cho bạn thay vì làm việc vì tiền.', 1, 2021, N'Bìa mềm', 260, '14.5 x 20.5 cm', 310, 65000.00, 105000.00, 94500.00, '/static/books/cha_giau_cha_ngheo.jpg', 'ACTIVE', 1),
(13, '9786049540025', N'Số Đỏ', N'Bức tranh trào phúng đả kích sâu cay tầng lớp thượng lưu rởm đời qua nhân vật Xuân Tóc Đỏ.', 5, 2020, N'Bìa mềm', 248, '13 x 20.5 cm', 300, 45000.00, 75000.00, 67500.00, '/static/books/so_do.jpg', 'ACTIVE', 1),
(14, '9786042001029', N'Không Gia Đình', N'Hành trình phiêu lưu đầy cảm động của cậu bé mồ côi Rémi và gánh xiếc cụ Vitalis.', 2, 2021, N'Bìa mềm', 580, '14.5 x 20.5 cm', 650, 85000.00, 140000.00, 126000.00, '/static/books/khong_gia_dinh.jpg', 'ACTIVE', 1),
(15, '9786049540032', N'Sherlock Holmes Toàn Tập (Tập 1)', N'Tuyển tập các vụ phá án tài tình của vị thám tử lừng danh nhất lịch sử văn học trinh thám.', 5, 2022, N'Bìa cứng', 620, '16 x 24 cm', 850, 110000.00, 185000.00, 166500.00, '/static/books/sherlock_holmes_1.jpg', 'ACTIVE', 1);
SET IDENTITY_INSERT dbo.books OFF;
GO

-- 10. Chèn Bảng book_categories (Liên kết 15 Sách - Danh mục)
IF NOT EXISTS (SELECT 1 FROM dbo.book_categories WHERE book_id = 1)
INSERT INTO dbo.book_categories (book_id, category_id) VALUES
(1, 1), -- Mắt Biếc -> Văn học
(2, 1), (2, 3), -- Hoa Vàng -> Văn học, Thiếu nhi
(3, 1), -- Cánh Đồng Bất Tận -> Văn học
(4, 2), -- Đắc Nhân Tâm -> Kinh tế - Kỹ năng
(5, 2), -- Quẳng Gánh Lo Đi -> Kinh tế - Kỹ năng
(6, 1), (6, 5), -- Nhà Giả Kim -> Văn học, Triết học
(7, 1), -- Rừng Na Uy -> Văn học
(8, 1), (8, 3), -- Harry Potter -> Văn học, Thiếu nhi
(9, 1), (9, 5), -- 1984 -> Văn học, Triết học
(10, 3), -- Dế Mèn -> Thiếu nhi
(11, 2), (11, 6), -- Tuổi Trẻ -> Kỹ năng, Đời sống
(12, 2), -- Cha Giàu Cha Nghèo -> Kinh tế
(13, 1), -- Số Đỏ -> Văn học
(14, 3), (14, 1), -- Không Gia Đình -> Thiếu nhi, Văn học
(15, 1); -- Sherlock Holmes -> Văn học
GO

-- 11. Chèn Bảng book_authors (Liên kết 15 Sách - Tác giả)
IF NOT EXISTS (SELECT 1 FROM dbo.book_authors WHERE book_id = 1)
INSERT INTO dbo.book_authors (book_id, author_id) VALUES
(1, 1),  -- Mắt Biếc -> Nguyễn Nhật Ánh
(2, 1),  -- Hoa Vàng -> Nguyễn Nhật Ánh
(3, 2),  -- Cánh Đồng Bất Tận -> Nguyễn Ngọc Tư
(4, 3),  -- Đắc Nhân Tâm -> Dale Carnegie
(5, 3),  -- Quẳng Gánh Lo Đi -> Dale Carnegie
(6, 4),  -- Nhà Giả Kim -> Paulo Coelho
(7, 5),  -- Rừng Na Uy -> Haruki Murakami
(8, 6),  -- Harry Potter -> J.K. Rowling
(9, 7),  -- 1984 -> George Orwell
(10, 8), -- Dế Mèn -> Tô Hoài
(11, 9), -- Tuổi Trẻ -> Rosie Nguyễn
(12, 10),-- Cha Giàu Cha Nghèo -> Robert Kiyosaki
(13, 11),-- Số Đỏ -> Vũ Trọng Phụng
(14, 12),-- Không Gia Đình -> Hector Malot
(15, 13);-- Sherlock Holmes -> Arthur Conan Doyle
GO

-- 12. Chèn Bảng book_genres (Liên kết 15 Sách - Thể loại)
IF NOT EXISTS (SELECT 1 FROM dbo.book_genres WHERE book_id = 1)
INSERT INTO dbo.book_genres (book_id, genre_id) VALUES
(1, 1), -- Mắt Biếc -> Tiểu thuyết
(2, 1), (2, 3), -- Hoa Vàng -> Tiểu thuyết, Truyện ngắn
(3, 3), -- Cánh Đồng Bất Tận -> Truyện ngắn
(4, 2), -- Đắc Nhân Tâm -> Kỹ năng sống
(5, 2), -- Quẳng Gánh Lo Đi -> Kỹ năng sống
(6, 1), (6, 7), -- Nhà Giả Kim -> Tiểu thuyết, Kinh điển
(7, 1), -- Rừng Na Uy -> Tiểu thuyết
(8, 4), -- Harry Potter -> Kỳ ảo
(9, 1), (9, 7), -- 1984 -> Tiểu thuyết, Kinh điển
(10, 3), (10, 7), -- Dế Mèn -> Truyện ngắn, Kinh điển
(11, 2), -- Tuổi Trẻ -> Kỹ năng sống
(12, 6), -- Cha Giàu Cha Nghèo -> Tài chính cá nhân
(13, 1), (13, 7), -- Số Đỏ -> Tiểu thuyết, Kinh điển
(14, 1), (14, 7), -- Không Gia Đình -> Tiểu thuyết, Kinh điển
(15, 5), (15, 7); -- Sherlock Holmes -> Trinh thám, Kinh điển
GO

-- 13. Chèn Bảng book_images (Album ảnh sách)
SET IDENTITY_INSERT dbo.book_images ON;
IF NOT EXISTS (SELECT 1 FROM dbo.book_images WHERE id = 1)
INSERT INTO dbo.book_images (id, book_id, image_url, is_primary, display_order) VALUES
(1, 1, '/static/books/mat_biec_front.jpg', 1, 1),
(2, 1, '/static/books/mat_biec_back.jpg', 0, 2),
(3, 2, '/static/books/hoa_vang_front.jpg', 1, 1),
(4, 3, '/static/books/canh_dong_front.jpg', 1, 1),
(5, 4, '/static/books/dac_nhan_tam_front.jpg', 1, 1),
(6, 4, '/static/books/dac_nhan_tam_inside.jpg', 0, 2),
(7, 5, '/static/books/quang_ganh_front.jpg', 1, 1),
(8, 6, '/static/books/nha_gia_kim_front.jpg', 1, 1),
(9, 7, '/static/books/rung_na_uy_front.jpg', 1, 1),
(10, 8, '/static/books/harry_potter_front.jpg', 1, 1),
(11, 9, '/static/books/1984_front.jpg', 1, 1),
(12, 10, '/static/books/de_men_front.jpg', 1, 1),
(13, 11, '/static/books/tuoi_tre_front.jpg', 1, 1),
(14, 12, '/static/books/cha_giau_front.jpg', 1, 1),
(15, 13, '/static/books/so_do_front.jpg', 1, 1),
(16, 14, '/static/books/khong_gia_dinh_front.jpg', 1, 1),
(17, 15, '/static/books/sherlock_front.jpg', 1, 1);
SET IDENTITY_INSERT dbo.book_images OFF;
GO

-- 14. Chèn Bảng book_price_history (Lịch sử giá)
SET IDENTITY_INSERT dbo.book_price_history ON;
IF NOT EXISTS (SELECT 1 FROM dbo.book_price_history WHERE id = 1)
INSERT INTO dbo.book_price_history (id, book_id, old_sale_price, new_sale_price, changed_by_user_id, note, changed_at) VALUES
(1, 1, 110000.00, 99000.00, 1, N'Áp dụng chương trình ưu đãi 10%', '2026-09-01'),
(2, 2, 125000.00, 112500.00, 1, N'Giảm giá đầu năm học', '2026-09-01'),
(3, 4, 86000.00, 77400.00, 1, N'Chương trình tri ân bạn đọc', '2026-09-15'),
(4, 6, 79000.00, 71100.00, 1, N'Khuyến mãi sách bán chạy', '2026-10-01'),
(5, 8, 160000.00, 144000.00, 1, N'Giảm giá mừng tái bản', '2026-10-10'),
(6, 15, 185000.00, 166500.00, 1, N'Ưu đãi sách bìa cứng kỷ niệm', '2026-10-15');
SET IDENTITY_INSERT dbo.book_price_history OFF;
GO

-- 15. Chèn Bảng inventories (Tồn kho cho đủ 15 đầu sách)
SET IDENTITY_INSERT dbo.inventories ON;
IF NOT EXISTS (SELECT 1 FROM dbo.inventories WHERE id = 1)
INSERT INTO dbo.inventories (id, book_id, stock_quantity, reserved_quantity, low_stock_threshold, updated_by) VALUES
(1, 1, 120, 5, 10, 3),
(2, 2, 95, 2, 10, 3),
(3, 3, 45, 0, 5, 3),
(4, 4, 250, 12, 20, 3),
(5, 5, 110, 4, 10, 3),
(6, 6, 180, 8, 15, 3),
(7, 7, 75, 3, 10, 3),
(8, 8, 140, 6, 15, 3),
(9, 9, 60, 1, 10, 3),
(10, 10, 200, 10, 20, 3),
(11, 11, 85, 2, 10, 3),
(12, 12, 160, 5, 15, 3),
(13, 13, 50, 0, 5, 3),
(14, 14, 70, 2, 10, 3),
(15, 15, 40, 1, 5, 3);
SET IDENTITY_INSERT dbo.inventories OFF;
GO

-- 16. Chèn Bảng goods_receipts (6 Phiếu nhập kho)
SET IDENTITY_INSERT dbo.goods_receipts ON;
IF NOT EXISTS (SELECT 1 FROM dbo.goods_receipts WHERE id = 1)
INSERT INTO dbo.goods_receipts (id, receipt_code, publisher_id, created_by_user_id, approved_by_user_id, total_amount, status, note, created_at, approved_at) VALUES
(1, 'GR-20260901-001', 1, 3, 1, 35000000.00, 'APPROVED', N'Nhập sách tái bản đợt 1 từ NXB Trẻ', '2026-09-01 08:30:00', '2026-09-01 10:00:00'),
(2, 'GR-20260905-002', 3, 3, 1, 28000000.00, 'APPROVED', N'Nhập bộ sách Đắc Nhân Tâm từ NXB Tổng Hợp', '2026-09-05 09:15:00', '2026-09-05 11:30:00'),
(3, 'GR-20260912-003', 4, 3, 1, 32500000.00, 'APPROVED', N'Nhập sách văn học dịch từ NXB Hội Nhà Văn', '2026-09-12 14:00:00', '2026-09-12 16:00:00'),
(4, 'GR-20260920-004', 2, 3, 1, 19500000.00, 'APPROVED', N'Nhập bổ sung sách thiếu nhi từ NXB Kim Đồng', '2026-09-20 10:20:00', '2026-09-20 11:45:00'),
(5, 'GR-20261001-005', 5, 3, 1, 24000000.00, 'APPROVED', N'Nhập tiểu thuyết kinh điển từ NXB Văn Học', '2026-10-01 08:45:00', '2026-10-01 10:15:00'),
(6, 'GR-20261015-006', 1, 3, NULL, 15000000.00, 'PENDING', N'Phiếu nhập chờ duyệt sách đợt tháng 10', '2026-10-15 15:30:00', NULL);
SET IDENTITY_INSERT dbo.goods_receipts OFF;
GO

-- 17. Chèn Bảng goods_receipt_items (Chi tiết phiếu nhập)
SET IDENTITY_INSERT dbo.goods_receipt_items ON;
IF NOT EXISTS (SELECT 1 FROM dbo.goods_receipt_items WHERE id = 1)
INSERT INTO dbo.goods_receipt_items (id, receipt_id, book_id, quantity, import_price, subtotal) VALUES
(1, 1, 1, 150, 70000.00, 10500000.00),
(2, 1, 2, 120, 80000.00, 9600000.00),
(3, 1, 8, 150, 95000.00, 14250000.00),
(4, 2, 4, 300, 50000.00, 15000000.00),
(5, 2, 5, 150, 52000.00, 7800000.00),
(6, 3, 6, 200, 48000.00, 9600000.00),
(7, 3, 7, 100, 90000.00, 9000000.00),
(8, 4, 10, 250, 35000.00, 8750000.00),
(9, 4, 14, 80, 85000.00, 6800000.00),
(10, 5, 9, 80, 75000.00, 6000000.00),
(11, 5, 13, 60, 45000.00, 2700000.00),
(12, 5, 15, 50, 110000.00, 5500000.00);
SET IDENTITY_INSERT dbo.goods_receipt_items OFF;
GO

-- 18. Chèn Bảng stock_movements (Thẻ kho)
SET IDENTITY_INSERT dbo.stock_movements ON;
IF NOT EXISTS (SELECT 1 FROM dbo.stock_movements WHERE id = 1)
INSERT INTO dbo.stock_movements (id, book_id, movement_type, quantity_change, balance_after, reference_code, note, created_by_user_id) VALUES
(1, 1, 'IN_IMPORT', 150, 150, 'GR-20260901-001', N'Nhập hàng ban đầu', 3),
(2, 2, 'IN_IMPORT', 120, 120, 'GR-20260901-001', N'Nhập hàng ban đầu', 3),
(3, 4, 'IN_IMPORT', 300, 300, 'GR-20260905-002', N'Nhập kho số lượng lớn', 3),
(4, 6, 'IN_IMPORT', 200, 200, 'GR-20260912-003', N'Nhập kho sách bán chạy', 3),
(5, 8, 'IN_IMPORT', 150, 150, 'GR-20260901-001', N'Nhập bộ truyện phép thuật', 3),
(6, 1, 'OUT_SALE', -2, 120, 'ORD-20261001-001', N'Xuất bán đơn hàng', 2),
(7, 4, 'OUT_SALE', -1, 250, 'ORD-20261002-002', N'Xuất bán đơn hàng', 2);
SET IDENTITY_INSERT dbo.stock_movements OFF;
GO

-- 19. Chèn Bảng carts (4 Giỏ hàng cho 4 khách hàng)
SET IDENTITY_INSERT dbo.carts ON;
IF NOT EXISTS (SELECT 1 FROM dbo.carts WHERE id = 1)
INSERT INTO dbo.carts (id, user_id, updated_at) VALUES
(1, 4, '2026-10-20 10:00:00'),
(2, 5, '2026-10-21 14:30:00'),
(3, 6, '2026-10-22 09:15:00'),
(4, 7, '2026-10-23 16:45:00');
SET IDENTITY_INSERT dbo.carts OFF;
GO

-- 20. Chèn Bảng cart_items (Chi tiết món trong giỏ)
SET IDENTITY_INSERT dbo.cart_items ON;
IF NOT EXISTS (SELECT 1 FROM dbo.cart_items WHERE id = 1)
INSERT INTO dbo.cart_items (id, cart_id, book_id, quantity, is_selected) VALUES
(1, 1, 1, 1, 1),
(2, 1, 4, 2, 1),
(3, 2, 6, 1, 1),
(4, 2, 8, 1, 1),
(5, 3, 11, 1, 1),
(6, 3, 12, 1, 1),
(7, 4, 15, 1, 1);
SET IDENTITY_INSERT dbo.cart_items OFF;
GO

-- 21. Chèn Bảng wishlists (Sách yêu thích)
SET IDENTITY_INSERT dbo.wishlists ON;
IF NOT EXISTS (SELECT 1 FROM dbo.wishlists WHERE id = 1)
INSERT INTO dbo.wishlists (id, user_id, book_id) VALUES
(1, 4, 7),
(2, 4, 15),
(3, 5, 1),
(4, 5, 9),
(5, 6, 6),
(6, 7, 2),
(7, 7, 8);
SET IDENTITY_INSERT dbo.wishlists OFF;
GO

-- 22. Chèn Bảng vouchers (6 Mã giảm giá)
SET IDENTITY_INSERT dbo.vouchers ON;
IF NOT EXISTS (SELECT 1 FROM dbo.vouchers WHERE id = 1)
INSERT INTO dbo.vouchers (id, code, discount_type, discount_value, max_discount_amount, min_order_value, usage_limit, used_count, usage_limit_per_user, start_date, end_date, status, created_by) VALUES
(1, 'WELCOME50', 'PERCENT', 10.00, 50000.00, 200000.00, 200, 15, 1, '2026-09-01', '2026-12-31', 'ACTIVE', 1),
(2, 'FREESHIP', 'FIXED_AMOUNT', 30000.00, 30000.00, 150000.00, 500, 42, 2, '2026-09-01', '2026-12-31', 'ACTIVE', 1),
(3, 'BOOKWORM10', 'PERCENT', 15.00, 70000.00, 300000.00, 100, 8, 1, '2026-10-01', '2026-11-30', 'ACTIVE', 1),
(4, 'SALE20K', 'FIXED_AMOUNT', 20000.00, 20000.00, 100000.00, 300, 25, 1, '2026-10-01', '2026-12-15', 'ACTIVE', 1),
(5, 'FLASHSALE', 'PERCENT', 20.00, 100000.00, 400000.00, 50, 5, 1, '2026-10-10', '2026-10-25', 'ACTIVE', 1),
(6, 'VIPMEMBER', 'PERCENT', 25.00, 150000.00, 500000.00, 50, 2, 1, '2026-09-01', '2026-12-31', 'ACTIVE', 1);
SET IDENTITY_INSERT dbo.vouchers OFF;
GO

-- 23. Chèn Bảng orders (6 Đơn hàng với đủ các trạng thái)
SET IDENTITY_INSERT dbo.orders ON;
IF NOT EXISTS (SELECT 1 FROM dbo.orders WHERE id = 1)
INSERT INTO dbo.orders (id, order_code, user_id, recipient_name, recipient_phone, shipping_address, total_book_amount, shipping_fee, voucher_id, discount_amount, final_amount, payment_method, payment_status, status, customer_note, created_at) VALUES
(1, 'ORD-20261001-001', 4, N'Trần Thành Trung', '0866760449', N'Số 12 Lê Duẩn, P. Bến Nghé, Q.1, TP.HCM', 275400.00, 25000.00, 1, 27540.00, 272860.00, 'COD', 'PAID', 'DELIVERED', N'Giao giờ hành chính', '2026-10-01 09:30:00'),
(2, 'ORD-20261005-002', 5, N'Diệp Vĩ Khang', '0977757253', N'Số 88 Bạch Đằng, P. Thạch Thang, Q. Hải Châu, Đà Nẵng', 221400.00, 30000.00, 2, 30000.00, 221400.00, 'VNPAY', 'PAID', 'DELIVERED', N'Đóng gói cẩn thận giúp mình', '2026-10-05 14:10:00'),
(3, 'ORD-20261012-003', 6, N'Đào Thị Mỹ Xuyên', '0975035545', N'Số 102 Cầu Giấy, P. Dịch Vọng, Q. Cầu Giấy, Hà Nội', 274500.00, 30000.00, 3, 41175.00, 263325.00, 'VNPAY', 'PAID', 'SHIPPING', N'Gọi trước khi giao', '2026-10-12 11:20:00'),
(4, 'ORD-20261018-004', 7, N'Lê Hoàng Yến', '0912345678', N'Số 15 Lạc Viên, P. Máy Chai, Q. Ngô Quyền, Hải Phòng', 198000.00, 30000.00, 4, 20000.00, 208000.00, 'COD', 'PENDING', 'CONFIRMED', N'Giao buổi chiều', '2026-10-18 16:00:00'),
(5, 'ORD-20261022-005', 4, N'Trần Thành Trung', '0866760449', N'Số 12 Lê Duẩn, P. Bến Nghé, Q.1, TP.HCM', 144000.00, 20000.00, NULL, 0.00, 164000.00, 'COD', 'PENDING', 'PENDING', N'Đơn hàng mới đặt', '2026-10-22 08:30:00'),
(6, 'ORD-20261023-006', 5, N'Diệp Vĩ Khang', '0977757253', N'Số 88 Bạch Đằng, P. Thạch Thang, Q. Hải Châu, Đà Nẵng', 180000.00, 30000.00, NULL, 0.00, 210000.00, 'COD', 'FAILED', 'CANCELLED', N'Hủy do đặt nhầm sách', '2026-10-23 10:15:00');
SET IDENTITY_INSERT dbo.orders OFF;
GO

-- 24. Chèn Bảng order_items (Món hàng trong đơn)
SET IDENTITY_INSERT dbo.order_items ON;
IF NOT EXISTS (SELECT 1 FROM dbo.order_items WHERE id = 1)
INSERT INTO dbo.order_items (id, order_id, book_id, book_title, quantity, unit_price, subtotal) VALUES
(1, 1, 1, N'Mắt Biếc', 1, 99000.00, 99000.00),
(2, 1, 4, N'Đắc Nhân Tâm', 1, 77400.00, 77400.00),
(3, 1, 11, N'Tuổi Trẻ Đáng Giá Bao Nhiêu?', 1, 81000.00, 81000.00),
(4, 2, 6, N'Nhà Giả Kim', 1, 71100.00, 71100.00),
(5, 2, 8, N'Harry Potter và Hòn Đá Phù Thủy', 1, 144000.00, 144000.00),
(6, 3, 7, N'Rừng Na Uy', 1, 130500.00, 130500.00),
(7, 3, 8, N'Harry Potter và Hòn Đá Phù Thủy', 1, 144000.00, 144000.00),
(8, 4, 1, N'Mắt Biếc', 2, 99000.00, 198000.00),
(9, 5, 8, N'Harry Potter và Hòn Đá Phù Thủy', 1, 144000.00, 144000.00),
(10, 6, 2, N'Tôi Thấy Hoa Vàng Trên Cỏ Xanh', 1, 112500.00, 112500.00);
SET IDENTITY_INSERT dbo.order_items OFF;
GO

-- 25. Chèn Bảng order_status_history (Lịch sử trạng thái)
SET IDENTITY_INSERT dbo.order_status_history ON;
IF NOT EXISTS (SELECT 1 FROM dbo.order_status_history WHERE id = 1)
INSERT INTO dbo.order_status_history (id, order_id, status, note, changed_by_user_id, created_at) VALUES
(1, 1, 'PENDING', N'Khách hàng tạo đơn đặt hàng', 4, '2026-10-01 09:30:00'),
(2, 1, 'CONFIRMED', N'Nhân viên xác nhận đơn', 2, '2026-10-01 10:15:00'),
(3, 1, 'SHIPPING', N'Bàn giao đơn vị vận chuyển GHTK', 2, '2026-10-01 14:00:00'),
(4, 1, 'DELIVERED', N'Khách hàng đã nhận hàng và thanh toán', 2, '2026-10-03 16:30:00'),
(5, 2, 'PENDING', N'Khách hàng tạo đơn đặt hàng', 5, '2026-10-05 14:10:00'),
(6, 2, 'CONFIRMED', N'Thanh toán VNPay thành công, xác nhận đơn', 2, '2026-10-05 14:15:00'),
(7, 2, 'SHIPPING', N'Bàn giao đơn vị vận chuyển Viettel Post', 2, '2026-10-06 09:00:00'),
(8, 2, 'DELIVERED', N'Giao hàng thành công', 2, '2026-10-08 11:20:00'),
(9, 3, 'PENDING', N'Khách hàng tạo đơn đặt hàng', 6, '2026-10-12 11:20:00'),
(10, 3, 'CONFIRMED', N'Thanh toán VNPay thành công', 2, '2026-10-12 11:25:00'),
(11, 3, 'SHIPPING', N'Đang trên đường giao cho khách', 2, '2026-10-13 08:30:00'),
(12, 6, 'PENDING', N'Khách hàng tạo đơn đặt hàng', 5, '2026-10-23 10:15:00'),
(13, 6, 'CANCELLED', N'Khách hàng bấm hủy đơn', 5, '2026-10-23 10:30:00');
SET IDENTITY_INSERT dbo.order_status_history OFF;
GO

-- 26. Chèn Bảng payment_transactions (Giao dịch thanh toán)
SET IDENTITY_INSERT dbo.payment_transactions ON;
IF NOT EXISTS (SELECT 1 FROM dbo.payment_transactions WHERE id = 1)
INSERT INTO dbo.payment_transactions (id, order_id, payment_method, amount, transaction_code, status, paid_at) VALUES
(1, 1, 'COD', 272860.00, 'COD-TRX-001', 'PAID', '2026-10-03 16:30:00'),
(2, 2, 'VNPAY', 221400.00, 'VNPAY-20261005-9921', 'PAID', '2026-10-05 14:15:00'),
(3, 3, 'VNPAY', 263325.00, 'VNPAY-20261012-4412', 'PAID', '2026-10-12 11:25:00'),
(4, 4, 'COD', 208000.00, 'COD-TRX-004', 'PENDING', NULL),
(5, 5, 'COD', 164000.00, 'COD-TRX-005', 'PENDING', NULL),
(6, 6, 'COD', 210000.00, 'COD-TRX-006', 'FAILED', NULL);
SET IDENTITY_INSERT dbo.payment_transactions OFF;
GO

-- 27. Chèn Bảng shipping_orders (Vận đơn giao hàng)
SET IDENTITY_INSERT dbo.shipping_orders ON;
IF NOT EXISTS (SELECT 1 FROM dbo.shipping_orders WHERE id = 1)
INSERT INTO dbo.shipping_orders (id, order_id, carrier_name, tracking_code, shipping_fee, status, estimated_delivery_date) VALUES
(1, 1, N'Giao Hàng Tiết Kiệm (GHTK)', 'GHTK-HCM-982103', 25000.00, 'DELIVERED', '2026-10-03'),
(2, 2, N'Viettel Post', 'VTP-DNG-445102', 30000.00, 'DELIVERED', '2026-10-08'),
(3, 3, N'Giao Hàng Nhanh (GHN)', 'GHN-HAN-112948', 30000.00, 'IN_TRANSIT', '2026-10-15'),
(4, 4, N'Giao Hàng Tiết Kiệm (GHTK)', 'GHTK-HPG-339104', 30000.00, 'READY_TO_PICK', '2026-10-21'),
(5, 5, N'Nội thành Hỏa Tốc', 'HT-HCM-551092', 20000.00, 'READY_TO_PICK', '2026-10-23');
SET IDENTITY_INSERT dbo.shipping_orders OFF;
GO

-- 28. Chèn Bảng voucher_usages (Lịch sử dùng voucher)
SET IDENTITY_INSERT dbo.voucher_usages ON;
IF NOT EXISTS (SELECT 1 FROM dbo.voucher_usages WHERE id = 1)
INSERT INTO dbo.voucher_usages (id, voucher_id, user_id, order_id, discount_amount, used_at) VALUES
(1, 1, 4, 1, 27540.00, '2026-10-01 09:30:00'),
(2, 2, 5, 2, 30000.00, '2026-10-05 14:10:00'),
(3, 3, 6, 3, 41175.00, '2026-10-12 11:20:00'),
(4, 4, 7, 4, 20000.00, '2026-10-18 16:00:00');
SET IDENTITY_INSERT dbo.voucher_usages OFF;
GO

-- 29. Chèn Bảng reviews (Đánh giá & Nhận xét)
SET IDENTITY_INSERT dbo.reviews ON;
IF NOT EXISTS (SELECT 1 FROM dbo.reviews WHERE id = 1)
INSERT INTO dbo.reviews (id, user_id, book_id, order_id, rating, comment, status, moderated_by_user_id) VALUES
(1, 4, 1, 1, 5, N'Sách in rất đẹp, bìa mềm cầm chắc tay, câu chuyện Mắt Biếc đọc lại lần nào cũng rưng rưng cảm xúc.', 'APPROVED', 2),
(2, 4, 4, 1, 5, N'Cuốn sách kinh điển gối đầu giường, mọi người đều nên đọc ít nhất một lần trong đời.', 'APPROVED', 2),
(3, 4, 11, 1, 4, N'Sách truyền cảm hứng tốt, lời văn gần gũi và nhiều bài học bổ ích cho sinh viên.', 'APPROVED', 2),
(4, 5, 6, 2, 5, N'Nhà Giả Kim mang đến triết lý sống tuyệt vời, giao hàng đóng gói rất kỹ càng.', 'APPROVED', 2),
(5, 5, 8, 2, 5, N'Bản dịch Harry Potter của bác Lý Lan xuất sắc không cần bàn cãi, giấy in xịn sò.', 'APPROVED', 2),
(6, 6, 7, 3, 4, N'Một câu chuyện tình buồn nhưng đẹp nao lòng, dịch thuật mượt mà.', 'APPROVED', 2);
SET IDENTITY_INSERT dbo.reviews OFF;
GO

-- 30. Chèn Bảng return_requests (Yêu cầu trả hàng & hoàn tiền)
SET IDENTITY_INSERT dbo.return_requests ON;
IF NOT EXISTS (SELECT 1 FROM dbo.return_requests WHERE id = 1)
INSERT INTO dbo.return_requests (id, order_id, user_id, reason, evidence_image_url, total_refund_amount, status, staff_note, processed_by_user_id, created_at, processed_at) VALUES
(1, 1, 4, N'Sách Mắt Biếc bị rách góc gáy sách trong quá trình vận chuyển', '/static/returns/evidence_01.jpg', 99000.00, 'APPROVED', N'Đã đối soát hình ảnh và chấp thuận hoàn tiền', 2, '2026-10-04 10:00:00', '2026-10-04 14:00:00'),
(2, 2, 5, N'Giao nhầm phiên bản bìa sách', '/static/returns/evidence_02.jpg', 71100.00, 'APPROVED', N'Đổi sản phẩm mới cho khách', 2, '2026-10-09 09:30:00', '2026-10-09 11:15:00'),
(3, 3, 6, N'Sách in mờ một số trang đầu', '/static/returns/evidence_03.jpg', 130500.00, 'PENDING', N'Đang chờ khách gửi video xác minh', 2, '2026-10-14 15:20:00', NULL),
(4, 4, 7, N'Khách đổi ý không muốn nhận', '/static/returns/evidence_04.jpg', 99000.00, 'REJECTED', N'Từ chối theo chính sách đổi trả: Không hỗ trợ trả hàng vì lý do đổi ý', 2, '2026-10-19 11:00:00', '2026-10-19 13:45:00'),
(5, 5, 4, N'Trùng sách đã mua trước đó', '/static/returns/evidence_05.jpg', 144000.00, 'PENDING', N'Đang kiểm tra', 2, '2026-10-23 09:00:00', NULL);
SET IDENTITY_INSERT dbo.return_requests OFF;
GO

-- 31. Chèn Bảng return_items (Chi tiết sách đổi trả)
SET IDENTITY_INSERT dbo.return_items ON;
IF NOT EXISTS (SELECT 1 FROM dbo.return_items WHERE id = 1)
INSERT INTO dbo.return_items (id, return_request_id, book_id, quantity, refund_price) VALUES
(1, 1, 1, 1, 99000.00),
(2, 2, 6, 1, 71100.00),
(3, 3, 7, 1, 130500.00),
(4, 4, 1, 1, 99000.00),
(5, 5, 8, 1, 144000.00);
SET IDENTITY_INSERT dbo.return_items OFF;
GO

-- 32. Chèn Bảng notifications (6 Thông báo hệ thống)
SET IDENTITY_INSERT dbo.notifications ON;
IF NOT EXISTS (SELECT 1 FROM dbo.notifications WHERE id = 1)
INSERT INTO dbo.notifications (id, title, message, type, reference_id) VALUES
(1, N'Chào mừng thành viên mới', N'Chào mừng bạn đến với Bookstore! Sử dụng mã WELCOME50 để nhận ngay ưu đãi 10% cho đơn hàng đầu tiên.', 'PROMOTION', NULL),
(2, N'Đơn hàng ORD-20261001-001 đã giao thành công', N'Đơn hàng của bạn đã được giao thành công. Hãy để lại đánh giá để nhận thêm điểm thưởng nhé!', 'ORDER', 1),
(3, N'Đơn hàng ORD-20261005-002 đã được xác nhận', N'Thanh toán VNPay thành công. Nhà sách đang chuẩn bị đơn hàng cho bạn.', 'ORDER', 2),
(4, N'Đại tiệc sách mùa Thu - Giảm đến 50%', N'Hàng ngàn đầu sách hot nhất đang được ưu đãi cực sâu tại Bookstore từ ngày 10/10 đến 25/10.', 'PROMOTION', NULL),
(5, N'Yêu cầu trả hàng đã được duyệt', N'Yêu cầu trả hàng cho đơn hàng ORD-20261001-001 đã được nhân viên chấp thuận.', 'RETURN', 1),
(6, N'Cảnh báo tồn kho thấp', N'Đầu sách Cánh Đồng Bất Tận sắp hết hàng (còn dưới 5 cuốn trong kho). Vui lòng lập phiếu nhập mới.', 'SYSTEM', 3);
SET IDENTITY_INSERT dbo.notifications OFF;
GO

-- 33. Chèn Bảng user_notifications (Trạng thái đọc thông báo)
SET IDENTITY_INSERT dbo.user_notifications ON;
IF NOT EXISTS (SELECT 1 FROM dbo.user_notifications WHERE id = 1)
INSERT INTO dbo.user_notifications (id, notification_id, user_id, is_read, read_at) VALUES
(1, 1, 4, 1, '2026-09-01 10:00:00'),
(2, 2, 4, 1, '2026-10-03 17:00:00'),
(3, 5, 4, 0, NULL),
(4, 1, 5, 1, '2026-09-05 08:30:00'),
(5, 3, 5, 1, '2026-10-05 14:20:00'),
(6, 1, 6, 1, '2026-09-10 12:15:00'),
(7, 4, 6, 0, NULL),
(8, 6, 3, 0, NULL);
SET IDENTITY_INSERT dbo.user_notifications OFF;
GO

-- 34. Chèn Bảng audit_logs (6 Bản ghi nhật ký kiểm toán)
SET IDENTITY_INSERT dbo.audit_logs ON;
IF NOT EXISTS (SELECT 1 FROM dbo.audit_logs WHERE id = 1)
INSERT INTO dbo.audit_logs (id, user_id, action, entity_name, entity_id, ip_address, old_value, new_value) VALUES
(1, 1, 'UPDATE_PRICE', 'books', 1, '192.168.1.10', N'{"sale_price": 110000.00}', N'{"sale_price": 99000.00}'),
(2, 1, 'APPROVE_RECEIPT', 'goods_receipts', 1, '192.168.1.10', N'{"status": "PENDING"}', N'{"status": "APPROVED"}'),
(3, 2, 'UPDATE_ORDER_STATUS', 'orders', 1, '192.168.1.15', N'{"status": "SHIPPING"}', N'{"status": "DELIVERED"}'),
(4, 2, 'APPROVE_RETURN', 'return_requests', 1, '192.168.1.15', N'{"status": "PENDING"}', N'{"status": "APPROVED"}'),
(5, 1, 'CREATE_VOUCHER', 'vouchers', 5, '192.168.1.10', NULL, N'{"code": "FLASHSALE", "discount": 20.00}'),
(6, 2, 'MODERATE_REVIEW', 'reviews', 1, '192.168.1.15', N'{"status": "PENDING"}', N'{"status": "APPROVED"}');
SET IDENTITY_INSERT dbo.audit_logs OFF;
GO

PRINT N'SUCCESS: Đã khởi tạo hoàn tất toàn bộ 34 bảng và nạp đầy đủ dữ liệu mẫu (15 sách, 5-7 bản ghi/bảng) cho BookStoreDB!';
GO