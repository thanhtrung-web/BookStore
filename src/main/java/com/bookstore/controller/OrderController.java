package com.bookstore.controller;

import com.bookstore.model.User;
import com.bookstore.service.OrderService;

import java.io.IOException;
import java.sql.SQLException;
import java.util.LinkedHashMap;
import java.util.Map;
import java.util.UUID;

import javax.servlet.ServletException;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

public class OrderController extends HttpServlet {

    private final OrderService orderService = new OrderService();

    @Override
    protected void doGet(HttpServletRequest request,
                         HttpServletResponse response)
            throws ServletException, IOException {

        User user = requireLogin(request, response);

        if (user == null) {
            return;
        }

        ensureToken(request.getSession());

        Map<String, String> form = new LinkedHashMap<>();
        form.put("recipientName", "");
        form.put("phone", "");
        form.put("shippingAddress", "");
        form.put("note", "");
        form.put("voucherCode", "");

        renderCheckout(request, response, user, form, false);
    }

    @Override
    protected void doPost(HttpServletRequest request,
                          HttpServletResponse response)
            throws ServletException, IOException {

        request.setCharacterEncoding("UTF-8");

        User user = requireLogin(request, response);

        if (user == null) {
            return;
        }

        HttpSession session = request.getSession();

        String expectedToken =
                (String) session.getAttribute("checkoutCsrfToken");
        String suppliedToken = request.getParameter("csrfToken");

        if (expectedToken == null || !expectedToken.equals(suppliedToken)) {
            response.sendError(
                    HttpServletResponse.SC_FORBIDDEN,
                    "Phiên thao tác không hợp lệ. Vui lòng mở lại trang xác nhận."
            );
            return;
        }

        Map<String, String> form = new LinkedHashMap<>();
        form.put("recipientName", readValue(request, "recipientName"));
        form.put("phone", readValue(request, "phone"));
        form.put("shippingAddress", readValue(request, "shippingAddress"));
        form.put("note", readValue(request, "note"));
        form.put("voucherCode", readValue(request, "voucherCode"));

        String action = request.getParameter("action");

        if (!"review".equals(action)
                && !"applyVoucher".equals(action)
                && !"removeVoucher".equals(action)) {

            response.sendError(
                    HttpServletResponse.SC_BAD_REQUEST,
                    "Thao tác không hợp lệ."
            );
            return;
        }

        if ("removeVoucher".equals(action)) {
            form.put("voucherCode", "");
        }

        if ("applyVoucher".equals(action)
                && form.get("voucherCode").isEmpty()) {

            request.setAttribute(
                    "errorMessage",
                    "Vui lòng nhập mã giảm giá."
            );
        }

        renderCheckout(
                request,
                response,
                user,
                form,
                "review".equals(action)
        );
    }

    private void renderCheckout(HttpServletRequest request,
                                HttpServletResponse response,
                                User user,
                                Map<String, String> form,
                                boolean review)
            throws ServletException, IOException {

        response.setHeader("Cache-Control", "no-store");
        response.setContentType("text/html;charset=UTF-8");

        request.setAttribute("pageTitle", "Xác nhận đặt hàng - BookStore");
        request.setAttribute("form", form);

        try {
            Map<String, Object> checkout = orderService.getCheckout(
                    user.getId(),
                    form.get("voucherCode")
            );

            request.setAttribute("checkout", checkout);
            request.setAttribute("checkoutLoaded", true);

            request.getSession().setAttribute(
                    "cartCount",
                    checkout.get("totalQuantity")
            );

            if (review) {
                Map<String, String> errors =
                        orderService.validateRecipient(form);

                request.setAttribute("errors", errors);

                if (!Boolean.TRUE.equals(checkout.get("stockValid"))) {
                    request.setAttribute(
                            "errorMessage",
                            "Giỏ hàng trống hoặc có sách không đủ tồn kho. "
                                    + "Vui lòng quay lại giỏ hàng để điều chỉnh."
                    );

                } else if (checkout.get("voucherError") != null) {
                    request.setAttribute(
                            "errorMessage",
                            "Vui lòng sửa hoặc bỏ mã giảm giá không hợp lệ."
                    );

                } else if (errors.isEmpty()) {
                    request.setAttribute("reviewReady", true);
                }
            }

        } catch (SQLException e) {
            getServletContext().log("Could not load checkout.", e);

            response.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);

            request.setAttribute(
                    "errorMessage",
                    "Không tải được thông tin đặt hàng. Vui lòng thử lại sau."
            );
        }

        request.getRequestDispatcher("/WEB-INF/views/checkout.jsp")
                .forward(request, response);
    }

    private String readValue(HttpServletRequest request, String name) {
        String value = request.getParameter(name);
        return value == null ? "" : value.trim();
    }

    private User requireLogin(HttpServletRequest request,
                              HttpServletResponse response)
            throws IOException {

        HttpSession session = request.getSession(false);

        Object authUser =
                session == null ? null : session.getAttribute("authUser");

        if (authUser instanceof User) {
            User user = (User) authUser;

            if (user.getId() != null && user.getId() > 0) {
                return user;
            }
        }

        response.sendRedirect(request.getContextPath() + "/login");
        return null;
    }

    private void ensureToken(HttpSession session) {
        synchronized (session) {
            if (session.getAttribute("checkoutCsrfToken") == null) {
                session.setAttribute(
                        "checkoutCsrfToken",
                        UUID.randomUUID().toString()
                );
            }
        }
    }
}