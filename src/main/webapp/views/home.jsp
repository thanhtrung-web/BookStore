<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>BookStore Management System</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    <style>
        body { background-color: #f8f9fa; font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif; }
        .hero-card { border-radius: 12px; border: none; box-shadow: 0 4px 12px rgba(0,0,0,0.08); }
    </style>
</head>
<body>
<nav class="navbar navbar-dark bg-dark">
    <div class="container">
        <a class="navbar-brand fw-bold" href="#">📚 BookStore Management (SWD392)</a>
    </div>
</nav>

<div class="container my-5">
    <div class="card hero-card p-5 bg-white">
        <h1 class="fw-bold text-primary mb-3">🚀 BookStore Application is Ready!</h1>
        <p class="fs-5 text-muted">
            Standard 3-Tier Layered Architecture (MVC + DAO Pattern) with Microsoft SQL Server.
        </p>
        
        <hr class="my-4">

        <div class="alert ${dbStatus ? 'alert-success' : 'alert-warning'} d-flex align-items-center" role="alert">
            <c:choose>
                <c:when test="${dbStatus}">
                    <div>
                        <h5 class="alert-heading fw-bold mb-1">✅ Database Connection: SUCCESS</h5>
                        <p class="mb-0 small">The application has successfully connected to database: <strong>BookStoreDB</strong>.</p>
                    </div>
                </c:when>
                <c:otherwise>
                    <div>
                        <h5 class="alert-heading fw-bold mb-1">⚠️ Database Status: Standby / Checking</h5>
                        <p class="mb-0 small">Web application is running on local server. Database connection will update automatically.</p>
                    </div>
                </c:otherwise>
            </c:choose>
        </div>

        <div class="mt-4">
            <h5 class="fw-bold">📁 Project Structure Overview:</h5>
            <ul class="text-muted small">
                <li><strong><code>model/</code> package:</strong> Empty. Create entity classes as needed per use case (User, Book, Order, etc.).</li>
                <li><strong><code>dao/</code> package:</strong> Empty. Implement DAO classes (UserDAO, BookDAO, etc.) utilizing <code>DBContext.getConnection()</code>.</li>
                <li><strong><code>service/</code> & <code>controller/</code>:</strong> Empty. Build your business services and HTTP servlets per feature requirements.</li>
            </ul>
        </div>
    </div>
</div>

<footer class="text-center text-muted py-3">
    <small>© 2026 BookStore Management Website - SWD392 Team PS06</small>
</footer>
</body>
</html>
