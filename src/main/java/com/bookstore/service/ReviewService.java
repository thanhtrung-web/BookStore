
package com.bookstore.service;

import com.bookstore.dao.ReviewDAO;
import com.bookstore.dao.ReviewDAO.ReviewBook;
import com.bookstore.model.Review;

import java.sql.SQLException;
import java.util.List;

public class ReviewService {

    private final ReviewDAO reviewDAO = new ReviewDAO();

    public ReviewBook getBook(long bookId) throws SQLException {
        if (bookId <= 0) {
            return null;
        }
        return reviewDAO.findBook(bookId);
    }

    public List<Review> getReviews(
            long bookId, int page, int pageSize,
            String sort, Integer ratingFilter) throws SQLException {

        if (page < 1) {
            page = 1;
        }

        if (pageSize < 1 || pageSize > 50) {
            pageSize = 5;
        }

        if (!"highest".equals(sort)
                && !"lowest".equals(sort)
                && !"newest".equals(sort)) {
            sort = "newest";
        }

        if (ratingFilter != null
                && (ratingFilter < 1 || ratingFilter > 5)) {
            ratingFilter = null;
        }

        return reviewDAO.getReviews(
                bookId, page, pageSize, sort, ratingFilter);
    }

    public int countReviews(long bookId, Integer ratingFilter)
            throws SQLException {
        return reviewDAO.countReviews(bookId, ratingFilter);
    }

    public double getAverageRating(long bookId) throws SQLException {
        return reviewDAO.getAverageRating(bookId);
    }

    public Review getOwnReview(long userId, long bookId)
            throws SQLException {
        return reviewDAO.getOwnReview(userId, bookId);
    }

    public Review getReviewById(long reviewId) throws SQLException {
        return reviewDAO.getReviewById(reviewId);
    }

    public boolean canWriteReview(long userId, long bookId)
            throws SQLException {

        if (userId <= 0 || bookId <= 0) {
            return false;
        }

        return reviewDAO.hasDeliveredOrder(userId, bookId)
                && !reviewDAO.hasReviewed(userId, bookId);
    }

    public boolean createReview(long userId, long bookId,
                                int rating, String comment)
            throws SQLException {

        validateReview(rating, comment);

        if (!canWriteReview(userId, bookId)) {
            throw new IllegalStateException(
                    "Bạn cần có đơn hàng đã giao và chưa đánh giá sách này.");
        }

        return reviewDAO.createReview(
                bookId, userId, rating, comment.trim());
    }

    public boolean updateReview(long userId, long reviewId,
                                int rating, String comment)
            throws SQLException {

        validateReview(rating, comment);

        Review existing = reviewDAO.getReviewById(reviewId);

        if (existing == null) {
            throw new IllegalStateException(
                    "Không tìm thấy đánh giá.");
        }

        if (existing.getUserId() == null
                || existing.getUserId() != userId) {
            throw new SecurityException(
                    "Bạn không có quyền sửa đánh giá này.");
        }

        if (!"APPROVED".equalsIgnoreCase(existing.getStatus())) {
            throw new IllegalStateException(
                    "Đánh giá này hiện không thể chỉnh sửa.");
        }

        return reviewDAO.updateReview(
                reviewId, userId, rating, comment.trim());
    }

    public boolean deleteReview(long userId, long reviewId)
            throws SQLException {

        Review existing = reviewDAO.getReviewById(reviewId);

        if (existing == null) {
            throw new IllegalStateException(
                    "Không tìm thấy đánh giá.");
        }

        if (existing.getUserId() == null
                || existing.getUserId() != userId) {
            throw new SecurityException(
                    "Bạn không có quyền xóa đánh giá này.");
        }

        return reviewDAO.deleteReview(reviewId, userId);
    }

    private void validateReview(int rating, String comment) {
        if (rating < 1 || rating > 5) {
            throw new IllegalArgumentException(
                    "Điểm đánh giá phải từ 1 đến 5 sao.");
        }

        if (comment == null || comment.trim().isEmpty()) {
            throw new IllegalArgumentException(
                    "Vui lòng nhập nội dung nhận xét.");
        }

        if (comment.trim().length() > 2000) {
            throw new IllegalArgumentException(
                    "Nhận xét không được vượt quá 2000 ký tự.");
        }
    }
}
