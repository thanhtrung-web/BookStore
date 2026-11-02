
package com.bookstore.service;

import com.bookstore.dao.BookDAO;
import com.bookstore.model.Book;

import java.sql.SQLException;
import java.util.List;
import com.bookstore.model.Publisher;
import com.bookstore.model.Category;
import com.bookstore.model.Author;

public class BookService {

    private final BookDAO bookDAO;

    public BookService() {
        this.bookDAO = new BookDAO();
    }

    public List<Book> getAdminBooks() throws SQLException { return bookDAO.getAdminBooks(); }
    public List<Book> getAdminBooks(String keyword,Long categoryId,Long authorId,java.math.BigDecimal minPrice,java.math.BigDecimal maxPrice) throws SQLException { return bookDAO.getAdminBooks(keyword,categoryId,authorId,minPrice,maxPrice); }
    public List<Publisher> getActivePublishers() throws SQLException { return bookDAO.getActivePublishers(); }
    public List<Category> getActiveCategories() throws SQLException { return bookDAO.getActiveCategories(); }
    public List<Author> getActiveAuthors() throws SQLException { return bookDAO.getActiveAuthors(); }
    public void createBook(Book book,int initialStock) throws SQLException { bookDAO.createBook(book,initialStock); }
    public void updateBook(Book book,long actorId) throws SQLException { if(book.getId()==null||book.getId()<=0) throw new IllegalArgumentException("Mã sách không hợp lệ."); bookDAO.updateBook(book,actorId); }
    public void softDeleteBook(long id) throws SQLException { bookDAO.softDeleteBook(id); }

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
