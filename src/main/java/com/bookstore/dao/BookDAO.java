
package com.bookstore.dao;

import com.bookstore.model.Book;
import com.bookstore.context.DBContext;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;
import com.bookstore.model.Publisher;
import com.bookstore.model.Category;
import com.bookstore.model.Author;

public class BookDAO {

    public List<Book> getAdminBooks() throws SQLException {
        return getAdminBooks(null, null, null, null, null);
    }

    public List<Book> getAdminBooks(String keyword, Long categoryId, Long authorId,
                                    java.math.BigDecimal minPrice, java.math.BigDecimal maxPrice) throws SQLException {
        List<Book> books = new ArrayList<>();
        String sql = "SELECT b.id,b.title,b.isbn,b.price,b.discount_percent,b.status,b.is_deleted,p.name publisher_name,bi.image_url, " +
                "COALESCE(authors.author_names,N'') author_names,COALESCE(categories.category_names,N'') category_names, " +
                "COALESCE(inv.stock_quantity-inv.reserved_quantity,0) available_stock " +
                "FROM dbo.books b LEFT JOIN dbo.publishers p ON p.id=b.publisher_id " +
                "LEFT JOIN dbo.inventories inv ON inv.book_id=b.id " +
                "OUTER APPLY (SELECT STRING_AGG(a.name,N', ') author_names FROM dbo.book_authors ba JOIN dbo.authors a ON a.id=ba.author_id WHERE ba.book_id=b.id AND a.is_deleted=0) authors " +
                "OUTER APPLY (SELECT STRING_AGG(c.name,N', ') category_names FROM dbo.book_categories bc JOIN dbo.categories c ON c.id=bc.category_id WHERE bc.book_id=b.id AND c.is_deleted=0) categories " +
                "OUTER APPLY (SELECT TOP 1 image_url FROM dbo.book_images WHERE book_id=b.id ORDER BY is_thumbnail DESC,display_order,id) bi " +
                "WHERE (? IS NULL OR b.title LIKE ? OR b.isbn LIKE ? OR p.name LIKE ?) " +
                "AND (? IS NULL OR EXISTS(SELECT 1 FROM dbo.book_categories fbc WHERE fbc.book_id=b.id AND fbc.category_id=?)) " +
                "AND (? IS NULL OR EXISTS(SELECT 1 FROM dbo.book_authors fba WHERE fba.book_id=b.id AND fba.author_id=?)) " +
                "AND (? IS NULL OR b.price>=?) AND (? IS NULL OR b.price<=?) " +
                "ORDER BY b.created_at DESC,b.id DESC";
        try (Connection c=DBContext.getConnection(); PreparedStatement ps=c.prepareStatement(sql)) {
            String pattern = keyword == null || keyword.isBlank() ? null : "%" + keyword.trim() + "%";
            ps.setString(1, pattern); ps.setString(2, pattern); ps.setString(3, pattern); ps.setString(4, pattern);
            if (categoryId == null) { ps.setNull(5, java.sql.Types.BIGINT); ps.setNull(6, java.sql.Types.BIGINT); }
            else { ps.setLong(5, categoryId); ps.setLong(6, categoryId); }
            if (authorId == null) { ps.setNull(7, java.sql.Types.BIGINT); ps.setNull(8, java.sql.Types.BIGINT); }
            else { ps.setLong(7, authorId); ps.setLong(8, authorId); }
            if (minPrice == null) { ps.setNull(9, java.sql.Types.DECIMAL); ps.setNull(10, java.sql.Types.DECIMAL); }
            else { ps.setBigDecimal(9, minPrice); ps.setBigDecimal(10, minPrice); }
            if (maxPrice == null) { ps.setNull(11, java.sql.Types.DECIMAL); ps.setNull(12, java.sql.Types.DECIMAL); }
            else { ps.setBigDecimal(11, maxPrice); ps.setBigDecimal(12, maxPrice); }
            try (ResultSet rs=ps.executeQuery()) {
            while(rs.next()) { Book b=new Book(); b.setId(rs.getLong("id")); b.setTitle(rs.getString("title")); b.setIsbn(rs.getString("isbn")); b.setPrice(rs.getBigDecimal("price")); b.setDiscountPercent(rs.getInt("discount_percent")); b.setStatus(rs.getString("status")); b.setDeleted(rs.getBoolean("is_deleted")); b.setPublisherName(rs.getString("publisher_name")); b.setImageUrl(rs.getString("image_url")); b.setAuthorNames(rs.getString("author_names")); b.setCategoryNames(rs.getString("category_names")); b.setAvailableStock(rs.getInt("available_stock")); books.add(b); }
            }
        }
        return books;
    }

