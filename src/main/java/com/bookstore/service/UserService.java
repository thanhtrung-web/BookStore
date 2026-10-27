
package com.bookstore.service;

import com.bookstore.dao.UserDAO;
import com.bookstore.model.User;

import java.sql.SQLException;
import java.util.List;

/**
 * UserService provides business logic for administrator user management.
 */
public class UserService {

    private final UserDAO userDAO;

    /**
     * Creates a UserService with a UserDAO instance.
     */
    public UserService() {
        this.userDAO = new UserDAO();
    }

    /**
     * Creates a UserService with the specified UserDAO.
     *
     * @param userDAO the data access object used to manage users
     */
    public UserService(UserDAO userDAO) {
        if (userDAO == null) {
            throw new IllegalArgumentException("UserDAO cannot be null.");
        }
        this.userDAO = userDAO;
    }

    /**
     * Retrieves all non-deleted user accounts.
     *
     * @return the list of user accounts
     * @throws SQLException if a database error occurs
     */
    public List<User> getAllUsers() throws SQLException {
        return userDAO.findAllUsers();
    }

    /**
     * Changes an account status to ACTIVE or LOCKED.
     *
     * @param userId the ID of the account to update
     * @param status the requested account status
     * @return true if the account was updated
     * @throws IllegalArgumentException if the user ID or status is invalid
     * @throws SQLException if a database error occurs
     */
    public boolean updateUserStatus(long userId, String status)
            throws SQLException {

        if (userId <= 0) {
            throw new IllegalArgumentException("Invalid user ID.");
        }

        if (!"ACTIVE".equals(status) && !"LOCKED".equals(status)) {
            throw new IllegalArgumentException("Unsupported account status.");
        }

        return userDAO.updateUserStatus(userId, status);
    }
}
