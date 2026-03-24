<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.sql.*, doa.DBConnection" %>
<%
    if (session.getAttribute("admin") == null) {
        response.sendRedirect("login.jsp?error=Please login first");
        return;
    }
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>View Dealers</title>
    <link rel="stylesheet" href="css/content.css">
</head>
<body>

<!-- Page Header -->
<div class="page-header">
    <div>
        <h2>📋 Dealer List</h2>
        <div class="breadcrumb">Home › View Dealers</div>
    </div>
    <button class="btn-save" style="padding:8px 18px; font-size:13px;"
            onclick="parent.loadPage('add_dealer.jsp','Add Dealer',null)">+ Add Dealer</button>
</div>

<div class="content-wrapper">

    <!-- Status messages -->
    <% if (request.getParameter("success") != null) { %>
    <div class="alert alert-success">✅ <%= request.getParameter("success") %></div>
    <% } %>
    <% if (request.getParameter("error") != null) { %>
    <div class="alert alert-error">❌ <%= request.getParameter("error") %></div>
    <% } %>

    <!-- Table -->
    <div class="table-container">
        <table>
            <thead>
                <tr>
                    <th>ID</th>
                    <th>Dealer Name</th>
                    <th>Phone</th>
                    <th>Total Credit (₹)</th>
                    <th>Add Credit</th>
                    <th>Settle Credit</th>
                    <th>Details</th>
                </tr>
            </thead>
            <tbody>
            <%
                try (Connection conn = DBConnection.getConnection();
                     java.sql.Statement stmt = conn.createStatement();
                     ResultSet rs = stmt.executeQuery("SELECT * FROM dealers ORDER BY id")) {

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
                        <span style="font-size:16px;">🏬</span> <%= name %>
                    </td>
                    <td>📞 <%= phone %></td>
                    <td>
                        <span class="credit-val" id="dcredit-<%= id %>">****</span>
                        <button class="btn-toggle" id="dtog-<%= id %>"
                                onclick="toggleCredit(<%= id %>, <%= credit %>)">Show</button>
                    </td>
                    <td>
                        <form action="<%=request.getContextPath()%>/AddDealerCreditServlet" method="post">
                            <input type="hidden" name="id" value="<%= id %>">
                            <div class="action-group">
                                <input type="number" step="0.01" min="0.01" name="additionalCredit"
                                       placeholder="Amount" required>
                                <button type="submit" class="btn-add">Add</button>
                            </div>
                        </form>
                    </td>
                    <td>
                        <form action="<%=request.getContextPath()%>/SettleDealerCreditServlet" method="post">
                            <input type="hidden" name="id" value="<%= id %>">
                            <div class="action-group">
                                <input type="number" step="0.01" min="0.01" name="settleAmount"
                                       placeholder="Amount" required>
                                <button type="submit" class="btn-settle">Settle</button>
                            </div>
                        </form>
                    </td>
                    <td>
                        <a href="dealerdetails.jsp?dealer_id=<%= id %>" class="btn-view"
                           onclick="parent.updateParentBreadcrumb('Dealer Details','dealerdetails.jsp')">
                           📄 View
                        </a>
                    </td>
                </tr>
            <%
                    }
                    if (!hasData) {
            %>
                <tr><td colspan="7" class="no-data">⚠ No dealers found.</td></tr>
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
    var span = document.getElementById('dcredit-' + id);
    var btn  = document.getElementById('dtog-'    + id);
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
