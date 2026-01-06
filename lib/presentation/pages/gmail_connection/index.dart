import 'package:assistant/presentation/constants/app_theme.dart';
import 'package:assistant/presentation/widgets/buttons/custom_button.dart';
import 'package:assistant/services/auth_service.dart';
import 'package:assistant/presentation/pages/dashboard/index.dart';
import 'package:flutter/material.dart';

class GmailConnectionPage extends StatefulWidget {
  const GmailConnectionPage({super.key});

  @override
  State<GmailConnectionPage> createState() => _GmailConnectionPageState();
}

class _GmailConnectionPageState extends State<GmailConnectionPage>
    with SingleTickerProviderStateMixin {
  bool _isConnecting = false;
  final AuthService _authService = AuthService();
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeOut,
      ),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeOut,
      ),
    );

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _connectGmail() async {
    setState(() {
      _isConnecting = true;
    });

    try {
      final user = await _authService.signInWithGoogle();
      
      if (mounted && user != null) {
        Navigator.pushReplacement(
          context,
          PageRouteBuilder(
            pageBuilder: (context, animation, secondaryAnimation) =>
                const Dashboard(),
            transitionsBuilder:
                (context, animation, secondaryAnimation, child) {
              return FadeTransition(
                opacity: animation,
                child: child,
              );
            },
            transitionDuration: const Duration(milliseconds: 300),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: AppTheme.errorColor,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppTheme.borderRadiusMedium),
            ),
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
      body: Container(
        decoration: BoxDecoration(
          gradient: AppTheme.primaryGradient,
        ),
        child: SafeArea(
          child: Stack(
            children: [
              // Main content
              Center(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(AppTheme.spacingLG),
                  child: FadeTransition(
                    opacity: _fadeAnimation,
                    child: SlideTransition(
                      position: _slideAnimation,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          // Gmail icon with modern styling
                          Container(
                            width: 100,
                            height: 100,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(24),
                              boxShadow: AppTheme.elevatedShadow,
                            ),
                            child: const Icon(
                              Icons.mail_outlined,
                              size: 50,
                              color: AppTheme.primaryColor,
                            ),
                          ),
                          const SizedBox(height: AppTheme.spacingXL),
                          
                          // Title text
                          Text(
                            'Connect your Gmail',
                            style: Theme.of(context)
                                .textTheme
                                .headlineLarge
                                ?.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w700,
                                ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: AppTheme.spacingMD),
                          
                          // Description text
                          Text(
                            'We need access to your Gmail account to help you manage your emails efficiently.',
                            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                  color: Colors.white.withValues(alpha: 0.9),
                                  height: 1.5,
                                ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: AppTheme.spacingXXL),
                          
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
                ),
              ),
              // Skip button in bottom right
              Positioned(
                bottom: AppTheme.spacingLG,
                right: AppTheme.spacingLG,
                child: FadeTransition(
                  opacity: _fadeAnimation,
                  child: CustomButton(
                    text: 'Skip',
                    backgroundColor: Colors.white.withValues(alpha: 0.2),
                    textColor: Colors.white,
                    onPressed: _isConnecting
                        ? null
                        : () {
                            Navigator.pushReplacement(
                              context,
                              PageRouteBuilder(
                                pageBuilder:
                                    (context, animation, secondaryAnimation) =>
                                        const Dashboard(),
                                transitionsBuilder: (context, animation,
                                    secondaryAnimation, child) {
                                  return FadeTransition(
                                    opacity: animation,
                                    child: child,
                                  );
                                },
                                transitionDuration:
                                    const Duration(milliseconds: 300),
                              ),
                            );
                          },
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

