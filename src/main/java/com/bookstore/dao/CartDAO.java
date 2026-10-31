package com.bookstore.dao;

import com.bookstore.context.DBContext;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;

public class CartDAO {

    public List<Map<String, Object>> findBooks() throws SQLException {
        String sql =
                "SELECT TOP (100) b.id, b.title, " +
                "CAST(b.price * (100 - b.discount_percent) / 100.0 " +
                "AS DECIMAL(18,2)) AS unit_price, " +
                "(i.stock_quantity - i.reserved_quantity) AS available " +
                "FROM dbo.books b " +
                "JOIN dbo.inventories i ON i.book_id = b.id " +
                "WHERE b.is_deleted = 0 AND b.status = 'ACTIVE' " +
                "AND i.stock_quantity > i.reserved_quantity " +
                "ORDER BY b.title, b.id";

        List<Map<String, Object>> books = new ArrayList<>();

        try (Connection connection = DBContext.getConnection();
             PreparedStatement statement = connection.prepareStatement(sql);
             ResultSet result = statement.executeQuery()) {

            while (result.next()) {
                Map<String, Object> book = new LinkedHashMap<>();
                book.put("id", result.getLong("id"));
                book.put("title", result.getString("title"));
                book.put("unitPrice", result.getBigDecimal("unit_price"));
                book.put("available", result.getInt("available"));
                books.add(book);
            }
        }

        return books;
    }

    public List<Map<String, Object>> findItems(long userId)
            throws SQLException {

        String sql =
                "SELECT ci.id, ci.book_id, ci.quantity, b.title, " +
                "CAST(b.price * (100 - b.discount_percent) / 100.0 " +
                "AS DECIMAL(18,2)) AS unit_price, " +
                "CASE WHEN b.is_deleted = 0 AND b.status = 'ACTIVE' " +
                "THEN CASE WHEN ISNULL(i.stock_quantity, 0) " +
                "- ISNULL(i.reserved_quantity, 0) > 0 " +
                "THEN i.stock_quantity - i.reserved_quantity ELSE 0 END " +
                "ELSE 0 END AS available " +
                "FROM dbo.carts c " +
                "JOIN dbo.cart_items ci ON ci.cart_id = c.id " +
                "JOIN dbo.books b ON b.id = ci.book_id " +
                "LEFT JOIN dbo.inventories i ON i.book_id = b.id " +
                "WHERE c.user_id = ? " +
                "ORDER BY ci.added_at DESC, ci.id DESC";

        List<Map<String, Object>> items = new ArrayList<>();

        try (Connection connection = DBContext.getConnection();
             PreparedStatement statement = connection.prepareStatement(sql)) {

            statement.setLong(1, userId);

            try (ResultSet result = statement.executeQuery()) {
                while (result.next()) {
                    Map<String, Object> item = new LinkedHashMap<>();
                    item.put("id", result.getLong("id"));
                    item.put("bookId", result.getLong("book_id"));
                    item.put("title", result.getString("title"));
                    item.put("quantity", result.getInt("quantity"));
                    item.put("unitPrice", result.getBigDecimal("unit_price"));
                    item.put("available", result.getInt("available"));
                    items.add(item);
                }
            }
        }

        return items;
    }

