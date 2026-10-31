
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
            min-width: 0;
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

        .purchase-section {
            margin-top: 30px;
            padding-top: 22px;
            border-top: 1px solid #e2e8f0;
        }

        .quantity-control {
            display: flex;
            align-items: center;
            gap: 15px;
            margin-bottom: 20px;
        }

        .quantity-control label {
            font-size: 16px;
            font-weight: 600;
        }
.quantity-box {
    display: inline-flex;
    align-items: center;
    border: 1px solid #cbd5e1;
    border-radius: 10px;
    overflow: hidden;
    background: white;
}

.quantity-btn {
    width: 42px;
    height: 44px;
    border: none;
    background: #f8fafc;
    font-size: 22px;
    font-weight: bold;
    cursor: pointer;
}

.quantity-btn:hover {
    background: #dbeafe;
    color: #2563eb;
}
        .quantity-input {
    width: 55px;
    height: 44px;
    border: none;
    text-align: center;
    font-size: 17px;
    font-weight: 600;
    outline: none;
    appearance: textfield;
    -moz-appearance: textfield;
}

.quantity-input::-webkit-inner-spin-button,
.quantity-input::-webkit-outer-spin-button {
    -webkit-appearance: none;
    margin: 0;
}

        .quantity-input:focus {
            border-color: #2563eb;
        }

        .book-actions {
            display: flex;
            gap: 14px;
            width: 100%;
        }

        .btn-add-cart,
        .btn-buy-now {
            flex: 1 1 0;
            min-width: 0;
            min-height: 56px;
            padding: 10px 12px;
            border-radius: 10px;
            font-size: 16px;
            font-weight: 700;
            cursor: pointer;
            transition: all 0.2s ease;
            display: flex;
            align-items: center;
            justify-content: center;
            gap: 10px;
        }

        .btn-add-cart {
            background: white;
            color: #c92127;
            border: 2px solid #c92127;
        }

        .btn-add-cart:hover {
            background: #fff1f2;
            box-shadow: 0 4px 12px rgba(201, 33, 39, 0.12);
        }

        .btn-buy-now {
            background: #c92127;
            color: white;
            border: 2px solid #c92127;
        }

        .btn-buy-now:hover:not(:disabled) {
            background: #ad1b20;
        }

        .btn-buy-now:disabled {
            opacity: 0.55;
            cursor: not-allowed;
        }

        @media (max-width: 600px) {
            body {
                padding: 15px;
            }

            .book-detail {
                padding: 18px;
            }

            .book-info {
                min-width: 100%;
            }

            .book-actions {
                flex-direction: column;
            }

            .btn-add-cart,
            .btn-buy-now {
                width: 100%;
                flex: none;
            }
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
                         style="display:flex;
                                align-items:center;
                                justify-content:center;">
                        Chưa có ảnh bìa
                    </div>
                </c:otherwise>
            </c:choose>
        </div>

        <div class="book-info">

            <h1>
                <c:out value="${book.title}" />
            </h1>

            <p class="price">
                <fmt:formatNumber
                    value="${book.price}"
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

            <div class="purchase-section">

                <form id="addToCartForm"
                      action="${pageContext.request.contextPath}/cart/add"
                      method="post">

                    <input type="hidden"
                           name="csrfToken"
                           value="${sessionScope.cartCsrfToken}">

                    <input type="hidden"
                           name="bookId"
                           value="${book.id}">

                    
<div class="quantity-control">
    <label for="quantity">Số lượng:</label>

    <div class="quantity-box">
        <button type="button"
                class="quantity-btn"
                onclick="changeQuantity(-1)">
            −
        </button>

        <input type="number"
               id="quantity"
               name="quantity"
               class="quantity-input"
               value="1"
               min="1"
               required>

        <button type="button"
                class="quantity-btn"
                onclick="changeQuantity(1)">
            +
        </button>
    </div>
</div>


                    <div class="book-actions">

                        <button type="submit"
                                class="btn-add-cart">
                            🛒 Thêm vào giỏ hàng
                        </button>

                        
<button type="submit"
        name="buyNow"
        value="true"
        class="btn-buy-now">
    Mua ngay
</button>


                    </div>

                </form>

            </div>

        </div>

    </div>

</div>
<script>
    function changeQuantity(amount) {
        const input = document.getElementById("quantity");
        const current = parseInt(input.value, 10) || 1;
        input.value = Math.max(1, current + amount);
    }
</script>
</body>
</html>

<jsp:include page="/views/common/footer.jsp" />
