<%
    if (session.getAttribute("admin") == null) {
        response.sendRedirect("login.jsp?error=Please login first");
        return;
    }
%>


<%@ page import="java.sql.*, doa.DBConnection" %>
<html>
<head>
    <title>All Customers</title>
    <link rel="stylesheet" href="style.css">
    <style>
        /* General Body */
        body {
            font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
            background-color: #1e1e2f;
            color: #ffffff;
            margin: 0;
            padding: 0;
            text-align: center;
        }

        h2 {
            margin-top: 20px;
            color: #ffffff;
        }

        /* Search Input */
        form input[type="text"] {
            padding: 8px 12px;
            width: 50%;
            border-radius: 5px;
            border: 1px solid #ccc;
            margin-bottom: 10px;
            text-align: center;
        }

        form input[type="submit"], form a {
            padding: 6px 12px;
            border-radius: 5px;
            border: none;
            cursor: pointer;
            margin-left: 5px;
            font-weight: bold;
            text-decoration: none;
            color: #fff;
        }

        form input[type="submit"] {
            background-color: #4caf50;
        }

        form a {
            background-color: #f44336;
        }

        /* Table Styling */
        table {
            width: 90%;
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

        /* Buttons inside table */
        .add, .settle, .view-details {
            padding: 5px 10px;
            border: none;
            border-radius: 5px;
            color: #fff;
            cursor: pointer;
            margin: 2px;
        }

        .add { background-color: #4caf50; }
        .settle { background-color: #f44336; }
        .view-details { background-color: #2196f3; }

        /* Credit Show/Hide button */
        td button {
            padding: 3px 6px;
            border: none;
            border-radius: 4px;
            background-color: #555;
            color: white;
            cursor: pointer;
            margin-left: 5px;
        }

        td button:hover {
            background-color: #777;
        }

        /* No records row */
        td[colspan] {
            color: #ffb74d;
        }

        /* Input fields inside forms in table */
        td input[type="number"] {
            width: 80px;
            padding: 4px 6px;
            border-radius: 4px;
            border: 1px solid #ccc;
        }
    </style>
</head>
<body>
<jsp:include page="navbar.jsp" />

<h2>Customer List</h2>

<!-- Search Form -->
<form action="<%=request.getContextPath()%>/view_customers.jsp" method="get">
    <input type="text" name="keyword" placeholder="Search by Name / Phone / ID"
        value="<%= request.getParameter("keyword") != null ? request.getParameter("keyword") : "" %>">
    <input type="submit" value="Search">
    <a href="<%=request.getContextPath()%>/view_customers.jsp">Reset</a>
</form>

<table>
    <tr>
        <th>ID</th>
        <th>Name</th>
        <th>Phone</th>
        <th>Credit</th>
        <th>Action</th>
        <th>View Details</th>
    </tr>

    <%
        String keyword = request.getParameter("keyword");
        String sql = "SELECT * FROM customers";
        boolean hasKeyword = keyword != null && !keyword.trim().isEmpty();
        if (hasKeyword) {
            sql += " WHERE LOWER(name) LIKE ? OR LOWER(phone) LIKE ? OR id = ?";
        }
        sql += " ORDER BY id ASC";

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            if (hasKeyword) {
                ps.setString(1, "%" + keyword.toLowerCase() + "%");
                ps.setString(2, "%" + keyword.toLowerCase() + "%");
                try {
                    ps.setInt(3, Integer.parseInt(keyword));
                } catch (NumberFormatException e) {
                    ps.setInt(3, -1);
                }
            }

            ResultSet rs = ps.executeQuery();
            boolean hasData = false;
            while (rs.next()) {
                hasData = true;
    %>
    <tr>
        <td><%= rs.getInt("id") %></td>
        <td><%= rs.getString("name") %></td>
        <td><%= rs.getString("phone") %></td>
        <td>
            <span id="credit-<%= rs.getInt("id") %>">****</span>
            <button type="button" onclick="toggleCredit(<%= rs.getInt("id") %>, <%= rs.getDouble("credit") %>)">
                Show
            </button>
        </td>
        <td>
            <!-- Add Credit -->
            <form action="<%=request.getContextPath()%>/AddCreditServlet" method="post" style="display:inline;">
                <input type="hidden" name="id" value="<%= rs.getInt("id") %>">
                <input type="number" step="0.01" name="additionalCredit" placeholder="Add" required>
                <input type="submit" class="add" value="Add">
            </form>

            <!-- Settle Credit -->
            <form action="<%=request.getContextPath()%>/SettleCreditServlet" method="post" style="display:inline;">
                <input type="hidden" name="id" value="<%= rs.getInt("id") %>">
                <input type="number" step="0.01" name="settleAmount" placeholder="Settle" required>
                <input type="submit" class="settle" value="Settle">
            </form>
        </td>
        <td>
            <form action="customer_details.jsp" method="get">
                <input type="hidden" name="id" value="<%= rs.getInt("id") %>">
                <input type="submit" class="view-details" value="View Details">
            </form>
        </td>
    </tr>
    <%
            }

            if (!hasData) {
                out.println("<tr><td colspan='6'>No records found.</td></tr>");
            }

        } catch (Exception e) {
            out.println("<tr><td colspan='6'>Error: " + e.getMessage() + "</td></tr>");
        }
    %>
</table>

<script>
function toggleCredit(id, amount) {
    const span = document.getElementById('credit-' + id);
    if (span.innerText === '****') {
        span.innerText = amount.toFixed(2);
        event.target.innerText = 'Hide';
    } else {
        span.innerText = '****';
        event.target.innerText = 'Show';
    }
}
</script>
</body>
</html>
