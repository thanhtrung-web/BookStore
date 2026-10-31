
package com.bookstore.dao;

import com.bookstore.context.DBContext;
import com.bookstore.model.Review;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class ReviewDAO {

    // Lấy thông tin sách
    public ReviewBook findBook(long bookId) throws SQLException {
        String sql = """
            SELECT id, title, description
            FROM dbo.books
            WHERE id = ? AND status = 'ACTIVE' AND is_deleted = 0
            """;

        try (Connection con = DBContext.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {

            ps.setLong(1, bookId);

            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return new ReviewBook(
                        rs.getLong("id"),
                        rs.getString("title"),
                        rs.getString("description")
                    );
                }
            }
        }
        return null;
    }

    // Kiểm tra người dùng có đơn hàng đã giao chứa sách này không
    public boolean hasDeliveredOrder(long userId, long bookId)
            throws SQLException {

        String sql = """
            SELECT COUNT(*)
            FROM dbo.orders o
            JOIN dbo.order_items oi ON oi.order_id = o.id
            WHERE o.user_id = ?
              AND oi.book_id = ?
              AND UPPER(o.order_status) = 'DELIVERED'
            """;

        try (Connection con = DBContext.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {

            ps.setLong(1, userId);
            ps.setLong(2, bookId);

            try (ResultSet rs = ps.executeQuery()) {
                return rs.next() && rs.getInt(1) > 0;
            }
        }
    }

    // Kiểm tra người dùng đã đánh giá sách chưa
    public boolean hasReviewed(long userId, long bookId)
            throws SQLException {

        String sql =
            "SELECT COUNT(*) FROM dbo.reviews WHERE user_id = ? AND book_id = ?";

        try (Connection con = DBContext.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {

            ps.setLong(1, userId);
            ps.setLong(2, bookId);

            try (ResultSet rs = ps.executeQuery()) {
                return rs.next() && rs.getInt(1) > 0;
            }
        }
    }

    // Lấy danh sách đánh giá đã được duyệt
    public List<Review> getReviews(
            long bookId, int page, int pageSize,
            String sort, Integer ratingFilter) throws SQLException {

        List<Review> reviews = new ArrayList<>();

        String orderBy;
        switch (sort == null ? "newest" : sort) {
            case "highest":
                orderBy = "r.rating DESC, r.created_at DESC";
                break;
            case "lowest":
                orderBy = "r.rating ASC, r.created_at DESC";
                break;
            default:
                orderBy = "r.created_at DESC";
        }

        StringBuilder sql = new StringBuilder("""
            SELECT r.id, r.book_id, r.user_id, r.order_id,
                   r.rating, r.comment, r.status,
                   r.created_at, r.updated_at,
                   u.full_name AS reviewer_name
            FROM dbo.reviews r
            JOIN dbo.users u ON u.id = r.user_id
            WHERE r.book_id = ?
              AND r.status = 'APPROVED'
            """);

        if (ratingFilter != null && ratingFilter >= 1 && ratingFilter <= 5) {
            sql.append(" AND r.rating = ?");
        }

        sql.append(" ORDER BY ").append(orderBy)
           .append(" OFFSET ? ROWS FETCH NEXT ? ROWS ONLY");

        try (Connection con = DBContext.getConnection();
             PreparedStatement ps = con.prepareStatement(sql.toString())) {

            int index = 1;
            ps.setLong(index++, bookId);

            if (ratingFilter != null && ratingFilter >= 1
                    && ratingFilter <= 5) {
                ps.setInt(index++, ratingFilter);
            }

            ps.setInt(index++, Math.max(0, page - 1) * pageSize);
            ps.setInt(index, pageSize);

            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    reviews.add(mapReview(rs));
                }
            }
        }

        return reviews;
    }

    // Đếm số đánh giá theo bộ lọc
    public int countReviews(long bookId, Integer ratingFilter)
            throws SQLException {

        String sql = """
            SELECT COUNT(*)
            FROM dbo.reviews
            WHERE book_id = ? AND status = 'APPROVED'
            """;

        if (ratingFilter != null && ratingFilter >= 1
                && ratingFilter <= 5) {
            sql += " AND rating = ?";
        }

        try (Connection con = DBContext.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {

            ps.setLong(1, bookId);

            if (ratingFilter != null && ratingFilter >= 1
                    && ratingFilter <= 5) {
                ps.setInt(2, ratingFilter);
            }

            try (ResultSet rs = ps.executeQuery()) {
                return rs.next() ? rs.getInt(1) : 0;
            }
        }
    }

    // Lấy điểm trung bình
    public double getAverageRating(long bookId) throws SQLException {
        String sql = """
            SELECT AVG(CAST(rating AS FLOAT))
            FROM dbo.reviews
            WHERE book_id = ? AND status = 'APPROVED'
            """;

        try (Connection con = DBContext.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {

            ps.setLong(1, bookId);

            try (ResultSet rs = ps.executeQuery()) {
                return rs.next() ? rs.getDouble(1) : 0.0;
            }
        }
    }

    // Lấy đánh giá của một người dùng cho sách
    public Review getOwnReview(long userId, long bookId)
            throws SQLException {

        String sql = """
            SELECT r.id, r.book_id, r.user_id, r.order_id,
                   r.rating, r.comment, r.status,
                   r.created_at, r.updated_at,
                   u.full_name AS reviewer_name
            FROM dbo.reviews r
            JOIN dbo.users u ON u.id = r.user_id
            WHERE r.user_id = ? AND r.book_id = ?
            """;

        try (Connection con = DBContext.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {

            ps.setLong(1, userId);
            ps.setLong(2, bookId);

            try (ResultSet rs = ps.executeQuery()) {
                return rs.next() ? mapReview(rs) : null;
            }
        }
    }

    // Lấy đánh giá theo ID
    public Review getReviewById(long reviewId) throws SQLException {
        String sql = """
            SELECT r.id, r.book_id, r.user_id, r.order_id,
                   r.rating, r.comment, r.status,
                   r.created_at, r.updated_at,
                   u.full_name AS reviewer_name
            FROM dbo.reviews r
            JOIN dbo.users u ON u.id = r.user_id
            WHERE r.id = ?
            """;

        try (Connection con = DBContext.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {

            ps.setLong(1, reviewId);

            try (ResultSet rs = ps.executeQuery()) {
                return rs.next() ? mapReview(rs) : null;
            }
        }
    }

    // Thêm đánh giá
    public boolean createReview(long bookId, long userId,
                                int rating, String comment)
            throws SQLException {

        String sql = """
            INSERT INTO dbo.reviews
                (book_id, user_id, order_id, rating, comment,
                 status, is_purchased, created_at, updated_at)
            SELECT ?, ?, o.id, ?, ?, 'APPROVED', 1, GETDATE(), GETDATE()
            FROM dbo.orders o
            JOIN dbo.order_items oi ON oi.order_id = o.id
            WHERE o.user_id = ?
              AND oi.book_id = ?
              AND UPPER(o.order_status) = 'DELIVERED'
              AND NOT EXISTS (
                  SELECT 1 FROM dbo.reviews r
                  WHERE r.book_id = ? AND r.user_id = ?
              )
            """;

        try (Connection con = DBContext.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {

            ps.setLong(1, bookId);
            ps.setLong(2, userId);
            ps.setInt(3, rating);
            ps.setString(4, comment);
            ps.setLong(5, userId);
            ps.setLong(6, bookId);
            ps.setLong(7, bookId);
            ps.setLong(8, userId);

            return ps.executeUpdate() > 0;
        }
    }

    // Sửa đánh giá của chính người dùng
    public boolean updateReview(long reviewId, long userId,
                                int rating, String comment)
            throws SQLException {

        String sql = """
            UPDATE dbo.reviews
            SET rating = ?, comment = ?, updated_at = GETDATE()
            WHERE id = ? AND user_id = ? AND status = 'APPROVED'
            """;

        try (Connection con = DBContext.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {

            ps.setInt(1, rating);
            ps.setString(2, comment);
            ps.setLong(3, reviewId);
            ps.setLong(4, userId);

            return ps.executeUpdate() > 0;
        }
    }

    // Xóa đánh giá của chính người dùng
    public boolean deleteReview(long reviewId, long userId)
            throws SQLException {

        String sql =
            "DELETE FROM dbo.reviews WHERE id = ? AND user_id = ?";

        try (Connection con = DBContext.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {

            ps.setLong(1, reviewId);
            ps.setLong(2, userId);

            return ps.executeUpdate() > 0;
        }
    }

    private Review mapReview(ResultSet rs) throws SQLException {
        Review review = new Review();

        review.setId(rs.getLong("id"));
        review.setBookId(rs.getLong("book_id"));
        review.setUserId(rs.getLong("user_id"));

        long orderId = rs.getLong("order_id");
        review.setOrderId(rs.wasNull() ? null : orderId);

        review.setRating(rs.getInt("rating"));
        review.setComment(rs.getString("comment"));
        review.setStatus(rs.getString("status"));
        review.setReviewerName(rs.getString("reviewer_name"));
        review.setCreatedAt(rs.getTimestamp("created_at"));
        review.setUpdatedAt(rs.getTimestamp("updated_at"));

        return review;
    }

    // Đối tượng chứa thông tin sách
    public static class ReviewBook {
        private final long id;
        private final String title;
        private final String description;

        public ReviewBook(long id, String title, String description) {
            this.id = id;
            this.title = title;
            this.description = description;
        }

        public long getId() { return id; }
        public String getTitle() { return title; }
        public String getDescription() { return description; }
    }
}
