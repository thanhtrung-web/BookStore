package com.bookstore.model;

import java.io.Serializable;
import java.sql.Timestamp;

/**
 * CartItem POJO mapping to table dbo.cart_items.
 */
public class CartItem implements Serializable {

    private static final long serialVersionUID = 1L;

    private Long id;
    private Long cartId;
    private Long bookId;
    private int quantity = 1;
    private Timestamp addedAt;

    public CartItem() {
    }

    public CartItem(Long id, Long cartId, Long bookId, int quantity, Timestamp addedAt) {
        this.id = id;
        this.cartId = cartId;
        this.bookId = bookId;
        this.quantity = quantity;
        this.addedAt = addedAt;
    }

    public Long getId() {
        return id;
    }

    public void setId(Long id) {
        this.id = id;
    }

    public Long getCartId() {
        return cartId;
    }

    public void setCartId(Long cartId) {
        this.cartId = cartId;
    }

    public Long getBookId() {
        return bookId;
    }

    public void setBookId(Long bookId) {
        this.bookId = bookId;
    }

    public int getQuantity() {
        return quantity;
    }

    public void setQuantity(int quantity) {
        this.quantity = quantity;
    }

    public Timestamp getAddedAt() {
        return addedAt;
    }

    public void setAddedAt(Timestamp addedAt) {
        this.addedAt = addedAt;
    }
}
