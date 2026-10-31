<%@ page contentType="text/html;charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>

<fmt:setLocale value="vi_VN" />
<c:set var="ctx" value="${pageContext.request.contextPath}" />

<jsp:include page="/views/common/header.jsp" />

<style>
    .order-page {
        min-height: 75vh;
        padding: 40px 20px 64px;
        background: #f4f7fc;
        color: #172b4d;
    }

    .order-container {
        max-width: 1180px;
        margin: 0 auto;
    }

    .order-banner {
        padding: 32px 24px;
        margin-bottom: 24px;
        border: 1px solid #a7f3d0;
        border-radius: 20px;
        background: #ecfdf5;
        text-align: center;
    }

    .order-icon {
        display: inline-flex;
        align-items: center;
        justify-content: center;
        width: 64px;
        height: 64px;
        border-radius: 50%;
        background: #059669;
        color: #fff;
        font-size: 34px;
        font-weight: 700;
    }

    .order-banner h1 {
        margin: 18px 0 12px;
        color: #047857;
        font-size: clamp(26px, 4vw, 36px);
    }

    .order-banner p {
        margin: 8px 0;
        line-height: 1.7;
    }

    .order-code {
        font-weight: 700;
        overflow-wrap: anywhere;
    }

    .order-grid {
        display: grid;
        grid-template-columns: minmax(0, 1fr) 350px;
        gap: 24px;
        align-items: start;
    }

    .order-panel {
        min-width: 0;
        padding: 26px;
        margin-bottom: 24px;
        border: 1px solid #dfe7f3;
        border-radius: 20px;
        background: #fff;
    }

    .order-panel h2 {
        margin: 0 0 22px;
        color: #172b4d;
        font-size: 23px;
    }

    .order-info {
        display: grid;
        grid-template-columns: 150px minmax(0, 1fr);
        gap: 16px;
        margin: 0;
        line-height: 1.6;
    }

    .order-info dt {
        color: #64748b;
        font-weight: 400;
    }

    .order-info dd {
        margin: 0;
        overflow-wrap: anywhere;
    }

    .order-text {
        white-space: pre-wrap;
    }

    .order-status {
        display: inline-block;
        padding: 5px 12px;
        border-radius: 20px;
        background: #eff6ff;
        color: #1d4ed8;
        font-size: 14px;
        font-weight: 600;
    }

    .order-table-wrap {
        overflow-x: auto;
    }

    .order-table {
        width: 100%;
        min-width: 520px;
        border-collapse: collapse;
    }

    .order-table th,
    .order-table td {
        padding: 16px 12px;
        border-bottom: 1px solid #e2e8f0;
        text-align: left;
        vertical-align: top;
    }

    .order-table th {
        background: #f8fafc;
        color: #64748b;
        font-size: 14px;
    }

    .order-table .order-number {
        text-align: right;
        white-space: nowrap;
    }

    .order-summary-row {
        display: flex;
        justify-content: space-between;
        gap: 16px;
        margin-bottom: 18px;
        line-height: 1.6;
    }

    .order-summary-row strong {
        text-align: right;
        white-space: nowrap;
    }

    .order-total {
        margin-top: 20px;
        padding-top: 20px;
        border-top: 1px solid #e2e8f0;
        font-weight: 700;
    }

    .order-total strong {
        color: #2563eb;
        font-size: 24px;
    }

    .order-payment {
        margin-top: 20px;
        padding: 16px;
        border-radius: 12px;
        background: #f1f5ff;
        line-height: 1.7;
    }

    .order-payment p {
        margin: 6px 0;
    }

    .order-button {
        display: block;
        margin-top: 22px;
        padding: 15px 20px;
        border-radius: 12px;
        background: #2563eb;
        color: #fff;
        text-align: center;
        text-decoration: none;
        font-weight: 700;
    }

    .order-button:hover {
        background: #1d4ed8;
        color: #fff;
        text-decoration: none;
    }

    .order-button:focus-visible {
        outline: 3px solid #93c5fd;
        outline-offset: 3px;
    }

    .order-error {
        max-width: 650px;
        margin: 0 auto;
        text-align: center;
    }

    .order-error p {
        color: #b91c1c;
        line-height: 1.7;
    }

    @media (max-width: 900px) {
        .order-grid {
            grid-template-columns: 1fr;
        }
    }

    @media (max-width: 560px) {
        .order-page {
            padding: 24px 12px 40px;
        }

        .order-panel,
        .order-banner {
            padding: 22px 16px;
        }

        .order-info {
            grid-template-columns: 1fr;
            gap: 6px;
        }

        .order-info dd {
            margin-bottom: 12px;
        }
    }
