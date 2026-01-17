import java.io.*;
import java.net.*;
import java.util.Base64;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.MultipartConfig;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

@WebServlet("/CreateRazorpayOrderServlet")
@MultipartConfig
public class CreateRazorpayOrderServlet extends HttpServlet {
    
    // Replace with your actual Razorpay test credentials
    private static final String RAZORPAY_KEY_ID = "";
    private static final String RAZORPAY_KEY_SECRET = "";
    
    protected void doPost(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        response.setContentType("application/json");
        response.setCharacterEncoding("UTF-8");
        PrintWriter out = response.getWriter();
        
        try {
            // Get parameters
            String amount = request.getParameter("amount");
            String currency = request.getParameter("currency");
            String customerName = request.getParameter("customer_name");
            String customerEmail = request.getParameter("customer_email");
            String customerPhone = request.getParameter("customer_phone");
            String userId = request.getParameter("user_id");
            
            // Validate amount
            if (amount == null || amount.isEmpty()) {
                out.println("{\"success\":false,\"message\":\"Amount is required\"}");
                return;
            }
            
            // Create receipt ID
            String receiptId = "receipt_" + System.currentTimeMillis() + "_" + userId;
            
            // Create order JSON for Razorpay
            String orderJson = String.format(
                "{\"amount\":%s,\"currency\":\"%s\",\"receipt\":\"%s\",\"payment_capture\":1,\"notes\":{\"customer_name\":\"%s\",\"customer_email\":\"%s\",\"user_id\":\"%s\"}}",
                amount, 
                currency != null ? currency : "INR",
                receiptId,
                customerName != null ? customerName : "Customer",
                customerEmail != null ? customerEmail : "customer@example.com",
                userId != null ? userId : "0"
            );
            
            System.out.println("Creating Razorpay order with JSON: " + orderJson);
            
            // Call Razorpay API
            String apiUrl = "https://api.razorpay.com/v1/orders";
            URL url = new URL(apiUrl);
            HttpURLConnection conn = (HttpURLConnection) url.openConnection();
            
            // Basic authentication
            String auth = RAZORPAY_KEY_ID + ":" + RAZORPAY_KEY_SECRET;
            String encodedAuth = Base64.getEncoder().encodeToString(auth.getBytes());
            
            // Set up connection
            conn.setRequestMethod("POST");
            conn.setRequestProperty("Content-Type", "application/json");
            conn.setRequestProperty("Authorization", "Basic " + encodedAuth);
            conn.setDoOutput(true);
            conn.setConnectTimeout(10000);
            conn.setReadTimeout(10000);
            
            // Send request
            try (OutputStream os = conn.getOutputStream()) {
                byte[] input = orderJson.getBytes("utf-8");
                os.write(input, 0, input.length);
            }
            
            // Get response code
            int responseCode = conn.getResponseCode();
            System.out.println("Razorpay API Response Code: " + responseCode);
            
            // Read response
            BufferedReader br;
            if (responseCode >= 200 && responseCode < 300) {
                br = new BufferedReader(new InputStreamReader(conn.getInputStream()));
            } else {
                br = new BufferedReader(new InputStreamReader(conn.getErrorStream()));
            }
            
            StringBuilder responseBuilder = new StringBuilder();
            String responseLine;
            while ((responseLine = br.readLine()) != null) {
                responseBuilder.append(responseLine);
            }
            
            String apiResponse = responseBuilder.toString();
            System.out.println("Razorpay API Response: " + apiResponse);
            
            // Return response to client
            if (responseCode >= 200 && responseCode < 300) {
                // Extract order ID from response
                String orderId = extractJsonValue(apiResponse, "id");
                String responseAmount = extractJsonValue(apiResponse, "amount");
                String responseCurrency = extractJsonValue(apiResponse, "currency");
                
                out.println(String.format(
                    "{\"success\":true,\"orderId\":\"%s\",\"amount\":%s,\"currency\":\"%s\",\"razorpayKey\":\"%s\"}",
                    orderId, 
                    responseAmount != null ? responseAmount : amount,
                    responseCurrency != null ? responseCurrency : currency,
                    RAZORPAY_KEY_ID
                ));
            } else {
                out.println(String.format(
                    "{\"success\":false,\"message\":\"Razorpay API Error (Code: %d): %s\"}",
                    responseCode, 
                    apiResponse.length() > 200 ? apiResponse.substring(0, 200) : apiResponse
                ));
            }
            
            conn.disconnect();
            
        } catch (Exception e) {
            e.printStackTrace();
            out.println("{\"success\":false,\"message\":\"Server Error: " + e.getMessage() + "\"}");
        }
    }
    
    private String extractJsonValue(String json, String key) {
        try {
            String searchKey = "\"" + key + "\":";
            int startIndex = json.indexOf(searchKey);
            if (startIndex == -1) return null;
            
            startIndex += searchKey.length();
            
            // Check if value is string or number
            if (json.charAt(startIndex) == '"') {
                // String value
                startIndex++; // Skip opening quote
                int endIndex = json.indexOf("\"", startIndex);
                return json.substring(startIndex, endIndex);
            } else {
                // Number or boolean value
                int endIndex = json.indexOf(",", startIndex);
                if (endIndex == -1) endIndex = json.indexOf("}", startIndex);
                return json.substring(startIndex, endIndex).trim();
            }
        } catch (Exception e) {
            return null;
        }
    }

}
