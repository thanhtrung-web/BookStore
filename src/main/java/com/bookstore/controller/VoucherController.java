
package com.bookstore.controller;

import com.bookstore.dao.VoucherDAO;
import com.bookstore.model.User;
import com.bookstore.service.VoucherService;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import java.io.IOException;
import java.math.BigDecimal;
import java.sql.SQLException;
import java.util.List;
import java.util.Map;

/**
 * Handles checkout requests and voucher application.
 */
@WebServlet(name = "VoucherController", urlPatterns = {"/checkout"})
public class VoucherController extends HttpServlet {

    private static final long serialVersionUID = 1L;
    private static final String SESSION_VOUCHER = "appliedVoucher";

    private VoucherService voucherService;
    private VoucherDAO voucherDAO;

    /**
     * Initializes checkout dependencies.
     *
     * @throws ServletException if initialization fails
     */
    @Override
    public void init() throws ServletException {
        voucherService = new VoucherService();
        voucherDAO = new VoucherDAO();
    }

    /**
     * Displays the checkout page.
     *
     * @param request HTTP request
     * @param response HTTP response
     * @throws ServletException if forwarding fails
     * @throws IOException if an I/O error occurs
     */
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        showCheckout(request, response);
    }

    /**
     * Applies or removes a voucher.
     *
     * @param request HTTP request
     * @param response HTTP response
     * @throws ServletException if forwarding fails
     * @throws IOException if an I/O error occurs
     */
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        request.setCharacterEncoding("UTF-8");

        HttpSession session = request.getSession(false);
        User user = session == null
                ? null : (User) session.getAttribute("authUser");

        if (user == null || user.getId() == null) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }

        String action = request.getParameter("action");

        if ("remove".equalsIgnoreCase(action)) {
            session.removeAttribute(SESSION_VOUCHER);
            session.setAttribute("voucherMessage", "Đã bỏ mã giảm giá.");
            session.setAttribute("voucherMessageType", "success");
            response.sendRedirect(request.getContextPath() + "/checkout");
            return;
        }

        try {
            BigDecimal subtotal = voucherService.getCartSubtotal(user.getId());

            Map<String, Object> voucher = voucherService.applyVoucher(
                    request.getParameter("voucherCode"), subtotal);

            session.setAttribute(SESSION_VOUCHER, voucher);
            session.setAttribute("voucherMessage",
                    "Áp dụng mã giảm giá thành công.");
            session.setAttribute("voucherMessageType", "success");

        } catch (IllegalArgumentException ex) {
            session.removeAttribute(SESSION_VOUCHER);
            session.setAttribute("voucherMessage", ex.getMessage());
            session.setAttribute("voucherMessageType", "error");

        } catch (SQLException ex) {
            session.removeAttribute(SESSION_VOUCHER);
            session.setAttribute("voucherMessage",
                    "Không thể kiểm tra mã giảm giá lúc này.");
            session.setAttribute("voucherMessageType", "error");
            getServletContext().log("Unable to apply checkout voucher.", ex);
        }

        response.sendRedirect(request.getContextPath() + "/checkout");
    }

    /**
     * Loads cart items and voucher information for checkout.
     *
     * @param request HTTP request
     * @param response HTTP response
     * @throws ServletException if forwarding fails
     * @throws IOException if an I/O error occurs
     */
    private void showCheckout(HttpServletRequest request,
            HttpServletResponse response) throws ServletException, IOException {

        HttpSession session = request.getSession(false);
        User user = session == null
                ? null : (User) session.getAttribute("authUser");

        if (user == null || user.getId() == null) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }

        try {
            List<Map<String, Object>> cartItems =
                    voucherDAO.findCartItems(user.getId());

            BigDecimal subtotal = voucherService.getCartSubtotal(user.getId());
            BigDecimal discount = BigDecimal.ZERO;

            @SuppressWarnings("unchecked")
            Map<String, Object> appliedVoucher =
                    (Map<String, Object>) session.getAttribute(SESSION_VOUCHER);

            if (appliedVoucher != null) {
                try {
                    appliedVoucher = voucherService.applyVoucher(
                            (String) appliedVoucher.get("code"), subtotal);

                    session.setAttribute(SESSION_VOUCHER, appliedVoucher);
                    discount = (BigDecimal) appliedVoucher.get("discountAmount");

                } catch (IllegalArgumentException ex) {
                    session.removeAttribute(SESSION_VOUCHER);
                    appliedVoucher = null;
                    session.setAttribute("voucherMessage", ex.getMessage());
                    session.setAttribute("voucherMessageType", "error");
                }
            }

            request.setAttribute("cartItems", cartItems);
            request.setAttribute("subtotal", subtotal);
            request.setAttribute("discount", discount);
            request.setAttribute("finalAmount", subtotal.subtract(discount));
            request.setAttribute("appliedVoucher", appliedVoucher);

            request.setAttribute("voucherMessage",
                    session.getAttribute("voucherMessage"));
            request.setAttribute("voucherMessageType",
                    session.getAttribute("voucherMessageType"));

            session.removeAttribute("voucherMessage");
            session.removeAttribute("voucherMessageType");

            request.getRequestDispatcher("/views/checkout.jsp")
                    .forward(request, response);

        } catch (SQLException ex) {
            getServletContext().log("Unable to load checkout page.", ex);
            response.sendError(HttpServletResponse.SC_INTERNAL_SERVER_ERROR,
                    "Unable to load checkout information.");
        }
    }
}
