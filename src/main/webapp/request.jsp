<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.sql.*, doa.DBConnection, doa.ShopConfig" %>
<%
    if (session.getAttribute("admin") == null) {
        response.sendRedirect("login.jsp?error=Please login first");
        return;
    }

    // ── Shop identity ──────────────────────────────────────────────────────
    ShopConfig shop      = ShopConfig.getInstance();
    String shopEnNameJs  = shop.getEnglishNameJs();
    String shopMrNameJs  = shop.getMarathiNameJs();

    // Fetch products for dropdown
    StringBuilder productsJson = new StringBuilder("[");
    try (Connection conn = DBConnection.getConnection()) {
        ResultSet prs = conn.createStatement().executeQuery(
            "SELECT id, product_name, quantity FROM products ORDER BY product_name ASC");
        boolean first = true;
        while (prs.next()) {
            if (!first) productsJson.append(",");
            first = false;
            productsJson.append("{")
                .append("\"id\":").append(prs.getInt("id")).append(",")
                .append("\"name\":\"").append(prs.getString("product_name").replace("\"","\\\"")).append("\",")
                .append("\"stock\":").append(prs.getInt("quantity"))
                .append("}");
        }
    } catch (Exception e) { /* ignore */ }
    productsJson.append("]");

    // Fetch dealers for dropdown
    StringBuilder dealersJson = new StringBuilder("[");
    try (Connection conn = DBConnection.getConnection()) {
        ResultSet drs = conn.createStatement().executeQuery(
            "SELECT id, name FROM dealers ORDER BY name ASC");
        boolean first = true;
        while (drs.next()) {
            if (!first) dealersJson.append(",");
            first = false;
            dealersJson.append("{")
                .append("\"id\":").append(drs.getInt("id")).append(",")
                .append("\"name\":\"").append(drs.getString("name").replace("\"","\\\"")).append("\"")
                .append("}");
        }
    } catch (Exception e) { /* ignore */ }
    dealersJson.append("]");

    // Fetch customers for cash request
    StringBuilder customersJson = new StringBuilder("[");
    try (Connection conn = DBConnection.getConnection()) {
        ResultSet crs = conn.createStatement().executeQuery(
            "SELECT id, name, phone, credit FROM customers ORDER BY name ASC");
        boolean first = true;
        while (crs.next()) {
            if (!first) customersJson.append(",");
            first = false;
            customersJson.append("{")
                .append("\"id\":").append(crs.getInt("id")).append(",")
                .append("\"name\":\"").append(crs.getString("name").replace("\"","\\\"")).append("\",")
                .append("\"phone\":\"").append(crs.getString("phone")).append("\",")
                .append("\"credit\":").append(crs.getDouble("credit"))
                .append("}");
        }
    } catch (Exception e) { /* ignore */ }
    customersJson.append("]");
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>Request</title>
    <link rel="stylesheet" href="css/content.css">
    <style>
        /* ── Card Grid ── */
        .req-cards {
            display: grid;
            grid-template-columns: 1fr 1fr;
            gap: 20px;
            margin-bottom: 28px;
        }
        @media (max-width: 640px) { .req-cards { grid-template-columns: 1fr; } }

        .req-card {
            border-radius: 16px;
            padding: 28px 26px;
            cursor: pointer;
            display: flex;
            flex-direction: column;
            align-items: flex-start;
            gap: 12px;
            transition: transform 0.2s, box-shadow 0.2s;
            position: relative;
            overflow: hidden;
            border: 2px solid transparent;
        }
        .req-card::after {
            content: '';
            position: absolute;
            width: 160px; height: 160px;
            border-radius: 50%;
            background: rgba(255,255,255,0.07);
            bottom: -60px; right: -40px;
        }
        .req-card:hover { transform: translateY(-4px); box-shadow: 0 16px 40px rgba(0,0,0,0.22); }
        .req-card.active { border-color: rgba(255,255,255,0.35); }

        .req-card-product { background: linear-gradient(135deg, #2b0d73, #4a2fa0); color: #fff; }
        .req-card-cash    { background: linear-gradient(135deg, #7a3800, #d4681a); color: #fff; }

        .req-card .rc-icon { font-size: 36px; line-height: 1; }
        .req-card h3 { font-size: 18px; font-weight: 800; margin: 0; }
        .req-card p  { font-size: 12px; opacity: 0.75; margin: 0; }

        /* ── Section panels ── */
        .section-panel {
            display: none;
            animation: fadeSlideIn 0.3s ease;
        }
        .section-panel.visible { display: block; }

        @keyframes fadeSlideIn {
            from { opacity: 0; transform: translateY(10px); }
            to   { opacity: 1; transform: translateY(0); }
        }

        /* ── Panel header ── */
        .panel-header {
            display: flex;
            align-items: center;
            gap: 12px;
            margin-bottom: 20px;
            padding-bottom: 14px;
            border-bottom: 2px solid #e2e8f0;
        }
        .panel-header .ph-icon {
            width: 44px; height: 44px;
            border-radius: 12px;
            display: flex; align-items: center; justify-content: center;
            font-size: 22px;
            flex-shrink: 0;
        }
        .ph-product { background: linear-gradient(135deg, #2b0d73, #4a2fa0); }
        .ph-cash    { background: linear-gradient(135deg, #7a3800, #d4681a); }
        .panel-header h2 { font-size: 18px; font-weight: 800; color: #0d1b2a; margin: 0 0 2px; }
        .panel-header p  { font-size: 12px; color: #94a3b8; margin: 0; }

        /* ── Form layout ── */
        .req-layout {
            display: grid;
            grid-template-columns: 360px 1fr;
            gap: 20px;
            align-items: start;
        }
        @media (max-width: 860px) { .req-layout { grid-template-columns: 1fr; } }

        /* ── Input panel ── */
        .input-panel {
            background: #fff;
            border-radius: 14px;
            box-shadow: 0 4px 16px rgba(0,0,0,0.08);
            overflow: hidden;
            position: sticky;
            top: 10px;
        }
        .input-panel-header {
            padding: 13px 18px;
            color: #fff;
            font-size: 13px;
            font-weight: 700;
            letter-spacing: 0.5px;
        }
        .iph-product { background: linear-gradient(90deg, #2b0d73, #4a2fa0); }
        .iph-cash    { background: linear-gradient(90deg, #7a3800, #d4681a); }

        .input-panel-body {
            padding: 18px;
            display: flex;
            flex-direction: column;
            gap: 14px;
        }

        .ip-group { display: flex; flex-direction: column; gap: 5px; }
        .ip-group label { font-size: 12px; font-weight: 700; letter-spacing: 0.3px; }
        .label-product { color: #373279; }
        .label-cash    { color: #7a3800; }

        .ip-group select,
        .ip-group input {
            padding: 9px 11px;
            border-radius: 8px;
            font-size: 13px;
            color: #1a1a2a;
            background: #fff;
            outline: none;
            transition: border 0.2s;
            width: 100%;
            -moz-appearance: textfield;
            border: 2px solid #c8b7f6;
        }
        .ip-group.cash-group select,
        .ip-group.cash-group input { border-color: #f5c89a; }
        .ip-group select:focus,
        .ip-group input:focus { border-color: #7c73b8; box-shadow: 0 0 0 3px rgba(124,115,184,0.12); }
        .ip-group.cash-group select:focus,
        .ip-group.cash-group input:focus { border-color: #d4681a; box-shadow: 0 0 0 3px rgba(212,104,26,0.12); }
        .ip-group input::-webkit-inner-spin-button,
        .ip-group input::-webkit-outer-spin-button { -webkit-appearance: none; }

        .stock-info {
            display: none;
            font-size: 11px;
            color: #888;
            padding: 4px 8px;
            background: #f5f3ff;
            border-radius: 6px;
        }
        .stock-info.show { display: block; }

        .btn-add-row {
            width: 100%;
            padding: 11px;
            color: #fff;
            border: none;
            border-radius: 9px;
            font-size: 14px;
            font-weight: 700;
            cursor: pointer;
            transition: opacity 0.2s, transform 0.15s;
        }
        .btn-add-row:hover { opacity: 0.88; transform: scale(1.02); }
        .btn-add-product { background: linear-gradient(135deg, #2b0d73, #4a2fa0); }
        .btn-add-cash    { background: linear-gradient(135deg, #7a3800, #d4681a); }

        /* ── Table panel ── */
        .table-panel {
            background: #fff;
            border-radius: 14px;
            box-shadow: 0 4px 16px rgba(0,0,0,0.08);
            overflow: hidden;
        }
        .table-panel-header {
            padding: 13px 18px;
            color: #fff;
            font-size: 13px;
            font-weight: 700;
            display: flex;
            align-items: center;
            justify-content: space-between;
        }
        .tph-product { background: linear-gradient(90deg, #182542, #2a5a8f); }
        .tph-cash    { background: linear-gradient(90deg, #7a3800, #d4681a); }

        .req-table { width: 100%; border-collapse: collapse; font-size: 13px; }
        .req-table thead th {
            padding: 10px 12px;
            text-align: center;
            font-weight: 700;
            font-size: 12px;
            letter-spacing: 0.3px;
            border-bottom: 2px solid #e2e8f0;
        }
        .req-table thead.th-product th { background: #f5f3ff; color: #373279; border-bottom-color: #c8b7f6; }
        .req-table thead.th-cash    th { background: #fff8f0; color: #7a3800; border-bottom-color: #f5dab0; }

        .req-table tbody td {
            padding: 9px 12px;
            border-bottom: 1px solid #ede9ff;
            text-align: center;
            vertical-align: middle;
        }
        .req-table tbody tr:hover { background: #f9f7ff; }
        .req-table tbody tr:last-child td { border-bottom: none; }

        .empty-msg td { padding: 32px !important; color: #bbb; font-size: 13px; font-style: italic; text-align: center !important; }

        .btn-remove {
            width: 26px; height: 26px;
            background: #ffebee; color: #e53935;
            border: none; border-radius: 5px;
            font-size: 14px; font-weight: 700;
            cursor: pointer;
            display: inline-flex; align-items: center; justify-content: center;
            transition: background 0.2s;
        }
        .btn-remove:hover { background: #e53935; color: #fff; }

        .prod-tag {
            padding: 3px 10px; border-radius: 20px;
            font-size: 12px; font-weight: 600;
            background: #e8f0fe; color: #1a56db;
        }
        .qty-num { font-weight: 700; color: #2b0d73; }

        /* ── Generate bar ── */
        .generate-bar {
            display: flex;
            align-items: center;
            justify-content: space-between;
            border-radius: 10px;
            padding: 13px 20px;
            margin-top: 16px;
            color: #fff;
        }
        .gb-product { background: linear-gradient(90deg, #2b0d73, #4a2fa0); }
        .gb-cash    { background: linear-gradient(90deg, #7a3800, #d4681a); }

        .generate-bar .g-label { font-size: 12px; opacity: 0.75; }
        .generate-bar .g-count { font-size: 18px; font-weight: 800; }

        .btn-generate {
            padding: 10px 22px;
            background: rgba(255,255,255,0.15);
            border: 1px solid rgba(255,255,255,0.3);
            color: #fff;
            border-radius: 9px;
            font-size: 13px; font-weight: 700;
            cursor: pointer;
            transition: background 0.2s;
        }
        .btn-generate:hover { background: rgba(255,255,255,0.25); }

        /* ── Dealer selector strip ── */
        .dealer-strip {
            background: #fff;
            border: 1px solid #e2e8f0;
            border-radius: 12px;
            padding: 14px 18px;
            margin-bottom: 16px;
            display: flex;
            align-items: center;
            gap: 12px;
            flex-wrap: wrap;
            box-shadow: 0 1px 4px rgba(0,0,0,0.06);
        }
        .dealer-strip label { font-size: 13px; font-weight: 700; color: #2b0d73; white-space: nowrap; }
        .dealer-strip select {
            flex: 1; min-width: 200px;
            padding: 9px 12px;
            border: 2px solid #c8b7f6;
            border-radius: 8px;
            font-size: 13px; color: #1a1a2a; background: #fff; outline: none;
        }

        /* ── Message Modal ── */
        .msg-modal-backdrop {
            display: none;
            position: fixed; inset: 0;
            background: rgba(0,0,0,0.65);
            backdrop-filter: blur(4px);
            z-index: 999;
            align-items: center;
            justify-content: center;
        }
        .msg-modal-backdrop.show { display: flex; }

        .msg-modal {
            background: #fff;
            border-radius: 20px;
            width: 90%; max-width: 540px;
            box-shadow: 0 32px 80px rgba(0,0,0,0.35);
            overflow: hidden;
            animation: slideUp 0.25s cubic-bezier(0.22,1,0.36,1);
        }
        @keyframes slideUp {
            from { opacity: 0; transform: translateY(30px) scale(0.97); }
            to   { opacity: 1; transform: translateY(0) scale(1); }
        }

        .msg-modal-header {
            background: linear-gradient(135deg, #2b0d73, #4a2fa0);
            color: #fff; padding: 16px 22px;
            display: flex; align-items: center; justify-content: space-between;
        }
        .msg-modal-header h3 { font-size: 15px; font-weight: 700; margin: 0; }
        .btn-close-modal {
            width: 30px; height: 30px;
            background: rgba(255,255,255,0.15);
            border: none; border-radius: 8px;
            color: #fff; font-size: 16px; cursor: pointer;
            display: flex; align-items: center; justify-content: center;
        }
        .btn-close-modal:hover { background: rgba(255,255,255,0.28); }

        .msg-body { padding: 22px; }

        .msg-preview {
            background: #f8fafc;
            border: 1px solid #e2e8f0;
            border-radius: 12px;
            padding: 18px 20px;
            font-family: 'Segoe UI', Arial, sans-serif;
            font-size: 14px; line-height: 1.7;
            color: #0d1b2a;
            white-space: pre-wrap; word-break: break-word;
            min-height: 120px; max-height: 320px;
            overflow-y: auto; margin-bottom: 16px;
        }

        .msg-actions { display: flex; gap: 10px; }
        .btn-copy {
            flex: 1; padding: 11px;
            background: #f5f3ff; color: #2b0d73;
            border: 2px solid #c8b7f6; border-radius: 9px;
            font-size: 13px; font-weight: 700; cursor: pointer;
            display: flex; align-items: center; justify-content: center; gap: 7px;
            transition: all 0.2s;
        }
        .btn-copy:hover { background: #2b0d73; color: #fff; border-color: #2b0d73; }
        .btn-copy.copied { background: #e8f5e9; color: #1b5e20; border-color: #a5d6a7; }

        .btn-share {
            flex: 1; padding: 11px;
            background: #25D366; color: #fff; border: none;
            border-radius: 9px; font-size: 13px; font-weight: 700;
            cursor: pointer;
            display: flex; align-items: center; justify-content: center; gap: 7px;
            transition: opacity 0.2s;
        }
        .btn-share:hover { opacity: 0.88; }
    </style>
</head>
<body>
<div class="content-wrapper">

    <!-- ── Page Title ── -->
    <div style="margin-bottom: 22px;">
        <h2 style="font-size:20px; font-weight:800; color:#0d1b2a; margin:0 0 4px;">📋 Requests</h2>
        <p style="font-size:13px; color:#94a3b8; margin:0;">Generate and share product or cash requests with Dealers and Customers.</p>
    </div>

    <!-- ── Type Cards ── -->
    <div class="req-cards">
        <div class="req-card req-card-product" id="card-product" onclick="showSection('product')">
            <div class="rc-icon">📦</div>
            <h3>Product Request</h3>
            <p>Request specific products from a dealer</p>
        </div>
        <div class="req-card req-card-cash" id="card-cash" onclick="showSection('cash')">
            <div class="rc-icon">💵</div>
            <h3>Cash Request</h3>
            <p>Generate a payment reminder message</p>
        </div>
    </div>

    <!-- ════════════ PRODUCT REQUEST SECTION ════════════ -->
    <div class="section-panel" id="section-product">

        <div class="panel-header">
            <div class="ph-icon ph-product">📦</div>
            <div>
                <h2>Product Request</h2>
                <p>Select products and quantities, then generate a shareable message.</p>
            </div>
        </div>

        <!-- Dealer Selector -->
        <div class="dealer-strip">
            <label for="dealerSelect">🏬 Dealer:</label>
            <select id="dealerSelect">
                <option value="" disabled selected>— Select dealer —</option>
            </select>
        </div>

        <div class="req-layout">

            <!-- LEFT: Input -->
            <div class="input-panel">
                <div class="input-panel-header iph-product">➕ Add Product to Request</div>
                <div class="input-panel-body">

                    <div class="ip-group">
                        <label class="label-product" for="prdSelect">📦 Product</label>
                        <select id="prdSelect" onchange="onPrdChange()">
                            <option value="" disabled selected>— Select product —</option>
                        </select>
                        <div class="stock-info" id="prdStockInfo"></div>
                    </div>

                    <div class="ip-group">
                        <label class="label-product" for="prdQty">🔢 Quantity</label>
                        <input type="number" id="prdQty" placeholder="0" min="1">
                    </div>

                    <button class="btn-add-row btn-add-product" onclick="addProductRow()">
                        ➕ Add to Request
                    </button>

                </div>
            </div>

            <!-- RIGHT: Table -->
            <div>
                <div class="table-panel">
                    <div class="table-panel-header tph-product">
                        <span>🧾 Request Items</span>
                        <span id="prdCountBadge" style="background:rgba(255,255,255,0.15); border-radius:20px; padding:2px 12px; font-size:12px;">0 items</span>
                    </div>
                    <table class="req-table">
                        <thead class="th-product">
                            <tr>
                                <th>#</th>
                                <th>Product Name</th>
                                <th>Quantity</th>
                                <th></th>
                            </tr>
                        </thead>
                        <tbody id="prdBody">
                            <tr class="empty-msg">
                                <td colspan="4">← Add products using the form on the left</td>
                            </tr>
                        </tbody>
                    </table>
                </div>

                <div class="generate-bar gb-product" style="margin-top:16px;">
                    <div>
                        <div class="g-label">PRODUCTS IN REQUEST</div>
                        <div class="g-count" id="prdTotalCount">0 items</div>
                    </div>
                    <button class="btn-generate" onclick="generateProductMessage()">
                        📩 Generate Message
                    </button>
                </div>
            </div>

        </div>
    </div><!-- end section-product -->

    <!-- ════════════ CASH REQUEST SECTION ════════════ -->
    <div class="section-panel" id="section-cash">

        <div class="panel-header">
            <div class="ph-icon ph-cash">💵</div>
            <div>
                <h2>Cash Request</h2>
                <p>Select a customer and generate a payment reminder message in Marathi.</p>
            </div>
        </div>

        <!-- Single card layout for cash -->
        <div style="max-width: 500px;">
            <div class="input-panel">
                <div class="input-panel-header iph-cash">👤 Select Customer</div>
                <div class="input-panel-body">

                    <div class="ip-group cash-group">
                        <label class="label-cash" for="cashCustSelect">👤 Customer Name</label>
                        <select id="cashCustSelect" onchange="onCashCustChange()">
                            <option value="" disabled selected>— Select Customer —</option>
                        </select>
                    </div>

                    <!-- Credit display card -->
                    <div id="cashCreditCard" style="display:none;">
                        <div style="background: linear-gradient(135deg, #7a3800, #d4681a);
                                    border-radius: 12px; padding: 16px 18px; color: #fff;">
                            <div style="font-size: 11px; color: #ffd0a0; text-transform: uppercase;
                                        letter-spacing: 0.8px; margin-bottom: 4px;">थकबाकी रक्कम (Outstanding Credit)</div>
                            <div id="cashCreditDisplay" style="font-size: 26px; font-weight: 800;
                                 color: #ffe082; font-variant-numeric: tabular-nums;">₹ 0.00</div>
                            <div id="cashCustPhone" style="font-size: 12px; color: #ffd8b0; margin-top: 6px;"></div>
                        </div>
                    </div>

                    <!-- Zero credit warning -->
                    <div id="cashZeroWarn" style="display:none; background:#fff8e1; border-left:4px solid #f5a623;
                         border-radius:0 8px 8px 0; padding:10px 14px; font-size:13px; color:#7a5c00;">
                        ⚠️ या ग्राहकाची थकबाकी शून्य आहे.
                    </div>

                    <button class="btn-add-row btn-add-cash" onclick="generateCashMessage()"
                            id="btnGenCash" style="display:none;">
                        📩 Generate Message
                    </button>

                </div>
            </div>
        </div>

    </div><!-- end section-cash -->

</div><!-- end content-wrapper -->

<!-- ════════════ MESSAGE MODAL (Product) ════════════ -->
<div class="msg-modal-backdrop" id="msgModalBackdrop" onclick="closeModal(event)">
    <div class="msg-modal" onclick="event.stopPropagation()">
        <div class="msg-modal-header">
            <h3>📩 Request Message</h3>
            <button class="btn-close-modal" onclick="closeModalDirect()">✕</button>
        </div>
        <div class="msg-body">
            <div class="msg-preview" id="msgPreviewText"></div>
            <div class="msg-actions">
                <button class="btn-copy" id="btnCopy" onclick="copyMessage()">📋 Copy Message</button>
                <button class="btn-share" onclick="shareMessage()">
                    <svg width="16" height="16" viewBox="0 0 24 24" fill="currentColor">
                        <path d="M17.498 14.382c-.301-.01-.6.049-.876.17l-2.456-2.457c.182-.415.276-.863.276-1.312 0-.45-.094-.898-.276-1.313l2.456-2.456c.276.12.575.18.876.17.856.028 1.66-.322 2.28-.946a3.26 3.26 0 0 0 0-4.576c-.62-.624-1.424-.974-2.28-.946-.856-.028-1.66.322-2.28.946-.624.62-.974 1.424-.946 2.28.01.301.07.6.17.876l-2.456 2.456A3.26 3.26 0 0 0 12 7.46a3.26 3.26 0 0 0-1.312.276L8.232 5.28c.1-.276.16-.575.17-.876.028-.856-.322-1.66-.946-2.28a3.26 3.26 0 0 0-4.576 0c-.624.62-.974 1.424-.946 2.28-.028.856.322 1.66.946 2.28.62.624 1.424.974 2.28.946.301-.01.6-.07.876-.17l2.456 2.456a3.26 3.26 0 0 0 0 2.625l-2.456 2.456a3.104 3.104 0 0 0-.876-.17c-.856-.028-1.66.322-2.28.946a3.26 3.26 0 0 0 0 4.576c.62.624 1.424.974 2.28.946.856.028 1.66-.322 2.28-.946.624-.62.974-1.424.946-2.28a3.104 3.104 0 0 0-.17-.876l2.456-2.456A3.26 3.26 0 0 0 12 16.54c.45 0 .898-.094 1.312-.276l2.456 2.456a3.104 3.104 0 0 0-.17.876c-.028.856.322 1.66.946 2.28.62.624 1.424.974 2.28.946.856.028 1.66-.322 2.28-.946a3.26 3.26 0 0 0 0-4.576c-.62-.624-1.424-.974-2.28-.946z"/>
                    </svg>
                    Share via WhatsApp
                </button>
            </div>
        </div>
    </div>
</div>

<!-- ════════════ CASH MESSAGE MODAL ════════════ -->
<div class="msg-modal-backdrop" id="cashModalBackdrop" onclick="closeCashModal(event)">
    <div class="msg-modal" onclick="event.stopPropagation()">
        <div class="msg-modal-header" style="background: linear-gradient(135deg, #7a3800, #d4681a);">
            <h3>💵 Payment Reminder</h3>
            <button class="btn-close-modal" onclick="closeCashModalDirect()">✕</button>
        </div>
        <div class="msg-body">
            <div class="msg-preview" id="cashMsgPreviewText"
                 style="border-color: #f5dab0; background: #fff8f0;"></div>
            <div class="msg-actions">
                <button class="btn-copy" id="btnCashCopy"
                        style="border-color:#f5c89a; color:#7a3800; background:#fff8f0;"
                        onclick="copyCashMessage()">
                    📋 Copy Message
                </button>
                <button class="btn-share" style="background: #25D366;" onclick="shareCashMessage()">
                    <svg width="16" height="16" viewBox="0 0 24 24" fill="currentColor">
                        <path d="M17.498 14.382c-.301-.01-.6.049-.876.17l-2.456-2.457c.182-.415.276-.863.276-1.312 0-.45-.094-.898-.276-1.313l2.456-2.456c.276.12.575.18.876.17.856.028 1.66-.322 2.28-.946a3.26 3.26 0 0 0 0-4.576c-.62-.624-1.424-.974-2.28-.946-.856-.028-1.66.322-2.28.946-.624.62-.974 1.424-.946 2.28.01.301.07.6.17.876l-2.456 2.456A3.26 3.26 0 0 0 12 7.46a3.26 3.26 0 0 0-1.312.276L8.232 5.28c.1-.276.16-.575.17-.876.028-.856-.322-1.66-.946-2.28a3.26 3.26 0 0 0-4.576 0c-.624.62-.974 1.424-.946 2.28-.028.856.322 1.66.946 2.28.62.624 1.424.974 2.28.946.301-.01.6-.07.876-.17l2.456 2.456a3.26 3.26 0 0 0 0 2.625l-2.456 2.456a3.104 3.104 0 0 0-.876-.17c-.856-.028-1.66.322-2.28.946a3.26 3.26 0 0 0 0 4.576c.62.624 1.424.974 2.28.946.856.028 1.66-.322 2.28-.946.624-.62.974-1.424.946-2.28a3.104 3.104 0 0 0-.17-.876l2.456-2.456A3.26 3.26 0 0 0 12 16.54c.45 0 .898-.094 1.312-.276l2.456 2.456a3.104 3.104 0 0 0-.17.876c-.028.856.322 1.66.946 2.28.62.624 1.424.974 2.28.946.856.028 1.66-.322 2.28-.946a3.26 3.26 0 0 0 0-4.576c-.62-.624-1.424-.974-2.28-.946z"/>
                    </svg>
                    Share via WhatsApp
                </button>
            </div>
        </div>
    </div>
</div>

<script>
// ── Shop identity loaded from DB via ShopConfig ────────────────────────────
var SHOP_EN = "<%= shopEnNameJs %>";   // e.g. "Mauali Tredars"
var SHOP_MR = "<%= shopMrNameJs %>";   // e.g. "माऊली ट्रेडर्स"

var PRODUCTS  = <%= productsJson.toString() %>;
var DEALERS   = <%= dealersJson.toString() %>;
var CUSTOMERS = <%= customersJson.toString() %>;

var prdRows      = [];
var prdSeq       = 0;
var generatedMsg = '';
var cashMsg      = '';

// ── Populate dropdowns ──────────────────────────────────────────────────────
(function() {
    var prdSel = document.getElementById('prdSelect');
    PRODUCTS.forEach(function(p) {
        var opt = document.createElement('option');
        opt.value = p.id;
        opt.text  = p.name;
        opt.setAttribute('data-stock', p.stock);
        opt.setAttribute('data-name',  p.name);
        prdSel.appendChild(opt);
    });

    var dlrSel = document.getElementById('dealerSelect');
    DEALERS.forEach(function(d) {
        var opt = document.createElement('option');
        opt.value = d.id;
        opt.text  = d.name;
        opt.setAttribute('data-name', d.name);
        dlrSel.appendChild(opt);
    });

    var custSel = document.getElementById('cashCustSelect');
    CUSTOMERS.forEach(function(c) {
        var opt = document.createElement('option');
        opt.value = c.id;
        opt.text  = c.name + ' — ₹ ' + parseFloat(c.credit).toFixed(2);
        custSel.appendChild(opt);
    });
})();

function getProduct(id) {
    for (var i = 0; i < PRODUCTS.length; i++) {
        if (PRODUCTS[i].id == id) return PRODUCTS[i];
    }
    return null;
}
function getCustomer(id) {
    for (var i = 0; i < CUSTOMERS.length; i++) {
        if (CUSTOMERS[i].id == id) return CUSTOMERS[i];
    }
    return null;
}

// ── Show/hide sections ──────────────────────────────────────────────────────
function showSection(type) {
    document.getElementById('section-product').classList.remove('visible');
    document.getElementById('section-cash').classList.remove('visible');
    document.getElementById('card-product').classList.remove('active');
    document.getElementById('card-cash').classList.remove('active');
    document.getElementById('section-' + type).classList.add('visible');
    document.getElementById('card-' + type).classList.add('active');
}

// ── Product select change ───────────────────────────────────────────────────
function onPrdChange() {
    var sel  = document.getElementById('prdSelect');
    var pid  = sel.value;
    var info = document.getElementById('prdStockInfo');
    if (!pid) { info.classList.remove('show'); return; }
    var p = getProduct(pid);
    if (!p) return;
    info.textContent = '📦 Current stock: ' + p.stock + ' units';
    info.classList.add('show');
}

// ── Add product row ─────────────────────────────────────────────────────────
function addProductRow() {
    var sel = document.getElementById('prdSelect');
    var pid = parseInt(sel.value, 10);
    var qty = parseInt(document.getElementById('prdQty').value, 10);

    if (!pid)             { alert('⚠️ Please select a product.');         return; }
    if (!qty || qty <= 0) { alert('⚠️ Please enter a valid quantity.');   return; }

    var p = getProduct(pid);
    if (!p) { alert('⚠️ Product not found.'); return; }

    var existing = null;
    prdRows.forEach(function(r) { if (r.productId === pid) existing = r; });
    if (existing) {
        existing.qty += qty;
    } else {
        prdRows.push({ rid: ++prdSeq, productId: pid, productName: p.name, qty: qty });
    }

    renderPrdTable();
    document.getElementById('prdSelect').value = '';
    document.getElementById('prdQty').value    = '';
    document.getElementById('prdStockInfo').classList.remove('show');
}

// ── Render product table ────────────────────────────────────────────────────
function renderPrdTable() {
    var tbody = document.getElementById('prdBody');
    tbody.innerHTML = '';

    if (prdRows.length === 0) {
        tbody.innerHTML = '<tr class="empty-msg"><td colspan="4">← Add products using the form on the left</td></tr>';
        updatePrdCount();
        return;
    }

    prdRows.forEach(function(r, idx) {
        var tr = document.createElement('tr');
        tr.innerHTML =
            '<td style="color:#888; font-size:12px;">' + (idx + 1) + '</td>' +
            '<td><span class="prod-tag">📦 ' + r.productName + '</span></td>' +
            '<td class="qty-num">' + r.qty + '</td>' +
            '<td><button class="btn-remove" onclick="removePrdRow(' + r.rid + ')">✕</button></td>';
        tbody.appendChild(tr);
    });

    updatePrdCount();
}

function removePrdRow(rid) {
    prdRows = prdRows.filter(function(r) { return r.rid !== rid; });
    renderPrdTable();
}

function updatePrdCount() {
    var n = prdRows.length;
    document.getElementById('prdCountBadge').textContent = n + ' item' + (n !== 1 ? 's' : '');
    document.getElementById('prdTotalCount').textContent  = n + ' item' + (n !== 1 ? 's' : '');
}

// ── Generate product message ────────────────────────────────────────────────
function generateProductMessage() {
    if (prdRows.length === 0) {
        alert('⚠️ Please add at least one product to the request.');
        return;
    }

    var dlrSel  = document.getElementById('dealerSelect');
    var dlrName = dlrSel.options[dlrSel.selectedIndex] ?
                  dlrSel.options[dlrSel.selectedIndex].getAttribute('data-name') : '';
    if (!dlrName || dlrSel.value === '') {
        alert('⚠️ Please select a dealer first.');
        return;
    }

    var lines = [];
    lines.push('|| श्री ||');
    lines.push('');
    lines.push(SHOP_MR);                         // ← from DB
    lines.push('');
    lines.push('डीलर: ' + dlrName);
    lines.push('📦 प्रॉडक्ट रिक्वेस्ट:');
    lines.push('─────────────────────');

    prdRows.forEach(function(r, idx) {
        lines.push((idx + 1) + '. ' + r.productName + '  →  ' + r.qty + ' नग');
    });

    lines.push('─────────────────────');
    lines.push('एकूण आयटम: ' + prdRows.length);

    generatedMsg = lines.join('\n');

    document.getElementById('msgPreviewText').textContent = generatedMsg;
    document.getElementById('btnCopy').textContent = '📋 Copy Message';
    document.getElementById('btnCopy').classList.remove('copied');
    document.getElementById('msgModalBackdrop').classList.add('show');
}

// ── Cash: customer select change ────────────────────────────────────────────
function onCashCustChange() {
    var sel  = document.getElementById('cashCustSelect');
    var cid  = parseInt(sel.value, 10);
    var card = document.getElementById('cashCreditCard');
    var warn = document.getElementById('cashZeroWarn');
    var btn  = document.getElementById('btnGenCash');

    if (!cid) {
        card.style.display = 'none';
        warn.style.display = 'none';
        btn.style.display  = 'none';
        return;
    }

    var c = getCustomer(cid);
    if (!c) return;

    document.getElementById('cashCreditDisplay').textContent = '₹ ' + parseFloat(c.credit).toFixed(2);
    document.getElementById('cashCustPhone').textContent     = '📞 ' + c.phone;
    card.style.display = 'block';

    if (parseFloat(c.credit) <= 0) {
        warn.style.display = 'block';
        btn.style.display  = 'none';
    } else {
        warn.style.display = 'none';
        btn.style.display  = 'block';
    }
}

// ── Generate cash message ───────────────────────────────────────────────────
function generateCashMessage() {
    var sel = document.getElementById('cashCustSelect');
    var cid = parseInt(sel.value, 10);
    if (!cid) { alert('⚠️ कृपया ग्राहक निवडा.'); return; }

    var c = getCustomer(cid);
    if (!c) return;

    var credit = parseFloat(c.credit).toFixed(2);

    var lines = [];
    lines.push('|| श्री ||');
    lines.push('');
    lines.push('🙏 *' + SHOP_MR + '*');           // ← from DB
    lines.push('');
    lines.push('नमस्कार ' + c.name);
    lines.push('');
    lines.push('आपल्या खात्यावर सध्या खालील थकबाकी आहे:');
    lines.push('💰 *थकबाकी रक्कम: ₹ ' + credit + '*');
    lines.push('कृपया लवकरात लवकर संपर्क करून ही रक्कम जमा करावी.');
    lines.push('आपल्या सहकार्याबद्दल आभारी आहोत. 🙏');
    lines.push('');
    lines.push('— ' + SHOP_MR);                   // ← from DB

    cashMsg = lines.join('\n');

    document.getElementById('cashMsgPreviewText').textContent = cashMsg;
    document.getElementById('btnCashCopy').textContent = '📋 Copy Message';
    document.getElementById('btnCashCopy').classList.remove('copied');
    document.getElementById('cashModalBackdrop').classList.add('show');
}

// ── Modal open/close ────────────────────────────────────────────────────────
function closeModal(e)          { if (e.target === document.getElementById('msgModalBackdrop'))  document.getElementById('msgModalBackdrop').classList.remove('show'); }
function closeModalDirect()     { document.getElementById('msgModalBackdrop').classList.remove('show'); }
function closeCashModal(e)      { if (e.target === document.getElementById('cashModalBackdrop')) document.getElementById('cashModalBackdrop').classList.remove('show'); }
function closeCashModalDirect() { document.getElementById('cashModalBackdrop').classList.remove('show'); }

// ── Copy ────────────────────────────────────────────────────────────────────
function copyMessage()     { if (generatedMsg) doCopy(generatedMsg, 'btnCopy'); }
function copyCashMessage() { if (cashMsg)      doCopy(cashMsg,      'btnCashCopy'); }

function doCopy(text, btnId) {
    if (navigator.clipboard && navigator.clipboard.writeText) {
        navigator.clipboard.writeText(text).then(function() { markCopied(btnId); })
                           .catch(function() { fallbackCopy(text, btnId); });
    } else { fallbackCopy(text, btnId); }
}
function fallbackCopy(text, btnId) {
    var ta = document.createElement('textarea');
    ta.value = text; ta.style.position = 'fixed'; ta.style.opacity = '0';
    document.body.appendChild(ta); ta.select();
    try { document.execCommand('copy'); markCopied(btnId); } catch(e) {}
    document.body.removeChild(ta);
}
function markCopied(btnId) {
    var btn = document.getElementById(btnId);
    btn.textContent = '✅ Copied!';
    btn.classList.add('copied');
    setTimeout(function() {
        btn.textContent = '📋 Copy Message';
        btn.classList.remove('copied');
    }, 2500);
}

// ── Share ───────────────────────────────────────────────────────────────────
function shareMessage()     { if (generatedMsg) window.open('https://wa.me/?text=' + encodeURIComponent(generatedMsg), '_blank'); }
function shareCashMessage() { if (cashMsg)      window.open('https://wa.me/?text=' + encodeURIComponent(cashMsg),      '_blank'); }
</script>
</body>
</html>
