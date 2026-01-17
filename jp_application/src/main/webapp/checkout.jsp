<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8" import="jakarta.servlet.http.*, java.sql.*, java.util.*" %>
<%@ page import="java.sql.*, java.util.*" %>
<%
    // Check if user is logged in
    Boolean loggedIn = (session != null && session.getAttribute("loggedin") != null) ? 
                      (Boolean) session.getAttribute("loggedin") : false;
    
    if(!loggedIn) {
        response.sendRedirect("login.jsp");
        return;
    }
    
    int userId = (Integer) session.getAttribute("user_id");
    String userEmail = (String) session.getAttribute("user_email");
    String firstName = (String) session.getAttribute("first_name");
    String lastName = (String) session.getAttribute("last_name");
    
    // Initialize variables
    double subtotal = 0.0;
    double tax = 0.0;
    double shipping = 0.0;
    double total = 0.0;
    int cartItemCount = 0;
    
    // Get cart totals from database
    Connection conn = null;
    PreparedStatement ps = null;
    ResultSet rs = null;
    
    try {
        Class.forName("com.mysql.cj.jdbc.Driver");
        conn = DriverManager.getConnection("jdbc:mysql://localhost:3306/ecom","root","Agr@hari567#");
        
        // Get cart items and calculate totals
        String cartSql = "SELECT c.quantity, p.price, p.name " +
                        "FROM cart c " +
                        "JOIN products p ON c.product_id = p.id " +
                        "WHERE c.user_id = ?";
        ps = conn.prepareStatement(cartSql);
        ps.setInt(1, userId);
        rs = ps.executeQuery();
        
        while(rs.next()) {
            int quantity = rs.getInt("quantity");
            double price = rs.getDouble("price");
            subtotal += (price * quantity);
            cartItemCount++;
        }
        
        // Calculate other amounts
        tax = subtotal * 0.1; // 10% tax
        shipping = (subtotal > 50) ? 0 : 5.99; // Free shipping over $50
        total = subtotal + tax + shipping;
        
    } catch(Exception e) {
        e.printStackTrace();
    } finally {
        try { if(rs != null) rs.close(); } catch(Exception e) {}
        try { if(ps != null) ps.close(); } catch(Exception e) {}
        try { if(conn != null) conn.close(); } catch(Exception e) {}
    }
%>
<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>Checkout - Ecommerce</title>
<link href="css/bootstrap.min.css" rel="stylesheet">
<link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.8.1/font/bootstrap-icons.css">
<!-- Razorpay Checkout Integration -->
<script src="https://checkout.razorpay.com/v1/checkout.js"></script>
<style>
    .checkout-container {
        max-width: 800px;
        margin: 0 auto;
    }
    .payment-steps {
        background: #f8f9fa;
        border-radius: 10px;
        padding: 20px;
        margin-bottom: 30px;
    }
    .payment-step {
        display: flex;
        align-items: center;
        margin-bottom: 15px;
        padding: 10px;
        border-left: 4px solid #0d6efd;
        background: white;
        border-radius: 5px;
    }
    .step-number {
        background: #0d6efd;
        color: white;
        width: 30px;
        height: 30px;
        border-radius: 50%;
        display: flex;
        align-items: center;
        justify-content: center;
        margin-right: 15px;
        font-weight: bold;
    }
    .payment-info {
        background: #e7f1ff;
        border-radius: 10px;
        padding: 25px;
        margin-bottom: 30px;
    }
    .razorpay-logo {
        height: 40px;
        margin-bottom: 20px;
    }
    .payment-options {
        display: grid;
        grid-template-columns: repeat(auto-fit, minmax(150px, 1fr));
        gap: 15px;
        margin-top: 20px;
    }
    .payment-option {
        border: 2px solid #dee2e6;
        border-radius: 10px;
        padding: 15px;
        text-align: center;
        cursor: pointer;
        transition: all 0.3s;
    }
    .payment-option:hover {
        border-color: #0d6efd;
        background: #f8f9fa;
    }
    .payment-option.selected {
        border-color: #0d6efd;
        background: #e7f1ff;
    }
    .payment-icon {
        font-size: 2rem;
        margin-bottom: 10px;
        color: #0d6efd;
    }
    .payment-process {
        display: none;
        text-align: center;
        padding: 30px;
    }
    .loader {
        border: 5px solid #f3f3f3;
        border-top: 5px solid #0d6efd;
        border-radius: 50%;
        width: 50px;
        height: 50px;
        animation: spin 1s linear infinite;
        margin: 0 auto 20px;
    }
    @keyframes spin {
        0% { transform: rotate(0deg); }
        100% { transform: rotate(360deg); }
    }
