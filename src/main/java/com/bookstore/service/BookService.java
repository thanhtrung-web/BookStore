
package com.bookstore.service;

import com.bookstore.dao.BookDAO;
import com.bookstore.model.Book;

import java.sql.SQLException;
import java.util.List;

public class BookService {

    private final BookDAO bookDAO;

    public BookService() {
        this.bookDAO = new BookDAO();
    }

    // Count total books
    public int countBooks() throws SQLException {
        return bookDAO.countBooks();
    }

    // Get books by page
    public List<Book> getBooksByPage(int page, int pageSize)
            throws SQLException {

        // Validate input
        if (page < 1) {
            page = 1;
        }

        if (pageSize < 1) {
            pageSize = 10;
        }

        return bookDAO.getBooksByPage(page, pageSize);
    }

    // View book detail
    public Book getBookDetail(long id) throws SQLException {
        if (id <= 0) {
            return null;
        }

        return bookDAO.getBookById(id);
    }

    
    // Count search results
    public int countSearchBooks(String keyword) throws SQLException {
        if (keyword == null || keyword.trim().isEmpty()) {
            return 0;
        }

        return bookDAO.countSearchBooks(keyword.trim());
    }

    // Search books by keyword with pagination
    public List<Book> searchBooks(
            String keyword, int page, int pageSize) throws SQLException {

        if (keyword == null || keyword.trim().isEmpty()) {
            return new java.util.ArrayList<>();
        }

        if (page < 1) {
            page = 1;
        }

        if (pageSize < 1) {
            pageSize = 10;
        }

        return bookDAO.searchBooks(keyword.trim(), page, pageSize);
    }

}
