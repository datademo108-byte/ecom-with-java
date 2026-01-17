import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import java.io.*;
import java.sql.*;

@WebServlet("/RemoveFromCartServlet")
public class RemoveFromCartServlet extends HttpServlet {
    
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws IOException {
        HttpSession session = request.getSession(false);
        
        // Check if user is logged in
        if(session == null || session.getAttribute("loggedin") == null) {
            response.sendRedirect("login.jsp");
            return;
        }
        
        String cartId = request.getParameter("cart_id");
        int userId = (Integer) session.getAttribute("user_id");
        
        PrintWriter out = response.getWriter();
        
        try {
            Class.forName("com.mysql.cj.jdbc.Driver");
            Connection conn = DriverManager.getConnection("jdbc:mysql://localhost:3306/ecom", "root", "Agr@hari567#");
            
            // Remove item from cart
            PreparedStatement stmt = conn.prepareStatement(
                "DELETE FROM cart WHERE id = ? AND user_id = ?"
            );
            stmt.setInt(1, Integer.parseInt(cartId));
            stmt.setInt(2, userId);
            
            int result = stmt.executeUpdate();
            
            if(result > 0) {
                out.print("success");
            } else {
                out.print("error");
            }
            
            conn.close();
        } catch(Exception e) {
            e.printStackTrace();
            out.print("error");
        }
    }
}