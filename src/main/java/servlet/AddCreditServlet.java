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

@WebServlet("/AddCreditServlet")
public class AddCreditServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;

    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String idStr              = request.getParameter("id");
        String additionalCreditStr = request.getParameter("additionalCredit");
        String productName        = request.getParameter("productName");

        if (idStr == null || additionalCreditStr == null
                || productName == null || productName.trim().isEmpty()) {
            response.sendRedirect("view_customers.jsp?error=Invalid input");
            return;
        }

        try (Connection conn = DBConnection.getConnection()) {
            int    id              = Integer.parseInt(idStr.trim());
            double additionalCredit = Double.parseDouble(additionalCreditStr.trim());

            // 1. Update customer credit
            String sql = "UPDATE customers SET credit = credit + ? WHERE id = ?";
            PreparedStatement ps = conn.prepareStatement(sql);
            ps.setDouble(1, additionalCredit);
            ps.setInt(2, id);
            ps.executeUpdate();
            ps.close();

            // 2. Insert transaction with product name
            String txnSql =
                "INSERT INTO customer_transactions "
              + "  (id, customer_id, transaction_type, amount, product_name) "
              + "VALUES (customer_txn_seq.NEXTVAL, ?, 'ADD', ?, ?)";
            PreparedStatement psTxn = conn.prepareStatement(txnSql);
            psTxn.setInt(1, id);
            psTxn.setDouble(2, additionalCredit);
            psTxn.setString(3, productName.trim());
            psTxn.executeUpdate();
            psTxn.close();

            response.sendRedirect("view_customers.jsp?success=Credit added successfully");

        } catch (Exception e) {
            e.printStackTrace();
            response.sendRedirect("view_customers.jsp?error=" + e.getMessage());
        }
    }
}