    public List<Publisher> getActivePublishers() throws SQLException {
        List<Publisher> result=new ArrayList<>();
        try(Connection c=DBContext.getConnection(); PreparedStatement ps=c.prepareStatement("SELECT id,name FROM dbo.publishers WHERE is_deleted=0 ORDER BY name"); ResultSet rs=ps.executeQuery()) { while(rs.next()) { Publisher p=new Publisher(); p.setId(rs.getLong("id")); p.setName(rs.getString("name")); result.add(p); } }
        return result;
    }

    public List<Category> getActiveCategories() throws SQLException {
        List<Category> result = new ArrayList<>();
        try (Connection c=DBContext.getConnection(); PreparedStatement ps=c.prepareStatement("SELECT id,name FROM dbo.categories WHERE is_deleted=0 ORDER BY name"); ResultSet rs=ps.executeQuery()) {
            while(rs.next()) { Category item=new Category(); item.setId(rs.getLong("id")); item.setName(rs.getString("name")); result.add(item); }
        }
        return result;
    }

    public List<Author> getActiveAuthors() throws SQLException {
        List<Author> result = new ArrayList<>();
        try (Connection c=DBContext.getConnection(); PreparedStatement ps=c.prepareStatement("SELECT id,name FROM dbo.authors WHERE is_deleted=0 ORDER BY name"); ResultSet rs=ps.executeQuery()) {
            while(rs.next()) { Author item=new Author(); item.setId(rs.getLong("id")); item.setName(rs.getString("name")); result.add(item); }
        }
        return result;
    }

    public void createBook(Book b, int initialStock) throws SQLException {
        validate(b);
        if(initialStock<0) throw new IllegalArgumentException("Initial stock cannot be negative.");
        String sql="INSERT INTO dbo.books(title,isbn,publisher_id,publication_year,edition,price,discount_percent,description,page_count,dimensions,weight_grams,cover_type,language,status) VALUES(?,?,?,?,?,?,?,?,?,?,?,?,?,?)";
        try(Connection c=DBContext.getConnection()) { c.setAutoCommit(false); try {
            assertUniqueIsbn(c, b.getIsbn(), null);
            long id;
            try(PreparedStatement ps=c.prepareStatement(sql, java.sql.Statement.RETURN_GENERATED_KEYS)) { bindBook(ps,b); ps.executeUpdate(); try(ResultSet rs=ps.getGeneratedKeys()){if(!rs.next()) throw new SQLException("Không lấy được mã sách vừa tạo."); id=rs.getLong(1);} }
            ensureInventory(c,id,initialStock); saveImage(c,id,b.getImageUrl()); replaceBookAssociations(c, id, b);
            c.commit();
        } catch(SQLException|RuntimeException e){c.rollback(); throw e;} }
    }

    public void updateBook(Book b, long actorId) throws SQLException {
        validate(b);
        String sql="UPDATE dbo.books SET title=?,isbn=?,publisher_id=?,publication_year=?,edition=?,price=?,discount_percent=?,description=?,page_count=?,dimensions=?,weight_grams=?,cover_type=?,language=?,status=?,updated_at=GETDATE() WHERE id=? AND is_deleted=0";
        try(Connection c=DBContext.getConnection()) { c.setAutoCommit(false); try {
            assertUniqueIsbn(c, b.getIsbn(), b.getId());
            java.math.BigDecimal previousSalePrice = loadCurrentSalePrice(c, b.getId());
            try(PreparedStatement ps=c.prepareStatement(sql)) { bindBook(ps,b); ps.setLong(15,b.getId()); if(ps.executeUpdate()!=1) throw new IllegalArgumentException("Không tìm thấy sách cần cập nhật."); }
            saveImage(c,b.getId(),b.getImageUrl()); replaceBookAssociations(c, b.getId(), b);
            if (previousSalePrice.compareTo(b.getSalePrice()) != 0) {
                try (PreparedStatement ps = c.prepareStatement("INSERT INTO dbo.book_price_history(book_id,old_price,new_price,changed_by,reason) VALUES(?,?,?,?,?)")) {
                    ps.setLong(1, b.getId()); ps.setBigDecimal(2, previousSalePrice); ps.setBigDecimal(3, b.getSalePrice()); ps.setLong(4, actorId); ps.setNString(5, "Admin updated original price or discount."); ps.executeUpdate();
                }
            }
            c.commit();
        } catch(SQLException|RuntimeException e){c.rollback(); throw e;} }
    }

    public void softDeleteBook(long id) throws SQLException {
        if(id<=0) throw new IllegalArgumentException("Mã sách không hợp lệ.");
        try(Connection c=DBContext.getConnection()) { c.setAutoCommit(false); try {
            try(PreparedStatement ps=c.prepareStatement("UPDATE dbo.books SET is_deleted=1,status='INACTIVE',updated_at=GETDATE() WHERE id=? AND is_deleted=0")){ps.setLong(1,id); if(ps.executeUpdate()!=1) throw new IllegalArgumentException("Sách không tồn tại hoặc đã được xóa.");}
            c.commit();
        } catch(SQLException|RuntimeException e){c.rollback(); throw e;} }
    }

