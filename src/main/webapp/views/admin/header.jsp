<%@ page contentType="text/html;charset=UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<header style="height:64px;background:#0f172a;color:#fff;padding:0 24px;display:flex;justify-content:space-between;align-items:center;font-family:Arial,sans-serif;position:relative;z-index:30">
    <a href="${pageContext.request.contextPath}/dashboard/admin" style="color:#fff;text-decoration:none;font-weight:800;font-size:16px">BookStore Management Website <span style="color:#60a5fa">Admin</span></a>
    <nav style="display:flex;gap:20px;align-items:center;font-size:13px">
        <a style="color:#cbd5e1;text-decoration:none" href="${pageContext.request.contextPath}/dashboard/admin">Dashboard</a>
        <a style="color:#cbd5e1;text-decoration:none" href="${pageContext.request.contextPath}/dashboard/admin?view=books">Book Catalog</a>
        <a style="color:#cbd5e1;text-decoration:none" href="${pageContext.request.contextPath}/dashboard/admin?view=orders">Orders &amp; Invoices</a>
        <a style="color:#cbd5e1;text-decoration:none" href="${pageContext.request.contextPath}/dashboard/staff">Staff Workspace</a>
        <a style="color:#cbd5e1;text-decoration:none" href="${pageContext.request.contextPath}/home">Storefront ↗</a>
        <details style="position:relative">
            <summary style="cursor:pointer;color:#fff;list-style:none;padding:8px 10px;border-radius:8px;background:#1e293b"><c:out value="${sessionScope.authUser.fullName}"/> ▾</summary>
            <div style="position:absolute;right:0;top:36px;width:180px;background:#fff;padding:8px;border-radius:8px;box-shadow:0 8px 24px #0003;z-index:50">
                <a style="display:block;padding:9px;color:#334155;text-decoration:none" href="${pageContext.request.contextPath}/profile">My Profile</a>
                <a style="display:block;padding:9px;color:#334155;text-decoration:none" href="${pageContext.request.contextPath}/change-password">Change Password</a>
                <a style="display:block;padding:9px;color:#be123c;text-decoration:none" href="${pageContext.request.contextPath}/dashboard/logout">Sign Out</a>
            </div>
        </details>
    </nav>
</header>
