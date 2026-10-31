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

public class OrderDAO {

    private final StockDAO stockDAO = new StockDAO();

    public String placeOrder(long userId,
                             String orderCode,
                             Map<String, String> form,
                             BigDecimal shippingFee) throws SQLException {

        try (Connection connection = DBContext.getConnection()) {
            connection.setAutoCommit(false);

            try {
                long cartId = lockCart(connection, userId);

                if (orderExists(connection, userId, orderCode)) {
                    connection.commit();
                    return orderCode;
                }

                List<Map<String, Object>> items =
                        loadItems(connection, cartId);

                if (items.isEmpty()) {
                    throw new IllegalArgumentException(
                            "Giỏ hàng đang trống."
                    );
                }

                BigDecimal subtotal = BigDecimal.ZERO;

                for (Map<String, Object> item : items) {
                    subtotal = subtotal.add(
                            (BigDecimal) item.get("subtotal")
                    );
                }

                Map<String, Object> voucher = loadVoucher(
                        connection,
                        form.get("voucherCode"),
                        subtotal
                );

                BigDecimal discount =
                        (BigDecimal) voucher.get("discount");

                BigDecimal finalAmount = subtotal
                        .subtract(discount)
                        .add(shippingFee);

                long orderId = insertOrder(
                        connection,
                        userId,
                        orderCode,
                        form,
                        subtotal,
                        shippingFee,
                        discount,
                        finalAmount
                );

                for (Map<String, Object> item : items) {
                    insertItem(connection, orderId, item);

                    stockDAO.decreaseStock(
                            connection,
                            ((Number) item.get("bookId")).longValue(),
                            ((Number) item.get("quantity")).intValue()
                    );
                }

                Long voucherId = (Long) voucher.get("id");

                if (voucherId != null) {
                    recordVoucherUsage(
                            connection, voucherId, userId, orderId
                    );
                }

                insertHistory(connection, orderId, userId);
                clearCart(connection, cartId);

                connection.commit();
                return orderCode;

            } catch (SQLException | RuntimeException e) {
                try {
                    connection.rollback();
                } catch (SQLException rollbackError) {
                    e.addSuppressed(rollbackError);
                }

                throw e;
            }
        }
    }

    private long lockCart(Connection connection, long userId)
            throws SQLException {

        String sql =
                "SELECT id FROM dbo.carts WITH (UPDLOCK, HOLDLOCK) " +
                "WHERE user_id = ?";

        try (PreparedStatement statement =
                     connection.prepareStatement(sql)) {

            statement.setLong(1, userId);

            try (ResultSet result = statement.executeQuery()) {
                if (result.next()) {
                    return result.getLong("id");
                }
            }
        }

        throw new IllegalArgumentException("Giỏ hàng đang trống.");
    }

    private boolean orderExists(Connection connection,
                                long userId,
                                String orderCode) throws SQLException {

        String sql =
                "SELECT id FROM dbo.orders " +
                "WHERE order_code = ? AND user_id = ?";

        try (PreparedStatement statement =
                     connection.prepareStatement(sql)) {

            statement.setString(1, orderCode);
            statement.setLong(2, userId);

            try (ResultSet result = statement.executeQuery()) {
                return result.next();
            }
        }
    }

