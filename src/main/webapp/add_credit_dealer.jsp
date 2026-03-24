<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.sql.*, doa.DBConnection" %>
<%
    if (session.getAttribute("admin") == null) {
        response.sendRedirect("login.jsp?error=Please login first");
        return;
    }
    String idStr = request.getParameter("id");
    if (idStr == null || idStr.trim().isEmpty()) {
        response.sendRedirect("view_dealers.jsp");
        return;
    }
    int dealerId = Integer.parseInt(idStr.trim());
    String dealerName  = "";
    String dealerPhone = "";
    double dealerCredit = 0;

    try (Connection conn = DBConnection.getConnection()) {
        PreparedStatement ps = conn.prepareStatement("SELECT name, phone, credit FROM dealers WHERE id = ?");
        ps.setInt(1, dealerId);
        ResultSet rs = ps.executeQuery();
        if (rs.next()) {
            dealerName  = rs.getString("name");
            dealerPhone = rs.getString("phone");
            dealerCredit = rs.getDouble("credit");
        } else {
            response.sendRedirect("view_dealers.jsp?error=Dealer not found");
            return;
        }
    } catch (Exception e) {
        response.sendRedirect("view_dealers.jsp?error=" + e.getMessage());
        return;
    }
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>Add Credit — <%= dealerName %></title>
    <link rel="stylesheet" href="css/content.css">
    <style>
        .dealer-card {
            background: linear-gradient(135deg, #7a3800 0%, #d4681a 100%);
            color: #fff;
            border-radius: 14px;
            padding: 20px 26px;
            margin-bottom: 24px;
            display: flex;
            align-items: center;
            gap: 20px;
            flex-wrap: wrap;
            box-shadow: 0 6px 20px rgba(0,0,0,0.18);
        }
        .dealer-card .avatar {
            width: 56px; height: 56px;
            background: rgba(255,255,255,0.15);
            border-radius: 50%;
            display: flex; align-items: center; justify-content: center;
            font-size: 26px;
            border: 2px solid rgba(255,255,255,0.3);
            flex-shrink: 0;
        }
        .dealer-card .cinfo { flex: 1; }
        .dealer-card .cinfo h3 { font-size: 18px; font-weight: 700; margin: 0 0 4px; }
        .dealer-card .cinfo p  { font-size: 13px; color: #ffd8b0; margin: 0; }
        .dealer-card .credit-pill {
            background: rgba(255,255,255,0.13);
            border: 1px solid rgba(255,255,255,0.25);
            border-radius: 10px;
            padding: 10px 20px;
            text-align: center;
        }
        .dealer-card .credit-pill .lbl { font-size: 11px; color: #ffd0a0; text-transform: uppercase; letter-spacing: 0.8px; }
        .dealer-card .credit-pill .val { font-size: 20px; font-weight: 800; color: #ffe082; margin-top: 2px; }

        select.custom-select {
            width: 100%;
            padding: 10px 12px;
            border: 2px solid #c8b7f6;
            border-radius: 8px;
            font-size: 14px;
            font-family: inherit;
            color: #1a1a2a;
            background: #fff;
            outline: none;
            transition: border 0.2s, box-shadow 0.2s;
            appearance: none;
            background-image: url("data:image/svg+xml,%3Csvg xmlns='http://www.w3.org/2000/svg' width='12' height='8' viewBox='0 0 12 8'%3E%3Cpath d='M1 1l5 5 5-5' stroke='%237c73b8' stroke-width='2' fill='none' stroke-linecap='round'/%3E%3C/svg%3E");
            background-repeat: no-repeat;
            background-position: right 14px center;
            cursor: pointer;
        }
        select.custom-select:focus {
            border-color: #7c73b8;
            box-shadow: 0 0 0 3px rgba(124,115,184,0.15);
        }
    </style>
</head>
<body>

<div class="content-wrapper">

    <% if (request.getParameter("error") != null) { %>
    <div class="alert alert-error">❌ <%= request.getParameter("error") %></div>
    <% } %>

    <!-- Back link -->
    <a href="view_dealers.jsp" class="back-link">← Back to Dealers</a>

    <!-- Dealer Info Banner -->
    <div class="dealer-card">
        <div class="avatar">🏬</div>
        <div class="cinfo">
            <h3><%= dealerName %></h3>
            <p>📞 <%= dealerPhone %> &nbsp;|&nbsp; Dealer ID #<%= dealerId %></p>
        </div>
        <div class="credit-pill">
            <div class="lbl">Current Credit</div>
            <div class="val">₹ <%= String.format("%.2f", dealerCredit) %></div>
        </div>
    </div>

    <!-- Add Credit Form -->
    <div class="form-container" style="padding: 0; max-width: 680px;">
        <form action="AddDealerCreditServlet" method="post" onsubmit="return validateForm()">
            <input type="hidden" name="id" value="<%= dealerId %>">

            <fieldset>
                <legend>Add Credit Transaction</legend>

                <div class="form-grid">

                    <div class="form-group full-width">
                        <label for="productId">📦 Product / Item <span style="color:#e53935;">*</span></label>
                        <select id="productId" name="productId" class="custom-select" required>
                            <option value="" disabled selected>— Select a product —</option>
                            <%
                                try (Connection conn = DBConnection.getConnection()) {
                                    ResultSet prs = conn.createStatement()
                                        .executeQuery("SELECT id, product_name, quantity FROM products ORDER BY product_name ASC");
                                    while (prs.next()) {
                                        int    pid  = prs.getInt("id");
                                        String pnm  = prs.getString("product_name");
                                        int    pqty = prs.getInt("quantity");
                            %>
                            <option value="<%= pid %>" data-name="<%= pnm %>">
                                <%= pnm %> &nbsp;(Stock: <%= pqty %>)
                            </option>
                            <%      }
                                } catch (Exception ex) { /* ignore */ }
                            %>
                        </select>
                    </div>

                    <div class="form-group full-width">
                        <label for="additionalCredit">💰 Credit Amount (₹) <span style="color:#e53935;">*</span></label>
                        <input type="number" id="additionalCredit" name="additionalCredit"
                               placeholder="0.00" step="0.01" min="0.01" required>
                    </div>

                    <!-- Hidden field to carry product name to servlet -->
                    <input type="hidden" id="productName" name="productName" value="">

                </div>
            </fieldset>

            <div class="form-buttons">
                <button type="submit" class="btn-save">💾 Add Credit</button>
                <a href="view_dealers.jsp" class="btn-clear" style="text-decoration:none; display:inline-flex; align-items:center; justify-content:center;">Cancel</a>
            </div>
        </form>
    </div>

</div>

<script>
document.getElementById('productId').addEventListener('change', function () {
    var opt = this.options[this.selectedIndex];
    document.getElementById('productName').value = opt.getAttribute('data-name') || '';
});

function validateForm() {
    var pid    = document.getElementById('productId').value;
    var amount = document.getElementById('additionalCredit').value;
    if (!pid)   { alert('⚠️ Please select a product.'); return false; }
    if (!amount || parseFloat(amount) <= 0) { alert('⚠️ Please enter a valid amount.'); return false; }
    return true;
}
</script>
</body>
</html>
