import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import java.io.*;
import java.sql.*;

@WebServlet("/admin/AddProductServlet")
public class AddProductServlet extends HttpServlet {
    
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        // Check admin
        HttpSession session = request.getSession(false);
        Boolean isAdmin = (session != null) ? (Boolean) session.getAttribute("is_admin") : false;
        if(!Boolean.TRUE.equals(isAdmin)) {
            response.sendRedirect("../login.jsp");
            return;
        }
        
        // Get parameters
        String name = request.getParameter("name");
        String description = request.getParameter("description");
        String priceStr = request.getParameter("price");
        String category = request.getParameter("category");
        String stockStr = request.getParameter("stock");
        String image = request.getParameter("image");
        
        PrintWriter out = response.getWriter();
        
        try {
            Class.forName("com.mysql.cj.jdbc.Driver");
            Connection conn = DriverManager.getConnection("jdbc:mysql://localhost:3306/ecom", "root", "Agr@hari567#");
            
            // Set default image if empty
            if(image == null || image.trim().isEmpty()) {
                image = "default.jpg";
            }
            
            String sql = "INSERT INTO products (name, description, price, category, stock_quantity, image) VALUES (?, ?, ?, ?, ?, ?)";
            PreparedStatement ps = conn.prepareStatement(sql);
            ps.setString(1, name);
            ps.setString(2, description);
            ps.setDouble(3, Double.parseDouble(priceStr));
            ps.setString(4, category);
            ps.setInt(5, Integer.parseInt(stockStr));
            ps.setString(6, image);
            
            int result = ps.executeUpdate();
            
            if(result > 0) {
                out.println("<script>alert('Product added successfully!'); window.location.href='view-products.jsp';</script>");
            } else {
                out.println("<script>alert('Failed to add product!'); window.history.back();</script>");
            }
            
            conn.close();
        } catch(Exception e) {
            e.printStackTrace();
            out.println("<script>alert('Error: " + e.getMessage() + "'); window.history.back();</script>");
        }
    }
}