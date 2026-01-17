<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<%@ page import="java.sql.*" %>
<%
    // Check if user is logged in
    Boolean loggedIn = (session != null && session.getAttribute("loggedin") != null) ? 
                      (Boolean) session.getAttribute("loggedin") : false;
    
    if(!loggedIn) {
        response.sendRedirect("login.jsp");
        return;
    }
    
    int userId = (Integer) session.getAttribute("user_id");
    
    // Initialize cart variables
    int cartItemCount = 0;
    double cartTotal = 0.0;
%>
<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>My Cart - Ecommerce</title>
<link href="css/bootstrap.min.css" rel="stylesheet">
<link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.8.1/font/bootstrap-icons.css">
<style>
    .cart-item {
        border-bottom: 1px solid #dee2e6;
        padding: 20px 0;
    }
    .cart-item:last-child {
        border-bottom: none;
    }
    .product-img {
        width: 100px;
        height: 100px;
        object-fit: cover;
        border-radius: 8px;
        border: 1px solid #dee2e6;
    }
    .quantity-input {
        width: 70px;
        text-align: center;
    }
    .remove-btn:hover {
        color: #dc3545 !important;
    }
    .summary-card {
        position: sticky;
        top: 20px;
    }
    .empty-cart {
        max-width: 400px;
        margin: 0 auto;
        text-align: center;
    }
</style>
</head>
<body>
<jsp:include page="navbar.jsp"></jsp:include>