    public void addItem(long userId, long bookId, int quantity)
            throws SQLException {

        try (Connection connection = DBContext.getConnection()) {
            connection.setAutoCommit(false);

            try {
                long cartId = getOrCreateCart(connection, userId);
                int available = getAvailableStock(connection, bookId);

                if (available <= 0) {
                    throw new IllegalArgumentException(
                            "Sách đã hết hàng hoặc không còn được bán."
                    );
                }

                int currentQuantity = 0;
                Long itemId = null;

                String findSql =
                        "SELECT id, quantity FROM dbo.cart_items " +
                        "WITH (UPDLOCK, HOLDLOCK) " +
                        "WHERE cart_id = ? AND book_id = ?";

                try (PreparedStatement statement =
                             connection.prepareStatement(findSql)) {

                    statement.setLong(1, cartId);
                    statement.setLong(2, bookId);

                    try (ResultSet result = statement.executeQuery()) {
                        if (result.next()) {
                            itemId = result.getLong("id");
                            currentQuantity = result.getInt("quantity");
                        }
                    }
                }

                long requestedQuantity = (long) currentQuantity + quantity;

                if (requestedQuantity > available) {
                    throw new IllegalArgumentException(
                            "Chỉ còn " + available + " cuốn có thể mua. " +
                            "Giỏ hàng của bạn đã có " + currentQuantity + " cuốn."
                    );
                }

                if (itemId == null) {
                    String insertSql =
                            "INSERT INTO dbo.cart_items " +
                            "(cart_id, book_id, quantity) VALUES (?, ?, ?)";

                    try (PreparedStatement statement =
                                 connection.prepareStatement(insertSql)) {

                        statement.setLong(1, cartId);
                        statement.setLong(2, bookId);
                        statement.setInt(3, quantity);
                        statement.executeUpdate();
                    }
                } else {
                    String updateSql =
                            "UPDATE dbo.cart_items SET quantity = ? WHERE id = ?";

                    try (PreparedStatement statement =
                                 connection.prepareStatement(updateSql)) {

                        statement.setInt(1, (int) requestedQuantity);
                        statement.setLong(2, itemId);
                        statement.executeUpdate();
                    }
                }

                try (PreparedStatement statement = connection.prepareStatement(
                        "UPDATE dbo.carts SET updated_at = GETDATE() WHERE id = ?")) {

                    statement.setLong(1, cartId);
                    statement.executeUpdate();
                }

                connection.commit();

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

    private long getOrCreateCart(Connection connection, long userId)
            throws SQLException {

        String findSql =
                "SELECT id FROM dbo.carts WITH (UPDLOCK, HOLDLOCK) " +
                "WHERE user_id = ?";

        try (PreparedStatement statement = connection.prepareStatement(findSql)) {
            statement.setLong(1, userId);

            try (ResultSet result = statement.executeQuery()) {
                if (result.next()) {
                    return result.getLong("id");
                }
            }
        }

        String insertSql =
                "INSERT INTO dbo.carts (user_id) OUTPUT INSERTED.id VALUES (?)";

        try (PreparedStatement statement =
                     connection.prepareStatement(insertSql)) {

            statement.setLong(1, userId);

            try (ResultSet result = statement.executeQuery()) {
                if (result.next()) {
                    return result.getLong(1);
                }
            }
        }

        throw new SQLException("Could not create cart.");
    }

    private int getAvailableStock(Connection connection, long bookId)
            throws SQLException {

        String sql =
                "SELECT i.stock_quantity - i.reserved_quantity AS available " +
                "FROM dbo.books b WITH (HOLDLOCK) " +
                "JOIN dbo.inventories i WITH (HOLDLOCK) ON i.book_id = b.id " +
                "WHERE b.id = ? AND b.is_deleted = 0 AND b.status = 'ACTIVE'";

        try (PreparedStatement statement = connection.prepareStatement(sql)) {
            statement.setLong(1, bookId);

            try (ResultSet result = statement.executeQuery()) {
                if (result.next()) {
                    return Math.max(0, result.getInt("available"));
                }
            }
        }

        return 0;
    }
    public void updateQuantity(long userId, long itemId, int quantity)
        throws SQLException {

    try (Connection connection = DBContext.getConnection()) {
        connection.setAutoCommit(false);

        try {
            Long cartId = null;

            String cartSql =
                    "SELECT id FROM dbo.carts WITH (UPDLOCK, HOLDLOCK) " +
                    "WHERE user_id = ?";

            try (PreparedStatement statement =
                         connection.prepareStatement(cartSql)) {

                statement.setLong(1, userId);

                try (ResultSet result = statement.executeQuery()) {
                    if (result.next()) {
                        cartId = result.getLong("id");
                    }
                }
            }

            if (cartId == null) {
                throw new IllegalArgumentException(
                        "Giỏ hàng không tồn tại."
                );
            }

            Long bookId = null;

            String itemSql =
                    "SELECT book_id FROM dbo.cart_items " +
                    "WITH (UPDLOCK, HOLDLOCK) " +
                    "WHERE id = ? AND cart_id = ?";

            try (PreparedStatement statement =
                         connection.prepareStatement(itemSql)) {

                statement.setLong(1, itemId);
                statement.setLong(2, cartId);

                try (ResultSet result = statement.executeQuery()) {
                    if (result.next()) {
                        bookId = result.getLong("book_id");
                    }
                }
            }

            if (bookId == null) {
                throw new IllegalArgumentException(
                        "Sách không còn trong giỏ hàng của bạn."
                );
            }

            int available = getAvailableStock(connection, bookId);

            if (available <= 0) {
                throw new IllegalArgumentException(
                        "Sách đã hết hàng hoặc ngừng bán. Bạn có thể xóa sách khỏi giỏ."
                );
            }

            if (quantity > available) {
                throw new IllegalArgumentException(
                        "Chỉ còn " + available + " cuốn có thể mua."
                );
            }

            String updateSql =
                    "UPDATE dbo.cart_items SET quantity = ? " +
                    "WHERE id = ? AND cart_id = ?";

            try (PreparedStatement statement =
                         connection.prepareStatement(updateSql)) {

                statement.setInt(1, quantity);
                statement.setLong(2, itemId);
                statement.setLong(3, cartId);
                statement.executeUpdate();
            }

            try (PreparedStatement statement = connection.prepareStatement(
                    "UPDATE dbo.carts SET updated_at = GETDATE() WHERE id = ?")) {

                statement.setLong(1, cartId);
                statement.executeUpdate();
            }

            connection.commit();

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

public void removeItem(long userId, long itemId) throws SQLException {
    try (Connection connection = DBContext.getConnection()) {
        connection.setAutoCommit(false);

        try {
            Long cartId = null;

            String cartSql =
                    "SELECT id FROM dbo.carts WITH (UPDLOCK, HOLDLOCK) " +
                    "WHERE user_id = ?";

            try (PreparedStatement statement =
                         connection.prepareStatement(cartSql)) {

                statement.setLong(1, userId);

                try (ResultSet result = statement.executeQuery()) {
                    if (result.next()) {
                        cartId = result.getLong("id");
                    }
                }
            }

            if (cartId == null) {
                throw new IllegalArgumentException(
                        "Giỏ hàng không tồn tại."
                );
            }

            String deleteSql =
                    "DELETE FROM dbo.cart_items WHERE id = ? AND cart_id = ?";

            try (PreparedStatement statement =
                         connection.prepareStatement(deleteSql)) {

                statement.setLong(1, itemId);
                statement.setLong(2, cartId);

                if (statement.executeUpdate() == 0) {
                    throw new IllegalArgumentException(
                            "Sách không còn trong giỏ hàng của bạn."
                    );
                }
            }

            try (PreparedStatement statement = connection.prepareStatement(
                    "UPDATE dbo.carts SET updated_at = GETDATE() WHERE id = ?")) {

                statement.setLong(1, cartId);
                statement.executeUpdate();
            }

            connection.commit();

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
}