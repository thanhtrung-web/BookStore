package com.bookstore.service;

import com.bookstore.dao.CartDAO;

import java.math.BigDecimal;
import java.sql.SQLException;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;

public class OrderService {

    private final CartDAO cartDAO = new CartDAO();
    private final VoucherService voucherService = new VoucherService();

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

            BigDecimal lineTotal = unitPrice.multiply(
                    BigDecimal.valueOf(quantity)
            );

            boolean stockWarning = quantity <= 0 || quantity > available;

            item.put("subtotal", lineTotal);
            item.put("stockWarning", stockWarning);

            subtotal = subtotal.add(lineTotal);
            totalQuantity += quantity;

            if (stockWarning) {
                stockValid = false;
            }
        }

        BigDecimal discount = BigDecimal.ZERO;
        Map<String, Object> voucher = null;
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
        checkout.put("discount", discount);
        checkout.put("finalAmount", subtotal.subtract(discount));
        checkout.put("voucher", voucher);
        checkout.put("voucherError", voucherError);
        checkout.put("stockValid", stockValid);

        return checkout;
    }

    public Map<String, String> validateRecipient(Map<String, String> form) {
        Map<String, String> errors = new LinkedHashMap<>();

        String recipientName = form.getOrDefault("recipientName", "");
        String phone = form.getOrDefault("phone", "");
        String shippingAddress = form.getOrDefault("shippingAddress", "");
        String note = form.getOrDefault("note", "");

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

        if (shippingAddress.isEmpty() || shippingAddress.length() > 255) {
            errors.put(
                    "shippingAddress",
                    "Nhập địa chỉ nhận hàng từ 1 đến 255 ký tự."
            );
        }

        if (note.length() > 500) {
            errors.put(
                    "note",
                    "Ghi chú không được vượt quá 500 ký tự."
            );
        }

        return errors;
    }
}