package com.bookstore.controller;

import com.bookstore.context.DBContext;
import com.bookstore.dao.BookDAO;
import com.bookstore.model.Book;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import java.io.IOException;
import java.util.List;

@WebServlet(name = "BookServlet", urlPatterns = { "/books" })
public class BookController extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request,
            HttpServletResponse response)
            throws ServletException, IOException {

        int page = 1;
        int pageSize = 10;

        String pageParam = request.getParameter("page");

        try {
            if (pageParam != null && !pageParam.isEmpty()) {
                page = Integer.parseInt(pageParam);
            }
        } catch (NumberFormatException e) {
            page = 1;
        }

        if (page < 1) {
            page = 1;
        }

        try {
            BookDAO bookDAO = new BookDAO();

            // Đếm tổng số sách
            int totalBooks = bookDAO.countBooks();

            // Tính tổng số trang
            int totalPages = (int) Math.ceil(
                    (double) totalBooks / pageSize);

            // Nếu page vượt quá tổng số trang thì đưa về trang cuối
            if (totalPages > 0 && page > totalPages) {
                page = totalPages;
            }

            // Lấy danh sách sách của trang hiện tại
            List<Book> books = bookDAO.getBooksByPage(page, pageSize);

            request.setAttribute("books", books);
            request.setAttribute("currentPage", page);
            request.setAttribute("totalPages", totalPages);
            request.setAttribute("totalBooks", totalBooks);

            request.getRequestDispatcher("/views/book-list.jsp")
                    .forward(request, response);
                    

        } catch (java.sql.SQLException e) {
            // Ghi lỗi để tiện kiểm tra trong console
            e.printStackTrace();

            // Trả về lỗi máy chủ nếu truy vấn database thất bại
            response.sendError(
                    HttpServletResponse.SC_INTERNAL_SERVER_ERROR,
                    "An error occurred while retrieving the book list.");
        }
    }
}