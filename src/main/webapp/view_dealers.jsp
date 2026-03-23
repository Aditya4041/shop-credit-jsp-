<%@ page import="java.sql.*, doa.DBConnection" %>
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

    <title>View Dealers</title>
    <style>
        body {
            font-family: 'Poppins', sans-serif;
            background: linear-gradient(135deg, #1a1a2e, #16213e);
            color: white;
            margin: 0;
            text-align: center;
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

        button {
            background-color: #e94560;
            border: none;
            padding: 8px 15px;
            color: #fff;
            border-radius: 8px;
            cursor: pointer;
        }
        button:hover {
            background-color: #ff5f7e;
        }
        input[type="number"] {
            width: 80px;
            padding: 5px;
            border-radius: 5px;
            border: none;
        }
    </style>
</head>
<body>

  <jsp:include page="navbar.jsp" />

    <h2>Dealer List</h2>
    <%
        try (Connection conn = DBConnection.getConnection()) {
            Statement stmt = conn.createStatement();
            ResultSet rs = stmt.executeQuery("SELECT * FROM dealers ORDER BY id");
    %>
        <table>
            <tr>
                <th>ID</th>
                <th>Dealer Name</th>
                <th>Phone</th>
                <th>Total Credit</th>
                <th>Add Credit</th>
                <th>Settle Credit</th>
                <th>View Details</th>
            </tr>
            <%
                while (rs.next()) {
                    int id = rs.getInt("id");
                    String name = rs.getString("name");
                    String phone = rs.getString("phone");
                    double credit = rs.getDouble("credit");
            %>
            <tr>
                <td><%= id %></td>
                <td><%= name %></td>
                <td><%= phone %></td>
                <td><%= credit %></td>
                <td>
                    <form action="AddDealerCreditServlet" method="post">
                        <input type="hidden" name="id" value="<%= id %>">
                        <input type="number" step="0.01" name="additionalCredit" required>
                        <button type="submit">Add</button>
                    </form>
                </td>
                <td>
                    <form action="SettleDealerCreditServlet" method="post">
                        <input type="hidden" name="id" value="<%= id %>">
                        <input type="number" step="0.01" name="settleAmount" required>
                        <button type="submit">Settle</button>
                    </form>
                </td>
                <td>
                    <form action="dealerdetails.jsp" method="get">
    					<input type="hidden" name="dealer_id" value="<%= id %>">
    					<button type="submit">View Details</button>
					</form>
                </td>
            </tr>
            <%
                }
            %>
        </table>
    <%
        } catch (Exception e) {
            out.println("<p>Error: " + e.getMessage() + "</p>");
        }
    %>

</body>
</html>
