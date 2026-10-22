package com.bookstore.service;

import com.bookstore.dao.UserDAO;
import com.bookstore.model.User;
import com.bookstore.service.EmailService.EmailDeliveryException;
import org.mindrot.jbcrypt.BCrypt;

import java.security.SecureRandom;
import java.sql.SQLException;
import java.util.LinkedHashMap;
import java.util.Map;
import java.util.regex.Pattern;

/**
 * AuthService («service» :AuthService) - Business Logic Layer for UC-01 Register & UC-02 Login.
 * Implements strict Gmail validation, BCrypt hashing/verification, 6-digit OTP generation, and account status checks.
 */
public class AuthService {

    /**
     * Strict Gmail address pattern:
     * - Local part must start and end with alphanumeric characters
     * - Dots/underscores/hyphens cannot be consecutive or placed immediately before '@'
     * - Domain must strictly be '@gmail.com' (blocks example@.gmail.com, example@email.com, etc.)
     */
    private static final Pattern GMAIL_PATTERN = Pattern.compile(
            "^[A-Za-z0-9]+([._+-][A-Za-z0-9]+)*@gmail\\.com$",
            Pattern.CASE_INSENSITIVE
    );

    private static final Pattern PHONE_PATTERN = Pattern.compile(
            "^(0|\\+84)[0-9]{8,10}$"
    );

    private static final Pattern OTP_6_DIGIT_PATTERN = Pattern.compile("^[0-9]{6}$");

