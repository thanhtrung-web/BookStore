
<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>

<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>Lịch sử mua hàng - BookStore</title>
    <style>
        * { box-sizing: border-box; }
        body {
            margin: 0;
            font-family: Arial, sans-serif;
            background: #f5f6fa;
            color: #253044;
        }
        .container {
            max-width: 1100px;
            margin: 45px auto;
            padding: 0 20px;
        }
        h1 { margin-bottom: 8px; }
        .subtitle { color: #667085; margin-bottom: 25px; }
        .panel {
            background: white;
            border-radius: 12px;
            padding: 24px;
            box-shadow: 0 4px 20px rgba(0,0,0,.05);
            overflow-x: auto;
        }
        table {
            width: 100%;
            border-collapse: collapse;
            min-width: 760px;
        }
        th, td {
            text-align: left;
            padding: 15px 12px;
            border-bottom: 1px solid #edf0f4;
        }
        th { background: #f8fafc; color: #475467; }
        .code { font-weight: bold; color: #2563eb; }
        .amount { font-weight: bold; }
        .status {
            display: inline-block;
            padding: 6px 10px;
            border-radius: 20px;
            background: #eef2ff;
            font-size: 13px;
        }
        .btn {
            display: inline-block;
            padding: 9px 14px;
            background: #2563eb;
            color: white;
            border-radius: 7px;
            text-decoration: none;
            white-space: nowrap;
        }
        .btn:hover { background: #1d4ed8; }
        .empty {
            text-align: center;
            padding: 50px 15px;
            color: #667085;
        }
        .error {
            padding: 14px;
            background: #fee4e2;
            color: #b42318;
            border-radius: 8px;
            margin-bottom: 15px;
        }
        .pagination {
            display: flex;
            gap: 8px;
            justify-content: center;
            align-items: center;
            margin-top: 25px;
        }
        .pagination a {
            padding: 9px 13px;
            border: 1px solid #d0d5dd;
            border-radius: 6px;
            text-decoration: none;
            color: #2563eb;
        }
    </style>
</head>
<body>
<div class="container">
    <h1>Lịch sử mua hàng</h1>
    <p class="subtitle">
        Theo dõi các đơn hàng bạn đã đặt tại BookStore.
    </p>

    <c:if test="${not empty errorMessage}">
        <div class="error"><c:out value="${errorMessage}" /></div>
    </c:if>

    <div class="panel">
        <c:choose>
            <c:when test="${empty orders}">
                <div class="empty">
                    <h2>Chưa có đơn hàng</h2>
                    <p>Bạn chưa thực hiện đơn hàng nào.</p>
                    <a class="btn" href="${pageContext.request.contextPath}/">
                        Tiếp tục mua sắm
                    </a>
                </div>
            </c:when>

            <c:otherwise>
                <p>Tổng số đơn hàng: <strong>${totalOrders}</strong></p>

                <table>
                    <thead>
                    <tr>
                        <th>Mã đơn hàng</th>
                        <th>Ngày đặt</th>
                        <th>Tổng tiền</th>
                        <th>Trạng thái</th>
                        <th>Thanh toán</th>
                        <th>Thao tác</th>
                    </tr>
                    </thead>
                    <tbody>
                    <c:forEach var="order" items="${orders}">
                        <tr>
                            <td class="code">
                                <c:out value="${order.orderCode}" />
                            </td>
                            <td>
                                <fmt:formatDate value="${order.createdAt}"
                                                pattern="dd/MM/yyyy HH:mm" />
                            </td>
                            <td class="amount">
                                <fmt:formatNumber value="${order.finalAmount}"
                                                  type="number"
                                                  maxFractionDigits="0" /> đ
                            </td>
                            <td>
                                <span class="status">
                                    <c:choose>
                                        <c:when test="${order.orderStatus == 'PENDING'}">Chờ xác nhận</c:when>
                                        <c:when test="${order.orderStatus == 'CONFIRMED'}">Đã xác nhận</c:when>
                                        <c:when test="${order.orderStatus == 'SHIPPING'}">Đang giao hàng</c:when>
                                        <c:when test="${order.orderStatus == 'DELIVERED'}">Đã giao hàng</c:when>
                                        <c:when test="${order.orderStatus == 'CANCELLED'}">Đã hủy</c:when>
                                        <c:otherwise><c:out value="${order.orderStatus}" /></c:otherwise>
                                    </c:choose>
                                </span>
                            </td>
                            <td>
                                <c:choose>
                                    <c:when test="${order.paymentStatus == 'PAID'}">Đã thanh toán</c:when>
                                    <c:when test="${order.paymentStatus == 'PENDING'}">Chưa thanh toán</c:when>
                                    <c:otherwise><c:out value="${order.paymentStatus}" /></c:otherwise>
                                </c:choose>
                            </td>
                            <td>
                                <c:url var="detailUrl" value="/order/checkout">
                                    <c:param name="view" value="success" />
                                    <c:param name="orderCode" value="${order.orderCode}" />
                                </c:url>
                                <a class="btn" href="${detailUrl}">
                                    Xem chi tiết
                                </a>
                            </td>
                        </tr>
                    </c:forEach>
                    </tbody>
                </table>
            </c:otherwise>
        </c:choose>
    </div>

    <c:if test="${totalPages > 1}">
        <div class="pagination">
            <c:if test="${currentPage > 1}">
                <a href="?view=history&amp;page=${currentPage - 1}">Trang trước</a>
            </c:if>

            <span>Trang ${currentPage} / ${totalPages}</span>

            <c:if test="${currentPage < totalPages}">
                <a href="?view=history&amp;page=${currentPage + 1}">Trang sau</a>
            </c:if>
        </div>
    </c:if>
</div>
</body>
</html>
