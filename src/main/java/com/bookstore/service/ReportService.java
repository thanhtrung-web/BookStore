
package com.bookstore.service;

import com.bookstore.dao.ReportDAO;

import java.math.BigDecimal;
import java.sql.Date;
import java.sql.SQLException;
import java.util.List;
import java.util.Map;

/**
 * Handles business logic for revenue and best-selling book reports.
 */
public class ReportService {

    private final ReportDAO reportDAO;

    public ReportService() {
        this.reportDAO = new ReportDAO();
    }

    /**
     * Gets revenue statistics grouped by day, week, or month.
     */
    public List<Map<String, Object>> getRevenueReport(
            Date startDate,
            Date endDate,
            String groupBy) throws SQLException {

        validateDateRange(startDate, endDate);

        String normalizedGroupBy =
                groupBy == null ? "DAY" : groupBy.trim().toUpperCase();

        if (!normalizedGroupBy.equals("DAY")
                && !normalizedGroupBy.equals("WEEK")
                && !normalizedGroupBy.equals("MONTH")) {
            normalizedGroupBy = "DAY";
        }

        return reportDAO.getRevenueReport(
                startDate, endDate, normalizedGroupBy);
    }

    /**
     * Gets the top-selling books for a selected period.
     *
     * @param categoryId null means all categories
     * @param rankingMetric QUANTITY or REVENUE
     * @param limit maximum number of books
     */
    public List<Map<String, Object>> getBestSellingBooks(
            Date startDate,
            Date endDate,
            Long categoryId,
            String rankingMetric,
            int limit) throws SQLException {

        validateDateRange(startDate, endDate);

        if (categoryId != null && categoryId <= 0) {
            throw new IllegalArgumentException(
                    "Category ID must be greater than zero.");
        }

        String normalizedMetric = rankingMetric == null
                ? "QUANTITY"
                : rankingMetric.trim().toUpperCase();

        if (!normalizedMetric.equals("QUANTITY")
                && !normalizedMetric.equals("REVENUE")) {
            normalizedMetric = "QUANTITY";
        }

        int safeLimit = Math.max(1, Math.min(limit, 100));

        return reportDAO.getBestSellingBooks(
                startDate,
                endDate,
                categoryId,
                normalizedMetric,
                safeLimit);
    }

    /**
     * Gets total revenue for a selected period.
     */
    public BigDecimal getTotalRevenue(
            Date startDate,
            Date endDate) throws SQLException {

        validateDateRange(startDate, endDate);

        BigDecimal total = reportDAO.getTotalRevenue(
                startDate, endDate);

        return total == null ? BigDecimal.ZERO : total;
    }

    /**
     * Validates the selected date range.
     */
    private void validateDateRange(Date startDate, Date endDate) {
        if (startDate == null || endDate == null) {
            throw new IllegalArgumentException(
                    "Start date and end date are required.");
        }

        if (startDate.after(endDate)) {
            throw new IllegalArgumentException(
                    "Start date must not be after end date.");
        }
    }
}
