<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.sql.*, doa.DBConnection" %>
<%
    if (session.getAttribute("admin") == null) {
        response.sendRedirect("login.jsp?error=Please login first");
        return;
    }
    String idStr = request.getParameter("id");
    if (idStr == null || idStr.trim().isEmpty()) {
        response.sendRedirect("view_customers.jsp");
        return;
    }
    int customerId = Integer.parseInt(idStr.trim());
    String custName  = "";
    String custPhone = "";
    double custCredit = 0;

    try (Connection conn = DBConnection.getConnection()) {
        PreparedStatement ps = conn.prepareStatement(
            "SELECT name, phone, credit FROM customers WHERE id = ?");
        ps.setInt(1, customerId);
        ResultSet rs = ps.executeQuery();
        if (rs.next()) {
            custName   = rs.getString("name");
            custPhone  = rs.getString("phone");
            custCredit = rs.getDouble("credit");
        } else {
            response.sendRedirect("view_customers.jsp?error=Customer not found");
            return;
        }
    } catch (Exception e) {
        response.sendRedirect("view_customers.jsp?error=" + e.getMessage());
        return;
    }
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>Settle Credit — <%= custName %></title>
    <link rel="stylesheet" href="css/content.css">
    <style>
        .entity-banner {
            background: linear-gradient(135deg, #0d1b2a 0%, #1e3350 100%);
            border-radius: 16px; padding: 20px 24px; margin-bottom: 22px;
            display: flex; align-items: center; gap: 18px; flex-wrap: wrap;
            box-shadow: 0 4px 20px rgba(13,27,42,0.2);
        }
        .entity-avatar { width:52px;height:52px;background:rgba(255,255,255,0.08);border:1px solid rgba(255,255,255,0.12);border-radius:14px;display:flex;align-items:center;justify-content:center;font-size:24px;flex-shrink:0; }
        .entity-info { flex:1; }
        .entity-info h3 { font-size:18px;font-weight:700;color:#fff;margin-bottom:3px; }
        .entity-info p  { font-size:12px;color:rgba(255,255,255,0.45); }
        .entity-credit { background:rgba(255,255,255,0.06);border:1px solid rgba(255,255,255,0.1);border-radius:12px;padding:10px 20px;text-align:center; }
        .entity-credit .lbl { font-size:10px;color:rgba(255,255,255,0.4);text-transform:uppercase;letter-spacing:0.8px; }
        .entity-credit .val { font-size:20px;font-weight:800;color:#ff8896;margin-top:2px;font-variant-numeric:tabular-nums; }

        .pay-mode-group { display:flex;gap:14px;flex-wrap:wrap; }
        .pay-option { flex:1;min-width:130px;position:relative; }
        .pay-option input[type="radio"] { position:absolute;opacity:0;width:0;height:0; }
        .pay-option label { display:flex;align-items:center;justify-content:center;gap:10px;padding:14px 18px;border:1.5px solid #e2e8f0;border-radius:12px;background:#fff;cursor:pointer;font-size:14px;font-weight:700;color:#4a5568;transition:all 0.18s;user-select:none; }
        .pay-option label .mode-icon { font-size:22px; }
        .pay-option input[type="radio"]:checked + label { border-color:#0d1b2a;background:#f0f2f8;color:#0d1b2a;box-shadow:0 0 0 3px rgba(13,27,42,0.07); }
        .pay-option label:hover { border-color:#cbd5e1;background:#f8fafc; }
        .warn-box { background:rgba(240,165,0,0.08);border:1px solid rgba(240,165,0,0.2);border-radius:10px;padding:12px 16px;font-size:13px;color:#92400e;margin-bottom:18px;display:flex;align-items:center;gap:8px; }
        .preview-bar { display:none;background:rgba(0,184,122,0.08);border:1px solid rgba(0,184,122,0.2);border-radius:10px;padding:12px 16px;font-size:13px;color:#065f46;font-weight:600; }
    </style>
</head>
<body>
<div class="content-wrapper">

    <% if (request.getParameter("error") != null) { %>
    <div class="alert alert-error">❌ <%= request.getParameter("error") %></div>
    <% } %>

    <a href="view_customers.jsp" class="back-link" data-i18n="btn.back_customers">← Back to Customers</a>

    <% if (custCredit <= 0) { %>
    <div class="warn-box">
        ⚠️ <strong>
            <span class="lang-name-en">No outstanding credit.</span>
            <span class="lang-name-mr" style="display:none;">थकबाकी नाही.</span>
        </strong>
        &nbsp;<span class="lang-name-en">This customer has ₹ <%= String.format("%.2f", custCredit) %> — nothing to settle.</span>
        <span class="lang-name-mr" style="display:none;">या ग्राहकाची थकबाकी ₹ <%= String.format("%.2f", custCredit) %> — परतफेड करण्यासारखे काहीही नाही.</span>
    </div>
    <% } %>

    <!-- Customer Banner -->
    <div class="entity-banner">
        <div class="entity-avatar">👤</div>
        <div class="entity-info">
            <h3><%= custName %></h3>
            <p>📞 <%= custPhone %> &nbsp;·&nbsp; Customer ID #<%= customerId %></p>
        </div>
        <div class="entity-credit">
            <div class="lbl" data-i18n="set.outstanding">Outstanding Credit</div>
            <div class="val">₹ <%= String.format("%.2f", custCredit) %></div>
        </div>
    </div>

    <!-- Settle Form -->
    <div class="form-container" style="padding:0;max-width:600px;">
        <form action="SettleCreditServlet" method="post" onsubmit="return validateForm()">
            <input type="hidden" name="id" value="<%= customerId %>">

            <fieldset>
                <legend data-i18n="set.legend">Settlement Details</legend>
                <div class="form-grid">

                    <div class="form-group full-width">
                        <label for="settleAmount">
                            <span data-i18n="set.amount">Settlement Amount (₹)</span>
                            <span style="color:#ff4757;">*</span>
                        </label>
                        <input type="number" id="settleAmount" name="settleAmount"
                               placeholder="0.00" step="0.01" min="0.01"
                               max="<%= custCredit %>" required
                               oninput="updatePreview(this)">
                        <div style="font-size:12px;color:#94a3b8;margin-top:4px;">
                            <span class="lang-name-en">Maximum: ₹ <%= String.format("%.2f", custCredit) %></span>
                            <span class="lang-name-mr" style="display:none;">कमाल: ₹ <%= String.format("%.2f", custCredit) %></span>
                        </div>
                    </div>

                    <div class="form-group full-width">
                        <label data-i18n="set.pay_mode">Payment Mode <span style="color:#ff4757;">*</span></label>
                        <div class="pay-mode-group">
                            <div class="pay-option">
                                <input type="radio" id="modeCash" name="paymentMode" value="CASH" required checked>
                                <label for="modeCash">
                                    <span class="mode-icon">💵</span>
                                    <span data-i18n="set.cash">Cash</span>
                                </label>
                            </div>
                            <div class="pay-option">
                                <input type="radio" id="modeOnline" name="paymentMode" value="ONLINE">
                                <label for="modeOnline">
                                    <span class="mode-icon">📱</span>
                                    <span data-i18n="set.online">Online Transfer</span>
                                </label>
                            </div>
                        </div>
                    </div>

                    <div class="form-group full-width">
                        <div class="preview-bar" id="previewBar">
                            <span class="lang-name-en">After settlement, remaining balance:</span>
                            <span class="lang-name-mr" style="display:none;">परतफेडीनंतर उर्वरित शिल्लक:</span>
                            <strong id="previewVal">—</strong>
                        </div>
                    </div>

                </div>
            </fieldset>

            <div class="form-buttons">
                <button type="submit" class="btn-save"
                        style="background:linear-gradient(135deg,#ff4757,#c0392b);box-shadow:0 4px 16px rgba(255,71,87,0.25);"
                        <%= custCredit <= 0 ? "disabled" : "" %> data-i18n="set.confirm">
                    ✅ Confirm Settlement
                </button>
                <a href="view_customers.jsp" class="btn-clear"
                   style="text-decoration:none;display:inline-flex;align-items:center;justify-content:center;"
                   data-i18n="btn.cancel">Cancel</a>
            </div>
        </form>
    </div>
</div>

<script src="js/i18n.js"></script>
<script>
var maxCredit = <%= custCredit %>;
function getLang() { return (typeof i18n !== 'undefined') ? i18n.getLang() : 'en'; }
function isMr()    { return getLang() === 'mr'; }

function updatePreview(inp) {
    var val = parseFloat(inp.value);
    var bar = document.getElementById('previewBar');
    var pv  = document.getElementById('previewVal');
    if (!isNaN(val) && val > 0) {
        pv.textContent    = '₹ ' + Math.max(0, maxCredit - val).toFixed(2);
        bar.style.display = 'block';
    } else {
        bar.style.display = 'none';
    }
}

function validateForm() {
    var amt  = parseFloat(document.getElementById('settleAmount').value);
    var mode = document.querySelector('input[name="paymentMode"]:checked');
    var mr   = isMr();
    if (!amt || amt <= 0)  { alert(mr ? 'कृपया योग्य परतफेड रक्कम टाका.'  : 'Please enter a valid settlement amount.'); return false; }
    if (amt > maxCredit)   { alert(mr ? 'रक्कम थकबाकीपेक्षा जास्त आहे (₹ ' + maxCredit.toFixed(2) + ').' : 'Amount exceeds outstanding credit (₹ ' + maxCredit.toFixed(2) + ').'); return false; }
    if (!mode)             { alert(mr ? 'कृपया देयक पद्धत निवडा.'         : 'Please select a payment mode.'); return false; }
    return true;
}
</script>
</body>
</html>
