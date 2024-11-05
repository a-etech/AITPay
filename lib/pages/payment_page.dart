import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_paystack/flutter_paystack.dart';
import 'check_status_page.dart'; // Import your CheckStatusPage

class PaymentPage extends StatefulWidget {
  final String studentID;
  final String level;
  final String semester;
  final double amountToPay;

  const PaymentPage({
    super.key,
    required this.studentID,
    required this.level,
    required this.semester,
    required this.amountToPay,
  });

  @override
  _PaymentPageState createState() => _PaymentPageState();
}

class _PaymentPageState extends State<PaymentPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _paymentReferenceController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final _paystackPlugin = PaystackPlugin();

  String _selectedPaymentMethod = 'card';
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _paystackPlugin.initialize(publicKey: 'pk_test_a5536162b17f636c053f6f15495f4b56548feafe');
  }

  Future<void> _savePaymentDetails(bool paymentSuccess, String paymentReference) async {
    final paymentData = {
      'studentID': widget.studentID,
      'level': widget.level,
      'semester': widget.semester,
      'amountToPay': widget.amountToPay,
      'paymentSuccess': paymentSuccess,
      'paymentReference': paymentReference,
      'selectedPaymentMethod': _selectedPaymentMethod, // Save selected payment method
      'timestamp': FieldValue.serverTimestamp(),
    };

    await FirebaseFirestore.instance.collection('payments').add(paymentData);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('last_payment_details', paymentData.toString());
  }

  Future<void> _startPayment() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });
      try {
        final charge = Charge()
          ..amount = (widget.amountToPay * 100).toInt()
          ..email = _emailController.text
          ..currency = 'GHS'
          ..reference = DateTime.now().millisecondsSinceEpoch.toString();

        final response = await _paystackPlugin.checkout(
          context,
          charge: charge,
          method: CheckoutMethod.card,
          logo: Container(
            height: 50,
            width: 50,
            child: Image.asset('assets/logo.png'),
          ),
        );

        if (response.status) {
          await _savePaymentDetails(true, charge.reference!);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Payment successful!'),
              backgroundColor: Colors.green,
            ),
          );

          // Navigate to CheckStatusPage with the payment details
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => CheckStatusPage(
                paymentReference: charge.reference!,
                amountToPay: widget.amountToPay,
                paymentMethod: _selectedPaymentMethod, // Pass the selected payment method
              ),
            ),
          );

        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Payment failed. Please try again.'),
              backgroundColor: Colors.red,
            ),
          );
        }

      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error occurred: $e'),
            backgroundColor: Colors.red,
          ),
        );
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Theme.of(context).colorScheme.primary,
        title: const Text(
          'Payment Details',
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Theme.of(context).colorScheme.primary.withOpacity(0.1),
              Colors.white,
            ],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildStudentInfo(),
                    const SizedBox(height: 24),
                    _buildPaymentMethodSelection(),
                    const SizedBox(height: 24),
                    _buildPaymentDetails(),
                    const SizedBox(height: 32),
                    _buildSubmitButton(),
                    if (_isLoading)
                      Container(
                        margin: const EdgeInsets.only(top: 20),
                        child: const Center(
                          child: CircularProgressIndicator(),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

Widget _buildStudentInfo() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 2,
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Student Information',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          _buildInfoRow(Icons.person_outline, 'Student ID', widget.studentID),
          _buildInfoRow(Icons.school_outlined, 'Level', widget.level),
          _buildInfoRow(Icons.calendar_today_outlined, 'Semester', widget.semester),
          const Divider(height: 24),
          _buildInfoRow(
            Icons.payments_outlined,
            'Amount to Pay',
            'GHS ${widget.amountToPay.toStringAsFixed(2)}',
            isAmount: true,
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value, {bool isAmount = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, size: 20, color: Colors.grey[600]),
          const SizedBox(width: 12),
          Text(
            '$label:',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[600],
            ),
          ),
          const Spacer(),
          Text(
            value,
            style: TextStyle(
              fontSize: isAmount ? 18 : 16,
              fontWeight: isAmount ? FontWeight.bold : FontWeight.w500,
              color: isAmount ? Theme.of(context).colorScheme.primary : Colors.black87,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentMethodSelection() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 2,
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Payment Method',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          DropdownButtonFormField<String>(
            value: _selectedPaymentMethod,
            decoration: InputDecoration(
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.grey.shade300),
              ),
              filled: true,
              fillColor: Colors.grey.shade50,
            ),
            items: [
              _buildPaymentMethodItem('card', 'Credit/Debit Card', Icons.credit_card, Colors.blue),
              _buildPaymentMethodItem('bank', 'Bank Transfer', Icons.account_balance, Colors.green),
              _buildPaymentMethodItem('mobile_money', 'Mobile Money', Icons.phone_android, Colors.orange),
            ],
            onChanged: (value) {
              setState(() {
                _selectedPaymentMethod = value!;
              });
            },
          ),
        ],
      ),
    );
  }

  DropdownMenuItem<String> _buildPaymentMethodItem(
      String value, String label, IconData icon, Color color) {
    return DropdownMenuItem<String>(
      value: value,
      child: Row(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(width: 12),
          Text(
            label,
            style: const TextStyle(
              color: Colors.black87,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentDetails() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 2,
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Payment Details',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _emailController,
            decoration: InputDecoration(
              labelText: 'Email Address',
              prefixIcon: const Icon(Icons.email_outlined),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.grey.shade300),
              ),
              filled: true,
              fillColor: Colors.grey.shade50,
            ),
            validator: (value) => value == null || value.isEmpty ? 'Please enter your email' : null,
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _paymentReferenceController,
            decoration: InputDecoration(
              labelText: 'Payment Reference',
              prefixIcon: const Icon(Icons.receipt_outlined),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.grey.shade300),
              ),
              filled: true,
              fillColor: Colors.grey.shade50,
            ),
            validator: (value) => value == null || value.isEmpty ? 'Please enter payment reference' : null,
          ),
        ],
      ),
    );
  }

  Widget _buildSubmitButton() {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: _isLoading ? null : _startPayment,
        style: ElevatedButton.styleFrom(
          foregroundColor: Colors.white,
          backgroundColor: Theme.of(context).colorScheme.primary,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 2,
        ),
        child: Text(
          _isLoading ? 'Processing...' : 'Complete Payment',
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}

