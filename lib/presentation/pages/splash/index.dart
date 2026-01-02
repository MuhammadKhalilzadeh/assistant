import 'package:assistant/presentation/constants/ui.dart';
import 'package:flutter/material.dart';

class SplashPage extends StatelessWidget {
  const SplashPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: primaryColor,
      body: Stack(
        children: [
          Center(
            child: Text(
              'Jarvis',
              style: TextStyle(
                fontSize: 54,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: const EdgeInsets.only(bottom: 64.0),
              child: RichText(
                text: TextSpan(
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.white70,
                  ),
                  children: [
                    const TextSpan(text: 'Powered by '),
                    TextSpan(
                      text: 'CiviTech Global',
                      style: const TextStyle(fontWeight: FontWeight.w900),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}