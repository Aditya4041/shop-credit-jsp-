package servlet;

import java.io.*;
import java.sql.*;
import javax.servlet.*;
import javax.servlet.annotation.*;
import javax.servlet.http.*;
import doa.DBConnection;

@WebServlet("/AddDealerCreditServlet")
public class AddDealerCreditServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;

    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String idStr = request.getParameter("id");
        String additionalCreditStr = request.getParameter("additionalCredit");

        try (Connection conn = DBConnection.getConnection()) {
            int id = Integer.parseInt(idStr);
            double additionalCredit = Double.parseDouble(additionalCreditStr);

            String sql = "UPDATE dealers SET credit = credit + ? WHERE id = ?";
            PreparedStatement ps = conn.prepareStatement(sql);
            ps.setDouble(1, additionalCredit);
            ps.setInt(2, id);
            ps.executeUpdate();

            // Insert transaction
            String txnSql = "INSERT INTO dealer_transactions (id, dealer_id, transaction_type, amount) VALUES (dealer_txn_seq.NEXTVAL, ?, 'ADD', ?)";
            PreparedStatement psTxn = conn.prepareStatement(txnSql);
            psTxn.setInt(1, id);
            psTxn.setDouble(2, additionalCredit);
            psTxn.executeUpdate();

            response.sendRedirect("view_dealers.jsp?success=Credit added successfully");
        } catch (Exception e) {
            e.printStackTrace();
            response.sendRedirect("view_dealers.jsp?error=" + e.getMessage());
        }
    }
}
