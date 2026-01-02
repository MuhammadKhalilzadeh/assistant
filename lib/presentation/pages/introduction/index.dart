import 'package:assistant/presentation/constants/ui.dart';
import 'package:assistant/presentation/widgets/textfields/custom_text_field.dart';
import 'package:assistant/presentation/widgets/buttons/custom_button.dart';
import 'package:assistant/presentation/pages/gmail_connection/index.dart';
import 'package:flutter/material.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  // Controller for nickname text field
  final _nicknameController = TextEditingController();

  @override
  void dispose() {
    // Clean up controller
    _nicknameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: primaryColor,
      body: SafeArea(
        child: Stack(
          children: [
            // Main content
            Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Big text above the input field
                    Text(
                      'What would you like me to call you?',
                      style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 40),
                    // Nickname input field
                    CustomTextField(
                      hint: 'Enter your nickname',
                      controller: _nicknameController,
                      prefixIcon: Icons.person,
                    ),
                  ],
                ),
              ),
            ),
            // Next button in bottom right
            Positioned(
              bottom: 24,
              right: 24,
              child: CustomButton(
                text: 'Continue',
                onPressed: () {
                  final nickname = _nicknameController.text;
                  if (nickname.isNotEmpty) {
                    // Navigate to Gmail connection page
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const GmailConnectionPage(),
                      ),
                    );
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}