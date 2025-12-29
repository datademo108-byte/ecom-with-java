import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import java.io.IOException;
import java.io.PrintWriter;
import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.PreparedStatement;
import java.sql.ResultSet;

@WebServlet("/loginservlet")
public class loginservlet extends HttpServlet {
    private static final long serialVersionUID = 1L;
    
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        String email = request.getParameter("email");
        String password = request.getParameter("password");
        
        response.setContentType("text/html");
        PrintWriter pw = response.getWriter();
        
        try {
            Class.forName("com.mysql.cj.jdbc.Driver");
            Connection conn = DriverManager.getConnection("jdbc:mysql://localhost:3306/ecom","root","Agr@hari567#");
            
            String sql = "SELECT * FROM user WHERE email = ? AND password = ?";
            PreparedStatement psmt = conn.prepareStatement(sql);
            psmt.setString(1, email);
            psmt.setString(2, password);
            
            ResultSet rs = psmt.executeQuery();
            
            if(rs.next()) {
                HttpSession session = request.getSession();
                session.setAttribute("user_id", rs.getInt("id"));
                session.setAttribute("user_fname", rs.getString("fname"));
                session.setAttribute("user_email", rs.getString("email"));
                session.setAttribute("loggedin", true);
                
                // Check if user is admin
                int isAdmin = rs.getInt("is_admin");
                if(isAdmin == 1) {
                    session.setAttribute("is_admin", true);
                    pw.println("<script>alert('Admin Login Successful!'); window.location.href='dashboard.jsp';</script>");
                } else {
                    session.setAttribute("is_admin", false);
                    pw.println("<script>alert('Login Successful!'); window.location.href='index.jsp';</script>");
                }
                
            } else {
                pw.println("<script>alert('Invalid email or password!'); window.history.back();</script>");
            }
            
            conn.close();
        } catch (Exception e) {
            e.printStackTrace();
            pw.println("<script>alert('Error occurred!'); window.history.back();</script>");
        }
    }
}