    private java.math.BigDecimal loadCurrentSalePrice(Connection connection, long id) throws SQLException {
        try (PreparedStatement ps=connection.prepareStatement("SELECT price,discount_percent FROM dbo.books WHERE id=? AND is_deleted=0")) {
            ps.setLong(1,id);
            try (ResultSet rs=ps.executeQuery()) {
                if (!rs.next()) throw new IllegalArgumentException("Book not found.");
                java.math.BigDecimal price=rs.getBigDecimal("price");
                int discount=rs.getInt("discount_percent");
                return price.multiply(java.math.BigDecimal.valueOf(100-discount)).divide(java.math.BigDecimal.valueOf(100),2,java.math.RoundingMode.HALF_UP);
            }
        }
    }

    private void assertUniqueIsbn(Connection connection, String isbn, Long excludedBookId) throws SQLException {
        String sql = "SELECT 1 FROM dbo.books WHERE isbn=? AND (? IS NULL OR id<>?)";
        try (PreparedStatement ps = connection.prepareStatement(sql)) {
            ps.setString(1, isbn.trim());
            if (excludedBookId == null) {
                ps.setNull(2, java.sql.Types.BIGINT);
                ps.setNull(3, java.sql.Types.BIGINT);
            } else {
                ps.setLong(2, excludedBookId);
                ps.setLong(3, excludedBookId);
            }
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) throw new IllegalArgumentException("ISBN is already in use.");
            }
        }
    }

    private void replaceBookAssociations(Connection connection, long bookId, Book book) throws SQLException {
        try (PreparedStatement ps = connection.prepareStatement("DELETE FROM dbo.book_categories WHERE book_id=?")) {
            ps.setLong(1, bookId); ps.executeUpdate();
        }
        try (PreparedStatement ps = connection.prepareStatement("DELETE FROM dbo.book_authors WHERE book_id=?")) {
            ps.setLong(1, bookId); ps.executeUpdate();
        }
        try (PreparedStatement ps = connection.prepareStatement("INSERT INTO dbo.book_categories(book_id,category_id) VALUES(?,?)")) {
            for (Long categoryId : book.getCategoryIds()) {
                if (categoryId == null || categoryId <= 0) continue;
                ps.setLong(1, bookId); ps.setLong(2, categoryId); ps.addBatch();
            }
            ps.executeBatch();
        }
        try (PreparedStatement ps = connection.prepareStatement("INSERT INTO dbo.book_authors(book_id,author_id,is_primary) VALUES(?,?,?)")) {
            boolean primary = true;
            for (Long authorId : book.getAuthorIds()) {
                if (authorId == null || authorId <= 0) continue;
                ps.setLong(1, bookId); ps.setLong(2, authorId); ps.setBoolean(3, primary); ps.addBatch(); primary = false;
            }
            ps.executeBatch();
        }
    }

    private void bindBook(PreparedStatement ps, Book b) throws SQLException {
        ps.setNString(1,b.getTitle().trim()); ps.setString(2,b.getIsbn().trim()); ps.setLong(3,b.getPublisherId());
        if(b.getPublicationYear()==null) ps.setNull(4,java.sql.Types.INTEGER); else ps.setInt(4,b.getPublicationYear());
        if(b.getEdition()==null) ps.setNull(5,java.sql.Types.INTEGER); else ps.setInt(5,b.getEdition());
        ps.setBigDecimal(6,b.getPrice()); ps.setInt(7,b.getDiscountPercent()); ps.setNString(8,b.getDescription());
        if(b.getPageCount()==null) ps.setNull(9,java.sql.Types.INTEGER); else ps.setInt(9,b.getPageCount());
        ps.setString(10,b.getDimensions()); ps.setInt(11,b.getWeightGrams()==null?300:b.getWeightGrams()); ps.setNString(12,b.getCoverType()); ps.setNString(13,b.getLanguage()); ps.setString(14,b.getStatus());
    }

    private void validate(Book b) {
        if(b.getTitle()==null||b.getTitle().trim().isEmpty()||b.getTitle().trim().length()>255) throw new IllegalArgumentException("Book title is required and must not exceed 255 characters.");
        if(b.getIsbn()==null||b.getIsbn().trim().isEmpty()||b.getIsbn().trim().length()>20) throw new IllegalArgumentException("ISBN is required and must not exceed 20 characters.");
        if(b.getPublisherId()==null||b.getPublisherId()<=0) throw new IllegalArgumentException("Select a publisher.");
        if(b.getPrice()==null||b.getPrice().signum()<=0) throw new IllegalArgumentException("Sale price must be greater than zero.");
        if(b.getDiscountPercent()<0||b.getDiscountPercent()>=100) throw new IllegalArgumentException("Discount must be from 0% to 99% so the sale price remains positive.");
        if(!"ACTIVE".equals(b.getStatus())&&!"INACTIVE".equals(b.getStatus())) throw new IllegalArgumentException("Invalid book status.");
    }

    private void ensureInventory(Connection c,long id,int initialStock) throws SQLException { try(PreparedStatement ps=c.prepareStatement("IF NOT EXISTS(SELECT 1 FROM dbo.inventories WHERE book_id=?) INSERT INTO dbo.inventories(book_id,stock_quantity,reserved_quantity,low_stock_threshold) VALUES(?,?,0,10)")){ps.setLong(1,id);ps.setLong(2,id);ps.setInt(3,initialStock);ps.executeUpdate();} }
    private void saveImage(Connection c,long id,String url) throws SQLException { if(url==null||url.trim().isEmpty()) return; try(PreparedStatement ps=c.prepareStatement("IF EXISTS(SELECT 1 FROM dbo.book_images WHERE book_id=? AND is_thumbnail=1) UPDATE dbo.book_images SET image_url=?,display_order=0 WHERE book_id=? AND is_thumbnail=1 ELSE INSERT INTO dbo.book_images(book_id,image_url,is_thumbnail,display_order) VALUES(?,?,1,0)")){ps.setLong(1,id);ps.setString(2,url.trim());ps.setLong(3,id);ps.setLong(4,id);ps.setString(5,url.trim());ps.executeUpdate();} }

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
        Book foundBook = null;

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
                foundBook = book;
            }
        }
        if (foundBook != null) {
            foundBook.setCategoryIds(loadAssociationIds(conn, "book_categories", "category_id", id));
            foundBook.setAuthorIds(loadAssociationIds(conn, "book_authors", "author_id", id));
            return foundBook;
        }
    }

    return null;
}

