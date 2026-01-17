<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<%@ page import="java.sql.*" %>
<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>Products - Ecommerce</title>
<link href="css/bootstrap.min.css" rel="stylesheet">
<link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.8.1/font/bootstrap-icons.css">
<style>
    .product-card {
        transition: transform 0.3s, box-shadow 0.3s;
        border: 1px solid #e0e0e0;
        border-radius: 10px;
        overflow: hidden;
    }
    .product-card:hover {
        transform: translateY(-5px);
        box-shadow: 0 10px 20px rgba(0,0,0,0.1);
    }
    .product-img {
        height: 200px;
        object-fit: cover;
        width: 100%;
    }
    .price {
        color: #28a745;
        font-weight: bold;
        font-size: 1.2rem;
    }
    .category-badge {
        position: absolute;
        top: 10px;
        left: 10px;
        z-index: 1;
    }
    .out-of-stock {
        position: absolute;
        top: 10px;
        right: 10px;
        z-index: 1;
    }
    .product-title {
        height: 48px;
        overflow: hidden;
        display: -webkit-box;
        -webkit-line-clamp: 2;
        -webkit-box-orient: vertical;
    }
</style>
</head>
<body>
<jsp:include page="navbar.jsp"></jsp:include>

<div class="container mt-5">
    <!-- Page Header -->
    <div class="row mb-4">
        <div class="col-md-8">
            <h1><i class="bi bi-shop"></i> Our Products</h1>
            <p class="text-muted">Browse our wide collection of quality products</p>
        </div>
        <div class="col-md-4">
            <!-- Search and Filter -->
            <form class="d-flex" method="get" action="products.jsp">
                <input type="text" name="search" class="form-control me-2" 
                       placeholder="Search products..." value="<%= request.getParameter("search") != null ? request.getParameter("search") : "" %>">
                <button class="btn btn-outline-primary" type="submit">
                    <i class="bi bi-search"></i>
                </button>
            </form>
        </div>
    </div>
    
    <!-- Category Filter -->
    <div class="row mb-4">
        <div class="col-12">
            <div class="btn-group" role="group">
                <a href="products.jsp" class="btn btn-outline-secondary">All</a>
                <%
                    Connection conn = null;
                    Statement stmt = null;
                    ResultSet rs = null;
                    
                    try {
                        Class.forName("com.mysql.cj.jdbc.Driver");
                        conn = DriverManager.getConnection("jdbc:mysql://localhost:3306/ecom","root","Agr@hari567#");
                        stmt = conn.createStatement();
                        
                        // Get distinct categories
                        rs = stmt.executeQuery("SELECT DISTINCT category FROM products WHERE category IS NOT NULL AND category != ''");
                        
                        while(rs.next()) {
                            String category = rs.getString("category");
                %>
                <a href="products.jsp?category=<%= java.net.URLEncoder.encode(category, "UTF-8") %>" 
                   class="btn btn-outline-secondary">
                    <%= category %>
                </a>
                <%
                        }
                    } catch(Exception e) {
                        e.printStackTrace();
                    } finally {
                        try { if(rs != null) rs.close(); } catch(Exception e) {}
                    }
                %>
            </div>
        </div>
    </div>
    
    <!-- Products Grid -->
    <div class="row">
        <%
            try {
                String searchQuery = request.getParameter("search");
                String categoryFilter = request.getParameter("category");
                String sql = "SELECT * FROM products WHERE 1=1";
                
                if(searchQuery != null && !searchQuery.trim().isEmpty()) {
                    sql += " AND (name LIKE '%" + searchQuery + "%' OR description LIKE '%" + searchQuery + "%')";
                }
                
                if(categoryFilter != null && !categoryFilter.trim().isEmpty()) {
                    sql += " AND category = '" + categoryFilter + "'";
                }
                
                sql += " ORDER BY created_at DESC";
                
                rs = stmt.executeQuery(sql);
                int productCount = 0;
                
                while(rs.next()) {
                    productCount++;
                    int productId = rs.getInt("id");
                    String productName = rs.getString("name");
                    String description = rs.getString("description");
                    double price = rs.getDouble("price");
                    String category = rs.getString("category");
                    int stock = rs.getInt("stock_quantity");
                    String image = rs.getString("image");
                    
                    // Handle image path
                    String imagePath = image;
                    if(image == null || image.isEmpty() || image.equals("default.jpg")) {
                        imagePath = "https://via.placeholder.com/300x200?text=No+Image";
                    } else if(!image.startsWith("http")) {
                        imagePath = "uploads/" + image;
                    }
                    
                    // Check if out of stock
                    boolean outOfStock = stock <= 0;
        %>
        <div class="col-md-4 col-lg-3 mb-4">
            <div class="card product-card h-100">
                <% if(category != null && !category.isEmpty()) { %>
                <span class="badge bg-primary category-badge"><%= category %></span>
                <% } %>
                
                <% if(outOfStock) { %>
                <span class="badge bg-danger out-of-stock">Out of Stock</span>
                <% } %>
                
                <img src="<%= imagePath %>" 
                     class="card-img-top product-img" 
                     alt="<%= productName %>"
                     onerror="this.src='https://via.placeholder.com/300x200?text=Image+Error'">
                
                <div class="card-body d-flex flex-column">
                    <h5 class="card-title product-title"><%= productName %></h5>
                    
                    <p class="card-text flex-grow-1">
                        <% 
                            if(description != null && description.length() > 60) {
                                out.print(description.substring(0, 60) + "...");
                            } else if(description != null) {
                                out.print(description);
                            }
                        %>
                    </p>
                    
                    <div class="d-flex justify-content-between align-items-center mt-auto">
                        <div class="price">$<%= String.format("%.2f", price) %></div>
                        <div class="stock">
                            <% if(!outOfStock) { %>
                            <small class="text-muted">
                                <i class="bi bi-check-circle text-success"></i> 
                                <%= stock %> in stock
                            </small>
                            <% } %>
                        </div>
                    </div>
                    
                    <div class="d-grid gap-2 mt-3">
                        <a href="product-details.jsp?id=<%= productId %>" class="btn btn-primary">
                            <i class="bi bi-eye"></i> View Details
                        </a>
                        <% if(!outOfStock) { %>
                        <button class="btn btn-success add-to-cart" data-id="<%= productId %>">
                            <i class="bi bi-cart-plus"></i> Add to Cart
                        </button>
                        <% } else { %>
                        <button class="btn btn-secondary" disabled>
                            <i class="bi bi-x-circle"></i> Out of Stock
                        </button>
                        <% } %>
                    </div>
                </div>
            </div>
        </div>
        <%
                }
                
                // If no products found
                if(productCount == 0) {
        %>
        <div class="col-12 text-center py-5">
            <i class="bi bi-search" style="font-size: 4rem; color: #ccc;"></i>
            <h3 class="mt-3">No Products Found</h3>
            <p class="text-muted">Try different search terms or check back later</p>
            <a href="products.jsp" class="btn btn-primary">View All Products</a>
        </div>
        <%
                }
                
            } catch(Exception e) {
                e.printStackTrace();
        %>
        <div class="col-12">
            <div class="alert alert-danger">Error loading products. Please try again later.</div>
        </div>
        <%
            } finally {
                try { if(rs != null) rs.close(); } catch(Exception e) {}
                try { if(stmt != null) stmt.close(); } catch(Exception e) {}
                try { if(conn != null) conn.close(); } catch(Exception e) {}
            }
        %>
    </div>
    
    <!-- Pagination (Optional) -->
    <!--
    <nav aria-label="Page navigation" class="mt-4">
        <ul class="pagination justify-content-center">
            <li class="page-item disabled"><a class="page-link" href="#">Previous</a></li>
            <li class="page-item active"><a class="page-link" href="#">1</a></li>
            <li class="page-item"><a class="page-link" href="#">2</a></li>
            <li class="page-item"><a class="page-link" href="#">3</a></li>
            <li class="page-item"><a class="page-link" href="#">Next</a></li>
        </ul>
    </nav>
    -->
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
document.querySelectorAll('.add-to-cart').forEach(button => {
    button.addEventListener('click', function () {
        const productId = this.getAttribute('data-id');

        <% Boolean loggedIn = (session != null && session.getAttribute("loggedin") != null); %>

        <% if (loggedIn) { %>
            fetch('AddToCartServlet?product_id=' + productId)
                .then(() => {
                    updateCartCount();   // 🔥 Update count
                })
                .catch(() => alert('Error adding to cart'));
        <% } else { %>
            if (confirm('You need to login first. Go to login page?')) {
                window.location.href = 'login.jsp';
            }
        <% } %>
    });
});

function updateCartCount() {
    fetch('CartCountServlet')
        .then(res => res.text())
        .then(count => {
            const badge = document.getElementById('cart-count');
            if (count > 0) {
                badge.innerText = count;
                badge.style.display = 'inline-block';
            } else {
                badge.style.display = 'none';
            }
        });
}

// Load count on page load
updateCartCount();
</script>

</body>
</html>