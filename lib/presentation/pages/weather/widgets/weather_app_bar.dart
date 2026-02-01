import 'package:assistant/presentation/constants/app_theme.dart';
import 'package:flutter/material.dart';

class WeatherAppBar extends StatelessWidget {
  final String location;
  final bool isSearching;
  final String searchQuery;
  final VoidCallback onBackPressed;
  final VoidCallback onSearchToggle;
  final ValueChanged<String> onSearchChanged;
  final VoidCallback onSearchSubmit;
  final VoidCallback? onSettingsPressed;

  const WeatherAppBar({
    super.key,
    required this.location,
    required this.isSearching,
    required this.searchQuery,
    required this.onBackPressed,
    required this.onSearchToggle,
    required this.onSearchChanged,
    required this.onSearchSubmit,
    this.onSettingsPressed,
  });

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final padding = (screenWidth * 0.04).clamp(16.0, 24.0);

    return Container(
      padding: EdgeInsets.all(padding),
      decoration: BoxDecoration(
        color: AppTheme.cardColor,
        boxShadow: AppTheme.cardShadow,
      ),
      child: Row(
        children: [
          IconButton(
            onPressed: onBackPressed,
            icon: Icon(Icons.arrow_back, color: AppTheme.textPrimary),
            splashRadius: 24,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              transitionBuilder: (child, animation) {
                return FadeTransition(
                  opacity: animation,
                  child: SizeTransition(
                    sizeFactor: animation,
                    axis: Axis.horizontal,
                    child: child,
                  ),
                );
              },
              child: isSearching
                  ? _buildSearchField()
                  : _buildLocationDisplay(),
            ),
          ),
          const SizedBox(width: 8),
          IconButton(
            onPressed: onSearchToggle,
            icon: Icon(
              isSearching ? Icons.close : Icons.search,
              color: AppTheme.textPrimary,
            ),
            splashRadius: 24,
          ),
          if (onSettingsPressed != null && !isSearching)
            IconButton(
              onPressed: onSettingsPressed,
              icon: Icon(Icons.settings, color: AppTheme.textPrimary),
              splashRadius: 24,
            ),
        ],
      ),
    );
  }

  Widget _buildLocationDisplay() {
    return Row(
      key: const ValueKey('location'),
      children: [
        Icon(Icons.location_on, color: AppTheme.primaryColor, size: 20),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            location,
            style: TextStyle(
              color: AppTheme.textPrimary,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  Widget _buildSearchField() {
    return Container(
      key: const ValueKey('search'),
      height: 40,
      decoration: BoxDecoration(
        color: AppTheme.backgroundColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: TextField(
        autofocus: true,
        style: TextStyle(color: AppTheme.textPrimary),
        decoration: InputDecoration(
          hintText: 'Search location...',
          hintStyle: TextStyle(color: AppTheme.textTertiary),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          prefixIcon: Icon(
            Icons.search,
            color: AppTheme.textTertiary,
            size: 20,
          ),
        ),
        onChanged: onSearchChanged,
        onSubmitted: (_) => onSearchSubmit(),
        textInputAction: TextInputAction.search,
      ),
    );
  }
}
