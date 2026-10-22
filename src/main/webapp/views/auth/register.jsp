<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>${pageTitle != null ? pageTitle : 'Create Account - BookStore'}</title>
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
            background: #f4f6fb;
            color: #1e293b;
            min-height: 100vh;
            display: flex;
            flex-direction: column;
            justify-content: space-between;
        }

        /* Top Navigation Bar */
        .top-navbar {
            background: #ffffff;
            border-bottom: 1px solid #e2e8f0;
            padding: 14px 40px;
            display: flex;
            align-items: center;
            justify-content: space-between;
        }
        .nav-brand {
            display: inline-flex;
            align-items: center;
            gap: 12px;
            text-decoration: none;
        }
        .nav-brand-icon {
            width: 36px;
            height: 36px;
            background: #0d2562;
            color: #ffffff;
            border-radius: 9px;
            display: flex;
            align-items: center;
            justify-content: center;
        }
        .nav-brand-text {
            font-size: 20px;
            font-weight: 800;
            color: #0d2562;
            letter-spacing: -0.4px;
        }
        .nav-links {
            display: flex;
            align-items: center;
            gap: 24px;
        }
        .nav-link-item {
            font-size: 13.5px;
            font-weight: 600;
            color: #334155;
            text-decoration: none;
            transition: color 0.15s ease;
        }
        .nav-link-item:hover {
            color: #0d2562;
        }
        .btn-nav-register {
            background: #0d2562;
            color: #ffffff;
            font-size: 13px;
            font-weight: 700;
            padding: 8px 20px;
            border-radius: 8px;
            text-decoration: none;
        }
        .user-circle-icon {
            width: 34px;
            height: 34px;
            background: #0d2562;
            color: #ffffff;
            border-radius: 50%;
            display: flex;
            align-items: center;
            justify-content: center;
        }

        /* Main Centered Container */
        .main-wrapper {
            flex: 1;
            display: flex;
            align-items: center;
            justify-content: center;
            padding: 28px 24px 36px;
        }
        .register-card {
            width: 100%;
            max-width: 1020px;
            background: #ffffff;
            border-radius: 18px;
            box-shadow: 0 22px 54px rgba(15, 23, 42, 0.09), 0 4px 14px rgba(15, 23, 42, 0.04);
            display: grid;
            grid-template-columns: 42% 58%;
            overflow: hidden;
        }

        /* Left Deep Navy Panel */
        .left-panel {
            background: linear-gradient(165deg, #163385 0%, #102566 60%, #0b1b4f 100%);
            color: #ffffff;
            padding: 36px 34px;
            display: flex;
            flex-direction: column;
            justify-content: space-between;
        }
        .privilege-pill {
            display: inline-flex;
            align-items: center;
            gap: 7px;
            background: rgba(255, 255, 255, 0.14);
            padding: 6px 14px;
            border-radius: 999px;
            font-size: 10.5px;
            font-weight: 700;
            letter-spacing: 0.6px;
            text-transform: uppercase;
            color: #f8fafc;
            width: fit-content;
            margin-bottom: 18px;
        }
        .left-heading h2 {
            font-size: 27px;
            font-weight: 800;
            letter-spacing: -0.5px;
            color: #ffffff;
            margin-bottom: 6px;
        }
        .left-heading p {
            font-size: 13.5px;
            font-weight: 700;
            color: #f59e0b;
            margin-bottom: 20px;
        }
        .art-banner-wrap {
            position: relative;
            border-radius: 14px;
            overflow: hidden;
            box-shadow: 0 14px 32px rgba(0, 0, 0, 0.32);
            margin-bottom: 24px;
        }
        .art-banner-wrap img {
            width: 100%;
            height: 185px;
            object-fit: cover;
            display: block;
        }
        .art-caption {
            position: absolute;
            bottom: 10px;
            left: 12px;
            right: 12px;
            background: rgba(9, 20, 56, 0.78);
            backdrop-filter: blur(4px);
            padding: 6px 10px;
            border-radius: 8px;
            font-size: 11px;
            font-weight: 600;
            color: #f8fafc;
            display: flex;
            align-items: center;
            gap: 6px;
        }
        .feature-list {
            display: flex;
            flex-direction: column;
            gap: 16px;
            margin-bottom: 24px;
        }
        .feature-item {
            display: flex;
            align-items: flex-start;
            gap: 12px;
        }
        .feature-icon {
            width: 30px;
            height: 30px;
            border-radius: 8px;
            background: rgba(255, 255, 255, 0.12);
            color: #fbbf24;
            display: flex;
            align-items: center;
            justify-content: center;
            flex-shrink: 0;
            margin-top: 2px;
        }
        .feature-text h4 {
            font-size: 13px;
            font-weight: 700;
            color: #ffffff;
            margin-bottom: 2px;
        }
        .feature-text p {
            font-size: 11.5px;
            color: #cbd5e1;
            line-height: 1.4;
        }
        .left-bottom-stats {
            padding-top: 14px;
            border-top: 1px solid rgba(255, 255, 255, 0.12);
            display: flex;
            align-items: center;
            justify-content: space-between;
            font-size: 11px;
            font-weight: 600;
            color: #cbd5e1;
        }
        .stat-badge {
            display: inline-flex;
            align-items: center;
            gap: 5px;
        }

        /* Right Form Panel */
        .right-panel {
            padding: 40px 48px;
            display: flex;
            flex-direction: column;
            justify-content: center;
        }
        .form-header h1 {
            font-size: 29px;
            font-weight: 800;
            color: #0f172a;
            letter-spacing: -0.5px;
            margin-bottom: 5px;
        }
        .form-header p {
            font-size: 13.5px;
            color: #64748b;
            margin-bottom: 20px;
        }

        /* Alert Banner */
        .alert-banner {
            border-radius: 10px;
            padding: 12px 16px;
            margin-bottom: 18px;
            display: flex;
            align-items: center;
            justify-content: space-between;
            gap: 12px;
            font-size: 12.8px;
            font-weight: 600;
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
        .alert-left {
            display: flex;
            align-items: center;
            gap: 10px;
        }
        .alert-close {
            background: none;
            border: none;
            color: inherit;
            cursor: pointer;
            font-size: 17px;
            line-height: 1;
            opacity: 0.75;
        }

        /* Form Fields */
        .form-group {
            margin-bottom: 15px;
        }
        .form-row-2col {
            display: grid;
            grid-template-columns: 1fr 1fr;
            gap: 14px;
            margin-bottom: 15px;
        }
        .form-label {
            display: block;
            font-size: 12px;
            font-weight: 700;
            color: #1e293b;
            margin-bottom: 6px;
        }
        .input-wrapper {
            position: relative;
            display: flex;
            align-items: center;
        }
        .input-icon-left {
            position: absolute;
            left: 13px;
            color: #64748b;
            display: flex;
            align-items: center;
            pointer-events: none;
        }
        .form-input {
            width: 100%;
            height: 44px;
            padding: 0 38px 0 40px;
            background-color: #f1f5f9;
            border: 1.5px solid transparent;
            border-radius: 9px;
            font-size: 13.5px;
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
            border-color: #142d6f;
            box-shadow: 0 0 0 3px rgba(20, 45, 111, 0.1);
        }
        .form-input.is-invalid {
            border-color: #ef4444;
            background-color: #fff5f5;
        }
        .toggle-password {
            position: absolute;
            right: 11px;
            background: none;
            border: none;
            color: #64748b;
            cursor: pointer;
            display: flex;
            align-items: center;
            padding: 4px;
        }
        .field-error {
            font-size: 11.5px;
            color: #dc2626;
            font-weight: 500;
            margin-top: 4px;
        }

        /* Terms Checkbox */
        .terms-row {
            display: flex;
            align-items: center;
            gap: 9px;
            margin: 6px 0 18px;
            font-size: 12.5px;
            color: #475569;
        }
        .terms-row input[type="checkbox"] {
            width: 15px;
            height: 15px;
            accent-color: #142d6f;
            cursor: pointer;
        }
        .terms-row a {
            color: #142d6f;
            font-weight: 700;
            text-decoration: none;
        }
        .terms-row a:hover {
            text-decoration: underline;
        }

        /* Register CTA Button */
        .btn-register {
            width: 100%;
            height: 46px;
            background: #142d6f;
            color: #ffffff;
            border: none;
            border-radius: 9px;
            font-size: 14.5px;
            font-weight: 700;
            font-family: inherit;
            display: inline-flex;
            align-items: center;
            justify-content: center;
            gap: 8px;
            cursor: pointer;
            box-shadow: 0 6px 16px rgba(20, 45, 111, 0.22);
            transition: all 0.2s ease;
        }
        .btn-register:hover {
            background: #1d3f96;
            transform: translateY(-1px);
        }

        /* Verification Pending Box (UC-01 Verify Email & Resend Activation) */
        .verify-pending-box {
            background: #f8fafc;
            border: 1.5px solid #cbd5e1;
            border-radius: 12px;
            padding: 24px;
            text-align: center;
            margin: 10px 0 16px;
        }
        .verify-icon-circle {
            width: 54px;
            height: 54px;
            border-radius: 50%;
            background: #fef3c7;
            color: #b45309;
            display: flex;
            align-items: center;
            justify-content: center;
            margin: 0 auto 14px;
        }
        .verify-pending-box h3 {
            font-size: 18px;
            font-weight: 800;
            color: #0f172a;
            margin-bottom: 8px;
        }
        .verify-pending-box p {
            font-size: 13px;
            color: #475569;
            line-height: 1.55;
            margin-bottom: 16px;
        }
        .dev-activate-box {
            background: #eff6ff;
            border: 1px dashed #93c5fd;
            border-radius: 8px;
            padding: 10px 14px;
            margin-bottom: 16px;
            font-size: 12px;
            color: #1e40af;
        }
        .dev-activate-box a {
            color: #b45309;
            font-weight: 700;
            word-break: break-all;
        }
        .btn-resend {
            background: #ffffff;
            color: #142d6f;
            border: 1.5px solid #142d6f;
            border-radius: 8px;
            padding: 10px 20px;
            font-size: 13px;
            font-weight: 700;
            cursor: pointer;
            transition: all 0.2s ease;
        }
        .btn-resend:hover {
            background: #142d6f;
            color: #ffffff;
        }

        /* OTP 6-Digit Verification Styles (UC-01 Verification Screen) */
        .otp-container {
            display: flex;
            align-items: center;
            justify-content: center;
            gap: 8px;
            margin: 22px 0 24px;
        }
        .otp-box {
            width: 46px;
            height: 54px;
            text-align: center;
            font-size: 22px;
            font-weight: 800;
            color: #0f172a;
            background: #f8fafc;
            border: 2px solid #cbd5e1;
            border-radius: 12px;
            transition: all 0.2s ease;
            font-family: inherit;
        }
        .otp-box:focus {
            outline: none;
            border-color: #142d6f;
            background: #ffffff;
            box-shadow: 0 0 0 4px rgba(20, 45, 111, 0.12);
            transform: scale(1.05);
        }
        .otp-divider {
            color: #94a3b8;
            font-weight: 700;
            font-size: 18px;
            user-select: none;
        }
        .btn-verify {
            width: 100%;
            height: 48px;
            background: #142d6f;
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
            box-shadow: 0 6px 18px rgba(20, 45, 111, 0.22);
            transition: all 0.2s ease;
        }
        .btn-verify:hover {
            background: #1d3f96;
            transform: translateY(-1px);
        }
        .resend-row {
            margin-top: 20px;
            padding-top: 18px;
            border-top: 1px solid #f1f5f9;
            text-align: center;
            font-size: 12.5px;
            color: #64748b;
        }
        .btn-resend-link {
            background: none;
            border: none;
            color: #142d6f;
            font-weight: 700;
            font-size: 12.5px;
            font-family: inherit;
            cursor: pointer;
            text-decoration: underline;
            padding: 0;
            margin-left: 4px;
        }
        .btn-resend-link:disabled {
            color: #94a3b8;
            cursor: not-allowed;
            text-decoration: none;
        }

        /* Bottom Sign In Link */
        .signin-footer-text {
            margin-top: 20px;
            text-align: center;
            font-size: 13px;
            color: #475569;
        }
        .signin-footer-text a {
            color: #9a4706;
            font-weight: 700;
            text-decoration: none;
            margin-left: 4px;
        }
        .signin-footer-text a:hover {
            text-decoration: underline;
        }

        /* Page Footer */
        .page-footer {
            background: #ffffff;
            border-top: 1px solid #e2e8f0;
            padding: 16px 40px;
            display: flex;
            align-items: center;
            justify-content: space-between;
            font-size: 11.5px;
            color: #64748b;
        }
        .footer-right-links {
            display: flex;
            align-items: center;
            gap: 20px;
        }
        .footer-right-links a {
            color: #475569;
            text-decoration: none;
            font-weight: 600;
        }

        @media (max-width: 860px) {
            .register-card {
                grid-template-columns: 1fr;
            }
            .left-panel {
                display: none;
            }
            .form-row-2col {
                grid-template-columns: 1fr;
            }
        }
    </style>
</head>
<body>

    <!-- Top Navigation Bar -->
    <header class="top-navbar">
        <a href="${pageContext.request.contextPath}/home" class="nav-brand">
            <div class="nav-brand-icon">
                <svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.2">
                    <path d="M2 3h6a4 4 0 0 1 4 4v14a3 3 0 0 0-3-3H2z"></path>
                    <path d="M22 3h-6a4 4 0 0 0-4 4v14a3 3 0 0 1 3-3h7z"></path>
                </svg>
            </div>
            <span class="nav-brand-text">BookStore</span>
        </a>
        <div class="nav-links">
            <a href="${pageContext.request.contextPath}/home" class="nav-link-item">Home</a>
            <a href="${pageContext.request.contextPath}/home" class="nav-link-item">Books</a>
            <a href="${pageContext.request.contextPath}/login" class="nav-link-item">Sign In</a>
            <a href="${pageContext.request.contextPath}/register" class="btn-nav-register">Register</a>
            <div class="user-circle-icon">
                <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                    <path d="M20 21v-2a4 4 0 0 0-4-4H8a4 4 0 0 0-4 4v2"></path>
                    <circle cx="12" cy="7" r="4"></circle>
                </svg>
            </div>
        </div>
    </header>

    <!-- Main Centered Split Card -->
    <main class="main-wrapper">
        <div class="register-card">

            <!-- Left Navy Community Panel -->
            <section class="left-panel">
                <div>
                    <div class="privilege-pill">
                        <svg width="12" height="12" viewBox="0 0 24 24" fill="currentColor">
                            <path d="M12 2L15.09 8.26L22 9.27L17 14.14L18.18 21.02L12 17.77L5.82 21.02L7 14.14L2 9.27L8.91 8.26L12 2Z"/>
                        </svg>
                        READER PRIVILEGE PASS
                    </div>

                    <div class="left-heading">
                        <h2>Join BookStore Today</h2>
                        <p>Discover thousands of books and literary treasures.</p>
                    </div>

                    <div class="art-banner-wrap">
                        <img src="${pageContext.request.contextPath}/static/images/auth-banner.jpg" alt="Join BookStore Today">
                        <div class="art-caption">
                            <span style="color:#f59e0b;">&#10024;</span> Handpicked curations every morning
                        </div>
                    </div>

                    <div class="feature-list">
                        <div class="feature-item">
                            <div class="feature-icon">
                                <svg width="15" height="15" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.2">
                                    <circle cx="12" cy="8" r="7"></circle>
                                    <polyline points="8.21 13.89 7 23 12 20 17 23 15.79 13.88"></polyline>
                                </svg>
                            </div>
                            <div class="feature-text">
                                <h4>Curated collections &amp; rare finds</h4>
                                <p>Exclusive first editions and staff recommendations.</p>
                            </div>
                        </div>

                        <div class="feature-item">
                            <div class="feature-icon">
                                <svg width="15" height="15" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.2">
                                    <path d="M20.59 13.41l-7.17 7.17a2 2 0 0 1-2.83 0L2 12V2h10l8.59 8.59a2 2 0 0 1 0 2.82z"></path>
                                    <line x1="7" y1="7" x2="7.01" y2="7"></line>
                                </svg>
                            </div>
                            <div class="feature-text">
                                <h4>Exclusive member discounts &amp; events</h4>
                                <p>Early access to annual sales and author signings.</p>
                            </div>
                        </div>

                        <div class="feature-item">
                            <div class="feature-icon">
                                <svg width="15" height="15" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.2">
                                    <rect x="2" y="4" width="20" height="16" rx="2"></rect>
                                    <path d="M7 15h0M2 9.5h20"></path>
                                </svg>
                            </div>
                            <div class="feature-text">
                                <h4>Instant order tracking &amp; wishlist</h4>
                                <p>Synchronized reading queue across web and mobile.</p>
                            </div>
                        </div>
                    </div>
                </div>

                <div class="left-bottom-stats">
                    <span class="stat-badge">
                        <span style="color:#f59e0b;">&#128101;</span> 50,000+ Active Readers
                    </span>
                    <span>&bull;</span>
                    <span class="stat-badge">
                        <span style="color:#f59e0b;">&#128274;</span> 256-Bit SSL Protection
                    </span>
                </div>
            </section>

            <!-- Right Registration Form Panel -->
            <section class="right-panel">
                <div class="form-header">
                    <h1><c:choose><c:when test="${registerSuccess}">Xác thực tài khoản</c:when><c:otherwise>Create Account</c:otherwise></c:choose></h1>
                    <p><c:choose><c:when test="${registerSuccess}">Nhập mã 6 chữ số đã được gửi tới email của bạn.</c:when><c:otherwise>Join our literary community and start exploring today.</c:otherwise></c:choose></p>
                </div>

                <!-- Error Alert Box -->
                <c:if test="${not empty errorMessage}">
                    <div class="alert-banner alert-error" id="regErrorAlert">
                        <div class="alert-left">
                            <svg width="17" height="17" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                                <circle cx="12" cy="12" r="10"></circle>
                                <line x1="12" y1="8" x2="12" y2="12"></line>
                                <line x1="12" y1="16" x2="12.01" y2="16"></line>
                            </svg>
                            <span><c:out value="${errorMessage}"/></span>
                        </div>
                        <button type="button" class="alert-close" onclick="document.getElementById('regErrorAlert').style.display='none'">&times;</button>
                    </div>
                </c:if>

                <!-- Success Alert Box -->
                <c:if test="${not empty successMessage}">
                    <div class="alert-banner alert-success" id="regSuccessAlert">
                        <div class="alert-left">
                            <svg width="17" height="17" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                                <path d="M22 11.08V12a10 10 0 1 1-5.93-9.14"></path>
                                <polyline points="22 4 12 14.01 9 11.01"></polyline>
                            </svg>
                            <span><c:out value="${successMessage}"/></span>
                        </div>
                        <button type="button" class="alert-close" onclick="document.getElementById('regSuccessAlert').style.display='none'">&times;</button>
                    </div>
                </c:if>

                <c:choose>
                    <%-- State 1: Email Verification OTP Screen (after successful registration or resend) --%>
                    <c:when test="${registerSuccess}">
                        <div class="verify-pending-box" style="text-align: left; padding: 22px 24px;">
                            <div style="display:flex; align-items:center; gap: 12px; margin-bottom: 14px;">
                                <div class="verify-icon-circle" style="margin: 0; width: 44px; height: 44px; flex-shrink: 0;">
                                    <svg width="22" height="22" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                                        <path d="M4 4h16c1.1 0 2 .9 2 2v12c0 1.1-.9 2-2 2H4c-1.1 0-2-.9-2-2V6c0-1.1.9-2 2-2z"></path>
                                        <polyline points="22,6 12,13 2,6"></polyline>
                                    </svg>
                                </div>
                                <div>
                                    <h3 style="font-size: 16px; margin: 0; font-weight: 800; color: #0f172a;">Kiểm tra hộp thư đến</h3>
                                    <p style="font-size: 12.5px; color: #64748b; margin: 0;">
                                        Mã xác thực đã được gửi tới: <strong style="color:#142d6f;"><c:out value="${registeredEmail}"/></strong>
                                    </p>
                                </div>
                            </div>

                            <!-- OTP Code Verification Form -->
                            <form action="${pageContext.request.contextPath}/verify-email" method="POST" id="otpForm" style="margin-top: 10px;">
                                <input type="hidden" name="email" value="<c:out value='${registeredEmail}'/>" />
                                <div class="otp-container">
                                    <input type="text" maxlength="1" pattern="[0-9]" inputmode="numeric" class="otp-box" autofocus />
                                    <input type="text" maxlength="1" pattern="[0-9]" inputmode="numeric" class="otp-box" />
                                    <input type="text" maxlength="1" pattern="[0-9]" inputmode="numeric" class="otp-box" />
                                    <span class="otp-divider">-</span>
                                    <input type="text" maxlength="1" pattern="[0-9]" inputmode="numeric" class="otp-box" />
                                    <input type="text" maxlength="1" pattern="[0-9]" inputmode="numeric" class="otp-box" />
                                    <input type="text" maxlength="1" pattern="[0-9]" inputmode="numeric" class="otp-box" />
                                </div>
                                <input type="hidden" name="token" id="fullToken" value="" />

                                <button type="submit" class="btn-verify">
                                    <span>Xác nhận &amp; Kích hoạt tài khoản</span>
                                    <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5">
                                        <line x1="5" y1="12" x2="19" y2="12"></line>
                                        <polyline points="12 5 19 12 12 19"></polyline>
                                    </svg>
                                </button>
                            </form>

                            <!-- Resend Code Form -->
                            <div class="resend-row">
                                <form action="${pageContext.request.contextPath}/resend-activation" method="POST" id="resendForm" style="display: inline-flex; align-items: center; justify-content: center; gap: 4px;">
                                    <input type="hidden" name="email" value="<c:out value='${registeredEmail}'/>">
                                    <span>Chưa nhận được mã?</span>
                                    <button type="submit" id="resendBtn" disabled class="btn-resend-link">
                                        Gửi lại mã (<span id="countdown">59</span>s)
                                    </button>
                                </form>
                                <p style="font-size: 11px; color: #94a3b8; margin-top: 6px;">
                                    Vui lòng kiểm tra thêm thư mục <em>Spam / Thư rác</em> nếu không thấy mã.
                                </p>
                            </div>
                        </div>
                    </c:when>

                    <%-- State 2: Standard Registration Form --%>
                    <c:otherwise>
                        <form action="${pageContext.request.contextPath}/register" method="post" novalidate>
                            <!-- Full Name -->
                            <div class="form-group">
                                <label for="fullName" class="form-label">Full Name</label>
                                <div class="input-wrapper">
                                    <span class="input-icon-left">
                                        <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                                            <path d="M20 21v-2a4 4 0 0 0-4-4H8a4 4 0 0 0-4 4v2"></path>
                                            <circle cx="12" cy="7" r="4"></circle>
                                        </svg>
                                    </span>
                                    <input type="text"
                                           id="fullName"
                                           name="fullName"
                                           class="form-input ${not empty validationErrors['fullName'] ? 'is-invalid' : ''}"
                                           placeholder="Enter your full name"
                                           value="<c:out value='${fullName}'/>"
                                           required>
                                </div>
                                <c:if test="${not empty validationErrors['fullName']}">
                                    <div class="field-error"><c:out value="${validationErrors['fullName']}"/></div>
                                </c:if>
                            </div>

                            <!-- Email Address -->
                            <div class="form-group">
                                <label for="email" class="form-label">Email Address</label>
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
                                <c:if test="${not empty validationErrors['email']}">
                                    <div class="field-error"><c:out value="${validationErrors['email']}"/></div>
                                </c:if>
                            </div>

                            <!-- Phone Number -->
                            <div class="form-group">
                                <label for="phone" class="form-label">Phone Number</label>
                                <div class="input-wrapper">
                                    <span class="input-icon-left">
                                        <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                                            <path d="M22 16.92v3a2 2 0 0 1-2.18 2 19.79 19.79 0 0 1-8.63-3.07 19.5 19.5 0 0 1-6-6 19.79 19.79 0 0 1-3.07-8.67A2 2 0 0 1 4.11 2h3a2 2 0 0 1 2 1.72 12.84 12.84 0 0 0 .7 2.81 2 2 0 0 1-.45 2.11L8.09 9.91a16 16 0 0 0 6 6l1.27-1.27a2 2 0 0 1 2.11-.45 12.84 12.84 0 0 0 2.81.7A2 2 0 0 1 22 16.92z"></path>
                                        </svg>
                                    </span>
                                    <input type="tel"
                                           id="phone"
                                           name="phone"
                                           class="form-input ${not empty validationErrors['phone'] ? 'is-invalid' : ''}"
                                           placeholder="0901234567"
                                           value="<c:out value='${phone}'/>"
                                           required>
                                </div>
                                <c:if test="${not empty validationErrors['phone']}">
                                    <div class="field-error"><c:out value="${validationErrors['phone']}"/></div>
                                </c:if>
                            </div>

                            <!-- Side-by-Side Password & Confirm Password -->
                            <div class="form-row-2col">
                                <div>
                                    <label for="password" class="form-label">Password</label>
                                    <div class="input-wrapper">
                                        <span class="input-icon-left">
                                            <svg width="15" height="15" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                                                <rect x="3" y="11" width="18" height="11" rx="2" ry="2"></rect>
                                                <path d="M7 11V7a5 5 0 0 1 10 0v4"></path>
                                            </svg>
                                        </span>
                                        <input type="password"
                                               id="password"
                                               name="password"
                                               class="form-input ${not empty validationErrors['password'] ? 'is-invalid' : ''}"
                                               placeholder="At least 8 characters"
                                               required>
                                        <button type="button" class="toggle-password" onclick="togglePasswordVisibility('password')" aria-label="Toggle password">
                                            <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                                                <path d="M1 12s4-8 11-8 11 8 11 8-4 8-11 8-11-8-11-8z"></path>
                                                <circle cx="12" cy="12" r="3"></circle>
                                            </svg>
                                        </button>
                                    </div>
                                    <c:if test="${not empty validationErrors['password']}">
                                        <div class="field-error"><c:out value="${validationErrors['password']}"/></div>
                                    </c:if>
                                </div>

                                <div>
                                    <label for="confirmPassword" class="form-label">Confirm Password</label>
                                    <div class="input-wrapper">
                                        <span class="input-icon-left">
                                            <svg width="15" height="15" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                                                <path d="M12 22s8-4 8-10V5l-8-3-8 3v7c0 6 8 10 8 10z"></path>
                                            </svg>
                                        </span>
                                        <input type="password"
                                               id="confirmPassword"
                                               name="confirmPassword"
                                               class="form-input ${not empty validationErrors['confirmPassword'] ? 'is-invalid' : ''}"
                                               placeholder="Re-enter your password"
                                               required>
                                        <button type="button" class="toggle-password" onclick="togglePasswordVisibility('confirmPassword')" aria-label="Toggle confirm password">
                                            <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                                                <path d="M1 12s4-8 11-8 11 8 11 8-4 8-11 8-11-8-11-8z"></path>
                                                <circle cx="12" cy="12" r="3"></circle>
                                            </svg>
                                        </button>
                                    </div>
                                    <c:if test="${not empty validationErrors['confirmPassword']}">
                                        <div class="field-error"><c:out value="${validationErrors['confirmPassword']}"/></div>
                                    </c:if>
                                </div>
                            </div>

                            <!-- Terms Checkbox -->
                            <div class="terms-row">
                                <input type="checkbox" id="agreeTerms" name="agreeTerms" checked>
                                <label for="agreeTerms">
                                    I agree to the <a href="#">Terms of Service</a> and <a href="#">Privacy Policy</a>.
                                </label>
                            </div>

                            <!-- Register Button -->
                            <button type="submit" class="btn-register">
                                Register
                                <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.2">
                                    <line x1="5" y1="12" x2="19" y2="12"></line>
                                    <polyline points="12 5 19 12 12 19"></polyline>
                                </svg>
                            </button>
                        </form>
                    </c:otherwise>
                </c:choose>

                <!-- Bottom Sign In Link -->
                <div class="signin-footer-text">
                    Already have an account?
                    <a href="${pageContext.request.contextPath}/login">Sign In &rsaquo;</a>
                </div>
            </section>

        </div>
    </main>

    <!-- Bottom Footer -->
    <footer class="page-footer">
        <span>&copy; 2026 BookStore Management Systems Inc. All rights reserved.</span>
        <div class="footer-right-links">
            <a href="#">Privacy Policy</a>
            <a href="#">Terms of Service</a>
        </div>
    </footer>

    <script>
        function togglePasswordVisibility(inputId) {
            var field = document.getElementById(inputId);
            if (field) {
                field.type = (field.type === 'password') ? 'text' : 'password';
            }
        }

        // OTP Auto-Focus & Resend Countdown Logic (State 1: Verification Screen)
        (function() {
            var inputs = document.querySelectorAll('.otp-box');
            var fullToken = document.getElementById('fullToken');
            var resendBtn = document.getElementById('resendBtn');
            var countdown = document.getElementById('countdown');

            if (inputs.length > 0) {
                inputs.forEach(function(input, index) {
                    input.addEventListener('input', function(e) {
                        var val = e.target.value.replace(/[^a-zA-Z0-9]/g, '');
                        e.target.value = val;
                        if (val && index < inputs.length - 1) {
                            inputs[index + 1].focus();
                        }
                        updateFullToken();
                    });

                    input.addEventListener('keydown', function(e) {
                        if (e.key === 'Backspace' && !input.value && index > 0) {
                            inputs[index - 1].focus();
                        }
                    });

                    input.addEventListener('paste', function(e) {
                        e.preventDefault();
                        var pasted = (e.clipboardData || window.clipboardData).getData('text').replace(/\s+/g, '').slice(0, 6);
                        if (pasted) {
                            pasted.split('').forEach(function(ch, i) {
                                if (inputs[i]) inputs[i].value = ch;
                            });
                            if (inputs[pasted.length - 1]) {
                                inputs[pasted.length - 1].focus();
                            }
                            updateFullToken();
                        }
                    });
                });

                function updateFullToken() {
                    var code = '';
                    inputs.forEach(function(i) { code += i.value.trim(); });
                    if (fullToken) fullToken.value = code;
                }

                var otpForm = document.getElementById('otpForm');
                if (otpForm) {
                    otpForm.addEventListener('submit', function() {
                        updateFullToken();
                    });
                }

                // 60s Resend Countdown
                if (resendBtn && countdown) {
                    var timeLeft = 59;
                    var timer = setInterval(function() {
                        timeLeft--;
                        countdown.textContent = timeLeft;
                        if (timeLeft <= 0) {
                            clearInterval(timer);
                            resendBtn.disabled = false;
                            resendBtn.innerHTML = "Gửi lại mã ngay";
                        }
                    }, 1000);
                }
            }
        })();
    </script>
</body>
</html>
