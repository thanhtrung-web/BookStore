package com.bookstore.dao;

import com.bookstore.context.DBContext;
import com.bookstore.model.Role;
import com.bookstore.model.User;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;
import java.util.ArrayList;
import java.util.List;

/**
 * UserDAO («dao» :UserDAO) - Data Access Layer for UC-01 Register & UC-02 Login.
 * Interacts with dbo.users, dbo.roles, and dbo.user_roles in Microsoft SQL Server.
 */
public class UserDAO {

    /**
     * Checks whether an email address is already registered in dbo.users (UC-01).
     */
    public boolean existsByEmail(String email) throws SQLException {
        String sql = "SELECT COUNT(*) FROM dbo.users WHERE email = ? AND is_deleted = 0";
        Connection conn = null;
        PreparedStatement ps = null;
        ResultSet rs = null;
        try {
            conn = DBContext.getConnection();
            ps = conn.prepareStatement(sql);
            ps.setString(1, email);
            rs = ps.executeQuery();
            if (rs.next()) {
                return rs.getInt(1) > 0;
            }
            return false;
        } finally {
            DBContext.close(conn, ps, rs);
        }
    }

    /**
     * Inserts a new User into dbo.users and assigns the specified role in dbo.user_roles
     * inside an atomic JDBC transaction (UC-01 critical [JDBC Transaction]).
     */
    public User createUser(User user, String roleName) throws SQLException {
        String insertUserSql = "INSERT INTO dbo.users "
                + "(email, password_hash, full_name, phone_number, auth_provider, "
                + "email_verification_token, is_email_verified, status, is_deleted, created_at, updated_at) "
                + "VALUES (?, ?, ?, ?, ?, ?, ?, ?, 0, GETDATE(), GETDATE())";

        String selectRoleSql = "SELECT id, role_name, description FROM dbo.roles WHERE role_name = ?";
        String insertRoleIfMissingSql = "INSERT INTO dbo.roles (role_name, description) VALUES (?, ?)";
        String insertUserRoleSql = "INSERT INTO dbo.user_roles (user_id, role_id, assigned_at) VALUES (?, ?, GETDATE())";

        Connection conn = null;
        PreparedStatement psUser = null;
        PreparedStatement psRole = null;
        PreparedStatement psCreateRole = null;
        PreparedStatement psUserRole = null;
        ResultSet rsKeys = null;
        ResultSet rsRole = null;
        ResultSet rsNewRoleKeys = null;

        try {
            conn = DBContext.getConnection();
            conn.setAutoCommit(false);

            // 1. Insert into dbo.users
            psUser = conn.prepareStatement(insertUserSql, Statement.RETURN_GENERATED_KEYS);
            psUser.setString(1, user.getEmail());
            psUser.setString(2, user.getPasswordHash());
            psUser.setString(3, user.getFullName());
            psUser.setString(4, user.getPhoneNumber());
            psUser.setString(5, user.getAuthProvider() != null ? user.getAuthProvider() : "LOCAL");
            psUser.setString(6, user.getEmailVerificationToken());
            psUser.setBoolean(7, user.isEmailVerified());
            psUser.setString(8, user.getStatus() != null ? user.getStatus() : "INACTIVE");

            int affected = psUser.executeUpdate();
            if (affected == 0) {
                throw new SQLException("Creating user failed, no rows affected.");
            }

            long newUserId;
            rsKeys = psUser.getGeneratedKeys();
            if (rsKeys.next()) {
                newUserId = rsKeys.getLong(1);
                user.setId(newUserId);
            } else {
                throw new SQLException("Creating user failed, no generated ID obtained.");
            }

            // 2. Resolve role_id from dbo.roles (create default role if missing)
            String targetRoleName = (roleName != null && !roleName.trim().isEmpty()) ? roleName.trim().toUpperCase() : "BUYER";
            long roleId;
            Role assignedRole;

            psRole = conn.prepareStatement(selectRoleSql);
            psRole.setString(1, targetRoleName);
            rsRole = psRole.executeQuery();
            if (rsRole.next()) {
                roleId = rsRole.getLong("id");
                assignedRole = new Role(roleId, rsRole.getString("role_name"), rsRole.getString("description"));
            } else {
                psCreateRole = conn.prepareStatement(insertRoleIfMissingSql, Statement.RETURN_GENERATED_KEYS);
                psCreateRole.setString(1, targetRoleName);
                psCreateRole.setString(2, "Default role " + targetRoleName);
                psCreateRole.executeUpdate();
                rsNewRoleKeys = psCreateRole.getGeneratedKeys();
                if (rsNewRoleKeys.next()) {
                    roleId = rsNewRoleKeys.getLong(1);
                    assignedRole = new Role(roleId, targetRoleName, "Default role " + targetRoleName);
                } else {
                    throw new SQLException("Failed to resolve role ID for role: " + targetRoleName);
                }
            }

            // 3. Insert into dbo.user_roles
            psUserRole = conn.prepareStatement(insertUserRoleSql);
            psUserRole.setLong(1, newUserId);
            psUserRole.setLong(2, roleId);
            psUserRole.executeUpdate();

            List<Role> roles = new ArrayList<>();
            roles.add(assignedRole);
            user.setRoles(roles);

            conn.commit();
            return user;
        } catch (SQLException ex) {
            if (conn != null) {
                try {
                    conn.rollback();
                } catch (SQLException ignored) {
                }
            }
            throw ex;
        } finally {
            if (rsNewRoleKeys != null) try { rsNewRoleKeys.close(); } catch (SQLException ignored) {}
            if (rsRole != null) try { rsRole.close(); } catch (SQLException ignored) {}
            if (psUserRole != null) try { psUserRole.close(); } catch (SQLException ignored) {}
            if (psCreateRole != null) try { psCreateRole.close(); } catch (SQLException ignored) {}
            if (psRole != null) try { psRole.close(); } catch (SQLException ignored) {}
            if (conn != null) {
                try {
                    conn.setAutoCommit(true);
                } catch (SQLException ignored) {
                }
            }
            DBContext.close(conn, psUser, rsKeys);
        }
    }

