
package com.bookstore.service;

import com.bookstore.dao.VoucherDAO;
import java.math.BigDecimal;
import java.math.RoundingMode;
import java.sql.SQLException;
import java.sql.Timestamp;
import java.util.Map;

/**
 * Validates vouchers and calculates checkout discounts.
 */
public class VoucherService {

    private final VoucherDAO voucherDAO;

    /**
     * Creates the voucher service.
     */
    public VoucherService() {
        this.voucherDAO = new VoucherDAO();
    }

    /**
     * Validates a voucher and calculates the discount.
     *
     * @param code the voucher code
     * @param subtotal the cart subtotal
     * @return voucher information with calculated amounts
     * @throws SQLException if a database error occurs
     * @throws IllegalArgumentException if the voucher is invalid
     */
    public Map<String, Object> applyVoucher(String code, BigDecimal subtotal)
            throws SQLException {

        if (code == null || code.trim().isEmpty()) {
            throw new IllegalArgumentException("Vui lòng nhập mã giảm giá.");
        }

        if (subtotal == null || subtotal.compareTo(BigDecimal.ZERO) <= 0) {
            throw new IllegalArgumentException("Giỏ hàng của bạn đang trống.");
        }

        Map<String, Object> voucher = voucherDAO.findVoucherByCode(code);

        if (voucher == null) {
            throw new IllegalArgumentException("Mã giảm giá không tồn tại.");
        }

        if (!"ACTIVE".equalsIgnoreCase((String) voucher.get("status"))) {
            throw new IllegalArgumentException("Mã giảm giá hiện không hoạt động.");
        }

        Timestamp now = new Timestamp(System.currentTimeMillis());
        Timestamp startDate = (Timestamp) voucher.get("startDate");
        Timestamp endDate = (Timestamp) voucher.get("endDate");

        if (startDate == null || endDate == null
                || now.before(startDate) || now.after(endDate)) {
            throw new IllegalArgumentException(
                    "Mã giảm giá chưa có hiệu lực hoặc đã hết hạn.");
        }

        int usageLimit = (Integer) voucher.get("usageLimit");
        int usedCount = (Integer) voucher.get("usedCount");

        if (usedCount >= usageLimit) {
            throw new IllegalArgumentException(
                    "Mã giảm giá đã hết lượt sử dụng.");
        }

        BigDecimal minimum = (BigDecimal) voucher.get("minOrderAmount");

        if (subtotal.compareTo(minimum) < 0) {
            throw new IllegalArgumentException(
                    "Đơn hàng chưa đạt giá trị tối thiểu để áp dụng mã.");
        }

        BigDecimal discountValue = (BigDecimal) voucher.get("discountValue");
        BigDecimal discount;
        String discountType = (String) voucher.get("discountType");

        if ("PERCENT".equalsIgnoreCase(discountType)) {
            discount = subtotal.multiply(discountValue)
                    .divide(BigDecimal.valueOf(100), 2, RoundingMode.HALF_UP);

            BigDecimal maxDiscount =
                    (BigDecimal) voucher.get("maxDiscountAmount");

            if (maxDiscount != null && discount.compareTo(maxDiscount) > 0) {
                discount = maxDiscount;
            }
        } else if ("FIXED_AMOUNT".equalsIgnoreCase(discountType)) {
            discount = discountValue.min(subtotal);
        } else {
            throw new IllegalArgumentException(
                    "Loại mã giảm giá không hợp lệ.");
        }

        discount = discount.min(subtotal)
                .setScale(2, RoundingMode.HALF_UP);

        voucher.put("discountAmount", discount);
        voucher.put("subtotal", subtotal);
        voucher.put("finalAmount", subtotal.subtract(discount));

        return voucher;
    }

    /**
     * Retrieves the subtotal of a buyer's cart.
     *
     * @param userId the buyer ID
     * @return the cart subtotal
     * @throws SQLException if a database error occurs
     */
    public BigDecimal getCartSubtotal(long userId) throws SQLException {
        return voucherDAO.calculateCartSubtotal(userId);
    }
}
