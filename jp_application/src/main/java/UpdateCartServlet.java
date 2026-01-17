import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import java.io.*;
import java.sql.*;

@WebServlet("/UpdateCartServlet")
public class UpdateCartServlet extends HttpServlet {
    
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws IOException {
        HttpSession session = request.getSession(false);
        
        // Check if user is logged in
        if(session == null || session.getAttribute("loggedin") == null) {
            response.sendRedirect("login.jsp");
            return;
        }
        
        String cartId = request.getParameter("cart_id");
        String quantityStr = request.getParameter("quantity");
        int userId = (Integer) session.getAttribute("user_id");
        
        PrintWriter out = response.getWriter();
        
        try {
            Class.forName("com.mysql.cj.jdbc.Driver");
            Connection conn = DriverManager.getConnection("jdbc:mysql://localhost:3306/ecom", "root", "Agr@hari567#");
            
            // Check if cart item belongs to user
            PreparedStatement checkStmt = conn.prepareStatement(
                "SELECT c.*, p.stock_quantity FROM cart c " +
                "JOIN products p ON c.product_id = p.id " +
                "WHERE c.id = ? AND c.user_id = ?"
            );
            checkStmt.setInt(1, Integer.parseInt(cartId));
            checkStmt.setInt(2, userId);
            ResultSet rs = checkStmt.executeQuery();
            
            if(rs.next()) {
                int stock = rs.getInt("stock_quantity");
                int quantity = Integer.parseInt(quantityStr);
                
                if(quantity > stock) {
                    out.println("<script>alert('Not enough stock available! Maximum: " + stock + "');</script>");
                    out.println("<script>alert('Added to cart!'); window.location.href='cart.jsp';</script>");
                    return;
                }
                
                // Update quantity
                PreparedStatement updateStmt = conn.prepareStatement(
                    "UPDATE cart SET quantity = ? WHERE id = ? AND user_id = ?"
                );
                updateStmt.setInt(1, quantity);
                updateStmt.setInt(2, Integer.parseInt(cartId));
                updateStmt.setInt(3, userId);
                
                int result = updateStmt.executeUpdate();
                
                if(result > 0) {
                    out.print("success");
                } else {
                    out.print("error");
                }
            }
            
            conn.close();
        } catch(Exception e) {
            e.printStackTrace();
            out.print("error");
        }
    }
}