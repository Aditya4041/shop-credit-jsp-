<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.sql.*, doa.DBConnection" %>
<%
    if (session.getAttribute("admin") == null) {
        response.sendRedirect("login.jsp?error=Please login first");
        return;
    }
    String keyword = request.getParameter("keyword");
    boolean hasKeyword = (keyword != null && !keyword.trim().isEmpty());
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>View Customers</title>
    <link rel="stylesheet" href="css/content.css">
</head>
<body>

<!-- Page Header -->
<div class="page-header">
    <div>
        <h2>👥 Customer List</h2>
        <div class="breadcrumb">Home › View Customers</div>
    </div>
    <button class="btn-save" style="padding:8px 18px; font-size:13px;"
            onclick="parent.loadPage('add_customer.jsp','Add Customer',null)">+ Add Customer</button>
</div>

<div class="content-wrapper">

    <!-- Status messages -->
    <% if (request.getParameter("success") != null) { %>
    <div class="alert alert-success">✅ <%= request.getParameter("success") %></div>
    <% } %>
    <% if (request.getParameter("error") != null) { %>
    <div class="alert alert-error">❌ <%= request.getParameter("error") %></div>
    <% } %>

    <!-- Search Bar -->
    <form class="search-bar" action="view_customers.jsp" method="get">
        <input type="text" name="keyword" placeholder="🔍 Search by Name, Phone or ID"
               value="<%= hasKeyword ? keyword : "" %>">
        <button type="submit" class="btn-search">Search</button>
        <a href="view_customers.jsp" class="btn-reset">Reset</a>
    </form>

    <!-- Table -->
    <div class="table-container">
        <table>
            <thead>
                <tr>
                    <th>ID</th>
                    <th>Name</th>
                    <th>Phone</th>
                    <th>Credit (₹)</th>
                    <th>Add Credit</th>
                    <th>Settle Credit</th>
                    <th>Details</th>
                </tr>
            </thead>
            <tbody>
            <%
                String sql = "SELECT * FROM customers";
                if (hasKeyword) sql += " WHERE LOWER(name) LIKE ? OR LOWER(phone) LIKE ? OR id = ?";
                sql += " ORDER BY id ASC";

                try (Connection conn = DBConnection.getConnection();
                     PreparedStatement ps = conn.prepareStatement(sql)) {

                    if (hasKeyword) {
                        ps.setString(1, "%" + keyword.toLowerCase() + "%");
                        ps.setString(2, "%" + keyword.toLowerCase() + "%");
                        try { ps.setInt(3, Integer.parseInt(keyword)); }
                        catch (NumberFormatException ex) { ps.setInt(3, -1); }
                    }

                    ResultSet rs = ps.executeQuery();
                    boolean hasData = false;

                    while (rs.next()) {
                        hasData = true;
                        int    id     = rs.getInt("id");
                        String name   = rs.getString("name");
                        String phone  = rs.getString("phone");
                        double credit = rs.getDouble("credit");
            %>
                <tr>
                    <td><strong>#<%= id %></strong></td>
                    <td style="text-align:left; font-weight:600; color:#2b0d73;">
                        <span style="font-size:16px;">👤</span> <%= name %>
                    </td>
                    <td>📞 <%= phone %></td>
                    <td>
                        <span class="credit-val" id="credit-<%= id %>">****</span>
                        <button class="btn-toggle" id="tog-<%= id %>"
                                onclick="toggleCredit(<%= id %>, <%= credit %>)">Show</button>
                    </td>
                    <td>
                        <form action="<%=request.getContextPath()%>/AddCreditServlet" method="post">
                            <input type="hidden" name="id" value="<%= id %>">
                            <div class="action-group">
                                <input type="number" step="0.01" min="0.01" name="additionalCredit"
                                       placeholder="Amount" required>
                                <button type="submit" class="btn-add">Add</button>
                            </div>
                        </form>
                    </td>
                    <td>
                        <form action="<%=request.getContextPath()%>/SettleCreditServlet" method="post">
                            <input type="hidden" name="id" value="<%= id %>">
                            <div class="action-group">
                                <input type="number" step="0.01" min="0.01" name="settleAmount"
                                       placeholder="Amount" required>
                                <button type="submit" class="btn-settle">Settle</button>
                            </div>
                        </form>
                    </td>
                    <td>
                        <a href="customer_details.jsp?id=<%= id %>" class="btn-view"
                           onclick="parent.updateParentBreadcrumb('Customer Details','customer_details.jsp')">
                           📄 View
                        </a>
                    </td>
                </tr>
            <%
                    }
                    if (!hasData) {
            %>
                <tr><td colspan="7" class="no-data">⚠ No customers found.</td></tr>
            <%
                    }
                } catch (Exception e) {
            %>
                <tr><td colspan="7" class="no-data">❌ Error: <%= e.getMessage() %></td></tr>
            <%
                }
            %>
            </tbody>
        </table>
    </div>
</div>

<script>
function toggleCredit(id, amount) {
    var span = document.getElementById('credit-' + id);
    var btn  = document.getElementById('tog-' + id);
    if (span.textContent === '****') {
        span.textContent = '₹ ' + amount.toFixed(2);
        btn.textContent  = 'Hide';
        btn.style.background = '#2b0d73';
    } else {
        span.textContent = '****';
        btn.textContent  = 'Show';
        btn.style.background = '';
    }
}
</script>
</body>
</html>
