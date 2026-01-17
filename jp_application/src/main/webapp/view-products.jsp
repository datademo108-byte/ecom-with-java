<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<%@ page import="java.sql.*" %>
<%
    // Admin check
    Boolean isAdmin = (session != null) ? (Boolean) session.getAttribute("is_admin") : false;
    if(!Boolean.TRUE.equals(isAdmin)) {
        response.sendRedirect("../login.jsp");
        return;
    }
%>
<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>View Products</title>
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
    .product-img {
        width: 60px;
        height: 60px;
        object-fit: cover;
        border-radius: 5px;
        border: 1px solid #ddd;
    }
</style>
</head>
<body>
<jsp:include page="navbar.jsp"></jsp:include>
<div class="container-fluid mt-5">
    <div class="row">
        <!-- Sidebar -->
        <div class="col-md-3 col-lg-2 p-0">
            <div class="sidebar">
                <h3 class="p-3">Admin Panel</h3>
                <a href="dashboard.jsp"><i class="bi bi-speedometer2"></i> Dashboard</a>
                <a href="add-product.jsp"><i class="bi bi-plus-circle"></i> Add Product</a>
                <a href="view-products.jsp" style="background:#495057;"><i class="bi bi-list-ul"></i> View Products</a>
                <a href="logout.jsp"><i class="bi bi-box-arrow-left"></i> Logout</a>
            </div>
        </div>
        
        <!-- Main Content -->
        <div class="col-md-9 col-lg-10 p-4">
            <nav class="navbar navbar-light bg-light mb-4">
                <div class="container-fluid">
                    <h4 class="mb-0">Product Management</h4>
                    <div>
                        <span class="navbar-text me-3">
                            Welcome, <%= session.getAttribute("user_fname") %>
                        </span>
                        <a href="add-product.jsp" class="btn btn-primary btn-sm">
                            <i class="bi bi-plus-circle"></i> Add New
                        </a>
                    </div>
                </div>
            </nav>
            
            <div class="card">
                <div class="card-body">
                    <h5 class="card-title">All Products</h5>
                    
                    <div class="table-responsive">
                        <table class="table table-hover table-bordered">
                            <thead class="table-dark">
                                <tr>
                                    <th>ID</th>
                                    <th>Image</th>
                                    <th>Name</th>
                                    <th>Price</th>
                                    <th>Category</th>
                                    <th>Stock</th>
                                    <th>Description</th>
                                    <th>Actions</th>
                                </tr>
                            </thead>
                            <tbody>
                                <%
                                    Connection conn = null;
                                    Statement stmt = null;
                                    ResultSet rs = null;
                                    
                                    try {
                                        Class.forName("com.mysql.cj.jdbc.Driver");
                                        conn = DriverManager.getConnection("jdbc:mysql://localhost:3306/ecom","root","Agr@hari567#");
                                        
                                        stmt = conn.createStatement();
                                        rs = stmt.executeQuery("SELECT * FROM products ORDER BY id DESC");
                                        
                                        while(rs.next()) {
                                            String imagePath = rs.getString("image");
                                            // If image is default or empty, use placeholder
                                            if(imagePath == null || imagePath.isEmpty() || imagePath.equals("default.jpg")) {
                                                imagePath = "https://via.placeholder.com/60x60?text=No+Image";
                                            } else if(!imagePath.startsWith("http")) {
                                                // If it's a local file path, prepend with uploads folder
                                                imagePath = "../uploads/" + imagePath;
                                            }
                                %>
                                <tr>
                                    <td><%= rs.getInt("id") %></td>
                                    <td>
                                        <img src="<%= imagePath %>" 
                                             alt="<%= rs.getString("name") %>" 
                                             class="product-img"
                                             onerror="this.src='https://via.placeholder.com/60x60?text=Error'">
                                    </td>
                                    <td><strong><%= rs.getString("name") %></strong></td>
                                    <td>$<%= String.format("%.2f", rs.getDouble("price")) %></td>
                                    <td>
                                        <% 
                                            String category = rs.getString("category");
                                            if(category != null && !category.isEmpty()) {
                                        %>
                                            <span class="badge bg-info"><%= category %></span>
                                        <% } else { %>
                                            <span class="text-muted">None</span>
                                        <% } %>
                                    </td>
                                    <td>
                                        <span class="badge <%= rs.getInt("stock_quantity") > 0 ? "bg-success" : "bg-danger" %>">
                                            <%= rs.getInt("stock_quantity") %>
                                        </span>
                                    </td>
                                    <td>
                                        <% 
                                            String desc = rs.getString("description");
                                            if(desc != null && desc.length() > 50) {
                                                out.print(desc.substring(0, 50) + "...");
                                            } else if(desc != null) {
                                                out.print(desc);
                                            } else {
                                                out.print("<span class='text-muted'>No description</span>");
                                            }
                                        %>
                                    </td>
                                    <td>
                                        <div class="btn-group btn-group-sm" role="group">
                                            <a href="edit-product.jsp?id=<%= rs.getInt("id") %>" 
                                               class="btn btn-warning" 
                                               title="Edit">
                                                <i class="bi bi-pencil"></i>
                                            </a>
                                            <a href="DeleteProductServlet?id=<%= rs.getInt("id") %>" 
                                               class="btn btn-danger" 
                                               onclick="return confirm('Are you sure you want to delete <%= rs.getString("name") %>?')"
                                               title="Delete">
                                                <i class="bi bi-trash"></i>
                                            </a>
                                            <a href="#" 
                                               class="btn btn-info" 
                                               title="View Details"
                                               data-bs-toggle="modal" 
                                               data-bs-target="#productModal<%= rs.getInt("id") %>">
                                                <i class="bi bi-eye"></i>
                                            </a>
                                        </div>
                                        
                                        <!-- Product Details Modal -->
                                        <div class="modal fade" id="productModal<%= rs.getInt("id") %>" tabindex="-1">
                                            <div class="modal-dialog">
                                                <div class="modal-content">
                                                    <div class="modal-header">
                                                        <h5 class="modal-title"><%= rs.getString("name") %></h5>
                                                        <button type="button" class="btn-close" data-bs-dismiss="modal"></button>
                                                    </div>
                                                    <div class="modal-body">
                                                        <div class="text-center mb-3">
                                                            <img src="<%= imagePath %>" 
                                                                 alt="<%= rs.getString("name") %>" 
                                                                 class="img-fluid rounded"
                                                                 style="max-height: 200px;"
                                                                 onerror="this.src='https://via.placeholder.com/300x200?text=No+Image'">
                                                        </div>
                                                        <table class="table table-sm">
                                                            <tr><th>ID:</th><td><%= rs.getInt("id") %></td></tr>
                                                            <tr><th>Name:</th><td><%= rs.getString("name") %></td></tr>
                                                            <tr><th>Price:</th><td>$<%= String.format("%.2f", rs.getDouble("price")) %></td></tr>
                                                            <tr><th>Category:</th><td><%= category != null ? category : "None" %></td></tr>
                                                            <tr><th>Stock:</th><td><%= rs.getInt("stock_quantity") %></td></tr>
                                                            <tr><th>Description:</th><td><%= desc != null ? desc : "No description" %></td></tr>
                                                            <tr><th>Added:</th><td><%= rs.getTimestamp("created_at") %></td></tr>
                                                        </table>
                                                    </div>
                                                    <div class="modal-footer">
                                                        <a href="edit-product.jsp?id=<%= rs.getInt("id") %>" class="btn btn-warning">
                                                            <i class="bi bi-pencil"></i> Edit
                                                        </a>
                                                        <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">Close</button>
                                                    </div>
                                                </div>
                                            </div>
                                        </div>
                                    </td>
                                </tr>
                                <%
                                        }
                                    } catch(Exception e) {
                                        e.printStackTrace();
                                    } finally {
                                        try { if(rs != null) rs.close(); } catch(Exception e) {}
                                        try { if(stmt != null) stmt.close(); } catch(Exception e) {}
                                        try { if(conn != null) conn.close(); } catch(Exception e) {}
                                    }
                                %>
                            </tbody>
                        </table>
                    </div>
                    
                    <!-- No Products Message -->
                    <% 
                        try {
                            conn = DriverManager.getConnection("jdbc:mysql://localhost:3306/ecom","root","Agr@hari567#");
                            stmt = conn.createStatement();
                            rs = stmt.executeQuery("SELECT COUNT(*) as count FROM products");
                            if(rs.next() && rs.getInt("count") == 0) {
                    %>
                    <div class="text-center py-5">
                        <i class="bi bi-inbox" style="font-size: 4rem; color: #ccc;"></i>
                        <h4 class="mt-3">No Products Found</h4>
                        <p class="text-muted">Start by adding your first product</p>
                        <a href="add-product.jsp" class="btn btn-primary">
                            <i class="bi bi-plus-circle"></i> Add First Product
                        </a>
                    </div>
                    <%
                            }
                        } catch(Exception e) {}
                    %>
                </div>
            </div>
        </div>
    </div>
</div>

<!-- Bootstrap JS -->
<script src="../js/bootstrap.bundle.min.js"></script>

<script>
// Function to confirm delete
function confirmDelete(productName) {
    return confirm("Are you sure you want to delete '" + productName + "'? This action cannot be undone.");
}
</script>
</body>
</html>