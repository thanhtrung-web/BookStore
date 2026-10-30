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
        padding: 8px 4px;
        border: 1px solid #cbd5e1;
        border-radius: 8px;
        text-align: center;
        font: inherit;
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

    .cart-save-button {
        padding: 8px 12px;
        border: 0;
        border-radius: 8px;
        background: #2563eb;
        color: white;
        font-weight: 600;
        cursor: pointer;
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
    .cart-save-button:disabled,
    .cart-quantity-input:disabled {
        opacity: 0.5;
        cursor: not-allowed;
    }

    .cart-quantity-hint {
        margin-top: 7px;
        font-size: 12px;
        color: #64748b;
        white-space: normal;
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

    .cart-catalog {
        margin-top: 28px;
    }

    .cart-books {
        display: grid;
        grid-template-columns: repeat(auto-fit, minmax(230px, 1fr));
        gap: 18px;
        margin-top: 20px;
    }

    .cart-book {
        display: flex;
        flex-direction: column;
        padding: 20px;
        border: 1px solid #e2e8f0;
        border-radius: 14px;
        background: white;
    }

    .cart-cover {
        display: grid;
        place-items: center;
        height: 100px;
        margin-bottom: 16px;
        border-radius: 10px;
        background: #eff6ff;
        font-size: 48px;
    }

    .cart-book h3 {
        font-size: 16px;
        font-weight: 700;
        margin-bottom: 10px;
        overflow-wrap: anywhere;
    }

    .cart-price {
        color: #2563eb;
        font-size: 19px;
        font-weight: 700;
        margin-bottom: 8px;
    }

    .cart-book form {
        margin-top: auto;
        padding-top: 18px;
    }

    .cart-book label {
        display: block;
        font-size: 13px;
        margin-bottom: 6px;
    }

    .cart-book input[type="number"] {
        box-sizing: border-box;
        width: 100%;
        padding: 10px;
        border: 1px solid #cbd5e1;
        border-radius: 8px;
        margin-bottom: 10px;
    }

    .cart-button {
        display: block;
        width: 100%;
        padding: 11px 15px;
        border: 0;
        border-radius: 9px;
        background: #2563eb;
        color: white;
        font-weight: 600;
        text-align: center;
        cursor: pointer;
    }

    .cart-button:hover,
    .cart-save-button:hover {
        background: #1d4ed8;
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
                                Chọn sách ở bên dưới để bắt đầu mua sắm.
                            </p>
                            <a href="#available-books" class="cart-back">
                                Chọn sách ngay ↓
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
                                                            <c:if test="${item.available le 0}">disabled</c:if>>
                                                        −
                                                    </button>

                                                    <input type="number"
                                                           name="quantity"
                                                           class="cart-quantity-input"
                                                           value="${item.quantity}"
                                                           min="1"
                                                           max="${item.available gt 0 ? item.available : 1}"
                                                           step="1"
                                                           aria-label="Số lượng sách"
                                                           required
                                                           <c:if test="${item.available le 0}">disabled</c:if>>

                                                    <button type="button"
                                                            class="cart-step-button"
                                                            data-delta="1"
                                                            aria-label="Tăng số lượng"
                                                            <c:if test="${item.available le 0}">disabled</c:if>>
                                                        +
                                                    </button>

                                                    <button type="submit"
                                                            class="cart-save-button"
                                                            <c:if test="${item.available le 0}">disabled</c:if>>
                                                        Lưu
                                                    </button>
                                                </form>

                                                <p class="cart-quantity-hint">
                                                    Bấm Lưu sau khi đổi số lượng.
                                                </p>
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

        <section id="available-books" class="cart-catalog">
            <h2>Chọn thêm sách</h2>

            <p class="cart-muted">
                Sách đang được bán và còn hàng tại cửa hàng.
            </p>

            <c:choose>
                <c:when test="${empty books}">
                    <div class="cart-panel">
                        Hiện chưa có sách còn hàng để thêm vào giỏ.
                    </div>
                </c:when>

                <c:otherwise>
                    <div class="cart-books">
                        <c:forEach var="book" items="${books}">
                            <article class="cart-book">
                                <div class="cart-cover" aria-hidden="true">📚</div>

                                <h3>
                                    <c:out value="${book.title}" />
                                </h3>

                                <div class="cart-price">
                                    <fmt:formatNumber
                                        value="${book.unitPrice}"
                                        maxFractionDigits="0"
                                    /> ₫
                                </div>

                                <p class="cart-muted">
                                    Còn <c:out value="${book.available}" /> cuốn
                                </p>

                                <form action="${ctx}/cart/add" method="post">
                                    <input type="hidden"
                                           name="csrfToken"
                                           value="${sessionScope.cartCsrfToken}">

                                    <input type="hidden"
                                           name="bookId"
                                           value="${book.id}">

                                    <label for="quantity-${book.id}">
                                        Số lượng thêm
                                    </label>

                                    <input id="quantity-${book.id}"
                                           type="number"
                                           name="quantity"
                                           value="1"
                                           min="1"
                                           max="${book.available}"
                                           step="1"
                                           required>

                                    <button type="submit" class="cart-button">
                                        Thêm vào giỏ hàng
                                    </button>
                                </form>
                            </article>
                        </c:forEach>
                    </div>
                </c:otherwise>
            </c:choose>
        </section>
    </c:if>
</main>

<script>
    document.querySelectorAll(".cart-step-button").forEach(function (button) {
        button.addEventListener("click", function () {
            const form = button.closest("form");
            const input = form.querySelector('input[name="quantity"]');
            const minimum = Number(input.min);
            const maximum = Number(input.max);
            const delta = Number(button.dataset.delta);
            const current = Number(input.value);

            if (!Number.isInteger(current)) {
                input.value = minimum;
                return;
            }

            input.value = Math.min(
                maximum,
                Math.max(minimum, current + delta)
            );
        });
    });

    document.querySelectorAll(".cart-remove-form").forEach(function (form) {
        form.addEventListener("submit", function (event) {
            if (!window.confirm("Bạn muốn xóa sách này khỏi giỏ hàng?")) {
                event.preventDefault();
            }
        });
    });
</script>

<jsp:include page="/views/common/footer.jsp" />