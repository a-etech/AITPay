import 'package:flutter/material.dart';

class PaymentMethodPage extends StatelessWidget {
  final ValueChanged<String> onPaymentMethodSelected;

  const PaymentMethodPage({super.key, required this.onPaymentMethodSelected});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Select Payment Method')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ListTile(
              title: const Text('Card Payment'),
              leading: const Icon(Icons.credit_card),
              onTap: () {
                onPaymentMethodSelected('Card');
                Navigator.pop(context);
              },
            ),
            ListTile(
              title: const Text('Bank Transfer'),
              leading: const Icon(Icons.account_balance),
              onTap: () {
                onPaymentMethodSelected('Bank Transfer');
                Navigator.pop(context);
              },
            ),
            ListTile(
              title: const Text('Mobile Money'),
              leading: const Icon(Icons.money),
              onTap: () {
                onPaymentMethodSelected('Mobile Money');
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }
}
