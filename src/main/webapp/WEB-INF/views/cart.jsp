<%@ page contentType="text/html;charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>

<fmt:setLocale value="vi_VN" />
<c:set var="ctx" value="${pageContext.request.contextPath}" />

<jsp:include page="/views/common/header.jsp" />

<style>
    .cart-page {
        width: 94%;
        max-width: 1280px;
        margin: 32px auto 60px;
        color: #1e293b;
    }

    .cart-page h1 {
        margin: 12px 0 6px;
        font-size: 30px;
        font-weight: 800;
        color: #172554;
    }

    .cart-page h2 {
        margin: 0 0 18px;
        font-size: 21px;
        font-weight: 700;
    }

    .cart-muted {
        color: #64748b;
        line-height: 1.6;
    }

    .cart-back {
        color: #2563eb;
        font-weight: 600;
        text-decoration: none;
    }

    .cart-layout {
        display: grid;
        grid-template-columns: minmax(0, 1fr) 280px;
        gap: 24px;
        margin-top: 24px;
        align-items: start;
    }

    .cart-panel {
        min-width: 0;
        padding: 24px;
        background: white;
        border: 1px solid #e2e8f0;
        border-radius: 18px;
    }

    .cart-table-wrap {
        overflow-x: auto;
    }

    .cart-table {
        width: 100%;
        border-collapse: collapse;
    }

    .cart-table th,
    .cart-table td {
        padding: 16px 10px;
        text-align: left;
        border-bottom: 1px solid #e2e8f0;
        vertical-align: top;
    }

    .cart-table th {
        background: #f8fafc;
        color: #64748b;
        font-size: 13px;
        white-space: nowrap;
    }

    .cart-table .cart-number {
        text-align: right;
        white-space: nowrap;
    }

    .cart-title {
        min-width: 130px;
        font-weight: 600;
        overflow-wrap: anywhere;
    }

    .cart-warning {
        margin-top: 7px;
        color: #b45309;
        font-size: 13px;
    }

    .cart-quantity-form {
        display: flex;
        align-items: center;
        justify-content: flex-end;
        gap: 6px;
    }

    .cart-quantity-input {
        box-sizing: border-box;
        width: 65px;
        height: 38px;
        padding: 8px 4px;
        border: 1px solid #cbd5e1;
        border-radius: 8px;
        text-align: center;
        font: inherit;
        appearance: textfield;
        -moz-appearance: textfield;
    }

    .cart-quantity-input::-webkit-inner-spin-button,
    .cart-quantity-input::-webkit-outer-spin-button {
        -webkit-appearance: none;
        margin: 0;
    }

    .cart-step-button {
        width: 32px;
        height: 36px;
        border: 1px solid #cbd5e1;
        border-radius: 8px;
        background: #f8fafc;
        color: #1e293b;
        font-size: 18px;
        cursor: pointer;
    }

    .cart-step-button:hover:not(:disabled) {
        background: #eff6ff;
        border-color: #2563eb;
        color: #2563eb;
    }

    .cart-remove-button {
        padding: 8px 12px;
        border: 1px solid #fecdd3;
        border-radius: 8px;
        background: #fff1f2;
        color: #be123c;
        font-weight: 600;
        cursor: pointer;
    }

    .cart-step-button:disabled,
    .cart-quantity-input:disabled {
        opacity: 0.5;
        cursor: not-allowed;
    }

    .cart-quantity-form[aria-busy="true"] {
        opacity: 0.6;
    }

    .cart-summary-row {
        display: flex;
        justify-content: space-between;
        gap: 12px;
        margin: 16px 0;
    }

    .cart-total {
        margin-top: 16px;
        padding-top: 16px;
        border-top: 1px solid #e2e8f0;
        color: #2563eb;
        font-size: 23px;
        font-weight: 800;
    }

    .cart-empty {
        text-align: center;
        padding: 42px 16px;
    }

    .cart-empty-icon {
        font-size: 50px;
        margin-bottom: 12px;
    }

    .cart-message {
        padding: 14px 18px;
        margin-top: 18px;
        border-radius: 10px;
        line-height: 1.6;
        overflow-wrap: anywhere;
    }

    .cart-success {
        color: #047857;
        background: #ecfdf5;
        border: 1px solid #a7f3d0;
    }

    .cart-error {
        color: #be123c;
        background: #fff1f2;
        border: 1px solid #fecdd3;
    }

    .cart-button {
        display: block;
        box-sizing: border-box;
        width: 100%;
        padding: 11px 15px;
        border: 0;
        border-radius: 9px;
        background: #2563eb;
        color: white;
        font-weight: 600;
        text-align: center;
        text-decoration: none;
        cursor: pointer;
    }

    .cart-button:hover {
        background: #1d4ed8;
    }

    .cart-checkout-button {
        margin-top: 20px;
    }

    @media (max-width: 1000px) {
        .cart-layout {
            grid-template-columns: 1fr;
        }
    }

    @media (max-width: 480px) {
        .cart-panel {
            padding: 16px;
        }
    }
