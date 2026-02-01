import 'dart:math';
import 'package:flutter/material.dart';
import 'package:assistant/presentation/constants/app_theme.dart';

/// Goal achievement celebration overlay with confetti animation for sleep
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
  late AnimationController _confettiController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;

  final List<_ConfettiParticle> _particles = [];
  final Random _random = Random();

  @override
  void initState() {
    super.initState();

    // Scale animation for text
    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _scaleController, curve: Curves.elasticOut),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _scaleController,
        curve: const Interval(0.0, 0.3, curve: Curves.easeOut),
      ),
    );

    // Confetti animation
    _confettiController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );

    // Generate confetti particles
    _generateParticles();

    // Start animations
    _scaleController.forward();
    _confettiController.forward();

    // Auto dismiss after 2 seconds
    Future.delayed(const Duration(milliseconds: 2000), () {
      if (mounted) {
        widget.onDismiss();
      }
    });
  }

  void _generateParticles() {
    for (int i = 0; i < 50; i++) {
      _particles.add(_ConfettiParticle(
        x: _random.nextDouble(),
        y: _random.nextDouble() * 0.3,
        vx: (_random.nextDouble() - 0.5) * 2,
        vy: _random.nextDouble() * 3 + 1,
        color: _getRandomColor(),
        rotation: _random.nextDouble() * 360,
        rotationSpeed: (_random.nextDouble() - 0.5) * 10,
        size: _random.nextDouble() * 8 + 4,
      ));
    }
  }

  Color _getRandomColor() {
    final colors = [
      AppTheme.primaryColor, // Red
      AppTheme.primaryLight, // Light red
      AppTheme.warningColor, // Amber
      AppTheme.successColor, // Green
      AppTheme.infoColor, // Blue
      const Color(0xFF8B5CF6), // Purple (night theme)
      const Color(0xFF6366F1), // Indigo
    ];
    return colors[_random.nextInt(colors.length)];
  }

  @override
  void dispose() {
    _scaleController.dispose();
    _confettiController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onDismiss,
      child: AnimatedBuilder(
        animation: _fadeAnimation,
        builder: (context, child) {
          return Container(
            color: Colors.black.withValues(alpha: 0.5 * _fadeAnimation.value),
            child: Stack(
              children: [
                // Confetti
                AnimatedBuilder(
                  animation: _confettiController,
                  builder: (context, child) {
                    return CustomPaint(
                      size: Size.infinite,
                      painter: _ConfettiPainter(
                        particles: _particles,
                        progress: _confettiController.value,
                      ),
                    );
                  },
                ),
                // Center celebration content
                Center(
                  child: ScaleTransition(
                    scale: _scaleAnimation,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 40,
                        vertical: 32,
                      ),
                      decoration: BoxDecoration(
                        color: AppTheme.cardColor,
                        borderRadius: BorderRadius.circular(24),
                        boxShadow: [
                          BoxShadow(
                            color: AppTheme.primaryColor.withValues(alpha: 0.3),
                            blurRadius: 30,
                            spreadRadius: 5,
                          ),
                        ],
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Moon and star icons with glow
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: AppTheme.primaryColor.withValues(alpha: 0.1),
                              shape: BoxShape.circle,
                            ),
                            child: Stack(
                              alignment: Alignment.center,
                              children: [
                                Icon(
                                  Icons.bedtime,
                                  color: AppTheme.primaryColor,
                                  size: 48,
                                ),
                                Positioned(
                                  top: 0,
                                  right: 0,
                                  child: Icon(
                                    Icons.star,
                                    color: AppTheme.warningColor,
                                    size: 16,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 20),
                          // Main text
                          Text(
                            'Well Rested!',
                            style: TextStyle(
                              color: AppTheme.textPrimary,
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'You\'ve reached your sleep goal!',
                            style: TextStyle(
                              color: AppTheme.textSecondary,
                              fontSize: 14,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 16),
                          // Moon icons row
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: List.generate(5, (index) {
                              return Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 4),
                                child: Icon(
                                  Icons.nightlight_round,
                                  color: AppTheme.primaryColor.withValues(alpha: 0.8),
                                  size: 20,
                                ),
                              );
                            }),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _ConfettiParticle {
  double x;
  double y;
  final double vx;
  final double vy;
  final Color color;
  double rotation;
  final double rotationSpeed;
  final double size;

  _ConfettiParticle({
    required this.x,
    required this.y,
    required this.vx,
    required this.vy,
    required this.color,
    required this.rotation,
    required this.rotationSpeed,
    required this.size,
  });
}

class _ConfettiPainter extends CustomPainter {
  final List<_ConfettiParticle> particles;
  final double progress;

  _ConfettiPainter({
    required this.particles,
    required this.progress,
  });

  @override
  void paint(Canvas canvas, Size size) {
    for (final particle in particles) {
      final x = (particle.x + particle.vx * progress * 0.2) * size.width;
      final y = (particle.y + particle.vy * progress) * size.height;
      final rotation = particle.rotation + particle.rotationSpeed * progress * 10;

      if (y > size.height) continue;

      final paint = Paint()
        ..color = particle.color.withValues(alpha: 1.0 - progress * 0.5)
        ..style = PaintingStyle.fill;

      canvas.save();
      canvas.translate(x, y);
      canvas.rotate(rotation * pi / 180);

      // Draw star-shaped confetti for sleep theme
      if (particles.indexOf(particle) % 3 == 0) {
        // Draw star
        final path = Path();
        for (int i = 0; i < 5; i++) {
          final angle = (i * 72 - 90) * pi / 180;
          final innerAngle = ((i * 72 + 36) - 90) * pi / 180;
          final outerRadius = particle.size;
          final innerRadius = particle.size * 0.4;

          if (i == 0) {
            path.moveTo(outerRadius * cos(angle), outerRadius * sin(angle));
          } else {
            path.lineTo(outerRadius * cos(angle), outerRadius * sin(angle));
          }
          path.lineTo(innerRadius * cos(innerAngle), innerRadius * sin(innerAngle));
        }
        path.close();
        canvas.drawPath(path, paint);
      } else {
        // Draw rectangular confetti
        canvas.drawRect(
          Rect.fromCenter(
            center: Offset.zero,
            width: particle.size,
            height: particle.size * 0.6,
          ),
          paint,
        );
      }

      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(covariant _ConfettiPainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}
