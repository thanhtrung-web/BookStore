<%@ page contentType="text/html;charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>

<fmt:setLocale value="vi_VN" />
<c:set var="ctx" value="${pageContext.request.contextPath}" />

<jsp:include page="/views/common/header.jsp" />

<style>
    .checkout-page {
        width: 94%;
        max-width: 1180px;
        margin: 32px auto 60px;
        color: #1e293b;
    }

    .checkout-page h1 {
        margin: 14px 0 8px;
        font-size: 30px;
        font-weight: 800;
        color: #172554;
    }

    .checkout-page h2 {
        margin: 0 0 18px;
        font-size: 21px;
        font-weight: 700;
    }

    .checkout-link {
        color: #2563eb;
        font-weight: 600;
        text-decoration: none;
    }

    .checkout-muted {
        color: #64748b;
        line-height: 1.6;
    }

    .checkout-grid {
        display: grid;
        grid-template-columns: minmax(0, 1fr) minmax(300px, 0.8fr);
        gap: 24px;
        margin-top: 24px;
        align-items: start;
    }

    .checkout-panel {
        min-width: 0;
        padding: 24px;
        background: white;
        border: 1px solid #e2e8f0;
        border-radius: 16px;
    }

    .checkout-field {
        margin-bottom: 18px;
    }

    .checkout-field label {
        display: block;
        margin-bottom: 7px;
        font-weight: 600;
    }

    .checkout-page input,
    .checkout-page textarea {
        box-sizing: border-box;
        width: 100%;
        padding: 11px 12px;
        border: 1px solid #cbd5e1;
        border-radius: 8px;
        font: inherit;
        background: white;
    }

    .checkout-page textarea {
        resize: vertical;
    }

    .checkout-page input:focus,
    .checkout-page textarea:focus {
        outline: 2px solid #93c5fd;
        border-color: #2563eb;
    }

    .checkout-error {
        margin-top: 6px;
        color: #be123c;
        font-size: 14px;
    }

    .checkout-alert {
        padding: 14px 18px;
        margin: 18px 0;
        border-radius: 10px;
        background: #fff1f2;
        border: 1px solid #fecdd3;
        color: #be123c;
    }

    .checkout-success {
        padding: 16px 18px;
        margin: 18px 0;
        border-radius: 10px;
        background: #ecfdf5;
        border: 1px solid #a7f3d0;
        color: #047857;
    }

    .checkout-item,
    .checkout-row {
        display: flex;
        justify-content: space-between;
        gap: 16px;
        padding: 14px 0;
        border-bottom: 1px solid #e2e8f0;
    }

    .checkout-item-title {
        font-weight: 600;
        overflow-wrap: anywhere;
    }

    .checkout-money {
        white-space: nowrap;
        font-weight: 600;
    }

    .checkout-total {
        font-size: 21px;
        color: #2563eb;
        font-weight: 800;
    }

    .checkout-button {
        padding: 11px 16px;
        background: #2563eb;
        color: white;
        border: 0;
        border-radius: 8px;
        font-weight: 600;
        cursor: pointer;
    }

    .checkout-button:hover {
        background: #1d4ed8;
    }

    .checkout-button:disabled {
        opacity: 0.5;
        cursor: not-allowed;
    }

    .checkout-secondary {
        background: #e2e8f0;
        color: #334155;
    }

    .checkout-secondary:hover {
        background: #cbd5e1;
    }

    .checkout-actions {
        display: flex;
        flex-wrap: wrap;
        gap: 10px;
        margin-top: 12px;
    }

    .checkout-voucher {
        margin-top: 24px;
    }

    .checkout-submit {
        width: 100%;
        margin-top: 24px;
    }

    .checkout-empty {
        margin-top: 24px;
        padding: 48px 24px;
        text-align: center;
    }

    @media (max-width: 850px) {
        .checkout-grid {
            grid-template-columns: 1fr;
        }
    }

    @media (max-width: 480px) {
        .checkout-panel {
            padding: 18px;
        }

        .checkout-page h1 {
            font-size: 26px;
        }
    }
</style>

