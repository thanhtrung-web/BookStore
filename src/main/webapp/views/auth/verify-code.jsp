<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>${pageTitle != null ? pageTitle : 'Xác thực tài khoản Email - BookStore'}</title>
    
    <!-- Tailwind CSS CDN -->
    <script src="https://cdn.tailwindcss.com"></script>
    
    <!-- Google Fonts -->
    <link rel="preconnect" href="https://fonts.googleapis.com">
    <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
    <link href="https://fonts.googleapis.com/css2?family=Plus+Jakarta+Sans:wght@400;500;600;700;800;900&display=swap" rel="stylesheet">
    
    <style>
        body {
            font-family: 'Plus Jakarta Sans', system-ui, -apple-system, sans-serif;
            background-color: #f3f8fc;
            background-image: 
                radial-gradient(at 0% 0%, rgba(224, 242, 254, 0.7) 0px, transparent 50%),
                radial-gradient(at 100% 100%, rgba(224, 242, 254, 0.7) 0px, transparent 50%);
        }
        .otp-input:focus {
            border-color: #2563eb;
            box-shadow: 0 0 0 4px rgba(37, 99, 235, 0.15);
            transform: scale(1.05);
        }
        .leaf-deco {
            pointer-events: none;
            position: absolute;
            opacity: 0.75;
            z-index: 0;
        }
    </style>
