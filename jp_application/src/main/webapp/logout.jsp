<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>Logout</title>
</head>
<body>
<%
    // End user session
    HttpSession userSession = request.getSession(false);
    if(userSession != null) {
        userSession.invalidate();
    }
    
    // Go to home page
    response.sendRedirect("index.jsp");
%>
</body>
</html>