
package com.bookstore.controller;

import com.bookstore.model.Book;
import com.bookstore.service.BookService;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import java.io.IOException;
import java.sql.SQLException;
import java.util.List;

@WebServlet(urlPatterns = { "/books", "/book-detail" })
public class BookController extends HttpServlet {

    private BookService bookService;

    @Override
    public void init() {
        bookService = new BookService();
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

            request.setAttribute("book", book);

            request.getRequestDispatcher(
                    "/views/book-detail.jsp").forward(request, response);

        } catch (NumberFormatException e) {
            response.sendError(
                    HttpServletResponse.SC_BAD_REQUEST,
                    "Invalid book ID");
        }
    }

    
    // Search Book
    private void searchBooks(HttpServletRequest request,
                             HttpServletResponse response)
            throws ServletException, IOException, SQLException {

        String keyword = request.getParameter("q").trim();
        System.out.println("SEARCH KEYWORD = " + request.getParameter("q"));

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

        // Avoid requesting a page beyond the search results
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
        request.setAttribute("pageTitle", "Kết quả tìm kiếm");

        request.getRequestDispatcher(
                "/views/book-list.jsp"
        ).forward(request, response);
    }

}
