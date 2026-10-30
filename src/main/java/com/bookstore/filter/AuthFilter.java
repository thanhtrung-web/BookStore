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
 * AuthFilter («filter» :AuthFilter) - Role-Based Access Control (RBAC) & Security Filter.
 * Protects:
 *  - Traps and prevents direct client access to internal JSP views (/views/admin/*, /views/staff/*, etc.)
 *  - Administrative & Staff Routes (/dashboard/admin/*, /dashboard/staff/*) -> strictly requires ADMIN/STAFF
 *  - Unauthorized attempts to access admin/staff URLs are silently redirected to Buyer /login
 *  - Authenticated Buyer routes (/profile, /change-password, /checkout, /orders, /wishlist)
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
        Object userRole = (session != null) ? session.getAttribute("userRole") : null;

        // 2. Trap direct client attempts to browse internal JSP views
        // Redirect directly to /login so the existence of dashboard is never disclosed
        if (path.startsWith("/views/admin/") || path.startsWith("/views/staff/")) {
            httpResp.sendRedirect(contextPath + "/login");
            return;
        }

        // 3. Prevent already-logged-in buyers from visiting GET /login or GET /register
        if (authUser != null && "GET".equalsIgnoreCase(httpReq.getMethod())
                && ("/login".equals(path) || "/register".equals(path))) {
            httpResp.sendRedirect(contextPath + "/home");
            return;
        }

        // 4. Portal login endpoints (/dashboard, /dashboard/logout) are publicly accessible to staff/admin
        if ("/dashboard".equals(path) || "/dashboard/logout".equals(path)) {
            chain.doFilter(request, response);
            return;
        }

        // 5. Admin Routes (/dashboard/admin, /dashboard/admin/*)
        // If not authenticated or not ADMIN, redirect to Buyer /login (hiding dashboard presence)
        if (path.equals("/dashboard/admin") || path.startsWith("/dashboard/admin/")) {
            if (authUser == null || (!authUser.hasRole("ADMIN") && !"ADMIN".equals(userRole))) {
                httpResp.sendRedirect(contextPath + "/login");
                return;
            }
        }

        // 6. Staff Routes (/dashboard/staff, /dashboard/staff/*)
        // If not authenticated or neither STAFF nor ADMIN, redirect to Buyer /login
        if (path.equals("/dashboard/staff") || path.startsWith("/dashboard/staff/")) {
            boolean isStaffOrAdmin = authUser != null && (authUser.hasRole("ADMIN")
                    || authUser.hasRole("STAFF")
                    || authUser.hasRole("INVENTORY_STAFF")
                    || "ADMIN".equals(userRole)
                    || "STAFF".equals(userRole));
            if (!isStaffOrAdmin) {
                httpResp.sendRedirect(contextPath + "/login");
                return;
            }
        }

        // 7. Protect customer authenticated routes (/profile, /change-password, /checkout, /orders, /wishlist)
        if (isAuthenticatedBuyerRoute(path)) {
            if (authUser == null) {
                httpResp.sendRedirect(contextPath + "/login");
                return;
            }
        }

        chain.doFilter(request, response);
    }

    private boolean isAuthenticatedBuyerRoute(String path) {
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
