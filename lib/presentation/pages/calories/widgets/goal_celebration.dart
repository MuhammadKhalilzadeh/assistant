import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:assistant/presentation/constants/app_theme.dart';

class GoalCelebration extends StatefulWidget {
  final VoidCallback onDismiss;

  const GoalCelebration({
    super.key,
    required this.onDismiss,
  });

  @override
  State<GoalCelebration> createState() => _GoalCelebrationState();
}

class _GoalCelebrationState extends State<GoalCelebration>
    with TickerProviderStateMixin {
  late AnimationController _scaleController;
  late AnimationController _fadeController;
  late AnimationController _confettiController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;
  late List<_ConfettiParticle> _particles;

  @override
  void initState() {
    super.initState();

    HapticFeedback.heavyImpact();

    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _confettiController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _scaleController, curve: Curves.elasticOut),
    );

    _fadeAnimation = Tween<double>(begin: 1.0, end: 0.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeOut),
    );

    _generateParticles();

    _scaleController.forward();
    _confettiController.forward();

    Future.delayed(const Duration(milliseconds: 1700), () {
      if (mounted) {
        _fadeController.forward().then((_) {
          if (mounted) {
            widget.onDismiss();
          }
        });
      }
    });
  }

  void _generateParticles() {
    final random = Random();
    _particles = List.generate(50, (index) {
      return _ConfettiParticle(
        x: random.nextDouble(),
        y: random.nextDouble() * 0.3,
        size: 6 + random.nextDouble() * 8,
        color: _confettiColors[random.nextInt(_confettiColors.length)],
        velocity: 0.3 + random.nextDouble() * 0.7,
        angle: random.nextDouble() * 2 * pi,
        rotationSpeed: random.nextDouble() * 4 - 2,
      );
    });
  }

  static const List<Color> _confettiColors = [
    AppTheme.primaryColor,
    AppTheme.warningColor,
    AppTheme.successColor,
    AppTheme.infoColor,
    Color(0xFFA78BFA),
    AppTheme.secondaryColor,
    Color(0xFF34D399),
  ];

  @override
  void dispose() {
    _scaleController.dispose();
    _fadeController.dispose();
    _confettiController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([
        _scaleAnimation,
        _fadeAnimation,
        _confettiController,
      ]),
      builder: (context, child) {
        return Opacity(
          opacity: _fadeAnimation.value,
          child: Container(
            color: Colors.black.withValues(alpha: 0.6),
            child: Stack(
              children: [
                // Confetti particles
                ..._particles.map((particle) {
                  final progress = _confettiController.value;
                  final y = particle.y +
                      progress * particle.velocity * 1.5;
                  final x = particle.x +
                      sin(progress * particle.angle * 4) * 0.05;

                  return Positioned(
                    left: x * MediaQuery.of(context).size.width,
                    top: y * MediaQuery.of(context).size.height,
                    child: Transform.rotate(
                      angle: progress * particle.rotationSpeed * pi,
                      child: Opacity(
                        opacity: (1 - progress).clamp(0.0, 1.0),
                        child: Container(
                          width: particle.size,
                          height: particle.size,
                          decoration: BoxDecoration(
                            color: particle.color,
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                      ),
                    ),
                  );
                }),

                // Center celebration content
                Center(
                  child: Transform.scale(
                    scale: _scaleAnimation.value,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Trophy/Star icon
                        Container(
                          width: 100,
                          height: 100,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [
                                AppTheme.primaryLight,
                                AppTheme.primaryColor,
                              ],
                            ),
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: AppTheme.primaryColor.withValues(alpha: 0.5),
                                blurRadius: 30,
                                spreadRadius: 5,
                              ),
                            ],
                          ),
                          child: const Icon(
                            Icons.star_rounded,
                            color: Colors.white,
                            size: 60,
                          ),
                        ),
                        const SizedBox(height: 24),
                        // Text
                        const Text(
                          'Perfect Day!',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                            shadows: [
                              Shadow(
                                color: Colors.black26,
                                blurRadius: 10,
                                offset: Offset(0, 2),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'You hit your calorie goal!',
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.9),
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _ConfettiParticle {
  final double x;
  final double y;
  final double size;
  final Color color;
  final double velocity;
  final double angle;
  final double rotationSpeed;

  _ConfettiParticle({
    required this.x,
    required this.y,
    required this.size,
    required this.color,
    required this.velocity,
    required this.angle,
    required this.rotationSpeed,
  });
}
