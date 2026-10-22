-- ====================================================================
-- DATABASE INITIALIZATION SCRIPT FOR BOOKSTORE MANAGEMENT SYSTEM
-- Project: SWD392 (Team PS06)
-- Target RDBMS: Microsoft SQL Server (T-SQL)
-- Database Name: BookStoreDB
-- Total Tables: 32 tables adhering strictly to DATABASE_DESCRIPTION.md
-- ====================================================================

-- 1. Create Database if not exists
IF NOT EXISTS (SELECT * FROM sys.databases WHERE name = 'BookStoreDB')
BEGIN
    CREATE DATABASE BookStoreDB;
END
GO

USE BookStoreDB;
GO

-- ====================================================================
-- PHÂN HỆ 1: TÀI KHOẢN, PHÂN QUYỀN & ĐỊA CHỈ (Users, Roles, Addresses)
-- ====================================================================

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

-- Filtered Unique Index cho google_id (cho phép nhiều dòng NULL khi đăng ký bằng Email LOCAL)
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
    CONSTRAINT PK_user_roles PRIMARY KEY (user_id, role_id),
    CONSTRAINT FK_user_roles_user FOREIGN KEY (user_id) REFERENCES dbo.users(id) ON DELETE CASCADE,
    CONSTRAINT FK_user_roles_role FOREIGN KEY (role_id) REFERENCES dbo.roles(id) ON DELETE CASCADE
);
GO

-- 1.4. Bảng user_addresses (Sổ địa chỉ giao hàng)
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

-- ====================================================================
-- PHÂN HỆ 2: DANH MỤC, TÁC GIẢ, NHÀ XUẤT BẢN & SÁCH (Catalog & Metadata)
-- ====================================================================

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
    bio NVARCHAR(MAX) NULL,
    is_deleted BIT NOT NULL DEFAULT 0
);
GO

-- 2.3. Bảng categories (Thể loại sách đa cấp)
IF OBJECT_ID('dbo.categories', 'U') IS NULL
CREATE TABLE dbo.categories (
    id BIGINT IDENTITY(1,1) PRIMARY KEY,
    name NVARCHAR(100) NOT NULL,
    description NVARCHAR(500) NULL,
    parent_id BIGINT NULL,
    is_deleted BIT NOT NULL DEFAULT 0,
    CONSTRAINT FK_categories_parent FOREIGN KEY (parent_id) REFERENCES dbo.categories(id)
);
GO

-- 2.4. Bảng books (Sản phẩm Sách)
IF OBJECT_ID('dbo.books', 'U') IS NULL
CREATE TABLE dbo.books (
    id BIGINT IDENTITY(1,1) PRIMARY KEY,
    title NVARCHAR(255) NOT NULL,
    isbn VARCHAR(20) NOT NULL UNIQUE,
    publisher_id BIGINT NOT NULL,
    publication_year INT NULL,
    edition INT NULL DEFAULT 1,
    price DECIMAL(18,2) NOT NULL CHECK (price >= 0),
    discount_percent INT NOT NULL DEFAULT 0 CHECK (discount_percent >= 0 AND discount_percent <= 100),
    description NVARCHAR(MAX) NULL,
    page_count INT NULL,
    dimensions VARCHAR(50) NULL,
    weight_grams INT NOT NULL DEFAULT 300,
    cover_type NVARCHAR(50) NULL,
    language NVARCHAR(50) NOT NULL DEFAULT N'Tiếng Việt',
    status VARCHAR(20) NOT NULL DEFAULT 'ACTIVE',
    is_deleted BIT NOT NULL DEFAULT 0,
    created_at DATETIME2 NOT NULL DEFAULT GETDATE(),
    updated_at DATETIME2 NOT NULL DEFAULT GETDATE(),
    CONSTRAINT FK_books_publisher FOREIGN KEY (publisher_id) REFERENCES dbo.publishers(id)
);
GO

