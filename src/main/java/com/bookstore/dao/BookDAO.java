
package com.bookstore.dao;

import com.bookstore.model.Book;
import com.bookstore.context.DBContext;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;

public class BookDAO {

    // Lấy danh sách sách của một trang
    public List<Book> getBooksByPage(int page, int pageSize)
            throws SQLException {

        List<Book> books = new ArrayList<>();

        int offset = (page - 1) * pageSize;

        String sql = "SELECT b.id, b.title, b.isbn, b.publisher_id, " +
                "b.publication_year, b.edition, b.price, " +
                "b.discount_percent, b.description, b.page_count, " +
                "b.dimensions, b.weight_grams, b.cover_type, " +
                "b.language, b.status, b.is_deleted, " +
                "b.created_at, b.updated_at, " +
                "p.name AS publisher_name, " +
                "bi.image_url AS image_url " +  //image
                "FROM books b " +
                "LEFT JOIN publishers p ON b.publisher_id = p.id " +
                "LEFT JOIN book_images bi ON b.id = bi.book_id " +  //image
                "AND bi.is_thumbnail = 1 " +  //image
                "WHERE b.is_deleted = 0 " +
                "ORDER BY b.id DESC " +   //sắp xếp sách theo id giảm dần
                "OFFSET ? ROWS FETCH NEXT ? ROWS ONLY";

        try (Connection conn = DBContext.getConnection();
                PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setInt(1, offset);
            ps.setInt(2, pageSize);

            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    Book book = new Book();

                    book.setId(rs.getLong("id"));
                    book.setTitle(rs.getString("title"));
                    book.setIsbn(rs.getString("isbn"));
                    book.setPublisherId(rs.getLong("publisher_id")); 

                    // Giữ null nếu cột SQL có giá trị NULL
                    int year = rs.getInt("publication_year");
                    book.setPublicationYear(
                            rs.wasNull() ? null : year);

                    int edition = rs.getInt("edition");
                    book.setEdition(
                            rs.wasNull() ? null : edition);

                    book.setPrice(rs.getBigDecimal("price"));
                    book.setDiscountPercent(
                            rs.getInt("discount_percent"));
                    book.setDescription(rs.getString("description"));

                    int pageCount = rs.getInt("page_count");
                    book.setPageCount(
                            rs.wasNull() ? null : pageCount);

                    book.setDimensions(rs.getString("dimensions"));
                    book.setWeightGrams(rs.getInt("weight_grams"));
                    book.setCoverType(rs.getString("cover_type"));
                    book.setLanguage(rs.getString("language"));
                    book.setStatus(rs.getString("status"));
                    book.setDeleted(rs.getBoolean("is_deleted"));
                    book.setCreatedAt(rs.getTimestamp("created_at").toLocalDateTime());
                    book.setUpdatedAt(rs.getTimestamp("updated_at").toLocalDateTime());
                    book.setPublisherName(rs.getString("publisher_name"));
                    book.setImageUrl(rs.getString("image_url"));

                    books.add(book);
                }
            }
        }

        return books;
    }

    // Đếm tổng số sách chưa bị xóa mềm
    public int countBooks() throws SQLException {

        String sql = "SELECT COUNT(*) FROM books WHERE is_deleted = 0";

        try (Connection conn = DBContext.getConnection();
                PreparedStatement ps = conn.prepareStatement(sql);
                ResultSet rs = ps.executeQuery()) {

            if (rs.next()) {
                return rs.getInt(1);
            }
        }

        return 0;
    }

    
public Book getBookById(long id) throws SQLException {
    String sql =
            "SELECT b.id, b.title, b.isbn, b.publisher_id, " +
            "b.publication_year, b.edition, b.price, " +
            "b.discount_percent, b.description, b.page_count, " +
            "b.dimensions, b.weight_grams, b.cover_type, " +
            "b.language, b.status, b.is_deleted, " +
            "b.created_at, b.updated_at, " +
            "p.name AS publisher_name, " +
            "bi.image_url AS image_url " +
            "FROM books b " +
            "LEFT JOIN publishers p ON b.publisher_id = p.id " +
            "LEFT JOIN book_images bi ON b.id = bi.book_id " +
            "AND bi.is_thumbnail = 1 " +
            "WHERE b.id = ? AND b.is_deleted = 0";

    try (Connection conn = DBContext.getConnection();
         PreparedStatement ps = conn.prepareStatement(sql)) {

        ps.setLong(1, id);

        try (ResultSet rs = ps.executeQuery()) {
            if (rs.next()) {
                Book book = new Book();

                book.setId(rs.getLong("id"));
                book.setTitle(rs.getString("title"));
                book.setIsbn(rs.getString("isbn"));
                book.setPublisherId(rs.getLong("publisher_id"));
                book.setPublisherName(rs.getString("publisher_name"));

                book.setPublicationYear(
                        (Integer) rs.getObject("publication_year"));
                book.setEdition(
                        (Integer) rs.getObject("edition"));

                book.setPrice(rs.getBigDecimal("price"));
                book.setDiscountPercent(
                        rs.getInt("discount_percent"));
                book.setDescription(rs.getString("description"));

                book.setPageCount(
                        (Integer) rs.getObject("page_count"));
                book.setDimensions(rs.getString("dimensions"));
                book.setWeightGrams(
                        (Integer) rs.getObject("weight_grams"));
                book.setCoverType(rs.getString("cover_type"));

                book.setLanguage(rs.getString("language"));
                book.setStatus(rs.getString("status"));
                book.setDeleted(rs.getBoolean("is_deleted"));

                book.setImageUrl(rs.getString("image_url"));

                return book;
            }
        }
    }

    return null;
}


    public static void main(String[] args) throws Exception {
        BookDAO test = new BookDAO();

        // Test đếm tổng số sách
        int totalBooks = test.countBooks();
        System.out.println("Total books: " + totalBooks);

        // Test lấy sách ở trang 1, mỗi trang 10 cuốn
        int page = 1;
        int pageSize = 10;

        List<Book> list = test.getBooksByPage(page, pageSize);

        System.out.println("Books in page " + page + ":");

        for (Book b : list) {
            System.out.println(
                    "ID: " + b.getId()
                            + " | Title: " + b.getTitle()
                            + " | ISBN: " + b.getIsbn()
                            + " | Publisher: " + b.getPublisherName()
                            +"anh" + b.getImageUrl()
                            + " | Price: " + b.getPrice());
        }
        System.out.println(test.getBookById(1));
    }

}
