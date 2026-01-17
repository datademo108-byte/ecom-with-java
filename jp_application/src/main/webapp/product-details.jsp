<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<%@ page import="java.sql.*" %>
<%
    String productId = request.getParameter("id");
    if(productId == null || productId.trim().isEmpty()) {
        response.sendRedirect("products.jsp");
        return;
    }
    
    // Declare variables at page scope so they're accessible throughout
    String productName = "";
    String description = "";
    double price = 0;
    String category = "";
    int stock = 0;
    String image = "";
    boolean outOfStock = false;
    String imagePath = "https://via.placeholder.com/500x400?text=No+Image";
    
    Connection conn = null;
    PreparedStatement ps = null;
    ResultSet rs = null;
    
    try {
        Class.forName("com.mysql.cj.jdbc.Driver");
        conn = DriverManager.getConnection("jdbc:mysql://localhost:3306/ecom","root","Agr@hari567#");
        
        String sql = "SELECT * FROM products WHERE id = ?";
        ps = conn.prepareStatement(sql);
        ps.setInt(1, Integer.parseInt(productId));
        rs = ps.executeQuery();
        
        if(rs.next()) {
            productName = rs.getString("name");
            description = rs.getString("description");
            price = rs.getDouble("price");
            category = rs.getString("category");
            stock = rs.getInt("stock_quantity");
            image = rs.getString("image");
            outOfStock = stock <= 0;
            
            // Handle image path
            if(image == null || image.isEmpty() || image.equals("default.jpg")) {
                imagePath = "https://via.placeholder.com/500x400?text=No+Image";
            } else if(!image.startsWith("http")) {
                imagePath = "uploads/" + image;
            } else {
                imagePath = image;
            }
        }
    } catch(Exception e) {
        e.printStackTrace();
    } finally {
        try { if(rs != null) rs.close(); } catch(Exception e) {}
        try { if(ps != null) ps.close(); } catch(Exception e) {}
        try { if(conn != null) conn.close(); } catch(Exception e) {}
    }
%>
<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title><%= productName.isEmpty() ? "Product Details" : productName %> - Ecommerce</title>
<link href="css/bootstrap.min.css" rel="stylesheet">
<link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.8.1/font/bootstrap-icons.css">
<style>
    .product-image {
        max-height: 400px;
        object-fit: contain;
        width: 100%;
        border: 1px solid #dee2e6;
        border-radius: 10px;
        padding: 10px;
        background: #f8f9fa;
    }
    .thumbnail {
        width: 80px;
        height: 80px;
        object-fit: cover;
        cursor: pointer;
        border: 2px solid transparent;
        border-radius: 5px;
    }
    .thumbnail.active {
        border-color: #007bff;
    }
    .price-tag {
        font-size: 2rem;
        color: #28a745;
        font-weight: bold;
    }
    .specs-table td {
        padding: 8px 0;
        border-bottom: 1px solid #dee2e6;
    }
    .quantity-input {
        width: 80px;
        text-align: center;
    }
</style>
</head>
<body>
<jsp:include page="navbar.jsp"></jsp:include>

