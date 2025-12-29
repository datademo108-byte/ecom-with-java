<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>Login Page</title>
<!-- Bootstrap CSS -->
<link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0-alpha1/dist/css/bootstrap.min.css" rel="stylesheet">
<!-- Bootstrap Icons -->
<link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.8.1/font/bootstrap-icons.css">
<style>
    body {
        background-image: url('https://images.unsplash.com/photo-1507525428034-b723cf961d3e?ixlib=rb-4.0.3&ixid=MnwxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8&auto=format&fit=crop&w=2073&q=80');
        background-size: cover;
        background-position: center;
        background-repeat: no-repeat;
        background-attachment: fixed;
        min-height: 100vh;
        margin: 0;
        padding: 0;
    }
    
    /* Overlay for better readability */
    body::before {
        content: '';
        position: fixed;
        top: 0;
        left: 0;
        width: 100%;
        height: 100%;
        background: rgba(0, 0, 0, 0.5);
        z-index: -1;
    }
    
    .container {
        min-height: 100vh;
        display: flex;
        align-items: center;
        justify-content: center;
    }
    
    .form-container {
        background: rgba(255, 255, 255, 0.9);
        backdrop-filter: blur(10px);
        border-radius: 20px;
        padding: 40px;
        box-shadow: 0 15px 35px rgba(0, 0, 0, 0.2);
        border: 1px solid rgba(255, 255, 255, 0.2);
        max-width: 450px;
        width: 100%;
    }
    
    .form-container h2 {
        text-align: center;
        margin-bottom: 30px;
        color: #333;
        font-weight: 600;
    }
    
    .form-label {
        font-weight: 500;
        color: #555;
    }
    
    .form-control {
        border-radius: 10px;
        padding: 12px 15px;
        border: 1px solid #ddd;
        transition: all 0.3s;
    }
    
    .form-control:focus {
        border-color: #4e73df;
        box-shadow: 0 0 0 0.25rem rgba(78, 115, 223, 0.25);
    }
    
    .btn-primary {
        background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
        border: none;
        border-radius: 10px;
        padding: 12px;
        font-weight: 600;
        transition: all 0.3s;
        width: 100%;
    }
    
    .btn-primary:hover {
        transform: translateY(-2px);
        box-shadow: 0 7px 14px rgba(102, 126, 234, 0.4);
    }
    
    .btn-floating {
        border-radius: 50%;
        width: 40px;
        height: 40px;
        display: inline-flex;
        align-items: center;
        justify-content: center;
        transition: all 0.3s;
    }
    
    .btn-floating:hover {
        transform: translateY(-3px);
    }
    
    .social-login {
        text-align: center;
        margin-top: 20px;
    }
    
    .social-login p {
        color: #666;
        margin-bottom: 15px;
    }
    
    .register-link {
        text-align: center;
        margin-top: 20px;
    }
    
    .register-link a {
        color: #667eea;
        text-decoration: none;
        font-weight: 500;
    }
    
    .register-link a:hover {
        text-decoration: underline;
    }
    
    /* Animation for form */
    @keyframes fadeIn {
        from {
            opacity: 0;
            transform: translateY(20px);
        }
        to {
            opacity: 1;
            transform: translateY(0);
        }
    }
    
    .form-container {
        animation: fadeIn 0.6s ease-out;
    }
    
    /* Responsive adjustments */
    @media (max-width: 576px) {
        .form-container {
            padding: 30px 20px;
            margin: 20px;
        }
    }
</style>
</head>
<body>

<jsp:include page="navbar.jsp"></jsp:include>

<div class="container mt-5">
    <div class="form-container">
        <h2>Welcome Back!</h2>
        
        <form id="loginForm" action="loginservlet" method="post">
            <!-- Email input -->
            <div class="form-outline mb-4">
                <input type="email" name="email" id="email" class="form-control" required />
                <label class="form-label" for="email">Email address</label>
            </div>

            <!-- Password input -->
            <div class="form-outline mb-4">
                <input type="password" name="password" id="password" class="form-control" required />
                <label class="form-label" for="password">Password</label>
            </div>

            <!-- Remember me checkbox -->
            <div class="row mb-4">
                <div class="col d-flex justify-content-center">
                    <div class="form-check">
                        <input class="form-check-input" type="checkbox" id="rememberMe" />
                        <label class="form-check-label" for="rememberMe">Remember me</label>
                    </div>
                </div>
                <div class="col text-end">
                    <a href="#!" style="color: #667eea; text-decoration: none;">Forgot password?</a>
                </div>
            </div>

            <!-- Submit button -->
            <button type="submit" class="btn btn-primary btn-block mb-4">Sign in</button>

            <!-- Register buttons -->
            <div class="register-link">
                <p>Not a member? <a href="register.jsp">Register</a></p>
            </div>
            
            <!-- Social login -->
            <div class="social-login">
                <p>or sign in with:</p>
                <button type="button" class="btn btn-light btn-floating mx-1">
                    <i class="bi bi-facebook" style="color: #1877f2;"></i>
                </button>

                <button type="button" class="btn btn-light btn-floating mx-1">
                    <i class="bi bi-google" style="color: #ea4335;"></i>
                </button>

                <button type="button" class="btn btn-light btn-floating mx-1">
                    <i class="bi bi-twitter" style="color: #1da1f2;"></i>
                </button>

                <button type="button" class="btn btn-light btn-floating mx-1">
                    <i class="bi bi-github" style="color: #333;"></i>
                </button>
            </div>
        </form>
    </div>
</div>

<!-- Bootstrap JS Bundle with Popper -->
<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0-alpha1/dist/js/bootstrap.bundle.min.js"></script>


        
     

</body>
</html>