</style>
</head>
<body>
<jsp:include page="navbar.jsp"></jsp:include>

<div class="container mt-4 checkout-container">
    <div class="text-center mb-4">
        <h2><i class="bi bi-credit-card"></i> Complete Your Payment</h2>
        <p class="text-muted">Secure payment powered by Razorpay</p>
    </div>

    <!-- Payment Steps Information -->
    <div class="payment-steps">
        <h5><i class="bi bi-list-check"></i> How to Pay:</h5>
        <div class="payment-step">
            <div class="step-number">1</div>
            <div>
                <strong>Click "Pay with Razorpay"</strong>
                <p class="mb-0 text-muted">Enter your billing details and proceed</p>
            </div>
        </div>
        <div class="payment-step">
            <div class="step-number">2</div>
            <div>
                <strong>Choose Payment Method</strong>
                <p class="mb-0 text-muted">Select Credit/Debit Card, UPI, NetBanking or Wallet</p>
            </div>
        </div>
        <div class="payment-step">
            <div class="step-number">3</div>
            <div>
                <strong>Complete Payment</strong>
                <p class="mb-0 text-muted">Enter your payment details securely</p>
            </div>
        </div>
        <div class="payment-step">
            <div class="step-number">4</div>
            <div>
                <strong>Order Confirmation</strong>
                <p class="mb-0 text-muted">You'll be redirected to order confirmation page</p>
            </div>
        </div>
    </div>

    <!-- Payment Information -->
    <div class="payment-info">
        <div class="row align-items-center">
            <div class="col-md-6">
                <img src="https://razorpay.com/assets/razorpay-logo-black.svg" 
                     class="razorpay-logo" alt="Razorpay">
                <h5>Secure Payment Gateway</h5>
                <p class="text-muted">
                    <i class="bi bi-shield-check text-success"></i> PCI DSS Compliant<br>
                    <i class="bi bi-lock text-success"></i> 256-bit SSL Encryption<br>
                    <i class="bi bi-check-circle text-success"></i> Trusted by 5M+ businesses
                </p>
            </div>
            <div class="col-md-6">
                <div class="card">
                    <div class="card-header bg-light">
                        <h5 class="mb-0"><i class="bi bi-receipt"></i> Order Summary</h5>
                    </div>
                    <div class="card-body">
                        <div class="d-flex justify-content-between mb-2">
                            <span>Subtotal (<%= cartItemCount %> items)</span>
                            <span>₹<%= String.format("%.2f", subtotal) %></span>
                        </div>
                        <div class="d-flex justify-content-between mb-2">
                            <span>Shipping</span>
                            <span><%= shipping == 0 ? "FREE" : "₹" + String.format("%.2f", shipping) %></span>
                        </div>
                        <div class="d-flex justify-content-between mb-2">
                            <span>Tax (10%)</span>
                            <span>₹<%= String.format("%.2f", tax) %></span>
                        </div>
                        <hr>
                        <div class="d-flex justify-content-between fw-bold fs-5">
                            <span>Total Amount</span>
                            <span>₹<%= String.format("%.2f", total) %></span>
                        </div>
                        <input type="hidden" id="totalAmountValue" value="<%= total %>">
                    </div>
                </div>
            </div>
        </div>
    </div>

    <!-- Payment Options -->
    <div class="mb-4">
        <h5><i class="bi bi-credit-card-2-front"></i> Select Payment Option</h5>
        <div class="payment-options">
            <div class="payment-option selected" onclick="selectPayment('online')" id="onlineOption">
                <div class="payment-icon">
                    <i class="bi bi-credit-card"></i>
                </div>
                <h6>Online Payment</h6>
                <small class="text-muted">Credit/Debit Card, UPI, NetBanking</small>
            </div>
            <div class="payment-option" onclick="selectPayment('cod')" id="codOption">
                <div class="payment-icon">
                    <i class="bi bi-cash"></i>
                </div>
                <h6>Cash on Delivery</h6>
                <small class="text-muted">Pay when you receive</small>
            </div>
        </div>
    </div>

    <!-- Terms and Conditions -->
    <div class="form-check mb-4">
        <input class="form-check-input" type="checkbox" id="agreeTerms" required>
        <label class="form-check-label" for="agreeTerms">
            I agree to the <a href="#" data-bs-toggle="modal" data-bs-target="#termsModal">Terms and Conditions</a>
            and authorize the payment
        </label>
    </div>

    <!-- Pay Now Button -->
    <div class="d-grid gap-2">
        <button type="button" class="btn btn-primary btn-lg" onclick="initiatePayment()" id="payButton">
            <i class="bi bi-lock-fill"></i> Pay with Razorpay - ₹<%= String.format("%.2f", total) %>
        </button>
        <button type="button" class="btn btn-outline-secondary" onclick="window.history.back()">
            <i class="bi bi-arrow-left"></i> Back to Cart
        </button>
    </div>

    <!-- Payment Processing -->
    <div class="payment-process" id="paymentProcess">
        <div class="loader"></div>
        <h4>Processing Payment...</h4>
        <p class="text-muted">Please wait while we connect to Razorpay</p>
        <div class="progress">
            <div class="progress-bar progress-bar-striped progress-bar-animated" style="width: 100%"></div>
        </div>
    </div>

    <!-- Security Info -->
    <div class="alert alert-light border mt-4">
        <div class="d-flex align-items-center">
            <i class="bi bi-shield-check text-success fs-4 me-3"></i>
            <div>
                <h6 class="mb-1">Your payment is secure</h6>
                <p class="mb-0 small text-muted">
                    All transactions are secured with 256-bit SSL encryption. 
                    Your card details are never stored on our servers.
                </p>
            </div>
        </div>
    </div>