-- 2.5. Bảng book_categories (Quan hệ nhiều - nhiều Sách và Thể loại)
IF OBJECT_ID('dbo.book_categories', 'U') IS NULL
CREATE TABLE dbo.book_categories (
    book_id BIGINT NOT NULL,
    category_id BIGINT NOT NULL,
    CONSTRAINT PK_book_categories PRIMARY KEY (book_id, category_id),
    CONSTRAINT FK_book_categories_book FOREIGN KEY (book_id) REFERENCES dbo.books(id) ON DELETE CASCADE,
    CONSTRAINT FK_book_categories_category FOREIGN KEY (category_id) REFERENCES dbo.categories(id) ON DELETE CASCADE
);
GO

-- 2.6. Bảng book_authors (Quan hệ nhiều - nhiều Sách và Tác giả)
IF OBJECT_ID('dbo.book_authors', 'U') IS NULL
CREATE TABLE dbo.book_authors (
    book_id BIGINT NOT NULL,
    author_id BIGINT NOT NULL,
    is_primary BIT NOT NULL DEFAULT 0,
    CONSTRAINT PK_book_authors PRIMARY KEY (book_id, author_id),
    CONSTRAINT FK_book_authors_book FOREIGN KEY (book_id) REFERENCES dbo.books(id) ON DELETE CASCADE,
    CONSTRAINT FK_book_authors_author FOREIGN KEY (author_id) REFERENCES dbo.authors(id) ON DELETE CASCADE
);
GO

-- 2.7. Bảng book_images (Bộ sưu tập ảnh sản phẩm)
IF OBJECT_ID('dbo.book_images', 'U') IS NULL
CREATE TABLE dbo.book_images (
    id BIGINT IDENTITY(1,1) PRIMARY KEY,
    book_id BIGINT NOT NULL,
    image_url VARCHAR(500) NOT NULL,
    is_thumbnail BIT NOT NULL DEFAULT 0,
    display_order INT NOT NULL DEFAULT 0,
    CONSTRAINT FK_book_images_book FOREIGN KEY (book_id) REFERENCES dbo.books(id) ON DELETE CASCADE
);
GO

-- 2.8. Bảng book_price_history (Lịch sử biến động giá bán)
IF OBJECT_ID('dbo.book_price_history', 'U') IS NULL
CREATE TABLE dbo.book_price_history (
    id BIGINT IDENTITY(1,1) PRIMARY KEY,
    book_id BIGINT NOT NULL,
    old_price DECIMAL(18,2) NOT NULL,
    new_price DECIMAL(18,2) NOT NULL,
    changed_by BIGINT NOT NULL,
    changed_at DATETIME2 NOT NULL DEFAULT GETDATE(),
    reason NVARCHAR(255) NULL,
    CONSTRAINT FK_price_history_book FOREIGN KEY (book_id) REFERENCES dbo.books(id),
    CONSTRAINT FK_price_history_user FOREIGN KEY (changed_by) REFERENCES dbo.users(id)
);
GO

-- ====================================================================
-- PHÂN HỆ 3: QUẢN LÝ KHO & NHẬP HÀNG (Inventory & Warehouse)
-- ====================================================================

-- 3.1. Bảng inventories (Quản lý Tồn kho)
IF OBJECT_ID('dbo.inventories', 'U') IS NULL
CREATE TABLE dbo.inventories (
    id BIGINT IDENTITY(1,1) PRIMARY KEY,
    book_id BIGINT NOT NULL UNIQUE,
    stock_quantity INT NOT NULL DEFAULT 0 CHECK (stock_quantity >= 0),
    reserved_quantity INT NOT NULL DEFAULT 0 CHECK (reserved_quantity >= 0),
    low_stock_threshold INT NOT NULL DEFAULT 10,
    updated_at DATETIME2 NOT NULL DEFAULT GETDATE(),
    CONSTRAINT FK_inventories_book FOREIGN KEY (book_id) REFERENCES dbo.books(id)
);
GO

