package servlet;

import java.io.IOException;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

import doa.AESEncryption;
import doa.DBConnection;

@WebServlet("/LoginServlet")
public class LoginServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String username = request.getParameter("username");
        String password = request.getParameter("password");

        // ── Basic blank-field guard ──────────────────────────────────────────
        if (username == null || password == null
                || username.trim().isEmpty() || password.trim().isEmpty()) {
            response.sendRedirect("login.jsp?error=Please+enter+username+and+password");
            return;
        }

        username = username.trim();

        Connection conn = null;
        PreparedStatement ps = null;
        ResultSet rs = null;

        try {
            conn = DBConnection.getConnection();

            // ── Fetch encrypted password for the given username ──────────────
            String sql = "SELECT password, full_name, is_active "
                       + "FROM admin_users "
                       + "WHERE username = ?";

            ps = conn.prepareStatement(sql);
            ps.setString(1, username);
            rs = ps.executeQuery();

            if (rs.next()) {
                String encryptedPwd = rs.getString("password");
                String fullName     = rs.getString("full_name");
                String isActive     = rs.getString("is_active");

                // ── Account disabled check ───────────────────────────────────
                if (!"Y".equalsIgnoreCase(isActive)) {
                    response.sendRedirect("login.jsp?error=Account+is+disabled.+Contact+administrator.");
                    return;
                }

                // ── Decrypt and compare ──────────────────────────────────────
                String decryptedPwd = AESEncryption.decrypt(encryptedPwd);

                if (decryptedPwd.equals(password)) {
                    // ── Login success — create session ───────────────────────
                    HttpSession session = request.getSession(true);
                    session.setAttribute("admin",    username);
                    session.setAttribute("fullName", fullName != null ? fullName : username);
                    session.setMaxInactiveInterval(30 * 60); // 30 minutes
                    response.sendRedirect("main.jsp");
                } else {
                    response.sendRedirect("login.jsp?error=Invalid+username+or+password");
                }

            } else {
                // Username not found — same generic message (no user enumeration)
                response.sendRedirect("login.jsp?error=Invalid+username+or+password");
            }

        } catch (Exception e) {
            e.printStackTrace();
            response.sendRedirect("login.jsp?error=Server+error.+Please+try+again.");
        } finally {
            try { if (rs != null) rs.close();   } catch (Exception ignored) {}
            try { if (ps != null) ps.close();   } catch (Exception ignored) {}
            // DBConnection manages connection lifecycle — do not close conn here
        }
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        response.sendRedirect("login.jsp");
    }
}