    /**
     * Finds a user record by email_verification_token (UC-01 verifyEmail).
     */
    public User findByVerificationToken(String token) throws SQLException {
        String sql = "SELECT * FROM dbo.users WHERE email_verification_token = ? AND is_deleted = 0";
        Connection conn = null;
        PreparedStatement ps = null;
        ResultSet rs = null;
        try {
            conn = DBContext.getConnection();
            ps = conn.prepareStatement(sql);
            ps.setString(1, token);
            rs = ps.executeQuery();
            if (rs.next()) {
                return mapUserRow(rs);
            }
            return null;
        } finally {
            DBContext.close(conn, ps, rs);
        }
    }

    /**
     * Finds a user record by email and 6-digit OTP verification code (UC-01 verifyEmail).
     */
    public User findByEmailAndToken(String email, String token) throws SQLException {
        String sql = "SELECT * FROM dbo.users WHERE email = ? AND email_verification_token = ? AND is_deleted = 0";
        Connection conn = null;
        PreparedStatement ps = null;
        ResultSet rs = null;
        try {
            conn = DBContext.getConnection();
            ps = conn.prepareStatement(sql);
            ps.setString(1, email);
            ps.setString(2, token);
            rs = ps.executeQuery();
            if (rs.next()) {
                return mapUserRow(rs);
            }
            return null;
        } finally {
            DBContext.close(conn, ps, rs);
        }
    }

    /**
     * Updates an existing unverified (INACTIVE) user record with newly submitted registration info and OTP code.
     */
    public boolean updatePendingUser(User user) throws SQLException {
        String sql = "UPDATE dbo.users "
                + "SET password_hash = ?, full_name = ?, phone_number = ?, "
                + "email_verification_token = ?, is_email_verified = 0, status = 'INACTIVE', updated_at = GETDATE() "
                + "WHERE email = ? AND is_email_verified = 0 AND is_deleted = 0";
        Connection conn = null;
        PreparedStatement ps = null;
        try {
            conn = DBContext.getConnection();
            ps = conn.prepareStatement(sql);
            ps.setString(1, user.getPasswordHash());
            ps.setString(2, user.getFullName());
            ps.setString(3, user.getPhoneNumber());
            ps.setString(4, user.getEmailVerificationToken());
            ps.setString(5, user.getEmail());
            return ps.executeUpdate() > 0;
        } finally {
            DBContext.close(conn, ps, null);
        }
    }