    private List<Map<String, Object>> loadItems(
            Connection connection, long cartId) throws SQLException {

        String sql =
                "SELECT ci.book_id, ci.quantity, b.title, " +
                "b.status, b.is_deleted, " +
                "CAST(b.price * (100 - b.discount_percent) / 100.0 " +
                "AS DECIMAL(18,2)) AS unit_price " +
                "FROM dbo.cart_items ci WITH (UPDLOCK, HOLDLOCK) " +
                "JOIN dbo.books b WITH (HOLDLOCK) ON b.id = ci.book_id " +
                "WHERE ci.cart_id = ? ORDER BY ci.book_id";

        List<Map<String, Object>> items = new ArrayList<>();

        try (PreparedStatement statement =
                     connection.prepareStatement(sql)) {

            statement.setLong(1, cartId);

            try (ResultSet result = statement.executeQuery()) {
                while (result.next()) {
                    if (result.getBoolean("is_deleted")
                            || !"ACTIVE".equals(result.getString("status"))) {

                        throw new IllegalArgumentException(
                                "Một sách trong giỏ đã ngừng bán. "
                                        + "Vui lòng kiểm tra lại giỏ hàng."
                        );
                    }

                    int quantity = result.getInt("quantity");
                    BigDecimal unitPrice =
                            result.getBigDecimal("unit_price");

                    if (quantity <= 0 || unitPrice == null
                            || unitPrice.signum() < 0) {

                        throw new IllegalArgumentException(
                                "Thông tin sách trong giỏ không hợp lệ."
                        );
                    }

                    Map<String, Object> item = new LinkedHashMap<>();
                    item.put("bookId", result.getLong("book_id"));
                    item.put("title", result.getString("title"));
                    item.put("quantity", quantity);
                    item.put("unitPrice", unitPrice);
                    item.put(
                            "subtotal",
                            unitPrice.multiply(BigDecimal.valueOf(quantity))
                    );

                    items.add(item);
                }
            }
        }

        return items;
    }

    private Map<String, Object> loadVoucher(
            Connection connection,
            String code,
            BigDecimal subtotal) throws SQLException {

        Map<String, Object> voucher = new LinkedHashMap<>();
        voucher.put("id", null);
        voucher.put("discount", BigDecimal.ZERO);

        if (code == null || code.trim().isEmpty()) {
            return voucher;
        }

        String sql =
                "SELECT id, discount_type, discount_value, " +
                "min_order_amount, max_discount_amount " +
                "FROM dbo.vouchers WITH (UPDLOCK, HOLDLOCK) " +
                "WHERE UPPER(code) = UPPER(?) " +
                "AND is_deleted = 0 AND status = 'ACTIVE' " +
                "AND start_date <= GETDATE() AND end_date >= GETDATE() " +
                "AND used_count < usage_limit";

        try (PreparedStatement statement =
                     connection.prepareStatement(sql)) {

            statement.setString(1, code.trim());

            try (ResultSet result = statement.executeQuery()) {
                if (!result.next()) {
                    throw new IllegalArgumentException(
                            "Mã giảm giá không hợp lệ, hết hạn hoặc hết lượt dùng."
                    );
                }

                BigDecimal minimum =
                        result.getBigDecimal("min_order_amount");

                if (subtotal.compareTo(minimum) < 0) {
                    throw new IllegalArgumentException(
                            "Đơn hàng chưa đạt giá trị tối thiểu để dùng mã."
                    );
                }

                BigDecimal value =
                        result.getBigDecimal("discount_value");
                BigDecimal discount;

                String type = result.getString("discount_type");

                if ("PERCENT".equalsIgnoreCase(type)) {
                    discount = subtotal.multiply(value).divide(
                            BigDecimal.valueOf(100),
                            2,
                            RoundingMode.HALF_UP
                    );

                    BigDecimal maximum =
                            result.getBigDecimal("max_discount_amount");

                    if (maximum != null) {
                        discount = discount.min(maximum);
                    }

                } else if ("FIXED_AMOUNT".equalsIgnoreCase(type)) {
                    discount = value;

                } else {
                    throw new IllegalArgumentException(
                            "Loại mã giảm giá không hợp lệ."
                    );
                }

                discount = discount.max(BigDecimal.ZERO)
                        .min(subtotal)
                        .setScale(2, RoundingMode.HALF_UP);

                voucher.put("id", result.getLong("id"));
                voucher.put("discount", discount);

                return voucher;
            }
        }
    }

