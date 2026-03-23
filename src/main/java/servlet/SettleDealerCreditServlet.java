package servlet;

import java.io.*;
import java.sql.*;
import javax.servlet.*;
import javax.servlet.annotation.*;
import javax.servlet.http.*;
import doa.DBConnection;

@WebServlet("/SettleDealerCreditServlet")
public class SettleDealerCreditServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;

    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String idStr = request.getParameter("id");
        String settleAmountStr = request.getParameter("settleAmount");

        try (Connection conn = DBConnection.getConnection()) {
            int id = Integer.parseInt(idStr);
            double amount = Double.parseDouble(settleAmountStr);

            String sql = "UPDATE dealers SET credit = credit - ? WHERE id = ?";
            PreparedStatement ps = conn.prepareStatement(sql);
            ps.setDouble(1, amount);
            ps.setInt(2, id);
            ps.executeUpdate();

            String txnSql = "INSERT INTO dealer_transactions (id, dealer_id, transaction_type, amount) VALUES (dealer_txn_seq.NEXTVAL, ?, 'SETTLE', ?)";
            PreparedStatement psTxn = conn.prepareStatement(txnSql);
            psTxn.setInt(1, id);
            psTxn.setDouble(2, amount);
            psTxn.executeUpdate();

            response.sendRedirect("view_dealers.jsp?success=Credit settled successfully");
        } catch (Exception e) {
            e.printStackTrace();
            response.sendRedirect("view_dealers.jsp?error=" + e.getMessage());
        }
    }
}
