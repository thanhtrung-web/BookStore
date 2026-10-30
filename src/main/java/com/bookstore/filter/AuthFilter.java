package com.bookstore.filter;

import com.bookstore.model.User;

import javax.servlet.Filter;
import javax.servlet.FilterChain;
import javax.servlet.FilterConfig;
import javax.servlet.ServletException;
import javax.servlet.ServletRequest;
import javax.servlet.ServletResponse;
import javax.servlet.annotation.WebFilter;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import java.io.IOException;

/**
 * AuthFilter («filter» :AuthFilter) - Role-Based Access Control (RBAC) Filter for TSK-06 (BR-03).
 * Protects authenticated user routes (/profile, /change-password, /checkout, /orders, /wishlist)
 * and administrative routes (/admin/*, /staff/*, /inventory/*).
 */
@WebFilter(filterName = "AuthFilter", urlPatterns = {"/*"})
public class AuthFilter implements Filter {

    @Override
    public void init(FilterConfig filterConfig) throws ServletException {
        // Initialization
    }

    @Override
    public void doFilter(ServletRequest request, ServletResponse response, FilterChain chain)
            throws IOException, ServletException {

        HttpServletRequest httpReq = (HttpServletRequest) request;
        HttpServletResponse httpResp = (HttpServletResponse) response;

        String contextPath = httpReq.getContextPath();
        String requestUri = httpReq.getRequestURI();
        String path = requestUri.substring(contextPath.length());

        // 1. Always allow static assets (/static/*)
        if (path.startsWith("/static/")) {
            chain.doFilter(request, response);
            return;
        }

        HttpSession session = httpReq.getSession(false);
        User authUser = (session != null) ? (User) session.getAttribute("authUser") : null;

        // 2. Redirect already-logged-in users away from GET /login or GET /register
        if (authUser != null && "GET".equalsIgnoreCase(httpReq.getMethod())
                && ("/login".equals(path) || "/register".equals(path))) {
            httpResp.sendRedirect(contextPath + "/home");
            return;
        }

        // 3. Protect authenticated user routes (/profile, /change-password, /checkout, /orders, /wishlist)
        if (isAuthenticatedRoute(path)) {
            if (authUser == null) {
                httpResp.sendRedirect(contextPath + "/login");
                return;
            }
        }

        // 4. Role-Based Access Control (BR-03) for /admin/*, /staff/*, /inventory/*
        if (path.startsWith("/admin")) {
            if (authUser == null) {
                httpResp.sendRedirect(contextPath + "/login");
                return;
            }
            if (!authUser.hasRole("ADMIN") && !authUser.hasRole("STAFF")) {
                httpResp.sendRedirect(contextPath + "/home?error=access_denied");
                return;
            }
        } else if (path.startsWith("/staff")) {
            if (authUser == null) {
                httpResp.sendRedirect(contextPath + "/login");
                return;
            }
            if (!authUser.hasRole("ADMIN") && !authUser.hasRole("STAFF")) {
                httpResp.sendRedirect(contextPath + "/home?error=access_denied");
                return;
            }
        } else if (path.startsWith("/inventory")) {
            if (authUser == null) {
                httpResp.sendRedirect(contextPath + "/login");
                return;
            }
            if (!authUser.hasRole("ADMIN") && !authUser.hasRole("INVENTORY_STAFF") && !authUser.hasRole("STAFF")) {
                httpResp.sendRedirect(contextPath + "/home?error=access_denied");
                return;
            }
        }

        chain.doFilter(request, response);
    }

    private boolean isAuthenticatedRoute(String path) {
        return path.equals("/profile")
                || path.startsWith("/profile/")
                || path.equals("/change-password")
                || path.startsWith("/checkout")
                || path.startsWith("/orders")
                || path.startsWith("/wishlist");
    }

    @Override
    public void destroy() {
        // Cleanup
    }
}
