<%
    if (session.getAttribute("admin") == null) {
        response.sendRedirect("login.jsp?error=Please login first");
        return;
    }
%>

<%@ page contentType="text/html;charset=UTF-8" %>
<html>
<head>
    <title>Shop Credit Manager</title>
    <link rel="stylesheet" href="style.css">
</head>
<body>
<jsp:include page="navbar.jsp" />
<div class="card-container">
    <div class="card" onclick="location.href='add_customer.jsp'">Add Customer</div>
    <div class="card" onclick="location.href='view_customers.jsp'">View Customers</div>
	<div class="card" onclick="location.href='add_dealer.jsp'">Add Dealer</div>
 	<div class="card" onclick="location.href='view_dealers.jsp'">View Dealers</div>
</div>


</body>
</html>