-- 3.2. Bảng goods_receipts (Phiếu nhập kho)
IF OBJECT_ID('dbo.goods_receipts', 'U') IS NULL
CREATE TABLE dbo.goods_receipts (
    id BIGINT IDENTITY(1,1) PRIMARY KEY,
    receipt_code VARCHAR(50) NOT NULL UNIQUE,
    supplier_name NVARCHAR(150) NOT NULL,
    staff_id BIGINT NOT NULL,
    total_amount DECIMAL(18,2) NOT NULL DEFAULT 0,
    status VARCHAR(20) NOT NULL DEFAULT 'COMPLETED',
    note NVARCHAR(500) NULL,
    received_at DATETIME2 NOT NULL DEFAULT GETDATE(),
    CONSTRAINT FK_goods_receipts_staff FOREIGN KEY (staff_id) REFERENCES dbo.users(id)
);
GO

-- 3.3. Bảng goods_receipt_items (Chi tiết Phiếu nhập kho)
IF OBJECT_ID('dbo.goods_receipt_items', 'U') IS NULL
CREATE TABLE dbo.goods_receipt_items (
    id BIGINT IDENTITY(1,1) PRIMARY KEY,
    receipt_id BIGINT NOT NULL,
    book_id BIGINT NOT NULL,
    quantity INT NOT NULL CHECK (quantity > 0),
    import_price DECIMAL(18,2) NOT NULL CHECK (import_price >= 0),
    CONSTRAINT FK_receipt_items_receipt FOREIGN KEY (receipt_id) REFERENCES dbo.goods_receipts(id) ON DELETE CASCADE,
    CONSTRAINT FK_receipt_items_book FOREIGN KEY (book_id) REFERENCES dbo.books(id)
);
GO

-- 3.4. Bảng stock_movements (Sổ thẻ kho - Kardex)
IF OBJECT_ID('dbo.stock_movements', 'U') IS NULL
CREATE TABLE dbo.stock_movements (
    id BIGINT IDENTITY(1,1) PRIMARY KEY,
    book_id BIGINT NOT NULL,
    movement_type VARCHAR(20) NOT NULL, -- IN, OUT, ADJUST
    quantity INT NOT NULL,
    balance_after INT NOT NULL,
    reference_type VARCHAR(50) NULL, -- GOODS_RECEIPT, ORDER, AUDIT
    reference_id BIGINT NULL,
    note NVARCHAR(255) NULL,
    created_at DATETIME2 NOT NULL DEFAULT GETDATE(),
    CONSTRAINT FK_stock_movements_book FOREIGN KEY (book_id) REFERENCES dbo.books(id)
);
GO

-- ====================================================================
-- PHÂN HỆ 4: GIỎ HÀNG, YÊU THÍCH & ĐƠN HÀNG (Cart, Wishlist & Orders)
-- ====================================================================

-- 4.1. Bảng carts (Giỏ hàng)
IF OBJECT_ID('dbo.carts', 'U') IS NULL
CREATE TABLE dbo.carts (
    id BIGINT IDENTITY(1,1) PRIMARY KEY,
    user_id BIGINT NOT NULL UNIQUE,
    created_at DATETIME2 NOT NULL DEFAULT GETDATE(),
    updated_at DATETIME2 NOT NULL DEFAULT GETDATE(),
    CONSTRAINT FK_carts_user FOREIGN KEY (user_id) REFERENCES dbo.users(id) ON DELETE CASCADE
);
GO

-- 4.2. Bảng cart_items (Món hàng trong giỏ)
IF OBJECT_ID('dbo.cart_items', 'U') IS NULL
CREATE TABLE dbo.cart_items (
    id BIGINT IDENTITY(1,1) PRIMARY KEY,
    cart_id BIGINT NOT NULL,
    book_id BIGINT NOT NULL,
    quantity INT NOT NULL DEFAULT 1 CHECK (quantity > 0),
    added_at DATETIME2 NOT NULL DEFAULT GETDATE(),
    CONSTRAINT UQ_cart_book UNIQUE (cart_id, book_id),
    CONSTRAINT FK_cart_items_cart FOREIGN KEY (cart_id) REFERENCES dbo.carts(id) ON DELETE CASCADE,
    CONSTRAINT FK_cart_items_book FOREIGN KEY (book_id) REFERENCES dbo.books(id)
);
GO