</div>

<!-- Terms Modal -->
<div class="modal fade" id="termsModal" tabindex="-1">
    <div class="modal-dialog">
        <div class="modal-content">
            <div class="modal-header">
                <h5 class="modal-title">Payment Terms</h5>
                <button type="button" class="btn-close" data-bs-dismiss="modal"></button>
            </div>
            <div class="modal-body">
                <p>By proceeding with payment, you agree to:</p>
                <ul>
                    <li>Complete the transaction for the amount shown</li>
                    <li>Authorize payment through Razorpay's secure gateway</li>
                    <li>Accept our refund and cancellation policy</li>
                    <li>Provide accurate billing information</li>
                </ul>
                <p><strong>Note:</strong> You will be redirected to Razorpay's secure payment page to complete the transaction.</p>
            </div>
            <div class="modal-footer">
                <button type="button" class="btn btn-primary" data-bs-dismiss="modal">I Understand</button>
            </div>
        </div>
    </div>
</div>

<!-- Footer -->
<footer class="bg-light mt-5 py-4 border-top">
    <div class="container text-center">
        <p class="mb-0">&copy; 2024 Ecommerce.org. All rights reserved.</p>
    </div>
</footer>


<script src="js/bootstrap.bundle.min.js"></script>
<script>
// Global variables
let selectedPaymentMethod = 'online';
let totalAmount = parseFloat(document.getElementById('totalAmountValue').value);

