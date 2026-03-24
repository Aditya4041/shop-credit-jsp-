package servlet;

import java.io.*;
import java.sql.*;
import javax.servlet.*;
import javax.servlet.annotation.*;
import javax.servlet.http.*;
import doa.DBConnection;

@WebServlet("/AddProductServlet")
public class AddProductServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;

    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String productName = request.getParameter("productName");
        String quantityStr = request.getParameter("quantity");

        if (productName == null || productName.trim().isEmpty()
                || quantityStr == null || quantityStr.trim().isEmpty()) {
            response.sendRedirect("view_products.jsp?error=Please fill all fields");
            return;
        }

        try (Connection conn = DBConnection.getConnection()) {
            int quantity = Integer.parseInt(quantityStr.trim());

            String sql = "INSERT INTO products (id, product_name, quantity) "
                       + "VALUES (product_seq.NEXTVAL, ?, ?)";
            PreparedStatement ps = conn.prepareStatement(sql);
            ps.setString(1, productName.trim());
            ps.setInt(2, quantity);
            ps.executeUpdate();

            response.sendRedirect("view_products.jsp?success=Product added successfully");
        } catch (NumberFormatException e) {
            response.sendRedirect("view_products.jsp?error=Invalid quantity value");
        } catch (Exception e) {
            e.printStackTrace();
            response.sendRedirect("view_products.jsp?error=" + e.getMessage());
        }
    }
}
