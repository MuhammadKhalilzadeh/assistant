import 'package:assistant/presentation/constants/ui.dart';
import 'package:assistant/presentation/widgets/buttons/custom_button.dart';
import 'package:assistant/services/auth_service.dart';
import 'package:flutter/material.dart';

class GmailConnectionPage extends StatefulWidget {
  const GmailConnectionPage({super.key});

  @override
  State<GmailConnectionPage> createState() => _GmailConnectionPageState();
}

class _GmailConnectionPageState extends State<GmailConnectionPage> {
  bool _isConnecting = false;
  final AuthService _authService = AuthService();

  Future<void> _connectGmail() async {
    setState(() {
      _isConnecting = true;
    });

    try {
      // Sign in with Google
      final user = await _authService.signInWithGoogle();
      
      if (mounted && user != null) {
        // Navigate to next page or show success
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Gmail connected successfully!'),
            backgroundColor: Colors.green,
          ),
        );
        
        // Navigator.pushReplacement(
        //   context,
        //   MaterialPageRoute(builder: (context) => HomePage()),
        // );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isConnecting = false;
        });
      }
    }
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
                    // Gmail icon or logo
                    Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(40),
                      ),
                      child: const Icon(
                        Icons.mail,
                        size: 50,
                        color: primaryColor,
                      ),
                    ),
                    const SizedBox(height: 40),
                    
                    // Title text
                    Text(
                      'Connect your Gmail',
                      style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    
                    // Description text
                    Text(
                      'We need access to your Gmail account to help you manage your emails efficiently.',
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: Colors.white70,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 40),
                    
                    // Connect button
                    SizedBox(
                      width: double.infinity,
                      child: CustomButton(
                        text: 'Connect with Gmail',
                        icon: Icons.mail_outline,
                        onPressed: _isConnecting ? null : _connectGmail,
                        isLoading: _isConnecting,
                        width: double.infinity,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            // Skip button in bottom right
            Positioned(
              bottom: 24,
              right: 24,
              child: CustomButton(
                text: 'Skip',
                onPressed: _isConnecting
                    ? null
                    : () {
                        // Navigate to next page or handle skip
                        // Navigator.pushReplacement(
                        //   context,
                        //   MaterialPageRoute(builder: (context) => HomePage()),
                        // );
                      },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