-- 4.3. Bảng wishlists (Danh sách sách yêu thích)
IF OBJECT_ID('dbo.wishlists', 'U') IS NULL
CREATE TABLE dbo.wishlists (
    id BIGINT IDENTITY(1,1) PRIMARY KEY,
    user_id BIGINT NOT NULL,
    book_id BIGINT NOT NULL,
    added_at DATETIME2 NOT NULL DEFAULT GETDATE(),
    CONSTRAINT UQ_wishlist_user_book UNIQUE (user_id, book_id),
    CONSTRAINT FK_wishlists_user FOREIGN KEY (user_id) REFERENCES dbo.users(id) ON DELETE CASCADE,
    CONSTRAINT FK_wishlists_book FOREIGN KEY (book_id) REFERENCES dbo.books(id) ON DELETE CASCADE
);
GO

-- 4.4. Bảng vouchers (Mã giảm giá - Phân hệ 6 nhưng cần trước Orders)
IF OBJECT_ID('dbo.vouchers', 'U') IS NULL
CREATE TABLE dbo.vouchers (
    id BIGINT IDENTITY(1,1) PRIMARY KEY,
    code VARCHAR(50) NOT NULL UNIQUE,
    discount_type VARCHAR(20) NOT NULL, -- PERCENT, FIXED_AMOUNT
    discount_value DECIMAL(18,2) NOT NULL CHECK (discount_value > 0),
    min_order_amount DECIMAL(18,2) NOT NULL DEFAULT 0,
    max_discount_amount DECIMAL(18,2) NULL,
    usage_limit INT NOT NULL DEFAULT 100,
    used_count INT NOT NULL DEFAULT 0,
    start_date DATETIME2 NOT NULL,
    end_date DATETIME2 NOT NULL,
    status VARCHAR(20) NOT NULL DEFAULT 'ACTIVE',
    is_deleted BIT NOT NULL DEFAULT 0,
    created_at DATETIME2 NOT NULL DEFAULT GETDATE()
);
GO

-- 4.5. Bảng orders (Đơn đặt hàng)
IF OBJECT_ID('dbo.orders', 'U') IS NULL
CREATE TABLE dbo.orders (
    id BIGINT IDENTITY(1,1) PRIMARY KEY,
    order_code VARCHAR(50) NOT NULL UNIQUE,
    user_id BIGINT NOT NULL,
    total_book_amount DECIMAL(18,2) NOT NULL,
    shipping_fee DECIMAL(18,2) NOT NULL DEFAULT 0,
    discount_amount DECIMAL(18,2) NOT NULL DEFAULT 0,
    final_amount DECIMAL(18,2) NOT NULL,
    payment_method VARCHAR(20) NOT NULL, -- COD, VNPAY, MOMO
    payment_status VARCHAR(20) NOT NULL DEFAULT 'PENDING', -- PENDING, PAID, FAILED, REFUNDED
    order_status VARCHAR(30) NOT NULL DEFAULT 'PENDING', -- PENDING, CONFIRMED, PROCESSING, SHIPPING, DELIVERED, CANCELLED, RETURNED
    shipping_address NVARCHAR(255) NOT NULL,
    recipient_name NVARCHAR(100) NOT NULL,
    recipient_phone VARCHAR(15) NOT NULL,
    note NVARCHAR(500) NULL,
    created_at DATETIME2 NOT NULL DEFAULT GETDATE(),
    updated_at DATETIME2 NOT NULL DEFAULT GETDATE(),
    CONSTRAINT FK_orders_user FOREIGN KEY (user_id) REFERENCES dbo.users(id)
);
GO

