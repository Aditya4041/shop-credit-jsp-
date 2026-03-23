<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%
    if (session.getAttribute("admin") == null) {
        response.sendRedirect("login.jsp?error=Please login first");
        return;
    }
%>
<!DOCTYPE html>
<html>
<head>
    <title>Add Dealer</title>
    <style>
        body {
            font-family: 'Poppins', sans-serif;
            background: linear-gradient(135deg, #1a1a2e, #16213e);
            color: white;
            text-align: center;
            margin: 0;
        }
        .navbar {
    background-color: #2e2e4d;
    padding: 15px;
    display: flex;
    justify-content: center;
    gap: 30px;
}

.navbar a {
    color: #ffffff;
    text-decoration: none;
    font-weight: bold;
    transition: 0.3s;
}

.navbar a:hover {
    color: #6c63ff;
}
        .container {
            margin-top: 80px;
        }
        form {
            background-color: #16213e;
            display: inline-block;
            padding: 30px;
            border-radius: 15px;
            box-shadow: 0 0 15px rgba(255,255,255,0.1);
        }
        input {
            width: 250px;
            padding: 10px;
            margin: 10px 0;
            border: none;
            border-radius: 8px;
        }
        button {
            background-color: #e94560;
            border: none;
            padding: 10px 20px;
            color: white;
            font-weight: bold;
            border-radius: 10px;
            cursor: pointer;
        }
        button:hover {
            background-color: #ff5f7e;
        }
    </style>
</head>
<body>

   <jsp:include page="navbar.jsp" />

    <div class="container">
        <h2>Add New Dealer</h2>
        <form action="AddDealerServlet" method="post">
            <input type="text" name="name" placeholder="Dealer Name" required><br>
            <input type="text" name="phone" placeholder="Phone Number" required><br>
            <input type="number" name="credit" placeholder="Initial Credit Amount" required><br>
            <button type="submit">Add Dealer</button>
        </form>
    </div>

</body>
</html>
