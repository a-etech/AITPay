import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class CheckRegistrationPage extends StatelessWidget {
  const CheckRegistrationPage({super.key});

  // Method to launch the URL using launchUrl with error handling
  Future<void> _launchLemsasUrl(BuildContext context) async {
    final Uri url = Uri.parse(Uri.encodeFull('https://www.lemsas.net/')); // Ensure HTTPS is used and properly encoded

    try {
      if (await canLaunchUrl(url)) {
        await launchUrl(
          url,
          mode: LaunchMode.externalApplication, // Ensure the URL opens in an external browser
        );
      } else {
        throw 'Could not launch $url';
      }
    } catch (e) {
      // Handle the error appropriately in production
      // Show a Snackbar to inform the user of the error
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error launching URL: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // Launch the URL when the widget is built
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await _launchLemsasUrl(context);
      await Future.delayed(const Duration(seconds: 1)); // Delay before navigating back
      Navigator.pop(context); // Navigate back after launching URL
    });

    return Scaffold(
      appBar: AppBar(
        title: const Text('Check Registration'),
      ),
      body: const Center(
        child: CircularProgressIndicator(), // Show a loading indicator while launching URL
      ),
    );
  }
}
