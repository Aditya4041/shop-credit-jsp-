<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.sql.*, doa.DBConnection, doa.ShopConfig" %>
<%
    if (session.getAttribute("admin") == null) {
        response.sendRedirect("login.jsp?error=Please login first");
        return;
    }
    String keyword = request.getParameter("keyword");
    boolean hasKeyword = (keyword != null && !keyword.trim().isEmpty());

    ShopConfig shop     = ShopConfig.getInstance();
    String shopEnNameJs = shop.getEnglishNameJs();
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>View Dealers</title>
    <link rel="stylesheet" href="css/content.css">
    <style>
        .btn-eye {
            background: none; border: none; cursor: pointer;
            padding: 3px 5px; color: #7c73b8;
            display: inline-flex; align-items: center; justify-content: center;
            border-radius: 5px; transition: color 0.2s, background 0.2s;
            vertical-align: middle; outline: none;
        }
        .btn-eye:hover { color: #2b0d73; background: #ede9ff; }
        .btn-eye svg   { display: block; pointer-events: none; }

        .btn-action-add {
            padding: 6px 16px;
            background: linear-gradient(135deg, #4caf50, #2e7d32);
            color: #fff; border: none; border-radius: 7px;
            font-size: 12px; font-weight: 700;
            text-decoration: none; display: inline-block;
            transition: opacity 0.2s, transform 0.15s; white-space: nowrap;
        }
        .btn-action-add:hover { opacity: 0.88; transform: scale(1.04); }

        .btn-action-settle {
            padding: 6px 16px;
            background: linear-gradient(135deg, #e53935, #b71c1c);
            color: #fff; border: none; border-radius: 7px;
            font-size: 12px; font-weight: 700;
            text-decoration: none; display: inline-block;
            transition: opacity 0.2s, transform 0.15s; white-space: nowrap;
        }
        .btn-action-settle:hover { opacity: 0.88; transform: scale(1.04); }

        .action-btns { display: flex; gap: 6px; justify-content: center; flex-wrap: wrap; }

        .btn-print {
            padding: 9px 20px;
            background: linear-gradient(135deg, #7a3800, #d4681a);
            color: #fff; border: none; border-radius: 8px;
            font-family: 'Outfit', sans-serif;
            font-size: 13.5px; font-weight: 600;
            cursor: pointer; white-space: nowrap;
            transition: background 0.2s;
            display: inline-flex; align-items: center; gap: 7px;
        }
        .btn-print:hover { opacity: 0.88; }
    </style>
</head>
<body>

<div class="content-wrapper">

    <% if (request.getParameter("success") != null) { %>
    <div class="alert alert-success">✅ <%= request.getParameter("success") %></div>
    <% } %>
    <% if (request.getParameter("error") != null) { %>
    <div class="alert alert-error">❌ <%= request.getParameter("error") %></div>
    <% } %>

    <div style="display:flex; align-items:center; justify-content:space-between; margin-bottom:14px; flex-wrap:wrap; gap:10px;" class="no-print">
        <form class="search-bar" action="view_dealers.jsp" method="get" style="margin-bottom:0; flex:1;">
            <input type="text" name="keyword" placeholder="🔍 Search by Name, Phone or ID"
                   value="<%= hasKeyword ? keyword : "" %>">
            <button type="submit" class="btn-search">Search</button>
            <a href="view_dealers.jsp" class="btn-reset">Reset</a>
        </form>
        <button class="btn-print" onclick="printStatement()">🖨️ Print Statement</button>
    </div>

    <div class="table-container no-print">
        <table>
            <thead>
                <tr>
                    <th>ID</th>
                    <th>Dealer Name</th>
                    <th>Phone</th>
                    <th>Total Credit (₹)</th>
                    <th>Actions</th>
                    <th>Details</th>
                </tr>
            </thead>
            <tbody>
            <%
                String sql = "SELECT * FROM dealers";
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
                        <span style="font-size:16px;">🏬</span> <%= name %>
                    </td>
                    <td>📞 <%= phone %></td>
                    <td>
                        <span class="credit-val" id="dcredit-<%= id %>">••••••</span>
                        <button class="btn-eye"
                                onclick="toggleCredit(<%= id %>, <%= credit %>)"
                                title="Show / Hide credit">
                            <svg id="deye-open-<%= id %>" width="18" height="18" viewBox="0 0 24 24"
                                 fill="none" stroke="currentColor" stroke-width="2"
                                 stroke-linecap="round" stroke-linejoin="round">
                                <path d="M1 12s4-8 11-8 11 8 11 8-4 8-11 8-11-8-11-8z"/>
                                <circle cx="12" cy="12" r="3"/>
                            </svg>
                            <svg id="deye-closed-<%= id %>" width="18" height="18" viewBox="0 0 24 24"
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
                        <div class="action-btns">
                            <a href="add_credit_dealer.jsp?id=<%= id %>"
                               class="btn-action-add">➕ Add Credit</a>
                            <a href="settle_credit_dealer.jsp?id=<%= id %>"
                               class="btn-action-settle">✅ Settle</a>
                        </div>
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
                <tr><td colspan="6" class="no-data">⚠ No dealers found.</td></tr>
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

<script>
// ── Shop identity (loaded from DB via ShopConfig) ──────────────────────────
var SHOP_NAME = "<%= shopEnNameJs %>";

var dealerData = [
<%
    try (Connection conn = DBConnection.getConnection();
         java.sql.Statement st = conn.createStatement();
         ResultSet rs = st.executeQuery("SELECT id, name, phone, credit FROM dealers ORDER BY id ASC")) {
        boolean first = true;
        while (rs.next()) {
            if (!first) out.print(",");
            first = false;
            out.print("{id:" + rs.getInt("id") + ",name:\"" + rs.getString("name").replace("\"","\\\"") + "\",phone:\"" + rs.getString("phone") + "\",credit:" + rs.getDouble("credit") + "}");
        }
    } catch (Exception e) {}
%>
];

function toggleCredit(id, amount) {
    var span      = document.getElementById('dcredit-'     + id);
    var eyeOpen   = document.getElementById('deye-open-'   + id);
    var eyeClosed = document.getElementById('deye-closed-' + id);
    if (span.textContent === '••••••') {
        span.textContent        = '₹ ' + parseFloat(amount).toFixed(2);
        eyeOpen.style.display   = 'none';
        eyeClosed.style.display = 'block';
    } else {
        span.textContent        = '••••••';
        eyeOpen.style.display   = 'block';
        eyeClosed.style.display = 'none';
    }
}

function printStatement() {
    var now = new Date();
    var dateStr = now.toLocaleDateString('en-IN', { weekday:'long', year:'numeric', month:'long', day:'numeric' });
    var timeStr = now.toLocaleTimeString('en-IN', { hour:'2-digit', minute:'2-digit' });

    var rows = '';
    var total = 0;
    var sNo = 1;
    dealerData.forEach(function(d) {
        total += d.credit;
        var bg = sNo % 2 === 0 ? 'background:#fff8f0;' : '';
        rows += '<tr style="' + bg + '">' +
            '<td style="padding:9px 12px;border-bottom:1px solid #e2e8f0;">' + sNo++ + '</td>' +
            '<td style="padding:9px 12px;border-bottom:1px solid #e2e8f0;">#' + d.id + '</td>' +
            '<td style="padding:9px 12px;border-bottom:1px solid #e2e8f0;">' + d.name + '</td>' +
            '<td style="padding:9px 12px;border-bottom:1px solid #e2e8f0;">' + d.phone + '</td>' +
            '<td style="padding:9px 12px;border-bottom:1px solid #e2e8f0;text-align:right;font-weight:700;">&#8377; ' + d.credit.toFixed(2) + '</td>' +
            '</tr>';
    });

    var html = '<!DOCTYPE html><html><head><meta charset="UTF-8">' +
        '<title>Dealer Credit Statement - ' + SHOP_NAME + '</title>' +
        '<style>' +
        'body{font-family:Arial,sans-serif;margin:30px;color:#0d1b2a;}' +
        '.header{text-align:center;border-bottom:3px double #7a3800;padding-bottom:14px;margin-bottom:20px;}' +
        '.shop-name{font-size:26px;font-weight:800;letter-spacing:2px;text-transform:uppercase;}' +
        '.report-title{font-size:14px;font-weight:600;color:#4a5568;margin-top:4px;}' +
        '.report-meta{font-size:12px;color:#94a3b8;margin-top:5px;}' +
        'table{width:100%;border-collapse:collapse;font-size:13px;}' +
        'th{background:#7a3800;color:#fff;padding:10px 12px;text-align:left;font-size:11px;text-transform:uppercase;letter-spacing:0.6px;}' +
        'tfoot td{background:#fff3e0;font-weight:700;border-top:2px solid #7a3800;padding:11px 12px;}' +
        '.footer{margin-top:20px;text-align:center;font-size:11px;color:#94a3b8;border-top:1px solid #e2e8f0;padding-top:10px;}' +
        '@media print{body{margin:15px;}}' +
        '</style></head><body>' +
        '<div class="header">' +
        '<div class="shop-name">' + SHOP_NAME + '</div>' +
        '<div class="report-title">Dealer Credit Statement</div>' +
        '<div class="report-meta">Generated on: ' + dateStr + ' at ' + timeStr + '</div>' +
        '</div>' +
        '<table><thead><tr>' +
        '<th>#</th><th>Dealer ID</th><th>Dealer Name</th><th>Phone No.</th><th style="text-align:right;">Credit Amount (Rs.)</th>' +
        '</tr></thead><tbody>' + rows + '</tbody>' +
        '<tfoot><tr>' +
        '<td colspan="4" style="text-align:right;font-size:13px;">Total Outstanding Credit</td>' +
        '<td style="text-align:right;font-size:14px;">&#8377; ' + total.toFixed(2) + '</td>' +
        '</tr></tfoot></table>' +
        '<div class="footer">' + SHOP_NAME + ' &middot; Dealer Credit Statement &middot; Printed on ' + dateStr + '</div>' +
        '</body></html>';

    var pw = window.open('', '_blank', 'width=900,height=650');
    pw.document.write(html);
    pw.document.close();
    pw.focus();
    pw.print();
}
</script>
</body>
</html>
