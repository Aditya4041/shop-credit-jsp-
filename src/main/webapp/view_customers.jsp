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
    <style>
        /* ── Eye-icon toggle button ── */
        .btn-eye {
            background: none;
            border: none;
            cursor: pointer;
            padding: 3px 5px;
            color: #7c73b8;
            display: inline-flex;
            align-items: center;
            justify-content: center;
            border-radius: 5px;
            transition: color 0.2s, background 0.2s;
            vertical-align: middle;
            outline: none;
        }
        .btn-eye:hover { color: #2b0d73; background: #ede9ff; }
        .btn-eye svg   { display: block; pointer-events: none; }
    </style>
</head>
<body>

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
                        <span class="credit-val" id="credit-<%= id %>">••••••</span>
                        <!-- Eye toggle button -->
                        <button class="btn-eye" id="tog-<%= id %>"
                                onclick="toggleCredit(<%= id %>, <%= credit %>)"
                                title="Show / Hide credit">
                            <!-- Eye-open icon (default) -->
                            <svg id="eye-open-<%= id %>" width="18" height="18" viewBox="0 0 24 24"
                                 fill="none" stroke="currentColor" stroke-width="2"
                                 stroke-linecap="round" stroke-linejoin="round">
                                <path d="M1 12s4-8 11-8 11 8 11 8-4 8-11 8-11-8-11-8z"/>
                                <circle cx="12" cy="12" r="3"/>
                            </svg>
                            <!-- Eye-closed icon (hidden) -->
                            <svg id="eye-closed-<%= id %>" width="18" height="18" viewBox="0 0 24 24"
                                 fill="none" stroke="currentColor" stroke-width="2"
                                 stroke-linecap="round" stroke-linejoin="round"
                                 style="display:none;">
                                <path d="M17.94 17.94A10.07 10.07 0 0 1 12 20c-7 0-11-8-11-8
                                         a18.45 18.45 0 0 1 5.06-5.94"/>
                                <path d="M9.9 4.24A9.12 9.12 0 0 1 12 4c7 0 11 8 11 8
                                         a18.5 18.5 0 0 1-2.16 3.19"/>
                                <line x1="1" y1="1" x2="23" y2="23"/>
                            </svg>
                        </button>
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
    var span      = document.getElementById('credit-'     + id);
    var eyeOpen   = document.getElementById('eye-open-'   + id);
    var eyeClosed = document.getElementById('eye-closed-' + id);

    if (span.textContent === '••••••') {
        // Show credit
        span.textContent        = '₹ ' + parseFloat(amount).toFixed(2);
        eyeOpen.style.display   = 'none';
        eyeClosed.style.display = 'block';
    } else {
        // Hide credit
        span.textContent        = '••••••';
        eyeOpen.style.display   = 'block';
        eyeClosed.style.display = 'none';
    }
}
</script>
</body>
</html>