    private static final int MIN_PASSWORD_LENGTH = 8;
    private static final int BCRYPT_WORK_FACTOR = 12;
    private static final SecureRandom SECURE_RANDOM = new SecureRandom();

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
            errors.put("email", "Gmail address cannot be blank.");
        } else if (!GMAIL_PATTERN.matcher(email.trim()).matches()) {
            errors.put("email", "Please enter a valid Gmail address (e.g. example@gmail.com).");
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
     * Generates a cryptographically random 6-digit OTP verification code (100000 - 999999)
     * (UC-01 generateVerificationToken).
     */
    public String generateVerificationToken() {
        int otp = 100000 + SECURE_RANDOM.nextInt(900000);
        return String.valueOf(otp);
    }

    /**
     * Step 1 of UC-01 Register:
     * Validates inputs, checks duplicate email in DB, hashes password, generates 6-digit OTP,
     * and dispatches the 6-digit OTP to the user's Gmail inbox BEFORE persisting to DB.
     */
    public User register(String fullName, String email, String phone,
                         String password, String confirmPassword, String baseUrl)
            throws ValidationException, EmailExistsException, EmailDeliveryException, SQLException {

        // 1. Validate form fields
        Map<String, String> validationErrors = validateInput(fullName, email, phone, password, confirmPassword);
        if (!validationErrors.isEmpty()) {
            throw new ValidationException("Please check the highlighted registration fields.", validationErrors);
        }

        String normalizedEmail = email.trim().toLowerCase();
        String normalizedName = fullName.trim();
        String normalizedPhone = phone.trim();

        // 2. Check existing email in database
        if (userDAO.existsByEmail(normalizedEmail)) {
            throw new EmailExistsException("This Gmail address is already registered. Please sign in or use another Gmail.");
        }

        // 3. Hash password with BCrypt & generate 6-digit OTP verification code
        String passwordHash = BCrypt.hashpw(password, BCrypt.gensalt(BCRYPT_WORK_FACTOR));
        String otpCode = generateVerificationToken();

        // 4. Prepare pending User object (will be inserted into DB once 6-digit OTP is verified)
        User pendingUser = new User();
        pendingUser.setEmail(normalizedEmail);
        pendingUser.setPasswordHash(passwordHash);
        pendingUser.setFullName(normalizedName);
        pendingUser.setPhoneNumber(normalizedPhone);
        pendingUser.setAuthProvider("LOCAL");
        pendingUser.setEmailVerificationToken(otpCode);
        pendingUser.setEmailVerified(true);
        pendingUser.setStatus("ACTIVE");

        // 5. Send 6-digit OTP email via Gmail SMTP
        emailService.sendActivationEmail(normalizedEmail, otpCode, baseUrl);

        return pendingUser;
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
     * Step 2 of UC-01 Register:
     * Verifies the 6-digit OTP code entered by the user against the pending registration session
     * and persists the verified Buyer account into dbo.users and dbo.user_roles.
     */
    public User verifyOtpAndCreateUser(User pendingUser, String submittedOtp)
            throws InvalidTokenException, EmailExistsException, SQLException {

        if (pendingUser == null || pendingUser.getEmail() == null) {
            throw new InvalidTokenException("Registration session expired. Please fill in the registration form again.");
        }

        if (submittedOtp == null || !OTP_6_DIGIT_PATTERN.matcher(submittedOtp.trim()).matches()) {
            throw new InvalidTokenException("Please enter all 6 digits of the verification code.");
        }

        String expectedOtp = pendingUser.getEmailVerificationToken();
        if (expectedOtp == null || !expectedOtp.equals(submittedOtp.trim())) {
            throw new InvalidTokenException("Incorrect 6-digit verification code. Please check your Gmail and try again.");
        }

        if (userDAO.existsByEmail(pendingUser.getEmail())) {
            throw new EmailExistsException("This Gmail address is already registered. Please sign in.");
        }

        // Clear token and save verified ACTIVE user to database inside atomic JDBC transaction
        pendingUser.setEmailVerificationToken(null);
        pendingUser.setEmailVerified(true);
        pendingUser.setStatus("ACTIVE");

        return userDAO.createUser(pendingUser, "BUYER");
    }

    /**
     * Verifies a 6-digit OTP code for an existing unverified DB record (fallback).
     */
    public void verifyEmail(String email, String otpCode) throws InvalidTokenException, SQLException {
        if (otpCode == null || !OTP_6_DIGIT_PATTERN.matcher(otpCode.trim()).matches()) {
            throw new InvalidTokenException("Please enter a valid 6-digit verification code.");
        }

        String trimmedOtp = otpCode.trim();
        User user;
        if (email != null && !email.trim().isEmpty()) {
            user = userDAO.findByEmailAndToken(email.trim().toLowerCase(), trimmedOtp);
        } else {
            user = userDAO.findByVerificationToken(trimmedOtp);
        }

        if (user == null) {
            throw new InvalidTokenException("Incorrect 6-digit verification code. Please check your Gmail inbox and try again.");
        }

        boolean activated = userDAO.activateByToken(user.getId());
        if (!activated) {
            throw new InvalidTokenException("Failed to activate account. Please try again.");
        }
    }

    /**
     * Single-argument overload matching Sequence Diagram signature: verifyEmail(token).
     */
    public void verifyEmail(String token) throws InvalidTokenException, SQLException {
        verifyEmail(null, token);
    }

    /**
     * Generates a new 6-digit OTP code and resends the verification email to the pending user's Gmail.
     */
    public String resendOtpForPendingUser(User pendingUser, String baseUrl)
            throws ValidationException, EmailDeliveryException {
        if (pendingUser == null || pendingUser.getEmail() == null || pendingUser.getEmail().trim().isEmpty()) {
            Map<String, String> err = new LinkedHashMap<>();
            err.put("email", "Registration session expired. Please register again.");
            throw new ValidationException("Registration session expired. Please register again.", err);
        }

        String newOtpCode = generateVerificationToken();
        pendingUser.setEmailVerificationToken(newOtpCode);
        emailService.sendActivationEmail(pendingUser.getEmail(), newOtpCode, baseUrl);
        return newOtpCode;
    }

    /**
     * Generates a new 6-digit OTP code and resends the verification email (UC-01 opt [Resend activation email]).
     */
    public String resendActivation(String email, String baseUrl)
            throws ValidationException, EmailDeliveryException, SQLException {
        if (email == null || email.trim().isEmpty()) {
            Map<String, String> err = new LinkedHashMap<>();
            err.put("email", "Gmail address is required to resend the verification code.");
            throw new ValidationException("Gmail address is required.", err);
        }

        String normalizedEmail = email.trim().toLowerCase();
        String newOtpCode = generateVerificationToken();

        userDAO.updateVerificationToken(normalizedEmail, newOtpCode);
        emailService.sendActivationEmail(normalizedEmail, newOtpCode, baseUrl);
        return newOtpCode;
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
        if (user == null || user.getPasswordHash() == null || !verifyPassword(password, user.getPasswordHash())) {
            throw new BadCredentialsException("Invalid email or password");
        }

        // 2. Check email verification & account status
        if (!user.isEmailVerified() || !"ACTIVE".equalsIgnoreCase(user.getStatus())) {
            throw new AccountNotActiveException(
                    "Your account is not active yet. Please verify the 6-digit code sent to your Gmail."
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
