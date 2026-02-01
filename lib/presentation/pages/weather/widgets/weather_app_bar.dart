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
        color: Colors.white.withValues(alpha: 0.1),
        border: Border(
          bottom: BorderSide(
            color: Colors.white.withValues(alpha: 0.1),
          ),
        ),
      ),
      child: Row(
        children: [
          IconButton(
            onPressed: onBackPressed,
            icon: const Icon(Icons.arrow_back, color: Colors.white),
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
              color: Colors.white,
            ),
            splashRadius: 24,
          ),
          if (onSettingsPressed != null && !isSearching)
            IconButton(
              onPressed: onSettingsPressed,
              icon: const Icon(Icons.settings, color: Colors.white),
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
        const Icon(Icons.location_on, color: Colors.white, size: 20),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            location,
            style: const TextStyle(
              color: Colors.white,
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
        color: Colors.white.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
      ),
      child: TextField(
        autofocus: true,
        style: const TextStyle(color: Colors.white),
        decoration: InputDecoration(
          hintText: 'Search location...',
          hintStyle: TextStyle(color: Colors.white.withValues(alpha: 0.6)),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          prefixIcon: Icon(
            Icons.search,
            color: Colors.white.withValues(alpha: 0.6),
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