-- 4.6. Bảng order_items (Chi tiết Đơn hàng)
IF OBJECT_ID('dbo.order_items', 'U') IS NULL
CREATE TABLE dbo.order_items (
    id BIGINT IDENTITY(1,1) PRIMARY KEY,
    order_id BIGINT NOT NULL,
    book_id BIGINT NOT NULL,
    book_title NVARCHAR(255) NOT NULL,
    unit_price DECIMAL(18,2) NOT NULL,
    quantity INT NOT NULL CHECK (quantity > 0),
    subtotal DECIMAL(18,2) NOT NULL,
    CONSTRAINT FK_order_items_order FOREIGN KEY (order_id) REFERENCES dbo.orders(id) ON DELETE CASCADE,
    CONSTRAINT FK_order_items_book FOREIGN KEY (book_id) REFERENCES dbo.books(id)
);
GO

-- 4.7. Bảng order_status_history (Lịch sử trạng thái Đơn hàng)
IF OBJECT_ID('dbo.order_status_history', 'U') IS NULL
CREATE TABLE dbo.order_status_history (
    id BIGINT IDENTITY(1,1) PRIMARY KEY,
    order_id BIGINT NOT NULL,
    previous_status VARCHAR(30) NULL,
    new_status VARCHAR(30) NOT NULL,
    changed_by BIGINT NOT NULL,
    reason NVARCHAR(255) NULL,
    changed_at DATETIME2 NOT NULL DEFAULT GETDATE(),
    CONSTRAINT FK_status_history_order FOREIGN KEY (order_id) REFERENCES dbo.orders(id) ON DELETE CASCADE,
    CONSTRAINT FK_status_history_user FOREIGN KEY (changed_by) REFERENCES dbo.users(id)
);
GO

-- 4.8. Bảng voucher_usages (Lịch sử sử dụng Voucher)
IF OBJECT_ID('dbo.voucher_usages', 'U') IS NULL
CREATE TABLE dbo.voucher_usages (
    id BIGINT IDENTITY(1,1) PRIMARY KEY,
    voucher_id BIGINT NOT NULL,
    user_id BIGINT NOT NULL,
    order_id BIGINT NOT NULL,
    used_at DATETIME2 NOT NULL DEFAULT GETDATE(),
    CONSTRAINT FK_voucher_usages_voucher FOREIGN KEY (voucher_id) REFERENCES dbo.vouchers(id),
    CONSTRAINT FK_voucher_usages_user FOREIGN KEY (user_id) REFERENCES dbo.users(id),
    CONSTRAINT FK_voucher_usages_order FOREIGN KEY (order_id) REFERENCES dbo.orders(id)
);
GO

-- ====================================================================
-- PHÂN HỆ 5: THANH TOÁN & VẬN CHUYỂN (Payment & Shipping)
-- ====================================================================

-- 5.1. Bảng payment_transactions (Giao dịch thanh toán)
IF OBJECT_ID('dbo.payment_transactions', 'U') IS NULL
CREATE TABLE dbo.payment_transactions (
    id BIGINT IDENTITY(1,1) PRIMARY KEY,
    order_id BIGINT NOT NULL,
    payment_method VARCHAR(20) NOT NULL,
    transaction_code VARCHAR(100) NULL,
    gateway_transaction_no VARCHAR(100) NULL,
    amount DECIMAL(18,2) NOT NULL,
    status VARCHAR(20) NOT NULL DEFAULT 'PENDING',
    response_code VARCHAR(50) NULL,
    pay_date DATETIME2 NULL,
    created_at DATETIME2 NOT NULL DEFAULT GETDATE(),
    CONSTRAINT FK_payment_order FOREIGN KEY (order_id) REFERENCES dbo.orders(id) ON DELETE CASCADE
);
GO

-- Filtered Unique Index cho transaction_code (cho phép nhiều dòng NULL đối với đơn COD)
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = 'UQ_payment_transactions_code' AND object_id = OBJECT_ID('dbo.payment_transactions'))
BEGIN
    CREATE UNIQUE NONCLUSTERED INDEX UQ_payment_transactions_code
    ON dbo.payment_transactions(transaction_code)
    WHERE transaction_code IS NOT NULL;
