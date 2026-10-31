
package com.bookstore.controller;

import com.bookstore.model.Book;
import com.bookstore.model.Review;
import com.bookstore.model.User;
import com.bookstore.service.BookService;
import com.bookstore.service.ReviewService;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

import java.io.IOException;
import java.sql.SQLException;
import java.util.List;
import java.util.UUID;

@WebServlet(urlPatterns = { "/books", "/book-detail" })
public class BookController extends HttpServlet {

    private BookService bookService;
    private ReviewService reviewService;

    @Override
    public void init() {
        bookService = new BookService();
        reviewService = new ReviewService();
    }

    @Override
    protected void doGet(HttpServletRequest request,
            HttpServletResponse response)
            throws ServletException, IOException {

        String path = request.getServletPath();

        try {
            if ("/books".equals(path)) {

                String keyword = request.getParameter("q");

                if (keyword != null && !keyword.trim().isEmpty()) {
                    searchBooks(request, response);
                } else {
                    viewBookList(request, response);
                }

            } else if ("/book-detail".equals(path)) {

                viewBookDetail(request, response);
            }

        } catch (SQLException e) {
            throw new ServletException(
                    "Error while processing book request", e);
        }
    }

    // View Book List
    private void viewBookList(HttpServletRequest request,
            HttpServletResponse response)
            throws ServletException, IOException, SQLException {

        int page = 1;
        int pageSize = 10;

        try {
            String pageParam = request.getParameter("page");

            if (pageParam != null) {
                page = Integer.parseInt(pageParam);
            }

        } catch (NumberFormatException e) {
            page = 1;
        }

        if (page < 1) {
            page = 1;
        }

        int totalBooks = bookService.countBooks();

        int totalPages = (int) Math.ceil(
                (double) totalBooks / pageSize);

        if (totalPages > 0 && page > totalPages) {
            page = totalPages;
        }

        List<Book> books = bookService.getBooksByPage(
                page, pageSize);

        request.setAttribute("books", books);
        request.setAttribute("currentPage", page);
        request.setAttribute("totalPages", totalPages);
        request.setAttribute("totalBooks", totalBooks);

        request.getRequestDispatcher(
                "/views/book-list.jsp").forward(request, response);
    }

    // View Book Detail
    private void viewBookDetail(HttpServletRequest request,
            HttpServletResponse response)
            throws ServletException, IOException, SQLException {

        String idParam = request.getParameter("id");

        try {
            long id = Long.parseLong(idParam);

            if (id <= 0) {
                response.sendError(
                        HttpServletResponse.SC_BAD_REQUEST,
                        "Invalid book ID");
                return;
            }

            Book book = bookService.getBookDetail(id);

            if (book == null) {
                response.sendError(
                        HttpServletResponse.SC_NOT_FOUND,
                        "Book not found");
                return;
            }

            // Initialize CSRF tokens
            HttpSession session = request.getSession();

            synchronized (session) {

                if (session.getAttribute("cartCsrfToken") == null) {
                    session.setAttribute(
                            "cartCsrfToken",
                            UUID.randomUUID().toString());
                }

                if (session.getAttribute("reviewCsrfToken") == null) {
                    session.setAttribute(
                            "reviewCsrfToken",
                            UUID.randomUUID().toString());
                }
            }

            // Set book information
            request.setAttribute("book", book);

            // Load review information
            loadReviewData(request, id);

            // Forward to book detail page
            request.getRequestDispatcher(
                    "/views/book-detail.jsp").forward(request, response);

        } catch (NumberFormatException e) {
            response.sendError(
                    HttpServletResponse.SC_BAD_REQUEST,
                    "Invalid book ID");
        }
    }

