


import java.io.IOException;
import java.io.PrintWriter;
import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.PreparedStatement;
import java.sql.SQLException;

import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

public class registerservlet extends HttpServlet {
	private static final long serialVersionUID = 1L;
       


	protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
		
	     String fname = request.getParameter("fname");
	        String lname = request.getParameter("lname");
	        String email = request.getParameter("email");
	        String password = request.getParameter("password");
	        
	        PrintWriter pw = response.getWriter();
			/*
			 * pw.println("this is your firstname"+fname);
			 * pw.println("this is your lastname"+lname);
			 * pw.println("this is your email"+email);
			 * pw.println("this is your password"+password);
			 */
	        
	        
	      
	        	
	        	try {
					Class.forName("com.mysql.cj.jdbc.Driver");
					
					Connection conn =DriverManager.getConnection("jdbc:mysql://localhost:3306/ecom","root","Agr@hari567#");
		        	
		        	String sql = "insert into user(fname,lname,email,password) values('"+fname+"','"+lname+"','"+email+"','"+password+"')";
		        	
		        	PreparedStatement psmt = conn.prepareStatement(sql);
		        	
		        	int rs = psmt.executeUpdate();
		        	
		        	if(rs> 0) {
		        		pw.println("<script type=\"text/javascript\">");
		                pw.println("alert('User registered successfully');");
		                pw.println("window.location.href = 'login.jsp';"); 
		                pw.println("</script>");
		        		
		        	}else {
		        		pw.println("there is some problem ?? error ");
		        	}
					
				} catch (ClassNotFoundException | SQLException e) {
					// TODO Auto-generated catch block
					e.printStackTrace();
				}
	        	
	        	
	        	
				
			
	        

		
	}

}
