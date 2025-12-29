<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<%@ page import="java.sql.*" %>
<%
    // Admin check
    HttpSession userSession = request.getSession(false);
    Boolean isAdmin = (userSession != null) ? (Boolean) userSession.getAttribute("is_admin") : false;
    
    if(!Boolean.TRUE.equals(isAdmin)) {
        response.sendRedirect("../login.jsp");
        return;
    }
    
    // Initialize counts
    int productCount = 0;
    int userCount = 0;
    int orderCount = 0;
    int lowStockCount = 0;
    
    Connection conn = null;
    Statement stmt = null;
    ResultSet rs = null;
    
    try {
        Class.forName("com.mysql.cj.jdbc.Driver");
        conn = DriverManager.getConnection("jdbc:mysql://localhost:3306/ecom","root","Agr@hari567#");
        stmt = conn.createStatement();
        
        // Get total products count
        rs = stmt.executeQuery("SELECT COUNT(*) as count FROM products");
        if(rs.next()) {
            productCount = rs.getInt("count");
        }
        
        // Get total users count
        rs = stmt.executeQuery("SELECT COUNT(*) as count FROM user");
        if(rs.next()) {
            userCount = rs.getInt("count");
        }
        
        // Get low stock products (stock < 10)
        rs = stmt.executeQuery("SELECT COUNT(*) as count FROM products WHERE stock_quantity < 10");
        if(rs.next()) {
            lowStockCount = rs.getInt("count");
        }
        
        // Note: You'll need to create an 'orders' table for this
        // rs = stmt.executeQuery("SELECT COUNT(*) as count FROM orders");
        // if(rs.next()) {
        //     orderCount = rs.getInt("count");
        // }
        
    } catch(Exception e) {
        e.printStackTrace();
    } finally {
        try { if(rs != null) rs.close(); } catch(Exception e) {}
        try { if(stmt != null) stmt.close(); } catch(Exception e) {}
        try { if(conn != null) conn.close(); } catch(Exception e) {}
    }
%>
<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>Admin Dashboard</title>
<link href="../css/bootstrap.min.css" rel="stylesheet">
<link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.8.1/font/bootstrap-icons.css">
<style>
    .sidebar {
        min-height: 100vh;
        background: #343a40;
        color: white;
    }
    .sidebar a {
        color: white;
        text-decoration: none;
        display: block;
        padding: 15px;
        border-bottom: 1px solid #495057;
    }
    .sidebar a:hover {
        background: #495057;
    }
    .stat-card {
        border-radius: 10px;
        transition: transform 0.3s;
    }
    .stat-card:hover {
        transform: translateY(-5px);
        box-shadow: 0 10px 20px rgba(0,0,0,0.1);
    }
    .stat-icon {
        font-size: 2.5rem;
        opacity: 0.8;
    }
    .recent-table th {
        background-color: #f8f9fa;
    }