// Select payment method
function selectPayment(method) {
    selectedPaymentMethod = method;
    
    // Update UI
    document.querySelectorAll('.payment-option').forEach(option => {
        option.classList.remove('selected');
    });
    document.getElementById(method + 'Option').classList.add('selected');
    
    // Update button text
    const payButton = document.getElementById('payButton');
    if(method === 'online') {
        payButton.innerHTML = `<i class="bi bi-lock-fill"></i> Pay with Razorpay - ₹${totalAmount.toFixed(2)}`;
        payButton.className = 'btn btn-primary btn-lg';
    } else {
        payButton.innerHTML = `<i class="bi bi-check-circle"></i> Place COD Order - ₹${totalAmount.toFixed(2)}`;
        payButton.className = 'btn btn-success btn-lg';
    }
}

// Show payment processing
function showProcessing() {
    document.getElementById('paymentProcess').style.display = 'block';
    document.getElementById('payButton').style.display = 'none';
}

// Hide payment processing
function hideProcessing() {
    document.getElementById('paymentProcess').style.display = 'none';
    document.getElementById('payButton').style.display = 'block';
}

// Main payment initiation function
async function initiatePayment() {
    // Validate terms
    if(!document.getElementById('agreeTerms').checked) {
        alert('Please agree to the Terms and Conditions to proceed');
        return;
    }
    
    if(selectedPaymentMethod === 'cod') {
        // Handle COD payment
        if(confirm(`Place Cash on Delivery order for ₹${totalAmount.toFixed(2)}?\n\nYou will pay when the order is delivered.`)) {
            showProcessing();
            await processCOD();
        }
        return;
    }
    
    // For online payment
    showProcessing();
    
    try {
        // Step 1: Get user details
        const userDetails = {
            name: '<%= firstName + " " + lastName %>',
            email: '<%= userEmail %>',
            phone: '<%= session.getAttribute("phone") != null ? session.getAttribute("phone") : "9999999999" %>',
            amount: Math.round(totalAmount * 100), // Convert to paise
            userId: <%= userId %>
        };
        
        console.log('Creating order for amount:', userDetails.amount, 'paise');
        
        // Step 2: Create order on your server
        const orderResponse = await fetch('CreateRazorpayOrderServlet', {
            method: 'POST',
            headers: {
                'Content-Type': 'application/x-www-form-urlencoded',
            },
            body: new URLSearchParams({
                'amount': userDetails.amount.toString(),
                'currency': 'INR',
                'customer_name': userDetails.name,
                'customer_email': userDetails.email,
                'customer_phone': userDetails.phone,
                'user_id': userDetails.userId.toString()
            })
        });
        
        const orderText = await orderResponse.text();
        console.log('Order response:', orderText);
        const orderData = JSON.parse(orderText);
        
        if(!orderData.success) {
            throw new Error(orderData.message || 'Failed to create payment order');
        }
        
        console.log('Order created successfully:', orderData);
        
        // Step 3: Initialize Razorpay Checkout
        const options = {
            key: orderData.razorpayKey || 'rzp_test_qwUWbYhsbam1oJ', // You'll set this in servlet
            amount: orderData.amount,
            currency: orderData.currency || 'INR',
            name: 'Your Ecommerce Store',
            description: 'Order Payment',
            order_id: orderData.orderId,
            handler: async function(response) {
                console.log('Payment successful response:', response);
                
                // Update UI to show verification
                document.getElementById('paymentProcess').innerHTML = `
                    <div class="loader"></div>
                    <h4 class="mt-3">Verifying Payment...</h4>
                    <p>Please wait while we verify your payment</p>
                    <div class="progress">
                        <div class="progress-bar progress-bar-striped progress-bar-animated" style="width: 100%"></div>
                    </div>
                `;
                
                // Verify payment
                try {
                    const verifyResponse = await fetch('VerifyPaymentServlet', {
                        method: 'POST',
                        headers: {
                            'Content-Type': 'application/x-www-form-urlencoded',
                        },
                        body: new URLSearchParams({
                            'razorpay_order_id': response.razorpay_order_id,
                            'razorpay_payment_id': response.razorpay_payment_id,
                            'razorpay_signature': response.razorpay_signature,
                            'order_id': orderData.orderId,
                            'amount': orderData.amount.toString(),
                            'user_id': userDetails.userId.toString()
                        })
                    });
                    
                    const verifyText = await verifyResponse.text();
                    console.log('Verification response:', verifyText);
                    const verifyData = JSON.parse(verifyText);
                    
                    if(verifyData.success) {
                        // Payment verified successfully
                        document.getElementById('paymentProcess').innerHTML = `
                            <i class="bi bi-check-circle text-success" style="font-size: 3rem;"></i>
                            <h4 class="mt-3">Payment Successful!</h4>
                            <p>Your payment has been verified.</p>
                            <p>Redirecting to order confirmation...</p>
                        `;
                        
                        // Redirect to order confirmation
                        setTimeout(() => {
                            window.location.href = 'order-confirmation.jsp?order_id=' + verifyData.orderId;
                        }, 2000);
                        
                    } else {
                        throw new Error(verifyData.message || 'Payment verification failed');
                    }
                    
                } catch (verifyError) {
                    console.error('Verification error:', verifyError);
                    document.getElementById('paymentProcess').innerHTML = `
                        <i class="bi bi-exclamation-triangle text-warning" style="font-size: 3rem;"></i>
                        <h4 class="mt-3">Payment Completed but Verification Pending</h4>
                        <p>Your payment was successful but verification is pending.</p>
                        <p>Order ID: ${orderData.orderId}</p>
                        <button class="btn btn-primary mt-3" onclick="window.location.href='orders.jsp'">View Orders</button>
                    `;
                }
            },
            prefill: {
                name: userDetails.name,
                email: userDetails.email,
                contact: userDetails.phone
            },
            theme: {
                color: '#0d6efd'
            },
            modal: {
                ondismiss: function() {
                    console.log('Payment modal closed by user');
                    hideProcessing();
                }
            },
            notes: {
                order_type: 'ecommerce_payment',
                user_id: userDetails.userId.toString()
            }
        };
        
        const rzp = new Razorpay(options);
        rzp.open();
        
    } catch (error) {
        console.error('Payment initiation error:', error);
        hideProcessing();
        alert('Payment Error: ' + error.message);
    }
}

