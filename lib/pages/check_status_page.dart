import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:pdf/pdf.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:share_plus/share_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'package:printing/printing.dart';

class CheckStatusPage extends StatefulWidget {
  final String paymentReference;
  final double amountToPay;
  final String paymentMethod;

  const CheckStatusPage({
    super.key,
    required this.paymentReference,
    required this.amountToPay,
    required this.paymentMethod,
  });

  @override
  _CheckStatusPageState createState() => _CheckStatusPageState();
}

class _CheckStatusPageState extends State<CheckStatusPage> {
  Map<String, dynamic>? _paymentDetails;

  @override
  void initState() {
    super.initState();
    _loadPaymentDetails();
  }

  Future<void> _loadPaymentDetails() async {
    final prefs = await SharedPreferences.getInstance();
    String? paymentData = prefs.getString('last_payment_details');

    if (paymentData == null) {
      _showNoPaymentDialog();
    } else {
      setState(() {
        _paymentDetails = {
          'details': paymentData,
          'reference': widget.paymentReference,
          'amountToPay': widget.amountToPay,
          'paymentMethod': widget.paymentMethod,
        };
      });
    }
  }

  void _showNoPaymentDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('No Payment Found'),
          content: const Text('Please make a payment before checking your status.'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _printPaymentDetails() async {
    if (_paymentDetails != null) {
      await Printing.layoutPdf(
        onLayout: (PdfPageFormat format) async {
          final pdf = await _generatePdf();
          return pdf.save();
        },
      );
    }
  }

  Future<void> _sharePaymentDetails() async {
    if (_paymentDetails != null) {
      final details = '''
      Payment Reference: ${_paymentDetails!['reference']}
      Amount: GHS ${_paymentDetails!['amountToPay']}
      Payment Method: ${_paymentDetails!['paymentMethod']}
      Details: ${_paymentDetails!['details']}
      ''';

      await Share.share(details);
    }
  }

  Future<void> _downloadPaymentDetails() async {
    if (_paymentDetails != null) {
      final directory = await getApplicationDocumentsDirectory();
      final filePath = '${directory.path}/payment_details.txt';
      final file = File(filePath);

      await file.writeAsString('''
      Payment Reference: ${_paymentDetails!['reference']}
      Amount: GHS ${_paymentDetails!['amountToPay']}
      Payment Method: ${_paymentDetails!['paymentMethod']}
      Details: ${_paymentDetails!['details']}
      ''');

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Payment details saved to: $filePath')),
      );
    }
  }

  Future<PdfDocument> _generatePdf() async {
    // Implement PDF generation logic here
    // You can use the pdf package to create a PDF
    final pdf = PdfDocument();

    // Example: Create a PDF page with the payment details
    final page = pdf.pages.add();
    page.graphics.drawString('Payment Reference: ${_paymentDetails!['reference']}', PdfStandardFont(PdfFontFamily.helvetica, 12));
    page.graphics.drawString('Amount: GHS ${_paymentDetails!['amountToPay']}', PdfStandardFont(PdfFontFamily.helvetica, 12));
    page.graphics.drawString('Payment Method: ${_paymentDetails!['paymentMethod']}', PdfStandardFont(PdfFontFamily.helvetica, 12));
    page.graphics.drawString('Details: ${_paymentDetails!['details']}', PdfStandardFont(PdfFontFamily.helvetica, 12));

    return pdf;
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        Navigator.of(context).pushNamedAndRemoveUntil('/home', (route) => false);
        return false;
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Payment Status'),
          actions: [
            IconButton(
              icon: const Icon(Icons.print),
              onPressed: _printPaymentDetails,
              tooltip: 'Print',
            ),
            IconButton(
              icon: const Icon(Icons.download),
              onPressed: _downloadPaymentDetails,
              tooltip: 'Download',
            ),
            IconButton(
              icon: const Icon(Icons.share),
              onPressed: _sharePaymentDetails,
              tooltip: 'Share',
            ),
          ],
        ),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: _paymentDetails == null
              ? const Center(child: CircularProgressIndicator())
              : Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Payment Reference: ${_paymentDetails!['reference']}',
                style: const TextStyle(fontSize: 18),
              ),
              const SizedBox(height: 16),
              Text(
                'Amount: GHS ${_paymentDetails!['amountToPay']}',
                style: const TextStyle(fontSize: 18),
              ),
              const SizedBox(height: 16),
              Text(
                'Payment Method: ${_paymentDetails!['paymentMethod']}',
                style: const TextStyle(fontSize: 18),
              ),
              const SizedBox(height: 16),
              Text(
                'Details: ${_paymentDetails!['details']}',
                style: const TextStyle(fontSize: 18),
              ),
            ],
          ),
        ),
      ),
    );
  }

  PdfStandardFont(helvetica, int i) {}
}

class PdfFontFamily {
  static var helvetica;
}

extension on PdfDocument {
  get pages => null;
}
