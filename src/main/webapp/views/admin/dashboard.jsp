<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>BookStore - Administrator Portal</title>
    <script src="https://www.gstatic.com/antigravity/web/dev/tailwindcss.min.js"></script>
    <style>
        @import url('https://fonts.googleapis.com/css2?family=Plus+Jakarta+Sans:wght@400;500;600;700;800;900&display=swap');

        body {
            font-family: 'Plus Jakarta Sans', system-ui, -apple-system, sans-serif;
            background-color: #0f172a;
        }

        .custom-scrollbar::-webkit-scrollbar {
            width: 6px;
            height: 6px;
        }
        .custom-scrollbar::-webkit-scrollbar-track {
            background: #f1f5f9;
            border-radius: 9999px;
        }
        .custom-scrollbar::-webkit-scrollbar-thumb {
            background: #cbd5e1;
            border-radius: 9999px;
        }
        .custom-scrollbar::-webkit-scrollbar-thumb:hover {
            background: #94a3b8;
        }

        .nav-item-active {
            background-color: #2563eb;
            color: #ffffff !important;
            font-weight: 700;
            box-shadow: 0 4px 12px rgba(37, 99, 235, 0.25);
        }
        .nav-item-active svg {
            color: #ffffff !important;
        }

        .hover-card {
            transition: all 0.2s cubic-bezier(0.4, 0, 0.2, 1);
        }
        .hover-card:hover {
            transform: translateY(-2px);
            box-shadow: 0 10px 25px -5px rgba(15, 23, 42, 0.08), 0 8px 10px -6px rgba(15, 23, 42, 0.04);
        }

        @keyframes pulse-dot {
            0%, 100% { transform: scale(1); opacity: 1; }
            50% { transform: scale(1.3); opacity: 0.7; }
        }
        .animate-pulse-dot {
            animation: pulse-dot 2s infinite ease-in-out;
        }
    </style>
</head>
<body class="bg-slate-50 text-slate-800 antialiased h-screen flex flex-col overflow-hidden">

    <jsp:include page="header.jsp"/>

    <!-- ================================================================= -->
    <!-- 2. MAIN LAYOUT: ADMIN SIDEBAR + WORKSPACE                         -->
    <!-- ================================================================= -->
    <div class="flex-1 flex overflow-hidden">
        
        <!-- =============================================================== -->
        <!-- 2.1. ADMIN SIDEBAR                                              -->
        <!-- =============================================================== -->
        <aside class="w-64 bg-white border-r border-slate-200/90 flex flex-col flex-shrink-0 z-20">
            
            <!-- Current Admin Profile Card -->
            <div class="p-4 border-b border-slate-100 bg-slate-50/70">
                <div class="flex items-center gap-3">
                    <div class="w-10 h-10 rounded-xl bg-gradient-to-br from-blue-600 to-indigo-700 text-white flex items-center justify-center font-bold text-base shadow-sm">
                        <c:choose>
                            <c:when test="${not empty sessionScope.authUser}">
                                <c:out value="${sessionScope.authUser.fullName.substring(0, 1).toUpperCase()}"/>
                            </c:when>
                            <c:otherwise>AD</c:otherwise>
                        </c:choose>
                    </div>
                    <div class="min-w-0 flex-1">
                        <h4 class="text-xs font-bold text-slate-900 truncate">
                            <c:choose>
                                <c:when test="${not empty sessionScope.authUser}">
                                    <c:out value="${sessionScope.authUser.fullName}"/> (Admin)
                                </c:when>
                                <c:otherwise>TrungTT (Admin)</c:otherwise>
                            </c:choose>
                        </h4>
                        <div class="flex items-center gap-1.5 mt-0.5">
                            <span class="w-2 h-2 rounded-full bg-emerald-500 animate-pulse-dot"></span>
                            <span class="text-[10px] font-extrabold text-blue-600 uppercase tracking-wider">Super Administrator</span>
                        </div>
                    </div>
                </div>
            </div>

            <!-- Admin Navigation Menu -->
            <nav class="flex-1 px-3 py-4 space-y-1.5 overflow-y-auto custom-scrollbar text-xs">
                
                <!-- 1. Dashboard -->
                <button onclick="navigateAdminTo('dashboard')" id="nav-dashboard" class="w-full nav-item-active flex items-center gap-3 px-3.5 py-2.5 rounded-xl font-semibold transition text-slate-600 hover:bg-slate-100">
                    <svg class="w-4 h-4 text-slate-500" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M3 12l2-2m0 0l7-7 7 7M5 10v10a1 1 0 001 1h3m10-11l2 2m-2-2v10a1 1 0 01-1 1h-3m-6 0a1 1 0 001-1v-4a1 1 0 011-1h2a1 1 0 011 1v4a1 1 0 001 1m-6 0h6"/></svg>
                    <span>Executive Dashboard</span>
                </button>

                <!-- Book Catalog -->
                <button onclick="window.location.href='${pageContext.request.contextPath}/dashboard/admin?view=books'" id="nav-books" class="w-full flex items-center justify-between px-3.5 py-2.5 rounded-xl font-semibold text-slate-600 hover:bg-slate-100 transition">
                    <div class="flex items-center gap-3">
                        <svg class="w-4 h-4 text-slate-500" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 6.253v13m0-13C10.832 5.477 9.246 5 7.5 5S4.168 5.477 3 6.253v13C4.168 18.477 5.754 18 7.5 18s3.332.477 4.5 1.253m0-13C13.168 5.477 14.754 5 16.5 5c1.747 0 3.332.477 4.5 1.253v13C19.832 18.477 18.247 18 16.5 18c-1.746 0-3.332.477-4.5 1.253"/></svg>
                        <span>Book Catalog</span>
                    </div>
                </button>

                <!-- 3. Category & Author Management -->
                <button onclick="showToast('Category &amp; Publisher master taxonomy manager.')" class="w-full flex items-center gap-3 px-3.5 py-2.5 rounded-xl font-semibold text-slate-600 hover:bg-slate-100 transition">
                    <svg class="w-4 h-4 text-slate-500" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M7 7h.01M7 3h5c.512 0 1.024.195 1.414.586l7 7a2 2 0 010 2.828l-7 7a2 2 0 01-2.828 0l-7-7A1.994 1.994 0 013 12V7a4 4 0 014-4z"/></svg>
                    <span>Categories &amp; Authors</span>
                </button>

                <!-- Orders Management -->
                <button onclick="window.location.href='${pageContext.request.contextPath}/dashboard/admin?view=orders'" id="nav-orders" class="w-full flex items-center justify-between px-3.5 py-2.5 rounded-xl font-semibold text-slate-600 hover:bg-slate-100 transition">
                    <div class="flex items-center gap-3">
                        <svg class="w-4 h-4 text-slate-500" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M16 11V7a4 4 0 00-8 0v4M5 9h14l1 12H4L5 9z"/></svg>
                        <span>Orders &amp; Invoices</span>
                    </div>
                </button>

                <!-- Return & Refund Approvals -->
                <button onclick="navigateAdminTo('returns')" id="nav-returns" class="w-full flex items-center justify-between px-3.5 py-2.5 rounded-xl font-semibold text-slate-600 hover:bg-slate-100 transition">
                    <div class="flex items-center gap-3">
                        <svg class="w-4 h-4 text-slate-500" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M4 4v5h.582m15.356 2A8.001 8.001 0 004.582 9m0 0H9m11 11v-5h-.581m0 0a8.003 8.003 0 01-15.357-2m15.357 2H15"/></svg>
                        <span>Return &amp; Refund Audit</span>
                    </div>
                </button>

                <!-- User Accounts & RBAC -->
                <button type="button"
        onclick="navigateAdminTo('users')"
        id="nav-users"
        class="w-full flex items-center justify-between px-3.5 py-2.5 rounded-xl font-semibold text-slate-600 hover:bg-slate-100 transition">

    <div class="flex items-center gap-3">
        <svg class="w-4 h-4 text-purple-600" fill="none" stroke="currentColor"
             viewBox="0 0 24 24">
            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2"
                  d="M12 4.354a4 4 0 110 5.292M15 21H3v-1a6 6 0 0112 0v1zm0 0h6v-1a6 6 0 00-9-5.197M13 7a4 4 0 11-8 0 4 4 0 018 0z"/>
        </svg>
        <span>User Management</span>
    </div>

