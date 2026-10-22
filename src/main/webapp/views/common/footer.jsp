<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>

    <!-- FOOTER -->
    <footer class="mt-16 bg-white border-t border-slate-200/80 pt-12 pb-8 text-xs text-slate-500">
        <div class="max-w-[1440px] mx-auto px-4 sm:px-8">
            
            <div class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-5 gap-8 mb-10">
                
                <!-- Col 1: Brand Info -->
                <div class="lg:col-span-2 space-y-3">
                    <div class="flex items-center gap-2.5">
                        <div class="w-8 h-8 rounded-lg bg-blue-600 text-white flex items-center justify-center font-bold text-sm">
                            📚
                        </div>
                        <span class="text-lg font-extrabold text-blue-600">Book<span class="text-slate-800">Store</span></span>
                    </div>
                    <p class="text-slate-400 text-xs leading-relaxed max-w-sm">
                        Read More • Grow More. Nền tảng mua sắm sách trực tuyến hàng đầu, kết nối hàng triệu độc giả với tri thức nhân loại.
                    </p>
                    <div class="pt-2 text-[11px] text-slate-400">
                        <strong>Dự án:</strong> SWD392 - Nhóm PS06 | Kiến trúc 3-Tier Layered
                    </div>
                </div>

                <!-- Col 2: Về BookStore -->
                <div class="space-y-2.5">
                    <h4 class="font-bold text-slate-800 text-xs uppercase tracking-wider">Về BookStore</h4>
                    <ul class="space-y-2">
                        <li><a href="${pageContext.request.contextPath}/about" class="hover:text-blue-600 transition">Giới thiệu</a></li>
                        <li><a href="#" class="hover:text-blue-600 transition">Tuyển dụng</a></li>
                        <li><a href="#" class="hover:text-blue-600 transition">Liên hệ</a></li>
                    </ul>
                </div>

                <!-- Col 3: Chính sách -->
                <div class="space-y-2.5">
                    <h4 class="font-bold text-slate-800 text-xs uppercase tracking-wider">Chính sách</h4>
                    <ul class="space-y-2">
                        <li><a href="#" class="hover:text-blue-600 transition">Chính sách bảo mật</a></li>
                        <li><a href="#" class="hover:text-blue-600 transition">Chính sách đổi trả</a></li>
                        <li><a href="#" class="hover:text-blue-600 transition">Điều khoản sử dụng</a></li>
                    </ul>
                </div>

                <!-- Col 4: Hỗ trợ & Mạng xã hội -->
                <div class="space-y-3">
                    <h4 class="font-bold text-slate-800 text-xs uppercase tracking-wider">Hỗ trợ</h4>
                    <ul class="space-y-2">
                        <li><a href="#" class="hover:text-blue-600 transition">Trung tâm trợ giúp</a></li>
                        <li><a href="#" class="hover:text-blue-600 transition">Hướng dẫn mua hàng</a></li>
                        <li><a href="#" class="hover:text-blue-600 transition">Câu hỏi thường gặp</a></li>
                    </ul>

                    <div class="pt-2 space-y-1.5">
                        <span class="block text-[11px] font-semibold text-slate-700">Kết nối với chúng tôi</span>
                        <div class="flex items-center gap-2.5 text-base">
                            <a href="#" class="w-7 h-7 rounded-full bg-slate-100 hover:bg-blue-50 text-slate-600 hover:text-blue-600 flex items-center justify-center transition">📘</a>
                            <a href="#" class="w-7 h-7 rounded-full bg-slate-100 hover:bg-rose-50 text-slate-600 hover:text-rose-600 flex items-center justify-center transition">📸</a>
                            <a href="#" class="w-7 h-7 rounded-full bg-slate-100 hover:bg-red-50 text-slate-600 hover:text-red-600 flex items-center justify-center transition">▶️</a>
                            <a href="#" class="w-7 h-7 rounded-full bg-slate-100 hover:bg-slate-200 text-slate-600 flex items-center justify-center transition">🎵</a>
                        </div>
                    </div>
                </div>

            </div>

            <!-- Copyright -->
            <div class="border-t border-slate-100 pt-6 flex flex-col sm:flex-row items-center justify-between gap-3 text-[11px] text-slate-400">
                <span>© 2026 BookStore. All rights reserved.</span>
                <div class="flex items-center gap-4">
                    <a href="#" class="hover:underline">Privacy Policy</a>
                    <span>•</span>
                    <a href="#" class="hover:underline">Terms of Service</a>
                    <span>•</span>
                    <a href="#" class="hover:underline">Sitemap</a>
                </div>
            </div>

        </div>
    </footer>

    <!-- FLOATING CHAT WIDGET BUTTON -->
    <div class="fixed bottom-6 right-6 z-50">
        <button class="w-12 h-12 rounded-full bg-blue-600 hover:bg-blue-700 text-white shadow-xl shadow-blue-500/30 flex items-center justify-center text-xl hover:scale-110 transition-all">
            💬
        </button>
    </div>

</body>
</html>
