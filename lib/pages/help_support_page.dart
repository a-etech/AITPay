import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class HelpSupportPage extends StatelessWidget {
  // Method to launch the URL using url_launcher
  Future<void> _launchHelpDeskUrl() async {
    final Uri url = Uri.parse('https://helpdesk.ait-ext.com/');
    if (await canLaunchUrl(url)) {
      await launchUrl(
        url,
        mode: LaunchMode.externalApplication, // Opens the URL in an external browser
      );
    } else {
      // Handle the error when URL can't be launched
      throw 'Could not launch $url';
    }
  }

  @override
  Widget build(BuildContext context) {
    // Launch the URL when the widget is built
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await _launchHelpDeskUrl();
      Navigator.pop(context); // Close the page after the URL is launched
    });

    return Scaffold(
      appBar: AppBar(
        title: const Text('Help & Support'),
      ),
      body: const Center(
        child: CircularProgressIndicator(), // Show loading while the URL is launching
      ),
    );
  }
}
