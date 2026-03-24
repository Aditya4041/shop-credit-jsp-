package servlet;

import java.io.*;
import java.sql.*;
import javax.servlet.*;
import javax.servlet.annotation.*;
import javax.servlet.http.*;
import doa.DBConnection;

@WebServlet("/UpdateProductServlet")
public class UpdateProductServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;

    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String idStr       = request.getParameter("id");
        String quantityStr = request.getParameter("quantity");

        if (idStr == null || quantityStr == null) {
            response.sendRedirect("view_products.jsp?error=Invalid input");
            return;
        }

        try (Connection conn = DBConnection.getConnection()) {
            int id       = Integer.parseInt(idStr.trim());
            int quantity = Integer.parseInt(quantityStr.trim());

            if (quantity < 0) {
                response.sendRedirect("view_products.jsp?error=Quantity cannot be negative");
                return;
            }

            String sql = "UPDATE products SET quantity = ? WHERE id = ?";
            PreparedStatement ps = conn.prepareStatement(sql);
            ps.setInt(1, quantity);
            ps.setInt(2, id);
            int rows = ps.executeUpdate();

            if (rows > 0) {
                response.sendRedirect("view_products.jsp?success=Quantity updated successfully");
            } else {
                response.sendRedirect("view_products.jsp?error=Product not found");
            }
        } catch (Exception e) {
            e.printStackTrace();
            response.sendRedirect("view_products.jsp?error=" + e.getMessage());
        }
    }
}
