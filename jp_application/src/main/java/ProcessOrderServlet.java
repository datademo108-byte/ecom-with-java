import java.io.*;
import java.sql.*;
import java.util.*;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.MultipartConfig;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

@WebServlet("/ProcessOrderServlet")
@MultipartConfig
public class ProcessOrderServlet extends HttpServlet {
    
    private static final String DB_URL = "jdbc:mysql://localhost:3306/ecom";
    private static final String DB_USER = "root";
    private static final String DB_PASSWORD = "Agr@hari567#";
    
    protected void doPost(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        response.setContentType("application/json");
        response.setCharacterEncoding("UTF-8");
        PrintWriter out = response.getWriter();
        
        Connection conn = null;
        PreparedStatement ps = null;
        ResultSet rs = null;
        
        try {
            // Get parameters
            String paymentMethod = request.getParameter("payment_method");
            String totalAmountStr = request.getParameter("total_amount");
            String userIdStr = request.getParameter("user_id");
            
            // Get user from session
            HttpSession session = request.getSession(false);
            int userId = 0;
            
            if (session != null && session.getAttribute("user_id") != null) {
                userId = (Integer) session.getAttribute("user_id");
            } else if (userIdStr != null && !userIdStr.isEmpty()) {
                userId = Integer.parseInt(userIdStr);
            } else {
                throw new Exception("User not logged in");
            }
            
            // Load database driver
            Class.forName("com.mysql.cj.jdbc.Driver");
            conn = DriverManager.getConnection(DB_URL, DB_USER, DB_PASSWORD);
            
            // Start transaction
            conn.setAutoCommit(false);
            
            // 1. Get cart items
            double cartTotal = 0;
            List<CartItem> cartItems = new ArrayList<>();
            
            String cartSql = "SELECT c.id as cart_id, c.product_id, c.quantity, p.price, p.name, p.stock_quantity " +
                            "FROM cart c " +
                            "JOIN products p ON c.product_id = p.id " +
                            "WHERE c.user_id = ?";
            
            ps = conn.prepareStatement(cartSql);
            ps.setInt(1, userId);
            rs = ps.executeQuery();
            
            while (rs.next()) {
                CartItem item = new CartItem();
                item.cartId = rs.getInt("cart_id");
                item.productId = rs.getInt("product_id");
                item.quantity = rs.getInt("quantity");
                item.price = rs.getDouble("price");
                item.productName = rs.getString("name");
                item.stock = rs.getInt("stock_quantity");
                
                // Check stock
                if (item.quantity > item.stock) {
                    throw new Exception("Insufficient stock for " + item.productName + 
                                       ". Available: " + item.stock);
                }
                
                cartTotal += (item.price * item.quantity);
                cartItems.add(item);
            }
            
            if (cartItems.isEmpty()) {
                throw new Exception("Your cart is empty");
            }
            
            // Calculate final amount
            double tax = cartTotal * 0.1;
            double shipping = (cartTotal > 50) ? 0 : 5.99;
            double finalTotal = cartTotal + tax + shipping;
            
            // 2. Create COD order
            String orderSql = "INSERT INTO orders (user_id, total_amount, status, payment_method, payment_status, order_date) " +
                            "VALUES (?, ?, 'pending', ?, 'pending', NOW())";
            
            ps = conn.prepareStatement(orderSql, Statement.RETURN_GENERATED_KEYS);
            ps.setInt(1, userId);
            ps.setDouble(2, finalTotal);
            ps.setString(3, paymentMethod);
            
            int affectedRows = ps.executeUpdate();
            
            if (affectedRows == 0) {
                throw new Exception("Failed to create order");
            }
            
            // Get order ID
            int orderId = 0;
            rs = ps.getGeneratedKeys();
            if (rs.next()) {
                orderId = rs.getInt(1);
            } else {
                throw new Exception("Failed to get order ID");
            }
            
            // 3. Create order items
            String orderItemSql = "INSERT INTO order_items (order_id, product_id, quantity, price) VALUES (?, ?, ?, ?)";
            ps = conn.prepareStatement(orderItemSql);
            
            for (CartItem item : cartItems) {
                ps.setInt(1, orderId);
                ps.setInt(2, item.productId);
                ps.setInt(3, item.quantity);
                ps.setDouble(4, item.price);
                ps.addBatch();
            }
            
            ps.executeBatch();
            
            // 4. Update stock
            String updateStockSql = "UPDATE products SET stock_quantity = stock_quantity - ? WHERE id = ?";
            PreparedStatement psUpdate = conn.prepareStatement(updateStockSql);
            
            for (CartItem item : cartItems) {
                psUpdate.setInt(1, item.quantity);
                psUpdate.setInt(2, item.productId);
                psUpdate.addBatch();
            }
            
            psUpdate.executeBatch();
            psUpdate.close();
            
            // 5. Clear cart
            String clearCartSql = "DELETE FROM cart WHERE user_id = ?";
            PreparedStatement psClear = conn.prepareStatement(clearCartSql);
            psClear.setInt(1, userId);
            psClear.executeUpdate();
            psClear.close();
            
            // 6. Commit
            conn.commit();
            
            out.println("{\"success\":true,\"orderId\":" + orderId + ",\"message\":\"COD order #" + orderId + " placed successfully!\"}");
            
        } catch (Exception e) {
            // Rollback
            try {
                if (conn != null) conn.rollback();
            } catch (SQLException ex) {
                ex.printStackTrace();
            }
            
            e.printStackTrace();
            out.println("{\"success\":false,\"message\":\"" + e.getMessage().replace("\"", "\\\"") + "\"}");
            
        } finally {
            try { if (rs != null) rs.close(); } catch (Exception e) {}
            try { if (ps != null) ps.close(); } catch (Exception e) {}
            try { 
                if (conn != null) {
                    conn.setAutoCommit(true);
                    conn.close(); 
                }
            } catch (Exception e) {}
        }
    }
    
    private static class CartItem {
        int cartId;
        int productId;
        int quantity;
        double price;
        String productName;
        int stock;
    }
}