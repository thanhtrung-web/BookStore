
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

/**
 * ReportDAO handles database queries for revenue reports
 * and best-selling books reports.
 */
public class ReportDAO {

    /**
     * Gets revenue grouped by day, week, or month.
     *
     * @param startDate inclusive start date
     * @param endDate inclusive end date
     * @param groupBy DAY, WEEK, or MONTH
     * @return revenue statistics
     */
    public List<Map<String, Object>> getRevenueReport(
            Date startDate,
            Date endDate,
            String groupBy) throws SQLException {

        String dateExpression;

        switch (groupBy == null ? "DAY" : groupBy.toUpperCase()) {
            case "WEEK":
                // SQL Server: Monday-based week grouping.
                dateExpression =
                        "DATEADD(day, 1 - DATEPART(weekday, " +
                        "DATEADD(day, @@DATEFIRST - 1, o.created_at)), " +
                        "CAST(o.created_at AS date))";
                break;
            case "MONTH":
                dateExpression =
                        "DATEFROMPARTS(YEAR(o.created_at), " +
                        "MONTH(o.created_at), 1)";
                break;
            case "DAY":
            default:
                dateExpression = "CAST(o.created_at AS date)";
                break;
        }

        String sql =
                "SELECT " + dateExpression + " AS report_date, " +
                "COUNT(*) AS order_count, " +
                "COALESCE(SUM(o.final_amount), 0) AS revenue " +
                "FROM dbo.orders o " +
                "WHERE o.payment_status = 'PAID' " +
                "AND o.order_status = 'DELIVERED' " +
                "AND o.created_at >= ? " +
                "AND o.created_at < DATEADD(day, 1, ?) " +
                "GROUP BY " + dateExpression + " " +
                "ORDER BY report_date ASC";

        List<Map<String, Object>> results = new ArrayList<>();

        try (Connection connection = DBContext.getConnection();
             PreparedStatement statement =
                     connection.prepareStatement(sql)) {

            statement.setDate(1, startDate);
            statement.setDate(2, endDate);

            try (ResultSet rs = statement.executeQuery()) {
                while (rs.next()) {
                    Map<String, Object> row = new LinkedHashMap<>();

                    row.put("reportDate", rs.getDate("report_date"));
                    row.put("orderCount", rs.getInt("order_count"));
                    row.put("revenue", rs.getBigDecimal("revenue"));

                    results.add(row);
                }
            }
        }

        return results;
    }

    /**
     * Gets the best-selling books for a selected period.
     *
     * @param startDate inclusive start date
     * @param endDate inclusive end date
     * @param categoryId optional category filter; null means all categories
     * @param rankingMetric QUANTITY or REVENUE
     * @param limit maximum number of books to return
     * @return ranked book statistics
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

        int safeLimit = Math.max(1, Math.min(limit, 100));

        String sql =
                "SELECT TOP (?) " +
                "b.id AS book_id, " +
                "b.title AS book_title, " +
                "COALESCE((" +
                "   SELECT TOP 1 bi.image_url " +
                "   FROM dbo.book_images bi " +
                "   WHERE bi.book_id = b.id " +
                "   ORDER BY bi.is_thumbnail DESC, bi.display_order ASC" +
                "), '') AS cover_image, " +
                "COALESCE((" +
                "   SELECT STRING_AGG(c.name, ', ') " +
                "   FROM dbo.book_categories bc " +
                "   JOIN dbo.categories c ON c.id = bc.category_id " +
                "   WHERE bc.book_id = b.id " +
                "   AND c.is_deleted = 0" +
                "), '') AS category_names, " +
                "SUM(oi.quantity) AS total_quantity, " +
                "SUM(oi.subtotal) AS total_revenue " +
                "FROM dbo.order_items oi " +
                "JOIN dbo.orders o ON o.id = oi.order_id " +
                "JOIN dbo.books b ON b.id = oi.book_id " +
                "WHERE o.payment_status = 'PAID' " +
                "AND o.order_status = 'DELIVERED' " +
                "AND o.created_at >= ? " +
                "AND o.created_at < DATEADD(day, 1, ?) " +
                "AND b.is_deleted = 0 " +
                "AND (? IS NULL OR EXISTS (" +
                "   SELECT 1 " +
                "   FROM dbo.book_categories bc2 " +
                "   WHERE bc2.book_id = b.id " +
                "   AND bc2.category_id = ?" +
                ")) " +
                "GROUP BY b.id, b.title " +
                "ORDER BY " + orderBy + " DESC, b.title ASC";

        List<Map<String, Object>> results = new ArrayList<>();

        try (Connection connection = DBContext.getConnection();
             PreparedStatement statement =
                     connection.prepareStatement(sql)) {

            statement.setInt(1, safeLimit);
            statement.setDate(2, startDate);
            statement.setDate(3, endDate);

            if (categoryId == null) {
                statement.setNull(4, java.sql.Types.BIGINT);
                statement.setNull(5, java.sql.Types.BIGINT);
            } else {
                statement.setLong(4, categoryId);
                statement.setLong(5, categoryId);
            }

            try (ResultSet rs = statement.executeQuery()) {
                int rank = 1;

                while (rs.next()) {
                    Map<String, Object> row = new LinkedHashMap<>();

                    row.put("rank", rank++);
                    row.put("bookId", rs.getLong("book_id"));
                    row.put("bookTitle", rs.getString("book_title"));
                    row.put("coverImage", rs.getString("cover_image"));
                    row.put("categories", rs.getString("category_names"));
                    row.put("quantitySold", rs.getInt("total_quantity"));
                    row.put("revenue", rs.getBigDecimal("total_revenue"));

                    results.add(row);
                }
            }
        }

        return results;
    }

    /**
     * Gets total revenue for the selected period.
     */
    public BigDecimal getTotalRevenue(
            Date startDate,
            Date endDate) throws SQLException {

        String sql =
                "SELECT COALESCE(SUM(final_amount), 0) AS total_revenue " +
                "FROM dbo.orders " +
                "WHERE payment_status = 'PAID' " +
                "AND order_status = 'DELIVERED' " +
                "AND created_at >= ? " +
                "AND created_at < DATEADD(day, 1, ?)";

        try (Connection connection = DBContext.getConnection();
             PreparedStatement statement =
                     connection.prepareStatement(sql)) {

            statement.setDate(1, startDate);
            statement.setDate(2, endDate);

            try (ResultSet rs = statement.executeQuery()) {
                if (rs.next()) {
                    return rs.getBigDecimal("total_revenue");
                }
            }
        }

        return BigDecimal.ZERO;
    }
}