    // Load Review Data
    private void loadReviewData(
            HttpServletRequest request,
            long bookId) throws SQLException {

        final int pageSize = 5;

        int page = 1;

        String sort = request.getParameter("sort");
        String ratingParam = request.getParameter("rating");

        if (sort == null || sort.trim().isEmpty()) {
            sort = "newest";
        }

        Integer ratingFilter = null;

        try {
            if (ratingParam != null
                    && !ratingParam.trim().isEmpty()) {

                ratingFilter = Integer.parseInt(ratingParam);
            }

        } catch (NumberFormatException e) {
            ratingFilter = null;
        }

        try {
            String pageParam = request.getParameter("reviewPage");

            if (pageParam != null) {
                page = Integer.parseInt(pageParam);
            }

        } catch (NumberFormatException e) {
            page = 1;
        }

        if (page < 1) {
            page = 1;
        }

        // Count reviews
        int totalReviews = reviewService.countReviews(
                bookId, ratingFilter);

        int totalPages = (int) Math.ceil(
                (double) totalReviews / pageSize);

        if (totalPages > 0 && page > totalPages) {
            page = totalPages;
        }

        // Get review list
        List<Review> reviews = reviewService.getReviews(
                bookId,
                page,
                pageSize,
                sort,
                ratingFilter
        );

        // Get average rating
        double averageRating = reviewService.getAverageRating(bookId);

        // Get logged-in user
        User authUser = (User) request.getSession()
                .getAttribute("authUser");

        // Check logged-in Buyer
        boolean isBuyer = authUser != null
                && authUser.getId() != null
                && authUser.hasRole("BUYER");

        Review ownReview = null;
        boolean canWriteReview = false;

        if (isBuyer) {

            long userId = authUser.getId();

            // Get current user's review
            ownReview = reviewService.getOwnReview(
                    userId, bookId);

            // Check whether the user can write a review
            canWriteReview = reviewService.canWriteReview(
                    userId, bookId);
        }

        // Handle Edit Review Request
        // Only the review owner can edit an approved review
        String action = request.getParameter("action");
        String reviewIdParam = request.getParameter("reviewId");

        if (isBuyer
                && "edit".equals(action)
                && reviewIdParam != null
                && !reviewIdParam.trim().isEmpty()) {

            try {
                long reviewId = Long.parseLong(reviewIdParam);

                Review editReview = reviewService.getReviewById(
                        reviewId);

                if (editReview != null
                        && editReview.getUserId() != null
                        && editReview.getUserId().equals(authUser.getId())
                        && editReview.getBookId() != null
                        && editReview.getBookId().longValue() == bookId
                        && "APPROVED".equalsIgnoreCase(
                                editReview.getStatus())) {

                    request.setAttribute(
                            "editReview", editReview);
                }

            } catch (NumberFormatException e) {
                // Ignore invalid review ID.
            }
        }

        // Send review data to JSP
        request.setAttribute("reviews", reviews);
        request.setAttribute("averageRating", averageRating);
        request.setAttribute("totalReviews", totalReviews);
        request.setAttribute("totalPages", totalPages);
        request.setAttribute("currentPage", page);
        request.setAttribute("sort", sort);
        request.setAttribute("ratingFilter", ratingFilter);
        request.setAttribute("isBuyer", isBuyer);
        request.setAttribute("ownReview", ownReview);
        request.setAttribute("canWriteReview", canWriteReview);

        // Display review success/error message
        String message = request.getParameter("message");

        if (message != null && !message.trim().isEmpty()) {
            request.setAttribute("reviewMessage", message);
        }
    }

    // Search Book
    private void searchBooks(HttpServletRequest request,
            HttpServletResponse response)
            throws ServletException, IOException, SQLException {

        String keyword = request.getParameter("q").trim();

        System.out.println(
                "SEARCH KEYWORD = " + keyword);

        int page = 1;
        int pageSize = 10;

        try {
            String pageParam = request.getParameter("page");

            if (pageParam != null) {
                page = Integer.parseInt(pageParam);
            }

        } catch (NumberFormatException e) {
            page = 1;
        }

        if (page < 1) {
            page = 1;
        }

        int totalBooks = bookService.countSearchBooks(keyword);

        int totalPages = (int) Math.ceil(
                (double) totalBooks / pageSize);

        if (totalPages > 0 && page > totalPages) {
            page = totalPages;
        }

        List<Book> books = bookService.searchBooks(
                keyword, page, pageSize);

        request.setAttribute("books", books);
        request.setAttribute("currentPage", page);
        request.setAttribute("totalPages", totalPages);
        request.setAttribute("totalBooks", totalBooks);
        request.setAttribute("keyword", keyword);
        request.setAttribute("pageTitle", "Search Results");

        request.getRequestDispatcher(
                "/views/book-list.jsp").forward(request, response);
    }
}