END
GO

-- 5.2. Bảng shipping_orders (Vận đơn giao hàng)
IF OBJECT_ID('dbo.shipping_orders', 'U') IS NULL
CREATE TABLE dbo.shipping_orders (
    id BIGINT IDENTITY(1,1) PRIMARY KEY,
    order_id BIGINT NOT NULL UNIQUE,
    carrier_name NVARCHAR(100) NOT NULL,
    tracking_number VARCHAR(100) NOT NULL UNIQUE,
    shipping_status VARCHAR(30) NOT NULL DEFAULT 'READY_TO_PICK',
    estimated_delivery DATE NULL,
    actual_delivery DATETIME2 NULL,
    shipping_notes NVARCHAR(255) NULL,
    created_at DATETIME2 NOT NULL DEFAULT GETDATE(),
    CONSTRAINT FK_shipping_order FOREIGN KEY (order_id) REFERENCES dbo.orders(id) ON DELETE CASCADE
);
GO

-- ====================================================================
-- PHÂN HỆ 6: ĐÁNH GIÁ & ĐỔI TRẢ (Reviews & Returns)
-- ====================================================================

-- 6.1. Bảng reviews (Đánh giá & Bình luận Sách)
IF OBJECT_ID('dbo.reviews', 'U') IS NULL
CREATE TABLE dbo.reviews (
    id BIGINT IDENTITY(1,1) PRIMARY KEY,
    book_id BIGINT NOT NULL,
    user_id BIGINT NOT NULL,
    order_id BIGINT NULL,
    rating INT NOT NULL CHECK (rating >= 1 AND rating <= 5),
    comment NVARCHAR(MAX) NULL,
    status VARCHAR(20) NOT NULL DEFAULT 'APPROVED', -- APPROVED, REJECTED, PENDING
    is_purchased BIT NOT NULL DEFAULT 1,
    created_at DATETIME2 NOT NULL DEFAULT GETDATE(),
    updated_at DATETIME2 NOT NULL DEFAULT GETDATE(),
    CONSTRAINT FK_reviews_book FOREIGN KEY (book_id) REFERENCES dbo.books(id),
    CONSTRAINT FK_reviews_user FOREIGN KEY (user_id) REFERENCES dbo.users(id),
    CONSTRAINT FK_reviews_order FOREIGN KEY (order_id) REFERENCES dbo.orders(id)
);
GO

-- 6.2. Bảng return_requests (Yêu cầu đổi trả & hoàn tiền)
IF OBJECT_ID('dbo.return_requests', 'U') IS NULL
CREATE TABLE dbo.return_requests (
    id BIGINT IDENTITY(1,1) PRIMARY KEY,
    request_code VARCHAR(50) NOT NULL UNIQUE,
    order_id BIGINT NOT NULL,
    user_id BIGINT NOT NULL,
    reason NVARCHAR(500) NOT NULL,
    refund_amount DECIMAL(18,2) NOT NULL DEFAULT 0,
    status VARCHAR(30) NOT NULL DEFAULT 'PENDING', -- PENDING, APPROVED, REJECTED, REFUNDED
    admin_notes NVARCHAR(500) NULL,
    requested_at DATETIME2 NOT NULL DEFAULT GETDATE(),
    processed_at DATETIME2 NULL,
    processed_by BIGINT NULL,
    CONSTRAINT FK_return_requests_order FOREIGN KEY (order_id) REFERENCES dbo.orders(id),
    CONSTRAINT FK_return_requests_user FOREIGN KEY (user_id) REFERENCES dbo.users(id),
    CONSTRAINT FK_return_requests_admin FOREIGN KEY (processed_by) REFERENCES dbo.users(id)
);
GO

