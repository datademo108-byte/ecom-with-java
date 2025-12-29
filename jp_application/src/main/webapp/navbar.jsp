<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>Insert title here</title>
 <!-- Bootstrap JS -->
 <script type="text/javascript" src="js/bootstrap.min.js"></script>
 <!-- Bootstrap CSS -->
 <link href="css/bootstrap.min.css" rel="stylesheet">
 <!-- Bootstrap Icons -->
 <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.13.1/font/bootstrap-icons.min.css">
 <!-- jQuery for potential AJAX operations -->
 <script src="https://code.jquery.com/jquery-3.6.0.min.js"></script>
</head>
<body>

<!-- Navigation Bar -->
<nav class="navbar navbar-expand-lg navbar-light bg-info fixed-top" style="font-weight:bold;">
  <div class="container-fluid">
    <!-- Brand/Logo -->
    <a class="navbar-brand" href="index.jsp">Ecommerce.org</a>
    
    <!-- Mobile Toggle Button -->
    <button class="navbar-toggler" type="button" data-bs-toggle="collapse" data-bs-target="#navbarSupportedContent" aria-controls="navbarSupportedContent" aria-expanded="false" aria-label="Toggle navigation">
      <span class="navbar-toggler-icon"></span>
    </button>
    
    <!-- Navbar Content -->
    <div class="collapse navbar-collapse" id="navbarSupportedContent">
      <!-- Left side navigation items -->
      <ul class="navbar-nav me-auto mb-2 mb-lg-0">
        <!-- Home Link (Always visible) -->
        <li class="nav-item">
          <a class="nav-link active" aria-current="page" href="index.jsp">Home</a>
        </li>
        
        <!-- START: User Authentication Logic -->
        <%
          // Get the current session (false means don't create new session if it doesn't exist)
          HttpSession userSession = request.getSession(false);
          
          // Initialize variables
          String userName = null;
          boolean isLoggedIn = false;
          boolean isAdmin = false;
          
          // Check if session exists
          if(userSession != null) {
            // Get user's first name from session
            userName = (String) userSession.getAttribute("user_fname");
            
            // Check if user is logged in
            Object loggedInAttr = userSession.getAttribute("loggedin");
            isLoggedIn = (loggedInAttr != null && (Boolean) loggedInAttr);
            
            // Check if user is admin
            Object adminAttr = userSession.getAttribute("is_admin");
            isAdmin = (adminAttr != null && (Boolean) adminAttr);
          }
          
          // Conditional Display based on login status
          if(isLoggedIn && userName != null) {
            // User IS logged in - Show User Menu with dropdown
        %>
        
        <!-- Admin Link (Only for admin users) -->
        <% if(isAdmin) { %>
        <li class="nav-item">
          <a class="nav-link active" href="admin/dashboard.jsp" style="color: #ff0000;">
            <i class="bi bi-shield-lock"></i> Admin Panel
          </a>
        </li>
        <% } %>
        
        <!-- User Dropdown Menu (Visible when logged in) -->
        <li class="nav-item dropdown">
          <!-- Dropdown Toggle Button with user's name -->
          <a class="nav-link active dropdown-toggle" href="#" id="userDropdown" role="button" data-bs-toggle="dropdown">
            <!-- User Icon -->
            <i class="bi bi-person-circle"></i> 
            <!-- Display Welcome message with user's first name -->
            Welcome, <%= userName %>
            <% if(isAdmin) { %>
              <span class="badge bg-danger">Admin</span>
            <% } %>
          </a>
          
          <!-- Dropdown Menu Items -->
          <ul class="dropdown-menu" aria-labelledby="userDropdown">
            <!-- Profile Link -->
            <li><a class="dropdown-item" href="profile.jsp">
                <i class="bi bi-person"></i> My Profile
            </a></li>
            
            <% if(isAdmin) { %>
            <!-- Admin Dashboard Link in dropdown too -->
            <li><a class="dropdown-item" href="dashboard.jsp" style="color: #dc3545;">
                <i class="bi bi-shield-lock"></i> Admin Dashboard
            </a></li>
            <li><hr class="dropdown-divider"></li>
            <% } %>
            
            <!-- Orders Link -->
            <li><a class="dropdown-item" href="orders.jsp">
                <i class="bi bi-bag"></i> My Orders
            </a></li>
            
            <!-- Divider -->
            <li><hr class="dropdown-divider"></li>
            
            <!-- Logout Link -->
            <li><a class="dropdown-item" href="logout.jsp">
                <i class="bi bi-box-arrow-right"></i> Logout
            </a></li>
          </ul>
        </li>
        
        <!-- Cart Link (Visible when logged in) -->
        <li class="nav-item">
          <a class="nav-link active" href="cart.jsp">
            <i class="bi bi-cart3"></i> Cart
          </a>
        </li>
        
        <%
          } else {
            // User is NOT logged in - Show Login and Register links
        %>
        
        <!-- Login Link (Visible when NOT logged in) -->
        <li class="nav-item">
          <a class="nav-link active" href="login.jsp">Login</a>
        </li>
        
        <!-- Register Link (Visible when NOT logged in) -->
        <li class="nav-item">
          <a class="nav-link active" href="register.jsp">Register</a>
        </li>
        
          <!-- Register Link (Visible when NOT logged in) -->
        <li class="nav-item">
          <a class="nav-link active" href="products.jsp">Products</a>
        </li>
        
        <!-- Admin Login Link (Visible when NOT logged in) -->
        <li class="nav-item">
          <a class="nav-link active" href="admin-login.jsp" style="color: #ff0000;">
            <i class="bi bi-shield-lock"></i> Admin Login
          </a>
        </li>
        
        <%
          } // End of if-else block for login status
        %>
        <!-- END: User Authentication Logic -->
        
      </ul>
      <!-- End of Left side navigation -->
      
      <!-- Search Form (Always visible) -->
      <form class="d-flex">
        <input class="form-control me-2" type="search" placeholder="Search" aria-label="Search">
        <button class="btn btn-outline-dark" type="submit">Search</button>
      </form>
      
    </div>
    <!-- End of navbar content -->
  </div>
</nav>
<!-- End of Navigation Bar -->


</body>
</html>