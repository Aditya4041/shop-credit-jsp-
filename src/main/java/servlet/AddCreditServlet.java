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

        String idStr               = request.getParameter("id");
        String additionalCreditStr = request.getParameter("additionalCredit");
        String productName         = request.getParameter("productName");
        String productIdStr        = request.getParameter("productId");
        String quantityStr         = request.getParameter("quantity");

        // ── Basic validation ────────────────────────────────────────────────
        if (idStr == null || additionalCreditStr == null
                || productName == null || productName.trim().isEmpty()
                || productIdStr == null || quantityStr == null) {
            response.sendRedirect("view_customers.jsp?error=Invalid input");
            return;
        }

        try (Connection conn = DBConnection.getConnection()) {
            int    id              = Integer.parseInt(idStr.trim());
            double additionalCredit = Double.parseDouble(additionalCreditStr.trim());
            int    productId       = Integer.parseInt(productIdStr.trim());
            int    quantity        = Integer.parseInt(quantityStr.trim());

            if (quantity <= 0) {
                response.sendRedirect("view_customers.jsp?error=Quantity must be greater than zero");
                return;
            }

            // ── 1. Check available stock ─────────────────────────────────────
            PreparedStatement psStock = conn.prepareStatement(
                "SELECT quantity FROM products WHERE id = ?");
            psStock.setInt(1, productId);
            java.sql.ResultSet rsStock = psStock.executeQuery();

            if (!rsStock.next()) {
                response.sendRedirect("view_customers.jsp?error=Product not found");
                psStock.close();
                return;
            }
            int availableStock = rsStock.getInt("quantity");
            psStock.close();

            if (availableStock < quantity) {
                response.sendRedirect("view_customers.jsp?error=Insufficient stock. Available: "
                        + availableStock);
                return;
            }

            // ── 2. Update customer credit ────────────────────────────────────
            PreparedStatement psCredit = conn.prepareStatement(
                "UPDATE customers SET credit = credit + ? WHERE id = ?");
            psCredit.setDouble(1, additionalCredit);
            psCredit.setInt(2, id);
            psCredit.executeUpdate();
            psCredit.close();

            // ── 3. Deduct quantity from product stock ────────────────────────
            PreparedStatement psDeduct = conn.prepareStatement(
                "UPDATE products SET quantity = quantity - ? WHERE id = ?");
            psDeduct.setInt(1, quantity);
            psDeduct.setInt(2, productId);
            psDeduct.executeUpdate();
            psDeduct.close();

            // ── 4. Insert transaction (with quantity) ────────────────────────
            PreparedStatement psTxn = conn.prepareStatement(
                "INSERT INTO customer_transactions "
              + "  (id, customer_id, transaction_type, amount, product_name, quantity) "
              + "VALUES (customer_txn_seq.NEXTVAL, ?, 'ADD', ?, ?, ?)");
            psTxn.setInt(1, id);
            psTxn.setDouble(2, additionalCredit);
            psTxn.setString(3, productName.trim());
            psTxn.setInt(4, quantity);
            psTxn.executeUpdate();
            psTxn.close();

            response.sendRedirect("view_customers.jsp?success=Credit added successfully");

        } catch (NumberFormatException e) {
            response.sendRedirect("view_customers.jsp?error=Invalid number format: " + e.getMessage());
        } catch (Exception e) {
            e.printStackTrace();
            response.sendRedirect("view_customers.jsp?error=" + e.getMessage());
        }
    }
}