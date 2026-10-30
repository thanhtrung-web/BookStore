<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>BookStore - Staff Operations Workspace</title>
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
            background-color: #059669;
            color: #ffffff !important;
            font-weight: 700;
            box-shadow: 0 4px 12px rgba(5, 150, 105, 0.25);
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
                <div class="w-8 h-8 rounded-xl bg-emerald-600 flex items-center justify-center font-black text-sm text-white shadow-sm">
                    💼
                </div>
                <div>
                    <span class="font-extrabold text-sm tracking-tight text-white">BookStore <span class="text-emerald-400 font-bold">Staff Workspace</span></span>
                    <span class="block text-[9px] font-semibold text-slate-400 tracking-wider uppercase leading-none">Fulfillment &amp; Operations Desk</span>
                </div>
            </div>
            <span class="hidden md:inline-block text-[11px] px-2 py-0.5 rounded-full bg-emerald-950/80 text-emerald-300 border border-emerald-800/80 font-bold">
                STAFF DESK
            </span>
        </div>

        <!-- Right Quick Actions & Admin View Switcher -->
        <div class="flex items-center gap-3">
            <!-- Link to Admin Portal -->
            <a href="${pageContext.request.contextPath}/dashboard/admin" class="flex items-center gap-1.5 text-xs text-slate-300 hover:text-white font-bold px-3 py-1.5 rounded-xl bg-slate-800 hover:bg-slate-700 border border-slate-700 transition">
                <span>👑</span>
                <span>Open Admin Portal</span>
            </a>

            <!-- Link to Public Storefront -->
            <a href="${pageContext.request.contextPath}/home" class="hidden sm:flex items-center gap-1 text-xs text-slate-400 hover:text-emerald-400 font-semibold px-2.5 py-1.5 rounded-xl hover:bg-slate-800 transition">
                <span>Storefront ↗</span>
            </a>
        </div>
    </header>

    <!-- ================================================================= -->
    <!-- 2. MAIN LAYOUT: STAFF SIDEBAR + WORKSPACE                         -->
    <!-- ================================================================= -->
    <div class="flex-1 flex overflow-hidden">
        
        <!-- =============================================================== -->
        <!-- 2.1. STAFF SIDEBAR                                              -->
        <!-- =============================================================== -->
        <aside class="w-64 bg-white border-r border-slate-200/90 flex flex-col flex-shrink-0 z-20">
            
            <!-- Current Staff Profile Card -->
            <div class="p-4 border-b border-slate-100 bg-slate-50/70">
                <div class="flex items-center gap-3">
                    <div class="w-10 h-10 rounded-xl bg-gradient-to-br from-emerald-600 to-teal-700 text-white flex items-center justify-center font-bold text-base shadow-sm">
                        <c:choose>
                            <c:when test="${not empty sessionScope.authUser}">
                                <c:out value="${sessionScope.authUser.fullName.substring(0, 1).toUpperCase()}"/>
                            </c:when>
                            <c:otherwise>ST</c:otherwise>
                        </c:choose>
                    </div>
                    <div class="min-w-0 flex-1">
                        <h4 class="text-xs font-bold text-slate-900 truncate">
                            <c:choose>
                                <c:when test="${not empty sessionScope.authUser}">
                                    <c:out value="${sessionScope.authUser.fullName}"/> (Staff)
                                </c:when>
                                <c:otherwise>Staff.Sales (Tran Staff)</c:otherwise>
                            </c:choose>
                        </h4>
                        <div class="flex items-center gap-1.5 mt-0.5">
                            <span class="w-2 h-2 rounded-full bg-emerald-500 animate-pulse-dot"></span>
                            <span class="text-[10px] font-extrabold text-emerald-600 uppercase tracking-wider">Fulfillment Staff</span>
                        </div>
                    </div>
                </div>
            </div>

            <!-- Staff Navigation Menu (Focused purely on daily duties) -->
            <nav class="flex-1 px-3 py-4 space-y-1.5 overflow-y-auto custom-scrollbar text-xs">
                
                <div class="px-3 pb-1 text-[10px] font-extrabold uppercase tracking-wider text-slate-400">
                    Daily Operations
                </div>

                <!-- 1. Staff Operations Overview -->
                <button onclick="navigateStaffTo('overview')" id="nav-overview" class="w-full nav-item-active flex items-center gap-3 px-3.5 py-2.5 rounded-xl font-semibold transition text-slate-600 hover:bg-slate-100">
                    <svg class="w-4 h-4 text-slate-500" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M3 12l2-2m0 0l7-7 7 7M5 10v10a1 1 0 001 1h3m10-11l2 2m-2-2v10a1 1 0 01-1 1h-3m-6 0a1 1 0 001-1v-4a1 1 0 011-1h2a1 1 0 011 1v4a1 1 0 001 1m-6 0h6"/></svg>
                    <span>Operations Desk</span>
                </button>

                <div class="px-3 pt-3 pb-1 text-[10px] font-extrabold uppercase tracking-wider text-slate-400">
                    Fulfillment
                </div>

                <!-- 2. Order Packing & Shipping (TSK-27) -->
                <button onclick="navigateStaffTo('orders')" id="nav-orders" class="w-full flex items-center justify-between px-3.5 py-2.5 rounded-xl font-semibold text-slate-600 hover:bg-slate-100 transition">
                    <div class="flex items-center gap-3">
                        <svg class="w-4 h-4 text-slate-500" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M16 11V7a4 4 0 00-8 0v4M5 9h14l1 12H4L5 9z"/></svg>
                        <span>Order Packing Queue</span>
                    </div>
                    <span class="bg-amber-100 text-amber-800 font-extrabold text-[10px] px-2 py-0.5 rounded-full">24 Pending</span>
                </button>

                <!-- 3. Return & Refund Inspection (TSK-33) -->
                <button onclick="navigateStaffTo('returns')" id="nav-returns" class="w-full flex items-center justify-between px-3.5 py-2.5 rounded-xl font-semibold text-slate-600 hover:bg-slate-100 transition">
                    <div class="flex items-center gap-3">
                        <svg class="w-4 h-4 text-slate-500" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M4 4v5h.582m15.356 2A8.001 8.001 0 004.582 9m0 0H9m11 11v-5h-.581m0 0a8.003 8.003 0 01-15.357-2m15.357 2H15"/></svg>
                        <span>Return Ticket Triage</span>
                    </div>
                    <span class="bg-rose-100 text-rose-700 font-bold text-[10px] px-2 py-0.5 rounded-full">3 New</span>
                </button>

                <div class="px-3 pt-3 pb-1 text-[10px] font-extrabold uppercase tracking-wider text-slate-400">
                    Warehouse &amp; Catalog
                </div>

                <!-- 4. Warehouse Stock Check (UC-06, UC-07) -->
                <button onclick="navigateStaffTo('stock')" id="nav-stock" class="w-full flex items-center justify-between px-3.5 py-2.5 rounded-xl font-semibold text-slate-600 hover:bg-slate-100 transition">
                    <div class="flex items-center gap-3">
                        <svg class="w-4 h-4 text-slate-500" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 6.253v13m0-13C10.832 5.477 9.246 5 7.5 5S4.168 5.477 3 6.253v13C4.168 18.477 5.754 18 7.5 18s3.332.477 4.5 1.253m0-13C13.168 5.477 14.754 5 16.5 5c1.747 0 3.332.477 4.5 1.253v13C19.832 18.477 18.247 18 16.5 18c-1.746 0-3.332.477-4.5 1.253"/></svg>
                        <span>Inventory Stock Check</span>
                    </div>
                    <span class="text-rose-600 font-bold text-[10px]">12 Low</span>
                </button>

                <!-- 5. Customer Review Moderation (UC-51) -->
                <button onclick="navigateStaffTo('reviews')" id="nav-reviews" class="w-full flex items-center justify-between px-3.5 py-2.5 rounded-xl font-semibold text-slate-600 hover:bg-slate-100 transition">
                    <div class="flex items-center gap-3">
                        <svg class="w-4 h-4 text-slate-500" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M8 12h.01M12 12h.01M16 12h.01M21 12c0 4.418-4.03 8-9 8a9.863 9.863 0 01-4.255-.949L3 20l1.395-3.72C3.512 15.042 3 13.574 3 12c0-4.418 4.03-8 9-8s9 3.582 9 8z"/></svg>
                        <span>Review Moderation</span>
                    </div>
                    <span class="text-slate-400 text-[10px] font-bold">12 to check</span>
                </button>

            </nav>

            <!-- Sidebar Security Notice -->
            <div class="p-4 border-t border-slate-100 text-[11px] text-slate-400 space-y-1">
                <div class="font-bold text-slate-700">Staff Shift: Active</div>
                <p>Operational access only (No access to user credentials or system financial tax settings).</p>
                <div class="pt-1">
                    <a href="${pageContext.request.contextPath}/dashboard/logout" class="text-xs font-bold text-rose-600 hover:underline">Sign Out</a>
                </div>
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
                        <span>Staff Desk</span>
                        <span>/</span>
                        <span id="staffBreadcrumb" class="text-slate-800 font-bold">Daily Operations Desk</span>
                    </div>
                    <h2 id="staffPageHeader" class="text-lg font-extrabold text-slate-900 leading-tight mt-0.5">
                        Shift Tasks &amp; Fulfillment Center
                    </h2>
                </div>

                <div class="flex items-center gap-3">
                    <!-- Quick Print All Pending Labels Button -->
                    <button onclick="showToast('Printing 24 dispatch shipping labels for courier pickup...')" class="bg-emerald-600 hover:bg-emerald-700 text-white font-bold text-xs px-4 py-2 rounded-xl shadow-sm shadow-emerald-500/20 transition flex items-center gap-1.5">
                        <span>🖨️</span>
                        <span>Print Pending Labels (24)</span>
                    </button>
                </div>
            </div>

            <!-- Scrollable Main Container -->
            <div class="flex-1 overflow-y-auto custom-scrollbar p-6 space-y-6">

                <!-- ============================================================= -->
                <!-- VIEW 1: STAFF OPERATIONS OVERVIEW                             -->
                <!-- ============================================================= -->
                <section id="view-overview" class="space-y-6">
                    
                    <!-- Shift Duty Banner -->
                    <div class="p-5 rounded-2xl bg-gradient-to-r from-emerald-900 via-teal-900 to-slate-900 text-white shadow-sm flex flex-col sm:flex-row items-start sm:items-center justify-between gap-4">
                        <div class="space-y-1">
                            <span class="text-[10px] bg-emerald-500 text-white font-extrabold px-2 py-0.5 rounded uppercase tracking-wider">Morning Operations Shift</span>
                            <h3 class="text-base font-extrabold">Fulfillment Checklist: 24 Orders Awaiting Packing</h3>
                            <p class="text-xs text-emerald-200">Courier pickup is scheduled for 4:00 PM. Please ensure all packages are scanned and labeled.</p>
                        </div>
                        <div class="flex items-center gap-2">
                            <button onclick="navigateStaffTo('orders')" class="px-3.5 py-2 rounded-xl bg-white text-emerald-900 hover:bg-emerald-50 font-black text-xs transition shadow-sm">
                                Start Packing Orders &rarr;
                            </button>
                        </div>
                    </div>

                    <!-- 4 Operational Staff KPIs -->
                    <div class="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-4 gap-4">
                        <div class="bg-white p-5 rounded-2xl border border-slate-200/80 shadow-sm hover-card">
                            <div class="flex items-center justify-between">
                                <span class="text-xs font-bold text-slate-500 uppercase tracking-wider">Orders to Pack</span>
                                <span class="w-9 h-9 rounded-xl bg-amber-50 text-amber-600 flex items-center justify-center text-base font-bold">📦</span>
                            </div>
                            <div class="mt-3 flex items-baseline justify-between">
                                <h3 class="text-2xl font-black text-slate-900">24 Orders</h3>
                                <span class="text-[11px] font-bold text-amber-700 bg-amber-50 px-2 py-0.5 rounded-full">Urgent</span>
                            </div>
                            <p class="text-[11px] text-slate-400 mt-1">Pending payment verification &amp; boxing</p>
                        </div>

                        <div class="bg-white p-5 rounded-2xl border border-slate-200/80 shadow-sm hover-card">
                            <div class="flex items-center justify-between">
                                <span class="text-xs font-bold text-slate-500 uppercase tracking-wider">Dispatched Today</span>
                                <span class="w-9 h-9 rounded-xl bg-emerald-50 text-emerald-600 flex items-center justify-center text-base font-bold">🚚</span>
                            </div>
                            <div class="mt-3 flex items-baseline justify-between">
                                <h3 class="text-2xl font-black text-slate-900">52 Orders</h3>
                                <span class="text-[11px] font-bold text-emerald-600 bg-emerald-50 px-2 py-0.5 rounded-full">On time</span>
                            </div>
                            <p class="text-[11px] text-slate-400 mt-1">Handed over to Vietnam Post &amp; GHTK</p>
                        </div>

                        <div class="bg-white p-5 rounded-2xl border border-slate-200/80 shadow-sm hover-card">
                            <div class="flex items-center justify-between">
                                <span class="text-xs font-bold text-slate-500 uppercase tracking-wider">Low Stock Warnings</span>
                                <span class="w-9 h-9 rounded-xl bg-rose-50 text-rose-600 flex items-center justify-center text-base font-bold">⚠️</span>
                            </div>
                            <div class="mt-3 flex items-baseline justify-between">
                                <h3 class="text-2xl font-black text-slate-900">12 Titles</h3>
                                <span class="text-[11px] font-bold text-rose-600 bg-rose-50 px-2 py-0.5 rounded-full">&lt; 10 units</span>
                            </div>
                            <p class="text-[11px] text-slate-400 mt-1">Requisition note forwarded to Admin</p>
                        </div>

                        <div class="bg-white p-5 rounded-2xl border border-slate-200/80 shadow-sm hover-card">
                            <div class="flex items-center justify-between">
                                <span class="text-xs font-bold text-slate-500 uppercase tracking-wider">Return Tickets</span>
                                <span class="w-9 h-9 rounded-xl bg-purple-50 text-purple-600 flex items-center justify-center text-base font-bold">↩️</span>
                            </div>
                            <div class="mt-3 flex items-baseline justify-between">
                                <h3 class="text-2xl font-black text-slate-900">3 Tickets</h3>
                                <span class="text-[11px] font-bold text-purple-600 bg-purple-50 px-2 py-0.5 rounded-full">Triage</span>
                            </div>
                            <p class="text-[11px] text-slate-400 mt-1">Awaiting physical book inspection</p>
                        </div>
                    </div>

                    <!-- Pending Order Packing Queue -->
                    <div class="bg-white rounded-2xl border border-slate-200/80 shadow-sm p-5 space-y-4">
                        <div class="flex items-center justify-between">
                            <div>
                                <h3 class="text-sm font-extrabold text-slate-900 flex items-center gap-2">
                                    <span>📋 Immediate Packing Queue</span>
                                    <span class="text-[10px] bg-amber-100 text-amber-800 font-bold px-2 py-0.5 rounded-md">24 Orders</span>
                                </h3>
                                <p class="text-xs text-slate-400">Scan items, pack with protective bubble wrap, and print courier slip</p>
                            </div>
                            <button onclick="navigateStaffTo('orders')" class="text-xs font-bold text-emerald-600 hover:underline">View All &rarr;</button>
                        </div>

                        <!-- Table -->
                        <div class="overflow-x-auto custom-scrollbar">
                            <table class="w-full text-left text-xs">
                                <thead class="bg-slate-50 text-slate-500 font-bold border-b border-slate-200">
                                    <tr>
                                        <th class="py-2.5 px-3">Order Code</th>
                                        <th class="py-2.5 px-3">Customer &amp; Destination</th>
                                        <th class="py-2.5 px-3">Books to Pick</th>
                                        <th class="py-2.5 px-3">Status</th>
                                        <th class="py-2.5 px-3 text-right">Fulfillment Action</th>
                                    </tr>
                                </thead>
                                <tbody class="divide-y divide-slate-100 font-medium text-slate-700">
                                    <tr class="hover:bg-slate-50 transition">
                                        <td class="py-3 px-3 font-bold text-slate-900">#ORD-2026-9842</td>
                                        <td class="py-3 px-3">
                                            <div class="font-bold text-slate-800">Nguyen Van An</div>
                                            <div class="text-[10px] text-slate-400">District 1, Ho Chi Minh City</div>
                                        </td>
                                        <td class="py-3 px-3 font-semibold text-slate-800">
                                            Atomic Habits (x1), Dune (x1)
                                        </td>
                                        <td class="py-3 px-3">
                                            <span class="px-2 py-0.5 rounded-full bg-amber-100 text-amber-800 font-bold text-[10px]">PENDING PACKING</span>
                                        </td>
                                        <td class="py-3 px-3 text-right space-x-1.5">
                                            <button onclick="openPackingModal('#ORD-2026-9842', 'Nguyen Van An', 'Atomic Habits (x1), Dune (x1)')" class="px-3 py-1.5 rounded-xl bg-emerald-600 hover:bg-emerald-700 text-white font-bold text-xs transition">
                                                Pack &amp; Dispatch
                                            </button>
                                        </td>
                                    </tr>

                                    <tr class="hover:bg-slate-50 transition">
                                        <td class="py-3 px-3 font-bold text-slate-900">#ORD-2026-9841</td>
                                        <td class="py-3 px-3">
                                            <div class="font-bold text-slate-800">Tran Thi Mai</div>
                                            <div class="text-[10px] text-slate-400">Ba Dinh, Hanoi</div>
                                        </td>
                                        <td class="py-3 px-3 font-semibold text-slate-800">
                                            The Midnight Library (x1)
                                        </td>
                                        <td class="py-3 px-3">
                                            <span class="px-2 py-0.5 rounded-full bg-blue-100 text-blue-700 font-bold text-[10px]">PROCESSING</span>
                                        </td>
                                        <td class="py-3 px-3 text-right space-x-1.5">
                                            <button onclick="openPackingModal('#ORD-2026-9841', 'Tran Thi Mai', 'The Midnight Library (x1)')" class="px-3 py-1.5 rounded-xl bg-emerald-600 hover:bg-emerald-700 text-white font-bold text-xs transition">
                                                Pack &amp; Dispatch
                                            </button>
                                        </td>
                                    </tr>
                                </tbody>
                            </table>
                        </div>
                    </div>

                </section>

                <!-- ============================================================= -->
                <!-- VIEW 2: ORDER PACKING & SHIPPING                              -->
                <!-- ============================================================= -->
                <section id="view-orders" class="hidden space-y-5">
                    <div class="bg-white p-5 rounded-2xl border border-slate-200/80 shadow-sm flex items-center justify-between">
                        <div>
                            <h3 class="text-base font-extrabold text-slate-900">Order Dispatch &amp; Shipping Workflow (TSK-27)</h3>
                            <p class="text-xs text-slate-400">Update order status: PENDING ➔ PROCESSING ➔ SHIPPED</p>
                        </div>
                        <div class="flex items-center gap-2">
                            <input type="text" placeholder="Scan Barcode / Order ID..." class="px-3 py-1.5 rounded-xl bg-slate-50 border border-slate-200 text-xs focus:outline-none">
                            <button onclick="showToast('Barcode scanned: Ready for packing.')" class="px-3 py-1.5 rounded-xl bg-slate-800 text-white font-bold text-xs">Scan</button>
                        </div>
                    </div>

                    <div class="bg-white rounded-2xl border border-slate-200/80 shadow-sm p-4 space-y-3">
                        <p class="text-xs text-slate-600">All orders pending dispatch are grouped below with automatic label generator.</p>
                        <div class="p-4 rounded-xl bg-slate-50 border border-slate-200 flex justify-between items-center text-xs">
                            <div>
                                <span class="font-bold text-slate-900">#ORD-2026-9842</span> — Nguyen Van An
                                <div class="text-[11px] text-slate-400">VNPAY Paid • Ready for box packing</div>
                            </div>
                            <button onclick="showToast('Order #ORD-2026-9842 dispatched to courier!')" class="px-3 py-1.5 rounded-xl bg-emerald-600 hover:bg-emerald-700 text-white font-bold text-xs transition">
                                Mark as SHIPPED
                            </button>
                        </div>
                    </div>
                </section>

                <!-- ============================================================= -->
                <!-- VIEW 3: INVENTORY STOCK CHECK                                 -->
                <!-- ============================================================= -->
                <section id="view-stock" class="hidden space-y-5">
                    <div class="bg-white p-5 rounded-2xl border border-slate-200/80 shadow-sm flex items-center justify-between">
                        <div>
                            <h3 class="text-base font-extrabold text-slate-900">Warehouse Inventory &amp; Stock Verification</h3>
                            <p class="text-xs text-slate-400">Check physical book quantity on shelves and report inventory differences</p>
                        </div>
                        <button onclick="showToast('Submitting restock request note to Admin...')" class="bg-amber-600 hover:bg-amber-700 text-white font-bold text-xs px-3.5 py-2 rounded-xl transition">
                            + Request Stock Reorder
                        </button>
                    </div>

                    <div class="bg-white rounded-2xl border border-slate-200/80 shadow-sm overflow-hidden">
                        <table class="w-full text-left text-xs">
                            <thead class="bg-slate-50 text-slate-500 font-bold border-b border-slate-200">
                                <tr>
                                    <th class="py-3 px-4">Book Title</th>
                                    <th class="py-3 px-3">Shelf Location</th>
                                    <th class="py-3 px-3">Recorded Stock</th>
                                    <th class="py-3 px-4 text-right">Physical Count Adjustment</th>
                                </tr>
                            </thead>
                            <tbody class="divide-y divide-slate-100 font-medium text-slate-700">
                                <tr>
                                    <td class="py-3 px-4 font-bold text-slate-900">Atomic Habits</td>
                                    <td class="py-3 px-3 font-mono">Row A-04</td>
                                    <td class="py-3 px-3 text-rose-600 font-bold">3 left (Critical)</td>
                                    <td class="py-3 px-4 text-right">
                                        <button onclick="showToast('Stock count verified.')" class="px-2.5 py-1 rounded-lg bg-slate-100 font-bold hover:bg-slate-200">Verify</button>
                                    </td>
                                </tr>
                                <tr>
                                    <td class="py-3 px-4 font-bold text-slate-900">Clean Code</td>
                                    <td class="py-3 px-3 font-mono">Row T-12</td>
                                    <td class="py-3 px-3 text-rose-600 font-bold">5 left (Low)</td>
                                    <td class="py-3 px-4 text-right">
                                        <button onclick="showToast('Stock count verified.')" class="px-2.5 py-1 rounded-lg bg-slate-100 font-bold hover:bg-slate-200">Verify</button>
                                    </td>
                                </tr>
                            </tbody>
                        </table>
                    </div>
                </section>

                <!-- ============================================================= -->
                <!-- VIEW 4: RETURN TICKETS TRIAGE                                 -->
                <!-- ============================================================= -->
                <section id="view-returns" class="hidden space-y-5">
                    <div class="bg-white p-5 rounded-2xl border border-slate-200/80 shadow-sm">
                        <h3 class="text-base font-extrabold text-slate-900">Customer Return Ticket Triage (TSK-33)</h3>
                        <p class="text-xs text-slate-400">Staff inspects customer evidence photos, writes condition report, and flags for Admin approval</p>
                    </div>

                    <div class="bg-white p-5 rounded-2xl border border-slate-200/80 shadow-sm space-y-3 text-xs">
                        <div class="border border-slate-200 rounded-xl p-4 flex justify-between items-center">
                            <div>
                                <span class="font-bold text-slate-900">Ticket #RET-104</span>
                                <p class="text-slate-500">Customer: Tran Quoc Bao • Reason: "Book spine torn during transit"</p>
                            </div>
                            <button onclick="showToast('Staff note added: Confirmed transit spine defect. Forwarded to Admin.')" class="px-3.5 py-1.5 rounded-xl bg-blue-600 text-white font-bold">
                                Inspect &amp; Forward to Admin
                            </button>
                        </div>
                    </div>
                </section>

                <!-- ============================================================= -->
                <!-- VIEW 5: REVIEW MODERATION                                     -->
                <!-- ============================================================= -->
                <section id="view-reviews" class="hidden space-y-5">
                    <div class="bg-white p-5 rounded-2xl border border-slate-200/80 shadow-sm">
                        <h3 class="text-base font-extrabold text-slate-900">Review &amp; Rating Moderation (UC-51)</h3>
                        <p class="text-xs text-slate-400">Review newly submitted ratings to filter spam and inappropriate words</p>
                    </div>

                    <div class="bg-white p-5 rounded-2xl border border-slate-200/80 shadow-sm space-y-3 text-xs">
                        <div class="p-3 bg-slate-50 rounded-xl flex justify-between items-center">
                            <div>
                                <span class="font-bold text-slate-900">★ ★ ★ ★ ★ "Amazing book for building habits!"</span>
                                <p class="text-[11px] text-slate-400">By user Le Long on Atomic Habits</p>
                            </div>
                            <div class="space-x-1.5">
                                <button onclick="showToast('Review approved &amp; published publicly.')" class="px-3 py-1 rounded-lg bg-emerald-600 text-white font-bold">Approve</button>
                                <button onclick="showToast('Review hidden.')" class="px-3 py-1 rounded-lg bg-rose-50 text-rose-600 font-bold">Hide</button>
                            </div>
                        </div>
                    </div>
                </section>

            </div>
        </main>

    </div>

    <!-- PACKING & DISPATCH MODAL -->
    <div id="modalPacking" class="fixed inset-0 bg-slate-900/60 backdrop-blur-sm z-50 hidden flex items-center justify-center p-4">
        <div class="bg-white rounded-3xl shadow-2xl max-w-lg w-full p-6 space-y-4">
            <div class="flex items-center justify-between border-b border-slate-100 pb-3">
                <div>
                    <h3 id="modalPackCode" class="text-base font-extrabold text-slate-900">#ORD-2026-9842</h3>
                    <p id="modalPackCustomer" class="text-xs text-slate-400">Customer: Nguyen Van An</p>
                </div>
                <button onclick="closePackingModal()" class="w-8 h-8 rounded-full bg-slate-100 hover:bg-slate-200 text-slate-600 font-bold">&times;</button>
            </div>

            <div class="space-y-3 text-xs">
                <div class="p-3 bg-slate-50 rounded-xl space-y-2">
                    <span class="font-bold text-slate-700">Packing Checklist:</span>
                    <label class="flex items-center gap-2 text-slate-800">
                        <input type="checkbox" checked class="w-4 h-4 text-emerald-600 rounded">
                        <span>Inspect book condition (no torn corners)</span>
                    </label>
                    <label class="flex items-center gap-2 text-slate-800">
                        <input type="checkbox" checked class="w-4 h-4 text-emerald-600 rounded">
                        <span>Include BookStore bookmark &amp; sticker gift</span>
                    </label>
                    <label class="flex items-center gap-2 text-slate-800">
                        <input type="checkbox" checked class="w-4 h-4 text-emerald-600 rounded">
                        <span>Seal with waterproof bubble envelope</span>
                    </label>
                </div>

                <div id="modalPackItems" class="p-3 bg-emerald-50 rounded-xl text-emerald-900 font-semibold">
                    Items: Atomic Habits (x1), Dune (x1)
                </div>
            </div>

            <div class="flex items-center justify-end gap-2 pt-3 border-t border-slate-100">
                <button onclick="showToast('Printing barcode courier slip...')" class="px-4 py-2 rounded-xl bg-slate-100 hover:bg-slate-200 text-slate-700 font-bold text-xs transition">🖨️ Print Label</button>
                <button onclick="handleCompletePacking()" class="px-4 py-2 rounded-xl bg-emerald-600 hover:bg-emerald-700 text-white font-bold text-xs transition">Mark as SHIPPED</button>
            </div>
        </div>
    </div>

    <!-- FLOATING TOAST -->
    <div id="toast" class="fixed bottom-6 right-6 z-50 bg-slate-900 text-white px-4 py-3 rounded-2xl shadow-2xl border border-slate-700 text-xs font-bold transition-all transform translate-y-20 opacity-0 pointer-events-none flex items-center gap-2">
        <span>💼</span>
        <span id="toastMsg">Notification message</span>
    </div>

    <script>
        function navigateStaffTo(viewName) {
            const views = ['overview', 'orders', 'stock', 'returns', 'reviews'];
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
                'overview': 'Daily Operations Desk',
                'orders': 'Order Dispatch & Packing',
                'stock': 'Warehouse Inventory Check',
                'returns': 'Return Ticket Triage',
                'reviews': 'Review Moderation'
            };
            document.getElementById('staffBreadcrumb').textContent = map[viewName] || 'Overview';
            document.getElementById('staffPageHeader').textContent = map[viewName] || 'Overview';
        }

        function openPackingModal(code, customer, items) {
            document.getElementById('modalPackCode').textContent = code;
            document.getElementById('modalPackCustomer').textContent = 'Customer: ' + customer;
            document.getElementById('modalPackItems').textContent = 'Items: ' + items;
            document.getElementById('modalPacking').classList.remove('hidden');
        }
        function closePackingModal() {
            document.getElementById('modalPacking').classList.add('hidden');
        }
        function handleCompletePacking() {
            closePackingModal();
            showToast('Order successfully packed and marked as SHIPPED (TSK-27).');
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
