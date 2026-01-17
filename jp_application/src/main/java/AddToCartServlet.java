import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import java.io.*;
import java.sql.*;

@WebServlet("/AddToCartServlet")
public class AddToCartServlet extends HttpServlet {
    
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        HttpSession session = request.getSession(false);
        
        // Check if user is logged in
        if(session == null || session.getAttribute("loggedin") == null) {
            response.sendRedirect("login.jsp");
            return;
        }
        
        String productId = request.getParameter("product_id");
        String quantityStr = request.getParameter("quantity");
        int userId = (Integer) session.getAttribute("user_id");
        
        response.setContentType("text/html");
        PrintWriter out = response.getWriter();
        
        try {
            Class.forName("com.mysql.cj.jdbc.Driver");
            Connection conn = DriverManager.getConnection("jdbc:mysql://localhost:3306/ecom", "root", "Agr@hari567#");
            
            // Check if product exists and has stock
            PreparedStatement checkStmt = conn.prepareStatement("SELECT stock_quantity FROM products WHERE id = ?");
            checkStmt.setInt(1, Integer.parseInt(productId));
            ResultSet rs = checkStmt.executeQuery();
            
            if(!rs.next()) {
                out.println("<script>alert('Product not found!'); window.history.back();</script>");
                return;
            }
            
            int stock = rs.getInt("stock_quantity");
            int quantity = (quantityStr != null) ? Integer.parseInt(quantityStr) : 1;
            
            if(stock < quantity) {
                out.println("<script>alert('Not enough stock available!'); window.history.back();</script>");
                out.println("<script>alert('Added to cart!'); window.location.href='cart.jsp';</script>");
                return;
            }
            
            // Check if product already in cart
            PreparedStatement checkCartStmt = conn.prepareStatement(
                "SELECT * FROM cart WHERE user_id = ? AND product_id = ?"
            );
            checkCartStmt.setInt(1, userId);
            checkCartStmt.setInt(2, Integer.parseInt(productId));
            ResultSet cartRs = checkCartStmt.executeQuery();
            
            if(cartRs.next()) {
                // Update quantity if already in cart
                int currentQty = cartRs.getInt("quantity");
                PreparedStatement updateStmt = conn.prepareStatement(
                    "UPDATE cart SET quantity = quantity + ? WHERE user_id = ? AND product_id = ?"
                );
                updateStmt.setInt(1, quantity);
                updateStmt.setInt(2, userId);
                updateStmt.setInt(3, Integer.parseInt(productId));
                updateStmt.executeUpdate();
            } else {
                // Add new item to cart
                PreparedStatement insertStmt = conn.prepareStatement(
                    "INSERT INTO cart (user_id, product_id, quantity) VALUES (?, ?, ?)"
                );
                insertStmt.setInt(1, userId);
                insertStmt.setInt(2, Integer.parseInt(productId));
                insertStmt.setInt(3, quantity);
                insertStmt.executeUpdate();
            }
            
            // Success message
            out.println("<script>alert('Added to cart!'); window.location.href='cart.jsp';</script>");
          

            conn.close();
        } catch(Exception e) {
            e.printStackTrace();
            out.println("<script>alert('Error adding to cart!'); window.history.back();</script>");
        }
    }
}