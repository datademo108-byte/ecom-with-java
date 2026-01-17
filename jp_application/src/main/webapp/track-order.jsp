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
    String orderIdParam = request.getParameter("order_id");
    int orderId = 0;
    
    if(orderIdParam != null && !orderIdParam.isEmpty()) {
        try {
            orderId = Integer.parseInt(orderIdParam);
        } catch(NumberFormatException e) {
            response.sendRedirect("order-history.jsp");
            return;
        }
    } else {
        response.sendRedirect("order-history.jsp");
        return;
    }
%>
<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>Track Order - Ecommerce</title>
<link href="css/bootstrap.min.css" rel="stylesheet">
<link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.8.1/font/bootstrap-icons.css">
<style>
    .timeline {
        position: relative;
        padding: 20px 0;
    }
    .timeline::before {
        content: '';
        position: absolute;
        left: 50%;
        transform: translateX(-50%);
        width: 2px;
        height: 100%;
        background: #dee2e6;
    }
    .timeline-item {
        position: relative;
        margin-bottom: 30px;
    }
    .timeline-item.completed .timeline-icon {
        background: #28a745;
        color: white;
    }
    .timeline-item.current .timeline-icon {
        background: #007bff;
        color: white;
        animation: pulse 2s infinite;
    }
    .timeline-item.pending .timeline-icon {
        background: #6c757d;
        color: white;
    }
    .timeline-icon {
        position: absolute;
        left: 50%;
        transform: translateX(-50%);
        width: 40px;
        height: 40px;
        border-radius: 50%;
        display: flex;
        align-items: center;
        justify-content: center;
        z-index: 1;
    }
    .timeline-content {
        width: 45%;
        padding: 20px;
        background: #f8f9fa;
        border-radius: 10px;
        position: relative;
    }
    .timeline-item:nth-child(odd) .timeline-content {
        margin-left: 0;
        margin-right: auto;
        text-align: right;
    }
    .timeline-item:nth-child(even) .timeline-content {
        margin-left: auto;
        margin-right: 0;
    }
    .timeline-item:nth-child(odd) .timeline-content::after {
        content: '';
        position: absolute;
        right: -10px;
        top: 20px;
        width: 0;
        height: 0;
        border-style: solid;
        border-width: 10px 0 10px 10px;
        border-color: transparent transparent transparent #f8f9fa;
    }
    .timeline-item:nth-child(even) .timeline-content::after {
        content: '';
        position: absolute;
        left: -10px;
        top: 20px;
        width: 0;
        height: 0;
        border-style: solid;
        border-width: 10px 10px 10px 0;
        border-color: transparent #f8f9fa transparent transparent;
    }
    @keyframes pulse {
        0% { box-shadow: 0 0 0 0 rgba(0, 123, 255, 0.7); }
        70% { box-shadow: 0 0 0 10px rgba(0, 123, 255, 0); }
        100% { box-shadow: 0 0 0 0 rgba(0, 123, 255, 0); }
    }
    .tracking-info {
        background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
        color: white;
        border-radius: 15px;
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
            <li class="breadcrumb-item"><a href="order-history.jsp">Order History</a></li>
            <li class="breadcrumb-item active">Track Order</li>
        </ol>
    </nav>
    
    <%
        Connection conn = null;
        PreparedStatement ps = null;
        ResultSet rs = null;
        String orderStatus = "";
        String estimatedDelivery = "";
        String trackingNumber = "TRK" + orderId + userId;
        String shippingAddress = "";
        String customerName = "";
        double orderTotal = 0;
        
        try {
            Class.forName("com.mysql.cj.jdbc.Driver");
            conn = DriverManager.getConnection("jdbc:mysql://localhost:3306/ecom","root","Agr@hari567#");
            
            // Get order details
            String sql = "SELECT o.*, a.address, a.city, a.state, a.zip_code, " +
                        "u.first_name, u.last_name " +
                        "FROM orders o " +
                        "LEFT JOIN addresses a ON o.address_id = a.id " +
                        "LEFT JOIN users u ON o.user_id = u.id " +
                        "WHERE o.id = ? AND o.user_id = ?";
            ps = conn.prepareStatement(sql);
            ps.setInt(1, orderId);
            ps.setInt(2, userId);
            rs = ps.executeQuery();
            
            if(rs.next()) {
                orderStatus = rs.getString("status");
                orderTotal = rs.getDouble("total_amount");
                customerName = rs.getString("first_name") + " " + rs.getString("last_name");
                
                // Build address
                String address = rs.getString("address");
                String city = rs.getString("city");
                String state = rs.getString("state");
                String zip = rs.getString("zip_code");
                if(address != null) {
                    shippingAddress = address + ", " + city + ", " + state + " - " + zip;
                }
                
                // Calculate estimated delivery (3 days from order date)
                java.sql.Timestamp orderDate = rs.getTimestamp("order_date");
                if(orderDate != null) {
                    Calendar cal = Calendar.getInstance();
                    cal.setTime(orderDate);
                    cal.add(Calendar.DAY_OF_MONTH, 3);
                    SimpleDateFormat sdf = new SimpleDateFormat("dd MMM yyyy");
                    estimatedDelivery = sdf.format(cal.getTime());
                }
            } else {
                response.sendRedirect("order-history.jsp");
                return;
            }
            
        } catch(Exception e) {
            e.printStackTrace();
        } finally {
            try { if(rs != null) rs.close(); } catch(Exception e) {}
            try { if(ps != null) ps.close(); } catch(Exception e) {}
            try { if(conn != null) conn.close(); } catch(Exception e) {}
        }
    %>
    
    <!-- Order Tracking Header -->
    <div class="card tracking-info mb-4">
        <div class="card-body">
            <div class="row align-items-center">
                <div class="col-md-8">
                    <h3 class="card-title text-white mb-1">Order #<%= orderId %></h3>
                    <p class="text-white-50 mb-2">
                        <i class="bi bi-person"></i> <%= customerName %> • 
                        <i class="bi bi-calendar"></i> Estimated Delivery: <%= estimatedDelivery %>
                    </p>
                    <div class="d-flex align-items-center">
                        <div class="me-3">
                            <h5 class="text-white mb-0">Tracking Number:</h5>
                            <code class="text-white"><%= trackingNumber %></code>
                        </div>
                        <div>
                            <button class="btn btn-light btn-sm" onclick="copyTrackingNumber()">
                                <i class="bi bi-clipboard"></i> Copy
                            </button>
                        </div>
                    </div>
                </div>
                <div class="col-md-4 text-end">
                    <h2 class="text-white mb-0">₹<%= String.format("%.2f", orderTotal) %></h2>
                    <span class="badge bg-light text-dark fs-6">
                        <%= orderStatus.substring(0, 1).toUpperCase() + orderStatus.substring(1) %>
                    </span>
                </div>
            </div>
        </div>
    </div>
    
    <!-- Tracking Timeline -->
    <div class="card mb-4">
        <div class="card-header bg-light">
            <h5 class="mb-0"><i class="bi bi-truck"></i> Order Tracking Timeline</h5>
        </div>
        <div class="card-body">
            <div class="timeline">
                <!-- Step 1: Order Placed -->
                <div class="timeline-item completed">
                    <div class="timeline-icon">
                        <i class="bi bi-cart-check"></i>
                    </div>
                    <div class="timeline-content">
                        <h6>Order Placed</h6>
                        <p class="text-muted small mb-2">Your order has been confirmed</p>
                        <span class="badge bg-success">Completed</span>
                    </div>
                </div>
                
                <!-- Step 2: Order Confirmed -->
                <div class="timeline-item <%= orderStatus.equals("pending") ? "current" : 
                                               orderStatus.equals("confirmed") || 
                                               orderStatus.equals("processing") || 
                                               orderStatus.equals("shipped") || 
                                               orderStatus.equals("delivered") ? "completed" : "pending" %>">
                    <div class="timeline-icon">
                        <i class="bi bi-check-circle"></i>
                    </div>
                    <div class="timeline-content">
                        <h6>Order Confirmed</h6>
                        <p class="text-muted small mb-2">Seller has processed your order</p>
                        <% if(orderStatus.equals("pending")) { %>
                        <span class="badge bg-primary">Current</span>
                        <% } else if(orderStatus.equals("confirmed") || orderStatus.equals("processing") || 
                                   orderStatus.equals("shipped") || orderStatus.equals("delivered")) { %>
                        <span class="badge bg-success">Completed</span>
                        <% } else { %>
                        <span class="badge bg-secondary">Pending</span>
                        <% } %>
                    </div>
                </div>
                
                <!-- Step 3: Processing -->
                <div class="timeline-item <%= orderStatus.equals("confirmed") ? "current" : 
                                               orderStatus.equals("processing") || 
                                               orderStatus.equals("shipped") || 
                                               orderStatus.equals("delivered") ? "completed" : "pending" %>">
                    <div class="timeline-icon">
                        <i class="bi bi-gear"></i>
                    </div>
                    <div class="timeline-content">
                        <h6>Processing</h6>
                        <p class="text-muted small mb-2">Preparing your shipment</p>
                        <% if(orderStatus.equals("confirmed")) { %>
                        <span class="badge bg-primary">Current</span>
                        <% } else if(orderStatus.equals("processing") || orderStatus.equals("shipped") || 
                                   orderStatus.equals("delivered")) { %>
                        <span class="badge bg-success">Completed</span>
                        <% } else { %>
                        <span class="badge bg-secondary">Pending</span>
                        <% } %>
                    </div>
                </div>
                
                <!-- Step 4: Shipped -->
                <div class="timeline-item <%= orderStatus.equals("shipped") ? "current" : 
                                               orderStatus.equals("delivered") ? "completed" : "pending" %>">
                    <div class="timeline-icon">
                        <i class="bi bi-truck"></i>
                    </div>
                    <div class="timeline-content">
                        <h6>Shipped</h6>
                        <p class="text-muted small mb-2">Your order is on the way</p>
                        <% if(orderStatus.equals("shipped")) { %>
                        <span class="badge bg-primary">Current</span>
                        <% } else if(orderStatus.equals("delivered")) { %>
                        <span class="badge bg-success">Completed</span>
                        <% } else { %>
                        <span class="badge bg-secondary">Pending</span>
                        <% } %>
                    </div>
                </div>
                
                <!-- Step 5: Delivered -->
                <div class="timeline-item <%= orderStatus.equals("delivered") ? "current" : "pending" %>">
                    <div class="timeline-icon">
                        <i class="bi bi-house-check"></i>
                    </div>
                    <div class="timeline-content">
                        <h6>Delivered</h6>
                        <p class="text-muted small mb-2">Order delivered successfully</p>
                        <% if(orderStatus.equals("delivered")) { %>
                        <span class="badge bg-success">Completed</span>
                        <% } else { %>
                        <span class="badge bg-secondary">Pending</span>
                        <% } %>
                    </div>
                </div>
            </div>
        </div>
    </div>
    
    <!-- Order Details & Shipping Info -->
    <div class="row">
        <!-- Shipping Information -->
        <div class="col-md-6">
            <div class="card h-100">
                <div class="card-header bg-light">
                    <h5 class="mb-0"><i class="bi bi-geo-alt"></i> Shipping Information</h5>
                </div>
                <div class="card-body">
                    <% if(!shippingAddress.isEmpty()) { %>
                    <h6>Delivery Address</h6>
                    <p class="text-muted"><%= shippingAddress %></p>
                    <% } %>
                    
                    <hr>
                    
                    <h6>Delivery Partner</h6>
                    <div class="d-flex align-items-center">
                        <img src="https://via.placeholder.com/40" alt="Shipping Partner" class="rounded me-3">
                        <div>
                            <h6 class="mb-0">FastExpress Logistics</h6>
                            <p class="text-muted small mb-0">Estimated delivery: <%= estimatedDelivery %></p>
                        </div>
                    </div>
                    
                    <div class="mt-3">
                        <button class="btn btn-outline-primary btn-sm">
                            <i class="bi bi-headset"></i> Contact Courier
                        </button>
                        <button class="btn btn-outline-secondary btn-sm" onclick="updateDeliveryAddress()">
                            <i class="bi bi-pencil"></i> Update Address
                        </button>
                    </div>
                </div>
            </div>
        </div>
        
        <!-- Order Summary -->
        <div class="col-md-6">
            <div class="card h-100">
                <div class="card-header bg-light">
                    <h5 class="mb-0"><i class="bi bi-info-circle"></i> Order Summary</h5>
                </div>
                <div class="card-body">
                    <div class="d-flex justify-content-between mb-2">
                        <span>Order Status:</span>
                        <strong><%= orderStatus.substring(0, 1).toUpperCase() + orderStatus.substring(1) %></strong>
                    </div>
                    <div class="d-flex justify-content-between mb-2">
                        <span>Payment Status:</span>
                        <strong class="text-success">Paid</strong>
                    </div>
                    <div class="d-flex justify-content-between mb-2">
                        <span>Payment Method:</span>
                        <strong>Online Payment</strong>
                    </div>
                    <div class="d-flex justify-content-between mb-2">
                        <span>Order Date:</span>
                        <strong><%= estimatedDelivery %></strong>
                    </div>
                    <div class="d-flex justify-content-between mb-2">
                        <span>Tracking Number:</span>
                        <strong><%= trackingNumber %></strong>
                    </div>
                    
                    <hr>
                    
                    <h6>Need Help?</h6>
                    <p class="text-muted small mb-3">Contact us for any order-related queries</p>
                    
                    <div class="d-grid gap-2">
                        <button class="btn btn-outline-primary" onclick="contactSupport()">
                            <i class="bi bi-envelope"></i> Contact Support
                        </button>
                        <button class="btn btn-outline-warning" onclick="requestCallback()">
                            <i class="bi bi-telephone"></i> Request Callback
                        </button>
                    </div>
                </div>
            </div>
        </div>
    </div>
    
    <!-- Action Buttons -->
    <div class="mt-4 text-center">
        <button class="btn btn-primary me-2" onclick="window.print()">
            <i class="bi bi-printer"></i> Print Tracking Details
        </button>
        <button class="btn btn-outline-primary me-2" onclick="shareTracking()">
            <i class="bi bi-share"></i> Share Tracking
        </button>
        <a href="order-history.jsp" class="btn btn-outline-secondary">
            <i class="bi bi-arrow-left"></i> Back to Orders
        </a>
    </div>
</div>

<!-- Footer -->
<%-- <jsp:include page="footer.jsp"></jsp:include> --%>

<script src="js/bootstrap.bundle.min.js"></script>
<script>
function copyTrackingNumber() {
    const trackingNum = '<%= trackingNumber %>';
    navigator.clipboard.writeText(trackingNum).then(() => {
        alert('Tracking number copied to clipboard!');
    });
}

function contactSupport() {
    alert('Redirecting to support...');
    window.location.href = 'contact.jsp?order_id=<%= orderId %>';
}

function requestCallback() {
    alert('Callback requested! Our executive will call you within 30 minutes.');
}

function shareTracking() {
    if(navigator.share) {
        navigator.share({
            title: 'Track Order #<%= orderId %>',
            text: 'Track my order on Ecommerce Store',
            url: window.location.href
        });
    } else {
        copyTrackingNumber();
        alert('Tracking link copied! Share it with others.');
    }
}

function updateDeliveryAddress() {
    alert('Address update feature coming soon!');
}

// Auto-refresh tracking every 30 seconds
setTimeout(() => {
    console.log('Refreshing tracking data...');
    // You could add AJAX call here to update tracking status
}, 30000);
</script>
</body>
</html>