</head>
<body class="text-slate-800 antialiased min-h-screen flex flex-col justify-between relative overflow-x-hidden p-4 sm:p-6">

    <!-- CORNER LEAVES DECORATION -->
    <div class="leaf-deco top-0 left-0 w-44 h-80 opacity-50 md:opacity-75">
        <svg viewBox="0 0 200 400" fill="none" xmlns="http://www.w3.org/2000/svg">
            <path d="M-20 40C30 80 80 60 70 120C60 180 -10 190 20 260C50 330 110 320 120 400" stroke="#86efac" stroke-width="2.5" stroke-linecap="round"/>
            <ellipse cx="60" cy="70" rx="25" ry="14" transform="rotate(-30 60 70)" fill="#4ade80" fill-opacity="0.45"/>
            <ellipse cx="35" cy="130" rx="30" ry="16" transform="rotate(25 35 130)" fill="#22c55e" fill-opacity="0.35"/>
            <ellipse cx="65" cy="190" rx="28" ry="15" transform="rotate(-40 65 190)" fill="#86efac" fill-opacity="0.55"/>
        </svg>
    </div>

    <div class="leaf-deco bottom-0 right-0 w-48 h-80 opacity-50 md:opacity-75">
        <svg viewBox="0 0 200 400" fill="none" xmlns="http://www.w3.org/2000/svg">
            <path d="M220 50C170 90 120 70 130 130C140 190 210 200 180 270C150 340 90 330 80 410" stroke="#86efac" stroke-width="2.5" stroke-linecap="round"/>
            <ellipse cx="140" cy="80" rx="25" ry="14" transform="rotate(30 140 80)" fill="#4ade80" fill-opacity="0.4"/>
            <ellipse cx="165" cy="140" rx="30" ry="16" transform="rotate(-25 165 140)" fill="#22c55e" fill-opacity="0.3"/>
        </svg>
    </div>

    <!-- TOP BAR -->
    <header class="max-w-4xl mx-auto w-full flex items-center justify-between py-2 relative z-10">
        <a href="${pageContext.request.contextPath}/home" class="flex items-center gap-2.5 group">
            <div class="w-10 h-10 rounded-xl bg-gradient-to-tr from-blue-700 to-blue-500 text-white flex items-center justify-center shadow-md shadow-blue-500/20 group-hover:scale-105 transition-transform">
                <svg class="w-6 h-6" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.2" stroke-linecap="round" stroke-linejoin="round">
                    <path d="M2 3h6a4 4 0 0 1 4 4v14a3 3 0 0 0-3-3H2z"></path>
                    <path d="M22 3h-6a4 4 0 0 0-4 4v14a3 3 0 0 1 3-3h7z"></path>
                </svg>
            </div>
            <div class="flex flex-col">
                <span class="text-xl font-extrabold tracking-tight text-blue-600 leading-none">Book<span class="text-blue-950">Store</span></span>
                <span class="text-[10px] font-semibold text-slate-400 tracking-wider mt-0.5">Read More • Grow More</span>
            </div>
        </a>

        <a href="${pageContext.request.contextPath}/login" class="text-xs font-bold text-slate-500 hover:text-blue-600 flex items-center gap-1.5 transition">
            <svg class="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M10 19l-7-7m0 0l7-7m-7 7h18"/></svg>
            <span>Quay lại Đăng nhập</span>
        </a>
    </header>

    <!-- MAIN FORM CONTAINER -->
    <main class="flex-1 flex items-center justify-center py-8 relative z-10">
        <div class="w-full max-w-lg bg-white rounded-3xl shadow-[0_20px_50px_-12px_rgba(15,23,42,0.08)] border border-slate-200/80 p-7 sm:p-10 text-center relative overflow-hidden">
            
            <!-- Top Gradient Accent Strip -->
            <div class="absolute top-0 left-0 right-0 h-1.5 bg-gradient-to-r from-blue-600 via-sky-500 to-amber-400"></div>

            <!-- Email Icon -->
            <div class="w-16 h-16 rounded-2xl bg-blue-50 border border-blue-100 text-blue-600 flex items-center justify-center text-3xl mx-auto mb-5 shadow-inner">
                ✉️
            </div>

            <!-- Heading -->
            <h1 class="text-2xl font-black text-slate-900 tracking-tight mb-2">
                Xác thực tài khoản Email
            </h1>

            <p class="text-xs sm:text-sm text-slate-500 leading-relaxed max-w-sm mx-auto mb-6">
                Chúng tôi đã gửi mã xác thực kích hoạt tài khoản đến địa chỉ: <br>
                <strong class="text-blue-600 font-bold text-sm">
                    <c:choose>
                        <c:when test="${not empty registeredEmail}"><c:out value="${registeredEmail}"/></c:when>
                        <c:when test="${not empty param.email}"><c:out value="${param.email}"/></c:when>
                        <c:otherwise>email của bạn</c:otherwise>
                    </c:choose>
                </strong>
            </p>

            <!-- Error Banner -->
            <c:if test="${not empty errorMessage}">
                <div class="mb-5 p-3 rounded-xl text-xs font-semibold text-left flex items-center justify-between bg-red-50 text-red-700 border border-red-200">
                    <div class="flex items-center gap-2">
                        <span>⚠️</span>
                        <span><c:out value="${errorMessage}"/></span>
                    </div>
                </div>
            </c:if>

            <!-- Success Banner -->
            <c:if test="${not empty successMessage}">
                <div class="mb-5 p-3 rounded-xl text-xs font-semibold text-left flex items-center justify-between bg-emerald-50 text-emerald-700 border border-emerald-200">
                    <div class="flex items-center gap-2">
                        <span>✅</span>
                        <span><c:out value="${successMessage}"/></span>
                    </div>
                </div>
            </c:if>

            <!-- Quick Demo Helper (if token exists in session/request) -->
            <c:if test="${not empty verificationToken}">
                <div class="mb-5 p-3 bg-blue-50/70 border border-blue-200 rounded-xl text-left text-xs">
                    <span class="font-bold text-blue-800">💡 Mã kích hoạt (Demo):</span>
                    <span class="font-mono font-bold text-amber-700 select-all"><c:out value="${verificationToken}"/></span>
                </div>
            </c:if>

            <!-- OTP FORM -->
            <form action="${pageContext.request.contextPath}/verify-email" method="GET" id="otpForm" class="space-y-6">
                
                <!-- 6 Digit Input Boxes -->
                <div class="flex items-center justify-center gap-2 sm:gap-3">
                    <input type="text" maxlength="1" pattern="[0-9]" inputmode="numeric" class="otp-input w-11 h-13 sm:w-12 sm:h-14 text-center text-xl sm:text-2xl font-black rounded-xl border-2 border-slate-200 bg-slate-50 text-slate-900 focus:bg-white focus:outline-none transition-all" autofocus />
                    <input type="text" maxlength="1" pattern="[0-9]" inputmode="numeric" class="otp-input w-11 h-13 sm:w-12 sm:h-14 text-center text-xl sm:text-2xl font-black rounded-xl border-2 border-slate-200 bg-slate-50 text-slate-900 focus:bg-white focus:outline-none transition-all" />
                    <input type="text" maxlength="1" pattern="[0-9]" inputmode="numeric" class="otp-input w-11 h-13 sm:w-12 sm:h-14 text-center text-xl sm:text-2xl font-black rounded-xl border-2 border-slate-200 bg-slate-50 text-slate-900 focus:bg-white focus:outline-none transition-all" />
                    <span class="text-slate-300 font-bold text-lg select-none">-</span>
                    <input type="text" maxlength="1" pattern="[0-9]" inputmode="numeric" class="otp-input w-11 h-13 sm:w-12 sm:h-14 text-center text-xl sm:text-2xl font-black rounded-xl border-2 border-slate-200 bg-slate-50 text-slate-900 focus:bg-white focus:outline-none transition-all" />
                    <input type="text" maxlength="1" pattern="[0-9]" inputmode="numeric" class="otp-input w-11 h-13 sm:w-12 sm:h-14 text-center text-xl sm:text-2xl font-black rounded-xl border-2 border-slate-200 bg-slate-50 text-slate-900 focus:bg-white focus:outline-none transition-all" />
                    <input type="text" maxlength="1" pattern="[0-9]" inputmode="numeric" class="otp-input w-11 h-13 sm:w-12 sm:h-14 text-center text-xl sm:text-2xl font-black rounded-xl border-2 border-slate-200 bg-slate-50 text-slate-900 focus:bg-white focus:outline-none transition-all" />
                </div>

                <!-- Combined hidden input submitted to verify-email -->
                <input type="hidden" name="token" id="fullToken" value="${verificationToken}" />

                <!-- Submit Button -->
                <button type="submit" class="w-full bg-blue-600 hover:bg-blue-700 text-white font-extrabold text-sm py-3.5 rounded-xl shadow-lg shadow-blue-500/25 hover:shadow-xl hover:scale-[1.01] active:scale-[0.99] transition-all flex items-center justify-center gap-2">
                    <span>Xác nhận & Kích hoạt tài khoản</span>
                    <svg class="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2.5" d="M14 5l7 7m0 0l-7 7m7-7H3"/></svg>
                </button>
            </form>

            <!-- RESEND CODE FORM -->
            <div class="mt-6 pt-6 border-t border-slate-100 flex flex-col items-center gap-2 text-xs">
                <form action="${pageContext.request.contextPath}/resend-activation" method="POST" id="resendForm" class="flex items-center justify-center">
                    <input type="hidden" name="email" value="<c:out value='${registeredEmail != null ? registeredEmail : param.email}'/>">
                    <span class="text-slate-500 mr-1">Chưa nhận được mã?</span>
                    <button type="submit" id="resendBtn" disabled class="font-bold text-slate-400 cursor-not-allowed transition">
                        Gửi lại mã (<span id="countdown">59</span>s)
                    </button>
                </form>
                
                <p class="text-[11px] text-slate-400">
                    Vui lòng kiểm tra cả thư mục <em>Spam / Thư rác</em> nếu không thấy mã trong hộp thư chính.
                </p>
            </div>

        </div>
    </main>

    <!-- FOOTER -->
    <footer class="max-w-4xl mx-auto w-full text-center py-3 text-[11px] text-slate-400 relative z-10">
        <span>© 2026 BookStore Management System (SWD392 - Team PS06). All rights reserved.</span>
    </footer>

    <!-- INTERACTIVE JAVASCRIPT -->
    <script>
        const inputs = document.querySelectorAll('.otp-input');
        const fullTokenInput = document.getElementById('fullToken');
        const resendBtn = document.getElementById('resendBtn');
        const countdownSpan = document.getElementById('countdown');
        let timeLeft = 59;
        let timer = null;

        // Auto-focus next input / Backspace behavior
        inputs.forEach((input, index) => {
            input.addEventListener('input', (e) => {
                const val = e.target.value.replace(/[^a-zA-Z0-9]/g, '');
                e.target.value = val;
                if (val && index < inputs.length - 1) {
                    inputs[index + 1].focus();
                }
                updateFullToken();
            });

            input.addEventListener('keydown', (e) => {
                if (e.key === 'Backspace' && !input.value && index > 0) {
                    inputs[index - 1].focus();
                }
            });

            // Handle paste 6 digits directly
            input.addEventListener('paste', (e) => {
                e.preventDefault();
                const pastedData = (e.clipboardData || window.clipboardData).getData('text').replace(/\s+/g, '').slice(0, 6);
                if (pastedData) {
                    pastedData.split('').forEach((char, i) => {
                        if (inputs[i]) inputs[i].value = char;
                    });
                    if (inputs[pastedData.length - 1]) {
                        inputs[pastedData.length - 1].focus();
                    } else {
                        inputs[inputs.length - 1].focus();
                    }
                    updateFullToken();
                }
            });
        });

        function updateFullToken() {
            let code = '';
            inputs.forEach(i => code += i.value);
            fullTokenInput.value = code;
        }

        // Countdown Timer
        function startTimer() {
            timeLeft = 59;
            resendBtn.disabled = true;
            resendBtn.className = "font-bold text-slate-400 cursor-not-allowed transition";
            resendBtn.innerHTML = `Gửi lại mã (<span id="countdown">${timeLeft}</span>s)`;

            if (timer) clearInterval(timer);
            timer = setInterval(() => {
                timeLeft--;
                const cd = document.getElementById('countdown');
                if (cd) cd.textContent = timeLeft;

                if (timeLeft <= 0) {
                    clearInterval(timer);
                    resendBtn.disabled = false;
                    resendBtn.className = "font-bold text-blue-600 hover:text-blue-700 cursor-pointer underline transition";
                    resendBtn.innerHTML = "Gửi lại mã ngay";
                }
            }, 1000);
        }
        startTimer();

        // If a verificationToken exists from server, prefill for testing convenience
        window.addEventListener('DOMContentLoaded', () => {
            const initialToken = fullTokenInput.value;
            if (initialToken && initialToken.length === 6) {
                initialToken.split('').forEach((ch, idx) => {
                    if (inputs[idx]) inputs[idx].value = ch;
                });
            }
        });
    </script>

</body>
</html>
