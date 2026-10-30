<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>

<!-- Include Header -->
<jsp:include page="/views/common/header.jsp" />

<style>
    .tab-btn.active {
        background-color: #eff6ff;
        color: #2563eb;
        font-weight: 700;
        border-right: 3px solid #2563eb;
    }
</style>

<!-- MAIN ACCOUNT WRAPPER (BREADCRUMB REMOVED PER USER REQUEST) -->
<main class="max-w-[1440px] mx-auto px-4 sm:px-8 pt-6 pb-10 flex-1 w-full relative z-10">
    <div class="grid grid-cols-1 lg:grid-cols-12 gap-7">
        
        <!-- ============================================== -->
        <!-- LEFT SIDEBAR: PROFILE SUMMARY & NAVIGATION     -->
        <!-- ============================================== -->
        <aside class="lg:col-span-3 space-y-4">
            
            <!-- User Short Bio Card -->
            <div class="bg-white rounded-3xl p-5 border border-slate-200/80 shadow-sm flex items-center gap-3.5">
                <div class="relative">
                    <img id="sidebarAvatar" 
                         src="${not empty sessionScope.authUser.avatarUrl ? sessionScope.authUser.avatarUrl : 'https://images.unsplash.com/photo-1534528741775-53994a69daeb?auto=format&fit=crop&w=200&h=200&q=80'}" 
                         alt="Avatar" 
                         class="w-14 h-14 rounded-full object-cover ring-2 ring-blue-500/30" />
                    <button type="button" onclick="switchTab('profile')" class="absolute bottom-0 right-0 bg-blue-600 text-white p-1 rounded-full text-[9px] shadow hover:bg-blue-700 transition" title="Change Avatar">
                        ✏️
                    </button>
                </div>
                <div class="overflow-hidden">
                    <h3 class="text-sm font-bold text-slate-900 truncate">
                        <c:out value="${not empty sessionScope.authUser.fullName ? sessionScope.authUser.fullName : 'Thanh Trung'}"/>
                    </h3>
                    <p class="text-[11px] text-slate-400 truncate">
                        <c:out value="${not empty sessionScope.authUser.email ? sessionScope.authUser.email : 'user@example.com'}"/>
                    </p>
                    <span class="inline-block mt-1 text-[10px] text-emerald-700 bg-emerald-50 px-2 py-0.5 rounded-full font-bold">
                        ✓ Verified
                    </span>
                </div>
            </div>

            <!-- Navigation Tabs Menu -->
            <nav class="bg-white rounded-3xl border border-slate-200/80 shadow-sm overflow-hidden py-2 text-xs font-semibold text-slate-600">
                
                <button type="button" onclick="switchTab('profile')" id="tabBtn-profile" class="tab-btn active w-full flex items-center gap-3 px-5 py-3 hover:bg-slate-50 transition text-left">
                    <span class="text-base">👤</span>
                    <div class="flex-1">
                        <span class="block font-bold">Personal Profile</span>
                        <span class="text-[10px] text-slate-400 font-normal">Name, birth date, phone number</span>
                    </div>
                </button>

                <button type="button" onclick="switchTab('password')" id="tabBtn-password" class="tab-btn w-full flex items-center gap-3 px-5 py-3 hover:bg-slate-50 transition text-left">
                    <span class="text-base">🔒</span>
                    <div class="flex-1">
                        <span class="block font-bold">Change Password</span>
                        <span class="text-[10px] text-slate-400 font-normal">Account security (UC-05)</span>
                    </div>
                </button>

                <button type="button" onclick="switchTab('address')" id="tabBtn-address" class="tab-btn w-full flex items-center gap-3 px-5 py-3 hover:bg-slate-50 transition text-left">
                    <span class="text-base">📍</span>
                    <div class="flex-1">
                        <span class="block font-bold">Address Book</span>
                        <span class="text-[10px] text-slate-400 font-normal">Default delivery addresses</span>
                    </div>
                </button>

                <a href="${pageContext.request.contextPath}/orders" class="w-full flex items-center gap-3 px-5 py-3 hover:bg-slate-50 transition text-left text-slate-600">
                    <span class="text-base">📦</span>
                    <div class="flex-1">
                        <span class="block font-bold">My Orders</span>
                        <span class="text-[10px] text-slate-400 font-normal">Track your orders</span>
                    </div>
                </a>

                <a href="${pageContext.request.contextPath}/wishlist" class="w-full flex items-center gap-3 px-5 py-3 hover:bg-slate-50 transition text-left text-slate-600">
                    <span class="text-base">❤️</span>
                    <div class="flex-1">
                        <span class="block font-bold">Wishlist</span>
                        <span class="text-[10px] text-slate-400 font-normal">Saved books list</span>
                    </div>
                </a>

                <div class="border-t border-slate-100 my-1"></div>

                <a href="${pageContext.request.contextPath}/logout" class="w-full flex items-center gap-3 px-5 py-2.5 text-red-600 hover:bg-red-50 transition text-left">
                    <span class="text-base">🚪</span>
                    <span class="font-bold">Sign Out</span>
                </a>

            </nav>

            <!-- Small Security Helper Box -->
            <div class="bg-blue-50/70 border border-blue-200/60 rounded-3xl p-4 text-xs text-blue-900 space-y-1.5">
                <span class="font-bold flex items-center gap-1.5">
                    <span>🛡️</span> Account Security
                </span>
                <p class="text-[11px] text-blue-700 leading-relaxed">
                    For optimal protection, change your password every 6 months and never share your credentials with others.
                </p>
            </div>

        </aside>

        <!-- ============================================== -->
        <!-- RIGHT PANEL: TAB CONTENTS                      -->
        <!-- ============================================== -->
        <section class="lg:col-span-9 bg-white rounded-3xl border border-slate-200/80 shadow-sm p-6 sm:p-9 relative">
            
            <!-- Success/Error Server Alert -->
            <c:if test="${not empty successMessage}">
                <div class="mb-6 p-4 rounded-2xl text-xs font-semibold flex items-center justify-between shadow-sm bg-emerald-50 text-emerald-700 border border-emerald-200">
                    <div class="flex items-center gap-2.5">
                        <span class="text-base">✅</span>
                        <span><c:out value="${successMessage}"/></span>
                    </div>
                </div>
            </c:if>
            <c:if test="${not empty errorMessage}">
                <div class="mb-6 p-4 rounded-2xl text-xs font-semibold flex items-center justify-between shadow-sm bg-rose-50 text-rose-700 border border-rose-200">
                    <div class="flex items-center gap-2.5">
                        <span class="text-base">⚠️</span>
                        <span><c:out value="${errorMessage}"/></span>
                    </div>
                </div>
            </c:if>

            <!-- Dynamic JS Toast Alert -->
            <div id="toastAlert" class="hidden mb-6 p-4 rounded-2xl text-xs font-semibold flex items-center justify-between shadow-sm transition-all">
                <div class="flex items-center gap-2.5">
                    <span id="toastIcon" class="text-base">✅</span>
                    <span id="toastMsg">Profile updated successfully!</span>
                </div>
                <button type="button" onclick="hideToast()" class="text-slate-400 hover:text-slate-600 text-sm font-bold ml-3">&times;</button>
            </div>

            <!-- -------------------------------------------- -->
            <!-- TAB 1: PERSONAL PROFILE                      -->
            <!-- -------------------------------------------- -->
            <div id="tabContent-profile" class="space-y-6">
                
                <div class="border-b border-slate-100 pb-4">
                    <h2 class="text-lg font-black text-slate-900">Personal Profile</h2>
                    <p class="text-xs text-slate-400">Manage your profile details to secure your account</p>
                </div>

                <form action="${pageContext.request.contextPath}/profile" method="POST" enctype="multipart/form-data" id="profileForm" class="space-y-6">
                    <input type="hidden" name="action" value="updateProfile" />
                    
                    <!-- Avatar Upload -->
                    <div class="flex flex-col sm:flex-row items-center gap-6 p-4 rounded-2xl bg-slate-50/70 border border-slate-100">
                        <div class="relative group">
                            <img id="mainAvatarPreview" 
                                 src="${not empty sessionScope.authUser.avatarUrl ? sessionScope.authUser.avatarUrl : 'https://images.unsplash.com/photo-1534528741775-53994a69daeb?auto=format&fit=crop&w=250&h=250&q=80'}" 
                                 alt="Avatar" 
                                 class="w-24 h-24 rounded-full object-cover ring-4 ring-white shadow-md" />
                            <label for="avatarInput" class="absolute inset-0 bg-slate-900/40 rounded-full flex flex-col items-center justify-center text-white text-[10px] font-bold opacity-0 group-hover:opacity-100 transition cursor-pointer">
                                <span>📷</span>
                                <span>Change</span>
                            </label>
                        </div>

                        <div class="space-y-2 text-center sm:text-left">
                            <input type="file" id="avatarInput" name="avatarFile" accept="image/*" class="hidden" onchange="previewAvatar(event)" />
                            <label for="avatarInput" class="inline-block bg-white hover:bg-slate-50 text-slate-700 font-bold text-xs px-4 py-2 rounded-xl border border-slate-200 shadow-sm cursor-pointer transition">
                                Upload New Photo
                            </label>
                            <p class="text-[11px] text-slate-400 leading-snug">
                                Supported formats: .JPEG, .PNG, .WEBP<br>
                                Max size: 2 MB. Square, clear images recommended.
                            </p>
                        </div>
                    </div>

                    <!-- Fields Grid -->
                    <div class="grid grid-cols-1 md:grid-cols-2 gap-5">
                        
                        <!-- Full Name -->
                        <div>
                            <label for="profFullName" class="block text-xs font-bold text-slate-700 mb-1.5">
                                Full Name <span class="text-rose-500">*</span>
                            </label>
                            <div class="relative">
                                <span class="absolute inset-y-0 left-0 pl-3.5 flex items-center text-slate-400 text-sm">👤</span>
                                <input type="text" id="profFullName" name="fullName" 
                                       value="<c:out value='${not empty sessionScope.authUser.fullName ? sessionScope.authUser.fullName : \"Thanh Trung\"}'/>" 
                                       required class="w-full text-xs pl-10 pr-3.5 py-2.5 rounded-xl border border-slate-200 bg-slate-50/50 focus:bg-white focus:border-blue-500 focus:ring-2 focus:ring-blue-100 transition focus:outline-none font-semibold text-slate-800" />
                            </div>
                        </div>

                        <!-- Email (Read-Only) -->
                        <div>
                            <label class="block text-xs font-bold text-slate-700 mb-1.5 flex items-center justify-between">
                                <span>Email Address</span>
                                <span class="text-[10px] text-emerald-600 font-semibold bg-emerald-50 px-1.5 py-0.2 rounded">✓ Verified</span>
                            </label>
                            <div class="relative">
                                <span class="absolute inset-y-0 left-0 pl-3.5 flex items-center text-slate-400 text-sm">✉️</span>
                                <input type="email" 
                                       value="<c:out value='${not empty sessionScope.authUser.email ? sessionScope.authUser.email : \"user@example.com\"}'/>" 
                                       disabled class="w-full text-xs pl-10 pr-3.5 py-2.5 rounded-xl border border-slate-200 bg-slate-100 text-slate-500 font-semibold cursor-not-allowed" />
                            </div>
                            <p class="text-[10px] text-slate-400 mt-1">Login email cannot be changed directly.</p>
                        </div>

                        <!-- Phone Number -->
                        <div>
                            <label for="profPhone" class="block text-xs font-bold text-slate-700 mb-1.5">
                                Phone Number <span class="text-rose-500">*</span>
                            </label>
                            <div class="relative">
                                <span class="absolute inset-y-0 left-0 pl-3.5 flex items-center text-slate-400 text-sm">📱</span>
                                <input type="tel" id="profPhone" name="phoneNumber" 
                                       value="<c:out value='${not empty sessionScope.authUser.phoneNumber ? sessionScope.authUser.phoneNumber : \"0912345678\"}'/>" 
                                       pattern="[0-9]{10,11}" required class="w-full text-xs pl-10 pr-3.5 py-2.5 rounded-xl border border-slate-200 bg-slate-50/50 focus:bg-white focus:border-blue-500 focus:ring-2 focus:ring-blue-100 transition focus:outline-none font-semibold text-slate-800" />
                            </div>
                        </div>

                        <!-- Date of Birth -->
                        <div>
                            <label for="profDob" class="block text-xs font-bold text-slate-700 mb-1.5">Date of Birth</label>
                            <div class="relative">
                                <span class="absolute inset-y-0 left-0 pl-3.5 flex items-center text-slate-400 text-sm">🎂</span>
                                <input type="date" id="profDob" name="dob" 
                                       value="<c:out value='${not empty sessionScope.authUser.dob ? sessionScope.authUser.dob : \"2002-05-15\"}'/>" 
                                       class="w-full text-xs pl-10 pr-3.5 py-2.5 rounded-xl border border-slate-200 bg-slate-50/50 focus:bg-white focus:border-blue-500 focus:ring-2 focus:ring-blue-100 transition focus:outline-none font-semibold text-slate-800" />
                            </div>
                        </div>

                    </div>

                    <!-- Gender Selection -->
                    <div>
                        <label class="block text-xs font-bold text-slate-700 mb-2">Gender</label>
                        <div class="flex items-center gap-6 text-xs font-semibold text-slate-700">
                            <label class="flex items-center gap-2 cursor-pointer">
                                <input type="radio" name="gender" value="Male" ${empty sessionScope.authUser.gender or sessionScope.authUser.gender == 'Male' ? 'checked' : ''} class="w-4 h-4 text-blue-600 focus:ring-blue-500 accent-blue-600" />
                                <span>Male</span>
                            </label>
                            <label class="flex items-center gap-2 cursor-pointer">
                                <input type="radio" name="gender" value="Female" ${sessionScope.authUser.gender == 'Female' ? 'checked' : ''} class="w-4 h-4 text-blue-600 focus:ring-blue-500 accent-blue-600" />
                                <span>Female</span>
                            </label>
                            <label class="flex items-center gap-2 cursor-pointer">
                                <input type="radio" name="gender" value="Other" ${sessionScope.authUser.gender == 'Other' ? 'checked' : ''} class="w-4 h-4 text-blue-600 focus:ring-blue-500 accent-blue-600" />
                                <span>Other</span>
                            </label>
                        </div>
                    </div>

                    <!-- Submit Button -->
                    <div class="pt-4 border-t border-slate-100 flex items-center gap-4">
                        <button type="submit" class="bg-blue-600 hover:bg-blue-700 text-white font-extrabold text-xs px-7 py-3 rounded-xl shadow-lg shadow-blue-500/25 hover:shadow-xl transition flex items-center gap-2">
                            <span>Save Changes</span>
                            <svg class="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2.5" d="M5 13l4 4L19 7"/></svg>
                        </button>
                        <button type="reset" class="text-xs font-bold text-slate-500 hover:text-slate-800 px-4 py-3 rounded-xl transition">
                            Cancel
                        </button>
                    </div>

                </form>

            </div>

            <!-- -------------------------------------------- -->
            <!-- TAB 2: CHANGE PASSWORD (UC-05)               -->
            <!-- -------------------------------------------- -->
            <div id="tabContent-password" class="hidden space-y-6">
                
                <div class="border-b border-slate-100 pb-4">
                    <h2 class="text-lg font-black text-slate-900">Change Account Password</h2>
                    <p class="text-xs text-slate-400">For security reasons, do not share your password with anyone</p>
                </div>

                <form action="${pageContext.request.contextPath}/change-password" method="POST" id="changePasswordForm" class="space-y-5 max-w-lg">
                    <input type="hidden" name="action" value="changePassword" />

                    <!-- Current Password -->
                    <div>
                        <label for="currentPass" class="block text-xs font-bold text-slate-700 mb-1.5">
                            Current Password <span class="text-rose-500">*</span>
                        </label>
                        <div class="relative">
                            <input type="password" id="currentPass" name="currentPassword" required placeholder="Enter current password" class="w-full text-xs pl-3.5 pr-10 py-2.5 rounded-xl border border-slate-200 bg-slate-50/50 focus:bg-white focus:border-blue-500 focus:ring-2 focus:ring-blue-100 transition focus:outline-none font-semibold text-slate-800" />
                            <button type="button" onclick="togglePass('currentPass')" class="absolute inset-y-0 right-0 pr-3 flex items-center text-slate-400 hover:text-slate-600 text-sm">
                                👁️
                            </button>
                        </div>
                    </div>

                    <!-- New Password -->
                    <div>
                        <label for="newPass" class="block text-xs font-bold text-slate-700 mb-1.5">
                            New Password <span class="text-rose-500">*</span>
                        </label>
                        <div class="relative">
                            <input type="password" id="newPass" name="newPassword" oninput="checkStrength(this.value)" required placeholder="Minimum 8 characters" class="w-full text-xs pl-3.5 pr-10 py-2.5 rounded-xl border border-slate-200 bg-slate-50/50 focus:bg-white focus:border-blue-500 focus:ring-2 focus:ring-blue-100 transition focus:outline-none font-semibold text-slate-800" />
                            <button type="button" onclick="togglePass('newPass')" class="absolute inset-y-0 right-0 pr-3 flex items-center text-slate-400 hover:text-slate-600 text-sm">
                                👁️
                            </button>
                        </div>

                        <!-- Strength Meter -->
                        <div class="mt-2 space-y-1">
                            <div class="flex items-center justify-between text-[10px] font-bold">
                                <span class="text-slate-400">Password strength:</span>
                                <span id="strengthText" class="text-slate-400">Not entered</span>
                            </div>
                            <div class="w-full bg-slate-100 h-1.5 rounded-full overflow-hidden">
                                <div id="strengthBar" class="h-full bg-slate-300 w-0 transition-all duration-300"></div>
                            </div>
                        </div>
                    </div>

                    <!-- Confirm New Password -->
                    <div>
                        <label for="confirmPass" class="block text-xs font-bold text-slate-700 mb-1.5">
                            Confirm New Password <span class="text-rose-500">*</span>
                        </label>
                        <div class="relative">
                            <input type="password" id="confirmPass" name="confirmPassword" required placeholder="Re-enter new password" class="w-full text-xs pl-3.5 pr-10 py-2.5 rounded-xl border border-slate-200 bg-slate-50/50 focus:bg-white focus:border-blue-500 focus:ring-2 focus:ring-blue-100 transition focus:outline-none font-semibold text-slate-800" />
                            <button type="button" onclick="togglePass('confirmPass')" class="absolute inset-y-0 right-0 pr-3 flex items-center text-slate-400 hover:text-slate-600 text-sm">
                                👁️
                            </button>
                        </div>
                    </div>

                    <!-- Rules Checklist -->
                    <div class="p-3.5 rounded-xl bg-slate-50 border border-slate-200/60 text-[11px] text-slate-600 space-y-1.5">
                        <span class="font-bold text-slate-800 block mb-1">A valid password must satisfy:</span>
                        <div class="flex items-center gap-2">
                            <span class="text-slate-400">●</span> <span>At least 8 characters long</span>
                        </div>
                        <div class="flex items-center gap-2">
                            <span class="text-slate-400">●</span> <span>Different from current password</span>
                        </div>
                        <div class="flex items-center gap-2">
                            <span class="text-slate-400">●</span> <span>Combine uppercase, lowercase, numbers & symbols</span>
                        </div>
                    </div>

                    <!-- Submit Button -->
                    <div class="pt-3">
                        <button type="submit" class="bg-blue-600 hover:bg-blue-700 text-white font-extrabold text-xs px-7 py-3 rounded-xl shadow-lg shadow-blue-500/25 hover:shadow-xl transition flex items-center gap-2">
                            <span>Update Password</span>
                            <svg class="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2.5" d="M14 5l7 7m0 0l-7 7m7-7H3"/></svg>
                        </button>
                    </div>

                </form>

            </div>

            <!-- -------------------------------------------- -->
            <!-- TAB 3: ADDRESS BOOK                          -->
            <!-- -------------------------------------------- -->
            <div id="tabContent-address" class="hidden space-y-6">
                
                <div class="flex items-center justify-between border-b border-slate-100 pb-4">
                    <div>
                        <h2 class="text-lg font-black text-slate-900">Shipping Address Book</h2>
                        <p class="text-xs text-slate-400">Manage your home delivery addresses</p>
                    </div>
                    <button type="button" class="bg-blue-600 hover:bg-blue-700 text-white font-bold text-xs px-4 py-2 rounded-xl shadow-sm transition flex items-center gap-1.5">
                        <span>+</span>
                        <span>Add New Address</span>
                    </button>
                </div>

                <!-- Existing Address 1 (Default) -->
                <div class="p-4 rounded-2xl border-2 border-blue-500/40 bg-blue-50/20 flex flex-col sm:flex-row items-start sm:items-center justify-between gap-4">
                    <div class="space-y-1">
                        <div class="flex items-center gap-2">
                            <span class="font-bold text-xs text-slate-900">Thanh Trung</span>
                            <span class="text-slate-300">|</span>
                            <span class="text-xs text-slate-500 font-semibold">0912 345 678</span>
                            <span class="bg-blue-600 text-white text-[10px] font-bold px-2 py-0.5 rounded-full">Default</span>
                        </div>
                        <p class="text-xs text-slate-600">
                            High-Tech Park, Thu Duc City, Ho Chi Minh City, Vietnam
                        </p>
                    </div>
                    <div class="flex items-center gap-2 flex-shrink-0">
                        <button type="button" class="text-xs text-blue-600 hover:underline font-bold">Edit</button>
                    </div>
                </div>

            </div>

        </section>

    </div>
