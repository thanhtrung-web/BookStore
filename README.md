# BOOKSTORE MANAGEMENT SYSTEM (SWD392 - TEAM PS06)

Standard **3-Tier Layered Architecture (MVC + DAO Pattern)** web application connecting to Microsoft SQL Server.

---

## 1. PROJECT STRUCTURE

```text
D:\SWD\BookStore/
├── pom.xml                                  <-- Maven build & Tomcat embedded plugin
├── README.md
└── src/
    └── main/
        ├── java/
        │   └── com/
        │       └── bookstore/
        │           ├── context/
        │           │   └── DBContext.java   <-- JDBC Connection manager (LocalDB thanhtrung, sa / 123456)
        │           ├── controller/
        │           │   └── HomeController.java <-- Entry point servlet
        │           ├── filter/
        │           │   └── EncodingFilter.java <-- UTF-8 encoding filter
        │           ├── model/               <-- EMPTY: Create entity POJOs per use case
        │           ├── dao/                 <-- EMPTY: Create DAOs with JDBC queries
        │           ├── service/             <-- EMPTY: Create business service logic
        │           └── util/                <-- EMPTY: Utility helper classes
        ├── resources/
        │   └── db.properties                <-- Database properties (thanhtrung instance, sa / 123456)
        └── webapp/
            ├── WEB-INF/
            │   └── web.xml                  <-- Servlet deployment descriptor
            ├── views/
            │   ├── common/
            │   │   ├── header.jsp
            │   │   └── footer.jsp
            │   └── home.jsp                 <-- Landing page displaying server & db status
            └── static/
                ├── css/style.css
                └── js/main.js
```

---

## 2. HOW TO RUN AND TEST

### 1. Test Database Connection directly:
- Open `src/main/java/com/bookstore/context/DBContext.java`.
- Right-click $\rightarrow$ select **Run Java** (executes the `main` method).
- Terminal console will display:
  `>>> [SUCCESS] Database connection established successfully!`

### 2. Launch Localhost Server in VS Code:
- **Option A (VS Code Maven Panel - 1 Click):**
  - In VS Code Explorer sidebar (left panel), scroll down to the **MAVEN** view.
  - Expand: `BookStore` $\rightarrow$ `Plugins` $\rightarrow$ `tomcat7` $\rightarrow$ click `tomcat7:run`.
- **Option B (Terminal):**
  - Run:
    ```bash
    mvn tomcat7:run
    ```
- Open browser and navigate to:
  👉 **`http://localhost:8080/bookstore`**

---

## 3. GIT BRANCHING & COMMIT CONVENTIONS (QUY TẮC ĐẶT TÊN NHÁNH & COMMIT)

Để đảm bảo dự án hoạt động nhóm trơn tru, tất cả thành viên trong nhóm **Team PS06** bắt buộc phải tuân thủ quy tắc đặt tên nhánh (branch) và định dạng thông điệp commit (commit message) theo chuẩn dưới đây:

### 3.1. Quy tắc đặt tên nhánh (Branch Naming Convention)

Cú pháp chuẩn:
```text
<type>/<mô-tả-ngắn-gọn>
```

- **Quy ước:** Viết bằng chữ thường (lowercase), các từ cách nhau bằng dấu gạch ngang `-` (kebab-case). Không dùng dấu cách hoặc ký tự đặc biệt.

| Tiền tố (Type) | Mục đích sử dụng | Ví dụ thực tế |
| :--- | :--- | :--- |
| **`feature/`** | Phát triển chức năng mới hoặc nâng cấp tính năng | `feature/login-captcha`<br>`feature/book-search`<br>`feature/cart-checkout` |
| **`bugfix/`** hoặc **`fix/`** | Sửa lỗi phát sinh trong hệ thống | `bugfix/payment-null-pointer`<br>`bugfix/login-session-expired` |
| **`hotfix/`** | Sửa lỗi nghiêm trọng, khẩn cấp trực tiếp trên production/main | `hotfix/security-sql-injection` |
| **`refactor/`** | Tái cấu trúc, tối ưu code (không thêm tính năng, không sửa lỗi) | `refactor/dbcontext-connection`<br>`refactor/bookdao-clean-code` |
| **`docs/`** | Viết hoặc cập nhật tài liệu dự án, sơ đồ UML, README | `docs/update-readme-conventions`<br>`docs/activity-diagrams` |

---

### 3.2. Quy tắc viết Commit Message (Conventional Commits)

Mỗi lần commit code, bắt buộc phải viết thông điệp theo định dạng:

```text
<type>(<scope>): <mô tả ngắn gọn về thay đổi>
```

#### 1. Loại Commit (`type` - BẮT BUỘC):
- **`feature`** (hoặc **`feat`**): Tính năng mới được thêm vào.
- **`bugfix`** (hoặc **`fix`**): Sửa lỗi cho hệ thống.
- **`refactor`**: Sửa đổi, tối ưu lại code nhưng không thêm tính năng mới và không sửa lỗi.
- **`docs`**: Thêm mới hoặc cập nhật tài liệu (README, tài liệu đặc tả, sơ đồ UML...).
- **`chore`**: Những sửa đổi nhỏ nhặt về cấu hình, công cụ build không liên quan đến logic code (ví dụ `.gitignore`, format file...).
- **`style`**: Những thay đổi về hình thức trình bày (khoảng trắng, dấu chấm phẩy, format code) không làm thay đổi ý nghĩa của code.
- **`perf`**: Tối ưu hiệu năng, cải thiện tốc độ xử lý của hệ thống.
- **`vendor`**: Cập nhật phiên bản các thư viện, dependencies trong `pom.xml`.

#### 2. Phạm vi (`scope` - TÙY CHỌN):
- Đặt trong dấu ngoặc tròn `(...)` ngay sau `type` để xác định rõ module/chức năng nào bị tác động.
- Ví dụ: `feature(login)`, `bugfix(cart)`, `refactor(db)`, `docs(readme)`.

#### 3. Mô tả commit (`description` - BẮT BUỘC):
- Viết ngắn gọn, rõ ràng, phản ánh chính xác hành động vừa thực hiện.
- Bắt đầu bằng động từ hành động (ví dụ: `add`, `update`, `fix`, `remove`, `optimize`).

---

### 3.3. Bảng ví dụ commit mẫu:

| Trường hợp | Commit Message mẫu |
| :--- | :--- |
| **Thêm tính năng** | `feature(login): add captcha verification after failed attempts` |
| **Sửa lỗi** | `bugfix(cart): fix total price calculation when voucher applied` |
| **Tối ưu code** | `refactor(db): optimize connection handling in DBContext` |
| **Cập nhật tài liệu** | `docs(readme): add branch naming and commit conventions` |
| **Cấu hình dự án** | `chore: update .gitignore to exclude target directory` |
| **Nâng cấp thư viện** | `vendor: upgrade mssql-jdbc dependency to 12.4.2` |

