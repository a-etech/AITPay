import 'package:flutter/material.dart';

class PaymentResultPage extends StatelessWidget {
  final bool paymentSuccess;
  final String studentID;
  final double amountToPay;

  const PaymentResultPage({
    super.key,
    required this.paymentSuccess,
    required this.studentID,
    required this.amountToPay,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Payment Result')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(paymentSuccess ? 'Payment Successful!' : 'Payment Failed!'),
            const SizedBox(height: 20),
            Text('Student ID: $studentID'),
            Text('Amount Paid: GHS$amountToPay'),
          ],
        ),
      ),
    );
  }
}
