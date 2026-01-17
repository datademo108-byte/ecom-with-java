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
    
    String productId = request.getParameter("id");
    if(productId == null || productId.trim().isEmpty()) {
        response.sendRedirect("view-products.jsp");
        return;
    }
%>
<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>Edit Product</title>
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
    .product-preview {
        max-width: 200px;
        max-height: 200px;
        object-fit: contain;
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
                <a href="dashboard.jsp"><i class="bi bi-speedometer2"></i> Dashboard</a>
                <a href="add-product.jsp"><i class="bi bi-plus-circle"></i> Add Product</a>
                <a href="view-products.jsp"><i class="bi bi-list-ul"></i> View Products</a>
                <a href="../logout.jsp"><i class="bi bi-box-arrow-left"></i> Logout</a>
            </div>
        </div>
        
        <!-- Main Content -->
        <div class="col-md-9 col-lg-10 p-4">
            <nav class="navbar navbar-light bg-light mb-4">
                <div class="container-fluid">
                    <h4 class="mb-0">Edit Product</h4>
                    <div>
                        <span class="navbar-text me-3">
                            Welcome, <%= session.getAttribute("user_fname") %>
                        </span>
                        <a href="view-products.jsp" class="btn btn-secondary btn-sm">
                            <i class="bi bi-arrow-left"></i> Back to Products
                        </a>
                    </div>
                </div>
            </nav>
            
            <%
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
                        String currentImage = rs.getString("image");
                        String imagePreview = currentImage;
                        if(currentImage == null || currentImage.isEmpty() || currentImage.equals("default.jpg")) {
                            imagePreview = "https://via.placeholder.com/200x200?text=No+Image";
                        } else if(!currentImage.startsWith("http")) {
                            imagePreview = "../uploads/" + currentImage;
                        }
            %>
            
            <div class="card">
                <div class="card-body">
                    <form action="UpdateProductServlet" method="post" class="row g-3">
                        <input type="hidden" name="id" value="<%= rs.getInt("id") %>">
                        
                        <div class="col-md-8">
                            <div class="row">
                                <div class="col-md-6">
                                    <div class="mb-3">
                                        <label class="form-label">Product Name *</label>
                                        <input type="text" name="name" class="form-control" 
                                               value="<%= rs.getString("name") %>" required>
                                    </div>
                                </div>
                                
                                <div class="col-md-6">
                                    <div class="mb-3">
                                        <label class="form-label">Price *</label>
                                        <input type="number" step="0.01" name="price" class="form-control" 
                                               value="<%= rs.getDouble("price") %>" required>
                                    </div>
                                </div>
                            </div>
                            
                            <div class="row">
                                <div class="col-md-6">
                                    <div class="mb-3">
                                        <label class="form-label">Category</label>
                                        <input type="text" name="category" class="form-control" 
                                               value="<%= rs.getString("category") != null ? rs.getString("category") : "" %>">
                                    </div>
                                </div>
                                
                                <div class="col-md-6">
                                    <div class="mb-3">
                                        <label class="form-label">Stock Quantity</label>
                                        <input type="number" name="stock" class="form-control" 
                                               value="<%= rs.getInt("stock_quantity") %>">
                                    </div>
                                </div>
                            </div>
                            
                            <div class="mb-3">
                                <label class="form-label">Current Image</label>
                                <div>
                                    <img src="<%= imagePreview %>" 
                                         alt="Current Image" 
                                         class="product-preview img-thumbnail"
                                         onerror="this.src='https://via.placeholder.com/200x200?text=No+Image'">
                                    <input type="hidden" name="current_image" value="<%= currentImage %>">
                                </div>
                            </div>
                            
                            <div class="mb-3">
                                <label class="form-label">Update Image URL (Optional)</label>
                                <input type="text" name="image" class="form-control" 
                                       value="<%= currentImage != null ? currentImage : "" %>"
                                       placeholder="Enter new image URL or leave current">
                                <small class="text-muted">Leave empty to keep current image</small>
                            </div>
                            
                            <div class="mb-3">
                                <label class="form-label">Description</label>
                                <textarea name="description" class="form-control" rows="4"><%= rs.getString("description") != null ? rs.getString("description") : "" %></textarea>
                            </div>
                        </div>
                        
                        <div class="col-md-4">
                            <div class="card">
                                <div class="card-body">
                                    <h5 class="card-title">Product Info</h5>
                                    <ul class="list-group list-group-flush">
                                        <li class="list-group-item d-flex justify-content-between">
                                            <span>Product ID:</span>
                                            <strong><%= rs.getInt("id") %></strong>
                                        </li>
                                        <li class="list-group-item d-flex justify-content-between">
                                            <span>Created:</span>
                                            <span><%= rs.getTimestamp("created_at") %></span>
                                        </li>
                                        <li class="list-group-item d-flex justify-content-between">
                                            <span>Last Updated:</span>
                                            <span><%= rs.getTimestamp("created_at") %></span>
                                        </li>
                                    </ul>
                                </div>
                            </div>
                        </div>
                        
                        <div class="col-12">
                            <div class="d-flex gap-2">
                                <button type="submit" class="btn btn-success">
                                    <i class="bi bi-check-circle"></i> Update Product
                                </button>
                                <a href="view-products.jsp" class="btn btn-secondary">
                                    <i class="bi bi-x-circle"></i> Cancel
                                </a>
                                <a href="DeleteProductServlet?id=<%= rs.getInt("id") %>" 
                                   class="btn btn-danger ms-auto"
                                   onclick="return confirm('Are you sure you want to delete this product?')">
                                    <i class="bi bi-trash"></i> Delete Product
                                </a>
                            </div>
                        </div>
                    </form>
                </div>
            </div>
            
            <%
                    } else {
                        out.println("<div class='alert alert-danger'>Product not found!</div>");
                        out.println("<a href='view-products.jsp' class='btn btn-secondary'>Back to Products</a>");
                    }
                } catch(Exception e) {
                    e.printStackTrace();
                    out.println("<div class='alert alert-danger'>Error: " + e.getMessage() + "</div>");
                } finally {
                    try { if(rs != null) rs.close(); } catch(Exception e) {}
                    try { if(ps != null) ps.close(); } catch(Exception e) {}
                    try { if(conn != null) conn.close(); } catch(Exception e) {}
                }
            %>
        </div>
    </div>
</div>

<!-- Bootstrap JS -->
<script src="../js/bootstrap.bundle.min.js"></script>
</body>
</html>