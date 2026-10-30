package com.bookstore.service;

import com.bookstore.dao.UserDAO;
import com.bookstore.model.User;
import org.mindrot.jbcrypt.BCrypt;

import java.sql.Date;
import java.sql.SQLException;
import java.util.regex.Pattern;

/**
 * Business Logic Service for User Profile & Password Management.
 * Implements TSK-07:
 *  - UC-43: View Own Profile
 *  - UC-44: Update Own Profile
 *  - UC-05: Change Password
 */
public class UserService {

    private static final Pattern PHONE_PATTERN = Pattern.compile("^(0|\\+84)[0-9]{8,10}$");
    private static final int BCRYPT_LOG_ROUNDS = 12;

    private final UserDAO userDAO;

    public UserService() {
        this.userDAO = new UserDAO();
    }

    /**
     * Retrieves a user's fresh profile and roles from the database by ID (UC-43).
     */
    public User getUserById(long userId) throws SQLException {
        return userDAO.findById(userId);
    }

    /**
     * Validates and updates the user's personal profile information (UC-44).
     */
    public ProfileUpdateResult updateProfile(long userId, String fullName, String phoneNumber,
                                             String gender, String dobStr, String avatarUrl) throws SQLException {
        User user = userDAO.findById(userId);
        if (user == null) {
            return ProfileUpdateResult.failure("User account not found.");
        }

        String trimmedName = fullName != null ? fullName.trim() : "";
        String trimmedPhone = phoneNumber != null ? phoneNumber.trim() : "";
        String trimmedGender = gender != null ? gender.trim() : "Male";
        String trimmedDob = dobStr != null ? dobStr.trim() : "";

        if (trimmedName.isEmpty()) {
            return ProfileUpdateResult.failure("Full name must not be empty.");
        }
        if (trimmedName.length() > 150) {
            return ProfileUpdateResult.failure("Full name must not exceed 150 characters.");
        }

        if (!trimmedPhone.isEmpty() && !PHONE_PATTERN.matcher(trimmedPhone).matches()) {
            return ProfileUpdateResult.failure("Invalid phone number format (e.g., 0901234567).");
        }

        if (!"Male".equalsIgnoreCase(trimmedGender)
                && !"Female".equalsIgnoreCase(trimmedGender)
                && !"Other".equalsIgnoreCase(trimmedGender)) {
            trimmedGender = "Male";
        }

        Date parsedDob = null;
        if (!trimmedDob.isEmpty()) {
            try {
                parsedDob = Date.valueOf(trimmedDob);
            } catch (IllegalArgumentException e) {
                return ProfileUpdateResult.failure("Invalid Date of Birth format (expected YYYY-MM-DD).");
            }
        }

        user.setFullName(trimmedName);
        user.setPhoneNumber(trimmedPhone.isEmpty() ? null : trimmedPhone);
        user.setGender(trimmedGender);
        user.setDob(parsedDob);
        if (avatarUrl != null && !avatarUrl.trim().isEmpty()) {
            user.setAvatarUrl(avatarUrl.trim());
        }

        boolean updated = userDAO.updateProfile(user);
        if (!updated) {
            return ProfileUpdateResult.failure("Unable to update profile in database.");
        }

        User refreshedUser = userDAO.findById(userId);
        return ProfileUpdateResult.success("Your personal profile has been updated successfully!", refreshedUser);
    }

    /**
     * Validates current password and updates to a new BCrypt-hashed password (UC-05 Change Password).
     */
    public PasswordChangeResult changePassword(long userId, String currentPassword,
                                               String newPassword, String confirmPassword) throws SQLException {
        if (currentPassword == null || currentPassword.isEmpty()
                || newPassword == null || newPassword.isEmpty()
                || confirmPassword == null || confirmPassword.isEmpty()) {
            return PasswordChangeResult.failure("Please fill in all password fields.");
        }

        User user = userDAO.findById(userId);
        if (user == null) {
            return PasswordChangeResult.failure("User account not found.");
        }

        // Verify current password using BCrypt (UC-05 Sequence Diagram step 1.1: verifyCurrentPassword)
        if (user.getPasswordHash() == null || !BCrypt.checkpw(currentPassword, user.getPasswordHash())) {
            return PasswordChangeResult.failure("Current password is incorrect.");
        }

        if (newPassword.length() < 8) {
            return PasswordChangeResult.failure("New password must be at least 8 characters long.");
        }

        if (!newPassword.equals(confirmPassword)) {
            return PasswordChangeResult.failure("New password and confirmation password do not match.");
        }

        if (BCrypt.checkpw(newPassword, user.getPasswordHash())) {
            return PasswordChangeResult.failure("New password must be different from your current password.");
        }

        String newPasswordHash = BCrypt.hashpw(newPassword, BCrypt.gensalt(BCRYPT_LOG_ROUNDS));
        boolean updated = userDAO.updatePassword(userId, newPasswordHash);
        if (!updated) {
            return PasswordChangeResult.failure("Failed to update password. Please try again.");
        }

        return PasswordChangeResult.success("Your password has been updated successfully!");
    }

    public static class ProfileUpdateResult {
        private final boolean success;
        private final String message;
        private final User user;

        private ProfileUpdateResult(boolean success, String message, User user) {
            this.success = success;
            this.message = message;
            this.user = user;
        }

        public static ProfileUpdateResult success(String message, User user) {
            return new ProfileUpdateResult(true, message, user);
        }

        public static ProfileUpdateResult failure(String message) {
            return new ProfileUpdateResult(false, message, null);
        }

        public boolean isSuccess() {
            return success;
        }

        public String getMessage() {
            return message;
        }

        public User getUser() {
            return user;
        }
    }

    public static class PasswordChangeResult {
        private final boolean success;
        private final String message;

        private PasswordChangeResult(boolean success, String message) {
            this.success = success;
            this.message = message;
        }

        public static PasswordChangeResult success(String message) {
            return new PasswordChangeResult(true, message);
        }

        public static PasswordChangeResult failure(String message) {
            return new PasswordChangeResult(false, message);
        }

        public boolean isSuccess() {
            return success;
        }

        public String getMessage() {
            return message;
        }
    }
}