</style>
</head>
<body>
<jsp:include page="navbar.jsp"></jsp:include>
<div class="container-fluid">
    <div class="row">
        <!-- Sidebar -->
        <div class="col-md-3 col-lg-2 p-0">
            <div class="sidebar">
                <h3 class="p-3">Admin Panel</h3>
                <a href="dashboard.jsp" style="background:#495057;">
                    <i class="bi bi-speedometer2"></i> Dashboard
                </a>
                <a href="add-product.jsp">
                    <i class="bi bi-plus-circle"></i> Add Product
                </a>
                <a href="view-products.jsp">
                    <i class="bi bi-list-ul"></i> View Products
                </a>
                <a href="users.jsp">
                    <i class="bi bi-people"></i> Users
                </a>
                <a href="orders.jsp">
                    <i class="bi bi-cart"></i> Orders
                </a>
                <a href="logout.jsp">
                    <i class="bi bi-box-arrow-left"></i> Logout
                </a>
            </div>
        </div>
        
        <!-- Main Content -->
        <div class="col-md-9 col-lg-10 p-0">
            <nav class="navbar navbar-light bg-light p-3 border-bottom">
                <div class="container-fluid">
                    <h4 class="mb-0">
                        <i class="bi bi-speedometer2 me-2"></i>
                        Admin Dashboard
                    </h4>
                    <div class="d-flex align-items-center">
                        <span class="me-3">
                            <i class="bi bi-person-circle"></i>
                            Welcome, <%= userSession.getAttribute("user_fname") %>
                        </span>
                        <span class="badge bg-danger">
                            <i class="bi bi-shield-check"></i> Admin
                        </span>
                    </div>
                </div>
            </nav>
            
            <div class="p-4">
                <!-- Welcome Message -->
                <div class="alert alert-info">
                    <h5><i class="bi bi-info-circle"></i> Quick Stats</h5>
                    <p class="mb-0">Manage your e-commerce store efficiently. Last login: <%= new java.util.Date() %></p>
                </div>
                
                <!-- Statistics Cards -->
                <div class="row mb-4">
                    <div class="col-md-3 mb-3">
                        <div class="card stat-card text-white bg-primary">
                            <div class="card-body">
                                <div class="d-flex justify-content-between align-items-center">
                                    <div>
                                        <h6 class="card-title mb-2">Total Products</h6>
                                        <h2 class="mb-0"><%= productCount %></h2>
                                        <small class="opacity-75">All products in store</small>
                                    </div>
                                    <div class="stat-icon">
                                        <i class="bi bi-box-seam"></i>
                                    </div>
                                </div>
                                <div class="mt-3">
                                    <a href="view-products.jsp" class="text-white text-decoration-none">
                                        <i class="bi bi-arrow-right-circle"></i> View All Products
                                    </a>
                                </div>
                            </div>
                        </div>
                    </div>
                    
                    <div class="col-md-3 mb-3">
                        <div class="card stat-card text-white bg-success">
                            <div class="card-body">
                                <div class="d-flex justify-content-between align-items-center">
                                    <div>
                                        <h6 class="card-title mb-2">Total Users</h6>
                                        <h2 class="mb-0"><%= userCount %></h2>
                                        <small class="opacity-75">Registered customers</small>
                                    </div>
                                    <div class="stat-icon">
                                        <i class="bi bi-people"></i>
                                    </div>
                                </div>
                                <div class="mt-3">
                                    <a href="users.jsp" class="text-white text-decoration-none">
                                        <i class="bi bi-arrow-right-circle"></i> Manage Users
                                    </a>
                                </div>
                            </div>
                        </div>
                    </div>
                    
                    <div class="col-md-3 mb-3">
                        <div class="card stat-card text-white bg-warning">
                            <div class="card-body">
                                <div class="d-flex justify-content-between align-items-center">
                                    <div>
                                        <h6 class="card-title mb-2">Low Stock</h6>
                                        <h2 class="mb-0"><%= lowStockCount %></h2>
                                        <small class="opacity-75">Products with stock &lt; 10</small>
                                    </div>
                                    <div class="stat-icon">
                                        <i class="bi bi-exclamation-triangle"></i>
                                    </div>
                                </div>
                                <div class="mt-3">
                                    <a href="view-products.jsp?filter=lowstock" class="text-white text-decoration-none">
                                        <i class="bi bi-arrow-right-circle"></i> Check Stock
                                    </a>
                                </div>
                            </div>
                        </div>
                    </div>
                    
                    <div class="col-md-3 mb-3">
                        <div class="card stat-card text-white bg-info">
                            <div class="card-body">
                                <div class="d-flex justify-content-between align-items-center">
                                    <div>
                                        <h6 class="card-title mb-2">Total Orders</h6>
                                        <h2 class="mb-0"><%= orderCount %></h2>
                                        <small class="opacity-75">All time orders</small>
                                    </div>
                                    <div class="stat-icon">
                                        <i class="bi bi-cart-check"></i>
                                    </div>
                                </div>
                                <div class="mt-3">
                                    <a href="orders.jsp" class="text-white text-decoration-none">
                                        <i class="bi bi-arrow-right-circle"></i> View Orders
                                    </a>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>
                
                <!-- Recent Products Section -->
                <div class="row">
                    <div class="col-md-8">
                        <div class="card">
                            <div class="card-header d-flex justify-content-between align-items-center">
                                <h5 class="mb-0">
                                    <i class="bi bi-clock-history me-2"></i>
                                    Recently Added Products
                                </h5>
                                <a href="add-product.jsp" class="btn btn-primary btn-sm">
                                    <i class="bi bi-plus-circle"></i> Add New
                                </a>
                            </div>
                            <div class="card-body">
                                <div class="table-responsive">
                                    <table class="table table-hover recent-table">
                                        <thead>
                                            <tr>
                                                <th>ID</th>
                                                <th>Product</th>
                                                <th>Price</th>
                                                <th>Stock</th>
                                                <th>Added</th>
                                                <th>Action</th>
                                            </tr>
                                        </thead>
                                        <tbody>
                                            <%
                                                try {
                                                    Class.forName("com.mysql.cj.jdbc.Driver");
                                                    conn = DriverManager.getConnection("jdbc:mysql://localhost:3306/ecom","root","Agr@hari567#");
                                                    stmt = conn.createStatement();
                                                    rs = stmt.executeQuery("SELECT * FROM products ORDER BY created_at DESC LIMIT 5");
                                                    
                                                    while(rs.next()) {
                                                        String stockClass = rs.getInt("stock_quantity") < 10 ? "text-danger fw-bold" : "text-success";
                                            %>
                                            <tr>
                                                <td><span class="badge bg-secondary">#<%= rs.getInt("id") %></span></td>
                                                <td>
                                                    <strong><%= rs.getString("name") %></strong>
                                                    <% if(rs.getString("category") != null && !rs.getString("category").isEmpty()) { %>
                                                        <br><small class="text-muted"><%= rs.getString("category") %></small>
                                                    <% } %>
                                                </td>
                                                <td>$<%= String.format("%.2f", rs.getDouble("price")) %></td>
                                                <td class="<%= stockClass %>">
                                                    <%= rs.getInt("stock_quantity") %>
                                                </td>
                                                <td>
                                                    <small>
                                                        <%= rs.getTimestamp("created_at").toString().substring(0, 10) %>
                                                    </small>
                                                </td>
                                                <td>
                                                    <a href="edit-product.jsp?id=<%= rs.getInt("id") %>" 
                                                       class="btn btn-sm btn-outline-primary" 
                                                       title="Edit">
                                                        <i class="bi bi-pencil"></i>
                                                    </a>
                                                </td>
                                            </tr>
                                            <%
                                                    }
                                                } catch(Exception e) {
                                                    e.printStackTrace();
                                            %>
                                            <tr>
                                                <td colspan="6" class="text-center text-muted">
                                                    <i class="bi bi-info-circle"></i> No products found
                                                </td>
                                            </tr>
                                            <%
                                                } finally {
                                                    try { if(rs != null) rs.close(); } catch(Exception e) {}
                                                    try { if(stmt != null) stmt.close(); } catch(Exception e) {}
                                                    try { if(conn != null) conn.close(); } catch(Exception e) {}
                                                }
                                            %>
                                        </tbody>
                                    </table>
                                </div>
                            </div>
                            <div class="card-footer text-center">
                                <a href="view-products.jsp" class="btn btn-link">
                                    <i class="bi bi-arrow-right"></i> View All Products
                                </a>
                            </div>
                        </div>
                    </div>
                    
                    <!-- Quick Actions Panel -->
                    <div class="col-md-4">
                        <div class="card">
                            <div class="card-header">
                                <h5 class="mb-0">
                                    <i class="bi bi-lightning me-2"></i>
                                    Quick Actions
                                </h5>
                            </div>
                            <div class="card-body">
                                <div class="list-group">
                                    <a href="add-product.jsp" class="list-group-item list-group-item-action d-flex align-items-center">
                                        <i class="bi bi-plus-circle fs-5 text-primary me-3"></i>
                                        <div>
                                            <h6 class="mb-1">Add New Product</h6>
                                            <small class="text-muted">Add a new product to your store</small>
                                        </div>
                                    </a>
                                    <a href="view-products.jsp" class="list-group-item list-group-item-action d-flex align-items-center">
                                        <i class="bi bi-list-check fs-5 text-success me-3"></i>
                                        <div>
                                            <h6 class="mb-1">Manage Products</h6>
                                            <small class="text-muted">Edit, delete or view all products</small>
                                        </div>
                                    </a>
                                    <% if(lowStockCount > 0) { %>
                                    <a href="view-products.jsp?filter=lowstock" class="list-group-item list-group-item-action d-flex align-items-center bg-warning bg-opacity-10">
                                        <i class="bi bi-exclamation-triangle fs-5 text-warning me-3"></i>
                                        <div>
                                            <h6 class="mb-1">Low Stock Alert</h6>
                                            <small class="text-muted"><%= lowStockCount %> products need restocking</small>
                                        </div>
                                    </a>
                                    <% } %>
                                    <a href="../logout.jsp" class="list-group-item list-group-item-action d-flex align-items-center">
                                        <i class="bi bi-box-arrow-right fs-5 text-danger me-3"></i>
                                        <div>
                                            <h6 class="mb-1">Logout</h6>
                                            <small class="text-muted">Logout from admin panel</small>
                                        </div>
                                    </a>
                                </div>
                            </div>
                        </div>
                        
                        <!-- System Info -->
                        <div class="card mt-3">
                            <div class="card-header">
                                <h5 class="mb-0">
                                    <i class="bi bi-info-circle me-2"></i>
                                    System Information
                                </h5>
                            </div>
                            <div class="card-body">
                                <ul class="list-group list-group-flush">
                                    <li class="list-group-item d-flex justify-content-between">
                                        <span>Server Time:</span>
                                        <span><%= new java.util.Date() %></span>
                                    </li>
                                    <li class="list-group-item d-flex justify-content-between">
                                        <span>Database:</span>
                                        <span>MySQL</span>
                                    </li>
                                    <li class="list-group-item d-flex justify-content-between">
                                        <span>Products:</span>
                                        <span class="badge bg-primary rounded-pill"><%= productCount %></span>
                                    </li>
                                    <li class="list-group-item d-flex justify-content-between">
                                        <span>Users:</span>
                                        <span class="badge bg-success rounded-pill"><%= userCount %></span>
                                    </li>
                                </ul>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </div>
</div>

<!-- Bootstrap JS -->
<script src="../js/bootstrap.bundle.min.js"></script>

<script>
// Auto refresh counts every 30 seconds
setTimeout(function() {
    window.location.reload();
}, 30000); // 30 seconds
</script>
</body>
</html>