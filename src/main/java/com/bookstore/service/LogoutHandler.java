package com.bookstore.service;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpSession;

/**
 * LogoutHandler («service» :LogoutHandler) - Handles session invalidation for UC-03 Logout (TSK-05).
 */
public class LogoutHandler {

    /**
     * Invalidates the current HTTP session if one exists.
     */
    public void logout(HttpServletRequest request) {
        if (request == null) {
            return;
        }
        HttpSession session = request.getSession(false);
        if (session != null) {
            session.removeAttribute("authUser");
            session.removeAttribute("userRole");
            session.invalidate();
        }
    }
}
