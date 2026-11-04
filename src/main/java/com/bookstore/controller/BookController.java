
package com.bookstore.controller;

import com.bookstore.model.Book;
import com.bookstore.model.Review;
import com.bookstore.model.User;
import com.bookstore.service.BookService;
import com.bookstore.service.ReviewService;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.annotation.MultipartConfig;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import javax.servlet.http.Part;

import java.io.IOException;
import java.sql.SQLException;
import java.util.List;
import java.util.UUID;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;

@WebServlet(urlPatterns = { "/books", "/book-detail", "/dashboard/admin/books",
        "/dashboard/admin/books/create", "/dashboard/admin/books/edit", "/dashboard/admin/books/delete" })
@MultipartConfig(maxFileSize = 5 * 1024 * 1024, maxRequestSize = 8 * 1024 * 1024)
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

        if (path.startsWith("/dashboard/admin/books")) {
            if (!requireAdmin(request, response)) return;
            try {
                if ("/dashboard/admin/books".equals(path)) {
                    String message = request.getParameter("message");
                    String redirect = request.getContextPath() + "/dashboard/admin?view=books";
                    if (message != null && !message.isBlank()) redirect += "&message=" + java.net.URLEncoder.encode(message, "UTF-8");
                    response.sendRedirect(redirect);
                    return;
                } else if ("/dashboard/admin/books/create".equals(path)) {
                    request.setAttribute("book", new Book());
                    request.setAttribute("publishers", bookService.getActivePublishers());
                    request.setAttribute("categories", bookService.getActiveCategories());
                    request.setAttribute("authors", bookService.getActiveAuthors());
                    request.getRequestDispatcher("/views/admin/book-create.jsp").forward(request, response);
                } else if ("/dashboard/admin/books/edit".equals(path)) {
                    request.setAttribute("publishers", bookService.getActivePublishers());
                    request.setAttribute("categories", bookService.getActiveCategories());
                    request.setAttribute("authors", bookService.getActiveAuthors());
                    Book book = bookService.getBookDetail(parseId(request.getParameter("id")));
                    if (book == null) { response.sendError(HttpServletResponse.SC_NOT_FOUND); return; }
                    request.setAttribute("book", book);
                    request.getRequestDispatcher("/views/admin/book-edit.jsp").forward(request, response);
                }
            } catch (SQLException e) { throw new ServletException("Unable to load admin book data", e); }
            return;
        }

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

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        request.setCharacterEncoding("UTF-8");
        String path = request.getServletPath();
        if (!path.startsWith("/dashboard/admin/books")) { response.sendError(405); return; }
        if (!requireAdmin(request, response)) return;
        HttpSession session = request.getSession(false);
        String expected = session == null ? null : (String) session.getAttribute("adminCsrfToken");
        if (expected == null || !expected.equals(request.getParameter("csrfToken"))) {
            response.sendError(HttpServletResponse.SC_FORBIDDEN); return;
        }
        try {
            User admin = (User) session.getAttribute("authUser");
            long actorId = admin.getId();
            if ("/dashboard/admin/books/create".equals(path)) {
                Integer stock=parseNullableInt(request.getParameter("initialStock"));
                bookService.createBook(readBookForm(request),stock==null?0:stock);
                response.sendRedirect(request.getContextPath() + "/dashboard/admin?view=books&message=created");
            } else if ("/dashboard/admin/books/edit".equals(path)) {
                Book book = readBookForm(request);
                book.setId(parseId(request.getParameter("id")));
                bookService.updateBook(book,actorId);
                response.sendRedirect(request.getContextPath() + "/dashboard/admin?view=books&message=updated");
            } else if ("/dashboard/admin/books/delete".equals(path)) {
                bookService.softDeleteBook(parseId(request.getParameter("id")));
                response.sendRedirect(request.getContextPath() + "/dashboard/admin?view=books&message=deleted");
            } else response.sendError(405);
        } catch (IllegalArgumentException e) {
            HttpSession errorSession=request.getSession();
            errorSession.setAttribute("adminBookError",e.getMessage());
            response.sendRedirect(request.getContextPath()+"/dashboard/admin?view=books");
        } catch (SQLException e) { throw new ServletException("Unable to save book", e); }
    }

    private boolean requireAdmin(HttpServletRequest request, HttpServletResponse response) throws IOException {
        HttpSession session = request.getSession(false);
        User user = session == null ? null : (User) session.getAttribute("authUser");
        if (user == null || !user.hasRole("ADMIN")) { response.sendError(HttpServletResponse.SC_FORBIDDEN); return false; }
        synchronized (session) { if (session.getAttribute("adminCsrfToken") == null) session.setAttribute("adminCsrfToken", UUID.randomUUID().toString()); }
        return true;
    }

    private long parseId(String value) {
        try { long id = Long.parseLong(value); if (id > 0) return id; } catch (Exception ignored) { }
        throw new IllegalArgumentException("Invalid book ID.");
    }

    private Book readBookForm(HttpServletRequest request) throws IOException, ServletException {
        Book book = new Book();
        book.setTitle(request.getParameter("title"));
        book.setIsbn(request.getParameter("isbn"));
        book.setPublisherId(parseId(request.getParameter("publisherId")));
        book.setCategoryIds(parseIdList(request.getParameterValues("categoryIds")));
        book.setAuthorIds(parseIdList(request.getParameterValues("authorIds")));
        book.setPublicationYear(parseNullableInt(request.getParameter("publicationYear")));
        book.setEdition(parseNullableInt(request.getParameter("edition")));
        try { book.setPrice(new java.math.BigDecimal(request.getParameter("price"))); }
        catch (Exception e) { throw new IllegalArgumentException("Invalid book price."); }
        book.setDiscountPercent(parseNullableInt(request.getParameter("discountPercent")) == null ? 0 : parseNullableInt(request.getParameter("discountPercent")));
        book.setDescription(request.getParameter("description"));
        book.setPageCount(parseNullableInt(request.getParameter("pageCount")));
        book.setWeightGrams(parseNullableInt(request.getParameter("weightGrams")) == null ? 300 : parseNullableInt(request.getParameter("weightGrams")));
        book.setDimensions(request.getParameter("dimensions"));
        book.setCoverType(request.getParameter("coverType"));
        book.setLanguage(request.getParameter("language"));
        book.setStatus(request.getParameter("status") == null ? "ACTIVE" : request.getParameter("status"));
        String imageUrl = request.getParameter("imageUrl");
        Part coverImage = request.getPart("coverImage");
        if (coverImage != null && coverImage.getSize() > 0) {
            if (coverImage.getSize() > 5L * 1024 * 1024) throw new IllegalArgumentException("Cover image must be 5 MB or smaller.");
            String contentType = coverImage.getContentType();
            String extension;
            if ("image/jpeg".equalsIgnoreCase(contentType)) extension = ".jpg";
            else if ("image/png".equalsIgnoreCase(contentType)) extension = ".png";
            else throw new IllegalArgumentException("Cover image must be a JPG or PNG file.");
            String realPath = getServletContext().getRealPath("/static/uploads");
            if (realPath == null) throw new ServletException("The application upload directory is unavailable.");
            Path uploadDirectory = Paths.get(realPath);
            Files.createDirectories(uploadDirectory);
            String fileName = UUID.randomUUID() + extension;
            try (java.io.InputStream input = coverImage.getInputStream()) {
                Files.copy(input, uploadDirectory.resolve(fileName));
            }
            imageUrl = request.getContextPath() + "/static/uploads/" + fileName;
        }
        book.setImageUrl(imageUrl);
        return book;
    }

    private Integer parseNullableInt(String value) {
        if (value == null || value.trim().isEmpty()) return null;
        try { return Integer.valueOf(value); } catch (NumberFormatException e) { throw new IllegalArgumentException("Invalid numeric value."); }
    }

    private List<Long> parseIdList(String[] values) {
        List<Long> ids = new java.util.ArrayList<>();
        if (values == null) return ids;
        for (String value : values) {
            try { long id = Long.parseLong(value); if (id > 0 && !ids.contains(id)) ids.add(id); }
            catch (NumberFormatException ignored) { throw new IllegalArgumentException("Invalid category or author selection."); }
        }
        return ids;
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