// Process COD order
async function processCOD() {
    try {
        const codResponse = await fetch('ProcessOrderServlet', {
            method: 'POST',
            headers: {
                'Content-Type': 'application/x-www-form-urlencoded',
            },
            body: new URLSearchParams({
                'payment_method': 'cod',
                'total_amount': totalAmount.toString(),
                'user_id': '<%= userId %>'
            })
        });
        
        const codData = await codResponse.json();
        
        if(codData.success) {
            // Show success
            document.getElementById('paymentProcess').innerHTML = `
                <i class="bi bi-check-circle text-success" style="font-size: 3rem;"></i>
                <h4 class="mt-3">COD Order Placed Successfully!</h4>
                <p>Your order ID: ${codData.orderId}</p>
                <p>You'll pay ₹${totalAmount.toFixed(2)} when you receive the order.</p>
                <p>Redirecting to order details...</p>
            `;
            
            // Redirect
            setTimeout(() => {
                window.location.href = 'order-confirmation.jsp?order_id=' + codData.orderId;
            }, 2000);
            
        } else {
            throw new Error(codData.message || 'Failed to place COD order');
        }
        
    } catch (error) {
        console.error('COD error:', error);
        document.getElementById('paymentProcess').innerHTML = `
            <i class="bi bi-x-circle text-danger" style="font-size: 3rem;"></i>
            <h4 class="mt-3">Order Failed</h4>
            <p>${error.message}</p>
            <button class="btn btn-primary mt-3" onclick="hideProcessing()">Try Again</button>
        `;
    }
}

// Initialize
document.addEventListener('DOMContentLoaded', function() {
    console.log('Payment page loaded');
    console.log('Total amount:', totalAmount);
    console.log('User ID:', <%= userId %>);
    
    // Check if Razorpay is loaded
    if(typeof Razorpay === 'undefined') {
        console.error('Razorpay script not loaded!');
        alert('Payment gateway not loaded. Please refresh the page.');
    } else {
        console.log('Razorpay loaded successfully');
    }
});
</script>




</body>
</html>