</style>

<main class="order-page">
    <div class="order-container">
        <c:choose>
            <c:when test="${not empty errorMessage}">
                <section class="order-panel order-error">
                    <h1>Thông tin đơn hàng</h1>
                    <p role="alert">
                        <c:out value="${errorMessage}" />
                    </p>
                    <a href="${ctx}/books" class="order-button">
                        Tiếp tục mua sắm
                    </a>
                </section>
            </c:when>

            <c:when test="${not empty order}">
                <section class="order-banner">
                    <span class="order-icon" aria-hidden="true">✓</span>

                    <h1>Đơn hàng đã được ghi nhận</h1>

                    <p>Cảm ơn bạn đã mua sách tại BookStore.</p>

                    <p>
                        Mã đơn hàng:
                        <span class="order-code">
                            <c:out value="${order.orderCode}" />
                        </span>
                    </p>

                    <p>
                        Ngày đặt:
                        <fmt:formatDate
                            value="${order.createdAt}"
                            pattern="dd/MM/yyyy HH:mm"
                        />
                    </p>
                </section>

                <div class="order-grid">
                    <div>
                        <section class="order-panel">
                            <h2>Thông tin nhận hàng</h2>

                            <dl class="order-info">
                                <dt>Người nhận</dt>
                                <dd>
                                    <c:out value="${order.recipientName}" />
                                </dd>

                                <dt>Số điện thoại</dt>
                                <dd>
                                    <c:out value="${order.phone}" />
                                </dd>

                                <dt>Địa chỉ</dt>
                                <dd class="order-text"><c:out value="${order.shippingAddress}" /></dd>

                                <dt>Trạng thái đơn</dt>
                                <dd>
                                    <span class="order-status">
                                        <c:choose>
                                            <c:when test="${order.orderStatus eq 'PENDING'}">
                                                Chờ xác nhận
                                            </c:when>
                                            <c:when test="${order.orderStatus eq 'CONFIRMED'}">
                                                Đã xác nhận
                                            </c:when>
                                            <c:when test="${order.orderStatus eq 'PROCESSING'}">
                                                Đang xử lý
                                            </c:when>
                                            <c:when test="${order.orderStatus eq 'SHIPPING'}">
                                                Đang giao hàng
                                            </c:when>
                                            <c:when test="${order.orderStatus eq 'DELIVERED'}">
                                                Đã giao hàng
                                            </c:when>
                                            <c:when test="${order.orderStatus eq 'COMPLETED'}">
                                                Hoàn tất
                                            </c:when>
                                            <c:when test="${order.orderStatus eq 'CANCELLED'}">
                                                Đã hủy
                                            </c:when>
                                            <c:otherwise>
                                                Đang cập nhật
                                            </c:otherwise>
                                        </c:choose>
                                    </span>
                                </dd>

                                <c:if test="${not empty order.note}">
                                    <dt>Ghi chú</dt>
                                    <dd class="order-text"><c:out value="${order.note}" /></dd>
                                </c:if>
                            </dl>
                        </section>

                        <section class="order-panel">
                            <h2>Sách đã đặt</h2>

                            <div class="order-table-wrap">
                                <table class="order-table">
                                    <thead>
                                        <tr>
                                            <th scope="col">Sách</th>
                                            <th scope="col" class="order-number">
                                                Đơn giá
                                            </th>
                                            <th scope="col" class="order-number">
                                                Số lượng
                                            </th>
                                            <th scope="col" class="order-number">
                                                Thành tiền
                                            </th>
                                        </tr>
                                    </thead>

                                    <tbody>
                                        <c:forEach var="item" items="${order.items}">
                                            <tr>
                                                <td>
                                                    <c:out value="${item.title}" />
                                                </td>

                                                <td class="order-number">
                                                    <fmt:formatNumber
                                                        value="${item.unitPrice}"
                                                        maxFractionDigits="0"
                                                    /> ₫
                                                </td>

                                                <td class="order-number">
                                                    <c:out value="${item.quantity}" />
                                                </td>

                                                <td class="order-number">
                                                    <fmt:formatNumber
                                                        value="${item.subtotal}"
                                                        maxFractionDigits="0"
                                                    /> ₫
                                                </td>
                                            </tr>
                                        </c:forEach>
                                    </tbody>
                                </table>
                            </div>
                        </section>
                    </div>

                    <aside class="order-panel">
                        <h2>Tóm tắt đơn hàng</h2>

                        <div class="order-summary-row">
                            <span>Số lượng sách</span>
                            <strong>
                                <c:out value="${order.totalQuantity}" />
                            </strong>
                        </div>

                        <div class="order-summary-row">
                            <span>Tiền sách</span>
                            <strong>
                                <fmt:formatNumber
                                    value="${order.subtotal}"
                                    maxFractionDigits="0"
                                /> ₫
                            </strong>
                        </div>

                        <div class="order-summary-row">
                            <span>Giảm giá</span>
                            <strong>
                                − <fmt:formatNumber
                                    value="${order.discount}"
                                    maxFractionDigits="0"
                                /> ₫
                            </strong>
                        </div>

                        <div class="order-summary-row">
                            <span>Phí vận chuyển</span>
                            <strong>
                                <fmt:formatNumber
                                    value="${order.shippingFee}"
                                    maxFractionDigits="0"
                                /> ₫
                            </strong>
                        </div>

                        <div class="order-summary-row order-total">
                            <span>Tổng thanh toán</span>
                            <strong>
                                <fmt:formatNumber
                                    value="${order.finalAmount}"
                                    maxFractionDigits="0"
                                /> ₫
                            </strong>
                        </div>

                        <div class="order-payment">
                            <p>
                                <strong>Phương thức thanh toán</strong>
                            </p>

                            <p>
                                <c:choose>
                                    <c:when test="${order.paymentMethod eq 'COD'}">
                                        Thanh toán khi nhận hàng
                                    </c:when>
                                    <c:otherwise>
                                        Phương thức thanh toán đang cập nhật
                                    </c:otherwise>
                                </c:choose>
                            </p>

                            <p>
                                <c:choose>
                                    <c:when test="${order.paymentStatus eq 'PENDING'}">
                                        Chưa thanh toán
                                    </c:when>
                                    <c:when test="${order.paymentStatus eq 'PAID'}">
                                        Đã thanh toán
                                    </c:when>
                                    <c:when test="${order.paymentStatus eq 'REFUNDED'}">
                                        Đã hoàn tiền
                                    </c:when>
                                    <c:when test="${order.paymentStatus eq 'FAILED'}">
                                        Thanh toán thất bại
                                    </c:when>
                                    <c:otherwise>
                                        Trạng thái thanh toán đang cập nhật
                                    </c:otherwise>
                                </c:choose>
                            </p>
                        </div>

                        <a href="${ctx}/books" class="order-button">
                            Tiếp tục mua sắm
                        </a>
                    </aside>
                </div>
            </c:when>

            <c:otherwise>
                <section class="order-panel order-error">
                    <h1>Thông tin đơn hàng</h1>
                    <p role="alert">Không tìm thấy thông tin đơn hàng.</p>
                    <a href="${ctx}/books" class="order-button">
                        Tiếp tục mua sắm
                    </a>
                </section>
            </c:otherwise>
        </c:choose>
    </div>
</main>

<jsp:include page="/views/common/footer.jsp" />