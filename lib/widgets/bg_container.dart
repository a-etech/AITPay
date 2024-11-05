import 'package:flutter/material.dart';

class BackgroundContainer extends StatelessWidget {
  final Widget child;
  final double opacity;

  const BackgroundContainer({super.key, required this.child, this.opacity = 0.5});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Opacity(
          opacity: opacity,
          child: Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/ait.jpg'), // Make sure this path is correct
                fit: BoxFit.cover, // Ensures the image covers the entire page
              ),
            ),
          ),
        ),
        child, // The page content goes here
      ],
    );
  }
}
