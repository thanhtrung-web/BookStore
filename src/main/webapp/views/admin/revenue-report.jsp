
<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>

<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Báo cáo doanh thu | BookStore</title>

    <style>
        * {
            box-sizing: border-box;
        }

        body {
            margin: 0;
            padding: 24px;
            background: #f4f6f9;
            color: #263445;
            font-family: Arial, sans-serif;
        }

        .container {
            max-width: 1200px;
            margin: auto;
        }

        h1 {
            margin-bottom: 8px;
            font-size: 28px;
        }

        .subtitle {
            margin-bottom: 24px;
            color: #68778a;
        }

        .card {
            margin-bottom: 24px;
            padding: 24px;
            background: #fff;
            border: 1px solid #e5eaf0;
            border-radius: 12px;
        }

        .filters {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(170px, 1fr));
            gap: 16px;
            align-items: end;
        }

        label {
            display: block;
            margin-bottom: 8px;
            font-size: 14px;
            font-weight: bold;
        }

        input, select, button {
            width: 100%;
            min-height: 40px;
            padding: 9px 12px;
            border: 1px solid #d5dce5;
            border-radius: 6px;
            font-size: 14px;
        }

        button {
            border: none;
            background: #2457c5;
            color: white;
            cursor: pointer;
            font-weight: bold;
        }

        button:hover {
            background: #19449f;
        }

        .summary {
            background: #eaf1ff;
            border-color: #d5e2ff;
        }

        .summary-label {
            color: #405777;
            font-size: 15px;
        }

        .summary-value {
            margin-top: 12px;
            color: #19449f;
            font-size: 30px;
            font-weight: bold;
            overflow-wrap: anywhere;
        }

        .section-title {
            margin: 0 0 18px;
            font-size: 20px;
        }

        .table-wrapper {
            overflow-x: auto;
        }

        table {
            width: 100%;
            border-collapse: collapse;
            white-space: nowrap;
        }

        th, td {
            padding: 13px 12px;
            border-bottom: 1px solid #e8edf3;
            text-align: left;
        }

        th {
            background: #f7f9fc;
            color: #526176;
            font-size: 13px;
        }

        td {
            font-size: 14px;
        }

        .number {
            text-align: right;
        }

        .message {
            margin-bottom: 20px;
            padding: 14px 16px;
            border-radius: 8px;
        }

        .error {
            background: #fff0f0;
            color: #a12626;
        }

        .empty {
            padding: 24px;
            color: #68778a;
            text-align: center;
        }

        .book-title {
            font-weight: bold;
        }

        .cover {
            width: 44px;
            height: 58px;
            object-fit: cover;
            border-radius: 4px;
            background: #edf0f4;
        }

        @media (max-width: 600px) {
            body {
                padding: 12px;
            }

            .card {
                padding: 16px;
            }

            h1 {
                font-size: 23px;
            }
        }
    </style>
</head>

