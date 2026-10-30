package com.bookstore.service;

import com.bookstore.dao.CartDAO;

import java.math.BigDecimal;
import java.sql.SQLException;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;

public class CartService {

    private final CartDAO cartDAO = new CartDAO();

    public List<Map<String, Object>> getBooks() throws SQLException {
        return cartDAO.findBooks();
    }

    public Map<String, Object> getCart(long userId) throws SQLException {
        List<Map<String, Object>> items = cartDAO.findItems(userId);
        BigDecimal total = BigDecimal.ZERO;
        long totalQuantity = 0;

        for (Map<String, Object> item : items) {
            int quantity = (Integer) item.get("quantity");
            int available = (Integer) item.get("available");
            BigDecimal unitPrice = (BigDecimal) item.get("unitPrice");
            BigDecimal subtotal =
                    unitPrice.multiply(BigDecimal.valueOf(quantity));

            item.put("subtotal", subtotal);
            item.put("stockWarning", quantity > available);

            total = total.add(subtotal);
            totalQuantity += quantity;
        }

        Map<String, Object> cart = new LinkedHashMap<>();
        cart.put("items", items);
        cart.put("total", total);
        cart.put("totalQuantity", totalQuantity);
        return cart;
    }

    public void addToCart(long userId, String bookIdInput, String quantityInput)
            throws SQLException {

        long bookId;
        int quantity;

        try {
            bookId = Long.parseLong(
                    bookIdInput == null ? "" : bookIdInput.trim()
            );
            quantity = Integer.parseInt(
                    quantityInput == null ? "" : quantityInput.trim()
            );
        } catch (NumberFormatException e) {
            throw new IllegalArgumentException(
                    "Vui lòng chọn sách và nhập số lượng hợp lệ."
            );
        }

        if (userId <= 0 || bookId <= 0 || quantity <= 0) {
            throw new IllegalArgumentException(
                    "Số lượng sách phải lớn hơn 0."
            );
        }

        cartDAO.addItem(userId, bookId, quantity);
    }
    public void updateQuantity(long userId, String itemIdInput,
                           String quantityInput) throws SQLException {

    if (userId <= 0) {
        throw new IllegalArgumentException(
                "Vui lòng đăng nhập lại."
        );
    }

    long itemId = parseItemId(itemIdInput);
    int quantity;

    try {
        quantity = Integer.parseInt(
                quantityInput == null ? "" : quantityInput.trim()
        );
    } catch (NumberFormatException e) {
        throw new IllegalArgumentException(
                "Số lượng phải là số nguyên hợp lệ."
        );
    }

    if (quantity <= 0) {
        throw new IllegalArgumentException(
                "Số lượng phải lớn hơn 0. Dùng nút Xóa để bỏ sách khỏi giỏ."
        );
    }

    cartDAO.updateQuantity(userId, itemId, quantity);
}

public void removeItem(long userId, String itemIdInput)
        throws SQLException {

    if (userId <= 0) {
        throw new IllegalArgumentException(
                "Vui lòng đăng nhập lại."
        );
    }

    cartDAO.removeItem(userId, parseItemId(itemIdInput));
}

private long parseItemId(String itemIdInput) {
    try {
        long itemId = Long.parseLong(
                itemIdInput == null ? "" : itemIdInput.trim()
        );

        if (itemId <= 0) {
            throw new NumberFormatException();
        }

        return itemId;

    } catch (NumberFormatException e) {
        throw new IllegalArgumentException(
                "Sách trong giỏ hàng không hợp lệ."
        );
    }
}
}