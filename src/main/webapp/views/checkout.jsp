
<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>

<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Checkout - BookStore</title>

    <style>
        body {
            font-family: Arial, sans-serif;
            max-width: 900px;
            margin: 32px auto;
            padding: 0 18px;
            color: #222;
        }

        .panel {
            border: 1px solid #ddd;
            border-radius: 10px;
            padding: 20px;
            margin-bottom: 20px;
        }

        .item, .total-row {
            display: flex;
            justify-content: space-between;
            gap: 16px;
            padding: 12px 0;
            border-bottom: 1px solid #eee;
        }

        .total-row:last-child {
            border-bottom: 0;
        }

        input[type="text"] {
            padding: 11px;
            width: min(320px, 65%);
            border: 1px solid #bbb;
            border-radius: 6px;
        }

        button {
            padding: 11px 16px;
            border: 0;
            border-radius: 6px;
            cursor: pointer;
        }

        .apply {
            background: #164e8a;
            color: white;
        }

        .remove {
            background: #eee;
            color: #222;
        }

        .message {
            margin-top: 14px;
            padding: 12px;
            border-radius: 6px;
        }

        .success {
            background: #e7f6ec;
            color: #176b36;
        }

        .error {
            background: #fdecec;
            color: #a32020;
        }

        .discount {
            color: #16803c;
        }
    </style>
</head>

<body>
    <h1>Thanh toán</h1>

    <section class="panel">
        <h2>Giỏ hàng</h2>

        <c:choose>
            <c:when test="${empty cartItems}">
                <p>Giỏ hàng của bạn đang trống.</p>
                <a href="${pageContext.request.contextPath}/home">
                    Tiếp tục mua sắm
                </a>
            </c:when>

            <c:otherwise>
                <c:forEach var="item" items="${cartItems}">
                    <div class="item">
                        <div>
                            <strong>
                                <c:out value="${item.title}"/>
                            </strong>
                            <div>
                                Số lượng:
                                <c:out value="${item.quantity}"/>
                            </div>
                        </div>

                        <div>
                            <fmt:formatNumber value="${item.subtotal}"
                                              type="number"
                                              maxFractionDigits="0"/> đ
                        </div>
                    </div>
                </c:forEach>

                <div class="total-row">
                    <strong>Tiền hàng</strong>
                    <strong>
                        <fmt:formatNumber value="${subtotal}"
                                          type="number"
                                          maxFractionDigits="0"/> đ
                    </strong>
                </div>
            </c:otherwise>
        </c:choose>
    </section>

    <c:if test="${not empty cartItems}">
        <section class="panel">
            <h2>Mã giảm giá</h2>

            <c:if test="${not empty voucherMessage}">
                <div class="message ${voucherMessageType eq 'success'
                                      ? 'success' : 'error'}">
                    <c:out value="${voucherMessage}"/>
                </div>
            </c:if>

            <c:choose>
                <c:when test="${not empty appliedVoucher}">
                    <p>
                        Đang áp dụng mã:
                        <strong>
                            <c:out value="${appliedVoucher.code}"/>
                        </strong>
                    </p>

                    <form method="post"
                          action="${pageContext.request.contextPath}/checkout">
                        <input type="hidden" name="action" value="remove">
                        <button class="remove" type="submit">
                            Bỏ mã giảm giá
                        </button>
                    </form>
                </c:when>

                <c:otherwise>
                    <form method="post"
                          action="${pageContext.request.contextPath}/checkout">
                        <input type="hidden" name="action" value="apply">

                        <label for="voucherCode">Nhập mã voucher</label>
                        <br><br>

                        <input type="text"
                               id="voucherCode"
                               name="voucherCode"
                               maxlength="50"
                               placeholder="Ví dụ: SAVE10"
                               required>

                        <button class="apply" type="submit">
                            Áp dụng
                        </button>
                    </form>
                </c:otherwise>
            </c:choose>
        </section>

        <section class="panel">
            <h2>Tổng thanh toán</h2>

            <div class="total-row">
                <span>Tiền hàng</span>
                <span>
                    <fmt:formatNumber value="${subtotal}"
                                      type="number"
                                      maxFractionDigits="0"/> đ
                </span>
            </div>

            <div class="total-row">
                <span>Giảm giá voucher</span>
                <strong class="discount">
                    - <fmt:formatNumber value="${discount}"
                                        type="number"
                                        maxFractionDigits="0"/> đ
                </strong>
            </div>

            <div class="total-row">
                <strong>Thành tiền</strong>
                <strong>
                    <fmt:formatNumber value="${finalAmount}"
                                      type="number"
                                      maxFractionDigits="0"/> đ
                </strong>
            </div>
        </section>
    </c:if>
</body>
</html>
