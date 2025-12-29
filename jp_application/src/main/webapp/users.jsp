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
%>
<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>Manage Users</title>
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
</style>
</head>
<body>
<jsp:include page="navbar.jsp"></jsp:include>
<div class="container-fluid mt-5">
    <div class="row">
        <div class="col-md-3 col-lg-2 p-0">
            <div class="sidebar">
                <h3 class="p-3">Admin Panel</h3>
                <a href="dashboard.jsp"><i class="bi bi-speedometer2"></i> Dashboard</a>
                <a href="add-product.jsp"><i class="bi bi-plus-circle"></i> Add Product</a>
                <a href="view-products.jsp"><i class="bi bi-list-ul"></i> View Products</a>
                <a href="users.jsp" style="background:#495057;"><i class="bi bi-people"></i> Users</a>
                <a href="orders.jsp"><i class="bi bi-cart"></i> Orders</a>
                <a href="logout.jsp"><i class="bi bi-box-arrow-left"></i> Logout</a>
            </div>
        </div>
        
        <div class="col-md-9 col-lg-10 p-4">
            <nav class="navbar navbar-light bg-light mb-4">
                <div class="container-fluid">
                    <h4 class="mb-0">Manage Users</h4>
                    <span class="navbar-text">
                        Welcome, <%= userSession.getAttribute("user_fname") %>
                    </span>
                </div>
            </nav>
            
            <div class="card">
                <div class="card-body">
                    <table class="table table-hover">
                        <thead class="table-dark">
                            <tr>
                                <th>ID</th>
                                <th>Name</th>
                                <th>Email</th>
                                <th>Admin</th>
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
                                    rs = stmt.executeQuery("SELECT * FROM user ORDER BY id DESC");
                                    
                                    while(rs.next()) {
                            %>
                            <tr>
                                <td><%= rs.getInt("id") %></td>
                                <td><%= rs.getString("fname") %> <%= rs.getString("lname") %></td>
                                <td><%= rs.getString("email") %></td>
                                <td>
                                    <% if(rs.getInt("is_admin") == 1) { %>
                                        <span class="badge bg-danger">Admin</span>
                                    <% } else { %>
                                        <span class="badge bg-secondary">User</span>
                                    <% } %>
                                </td>
                                <td>
                                    <button class="btn btn-sm btn-warning" onclick="makeAdmin(<%= rs.getInt("id") %>)">
                                        <i class="bi bi-shield-check"></i> Make Admin
                                    </button>
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
            </div>
        </div>
    </div>
</div>

<script src="../js/bootstrap.bundle.min.js"></script>
<script>
function makeAdmin(userId) {
    if(confirm("Make this user an admin?")) {
        window.location.href = "MakeAdminServlet?user_id=" + userId;
    }
}
</script>
</body>
</html>