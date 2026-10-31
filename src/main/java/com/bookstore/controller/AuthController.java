package com.bookstore.controller;

import com.bookstore.model.User;
import com.bookstore.service.AuthService;
import com.bookstore.service.AuthService.AccountNotActiveException;
import com.bookstore.service.AuthService.BadCredentialsException;
import com.bookstore.service.AuthService.EmailExistsException;
import com.bookstore.service.AuthService.InvalidTokenException;
import com.bookstore.service.AuthService.ValidationException;
import com.bookstore.service.EmailService.EmailDeliveryException;
import com.bookstore.service.LogoutHandler;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.Cookie;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import java.io.IOException;
import java.sql.SQLException;
import java.util.LinkedHashMap;
import java.util.Map;

/**
 * AuthController («controller» :AuthController) - Presentation Controller Layer
 * for UC-01 Register, UC-02 Login, UC-03 Logout, and Management Portal Authentication (/dashboard).
 */
@WebServlet(name = "AuthController", urlPatterns = {
        "/login",
        "/register",
        "/verify-email",
        "/resend-activation",
        "/logout",
        "/dashboard",
        "/dashboard/logout"
})
public class AuthController extends HttpServlet {

    private static final long serialVersionUID = 1L;
    private static final int SESSION_TIMEOUT_SECONDS = 60 * 60; // 1h
    private static final int REMEMBER_ME_COOKIE_AGE = 7 * 24 * 60 * 60; // 7 days
    private static final String SESSION_PENDING_REG_USER = "pendingRegUser";

    private AuthService authService;
    private LogoutHandler logoutHandler;

