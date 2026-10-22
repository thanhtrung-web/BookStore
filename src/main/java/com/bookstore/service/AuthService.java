package com.bookstore.service;

import com.bookstore.dao.UserDAO;
import com.bookstore.model.User;
import com.bookstore.service.EmailService.EmailDeliveryException;
import org.mindrot.jbcrypt.BCrypt;

import java.sql.SQLException;
import java.util.LinkedHashMap;
import java.util.Map;
import java.util.UUID;
import java.util.regex.Pattern;

/**
 * AuthService («service» :AuthService) - Business Logic Layer for UC-01 Register & UC-02 Login.
 * Implements input validation, BCrypt hashing/verification, token generation, and account status checks.
 */
public class AuthService {

    private static final Pattern EMAIL_PATTERN = Pattern.compile(
            "^[A-Za-z0-9+_.-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}$"
    );
    private static final Pattern PHONE_PATTERN = Pattern.compile(
            "^(0|\\+84)[0-9]{8,10}$"
    );
    private static final int MIN_PASSWORD_LENGTH = 8;
    private static final int BCRYPT_WORK_FACTOR = 12;

    private final UserDAO userDAO;
    private final EmailService emailService;

    public AuthService() {
        this.userDAO = new UserDAO();
        this.emailService = new EmailService();
    }

    public AuthService(UserDAO userDAO, EmailService emailService) {
        this.userDAO = userDAO;
        this.emailService = emailService;
    }

    /**
     * Validates registration form inputs (UC-01 validateInput).
     * Returns a map of field-level validation errors.
     */
    public Map<String, String> validateInput(String fullName, String email, String phone,
                                             String password, String confirmPassword) {
        Map<String, String> errors = new LinkedHashMap<>();

        if (fullName == null || fullName.trim().isEmpty()) {
            errors.put("fullName", "Full name cannot be blank.");
        } else if (fullName.trim().length() > 100) {
            errors.put("fullName", "Full name must not exceed 100 characters.");
        }

        if (email == null || email.trim().isEmpty()) {
            errors.put("email", "Email address cannot be blank.");
        } else if (!EMAIL_PATTERN.matcher(email.trim()).matches()) {
            errors.put("email", "Invalid email format.");
        }

        if (phone == null || phone.trim().isEmpty()) {
            errors.put("phone", "Phone number cannot be blank.");
        } else if (!PHONE_PATTERN.matcher(phone.trim()).matches()) {
            errors.put("phone", "Invalid phone number format (e.g. 0901234567).");
        }

        if (password == null || password.isEmpty()) {
            errors.put("password", "Password cannot be blank.");
        } else if (password.length() < MIN_PASSWORD_LENGTH) {
            errors.put("password", "Password must be at least 8 characters.");
        }

        if (confirmPassword == null || confirmPassword.isEmpty()) {
            errors.put("confirmPassword", "Confirm password cannot be blank.");
        } else if (password != null && !password.equals(confirmPassword)) {
            errors.put("confirmPassword", "Password and confirm password do not match.");
        }

        return errors;
    }

    /**
     * Generates a cryptographically random verification token (UC-01 generateVerificationToken).
     */
    public String generateVerificationToken() {
        return UUID.randomUUID().toString();
    }

    /**
     * Registers a new buyer account and sends an activation email (UC-01 register).
     */
    public User register(String fullName, String email, String phone,
                         String password, String confirmPassword, String baseUrl)
            throws ValidationException, EmailExistsException, EmailDeliveryException, SQLException {

        // 1. Validate form fields
        Map<String, String> validationErrors = validateInput(fullName, email, phone, password, confirmPassword);
        if (!validationErrors.isEmpty()) {
            throw new ValidationException("Invalid registration input.", validationErrors);
        }

        String normalizedEmail = email.trim().toLowerCase();
        String normalizedName = fullName.trim();
        String normalizedPhone = phone.trim();

        // 2. Check duplicate email in database
        if (userDAO.existsByEmail(normalizedEmail)) {
            throw new EmailExistsException("Email is already registered. Please login or use a different email.");
        }

        // 3. Hash password with BCrypt & generate verification token
        String passwordHash = BCrypt.hashpw(password, BCrypt.gensalt(BCRYPT_WORK_FACTOR));
        String token = generateVerificationToken();

        // 4. Create user record & assign BUYER role inside JDBC transaction
        User newUser = new User();
        newUser.setEmail(normalizedEmail);
        newUser.setPasswordHash(passwordHash);
        newUser.setFullName(normalizedName);
        newUser.setPhoneNumber(normalizedPhone);
        newUser.setAuthProvider("LOCAL");
        newUser.setEmailVerificationToken(token);
        newUser.setEmailVerified(false);
        newUser.setStatus("INACTIVE");

        User createdUser = userDAO.createUser(newUser, "BUYER");

        // 5. Send activation email via EmailService
        emailService.sendActivationEmail(normalizedEmail, token, baseUrl);

        return createdUser;
    }

