<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Edit Book | BookStore Admin</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/static/css/style.css">
</head>
<body style="margin:0;background:#f8fafc;color:#0f172a;font:14px Arial,sans-serif">
    <jsp:include page="header.jsp"/>
    <main style="max-width:1000px;margin:32px auto;padding:28px;background:#fff;border:1px solid #e2e8f0;border-radius:16px">
        <p style="color:#64748b">Admin / <a href="${pageContext.request.contextPath}/dashboard/admin?view=books">Book Catalog</a> / Edit Book</p>
        <h1>Edit Book</h1>
        <c:if test="${not empty errorMessage}"><p style="color:#b91c1c"><c:out value="${errorMessage}"/></p></c:if>
        <form method="post" enctype="multipart/form-data" action="${pageContext.request.contextPath}/dashboard/admin/books/edit">
            <input type="hidden" name="csrfToken" value="${sessionScope.adminCsrfToken}"/>
            <input type="hidden" name="id" value="${book.id}"/>
            <jsp:include page="book-form-fields.jsp"/>
            <p><button type="submit">Save Changes</button> <a href="${pageContext.request.contextPath}/dashboard/admin?view=books">Cancel</a></p>
        </form>
    </main>
</body>
</html>