</button>

                <!-- Vouchers & Promotions -->
                <button onclick="navigateAdminTo('vouchers')" id="nav-vouchers" class="w-full flex items-center justify-between px-3.5 py-2.5 rounded-xl font-semibold text-slate-600 hover:bg-slate-100 transition">
                    <div class="flex items-center gap-3">
                        <svg class="w-4 h-4 text-amber-600" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M15 5v2m0 4v2m0 4v2M5 5a2 2 0 00-2 2v3a2 2 0 110 4v3a2 2 0 002 2h14a2 2 0 002-2v-3a2 2 0 110-4V7a2 2 0 00-2-2H5z"/></svg>
                        <span>Vouchers &amp; Campaigns</span>
                    </div>
                </button>

                <!-- Financial Analytics -->
                <button onclick="navigateAdminTo('analytics')" id="nav-analytics" class="w-full flex items-center gap-3 px-3.5 py-2.5 rounded-xl font-semibold text-slate-600 hover:bg-slate-100 transition">
                    <svg class="w-4 h-4 text-emerald-600" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 19v-6a2 2 0 00-2-2H5a2 2 0 00-2 2v6a2 2 0 002 2h2a2 2 0 002-2zm0 0V9a2 2 0 012-2h2a2 2 0 012 2v10m-6 0a2 2 0 002 2h2a2 2 0 002-2m0 0V5a2 2 0 012-2h2a2 2 0 012 2v14a2 2 0 01-2 2h-2a2 2 0 01-2-2z"/></svg>
                    <span>Revenue &amp; Analytics</span>
                </button>

            </nav>

            <!-- Sidebar Footer -->
            <div class="p-4 border-t border-slate-100 flex items-center justify-between">
                <span class="text-[11px] font-semibold text-slate-400">BookStore Admin</span>
                <a href="${pageContext.request.contextPath}/dashboard/logout" class="text-xs font-bold text-rose-600 hover:text-rose-700 hover:underline">Sign Out</a>
            </div>
        </aside>

        <!-- =============================================================== -->
        <!-- 2.2. MAIN WORKSPACE                                             -->
        <!-- =============================================================== -->
        <main class="flex-1 flex flex-col overflow-hidden bg-[#f8fafc]">
            
            <!-- Top Workspace Bar -->
            <div class="bg-white border-b border-slate-200/80 px-6 py-3.5 flex items-center justify-between flex-shrink-0">
                <div>
                    <div class="flex items-center gap-2 text-xs text-slate-400 font-medium">
                        <span>Admin</span>
                        <span>/</span>
                        <span id="adminBreadcrumb" class="text-slate-800 font-bold">Executive Dashboard</span>
                    </div>
                    <h2 id="adminPageHeader" class="text-lg font-extrabold text-slate-900 leading-tight mt-0.5">
                        System Executive Overview
                    </h2>
                </div>

                
            </div>

            <!-- Scrollable Main Container -->
            <div class="flex-1 overflow-y-auto custom-scrollbar p-6 space-y-6">

                <!-- ============================================================= -->
                <!-- VIEW 1: EXECUTIVE DASHBOARD                                   -->
                <!-- ============================================================= -->
                <section id="view-dashboard" class="space-y-6">
                    
                    <!-- Welcome Banner -->
                    <div class="p-5 rounded-2xl bg-gradient-to-r from-blue-900 via-indigo-900 to-slate-900 text-white shadow-sm flex flex-col sm:flex-row items-start sm:items-center justify-between gap-4">
                        <div class="space-y-1">
                            <h3 class="text-base font-extrabold">Welcome back, <c:out value="${sessionScope.authUser.fullName}"/>!</h3>
                            <p class="text-xs text-blue-200">Here is an overview of your bookstore operations.</p>
                        </div>
                    </div>

                    <!-- 4 Executive KPIs: loaded from ReportController -->
                    <c:if test="${not empty reportError}">
                        <div class="p-4 rounded-xl border border-rose-200 bg-rose-50 text-rose-700 text-sm">
                            <strong>Report loading error:</strong>
                            <c:out value="${reportError}"/>
                        </div>
                    </c:if>

                    <div class="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-4 gap-4">
                        <div class="bg-white p-5 rounded-2xl border border-slate-200/80 shadow-sm hover-card">
                            <div class="flex items-center justify-between">
                                <span class="text-xs font-bold text-slate-500 uppercase tracking-wider">Gross Revenue</span>
                                <span class="w-9 h-9 rounded-xl bg-emerald-50 text-emerald-600 flex items-center justify-center text-base font-bold">💰</span>
                            </div>
                            <h3 class="mt-3 text-2xl font-black text-slate-900">
                                <fmt:formatNumber value="${reportSummary.totalRevenue}" type="number" groupingUsed="true" maxFractionDigits="0"/> ₫
                            </h3>
                            <p class="text-[11px] text-slate-400 mt-1">Paid and delivered orders</p>
                        </div>

                        <div class="bg-white p-5 rounded-2xl border border-slate-200/80 shadow-sm hover-card">
                            <div class="flex items-center justify-between">
                                <span class="text-xs font-bold text-slate-500 uppercase tracking-wider">Paid &amp; Delivered Orders</span>
                                <span class="w-9 h-9 rounded-xl bg-blue-50 text-blue-600 flex items-center justify-center text-base font-bold">📦</span>
                            </div>
                            <h3 class="mt-3 text-2xl font-black text-slate-900">
                                <fmt:formatNumber value="${reportSummary.totalOrders}" groupingUsed="true"/>
                            </h3>
                            <p class="text-[11px] text-slate-400 mt-1">Orders included in the revenue report</p>
                        </div>

                        <div class="bg-white p-5 rounded-2xl border border-slate-200/80 shadow-sm hover-card">
                            <div class="flex items-center justify-between">
                                <span class="text-xs font-bold text-slate-500 uppercase tracking-wider">Books in Catalog</span>
                                <span class="w-9 h-9 rounded-xl bg-amber-50 text-amber-600 flex items-center justify-center text-base font-bold">📚</span>
                            </div>
                            <h3 class="mt-3 text-2xl font-black text-slate-900">
                                <fmt:formatNumber value="${reportSummary.totalBooks}" groupingUsed="true"/>
                            </h3>
                            <p class="text-[11px] text-slate-400 mt-1">Non-deleted books</p>
                        </div>

                        <div class="bg-white p-5 rounded-2xl border border-slate-200/80 shadow-sm hover-card">
                            <div class="flex items-center justify-between">
                                <span class="text-xs font-bold text-slate-500 uppercase tracking-wider">Active Customers</span>
                                <span class="w-9 h-9 rounded-xl bg-purple-50 text-purple-600 flex items-center justify-center text-base font-bold">👥</span>
                            </div>
                            <h3 class="mt-3 text-2xl font-black text-slate-900">
                                <fmt:formatNumber value="${reportSummary.activeCustomers}" groupingUsed="true"/>
                            </h3>
                            <p class="text-[11px] text-slate-400 mt-1">Active buyer accounts</p>
                        </div>

                    </div>

                    <!-- Quick Access Cards -->
                    <div class="grid grid-cols-1 lg:grid-cols-12 gap-6">
                        <!-- Left 8 Cols: Top Selling Books -->
                        <div class="lg:col-span-12 bg-white p-5 rounded-2xl border border-slate-200/80 shadow-sm space-y-4">
                            <div class="flex items-center justify-between">
                                <div>
                                    <h3 class="text-sm font-extrabold text-slate-900">🔥 Top Performing Books</h3>
                                    <p class="text-xs text-slate-400">Ranked by total revenue and unit sales</p>
                                </div>
                                <button onclick="window.location.href='${pageContext.request.contextPath}/dashboard/admin?view=books'" class="text-xs font-bold text-blue-600 hover:underline">View Catalog &rarr;</button>
                            </div>

                            <div class="overflow-x-auto custom-scrollbar">
                                <table class="w-full text-left text-xs">
                                    <thead class="bg-slate-50 text-slate-500 font-bold border-b border-slate-200">
                                        <tr>
                                            <th class="py-2.5 px-3">Title &amp; Author</th>
                                            <th class="py-2.5 px-3">Units Sold</th>
                                            <th class="py-2.5 px-3">Sale Price</th>
                                            <th class="py-2.5 px-3">Total Sales</th>
                                            <th class="py-2.5 px-3 text-right">Stock</th>
                                        </tr>
                                    </thead>
                                    <tbody class="divide-y divide-slate-100 font-medium text-slate-700">
                                        <c:choose>
                                            <c:when test="${not empty topBooks}">
                                                <c:forEach var="book" items="${topBooks}">
                                                    <tr class="hover:bg-slate-50">
                                                        <td class="py-3 px-3">
                                                            <div class="font-bold text-slate-900"><c:out value="${book.bookTitle}"/></div>
                                                            <div class="text-[11px] text-slate-500"><c:out value="${book.authors}"/></div>
                                                        </td>
                                                        <td class="py-3 px-3 font-bold text-blue-600">
                                                            <fmt:formatNumber value="${book.quantitySold}" groupingUsed="true"/> units
                                                        </td>
                                                        <td class="py-3 px-3">
                                                            <fmt:formatNumber value="${book.salePrice}" type="number" groupingUsed="true" maxFractionDigits="0"/> ₫
                                                        </td>
                                                        <td class="py-3 px-3 font-bold text-emerald-600">
                                                            <fmt:formatNumber value="${book.revenue}" type="number" groupingUsed="true" maxFractionDigits="0"/> ₫
                                                        </td>
                                                        <td class="py-3 px-3 text-right font-bold ${book.stock le 0 ? 'text-rose-600' : 'text-emerald-600'}">
                                                            <fmt:formatNumber value="${book.stock}" groupingUsed="true"/>
                                                        </td>
                                                    </tr>
                                                </c:forEach>
                                            </c:when>
                                            <c:otherwise>
                                                <tr>
                                                    <td colspan="5" class="py-8 px-3 text-center text-slate-400">
                                                        No best-selling book data is available for the selected period.
                                                    </td>
                                                </tr>
                                            </c:otherwise>
                                        </c:choose>
                                    </tbody>
                                </table>
                            </div>
                        </div>

                    </div>

                    <div class="bg-white rounded-2xl border border-slate-200/80 shadow-sm overflow-hidden">
                        <div class="p-4 border-b border-slate-100 flex items-center justify-between">
                            <div><h3 class="text-sm font-extrabold text-slate-900">Recent Orders</h3><p class="text-xs text-slate-400 mt-1">Latest customer orders</p></div>
                            <button onclick="window.location.href='${pageContext.request.contextPath}/dashboard/admin?view=orders'" class="text-xs font-bold text-blue-600 hover:underline">View All &rarr;</button>
                        </div>
                        <div class="overflow-x-auto custom-scrollbar">
                            <table class="w-full text-left text-xs">
                                <thead class="bg-slate-50 text-slate-500 font-bold border-b border-slate-200"><tr><th class="py-3 px-4">Order</th><th class="py-3 px-3">Customer</th><th class="py-3 px-3">Total</th><th class="py-3 px-3">Payment</th><th class="py-3 px-4">Status</th></tr></thead>
                                <tbody class="divide-y divide-slate-100 font-medium text-slate-700">
                                    <c:choose>
                                        <c:when test="${recentOrdersLoadError}"><tr><td colspan="5" class="py-8 text-center text-rose-600">Recent orders could not be loaded.</td></tr></c:when>
                                        <c:when test="${empty recentOrders}"><tr><td colspan="5" class="py-8 text-center text-slate-400">No orders found.</td></tr></c:when>
                                        <c:otherwise><c:forEach items="${recentOrders}" var="order"><tr class="hover:bg-slate-50"><td class="py-3 px-4 font-bold text-blue-700"><c:out value="${order.orderCode}"/><small class="block mt-1 text-slate-400 font-normal"><c:out value="${order.createdAt}"/></small></td><td class="py-3 px-3"><c:out value="${order.customerName}"/></td><td class="py-3 px-3"><fmt:formatNumber value="${order.finalAmount}" pattern="#,##0.##"/> ₫</td><td class="py-3 px-3"><c:out value="${order.paymentStatus}"/></td><td class="py-3 px-4"><c:out value="${order.orderStatus}"/></td></tr></c:forEach></c:otherwise>
                                    </c:choose>
                                </tbody>
                            </table>
                        </div>
                    </div>

                </section>

                <!-- Book catalog view -->
                <section id="view-books" class="hidden space-y-5">
                    <div class="bg-white p-5 rounded-2xl border border-slate-200/80 shadow-sm flex flex-col sm:flex-row items-start sm:items-center justify-between gap-4">
                        <div>
                            <h3 class="text-base font-extrabold text-slate-900">Book Catalog</h3>
                            <p class="text-xs text-slate-400">Manage books, pricing, and inventory.</p>
                        </div>
                        <a href="${pageContext.request.contextPath}/dashboard/admin/books/create" class="bg-blue-600 hover:bg-blue-700 text-white font-bold text-xs px-4 py-2 rounded-xl transition flex items-center gap-1.5 shadow-sm text-decoration-none">
                            <span>➕</span>
                            <span>Add Book</span>
                        </a>
                    </div>

                    <c:if test="${param.message == 'created'}"><div class="bg-emerald-50 border border-emerald-200 text-emerald-700 px-4 py-3 rounded-xl text-xs font-semibold">Book added successfully.</div></c:if>
                    <c:if test="${param.message == 'updated'}"><div class="bg-emerald-50 border border-emerald-200 text-emerald-700 px-4 py-3 rounded-xl text-xs font-semibold">Book updated successfully.</div></c:if>
                    <c:if test="${param.message == 'deleted'}"><div class="bg-emerald-50 border border-emerald-200 text-emerald-700 px-4 py-3 rounded-xl text-xs font-semibold">Book removed from the catalog.</div></c:if>
                    <c:if test="${not empty errorMessage}"><div class="bg-rose-50 border border-rose-200 text-rose-700 px-4 py-3 rounded-xl text-xs font-semibold"><c:out value="${errorMessage}"/></div></c:if>
                    <c:if test="${not empty bookLoadError}"><div class="bg-rose-50 border border-rose-200 text-rose-700 px-4 py-3 rounded-xl text-xs font-semibold">Books could not be loaded. Check the database connection and try again.</div></c:if>
                    <c:if test="${not empty bookFilterError}"><div class="bg-rose-50 border border-rose-200 text-rose-700 px-4 py-3 rounded-xl text-xs font-semibold"><c:out value="${bookFilterError}"/></div></c:if>

                    <form method="get" action="${pageContext.request.contextPath}/dashboard/admin" class="bg-white p-4 rounded-2xl border border-slate-200/80 shadow-sm grid grid-cols-1 sm:grid-cols-2 xl:grid-cols-6 gap-3 items-end text-xs">
                        <input type="hidden" name="view" value="books"/>
                        <label class="grid gap-1 text-slate-500 font-bold">Search<input name="q" value="<c:out value='${bookKeyword}'/>" placeholder="Title, ISBN, publisher" class="rounded-lg border border-slate-200 px-3 py-2 font-normal"/></label>
                        <label class="grid gap-1 text-slate-500 font-bold">Category<select name="categoryId" class="rounded-lg border border-slate-200 px-3 py-2 font-normal"><option value="">All categories</option><c:forEach items="${bookCategories}" var="category"><option value="${category.id}" ${bookCategoryFilter == category.id ? 'selected' : ''}><c:out value="${category.name}"/></option></c:forEach></select></label>
                        <label class="grid gap-1 text-slate-500 font-bold">Author<select name="authorId" class="rounded-lg border border-slate-200 px-3 py-2 font-normal"><option value="">All authors</option><c:forEach items="${bookAuthors}" var="author"><option value="${author.id}" ${bookAuthorFilter == author.id ? 'selected' : ''}><c:out value="${author.name}"/></option></c:forEach></select></label>
                        <label class="grid gap-1 text-slate-500 font-bold">Min price<input type="number" min="0" step="0.01" name="minPrice" value="${bookMinPrice}" class="rounded-lg border border-slate-200 px-3 py-2 font-normal"/></label>
                        <label class="grid gap-1 text-slate-500 font-bold">Max price<input type="number" min="0" step="0.01" name="maxPrice" value="${bookMaxPrice}" class="rounded-lg border border-slate-200 px-3 py-2 font-normal"/></label>
                        <div class="flex gap-2"><button class="rounded-lg bg-blue-600 px-4 py-2 font-bold text-white">Filter</button><a class="rounded-lg bg-slate-100 px-4 py-2 font-bold text-slate-600" href="${pageContext.request.contextPath}/dashboard/admin?view=books">Reset</a></div>
                    </form>

                    <div class="bg-white rounded-2xl border border-slate-200/80 shadow-sm overflow-hidden">
                        <div class="overflow-x-auto custom-scrollbar">
                            <table class="w-full text-left text-xs">
                                <thead class="bg-slate-50 text-slate-500 font-bold border-b border-slate-200">
                                    <tr>
                                        <th class="py-3 px-3">ID</th><th class="py-3 px-3">ISBN</th><th class="py-3 px-3">Title</th><th class="py-3 px-3">Category</th><th class="py-3 px-3">Author</th><th class="py-3 px-3">Publisher</th><th class="py-3 px-3">Original Price</th><th class="py-3 px-3">Sale Price</th><th class="py-3 px-3">Stock</th><th class="py-3 px-3">Status</th><th class="py-3 px-4 text-right">Actions</th>
                                    </tr>
                                </thead>
                                <tbody class="divide-y divide-slate-100 font-medium text-slate-700">
                                    <c:choose>
                                        <c:when test="${bookLoadError}"><tr><td colspan="11" class="py-10 text-center text-slate-400">Book data is unavailable.</td></tr></c:when>
                                        <c:when test="${empty books}"><tr><td colspan="11" class="py-10 text-center text-slate-400">No books found.</td></tr></c:when>
                                        <c:otherwise>
                                            <c:forEach items="${books}" var="book">
                                                <tr class="hover:bg-slate-50 transition ${book.deleted ? 'opacity-60' : ''}">
                                                    <td class="py-3 px-3"><c:out value="${book.id}"/></td>
                                                    <td class="py-3 px-3 font-mono"><c:out value="${book.isbn}"/></td>
                                                    <td class="py-3 px-3 font-bold text-slate-900"><c:out value="${book.title}"/><c:if test="${book.deleted}"><small class="block text-rose-600">Deleted</small></c:if></td>
                                                    <td class="py-3 px-3"><c:out value="${empty book.categoryNames ? '—' : book.categoryNames}"/></td>
                                                    <td class="py-3 px-3"><c:out value="${empty book.authorNames ? '—' : book.authorNames}"/></td>
                                                    <td class="py-3 px-3"><c:out value="${book.publisherName}"/></td>
                                                    <td class="py-3 px-3"><fmt:formatNumber value="${book.price}" pattern="#,##0.##"/> ₫</td>
                                                    <td class="py-3 px-3 font-bold text-blue-600"><fmt:formatNumber value="${book.salePrice}" pattern="#,##0.##"/> ₫</td>
                                                    <td class="py-3 px-3"><fmt:formatNumber value="${book.availableStock}"/></td>
                                                    <td class="py-3 px-3"><span class="px-2 py-0.5 rounded-full bg-emerald-100 text-emerald-800 font-bold text-[10px]"><c:out value="${book.deleted ? 'DELETED' : book.status}"/></span></td>
                                                    <td class="py-3 px-4 text-right whitespace-nowrap">
                                                        <a href="${pageContext.request.contextPath}/dashboard/admin/books/edit?id=${book.id}" class="px-2.5 py-1 rounded-lg bg-blue-50 text-blue-600 hover:bg-blue-600 hover:text-white font-bold transition">Edit</a>
                                                        <c:if test="${not book.deleted}">
                                                            <form method="post" action="${pageContext.request.contextPath}/dashboard/admin/books/delete" class="inline" onsubmit="return confirm('Remove this book from the catalog?')">
                                                                <input type="hidden" name="csrfToken" value="${sessionScope.adminCsrfToken}"/><input type="hidden" name="id" value="${book.id}"/>
                                                                <button type="submit" class="px-2.5 py-1 rounded-lg bg-rose-50 text-rose-600 hover:bg-rose-600 hover:text-white font-bold transition">Delete</button>
                                                            </form>
                                                        </c:if>
                                                    </td>
                                                </tr>
                                            </c:forEach>
                                        </c:otherwise>
                                    </c:choose>
                                </tbody>
                            </table>
                        </div>
                    </div>
                </section>

                <!-- ============================================================= -->
                <!-- VIEW 3: ORDERS MANAGEMENT                                     -->
                <!-- ============================================================= -->
                <section id="view-orders" class="hidden space-y-5">
                    <div class="bg-white p-5 rounded-2xl border border-slate-200/80 shadow-sm">
                        <div>
                            <h3 class="text-base font-extrabold text-slate-900">Orders &amp; Invoices</h3>
                            <p class="text-xs text-slate-400">Review customer orders and update their fulfillment status.</p>
                        </div>
                    </div>
                    <div class="flex flex-wrap gap-2 text-xs">
                        <a class="px-3 py-2 rounded-lg ${selectedOrderStatus eq 'ALL' ? 'bg-blue-600 text-white' : 'bg-white text-slate-600 border border-slate-200'}" href="${pageContext.request.contextPath}/dashboard/admin?view=orders">All</a>
                        <a class="px-3 py-2 rounded-lg ${selectedOrderStatus eq 'PENDING_PAYMENT' ? 'bg-blue-600 text-white' : 'bg-white text-slate-600 border border-slate-200'}" href="${pageContext.request.contextPath}/dashboard/admin?view=orders&amp;status=PENDING_PAYMENT">Pending Payment</a>
                        <a class="px-3 py-2 rounded-lg ${selectedOrderStatus eq 'PENDING' ? 'bg-blue-600 text-white' : 'bg-white text-slate-600 border border-slate-200'}" href="${pageContext.request.contextPath}/dashboard/admin?view=orders&amp;status=PENDING">Pending</a>
                        <a class="px-3 py-2 rounded-lg ${selectedOrderStatus eq 'CONFIRMED' ? 'bg-blue-600 text-white' : 'bg-white text-slate-600 border border-slate-200'}" href="${pageContext.request.contextPath}/dashboard/admin?view=orders&amp;status=CONFIRMED">Confirmed</a>
                        <a class="px-3 py-2 rounded-lg ${selectedOrderStatus eq 'PROCESSING' ? 'bg-blue-600 text-white' : 'bg-white text-slate-600 border border-slate-200'}" href="${pageContext.request.contextPath}/dashboard/admin?view=orders&amp;status=PROCESSING">Processing</a>
                        <a class="px-3 py-2 rounded-lg ${selectedOrderStatus eq 'SHIPPING' ? 'bg-blue-600 text-white' : 'bg-white text-slate-600 border border-slate-200'}" href="${pageContext.request.contextPath}/dashboard/admin?view=orders&amp;status=SHIPPING">Shipped</a>
                        <a class="px-3 py-2 rounded-lg ${selectedOrderStatus eq 'DELIVERED' ? 'bg-blue-600 text-white' : 'bg-white text-slate-600 border border-slate-200'}" href="${pageContext.request.contextPath}/dashboard/admin?view=orders&amp;status=DELIVERED">Delivered</a>
                        <a class="px-3 py-2 rounded-lg ${selectedOrderStatus eq 'CANCELLED' ? 'bg-blue-600 text-white' : 'bg-white text-slate-600 border border-slate-200'}" href="${pageContext.request.contextPath}/dashboard/admin?view=orders&amp;status=CANCELLED">Cancelled</a>
                    </div>
                    <c:if test="${param.message == 'updated'}">
                        <div class="bg-emerald-50 border border-emerald-200 text-emerald-700 px-4 py-3 rounded-xl text-xs font-semibold">Order status updated successfully.</div>
                    </c:if>
                    <c:if test="${param.message == 'invalid'}">
                        <div class="bg-rose-50 border border-rose-200 text-rose-700 px-4 py-3 rounded-xl text-xs font-semibold">The status could not be updated. Refresh the page and check the current order status.</div>
                    </c:if>
                    <c:if test="${ordersLoadError}">
                        <div class="bg-rose-50 border border-rose-200 text-rose-700 px-4 py-3 rounded-xl text-xs font-semibold">Orders could not be loaded. Check the database connection and try again.</div>
                    </c:if>
                    <div class="bg-white rounded-2xl border border-slate-200/80 shadow-sm overflow-hidden">
                        <div class="p-4 border-b border-slate-100">
                            <h3 class="text-sm font-extrabold text-slate-900">All Orders</h3>
                            <p class="text-xs text-slate-400 mt-1">Order information retrieved from the database.</p>
                        </div>
                        <div class="overflow-x-auto custom-scrollbar">
                            <table class="w-full text-left text-xs">
                                <thead class="bg-slate-50 text-slate-500 font-bold border-b border-slate-200">
                                    <tr><th class="py-3 px-4">Order</th><th class="py-3 px-3">Customer</th><th class="py-3 px-3">Recipient</th><th class="py-3 px-3">Total</th><th class="py-3 px-3">Payment</th><th class="py-3 px-3">Status</th><th class="py-3 px-4">Actions</th></tr>
                                </thead>
                                <tbody class="divide-y divide-slate-100 font-medium text-slate-700">
                                    <c:choose>
                                        <c:when test="${ordersLoadError}"><tr><td colspan="7" class="py-10 text-center text-slate-400">Order data is unavailable.</td></tr></c:when>
                                        <c:when test="${empty orders}"><tr><td colspan="7" class="py-10 text-center text-slate-400">No orders found.</td></tr></c:when>
                                        <c:otherwise>
                                            <c:forEach items="${orders}" var="order">
                                                <tr class="hover:bg-slate-50 transition">
                                                    <td class="py-3 px-4 font-bold text-blue-700"><c:out value="${order.orderCode}"/><small class="block mt-1 text-slate-400 font-normal"><c:out value="${order.createdAt}"/></small></td>
                                                    <td class="py-3 px-3"><c:out value="${order.customerName}"/></td>
                                                    <td class="py-3 px-3"><c:out value="${order.recipientName}"/><small class="block mt-1 text-slate-400"><c:out value="${order.recipientPhone}"/></small></td>
                                                    <td class="py-3 px-3"><fmt:formatNumber value="${order.finalAmount}" pattern="#,##0.##"/> ₫</td>
                                                    <td class="py-3 px-3"><c:out value="${order.paymentMethod}"/><small class="block mt-1 text-slate-400"><c:out value="${order.paymentStatus}"/></small></td>
                                                    <td class="py-3 px-3"><span class="px-2 py-1 rounded-full bg-blue-50 text-blue-700 font-bold text-[10px]"><c:out value="${order.orderStatus}"/></span></td>
                                                    <td class="py-3 px-4">
                                                        <form method="post" action="${pageContext.request.contextPath}/dashboard/admin/orders" class="space-y-2">
                                                            <input type="hidden" name="csrfToken" value="${sessionScope.adminCsrfToken}"/>
                                                            <input type="hidden" name="orderId" value="${order.id}"/>
                                                            <select name="orderStatus" required class="w-full rounded-lg border border-slate-200 px-2 py-2 text-xs">
                                                                <option value="" selected disabled>Select status</option>
                                                                <c:choose>
                                                                    <c:when test="${order.orderStatus eq 'PENDING'}"><option value="CONFIRMED">CONFIRMED</option><option value="CANCELLED">CANCELLED</option></c:when>
                                                                    <c:when test="${order.orderStatus eq 'CONFIRMED'}"><option value="PROCESSING">PROCESSING</option><option value="CANCELLED">CANCELLED</option></c:when>
                                                                    <c:when test="${order.orderStatus eq 'PROCESSING'}"><option value="SHIPPING">SHIPPING</option><option value="CANCELLED">CANCELLED</option></c:when>
                                                                    <c:when test="${order.orderStatus eq 'SHIPPING'}"><option value="DELIVERED">DELIVERED</option></c:when>
                                                                </c:choose>
                                                            </select>
                                                            <input name="reason" maxlength="255" placeholder="Note (optional)" class="w-full rounded-lg border border-slate-200 px-2 py-2 text-xs"/>
                                                            <button type="submit" class="rounded-lg bg-blue-600 px-3 py-2 text-xs font-bold text-white hover:bg-blue-700">Save</button>
                                                        </form>
                                                    </td>
                                                </tr>
                                            </c:forEach>
                                        </c:otherwise>
                                    </c:choose>
                                </tbody>
                            </table>
                        </div>
                    </div>
                </section>

                <!-- ============================================================= -->
                <!-- VIEW 4: USERS & ROLES                                         -->
                <!-- ============================================================= -->
                <section id="view-users" class="hidden space-y-5">

    <!-- Header -->
    <div class="bg-white p-5 rounded-2xl border border-slate-200/80 shadow-sm flex items-center justify-between">
        <div>
            <h3 class="text-base font-extrabold text-slate-900">
                User Account Management
            </h3>
            <p class="text-xs text-slate-400">
                View user accounts and manage account status
            </p>
        </div>
    </div>

    <!-- Message -->
    <c:if test="${not empty param.message}">
        <div class="bg-emerald-50 border border-emerald-200 text-emerald-700 px-4 py-3 rounded-xl text-xs font-semibold">
            <c:out value="${param.message}"/>
        </div>
    </c:if>

    <!-- User Table -->
    <div class="bg-white rounded-2xl border border-slate-200/80 shadow-sm overflow-hidden">

        <div class="p-4 border-b border-slate-100 flex items-center justify-between">
            <div>
                <h3 class="text-sm font-extrabold text-slate-900">
                    All User Accounts
                </h3>
                <p class="text-xs text-slate-400 mt-1">
                    Account information retrieved from database
                </p>
            </div>

            <span class="text-xs font-bold text-blue-600 bg-blue-50 px-3 py-1.5 rounded-lg">
                Total: ${fn:length(users)}
            </span>
        </div>

        <div class="overflow-x-auto custom-scrollbar">
            <table class="w-full text-left text-xs">

                <thead class="bg-slate-50 text-slate-500 font-bold border-b border-slate-200">
                    <tr>
                        <th class="py-3 px-4">ID</th>
                        <th class="py-3 px-3">Full Name</th>
                        <th class="py-3 px-3">Email</th>
                        <th class="py-3 px-3">Phone</th>
                        <th class="py-3 px-3">Email Verified</th>
                        <th class="py-3 px-3">Status</th>
                        <th class="py-3 px-4">Created At</th>
                        <th class="py-3 px-4 text-right">Actions</th>
                    </tr>
                </thead>

                <tbody class="divide-y divide-slate-100 font-medium text-slate-700">

                    <c:choose>
                        <c:when test="${empty users}">
                            <tr>
                                <td colspan="8" class="py-10 text-center text-slate-400">
                                    No user accounts found.
                                </td>
                            </tr>
                        </c:when>

                        <c:otherwise>
                            <c:forEach var="user" items="${users}">

                                <tr class="hover:bg-slate-50 transition">

                                    <td class="py-3 px-4 font-bold text-slate-500">
                                        <c:out value="${user.id}"/>
                                    </td>

                                    <td class="py-3 px-3 font-bold text-slate-900">
                                        <c:out value="${user.fullName}"/>
                                    </td>

                                    <td class="py-3 px-3">
                                        <c:out value="${user.email}"/>
                                    </td>

                                    <td class="py-3 px-3">
                                        <c:out value="${user.phoneNumber}"/>
                                    </td>

                                    <td class="py-3 px-3">
                                        <c:choose>
                                            <c:when test="${user.emailVerified}">
                                                <span class="px-2 py-1 rounded-full bg-emerald-100 text-emerald-700 font-bold text-[10px]">
                                                    Verified
                                                </span>
                                            </c:when>
                                            <c:otherwise>
                                                <span class="px-2 py-1 rounded-full bg-amber-100 text-amber-700 font-bold text-[10px]">
                                                    Not Verified
                                                </span>
                                            </c:otherwise>
                                        </c:choose>
                                    </td>

                                    <td class="py-3 px-3">
                                        <c:choose>
                                            <c:when test="${user.status eq 'ACTIVE'}">
                                                <span class="px-2 py-1 rounded-full bg-emerald-100 text-emerald-700 font-bold text-[10px]">
                                                    ACTIVE
                                                </span>
                                            </c:when>
                                            <c:when test="${user.status eq 'LOCKED'}">
                                                <span class="px-2 py-1 rounded-full bg-rose-100 text-rose-700 font-bold text-[10px]">
                                                    LOCKED
                                                </span>
                                            </c:when>
                                            <c:otherwise>
                                                <span class="px-2 py-1 rounded-full bg-slate-100 text-slate-600 font-bold text-[10px]">
                                                    <c:out value="${user.status}"/>
                                                </span>
                                            </c:otherwise>
                                        </c:choose>
                                    </td>

                                    <td class="py-3 px-4 text-slate-500">
                                        <fmt:formatDate value="${user.createdAt}"
                                                        pattern="dd/MM/yyyy HH:mm"/>
                                    </td>

                                    <td class="py-3 px-4 text-right">

                                        <c:choose>
                                            <c:when test="${user.status eq 'ACTIVE'}">
                                                <form method="post"
                                                      action="${pageContext.request.contextPath}/dashboard/admin/users"
                                                      class="inline"
                                                      onsubmit="return confirm('Are you sure you want to lock this account?');">

                                                    <input type="hidden"
                                                           name="userId"
                                                           value="${user.id}"/>

                                                    <input type="hidden"
                                                           name="status"
                                                           value="LOCKED"/>

                                                    <button type="submit"
                                                            class="px-3 py-1.5 rounded-lg bg-rose-50 text-rose-600 hover:bg-rose-600 hover:text-white font-bold transition">
                                                        Lock
                                                    </button>
                                                </form>
                                            </c:when>

                                            <c:when test="${user.status eq 'LOCKED'}">
                                                <form method="post"
                                                      action="${pageContext.request.contextPath}/dashboard/admin/users"
                                                      class="inline"
                                                      onsubmit="return confirm('Are you sure you want to unlock this account?');">

                                                    <input type="hidden"
                                                           name="userId"
                                                            value="${user.id}"/>

                                                    <input type="hidden"
                                                           name="status"
                                                           value="ACTIVE"/>

                                                    <button type="submit"
                                                            class="px-3 py-1.5 rounded-lg bg-blue-50 text-blue-600 hover:bg-blue-600 hover:text-white font-bold transition">
                                                        Unlock
                                                    </button>
                                                </form>
                                            </c:when>

                                            <c:otherwise>
                                                <span class="text-slate-400 text-[10px]">
                                                    Not available
                                                </span>
                                            </c:otherwise>
                                        </c:choose>

                                    </td>
                                </tr>

                            </c:forEach>
                        </c:otherwise>
                    </c:choose>

                </tbody>
            </table>
        </div>
    </div>