    private long insertOrder(Connection connection,
                             long userId,
                             String orderCode,
                             Map<String, String> form,
                             BigDecimal subtotal,
                             BigDecimal shippingFee,
                             BigDecimal discount,
                             BigDecimal finalAmount) throws SQLException {

        String sql =
                "INSERT INTO dbo.orders " +
                "(order_code, user_id, total_book_amount, shipping_fee, " +
                "discount_amount, final_amount, payment_method, " +
                "payment_status, order_status, shipping_address, " +
                "recipient_name, recipient_phone, note) " +
                "OUTPUT INSERTED.id " +
                "VALUES (?, ?, ?, ?, ?, ?, 'COD', 'PENDING', 'PENDING', " +
                "?, ?, ?, ?)";

        try (PreparedStatement statement =
                     connection.prepareStatement(sql)) {

            statement.setString(1, orderCode);
            statement.setLong(2, userId);
            statement.setBigDecimal(3, subtotal);
            statement.setBigDecimal(4, shippingFee);
            statement.setBigDecimal(5, discount);
            statement.setBigDecimal(6, finalAmount);
            statement.setNString(7, form.get("shippingAddress"));
            statement.setNString(8, form.get("recipientName"));
            statement.setString(9, form.get("phone"));
            statement.setNString(10, form.get("note"));

            try (ResultSet result = statement.executeQuery()) {
                if (result.next()) {
                    return result.getLong(1);
                }
            }
        }

        throw new SQLException("Could not create order.");
    }

    private void insertItem(Connection connection,
                            long orderId,
                            Map<String, Object> item) throws SQLException {

        String sql =
                "INSERT INTO dbo.order_items " +
                "(order_id, book_id, book_title, unit_price, quantity, subtotal) " +
                "VALUES (?, ?, ?, ?, ?, ?)";

        try (PreparedStatement statement =
                     connection.prepareStatement(sql)) {

            statement.setLong(1, orderId);
            statement.setLong(
                    2, ((Number) item.get("bookId")).longValue()
            );
            statement.setNString(3, (String) item.get("title"));
            statement.setBigDecimal(
                    4, (BigDecimal) item.get("unitPrice")
            );
            statement.setInt(
                    5, ((Number) item.get("quantity")).intValue()
            );
            statement.setBigDecimal(
                    6, (BigDecimal) item.get("subtotal")
            );

            statement.executeUpdate();
        }
    }

    private void recordVoucherUsage(Connection connection,
                                    long voucherId,
                                    long userId,
                                    long orderId) throws SQLException {

        String updateSql =
                "UPDATE dbo.vouchers SET used_count = used_count + 1 " +
                "WHERE id = ? AND used_count < usage_limit";

        try (PreparedStatement statement =
                     connection.prepareStatement(updateSql)) {

            statement.setLong(1, voucherId);

            if (statement.executeUpdate() != 1) {
                throw new IllegalArgumentException(
                        "Mã giảm giá đã hết lượt sử dụng."
                );
            }
        }

        String insertSql =
                "INSERT INTO dbo.voucher_usages " +
                "(voucher_id, user_id, order_id) VALUES (?, ?, ?)";

        try (PreparedStatement statement =
                     connection.prepareStatement(insertSql)) {

            statement.setLong(1, voucherId);
            statement.setLong(2, userId);
            statement.setLong(3, orderId);
            statement.executeUpdate();
        }
    }

    private void insertHistory(Connection connection,
                               long orderId,
                               long userId) throws SQLException {

        String sql =
                "INSERT INTO dbo.order_status_history " +
                "(order_id, previous_status, new_status, changed_by, reason) " +
                "VALUES (?, NULL, 'PENDING', ?, ?)";

        try (PreparedStatement statement =
                     connection.prepareStatement(sql)) {

            statement.setLong(1, orderId);
            statement.setLong(2, userId);
            statement.setNString(3, "Khách hàng tạo đơn hàng");
            statement.executeUpdate();
        }
    }

    private void clearCart(Connection connection, long cartId)
            throws SQLException {

        try (PreparedStatement statement = connection.prepareStatement(
                "DELETE FROM dbo.cart_items WHERE cart_id = ?")) {

            statement.setLong(1, cartId);
            statement.executeUpdate();
        }

        try (PreparedStatement statement = connection.prepareStatement(
                "UPDATE dbo.carts SET updated_at = GETDATE() WHERE id = ?")) {

            statement.setLong(1, cartId);
            statement.executeUpdate();
        }
    }
}