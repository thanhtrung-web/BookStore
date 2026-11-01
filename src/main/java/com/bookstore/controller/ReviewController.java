
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
import java.util.UUID;

@WebServlet("/reviews")
public class ReviewController extends HttpServlet {

    private static final long serialVersionUID = 1L;
    private static final int PAGE_SIZE = 5;

    private static final String REVIEW_CSRF_TOKEN =
            "reviewCsrfToken";

    private final ReviewService reviewService =
            new ReviewService();

    @Override
    protected void doGet(HttpServletRequest request,
                         HttpServletResponse response)
            throws ServletException, IOException {

        request.setCharacterEncoding("UTF-8");

        try {
            long bookId = parseLong(
                    request.getParameter("bookId"), 0);

            if (bookId <= 0) {
                response.sendError(
                        HttpServletResponse.SC_BAD_REQUEST,
                        "Invalid book ID.");
                return;
            }

            // Redirect to BookController so the book detail page
            // can load all required book and cart information.
            StringBuilder redirectUrl = new StringBuilder(
                    request.getContextPath()
                            + "/book-detail?id=" + bookId);

            copyParameter(request, redirectUrl, "sort");
            copyParameter(request, redirectUrl, "rating");

            String page = request.getParameter("page");
            if (page != null && !page.trim().isEmpty()) {
                redirectUrl.append("&reviewPage=")
                        .append(encode(page));
            }

            String action = request.getParameter("action");
            if ("edit".equals(action)) {
                redirectUrl.append("&action=edit");
                copyParameter(request, redirectUrl, "reviewId");
            }

            response.sendRedirect(redirectUrl.toString());

        } catch (RuntimeException e) {
            throw new ServletException(
                    "Unable to redirect to book details.", e);
        }
    }

    @Override
    protected void doPost(HttpServletRequest request,
                          HttpServletResponse response)
            throws ServletException, IOException {

        request.setCharacterEncoding("UTF-8");

        long bookId = parseLong(
                request.getParameter("bookId"), 0);

        String action = request.getParameter("action");

        HttpSession session = request.getSession(false);

        User user = getAuthenticatedUser(session);

        // Require a logged-in Buyer.
        if (user == null || !user.hasRole("BUYER")) {
            response.sendRedirect(
                    request.getContextPath() + "/login");
            return;
        }

        if (bookId <= 0) {
            response.sendError(
                    HttpServletResponse.SC_BAD_REQUEST,
                    "Invalid book ID.");
            return;
        }

        // Verify CSRF token.
        if (!isValidCsrfToken(request, session)) {
            response.sendError(
                    HttpServletResponse.SC_FORBIDDEN,
                    "Invalid security token. Please reload the page.");
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

                if (!isReviewForBook(review, bookId)) {
                    response.sendError(
                            HttpServletResponse.SC_NOT_FOUND,
                            "Review not found.");
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

                if (!isReviewForBook(review, bookId)) {
                    response.sendError(
                            HttpServletResponse.SC_NOT_FOUND,
                            "Review not found.");
                    return;
                }

                success = reviewService.deleteReview(
                        user.getId(), reviewId);

            } else {
                response.sendError(
                        HttpServletResponse.SC_BAD_REQUEST,
                        "Invalid review action.");
                return;
            }

            String message = success
                    ? "Review operation completed successfully."
                    : "Unable to complete the review operation.";

            redirectWithMessage(
                    request, response, bookId, message);

        } catch (IllegalArgumentException
                 | IllegalStateException e) {

            redirectWithMessage(
                    request, response, bookId, e.getMessage());

        } catch (SecurityException e) {

            response.sendError(
                    HttpServletResponse.SC_FORBIDDEN,
                    e.getMessage());

        } catch (SQLException e) {

            throw new ServletException(
                    "Unable to save review.", e);
        }
    }

    private User getAuthenticatedUser(HttpSession session) {
        if (session == null) {
            return null;
        }

        Object authUser = session.getAttribute("authUser");

        if (authUser instanceof User) {
            return (User) authUser;
        }

        return null;
    }

    private boolean isReviewForBook(Review review, long bookId) {
        return review != null
                && review.getBookId() != null
                && review.getBookId().longValue() == bookId;
    }

    private boolean isValidCsrfToken(
            HttpServletRequest request,
            HttpSession session) {

        if (session == null) {
            return false;
        }

        String sessionToken = (String) session.getAttribute(
                REVIEW_CSRF_TOKEN);

        String requestToken = request.getParameter(
                REVIEW_CSRF_TOKEN);

        return sessionToken != null
                && requestToken != null
                && sessionToken.equals(requestToken);
    }

    private String getOrCreateCsrfToken(HttpSession session) {
        String token = (String) session.getAttribute(
                REVIEW_CSRF_TOKEN);

        if (token == null || token.trim().isEmpty()) {
            token = UUID.randomUUID().toString();

            session.setAttribute(
                    REVIEW_CSRF_TOKEN, token);
        }

        return token;
    }

    private void redirectWithMessage(
            HttpServletRequest request,
            HttpServletResponse response,
            long bookId,
            String message) throws IOException {

        String encodedMessage = encode(
                message == null ? "" : message);

        response.sendRedirect(
                request.getContextPath()
                        + "/book-detail?id=" + bookId
                        + "&message=" + encodedMessage);
    }

    private void copyParameter(
            HttpServletRequest request,
            StringBuilder url,
            String parameterName) {

        String value = request.getParameter(parameterName);

        if (value != null && !value.trim().isEmpty()) {
            url.append("&")
                    .append(parameterName)
                    .append("=")
                    .append(encode(value));
        }
    }

    private String encode(String value) {
        return URLEncoder.encode(
                value, StandardCharsets.UTF_8);
    }

    private long parseLong(String value, long defaultValue) {
        try {
            return Long.parseLong(value);
        } catch (NumberFormatException | NullPointerException e) {
            return defaultValue;
        }
    }
}
