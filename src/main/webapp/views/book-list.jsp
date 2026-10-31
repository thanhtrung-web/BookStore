<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
    <%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
        <%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
            <jsp:include page="/views/common/header.jsp" />

            <!DOCTYPE html>
            <html lang="vi">

            <head>
                <meta charset="UTF-8">
                <meta name="viewport" content="width=device-width, initial-scale=1.0">

                <title>Danh sách sách - BookStore</title>

                <style>
                    * {
                        box-sizing: border-box;
                    }

                    body {
                        margin: 0;
                        padding: 30px;
                        font-family: Arial, sans-serif;
                        background: #f8fafc;
                        color: #1e293b;
                    }

                    .container {
                        max-width: 1200px;
                        margin: 0 auto;
                    }

                    .header {
                        display: flex;
                        justify-content: space-between;
                        align-items: center;
                        flex-wrap: wrap;
                        gap: 12px;
                        margin-bottom: 24px;
                    }

                    h1 {
                        margin: 0;
                        font-size: 28px;
                    }

                    .back-link {
                        color: #2563eb;
                        text-decoration: none;
                        font-weight: bold;
                    }

                    .summary {
                        margin-bottom: 16px;
                        color: #64748b;
                    }

                    .table-wrapper {
                        overflow-x: auto;
                        background: white;
                        border-radius: 12px;
                        box-shadow: 0 2px 10px rgba(0, 0, 0, 0.05);
                    }

                    table {
                        width: 100%;
                        border-collapse: collapse;
                    }

                    th,
                    td {
                        padding: 15px;
                        text-align: left;
                        border-bottom: 1px solid #e2e8f0;
                    }

                    th {
                        background: #eff6ff;
                        color: #1e40af;
                        white-space: nowrap;
                    }

                    tbody tr:hover {
                        background: #f8fafc;
                    }

                    .price {
                        color: #2563eb;
                        font-weight: bold;
                        white-space: nowrap;
                    }

                    .empty {
                        padding: 30px;
                        text-align: center;
                        color: #64748b;
                    }

                    .pagination {
                        display: flex;
                        justify-content: center;
                        align-items: center;
                        flex-wrap: wrap;
                        gap: 8px;
                        margin-top: 24px;
                    }

                    .pagination a,
                    .pagination span {
                        min-width: 38px;
                        padding: 10px 13px;
                        text-align: center;
                        border-radius: 8px;
                        text-decoration: none;
                    }

                    .pagination a {
                        color: #2563eb;
                        background: white;
                        border: 1px solid #cbd5e1;
                    }

                    .pagination a:hover {
                        background: #dbeafe;
                    }

                    .pagination .active {
                        color: white;
                        background: #2563eb;
                        border: 1px solid #2563eb;
                    }

                    .pagination .disabled {
                        color: #94a3b8;
                        background: #f1f5f9;
                    }
                </style>
            </head>

            <body>
                <div class="container">

                    <div class="header">
                        <h1>Danh sách sách</h1>

                        <a class="back-link" href="${pageContext.request.contextPath}/home">
                            ← Quay về trang chủ
                        </a>
                    </div>

                    <div class="summary">
                        Tổng số sách:
                        <strong>
                            <c:out value="${totalBooks}" />
                        </strong>
                    </div>

                    <div class="table-wrapper">
                        <table>
                            <thead>
                                <tr>
                                    <th>Ảnh bìa</th>
                                    <th>ID</th>
                                    <th>Tên sách</th>
                                    <th>ISBN</th>
                                    <th>Giá bán</th>
                                </tr>
                            </thead>

                            <tbody>
                                <c:choose>
                                    <c:when test="${not empty books}">
                                        <c:forEach var="book" items="${books}">
                                            <tr>
                                                <td>
                                                    <a
                                                        href="${pageContext.request.contextPath}/book-detail?id=${book.id}">
                                                        <img src="${book.imageUrl}" alt="Bìa sách" style="width: 70px; height: 95px; object-fit: cover;
            border-radius: 6px;" />
                                                    </a>
                                                </td>


                                                <td>
                                                    <c:out value="${book.id}" />
                                                </td>

                                                <td>
                                                    <c:out value="${book.title}" />
                                                </td>

                                                <td>
                                                    <c:out value="${book.isbn}" />
                                                </td>

                                                <td class="price">
                                                    <fmt:formatNumber value="${book.price}" pattern="#,##0.##" /> đ
                                                </td>
                                            </tr>
                                        </c:forEach>
                                    </c:when>

                                    <c:otherwise>
                                        <tr>
                                            <td colspan="5" class="empty">
                                                Không tìm thấy sách nào.
                                            </td>
                                        </tr>
                                    </c:otherwise>
                                </c:choose>
                            </tbody>
                        </table>
                    </div>

                    <%-- Pagination --%>
                        <c:if test="${totalPages > 1}">
                            <div class="pagination">

                                <%-- Previous page --%>
                                    <c:choose>
                                        <c:when test="${currentPage > 1}">
                                            <a href="${pageContext.request.contextPath}/books?page=${currentPage - 1}">
                                                ← Trước
                                            </a>
                                        </c:when>
                                        <c:otherwise>
                                            <span class="disabled">← Trước</span>
                                        </c:otherwise>
                                    </c:choose>

                                    <%-- Page numbers --%>
                                        <c:forEach var="pageNumber" begin="1" end="${totalPages}">

                                            <c:choose>
                                                <c:when test="${pageNumber == currentPage}">
                                                    <span class="active">
                                                        <c:out value="${pageNumber}" />
                                                    </span>
                                                </c:when>

                                                <c:otherwise>
                                                    <a
                                                        href="${pageContext.request.contextPath}/books?page=${pageNumber}">
                                                        <c:out value="${pageNumber}" />
                                                    </a>
                                                </c:otherwise>
                                            </c:choose>

                                        </c:forEach>

                                        <%-- Next page --%>
                                            <c:choose>
                                                <c:when test="${currentPage < totalPages}">
                                                    <a
                                                        href="${pageContext.request.contextPath}/books?page=${currentPage + 1}">
                                                        Sau →
                                                    </a>
                                                </c:when>
                                                <c:otherwise>
                                                    <span class="disabled">Sau →</span>
                                                </c:otherwise>
                                            </c:choose>

                            </div>
                        </c:if>

                </div>
            </body>
            <jsp:include page="/views/common/footer.jsp" />

            </html>