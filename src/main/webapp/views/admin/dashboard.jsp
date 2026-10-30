<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
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

    <!-- ================================================================= -->
    <!-- 1. TOP HEADER BAR                                                 -->
    <!-- ================================================================= -->
    <header class="bg-slate-900 border-b border-slate-800 text-white px-5 py-2.5 flex items-center justify-between z-30 flex-shrink-0">
        <div class="flex items-center gap-3">
            <div class="flex items-center gap-2">
                <div class="w-8 h-8 rounded-xl bg-blue-600 flex items-center justify-center font-black text-sm text-white shadow-sm">
                    👑
                </div>
                <div>
                    <span class="font-extrabold text-sm tracking-tight text-white">BookStore <span class="text-blue-400 font-bold">Admin Console</span></span>
                    <span class="block text-[9px] font-semibold text-slate-400 tracking-wider uppercase leading-none">Super Administrator Privilege</span>
                </div>
            </div>
            <span class="hidden md:inline-block text-[11px] px-2 py-0.5 rounded-full bg-purple-950/80 text-purple-300 border border-purple-800/80 font-bold">
                ROOT ACCESS
            </span>
        </div>

        <!-- Right Quick Actions & Storefront Link -->
        <div class="flex items-center gap-3">
            <!-- Link to Staff View -->
            <a href="${pageContext.request.contextPath}/dashboard/staff" class="flex items-center gap-1.5 text-xs text-slate-300 hover:text-white font-bold px-3 py-1.5 rounded-xl bg-slate-800 hover:bg-slate-700 border border-slate-700 transition">
                <span>💼</span>
                <span>Open Staff Portal</span>
            </a>

            <!-- Link to Public Storefront -->
            <a href="${pageContext.request.contextPath}/home" class="hidden sm:flex items-center gap-1 text-xs text-slate-400 hover:text-blue-400 font-semibold px-2.5 py-1.5 rounded-xl hover:bg-slate-800 transition">
                <span>Storefront ↗</span>
            </a>
        </div>
    </header>

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
                
                <div class="px-3 pb-1 text-[10px] font-extrabold uppercase tracking-wider text-slate-400">
                    Executive
                </div>

                <!-- 1. Dashboard -->
                <button onclick="navigateAdminTo('dashboard')" id="nav-dashboard" class="w-full nav-item-active flex items-center gap-3 px-3.5 py-2.5 rounded-xl font-semibold transition text-slate-600 hover:bg-slate-100">
                    <svg class="w-4 h-4 text-slate-500" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M3 12l2-2m0 0l7-7 7 7M5 10v10a1 1 0 001 1h3m10-11l2 2m-2-2v10a1 1 0 01-1 1h-3m-6 0a1 1 0 001-1v-4a1 1 0 011-1h2a1 1 0 011 1v4a1 1 0 001 1m-6 0h6"/></svg>
                    <span>Executive Dashboard</span>
                </button>

                <div class="px-3 pt-3 pb-1 text-[10px] font-extrabold uppercase tracking-wider text-slate-400">
                    Catalog &amp; Inventory
                </div>

                <!-- 2. Book Catalog Management (UC-08, UC-09, UC-10) -->
                <button onclick="navigateAdminTo('books')" id="nav-books" class="w-full flex items-center justify-between px-3.5 py-2.5 rounded-xl font-semibold text-slate-600 hover:bg-slate-100 transition">
                    <div class="flex items-center gap-3">
                        <svg class="w-4 h-4 text-slate-500" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 6.253v13m0-13C10.832 5.477 9.246 5 7.5 5S4.168 5.477 3 6.253v13C4.168 18.477 5.754 18 7.5 18s3.332.477 4.5 1.253m0-13C13.168 5.477 14.754 5 16.5 5c1.747 0 3.332.477 4.5 1.253v13C19.832 18.477 18.247 18 16.5 18c-1.746 0-3.332.477-4.5 1.253"/></svg>
                        <span>Book Catalog (CRUD)</span>
                    </div>
                    <span class="text-slate-400 text-[10px] font-bold">1,248</span>
                </button>

                <!-- 3. Category & Author Management -->
                <button onclick="showToast('Category &amp; Publisher master taxonomy manager.')" class="w-full flex items-center gap-3 px-3.5 py-2.5 rounded-xl font-semibold text-slate-600 hover:bg-slate-100 transition">
                    <svg class="w-4 h-4 text-slate-500" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M7 7h.01M7 3h5c.512 0 1.024.195 1.414.586l7 7a2 2 0 010 2.828l-7 7a2 2 0 01-2.828 0l-7-7A1.994 1.994 0 013 12V7a4 4 0 014-4z"/></svg>
                    <span>Categories &amp; Authors</span>
                </button>

                <div class="px-3 pt-3 pb-1 text-[10px] font-extrabold uppercase tracking-wider text-slate-400">
                    Sales &amp; Commerce
                </div>

                <!-- 4. Orders Management (TSK-26, TSK-27) -->
                <button onclick="navigateAdminTo('orders')" id="nav-orders" class="w-full flex items-center justify-between px-3.5 py-2.5 rounded-xl font-semibold text-slate-600 hover:bg-slate-100 transition">
                    <div class="flex items-center gap-3">
                        <svg class="w-4 h-4 text-slate-500" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M16 11V7a4 4 0 00-8 0v4M5 9h14l1 12H4L5 9z"/></svg>
                        <span>Orders &amp; Invoices</span>
                    </div>
                    <span class="bg-blue-100 text-blue-700 font-bold text-[10px] px-2 py-0.5 rounded-full">1,842</span>
                </button>

                <!-- 5. Return & Refund Approvals (TSK-33) -->
                <button onclick="navigateAdminTo('returns')" id="nav-returns" class="w-full flex items-center justify-between px-3.5 py-2.5 rounded-xl font-semibold text-slate-600 hover:bg-slate-100 transition">
                    <div class="flex items-center gap-3">
                        <svg class="w-4 h-4 text-slate-500" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M4 4v5h.582m15.356 2A8.001 8.001 0 004.582 9m0 0H9m11 11v-5h-.581m0 0a8.003 8.003 0 01-15.357-2m15.357 2H15"/></svg>
                        <span>Return &amp; Refund Audit</span>
                    </div>
                    <span class="bg-rose-100 text-rose-700 font-bold text-[10px] px-2 py-0.5 rounded-full">3</span>
                </button>

                <div class="px-3 pt-3 pb-1 text-[10px] font-extrabold uppercase tracking-wider text-purple-600">
                    Administration &amp; Security
                </div>

                <!-- 6. User Accounts & RBAC (UC-13, UC-14, TSK-28) -->
                <button onclick="navigateAdminTo('users')" id="nav-users" class="w-full flex items-center justify-between px-3.5 py-2.5 rounded-xl font-semibold text-slate-600 hover:bg-slate-100 transition">
                    <div class="flex items-center gap-3">
                        <svg class="w-4 h-4 text-purple-600" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 4.354a4 4 0 110 5.292M15 21H3v-1a6 6 0 0112 0v1zm0 0h6v-1a6 6 0 00-9-5.197M13 7a4 4 0 11-8 0 4 4 0 018 0z"/></svg>
                        <span>User Accounts &amp; RBAC</span>
                    </div>
                    <span class="text-slate-400 text-[10px] font-bold">3.8k</span>
                </button>

                <!-- 7. Vouchers & Promotions (TSK-29) -->
                <button onclick="navigateAdminTo('vouchers')" id="nav-vouchers" class="w-full flex items-center justify-between px-3.5 py-2.5 rounded-xl font-semibold text-slate-600 hover:bg-slate-100 transition">
                    <div class="flex items-center gap-3">
                        <svg class="w-4 h-4 text-amber-600" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M15 5v2m0 4v2m0 4v2M5 5a2 2 0 00-2 2v3a2 2 0 110 4v3a2 2 0 002 2h14a2 2 0 002-2v-3a2 2 0 110-4V7a2 2 0 00-2-2H5z"/></svg>
                        <span>Vouchers &amp; Campaigns</span>
                    </div>
                    <span class="bg-amber-100 text-amber-800 font-bold text-[10px] px-2 py-0.5 rounded-full">5 Active</span>
                </button>

                <!-- 8. Financial Analytics (TSK-31) -->
                <button onclick="navigateAdminTo('analytics')" id="nav-analytics" class="w-full flex items-center gap-3 px-3.5 py-2.5 rounded-xl font-semibold text-slate-600 hover:bg-slate-100 transition">
                    <svg class="w-4 h-4 text-emerald-600" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 19v-6a2 2 0 00-2-2H5a2 2 0 00-2 2v6a2 2 0 002 2h2a2 2 0 002-2zm0 0V9a2 2 0 012-2h2a2 2 0 012 2v10m-6 0a2 2 0 002 2h2a2 2 0 002-2m0 0V5a2 2 0 012-2h2a2 2 0 012 2v14a2 2 0 01-2 2h-2a2 2 0 01-2-2z"/></svg>
                    <span>Revenue &amp; Analytics</span>
                </button>

            </nav>

            <!-- Sidebar Footer -->
            <div class="p-4 border-t border-slate-100 flex items-center justify-between">
                <span class="text-[11px] font-semibold text-slate-400">Database: Active</span>
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

                <div class="flex items-center gap-3">
                    <!-- Add Book Button (Primary Action) -->
                    <button onclick="openAddBookModal()" class="bg-blue-600 hover:bg-blue-700 text-white font-bold text-xs px-4 py-2 rounded-xl shadow-sm shadow-blue-500/20 transition flex items-center gap-1.5">
                        <svg class="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2.5" d="M12 4v16m8-8H4"/></svg>
                        <span>+ Add New Book</span>
                    </button>
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
                            <span class="text-[10px] bg-blue-500 text-white font-extrabold px-2 py-0.5 rounded uppercase tracking-wider">Administrator Master Panel</span>
                            <h3 class="text-base font-extrabold">Welcome back, Administrator!</h3>
                            <p class="text-xs text-blue-200">System running smoothly across 32 relational tables. All operational metrics updated.</p>
                        </div>
                        <div class="flex items-center gap-2">
                            <button onclick="showToast('Generating Q4 Audit &amp; Financial Summary (PDF)...')" class="px-3.5 py-2 rounded-xl bg-white/10 hover:bg-white/20 text-white font-bold text-xs transition border border-white/20">
                                📄 Export Full Audit Report
                            </button>
                        </div>
                    </div>

                    <!-- 4 Executive KPIs -->
                    <div class="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-4 gap-4">
                        <div class="bg-white p-5 rounded-2xl border border-slate-200/80 shadow-sm hover-card">
                            <div class="flex items-center justify-between">
                                <span class="text-xs font-bold text-slate-500 uppercase tracking-wider">Gross Revenue</span>
                                <span class="w-9 h-9 rounded-xl bg-emerald-50 text-emerald-600 flex items-center justify-center text-base font-bold">💰</span>
                            </div>
                            <div class="mt-3 flex items-baseline justify-between">
                                <h3 class="text-2xl font-black text-slate-900">$128,450.00</h3>
                                <span class="text-[11px] font-bold text-emerald-600 bg-emerald-50 px-2 py-0.5 rounded-full">↑ 14.8%</span>
                            </div>
                            <p class="text-[11px] text-slate-400 mt-1">vs last month ($111,890.00)</p>
                        </div>

                        <div class="bg-white p-5 rounded-2xl border border-slate-200/80 shadow-sm hover-card">
                            <div class="flex items-center justify-between">
                                <span class="text-xs font-bold text-slate-500 uppercase tracking-wider">Total Orders</span>
                                <span class="w-9 h-9 rounded-xl bg-blue-50 text-blue-600 flex items-center justify-center text-base font-bold">📦</span>
                            </div>
                            <div class="mt-3 flex items-baseline justify-between">
                                <h3 class="text-2xl font-black text-slate-900">1,842</h3>
                                <span class="text-[11px] font-bold text-blue-600 bg-blue-50 px-2 py-0.5 rounded-full">24 new today</span>
                            </div>
                            <p class="text-[11px] text-slate-400 mt-1">98.2% fulfillment rate</p>
                        </div>

                        <div class="bg-white p-5 rounded-2xl border border-slate-200/80 shadow-sm hover-card">
                            <div class="flex items-center justify-between">
                                <span class="text-xs font-bold text-slate-500 uppercase tracking-wider">Books in Catalog</span>
                                <span class="w-9 h-9 rounded-xl bg-amber-50 text-amber-600 flex items-center justify-center text-base font-bold">📚</span>
                            </div>
                            <div class="mt-3 flex items-baseline justify-between">
                                <h3 class="text-2xl font-black text-slate-900">1,248</h3>
                                <span class="text-[11px] font-bold text-amber-700 bg-amber-50 px-2 py-0.5 rounded-full">12 Low Stock</span>
                            </div>
                            <p class="text-[11px] text-slate-400 mt-1">Total 12,480 units stored</p>
                        </div>

                        <div class="bg-white p-5 rounded-2xl border border-slate-200/80 shadow-sm hover-card">
                            <div class="flex items-center justify-between">
                                <span class="text-xs font-bold text-slate-500 uppercase tracking-wider">Active Customers</span>
                                <span class="w-9 h-9 rounded-xl bg-purple-50 text-purple-600 flex items-center justify-center text-base font-bold">👥</span>
                            </div>
                            <div class="mt-3 flex items-baseline justify-between">
                                <h3 class="text-2xl font-black text-slate-900">3,892</h3>
                                <span class="text-[11px] font-bold text-purple-600 bg-purple-50 px-2 py-0.5 rounded-full">+185 this week</span>
                            </div>
                            <p class="text-[11px] text-slate-400 mt-1">Verified email accounts</p>
                        </div>
                    </div>

                    <!-- Quick Access Cards -->
                    <div class="grid grid-cols-1 lg:grid-cols-12 gap-6">
                        <!-- Left 8 Cols: Top Selling Books -->
                        <div class="lg:col-span-8 bg-white p-5 rounded-2xl border border-slate-200/80 shadow-sm space-y-4">
                            <div class="flex items-center justify-between">
                                <div>
                                    <h3 class="text-sm font-extrabold text-slate-900">🔥 Top Performing Books (TSK-31)</h3>
                                    <p class="text-xs text-slate-400">Ranked by total revenue and unit sales</p>
                                </div>
                                <button onclick="navigateAdminTo('books')" class="text-xs font-bold text-blue-600 hover:underline">View Catalog &rarr;</button>
                            </div>

                            <div class="overflow-x-auto custom-scrollbar">
                                <table class="w-full text-left text-xs">
                                    <thead class="bg-slate-50 text-slate-500 font-bold border-b border-slate-200">
                                        <tr>
                                            <th class="py-2.5 px-3">Title &amp; Author</th>
                                            <th class="py-2.5 px-3">Units Sold</th>
                                            <th class="py-2.5 px-3">Unit Price</th>
                                            <th class="py-2.5 px-3">Total Sales</th>
                                            <th class="py-2.5 px-3 text-right">Stock</th>
                                        </tr>
                                    </thead>
                                    <tbody class="divide-y divide-slate-100 font-medium text-slate-700">
                                        <tr>
                                            <td class="py-3 px-3 font-bold text-slate-900">Atomic Habits (James Clear)</td>
                                            <td class="py-3 px-3 font-bold text-blue-600">842 units</td>
                                            <td class="py-3 px-3">$12.99</td>
                                            <td class="py-3 px-3 font-bold text-emerald-600">$10,937.58</td>
                                            <td class="py-3 px-3 text-right text-rose-600 font-bold">3 left</td>
                                        </tr>
                                        <tr>
                                            <td class="py-3 px-3 font-bold text-slate-900">Clean Code (Robert C. Martin)</td>
                                            <td class="py-3 px-3 font-bold text-blue-600">315 units</td>
                                            <td class="py-3 px-3">$39.99</td>
                                            <td class="py-3 px-3 font-bold text-emerald-600">$12,596.85</td>
                                            <td class="py-3 px-3 text-right text-rose-600 font-bold">5 left</td>
                                        </tr>
                                        <tr>
                                            <td class="py-3 px-3 font-bold text-slate-900">Dune (Frank Herbert)</td>
                                            <td class="py-3 px-3 font-bold text-blue-600">520 units</td>
                                            <td class="py-3 px-3">$14.99</td>
                                            <td class="py-3 px-3 font-bold text-emerald-600">$7,794.80</td>
                                            <td class="py-3 px-3 text-right text-emerald-600 font-bold">142 left</td>
                                        </tr>
                                    </tbody>
                                </table>
                            </div>
                        </div>

                        <!-- Right 4 Cols: Quick Actions & Management Links -->
                        <div class="lg:col-span-4 bg-white p-5 rounded-2xl border border-slate-200/80 shadow-sm space-y-3">
                            <h3 class="text-sm font-extrabold text-slate-900">Administrative Tools</h3>
                            <div class="space-y-2 text-xs">
                                <button onclick="navigateAdminTo('users')" class="w-full text-left p-3 rounded-xl bg-slate-50 hover:bg-slate-100 transition flex items-center justify-between border border-slate-100">
                                    <div class="flex items-center gap-2.5">
                                        <span class="text-lg">👥</span>
                                        <div>
                                            <div class="font-bold text-slate-800">User &amp; Staff Accounts</div>
                                            <div class="text-[10px] text-slate-400">Lock, unlock or grant roles</div>
                                        </div>
                                    </div>
                                    <span>&rarr;</span>
                                </button>
                                <button onclick="navigateAdminTo('vouchers')" class="w-full text-left p-3 rounded-xl bg-slate-50 hover:bg-slate-100 transition flex items-center justify-between border border-slate-100">
                                    <div class="flex items-center gap-2.5">
                                        <span class="text-lg">🏷️</span>
                                        <div>
                                            <div class="font-bold text-slate-800">Create Voucher Campaign</div>
                                            <div class="text-[10px] text-slate-400">Coupons &amp; cart discounts</div>
                                        </div>
                                    </div>
                                    <span>&rarr;</span>
                                </button>
                                <button onclick="navigateAdminTo('returns')" class="w-full text-left p-3 rounded-xl bg-slate-50 hover:bg-slate-100 transition flex items-center justify-between border border-slate-100">
                                    <div class="flex items-center gap-2.5">
                                        <span class="text-lg">↩️</span>
                                        <div>
                                            <div class="font-bold text-slate-800">Return &amp; Refund Auditing</div>
                                            <div class="text-[10px] text-slate-400">3 pending customer requests</div>
                                        </div>
                                    </div>
                                    <span>&rarr;</span>
                                </button>
                            </div>
                        </div>
                    </div>

                </section>

                <!-- ============================================================= -->
                <!-- VIEW 2: BOOK CATALOG (CRUD)                                   -->
                <!-- ============================================================= -->
                <section id="view-books" class="hidden space-y-5">
                    <div class="bg-white p-5 rounded-2xl border border-slate-200/80 shadow-sm flex flex-col sm:flex-row items-start sm:items-center justify-between gap-4">
                        <div>
                            <h3 class="text-base font-extrabold text-slate-900">Book Catalog Management (UC-08, UC-09, UC-10)</h3>
                            <p class="text-xs text-slate-400">Admin CRUD operations on inventory books and pricing</p>
                        </div>
                        <button onclick="openAddBookModal()" class="bg-blue-600 hover:bg-blue-700 text-white font-bold text-xs px-4 py-2 rounded-xl transition flex items-center gap-1.5 shadow-sm">
                            <span>➕</span>
                            <span>Create New Book (UC-08)</span>
                        </button>
                    </div>

                    <!-- Table -->
                    <div class="bg-white rounded-2xl border border-slate-200/80 shadow-sm overflow-hidden">
                        <div class="overflow-x-auto custom-scrollbar">
                            <table class="w-full text-left text-xs">
                                <thead class="bg-slate-50 text-slate-500 font-bold border-b border-slate-200">
                                    <tr>
                                        <th class="py-3 px-4">Book</th>
                                        <th class="py-3 px-3">ISBN</th>
                                        <th class="py-3 px-3">Category</th>
                                        <th class="py-3 px-3">Retail Price</th>
                                        <th class="py-3 px-3">Inventory Stock</th>
                                        <th class="py-3 px-3">Status</th>
                                        <th class="py-3 px-4 text-right">Actions</th>
                                    </tr>
                                </thead>
                                <tbody class="divide-y divide-slate-100 font-medium text-slate-700">
                                    <tr class="hover:bg-slate-50 transition">
                                        <td class="py-3 px-4 font-bold text-slate-900">Atomic Habits</td>
                                        <td class="py-3 px-3 font-mono">978-0735211292</td>
                                        <td class="py-3 px-3">Self-Help</td>
                                        <td class="py-3 px-3 font-bold text-blue-600">$12.99</td>
                                        <td class="py-3 px-3 text-rose-600 font-black">3 left</td>
                                        <td class="py-3 px-3"><span class="px-2 py-0.5 rounded-full bg-emerald-100 text-emerald-800 font-bold text-[10px]">ACTIVE</span></td>
                                        <td class="py-3 px-4 text-right space-x-1.5">
                                            <button onclick="showToast('Edit Book Modal (UC-09)...')" class="px-2.5 py-1 rounded-lg bg-blue-50 text-blue-600 hover:bg-blue-600 hover:text-white font-bold transition">Edit</button>
                                            <button onclick="showToast('Soft-deleting Book is_deleted = 1 (UC-10)...')" class="px-2.5 py-1 rounded-lg bg-rose-50 text-rose-600 hover:bg-rose-600 hover:text-white font-bold transition">Delete</button>
                                        </td>
                                    </tr>
                                    <tr class="hover:bg-slate-50 transition">
                                        <td class="py-3 px-4 font-bold text-slate-900">Clean Code</td>
                                        <td class="py-3 px-3 font-mono">978-0132350884</td>
                                        <td class="py-3 px-3">Technology</td>
                                        <td class="py-3 px-3 font-bold text-blue-600">$39.99</td>
                                        <td class="py-3 px-3 text-rose-600 font-black">5 left</td>
                                        <td class="py-3 px-3"><span class="px-2 py-0.5 rounded-full bg-emerald-100 text-emerald-800 font-bold text-[10px]">ACTIVE</span></td>
                                        <td class="py-3 px-4 text-right space-x-1.5">
                                            <button onclick="showToast('Edit Book Modal (UC-09)...')" class="px-2.5 py-1 rounded-lg bg-blue-50 text-blue-600 hover:bg-blue-600 hover:text-white font-bold transition">Edit</button>
                                            <button onclick="showToast('Soft-deleting Book is_deleted = 1 (UC-10)...')" class="px-2.5 py-1 rounded-lg bg-rose-50 text-rose-600 hover:bg-rose-600 hover:text-white font-bold transition">Delete</button>
                                        </td>
                                    </tr>
                                </tbody>
                            </table>
                        </div>
                    </div>
                </section>

                <!-- ============================================================= -->
                <!-- VIEW 3: ORDERS MANAGEMENT                                     -->
                <!-- ============================================================= -->
                <section id="view-orders" class="hidden space-y-5">
                    <div class="bg-white p-5 rounded-2xl border border-slate-200/80 shadow-sm flex items-center justify-between">
                        <div>
                            <h3 class="text-base font-extrabold text-slate-900">Orders Management (TSK-26, TSK-27)</h3>
                            <p class="text-xs text-slate-400">Audit all transactions, update order statuses, and inspect payment gateways</p>
                        </div>
                    </div>
                    <div class="bg-white rounded-2xl border border-slate-200/80 shadow-sm p-4">
                        <p class="text-xs text-slate-600">Admin can review and force update statuses: <code>PENDING</code> ➔ <code>PROCESSING</code> ➔ <code>SHIPPED</code> ➔ <code>DELIVERED</code> or <code>CANCELLED</code>.</p>
                    </div>
                </section>

                <!-- ============================================================= -->
                <!-- VIEW 4: USERS & ROLES                                         -->
                <!-- ============================================================= -->
                <section id="view-users" class="hidden space-y-5">
                    <div class="bg-white p-5 rounded-2xl border border-slate-200/80 shadow-sm flex items-center justify-between">
                        <div>
                            <h3 class="text-base font-extrabold text-slate-900">User Account &amp; Role Governance (UC-13, UC-14)</h3>
                            <p class="text-xs text-slate-400">Admin has exclusive root authority to lock accounts and assign roles</p>
                        </div>
                        <button onclick="showToast('Add staff user modal...')" class="bg-purple-600 hover:bg-purple-700 text-white font-bold text-xs px-3.5 py-2 rounded-xl transition">+ Add Staff</button>
                    </div>

                    <div class="bg-white rounded-2xl border border-slate-200/80 shadow-sm overflow-hidden">
                        <table class="w-full text-left text-xs">
                            <thead class="bg-slate-50 text-slate-500 font-bold border-b border-slate-200">
                                <tr>
                                    <th class="py-3 px-4">User</th>
                                    <th class="py-3 px-3">Role</th>
                                    <th class="py-3 px-3">Status</th>
                                    <th class="py-3 px-4 text-right">Action</th>
                                </tr>
                            </thead>
                            <tbody class="divide-y divide-slate-100 font-medium text-slate-700">
                                <tr>
                                    <td class="py-3 px-4 font-bold">admin@bookstore.com</td>
                                    <td class="py-3 px-3"><span class="px-2 py-0.5 rounded-full bg-purple-100 text-purple-800 font-extrabold text-[10px]">ADMIN</span></td>
                                    <td class="py-3 px-3"><span class="px-2 py-0.5 rounded-full bg-emerald-100 text-emerald-800 font-bold text-[10px]">ACTIVE</span></td>
                                    <td class="py-3 px-4 text-right text-slate-400 font-bold">System Root</td>
                                </tr>
                                <tr>
                                    <td class="py-3 px-4 font-bold">staff.sales@bookstore.com</td>
                                    <td class="py-3 px-3"><span class="px-2 py-0.5 rounded-full bg-blue-100 text-blue-800 font-extrabold text-[10px]">STAFF</span></td>
                                    <td class="py-3 px-3"><span class="px-2 py-0.5 rounded-full bg-emerald-100 text-emerald-800 font-bold text-[10px]">ACTIVE</span></td>
                                    <td class="py-3 px-4 text-right">
                                        <button onclick="showToast('Account locked (UC-14).')" class="px-2.5 py-1 rounded-lg bg-rose-50 text-rose-600 font-bold">Lock</button>
                                    </td>
                                </tr>
                                <tr>
                                    <td class="py-3 px-4 font-bold">buyer.test@gmail.com</td>
                                    <td class="py-3 px-3"><span class="px-2 py-0.5 rounded-full bg-slate-100 text-slate-800 font-extrabold text-[10px]">BUYER</span></td>
                                    <td class="py-3 px-3"><span class="px-2 py-0.5 rounded-full bg-emerald-100 text-emerald-800 font-bold text-[10px]">ACTIVE</span></td>
                                    <td class="py-3 px-4 text-right">
                                        <button onclick="showToast('Account locked (UC-14).')" class="px-2.5 py-1 rounded-lg bg-rose-50 text-rose-600 font-bold">Lock</button>
                                    </td>
                                </tr>
                            </tbody>
                        </table>
                    </div>
                </section>

                <!-- ============================================================= -->
                <!-- VIEW 5: VOUCHERS                                              -->
                <!-- ============================================================= -->
                <section id="view-vouchers" class="hidden space-y-5">
                    <div class="bg-white p-5 rounded-2xl border border-slate-200/80 shadow-sm flex items-center justify-between">
                        <div>
                            <h3 class="text-base font-extrabold text-slate-900">Voucher &amp; Coupon Campaigns (TSK-29)</h3>
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
                        <h3 class="text-base font-extrabold text-slate-900">Customer Return &amp; Refund Approvals (TSK-33)</h3>
                        <p class="text-xs text-slate-400">Admin audit and financial disbursement for returned goods</p>
                    </div>
                    <div class="p-4 bg-white rounded-2xl border border-slate-200/80 flex items-center justify-between text-xs">
                        <div>
                            <span class="font-bold text-slate-900">Ticket #RET-104</span>
                            <p class="text-slate-500">Order #ORD-2026-9812 • Reason: Damaged cover • Amount: <strong>$14.99</strong></p>
                        </div>
                        <button onclick="showToast('Return #RET-104 Approved &amp; Refund disbursed.')" class="px-3 py-1.5 rounded-xl bg-emerald-600 text-white font-bold">Approve Refund</button>
                    </div>
                </section>

                <!-- ============================================================= -->
                <!-- VIEW 7: ANALYTICS                                             -->
                <!-- ============================================================= -->
                <section id="view-analytics" class="hidden space-y-5">
                    <div class="bg-white p-5 rounded-2xl border border-slate-200/80 shadow-sm">
                        <h3 class="text-base font-extrabold text-slate-900">Financial &amp; Revenue Analytics (TSK-31)</h3>
                        <p class="text-xs text-slate-400">Monthly gross profits, publisher royalties, and tax computations</p>
                    </div>
                    <div class="p-6 bg-white rounded-2xl border border-slate-200/80 text-center text-slate-500 text-xs">
                        📊 Interactive charts rendered from transaction ledger data.
                    </div>
                </section>

            </div>
        </main>

    </div>

    <!-- ADD BOOK MODAL (UC-08) -->
    <div id="modalAddBook" class="fixed inset-0 bg-slate-900/60 backdrop-blur-sm z-50 hidden flex items-center justify-center p-4">
        <div class="bg-white rounded-3xl shadow-2xl max-w-xl w-full p-6 space-y-4">
            <div class="flex items-center justify-between border-b border-slate-100 pb-3">
                <h3 class="text-base font-extrabold text-slate-900">Add New Book to Inventory (UC-08)</h3>
                <button onclick="closeAddBookModal()" class="w-8 h-8 rounded-full bg-slate-100 hover:bg-slate-200 text-slate-600 font-bold">&times;</button>
            </div>
            <form onsubmit="handleCreateBook(event)" class="space-y-4 text-xs">
                <div>
                    <label class="block font-bold text-slate-700 mb-1">Book Title *</label>
                    <input type="text" required placeholder="Book Title..." class="w-full bg-slate-50 border border-slate-200 rounded-xl px-3.5 py-2.5 text-slate-800 focus:outline-none focus:border-blue-500">
                </div>
                <div class="grid grid-cols-2 gap-3">
                    <div>
                        <label class="block font-bold text-slate-700 mb-1">Author *</label>
                        <input type="text" required placeholder="Author Name..." class="w-full bg-slate-50 border border-slate-200 rounded-xl px-3.5 py-2.5 text-slate-800 focus:outline-none focus:border-blue-500">
                    </div>
                    <div>
                        <label class="block font-bold text-slate-700 mb-1">Category *</label>
                        <select class="w-full bg-slate-50 border border-slate-200 rounded-xl px-3.5 py-2.5 text-slate-800 focus:outline-none">
                            <option>Technology</option>
                            <option>Economics</option>
                            <option>Literature</option>
                            <option>Science</option>
                        </select>
                    </div>
                </div>
                <div class="grid grid-cols-3 gap-3">
                    <div>
                        <label class="block font-bold text-slate-700 mb-1">ISBN-13 *</label>
                        <input type="text" required placeholder="978-XXXXXXXXXX" class="w-full bg-slate-50 border border-slate-200 rounded-xl px-3 py-2 text-slate-800 focus:outline-none">
                    </div>
                    <div>
                        <label class="block font-bold text-slate-700 mb-1">Price ($) *</label>
                        <input type="number" step="0.01" required placeholder="19.99" class="w-full bg-slate-50 border border-slate-200 rounded-xl px-3 py-2 text-slate-800 focus:outline-none">
                    </div>
                    <div>
                        <label class="block font-bold text-slate-700 mb-1">Stock Quantity *</label>
                        <input type="number" required placeholder="100" class="w-full bg-slate-50 border border-slate-200 rounded-xl px-3 py-2 text-slate-800 focus:outline-none">
                    </div>
                </div>
                <div class="flex items-center justify-end gap-2 pt-3 border-t border-slate-100">
                    <button type="button" onclick="closeAddBookModal()" class="px-4 py-2 rounded-xl text-slate-600 hover:bg-slate-100 font-bold transition">Cancel</button>
                    <button type="submit" class="px-5 py-2 rounded-xl bg-blue-600 hover:bg-blue-700 text-white font-bold transition">Save Book</button>
                </div>
            </form>
        </div>
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
                'books': 'Book Catalog (CRUD)',
                'orders': 'Orders & Transactions',
                'users': 'User Accounts & Roles (RBAC)',
                'vouchers': 'Vouchers & Campaigns',
                'returns': 'Return & Refund Audit',
                'analytics': 'Financial Analytics'
            };
            document.getElementById('adminBreadcrumb').textContent = map[viewName] || 'Overview';
            document.getElementById('adminPageHeader').textContent = map[viewName] || 'Overview';
        }

        function openAddBookModal() { document.getElementById('modalAddBook').classList.remove('hidden'); }
        function closeAddBookModal() { document.getElementById('modalAddBook').classList.add('hidden'); }
        function handleCreateBook(e) {
            e.preventDefault();
            closeAddBookModal();
            showToast('Book successfully added to catalog (UC-08).');
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
    </script>

</body>
</html>
