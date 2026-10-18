package com.bookstore.context;

import java.io.InputStream;
import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.Properties;

/**
 * DBContext - Manages JDBC Connection to Microsoft SQL Server (BookStoreDB)
 * Standard architectural implementation for SWD392.
 */
public class DBContext {

    private static String driver = "com.microsoft.sqlserver.jdbc.SQLServerDriver";
    private static String url = "jdbc:sqlserver://localhost:1433;databaseName=BookStoreDB;encrypt=true;trustServerCertificate=true";
    private static String user = "sa";
    private static String password = "123456";

    static {
        try (InputStream input = DBContext.class.getClassLoader().getResourceAsStream("db.properties")) {
            if (input != null) {
                Properties prop = new Properties();
                prop.load(input);
                driver = prop.getProperty("db.driver", driver);
                url = prop.getProperty("db.url", url);
                user = prop.getProperty("db.user", user);
                password = prop.getProperty("db.password", password);
            }
            Class.forName(driver);
        } catch (Exception e) {
            System.err.println("[DBContext] Configuration loading warning: " + e.getMessage());
        }
    }

    /**
     * Get a new connection to the database
     */
    public static Connection getConnection() throws SQLException {
        return DriverManager.getConnection(url, user, password);
    }

    /**
     * Test database connectivity (returns true if successful)
     */
    public static boolean testConnection() {
        try (Connection conn = getConnection()) {
            return conn != null && !conn.isClosed();
        } catch (Exception e) {
            return false;
        }
    }

    /**
     * Safely close JDBC resources
     */
    public static void close(Connection conn, PreparedStatement ps, ResultSet rs) {
        try {
            if (rs != null && !rs.isClosed()) rs.close();
        } catch (SQLException ignored) {}
        try {
            if (ps != null && !ps.isClosed()) ps.close();
        } catch (SQLException ignored) {}
        try {
            if (conn != null && !conn.isClosed()) conn.close();
        } catch (SQLException ignored) {}
    }

    /**
     * Main method to test database connectivity directly
     */
    public static void main(String[] args) {
        System.out.println("Testing database connection to: " + url);
        try (Connection conn = getConnection()) {
            if (conn != null && !conn.isClosed()) {
                System.out.println(">>> [SUCCESS] Database connection established successfully!");
            }
        } catch (Exception e) {
            System.err.println(">>> [FAILED] Database connection failed: " + e.getMessage());
        }
    }
}
