
<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>User Management</title>

    <style>
        * {
            box-sizing: border-box;
        }

        body {
            margin: 0;
            padding: 30px;
            background: #f4f6f9;
            color: #263238;
            font-family: Arial, sans-serif;
        }

        .container {
            max-width: 1200px;
            margin: 0 auto;
        }

        .header {
            display: flex;
            justify-content: space-between;
            align-items: center;
            gap: 16px;
            flex-wrap: wrap;
            margin-bottom: 24px;
        }

        h1 {
            margin: 0 0 8px;
            font-size: 28px;
        }

        .subtitle {
            margin: 0;
            color: #687386;
        }

        .card {
            background: #ffffff;
            padding: 24px;
            border-radius: 10px;
            box-shadow: 0 3px 12px rgba(0, 0, 0, 0.06);
        }

        .message {
            padding: 12px 16px;
            margin-bottom: 18px;
            border-radius: 6px;
            background: #e8f5e9;
            color: #256029;
        }

        .table-wrapper {
            overflow-x: auto;
        }

        table {
            width: 100%;
            border-collapse: collapse;
            white-space: nowrap;
        }

        th, td {
            padding: 14px 12px;
            border-bottom: 1px solid #e8ebef;
            text-align: left;
        }

        th {
            background: #f8fafc;
            color: #526071;
            font-size: 13px;
            text-transform: uppercase;
        }

        tbody tr:hover {
            background: #fafcff;
        }

        .status {
            display: inline-block;
            padding: 5px 10px;
            border-radius: 20px;
            font-size: 12px;
            font-weight: bold;
        }

        .status-active {
            background: #e2f7e8;
            color: #18753a;
        }

        .status-locked {
            background: #ffebee;
            color: #b42318;
        }

        .status-other {
            background: #fff4d6;
            color: #8a6100;
        }

        .action-form {
            display: inline;
        }

        .btn {
            display: inline-block;
            border: none;
            border-radius: 5px;
            padding: 9px 12px;
            color: white;
            font-weight: bold;
            cursor: pointer;
        }

        .btn-lock {
            background: #c62828;
        }

        .btn-unlock {
            background: #218838;
        }

        .btn:disabled {
            background: #aab2bd;
            cursor: not-allowed;
        }

        .empty {
            padding: 30px;
            text-align: center;
            color: #687386;
        }

        .verified {
            color: #18753a;
            font-weight: bold;
        }

        .unverified {
            color: #8a6100;
        }

        .back-link {
            color: #2457c5;
            text-decoration: none;
        }

        @media (max-width: 600px) {
            body {
                padding: 14px;
            }

            .card {
                padding: 12px;
            }

            h1 {
                font-size: 23px;
            }
        }
    </style>
</head>

<body>
<div class="container">

    <div class="header">
        <div>
            <h1>User Management</h1>
            <p class="subtitle">
                View user accounts and manage account status.
            </p>
        </div>

        <a class="back-link"
           href="${pageContext.request.contextPath}/dashboard/admin">
            Back to Home
        </a>
    </div>

    <c:if test="${not empty param.message}">
        <div class="message">
            <c:out value="${param.message}" />
        </div>
    </c:if>

    <div class="card">
        <div class="table-wrapper">
            <table>
                <thead>
                <tr>
                    <th>ID</th>
                    <th>Full Name</th>
                    <th>Email</th>
                    <th>Phone</th>
                    <th>Email Verified</th>
                    <th>Status</th>
                    <th>Created At</th>
                    <th>Action</th>
                </tr>
                </thead>

                <tbody>
                <c:choose>
                    <c:when test="${empty users}">
                        <tr>
                            <td colspan="8" class="empty">
                                No user accounts found.
                            </td>
                        </tr>
                    </c:when>

                    <c:otherwise>
                        <c:forEach var="user" items="${users}">
                            <tr>
                                <td>
                                    <c:out value="${user.id}" />
                                </td>

                                <td>
                                    <c:out value="${user.fullName}" />
                                </td>

                                <td>
                                    <c:out value="${user.email}" />
                                </td>

                                <td>
                                    <c:out value="${user.phoneNumber}" />
                                </td>

                                <td>
                                    <c:choose>
                                        <c:when test="${user.emailVerified}">
                                            <span class="verified">Verified</span>
                                        </c:when>
                                        <c:otherwise>
                                            <span class="unverified">
                                                Not verified
                                            </span>
                                        </c:otherwise>
                                    </c:choose>
                                </td>

                                <td>
                                    <c:choose>
                                        <c:when test="${user.status eq 'ACTIVE'}">
                                            <span class="status status-active">
                                                ACTIVE
                                            </span>
                                        </c:when>

                                        <c:when test="${user.status eq 'LOCKED'}">
                                            <span class="status status-locked">
                                                LOCKED
                                            </span>
                                        </c:when>

                                        <c:otherwise>
                                            <span class="status status-other">
                                                <c:out value="${user.status}" />
                                            </span>
                                        </c:otherwise>
                                    </c:choose>
                                </td>

                                <td>
                                    <c:if test="${not empty user.createdAt}">
                                        <fmt:formatDate
                                            value="${user.createdAt}"
                                            pattern="dd/MM/yyyy HH:mm" />
                                    </c:if>
                                </td>

                                <td>
                                    <c:choose>
                                        <c:when test="${user.status eq 'ACTIVE'}">
                                            <form class="action-form"
                                                  method="post"
                                                  action="${pageContext.request.contextPath}/dashboard/admin/users"
                                                  onsubmit="return confirm('Lock this user account?');">

                                                <input type="hidden"
                                                       name="userId"
                                                       value="<c:out value='${user.id}' />">

                                                <input type="hidden"
                                                       name="status"
                                                       value="LOCKED">

                                                <button class="btn btn-lock"
                                                        type="submit">
                                                    Lock
                                                </button>
                                            </form>
                                        </c:when>

                                        <c:when test="${user.status eq 'LOCKED'}">
                                            <form class="action-form"
                                                  method="post"
                                                  action="${pageContext.request.contextPath}/dashboard/admin/users"
                                                  onsubmit="return confirm('Unlock this user account?');">

                                                <input type="hidden"
                                                       name="userId"
                                                       value="<c:out value='${user.id}' />">

                                                <input type="hidden"
                                                       name="status"
                                                       value="ACTIVE">

                                                <button class="btn btn-unlock"
                                                        type="submit">
                                                    Unlock
                                                </button>
                                            </form>
                                        </c:when>

                                        <c:otherwise>
                                            <span>Not available</span>
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
</div>
</body>
</html>
