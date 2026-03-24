<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%
    // If already logged in, redirect to main
    if (session.getAttribute("admin") != null) {
        response.sendRedirect("main.jsp");
        return;
    }
    String errorMsg = request.getParameter("error");
    String logoutMsg = request.getParameter("logout");
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Login — Mauali Tredars</title>
    <link rel="stylesheet" href="css/login.css">
</head>
<body>

<div class="login-container">

    <!-- Brand -->
    <div class="brand-section">
        <div class="brand-icon">🏪</div>
        <div class="brand-title">Mauali Tredars</div>
        <div class="brand-sub">Shop Credit Management System — Secure Access</div>
    </div>

    <!-- Login Card -->
    <div class="login-card">
        <h2>Admin Login</h2>

        <% if (errorMsg != null) { %>
        <div class="error-msg">❌ <%= errorMsg %></div>
        <% } %>
        <% if (logoutMsg != null) { %>
        <div class="error-msg" style="background:rgba(0,200,100,0.15); border-color:rgba(0,200,100,0.4); color:#d0ffe8;">
            ✅ Logged out successfully.
        </div>
        <% } %>

        <form action="LoginServlet" method="post" autocomplete="off">

            <div class="field-group">
                <label for="username">👤 Username</label>
                <input type="text" id="username" name="username"
                       placeholder="Enter your username" required autofocus>
            </div>

            <div class="field-group">
                <label for="password">🔒 Password</label>
                <input type="password" id="password" name="password"
                       placeholder="Enter your password" required>
            </div>

            <button type="submit" class="btn-login">Login →</button>
        </form>
    </div>

    <div class="login-footer">© 2025 Mauali Tredars. All rights reserved.</div>
</div>

</body>
</html>
