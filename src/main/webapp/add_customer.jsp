<%
    if (session.getAttribute("admin") == null) {
        response.sendRedirect("login.jsp?error=Please login first");
        return;
    }
%>

<%@ page contentType="text/html;charset=UTF-8" %>
<html>
<head>
    <title>Add Customer</title>
    <link rel="stylesheet" href="style.css">
</head>
<body>
<jsp:include page="navbar.jsp" />

<h2>Add New Customer</h2>

<form action="AddCustomerServlet" method="post">
    <input type="text" name="name" placeholder="Customer Name" required><br><br>
    <input type="text" name="phone" placeholder="Phone" required><br><br>
    <input type="number" name="credit" placeholder="Initial Credit" step="0.01" required><br><br>
    <input type="submit" class="btn add" value="Add Customer">
</form>

<% if(request.getParameter("error") != null) { %>
    <p style="color:#ff4d4d;"><%= request.getParameter("error") %></p>
<% } %>
<% if(request.getParameter("success") != null) { %>
    <p style="color:#6c63ff;"><%= request.getParameter("success") %></p>
<% } %>

</body>
</html>
