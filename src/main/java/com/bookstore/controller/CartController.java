package com.bookstore.controller;

import com.bookstore.model.User;
import com.bookstore.service.CartService;

import java.io.IOException;
import java.sql.SQLException;
import java.util.Map;
import java.util.UUID;

import javax.servlet.ServletException;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

public class CartController extends HttpServlet {

    private final CartService cartService = new CartService();

    @Override
    protected void doGet(HttpServletRequest request,
                         HttpServletResponse response)
            throws ServletException, IOException {

        User user = requireLogin(request, response);

        if (user == null) {
            return;
        }

        response.setHeader("Cache-Control", "no-store");
        response.setContentType("text/html;charset=UTF-8");

        HttpSession session = request.getSession();
        ensureToken(session);

        request.setAttribute("pageTitle", "Giỏ hàng - BookStore");

        synchronized (session) {
            request.setAttribute(
                    "successMessage",
                    session.getAttribute("cartSuccess")
            );
            request.setAttribute(
                    "errorMessage",
                    session.getAttribute("cartError")
            );

            session.removeAttribute("cartSuccess");
            session.removeAttribute("cartError");
            boolean buyNowSuccess = false;
        }

        try {
            Map<String, Object> cart = cartService.getCart(user.getId());

            request.setAttribute("cart", cart);
            request.setAttribute("books", cartService.getBooks());
            request.setAttribute("cartLoaded", true);

            session.setAttribute("cartCount", cart.get("totalQuantity"));

        } catch (SQLException e) {
            getServletContext().log("Could not load cart.", e);

            response.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
            request.setAttribute(
                    "errorMessage",
                    "Không tải được giỏ hàng. Vui lòng thử lại sau."
            );
        }

        request.getRequestDispatcher("/WEB-INF/views/cart.jsp")
                .forward(request, response);
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
        String expectedToken = (String) session.getAttribute("cartCsrfToken");
        String suppliedToken = request.getParameter("csrfToken");

        if (expectedToken == null || !expectedToken.equals(suppliedToken)) {
            response.sendError(
                    HttpServletResponse.SC_FORBIDDEN,
                    "Phiên thao tác không hợp lệ. Vui lòng mở lại giỏ hàng."
            );
            return;
        }

        session.removeAttribute("cartSuccess");
        session.removeAttribute("cartError");
        boolean buyNowSuccess = false;


        try {
            String action = request.getParameter("action");
            String successMessage;

            
if ("/cart/add".equals(request.getServletPath())) {
    cartService.addToCart(
            user.getId(),
            request.getParameter("bookId"),
            request.getParameter("quantity")
    );

    buyNowSuccess = "true".equals(
            request.getParameter("buyNow")
    );

    successMessage = "Đã thêm sách vào giỏ hàng.";


            } else if ("update".equals(action)) {
                cartService.updateQuantity(
                        user.getId(),
                        request.getParameter("itemId"),
                        request.getParameter("quantity")
                );

                successMessage = "Đã cập nhật số lượng sách.";

            } else if ("remove".equals(action)) {
                cartService.removeItem(
                        user.getId(),
                        request.getParameter("itemId")
                );

                successMessage = "Đã xóa sách khỏi giỏ hàng.";

            } else {
                throw new IllegalArgumentException(
                        "Thao tác giỏ hàng không hợp lệ."
                );
            }

            session.setAttribute("cartSuccess", successMessage);

        } catch (IllegalArgumentException e) {
            session.setAttribute("cartError", e.getMessage());

        } catch (SQLException e) {
            getServletContext().log("Could not modify cart.", e);

            session.setAttribute(
                    "cartError",
                    "Không thể cập nhật giỏ hàng lúc này. Vui lòng thử lại sau."
            );
        }

        if (buyNowSuccess) {
    response.sendRedirect(
            request.getContextPath() + "/order/checkout"
    );
} else {
    response.sendRedirect(
            request.getContextPath() + "/cart"
    );
}
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
            if (session.getAttribute("cartCsrfToken") == null) {
                session.setAttribute(
                        "cartCsrfToken",
                        UUID.randomUUID().toString()
                );
            }
        }
    }
}