<div class="container mt-4">
    <!-- Page Header -->
    <div class="row mb-4">
        <div class="col-12">
            <nav aria-label="breadcrumb">
                <ol class="breadcrumb">
                    <li class="breadcrumb-item"><a href="index.jsp">Home</a></li>
                    <li class="breadcrumb-item active" aria-current="page">Shopping Cart</li>
                </ol>
            </nav>
            
            <h2><i class="bi bi-cart3"></i> My Shopping Cart</h2>
            <p class="text-muted">Review your items and proceed to checkout</p>
        </div>
    </div>
    
    <%
        Connection conn = null;
        PreparedStatement ps = null;
        ResultSet rs = null;
        
        try {
            Class.forName("com.mysql.cj.jdbc.Driver");
            conn = DriverManager.getConnection("jdbc:mysql://localhost:3306/ecom","root","Agr@hari567#");
    %>
    
    <div class="row">
        <!-- Cart Items -->
        <div class="col-lg-8">
            <%
                // Get cart items with product details
                String cartSql = "SELECT c.*, p.name, p.price, p.image, p.stock_quantity " +
                                "FROM cart c " +
                                "JOIN products p ON c.product_id = p.id " +
                                "WHERE c.user_id = ? " +
                                "ORDER BY c.added_at DESC";
                ps = conn.prepareStatement(cartSql);
                ps.setInt(1, userId);
                rs = ps.executeQuery();
                
                boolean hasItems = false;
                
                while(rs.next()) {
                    hasItems = true;
                    cartItemCount++;
                    int cartId = rs.getInt("id");
                    int productId = rs.getInt("product_id");
                    String productName = rs.getString("name");
                    double price = rs.getDouble("price");
                    int quantity = rs.getInt("quantity");
                    int stock = rs.getInt("stock_quantity");
                    String image = rs.getString("image");
                    
                    double itemTotal = price * quantity;
                    cartTotal += itemTotal;
                    
                    // Handle image path
                    String imagePath = image;
                    if(image == null || image.isEmpty() || image.equals("default.jpg")) {
                        imagePath = "https://via.placeholder.com/100x100?text=No+Image";
                    } else if(!image.startsWith("http")) {
                        imagePath = "uploads/" + image;
                    }
            %>
            <div class="card mb-3">
                <div class="card-body">
                    <div class="row align-items-center">
                        <!-- Product Image -->
                        <div class="col-md-2">
                            <img src="<%= imagePath %>" alt="<%= productName %>" class="product-img"
                                 onerror="this.src='https://via.placeholder.com/100x100?text=Image+Error'">
                        </div>
                        
                        <!-- Product Details -->
                        <div class="col-md-5">
                            <h5 class="mb-1"><%= productName %></h5>
                            <p class="text-muted mb-1">Product ID: #<%= productId %></p>
                            <p class="mb-2">
                                <span class="price fw-bold">$<%= String.format("%.2f", price) %></span>
                                <span class="text-muted"> each</span>
                            </p>
                            <div class="stock-info">
                                <% if(stock >= quantity) { %>
                                    <span class="text-success">
                                        <i class="bi bi-check-circle"></i> In Stock
                                    </span>
                                <% } else { %>
                                    <span class="text-danger">
                                        <i class="bi bi-exclamation-triangle"></i> Only <%= stock %> left
                                    </span>
                                <% } %>
                            </div>
                        </div>
                        
                        <!-- Quantity Controls -->
                        <div class="col-md-3">
                            <div class="input-group">
                                <button class="btn btn-outline-secondary" type="button" 
                                        onclick="updateQuantity(<%= cartId %>, 'decrease')">-</button>
                                <input type="number" id="qty-<%= cartId %>" 
                                       class="form-control quantity-input" 
                                       value="<%= quantity %>" min="1" max="<%= stock %>"
                                       onchange="updateQuantity(<%= cartId %>, this.value)">
                                <button class="btn btn-outline-secondary" type="button" 
                                        onclick="updateQuantity(<%= cartId %>, 'increase')">+</button>
                            </div>
                            <div class="mt-2">
                                <a href="#" class="text-danger remove-btn text-decoration-none" 
                                   onclick="removeFromCart(<%= cartId %>, '<%= productName %>')">
                                    <i class="bi bi-trash"></i> Remove
                                </a>
                            </div>
                        </div>
                        
                        <!-- Item Total -->
                        <div class="col-md-2 text-end">
                            <div class="fw-bold">$<%= String.format("%.2f", itemTotal) %></div>
                            <small class="text-muted">Total</small>
                        </div>
                    </div>
                </div>
            </div>
            <%
                }
                
                if(!hasItems) {
            %>
            <!-- Empty Cart -->
            <div class="card">
                <div class="card-body text-center py-5">
                    <div class="empty-cart">
                        <i class="bi bi-cart-x" style="font-size: 4rem; color: #ccc;"></i>
                        <h3 class="mt-3">Your cart is empty</h3>
                        <p class="text-muted">Looks like you haven't added any items to your cart yet.</p>
                        <a href="products.jsp" class="btn btn-primary">
                            <i class="bi bi-shop"></i> Start Shopping
                        </a>
                    </div>
                </div>
            </div>
            <%
                }
            %>
            
            <!-- Continue Shopping -->
            <% if(hasItems) { %>
            <div class="mt-4">
                <a href="products.jsp" class="btn btn-outline-primary">
                    <i class="bi bi-arrow-left"></i> Continue Shopping
                </a>
            </div>
            <% } %>
        </div>
        
        <!-- Order Summary -->
        <% if(hasItems) { %>
        <div class="col-lg-4">
            <div class="card summary-card">
                <div class="card-body">
                    <h5 class="card-title">Order Summary</h5>
                    
                    <!-- Summary Details -->
                    <div class="mb-3">
                        <div class="d-flex justify-content-between mb-2">
                            <span>Subtotal (<%= cartItemCount %> items)</span>
                            <span>$<%= String.format("%.2f", cartTotal) %></span>
                        </div>
                        
                        <div class="d-flex justify-content-between mb-2">
                            <span>Shipping</span>
                            <span class="text-success">FREE</span>
                        </div>
                        
                        <div class="d-flex justify-content-between mb-2">
                            <span>Tax</span>
                            <span>$<%= String.format("%.2f", cartTotal * 0.1) %></span>
                        </div>
                        
                        <hr>
                        
                        <div class="d-flex justify-content-between fw-bold fs-5">
                            <span>Total</span>
                            <span>$<%= String.format("%.2f", cartTotal + (cartTotal * 0.1)) %></span>
                        </div>
                        
                        <small class="text-muted">Including $<%= String.format("%.2f", cartTotal * 0.1) %> in taxes</small>
                    </div>
                    
                    <!-- Checkout Button -->
                    <button class="btn btn-success w-100 mb-3" onclick="checkout()">
                        <i class="bi bi-lock"></i> Proceed to Checkout
                    </button>
                    
                    <!-- Payment Methods -->
                    <div class="text-center mb-3">
                        <small class="text-muted">We accept</small><br>
                        <i class="bi bi-credit-card fs-4 mx-2"></i>
                        <i class="bi bi-paypal fs-4 mx-2 text-primary"></i>
                        <i class="bi bi-google fs-4 mx-2"></i>
                    </div>
                    
                    <!-- Security Info -->
                    <div class="alert alert-light border">
                        <i class="bi bi-shield-check text-success"></i>
                        <small>
                            Your payment is secure and encrypted. We don't store your credit card details.
                        </small>
                    </div>
                </div>
            </div>
            
            <!-- Promo Code -->
            <div class="card mt-3">
                <div class="card-body">
                    <h6 class="card-title">Have a Promo Code?</h6>
                    <div class="input-group">
                        <input type="text" class="form-control" placeholder="Enter code" id="promoCode">
                        <button class="btn btn-outline-secondary" type="button" onclick="applyPromo()">
                            Apply
                        </button>
                    </div>
                </div>
            </div>
        </div>
        <% } %>
    </div>
    
    <%
        } catch(Exception e) {
            e.printStackTrace();
    %>
    <div class="alert alert-danger">
        <h4>Error Loading Cart</h4>
        <p>An error occurred while loading your cart. Please try again later.</p>
        <a href="products.jsp" class="btn btn-primary">Continue Shopping</a>
    </div>
    <%
        } finally {
            try { if(rs != null) rs.close(); } catch(Exception e) {}
            try { if(ps != null) ps.close(); } catch(Exception e) {}
            try { if(conn != null) conn.close(); } catch(Exception e) {}
        }
    %>
