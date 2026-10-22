<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>${pageTitle != null ? pageTitle : 'Sign In to BookStore'}</title>
    <link rel="preconnect" href="https://fonts.googleapis.com">
    <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700;800&display=swap" rel="stylesheet">
    <style>
        * {
            box-sizing: border-box;
            margin: 0;
            padding: 0;
        }
        body {
            font-family: 'Inter', -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, sans-serif;
            background: radial-gradient(circle at 10% 10%, #f1f5fb 0%, #f8f9fc 55%, #f4f1ea 100%);
            color: #1e293b;
            min-height: 100vh;
            display: flex;
            flex-direction: column;
            justify-content: space-between;
        }
        /* Top Portal Header */
        .top-header {
            width: 100%;
            max-width: 1320px;
            margin: 0 auto;
            padding: 24px 32px;
            display: flex;
            align-items: center;
            justify-content: space-between;
        }
        .brand-logo {
            display: flex;
            align-items: center;
            gap: 12px;
            text-decoration: none;
        }
        .brand-badge {
            width: 38px;
            height: 38px;
            background: #ffffff;
            border-radius: 10px;
            box-shadow: 0 2px 8px rgba(15, 23, 42, 0.08);
            display: flex;
            align-items: center;
            justify-content: center;
            font-size: 9px;
            font-weight: 800;
            color: #0b2259;
            border: 1px solid #e2e8f0;
        }
        .brand-text-wrap {
            display: flex;
            flex-direction: column;
        }
        .brand-title {
            font-size: 20px;
            font-weight: 800;
            letter-spacing: -0.4px;
            color: #0f172a;
            line-height: 1.1;
        }
        .brand-title span {
            color: #b45309;
        }
        .brand-subtitle {
            font-size: 9.5px;
            font-weight: 700;
            letter-spacing: 1.2px;
            color: #64748b;
            text-transform: uppercase;
            margin-top: 2px;
        }
        .back-home-link {
            display: inline-flex;
            align-items: center;
            gap: 8px;
            font-size: 13.5px;
            font-weight: 600;
            color: #334155;
            text-decoration: none;
            padding: 8px 14px;
            border-radius: 8px;
            transition: all 0.2s ease;
        }
        .back-home-link:hover {
            background: rgba(15, 23, 42, 0.05);
            color: #0b2259;
        }

        /* Main Split Card */
        .main-wrapper {
            flex: 1;
            display: flex;
            align-items: center;
            justify-content: center;
            padding: 12px 24px 32px;
        }
        .auth-card {
            width: 100%;
            max-width: 980px;
            background: #ffffff;
            border-radius: 20px;
            box-shadow: 0 24px 60px rgba(15, 23, 42, 0.10), 0 4px 16px rgba(15, 23, 42, 0.04);
            display: grid;
            grid-template-columns: 42% 58%;
            overflow: hidden;
        }

        /* Left Visual Panel */
        .left-panel {
            background: linear-gradient(160deg, #071946 0%, #0d286d 55%, #16264c 100%);
            color: #ffffff;
            padding: 36px 34px;
            display: flex;
            flex-direction: column;
            justify-content: space-between;
            position: relative;
        }
        .left-top-meta {
            display: flex;
            align-items: center;
            justify-content: space-between;
        }
        .suite-pill {
            display: inline-flex;
            align-items: center;
            gap: 6px;
            background: rgba(255, 255, 255, 0.12);
            border: 1px solid rgba(255, 255, 255, 0.16);
            padding: 6px 12px;
            border-radius: 999px;
            font-size: 11px;
            font-weight: 600;
            color: #e2e8f0;
        }
        .version-tag {
            font-size: 11px;
            font-weight: 600;
            color: #94a3b8;
        }
        .art-box {
            margin: 26px 0 22px;
            border-radius: 14px;
            overflow: hidden;
            box-shadow: 0 16px 36px rgba(0, 0, 0, 0.35);
            border: 1px solid rgba(255, 255, 255, 0.12);
        }
        .art-box img {
            width: 100%;
            height: 235px;
            object-fit: cover;
            display: block;
        }
        .left-copy {
            text-align: center;
            padding: 0 6px;
        }
        .left-copy h2 {
            font-size: 21px;
            font-weight: 800;
            letter-spacing: -0.3px;
            color: #ffffff;
            margin-bottom: 10px;
        }
        .left-copy p {
            font-size: 12.8px;
            line-height: 1.6;
            color: #cbd5e1;
        }
        .left-footer-meta {
            margin-top: 28px;
            padding-top: 16px;
            border-top: 1px solid rgba(255, 255, 255, 0.1);
            display: flex;
            align-items: center;
            justify-content: space-between;
            font-size: 11px;
            font-weight: 600;
        }
        .partner-tag {
            display: inline-flex;
            align-items: center;
            gap: 6px;
            color: #fbbf24;
        }
        .ssl-tag {
            color: #94a3b8;
        }

        /* Right Form Panel */
        .right-panel {
            padding: 46px 52px;
            display: flex;
            flex-direction: column;
            justify-content: center;
        }
        .form-header h1 {
            font-size: 28px;
            font-weight: 800;
            color: #0f172a;
            letter-spacing: -0.5px;
            margin-bottom: 6px;
        }
        .form-header p {
            font-size: 13.5px;
            color: #64748b;
            margin-bottom: 24px;
        }

        /* Alert Banner */
        .alert-banner {
            border-radius: 10px;
            padding: 13px 16px;
            margin-bottom: 22px;
            display: flex;
            align-items: flex-start;
            justify-content: space-between;
            gap: 12px;
            font-size: 13px;
            line-height: 1.45;
        }
        .alert-error {
            background-color: #fef2f2;
            border: 1px solid #fecaca;
            color: #b91c1c;
        }
        .alert-success {
            background-color: #f0fdf4;
            border: 1px solid #bbf7d0;
            color: #15803d;
        }
        .alert-content {
            display: flex;
            align-items: flex-start;
            gap: 10px;
        }
        .alert-icon {
            flex-shrink: 0;
            margin-top: 1px;
        }
        .alert-title {
            font-weight: 700;
            display: block;
            margin-bottom: 2px;
        }
        .alert-close {
            background: none;
            border: none;
            color: inherit;
            cursor: pointer;
            font-size: 16px;
            line-height: 1;
            opacity: 0.7;
            padding: 2px;
        }
        .alert-close:hover {
            opacity: 1;
        }

        /* Form Controls */
        .form-group {
            margin-bottom: 20px;
        }
        .label-row {
            display: flex;
            align-items: center;
            justify-content: space-between;
            margin-bottom: 8px;
        }
        .form-label {
            font-size: 11px;
            font-weight: 700;
            letter-spacing: 0.6px;
            text-transform: uppercase;
            color: #334155;
        }
        .forgot-link {
            font-size: 12px;
            font-weight: 600;
            color: #1d4ed8;
            text-decoration: none;
        }
        .forgot-link:hover {
            text-decoration: underline;
        }
        .input-wrapper {
            position: relative;
            display: flex;
            align-items: center;
        }
        .input-icon-left {
            position: absolute;
            left: 14px;
            color: #64748b;
            display: flex;
            align-items: center;
            pointer-events: none;
        }
        .form-input {
            width: 100%;
            height: 46px;
            padding: 0 42px 0 42px;
            background-color: #f1f5f9;
            border: 1.5px solid transparent;
            border-radius: 10px;
            font-size: 14px;
            font-family: inherit;
            color: #0f172a;
            transition: all 0.2s ease;
        }
        .form-input::placeholder {
            color: #94a3b8;
        }
        .form-input:focus {
            outline: none;
            background-color: #ffffff;
            border-color: #0b2259;
            box-shadow: 0 0 0 3px rgba(11, 34, 89, 0.1);
        }
        .form-input.is-invalid {
            border-color: #ef4444;
            background-color: #fff5f5;
        }
        .toggle-password {
            position: absolute;
            right: 12px;
            background: none;
            border: none;
            color: #64748b;
            cursor: pointer;
            display: flex;
            align-items: center;
            padding: 4px;
        }
        .toggle-password:hover {
            color: #0f172a;
        }
        .field-hint {
            font-size: 11.5px;
            color: #64748b;
            margin-top: 6px;
        }
        .field-error {
            font-size: 12px;
            color: #dc2626;
            font-weight: 500;
            margin-top: 5px;
        }

        /* Remember Me Checkbox */
        .remember-row {
            display: flex;
            align-items: center;
            gap: 9px;
            margin: 6px 0 22px;
        }
        .remember-row input[type="checkbox"] {
            width: 16px;
            height: 16px;
            accent-color: #0b2259;
            cursor: pointer;
            border-radius: 4px;
        }
        .remember-row label {
            font-size: 13px;
            color: #475569;
            cursor: pointer;
            user-select: none;
        }

        /* Submit Button */
        .btn-signin {
            width: 100%;
            height: 48px;
            background: #071f56;
            color: #ffffff;
            border: none;
            border-radius: 10px;
            font-size: 14.5px;
            font-weight: 700;
            font-family: inherit;
            display: inline-flex;
            align-items: center;
            justify-content: center;
            gap: 8px;
            cursor: pointer;
            box-shadow: 0 6px 16px rgba(7, 31, 86, 0.22);
            transition: all 0.2s ease;
        }
        .btn-signin:hover {
            background: #0b2b73;
            transform: translateY(-1px);
        }

        /* Resend Quick Box if account not active */
        .resend-inline-form {
            margin-top: 12px;
            text-align: center;
        }
        .btn-resend-link {
            background: none;
            border: none;
            color: #b45309;
            font-weight: 700;
            font-size: 12.5px;
            text-decoration: underline;
            cursor: pointer;
        }

        /* Register Prompt Box */
        .register-box {
            margin-top: 24px;
            padding: 15px 18px;
            background: #f8fafc;
            border: 1px solid #f1f5f9;
            border-radius: 10px;
            text-align: center;
            font-size: 13px;
            color: #475569;
        }
        .register-box a {
            color: #9a4706;
            font-weight: 700;
            text-decoration: none;
            margin-left: 4px;
        }
        .register-box a:hover {
            text-decoration: underline;
        }

        /* Bottom Footer */
        .page-footer {
            width: 100%;
            max-width: 1320px;
            margin: 0 auto;
            padding: 18px 32px;
            display: flex;
            align-items: center;
            justify-content: space-between;
            font-size: 11.5px;
            color: #64748b;
            border-top: 1px solid rgba(226, 232, 240, 0.7);
        }
        .footer-links {
            display: flex;
            align-items: center;
            gap: 20px;
        }
        .footer-links a {
            color: #64748b;
            text-decoration: none;
            font-weight: 500;
        }
        .footer-links a:hover {
            color: #0f172a;
        }
        .system-status {
            display: inline-flex;
            align-items: center;
            gap: 7px;
            font-weight: 600;
            color: #475569;
        }
        .status-dot {
            width: 7px;
            height: 7px;
            border-radius: 50%;
            background-color: #f59e0b;
        }

        @media (max-width: 860px) {
            .auth-card {
                grid-template-columns: 1fr;
            }
            .left-panel {
                display: none;
            }
            .right-panel {
                padding: 36px 28px;
            }
        }
    </style>
</head>
<body>

    <!-- Top Portal Bar -->
    <header class="top-header">
        <a href="${pageContext.request.contextPath}/home" class="brand-logo">
            <div class="brand-badge">Book<span style="color:#b45309;">Store</span></div>
            <div class="brand-text-wrap">
                <div class="brand-title">Book<span>Store</span></div>
                <div class="brand-subtitle">MANAGEMENT PORTAL</div>
            </div>
        </a>
        <a href="${pageContext.request.contextPath}/home" class="back-home-link">
            <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
                <line x1="19" y1="12" x2="5" y2="12"></line>
                <polyline points="12 19 5 12 12 5"></polyline>
            </svg>
            Back to Home
        </a>
    </header>

    <!-- Main Centered Card -->
    <main class="main-wrapper">
        <div class="auth-card">

            <!-- Left Navy Branding Panel -->
            <section class="left-panel">
                <div class="left-top-meta">
                    <span class="suite-pill">
                        <svg width="13" height="13" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                            <path d="M2 3h6a4 4 0 0 1 4 4v14a3 3 0 0 0-3-3H2z"></path>
                            <path d="M22 3h-6a4 4 0 0 0-4 4v14a3 3 0 0 1 3-3h7z"></path>
                        </svg>
                        Institutional Catalog Suite
                    </span>
                    <span class="version-tag">v4.8</span>
                </div>

                <div class="art-box">
                    <img src="${pageContext.request.contextPath}/static/images/auth-banner.jpg" alt="Discover Your Next Great Read">
                </div>

                <div class="left-copy">
                    <h2>Discover Your Next Great Read</h2>
                    <p>Curated collections, effortless inventory management, and literary treasures at your fingertips.</p>
                </div>

                <div class="left-footer-meta">
                    <span class="partner-tag">
                        <svg width="14" height="14" viewBox="0 0 24 24" fill="currentColor">
                            <circle cx="12" cy="12" r="10" fill="none" stroke="currentColor" stroke-width="2"/>
                            <polygon points="12 7 13.8 10.6 17.8 11.2 14.9 14 15.6 18 12 16.1 8.4 18 9.1 14 6.2 11.2 10.2 10.6 12 7"/>
                        </svg>
                        BookStore Premium Partner
                    </span>
                    <span class="ssl-tag">Secure 256-Bit SSL</span>
                </div>
            </section>

            <!-- Right Sign In Form Panel -->
            <section class="right-panel">
                <div class="form-header">
                    <h1>Sign In to BookStore</h1>
                    <p>Enter your buyer, staff, or administrative credentials to access your catalog.</p>
                </div>

                <!-- Error Alert Box -->
                <c:if test="${not empty errorMessage}">
                    <div class="alert-banner alert-error" id="loginAlertBox">
                        <div class="alert-content">
                            <svg class="alert-icon" width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                                <circle cx="12" cy="12" r="10"></circle>
                                <line x1="12" y1="8" x2="12" y2="12"></line>
                                <line x1="12" y1="16" x2="12.01" y2="16"></line>
                            </svg>
                            <div>
                                <span class="alert-title"><c:out value="${errorMessage}"/></span>
                                <span>Please check your credentials and try again.</span>
                            </div>
                        </div>
                        <button type="button" class="alert-close" onclick="document.getElementById('loginAlertBox').style.display='none'">&times;</button>
                    </div>
                </c:if>

                <!-- Success Alert Box (e.g. after Email Verification) -->
                <c:if test="${not empty successMessage}">
                    <div class="alert-banner alert-success" id="loginSuccessBox">
                        <div class="alert-content">
                            <svg class="alert-icon" width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                                <path d="M22 11.08V12a10 10 0 1 1-5.93-9.14"></path>
                                <polyline points="22 4 12 14.01 9 11.01"></polyline>
                            </svg>
                            <div>
                                <span class="alert-title">Account Activated</span>
                                <span><c:out value="${successMessage}"/></span>
                            </div>
                        </div>
                        <button type="button" class="alert-close" onclick="document.getElementById('loginSuccessBox').style.display='none'">&times;</button>
                    </div>
                </c:if>

                <form action="${pageContext.request.contextPath}/login" method="post" novalidate>
                    <!-- Email Field -->
                    <div class="form-group">
                        <div class="label-row">
                            <label for="email" class="form-label">EMAIL ADDRESS</label>
                        </div>
                        <div class="input-wrapper">
                            <span class="input-icon-left">
                                <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                                    <path d="M4 4h16c1.1 0 2 .9 2 2v12c0 1.1-.9 2-2 2H4c-1.1 0-2-.9-2-2V6c0-1.1.9-2 2-2z"></path>
                                    <polyline points="22,6 12,13 2,6"></polyline>
                                </svg>
                            </span>
                            <input type="email"
                                   id="email"
                                   name="email"
                                   class="form-input ${not empty validationErrors['email'] ? 'is-invalid' : ''}"
                                   placeholder="example@gmail.com"
                                   value="<c:out value='${email}'/>"
                                   required>
                        </div>
                        <c:choose>
                            <c:when test="${not empty validationErrors['email']}">
                                <div class="field-error"><c:out value="${validationErrors['email']}"/></div>
                            </c:when>
                            <c:otherwise>
                                <div class="field-hint">Please enter your registered buyer, staff, or administrator email.</div>
                            </c:otherwise>
                        </c:choose>
                    </div>

                    <!-- Password Field -->
                    <div class="form-group">
                        <div class="label-row">
                            <label for="password" class="form-label">PASSWORD</label>
                            <a href="#" class="forgot-link">Forgot Password?</a>
                        </div>
                        <div class="input-wrapper">
                            <span class="input-icon-left">
                                <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                                    <rect x="3" y="11" width="18" height="11" rx="2" ry="2"></rect>
                                    <path d="M7 11V7a5 5 0 0 1 10 0v4"></path>
                                </svg>
                            </span>
                            <input type="password"
                                   id="password"
                                   name="password"
                                   class="form-input ${not empty validationErrors['password'] ? 'is-invalid' : ''}"
                                   placeholder="••••••••••••"
                                   required>
                            <button type="button" class="toggle-password" onclick="togglePasswordVisibility('password')" aria-label="Toggle password visibility">
                                <svg width="17" height="17" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                                    <path d="M1 12s4-8 11-8 11 8 11 8-4 8-11 8-11-8-11-8z"></path>
                                    <circle cx="12" cy="12" r="3"></circle>
                                </svg>
                            </button>
                        </div>
                        <c:if test="${not empty validationErrors['password']}">
                            <div class="field-error"><c:out value="${validationErrors['password']}"/></div>
                        </c:if>
                    </div>

                    <!-- Remember Me -->
                    <div class="remember-row">
                        <input type="checkbox" id="rememberMe" name="rememberMe" ${rememberMe ? 'checked' : ''}>
                        <label for="rememberMe">Remember this device for 30 days</label>
                    </div>

                    <!-- Sign In CTA -->
                    <button type="submit" class="btn-signin">
                        <svg width="17" height="17" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.2">
                            <path d="M15 3h4a2 2 0 0 1 2 2v14a2 2 0 0 1-2 2h-4"></path>
                            <polyline points="10 17 15 12 10 7"></polyline>
                            <line x1="15" y1="12" x2="3" y2="12"></line>
                        </svg>
                        Sign In
                    </button>
                </form>

                <!-- Quick Resend Activation option when account is inactive -->
                <c:if test="${not empty inactiveEmail}">
                    <form action="${pageContext.request.contextPath}/resend-activation" method="post" class="resend-inline-form">
                        <input type="hidden" name="email" value="<c:out value='${inactiveEmail}'/>">
                        <button type="submit" class="btn-resend-link">Didn't receive activation email? Click here to resend</button>
                    </form>
                </c:if>

                <!-- Register Link Box -->
                <div class="register-box">
                    Don't have an account?
                    <a href="${pageContext.request.contextPath}/register">Register now &#8599;</a>
                </div>
            </section>

        </div>
    </main>

    <!-- Bottom Footer -->
    <footer class="page-footer">
        <div class="footer-links">
            <span>&copy; 2026 BookStore Management Systems Inc.</span>
            <a href="#">Privacy Policy</a>
            <a href="#">Terms of Service</a>
            <a href="#">System Status</a>
        </div>
        <div class="system-status">
            <span class="status-dot"></span>
            Internal Core Online &bull; Latency 24ms
        </div>
    </footer>

    <script>
        function togglePasswordVisibility(inputId) {
            var field = document.getElementById(inputId);
            if (field) {
                field.type = (field.type === 'password') ? 'text' : 'password';
            }
        }
    </script>
</body>
</html>