<body>
<div class="container">

    <h1>Báo cáo doanh thu</h1>
    <p class="subtitle">
        Theo dõi doanh thu và các đầu sách bán chạy của BookStore.
    </p>

    <c:if test="${not empty errorMessage}">
        <div class="message error">
            <c:out value="${errorMessage}" />
        </div>
    </c:if>

    <!-- Report filters -->
    <section class="card">
        <h2 class="section-title">Bộ lọc báo cáo</h2>

        <form method="get"
              action="${pageContext.request.contextPath}/admin/reports/revenue">

            <div class="filters">
                <div>
                    <label for="startDate">Từ ngày</label>
                    <input type="date"
                           id="startDate"
                           name="startDate"
                           value="<c:out value='${startDate}'/>"
                           required>
                </div>

                <div>
                    <label for="endDate">Đến ngày</label>
                    <input type="date"
                           id="endDate"
                           name="endDate"
                           value="<c:out value='${endDate}'/>"
                           required>
                </div>

                <div>
                    <label for="groupBy">Nhóm doanh thu</label>
                    <select id="groupBy" name="groupBy">
                        <option value="DAY"
                            ${groupBy == 'DAY' ? 'selected' : ''}>
                            Theo ngày
                        </option>
                        <option value="WEEK"
                            ${groupBy == 'WEEK' ? 'selected' : ''}>
                            Theo tuần
                        </option>
                        <option value="MONTH"
                            ${groupBy == 'MONTH' ? 'selected' : ''}>
                            Theo tháng
                        </option>
                    </select>
                </div>

                <div>
                    <label for="rankingMetric">Xếp hạng sách</label>
                    <select id="rankingMetric" name="rankingMetric">
                        <option value="QUANTITY"
                            ${rankingMetric == 'QUANTITY' ? 'selected' : ''}>
                            Theo số lượng bán
                        </option>
                        <option value="REVENUE"
                            ${rankingMetric == 'REVENUE' ? 'selected' : ''}>
                            Theo doanh thu
                        </option>
                    </select>
                </div>

                <div>
                    <label for="categoryId">ID thể loại (không bắt buộc)</label>
                    <input type="number"
                           id="categoryId"
                           name="categoryId"
                           min="1"
                           placeholder="Để trống = tất cả"
                           value="<c:out value='${categoryId}'/>">
                </div>

                <div>
                    <button type="submit">Xem báo cáo</button>
                </div>
            </div>
        </form>
    </section>

    <!-- Revenue summary -->
    <section class="card summary">
        <div class="summary-label">Tổng doanh thu trong kỳ</div>
        <div class="summary-value">
            <c:choose>
                <c:when test="${not empty totalRevenue}">
                    <fmt:formatNumber
                        value="${totalRevenue}"
                        type="number"
                        groupingUsed="true"
                        maxFractionDigits="0" /> đ
                </c:when>
                <c:otherwise>
                    Chưa có dữ liệu
                </c:otherwise>
            </c:choose>
        </div>
    </section>

    <!-- Revenue table -->
    <section class="card">
        <h2 class="section-title">Chi tiết doanh thu</h2>

        <div class="table-wrapper">
            <table>
                <thead>
                <tr>
                    <th>Ngày / kỳ báo cáo</th>
                    <th class="number">Số đơn hàng</th>
                    <th class="number">Doanh thu</th>
                </tr>
                </thead>

                <tbody>
                <c:choose>
                    <c:when test="${not empty revenueData}">
                        <c:forEach var="item" items="${revenueData}">
                            <tr>
                                <td>
                                    <c:out value="${item.reportDate}"/>
                                </td>
                                <td class="number">
                                    <c:out value="${item.orderCount}"/>
                                </td>
                                <td class="number">
                                    <fmt:formatNumber
                                        value="${item.revenue}"
                                        type="number"
                                        groupingUsed="true"
                                        maxFractionDigits="0"/> đ
                                </td>
                            </tr>
                        </c:forEach>
                    </c:when>

                    <c:otherwise>
                        <tr>
                            <td colspan="3" class="empty">
                                Chưa có dữ liệu doanh thu trong kỳ đã chọn.
                            </td>
                        </tr>
                    </c:otherwise>
                </c:choose>
                </tbody>
            </table>
        </div>
    </section>

    <!-- Best-selling books -->
    <section class="card">
        <h2 class="section-title">Top 20 sách bán chạy</h2>

        <div class="table-wrapper">
            <table>
                <thead>
                <tr>
                    <th>Hạng</th>
                    <th>Bìa sách</th>
                    <th>Tên sách</th>
                    <th>Thể loại</th>
                    <th class="number">Số lượng bán</th>
                    <th class="number">Doanh thu</th>
                </tr>
                </thead>

                <tbody>
                <c:choose>
                    <c:when test="${not empty topBooks}">
                        <c:forEach var="book" items="${topBooks}">
                            <tr>
                                <td>
                                    <c:out value="${book.rank}"/>
                                </td>

                                <td>
                                    <c:choose>
                                        <c:when test="${not empty book.coverImage}">
                                            <img class="cover"
                                                 src="<c:out value='${book.coverImage}'/>"
                                                 alt="Bìa sách">
                                        </c:when>
                                        <c:otherwise>
                                            Không có ảnh
                                        </c:otherwise>
                                    </c:choose>
                                </td>

                                <td class="book-title">
                                    <c:out value="${book.bookTitle}"/>
                                </td>

                                <td>
                                    <c:out value="${book.categories}"/>
                                </td>

                                <td class="number">
                                    <c:out value="${book.quantitySold}"/>
                                </td>

                                <td class="number">
                                    <fmt:formatNumber
                                        value="${book.revenue}"
                                        type="number"
                                        groupingUsed="true"
                                        maxFractionDigits="0"/> đ
                                </td>
                            </tr>
                        </c:forEach>
                    </c:when>

                    <c:otherwise>
                        <tr>
                            <td colspan="6" class="empty">
                                Chưa có dữ liệu sách bán chạy trong kỳ đã chọn.
                            </td>
                        </tr>
                    </c:otherwise>
                </c:choose>
                </tbody>
            </table>
        </div>
    </section>

</div>
</body>
</html>