</div>

<!-- Footer -->
<footer class="bg-light mt-5 py-4 border-top">
    <div class="container">
        <div class="row">
            <div class="col-md-6">
                <h5>Ecommerce.org</h5>
                <p class="text-muted">Your one-stop shop for quality products</p>
            </div>
            <div class="col-md-6 text-end">
                <p>&copy; 2024 Ecommerce.org. All rights reserved.</p>
            </div>
        </div>
    </div>
</footer>

<script src="js/bootstrap.bundle.min.js"></script>
<script>
// Update quantity function
function updateQuantity(cartId, action) {
    const input = document.getElementById('qty-' + cartId);
    let newQuantity = parseInt(input.value);
    
    if(action === 'increase') {
        newQuantity += 1;
    } else if(action === 'decrease') {
        newQuantity = Math.max(1, newQuantity - 1);
    } else {
        newQuantity = parseInt(action);
        if(isNaN(newQuantity) || newQuantity < 1) {
            newQuantity = 1;
        }
    }
    
    // Update input value
    input.value = newQuantity;
    
    // Send update to server
    fetch('UpdateCartServlet?cart_id=' + cartId + '&quantity=' + newQuantity)
        .then(response => response.text())
        .then(data => {
            // Reload page to update totals
            window.location.reload();
        })
        .catch(error => {
            alert('Error updating quantity');
            window.location.reload();
        });
}

// Remove item from cart
function removeFromCart(cartId, productName) {
    if(confirm('Remove "' + productName + '" from cart?')) {
        fetch('RemoveFromCartServlet?cart_id=' + cartId)
            .then(response => response.text())
            .then(data => {
                window.location.reload();
            })
            .catch(error => {
                alert('Error removing item');
                window.location.reload();
            });
    }
}

// Checkout function
function checkout() {
    // Check if cart has items
    if(<%= cartItemCount %> === 0) {
        alert('Your cart is empty!');
        return;
    }
    
    // Redirect to checkout page (you'll need to create this)
    window.location.href = 'checkout.jsp';
}

// Apply promo code
function applyPromo() {
    const promoCode = document.getElementById('promoCode').value;
    if(!promoCode.trim()) {
        alert('Please enter a promo code');
        return;
    }
    
    // You can implement promo code validation here
    alert('Promo code applied! (This is a demo - no actual discount applied)');
}

//In cart.jsp, update the checkout function:
function checkout() {
    // Check if cart has items
    if(<%= cartItemCount %> === 0) {
        alert('Your cart is empty!');
        return;
    }
    
    // Redirect to checkout page
    window.location.href = 'checkout.jsp';
}
</script>
</body>
</html>