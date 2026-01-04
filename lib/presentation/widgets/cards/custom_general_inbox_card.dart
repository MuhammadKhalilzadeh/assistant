import 'package:assistant/presentation/constants/ui.dart';
import 'package:flutter/material.dart';

/// A reusable general inbox card widget
///
/// This widget displays inbox information with customizable
/// title, subtitle (unread count), and action callbacks. It features a red background
/// with white text and an email icon.
class CustomGeneralInboxCard extends StatelessWidget {
  /// The main title text (e.g., "Tap to open your inbox")
  final String title;

  /// The subtitle text showing unread count (e.g., "You have 37 unread message from 2 services")
  final String subtitle;

  /// Number of unread messages
  final int unreadCount;

  /// Number of services with unread messages
  final int servicesCount;

  /// Callback when the entire card is tapped
  final VoidCallback? onTap;

  /// Background color (defaults to primaryColor - red)
  final Color? backgroundColor;

  /// Foreground/text color (defaults to white)
  final Color? foregroundColor;

  /// Border radius for the card
  final double borderRadius;

  /// Icon to display
  final IconData icon;

  /// Whether the card is enabled
  final bool enabled;

  const CustomGeneralInboxCard({
    super.key,
    this.title = 'Tap to open your inbox',
    this.subtitle = '',
    this.unreadCount = 0,
    this.servicesCount = 0,
    this.onTap,
    this.backgroundColor,
    this.foregroundColor,
    this.borderRadius = 20,
    this.icon = Icons.mail,
    this.enabled = true,
  });

  /// Generate subtitle text from unread and services count
  String get _subtitleText {
    if (subtitle.isNotEmpty) return subtitle;
    if (unreadCount > 0) {
      final messageText = unreadCount == 1 ? 'message' : 'messages';
      final serviceText = servicesCount == 1 ? 'service' : 'services';
      return 'You have $unreadCount unread $messageText from $servicesCount $serviceText';
    }
    return 'No unread messages';
  }

  @override
  Widget build(BuildContext context) {
    final Color bgColor = backgroundColor ?? primaryColor;
    final Color fgColor = foregroundColor ?? Colors.white;
    final double screenWidth = MediaQuery.of(context).size.width;
    final double responsivePadding = screenWidth * 0.05;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: enabled ? onTap : null,
        borderRadius: BorderRadius.circular(borderRadius),
        child: Ink(
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(borderRadius),
          ),
          child: Padding(
            padding: EdgeInsets.all(responsivePadding.clamp(16.0, 24.0)),
            child: LayoutBuilder(
              builder: (context, constraints) {
                return Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Left section: Icon
                    _buildIconContainer(fgColor, constraints.maxWidth),

                    SizedBox(width: constraints.maxWidth * 0.04),

                    // Right section: Title + Subtitle
                    Expanded(
                      child: _buildTextSection(fgColor, constraints.maxWidth),
                    ),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildIconContainer(Color fgColor, double maxWidth) {
    final double iconSize = (maxWidth * 0.08).clamp(20.0, 32.0);
    final double padding = iconSize * 0.4;
    final double containerRadius = (iconSize * 0.3).clamp(8.0, 12.0);

    return Container(
      padding: EdgeInsets.all(padding),
      decoration: BoxDecoration(
        color: fgColor,
        borderRadius: BorderRadius.circular(containerRadius),
      ),
      child: Icon(
        icon,
        color: backgroundColor ?? primaryColor,
        size: iconSize,
      ),
    );
  }

  Widget _buildTextSection(Color fgColor, double maxWidth) {
    final double titleFontSize = (maxWidth * 0.055).clamp(16.0, 22.0);
    final double subtitleFontSize = (maxWidth * 0.038).clamp(12.0, 16.0);
    final double spacing = (maxWidth * 0.015).clamp(4.0, 8.0);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        // Title
        Text(
          title,
          style: TextStyle(
            color: fgColor,
            fontSize: titleFontSize,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: spacing),
        // Subtitle
        Text(
          _subtitleText,
          style: TextStyle(
            color: fgColor,
            fontSize: subtitleFontSize,
            fontWeight: FontWeight.w400,
          ),
        ),
      ],
    );
  }
}
