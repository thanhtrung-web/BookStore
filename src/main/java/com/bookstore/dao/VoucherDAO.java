
package com.bookstore.dao;

import com.bookstore.context.DBContext;
import java.math.BigDecimal;
import java.math.RoundingMode;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;

/**
 * Provides database operations for vouchers and checkout cart items.
 */
public class VoucherDAO {

    /**
     * Finds a voucher by its code.
     *
     * @param code the voucher code
     * @return voucher information, or null if not found
     * @throws SQLException if a database error occurs
     */
    public Map<String, Object> findVoucherByCode(String code)
            throws SQLException {

        String sql = "SELECT id, code, discount_type, discount_value, "
                + "min_order_amount, max_discount_amount, usage_limit, "
                + "used_count, start_date, end_date, status "
                + "FROM dbo.vouchers "
                + "WHERE UPPER(code) = UPPER(?) AND is_deleted = 0";

        try (Connection connection = DBContext.getConnection();
             PreparedStatement statement = connection.prepareStatement(sql)) {

            statement.setString(1, code.trim());

            try (ResultSet result = statement.executeQuery()) {
                if (!result.next()) {
                    return null;
                }

                Map<String, Object> voucher = new LinkedHashMap<>();
                voucher.put("id", result.getLong("id"));
                voucher.put("code", result.getString("code"));
                voucher.put("discountType", result.getString("discount_type"));
                voucher.put("discountValue", result.getBigDecimal("discount_value"));
                voucher.put("minOrderAmount", result.getBigDecimal("min_order_amount"));
                voucher.put("maxDiscountAmount", result.getBigDecimal("max_discount_amount"));
                voucher.put("usageLimit", result.getInt("usage_limit"));
                voucher.put("usedCount", result.getInt("used_count"));
                voucher.put("startDate", result.getTimestamp("start_date"));
                voucher.put("endDate", result.getTimestamp("end_date"));
                voucher.put("status", result.getString("status"));

                return voucher;
            }
        }
    }

    /**
     * Retrieves active cart items for a buyer.
     *
     * @param userId the buyer ID
     * @return the buyer's cart items
     * @throws SQLException if a database error occurs
     */
    public List<Map<String, Object>> findCartItems(long userId)
            throws SQLException {

        String sql = "SELECT b.id AS bookId, b.title, b.price, "
                + "b.discount_percent, ci.quantity "
                + "FROM dbo.carts c "
                + "JOIN dbo.cart_items ci ON ci.cart_id = c.id "
                + "JOIN dbo.books b ON b.id = ci.book_id "
                + "WHERE c.user_id = ? AND b.is_deleted = 0 "
                + "AND b.status = 'ACTIVE'";

        List<Map<String, Object>> items = new ArrayList<>();

        try (Connection connection = DBContext.getConnection();
             PreparedStatement statement = connection.prepareStatement(sql)) {

            statement.setLong(1, userId);

            try (ResultSet result = statement.executeQuery()) {
                while (result.next()) {
                    BigDecimal price = result.getBigDecimal("price");
                    int discountPercent = result.getInt("discount_percent");
                    int quantity = result.getInt("quantity");

                    BigDecimal unitPrice = price.multiply(
                            BigDecimal.valueOf(100 - discountPercent))
                            .divide(BigDecimal.valueOf(100), 2,
                                    RoundingMode.HALF_UP);

                    Map<String, Object> item = new LinkedHashMap<>();
                    item.put("bookId", result.getLong("bookId"));
                    item.put("title", result.getString("title"));
                    item.put("quantity", quantity);
                    item.put("unitPrice", unitPrice);
                    item.put("subtotal", unitPrice.multiply(
                            BigDecimal.valueOf(quantity)));

                    items.add(item);
                }
            }
        }

        return items;
    }

    /**
     * Calculates the subtotal of a buyer's cart.
     *
     * @param userId the buyer ID
     * @return the cart subtotal
     * @throws SQLException if a database error occurs
     */
    public BigDecimal calculateCartSubtotal(long userId)
            throws SQLException {

        String sql = "SELECT COALESCE(SUM("
                + "b.price * (100 - b.discount_percent) / 100.0 * ci.quantity"
                + "), 0) AS subtotal "
                + "FROM dbo.carts c "
                + "JOIN dbo.cart_items ci ON ci.cart_id = c.id "
                + "JOIN dbo.books b ON b.id = ci.book_id "
                + "WHERE c.user_id = ? AND b.is_deleted = 0 "
                + "AND b.status = 'ACTIVE'";

        try (Connection connection = DBContext.getConnection();
             PreparedStatement statement = connection.prepareStatement(sql)) {

            statement.setLong(1, userId);

            try (ResultSet result = statement.executeQuery()) {
                if (result.next()) {
                    BigDecimal subtotal = result.getBigDecimal("subtotal");
                    return subtotal.setScale(2, RoundingMode.HALF_UP);
                }
            }
        }

        return BigDecimal.ZERO;
    }
}
