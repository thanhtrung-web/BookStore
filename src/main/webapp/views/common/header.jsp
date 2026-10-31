<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>${pageTitle != null ? pageTitle : 'BookStore - Read More • Grow More'}</title>

    <!-- Google Fonts: Inter & Dancing Script (for .font-handwriting) -->
    <link rel="preconnect" href="https://fonts.googleapis.com">
    <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
    <link href="https://fonts.googleapis.com/css2?family=Dancing+Script:wght@600;700&family=Inter:wght@400;500;600;700;800;900&display=swap" rel="stylesheet">

    <!-- Tailwind CSS CDN -->
    <script src="https://cdn.tailwindcss.com"></script>

    <!-- Custom Styles for Home & Common Layout -->
    <link rel="stylesheet" href="${pageContext.request.contextPath}/static/css/style.css">
    <style>
        body {
            font-family: 'Inter', -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, sans-serif;
            background-color: #f4f7fb;
            color: #1e293b;
        }
        .font-handwriting {
            font-family: 'Dancing Script', cursive;
        }
        .book-card {
            transition: all 0.22s cubic-bezier(0.4, 0, 0.2, 1);
        }
        .book-card:hover {
            transform: translateY(-4px);
            box-shadow: 0 12px 24px -6px rgba(37, 99, 235, 0.14), 0 4px 10px -3px rgba(15, 23, 42, 0.06);
            border-color: #bfdbfe;
        }
        .custom-scrollbar::-webkit-scrollbar {
            height: 5px;
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
    </style>
</head>
<body class="min-h-screen flex flex-col bg-[#f4f7fb] text-slate-800 antialiased">

    <!-- TOP STICKY E-COMMERCE HEADER -->
    <header class="sticky top-0 z-40 bg-white/95 backdrop-blur-md border-b border-slate-200/80 shadow-xs">
        <div class="max-w-[1440px] mx-auto px-4 sm:px-8 h-16 flex items-center justify-between gap-4">

            <!-- Left: Brand Logo & Primary Navigation -->
            <div class="flex items-center gap-6 lg:gap-8">
                <a href="${pageContext.request.contextPath}/home" class="flex items-center gap-2.5 group">
                    <div class="w-9 h-9 rounded-xl bg-blue-600 text-white flex items-center justify-center font-bold text-base shadow-sm shadow-blue-500/20 group-hover:bg-blue-700 transition">
                        📚
                    </div>
                    <div class="flex flex-col">
                        <span class="text-lg font-extrabold tracking-tight text-blue-600 leading-none">
                            Book<span class="text-slate-900">Store</span>
                        </span>
                        <span class="text-[9px] font-semibold text-slate-400 tracking-wider uppercase mt-0.5">
                            Read More • Grow More
                        </span>
                    </div>
                </a>

                <nav class="hidden md:flex items-center gap-1">
                    <a href="${pageContext.request.contextPath}/home"
                       class="px-3.5 py-2 rounded-xl text-xs font-bold text-blue-600 bg-blue-50/80 transition">
                        Home
                    </a>
                    <a href="#featured-books"
                       class="px-3.5 py-2 rounded-xl text-xs font-semibold text-slate-600 hover:text-blue-600 hover:bg-slate-50 transition">
                        Featured Books
                    </a>
                    <a href="${pageContext.request.contextPath}/books?filter=new"
                       class="px-3.5 py-2 rounded-xl text-xs font-semibold text-slate-600 hover:text-blue-600 hover:bg-slate-50 transition">
                        New Releases
                    </a>
                    <a href="${pageContext.request.contextPath}/promotions"
                       class="px-3.5 py-2 rounded-xl text-xs font-semibold text-slate-600 hover:text-blue-600 hover:bg-slate-50 transition">
                        Promotions
                    </a>
                </nav>
            </div>

            <!-- Center: Search Bar -->
            <form action="${pageContext.request.contextPath}/books" method="get" class="hidden sm:flex items-center flex-1 max-w-md mx-2">
                <div class="relative w-full">
                    <span class="absolute inset-y-0 left-0 pl-3.5 flex items-center text-slate-400 pointer-events-none text-xs">
                        🔍
                    </span>
                    <input type="text"
                           name="q"
                           value="<c:out value='${param.q}'/>"
                           placeholder="Search books, authors, genres..."
                           class="w-full pl-9 pr-20 py-2 rounded-full bg-slate-100/90 border border-slate-200/80 text-xs text-slate-800 placeholder-slate-400 focus:outline-none focus:bg-white focus:border-blue-500 focus:ring-2 focus:ring-blue-100 transition" />
                    <button type="submit"
                            class="absolute right-1 top-1 bottom-1 px-3.5 rounded-full bg-blue-600 hover:bg-blue-700 text-white text-[11px] font-bold transition">
                        Search
                    </button>
                </div>
            </form>

            <!-- Right: Cart & User Authentication Actions -->
            <div class="flex items-center gap-2.5 sm:gap-3">

                <!-- Shopping Cart Button -->
                <a href="${pageContext.request.contextPath}/cart"
                   class="relative p-2 rounded-xl bg-slate-100/80 hover:bg-blue-50 text-slate-700 hover:text-blue-600 transition"
                   title="Shopping Cart">
                    <span class="text-base leading-none">🛒</span>
                    <span class="absolute -top-1 -right-1 w-4 h-4 rounded-full bg-rose-500 text-white text-[9px] font-extrabold flex items-center justify-center shadow-xs">
                        ${not empty sessionScope.cartCount ? sessionScope.cartCount : 0}
                    </span>
                </a>

                <!-- Conditional Auth State (UC-01 / UC-02 / UC-03 :UserMenu) -->
                <c:choose>
                    <c:when test="${not empty sessionScope.authUser}">
                        <div class="relative group flex items-center gap-2 pl-2 border-l border-slate-200">
                            <a href="${pageContext.request.contextPath}/profile"
                               class="flex items-center gap-2 px-2 py-1 rounded-xl hover:bg-slate-100/80 transition"
                               title="My Account Profile">
                                <c:choose>
                                    <c:when test="${not empty sessionScope.authUser.avatarUrl}">
                                        <img src="${sessionScope.authUser.avatarUrl}" alt="Avatar" class="w-8 h-8 rounded-full object-cover ring-2 ring-blue-500/20" />
                                    </c:when>
                                    <c:otherwise>
                                        <div class="w-8 h-8 rounded-full bg-blue-600 text-white font-bold text-xs flex items-center justify-center shadow-xs">
                                            <c:out value="${sessionScope.authUser.fullName.substring(0, 1).toUpperCase()}"/>
                                        </div>
                                    </c:otherwise>
                                </c:choose>
                                <div class="hidden lg:flex flex-col text-left">
                                    <div class="flex items-center gap-1.5">
                                        <span class="text-xs font-bold text-slate-800 max-w-[130px] truncate">
                                            <c:out value="${sessionScope.authUser.fullName}"/>
                                        </span>
                                        <span class="px-1.5 py-0.5 rounded-md bg-amber-100 text-amber-800 text-[9px] font-extrabold uppercase">
                                            <c:out value="${sessionScope.userRole}"/>
                                        </span>
                                    </div>
                                    <span class="text-[10px] text-slate-400 max-w-[150px] truncate">
                                        <c:out value="${sessionScope.authUser.email}"/>
                                    </span>
                                </div>
                            </a>

                            <!-- UserMenu Dropdown (TSK-05 / UC-03 & TSK-07 / UC-05) -->
                            <div class="absolute right-0 top-full pt-2 w-52 opacity-0 invisible group-hover:opacity-100 group-hover:visible transition-all duration-150 z-50">
                                <div class="bg-white rounded-2xl border border-slate-200/90 shadow-xl py-2 text-xs font-semibold text-slate-700">
                                    <a href="${pageContext.request.contextPath}/profile" class="flex items-center gap-2.5 px-4 py-2 hover:bg-blue-50 hover:text-blue-600 transition">
                                        <span>👤</span> <span>Personal Profile</span>
                                    </a>
                                    <a href="${pageContext.request.contextPath}/profile#password" class="flex items-center gap-2.5 px-4 py-2 hover:bg-blue-50 hover:text-blue-600 transition">
                                        <span>🔒</span> <span>Change Password</span>
                                    </a>
                                    <a href="${pageContext.request.contextPath}/profile#address" class="flex items-center gap-2.5 px-4 py-2 hover:bg-blue-50 hover:text-blue-600 transition">
                                        <span>📍</span> <span>Address Book</span>
                                    </a>
                                    <c:if test="${sessionScope.userRole == 'ADMIN'}">
                                        <div class="my-1 border-t border-slate-100"></div>
                                        <a href="${pageContext.request.contextPath}/dashboard/admin" class="flex items-center gap-2.5 px-4 py-2 hover:bg-purple-50 hover:text-purple-600 transition font-bold text-purple-700">
                                            <span>👑</span> <span>Admin Console</span>
                                        </a>
                                    </c:if>
                                    <c:if test="${sessionScope.userRole == 'STAFF' || sessionScope.userRole == 'INVENTORY_STAFF'}">
                                        <div class="my-1 border-t border-slate-100"></div>
                                        <a href="${pageContext.request.contextPath}/dashboard/staff" class="flex items-center gap-2.5 px-4 py-2 hover:bg-emerald-50 hover:text-emerald-600 transition font-bold text-emerald-700">
                                            <span>💼</span> <span>Staff Workspace</span>
                                        </a>
                                    </c:if>
                                    <div class="my-1 border-t border-slate-100"></div>
                                    <a href="${pageContext.request.contextPath}/logout" class="flex items-center gap-2.5 px-4 py-2 text-rose-600 hover:bg-rose-50 transition font-bold">
                                        <span>🚪</span> <span>Sign Out</span>
                                    </a>
                                </div>
                            </div>

                            <a href="${pageContext.request.contextPath}/logout"
                               class="ml-1 px-3 py-1.5 rounded-xl border border-slate-200 hover:border-rose-200 hover:bg-rose-50 text-slate-600 hover:text-rose-600 text-xs font-bold transition">
                                Sign Out
                            </a>
                        </div>
                    </c:when>
                    <c:otherwise>
                        <div class="flex items-center gap-2 pl-1">
                            <a href="${pageContext.request.contextPath}/login"
                               class="px-3.5 py-2 rounded-xl text-xs font-bold text-slate-700 hover:text-blue-600 hover:bg-slate-100 transition">
                                Sign In
                            </a>
                            <a href="${pageContext.request.contextPath}/register"
                               class="px-4 py-2 rounded-xl bg-blue-600 hover:bg-blue-700 text-white text-xs font-bold shadow-sm shadow-blue-500/20 transition">
                                Register
                            </a>
                        </div>
                    </c:otherwise>
                </c:choose>

            </div>

        </div>
    </header>