<div class="container mt-4">
    <% if(productName.isEmpty()) { %>
        <!-- Product not found -->
        <div class="alert alert-danger">
            <h4>Product Not Found</h4>
            <p>The product you're looking for doesn't exist or has been removed.</p>
            <a href="products.jsp" class="btn btn-primary">Browse Products</a>
        </div>
    <% } else { %>
        <!-- Breadcrumb -->
        <nav aria-label="breadcrumb" class="mb-4">
            <ol class="breadcrumb">
                <li class="breadcrumb-item"><a href="index.jsp">Home</a></li>
                <li class="breadcrumb-item"><a href="products.jsp">Products</a></li>
                <% if(category != null && !category.isEmpty()) { %>
                <li class="breadcrumb-item"><a href="products.jsp?category=<%= java.net.URLEncoder.encode(category, "UTF-8") %>"><%= category %></a></li>
                <% } %>
                <li class="breadcrumb-item active" aria-current="page"><%= productName %></li>
            </ol>
        </nav>
        
        <div class="row">
            <!-- Product Images -->
            <div class="col-md-6">
                <div class="mb-3">
                    <img id="mainImage" src="<%= imagePath %>" 
                         alt="<%= productName %>" 
                         class="product-image"
                         onerror="this.src='https://via.placeholder.com/500x400?text=Image+Error'">
                </div>
            </div>
            
            <!-- Product Details -->
            <div class="col-md-6">
                <div class="card">
                    <div class="card-body">
                        <% if(category != null && !category.isEmpty()) { %>
                        <span class="badge bg-primary mb-2"><%= category %></span>
                        <% } %>
                        
                        <% if(outOfStock) { %>
                        <span class="badge bg-danger mb-2">Out of Stock</span>
                        <% } %>
                        
                        <h1 class="card-title"><%= productName %></h1>
                        
                        <div class="mb-3">
                            <span class="price-tag">$<%= String.format("%.2f", price) %></span>
                            <% if(!outOfStock) { %>
                            <span class="text-success ms-3">
                                <i class="bi bi-check-circle"></i> 
                                <%= stock %> available
                            </span>
                            <% } else { %>
                            <span class="text-danger ms-3">
                                <i class="bi bi-x-circle"></i> 
                                Out of Stock
                            </span>
                            <% } %>
                        </div>
                        
                        <div class="mb-4">
                            <h5>Description</h5>
                            <p><%= description != null ? description : "No description available." %></p>
                        </div>
                        
                        <!-- Specifications Table -->
                        <div class="mb-4">
                            <h5>Product Details</h5>
                            <table class="table specs-table">
                                <tbody>
                                    <tr>
                                        <td><strong>Product ID</strong></td>
                                        <td>#<%= productId %></td>
                                    </tr>
                                    <tr>
                                        <td><strong>Category</strong></td>
                                        <td><%= category != null ? category : "Not specified" %></td>
                                    </tr>
                                    <tr>
                                        <td><strong>Availability</strong></td>
                                        <td>
                                            <% if(!outOfStock) { %>
                                            <span class="text-success">In Stock</span>
                                            <% } else { %>
                                            <span class="text-danger">Out of Stock</span>
                                            <% } %>
                                        </td>
                                    </tr>
                                    <tr>
                                        <td><strong>Shipping</strong></td>
                                        <td>Free shipping on orders over $50</td>
                                    </tr>
                                </tbody>
                            </table>
                        </div>
                        
                        <!-- Add to Cart Section -->
                        <div class="card bg-light">
                            <div class="card-body">
                                <% if(!outOfStock) { %>
                                <div class="row align-items-center">
                                    <div class="col-md-4 mb-2 mb-md-0">
                                        <div class="input-group">
                                            <button class="btn btn-outline-secondary" type="button" onclick="decreaseQuantity()">-</button>
                                            <input type="number" id="quantity" class="form-control quantity-input" value="1" min="1" max="<%= stock %>">
                                            <button class="btn btn-outline-secondary" type="button" onclick="increaseQuantity()">+</button>
                                        </div>
                                    </div>
                                    <div class="col-md-8">
                                        <button id="addToCartBtn" class="btn btn-success w-100" onclick="addToCart()">
                                            <i class="bi bi-cart-plus"></i> Add to Cart
                                        </button>
                                    </div>
                                </div>
                                <% } else { %>
                                <div class="text-center">
                                    <button class="btn btn-secondary" disabled>
                                        <i class="bi bi-x-circle"></i> Currently Unavailable
                                    </button>
                                    <p class="text-muted mt-2">Get notified when this product is back in stock</p>
                                    <div class="input-group mt-2">
                                        <input type="email" class="form-control" placeholder="Enter your email">
                                        <button class="btn btn-primary">Notify Me</button>
                                    </div>
                                </div>
                                <% } %>
                            </div>
                        </div>
                        
                        <!-- Action Buttons -->
                        <div class="mt-3 d-flex gap-2">
                            <button class="btn btn-outline-primary" onclick="shareProduct()">
                                <i class="bi bi-share"></i> Share
                            </button>
                            <button class="btn btn-outline-secondary" onclick="addToWishlist()">
                                <i class="bi bi-heart"></i> Add to Wishlist
                            </button>
                            <% 
                                Boolean isAdmin = (session != null) ? (Boolean) session.getAttribute("is_admin") : false;
                                if(Boolean.TRUE.equals(isAdmin)) {
                            %>
                            <a href="admin/edit-product.jsp?id=<%= productId %>" class="btn btn-outline-warning ms-auto">
                                <i class="bi bi-pencil"></i> Edit
                            </a>
                            <% } %>
                        </div>
                    </div>
                </div>
            </div>
        </div>
        
        <!-- Related Products -->
        <div class="mt-5">
            <h3>Related Products</h3>
            <div class="row">
                <%
                    // Get related products (same category)
                    if(category != null && !category.isEmpty()) {
                        Connection conn2 = null;
                        PreparedStatement relatedPs = null;
                        ResultSet relatedRs = null;
                        
                        try {
                            conn2 = DriverManager.getConnection("jdbc:mysql://localhost:3306/ecom","root","Agr@hari567#");
                            String relatedSql = "SELECT * FROM products WHERE category = ? AND id != ? LIMIT 4";
                            relatedPs = conn2.prepareStatement(relatedSql);
                            relatedPs.setString(1, category);
                            relatedPs.setInt(2, Integer.parseInt(productId));
                            relatedRs = relatedPs.executeQuery();
                            
                            while(relatedRs.next()) {
                                int relatedId = relatedRs.getInt("id");
                                String relatedName = relatedRs.getString("name");
                                double relatedPrice = relatedRs.getDouble("price");
                                String relatedImage = relatedRs.getString("image");
                                
                                String relatedImagePath = relatedImage;
                                if(relatedImage == null || relatedImage.isEmpty() || relatedImage.equals("default.jpg")) {
                                    relatedImagePath = "https://via.placeholder.com/200x150?text=No+Image";
                                } else if(!relatedImage.startsWith("http")) {
                                    relatedImagePath = "uploads/" + relatedImage;
                                } else {
                                    relatedImagePath = relatedImage;
                                }
                %>
                <div class="col-md-3 col-sm-6 mb-3">
                    <div class="card h-100">
                        <img src="<%= relatedImagePath %>" class="card-img-top" alt="<%= relatedName %>" style="height: 150px; object-fit: cover;">
                        <div class="card-body">
                            <h6 class="card-title"><%= relatedName %></h6>
                            <p class="card-text text-success fw-bold">$<%= String.format("%.2f", relatedPrice) %></p>
                            <a href="product-details.jsp?id=<%= relatedId %>" class="btn btn-sm btn-outline-primary w-100">
                                View Details
                            </a>
                        </div>
                    </div>
                </div>
                <%
                            }
                        } catch(Exception e) {
                            e.printStackTrace();
                        } finally {
                            try { if(relatedRs != null) relatedRs.close(); } catch(Exception e) {}
                            try { if(relatedPs != null) relatedPs.close(); } catch(Exception e) {}
                            try { if(conn2 != null) conn2.close(); } catch(Exception e) {}
                        }
                    }
                %>
            </div>
        </div>
    <% } %>
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
// Quantity functions
function decreaseQuantity() {
    const input = document.getElementById('quantity');
    if(parseInt(input.value) > 1) {
        input.value = parseInt(input.value) - 1;
    }
}