    /**
     * Overload matching Sequence Diagram signature: register(fullName, email, phone, password, confirmPassword).
     */
    public User register(String fullName, String email, String phone,
                         String password, String confirmPassword)
            throws ValidationException, EmailExistsException, EmailDeliveryException, SQLException {
        return register(fullName, email, phone, password, confirmPassword, null);
    }

    /**
     * Verifies an email activation token and activates the user account (UC-01 verifyEmail).
     */
    public void verifyEmail(String token) throws InvalidTokenException, SQLException {
        if (token == null || token.trim().isEmpty()) {
            throw new InvalidTokenException("Activation link is invalid or expired.");
        }

        User user = userDAO.findByVerificationToken(token.trim());
        if (user == null) {
            throw new InvalidTokenException("Activation link is invalid or expired.");
        }

        boolean activated = userDAO.activateByToken(user.getId());
        if (!activated) {
            throw new InvalidTokenException("Failed to activate account. Please try again.");
        }
    }

    /**
     * Generates a new verification token and resends the activation email (UC-01 opt [Resend activation email]).
     */
    public String resendActivation(String email, String baseUrl)
            throws ValidationException, EmailDeliveryException, SQLException {
        if (email == null || email.trim().isEmpty()) {
            Map<String, String> err = new LinkedHashMap<>();
            err.put("email", "Email address is required to resend activation link.");
            throw new ValidationException("Email address is required.", err);
        }

        String normalizedEmail = email.trim().toLowerCase();
        String newToken = generateVerificationToken();

        boolean updated = userDAO.updateVerificationToken(normalizedEmail, newToken);
        if (!updated) {
            Map<String, String> err = new LinkedHashMap<>();
            err.put("email", "No pending account found for this email address.");
            throw new ValidationException("No pending account found for this email address.", err);
        }

        emailService.sendActivationEmail(normalizedEmail, newToken, baseUrl);
        return newToken;
    }

    /**
     * Overload matching Sequence Diagram signature: resendActivation(email).
     */
    public String resendActivation(String email)
            throws ValidationException, EmailDeliveryException, SQLException {
        return resendActivation(email, null);
    }

    /**
     * Authenticates a user by email and password using BCrypt and checks account status (UC-02 authenticate).
     */
    public User authenticate(String email, String password)
            throws BadCredentialsException, AccountNotActiveException, SQLException {

        String normalizedEmail = (email != null) ? email.trim().toLowerCase() : "";
        User user = userDAO.findByEmail(normalizedEmail);

        // 1. Check user existence and verify BCrypt password hash
        if (user == null || user.getPasswordHash() == null || ! verifyPassword(password, user.getPasswordHash())) {
            throw new BadCredentialsException("Invalid email or password");
        }

        // 2. Check email verification & account status
        if (!user.isEmailVerified() || !"ACTIVE".equalsIgnoreCase(user.getStatus())) {
            throw new AccountNotActiveException(
                    "Your account is not active. Please verify your email or contact support."
            );
        }

        return user;
    }

    /**
     * Verifies plaintext password against BCrypt hash (UC-02 verifyPassword).
     */
    public boolean verifyPassword(String rawPassword, String passwordHash) {
        if (rawPassword == null || passwordHash == null || passwordHash.isEmpty()) {
            return false;
        }
        try {
            return BCrypt.checkpw(rawPassword, passwordHash);
        } catch (IllegalArgumentException ex) {
            return false;
        }
    }

    // =========================================================================
    // Domain Exceptions matching Sequence Diagrams UC-01 & UC-02
    // =========================================================================

    public static class ValidationException extends Exception {
        private static final long serialVersionUID = 1L;
        private final Map<String, String> fieldErrors;

        public ValidationException(String message, Map<String, String> fieldErrors) {
            super(message);
            this.fieldErrors = fieldErrors;
        }

        public Map<String, String> getFieldErrors() {
            return fieldErrors;
        }
    }

    public static class EmailExistsException extends Exception {
        private static final long serialVersionUID = 1L;

        public EmailExistsException(String message) {
            super(message);
        }
    }

    public static class InvalidTokenException extends Exception {
        private static final long serialVersionUID = 1L;

        public InvalidTokenException(String message) {
            super(message);
        }
    }

    public static class BadCredentialsException extends Exception {
        private static final long serialVersionUID = 1L;

        public BadCredentialsException(String message) {
            super(message);
        }
    }

    public static class AccountNotActiveException extends Exception {
        private static final long serialVersionUID = 1L;

        public AccountNotActiveException(String message) {
            super(message);
        }
    }
}
