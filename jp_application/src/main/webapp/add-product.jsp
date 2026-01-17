<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<%
    // Admin check - use existing session object
    Boolean isAdmin = (session != null) ? (Boolean) session.getAttribute("is_admin") : false;
    if(!Boolean.TRUE.equals(isAdmin)) {
        response.sendRedirect("../login.jsp");  // Fixed path
        return;
    }
%>
<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>Add Product</title>
<link href="../css/bootstrap.min.css" rel="stylesheet">
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
                <a href="add-product.jsp" style="background:#495057;"><i class="bi bi-plus-circle"></i> Add Product</a>
                <a href="view-products.jsp"><i class="bi bi-list-ul"></i> View Products</a>
                <a href="logout.jsp"><i class="bi bi-box-arrow-left"></i> Logout</a>
            </div>
        </div>
        
        <!-- Main Content -->
        <div class="col-md-9 col-lg-10 p-4">
            <nav class="navbar navbar-light bg-light mb-4">
                <div class="container-fluid">
                    <h4 class="mb-0">Add New Product</h4>
                    <span class="navbar-text">
                        Welcome, <%= session.getAttribute("user_fname") %>
                    </span>
                </div>
            </nav>
            
            <!-- Simple form without file upload -->
            <form action="AddProductServlet" method="post" class="mt-4">
                <div class="row">
                    <div class="col-md-6">
                        <div class="mb-3">
                            <label class="form-label">Product Name *</label>
                            <input type="text" name="name" class="form-control" required>
                        </div>
                        
                        <div class="mb-3">
                            <label class="form-label">Price *</label>
                            <input type="number" step="0.01" name="price" class="form-control" required>
                        </div>
                        
                        <div class="mb-3">
                            <label class="form-label">Category</label>
                            <input type="text" name="category" class="form-control">
                        </div>
                    </div>
                    
                    <div class="col-md-6">
                        <div class="mb-3">
                            <label class="form-label">Stock Quantity</label>
                            <input type="number" name="stock" class="form-control" value="0">
                        </div>
                        
                        <div class="mb-3">
                            <label class="form-label">Image URL (Optional)</label>
                            <input type="text" name="image" class="form-control" placeholder="https://example.com/image.jpg">
                            <small class="text-muted">Leave empty for default image</small>
                        </div>
                    </div>
                </div>
                
                <div class="mb-3">
                    <label class="form-label">Description</label>
                    <textarea name="description" class="form-control" rows="4"></textarea>
                </div>
                
                <div class="d-flex gap-2">
                    <button type="submit" class="btn btn-primary">
                        <i class="bi bi-check-circle"></i> Add Product
                    </button>
                    <a href="dashboard.jsp" class="btn btn-secondary">
                        <i class="bi bi-x-circle"></i> Cancel
                    </a>
                </div>
            </form>
        </div>
    </div>
</div>

<!-- Add Bootstrap Icons -->
<link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.8.1/font/bootstrap-icons.css">
<script src="../js/bootstrap.bundle.min.js"></script>
</body>
</html>