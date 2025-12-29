import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import java.io.*;
import java.sql.*;

@WebServlet("/admin/DeleteProductServlet")
public class DeleteProductServlet extends HttpServlet {
    
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws IOException {
        // Check admin
        HttpSession session = request.getSession(false);
        Boolean isAdmin = (session != null) ? (Boolean) session.getAttribute("is_admin") : false;
        if(!Boolean.TRUE.equals(isAdmin)) {
            response.sendRedirect("../login.jsp");
            return;
        }
        
        String id = request.getParameter("id");
        PrintWriter out = response.getWriter();
        
        try {
            Class.forName("com.mysql.cj.jdbc.Driver");
            Connection conn = DriverManager.getConnection("jdbc:mysql://localhost:3306/ecom", "root", "Agr@hari567#");
            
            // Optional: Get product name for confirmation message
            String productName = "";
            PreparedStatement psName = conn.prepareStatement("SELECT name FROM products WHERE id = ?");
            psName.setInt(1, Integer.parseInt(id));
            var rs = psName.executeQuery();
            if(rs.next()) {
                productName = rs.getString("name");
            }
            
            // Delete product
            String sql = "DELETE FROM products WHERE id = ?";
            PreparedStatement ps = conn.prepareStatement(sql);
            ps.setInt(1, Integer.parseInt(id));
            
            int result = ps.executeUpdate();
            
            if(result > 0) {
                out.println("<script>alert('Product \\\"" + productName + "\\\" deleted successfully!'); window.location.href='view-products.jsp';</script>");
            } else {
                out.println("<script>alert('Failed to delete product!'); window.history.back();</script>");
            }
            
            conn.close();
        } catch(Exception e) {
            e.printStackTrace();
            out.println("<script>alert('Error: " + e.getMessage() + "'); window.history.back();</script>");
        }
    }
}