</style>

<main class="cart-page">
    <a class="cart-back" href="${ctx}/home">← Về trang chủ</a>

    <h1>Giỏ hàng của bạn</h1>

    <p class="cart-muted">
        Xem sách đã chọn, thay đổi số lượng hoặc xóa sách khỏi giỏ hàng.
    </p>

    <c:if test="${not empty successMessage}">
        <div class="cart-message cart-success" role="status">
            <c:out value="${successMessage}" />
        </div>
    </c:if>

    <c:if test="${not empty errorMessage}">
        <div class="cart-message cart-error" role="alert">
            <c:out value="${errorMessage}" />
        </div>
    </c:if>

    <c:if test="${cartLoaded}">
        <div class="cart-layout">
            <section class="cart-panel">
                <h2>Sách trong giỏ</h2>

                <c:choose>
                    <c:when test="${empty cart.items}">
                        <div class="cart-empty">
                            <div class="cart-empty-icon">🛒</div>
                            <h2>Giỏ hàng đang trống</h2>

                            <p class="cart-muted">
                                Hãy chọn sách để thêm vào giỏ hàng.
                            </p>

                            <a href="${ctx}/home" class="cart-back">
                                Tiếp tục mua sắm
                            </a>
                        </div>
                    </c:when>

                    <c:otherwise>
                        <div class="cart-table-wrap">
                            <table class="cart-table">
                                <thead>
                                    <tr>
                                        <th>Sách</th>
                                        <th class="cart-number">Đơn giá</th>
                                        <th class="cart-number">Số lượng</th>
                                        <th class="cart-number">Thành tiền</th>
                                        <th>Thao tác</th>
                                    </tr>
                                </thead>

                                <tbody>
                                    <c:forEach var="item" items="${cart.items}">
                                        <tr>
                                            <td>
                                                <div class="cart-title">
                                                    <c:out value="${item.title}" />
                                                </div>

                                                <c:if test="${item.stockWarning}">
                                                    <div class="cart-warning">
                                                        Số lượng khả dụng:
                                                        <c:out value="${item.available}" />.
                                                        Vui lòng giảm số lượng
                                                        hoặc xóa sách khỏi giỏ.
                                                    </div>
                                                </c:if>
                                            </td>

                                            <td class="cart-number">
                                                <fmt:formatNumber
                                                    value="${item.unitPrice}"
                                                    maxFractionDigits="0"
                                                /> ₫
                                            </td>

                                            <td class="cart-number">
                                                <form action="${ctx}/cart"
                                                      method="post"
                                                      class="cart-quantity-form">

                                                    <input type="hidden"
                                                           name="csrfToken"
                                                           value="${sessionScope.cartCsrfToken}">

                                                    <input type="hidden"
                                                           name="action"
                                                           value="update">

                                                    <input type="hidden"
                                                           name="itemId"
                                                           value="${item.id}">

                                                    <button type="button"
                                                            class="cart-step-button"
                                                            data-delta="-1"
                                                            aria-label="Giảm số lượng"
                                                            <c:if test="${item.available le 0 or item.quantity le 1}">disabled</c:if>>
                                                        −
                                                    </button>

                                                    <input type="number"
                                                           name="quantity"
                                                           class="cart-quantity-input"
                                                           value="${item.quantity}"
                                                           min="1"
                                                           max="${item.available gt 0 ? item.available : 1}"
                                                           step="1"
                                                           inputmode="numeric"
                                                           aria-label="Số lượng sách"
                                                           required
                                                           <c:if test="${item.available le 0}">disabled</c:if>>

                                                    <button type="button"
                                                            class="cart-step-button"
                                                            data-delta="1"
                                                            aria-label="Tăng số lượng"
                                                            <c:if test="${item.available le 0 or item.quantity ge item.available}">disabled</c:if>>
                                                        +
                                                    </button>
                                                </form>
                                            </td>

                                            <td class="cart-number">
                                                <fmt:formatNumber
                                                    value="${item.subtotal}"
                                                    maxFractionDigits="0"
                                                /> ₫
                                            </td>

                                            <td>
                                                <form action="${ctx}/cart"
                                                      method="post"
                                                      class="cart-remove-form">

                                                    <input type="hidden"
                                                           name="csrfToken"
                                                           value="${sessionScope.cartCsrfToken}">

                                                    <input type="hidden"
                                                           name="action"
                                                           value="remove">

                                                    <input type="hidden"
                                                           name="itemId"
                                                           value="${item.id}">

                                                    <button type="submit"
                                                            class="cart-remove-button">
                                                        Xóa
                                                    </button>
                                                </form>
                                            </td>
                                        </tr>
                                    </c:forEach>
                                </tbody>
                            </table>
                        </div>
                    </c:otherwise>
                </c:choose>
            </section>

            <aside class="cart-panel">
                <h2>Tóm tắt giỏ hàng</h2>

                <div class="cart-summary-row">
                    <span>Số lượng sách</span>
                    <strong>
                        <c:out value="${cart.totalQuantity}" />
                    </strong>
                </div>

                <div class="cart-total">
                    <fmt:formatNumber
                        value="${cart.total}"
                        maxFractionDigits="0"
                    /> ₫
                </div>

                <p class="cart-muted">
                    Tạm tính tiền sách, chưa bao gồm phí vận chuyển.
                </p>
            </aside>
        </div>
    </c:if>
