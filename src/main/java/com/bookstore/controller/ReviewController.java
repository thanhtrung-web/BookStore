
package com.bookstore.controller;

import com.bookstore.dao.ReviewDAO.ReviewBook;
import com.bookstore.model.Review;
import com.bookstore.model.User;
import com.bookstore.service.ReviewService;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

import java.io.IOException;
import java.net.URLEncoder;
import java.nio.charset.StandardCharsets;
import java.sql.SQLException;
import java.util.List;

@WebServlet("/reviews")
public class ReviewController extends HttpServlet {

    private static final long serialVersionUID = 1L;
    private static final int PAGE_SIZE = 5;

    private final ReviewService reviewService = new ReviewService();

    @Override
    protected void doGet(HttpServletRequest request,
                         HttpServletResponse response)
            throws ServletException, IOException {

        request.setCharacterEncoding("UTF-8");

        try {
            long bookId = parseLong(request.getParameter("bookId"), 0);

            if (bookId <= 0) {
                response.sendError(
                        HttpServletResponse.SC_BAD_REQUEST,
                        "Book ID không hợp lệ.");
                return;
            }

            ReviewBook book = reviewService.getBook(bookId);

            if (book == null) {
                response.sendError(
                        HttpServletResponse.SC_NOT_FOUND,
                        "Không tìm thấy sách.");
                return;
            }

            request.setAttribute("bookId", book.getId());
            request.setAttribute("bookTitle", book.getTitle());
            request.setAttribute("bookDescription", book.getDescription());

            String sort = request.getParameter("sort");

            if (!"highest".equals(sort) && !"lowest".equals(sort)) {
                sort = "newest";
            }

            Integer ratingFilter = parseRating(
                    request.getParameter("rating"));

            int page = (int) Math.max(
                    1, parseLong(request.getParameter("page"), 1));

            int totalReviews = reviewService.countReviews(
                    bookId, ratingFilter);

            int totalPages = Math.max(
                    1, (int) Math.ceil(totalReviews / (double) PAGE_SIZE));

            page = Math.min(page, totalPages);

            List<Review> reviews = reviewService.getReviews(
                    bookId, page, PAGE_SIZE, sort, ratingFilter);

            request.setAttribute("reviews", reviews);
            request.setAttribute("averageRating",
                    reviewService.getAverageRating(bookId));
            request.setAttribute("totalReviews", totalReviews);
            request.setAttribute("totalPages", totalPages);
            request.setAttribute("currentPage", page);
            request.setAttribute("sort", sort);
            request.setAttribute("ratingFilter", ratingFilter);

            HttpSession session = request.getSession(false);
            User user = null;

            if (session != null) {
                Object authUser = session.getAttribute("authUser");

                if (authUser instanceof User) {
                    user = (User) authUser;
                }
            }

            boolean isBuyer = user != null && user.hasRole("BUYER");
            request.setAttribute("isBuyer", isBuyer);

            Review ownReview = null;
            boolean canWriteReview = false;

            if (isBuyer) {
                ownReview = reviewService.getOwnReview(
                        user.getId(), bookId);

                canWriteReview = reviewService.canWriteReview(
                        user.getId(), bookId);
            }

            request.setAttribute("ownReview", ownReview);
            request.setAttribute("canWriteReview", canWriteReview);

            if ("edit".equals(request.getParameter("action"))) {
                long reviewId = parseLong(
                        request.getParameter("reviewId"), 0);

                Review editReview =
                        reviewService.getReviewById(reviewId);

                if (editReview == null
                        || user == null
                        || editReview.getUserId() == null
                        || editReview.getUserId().longValue()
                                != user.getId()
                        || !"APPROVED".equalsIgnoreCase(
                                editReview.getStatus())
                        || editReview.getBookId() == null
                        || editReview.getBookId().longValue()
                                != bookId) {

                    response.sendError(
                            HttpServletResponse.SC_FORBIDDEN,
                            "Bạn không có quyền sửa đánh giá này.");
                    return;
                }

                request.setAttribute("editReview", editReview);
            }

            request.getRequestDispatcher(
                    "/views/book-detail.jsp").forward(request, response);

        } catch (SQLException e) {
            throw new ServletException(
                    "Không thể tải thông tin đánh giá.", e);
        }
    }

