import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import java.io.*;
import java.sql.*;

@WebServlet("/CartCountServlet")
public class CartCountServlet extends HttpServlet {

    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws IOException {

        HttpSession session = request.getSession(false);
        response.setContentType("text/plain");

        if (session == null || session.getAttribute("user_id") == null) {
            response.getWriter().print(0);
            return;
        }

        int userId = (Integer) session.getAttribute("user_id");

        try {
            Class.forName("com.mysql.cj.jdbc.Driver");
            Connection conn = DriverManager.getConnection(
                "jdbc:mysql://localhost:3306/ecom", "root", "Agr@hari567#"
            );

            PreparedStatement ps = conn.prepareStatement(
                "SELECT SUM(quantity) FROM cart WHERE user_id=?"
            );
            ps.setInt(1, userId);

            ResultSet rs = ps.executeQuery();
            int count = 0;

            if (rs.next()) {
                count = rs.getInt(1);
            }

            response.getWriter().print(count);
            conn.close();

        } catch (Exception e) {
            e.printStackTrace();
            response.getWriter().print(0);
        }
    }
}