    /**
     * Activates a user account upon valid email token verification (UC-01 activateByToken).
     */
    public boolean activateByToken(long userId) throws SQLException {
        String sql = "UPDATE dbo.users "
                + "SET status = 'ACTIVE', is_email_verified = 1, email_verification_token = NULL, updated_at = GETDATE() "
                + "WHERE id = ? AND is_deleted = 0";
        Connection conn = null;
        PreparedStatement ps = null;
        try {
            conn = DBContext.getConnection();
            ps = conn.prepareStatement(sql);
            ps.setLong(1, userId);
            return ps.executeUpdate() > 0;
        } finally {
            DBContext.close(conn, ps, null);
        }
    }

    /**
     * Updates a user's email_verification_token for Resend Activation Email (UC-01 opt [Resend activation email]).
     */
    public boolean updateVerificationToken(String email, String newToken) throws SQLException {
        String sql = "UPDATE dbo.users "
                + "SET email_verification_token = ?, updated_at = GETDATE() "
                + "WHERE email = ? AND is_deleted = 0";
        Connection conn = null;
        PreparedStatement ps = null;
        try {
            conn = DBContext.getConnection();
            ps = conn.prepareStatement(sql);
            ps.setString(1, newToken);
            ps.setString(2, email);
            return ps.executeUpdate() > 0;
        } finally {
            DBContext.close(conn, ps, null);
        }
    }

    /**
     * Finds a user by email together with all assigned roles from dbo.roles and dbo.user_roles (UC-02 Login).
     */
    public User findByEmail(String email) throws SQLException {
        String sql = "SELECT u.*, r.id AS role_id, r.role_name, r.description AS role_description "
                + "FROM dbo.users u "
                + "LEFT JOIN dbo.user_roles ur ON u.id = ur.user_id "
                + "LEFT JOIN dbo.roles r ON ur.role_id = r.id "
                + "WHERE u.email = ? AND u.is_deleted = 0";

        Connection conn = null;
        PreparedStatement ps = null;
        ResultSet rs = null;
        try {
            conn = DBContext.getConnection();
            ps = conn.prepareStatement(sql);
            ps.setString(1, email);
            rs = ps.executeQuery();

            User user = null;
            List<Role> roles = new ArrayList<>();

            while (rs.next()) {
                if (user == null) {
                    user = mapUserRow(rs);
                }
                long roleId = rs.getLong("role_id");
                if (!rs.wasNull()) {
                    Role role = new Role(
                            roleId,
                            rs.getString("role_name"),
                            rs.getString("role_description")
                    );
                    roles.add(role);
                }
            }

            if (user != null) {
                user.setRoles(roles);
            }
            return user;
        } finally {
            DBContext.close(conn, ps, rs);
        }
    }

    /**
     * Finds a user by ID together with all assigned roles (UC-43 View Own Profile, UC-05 Change Password).
     */
    public User findById(long id) throws SQLException {
        String sql = "SELECT u.*, r.id AS role_id, r.role_name, r.description AS role_description "
                + "FROM dbo.users u "
                + "LEFT JOIN dbo.user_roles ur ON u.id = ur.user_id "
                + "LEFT JOIN dbo.roles r ON ur.role_id = r.id "
                + "WHERE u.id = ? AND u.is_deleted = 0";

        Connection conn = null;
        PreparedStatement ps = null;
        ResultSet rs = null;
        try {
            conn = DBContext.getConnection();
            ps = conn.prepareStatement(sql);
            ps.setLong(1, id);
            rs = ps.executeQuery();

            User user = null;
            List<Role> roles = new ArrayList<>();

            while (rs.next()) {
                if (user == null) {
                    user = mapUserRow(rs);
                }
                long roleId = rs.getLong("role_id");
                if (!rs.wasNull()) {
                    Role role = new Role(
                            roleId,
                            rs.getString("role_name"),
                            rs.getString("role_description")
                    );
                    roles.add(role);
                }
            }

            if (user != null) {
                user.setRoles(roles);
            }
            return user;
        } finally {
            DBContext.close(conn, ps, rs);
        }
    }

