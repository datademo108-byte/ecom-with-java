<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<%@ page import="java.sql.*, java.util.*" %>
<%
    // Check if user is logged in
    Boolean loggedIn = (session != null && session.getAttribute("loggedin") != null) ? 
                      (Boolean) session.getAttribute("loggedin") : false;
    
    if(!loggedIn) {
        response.sendRedirect("login.jsp");
        return;
    }
    
    int userId = (Integer) session.getAttribute("user_id");
    String userName = (String) session.getAttribute("first_name");
%>
<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>My Orders</title>
<link href="css/bootstrap.min.css" rel="stylesheet">
<link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.8.1/font/bootstrap-icons.css">
<style>
    .order-card {
        border-left: 4px solid #0d6efd;
        margin-bottom: 20px;
        transition: all 0.3s;
    }
    .order-card:hover {
        transform: translateY(-2px);
        box-shadow: 0 5px 15px rgba(0,0,0,0.1);
    }
    .order-status {
        font-size: 0.9rem;
        padding: 3px 10px;
        border-radius: 20px;
        font-weight: 500;
    }
    .status-pending { background: #fff3cd; color: #856404; }
    .status-confirmed { background: #d1ecf1; color: #0c5460; }
    .status-shipped { background: #d4edda; color: #155724; }
    .status-delivered { background: #c3e6cb; color: #155724; }
    .status-cancelled { background: #f8d7da; color: #721c24; }
    .empty-orders {
        max-width: 400px;
        margin: 0 auto;
        text-align: center;
        padding: 40px 0;
    }
</style>
</head>
<body>
<jsp:include page="navbar.jsp"></jsp:include>

<div class="container mt-4">
    <div class="row">
        <div class="col-12">
            <!-- Breadcrumb -->
            <nav aria-label="breadcrumb" class="mb-4">
                <ol class="breadcrumb">
                    <li class="breadcrumb-item"><a href="index.jsp"><i class="bi bi-house"></i> Home</a></li>
                    <li class="breadcrumb-item active">My Orders</li>
                </ol>
            </nav>
            
            <!-- Page Header -->
            <div class="d-flex justify-content-between align-items-center mb-4">
                <div>
                    <h2><i class="bi bi-list-check"></i> My Orders</h2>
                    <p class="text-muted mb-0">View your order history and track shipments</p>
                </div>
                <div>
                    <a href="products.jsp" class="btn btn-primary">
                        <i class="bi bi-plus-circle"></i> Shop More
                    </a>
                </div>
            </div>
            
            <!-- Orders List -->
            <%
                Connection conn = null;
                PreparedStatement ps = null;
                ResultSet rs = null;
                
                try {
                    Class.forName("com.mysql.cj.jdbc.Driver");
                    conn = DriverManager.getConnection("jdbc:mysql://localhost:3306/ecom","root","Agr@hari567#");
                    
                    // Get orders with item count
                    String orderSql = "SELECT o.*, COUNT(oi.id) as item_count " +
                                     "FROM orders o " +
                                     "LEFT JOIN order_items oi ON o.id = oi.order_id " +
                                     "WHERE o.user_id = ? " +
                                     "GROUP BY o.id " +
                                     "ORDER BY o.order_date DESC";
                    
                    ps = conn.prepareStatement(orderSql);
                    ps.setInt(1, userId);
                    rs = ps.executeQuery();
                    
                    boolean hasOrders = false;
                    
                    while(rs.next()) {
                        hasOrders = true;
                        int orderId = rs.getInt("id");
                        double totalAmount = rs.getDouble("total_amount");
                        String status = rs.getString("status");
                        java.sql.Date orderDate = rs.getDate("order_date"); // Changed to java.sql.Date
                        String paymentMethod = rs.getString("payment_method");
                        String paymentStatus = rs.getString("payment_status");
                        int itemCount = rs.getInt("item_count");
                        
                        // Format date
                        String formattedDate = "";
                        if (orderDate != null) {
                            formattedDate = orderDate.toString();
                        }
                        
                        String statusClass = "";
                        String statusText = status;
                        
                        if(status != null) {
                            switch(status.toLowerCase()) {
                                case "pending": 
                                    statusClass = "status-pending"; 
                                    statusText = "Pending";
                                    break;
                                case "confirmed": 
                                case "processing":
                                    statusClass = "status-confirmed"; 
                                    statusText = "Processing";
                                    break;
                                case "shipped": 
                                    statusClass = "status-shipped"; 
                                    statusText = "Shipped";
                                    break;
                                case "delivered": 
                                    statusClass = "status-delivered"; 
                                    statusText = "Delivered";
                                    break;
                                case "cancelled": 
                                    statusClass = "status-cancelled"; 
                                    statusText = "Cancelled";
                                    break;
                                default: 
                                    statusClass = "status-pending";
                                    statusText = "Pending";
                            }
                        }
                        
                        // Payment method display
                        String paymentDisplay = "";
                        if("cod".equalsIgnoreCase(paymentMethod)) {
                            paymentDisplay = "Cash on Delivery";
                        } else if("razorpay".equalsIgnoreCase(paymentMethod)) {
                            paymentDisplay = "Online Payment";
                        } else if(paymentMethod != null) {
                            paymentDisplay = paymentMethod;
                        } else {
                            paymentDisplay = "Not Specified";
                        }
            %>
            <!-- Order Card -->
            <div class="card order-card mb-3">
                <div class="card-body">
                    <div class="row align-items-center">
                        <!-- Order Info -->
                        <div class="col-md-8">
                            <div class="d-flex align-items-center mb-2">
                                <h5 class="card-title mb-0 me-3">
                                    <i class="bi bi-bag-check text-primary"></i> Order #<%= orderId %>
                                </h5>
                                <span class="order-status <%= statusClass %>"><%= statusText %></span>
                            </div>
                            
                            <div class="row text-muted mb-2">
                                <div class="col-auto">
                                    <i class="bi bi-calendar"></i> <%= formattedDate %>
                                </div>
                                <div class="col-auto">
                                    <i class="bi bi-box"></i> <%= itemCount %> item(s)
                                </div>
                                <div class="col-auto">
                                    <i class="bi bi-credit-card"></i> <%= paymentDisplay %>
                                </div>
                            </div>
                            
                            <div class="d-flex align-items-center">
                                <span class="fs-4 fw-bold text-dark">₹<%= String.format("%.2f", totalAmount) %></span>
                                <% if("paid".equalsIgnoreCase(paymentStatus)) { %>
                                    <span class="badge bg-success ms-3">
                                        <i class="bi bi-check-circle"></i> Paid
                                    </span>
                                <% } else if("pending".equalsIgnoreCase(paymentStatus)) { %>
                                    <span class="badge bg-warning ms-3">
                                        <i class="bi bi-clock"></i> Payment Pending
                                    </span>
                                <% } else if(paymentStatus != null) { %>
                                    <span class="badge bg-secondary ms-3">
                                        <%= paymentStatus %>
                                    </span>
                                <% } %>
                            </div>
                        </div>
                        
                        <!-- Action Buttons -->
                        <div class="col-md-4 text-end">
                            <div class="d-flex flex-column flex-md-row justify-content-end gap-2">
                                <a href="order-confirmation.jsp?order_id=<%= orderId %>" class="btn btn-outline-primary">
                                    <i class="bi bi-eye"></i> View Details
                                </a>
                                
                                <% if("pending".equalsIgnoreCase(status)) { %>
                                <button class="btn btn-outline-danger" onclick="cancelOrder(<%= orderId %>)">
                                    <i class="bi bi-x-circle"></i> Cancel
                                </button>
                                <% } %>
                            </div>
                            
                            <!-- Additional options -->
                            <div class="mt-2">
                                <% if("delivered".equalsIgnoreCase(status)) { %>
                                <button class="btn btn-sm btn-outline-success">
                                    <i class="bi bi-star"></i> Rate Order
                                </button>
                                <% } %>
                                
                                <% if("shipped".equalsIgnoreCase(status) || "delivered".equalsIgnoreCase(status)) { %>
                                <button class="btn btn-sm btn-outline-info ms-1" onclick="trackOrder(<%= orderId %>)">
                                    <i class="bi bi-truck"></i> Track
                                </button>
                                <% } %>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
            <%
                    }
                    
                    if(!hasOrders) {
            %>
            <!-- Empty Orders State -->
            <div class="empty-orders">
                <div class="card border-0 shadow-sm">
                    <div class="card-body py-5">
                        <i class="bi bi-cart-x display-1 text-muted mb-4"></i>
                        <h3 class="mb-3">No Orders Yet</h3>
                        <p class="text-muted mb-4">You haven't placed any orders yet. Start shopping to see your orders here.</p>
                        <div class="d-grid gap-2 col-md-6 mx-auto">
                            <a href="products.jsp" class="btn btn-primary btn-lg">
                                <i class="bi bi-shop"></i> Start Shopping
                            </a>
                            <a href="index.jsp" class="btn btn-outline-secondary">
                                <i class="bi bi-house"></i> Return Home
                            </a>
                        </div>
                    </div>
                </div>
            </div>
            <%
                    }
                    
                } catch(Exception e) {
                    e.printStackTrace();
            %>
            <!-- Error State -->
            <div class="alert alert-danger">
                <div class="d-flex align-items-center">
                    <i class="bi bi-exclamation-triangle-fill fs-4 me-3"></i>
                    <div>
                        <h4 class="alert-heading">Error Loading Orders</h4>
                        <p class="mb-0">An error occurred while loading your orders. Please try again later.</p>
                    </div>
                </div>
                <hr>
                <div class="d-flex gap-2">
                    <a href="index.jsp" class="btn btn-primary">
                        <i class="bi bi-house"></i> Return Home
                    </a>
                    <button class="btn btn-outline-primary" onclick="window.location.reload()">
                        <i class="bi bi-arrow-clockwise"></i> Try Again
                    </button>
                </div>
            </div>
            <%
                } finally {
                    try { if(rs != null) rs.close(); } catch(Exception e) {}
                    try { if(ps != null) ps.close(); } catch(Exception e) {}
                    try { if(conn != null) conn.close(); } catch(Exception e) {}
                }
            %>
        </div>
    </div>
</div>

<!-- Footer -->
<footer class="bg-light mt-5 py-4 border-top">
    <div class="container">
        <div class="row">
            <div class="col-md-6">
                <h5>Order Support</h5>
                <p class="text-muted small mb-0">Need help with your orders?</p>
                <a href="mailto:support@ecommerce.com" class="text-decoration-none">
                    <i class="bi bi-envelope"></i> support@ecommerce.com
                </a>
            </div>
            <div class="col-md-6 text-end">
                <p class="text-muted small mb-0">&copy; 2024 Ecommerce. All rights reserved.</p>
            </div>
        </div>
    </div>
</footer>

<script src="js/bootstrap.bundle.min.js"></script>
<script>
// Cancel order function
function cancelOrder(orderId) {
    if(confirm('Are you sure you want to cancel Order #' + orderId + '?\n\nThis action cannot be undone.')) {
        // Show loading
        const btn = event.target;
        const originalText = btn.innerHTML;
        btn.innerHTML = '<i class="bi bi-hourglass-split"></i> Cancelling...';
        btn.disabled = true;
        
        fetch('CancelOrderServlet?order_id=' + orderId)
            .then(response => response.json())
            .then(data => {
                if(data.success) {
                    alert('Order #' + orderId + ' has been cancelled successfully.');
                    location.reload();
                } else {
                    alert('Error: ' + data.message);
                    btn.innerHTML = originalText;
                    btn.disabled = false;
                }
            })
            .catch(error => {
                alert('Network error. Please try again.');
                btn.innerHTML = originalText;
                btn.disabled = false;
            });
    }
}

// Track order function
function trackOrder(orderId) {
    // For now, just show a message
    // You can implement actual tracking later
    alert('Tracking for Order #' + orderId + '\n\nTracking feature will be available soon!');
}

// Print order function
function printOrder(orderId) {
    window.open('print-order.jsp?order_id=' + orderId, '_blank');
}

// Filter orders by status
function filterOrders(status) {
    // You can implement this later
    alert('Filter by ' + status + ' - Feature coming soon!');
}

// Search orders
function searchOrders() {
    const searchTerm = document.getElementById('searchOrders').value;
    if(searchTerm.trim()) {
        alert('Searching for: ' + searchTerm + '\n\nSearch feature coming soon!');
    }
}

// Initialize
document.addEventListener('DOMContentLoaded', function() {
    console.log('Orders page loaded');
    
    // Add any initialization code here
});
</script>
</body>
</html>