</section>

                <!-- ============================================================= -->
                <!-- VIEW 5: VOUCHERS                                              -->
                <!-- ============================================================= -->
                <section id="view-vouchers" class="hidden space-y-5">
                    <div class="bg-white p-5 rounded-2xl border border-slate-200/80 shadow-sm flex items-center justify-between">
                        <div>
                            <h3 class="text-base font-extrabold text-slate-900">Voucher &amp; Coupon Campaigns</h3>
                            <p class="text-xs text-slate-400">Configure discount percentage, min order amount, and expiry dates</p>
                        </div>
                        <button onclick="showToast('Create new voucher dialog...')" class="bg-amber-600 hover:bg-amber-700 text-white font-bold text-xs px-3.5 py-2 rounded-xl transition">+ Create Voucher</button>
                    </div>
                    <div class="p-4 bg-white rounded-2xl border border-slate-200/80 space-y-2 text-xs">
                        <div class="p-3 bg-amber-50 rounded-xl border border-amber-200 flex justify-between items-center">
                            <div>
                                <span class="font-black text-amber-900 text-sm">BOOKLOVER10</span>
                                <p class="text-[11px] text-amber-700">10% OFF for orders above $20.00 • Active until Dec 31, 2026</p>
                            </div>
                            <span class="px-2.5 py-1 rounded-full bg-emerald-100 text-emerald-800 font-bold text-[10px]">ACTIVE</span>
                        </div>
                    </div>
                </section>

                <!-- ============================================================= -->
                <!-- VIEW 6: RETURNS & REFUNDS                                     -->
                <!-- ============================================================= -->
                <section id="view-returns" class="hidden space-y-5">
                    <div class="bg-white p-5 rounded-2xl border border-slate-200/80 shadow-sm">
                        <h3 class="text-base font-extrabold text-slate-900">Customer Return &amp; Refund Approvals</h3>
                        <p class="text-xs text-slate-400">Admin audit and financial disbursement for returned goods</p>
                    </div>
                    <div class="p-4 bg-white rounded-2xl border border-slate-200/80 text-xs text-slate-500">
                        Return requests are not connected to a database-backed admin workflow yet.
                    </div>
                </section>

                <!-- ============================================================= -->
                <!-- VIEW 7: ANALYTICS                                             -->
                <!-- ============================================================= -->
                <section id="view-analytics" class="hidden space-y-5">
                    <div class="bg-white p-5 rounded-2xl border border-slate-200/80 shadow-sm">
                        <h3 class="text-base font-extrabold text-slate-900">Financial &amp; Revenue Analytics</h3>
                        <p class="text-xs text-slate-400 mt-1">Revenue and order statistics from paid and delivered orders</p>
                        <div class="mt-3 flex flex-wrap gap-4 text-xs text-slate-600">
                            <div><span class="font-bold">From:</span>
                                <fmt:formatDate value="${reportStartDate}" pattern="dd/MM/yyyy"/>
                            </div>
                            <div><span class="font-bold">To:</span>
                                <fmt:formatDate value="${reportEndDate}" pattern="dd/MM/yyyy"/>
                            </div>
                        </div>
                    </div>

                    <c:if test="${not empty reportError}">
                        <div class="p-4 rounded-xl border border-rose-200 bg-rose-50 text-rose-700 text-sm">
                            <c:out value="${reportError}"/>
                        </div>
                    </c:if>

                    <div class="grid grid-cols-1 sm:grid-cols-2 gap-4">
                        <div class="bg-white p-5 rounded-2xl border border-slate-200/80 shadow-sm">
                            <p class="text-xs font-bold uppercase tracking-wider text-slate-500">Total Revenue</p>
                            <p class="mt-2 text-2xl font-black text-emerald-600">
                                <fmt:formatNumber value="${reportSummary.totalRevenue}" type="number" groupingUsed="true" maxFractionDigits="0"/> ₫
                            </p>
                        </div>
                        <div class="bg-white p-5 rounded-2xl border border-slate-200/80 shadow-sm">
                            <p class="text-xs font-bold uppercase tracking-wider text-slate-500">Total Orders</p>
                            <p class="mt-2 text-2xl font-black text-blue-600">
                                <fmt:formatNumber value="${reportSummary.totalOrders}" groupingUsed="true"/>
                            </p>
                        </div>
                    </div>

                    <div class="bg-white rounded-2xl border border-slate-200/80 shadow-sm overflow-hidden">
                        <div class="p-5 border-b border-slate-100">
                            <h4 class="text-sm font-extrabold text-slate-900">Revenue by Month</h4>
                            <p class="text-xs text-slate-400 mt-1">Monthly revenue and completed order count</p>
                        </div>
                        <div class="overflow-x-auto">
                            <table class="w-full text-left text-xs">
                                <thead class="bg-slate-50 text-slate-500 font-bold">
                                    <tr>
                                        <th class="px-5 py-3">Period</th>
                                        <th class="px-5 py-3 text-right">Orders</th>
                                        <th class="px-5 py-3 text-right">Revenue</th>
                                    </tr>
                                </thead>
                                <tbody class="divide-y divide-slate-100 text-slate-700">
                                    <c:choose>
                                        <c:when test="${not empty revenueReport}">
                                            <c:forEach var="item" items="${revenueReport}">
                                                <tr class="hover:bg-slate-50">
                                                    <td class="px-5 py-3 font-semibold">
                                                        <fmt:formatDate value="${item.reportDate}" pattern="MM/yyyy"/>
                                                    </td>
                                                    <td class="px-5 py-3 text-right">
                                                        <fmt:formatNumber value="${item.orderCount}" groupingUsed="true"/>
                                                    </td>
                                                    <td class="px-5 py-3 text-right font-bold text-emerald-600">
                                                        <fmt:formatNumber value="${item.revenue}" type="number" groupingUsed="true" maxFractionDigits="0"/> ₫
                                                    </td>
                                                </tr>
                                            </c:forEach>
                                        </c:when>
                                        <c:otherwise>
                                            <tr>
                                                <td colspan="3" class="px-5 py-10 text-center text-slate-400">
                                                    No revenue data found for this period. Revenue is counted only from orders with PAID and DELIVERED status.
                                                </td>
                                            </tr>
                                        </c:otherwise>
                                    </c:choose>
                                </tbody>
                            </table>
                        </div>
                    </div>
                </section>

            </div>
        </main>

    </div>

    <!-- FLOATING TOAST -->
    <div id="toast" class="fixed bottom-6 right-6 z-50 bg-slate-900 text-white px-4 py-3 rounded-2xl shadow-2xl border border-slate-700 text-xs font-bold transition-all transform translate-y-20 opacity-0 pointer-events-none flex items-center gap-2">
        <span>👑</span>
        <span id="toastMsg">Notification message</span>
    </div>

    <script>
        function navigateAdminTo(viewName) {
            const views = ['dashboard', 'books', 'orders', 'users', 'vouchers', 'returns', 'analytics'];
            views.forEach(v => {
                const el = document.getElementById('view-' + v);
                const navEl = document.getElementById('nav-' + v);
                if (el) el.classList.add('hidden');
                if (navEl) {
                    navEl.classList.remove('nav-item-active');
                    navEl.classList.add('text-slate-600');
                }
            });

            const activeView = document.getElementById('view-' + viewName);
            const activeNav = document.getElementById('nav-' + viewName);
            if (activeView) activeView.classList.remove('hidden');
            if (activeNav) {
                activeNav.classList.add('nav-item-active');
                activeNav.classList.remove('text-slate-600');
            }

            const map = {
                'dashboard': 'Executive Dashboard',
                'books': 'Book Catalog',
                'orders': 'Orders & Transactions',
                'users': 'User Accounts & Roles (RBAC)',
                'vouchers': 'Vouchers & Campaigns',
                'returns': 'Return & Refund Audit',
                'analytics': 'Financial Analytics'
            };
            document.getElementById('adminBreadcrumb').textContent = map[viewName] || 'Overview';
            document.getElementById('adminPageHeader').textContent = map[viewName] || 'Overview';
        }

        let toastTimer = null;
        function showToast(msg) {
            const toast = document.getElementById('toast');
            const toastMsg = document.getElementById('toastMsg');
            toastMsg.textContent = msg;
            toast.classList.remove('translate-y-20', 'opacity-0', 'pointer-events-none');
            if (toastTimer) clearTimeout(toastTimer);
            toastTimer = setTimeout(() => {
                toast.classList.add('translate-y-20', 'opacity-0', 'pointer-events-none');
            }, 3500);
        }
        document.addEventListener('DOMContentLoaded', function () {
    const params = new URLSearchParams(window.location.search);
    const requestedView = params.get('view');

    if (requestedView) {
        navigateAdminTo(requestedView);
    }
});
    </script>

</body>
</html>
