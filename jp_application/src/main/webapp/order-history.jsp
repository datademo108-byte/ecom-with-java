<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<%@ page import="java.sql.*, java.util.*, java.text.SimpleDateFormat" %>
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
    
    // Get filter parameters
    String filterStatus = request.getParameter("status");
    String filterDate = request.getParameter("date");
    String searchQuery = request.getParameter("search");
%>
<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>Order History - Ecommerce</title>
<link href="css/bootstrap.min.css" rel="stylesheet">
<link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.8.1/font/bootstrap-icons.css">
<link rel="stylesheet" type="text/css" href="https://cdn.datatables.net/1.13.4/css/dataTables.bootstrap5.min.css">
<style>
    .order-card {
        border-left: 4px solid #0d6efd;
        margin-bottom: 15px;
        transition: all 0.3s;
    }
    .order-card:hover {
        transform: translateY(-2px);
        box-shadow: 0 5px 15px rgba(0,0,0,0.1);
    }
    .status-badge {
        font-size: 0.85rem;
        padding: 3px 10px;
        border-radius: 20px;
        font-weight: 500;
    }
    .status-pending { background: #fff3cd; color: #856404; }
    .status-processing { background: #cce5ff; color: #004085; }
    .status-confirmed { background: #d1ecf1; color: #0c5460; }
    .status-shipped { background: #d4edda; color: #155724; }
    .status-delivered { background: #c3e6cb; color: #155724; }
    .status-cancelled { background: #f8d7da; color: #721c24; }
    .status-refunded { background: #e2e3e5; color: #383d41; }
    .payment-badge {
        font-size: 0.8rem;
        padding: 2px 8px;
        border-radius: 15px;
    }
    .payment-paid { background: #d4edda; color: #155724; }
    .payment-pending { background: #fff3cd; color: #856404; }
    .payment-failed { background: #f8d7da; color: #721c24; }
    .filter-section {
        background: #f8f9fa;
        border-radius: 10px;
        padding: 20px;
        margin-bottom: 25px;
    }
    .stats-card {
        text-align: center;
        padding: 15px;
        border-radius: 10px;
        margin-bottom: 15px;
    }
    .stats-total { background: #e3f2fd; border-left: 4px solid #2196f3; }
    .stats-pending { background: #fff3e0; border-left: 4px solid #ff9800; }
    .stats-delivered { background: #e8f5e9; border-left: 4px solid #4caf50; }
    .stats-cancelled { background: #ffebee; border-left: 4px solid #f44336; }
    .empty-state {
        max-width: 500px;
        margin: 0 auto;
        text-align: center;
        padding: 50px 0;
    }
    .order-actions {
        display: flex;
        gap: 8px;
        flex-wrap: wrap;
    }
    .order-actions .btn {
        font-size: 0.85rem;
        padding: 4px 10px;
    }
</style>
</head>
<body>
<jsp:include page="navbar.jsp"></jsp:include>

<div class="container mt-4">
    <!-- Breadcrumb -->
    <nav aria-label="breadcrumb" class="mb-4">
        <ol class="breadcrumb">
            <li class="breadcrumb-item"><a href="index.jsp"><i class="bi bi-house"></i> Home</a></li>
            <li class="breadcrumb-item active">Order History</li>
        </ol>
    </nav>
    
    <!-- Page Header -->
    <div class="d-flex justify-content-between align-items-center mb-4">
        <div>
            <h2><i class="bi bi-clock-history"></i> Order History</h2>
            <p class="text-muted mb-0">View and manage all your past orders</p>
        </div>
        <div>
            <a href="products.jsp" class="btn btn-primary">
                <i class="bi bi-plus-circle"></i> Shop More
            </a>
            <button class="btn btn-outline-secondary" onclick="printOrders()">
                <i class="bi bi-printer"></i> Print
            </button>
        </div>
    </div>
    
    <!-- Stats Cards -->
    <%
        Connection statsConn = null;
        PreparedStatement statsPs = null;
        ResultSet statsRs = null;
        
        int totalOrders = 0;
        int pendingOrders = 0;
        int deliveredOrders = 0;
        int cancelledOrders = 0;
        double totalSpent = 0;
        
        try {
            Class.forName("com.mysql.cj.jdbc.Driver");
            statsConn = DriverManager.getConnection("jdbc:mysql://localhost:3306/ecom","root","Agr@hari567#");
            
            // Total orders count
            String totalSql = "SELECT COUNT(*) as total FROM orders WHERE user_id = ?";
            statsPs = statsConn.prepareStatement(totalSql);
            statsPs.setInt(1, userId);
            statsRs = statsPs.executeQuery();
            if(statsRs.next()) totalOrders = statsRs.getInt("total");
            
            // Pending orders
            String pendingSql = "SELECT COUNT(*) as count FROM orders WHERE user_id = ? AND status = 'pending'";
            statsPs = statsConn.prepareStatement(pendingSql);
            statsPs.setInt(1, userId);
            statsRs = statsPs.executeQuery();
            if(statsRs.next()) pendingOrders = statsRs.getInt("count");
            
            // Delivered orders
            String deliveredSql = "SELECT COUNT(*) as count FROM orders WHERE user_id = ? AND status = 'delivered'";
            statsPs = statsConn.prepareStatement(deliveredSql);
            statsPs.setInt(1, userId);
            statsRs = statsPs.executeQuery();
            if(statsRs.next()) deliveredOrders = statsRs.getInt("count");
            
            // Cancelled orders
            String cancelledSql = "SELECT COUNT(*) as count FROM orders WHERE user_id = ? AND status = 'cancelled'";
            statsPs = statsConn.prepareStatement(cancelledSql);
            statsPs.setInt(1, userId);
            statsRs = statsPs.executeQuery();
            if(statsRs.next()) cancelledOrders = statsRs.getInt("count");
            
            // Total spent
            String spentSql = "SELECT COALESCE(SUM(total_amount), 0) as total FROM orders WHERE user_id = ? AND payment_status = 'paid'";
            statsPs = statsConn.prepareStatement(spentSql);
            statsPs.setInt(1, userId);
            statsRs = statsPs.executeQuery();
            if(statsRs.next()) totalSpent = statsRs.getDouble("total");
            
        } catch(Exception e) {
            e.printStackTrace();
        } finally {
            try { if(statsRs != null) statsRs.close(); } catch(Exception e) {}
            try { if(statsPs != null) statsPs.close(); } catch(Exception e) {}
            try { if(statsConn != null) statsConn.close(); } catch(Exception e) {}
        }
    %>
    
    <div class="row mb-4">
        <div class="col-md-3">
            <div class="stats-card stats-total">
                <h3 class="mb-1"><%= totalOrders %></h3>
                <p class="text-muted mb-0">Total Orders</p>
            </div>
        </div>
        <div class="col-md-3">
            <div class="stats-card stats-pending">
                <h3 class="mb-1"><%= pendingOrders %></h3>
                <p class="text-muted mb-0">Pending</p>
            </div>
        </div>
        <div class="col-md-3">
            <div class="stats-card stats-delivered">
                <h3 class="mb-1"><%= deliveredOrders %></h3>
                <p class="text-muted mb-0">Delivered</p>
            </div>
        </div>
        <div class="col-md-3">
            <div class="stats-card stats-cancelled">
                <h3 class="mb-1"><%= cancelledOrders %></h3>
                <p class="text-muted mb-0">Cancelled</p>
            </div>
        </div>
    </div>
    
    <!-- Total Spent -->
    <div class="alert alert-info">
        <div class="d-flex justify-content-between align-items-center">
            <div>
                <h5 class="mb-1"><i class="bi bi-currency-rupee"></i> Total Amount Spent</h5>
                <p class="mb-0">You've spent a total of <strong>₹<%= String.format("%.2f", totalSpent) %></strong> on <%= totalOrders %> orders</p>
            </div>
            <div>
                <button class="btn btn-outline-info" onclick="showSpendingReport()">
                    <i class="bi bi-graph-up"></i> View Report
                </button>
            </div>
        </div>
    </div>
    
    <!-- Filter Section -->
    <div class="filter-section">
        <h5><i class="bi bi-funnel"></i> Filter Orders</h5>
        <form method="GET" action="order-history.jsp" class="row g-3">
            <div class="col-md-3">
                <label for="status" class="form-label">Status</label>
                <select class="form-select" id="status" name="status">
                    <option value="">All Status</option>
                    <option value="pending" <%= "pending".equals(filterStatus) ? "selected" : "" %>>Pending</option>
                    <option value="confirmed" <%= "confirmed".equals(filterStatus) ? "selected" : "" %>>Confirmed</option>
                    <option value="processing" <%= "processing".equals(filterStatus) ? "selected" : "" %>>Processing</option>
                    <option value="shipped" <%= "shipped".equals(filterStatus) ? "selected" : "" %>>Shipped</option>
                    <option value="delivered" <%= "delivered".equals(filterStatus) ? "selected" : "" %>>Delivered</option>
                    <option value="cancelled" <%= "cancelled".equals(filterStatus) ? "selected" : "" %>>Cancelled</option>
                </select>
            </div>
            <div class="col-md-3">
                <label for="date" class="form-label">Date Range</label>
                <select class="form-select" id="date" name="date">
                    <option value="">All Time</option>
                    <option value="today" <%= "today".equals(filterDate) ? "selected" : "" %>>Today</option>
                    <option value="week" <%= "week".equals(filterDate) ? "selected" : "" %>>This Week</option>
                    <option value="month" <%= "month".equals(filterDate) ? "selected" : "" %>>This Month</option>
                    <option value="year" <%= "year".equals(filterDate) ? "selected" : "" %>>This Year</option>
                </select>
            </div>
            <div class="col-md-4">
                <label for="search" class="form-label">Search Orders</label>
                <input type="text" class="form-control" id="search" name="search" 
                       placeholder="Search by order ID, product name..." value="<%= searchQuery != null ? searchQuery : "" %>">
            </div>
            <div class="col-md-2 d-flex align-items-end">
                <div class="d-grid gap-2">
                    <button type="submit" class="btn btn-primary">
                        <i class="bi bi-search"></i> Filter
                    </button>
                    <a href="order-history.jsp" class="btn btn-outline-secondary">Clear</a>
                </div>
            </div>
        </form>
    </div>
    
    <!-- Orders List -->
    <div class="card">
        <div class="card-header bg-light">
            <div class="d-flex justify-content-between align-items-center">
                <h5 class="mb-0"><i class="bi bi-list-ul"></i> Your Orders</h5>
                <span class="badge bg-primary"><%= totalOrders %> orders</span>
            </div>
        </div>
        <div class="card-body">
            <%
                Connection conn = null;
                PreparedStatement ps = null;
                ResultSet rs = null;
                
                try {
                    Class.forName("com.mysql.cj.jdbc.Driver");
                    conn = DriverManager.getConnection("jdbc:mysql://localhost:3306/ecom","root","Agr@hari567#");
                    
                    // Build SQL query with filters
                    StringBuilder sqlBuilder = new StringBuilder();
                    sqlBuilder.append("SELECT o.*, ");
                    sqlBuilder.append("(SELECT COUNT(*) FROM order_items oi WHERE oi.order_id = o.id) as item_count, ");
                    sqlBuilder.append("(SELECT GROUP_CONCAT(p.name SEPARATOR ', ') FROM order_items oi JOIN products p ON oi.product_id = p.id WHERE oi.order_id = o.id LIMIT 3) as product_names ");
                    sqlBuilder.append("FROM orders o WHERE o.user_id = ? ");
                    
                    List<Object> params = new ArrayList<>();
                    params.add(userId);
                    
                    // Apply filters
                    if(filterStatus != null && !filterStatus.isEmpty()) {
                        sqlBuilder.append("AND o.status = ? ");
                        params.add(filterStatus);
                    }
                    
                    if(filterDate != null && !filterDate.isEmpty()) {
                        switch(filterDate) {
                            case "today":
                                sqlBuilder.append("AND DATE(o.order_date) = CURDATE() ");
                                break;
                            case "week":
                                sqlBuilder.append("AND YEARWEEK(o.order_date) = YEARWEEK(CURDATE()) ");
                                break;
                            case "month":
                                sqlBuilder.append("AND MONTH(o.order_date) = MONTH(CURDATE()) AND YEAR(o.order_date) = YEAR(CURDATE()) ");
                                break;
                            case "year":
                                sqlBuilder.append("AND YEAR(o.order_date) = YEAR(CURDATE()) ");
                                break;
                        }
                    }
                    
                    if(searchQuery != null && !searchQuery.isEmpty()) {
                        sqlBuilder.append("AND (o.id LIKE ? OR EXISTS (SELECT 1 FROM order_items oi JOIN products p ON oi.product_id = p.id WHERE oi.order_id = o.id AND p.name LIKE ?)) ");
                        params.add("%" + searchQuery + "%");
                        params.add("%" + searchQuery + "%");
                    }
                    
                    sqlBuilder.append("ORDER BY o.order_date DESC");
                    
                    ps = conn.prepareStatement(sqlBuilder.toString());
                    
                    // Set parameters
                    for(int i = 0; i < params.size(); i++) {
                        ps.setObject(i + 1, params.get(i));
                    }
                    
                    rs = ps.executeQuery();
                    
                    boolean hasOrders = false;
                    
                    while(rs.next()) {
                        hasOrders = true;
                        int orderId = rs.getInt("id");
                        double totalAmount = rs.getDouble("total_amount");
                        String status = rs.getString("status");
                        java.sql.Timestamp orderTimestamp = rs.getTimestamp("order_date");
                        String paymentMethod = rs.getString("payment_method");
                        String paymentStatus = rs.getString("payment_status");
                        int itemCount = rs.getInt("item_count");
                        String productNames = rs.getString("product_names");
                        
                        // Format date
                        String formattedDate = "";
                        if (orderTimestamp != null) {
                            SimpleDateFormat sdf = new SimpleDateFormat("dd MMM yyyy, hh:mm a");
                            formattedDate = sdf.format(new java.util.Date(orderTimestamp.getTime()));
                        }
                        
                        // Status badge class
                        String statusClass = "status-" + (status != null ? status.toLowerCase() : "pending");
                        String statusText = status != null ? status.substring(0, 1).toUpperCase() + status.substring(1) : "Pending";
                        
                        // Payment badge
                        String paymentClass = "";
                        String paymentText = "";
                        if("paid".equalsIgnoreCase(paymentStatus)) {
                            paymentClass = "payment-paid";
                            paymentText = "Paid";
                        } else if("pending".equalsIgnoreCase(paymentStatus)) {
                            paymentClass = "payment-pending";
                            paymentText = "Pending";
                        } else if("failed".equalsIgnoreCase(paymentStatus)) {
                            paymentClass = "payment-failed";
                            paymentText = "Failed";
                        } else {
                            paymentClass = "payment-pending";
                            paymentText = "Pending";
                        }
                        
                        // Payment method display
                        String paymentDisplay = "";
                        if("cod".equalsIgnoreCase(paymentMethod)) {
                            paymentDisplay = "Cash on Delivery";
                        } else if("razorpay".equalsIgnoreCase(paymentMethod)) {
                            paymentDisplay = "Online Payment";
                        } else if(paymentMethod != null) {
                            paymentDisplay = paymentMethod;
                        }
            %>
            <!-- Order Card -->
            <div class="card order-card mb-3">
                <div class="card-body">
                    <div class="row">
                        <!-- Order Info -->
                        <div class="col-md-8">
                            <div class="d-flex align-items-center mb-2">
                                <h5 class="card-title mb-0 me-3">
                                    Order #<%= orderId %>
                                </h5>
                                <span class="status-badge <%= statusClass %> me-2"><%= statusText %></span>
                                <span class="payment-badge <%= paymentClass %>"><%= paymentText %></span>
                            </div>
                            
                            <p class="text-muted mb-2">
                                <i class="bi bi-calendar"></i> <%= formattedDate %>
                                • <i class="bi bi-box"></i> <%= itemCount %> item(s)
                                <% if(paymentDisplay != null && !paymentDisplay.isEmpty()) { %>
                                • <i class="bi bi-credit-card"></i> <%= paymentDisplay %>
                                <% } %>
                            </p>
                            
                            <% if(productNames != null && !productNames.isEmpty()) { %>
                            <p class="mb-2">
                                <small class="text-muted">
                                    <i class="bi bi-cart"></i> 
                                    <%= productNames.length() > 100 ? productNames.substring(0, 100) + "..." : productNames %>
                                </small>
                            </p>
                            <% } %>
                            
                            <h4 class="text-dark mb-0">₹<%= String.format("%.2f", totalAmount) %></h4>
                        </div>
                        
                        <!-- Action Buttons -->
                        <div class="col-md-4">
                            <div class="order-actions justify-content-end">
                                <a href="order-confirmation.jsp?order_id=<%= orderId %>" class="btn btn-outline-primary">
                                    <i class="bi bi-eye"></i> View
                                </a>
                                
                                <% if("pending".equalsIgnoreCase(status) || "confirmed".equalsIgnoreCase(status)) { %>
                                
                                <% } %>
                                
                                <% if("delivered".equalsIgnoreCase(status)) { %>
                                <button class="btn btn-outline-success" onclick="rateOrder(<%= orderId %>)">
                                    <i class="bi bi-star"></i> Rate
                                </button>
                                <button class="btn btn-outline-info" onclick="reorder(<%= orderId %>)">
                                    <i class="bi bi-arrow-repeat"></i> Reorder
                                </button>
                                <% } %>
                                
                                <% if("pending".equalsIgnoreCase(status)) { %>
                                <button class="btn btn-outline-danger" onclick="cancelOrder(<%= orderId %>)">
                                    <i class="bi bi-x-circle"></i> Cancel
                                </button>
                                <% } %>
                                
                              
                            </div>
                            
                            <!-- Quick Status -->
                            <div class="mt-3 text-end">
                                <% if("shipped".equalsIgnoreCase(status)) { %>
                                <small class="text-info">
                                    <i class="bi bi-info-circle"></i> Your order is on the way
                                </small>
                                <% } else if("delivered".equalsIgnoreCase(status)) { %>
                                <small class="text-success">
                                    <i class="bi bi-check-circle"></i> Delivered successfully
                                </small>
                                <% } else if("cancelled".equalsIgnoreCase(status)) { %>
                                <small class="text-danger">
                                    <i class="bi bi-x-circle"></i> Order cancelled
                                </small>
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
            <!-- Empty State -->
            <div class="empty-state">
                <i class="bi bi-cart-x display-1 text-muted mb-4"></i>
                <h3 class="mb-3">No Orders Found</h3>
                <p class="text-muted mb-4">
                    <% if(filterStatus != null || filterDate != null || searchQuery != null) { %>
                    No orders match your filter criteria. Try changing your filters.
                    <% } else { %>
                    You haven't placed any orders yet. Start shopping to see your order history here.
                    <% } %>
                </p>
                <div class="d-grid gap-2 col-md-6 mx-auto">
                    <a href="products.jsp" class="btn btn-primary btn-lg">
                        <i class="bi bi-shop"></i> Start Shopping
                    </a>
                    <% if(filterStatus != null || filterDate != null || searchQuery != null) { %>
                    <a href="order-history.jsp" class="btn btn-outline-secondary">
                        <i class="bi bi-x-circle"></i> Clear Filters
                    </a>
                    <% } %>
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
                        <p class="mb-0">An error occurred while loading your order history. Please try again later.</p>
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
        
        <!-- Pagination (if needed) -->
        <% if(totalOrders > 10) { %>
        <div class="card-footer">
            <nav aria-label="Page navigation">
                <ul class="pagination justify-content-center mb-0">
                    <li class="page-item disabled">
                        <a class="page-link" href="#" tabindex="-1">Previous</a>
                    </li>
                    <li class="page-item active"><a class="page-link" href="#">1</a></li>
                    <li class="page-item"><a class="page-link" href="#">2</a></li>
                    <li class="page-item"><a class="page-link" href="#">3</a></li>
                    <li class="page-item">
                        <a class="page-link" href="#">Next</a>
                    </li>
                </ul>
            </nav>
        </div>
        <% } %>
    </div>
    
   

<!-- Footer -->
<footer class="bg-light mt-5 py-4 border-top">
    <div class="container">
        <div class="row">
            <div class="col-md-6">
                <h5>Order Support</h5>
                <p class="text-muted small mb-2">Need help with your orders? Contact our support team.</p>
                <p class="mb-0">
                    <i class="bi bi-envelope"></i> support@ecommerce.com<br>
                    <i class="bi bi-telephone"></i> +91 9876543210
                </p>
            </div>
            <div class="col-md-6 text-end">
                <p class="text-muted small mb-0">&copy; 2024 Ecommerce. All rights reserved.</p>
                <p class="small mb-0">
                    <a href="privacy.jsp" class="text-decoration-none me-3">Privacy Policy</a>
                    <a href="terms.jsp" class="text-decoration-none">Terms of Service</a>
                </p>
            </div>
        </div>
    </div>
</footer>

<!-- JavaScript Libraries -->
<script src="js/bootstrap.bundle.min.js"></script>
<script src="https://code.jquery.com/jquery-3.6.0.min.js"></script>
<script src="https://cdn.datatables.net/1.13.4/js/jquery.dataTables.min.js"></script>
<script src="https://cdn.datatables.net/1.13.4/js/dataTables.bootstrap5.min.js"></script>

<script>
// Initialize DataTable
$(document).ready(function() {
    console.log('Order history page loaded');
});

// Order actions
function trackOrder(orderId) {
    window.location.href = 'track-order.jsp?order_id=' + orderId;
}

function cancelOrder(orderId) {
    if(confirm('Are you sure you want to cancel Order #' + orderId + '?\n\nThis action cannot be undone.')) {
        fetch('CancelOrderServlet?order_id=' + orderId)
            .then(response => response.json())
            .then(data => {
                if(data.success) {
                    alert('Order #' + orderId + ' has been cancelled.');
                    location.reload();
                } else {
                    alert('Error: ' + data.message);
                }
            })
            .catch(error => {
                alert('Network error. Please try again.');
            });
    }
}

function rateOrder(orderId) {
    window.location.href = 'rate-order.jsp?order_id=' + orderId;
}

function reorder(orderId) {
    if(confirm('Add all items from Order #' + orderId + ' to your cart?')) {
        fetch('ReorderServlet?order_id=' + orderId)
            .then(response => response.json())
            .then(data => {
                if(data.success) {
                    alert('Items added to cart!');
                    window.location.href = 'cart.jsp';
                } else {
                    alert('Error: ' + data.message);
                }
            })
            .catch(error => {
                alert('Network error. Please try again.');
            });
    }
}

function printInvoice(orderId) {
    window.open('invoice.jsp?order_id=' + orderId, '_blank');
}

function printOrders() {
    window.print();
}

function showTrackModal() {
    const orderId = prompt('Enter your Order ID to track:');
    if(orderId && orderId.trim()) {
        trackOrder(orderId.trim());
    }
}

function showSpendingReport() {
    alert('Spending report feature coming soon!\n\nYou can view detailed analytics of your purchases.');
}

// Export orders
function exportOrders(format) {
    alert('Exporting orders as ' + format.toUpperCase() + '...\n\nFeature coming soon!');
}

// Quick filter buttons
function filterByStatus(status) {
    window.location.href = 'order-history.jsp?status=' + status;
}

// Search orders
function searchOrders() {
    const query = document.getElementById('searchInput').value;
    if(query.trim()) {
        window.location.href = 'order-history.jsp?search=' + encodeURIComponent(query);
    }
}

// Sort orders
function sortOrders(sortBy) {
    alert('Sort by ' + sortBy + ' - Feature coming soon!');
}
</script>
</body>
</html>