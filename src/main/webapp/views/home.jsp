<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>

<!-- Include Common Modular Header -->
<jsp:include page="/views/common/header.jsp" />

<!-- Optional Logout Notification -->
<c:if test="${param.logout == 'true'}">
    <div class="max-w-[1440px] mx-auto px-4 sm:px-8 pt-4">
        <div class="bg-blue-50 border border-blue-200 text-blue-700 px-4 py-3 rounded-2xl flex items-center justify-between text-xs font-semibold shadow-sm" role="alert">
            <div class="flex items-center gap-2">
                <span>👋</span>
                <span>You have successfully signed out of BookStore.</span>
            </div>
            <button type="button" onclick="this.parentElement.parentElement.remove()" class="text-blue-500 hover:text-blue-700 font-bold ml-4">&times;</button>
        </div>
    </div>
</c:if>

<!-- ========================================================= -->
<!-- MAIN PAGE CONTENT CONTAINER                               -->
<!-- ========================================================= -->
<main class="max-w-[1440px] mx-auto px-4 sm:px-8 py-6 space-y-7 relative z-10">

    <!-- 1. HERO BANNER (USING SAVED STATIC ASSET) -->
    <section class="relative rounded-3xl overflow-hidden shadow-[0_10px_30px_-8px_rgba(37,99,235,0.12)] border border-blue-100/90 group transition-all">
        <img src="${pageContext.request.contextPath}/static/images/hero-banner.png" alt="Good Books Brighter Your Life" class="w-full h-auto object-cover rounded-3xl select-none block" />
        
        <!-- Interactive Hotspot on Shop Now button linking to featured books -->
        <a href="#featured-books" class="absolute left-[7.5%] sm:left-[8.5%] md:left-[9.5%] top-[54%] sm:top-[56%] md:top-[58%] w-[115px] sm:w-[150px] md:w-[170px] h-[34px] sm:h-[42px] md:h-[48px] rounded-full opacity-0 hover:opacity-20 bg-blue-300 transition cursor-pointer" title="Shop Now"></a>

        <!-- Slider Arrows (Visible on Hover) -->
        <button type="button" class="absolute left-3 top-1/2 -translate-y-1/2 w-9 h-9 rounded-full bg-white/90 backdrop-blur-sm shadow-md border border-slate-200 text-slate-600 hover:text-blue-600 hover:scale-110 flex items-center justify-center transition opacity-0 group-hover:opacity-100">
            <svg class="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2.5" d="M15 19l-7-7 7-7"/></svg>
        </button>
        <button type="button" class="absolute right-3 top-1/2 -translate-y-1/2 w-9 h-9 rounded-full bg-white/90 backdrop-blur-sm shadow-md border border-slate-200 text-slate-600 hover:text-blue-600 hover:scale-110 flex items-center justify-center transition opacity-0 group-hover:opacity-100">
            <svg class="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2.5" d="M9 5l7 7-7 7"/></svg>
        </button>
    </section>

    <!-- 2. CATEGORY PILLS BAR (11 CATEGORIES EXACTLY AS IN DESIGN) -->
    <section class="bg-white rounded-2xl p-3 border border-slate-200/80 shadow-sm overflow-x-auto custom-scrollbar">
        <div class="flex items-center justify-between gap-2 min-w-max">
            
            <!-- 1. All Books (Active Blue) -->
            <a href="${pageContext.request.contextPath}/books" class="flex flex-col items-center justify-center py-2 px-3.5 rounded-xl bg-blue-50 text-blue-600 font-bold text-[11px] min-w-[76px] transition border border-blue-200/80">
                <div class="w-8 h-8 rounded-lg bg-blue-600 text-white flex items-center justify-center text-sm mb-1 shadow-sm">
                    📖
                </div>
                <span>All Books</span>
            </a>

            <!-- 2. Literature -->
            <a href="${pageContext.request.contextPath}/books?category=van-hoc" class="flex flex-col items-center justify-center py-2 px-3.5 rounded-xl hover:bg-slate-50 text-slate-700 font-semibold text-[11px] min-w-[76px] transition">
                <div class="w-8 h-8 rounded-lg bg-pink-100 text-pink-600 flex items-center justify-center text-sm mb-1">
                    📕
                </div>
                <span>Literature</span>
            </a>

            <!-- 3. Economics -->
            <a href="${pageContext.request.contextPath}/books?category=kinh-te" class="flex flex-col items-center justify-center py-2 px-3.5 rounded-xl hover:bg-slate-50 text-slate-700 font-semibold text-[11px] min-w-[76px] transition">
                <div class="w-8 h-8 rounded-lg bg-emerald-100 text-emerald-600 flex items-center justify-center text-sm mb-1">
                    📈
                </div>
                <span>Economics</span>
            </a>

            <!-- 4. Technology -->
            <a href="${pageContext.request.contextPath}/books?category=cong-nghe" class="flex flex-col items-center justify-center py-2 px-3.5 rounded-xl hover:bg-slate-50 text-slate-700 font-semibold text-[11px] min-w-[76px] transition">
                <div class="w-8 h-8 rounded-lg bg-purple-100 text-purple-600 flex items-center justify-center text-sm mb-1">
                    💻
                </div>
                <span>Technology</span>
            </a>

            <!-- 5. Science -->
            <a href="${pageContext.request.contextPath}/books?category=khoa-hoc" class="flex flex-col items-center justify-center py-2 px-3.5 rounded-xl hover:bg-slate-50 text-slate-700 font-semibold text-[11px] min-w-[76px] transition">
                <div class="w-8 h-8 rounded-lg bg-cyan-100 text-cyan-600 flex items-center justify-center text-sm mb-1">
                    ⚛️
                </div>
                <span>Science</span>
            </a>

            <!-- 6. Education -->
            <a href="${pageContext.request.contextPath}/books?category=giao-duc" class="flex flex-col items-center justify-center py-2 px-3.5 rounded-xl hover:bg-slate-50 text-slate-700 font-semibold text-[11px] min-w-[76px] transition">
                <div class="w-8 h-8 rounded-lg bg-amber-100 text-amber-600 flex items-center justify-center text-sm mb-1">
                    🎓
                </div>
                <span>Education</span>
            </a>

            <!-- 7. Children's Books -->
            <a href="${pageContext.request.contextPath}/books?category=tre-em" class="flex flex-col items-center justify-center py-2 px-3.5 rounded-xl hover:bg-slate-50 text-slate-700 font-semibold text-[11px] min-w-[76px] transition">
                <div class="w-8 h-8 rounded-lg bg-rose-100 text-rose-600 flex items-center justify-center text-sm mb-1">
                    😊
                </div>
                <span>Children</span>
            </a>

            <!-- 8. Comics & Manga -->
            <a href="${pageContext.request.contextPath}/books?category=truyen-tranh" class="flex flex-col items-center justify-center py-2 px-3.5 rounded-xl hover:bg-slate-50 text-slate-700 font-semibold text-[11px] min-w-[76px] transition">
                <div class="w-8 h-8 rounded-lg bg-indigo-100 text-indigo-600 flex items-center justify-center text-sm mb-1">
                    🎮
                </div>
                <span>Comics</span>
            </a>

            <!-- 9. Health & Fitness -->
            <a href="${pageContext.request.contextPath}/books?category=suc-khoe" class="flex flex-col items-center justify-center py-2 px-3.5 rounded-xl hover:bg-slate-50 text-slate-700 font-semibold text-[11px] min-w-[76px] transition">
                <div class="w-8 h-8 rounded-lg bg-teal-100 text-teal-600 flex items-center justify-center text-sm mb-1">
                    💚
                </div>
                <span>Health</span>
            </a>

            <!-- 10. Self-Help -->
            <a href="${pageContext.request.contextPath}/books?category=ky-nang-song" class="flex flex-col items-center justify-center py-2 px-3.5 rounded-xl hover:bg-slate-50 text-slate-700 font-semibold text-[11px] min-w-[76px] transition">
                <div class="w-8 h-8 rounded-lg bg-orange-100 text-orange-600 flex items-center justify-center text-sm mb-1">
                    🌱
                </div>
                <span>Self-Help</span>
            </a>

            <!-- 11. More Categories -->
            <a href="${pageContext.request.contextPath}/categories" class="flex flex-col items-center justify-center py-2 px-3.5 rounded-xl hover:bg-slate-50 text-slate-500 font-semibold text-[11px] min-w-[76px] transition">
                <div class="w-8 h-8 rounded-lg bg-slate-100 text-slate-500 flex items-center justify-center text-sm mb-1">
                    •••
                </div>
                <span>More</span>
            </a>

        </div>
    </section>

    <!-- 3. MAIN SECTION SPLIT: LEFT 8-9 COLS + RIGHT 3-4 COLS -->
    <div class="grid grid-cols-1 lg:grid-cols-12 gap-7">
        
        <!-- ============================================== -->
        <!-- LEFT COLUMN: FEATURED BOOKS & NEW ARRIVALS     -->
        <!-- ============================================== -->
        <div class="lg:col-span-8 xl:col-span-9 space-y-7">
            
            <!-- SECTION 1: FEATURED BOOKS (6 BOOKS IN A ROW WITH CAROUSEL ARROWS) -->
            <section id="featured-books" class="bg-white rounded-3xl p-6 border border-slate-200/80 shadow-sm relative">
                
                <!-- Section Title & Arrows -->
                <div class="flex items-center justify-between mb-5">
                    <div>
                        <h2 class="text-base sm:text-lg font-bold text-slate-900 flex items-center gap-2">
                            <span class="text-rose-500">🔥</span> Featured Books
                        </h2>
                        <p class="text-xs text-slate-400 font-medium">Most popular and critically acclaimed books today</p>
                    </div>
                    <div class="flex items-center gap-3">
                        <a href="${pageContext.request.contextPath}/books?filter=featured" class="text-xs font-bold text-blue-600 hover:underline">View all &rarr;</a>
                        <div class="hidden sm:flex items-center gap-1.5">
                            <button type="button" class="w-7 h-7 rounded-full border border-slate-200 hover:bg-slate-50 flex items-center justify-center text-slate-500 transition">
                                <svg class="w-3.5 h-3.5" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M15 19l-7-7 7-7"/></svg>
                            </button>
                            <button type="button" class="w-7 h-7 rounded-full border border-slate-200 hover:bg-slate-50 flex items-center justify-center text-slate-500 transition">
                                <svg class="w-3.5 h-3.5" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 5l7 7-7 7"/></svg>
                            </button>
                        </div>
                    </div>
                </div>

                <!-- Featured 6 Books Grid -->
                <div class="grid grid-cols-2 sm:grid-cols-3 xl:grid-cols-6 gap-3.5">
                    
                    <!-- Book 1: Atomic Habits -->
                    <div class="book-card border border-slate-100 rounded-2xl p-2.5 flex flex-col justify-between bg-white relative">
                        <span class="absolute top-2 right-2 bg-red-500 text-white text-[9px] font-extrabold px-1.5 py-0.5 rounded-full z-10">-20%</span>
                        <div class="w-full h-40 rounded-xl bg-[#faf6ee] border border-amber-100 flex flex-col items-center justify-center p-2 text-center mb-2 shadow-sm">
                            <span class="text-[7px] font-bold tracking-widest text-amber-700 uppercase">Tiny Changes, Remarkable Results</span>
                            <span class="text-xs font-black text-slate-900 my-1 leading-tight">Atomic<br>Habits</span>
                            <span class="text-[8px] text-slate-500">James Clear</span>
                        </div>
                        <div class="space-y-1">
                            <h3 class="text-xs font-bold text-slate-800 truncate" title="Atomic Habits">Atomic Habits</h3>
                            <p class="text-[10px] text-slate-400 truncate">James Clear</p>
                            <div class="flex items-center gap-1 text-[10px]">
                                <span class="text-amber-400 font-bold">★ 4.8</span>
                                <span class="text-slate-400 text-[9px]">(12.4k)</span>
                            </div>
                            <div class="flex items-baseline gap-1.5 pt-0.5">
                                <span class="text-xs font-bold text-blue-600">$12.99</span>
                                <span class="text-[10px] text-slate-400 line-through">$16.24</span>
                            </div>
                        </div>
                        <button type="button" class="mt-2.5 w-full bg-blue-600 hover:bg-blue-700 text-white text-[10px] font-bold py-1.5 rounded-xl transition flex items-center justify-center gap-1">
                            <span>🛒 Add to Cart</span>
                        </button>
                    </div>

                    <!-- Book 2: Dune -->
                    <div class="book-card border border-slate-100 rounded-2xl p-2.5 flex flex-col justify-between bg-white relative">
                        <span class="absolute top-2 right-2 bg-red-500 text-white text-[9px] font-extrabold px-1.5 py-0.5 rounded-full z-10">-15%</span>
                        <div class="w-full h-40 rounded-xl bg-gradient-to-b from-orange-400 to-amber-700 border border-orange-200 flex flex-col items-center justify-center p-2 text-center mb-2 text-white shadow-sm">
                            <span class="text-[7px] tracking-widest uppercase text-orange-200">The Sci-Fi Classic</span>
                            <span class="text-sm font-black tracking-widest my-1">DUNE</span>
                            <span class="text-[8px] text-orange-100">Frank Herbert</span>
                        </div>
                        <div class="space-y-1">
                            <h3 class="text-xs font-bold text-slate-800 truncate" title="Dune">Dune</h3>
                            <p class="text-[10px] text-slate-400 truncate">Frank Herbert</p>
                            <div class="flex items-center gap-1 text-[10px]">
                                <span class="text-amber-400 font-bold">★ 4.7</span>
                                <span class="text-slate-400 text-[9px]">(10.7k)</span>
                            </div>
                            <div class="flex items-baseline gap-1.5 pt-0.5">
                                <span class="text-xs font-bold text-blue-600">$14.99</span>
                                <span class="text-[10px] text-slate-400 line-through">$17.64</span>
                            </div>
                        </div>
                        <button type="button" class="mt-2.5 w-full bg-blue-600 hover:bg-blue-700 text-white text-[10px] font-bold py-1.5 rounded-xl transition flex items-center justify-center gap-1">
                            <span>🛒 Add to Cart</span>
                        </button>
                    </div>

                    <!-- Book 3: The Midnight Library -->
                    <div class="book-card border border-slate-100 rounded-2xl p-2.5 flex flex-col justify-between bg-white relative">
                        <span class="absolute top-2 right-2 bg-red-500 text-white text-[9px] font-extrabold px-1.5 py-0.5 rounded-full z-10">-25%</span>
                        <div class="w-full h-40 rounded-xl bg-gradient-to-b from-indigo-900 to-slate-900 border border-indigo-800 flex flex-col items-center justify-center p-2 text-center mb-2 text-white shadow-sm">
                            <span class="text-[7px] tracking-widest uppercase text-indigo-300">Bestselling Novel</span>
                            <span class="text-[10px] font-black tracking-wide my-1 leading-tight">THE MIDNIGHT<br>LIBRARY</span>
                            <span class="text-[8px] text-indigo-300">Matt Haig</span>
                        </div>
                        <div class="space-y-1">
                            <h3 class="text-xs font-bold text-slate-800 truncate" title="The Midnight Library">The Midnight Library</h3>
                            <p class="text-[10px] text-slate-400 truncate">Matt Haig</p>
                            <div class="flex items-center gap-1 text-[10px]">
                                <span class="text-amber-400 font-bold">★ 4.6</span>
                                <span class="text-slate-400 text-[9px]">(15.2k)</span>
                            </div>
                            <div class="flex items-baseline gap-1.5 pt-0.5">
                                <span class="text-xs font-bold text-blue-600">$13.99</span>
                                <span class="text-[10px] text-slate-400 line-through">$18.67</span>
                            </div>
                        </div>
                        <button type="button" class="mt-2.5 w-full bg-blue-600 hover:bg-blue-700 text-white text-[10px] font-bold py-1.5 rounded-xl transition flex items-center justify-center gap-1">
                            <span>🛒 Add to Cart</span>
                        </button>
                    </div>

                    <!-- Book 4: Clean Code -->
                    <div class="book-card border border-slate-100 rounded-2xl p-2.5 flex flex-col justify-between bg-white relative">
                        <span class="absolute top-2 right-2 bg-red-500 text-white text-[9px] font-extrabold px-1.5 py-0.5 rounded-full z-10">-18%</span>
                        <div class="w-full h-40 rounded-xl bg-slate-950 border border-slate-700 flex flex-col items-center justify-center p-2 text-center mb-2 text-cyan-300 shadow-sm">
                            <span class="text-[7px] tracking-widest uppercase text-slate-400">Software Craft</span>
                            <span class="text-[11px] font-black tracking-wide my-1 text-white">Clean Code</span>
                            <span class="text-[8px] text-cyan-400">Robert C. Martin</span>
                        </div>
                        <div class="space-y-1">
                            <h3 class="text-xs font-bold text-slate-800 truncate" title="Clean Code">Clean Code</h3>
                            <p class="text-[10px] text-slate-400 truncate">Robert C. Martin</p>
                            <div class="flex items-center gap-1 text-[10px]">
                                <span class="text-amber-400 font-bold">★ 4.5</span>
                                <span class="text-slate-400 text-[9px]">(6.1k)</span>
                            </div>
                            <div class="flex items-baseline gap-1.5 pt-0.5">
                                <span class="text-xs font-bold text-blue-600">$39.99</span>
                                <span class="text-[10px] text-slate-400 line-through">$48.79</span>
                            </div>
                        </div>
                        <button type="button" class="mt-2.5 w-full bg-blue-600 hover:bg-blue-700 text-white text-[10px] font-bold py-1.5 rounded-xl transition flex items-center justify-center gap-1">
                            <span>🛒 Add to Cart</span>
                        </button>
                    </div>

                    <!-- Book 5: The Psychology of Money -->
                    <div class="book-card border border-slate-100 rounded-2xl p-2.5 flex flex-col justify-between bg-white relative">
                        <span class="absolute top-2 right-2 bg-red-500 text-white text-[9px] font-extrabold px-1.5 py-0.5 rounded-full z-10">-22%</span>
                        <div class="w-full h-40 rounded-xl bg-[#faf5ea] border border-amber-200 flex flex-col items-center justify-center p-2 text-center mb-2 text-slate-800 shadow-sm">
                            <span class="text-[7px] tracking-widest uppercase text-slate-400">Timeless Lessons</span>
                            <span class="text-[10px] font-black my-1 leading-tight">The Psychology<br>of Money</span>
                            <span class="text-[8px] text-amber-800">Morgan Housel</span>
                        </div>
                        <div class="space-y-1">
                            <h3 class="text-xs font-bold text-slate-800 truncate" title="The Psychology of Money">The Psychology of Money</h3>
                            <p class="text-[10px] text-slate-400 truncate">Morgan Housel</p>
                            <div class="flex items-center gap-1 text-[10px]">
                                <span class="text-amber-400 font-bold">★ 4.7</span>
                                <span class="text-slate-400 text-[9px]">(9.8k)</span>
                            </div>
                            <div class="flex items-baseline gap-1.5 pt-0.5">
                                <span class="text-xs font-bold text-blue-600">$11.99</span>
                                <span class="text-[10px] text-slate-400 line-through">$15.38</span>
                            </div>
                        </div>
                        <button type="button" class="mt-2.5 w-full bg-blue-600 hover:bg-blue-700 text-white text-[10px] font-bold py-1.5 rounded-xl transition flex items-center justify-center gap-1">
                            <span>🛒 Add to Cart</span>
                        </button>
                    </div>

                    <!-- Book 6: Dopamine Nation -->
                    <div class="book-card border border-slate-100 rounded-2xl p-2.5 flex flex-col justify-between bg-white relative">
                        <span class="absolute top-2 right-2 bg-red-500 text-white text-[9px] font-extrabold px-1.5 py-0.5 rounded-full z-10">-16%</span>
                        <div class="w-full h-40 rounded-xl bg-[#fff2ed] border border-rose-200 flex flex-col items-center justify-center p-2 text-center mb-2 text-rose-900 shadow-sm">
                            <span class="text-[7px] tracking-widest uppercase text-rose-400">Finding Balance</span>
                            <span class="text-[11px] font-black my-1 text-rose-600">DOPAMINE<br>NATION</span>
                            <span class="text-[8px] text-rose-500">Anna Lembke</span>
                        </div>
                        <div class="space-y-1">
                            <h3 class="text-xs font-bold text-slate-800 truncate" title="Dopamine Nation">Dopamine Nation</h3>
                            <p class="text-[10px] text-slate-400 truncate">Anna Lembke</p>
                            <div class="flex items-center gap-1 text-[10px]">
                                <span class="text-amber-400 font-bold">★ 4.6</span>
                                <span class="text-slate-400 text-[9px]">(8.5k)</span>
                            </div>
                            <div class="flex items-baseline gap-1.5 pt-0.5">
                                <span class="text-xs font-bold text-blue-600">$11.99</span>
                                <span class="text-[10px] text-slate-400 line-through">$14.28</span>
                            </div>
                        </div>
                        <button type="button" class="mt-2.5 w-full bg-blue-600 hover:bg-blue-700 text-white text-[10px] font-bold py-1.5 rounded-xl transition flex items-center justify-center gap-1">
                            <span>🛒 Add to Cart</span>
                        </button>
                    </div>

                </div>
            </section>

            <!-- SECTION 2: NEW ARRIVALS (5 BOOKS HORIZONTAL CARDS) -->
            <section class="bg-white rounded-3xl p-6 border border-slate-200/80 shadow-sm">
                <div class="flex items-center justify-between mb-5">
                    <div class="flex items-center gap-2.5">
                        <span class="bg-sky-500 text-white text-[10px] font-black px-2 py-0.5 rounded-md shadow-sm uppercase tracking-wide">
                            New
                        </span>
                        <div>
                            <h2 class="text-base sm:text-lg font-bold text-slate-900 leading-none">New Arrivals</h2>
                            <p class="text-xs text-slate-400 font-medium mt-0.5">Fresh books, fresh perspectives</p>
                        </div>
                    </div>
                    <a href="${pageContext.request.contextPath}/books?filter=new" class="text-xs font-bold text-blue-600 hover:underline">View all &rarr;</a>
                </div>

                <!-- 5 New Arrivals Cards -->
                <div class="grid grid-cols-1 sm:grid-cols-2 md:grid-cols-3 xl:grid-cols-5 gap-3.5">
                    
                    <!-- Item 1: The Let Them Theory -->
                    <div class="book-card border border-slate-100 rounded-2xl p-2.5 bg-white shadow-sm hover:border-blue-200 flex items-center gap-3 transition">
                        <div class="relative w-14 h-20 rounded-lg bg-emerald-700 flex flex-col items-center justify-center p-1 text-center text-white flex-shrink-0 shadow-sm overflow-visible">
                            <span class="absolute -top-1.5 -left-1.5 bg-amber-400 text-slate-900 text-[8px] font-black px-1.5 py-0.5 rounded shadow">New</span>
                            <span class="text-[8px] font-black uppercase leading-tight">LET<br>THEM</span>
                            <span class="text-[6px] text-emerald-200 mt-1">THEORY</span>
                        </div>
                        <div class="flex-1 min-w-0 flex flex-col justify-between py-0.5">
                            <div>
                                <h4 class="text-xs font-bold text-slate-800 truncate" title="The Let Them Theory">The Let Them Theory</h4>
                                <p class="text-[10px] text-slate-400 truncate">Mel Robbins</p>
                                <div class="flex items-center gap-1 text-[10px] text-amber-400 font-bold mt-0.5">
                                    ★ 4.5 <span class="text-slate-400 text-[9px] font-normal">(5.2k)</span>
                                </div>
                            </div>
                            <div class="flex items-center justify-between pt-1">
                                <span class="text-xs font-bold text-blue-600">$12.99</span>
                                <button type="button" class="w-6 h-6 rounded-lg bg-blue-50 text-blue-600 hover:bg-blue-600 hover:text-white flex items-center justify-center text-[11px] transition shadow-xs">
                                    🛒
                                </button>
                            </div>
                        </div>
                    </div>

                    <!-- Item 2: Fourth Wing -->
                    <div class="book-card border border-slate-100 rounded-2xl p-2.5 bg-white shadow-sm hover:border-blue-200 flex items-center gap-3 transition">
                        <div class="relative w-14 h-20 rounded-lg bg-[#3d2314] flex flex-col items-center justify-center p-1 text-center text-amber-200 flex-shrink-0 shadow-sm overflow-visible">
                            <span class="absolute -top-1.5 -left-1.5 bg-amber-400 text-slate-900 text-[8px] font-black px-1.5 py-0.5 rounded shadow">New</span>
                            <span class="text-[8px] font-black uppercase tracking-wide leading-tight">FOURTH<br>WING</span>
                            <span class="text-[6px] text-amber-400 mt-0.5">⚔️</span>
                        </div>
                        <div class="flex-1 min-w-0 flex flex-col justify-between py-0.5">
                            <div>
                                <h4 class="text-xs font-bold text-slate-800 truncate" title="Fourth Wing">Fourth Wing</h4>
                                <p class="text-[10px] text-slate-400 truncate">Rebecca Yarros</p>
                                <div class="flex items-center gap-1 text-[10px] text-amber-400 font-bold mt-0.5">
                                    ★ 4.8 <span class="text-slate-400 text-[9px] font-normal">(8.6k)</span>
                                </div>
                            </div>
                            <div class="flex items-center justify-between pt-1">
                                <span class="text-xs font-bold text-blue-600">$14.99</span>
                                <button type="button" class="w-6 h-6 rounded-lg bg-blue-50 text-blue-600 hover:bg-blue-600 hover:text-white flex items-center justify-center text-[11px] transition shadow-xs">
                                    🛒
                                </button>
                            </div>
                        </div>
                    </div>

                    <!-- Item 3: Atomic Love -->
                    <div class="book-card border border-slate-100 rounded-2xl p-2.5 bg-white shadow-sm hover:border-blue-200 flex items-center gap-3 transition">
                        <div class="relative w-14 h-20 rounded-lg bg-red-800 flex flex-col items-center justify-center p-1 text-center text-white flex-shrink-0 shadow-sm overflow-visible">
                            <span class="absolute -top-1.5 -left-1.5 bg-amber-400 text-slate-900 text-[8px] font-black px-1.5 py-0.5 rounded shadow">New</span>
                            <span class="text-[8px] font-black uppercase leading-tight">ATOMIC<br>LOVE</span>
                            <span class="text-[6px] text-rose-300 mt-0.5">❤️</span>
                        </div>
                        <div class="flex-1 min-w-0 flex flex-col justify-between py-0.5">
                            <div>
                                <h4 class="text-xs font-bold text-slate-800 truncate" title="Atomic Love">Atomic Love</h4>
                                <p class="text-[10px] text-slate-400 truncate">Jennifer L. Armentrout</p>
                                <div class="flex items-center gap-1 text-[10px] text-amber-400 font-bold mt-0.5">
                                    ★ 4.7 <span class="text-slate-400 text-[9px] font-normal">(3.1k)</span>
                                </div>
                            </div>
                            <div class="flex items-center justify-between pt-1">
                                <span class="text-xs font-bold text-blue-600">$11.99</span>
                                <button type="button" class="w-6 h-6 rounded-lg bg-blue-50 text-blue-600 hover:bg-blue-600 hover:text-white flex items-center justify-center text-[11px] transition shadow-xs">
                                    🛒
                                </button>
                            </div>
                        </div>
                    </div>

                    <!-- Item 4: The 7 Habits -->
                    <div class="book-card border border-slate-100 rounded-2xl p-2.5 bg-white shadow-sm hover:border-blue-200 flex items-center gap-3 transition">
                        <div class="relative w-14 h-20 rounded-lg bg-blue-950 flex flex-col items-center justify-center p-1 text-center text-white flex-shrink-0 shadow-sm overflow-visible">
                            <span class="absolute -top-1.5 -left-1.5 bg-amber-400 text-slate-900 text-[8px] font-black px-1.5 py-0.5 rounded shadow">New</span>
                            <span class="text-[8px] font-black uppercase leading-tight">THE 7<br>HABITS</span>
                            <span class="text-[6px] text-blue-300 mt-0.5">★ ★ ★</span>
                        </div>
                        <div class="flex-1 min-w-0 flex flex-col justify-between py-0.5">
                            <div>
                                <h4 class="text-xs font-bold text-slate-800 truncate" title="The 7 Habits">The 7 Habits</h4>
                                <p class="text-[10px] text-slate-400 truncate">Stephen R. Covey</p>
                                <div class="flex items-center gap-1 text-[10px] text-amber-400 font-bold mt-0.5">
                                    ★ 4.6 <span class="text-slate-400 text-[9px] font-normal">(5.4k)</span>
                                </div>
                            </div>
                            <div class="flex items-center justify-between pt-1">
                                <span class="text-xs font-bold text-blue-600">$13.99</span>
                                <button type="button" class="w-6 h-6 rounded-lg bg-blue-50 text-blue-600 hover:bg-blue-600 hover:text-white flex items-center justify-center text-[11px] transition shadow-xs">
                                    🛒
                                </button>
                            </div>
                        </div>
                    </div>

                    <!-- Item 5: Demon Copperhead -->
                    <div class="book-card border border-slate-100 rounded-2xl p-2.5 bg-white shadow-sm hover:border-blue-200 flex items-center gap-3 transition">
                        <div class="relative w-14 h-20 rounded-lg bg-gradient-to-br from-amber-700 to-rose-900 flex flex-col items-center justify-center p-1 text-center text-white flex-shrink-0 shadow-sm overflow-visible">
                            <span class="absolute -top-1.5 -left-1.5 bg-amber-400 text-slate-900 text-[8px] font-black px-1.5 py-0.5 rounded shadow">New</span>
                            <span class="text-[7px] font-black uppercase leading-tight">DEMON<br>COPPERHEAD</span>
                        </div>
                        <div class="flex-1 min-w-0 flex flex-col justify-between py-0.5">
                            <div>
                                <h4 class="text-xs font-bold text-slate-800 truncate" title="Demon Copperhead">Demon Copperhead</h4>
                                <p class="text-[10px] text-slate-400 truncate">Barbara Kingsolver</p>
                                <div class="flex items-center gap-1 text-[10px] text-amber-400 font-bold mt-0.5">
                                    ★ 4.7 <span class="text-slate-400 text-[9px] font-normal">(6.1k)</span>
                                </div>
                            </div>
                            <div class="flex items-center justify-between pt-1">
                                <span class="text-xs font-bold text-blue-600">$12.99</span>
                                <button type="button" class="w-6 h-6 rounded-lg bg-blue-50 text-blue-600 hover:bg-blue-600 hover:text-white flex items-center justify-center text-[11px] transition shadow-xs">
                                    🛒
                                </button>
                            </div>
                        </div>
                    </div>

                </div>
            </section>

            <!-- SECTION 3: NEWSLETTER SUBSCRIPTION -->
            <section class="rounded-3xl p-6 sm:p-7 bg-gradient-to-r from-[#0c1829] via-[#142643] to-[#1c365d] text-white shadow-lg flex flex-col md:flex-row items-center justify-between gap-5 relative overflow-hidden">
                <div class="absolute top-2 left-6 text-amber-300 text-xs opacity-60">✨</div>
                <div class="absolute bottom-3 left-1/3 text-cyan-300 text-sm opacity-60">★</div>

                <div class="flex items-center gap-3 z-10">
                    <div class="w-10 h-10 rounded-2xl bg-white/10 text-xl flex items-center justify-center flex-shrink-0">
                        📬
                    </div>
                    <div>
                        <h3 class="text-sm sm:text-base font-extrabold text-white">Subscribe to Newsletter</h3>
                        <p class="text-[11px] text-blue-200">Get an exclusive <strong class="text-amber-400">10% OFF</strong> your first order!</p>
                    </div>
                </div>

                <form action="#" method="POST" class="flex items-center w-full md:w-auto max-w-sm rounded-full bg-white p-1 shadow-inner z-10 mb-0">
                    <input type="email" placeholder="Enter your email address" class="w-full text-slate-800 text-xs px-3.5 py-1.5 focus:outline-none bg-transparent">
                    <button type="submit" class="bg-[#facc15] hover:bg-yellow-400 text-slate-900 font-extrabold text-xs px-5 py-2 rounded-full transition shadow-sm flex-shrink-0">
                        Subscribe
                    </button>
                </form>

                <div class="z-10 text-center md:text-right flex-shrink-0 hidden lg:block">
                    <span class="font-handwriting text-xl text-amber-300 flex items-center gap-1.5">
                        Spreading the love for reading together! 🚀
                    </span>
                </div>
            </section>

        </div>

        <!-- ============================================== -->
        <!-- RIGHT COLUMN: PROMOTIONS & SERVICE COMMITS     -->
        <!-- ============================================== -->
        <div class="lg:col-span-4 xl:col-span-3 space-y-6">
            
            <!-- CARD 1: SPECIAL OFFER -->
            <div class="rounded-3xl p-6 bg-gradient-to-br from-blue-700 to-blue-500 text-white shadow-lg relative overflow-hidden flex items-center justify-between">
                <div class="space-y-2 z-10 max-w-[170px]">
                    <span class="bg-blue-400/40 text-blue-100 font-bold text-[9px] px-2.5 py-0.5 rounded-full uppercase tracking-wider">
                        SPECIAL OFFER
                    </span>
                    <h3 class="text-xl font-black leading-tight">Up to 50% OFF</h3>
                    <p class="text-[11px] text-blue-100 leading-snug">On academic textbooks & learning materials</p>
                    <div class="pt-1">
                        <a href="${pageContext.request.contextPath}/books?discount=50" class="inline-block bg-[#facc15] hover:bg-yellow-400 text-slate-900 font-black text-xs px-4 py-1.5 rounded-full transition shadow-sm">
                            Shop Now &rarr;
                        </a>
                    </div>
                </div>
                <div class="text-6xl select-none z-10 transform -rotate-6">
                    🎒
                </div>
            </div>

            <!-- CARD 2: EXCLUSIVE GIFTS -->
            <div class="rounded-3xl p-6 bg-gradient-to-br from-rose-500 to-pink-500 text-white shadow-lg flex items-center justify-between relative overflow-hidden">
                <div class="space-y-1.5 z-10">
                    <h3 class="text-lg font-black leading-tight">Exclusive Gifts</h3>
                    <p class="text-[11px] text-rose-100">For orders over $25.00</p>
                    <div class="pt-2">
                        <a href="${pageContext.request.contextPath}/promotions" class="inline-block bg-white hover:bg-pink-50 text-rose-600 font-extrabold text-[11px] px-4 py-1.5 rounded-full transition shadow-sm">
                            Learn more &rarr;
                        </a>
                    </div>
                </div>
                <div class="text-5xl select-none z-10 animate-bounce" style="animation-duration: 3s;">
                    🎁
                </div>
            </div>

            <!-- CARD 3: WHY CHOOSE BOOKSTORE? -->
            <div class="bg-white rounded-3xl p-6 border border-slate-200/80 shadow-sm space-y-4">
                <h3 class="text-sm font-bold text-slate-900 border-b border-slate-100 pb-3 flex items-center gap-2">
                    <span class="text-blue-600">🛡️</span> Why Choose BookStore?
                </h3>

                <div class="space-y-3.5 text-xs">
                    <div class="flex items-start gap-3">
                        <div class="w-8 h-8 rounded-full bg-blue-50 text-blue-600 flex items-center justify-center flex-shrink-0 text-sm">
                            🛡️
                        </div>
                        <div>
                            <h4 class="font-bold text-slate-800">Authentic Books</h4>
                            <p class="text-[11px] text-slate-400">100% authentic editions guaranteed</p>
                        </div>
                    </div>

                    <div class="flex items-start gap-3">
                        <div class="w-8 h-8 rounded-full bg-emerald-50 text-emerald-600 flex items-center justify-center flex-shrink-0 text-sm">
                            🚚
                        </div>
                        <div>
                            <h4 class="font-bold text-slate-800">Fast Delivery</h4>
                            <p class="text-[11px] text-slate-400">Nationwide, within 2-5 business days</p>
                        </div>
                    </div>

                    <div class="flex items-start gap-3">
                        <div class="w-8 h-8 rounded-full bg-amber-50 text-amber-600 flex items-center justify-center flex-shrink-0 text-sm">
                            💳
                        </div>
                        <div>
                            <h4 class="font-bold text-slate-800">Secure Payment</h4>
                            <p class="text-[11px] text-slate-400">Encrypted & verified transactions</p>
                        </div>
                    </div>

                    <div class="flex items-start gap-3">
                        <div class="w-8 h-8 rounded-full bg-purple-50 text-purple-600 flex items-center justify-center flex-shrink-0 text-sm">
                            🎧
                        </div>
                        <div>
                            <h4 class="font-bold text-slate-800">24/7 Support</h4>
                            <p class="text-[11px] text-slate-400">Dedicated customer assistance anytime</p>
                        </div>
                    </div>
                </div>

                <div class="pt-4 border-t border-slate-100 flex items-center justify-between">
                    <div class="flex items-center gap-2">
                        <div class="text-3xl">📚</div>
                        <div class="text-2xl">🪴</div>
                    </div>
                    <div class="bg-blue-50 px-3 py-1.5 rounded-xl border border-blue-100 text-[10px] font-bold text-blue-700 flex items-center gap-1">
                        <span>Good Books, Better You ❤️</span>
                    </div>
                </div>

            </div>

        </div>

    </div>

</main>

<!-- Include Common Modular Footer -->
<jsp:include page="/views/common/footer.jsp" />