<main class="checkout-page">
    <a href="${ctx}/cart" class="checkout-link">
        ← Quay lại giỏ hàng
    </a>

    <h1>Xác nhận thông tin đặt hàng</h1>

    <c:if test="${not empty errorMessage}">
        <div class="checkout-alert" role="alert">
            <c:out value="${errorMessage}" />
        </div>
    </c:if>

    <c:if test="${reviewReady}">
        <div class="checkout-success" role="status">
            Thông tin nhận hàng hợp lệ.
        </div>
    </c:if>

    <c:if test="${checkoutLoaded}">
        <c:choose>
            <c:when test="${empty checkout.items}">
                <section class="checkout-panel checkout-empty">
                    <h2>Giỏ hàng đang trống</h2>

                    <p class="checkout-muted">
                        Vui lòng thêm sách trước khi xác nhận thông tin đặt hàng.
                    </p>

                    <a href="${ctx}/cart" class="checkout-link">
                        Về giỏ hàng
                    </a>
                </section>
            </c:when>

            <c:otherwise>
                <form method="post" action="${ctx}/order/checkout">
                    <input type="hidden"
                           name="csrfToken"
                           value="${sessionScope.checkoutCsrfToken}">

                    <div class="checkout-grid">
                        <section class="checkout-panel">
                            <h2>Thông tin nhận hàng</h2>

                            <div class="checkout-field">
                                <label for="recipientName">
                                    Tên người nhận *
                                </label>

                                <input id="recipientName"
                                       name="recipientName"
                                       type="text"
                                       maxlength="100"
                                       autocomplete="name"
                                       value="<c:out value='${form.recipientName}' />"
                                       required>

                                <p class="checkout-error">
                                    <c:out value="${errors.recipientName}" />
                                </p>
                            </div>

                            <div class="checkout-field">
                                <label for="phone">
                                    Số điện thoại *
                                </label>

                                <input id="phone"
                                       name="phone"
                                       type="tel"
                                       maxlength="15"
                                       autocomplete="tel"
                                       value="<c:out value='${form.phone}' />"
                                       required>

                                <p class="checkout-error">
                                    <c:out value="${errors.phone}" />
                                </p>
                            </div>

                            <div class="checkout-field">
                                <label for="shippingAddress">
                                    Địa chỉ nhận hàng *
                                </label>

                                <textarea id="shippingAddress"
                                          name="shippingAddress"
                                          rows="3"
                                          maxlength="255"
                                          autocomplete="street-address"
                                          required><c:out value="${form.shippingAddress}" /></textarea>

                                <p class="checkout-error">
                                    <c:out value="${errors.shippingAddress}" />
                                </p>
                            </div>

                            <div class="checkout-field">
                                <label for="note">
                                    Ghi chú giao hàng
                                </label>

                                <textarea id="note"
                                          name="note"
                                          rows="3"
                                          maxlength="500"><c:out value="${form.note}" /></textarea>

                                <p class="checkout-error">
                                    <c:out value="${errors.note}" />
                                </p>
                            </div>
                        </section>

                        <aside class="checkout-panel">
                            <h2>Sách đã chọn</h2>

                            <c:forEach var="item" items="${checkout.items}">
                                <div class="checkout-item">
                                    <div>
                                        <div class="checkout-item-title">
                                            <c:out value="${item.title}" />
                                        </div>

                                        <p class="checkout-muted">
                                            Số lượng:
                                            <c:out value="${item.quantity}" />
                                        </p>

                                        <p class="checkout-muted">
                                            Đơn giá:
                                            <fmt:formatNumber
                                                value="${item.unitPrice}"
                                                maxFractionDigits="0"
                                            /> ₫
                                        </p>

                                        <c:if test="${item.stockWarning}">
                                            <p class="checkout-error">
                                                Không đủ hàng. Hiện còn
                                                <c:out value="${item.available}" />
                                                cuốn. Vui lòng sửa giỏ hàng.
                                            </p>
                                        </c:if>
                                    </div>

                                    <span class="checkout-money">
                                        <fmt:formatNumber
                                            value="${item.subtotal}"
                                            maxFractionDigits="0"
                                        /> ₫
                                    </span>
                                </div>
                            </c:forEach>

                            <div class="checkout-voucher">
                                <div class="checkout-field">
                                    <label for="voucherCode">
                                        Mã giảm giá
                                    </label>

                                    <input id="voucherCode"
                                           name="voucherCode"
                                           type="text"
                                           maxlength="50"
                                           value="<c:out value='${form.voucherCode}' />">
                                </div>

                                <div class="checkout-actions">
                                    <button type="submit"
                                            name="action"
                                            value="applyVoucher"
                                            class="checkout-button"
                                            formnovalidate>
                                        Áp dụng
                                    </button>

                                    <button type="submit"
                                            name="action"
                                            value="removeVoucher"
                                            class="checkout-button checkout-secondary"
                                            formnovalidate>
                                        Bỏ mã
                                    </button>
                                </div>

                                <c:if test="${not empty checkout.voucherError}">
                                    <p class="checkout-error" role="alert">
                                        <c:out value="${checkout.voucherError}" />
                                    </p>
                                </c:if>

                                <c:if test="${not empty checkout.voucher}">
                                    <p class="checkout-muted">
                                        Đã áp dụng:
                                        <strong>
                                            <c:out value="${checkout.voucher.code}" />
                                        </strong>
                                    </p>
                                </c:if>
                            </div>

                            <div class="checkout-row">
                                <span>Tiền sách</span>

                                <span>
                                    <fmt:formatNumber
                                        value="${checkout.subtotal}"
                                        maxFractionDigits="0"
                                    /> ₫
                                </span>
                            </div>

                            <div class="checkout-row">
                                <span>Giảm giá</span>

                                <span>
                                    − <fmt:formatNumber
                                        value="${checkout.discount}"
                                        maxFractionDigits="0"
                                    /> ₫
                                </span>
                            </div>

                            <div class="checkout-row checkout-total">
                                <span>Tạm tính</span>

                                <span>
                                    <fmt:formatNumber
                                        value="${checkout.finalAmount}"
                                        maxFractionDigits="0"
                                    /> ₫
                                </span>
                            </div>

                            <p class="checkout-muted">
                                Chưa bao gồm phí vận chuyển.
                            </p>

                            <button type="submit"
                                    name="action"
                                    value="review"
                                    class="checkout-button checkout-submit"
                                    <c:if test="${not checkout.stockValid}">disabled</c:if>>
                                Kiểm tra thông tin
                            </button>
                        </aside>
                    </div>
                </form>
            </c:otherwise>
        </c:choose>
    </c:if>
</main>

<jsp:include page="/views/common/footer.jsp" />