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
        PreparedStatement ps = conn.prepareStatement(
            "SELECT name, phone, credit FROM dealers WHERE id = ?");
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

        /* ── Stock info strip (shows current stock, will increase after save) ── */
        .stock-strip {
            display: none;
            align-items: center;
            gap: 10px;
            background: #e8f5e9;
            border: 1px solid #a5d6a7;
            border-radius: 8px;
            padding: 8px 14px;
            margin-top: 8px;
            font-size: 13px;
            color: #1b5e20;
            font-weight: 600;
        }
        .stock-strip .stock-num {
            background: #2e7d32;
            color: #fff;
            border-radius: 20px;
            padding: 2px 12px;
            font-size: 13px;
            font-weight: 700;
        }

        /* ── After-add preview pill ── */
        .preview-strip {
            display: none;
            align-items: center;
            gap: 8px;
            background: #f0f4ff;
            border: 1px solid #c8d8f8;
            border-radius: 8px;
            padding: 8px 14px;
            margin-top: 6px;
            font-size: 13px;
            color: #2b0d73;
            font-weight: 600;
        }
        .preview-strip .arrow { color: #4caf50; font-size: 16px; }
        .preview-strip .new-num {
            background: #4caf50;
            color: #fff;
            border-radius: 20px;
            padding: 2px 12px;
            font-size: 13px;
            font-weight: 700;
        }

        /* ── Info banner explaining dealer logic ── */
        .info-banner {
            background: #fff8e1;
            border-left: 4px solid #f5a623;
            border-radius: 0 8px 8px 0;
            padding: 10px 16px;
            font-size: 13px;
            color: #7a5c00;
            margin-bottom: 20px;
            display: flex;
            align-items: center;
            gap: 8px;
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

    <!-- Info banner -->
    <div class="info-banner">
        💡 <strong>Dealer Stock Logic:</strong> When a dealer supplies goods, the selected quantity is
        <strong>added to product stock</strong>. This is the opposite of customer credit which deducts stock.
    </div>

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

                    <!-- Product Dropdown -->
                    <div class="form-group full-width">
                        <label for="productId">📦 Product / Item <span style="color:#e53935;">*</span></label>
                        <select id="productId" name="productId" class="custom-select"
                                required onchange="onProductChange(this)">
                            <option value="" disabled selected data-stock="0">— Select a product —</option>
                            <%
                                try (Connection conn = DBConnection.getConnection()) {
                                    ResultSet prs = conn.createStatement()
                                        .executeQuery(
                                            "SELECT id, product_name, quantity " +
                                            "FROM products ORDER BY product_name ASC");
                                    while (prs.next()) {
                                        int    pid  = prs.getInt("id");
                                        String pnm  = prs.getString("product_name");
                                        int    pqty = prs.getInt("quantity");
                                        String label = pnm + " \u00a0(Stock: " + pqty + ")";
                            %>
                            <option value="<%= pid %>"
                                    data-name="<%= pnm %>"
                                    data-stock="<%= pqty %>">
                                <%= label %>
                            </option>
                            <%      }
                                } catch (Exception ex) { /* ignore */ }
                            %>
                        </select>

                        <!-- Current stock display -->
                        <div class="stock-strip" id="stockStrip">
                            Current stock: <span class="stock-num" id="stockNum">—</span>
                        </div>
                    </div>

                    <!-- Quantity -->
                    <div class="form-group">
                        <label for="quantity">🔢 Quantity Supplied <span style="color:#e53935;">*</span></label>
                        <input type="number" id="quantity" name="quantity"
                               placeholder="0" min="1" required
                               oninput="updatePreview()">
                        <!-- Live preview of new stock after save -->
                        <div class="preview-strip" id="previewStrip">
                            Stock after save:
                            <span class="arrow">↑</span>
                            <span class="new-num" id="newStockNum">—</span>
                        </div>
                    </div>

                    <!-- Credit Amount -->
                    <div class="form-group">
                        <label for="additionalCredit">💰 Credit Amount (₹) <span style="color:#e53935;">*</span></label>
                        <input type="number" id="additionalCredit" name="additionalCredit"
                               placeholder="0.00" step="0.01" min="0.01" required>
                    </div>

                    <!-- Hidden: product name for servlet -->
                    <input type="hidden" id="productName" name="productName" value="">

                </div>
            </fieldset>

            <div class="form-buttons">
                <button type="submit" class="btn-save">💾 Add Credit & Update Stock</button>
                <a href="view_dealers.jsp" class="btn-clear"
                   style="text-decoration:none; display:inline-flex; align-items:center; justify-content:center;">
                    Cancel
                </a>
            </div>
        </form>
    </div>

</div>

<script>
var currentStock = 0;

function onProductChange(sel) {
    var opt   = sel.options[sel.selectedIndex];
    var name  = opt.getAttribute('data-name') || '';
    var stock = parseInt(opt.getAttribute('data-stock') || '0', 10);

    document.getElementById('productName').value = name;
    currentStock = stock;

    // Show current stock strip
    var strip  = document.getElementById('stockStrip');
    strip.style.display = 'flex';
    document.getElementById('stockNum').textContent = stock;

    // Reset quantity and preview
    document.getElementById('quantity').value = '';
    document.getElementById('previewStrip').style.display = 'none';
}

function updatePreview() {
    var qty = parseInt(document.getElementById('quantity').value, 10);
    var preview = document.getElementById('previewStrip');

    if (!isNaN(qty) && qty > 0) {
        var newStock = currentStock + qty;
        document.getElementById('newStockNum').textContent = newStock + ' units';
        preview.style.display = 'flex';
    } else {
        preview.style.display = 'none';
    }
}

function validateForm() {
    var pid    = document.getElementById('productId').value;
    var qty    = parseInt(document.getElementById('quantity').value, 10);
    var amount = document.getElementById('additionalCredit').value;

    if (!pid)                                    { alert('⚠️ Please select a product.');       return false; }
    if (!qty || qty <= 0)                        { alert('⚠️ Please enter a valid quantity.');  return false; }
    if (!amount || parseFloat(amount) <= 0)      { alert('⚠️ Please enter a valid amount.');    return false; }
    return true;
}
</script>
</body>
</html>
