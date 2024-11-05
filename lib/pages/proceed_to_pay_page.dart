import 'package:flutter/material.dart';
import 'payment_page.dart';

class ProceedToPayPage extends StatefulWidget {
  const ProceedToPayPage({super.key});

  @override
  _ProceedToPayPageState createState() => _ProceedToPayPageState();
}

class _ProceedToPayPageState extends State<ProceedToPayPage> {
  final _formKey = GlobalKey<FormState>();
  String _studentID = '';
  String? _level;
  String? _semester;
  String? _paymentOption;
  double _amountToPay = 0.0;

  final List<String> _levels = ['100', '200', '300', '400'];
  final List<String> _semesters = ['1st', '2nd'];
  final List<String> _paymentOptions = ['50%', '75%', 'Full Fee'];

  double _calculateTotalFee() {
    if (_studentID.toLowerCase().startsWith('ads')) {
      return 2000.0;
    } else if (_studentID.toLowerCase().startsWith('abs')) {
      return 2500.0;
    } else if (_studentID.toLowerCase().startsWith('eng')) {
      return 3000.0;
    }
    return 0.0;
  }

  void _updateAmountToPay(String? option) {
    double totalFee = _calculateTotalFee();
    switch (option) {
      case '50%':
        _amountToPay = totalFee * 0.50;
        break;
      case '75%':
        _amountToPay = totalFee * 0.75;
        break;
      case 'Full Fee':
        _amountToPay = totalFee;
        break;
      default:
        _amountToPay = 0.0;
    }
    setState(() {});

    // Show balance alert if payment option is selected
    if (option != null && option != 'None') {
      _showBalanceAlert(totalFee, _amountToPay);
    }
  }

  void _showBalanceAlert(double totalFee, double amountToPay) {
    double balance = totalFee - amountToPay;
    String message = balance > 0
        ? 'Your remaining balance for this semester is GHS ${balance.toStringAsFixed(2)}'
        : 'You are paying the full amount for this semester.';

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Payment Information'),
          content: Text(message),
          actions: <Widget>[
            TextButton(
              child: const Text('OK'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Theme.of(context).colorScheme.primary,
        title: const Text(
          'Student Fee Payment',
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
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header Section
                  const Text(
                    'Payment Details',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Please fill in your details to proceed with the payment',
                    style: TextStyle(
                      color: Colors.grey[800],
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 32),

                  // Student ID field
                  TextFormField(
                    decoration: InputDecoration(
                      labelText: 'Student ID',
                      prefixIcon: const Icon(Icons.person_outline),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      filled: true,
                      fillColor: Colors.white,
                    ),
                    onChanged: (value) {
                      setState(() {
                        _studentID = value;
                      });
                    },
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your Student ID';
                      }
                      if (!RegExp(r'^(ads|abs|eng)[a-zA-Z0-9]*$').hasMatch(value)) {
                        return 'Student ID must start with "ads", "abs", or "eng"';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 24),

                  // Level dropdown
                  DropdownButtonFormField<String>(
                    decoration: InputDecoration(
                      labelText: 'Level',
                      prefixIcon: const Icon(Icons.school_outlined),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      filled: true,
                      fillColor: Colors.white,
                    ),
                    value: _level,
                    items: _levels.map((String level) {
                      return DropdownMenuItem<String>(
                        value: level,
                        child: Text(level),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        _level = value;
                      });
                    },
                    validator: (value) => value == null ? 'Please select your level' : null,
                  ),
                  const SizedBox(height: 24),

                  // Semester dropdown
                  DropdownButtonFormField<String>(
                    decoration: InputDecoration(
                      labelText: 'Semester',
                      prefixIcon: const Icon(Icons.calendar_today_outlined),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      filled: true,
                      fillColor: Colors.white,
                    ),
                    value: _semester,
                    items: _semesters.map((String semester) {
                      return DropdownMenuItem<String>(
                        value: semester,
                        child: Text(semester),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        _semester = value;
                      });
                    },
                    validator: (value) => value == null ? 'Please select your semester' : null,
                  ),
                  const SizedBox(height: 24),

                  // Payment option dropdown
                  DropdownButtonFormField<String>(
                    decoration: InputDecoration(
                      labelText: 'Payment Option',
                      prefixIcon: const Icon(Icons.payment_outlined),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      filled: true,
                      fillColor: Colors.white,
                    ),
                    value: _paymentOption,
                    items: _paymentOptions.map((String option) {
                      return DropdownMenuItem<String>(
                        value: option,
                        child: Text(option),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        _paymentOption = value;
                        _updateAmountToPay(value);
                      });
                    },
                    validator: (value) => value == null ? 'Please select a payment option' : null,
                  ),
                  const SizedBox(height: 12),

                  // Amount to pay card
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: Theme.of(context).colorScheme.primary.withOpacity(0.2),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Amount to Pay:',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        Text(
                          'GHS ${_amountToPay.toStringAsFixed(2)}',
                          style: TextStyle(
                            fontSize: 19,
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),

                  // Proceed button
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      onPressed: () {
                        if (_formKey.currentState!.validate()) {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => PaymentPage(
                                studentID: _studentID,
                                level: _level!,
                                semester: _semester!,
                                amountToPay: _amountToPay,
                              ),
                            ),
                          );
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        foregroundColor: Colors.white,
                        backgroundColor: Theme.of(context).colorScheme.primary,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 2,
                      ),
                      child: const Text(
                        'Proceed to Pay',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
