package com.bookstore.dao;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.SQLException;

public class StockDAO {

    public void decreaseStock(Connection connection,
                              long bookId,
                              int quantity) throws SQLException {

        if (quantity <= 0) {
            throw new IllegalArgumentException(
                    "Số lượng sách phải lớn hơn 0."
            );
        }

        String sql =
                "UPDATE dbo.inventories " +
                "SET stock_quantity = stock_quantity - ?, " +
                "updated_at = GETDATE() " +
                "WHERE book_id = ? " +
                "AND stock_quantity - reserved_quantity >= ?";

        try (PreparedStatement statement =
                     connection.prepareStatement(sql)) {

            statement.setInt(1, quantity);
            statement.setLong(2, bookId);
            statement.setInt(3, quantity);

            if (statement.executeUpdate() != 1) {
                throw new IllegalArgumentException(
                        "Một sách trong giỏ không còn đủ hàng. "
                                + "Vui lòng kiểm tra lại giỏ hàng."
                );
            }
        }
    }
}