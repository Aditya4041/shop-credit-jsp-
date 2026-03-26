<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.sql.*, doa.DBConnection, doa.ShopConfig" %>
<%!
private String jsEscape(String s) {
    if (s == null) return "";
    return s.replace("\\", "\\\\")
            .replace("\"", "\\\"")
            .replace("'",  "\\'")
            .replace("\r", "\\r")
            .replace("\n", "\\n")
            .replace("\t", "\\t");
}
%>
<%
    if (session.getAttribute("admin") == null) {
        response.sendRedirect("login.jsp?error=Please login first");
        return;
    }
    String idStr = request.getParameter("id");
    if (idStr == null) {
        response.sendRedirect("view_customers.jsp");
        return;
    }
    int customerId = Integer.parseInt(idStr);

    String custName = "", custPhone = "", custAddress = "", custMarathiName = "";
    double custCredit = 0;
    int txnCount = 0;
    double totalAdded = 0, totalSettled = 0;

    try (Connection conn = DBConnection.getConnection()) {
        PreparedStatement ps = conn.prepareStatement("SELECT * FROM customers WHERE id = ?");
        ps.setInt(1, customerId);
        ResultSet rs = ps.executeQuery();
        if (rs.next()) {
            custName        = rs.getString("name");
            custMarathiName = rs.getString("marathi_name");
            if (custMarathiName == null) custMarathiName = "";
            custPhone   = rs.getString("phone");
            custCredit  = rs.getDouble("credit");
            custAddress = rs.getString("address");
            if (custAddress == null || custAddress.trim().isEmpty()) custAddress = "—";
        }
        PreparedStatement psTxn = conn.prepareStatement(
            "SELECT COUNT(*), " +
            "SUM(CASE WHEN transaction_type='ADD' THEN amount ELSE 0 END), " +
            "SUM(CASE WHEN transaction_type='SETTLE' THEN amount ELSE 0 END) " +
            "FROM customer_transactions WHERE customer_id = ?");
        psTxn.setInt(1, customerId);
        ResultSet rsTxn = psTxn.executeQuery();
        if (rsTxn.next()) {
            txnCount     = rsTxn.getInt(1);
            totalAdded   = rsTxn.getDouble(2);
            totalSettled = rsTxn.getDouble(3);
        }
    } catch (Exception e) { /* ignore */ }

    ShopConfig shop      = ShopConfig.getInstance();
    String shopEnNameJs  = shop.getEnglishNameJs();
    String shopMrNameJs  = shop.getMarathiNameJs();

    String displayNameJs   = jsEscape(custName);
    String displayMrNameJs = jsEscape(custMarathiName.isEmpty() ? custName : custMarathiName);
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>Customer Details</title>
    <link rel="stylesheet" href="css/content.css">
    <style>
        .product-tag {
            background: #e8f0fe; color: #1a56db;
            padding: 3px 10px; border-radius: 20px;
            font-size: 12px; font-weight: 600; white-space: nowrap;
        }
        .product-tag.settle { background: #fef3e2; color: #b45309; }
        .qty-pill {
            display: inline-block;
            background: #f0f4ff; color: #2b0d73;
            border: 1px solid #c8d8f8;
            border-radius: 20px; padding: 2px 12px;
            font-size: 12px; font-weight: 700;
        }
        .qty-pill.na { background: #f5f5f5; color: #aaa; border-color: #e0e0e0; font-weight: 400; }
        .pay-cash   { display:inline-flex; align-items:center; gap:4px; background:#e8f5e9; color:#1b5e20; border:1px solid #a5d6a7; border-radius:20px; padding:3px 12px; font-size:12px; font-weight:700; }
        .pay-online { display:inline-flex; align-items:center; gap:4px; background:#e3f2fd; color:#0d47a1; border:1px solid #90caf9; border-radius:20px; padding:3px 12px; font-size:12px; font-weight:700; }
        .pay-na     { display:inline-block; background:#f5f5f5; color:#aaa; border:1px solid #e0e0e0; border-radius:20px; padding:3px 12px; font-size:12px; }
        .info-item.address-item .info-value {
            font-size: 14px !important; font-weight: 600 !important;
            color: #2b0d73 !important; max-width: 260px;
            white-space: normal; line-height: 1.45;
        }
        .print-controls {
            display: flex; align-items: center; gap: 12px;
            background: #fff; border: 1px solid #e2e8f0;
            border-left: 4px solid #0d1b2a;
            border-radius: 10px; padding: 12px 16px;
            margin-bottom: 16px; flex-wrap: wrap;
        }
        .print-controls label { font-size: 12px; font-weight: 700; color: #4a5568; text-transform: uppercase; letter-spacing: 0.4px; }
        .print-controls input[type="date"] {
            padding: 7px 11px; border: 1.5px solid #e2e8f0; border-radius: 7px;
            font-family: 'Outfit', sans-serif; font-size: 13px; color: #0d1b2a;
            background: #f8fafc; outline: none; transition: border 0.18s;
        }
        .print-controls input[type="date"]:focus { border-color: #0d1b2a; }
        .btn-print {
            padding: 8px 18px;
            background: linear-gradient(135deg, #0d1b2a, #162538);
            color: #fff; border: none; border-radius: 8px;
            font-family: 'Outfit', sans-serif;
            font-size: 13px; font-weight: 600; cursor: pointer;
            display: inline-flex; align-items: center; gap: 6px;
            transition: background 0.2s; white-space: nowrap;
        }
        .btn-print:hover { background: #1e3350; }
        .btn-print-all {
            padding: 8px 18px; background: transparent;
            color: #0d1b2a; border: 1.5px solid #0d1b2a; border-radius: 8px;
            font-family: 'Outfit', sans-serif; font-size: 13px; font-weight: 600; cursor: pointer;
            display: inline-flex; align-items: center; gap: 6px;
            transition: all 0.2s; white-space: nowrap;
        }
        .btn-print-all:hover { background: #0d1b2a; color: #fff; }
        /* Stat chip label for lang switch */
        .s-label-en, .s-label-mr { display: block; }
    </style>
</head>
<body>
<div class="content-wrapper">

    <div class="no-print">
        <a href="view_customers.jsp" class="back-link" data-i18n="btn.back_customers">← Back to Customer List</a>
    </div>

    <!-- Customer Info Card -->
    <div class="detail-info-card no-print">
        <div class="info-item">
            <span class="info-label" data-i18n="vc.th_id">ID</span>
            <span class="info-value">#<%= customerId %></span>
        </div>
        <div class="info-item">
            <span class="info-label" data-i18n="vc.th_name">Name</span>
            <span class="info-value">
                👤
                <span class="lang-name-en"><%= custName %></span>
                <span class="lang-name-mr" style="display:none;"><%= custMarathiName.isEmpty() ? custName : custMarathiName %></span>
            </span>
        </div>
        <div class="info-item">
            <span class="info-label" data-i18n="vc.th_phone">Phone</span>
            <span class="info-value">📞 <%= custPhone %></span>
        </div>
        <div class="info-item address-item">
            <span class="info-label">
                <span class="lang-name-en">Address</span>
                <span class="lang-name-mr" style="display:none;">पत्ता</span>
            </span>
            <span class="info-value">📍 <%= custAddress %></span>
        </div>
        <div class="info-item">
            <span class="info-label">
                <span class="lang-name-en">Current Credit</span>
                <span class="lang-name-mr" style="display:none;">सध्याची उधार</span>
            </span>
            <span class="info-value credit-amount">₹ <%= String.format("%.2f", custCredit) %></span>
        </div>
    </div>

    <!-- Stats Row -->
    <div class="stats-row no-print">
        <div class="stat-chip">
            <div class="s-label">
                <span class="lang-name-en">Total Transactions</span>
                <span class="lang-name-mr" style="display:none;">एकूण व्यवहार</span>
            </div>
            <div class="s-value"><%= txnCount %></div>
        </div>
        <div class="stat-chip green">
            <div class="s-label">
                <span class="lang-name-en">Total Added</span>
                <span class="lang-name-mr" style="display:none;">एकूण जोडलेली</span>
            </div>
            <div class="s-value">₹ <%= String.format("%.2f", totalAdded) %></div>
        </div>
        <div class="stat-chip red">
            <div class="s-label">
                <span class="lang-name-en">Total Settled</span>
                <span class="lang-name-mr" style="display:none;">एकूण परतफेड</span>
            </div>
            <div class="s-value">₹ <%= String.format("%.2f", totalSettled) %></div>
        </div>
        <div class="stat-chip">
            <div class="s-label">
                <span class="lang-name-en">Net Credit</span>
                <span class="lang-name-mr" style="display:none;">निव्वळ उधार</span>
            </div>
            <div class="s-value" style="color:#2b0d73;">₹ <%= String.format("%.2f", custCredit) %></div>
        </div>
    </div>

    <!-- Print Controls -->
    <div class="print-controls no-print">
        <span style="font-size:14px;">🖨️</span>
        <label data-i18n="det.print_from">From:</label>
        <input type="date" id="fromDate">
        <label data-i18n="det.print_to">To:</label>
        <input type="date" id="toDate">
        <button class="btn-print" onclick="printFiltered()" data-i18n="det.print_range">🖨️ Print Selected Range</button>
        <button class="btn-print-all" onclick="printAll()" data-i18n="det.print_all">Print All Transactions</button>
    </div>

    <!-- Transaction Table -->
    <h3 style="font-size:16px; color:#373279; font-weight:700; margin-bottom:12px;
               border-bottom:2px solid #c8b7f6; padding-bottom:8px;" class="no-print" data-i18n="det.txn_history">
        📊 Transaction History
    </h3>

    <div class="table-container no-print">
        <table>
            <thead>
                <tr>
                    <th data-i18n="det.th_no">#</th>
                    <th data-i18n="det.th_txn_id">Txn ID</th>
                    <th data-i18n="det.th_date">Date</th>
                    <th data-i18n="det.th_type">Type</th>
                    <th data-i18n="det.th_product">Product / Item</th>
                    <th data-i18n="det.th_qty">Quantity</th>
                    <th data-i18n="det.th_pay">Payment Mode</th>
                    <th data-i18n="det.th_amount">Amount (₹)</th>
                </tr>
            </thead>
            <tbody>
            <%
                int sNo = 1;
                try (Connection conn = DBConnection.getConnection()) {
                    PreparedStatement ps = conn.prepareStatement(
                        "SELECT * FROM customer_transactions WHERE customer_id = ? ORDER BY transaction_date DESC");
                    ps.setInt(1, customerId);
                    ResultSet rs = ps.executeQuery();
                    boolean hasTxn = false;
                    while (rs.next()) {
                        hasTxn = true;
                        String type        = rs.getString("transaction_type");
                        String prodName    = rs.getString("product_name");
                        int    qty         = rs.getInt("quantity");
                        String paymentMode = rs.getString("payment_mode");
                        if (prodName == null || prodName.trim().isEmpty()) prodName = "—";
                        boolean isAdd = "ADD".equals(type);
            %>
                <tr>
                    <td><%= sNo++ %></td>
                    <td><strong><%= rs.getInt("id") %></strong></td>
                    <td><%= rs.getDate("transaction_date") %></td>
                    <td>
                        <% if (isAdd) { %><span class="badge-add">➕ ADD</span>
                        <% } else { %><span class="badge-settle">✅ SETTLE</span><% } %>
                    </td>
                    <td><span class="product-tag <%= isAdd ? "" : "settle" %>">📦 <%= prodName %></span></td>
                    <td>
                        <% if (isAdd && qty > 0) { %>
                        <span class="qty-pill"><%= qty %> unit<%= qty != 1 ? "s" : "" %></span>
                        <% } else { %><span class="qty-pill na">—</span><% } %>
                    </td>
                    <td>
                        <% if (!isAdd && paymentMode != null) {
                            if ("CASH".equals(paymentMode)) { %><span class="pay-cash">💵 <span class="lang-name-en">Cash</span><span class="lang-name-mr" style="display:none;">रोख</span></span>
                            <% } else if ("ONLINE".equals(paymentMode)) { %><span class="pay-online">📱 <span class="lang-name-en">Online</span><span class="lang-name-mr" style="display:none;">ऑनलाइन</span></span>
                            <% } else { %><span class="pay-na"><%= paymentMode %></span>
                            <% } } else { %><span class="pay-na">—</span><% } %>
                    </td>
                    <td style="font-weight:700; color:<%= isAdd ? "#2e7d32" : "#c62828" %>;">
                        ₹ <%= String.format("%.2f", rs.getDouble("amount")) %>
                    </td>
                </tr>
            <%
                    }
                    if (!hasTxn) {
            %>
                <tr><td colspan="8" class="no-data" data-i18n="det.no_txn">No transactions found for this customer.</td></tr>
            <%  }
                } catch (Exception e) { %>
                <tr><td colspan="8" class="no-data">❌ Error: <%= e.getMessage() %></td></tr>
            <% } %>
            </tbody>
        </table>
    </div>
</div>

<script src="js/i18n.js"></script>
<script>
var SHOP_NAME_EN = "<%= shopEnNameJs %>";
var SHOP_NAME_MR = "<%= shopMrNameJs %>";

var allTxns = [
<%
    try (Connection conn = DBConnection.getConnection()) {
        PreparedStatement ps = conn.prepareStatement(
            "SELECT id, transaction_date, transaction_type, product_name, quantity, payment_mode, amount " +
            "FROM customer_transactions WHERE customer_id = ? ORDER BY transaction_date DESC");
        ps.setInt(1, customerId);
        ResultSet rs = ps.executeQuery();
        boolean first = true;
        while (rs.next()) {
            if (!first) out.print(",");
            first = false;
            String pn = rs.getString("product_name");
            if (pn == null || pn.trim().isEmpty()) pn = "—";
            String pm = rs.getString("payment_mode");
            if (pm == null) pm = "—";
            out.print("{id:" + rs.getInt("id") +
                ",date:\"" + rs.getDate("transaction_date") + "\"" +
                ",type:\"" + rs.getString("transaction_type") + "\"" +
                ",product:\"" + jsEscape(pn) + "\"" +
                ",qty:" + rs.getInt("quantity") +
                ",paymode:\"" + jsEscape(pm) + "\"" +
                ",amount:" + rs.getDouble("amount") + "}");
        }
    } catch (Exception e) {}
%>
];

var CUST_NAME_EN = "<%= displayNameJs %>";
var CUST_NAME_MR = "<%= displayMrNameJs %>";
var CUST_ID      = "<%= customerId %>";
var CUST_PHONE   = "<%= jsEscape(custPhone) %>";
var CUST_ADDR    = "<%= jsEscape(custAddress) %>";
var CUST_CREDIT  = "<%= String.format("%.2f", custCredit) %>";

function getLang() { return (typeof i18n !== 'undefined') ? i18n.getLang() : 'en'; }

function buildPopupHtml(txns, periodLabel, dateStr) {
    var lang  = getLang();
    var isMr  = (lang === 'mr');
    var shopName  = isMr ? SHOP_NAME_MR : SHOP_NAME_EN;
    var custName  = isMr ? CUST_NAME_MR : CUST_NAME_EN;

    var labels = isMr ? {
        title: 'ग्राहक व्यवहार विवरण',
        custLabel: 'ग्राहकाचे नाव', custId: 'ग्राहक क्र.', phone: 'दूरध्वनी क्र.',
        addr: 'पत्ता', credit: 'सध्याची उधार शिल्लक',
        added: 'एकूण जोडलेली', settled: 'एकूण परतफेड', txns: 'व्यवहार',
        net: 'या कालावधीचे एकूण',
        th: ['#','दिनांक','प्रकार','उत्पाद / वस्तू','प्रमाण','देयक पद्धत','रक्कम (₹)'],
        add: '+ जोडली', settle: '✓ परतफेड',
        cash: 'रोख', online: 'ऑनलाइन',
        footer: 'ग्राहक व्यवहार विवरण'
    } : {
        title: 'Customer Transaction Statement',
        custLabel: 'Customer Name', custId: 'Customer ID', phone: 'Phone No.',
        addr: 'Address', credit: 'Current Credit Balance',
        added: 'Total Added', settled: 'Total Settled', txns: 'Transactions',
        net: 'Net for Period',
        th: ['#','Date','Type','Product / Item','Quantity','Payment Mode','Amount (Rs.)'],
        add: '+ ADD', settle: '✓ SETTLE',
        cash: 'Cash', online: 'Online',
        footer: 'Customer Transaction Statement'
    };

    var rows = '';
    var sumAdded = 0, sumSettled = 0, sNo = 1;
    txns.forEach(function(t) {
        var isAdd = t.type === 'ADD';
        if (isAdd) sumAdded += t.amount; else sumSettled += t.amount;
        var pmLabel  = isAdd ? '—' : (t.paymode === 'CASH' ? labels.cash : (t.paymode === 'ONLINE' ? labels.online : t.paymode));
        var qtyLabel = (isAdd && t.qty > 0) ? (t.qty + (isMr ? ' नग' : ' unit' + (t.qty !== 1 ? 's' : ''))) : '—';
        var amtColor = isAdd ? '#1b5e20' : '#b91c1c';
        var bg = sNo % 2 === 0 ? 'background:#f8fafc;' : '';
        rows += '<tr style="' + bg + '">' +
            '<td style="padding:8px 10px;border-bottom:1px solid #e2e8f0;">' + sNo++ + '</td>' +
            '<td style="padding:8px 10px;border-bottom:1px solid #e2e8f0;">' + t.date + '</td>' +
            '<td style="padding:8px 10px;border-bottom:1px solid #e2e8f0;font-weight:700;">' + (isAdd ? labels.add : labels.settle) + '</td>' +
            '<td style="padding:8px 10px;border-bottom:1px solid #e2e8f0;">' + t.product + '</td>' +
            '<td style="padding:8px 10px;border-bottom:1px solid #e2e8f0;text-align:center;">' + qtyLabel + '</td>' +
            '<td style="padding:8px 10px;border-bottom:1px solid #e2e8f0;text-align:center;">' + pmLabel + '</td>' +
            '<td style="padding:8px 10px;border-bottom:1px solid #e2e8f0;text-align:right;font-weight:700;color:' + amtColor + ';">&#8377; ' + t.amount.toFixed(2) + '</td>' +
            '</tr>';
    });
    var net = sumAdded - sumSettled;
    var thHtml = labels.th.map(function(h){ return '<th>' + h + '</th>'; }).join('');

    return '<!DOCTYPE html><html><head><meta charset="UTF-8">' +
        '<title>' + labels.title + ' - ' + custName + '</title>' +
        '<style>body{font-family:Arial,sans-serif;margin:30px;color:#0d1b2a;font-size:13px;}' +
        '.header{text-align:center;border-bottom:3px double #0d1b2a;padding-bottom:14px;margin-bottom:16px;}' +
        '.shop-name{font-size:24px;font-weight:800;letter-spacing:2px;text-transform:uppercase;}' +
        '.report-title{font-size:14px;font-weight:600;color:#4a5568;margin-top:4px;}' +
        '.report-meta{font-size:12px;color:#94a3b8;margin-top:5px;}' +
        '.info-box{display:grid;grid-template-columns:1fr 1fr;gap:6px 24px;background:#f8fafc;border:1px solid #e2e8f0;padding:12px 16px;margin-bottom:14px;border-radius:4px;}' +
        '.info-item{display:flex;flex-direction:column;gap:2px;}' +
        '.info-label{font-size:9px;font-weight:700;color:#94a3b8;text-transform:uppercase;letter-spacing:0.8px;}' +
        '.info-value{font-size:13px;font-weight:700;color:#0d1b2a;}' +
        '.info-value.credit{color:#00805a;font-size:15px;}' +
        '.summary{display:grid;grid-template-columns:repeat(3,1fr);gap:8px;margin-bottom:14px;}' +
        '.sum-chip{background:#f8fafc;border:1px solid #e2e8f0;padding:8px 10px;text-align:center;border-radius:4px;}' +
        '.sum-chip .sl{font-size:9px;font-weight:700;color:#94a3b8;text-transform:uppercase;}' +
        '.sum-chip .sv{font-size:14px;font-weight:800;margin-top:3px;}' +
        'table{width:100%;border-collapse:collapse;}' +
        'th{background:#0d1b2a;color:#fff;padding:8px 10px;text-align:left;font-size:10px;text-transform:uppercase;letter-spacing:0.5px;}' +
        'tfoot td{background:#f0f2f8;font-weight:700;border-top:2px solid #0d1b2a;padding:9px 10px;}' +
        '.footer{margin-top:16px;text-align:center;font-size:10px;color:#94a3b8;border-top:1px solid #e2e8f0;padding-top:8px;}' +
        '@media print{body{margin:12px;}}' +
        '</style></head><body>' +
        '<div class="header">' +
        '<div class="shop-name">' + shopName + '</div>' +
        '<div class="report-title">' + labels.title + '</div>' +
        '<div class="report-meta">' + periodLabel + '</div>' +
        '</div>' +
        '<div class="info-box">' +
        '<div class="info-item"><span class="info-label">' + labels.custLabel + '</span><span class="info-value">' + custName + '</span></div>' +
        '<div class="info-item"><span class="info-label">' + labels.custId + '</span><span class="info-value">#' + CUST_ID + '</span></div>' +
        '<div class="info-item"><span class="info-label">' + labels.phone + '</span><span class="info-value">' + CUST_PHONE + '</span></div>' +
        '<div class="info-item"><span class="info-label">' + labels.addr + '</span><span class="info-value">' + CUST_ADDR + '</span></div>' +
        '<div class="info-item"><span class="info-label">' + labels.credit + '</span><span class="info-value credit">&#8377; ' + CUST_CREDIT + '</span></div>' +
        '</div>' +
        '<div class="summary">' +
        '<div class="sum-chip"><div class="sl">' + labels.added + '</div><div class="sv" style="color:#00805a;">&#8377; ' + sumAdded.toFixed(2) + '</div></div>' +
        '<div class="sum-chip"><div class="sl">' + labels.settled + '</div><div class="sv" style="color:#be123c;">&#8377; ' + sumSettled.toFixed(2) + '</div></div>' +
        '<div class="sum-chip"><div class="sl">' + labels.txns + '</div><div class="sv">' + txns.length + '</div></div>' +
        '</div>' +
        '<table><thead><tr>' + thHtml + '</tr></thead><tbody>' + rows + '</tbody>' +
        '<tfoot><tr>' +
        '<td colspan="6" style="text-align:right;">' + labels.net + '</td>' +
        '<td style="text-align:right;">&#8377; ' + net.toFixed(2) + '</td>' +
        '</tr></tfoot></table>' +
        '<div class="footer">' + shopName + ' &middot; ' + labels.footer + ' &middot; ' + dateStr + '</div>' +
        '</body></html>';
}

function printFiltered() {
    var from = document.getElementById('fromDate').value;
    var to   = document.getElementById('toDate').value;
    var lang = getLang(); var isMr = lang === 'mr';
    if (!from || !to) { alert(isMr ? 'कृपया दोन्ही तारखा निवडा.' : 'Please select both From and To dates.'); return; }
    if (from > to)    { alert(isMr ? 'प्रारंभ तारीख अंत तारखेपेक्षा नंतर असू शकत नाही.' : 'From date cannot be after To date.'); return; }
    var filtered = allTxns.filter(function(t) { return t.date >= from && t.date <= to; });
    if (filtered.length === 0) { alert(isMr ? 'निवडलेल्या कालावधीत कोणताही व्यवहार नाही.' : 'No transactions found in the selected date range.'); return; }
    var fromFmt = new Date(from + 'T00:00:00').toLocaleDateString('en-IN', {day:'2-digit',month:'short',year:'numeric'});
    var toFmt   = new Date(to   + 'T00:00:00').toLocaleDateString('en-IN', {day:'2-digit',month:'short',year:'numeric'});
    var now     = new Date();
    var dateStr = now.toLocaleDateString('en-IN', {weekday:'long',year:'numeric',month:'long',day:'numeric'});
    var periodLabel = (isMr ? 'कालावधी: ' : 'Period: ') + fromFmt + ' — ' + toFmt;
    var pw = window.top.open('', '_blank', 'width=1000,height=700');
    if (!pw) { alert('⚠️ Popup blocked. Please allow popups for this site.'); return; }
    pw.document.write(buildPopupHtml(filtered, periodLabel, dateStr));
    pw.document.close(); pw.focus(); pw.print();
}

function printAll() {
    var lang = getLang(); var isMr = lang === 'mr';
    if (allTxns.length === 0) { alert(isMr ? 'कोणताही व्यवहार उपलब्ध नाही.' : 'No transactions found for this customer.'); return; }
    var now = new Date();
    var dateStr = now.toLocaleDateString('en-IN', {weekday:'long',year:'numeric',month:'long',day:'numeric'});
    var periodLabel = (isMr ? 'सर्व व्यवहार · छापण्याची तारीख: ' : 'All Transactions · Printed: ') + dateStr;
    var pw = window.top.open('', '_blank', 'width=1000,height=700');
    if (!pw) { alert('⚠️ Popup blocked. Please allow popups for this site.'); return; }
    pw.document.write(buildPopupHtml(allTxns, periodLabel, dateStr));
    pw.document.close(); pw.focus(); pw.print();
}

(function() {
    var today = new Date();
    var firstOfMonth = new Date(today.getFullYear(), today.getMonth(), 1);
    document.getElementById('toDate').value   = today.toISOString().split('T')[0];
    document.getElementById('fromDate').value = firstOfMonth.toISOString().split('T')[0];
})();
</script>
</body>
</html>
