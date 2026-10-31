package com.bookstore.dao;

import com.bookstore.context.DBContext;

import java.math.BigDecimal;
import java.sql.Connection;
import java.sql.Date;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;

public class ReportDAO {

    private static final String ORDER_CONDITION =
            " o.payment_status = 'PAID' " +
            " AND o.order_status = 'DELIVERED' ";

    /**
     * Lấy các chỉ số tổng quan cho Admin Dashboard.
     * Doanh thu và số đơn dùng chung điều kiện PAID + DELIVERED.
     */
    public Map<String, Object> getDashboardSummary(
            Date startDate, Date endDate) throws SQLException {

        Map<String, Object> result = new LinkedHashMap<>();

        String revenueSql =
                "SELECT " +
                " COALESCE(SUM(o.final_amount), 0) AS total_revenue, " +
                " COUNT(*) AS total_orders " +
                "FROM dbo.orders o " +
                "WHERE " + ORDER_CONDITION +
                " AND o.created_at >= ? " +
                " AND o.created_at < DATEADD(day, 1, ?)";

        String booksSql =
                "SELECT COUNT(*) AS total_books " +
                "FROM dbo.books b " +
                "WHERE b.is_deleted = 0";

        String customersSql =
                "SELECT COUNT(DISTINCT u.id) AS active_customers " +
                "FROM dbo.users u " +
                "INNER JOIN dbo.user_roles ur ON ur.user_id = u.id " +
                "INNER JOIN dbo.roles r ON r.id = ur.role_id " +
                "WHERE u.status = 'ACTIVE' " +
                "AND u.is_deleted = 0 " +
                "AND UPPER(r.role_name) = 'BUYER'";

        try (Connection conn = DBContext.getConnection()) {

            try (PreparedStatement ps = conn.prepareStatement(revenueSql)) {
                ps.setDate(1, startDate);
                ps.setDate(2, endDate);

                try (ResultSet rs = ps.executeQuery()) {
                    if (rs.next()) {
                        result.put("totalRevenue", rs.getBigDecimal("total_revenue"));
                        result.put("totalOrders", rs.getInt("total_orders"));
                    }
                }
            }

            try (PreparedStatement ps = conn.prepareStatement(booksSql);
                 ResultSet rs = ps.executeQuery()) {

                if (rs.next()) {
                    result.put("totalBooks", rs.getInt("total_books"));
                }
            }

            try (PreparedStatement ps = conn.prepareStatement(customersSql);
                 ResultSet rs = ps.executeQuery()) {

                if (rs.next()) {
                    result.put("activeCustomers", rs.getInt("active_customers"));
                }
            }
        }

        result.putIfAbsent("totalRevenue", BigDecimal.ZERO);
        result.putIfAbsent("totalOrders", 0);
        result.putIfAbsent("totalBooks", 0);
        result.putIfAbsent("activeCustomers", 0);

        return result;
    }

