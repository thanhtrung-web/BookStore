package com.bookstore.controller;

import com.bookstore.model.User;
import com.bookstore.service.UserService;
import com.bookstore.service.UserService.PasswordChangeResult;
import com.bookstore.service.UserService.ProfileUpdateResult;

import javax.servlet.ServletException;
import javax.servlet.annotation.MultipartConfig;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import javax.servlet.http.Part;
import java.io.File;
import java.io.IOException;
import java.io.InputStream;
import java.net.URLEncoder;
import java.nio.charset.StandardCharsets;
import java.nio.file.Files;
import java.nio.file.StandardCopyOption;
import java.sql.SQLException;

/**
 * Controller for User Management (Customer Profile, Password Change, and
 * Management Dashboards).
 * Handles:
 * - GET /profile -> UC-43 View Own Profile
 * - POST /profile -> UC-44 Update Own Profile
 * - GET /change-password -> UC-05 View Change Password Tab
 * - POST /change-password -> UC-05 Submit Password Change
 * - GET /dashboard/admin -> Administrator Portal Dashboard
 * - GET /dashboard/staff -> Staff Workspace Dashboard
 * - GET /dashboard/admin/users -> Administrator View All Users
 * - POST /dashboard/admin/users -> Administrator Lock / Unlock User Status
 */
@WebServlet(name = "UserController", urlPatterns = {
        "/profile",
        "/change-password",
        "/dashboard/admin",
        "/dashboard/staff",
        "/dashboard/admin/users"
})
@MultipartConfig(fileSizeThreshold = 1024 * 1024, // 1 MB
        maxFileSize = 2 * 1024 * 1024, // 2 MB max per avatar
        maxRequestSize = 5 * 1024 * 1024 // 5 MB max request
)
public class UserController extends HttpServlet {

    private static final long serialVersionUID = 1L;
    private static final String PROFILE_VIEW = "/views/account/profile.jsp";
    private static final String ADMIN_DASHBOARD_VIEW = "/views/admin/dashboard.jsp";
    private static final String STAFF_DASHBOARD_VIEW = "/views/staff/dashboard.jsp";
    private static final String ADMIN_USERS_VIEW = "/views/admin/user-list.jsp";

    private UserService userService;

    @Override
    public void init() throws ServletException {
        super.init();
        this.userService = new UserService();
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String servletPath = request.getServletPath();
        // Admin lock / unlock user account
        // Redirect old user management URL to the integrated dashboard
        if ("/dashboard/admin/users".equals(servletPath)) {
            if (!isAdmin(request)) {
                response.sendRedirect(request.getContextPath() + "/login");
                return;
            }

            response.sendRedirect(
                    request.getContextPath() + "/dashboard/admin?view=users");
            return;
        }
        // 1. Admin Portal Dashboard
        if ("/dashboard/admin".equals(servletPath)) {
            if (!isAdmin(request)) {
                response.sendRedirect(request.getContextPath() + "/login");
                return;
            }

            try {
                request.setAttribute("users", userService.getAllUsers());
            } catch (SQLException ex) {
                getServletContext().log("Failed to load users for dashboard.", ex);
                response.sendError(
                        HttpServletResponse.SC_INTERNAL_SERVER_ERROR,
                        "Unable to load user accounts.");
                return;
            }

            request.getRequestDispatcher(ADMIN_DASHBOARD_VIEW).forward(request, response);
            return;
        }

        // 2. Staff Workspace Dashboard
        if ("/dashboard/staff".equals(servletPath)) {
            if (!isStaffOrAdmin(request)) {
                response.sendRedirect(request.getContextPath() + "/login");
                return;
            }
            request.getRequestDispatcher(STAFF_DASHBOARD_VIEW).forward(request, response);
            return;
        }

        // 3. Admin user management list
        // if ("/dashboard/admin/users".equals(servletPath)) {
        //     if (!isAdmin(request)) {
        //         response.sendRedirect(request.getContextPath() + "/login");
        //         return;
        //     }
        //     handleAdminListUsers(request, response);
        //     return;
        // }

        // 4. Customer profile & change password endpoints
        HttpSession session = request.getSession(false);
        User authUser = (session != null) ? (User) session.getAttribute("authUser") : null;
        if (authUser == null) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }

        // Refresh user profile from DB to ensure latest data (UC-43)
        try {
            User freshUser = userService.getUserById(authUser.getId());
            if (freshUser != null && session != null) {
                session.setAttribute("authUser", freshUser);
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }

        if ("/change-password".equals(servletPath)) {
            request.setAttribute("activeTab", "password");
        } else {
            request.setAttribute("activeTab", "profile");
        }

        request.getRequestDispatcher(PROFILE_VIEW).forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String servletPath = request.getServletPath();
        // Admin lock / unlock user account
        if ("/dashboard/admin/users".equals(servletPath)) {
            if (!isAdmin(request)) {
                response.sendRedirect(request.getContextPath() + "/login");
                return;
            }

            handleAdminUpdateUserStatus(request, response);
            return;
        }

        // 1. Admin update user status endpoint
        if ("/dashboard/admin".equals(servletPath)) {
            if (!isAdmin(request)) {
                response.sendRedirect(request.getContextPath() + "/login");
                return;
            }

            try {
                java.util.List<User> users = userService.getAllUsers();

                getServletContext().log(
                        "[ADMIN DASHBOARD] Servlet Path: " + servletPath);

                getServletContext().log(
                        "[ADMIN DASHBOARD] Users count: "
                                + (users == null ? "NULL" : users.size()));

                request.setAttribute("users", users);

            } catch (SQLException ex) {
                getServletContext().log(
                        "[ADMIN DASHBOARD] Failed to load users.", ex);

                response.sendError(
                        HttpServletResponse.SC_INTERNAL_SERVER_ERROR,
                        "Unable to load user accounts.");
                return;
            }

            request.getRequestDispatcher(ADMIN_DASHBOARD_VIEW)
                    .forward(request, response);
            return;
        }

        // 2. Customer profile update & password change endpoints
        HttpSession session = request.getSession(false);
        User authUser = (session != null) ? (User) session.getAttribute("authUser") : null;
        if (authUser == null) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }

        String action = request.getParameter("action");
        if ("/change-password".equals(servletPath) || "changePassword".equals(action)) {
            handleChangePassword(request, response, authUser);
        } else {
            handleUpdateProfile(request, response, session, authUser);
        }
    }

    // =========================================================================
    // Administrator Handlers (/dashboard/admin/*)
    // =========================================================================

    private void handleAdminListUsers(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        try {
            request.setAttribute("users", userService.getAllUsers());
            request.getRequestDispatcher(ADMIN_USERS_VIEW).forward(request, response);
        } catch (SQLException ex) {
            getServletContext().log("Failed to load user management page.", ex);
            response.sendError(HttpServletResponse.SC_INTERNAL_SERVER_ERROR, "Unable to load user accounts.");
        }
    }

    private void handleAdminUpdateUserStatus(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String userIdValue = request.getParameter("userId");
        String status = request.getParameter("status");

        try {
            if (userIdValue == null || userIdValue.trim().isEmpty()) {
                response.sendError(HttpServletResponse.SC_BAD_REQUEST, "User ID is required.");
                return;
            }

            long userId = Long.parseLong(userIdValue);
            HttpSession session = request.getSession(false);
            User currentUser = (session != null) ? (User) session.getAttribute("authUser") : null;

            if (currentUser != null && currentUser.getId() != null && currentUser.getId().longValue() == userId) {
                response.sendError(HttpServletResponse.SC_BAD_REQUEST, "You cannot change your own account status.");
                return;
            }

            boolean updated = userService.updateUserStatus(userId, status);
            String message = updated ? "User account status updated successfully." : "User account was not found.";

            response.sendRedirect(
                    request.getContextPath()
                            + "/dashboard/admin?view=users&message="
                            + URLEncoder.encode(message, StandardCharsets.UTF_8.name()));

        } catch (IllegalArgumentException ex) {
            response.sendError(HttpServletResponse.SC_BAD_REQUEST, "Invalid user ID or account status.");
        } catch (SQLException ex) {
            getServletContext().log("Failed to update user account status.", ex);
            response.sendError(HttpServletResponse.SC_INTERNAL_SERVER_ERROR, "Unable to update user account.");
        }
    }

    private boolean isAdmin(HttpServletRequest request) {
        HttpSession session = request.getSession(false);
        if (session == null) {
            return false;
        }
        Object authenticatedUser = session.getAttribute("authUser");
        Object role = session.getAttribute("userRole");

        if (authenticatedUser instanceof User) {
            User u = (User) authenticatedUser;
            if ("ADMIN".equalsIgnoreCase(String.valueOf(role)) || u.hasRole("ADMIN")) {
                return true;
            }
        }
        return "ADMIN".equals(role);
    }

    private boolean isStaffOrAdmin(HttpServletRequest request) {
        HttpSession session = request.getSession(false);
        if (session == null) {
            return false;
        }
        Object authenticatedUser = session.getAttribute("authUser");
        if (authenticatedUser instanceof User) {
            User u = (User) authenticatedUser;
            return u.hasRole("ADMIN") || u.hasRole("STAFF") || u.hasRole("INVENTORY_STAFF");
        }
        Object role = session.getAttribute("userRole");
        return "ADMIN".equals(role) || "STAFF".equals(role);
    }

    // =========================================================================
    // Customer Profile & Password Handlers (/profile, /change-password)
    // =========================================================================

    private void handleUpdateProfile(HttpServletRequest request, HttpServletResponse response,
            HttpSession session, User authUser)
            throws ServletException, IOException {
        request.setAttribute("activeTab", "profile");

        String fullName = request.getParameter("fullName");
        String phoneNumber = request.getParameter("phoneNumber");
        String dob = request.getParameter("dob");
        String gender = request.getParameter("gender");
        String avatarUrl = authUser.getAvatarUrl();

        // Check for optional avatar file upload
        try {
            String contentType = request.getContentType();
            if (contentType != null && contentType.toLowerCase().startsWith("multipart/")) {
                Part avatarPart = request.getPart("avatarFile");
                if (avatarPart != null && avatarPart.getSize() > 0) {
                    String submittedName = getSubmittedFileName(avatarPart);
                    String ext = ".png";
                    if (submittedName != null && submittedName.contains(".")) {
                        ext = submittedName.substring(submittedName.lastIndexOf('.')).toLowerCase();
                    }
                    if (!ext.equals(".jpg") && !ext.equals(".jpeg") && !ext.equals(".png") && !ext.equals(".webp")) {
                        request.setAttribute("errorMessage", "Only JPG, PNG, or WEBP avatar images are supported.");
                        request.getRequestDispatcher(PROFILE_VIEW).forward(request, response);
                        return;
                    }

                    String relativeDir = "/static/uploads/avatars";
                    String realDirPath = getServletContext().getRealPath(relativeDir);
                    if (realDirPath != null) {
                        File uploadDir = new File(realDirPath);
                        if (!uploadDir.exists()) {
                            uploadDir.mkdirs();
                        }
                        String fileName = "avatar_u" + authUser.getId() + "_" + System.currentTimeMillis() + ext;
                        File targetFile = new File(uploadDir, fileName);
                        try (InputStream in = avatarPart.getInputStream()) {
                            Files.copy(in, targetFile.toPath(), StandardCopyOption.REPLACE_EXISTING);
                        }
                        avatarUrl = request.getContextPath() + relativeDir + "/" + fileName;
                    }
                }
            }
        } catch (IllegalStateException e) {
            request.setAttribute("errorMessage", "Uploaded image exceeds maximum allowed size (2MB).");
            request.getRequestDispatcher(PROFILE_VIEW).forward(request, response);
            return;
        } catch (Exception e) {
            e.printStackTrace();
        }

        try {
            ProfileUpdateResult result = userService.updateProfile(
                    authUser.getId(), fullName, phoneNumber, gender, dob, avatarUrl);
            if (result.isSuccess()) {
                session.setAttribute("authUser", result.getUser());
                request.setAttribute("successMessage", result.getMessage());
            } else {
                request.setAttribute("errorMessage", result.getMessage());
            }
        } catch (SQLException e) {
            e.printStackTrace();
            request.setAttribute("errorMessage", "Database error occurred while updating your profile.");
        }

        request.getRequestDispatcher(PROFILE_VIEW).forward(request, response);
    }

    private void handleChangePassword(HttpServletRequest request, HttpServletResponse response,
            User authUser)
            throws ServletException, IOException {
        request.setAttribute("activeTab", "password");

        String currentPassword = request.getParameter("currentPassword");
        String newPassword = request.getParameter("newPassword");
        String confirmPassword = request.getParameter("confirmPassword");

        try {
            PasswordChangeResult result = userService.changePassword(
                    authUser.getId(), currentPassword, newPassword, confirmPassword);
            if (result.isSuccess()) {
                request.setAttribute("successMessage", result.getMessage());
            } else {
                request.setAttribute("errorMessage", result.getMessage());
            }
        } catch (SQLException e) {
            e.printStackTrace();
            request.setAttribute("errorMessage", "Database error occurred while changing your password.");
        }

        request.getRequestDispatcher(PROFILE_VIEW).forward(request, response);
    }

    private String getSubmittedFileName(Part part) {
        String header = part.getHeader("content-disposition");
        if (header == null) {
            return null;
        }
        for (String token : header.split(";")) {
            if (token.trim().startsWith("filename")) {
                return token.substring(token.indexOf('=') + 1).trim().replace("\"", "");
            }
        }
        return null;
    }
}