function increaseQuantity() {
    const input = document.getElementById('quantity');
    const maxStock = <%= stock %>;
    if(parseInt(input.value) < maxStock) {
        input.value = parseInt(input.value) + 1;
    }
}

// Change main image
function changeImage(src) {
    document.getElementById('mainImage').src = src;
    // Update active thumbnail
    document.querySelectorAll('.thumbnail').forEach(img => {
        img.classList.remove('active');
    });
    event.target.classList.add('active');
}

// Add to cart function
function addToCart() {
    const productId = <%= productId %>;
    const quantity = document.getElementById('quantity').value;
    
    // Check if user is logged in
    <%
        Boolean loggedIn = (session != null && session.getAttribute("loggedin") != null) ? 
                          (Boolean) session.getAttribute("loggedin") : false;
    %>
    
    <% if(loggedIn) { %>
        fetch('AddToCartServlet?product_id=' + productId + '&quantity=' + quantity)
            .then(response => response.text())
            .then(data => {
                alert('Product added to cart!');
                document.getElementById('addToCartBtn').innerHTML = 
                    '<i class="bi bi-check-circle"></i> Added to Cart';
                document.getElementById('addToCartBtn').classList.remove('btn-success');
                document.getElementById('addToCartBtn').classList.add('btn-secondary');
                document.getElementById('addToCartBtn').disabled = true;
            })
            .catch(error => {
                alert('Error adding to cart');
            });
    <% } else { %>
        if(confirm('You need to login to add items to cart. Go to login page?')) {
            window.location.href = 'login.jsp?redirect=product-details.jsp?id=<%= productId %>';
        }
    <% } %>
}

// Share product
function shareProduct() {
    if(navigator.share) {
        navigator.share({
            title: '<%= productName %>',
            text: 'Check out this product: <%= productName %>',
            url: window.location.href
        });
    } else {
        // Fallback: copy to clipboard
        navigator.clipboard.writeText(window.location.href);
        alert('Link copied to clipboard!');
    }
}

// Add to wishlist
function addToWishlist() {
    <%
        if(loggedIn) {
    %>
    alert('Added to wishlist!');
    <% } else { %>
    if(confirm('You need to login to add items to wishlist. Go to login page?')) {
        window.location.href = 'login.jsp?redirect=product-details.jsp?id=<%= productId %>';
    }
    <% } %>
}
</script>
</body>
</html>