    @Override
    protected void doPost(HttpServletRequest request,
                          HttpServletResponse response)
            throws ServletException, IOException {

        request.setCharacterEncoding("UTF-8");

        long bookId = parseLong(request.getParameter("bookId"), 0);
        String action = request.getParameter("action");

        HttpSession session = request.getSession(false);
        User user = null;

        if (session != null) {
            Object authUser = session.getAttribute("authUser");

            if (authUser instanceof User) {
                user = (User) authUser;
            }
        }

        if (user == null || !user.hasRole("BUYER")) {
            response.sendRedirect(
                    request.getContextPath() + "/login");
            return;
        }

        if (bookId <= 0) {
            response.sendError(
                    HttpServletResponse.SC_BAD_REQUEST,
                    "Book ID không hợp lệ.");
            return;
        }

        try {
            boolean success;

            if ("create".equals(action)) {
                int rating = (int) parseLong(
                        request.getParameter("rating"), 0);

                success = reviewService.createReview(
                        user.getId(),
                        bookId,
                        rating,
                        request.getParameter("comment"));

            } else if ("update".equals(action)) {
                long reviewId = parseLong(
                        request.getParameter("reviewId"), 0);

                int rating = (int) parseLong(
                        request.getParameter("rating"), 0);

                Review review =
                        reviewService.getReviewById(reviewId);

                if (review == null
                        || review.getBookId() == null
                        || review.getBookId().longValue() != bookId) {
                    response.sendError(
                            HttpServletResponse.SC_NOT_FOUND,
                            "Không tìm thấy đánh giá.");
                    return;
                }

                success = reviewService.updateReview(
                        user.getId(),
                        reviewId,
                        rating,
                        request.getParameter("comment"));

            } else if ("delete".equals(action)) {
                long reviewId = parseLong(
                        request.getParameter("reviewId"), 0);

                Review review =
                        reviewService.getReviewById(reviewId);

                if (review == null
                        || review.getBookId() == null
                        || review.getBookId().longValue() != bookId) {
                    response.sendError(
                            HttpServletResponse.SC_NOT_FOUND,
                            "Không tìm thấy đánh giá.");
                    return;
                }

                success = reviewService.deleteReview(
                        user.getId(), reviewId);

            } else {
                response.sendError(
                        HttpServletResponse.SC_BAD_REQUEST,
                        "Thao tác không hợp lệ.");
                return;
            }

            String message = success
                    ? "Thao tác đánh giá thành công."
                    : "Không thể thực hiện thao tác đánh giá.";

            redirectWithMessage(
                    request, response, bookId, message);

        } catch (IllegalArgumentException | IllegalStateException e) {
            redirectWithMessage(
                    request, response, bookId, e.getMessage());

        } catch (SecurityException e) {
            response.sendError(
                    HttpServletResponse.SC_FORBIDDEN, e.getMessage());

        } catch (SQLException e) {
            throw new ServletException(
                    "Không thể lưu đánh giá.", e);
        }
    }

    private void redirectWithMessage(
            HttpServletRequest request,
            HttpServletResponse response,
            long bookId,
            String message) throws IOException {

        String encodedMessage = URLEncoder.encode(
                message == null ? "" : message,
                StandardCharsets.UTF_8.name());

        response.sendRedirect(
                request.getContextPath()
                        + "/reviews?bookId=" + bookId
                        + "&message=" + encodedMessage);
    }

    private long parseLong(String value, long defaultValue) {
        try {
            return Long.parseLong(value);
        } catch (NumberFormatException | NullPointerException e) {
            return defaultValue;
        }
    }

    private Integer parseRating(String value) {
        if (value == null || value.trim().isEmpty()) {
            return null;
        }

        try {
            int rating = Integer.parseInt(value);
            return rating >= 1 && rating <= 5 ? rating : null;
        } catch (NumberFormatException e) {
            return null;
        }
    }
}