    /**
     * Lấy dữ liệu doanh thu theo ngày, tuần hoặc tháng.
     */
    public List<Map<String, Object>> getRevenueReport(
            Date startDate, Date endDate, String groupBy) throws SQLException {

        String dateExpression;

        switch (groupBy) {
            case "WEEK":
                dateExpression =
                        "DATEADD(day, 1 - DATEPART(weekday, CAST(o.created_at AS date)), " +
                        "CAST(o.created_at AS date))";
                break;
            case "MONTH":
                dateExpression =
                        "DATEFROMPARTS(YEAR(o.created_at), MONTH(o.created_at), 1)";
                break;
            default:
                dateExpression = "CAST(o.created_at AS date)";
                break;
        }

        String sql =
                "SELECT " + dateExpression + " AS report_date, " +
                "COUNT(*) AS order_count, " +
                "COALESCE(SUM(o.final_amount), 0) AS revenue " +
                "FROM dbo.orders o " +
                "WHERE " + ORDER_CONDITION +
                " AND o.created_at >= ? " +
                " AND o.created_at < DATEADD(day, 1, ?) " +
                "GROUP BY " + dateExpression + " " +
                "ORDER BY report_date ASC";

        List<Map<String, Object>> result = new ArrayList<>();

        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setDate(1, startDate);
            ps.setDate(2, endDate);

            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    Map<String, Object> row = new LinkedHashMap<>();
                    row.put("reportDate", rs.getDate("report_date"));
                    row.put("orderCount", rs.getInt("order_count"));
                    row.put("revenue", rs.getBigDecimal("revenue"));
                    result.add(row);
                }
            }
        }

        return result;
    }

    /**
     * Lấy danh sách sách bán chạy.
     * rankingMetric = QUANTITY hoặc REVENUE.
     */
    public List<Map<String, Object>> getBestSellingBooks(
            Date startDate,
            Date endDate,
            Long categoryId,
            String rankingMetric,
            int limit) throws SQLException {

        String orderBy = "total_quantity";

        if ("REVENUE".equalsIgnoreCase(rankingMetric)) {
            orderBy = "total_revenue";
        }

        String sql =
                "SELECT TOP (?) " +
                " b.id AS book_id, " +
                " b.title AS book_title, " +
                " b.price AS unit_price, " +
                " COALESCE(inv.stock_quantity, 0) AS stock_quantity, " +
                " COALESCE(SUM(oi.quantity), 0) AS total_quantity, " +
                " COALESCE(SUM(oi.subtotal), 0) AS total_revenue, " +
                " COALESCE(authors.author_names, N'Chưa cập nhật') AS author_names, " +
                " (SELECT TOP 1 bi.image_url " +
                "  FROM dbo.book_images bi " +
                "  WHERE bi.book_id = b.id " +
                "  ORDER BY bi.is_thumbnail DESC, bi.display_order ASC) AS cover_image " +
                "FROM dbo.books b " +
                "INNER JOIN dbo.order_items oi ON oi.book_id = b.id " +
                "INNER JOIN dbo.orders o ON o.id = oi.order_id " +
                "LEFT JOIN dbo.inventories inv ON inv.book_id = b.id " +
                "OUTER APPLY ( " +
                "   SELECT STRING_AGG(a.name, N', ') AS author_names " +
                "   FROM dbo.book_authors ba " +
                "   INNER JOIN dbo.authors a ON a.id = ba.author_id " +
                "   WHERE ba.book_id = b.id AND a.is_deleted = 0 " +
                ") authors " +
                "WHERE " + ORDER_CONDITION +
                " AND o.created_at >= ? " +
                " AND o.created_at < DATEADD(day, 1, ?) " +
                " AND b.is_deleted = 0 " +
                " AND (? IS NULL OR EXISTS ( " +
                "     SELECT 1 FROM dbo.book_categories bc " +
                "     WHERE bc.book_id = b.id AND bc.category_id = ? " +
                " )) " +
                "GROUP BY b.id, b.title, b.price, inv.stock_quantity, authors.author_names " +
                "ORDER BY " + orderBy + " DESC";

        List<Map<String, Object>> result = new ArrayList<>();

        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setInt(1, limit);
            ps.setDate(2, startDate);
            ps.setDate(3, endDate);

            if (categoryId == null) {
                ps.setNull(4, java.sql.Types.BIGINT);
                ps.setNull(5, java.sql.Types.BIGINT);
            } else {
                ps.setLong(4, categoryId);
                ps.setLong(5, categoryId);
            }

            try (ResultSet rs = ps.executeQuery()) {
                int rank = 1;

                while (rs.next()) {
                    Map<String, Object> row = new LinkedHashMap<>();

                    row.put("rank", rank++);
                    row.put("bookId", rs.getLong("book_id"));
                    row.put("bookTitle", rs.getString("book_title"));
                    row.put("authors", rs.getString("author_names"));
                    row.put("coverImage", rs.getString("cover_image"));
                    row.put("unitPrice", rs.getBigDecimal("unit_price"));
                    row.put("stock", rs.getInt("stock_quantity"));
                    row.put("quantitySold", rs.getInt("total_quantity"));
                    row.put("revenue", rs.getBigDecimal("total_revenue"));

                    result.add(row);
                }
            }
        }

        return result;
    }

    public BigDecimal getTotalRevenue(
            Date startDate, Date endDate) throws SQLException {

        String sql =
                "SELECT COALESCE(SUM(o.final_amount), 0) AS total_revenue " +
                "FROM dbo.orders o " +
                "WHERE " + ORDER_CONDITION +
                " AND o.created_at >= ? " +
                " AND o.created_at < DATEADD(day, 1, ?)";

        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setDate(1, startDate);
            ps.setDate(2, endDate);

            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return rs.getBigDecimal("total_revenue");
                }
            }
        }

        return BigDecimal.ZERO;
    }
}