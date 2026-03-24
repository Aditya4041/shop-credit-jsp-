<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.sql.*, doa.DBConnection" %>
<%
    if (session.getAttribute("admin") == null) {
        response.sendRedirect("login.jsp?error=Please login first");
        return;
    }
    String idStr = request.getParameter("id");
    if (idStr == null) {
        response.sendRedirect("view_customers.jsp");
        return;
    }
    int customerId = Integer.parseInt(idStr);

    String custName = "", custPhone = "";
    double custCredit = 0;
    int txnCount = 0;
    double totalAdded = 0, totalSettled = 0;

    try (Connection conn = DBConnection.getConnection()) {
        PreparedStatement ps = conn.prepareStatement("SELECT * FROM customers WHERE id = ?");
        ps.setInt(1, customerId);
        ResultSet rs = ps.executeQuery();
        if (rs.next()) {
            custName   = rs.getString("name");
            custPhone  = rs.getString("phone");
            custCredit = rs.getDouble("credit");
        }
        PreparedStatement psTxn = conn.prepareStatement(
            "SELECT COUNT(*), " +
            "SUM(CASE WHEN transaction_type='ADD' THEN amount ELSE 0 END), " +
            "SUM(CASE WHEN transaction_type='SETTLE' THEN amount ELSE 0 END) " +
            "FROM customer_transactions WHERE customer_id = ?");
        psTxn.setInt(1, customerId);
        ResultSet rsTxn = psTxn.executeQuery();
        if (rsTxn.next()) {
            txnCount     = rsTxn.getInt(1);
            totalAdded   = rsTxn.getDouble(2);
            totalSettled = rsTxn.getDouble(3);
        }
    } catch (Exception e) { /* ignore */ }
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>Customer Details</title>
    <link rel="stylesheet" href="css/content.css">
</head>
<body>

<!-- Page Header -->
<div class="page-header">
    <div>
        <h2>📄 Customer Details</h2>
        <div class="breadcrumb">Home › View Customers › Details</div>
    </div>
</div>

<div class="content-wrapper">

    <!-- Back Link -->
    <a href="view_customers.jsp" class="back-link">← Back to Customer List</a>

    <!-- Customer Info Card -->
    <div class="detail-info-card">
        <div class="info-item">
            <span class="info-label">Customer ID</span>
            <span class="info-value">#<%= customerId %></span>
        </div>
        <div class="info-item">
            <span class="info-label">Name</span>
            <span class="info-value">👤 <%= custName %></span>
        </div>
        <div class="info-item">
            <span class="info-label">Phone</span>
            <span class="info-value">📞 <%= custPhone %></span>
        </div>
        <div class="info-item">
            <span class="info-label">Current Credit</span>
            <span class="info-value credit-amount">₹ <%= String.format("%.2f", custCredit) %></span>
        </div>
    </div>

    <!-- Stats Row -->
    <div class="stats-row">
        <div class="stat-chip">
            <div class="s-label">Total Transactions</div>
            <div class="s-value"><%= txnCount %></div>
        </div>
        <div class="stat-chip green">
            <div class="s-label">Total Added</div>
            <div class="s-value">₹ <%= String.format("%.2f", totalAdded) %></div>
        </div>
        <div class="stat-chip red">
            <div class="s-label">Total Settled</div>
            <div class="s-value">₹ <%= String.format("%.2f", totalSettled) %></div>
        </div>
        <div class="stat-chip">
            <div class="s-label">Net Credit</div>
            <div class="s-value" style="color:#2b0d73;">₹ <%= String.format("%.2f", custCredit) %></div>
        </div>
    </div>

    <!-- Transaction History Table -->
    <h3 style="font-size:16px; color:#373279; font-weight:700; margin-bottom:12px;
               border-bottom:2px solid #c8b7f6; padding-bottom:8px;">
        📊 Transaction History
    </h3>

    <div class="table-container">
        <table>
            <thead>
                <tr>
                    <th>#</th>
                    <th>Txn ID</th>
                    <th>Date</th>
                    <th>Type</th>
                    <th>Amount (₹)</th>
                </tr>
            </thead>
            <tbody>
            <%
                int sNo = 1;
                try (Connection conn = DBConnection.getConnection()) {
                    PreparedStatement ps = conn.prepareStatement(
                        "SELECT * FROM customer_transactions WHERE customer_id = ? ORDER BY transaction_date DESC");
                    ps.setInt(1, customerId);
                    ResultSet rs = ps.executeQuery();
                    boolean hasTxn = false;

                    while (rs.next()) {
                        hasTxn = true;
                        String type = rs.getString("transaction_type");
            %>
                <tr>
                    <td><%= sNo++ %></td>
                    <td><strong><%= rs.getInt("id") %></strong></td>
                    <td><%= rs.getDate("transaction_date") %></td>
                    <td>
                        <% if ("ADD".equals(type)) { %>
                        <span class="badge-add">➕ ADD</span>
                        <% } else { %>
                        <span class="badge-settle">✅ SETTLE</span>
                        <% } %>
                    </td>
                    <td style="font-weight:700;
                        color:<%= "ADD".equals(type) ? "#2e7d32" : "#c62828" %>;">
                        ₹ <%= String.format("%.2f", rs.getDouble("amount")) %>
                    </td>
                </tr>
            <%
                    }
                    if (!hasTxn) {
            %>
                <tr><td colspan="5" class="no-data">No transactions found for this customer.</td></tr>
            <%
                    }
                } catch (Exception e) {
            %>
                <tr><td colspan="5" class="no-data">❌ Error: <%= e.getMessage() %></td></tr>
            <%
                }
            %>
            </tbody>
        </table>
    </div>
</div>

</body>
</html>
