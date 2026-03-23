<%
    if (session.getAttribute("admin") == null) {
        response.sendRedirect("login.jsp?error=Please login first");
        return;
    }
%>

<%@ page import="java.sql.*, doa.DBConnection" %>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<html>
<head>
    <title>Dealer Details</title>
    <link rel="stylesheet" href="style.css">

    <style>
        table {
            width: 80%;
            margin: 20px auto;
            border-collapse: collapse;
            background-color: #2e2e4d;
            color: #ffffff;
        }
        th, td {
            padding: 10px;
            border: 1px solid #444;
            text-align: center;
        }
        th {
            background-color: #1e1e2f;
        }
        h2, h3 {
            text-align: center;
            color: #ffffff;
        }
        .back-link {
            display: block;
            text-align: center;
            margin: 20px;
            color: #ffffff;
            text-decoration: none;
            font-weight: bold;
        }
        .back-link:hover {
            text-decoration: underline;
        }
    </style>
</head>
<body>
    <jsp:include page="navbar.jsp" />

    <h2>Dealer Transactions</h2>

    <%
        String dealerIdStr = request.getParameter("dealer_id");
        if(dealerIdStr == null) {
            out.println("<p style='text-align:center; color:white;'>Invalid dealer ID.</p>");
        } else {
            int dealerId = Integer.parseInt(dealerIdStr);

            try (Connection conn = DBConnection.getConnection()) {
                // Get dealer info
                String dealerSql = "SELECT * FROM DEALERS WHERE ID = ?";
                PreparedStatement psDealer = conn.prepareStatement(dealerSql);
                psDealer.setInt(1, dealerId);
                ResultSet rsDealer = psDealer.executeQuery();

                if(rsDealer.next()) {
    %>
    <p style="text-align:center; color:white;"><b>Name:</b> <%= rsDealer.getString("NAME") %></p>
    <p style="text-align:center; color:white;"><b>Phone:</b> <%= rsDealer.getString("PHONE") %></p>
    <p style="text-align:center; color:white;"><b>Current Credit:</b> <%= rsDealer.getDouble("CREDIT") %></p>

    <h3>Transaction History</h3>
    <table>
        <tr>
            <th>ID</th>
            <th>Date</th>
            <th>Type</th>
            <th>Amount</th>
        </tr>
        <%
            String txnSql = "SELECT * FROM DEALER_TRANSACTIONS WHERE DEALER_ID = ? ORDER BY TRANSACTION_DATE DESC";
            PreparedStatement psTxn = conn.prepareStatement(txnSql);
            psTxn.setInt(1, dealerId);
            ResultSet rsTxn = psTxn.executeQuery();

            boolean hasTxn = false;
            while(rsTxn.next()) {
                hasTxn = true;
        %>
        <tr>
            <td><%= rsTxn.getInt("ID") %></td>
            <td><%= rsTxn.getTimestamp("TRANSACTION_DATE") %></td>
            <td><%= rsTxn.getString("TRANSACTION_TYPE") %></td>
            <td><%= rsTxn.getDouble("AMOUNT") %></td>
        </tr>
        <%  } 
            if(!hasTxn) {
        %>
        <tr>
            <td colspan="4">No transactions found.</td>
        </tr>
        <%  } %>
    </table>

    <%
                } else {
                    out.println("<p style='text-align:center; color:white;'>Dealer not found.</p>");
                }
            } catch (Exception e) {
                out.println("<p style='text-align:center; color:white;'>Error: " + e.getMessage() + "</p>");
            }
        }
    %>

    <h1><a href="view_dealers.jsp" class="back-link">Back to Dealer List</a></h1>
</body>
</html>
