package com.bookstore.controller;

import com.bookstore.model.User;
import com.bookstore.service.AuthService;
import com.bookstore.service.AuthService.AccountNotActiveException;
import com.bookstore.service.AuthService.BadCredentialsException;
import com.bookstore.service.AuthService.EmailExistsException;
import com.bookstore.service.AuthService.InvalidTokenException;
import com.bookstore.service.AuthService.ValidationException;
import com.bookstore.service.EmailService.EmailDeliveryException;

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
 * for UC-01 Register, UC-02 Login, and UC-03 Logout.
 */
@WebServlet(name = "AuthController", urlPatterns = {
        "/login",
        "/register",
        "/verify-email",
        "/resend-activation",
        "/logout"
})
public class AuthController extends HttpServlet {

    private static final long serialVersionUID = 1L;
    private static final int SESSION_TIMEOUT_SECONDS = 60 * 60; // 1h
    private static final int REMEMBER_ME_COOKIE_AGE = 7 * 24 * 60 * 60; // 7 days

    private AuthService authService;

    @Override
    public void init() throws ServletException {
        super.init();
        this.authService = new AuthService();
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
            case "/resend-activation":
                resendActivation(request, response);
                break;
            case "/logout":
                logout(request, response);
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
     * Displays the Login page (:LoginPage).
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
            request.setAttribute("successMessage", "Your email has been verified! Please sign in.");
        }

        request.getRequestDispatcher("/views/auth/login.jsp").forward(request, response);
    }

    /**
     * Handles UC-01 Register submission: register(fullName, email, phone, password, confirmPassword).
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
            User createdUser = authService.register(fullName, email, phone, password, confirmPassword, baseUrl);
            request.setAttribute("registerSuccess", true);
            request.setAttribute("registeredEmail", createdUser.getEmail());
            request.setAttribute("verificationToken", createdUser.getEmailVerificationToken());
            request.setAttribute("successMessage", "Please check your email inbox to activate your account.");
            request.getRequestDispatcher("/views/auth/register.jsp").forward(request, response);

        } catch (ValidationException ex) {
            request.setAttribute("validationErrors", ex.getFieldErrors());
            request.setAttribute("errorMessage", ex.getMessage());
            request.getRequestDispatcher("/views/auth/register.jsp").forward(request, response);

        } catch (EmailExistsException ex) {
            request.setAttribute("errorMessage", ex.getMessage());
            request.getRequestDispatcher("/views/auth/register.jsp").forward(request, response);

        } catch (EmailDeliveryException ex) {
            request.setAttribute("registeredEmail", email != null ? email.trim() : "");
            request.setAttribute("errorMessage", "Email delivery failed. Please click 'Resend Email' to try again.");
            request.getRequestDispatcher("/views/auth/register.jsp").forward(request, response);

        } catch (SQLException ex) {
            request.setAttribute("errorMessage", "Database error occurred during registration: " + ex.getMessage());
            request.getRequestDispatcher("/views/auth/register.jsp").forward(request, response);
        }
    }

    /**
     * Handles Email Verification link: verifyEmail(token).
     */
    protected void verifyEmail(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String token = request.getParameter("token");
        try {
            authService.verifyEmail(token);
            response.sendRedirect(request.getContextPath() + "/login?verified=true");

        } catch (InvalidTokenException ex) {
            request.setAttribute("pageTitle", "Account Activation - BookStore");
            request.setAttribute("errorMessage", ex.getMessage());
            request.getRequestDispatcher("/views/auth/register.jsp").forward(request, response);

        } catch (SQLException ex) {
            request.setAttribute("pageTitle", "Account Activation - BookStore");
            request.setAttribute("errorMessage", "Database error occurred while verifying email.");
            request.getRequestDispatcher("/views/auth/register.jsp").forward(request, response);
        }
    }

    /**
     * Handles Resend Activation Email: resendActivation(email).
     */
    protected void resendActivation(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String email = request.getParameter("email");
        request.setAttribute("registeredEmail", email);
        request.setAttribute("registerSuccess", true);
        request.setAttribute("pageTitle", "Verify Email - BookStore");

        String baseUrl = getApplicationBaseUrl(request);

        try {
            String newToken = authService.resendActivation(email, baseUrl);
            request.setAttribute("verificationToken", newToken);
            request.setAttribute("resendSuccess", true);
            request.setAttribute("successMessage", "A new activation link has been sent to your email inbox.");
            request.getRequestDispatcher("/views/auth/register.jsp").forward(request, response);

        } catch (ValidationException | EmailDeliveryException ex) {
            request.setAttribute("errorMessage", ex.getMessage());
            request.getRequestDispatcher("/views/auth/register.jsp").forward(request, response);

        } catch (SQLException ex) {
            request.setAttribute("errorMessage", "Database error occurred while resending activation email.");
            request.getRequestDispatcher("/views/auth/register.jsp").forward(request, response);
        }
    }

    /**
     * Handles Login submission: login(email, password, rememberMe).
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

            // Create HTTP Session (JSESSIONID, timeout = 60 min)
            HttpSession session = request.getSession(true);
            session.setMaxInactiveInterval(SESSION_TIMEOUT_SECONDS);
            session.setAttribute("authUser", authenticatedUser);
            session.setAttribute("userRole", authenticatedUser.getPrimaryRole());

            // opt [rememberMe is checked]
            Cookie emailCookie = new Cookie("rememberedEmail", rememberMe ? authenticatedUser.getEmail() : "");
            emailCookie.setHttpOnly(true);
            emailCookie.setPath(request.getContextPath().isEmpty() ? "/" : request.getContextPath());
            emailCookie.setMaxAge(rememberMe ? REMEMBER_ME_COOKIE_AGE : 0);
            response.addCookie(emailCookie);

            // Redirect based on role (ADMIN/STAFF -> Admin Dashboard or Home; BUYER -> Home)
            String primaryRole = authenticatedUser.getPrimaryRole();
            if ("ADMIN".equalsIgnoreCase(primaryRole)
                    || "STAFF".equalsIgnoreCase(primaryRole)
                    || "INVENTORY_STAFF".equalsIgnoreCase(primaryRole)) {
                response.sendRedirect(request.getContextPath() + "/home");
            } else {
                response.sendRedirect(request.getContextPath() + "/home");
            }

        } catch (BadCredentialsException ex) {
            request.setAttribute("errorMessage", ex.getMessage());
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
     * Handles Logout: invalidates active HTTP session and redirects to Home.
     */
    protected void logout(HttpServletRequest request, HttpServletResponse response)
            throws IOException {
        HttpSession session = request.getSession(false);
        if (session != null) {
            session.invalidate();
        }
        response.sendRedirect(request.getContextPath() + "/home?logout=true");
    }

    private String getApplicationBaseUrl(HttpServletRequest request) {
        return request.getScheme() + "://" + request.getServerName()
                + ":" + request.getServerPort() + request.getContextPath();
    }
}