private List<Long> loadAssociationIds(Connection connection, String table, String idColumn, long bookId) throws SQLException {
    // Table and column names are fixed internal constants at call sites.
    List<Long> ids = new ArrayList<>();
    String sql = "SELECT " + idColumn + " FROM dbo." + table + " WHERE book_id=?";
    try (PreparedStatement ps = connection.prepareStatement(sql)) {
        ps.setLong(1, bookId);
        try (ResultSet rs = ps.executeQuery()) { while (rs.next()) ids.add(rs.getLong(1)); }
    }
    return ids;
}


public int countSearchBooks(String keyword) throws SQLException {
    String sql =
            "SELECT COUNT(*) " +
            "FROM books b " +
            "WHERE b.is_deleted = 0 " +
            "AND ( " +
            "    b.title LIKE ? " +
            "    OR EXISTS ( " +
            "        SELECT 1 " +
            "        FROM book_authors ba " +
            "        JOIN authors a ON ba.author_id = a.id " +
            "        WHERE ba.book_id = b.id " +
            "        AND a.name LIKE ? " +
            "    ) " +
            ")";

    try (Connection conn = DBContext.getConnection();
         PreparedStatement ps = conn.prepareStatement(sql)) {

        String searchPattern = "%" + keyword.trim() + "%";

        ps.setString(1, searchPattern);
        ps.setString(2, searchPattern);

        try (ResultSet rs = ps.executeQuery()) {
            if (rs.next()) {
                return rs.getInt(1);
            }
        }
    }

    return 0;
}


public List<Book> searchBooks(
        String keyword, int page, int pageSize) throws SQLException {

    List<Book> books = new ArrayList<>();

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
            "OUTER APPLY ( " +
            "    SELECT TOP 1 bi2.image_url " +
            "    FROM book_images bi2 " +
            "    WHERE bi2.book_id = b.id " +
            "    AND bi2.is_thumbnail = 1 " +
            "    ORDER BY bi2.display_order " +
            ") bi " +
            "WHERE b.is_deleted = 0 " +
            "AND ( " +
            "    b.title LIKE ? " +
            "    OR EXISTS ( " +
            "        SELECT 1 " +
            "        FROM book_authors ba " +
            "        JOIN authors a ON ba.author_id = a.id " +
            "        WHERE ba.book_id = b.id " +
            "        AND a.name LIKE ? " +
            "    ) " +
            ") " +
            "ORDER BY b.id DESC " +
            "OFFSET ? ROWS FETCH NEXT ? ROWS ONLY";

    try (Connection conn = DBContext.getConnection();
         PreparedStatement ps = conn.prepareStatement(sql)) {

        String searchPattern = "%" + keyword.trim() + "%";

        ps.setString(1, searchPattern);
        ps.setString(2, searchPattern);
        ps.setInt(3, (page - 1) * pageSize);
        ps.setInt(4, pageSize);

        try (ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
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

                books.add(book);
            }
        }
    }

    return books;
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
