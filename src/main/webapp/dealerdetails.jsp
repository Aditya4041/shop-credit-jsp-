<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.sql.*, doa.DBConnection" %>
<%
    if (session.getAttribute("admin") == null) {
        response.sendRedirect("login.jsp?error=Please login first");
        return;
    }
    String dealerIdStr = request.getParameter("dealer_id");
    if (dealerIdStr == null) {
        response.sendRedirect("view_dealers.jsp");
        return;
    }
    int dealerId = Integer.parseInt(dealerIdStr);

    String dealerName = "", dealerPhone = "";
    double dealerCredit = 0;
    int txnCount = 0;
    double totalAdded = 0, totalSettled = 0;

    try (Connection conn = DBConnection.getConnection()) {
        PreparedStatement ps = conn.prepareStatement("SELECT * FROM dealers WHERE id = ?");
        ps.setInt(1, dealerId);
        ResultSet rs = ps.executeQuery();
        if (rs.next()) {
            dealerName   = rs.getString("name");
            dealerPhone  = rs.getString("phone");
            dealerCredit = rs.getDouble("credit");
        }
        PreparedStatement psTxn = conn.prepareStatement(
            "SELECT COUNT(*), " +
            "SUM(CASE WHEN transaction_type='ADD' THEN amount ELSE 0 END), " +
            "SUM(CASE WHEN transaction_type='SETTLE' THEN amount ELSE 0 END) " +
            "FROM dealer_transactions WHERE dealer_id = ?");
        psTxn.setInt(1, dealerId);
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
    <title>Dealer Details</title>
    <link rel="stylesheet" href="css/content.css">
    <style>
        .product-tag {
            background: #e8f0fe;
            color: #1a56db;
            padding: 3px 10px;
            border-radius: 20px;
            font-size: 12px;
            font-weight: 600;
            white-space: nowrap;
        }
        .product-tag.settle {
            background: #fef3e2;
            color: #b45309;
        }
    </style>
</head>
<body>

<div class="content-wrapper">

    <a href="view_dealers.jsp" class="back-link">← Back to Dealer List</a>

    <!-- Dealer Info Card -->
    <div class="detail-info-card" style="border-left-color: #f5a623;">
        <div class="info-item">
            <span class="info-label">Dealer ID</span>
            <span class="info-value">#<%= dealerId %></span>
        </div>
        <div class="info-item">
            <span class="info-label">Dealer Name</span>
            <span class="info-value">🏬 <%= dealerName %></span>
        </div>
        <div class="info-item">
            <span class="info-label">Phone</span>
            <span class="info-value">📞 <%= dealerPhone %></span>
        </div>
        <div class="info-item">
            <span class="info-label">Current Credit</span>
            <span class="info-value credit-amount">₹ <%= String.format("%.2f", dealerCredit) %></span>
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
            <div class="s-value" style="color:#2b0d73;">₹ <%= String.format("%.2f", dealerCredit) %></div>
        </div>
    </div>

    <!-- Transaction History -->
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
                    <th>Product / Item</th>
                    <th>Amount (₹)</th>
                </tr>
            </thead>
            <tbody>
            <%
                int sNo = 1;
                try (Connection conn = DBConnection.getConnection()) {
                    PreparedStatement ps = conn.prepareStatement(
                        "SELECT * FROM dealer_transactions WHERE dealer_id = ? ORDER BY transaction_date DESC");
                    ps.setInt(1, dealerId);
                    ResultSet rs = ps.executeQuery();
                    boolean hasTxn = false;

                    while (rs.next()) {
                        hasTxn = true;
                        String type     = rs.getString("transaction_type");
                        String prodName = rs.getString("product_name");
                        if (prodName == null || prodName.trim().isEmpty()) prodName = "—";
            %>
                <tr>
                    <td><%= sNo++ %></td>
                    <td><strong><%= rs.getInt("id") %></strong></td>
                    <td><%= rs.getTimestamp("transaction_date") %></td>
                    <td>
                        <% if ("ADD".equals(type)) { %>
                        <span class="badge-add">➕ ADD</span>
                        <% } else { %>
                        <span class="badge-settle">✅ SETTLE</span>
                        <% } %>
                    </td>
                    <td>
                        <span class="product-tag <%= "SETTLE".equals(type) ? "settle" : "" %>">
                            📦 <%= prodName %>
                        </span>
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
                <tr><td colspan="6" class="no-data">No transactions found for this dealer.</td></tr>
            <%
                    }
                } catch (Exception e) {
            %>
                <tr><td colspan="6" class="no-data">❌ Error: <%= e.getMessage() %></td></tr>
            <%
                }
            %>
            </tbody>
        </table>
    </div>
</div>

</body>
</html>