    /**
     * Updates user's personal profile information in dbo.users (UC-44 Update Own Profile).
     */
    public boolean updateProfile(User user) throws SQLException {
        String sql = "UPDATE dbo.users "
                + "SET full_name = ?, phone_number = ?, gender = ?, dob = ?, avatar_url = ?, updated_at = GETDATE() "
                + "WHERE id = ? AND is_deleted = 0";

        Connection conn = null;
        PreparedStatement ps = null;
        try {
            conn = DBContext.getConnection();
            ps = conn.prepareStatement(sql);
            ps.setString(1, user.getFullName());
            ps.setString(2, user.getPhoneNumber());
            ps.setString(3, user.getGender());
            ps.setDate(4, user.getDob());
            ps.setString(5, user.getAvatarUrl());
            ps.setLong(6, user.getId());
            return ps.executeUpdate() > 0;
        } finally {
            DBContext.close(conn, ps, null);
        }
    }

    /**
     * Updates user's BCrypt password hash in dbo.users (UC-05 Change Password).
     */
    public boolean updatePassword(long userId, String newPasswordHash) throws SQLException {
        String sql = "UPDATE dbo.users "
                + "SET password_hash = ?, updated_at = GETDATE() "
                + "WHERE id = ? AND is_deleted = 0";

        Connection conn = null;
        PreparedStatement ps = null;
        try {
            conn = DBContext.getConnection();
            ps = conn.prepareStatement(sql);
            ps.setString(1, newPasswordHash);
            ps.setLong(2, userId);
            return ps.executeUpdate() > 0;
        } finally {
            DBContext.close(conn, ps, null);
        }
    }

    private User mapUserRow(ResultSet rs) throws SQLException {
        User user = new User();
        user.setId(rs.getLong("id"));
        user.setEmail(rs.getString("email"));
        user.setPasswordHash(rs.getString("password_hash"));
        user.setFullName(rs.getString("full_name"));
        user.setPhoneNumber(rs.getString("phone_number"));
        user.setAvatarUrl(rs.getString("avatar_url"));
        user.setGender(rs.getString("gender"));
        user.setDob(rs.getDate("dob"));
        user.setGoogleId(rs.getString("google_id"));
        user.setAuthProvider(rs.getString("auth_provider"));
        user.setEmailVerificationToken(rs.getString("email_verification_token"));
        user.setEmailVerified(rs.getBoolean("is_email_verified"));
        user.setResetPasswordToken(rs.getString("reset_password_token"));
        user.setResetPasswordTokenExpiry(rs.getTimestamp("reset_password_token_expiry"));
        user.setStatus(rs.getString("status"));
        user.setDeleted(rs.getBoolean("is_deleted"));
        user.setCreatedAt(rs.getTimestamp("created_at"));
        user.setUpdatedAt(rs.getTimestamp("updated_at"));
        return user;
    }


    /**
     * Retrieves all non-deleted user accounts for the admin user management page.
     *
     * @return a list of user accounts ordered by creation date
     * @throws SQLException if a database error occurs
     */
    public List<User> findAllUsers() throws SQLException {
        String sql = "SELECT id, email, full_name, phone_number, status, "
                + "is_email_verified, created_at "
                + "FROM dbo.users "
                + "WHERE is_deleted = 0 "
                + "ORDER BY created_at DESC";

        List<User> users = new ArrayList<>();

        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {

            while (rs.next()) {
                User user = new User();
                user.setId(rs.getLong("id"));
                user.setEmail(rs.getString("email"));
                user.setFullName(rs.getString("full_name"));
                user.setPhoneNumber(rs.getString("phone_number"));
                user.setStatus(rs.getString("status"));
                user.setEmailVerified(rs.getBoolean("is_email_verified"));
                user.setCreatedAt(rs.getTimestamp("created_at"));
                users.add(user);
            }
        }

        return users;
    }

    /**
     * Updates the status of a non-deleted user account.
     *
     * @param userId the ID of the account to update
     * @param status the new account status, ACTIVE or LOCKED
     * @return true if an account was updated
     * @throws SQLException if a database error occurs
     */
    public boolean updateUserStatus(long userId, String status) throws SQLException {
        if (!"ACTIVE".equals(status) && !"LOCKED".equals(status)) {
            throw new IllegalArgumentException("Unsupported account status.");
        }

        String sql = "UPDATE dbo.users "
                + "SET status = ?, updated_at = GETDATE() "
                + "WHERE id = ? AND is_deleted = 0";

        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setString(1, status);
            ps.setLong(2, userId);

            return ps.executeUpdate() == 1;
        }
    }
}