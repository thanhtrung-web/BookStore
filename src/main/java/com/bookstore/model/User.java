package com.bookstore.model;

import java.io.Serializable;
import java.sql.Date;
import java.sql.Timestamp;
import java.util.ArrayList;
import java.util.List;

/**
 * User POJO mapping to table dbo.users and dbo.user_roles (TSK-02).
 */
public class User implements Serializable {

    private static final long serialVersionUID = 1L;

    private Long id;
    private String email;
    private String passwordHash;
    private String fullName;
    private String phoneNumber;
    private String avatarUrl;
    private String gender;
    private Date dob;
    private String googleId;
    private String authProvider = "LOCAL";
    private String emailVerificationToken;
    private boolean emailVerified;
    private String resetPasswordToken;
    private Timestamp resetPasswordTokenExpiry;
    private String status = "INACTIVE";
    private boolean deleted;
    private Timestamp createdAt;
    private Timestamp updatedAt;

    private List<Role> roles = new ArrayList<>();

    public User() {
    }

    public User(Long id, String email, String passwordHash, String fullName, String phoneNumber, String status) {
        this.id = id;
        this.email = email;
        this.passwordHash = passwordHash;
        this.fullName = fullName;
        this.phoneNumber = phoneNumber;
        this.status = status;
    }

    /**
     * Checks whether the user holds a specific role name (e.g. ADMIN, STAFF, BUYER).
     */
    public boolean hasRole(String roleName) {
        if (roleName == null || roles == null) {
            return false;
        }
        for (Role role : roles) {
            if (role != null && roleName.equalsIgnoreCase(role.getRoleName())) {
                return true;
            }
        }
        return false;
    }

    /**
     * Returns the highest priority role name for session routing (ADMIN > STAFF > INVENTORY_STAFF > BUYER).
     */
    public String getPrimaryRole() {
        if (hasRole("ADMIN")) {
            return "ADMIN";
        }
        if (hasRole("STAFF")) {
            return "STAFF";
        }
        if (hasRole("INVENTORY_STAFF")) {
            return "INVENTORY_STAFF";
        }
        if (roles != null && !roles.isEmpty() && roles.get(0).getRoleName() != null) {
            return roles.get(0).getRoleName();
        }
        return "BUYER";
    }

    public Long getId() {
        return id;
    }

    public void setId(Long id) {
        this.id = id;
    }

    public String getEmail() {
        return email;
    }

    public void setEmail(String email) {
        this.email = email;
    }

    public String getPasswordHash() {
        return passwordHash;
    }

    public void setPasswordHash(String passwordHash) {
        this.passwordHash = passwordHash;
    }

    public String getFullName() {
        return fullName;
    }

    public void setFullName(String fullName) {
        this.fullName = fullName;
    }

    public String getPhoneNumber() {
        return phoneNumber;
    }

    public void setPhoneNumber(String phoneNumber) {
        this.phoneNumber = phoneNumber;
    }

    public String getAvatarUrl() {
        return avatarUrl;
    }

    public void setAvatarUrl(String avatarUrl) {
        this.avatarUrl = avatarUrl;
    }

    public String getGender() {
        return gender;
    }

    public void setGender(String gender) {
        this.gender = gender;
    }

    public Date getDob() {
        return dob;
    }

    public void setDob(Date dob) {
        this.dob = dob;
    }

    public String getGoogleId() {
        return googleId;
    }

    public void setGoogleId(String googleId) {
        this.googleId = googleId;
    }

    public String getAuthProvider() {
        return authProvider;
    }

    public void setAuthProvider(String authProvider) {
        this.authProvider = authProvider;
    }

    public String getEmailVerificationToken() {
        return emailVerificationToken;
    }

    public void setEmailVerificationToken(String emailVerificationToken) {
        this.emailVerificationToken = emailVerificationToken;
    }

    public boolean isEmailVerified() {
        return emailVerified;
    }

    public void setEmailVerified(boolean emailVerified) {
        this.emailVerified = emailVerified;
    }

    public String getResetPasswordToken() {
        return resetPasswordToken;
    }

    public void setResetPasswordToken(String resetPasswordToken) {
        this.resetPasswordToken = resetPasswordToken;
    }

    public Timestamp getResetPasswordTokenExpiry() {
        return resetPasswordTokenExpiry;
    }

    public void setResetPasswordTokenExpiry(Timestamp resetPasswordTokenExpiry) {
        this.resetPasswordTokenExpiry = resetPasswordTokenExpiry;
    }

    public String getStatus() {
        return status;
    }

    public void setStatus(String status) {
        this.status = status;
    }

    public boolean isDeleted() {
        return deleted;
    }

    public void setDeleted(boolean deleted) {
        this.deleted = deleted;
    }

    public Timestamp getCreatedAt() {
        return createdAt;
    }

    public void setCreatedAt(Timestamp createdAt) {
        this.createdAt = createdAt;
    }

    public Timestamp getUpdatedAt() {
        return updatedAt;
    }

    public void setUpdatedAt(Timestamp updatedAt) {
        this.updatedAt = updatedAt;
    }

    public List<Role> getRoles() {
        return roles;
    }

    public void setRoles(List<Role> roles) {
        this.roles = roles != null ? roles : new ArrayList<>();
    }

    @Override
    public String toString() {
        return "User{" +
                "id=" + id +
                ", email='" + email + '\'' +
                ", fullName='" + fullName + '\'' +
                ", phoneNumber='" + phoneNumber + '\'' +
                ", emailVerified=" + emailVerified +
                ", status='" + status + '\'' +
                ", primaryRole='" + getPrimaryRole() + '\'' +
                '}';
    }
}
