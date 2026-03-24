<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%
    if (session.getAttribute("admin") == null) {
        response.sendRedirect("login.jsp?error=Please login first");
        return;
    }
    String adminUser = (String) session.getAttribute("admin");
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Mauali Tredars — Credit Manager</title>
    <link rel="stylesheet" href="css/main.css">
</head>
<body>

<!-- ═══════ SIDEBAR ═══════ -->
<div class="sidebar" id="sidebar">

    <div class="profile-section">
        <div class="profile-avatar" id="avatarEl">👤</div>
        <div class="user-name"><%= adminUser.toUpperCase() %></div>
    </div>

    <ul class="menu" id="mainMenu">

        <li class="active" data-page="index.jsp">
            <a href="#" onclick="loadPage('index.jsp','Dashboard',this);return false;">
                <span class="menu-icon">🏠</span>
                <span class="menu-label">Dashboard</span>
            </a>
            <span class="tooltip-label">Dashboard</span>
        </li>

        <li data-page="add_customer.jsp">
            <a href="#" onclick="loadPage('add_customer.jsp','Add Customer',this);return false;">
                <span class="menu-icon">➕</span>
                <span class="menu-label">Add Customer</span>
            </a>
            <span class="tooltip-label">Add Customer</span>
        </li>

        <li data-page="view_customers.jsp">
            <a href="#" onclick="loadPage('view_customers.jsp','View Customers',this);return false;">
                <span class="menu-icon">👥</span>
                <span class="menu-label">View Customers</span>
            </a>
            <span class="tooltip-label">View Customers</span>
        </li>

        <li data-page="add_dealer.jsp">
            <a href="#" onclick="loadPage('add_dealer.jsp','Add Dealer',this);return false;">
                <span class="menu-icon">🏬</span>
                <span class="menu-label">Add Dealer</span>
            </a>
            <span class="tooltip-label">Add Dealer</span>
        </li>

        <li data-page="view_dealers.jsp">
            <a href="#" onclick="loadPage('view_dealers.jsp','View Dealers',this);return false;">
                <span class="menu-icon">📋</span>
                <span class="menu-label">View Dealers</span>
            </a>
            <span class="tooltip-label">View Dealers</span>
        </li>

    </ul>

    <div class="logout">
        <a href="#" onclick="showLogoutModal(event)">
            <span class="menu-icon" style="font-size:16px;">🚪</span>
            <span class="logout-text">Logout</span>
        </a>
        <span class="tooltip-label">Logout</span>
    </div>
</div>

<!-- ═══════ MAIN CONTENT ═══════ -->
<div class="main-content" id="mainContent">
    <header>
        <div class="title-row">
            <div class="bank-section">
                <button class="sidebar-toggle" id="sidebarToggle" onclick="toggleSidebar()" title="Toggle menu">
                    <span></span><span></span><span></span>
                </button>
                <span class="bank-icon">🏪</span>
                <h1 class="bank-title">Mauali Tredars</h1>
            </div>
            <div class="shop-badge" id="pageTitle">Dashboard</div>
        </div>
        <div class="nav-row">
            <div class="current-date" id="currentDate">Loading...</div>
        </div>
    </header>

    <iframe id="contentFrame" frameborder="0" src="index.jsp"></iframe>
</div>

<!-- Logout Confirm Modal -->
<div id="logoutModal" class="logout-modal">
    <div class="logout-modal-content">
        <h2>⚠️ Confirm Logout</h2>
        <p>Are you sure you want to log out?</p>
        <div class="modal-btns">
            <button class="btn-cancel" onclick="closeLogoutModal()">Cancel</button>
            <button class="btn-confirm" onclick="confirmLogout()">Yes, Logout</button>
        </div>
    </div>
</div>

<script>
// ── Sidebar collapse ──────────────────────────────────────────────────────
var isCollapsed = sessionStorage.getItem('sidebarCollapsed') === 'true';

function applyState() {
    var sidebar = document.getElementById('sidebar');
    var mc      = document.getElementById('mainContent');
    if (isCollapsed) {
        sidebar.classList.add('collapsed');
        document.body.classList.add('sidebar-collapsed');
    } else {
        sidebar.classList.remove('collapsed');
        document.body.classList.remove('sidebar-collapsed');
    }
    sessionStorage.setItem('sidebarCollapsed', isCollapsed);
}

function toggleSidebar() {
    isCollapsed = !isCollapsed;
    applyState();
}

applyState();

// ── Tooltip vertical positioning ──────────────────────────────────────────
document.addEventListener('DOMContentLoaded', function () {
    document.querySelectorAll('.menu li, .logout').forEach(function (item) {
        var tip = item.querySelector('.tooltip-label');
        if (!tip) return;
        item.addEventListener('mouseenter', function () {
            if (!isCollapsed) return;
            var r = item.getBoundingClientRect();
            tip.style.top = (r.top + r.height / 2) + 'px';
            tip.style.transform = 'translateY(-50%) translateX(0)';
        });
    });
});

// ── Page loading ──────────────────────────────────────────────────────────
function loadPage(page, title, el) {
    document.getElementById('contentFrame').src = page;
    document.getElementById('pageTitle').textContent = title;
    sessionStorage.setItem('currentPage',  page);
    sessionStorage.setItem('currentTitle', title);
    document.querySelectorAll('.menu li').forEach(function(li){ li.classList.remove('active'); });
    if (el && el.closest) el.closest('li').classList.add('active');
}

// Allow iframed pages to load detail pages
function loadDetailPage(page, title) {
    document.getElementById('contentFrame').src = page;
    document.getElementById('pageTitle').textContent = title;
}
window.updateParentBreadcrumb = function(path, page) {
    document.getElementById('pageTitle').textContent = path;
    sessionStorage.setItem('currentPage',  page);
    sessionStorage.setItem('currentTitle', path);
};

// Restore last page
window.onload = function() {
    var savedPage  = sessionStorage.getItem('currentPage');
    var savedTitle = sessionStorage.getItem('currentTitle');
    if (savedPage) {
        document.getElementById('contentFrame').src = savedPage;
        document.getElementById('pageTitle').textContent = savedTitle || '';
        document.querySelectorAll('.menu li').forEach(function(li){
            if (li.dataset.page === savedPage) li.classList.add('active');
            else li.classList.remove('active');
        });
    }
    // Date
    var d = new Date();
    var opts = { weekday:'long', year:'numeric', month:'long', day:'numeric' };
    document.getElementById('currentDate').textContent = 'Today: ' + d.toLocaleDateString('en-IN', opts);
};

// ── Logout ────────────────────────────────────────────────────────────────
function showLogoutModal(e) { e.preventDefault(); document.getElementById('logoutModal').classList.add('show'); }
function closeLogoutModal() { document.getElementById('logoutModal').classList.remove('show'); }
function confirmLogout()    { sessionStorage.clear(); window.location.href = 'LogoutServlet'; }

window.onclick = function(e) { if (e.target === document.getElementById('logoutModal')) closeLogoutModal(); };
document.addEventListener('keydown', function(e) { if (e.key === 'Escape') closeLogoutModal(); });
</script>

</body>
</html>
