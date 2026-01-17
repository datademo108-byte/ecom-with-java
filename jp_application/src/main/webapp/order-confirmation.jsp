<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<%@ page import="java.sql.*" %>
<%
    String orderId = request.getParameter("order_id");
    if(orderId == null || orderId.trim().isEmpty()) {
        response.sendRedirect("cart.jsp");
        return;
    }
    
    // Check if user is logged in
    Boolean loggedIn = (session != null && session.getAttribute("loggedin") != null) ? 
                      (Boolean) session.getAttribute("loggedin") : false;
    
    if(!loggedIn) {
        response.sendRedirect("login.jsp");
        return;
    }
    
    int userId = (Integer) session.getAttribute("user_id");
    
    // Order details
    double totalAmount = 0;
    String orderDate = "";
    String status = "";
    String paymentMethod = "";
%>
<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>Order Confirmation - Ecommerce</title>
<link href="css/bootstrap.min.css" rel="stylesheet">
<link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.8.1/font/bootstrap-icons.css">
<style>
    .confirmation-container {
        max-width: 800px;
        margin: 0 auto;
    }
    .success-animation {
        animation: successPulse 2s ease-in-out;
    }
    @keyframes successPulse {
        0% { transform: scale(1); }
        50% { transform: scale(1.1); }
        100% { transform: scale(1); }
    }
    .order-details-card {
        border-left: 5px solid #28a745;
    }
    .timeline {
        position: relative;
        padding: 20px 0;
    }
    .timeline::before {
        content: '';
        position: absolute;
        left: 30px;
        top: 0;
        bottom: 0;
        width: 2px;
        background: #dee2e6;
    }
    .timeline-step {
        position: relative;
        padding-left: 60px;
        margin-bottom: 30px;
    }
    .timeline-step.active .timeline-icon {
        background: #28a745;
        color: white;
    }
    .timeline-icon {
        position: absolute;
        left: 20px;
        top: 0;
        width: 24px;
        height: 24px;
        border-radius: 50%;
        background: #dee2e6;
        display: flex;
        align-items: center;
        justify-content: center;
        z-index: 2;
    }
</style>
</head>
<body>
<jsp:include page="navbar.jsp"></jsp:include>

