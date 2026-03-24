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

        String idStr               = request.getParameter("id");
        String additionalCreditStr = request.getParameter("additionalCredit");
        String productName         = request.getParameter("productName");
        String productIdStr        = request.getParameter("productId");
        String quantityStr         = request.getParameter("quantity");

        // ── Basic validation ────────────────────────────────────────────────
        if (idStr == null || additionalCreditStr == null
                || productName == null || productName.trim().isEmpty()
                || productIdStr == null || quantityStr == null) {
            response.sendRedirect("view_dealers.jsp?error=Invalid input");
            return;
        }

        try (Connection conn = DBConnection.getConnection()) {
            int    id              = Integer.parseInt(idStr.trim());
            double additionalCredit = Double.parseDouble(additionalCreditStr.trim());
            int    productId       = Integer.parseInt(productIdStr.trim());
            int    quantity        = Integer.parseInt(quantityStr.trim());

            if (quantity <= 0) {
                response.sendRedirect("view_dealers.jsp?error=Quantity must be greater than zero");
                return;
            }

            // ── 1. Verify product exists ─────────────────────────────────────
            PreparedStatement psCheck = conn.prepareStatement(
                "SELECT id FROM products WHERE id = ?");
            psCheck.setInt(1, productId);
            ResultSet rsCheck = psCheck.executeQuery();
            if (!rsCheck.next()) {
                response.sendRedirect("view_dealers.jsp?error=Product not found");
                psCheck.close();
                return;
            }
            psCheck.close();

            // ── 2. Update dealer credit ──────────────────────────────────────
            PreparedStatement psCredit = conn.prepareStatement(
                "UPDATE dealers SET credit = credit + ? WHERE id = ?");
            psCredit.setDouble(1, additionalCredit);
            psCredit.setInt(2, id);
            psCredit.executeUpdate();
            psCredit.close();

            // ── 3. ADD quantity to product stock (dealer supplies stock) ─────
            PreparedStatement psAdd = conn.prepareStatement(
                "UPDATE products SET quantity = quantity + ? WHERE id = ?");
            psAdd.setInt(1, quantity);
            psAdd.setInt(2, productId);
            psAdd.executeUpdate();
            psAdd.close();

            // ── 4. Insert transaction (with quantity) ────────────────────────
            PreparedStatement psTxn = conn.prepareStatement(
                "INSERT INTO dealer_transactions "
              + "  (id, dealer_id, transaction_type, amount, product_name, quantity) "
              + "VALUES (dealer_txn_seq.NEXTVAL, ?, 'ADD', ?, ?, ?)");
            psTxn.setInt(1, id);
            psTxn.setDouble(2, additionalCredit);
            psTxn.setString(3, productName.trim());
            psTxn.setInt(4, quantity);
            psTxn.executeUpdate();
            psTxn.close();

            response.sendRedirect("view_dealers.jsp?success=Credit added and stock updated successfully");

        } catch (NumberFormatException e) {
            response.sendRedirect("view_dealers.jsp?error=Invalid number format: " + e.getMessage());
        } catch (Exception e) {
            e.printStackTrace();
            response.sendRedirect("view_dealers.jsp?error=" + e.getMessage());
        }
    }
}