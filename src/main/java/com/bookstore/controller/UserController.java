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
import java.nio.file.Files;
import java.nio.file.StandardCopyOption;
import java.sql.SQLException;

/**
 * Presentation Controller for User Account Management (TSK-07).
 * Handles:
 *  - GET  /profile         -> UC-43 View Own Profile
 *  - POST /profile         -> UC-44 Update Own Profile
 *  - GET  /change-password -> UC-05 View Change Password Tab
 *  - POST /change-password -> UC-05 Submit Password Change
 */
@WebServlet(name = "UserController", urlPatterns = {
        "/profile",
        "/change-password"
})
@MultipartConfig(
        fileSizeThreshold = 1024 * 1024,      // 1 MB
        maxFileSize = 2 * 1024 * 1024,        // 2 MB max per avatar
        maxRequestSize = 5 * 1024 * 1024      // 5 MB max request
)
public class UserController extends HttpServlet {

    private static final String PROFILE_VIEW = "/views/account/profile.jsp";

    private UserService userService;

    @Override
    public void init() throws ServletException {
        super.init();
        this.userService = new UserService();
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
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

        String servletPath = request.getServletPath();
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
        HttpSession session = request.getSession(false);
        User authUser = (session != null) ? (User) session.getAttribute("authUser") : null;
        if (authUser == null) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }

        String servletPath = request.getServletPath();
        String action = request.getParameter("action");

        if ("/change-password".equals(servletPath) || "changePassword".equals(action)) {
            handleChangePassword(request, response, authUser);
        } else {
            handleUpdateProfile(request, response, session, authUser);
        }
    }

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
                    authUser.getId(), fullName, phoneNumber, gender, dob, avatarUrl
            );
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
                    authUser.getId(), currentPassword, newPassword, confirmPassword
            );
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
