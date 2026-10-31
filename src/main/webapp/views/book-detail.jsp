
<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<jsp:include page="/views/common/header.jsp" />

<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Chi tiết sách - BookStore</title>

    <style>
        body {
            font-family: Arial, sans-serif;
            background: #f8fafc;
            color: #1e293b;
            margin: 0;
            padding: 30px;
        }

        .container {
            max-width: 1000px;
            margin: auto;
        }

        .book-detail {
            display: flex;
            flex-wrap: wrap;
            gap: 30px;
            background: white;
            padding: 28px;
            border-radius: 14px;
        }

        .book-image {
            width: 260px;
            max-width: 100%;
            height: 350px;
            object-fit: contain;
            background: #f1f5f9;
            border-radius: 10px;
        }

        .book-info {
            flex: 1;
            min-width: 250px;
        }

        .price {
            color: #2563eb;
            font-size: 24px;
            font-weight: bold;
        }

        .description {
            line-height: 1.7;
            white-space: pre-line;
        }

        .back-link {
            display: inline-block;
            margin-bottom: 20px;
            color: #2563eb;
            text-decoration: none;
        }

        .field {
            margin: 12px 0;
        }
    </style>
</head>

<body>
<div class="container">

    <a class="back-link"
       href="${pageContext.request.contextPath}/books">
        ← Quay lại danh sách sách
    </a>

    <div class="book-detail">

        <div>
            <c:choose>
                <c:when test="${not empty book.imageUrl}">
                    <img class="book-image"
                         src="<c:out value='${book.imageUrl}' />"
                         alt="Bìa sách">
                </c:when>
                <c:otherwise>
                    <div class="book-image"
                         style="display:flex;align-items:center;
                                justify-content:center;">
                        Chưa có ảnh bìa
                    </div>
                </c:otherwise>
            </c:choose>
        </div>

        <div class="book-info">
            <h1><c:out value="${book.title}" /></h1>

            <p class="price">
                <fmt:formatNumber value="${book.price}"
                                  pattern="#,##0.##" /> đ
            </p>

            <div class="field">
                <strong>ISBN:</strong>
                <c:out value="${book.isbn}" />
            </div>

            <div class="field">
                <strong>Nhà xuất bản:</strong>
                <c:out value="${book.publisherName}" />
            </div>

            <div class="field">
                <strong>Năm xuất bản:</strong>
                <c:out value="${book.publicationYear}" />
            </div>

            <div class="field">
                <strong>Phiên bản:</strong>
                <c:out value="${book.edition}" />
            </div>

            <div class="field">
                <strong>Số trang:</strong>
                <c:out value="${book.pageCount}" />
            </div>

            <div class="field">
                <strong>Loại bìa:</strong>
                <c:out value="${book.coverType}" />
            </div>

            <div class="field">
                <strong>Ngôn ngữ:</strong>
                <c:out value="${book.language}" />
            </div>

            <div class="field">
                <strong>Giảm giá:</strong>
                <c:out value="${book.discountPercent}" />%
            </div>

            <h3>Mô tả sách</h3>
            <p class="description">
                <c:out value="${book.description}" />
            </p>
        </div>

    </div>
</div>
</body>
</html>
<jsp:include page="/views/common/footer.jsp" />