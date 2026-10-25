
package com.bookstore.controller;

import com.bookstore.model.User;
import com.bookstore.service.UserService;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import java.io.IOException;
import java.net.URLEncoder;
import java.nio.charset.StandardCharsets;
import java.sql.SQLException;

/**
 * UserController handles administrator user management requests.
 */
@WebServlet(name = "UserController", urlPatterns = {"/admin/users"})
public class UserController extends HttpServlet {

    private static final long serialVersionUID = 1L;

    private UserService userService;

    /**
     * Initializes the user management service.
     *
     * @throws ServletException if initialization fails
     */
    @Override
    public void init() throws ServletException {
        super.init();
        userService = new UserService();
    }

    /**
     * Displays the user management page for administrators.
     *
     * @param request the HTTP request
     * @param response the HTTP response
     * @throws ServletException if page forwarding fails
     * @throws IOException if a communication error occurs
     */
    @Override
    protected void doGet(HttpServletRequest request,
                         HttpServletResponse response)
            throws ServletException, IOException {

        if (!isAdmin(request)) {
            response.sendError(HttpServletResponse.SC_FORBIDDEN);
            return;
        }

        try {
            request.setAttribute("users", userService.getAllUsers());

            request.getRequestDispatcher("/views/admin/user-list.jsp")
                    .forward(request, response);

        } catch (SQLException ex) {
            getServletContext().log(
                    "Failed to load user management page.", ex);

            response.sendError(
                    HttpServletResponse.SC_INTERNAL_SERVER_ERROR,
                    "Unable to load user accounts.");
        }
    }

    /**
     * Locks or unlocks a user account.
     *
     * @param request the HTTP request
     * @param response the HTTP response
     * @throws ServletException if request processing fails
     * @throws IOException if a communication error occurs
     */
    @Override
    protected void doPost(HttpServletRequest request,
                          HttpServletResponse response)
            throws ServletException, IOException {

        if (!isAdmin(request)) {
            response.sendError(HttpServletResponse.SC_FORBIDDEN);
            return;
        }

        String userIdValue = request.getParameter("userId");
        String status = request.getParameter("status");

        try {
            if (userIdValue == null || userIdValue.trim().isEmpty()) {
                response.sendError(
                        HttpServletResponse.SC_BAD_REQUEST,
                        "User ID is required.");
                return;
            }

            long userId = Long.parseLong(userIdValue);

            HttpSession session = request.getSession(false);
            User currentUser = (User) session.getAttribute("authUser");

            if (currentUser.getId() != null
                    && currentUser.getId().longValue() == userId) {
                response.sendError(
                        HttpServletResponse.SC_BAD_REQUEST,
                        "You cannot change your own account status.");
                return;
            }

            boolean updated =
                    userService.updateUserStatus(userId, status);

            String message = updated
                    ? "User account status updated successfully."
                    : "User account was not found.";

            response.sendRedirect(
                    request.getContextPath()
                    + "/admin/users?message="
                    + URLEncoder.encode(
                            message, StandardCharsets.UTF_8.name()));

        } catch (IllegalArgumentException ex) {
            response.sendError(
                    HttpServletResponse.SC_BAD_REQUEST,
                    "Invalid user ID or account status.");

        } catch (SQLException ex) {
            getServletContext().log(
                    "Failed to update user account status.", ex);

            response.sendError(
                    HttpServletResponse.SC_INTERNAL_SERVER_ERROR,
                    "Unable to update user account.");
        }
    }

    /**
     * Checks whether the current session belongs to an administrator.
     *
     * @param request the HTTP request
     * @return true if the authenticated user is an administrator
     */
    private boolean isAdmin(HttpServletRequest request) {
        HttpSession session = request.getSession(false);

        if (session == null) {
            return false;
        }

        Object authenticatedUser = session.getAttribute("authUser");
        Object role = session.getAttribute("userRole");

        return authenticatedUser instanceof User
                && "ADMIN".equals(role);
    }
}
