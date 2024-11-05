import 'package:flutter/material.dart';
import '../widgets/bg_container.dart';

class WelcomePage extends StatelessWidget {
  const WelcomePage({super.key, required void Function(bool value) toggleTheme});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BackgroundContainer(
        opacity: 0.3,
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                const Text(
                  'Welcome to AITPay!',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 36,
                    fontWeight: FontWeight.bold,
                    color: Colors.deepPurple,
                  ),
                ),
                const SizedBox(height: 20),
                const Text(
                  'The easiest way to manage your payments at AIT University',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 50),
                ElevatedButton.icon(
                  icon: const Icon(Icons.login, size: 24),
                  label: const Text('Login'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 15.0),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30.0),
                    ),
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                    textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  onPressed: () {
                    Navigator.pushNamed(context, '/login');
                  },
                ),
                const SizedBox(height: 20),
                ElevatedButton.icon(
                  icon: const Icon(Icons.person_add, size: 24),
                  label: const Text('Register'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 15.0),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30.0),
                    ),
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                    textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  onPressed: () {
                    Navigator.pushNamed(context, '/registration');
                  },
                ),
                const SizedBox(height: 40),
                TextButton(
                  child: const Text(
                    'Learn More',
                    style: TextStyle(color: Colors.deepPurple, fontSize: 16),
                  ),
                  onPressed: () {
                    _showLearnMoreDialog(context);
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showLearnMoreDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Learn More about AITPay'),
          content: const SingleChildScrollView(
            child: Text(
              'AITPay is designed to streamline your payment processes at AIT University. '
                  'With AITPay, you can:\n\n'
                  '- Manage your course fees efficiently.\n'
                  '- Choose your preferred mode of payment, including bank transfers or mobile money.\n'
                  '- Easily track your payment history and receipts.\n'
                  '- Enjoy a user-friendly interface for a seamless experience.\n\n'
                  'Join us today and take the stress out of managing your university payments!',
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Close'),
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
            ),
          ],
        );
      },
    );
  }
}
