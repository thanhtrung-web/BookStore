package com.bookstore.controller;

import com.bookstore.context.DBContext;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.io.IOException;

/**
 * HomeController - Basic servlet routing to the homepage
 */
@WebServlet(name = "HomeController", urlPatterns = {"", "/home"})
public class HomeController extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        // Verify database connectivity
        boolean isConnected = DBContext.testConnection();
        request.setAttribute("dbStatus", isConnected);
        request.setAttribute("pageTitle", "BookStore Management System");
        
        request.getRequestDispatcher("/views/home.jsp").forward(request, response);
    }
}
