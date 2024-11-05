import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class ScheduleOfFeePage extends StatelessWidget {
  const ScheduleOfFeePage({super.key});

  // Method to launch the Schedule of Fees URL
  Future<void> _launchScheduleOfFeeUrl() async {
    final Uri url = Uri.parse('https://ait.edu.gh/schedule-of-fees/');
    if (await canLaunchUrl(url)) {
      await launchUrl(
        url,
        mode: LaunchMode.externalApplication, // Opens the URL in an external browser
      );
    } else {
      throw 'Could not launch $url';
    }
  }

  @override
  Widget build(BuildContext context) {
    // Launch the URL when the widget is built
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await _launchScheduleOfFeeUrl();
      Navigator.pop(context); // Close the page after the URL is launched
    });

    return Scaffold(
      appBar: AppBar(
        title: const Text('Schedule of Fees'),
        backgroundColor: Colors.teal,
      ),
      body: const Center(
        child: CircularProgressIndicator(), // Show loading indicator while URL is launching
      ),
    );
  }
}