    @Override
    public void init() throws ServletException {
        super.init();
        this.authService = new AuthService();
        this.logoutHandler = new LogoutHandler();
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String path = request.getServletPath();
        switch (path) {
            case "/register":
                showRegisterPage(request, response);
                break;
            case "/verify-email":
                verifyEmail(request, response);
                break;
            case "/logout":
                logout(request, response);
                break;
            case "/dashboard/logout":
                logoutDashboard(request, response);
                break;
            case "/dashboard":
                showDashboardLoginPage(request, response);
                break;
            case "/login":
            default:
                showLoginPage(request, response);
                break;
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String path = request.getServletPath();
        switch (path) {
            case "/register":
                register(request, response);
                break;
            case "/verify-email":
                verifyEmail(request, response);
                break;
            case "/resend-activation":
                resendActivation(request, response);
                break;
            case "/logout":
                logout(request, response);
                break;
            case "/dashboard/logout":
                logoutDashboard(request, response);
                break;
            case "/dashboard":
                loginDashboard(request, response);
                break;
            case "/login":
            default:
                login(request, response);
                break;
        }
    }

    /**
     * Displays the Registration page (:RegisterPage).
     */
    private void showRegisterPage(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        request.setAttribute("pageTitle", "Create Account - BookStore");
        request.getRequestDispatcher("/views/auth/register.jsp").forward(request, response);
    }

    /**
     * Displays the Login page (:LoginPage) for Customers/Buyers.
     */
    private void showLoginPage(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        request.setAttribute("pageTitle", "Sign In - BookStore");

        // Pre-populate remembered email if cookie exists
        Cookie[] cookies = request.getCookies();
        if (cookies != null) {
            for (Cookie cookie : cookies) {
                if ("rememberedEmail".equals(cookie.getName())) {
                    request.setAttribute("email", cookie.getValue());
                    request.setAttribute("rememberMe", true);
                    break;
                }
            }
        }

        if ("true".equals(request.getParameter("verified"))) {
            request.setAttribute("successMessage", "Xác thực Gmail thành công! Tài khoản của bạn đã được tạo, vui lòng đăng nhập.");
        }

        request.getRequestDispatcher("/views/auth/login.jsp").forward(request, response);
    }

    /**
     * Displays the Dedicated Login page for Staff and Administrators (/dashboard).
     */
    private void showDashboardLoginPage(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        HttpSession session = request.getSession(false);
        User authUser = (session != null) ? (User) session.getAttribute("authUser") : null;

        if (authUser != null) {
            if (authUser.hasRole("ADMIN")) {
                response.sendRedirect(request.getContextPath() + "/dashboard/admin");
                return;
            } else if (authUser.hasRole("STAFF") || authUser.hasRole("INVENTORY_STAFF")) {
                response.sendRedirect(request.getContextPath() + "/dashboard/staff");
                return;
            }
        }

        request.getRequestDispatcher("/views/admin/login.jsp").forward(request, response);
    }

    /**
     * Step 1 of UC-01 Register:
     * Validates form inputs, generates a 6-digit OTP, sends it to the user's Gmail,
     * and stores pending registration info in HttpSession awaiting OTP verification.
     */
    protected void register(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String fullName = request.getParameter("fullName");
        String email = request.getParameter("email");
        String phone = request.getParameter("phone");
        String password = request.getParameter("password");
        String confirmPassword = request.getParameter("confirmPassword");

        // Preserve user inputs on form in case of validation failure
        request.setAttribute("fullName", fullName);
        request.setAttribute("email", email);
        request.setAttribute("phone", phone);
        request.setAttribute("pageTitle", "Create Account - BookStore");

        String baseUrl = getApplicationBaseUrl(request);

        try {
            User pendingUser = authService.register(fullName, email, phone, password, confirmPassword, baseUrl);

            HttpSession session = request.getSession(true);
            session.setAttribute(SESSION_PENDING_REG_USER, pendingUser);

            request.setAttribute("registerSuccess", true);
            request.setAttribute("registeredEmail", pendingUser.getEmail());
            request.setAttribute("successMessage", "Mã xác thực 6 chữ số đã được gửi tới hộp thư Gmail: " + pendingUser.getEmail());
            request.getRequestDispatcher("/views/auth/register.jsp").forward(request, response);

        } catch (ValidationException ex) {
            request.setAttribute("validationErrors", ex.getFieldErrors());
            request.setAttribute("errorMessage", ex.getMessage());
            request.getRequestDispatcher("/views/auth/register.jsp").forward(request, response);

        } catch (EmailExistsException ex) {
            request.setAttribute("errorMessage", ex.getMessage());
            request.getRequestDispatcher("/views/auth/register.jsp").forward(request, response);

        } catch (EmailDeliveryException ex) {
            request.setAttribute("errorMessage", ex.getMessage());
            request.getRequestDispatcher("/views/auth/register.jsp").forward(request, response);

        } catch (SQLException ex) {
            request.setAttribute("errorMessage", "Database error occurred during registration: " + ex.getMessage());
            request.getRequestDispatcher("/views/auth/register.jsp").forward(request, response);
        }
    }

    /**
     * Step 2 of UC-01 Register:
     * Verifies the 6-digit OTP code entered by the user and inserts the verified account into SQL Server.
     */
    protected void verifyEmail(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String email = request.getParameter("email");
        String token = request.getParameter("token");
        if (token == null || token.trim().isEmpty()) {
            token = request.getParameter("otp");
        }

        HttpSession session = request.getSession(false);
        User pendingUser = (session != null) ? (User) session.getAttribute(SESSION_PENDING_REG_USER) : null;

        try {
            if (pendingUser != null) {
                authService.verifyOtpAndCreateUser(pendingUser, token);
                session.removeAttribute(SESSION_PENDING_REG_USER);
            } else {
                authService.verifyEmail(email, token);
            }
            response.sendRedirect(request.getContextPath() + "/login?verified=true");

        } catch (InvalidTokenException ex) {
            request.setAttribute("pageTitle", "Verify Gmail Code - BookStore");
            request.setAttribute("registerSuccess", true);
            request.setAttribute("registeredEmail", pendingUser != null ? pendingUser.getEmail() : email);
            request.setAttribute("errorMessage", ex.getMessage());
            request.getRequestDispatcher("/views/auth/register.jsp").forward(request, response);

        } catch (EmailExistsException ex) {
            if (session != null) {
                session.removeAttribute(SESSION_PENDING_REG_USER);
            }
            request.setAttribute("errorMessage", ex.getMessage());
            request.getRequestDispatcher("/views/auth/login.jsp").forward(request, response);

        } catch (SQLException ex) {
            request.setAttribute("pageTitle", "Verify Gmail Code - BookStore");
            request.setAttribute("registerSuccess", true);
            request.setAttribute("registeredEmail", pendingUser != null ? pendingUser.getEmail() : email);
            request.setAttribute("errorMessage", "Database error occurred while saving your verified account: " + ex.getMessage());
            request.getRequestDispatcher("/views/auth/register.jsp").forward(request, response);
        }
    }

    /**
     * Handles Resend 6-Digit OTP Email: resendActivation(email).
     */
    protected void resendActivation(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String email = request.getParameter("email");
        HttpSession session = request.getSession(false);
        User pendingUser = (session != null) ? (User) session.getAttribute(SESSION_PENDING_REG_USER) : null;

        String targetEmail = (pendingUser != null) ? pendingUser.getEmail() : email;
        request.setAttribute("registeredEmail", targetEmail);
        request.setAttribute("registerSuccess", true);
        request.setAttribute("pageTitle", "Verify Gmail Code - BookStore");

        String baseUrl = getApplicationBaseUrl(request);

        try {
            if (pendingUser != null) {
                authService.resendOtpForPendingUser(pendingUser, baseUrl);
                session.setAttribute(SESSION_PENDING_REG_USER, pendingUser);
            } else {
                authService.resendActivation(email, baseUrl);
            }
            request.setAttribute("resendSuccess", true);
            request.setAttribute("successMessage", "Mã xác thực 6 chữ số mới đã được gửi tới " + targetEmail + ".");
            request.getRequestDispatcher("/views/auth/register.jsp").forward(request, response);

        } catch (ValidationException | EmailDeliveryException ex) {
            request.setAttribute("errorMessage", ex.getMessage());
            request.getRequestDispatcher("/views/auth/register.jsp").forward(request, response);

        } catch (SQLException ex) {
            request.setAttribute("errorMessage", "Database error occurred while resending verification code.");
            request.getRequestDispatcher("/views/auth/register.jsp").forward(request, response);
        }
    }

    /**
     * Handles Customer / Buyer Login submission at /login.
     * Strictly authenticates only BUYER accounts. Admin/Staff credentials yield standard error.
     */
    protected void login(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String email = request.getParameter("email");
        String password = request.getParameter("password");
        String rememberMeParam = request.getParameter("rememberMe");
        boolean rememberMe = "on".equalsIgnoreCase(rememberMeParam) || "true".equalsIgnoreCase(rememberMeParam);

        request.setAttribute("email", email);
        request.setAttribute("rememberMe", rememberMe);
        request.setAttribute("pageTitle", "Sign In - BookStore");

        // alt [credentials are blank]
        if (email == null || email.trim().isEmpty() || password == null || password.isEmpty()) {
            Map<String, String> validationErrors = new LinkedHashMap<>();
            if (email == null || email.trim().isEmpty()) {
                validationErrors.put("email", "Email address cannot be blank.");
            }
            if (password == null || password.isEmpty()) {
                validationErrors.put("password", "Password cannot be blank.");
            }
            request.setAttribute("validationErrors", validationErrors);
            request.setAttribute("errorMessage", "Email and password cannot be blank.");
            request.getRequestDispatcher("/views/auth/login.jsp").forward(request, response);
            return;
        }

        // else [credentials not blank]
        try {
            User authenticatedUser = authService.authenticate(email, password);

            // /login strictly accepts BUYER accounts!
            // If user has ADMIN or STAFF role and not BUYER, reject with generic error message
            boolean isStaffOrAdmin = authenticatedUser.hasRole("ADMIN")
                    || authenticatedUser.hasRole("STAFF")
                    || authenticatedUser.hasRole("INVENTORY_STAFF");
            if (isStaffOrAdmin && !authenticatedUser.hasRole("BUYER")) {
                request.setAttribute("errorMessage", "Invalid email or password.");
                request.getRequestDispatcher("/views/auth/login.jsp").forward(request, response);
                return;
            }

            // Create HTTP Session (JSESSIONID, timeout = 60 min)
            HttpSession session = request.getSession(true);
            session.setMaxInactiveInterval(SESSION_TIMEOUT_SECONDS);
            session.setAttribute("authUser", authenticatedUser);
            session.setAttribute("userRole", "BUYER");

            // opt [rememberMe is checked]
            Cookie emailCookie = new Cookie("rememberedEmail", rememberMe ? authenticatedUser.getEmail() : "");
            emailCookie.setHttpOnly(true);
            emailCookie.setPath(request.getContextPath().isEmpty() ? "/" : request.getContextPath());
            emailCookie.setMaxAge(rememberMe ? REMEMBER_ME_COOKIE_AGE : 0);
            response.addCookie(emailCookie);

            response.sendRedirect(request.getContextPath() + "/home");

        } catch (BadCredentialsException ex) {
            request.setAttribute("errorMessage", "Invalid email or password.");
            request.getRequestDispatcher("/views/auth/login.jsp").forward(request, response);

        } catch (AccountNotActiveException ex) {
            request.setAttribute("errorMessage", ex.getMessage());
            request.setAttribute("inactiveEmail", email.trim());
            request.getRequestDispatcher("/views/auth/login.jsp").forward(request, response);

        } catch (SQLException ex) {
            request.setAttribute("errorMessage", "Database connection error occurred: " + ex.getMessage());
            request.getRequestDispatcher("/views/auth/login.jsp").forward(request, response);
        }
    }

    /**
     * Handles Management Portal Login at /dashboard.
     * Strictly authenticates ADMIN and STAFF accounts. Non-staff accounts yield standard error.
     */
    private void loginDashboard(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String email = request.getParameter("email");
        String password = request.getParameter("password");

        if (email == null || email.trim().isEmpty() || password == null || password.isEmpty()) {
            request.setAttribute("errorMessage", "Invalid email or password.");
            request.getRequestDispatcher("/views/admin/login.jsp").forward(request, response);
            return;
        }

        try {
            User authenticatedUser = authService.authenticate(email.trim(), password);

            boolean isAdmin = authenticatedUser.hasRole("ADMIN");
            boolean isStaff = authenticatedUser.hasRole("STAFF") || authenticatedUser.hasRole("INVENTORY_STAFF");

            if (!isAdmin && !isStaff) {
                // Return generic error message to prevent account probing
                request.setAttribute("errorMessage", "Invalid email or password.");
                request.getRequestDispatcher("/views/admin/login.jsp").forward(request, response);
                return;
            }

            HttpSession session = request.getSession(true);
            session.setMaxInactiveInterval(SESSION_TIMEOUT_SECONDS);
            session.setAttribute("authUser", authenticatedUser);
            session.setAttribute("userRole", isAdmin ? "ADMIN" : "STAFF");

            if (isAdmin) {
                response.sendRedirect(request.getContextPath() + "/dashboard/admin");
            } else {
                response.sendRedirect(request.getContextPath() + "/dashboard/staff");
            }

        } catch (BadCredentialsException | AccountNotActiveException ex) {
            request.setAttribute("errorMessage", "Invalid email or password.");
            request.getRequestDispatcher("/views/admin/login.jsp").forward(request, response);

        } catch (SQLException ex) {
            request.setAttribute("errorMessage", "Database connection error occurred: " + ex.getMessage());
            request.getRequestDispatcher("/views/admin/login.jsp").forward(request, response);
        }
    }

    /**
     * Handles Customer Logout: invalidates active HTTP session via LogoutHandler (UC-03) and redirects to Home.
     */
    protected void logout(HttpServletRequest request, HttpServletResponse response)
            throws IOException {
        logoutHandler.logout(request);
        response.sendRedirect(request.getContextPath() + "/home?logout=true");
    }

    /**
     * Handles Management Portal Logout: invalidates active HTTP session and redirects to /dashboard.
     */
    protected void logoutDashboard(HttpServletRequest request, HttpServletResponse response)
            throws IOException {
        logoutHandler.logout(request);
        response.sendRedirect(request.getContextPath() + "/dashboard");
    }

    private String getApplicationBaseUrl(HttpServletRequest request) {
        return request.getScheme() + "://" + request.getServerName()
                + ":" + request.getServerPort() + request.getContextPath();
    }
}
