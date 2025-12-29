<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>Insert title here</title>
</head>
<body>

<jsp:include page="navbar.jsp"></jsp:include>


<!-- register with mdboostrap  -->

<div class="container mt-5">
  <div class= " row">
  <div class="col">
  
  </div>
  
  <div class="col">
  
  
  <form action="registerservlet" method="post" style="background-color: gray;padding:30px;border-radius: 20px;">
  <!-- 2 column grid layout with text inputs for the first and last names -->
  <div class="row mb-4">
    <div class="col">
      <div data-mdb-input-init class="form-outline">
        <input type="text" name="fname" id="form3Example1" class="form-control" />
        <label class="form-label" for="form3Example1">First name</label>
      </div>
    </div>
    <div class="col">
      <div data-mdb-input-init class="form-outline">
        <input type="text" name="lname" id="form3Example2" class="form-control" />
        <label class="form-label" for="form3Example2">Last name</label>
      </div>
    </div>
  </div>

  <!-- Email input -->
  <div data-mdb-input-init class="form-outline mb-4">
    <input type="email" name="email" id="form3Example3" class="form-control" />
    <label class="form-label" for="form3Example3">Email address</label>
  </div>

  <!-- Password input -->
  <div data-mdb-input-init class="form-outline mb-4">
    <input type="password" name="password" id="form3Example4" class="form-control" />
    <label class="form-label" for="form3Example4">Password</label>
  </div>

  <!-- Checkbox -->
  <div class="form-check d-flex justify-content-center mb-4">
    <input class="form-check-input me-2" type="checkbox" value="" id="form2Example33" checked />
    <label class="form-check-label" for="form2Example33">
      Subscribe to our newsletter
    </label>
  </div>

  <!-- Submit button -->
  <button data-mdb-ripple-init type="submit" class="btn btn-primary btn-block mb-4">Sign up</button>

  <!-- Register buttons -->
  <div class="text-center">
    <p>or sign up with:</p>
    <button data-mdb-ripple-init type="button" class="btn btn-secondary btn-floating mx-1">
      <i class="bi bi-facebook"></i>
    </button>

    <button data-mdb-ripple-init type="button" class="btn btn-secondary btn-floating mx-1">
      <i class="bi bi-google"></i>
    </button>

    <button data-mdb-ripple-init type="button" class="btn btn-secondary btn-floating mx-1">
      <i class="bi bi-twitter"></i>
    </button>

    <button data-mdb-ripple-init type="button" class="btn btn-secondary btn-floating mx-1">
     <i class="bi bi-github"></i>
    </button>
  </div>
</form>
  
  
  
  
  
  
  
  </div>
  
  <div class="col">
  
  </div>
  
  
  </div>
</div>







</body>
</html>