-- 6.3. Bảng return_items (Chi tiết sản phẩm đổi trả)
IF OBJECT_ID('dbo.return_items', 'U') IS NULL
CREATE TABLE dbo.return_items (
    id BIGINT IDENTITY(1,1) PRIMARY KEY,
    return_request_id BIGINT NOT NULL,
    book_id BIGINT NOT NULL,
    quantity INT NOT NULL CHECK (quantity > 0),
    refund_price DECIMAL(18,2) NOT NULL,
    book_condition NVARCHAR(255) NULL,
    CONSTRAINT FK_return_items_request FOREIGN KEY (return_request_id) REFERENCES dbo.return_requests(id) ON DELETE CASCADE,
    CONSTRAINT FK_return_items_book FOREIGN KEY (book_id) REFERENCES dbo.books(id)
);
GO

-- ====================================================================
-- PHÂN HỆ 7: THÔNG BÁO & NHẬT KÝ HỆ THỐNG (Notifications & Audit Logs)
-- ====================================================================

-- 7.1. Bảng notifications (Nội dung thông báo)
IF OBJECT_ID('dbo.notifications', 'U') IS NULL
CREATE TABLE dbo.notifications (
    id BIGINT IDENTITY(1,1) PRIMARY KEY,
    title NVARCHAR(200) NOT NULL,
    content NVARCHAR(MAX) NOT NULL,
    notification_type VARCHAR(50) NOT NULL, -- ORDER, PROMOTION, SYSTEM
    target_url VARCHAR(500) NULL,
    created_at DATETIME2 NOT NULL DEFAULT GETDATE()
);
GO

-- 7.2. Bảng user_notifications (Trạng thái nhận thông báo của User)
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

-- 7.3. Bảng audit_logs (Nhật ký kiểm toán hệ thống)
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
-- DỮ LIỆU MẪU BAN ĐẦU (SEED DATA)
-- ====================================================================

-- Chèn các Vai trò cốt lõi
IF NOT EXISTS (SELECT 1 FROM dbo.roles WHERE role_name = 'ADMIN')
    INSERT INTO dbo.roles (role_name, description) VALUES ('ADMIN', N'Quản trị viên toàn quyền hệ thống');

IF NOT EXISTS (SELECT 1 FROM dbo.roles WHERE role_name = 'STAFF')
    INSERT INTO dbo.roles (role_name, description) VALUES ('STAFF', N'Nhân viên bán hàng và xử lý đơn');

IF NOT EXISTS (SELECT 1 FROM dbo.roles WHERE role_name = 'INVENTORY_STAFF')
    INSERT INTO dbo.roles (role_name, description) VALUES ('INVENTORY_STAFF', N'Nhân viên quản lý kho và nhập sách');

IF NOT EXISTS (SELECT 1 FROM dbo.roles WHERE role_name = 'BUYER')
    INSERT INTO dbo.roles (role_name, description) VALUES ('BUYER', N'Khách hàng mua sách');

-- Chèn tài khoản Admin mặc định (Pass BCrypt băm từ 'Admin@123')
IF NOT EXISTS (SELECT 1 FROM dbo.users WHERE email = 'admin@bookstore.com')
BEGIN
    INSERT INTO dbo.users (email, password_hash, full_name, phone_number, is_email_verified, status)
    VALUES ('admin@bookstore.com', '$2a$12$e8Yy8n8R2uG3X/gZlD1g3.N6Y0F41t9pU8C5S7o5O9f8m4s8m6n3.', N'Quản Trị Viên', '0901234567', 1, 'ACTIVE');
    
    DECLARE @admin_id BIGINT = SCOPE_IDENTITY();
    DECLARE @admin_role_id BIGINT = (SELECT id FROM dbo.roles WHERE role_name = 'ADMIN');
    
    INSERT INTO dbo.user_roles (user_id, role_id) VALUES (@admin_id, @admin_role_id);
END;
GO

PRINT N'SUCCESS: Đã khởi tạo hoàn tất toàn bộ 32 bảng cho Database BookStoreDB!';
GO
