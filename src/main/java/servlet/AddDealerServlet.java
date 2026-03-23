package servlet;

import java.io.*;
import java.sql.*;
import javax.servlet.*;
import javax.servlet.annotation.*;
import javax.servlet.http.*;
import doa.DBConnection;

@WebServlet("/AddDealerServlet")
public class AddDealerServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;

    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String name = request.getParameter("name");
        String phone = request.getParameter("phone");
        String creditStr = request.getParameter("credit");

        try (Connection conn = DBConnection.getConnection()) {
            String sql = "INSERT INTO dealers (id, name, phone, credit) VALUES (dealer_seq.NEXTVAL, ?, ?, ?)";
            PreparedStatement ps = conn.prepareStatement(sql);
            ps.setString(1, name);
            ps.setString(2, phone);
            ps.setDouble(3, Double.parseDouble(creditStr));
            ps.executeUpdate();

            response.sendRedirect("view_dealers.jsp?success=Dealer added successfully");
        } catch (Exception e) {
            e.printStackTrace();
            response.sendRedirect("view_dealers.jsp?error=" + e.getMessage());
        }
    }
}
