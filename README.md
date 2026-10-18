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