</main>

<!-- Tab Switching & Interaction Scripts -->
<script>
    function switchTab(tabName) {
        document.getElementById('tabContent-profile').classList.add('hidden');
        document.getElementById('tabContent-password').classList.add('hidden');
        document.getElementById('tabContent-address').classList.add('hidden');

        document.getElementById('tabBtn-profile').classList.remove('active');
        document.getElementById('tabBtn-password').classList.remove('active');
        document.getElementById('tabBtn-address').classList.remove('active');

        const contentEl = document.getElementById('tabContent-' + tabName);
        const btnEl = document.getElementById('tabBtn-' + tabName);
        if (contentEl && btnEl) {
            contentEl.classList.remove('hidden');
            btnEl.classList.add('active');
        }
    }

    function togglePass(id) {
        const field = document.getElementById(id);
        field.type = field.type === 'password' ? 'text' : 'password';
    }

    function previewAvatar(event) {
        const file = event.target.files[0];
        if (file) {
            const reader = new FileReader();
            reader.onload = function(e) {
                document.getElementById('mainAvatarPreview').src = e.target.result;
                document.getElementById('sidebarAvatar').src = e.target.result;
            };
            reader.readAsDataURL(file);
        }
    }

    function checkStrength(pass) {
        const bar = document.getElementById('strengthBar');
        const text = document.getElementById('strengthText');

        if (!pass) {
            bar.style.width = '0%';
            bar.className = 'h-full bg-slate-300 w-0';
            text.textContent = 'Not entered';
            text.className = 'text-slate-400 font-bold';
            return;
        }

        let score = 0;
        if (pass.length >= 8) score++;
        if (/[A-Z]/.test(pass)) score++;
        if (/[0-9]/.test(pass)) score++;
        if (/[^A-Za-z0-9]/.test(pass)) score++;

        if (score <= 1) {
            bar.style.width = '25%';
            bar.className = 'h-full bg-rose-500 transition-all';
            text.textContent = 'Weak';
            text.className = 'text-rose-500 font-bold';
        } else if (score === 2) {
            bar.style.width = '50%';
            bar.className = 'h-full bg-amber-500 transition-all';
            text.textContent = 'Fair';
            text.className = 'text-amber-500 font-bold';
        } else if (score === 3) {
            bar.style.width = '75%';
            bar.className = 'h-full bg-blue-500 transition-all';
            text.textContent = 'Good';
            text.className = 'text-blue-500 font-bold';
        } else {
            bar.style.width = '100%';
            bar.className = 'h-full bg-emerald-500 transition-all';
            text.textContent = 'Strong';
            text.className = 'text-emerald-600 font-bold';
        }
    }

    // Auto-switch to tab if passed in URL hash (e.g. #password) or server activeTab
    window.addEventListener('DOMContentLoaded', () => {
        const serverTab = '<c:out value="${activeTab}"/>';
        const hash = window.location.hash.replace('#', '');
        if (hash === 'password' || hash === 'address' || hash === 'profile') {
            switchTab(hash);
        } else if (serverTab === 'password' || serverTab === 'address' || serverTab === 'profile') {
            switchTab(serverTab);
        }
    });

    window.addEventListener('hashchange', () => {
        const hash = window.location.hash.replace('#', '');
        if (hash === 'password' || hash === 'address' || hash === 'profile') {
            switchTab(hash);
        }
    });
</script>

<!-- Include Footer -->
<jsp:include page="/views/common/footer.jsp" />
