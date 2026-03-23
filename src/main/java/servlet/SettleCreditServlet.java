package servlet;

import java.io.IOException;
import java.sql.Connection;
import java.sql.PreparedStatement;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import doa.DBConnection;

@WebServlet("/SettleCreditServlet")
public class SettleCreditServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;

    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String idStr = request.getParameter("id");
        String settleAmountStr = request.getParameter("settleAmount");

        if(idStr == null || settleAmountStr == null) {
            response.sendRedirect("view_customers.jsp?error=Invalid input");
            return;
        }

        try (Connection conn = DBConnection.getConnection()) {
            int id = Integer.parseInt(idStr);
            double settleAmount = Double.parseDouble(settleAmountStr);

            // 1. Deduct credit (ensure credit does not go negative)
            String sql = "UPDATE customers SET credit = credit - ? WHERE id = ? AND credit >= ?";
            PreparedStatement ps = conn.prepareStatement(sql);
            ps.setDouble(1, settleAmount);
            ps.setInt(2, id);
            ps.setDouble(3, settleAmount);

            int updated = ps.executeUpdate();
            if (updated == 0) {
                response.sendRedirect("view_customers.jsp?error=Insufficient credit to settle");
                return;
            }

            // 2. Insert transaction record
            String txnSql = "INSERT INTO customer_transactions (id, customer_id, transaction_type, amount) VALUES (customer_txn_seq.NEXTVAL, ?, 'SETTLE', ?)";
            PreparedStatement psTxn = conn.prepareStatement(txnSql);
            psTxn.setInt(1, id);
            psTxn.setDouble(2, settleAmount);
            psTxn.executeUpdate();

            response.sendRedirect("view_customers.jsp?success=Credit settled successfully");
        } catch (Exception e) {
            e.printStackTrace();
            response.sendRedirect("view_customers.jsp?error=" + e.getMessage());
        }
    }
}
