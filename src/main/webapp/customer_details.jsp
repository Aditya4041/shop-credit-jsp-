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
    <title>Customer Details</title>
    <link rel="stylesheet" href="style.css">

    <style>
        /* Table Styling */
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

        /* Headings */
        h2, h3 {
            text-align: center;
            color: #ffffff;
        }

        /* Buttons */
        .add {
            background-color: #4caf50;
            color: white;
            padding: 6px 12px;
            border: none;
            border-radius: 5px;
            cursor: pointer;
            margin: 5px;
        }

        .settle {
            background-color: #f44336;
            color: white;
            padding: 6px 12px;
            border: none;
            border-radius: 5px;
            cursor: pointer;
            margin: 5px;
        }

        /* Search Input */
        .search-input {
            display: block;
            margin: 20px auto;
            padding: 8px 12px;
            width: 50%;
            border-radius: 5px;
            border: 1px solid #ccc;
            text-align: center;
        }

        /* Back link */
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

    <h2>Customer Transactions</h2>

    <!-- Centered Search Input -->
  

    <%
        String idStr = request.getParameter("id");
        if(idStr == null) {
            out.println("<p style='text-align:center; color:white;'>Invalid customer ID.</p>");
        } else {
            int customerId = Integer.parseInt(idStr);

            try (Connection conn = DBConnection.getConnection()) {
                // Get customer info
                String custSql = "SELECT * FROM customers WHERE id = ?";
                PreparedStatement psCust = conn.prepareStatement(custSql);
                psCust.setInt(1, customerId);
                ResultSet rsCust = psCust.executeQuery();

                if(rsCust.next()) {
    %>
    <p style="text-align:center; color:white;"><b>Name:</b> <%= rsCust.getString("name") %></p>
    <p style="text-align:center; color:white;"><b>Phone:</b> <%= rsCust.getString("phone") %></p>
    <p style="text-align:center; color:white;"><b>Current Credit:</b> <%= rsCust.getDouble("credit") %></p>

   

    <h3>Transaction History</h3>
    <table>
        <tr>
            <th>ID</th>
            <th>Date</th>
            <th>Type</th>
            <th>Amount</th>
            
        </tr>
        <%
            String txnSql = "SELECT * FROM customer_transactions WHERE customer_id = ? ORDER BY transaction_date DESC";
            PreparedStatement psTxn = conn.prepareStatement(txnSql);
            psTxn.setInt(1, customerId);
            ResultSet rsTxn = psTxn.executeQuery();

            boolean hasTxn = false;
            while(rsTxn.next()) {
                hasTxn = true;
        %>
        <tr>
            <td><%= rsTxn.getInt("id") %></td>
             <td><%= rsTxn.getDate("transaction_date") %></td>
            <td><%= rsTxn.getString("transaction_type") %></td>
            <td><%= rsTxn.getDouble("amount") %></td>
           
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
                    out.println("<p style='text-align:center; color:white;'>Customer not found.</p>");
                }
            } catch (Exception e) {
                out.println("<p style='text-align:center; color:white;'>Error: " + e.getMessage() + "</p>");
            }
        }
    %>

    <h1><a href="view_customers.jsp" class="back-link">Back to Customer List</a></h1>
</body>
</html>
