import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import java.io.*;
import java.sql.*;

@WebServlet("/admin/UpdateProductServlet")
public class UpdateProductServlet extends HttpServlet {
    
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        // Check admin
        HttpSession session = request.getSession(false);
        Boolean isAdmin = (session != null) ? (Boolean) session.getAttribute("is_admin") : false;
        if(!Boolean.TRUE.equals(isAdmin)) {
            response.sendRedirect("../login.jsp");
            return;
        }
        
        // Get form data
        String id = request.getParameter("id");
        String name = request.getParameter("name");
        String description = request.getParameter("description");
        String priceStr = request.getParameter("price");
        String category = request.getParameter("category");
        String stockStr = request.getParameter("stock");
        String newImage = request.getParameter("image");
        String currentImage = request.getParameter("current_image");
        
        response.setContentType("text/html");
        PrintWriter out = response.getWriter();
        
        try {
            // Validate required fields
            if(name == null || name.trim().isEmpty() || priceStr == null || priceStr.trim().isEmpty()) {
                out.println("<script>alert('Name and Price are required!'); window.history.back();</script>");
                return;
            }
            
            Class.forName("com.mysql.cj.jdbc.Driver");
            Connection conn = DriverManager.getConnection("jdbc:mysql://localhost:3306/ecom", "root", "Agr@hari567#");
            
            // Determine which image to use
            String imageToUse = currentImage;
            if(newImage != null && !newImage.trim().isEmpty()) {
                imageToUse = newImage;
            }
            if(imageToUse == null || imageToUse.trim().isEmpty()) {
                imageToUse = "default.jpg";
            }
            
            // Set defaults
            if(stockStr == null || stockStr.trim().isEmpty()) stockStr = "0";
            if(category == null) category = "";
            if(description == null) description = "";
            
            // Update product
            String sql = "UPDATE products SET name=?, description=?, price=?, category=?, stock_quantity=?, image=? WHERE id=?";
            PreparedStatement ps = conn.prepareStatement(sql);
            ps.setString(1, name);
            ps.setString(2, description);
            ps.setDouble(3, Double.parseDouble(priceStr));
            ps.setString(4, category);
            ps.setInt(5, Integer.parseInt(stockStr));
            ps.setString(6, imageToUse);
            ps.setInt(7, Integer.parseInt(id));
            
            int result = ps.executeUpdate();
            
            if(result > 0) {
                out.println("<script>alert('Product updated successfully!'); window.location.href='view-products.jsp';</script>");
            } else {
                out.println("<script>alert('Failed to update product!'); window.history.back();</script>");
            }
            
            conn.close();
        } catch(NumberFormatException e) {
            out.println("<script>alert('Invalid price or stock value!'); window.history.back();</script>");
        } catch(Exception e) {
            e.printStackTrace();
            out.println("<script>alert('Error: " + e.getMessage() + "'); window.history.back();</script>");
        }
    }
}