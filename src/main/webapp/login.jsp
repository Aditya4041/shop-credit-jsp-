<%@ page contentType="text/html;charset=UTF-8" %>
<!DOCTYPE html>
<html>
<head>
    <title>Admin Login | Shop Credit Manager</title>
    <link rel="stylesheet" href="style.css">
    <style>
        .login-container {
            background-color: #2e2e4d;
            width: 400px;
            margin: 100px auto;
            padding: 40px;
            border-radius: 16px;
            box-shadow: 0 0 20px rgba(0,0,0,0.5);
        }

        .login-container h2 {
            margin-bottom: 25px;
            color: #ffffff;
        }

        .login-container input[type="text"],
        .login-container input[type="password"] {
            width: 80%;
            padding: 10px;
            border-radius: 8px;
            border: none;
            margin-bottom: 20px;
            text-align: center;
            background-color: #1e1e2f;
            color: #fff;
        }

        .login-container input::placeholder {
            color: #aaa;
        }

        .login-container input[type="submit"] {
            width: 85%;
            background-color: #6c63ff;
            color: white;
            font-weight: bold;
            border: none;
            border-radius: 8px;
            padding: 10px;
            cursor: pointer;
            transition: 0.3s;
        }

        .login-container input[type="submit"]:hover {
            background-color: #574fd1;
        }

        .error, .success {
            margin-top: 15px;
            font-weight: bold;
        }

        .error { color: #ff4d4d; }
        .success { color: #6c63ff; }
    </style>
</head>
<body>

<h1 style="margin-top:40px;">Shop Credit Manager</h1>

<div class="login-container">
    <h2>Admin Login</h2>

    <form action="LoginServlet" method="post">
        <input type="text" name="username" placeholder="Enter Username" required><br>
        <input type="password" name="password" placeholder="Enter Password" required><br>
        <input type="submit" value="Login">
    </form>

    <% if(request.getParameter("error") != null) { %>
        <p class="error"><%= request.getParameter("error") %></p>
    <% } %>

    <% if(request.getParameter("logout") != null) { %>
        <p class="success">Logged out successfully.</p>
    <% } %>
</div>

</body>
</html>