</main>

<script>
    (function () {
        let updatePending = false;

        document.querySelectorAll(".cart-quantity-form").forEach(function (form) {
            const input = form.elements.namedItem("quantity");
            const originalQuantity = Number(input.value);
            const buttons = form.querySelectorAll(".cart-step-button");

            function saveQuantity() {
                if (updatePending || input.disabled) {
                    return;
                }

                if (!form.reportValidity()) {
                    return;
                }

                if (Number(input.value) === originalQuantity) {
                    return;
                }

                form.requestSubmit();
            }

            form.addEventListener("submit", function (event) {
                if (updatePending
                        || input.disabled
                        || !form.reportValidity()
                        || Number(input.value) === originalQuantity) {
                    event.preventDefault();
                    return;
                }

                updatePending = true;
                form.setAttribute("aria-busy", "true");
                input.readOnly = true;

                document.querySelectorAll(".cart-step-button").forEach(function (button) {
                    button.disabled = true;
                });
            });

            buttons.forEach(function (button) {
                button.addEventListener("click", function () {
                    if (updatePending || input.disabled) {
                        return;
                    }

                    const minimum = Number(input.min);
                    const maximum = Number(input.max);
                    const current = Number(input.value);
                    const delta = Number(button.dataset.delta);

                    if (!Number.isInteger(current)) {
                        input.reportValidity();
                        return;
                    }

                    const next = Math.min(
                        maximum,
                        Math.max(minimum, current + delta)
                    );

                    if (next === current) {
                        return;
                    }

                    input.value = next;
                    saveQuantity();
                });
            });

            input.addEventListener("change", saveQuantity);

            input.addEventListener("keydown", function (event) {
                if (event.key === "Enter") {
                    event.preventDefault();
                    saveQuantity();
                }
            });
        });

        document.querySelectorAll(".cart-remove-form").forEach(function (form) {
            form.addEventListener("submit", function (event) {
                if (updatePending
                        || !window.confirm("Bạn muốn xóa sách này khỏi giỏ hàng?")) {
                    event.preventDefault();
                }
            });
        });

        document.querySelectorAll(".cart-checkout-button").forEach(function (link) {
            link.addEventListener("click", function (event) {
                if (updatePending) {
                    event.preventDefault();
                }
            });
        });

        window.addEventListener("pageshow", function (event) {
            if (event.persisted) {
                window.location.reload();
            }
        });
    })();
</script>

<jsp:include page="/views/common/footer.jsp" />