package com.bookstore.service;

import com.bookstore.dao.ReportDAO;

import java.math.BigDecimal;
import java.sql.Date;
import java.sql.SQLException;
import java.time.LocalDate;
import java.util.List;
import java.util.Map;

public class ReportService {

    private final ReportDAO reportDAO;

    public ReportService() {
        this.reportDAO = new ReportDAO();
    }

    /**
     * Ngày bắt đầu mặc định để lấy dữ liệu toàn bộ lịch sử.
     */
    public Date getDefaultStartDate() {
        return Date.valueOf(LocalDate.of(2000, 1, 1));
    }

    /**
     * Ngày kết thúc mặc định là ngày hiện tại.
     */
    public Date getDefaultEndDate() {
        return Date.valueOf(LocalDate.now());
    }

    /**
     * Lấy dữ liệu KPI cho Executive Dashboard.
     */
    public Map<String, Object> getDashboardSummary(
            Date startDate, Date endDate) throws SQLException {

        validateDateRange(startDate, endDate);
        return reportDAO.getDashboardSummary(startDate, endDate);
    }

    /**
     * Lấy doanh thu theo ngày, tuần hoặc tháng.
     */
    public List<Map<String, Object>> getRevenueReport(
            Date startDate, Date endDate, String groupBy) throws SQLException {

        validateDateRange(startDate, endDate);

        String normalizedGroupBy =
                groupBy == null ? "MONTH" : groupBy.trim().toUpperCase();

        if (!normalizedGroupBy.equals("DAY")
                && !normalizedGroupBy.equals("WEEK")
                && !normalizedGroupBy.equals("MONTH")) {
            normalizedGroupBy = "MONTH";
        }

        return reportDAO.getRevenueReport(
                startDate, endDate, normalizedGroupBy);
    }

    /**
     * Lấy top sách bán chạy.
     */
    public List<Map<String, Object>> getBestSellingBooks(
            Date startDate,
            Date endDate,
            Long categoryId,
            String rankingMetric,
            int limit) throws SQLException {

        validateDateRange(startDate, endDate);

        String normalizedMetric =
                rankingMetric == null
                        ? "QUANTITY"
                        : rankingMetric.trim().toUpperCase();

        if (!normalizedMetric.equals("QUANTITY")
                && !normalizedMetric.equals("REVENUE")) {
            normalizedMetric = "QUANTITY";
        }

        if (limit < 1 || limit > 100) {
            limit = 10;
        }

        return reportDAO.getBestSellingBooks(
                startDate,
                endDate,
                categoryId,
                normalizedMetric,
                limit);
    }

    public BigDecimal getTotalRevenue(
            Date startDate, Date endDate) throws SQLException {

        validateDateRange(startDate, endDate);

        BigDecimal revenue =
                reportDAO.getTotalRevenue(startDate, endDate);

        return revenue == null ? BigDecimal.ZERO : revenue;
    }

    private void validateDateRange(
            Date startDate, Date endDate) {

        if (startDate == null || endDate == null) {
            throw new IllegalArgumentException(
                    "Ngày bắt đầu và ngày kết thúc không được để trống.");
        }

        if (startDate.after(endDate)) {
            throw new IllegalArgumentException(
                    "Ngày bắt đầu không được lớn hơn ngày kết thúc.");
        }
    }
}