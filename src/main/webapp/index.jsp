<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.sql.*, doa.DBConnection" %>
<%
    if (session.getAttribute("admin") == null) {
        response.sendRedirect("login.jsp?error=Please login first");
        return;
    }

    int totalCustomers = 0, totalDealers = 0;
    double totalCustomerCredit = 0, totalDealerCredit = 0;

    try (Connection conn = DBConnection.getConnection()) {
        ResultSet rs1 = conn.createStatement().executeQuery("SELECT COUNT(*) FROM customers");
        if (rs1.next()) totalCustomers = rs1.getInt(1);

        ResultSet rs2 = conn.createStatement().executeQuery("SELECT SUM(credit) FROM customers");
        if (rs2.next()) totalCustomerCredit = rs2.getDouble(1);

        ResultSet rs3 = conn.createStatement().executeQuery("SELECT COUNT(*) FROM dealers");
        if (rs3.next()) totalDealers = rs3.getInt(1);

        ResultSet rs4 = conn.createStatement().executeQuery("SELECT SUM(credit) FROM dealers");
        if (rs4.next()) totalDealerCredit = rs4.getDouble(1);
    } catch (Exception e) { /* ignore for display */ }
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>Dashboard</title>
    <link rel="stylesheet" href="css/content.css">
    <style>
        body { padding: 0; }
        .welcome-banner {
            background: linear-gradient(135deg, #182542 0%, #2a5a8f 100%);
            color: #fff;
            padding: 28px 32px;
            margin-bottom: 0;
        }
        .welcome-banner h1 { font-size: 22px; font-weight: 700; margin-bottom: 4px; }
        .welcome-banner p  { font-size: 14px; color: #90b8d4; }
        .section-label {
            padding: 24px 28px 8px;
            font-size: 13px;
            font-weight: 700;
            color: #888;
            text-transform: uppercase;
            letter-spacing: 1px;
        }
    </style>
</head>
<body>

<div class="section-label">Quick Actions</div>

<div class="cards-grid" style="padding-top: 8px;">

    <div class="dash-card card-blue" onclick="parent.loadPage('add_customer.jsp','Add Customer',null)">
        <div class="card-icon">➕</div>
        <div>
            <h3>Add Customer</h3>
            <p>Register a new customer with credit limit</p>
        </div>
    </div>

    <div class="dash-card card-green" onclick="parent.loadPage('view_customers.jsp','View Customers',null)">
        <div class="card-icon">👥</div>
        <div>
            <h3>View Customers</h3>
            <p>Manage credit &amp; transactions</p>
        </div>
    </div>

    <div class="dash-card card-orange" onclick="parent.loadPage('add_dealer.jsp','Add Dealer',null)">
        <div class="card-icon">🏬</div>
        <div>
            <h3>Add Dealer</h3>
            <p>Register a new dealer with credit limit</p>
        </div>
    </div>

    <div class="dash-card card-purple" onclick="parent.loadPage('view_dealers.jsp','View Dealers',null)">
        <div class="card-icon">📋</div>
        <div>
            <h3>View Dealers</h3>
            <p>Manage dealer credit &amp; transactions</p>
        </div>
    </div>

</div>

<div class="section-label">Overview</div>

<div class="cards-grid" style="padding-top: 8px; grid-template-columns: repeat(4,1fr);">

    <div class="dash-card card-teal" style="cursor:default;">
        <div class="card-icon">👤</div>
        <div>
            <h3>Total Customers</h3>
            <p style="font-size:28px; font-weight:800; opacity:1;"><%= totalCustomers %></p>
        </div>
    </div>

    <div class="dash-card card-green" style="cursor:default;">
        <div class="card-icon">💰</div>
        <div>
            <h3>Customer Credit</h3>
            <p style="font-size:22px; font-weight:800; opacity:1;">₹ <%= String.format("%.2f", totalCustomerCredit) %></p>
        </div>
    </div>

    <div class="dash-card card-orange" style="cursor:default;">
        <div class="card-icon">🏬</div>
        <div>
            <h3>Total Dealers</h3>
            <p style="font-size:28px; font-weight:800; opacity:1;"><%= totalDealers %></p>
        </div>
    </div>

    <div class="dash-card card-red" style="cursor:default;">
        <div class="card-icon">💳</div>
        <div>
            <h3>Dealer Credit</h3>
            <p style="font-size:22px; font-weight:800; opacity:1;">₹ <%= String.format("%.2f", totalDealerCredit) %></p>
        </div>
    </div>

</div>

</body>
</html>
