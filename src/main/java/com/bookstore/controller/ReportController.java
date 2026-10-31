package com.bookstore.controller;

import com.bookstore.service.ReportService;

import java.sql.Date;
import java.sql.SQLException;
import java.util.List;
import java.util.Map;

import javax.servlet.http.HttpServletRequest;

public class ReportController {

    private final ReportService reportService;

    public ReportController() {
        this.reportService = new ReportService();
    }

    /**
     * Nạp dữ liệu báo cáo vào request để dashboard.jsp sử dụng.
     */
    public void loadDashboardReport(HttpServletRequest request) {

        Date startDate = reportService.getDefaultStartDate();
        Date endDate = reportService.getDefaultEndDate();

        try {
            Map<String, Object> summary =
                    reportService.getDashboardSummary(startDate, endDate);

            List<Map<String, Object>> topBooks =
                    reportService.getBestSellingBooks(
                            startDate,
                            endDate,
                            null,
                            "REVENUE",
                            5
                    );

            List<Map<String, Object>> revenueReport =
                    reportService.getRevenueReport(
                            startDate,
                            endDate,
                            "MONTH"
                    );

            request.setAttribute("reportSummary", summary);
            request.setAttribute("topBooks", topBooks);
            request.setAttribute("revenueReport", revenueReport);

            request.setAttribute("reportStartDate", startDate);
            request.setAttribute("reportEndDate", endDate);

            request.setAttribute("reportError", null);

        } catch (SQLException | IllegalArgumentException e) {
            e.printStackTrace();

            request.setAttribute("reportSummary", null);
            request.setAttribute("topBooks", java.util.Collections.emptyList());
            request.setAttribute("revenueReport", java.util.Collections.emptyList());

            request.setAttribute(
                    "reportError",
                    "Không thể tải dữ liệu báo cáo. Vui lòng kiểm tra kết nối cơ sở dữ liệu."
            );
        }
    }
}