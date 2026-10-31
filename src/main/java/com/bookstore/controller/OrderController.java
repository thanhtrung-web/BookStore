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

        ensureTokens(request.getSession());

        Map<String, String> form = new LinkedHashMap<>();
        form.put("recipientName", "");
        form.put("phone", "");
        form.put("shippingAddress", "");
        form.put("note", "");
        form.put("voucherCode", "");

        renderCheckout(request, response, user, form);
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

        String expectedCsrf =
                (String) session.getAttribute("checkoutCsrfToken");
        String suppliedCsrf = request.getParameter("csrfToken");

        if (expectedCsrf == null || !expectedCsrf.equals(suppliedCsrf)) {
            response.sendError(
                    HttpServletResponse.SC_FORBIDDEN,
                    "Phiên thao tác không hợp lệ. Vui lòng mở lại trang."
            );
            return;
        }

        Map<String, String> form = readForm(request);
        String action = request.getParameter("action");

        if ("removeVoucher".equals(action)) {
            form.put("voucherCode", "");
            renderCheckout(request, response, user, form);
            return;
        }

        if ("applyVoucher".equals(action)) {
            if (form.get("voucherCode").isEmpty()) {
                request.setAttribute(
                        "errorMessage", "Vui lòng nhập mã giảm giá."
                );
            }

            renderCheckout(request, response, user, form);
            return;
        }

        if (!"placeOrder".equals(action)) {
            response.sendError(
                    HttpServletResponse.SC_BAD_REQUEST,
                    "Thao tác không hợp lệ."
            );
            return;
        }

        String suppliedToken = request.getParameter("orderToken");

        synchronized (session) {
            String completedToken =
                    (String) session.getAttribute("completedOrderToken");

            if (suppliedToken != null && suppliedToken.equals(completedToken)) {
                session.setAttribute(
                        "cartSuccess",
                        "Đơn hàng đã được ghi nhận. Mã đơn: "
                                + session.getAttribute("completedOrderCode")
                );

                response.sendRedirect(request.getContextPath() + "/cart");
                return;
            }

            String expectedToken =
                    (String) session.getAttribute("orderRequestToken");

            if (expectedToken == null
                    || !expectedToken.equals(suppliedToken)) {

                response.sendError(
                        HttpServletResponse.SC_CONFLICT,
                        "Phiên đặt hàng đã thay đổi. Vui lòng mở lại trang."
                );
                return;
            }

            Map<String, String> errors =
                    orderService.validateRecipient(form);

            if (!errors.isEmpty()) {
                request.setAttribute("errors", errors);
                request.setAttribute(
                        "errorMessage",
                        "Vui lòng kiểm tra lại thông tin nhận hàng."
                );
            } else {
                try {
                    String orderCode = orderService.placeOrder(
                            user.getId(), suppliedToken, form
                    );

                    session.setAttribute("completedOrderToken", suppliedToken);
                    session.setAttribute("completedOrderCode", orderCode);
                    session.removeAttribute("orderRequestToken");
                    session.removeAttribute("appliedVoucher");
                    session.setAttribute("cartCount", 0L);
                    session.removeAttribute("cartError");
                    session.setAttribute(
                            "cartSuccess",
                            "Đặt hàng thành công. Mã đơn: " + orderCode
                    );

                    response.sendRedirect(
                            request.getContextPath() + "/cart"
                    );
                    return;

                } catch (IllegalArgumentException e) {
                    request.setAttribute("errorMessage", e.getMessage());

                } catch (SQLException e) {
                    getServletContext().log("Could not place order.", e);

                    request.setAttribute(
                            "errorMessage",
                            "Chưa thể xác nhận kết quả đặt hàng. "
                                    + "Vui lòng thử lại trên trang này."
                    );
                }
            }
        }

        renderCheckout(request, response, user, form);
    }

    private void renderCheckout(HttpServletRequest request,
                                HttpServletResponse response,
                                User user,
                                Map<String, String> form)
            throws ServletException, IOException {

        response.setHeader("Cache-Control", "no-store");
        response.setContentType("text/html;charset=UTF-8");

        request.setAttribute("pageTitle", "Xác nhận đặt hàng - BookStore");
        request.setAttribute("form", form);

        try {
            Map<String, Object> checkout = orderService.getCheckout(
                    user.getId(), form.get("voucherCode")
            );

            request.setAttribute("checkout", checkout);
            request.setAttribute("checkoutLoaded", true);

            request.getSession().setAttribute(
                    "cartCount", checkout.get("totalQuantity")
            );

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

    private Map<String, String> readForm(HttpServletRequest request) {
        Map<String, String> form = new LinkedHashMap<>();

        form.put("recipientName", readValue(request, "recipientName"));
        form.put("phone", readValue(request, "phone"));
        form.put("shippingAddress", readValue(request, "shippingAddress"));
        form.put("note", readValue(request, "note"));
        form.put("voucherCode", readValue(request, "voucherCode"));

        return form;
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

    private void ensureTokens(HttpSession session) {
        synchronized (session) {
            if (session.getAttribute("checkoutCsrfToken") == null) {
                session.setAttribute(
                        "checkoutCsrfToken",
                        UUID.randomUUID().toString()
                );
            }

            if (session.getAttribute("orderRequestToken") == null) {
                session.setAttribute(
                        "orderRequestToken",
                        UUID.randomUUID().toString()
                );
            }
        }
    }
}