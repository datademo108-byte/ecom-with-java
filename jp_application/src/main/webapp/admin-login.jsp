<!DOCTYPE html>
<html>
<head>
    <title>Admin Login</title>
    <link href="css/bootstrap.min.css" rel="stylesheet">
</head>
<body class="bg-light">
    <div class="container mt-5">
        <div class="row justify-content-center">
            <div class="col-md-5">
                <div class="card shadow">
                    <div class="card-header bg-danger text-white text-center">
                        <h4><i class="bi bi-shield-lock"></i> Admin Login</h4>
                    </div>
                    <div class="card-body">
                        <form action="loginservlet" method="post">
                            <div class="mb-3">
                                <label class="form-label">Email Address</label>
                                <input type="email" name="email" class="form-control" required>
                            </div>
                            <div class="mb-3">
                                <label class="form-label">Password</label>
                                <input type="password" name="password" class="form-control" required>
                            </div>
                            <button type="submit" class="btn btn-danger w-100">
                                <i class="bi bi-box-arrow-in-right"></i> Login as Admin
                            </button>
                        </form>
                        <div class="mt-3 text-center">
                            <a href="index.jsp" class="btn btn-outline-secondary btn-sm">Back to Home</a>
                            <a href="login.jsp" class="btn btn-link">User Login</a>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </div>
</body>
</html>