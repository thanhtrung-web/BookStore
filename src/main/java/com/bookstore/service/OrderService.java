package com.bookstore.service;

import com.bookstore.dao.CartDAO;
import com.bookstore.dao.OrderDAO;

import java.math.BigDecimal;
import java.sql.SQLException;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;
import java.util.UUID;

public class OrderService {

    private static final BigDecimal SHIPPING_FEE = new BigDecimal("0.00");

    private final CartDAO cartDAO = new CartDAO();
    private final OrderDAO orderDAO = new OrderDAO();
    private final VoucherService voucherService = new VoucherService();
public Map<String, Object> getOrderDetails(long userId, String orderCode)
        throws SQLException {

    if (userId <= 0 || orderCode == null) {
        return null;
    }

    String normalizedCode = orderCode.trim();

    if (!normalizedCode.matches("BS-[0-9a-fA-F]{32}")) {
        return null;
    }

    return orderDAO.findOrderByCode(userId, normalizedCode);
}
    public Map<String, Object> getCheckout(long userId, String voucherCode)
            throws SQLException {

        List<Map<String, Object>> items = cartDAO.findItems(userId);

        BigDecimal subtotal = BigDecimal.ZERO;
        long totalQuantity = 0;
        boolean stockValid = !items.isEmpty();

        for (Map<String, Object> item : items) {
            int quantity = ((Number) item.get("quantity")).intValue();
            int available = ((Number) item.get("available")).intValue();
            BigDecimal unitPrice = (BigDecimal) item.get("unitPrice");

            BigDecimal lineTotal =
                    unitPrice.multiply(BigDecimal.valueOf(quantity));

            boolean stockWarning = quantity <= 0 || quantity > available;

            item.put("subtotal", lineTotal);
            item.put("stockWarning", stockWarning);

            subtotal = subtotal.add(lineTotal);
            totalQuantity += quantity;

            if (stockWarning) {
                stockValid = false;
            }
        }

        Map<String, Object> voucher = null;
        BigDecimal discount = BigDecimal.ZERO;
        String voucherError = null;

        if (voucherCode != null && !voucherCode.trim().isEmpty()) {
            try {
                voucher = voucherService.applyVoucher(
                        voucherCode.trim(), subtotal
                );

                discount = (BigDecimal) voucher.get("discountAmount");

            } catch (IllegalArgumentException e) {
                voucherError = e.getMessage();
            }
        }

        Map<String, Object> checkout = new LinkedHashMap<>();

        checkout.put("items", items);
        checkout.put("subtotal", subtotal);
        checkout.put("totalQuantity", totalQuantity);
        checkout.put("shippingFee", SHIPPING_FEE);
        checkout.put("discount", discount);
        checkout.put(
                "finalAmount",
                subtotal.subtract(discount).add(SHIPPING_FEE)
        );
        checkout.put("voucher", voucher);
        checkout.put("voucherError", voucherError);
        checkout.put("stockValid", stockValid);

        return checkout;
    }

    public Map<String, String> validateRecipient(Map<String, String> form) {
        Map<String, String> errors = new LinkedHashMap<>();

        String recipientName = form.getOrDefault("recipientName", "");
        String phone = form.getOrDefault("phone", "");
        String address = form.getOrDefault("shippingAddress", "");
        String note = form.getOrDefault("note", "");
        String voucherCode = form.getOrDefault("voucherCode", "");

        if (recipientName.isEmpty() || recipientName.length() > 100) {
            errors.put(
                    "recipientName",
                    "Nhập tên người nhận từ 1 đến 100 ký tự."
            );
        }

        if (!phone.matches("(0[0-9]{9}|\\+84[0-9]{9})")) {
            errors.put(
                    "phone",
                    "Nhập 10 chữ số bắt đầu bằng 0, hoặc số dạng +84."
            );
        }

        if (address.isEmpty() || address.length() > 255) {
            errors.put(
                    "shippingAddress",
                    "Nhập địa chỉ nhận hàng từ 1 đến 255 ký tự."
            );
        }

        if (note.length() > 500) {
            errors.put("note", "Ghi chú không được vượt quá 500 ký tự.");
        }

        if (voucherCode.length() > 50) {
            errors.put(
                    "voucherCode",
                    "Mã giảm giá không được vượt quá 50 ký tự."
            );
        }

        return errors;
    }

    public String placeOrder(long userId,
                             String requestToken,
                             Map<String, String> form) throws SQLException {

        if (userId <= 0) {
            throw new IllegalArgumentException("Vui lòng đăng nhập lại.");
        }

        Map<String, String> errors = validateRecipient(form);

        if (!errors.isEmpty()) {
            throw new IllegalArgumentException(
                    errors.values().iterator().next()
            );
        }

        String normalizedToken;

        try {
            normalizedToken = UUID.fromString(requestToken).toString();
        } catch (IllegalArgumentException | NullPointerException e) {
            throw new IllegalArgumentException(
                    "Phiên đặt hàng không hợp lệ. Vui lòng mở lại trang."
            );
        }

        String orderCode = "BS-" + normalizedToken.replace("-", "");

        return orderDAO.placeOrder(
                userId, orderCode, form, SHIPPING_FEE
        );
    }
}