<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.sql.*, doa.DBConnection, doa.AESEncryption" %>
<%
    String action   = request.getParameter("action");
    String uname    = request.getParameter("uname");
    String upass    = request.getParameter("upass");
    String fullName = request.getParameter("fullName");
    String encrypted = null;
    String message   = null;
    String msgType   = "info";

    if ("encrypt".equals(action) && uname != null && upass != null) {
        try {
            encrypted = AESEncryption.encrypt(upass.trim());
            message   = "Password encrypted. Click Save to Database.";
            msgType   = "success";
        } catch (Exception e) {
            message = "Encryption error: " + e.getMessage(); msgType = "error";
        }
    }

    if ("save".equals(action) && uname != null && request.getParameter("encrypted") != null) {
        encrypted = request.getParameter("encrypted");
        try (Connection conn = DBConnection.getConnection()) {
            PreparedStatement chk = conn.prepareStatement("SELECT COUNT(*) FROM admin_users WHERE username=?");
            chk.setString(1, uname.trim()); ResultSet chkRs = chk.executeQuery(); chkRs.next();
            boolean exists = chkRs.getInt(1) > 0; chkRs.close(); chk.close();
            if (exists) {
                PreparedStatement upd = conn.prepareStatement("UPDATE admin_users SET password=?, full_name=? WHERE username=?");
                upd.setString(1, encrypted); upd.setString(2, fullName != null ? fullName.trim() : uname.trim()); upd.setString(3, uname.trim());
                upd.executeUpdate(); upd.close();
                message = "Password updated for: " + uname.trim();
            } else {
                PreparedStatement ins = conn.prepareStatement("INSERT INTO admin_users (username, password, full_name, is_active) VALUES (?,?,?,'Y')");
                ins.setString(1, uname.trim()); ins.setString(2, encrypted); ins.setString(3, fullName != null ? fullName.trim() : uname.trim());
                ins.executeUpdate(); ins.close();
                message = "New admin created: " + uname.trim();
            }
            msgType = "success"; encrypted = null;
        } catch (Exception e) { message = "DB error: " + e.getMessage(); msgType = "error"; }
    }
%>
<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8"><title>Admin Setup</title>
<style>
*{box-sizing:border-box} body{font-family:'Segoe UI',Arial,sans-serif;background:linear-gradient(135deg,#182542,#2a5a8f);min-height:100vh;margin:0;display:flex;align-items:center;justify-content:center;padding:30px 16px}
.card{background:#fff;border-radius:16px;padding:36px 40px;max-width:500px;width:100%;box-shadow:0 20px 60px rgba(0,0,0,.3)}
h2{color:#182542;font-size:20px;margin:0 0 4px}.subtitle{font-size:13px;color:#888;margin-bottom:24px}
.warn{background:#fff8e1;border-left:4px solid #f5a623;padding:10px 14px;border-radius:6px;font-size:13px;color:#7a5c00;margin-bottom:20px}
label{display:block;font-size:13px;font-weight:700;color:#373279;margin-bottom:5px}
input[type=text],input[type=password]{width:100%;padding:10px 12px;border:2px solid #d4cef7;border-radius:8px;font-size:14px;outline:none;margin-bottom:14px;transition:border .2s}
input:focus{border-color:#7c73b8}
.btn{width:100%;padding:12px;border:none;border-radius:9px;font-size:15px;font-weight:700;cursor:pointer;transition:all .2s;margin-bottom:10px}
.bp{background:#373279;color:#fff}.bp:hover{background:#2b0d73}
.bs{background:#4caf50;color:#fff}.bs:hover{background:#388e3c}
.msg{padding:12px 14px;border-radius:8px;font-size:14px;margin-bottom:16px;font-weight:500}
.success{background:#e8f5e9;color:#1b5e20;border-left:4px solid #4caf50}
.error{background:#ffebee;color:#b71c1c;border-left:4px solid #e53935}
.enc{background:#f5f3ff;border:2px dashed #7c73b8;border-radius:8px;padding:12px 14px;font-family:monospace;font-size:13px;word-break:break-all;color:#2b0d73;margin-bottom:14px}
hr{border:none;border-top:1px dashed #c8b7f6;margin:18px 0}
</style>
</head>
<body>
<div class="card">
<h2>🔐 Admin Setup</h2>
<p class="subtitle">Create or update admin credentials with AES-256 encryption</p>
<div class="warn">⚠️ <strong>One-time use only.</strong> Delete <code>setup_admin.jsp</code> after setup.</div>
<% if(message!=null){%><div class="msg <%= msgType %>"><%= message %></div><%}%>

<form action="setup_admin.jsp" method="post">
<input type="hidden" name="action" value="encrypt">
<label>Username</label>
<input type="text" name="uname" placeholder="e.g. admin" value="<%= uname!=null?uname:"" %>" required>
<label>Full Name</label>
<input type="text" name="fullName" placeholder="e.g. Administrator" value="<%= fullName!=null?fullName:"" %>">
<label>Password (plain text)</label>
<input type="password" name="upass" placeholder="Enter password" required>
<button type="submit" class="btn bp">🔒 Encrypt Password</button>
</form>

<% if(encrypted!=null){ %>
<hr>
<p style="font-size:13px;font-weight:700;color:#373279;margin-bottom:8px;">Encrypted Password:</p>
<div class="enc"><%= encrypted %></div>
<form action="setup_admin.jsp" method="post">
<input type="hidden" name="action" value="save">
<input type="hidden" name="uname" value="<%= uname %>">
<input type="hidden" name="fullName" value="<%= fullName %>">
<input type="hidden" name="encrypted" value="<%= encrypted %>">
<button type="submit" class="btn bs">💾 Save to Database</button>
</form>
<% } %>
</div>
</body>
</html>