<div class="container mt-4 confirmation-container">
    <%
        Connection conn = null;
        PreparedStatement ps = null;
        ResultSet rs = null;
        
        try {
            Class.forName("com.mysql.cj.jdbc.Driver");
            conn = DriverManager.getConnection("jdbc:mysql://localhost:3306/ecom","root","Agr@hari567#");
            
            // Get order details
            String orderSql = "SELECT * FROM orders WHERE id = ? AND user_id = ?";
            ps = conn.prepareStatement(orderSql);
            ps.setInt(1, Integer.parseInt(orderId));
            ps.setInt(2, userId);
            rs = ps.executeQuery();
            
            if(rs.next()) {
                totalAmount = rs.getDouble("total_amount");
                orderDate = rs.getString("order_date");
                status = rs.getString("status");
                paymentMethod = rs.getString("payment_method");
            } else {
                response.sendRedirect("cart.jsp");
                return;
            }
            
            // Get order items
            String itemsSql = "SELECT oi.*, p.name, p.image FROM order_items oi " +
                             "JOIN products p ON oi.product_id = p.id " +
                             "WHERE oi.order_id = ?";
            ps = conn.prepareStatement(itemsSql);
            ps.setInt(1, Integer.parseInt(orderId));
            rs = ps.executeQuery();
    %>
    
    <!-- Success Header -->
    <div class="text-center mb-5">
        <div class="success-animation">
            <i class="bi bi-check-circle-fill text-success" style="font-size: 5rem;"></i>
        </div>
        <h1 class="mt-3">Order Confirmed!</h1>
        <p class="lead">Thank you for your purchase. Your order has been received.</p>
        <div class="alert alert-success d-inline-block">
            <i class="bi bi-info-circle"></i> 
            Order ID: <strong>#<%= orderId %></strong> | 
            Total: <strong>$<%= String.format("%.2f", totalAmount) %></strong>
        </div>
    </div>
    
    <div class="row">
        <!-- Order Timeline -->
        <div class="col-md-4 mb-4">
            <div class="card">
                <div class="card-header">
                    <h5 class="mb-0"><i class="bi bi-clock-history"></i> Order Status</h5>
                </div>
                <div class="card-body">
                    <div class="timeline">
                        <div class="timeline-step active">
                            <div class="timeline-icon">
                                <i class="bi bi-check"></i>
                            </div>
                            <h6>Order Placed</h6>
                            <small class="text-muted"><%= orderDate %></small>
                        </div>
                        
                        <div class="timeline-step">
                            <div class="timeline-icon">
                                <i class="bi bi-box"></i>
                            </div>
                            <h6>Processing</h6>
                            <small class="text-muted">Order being prepared</small>
                        </div>
                        
                        <div class="timeline-step">
                            <div class="timeline-icon">
                                <i class="bi bi-truck"></i>
                            </div>
                            <h6>Shipped</h6>
                            <small class="text-muted">Out for delivery</small>
                        </div>
                        
                        <div class="timeline-step">
                            <div class="timeline-icon">
                                <i class="bi bi-house-check"></i>
                            </div>
                            <h6>Delivered</h6>
                            <small class="text-muted">Order received</small>
                        </div>
                    </div>
                </div>
            </div>
            
            <!-- Help Card -->
            <div class="card mt-3">
                <div class="card-body text-center">
                    <i class="bi bi-headset text-primary fs-2"></i>
                    <h6 class="mt-2">Need Help?</h6>
                    <p class="text-muted small">Contact our support team</p>
                    <a href="mailto:support@ecommerce.com" class="btn btn-outline-primary btn-sm">
                        <i class="bi bi-envelope"></i> Email Support
                    </a>
                </div>
            </div>
        </div>
        
        <!-- Order Details -->
        <div class="col-md-8">
            <div class="card order-details-card">
                <div class="card-header">
                    <h5 class="mb-0"><i class="bi bi-receipt"></i> Order Details</h5>
                </div>
                <div class="card-body">
                    <div class="row mb-4">
                        <div class="col-md-6">
                            <h6>Order Information</h6>
                            <table class="table table-sm">
                                <tr>
                                    <td>Order ID:</td>
                                    <td><strong>#<%= orderId %></strong></td>
                                </tr>
                                <tr>
                                    <td>Order Date:</td>
                                    <td><%= orderDate %></td>
                                </tr>
                                <tr>
                                    <td>Status:</td>
                                    <td><span class="badge bg-success"><%= status %></span></td>
                                </tr>
                                <tr>
                                    <td>Payment Method:</td>
                                    <td>
                                        <% if("card".equals(paymentMethod)) { %>
                                            <i class="bi bi-credit-card"></i> Credit/Debit Card
                                        <% } else if("paypal".equals(paymentMethod)) { %>
                                            <i class="fab fa-paypal"></i> PayPal
                                        <% } else { %>
                                            <i class="bi bi-cash"></i> Cash on Delivery
                                        <% } %>
                                    </td>
                                </tr>
                            </table>
                        </div>
                        <div class="col-md-6">
                            <h6>Order Summary</h6>
                            <table class="table table-sm">
                                <tr>
                                    <td>Subtotal:</td>
                                    <td class="text-end">$<%= String.format("%.2f", totalAmount * 0.9) %></td>
                                </tr>
                                <tr>
                                    <td>Tax (10%):</td>
                                    <td class="text-end">$<%= String.format("%.2f", totalAmount * 0.1) %></td>
                                </tr>
                                <tr>
                                    <td>Shipping:</td>
                                    <td class="text-end">FREE</td>
                                </tr>
                                <tr class="table-active">
                                    <td><strong>Total:</strong></td>
                                    <td class="text-end"><strong>$<%= String.format("%.2f", totalAmount) %></strong></td>
                                </tr>
                            </table>
                        </div>
                    </div>
                    
                    <!-- Order Items -->
                    <h6>Order Items</h6>
                    <div class="table-responsive">
                        <table class="table table-hover">
                            <thead>
                                <tr>
                                    <th>Product</th>
                                    <th>Quantity</th>
                                    <th>Price</th>
                                    <th>Total</th>
                                </tr>
                            </thead>
                            <tbody>
                                <%
                                    double itemsTotal = 0;
                                    while(rs.next()) {
                                        double price = rs.getDouble("price");
                                        int quantity = rs.getInt("quantity");
                                        double itemTotal = price * quantity;
                                        itemsTotal += itemTotal;
                                %>
                                <tr>
                                    <td>
                                        <div class="d-flex align-items-center">
                                            <img src="uploads/<%= rs.getString("image") %>" 
                                                 alt="Product" class="rounded me-3" width="50" 
                                                 onerror="this.src='https://via.placeholder.com/50x50'">
                                            <div>
                                                <div><%= rs.getString("name") %></div>
                                                <small class="text-muted">Item #<%= rs.getInt("product_id") %></small>
                                            </div>
                                        </div>
                                    </td>
                                    <td><%= quantity %></td>
                                    <td>$<%= String.format("%.2f", price) %></td>
                                    <td>$<%= String.format("%.2f", itemTotal) %></td>
                                </tr>
                                <%
                                    }
                                %>
                            </tbody>
                            <tfoot>
                                <tr class="table-active">
                                    <td colspan="3" class="text-end"><strong>Items Total:</strong></td>
                                    <td><strong>$<%= String.format("%.2f", itemsTotal) %></strong></td>
                                </tr>
                            </tfoot>
                        </table>
                    </div>
                    
                    <!-- Action Buttons -->
                    <div class="d-flex justify-content-between mt-4">
                        <a href="products.jsp" class="btn btn-outline-primary">
                            <i class="bi bi-arrow-left"></i> Continue Shopping
                        </a>
                        <a href="order-history.jsp" class="btn btn-primary">
                            <i class="bi bi-list-check"></i> View All Orders
                        </a>
                        <button class="btn btn-success" onclick="window.print()">
                            <i class="bi bi-printer"></i> Print Receipt
                        </button>
                    </div>
                </div>
            </div>
            
            <!-- What's Next -->
            <div class="card mt-3">
                <div class="card-body">
                    <h6><i class="bi bi-info-circle text-info"></i> What happens next?</h6>
                    <div class="row mt-3">
                        <div class="col-md-4 text-center">
                            <div class="p-3 border rounded">
                                <i class="bi bi-envelope fs-2 text-primary"></i>
                                <h6 class="mt-2">Order Confirmation</h6>
                                <p class="small text-muted">You'll receive an email confirmation shortly</p>
                            </div>
                        </div>
                        <div class="col-md-4 text-center">
                            <div class="p-3 border rounded">
                                <i class="bi bi-truck fs-2 text-warning"></i>
                                <h6 class="mt-2">Shipment Tracking</h6>
                                <p class="small text-muted">Track your order in "My Orders" section</p>
                            </div>
                        </div>
                        <div class="col-md-4 text-center">
                            <div class="p-3 border rounded">
                                <i class="bi bi-house-check fs-2 text-success"></i>
                                <h6 class="mt-2">Delivery</h6>
                                <p class="small text-muted">Your order will arrive within 3-5 business days</p>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </div>
    
    <%
        } catch(Exception e) {
            e.printStackTrace();
    %>
    <div class="alert alert-danger">
        <h4>Error Loading Order</h4>
        <p>An error occurred while loading your order details.</p>
        <a href="index.jsp" class="btn btn-primary">Return Home</a>
    </div>
    <%
        } finally {
            try { if(rs != null) rs.close(); } catch(Exception e) {}
            try { if(ps != null) ps.close(); } catch(Exception e) {}
            try { if(conn != null) conn.close(); } catch(Exception e) {}
        }
    %>
    
    <!-- Email Confirmation Message -->
    <div class="alert alert-info mt-4">
        <div class="d-flex align-items-center">
            <i class="bi bi-envelope-check fs-3 me-3"></i>
            <div>
                <h6 class="mb-1">Check your email</h6>
                <p class="mb-0">We've sent an order confirmation to your email address. Please check your inbox (and spam folder).</p>
            </div>
        </div>
    </div>
</div>

<!-- Footer -->
<footer class="bg-light mt-5 py-4 border-top">
    <div class="container">
        <div class="row">
            <div class="col-md-12 text-center">
                <p>&copy; 2024 Ecommerce.org. All rights reserved.</p>
            </div>
        </div>
    </div>
</footer>

<script src="js/bootstrap.bundle.min.js"></script>
<script>
// Auto-scroll to top
window.onload = function() {
    window.scrollTo(0, 0);
};

// Set up order tracking
function trackOrder(orderId) {
    window.location.href = 'track-order.jsp?order_id=' + orderId;
}

// Share order
function shareOrder() {
    if(navigator.share) {
        navigator.share({
            title: 'My Ecommerce Order',
            text: 'I just placed an order on Ecommerce.org',
            url: window.location.href
        });
    } else {
        alert('Share this URL: ' + window.location.href);
    }
}
</script>
</body>
</html>