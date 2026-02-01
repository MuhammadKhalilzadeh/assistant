import 'package:assistant/presentation/constants/app_theme.dart';
import 'package:flutter/material.dart';

class HabitAppBar extends StatefulWidget {
  final bool isSearching;
  final String searchQuery;
  final int currentStreak;
  final VoidCallback onSearchToggle;
  final ValueChanged<String> onSearchChanged;

  const HabitAppBar({
    super.key,
    required this.isSearching,
    required this.searchQuery,
    required this.currentStreak,
    required this.onSearchToggle,
    required this.onSearchChanged,
  });

  @override
  State<HabitAppBar> createState() => _HabitAppBarState();
}

class _HabitAppBarState extends State<HabitAppBar>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _searchWidthAnimation;
  late TextEditingController _searchController;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _searchWidthAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeInOut,
      ),
    );
    _searchController = TextEditingController(text: widget.searchQuery);

    if (widget.isSearching) {
      _animationController.value = 1.0;
    }
  }

  @override
  void didUpdateWidget(HabitAppBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isSearching != oldWidget.isSearching) {
      if (widget.isSearching) {
        _animationController.forward();
      } else {
        _animationController.reverse();
        _searchController.clear();
      }
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          // Back button
          Container(
            decoration: BoxDecoration(
              color: AppTheme.cardColor,
              borderRadius: BorderRadius.circular(12),
              boxShadow: AppTheme.cardShadow,
            ),
            child: IconButton(
              onPressed: () => Navigator.pop(context),
              icon: const Icon(Icons.arrow_back, color: AppTheme.textPrimary),
            ),
          ),
          const SizedBox(width: 12),

          // Title or Search field
          Expanded(
            child: AnimatedBuilder(
              animation: _searchWidthAnimation,
              builder: (context, child) {
                if (_searchWidthAnimation.value > 0.1) {
                  return Opacity(
                    opacity: _searchWidthAnimation.value,
                    child: Container(
                      height: 48,
                      decoration: BoxDecoration(
                        color: AppTheme.cardColor,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: AppTheme.cardShadow,
                      ),
                      child: TextField(
                        controller: _searchController,
                        autofocus: true,
                        style: const TextStyle(color: AppTheme.textPrimary),
                        decoration: InputDecoration(
                          hintText: 'Search habits...',
                          hintStyle: const TextStyle(
                            color: AppTheme.textTertiary,
                          ),
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 14,
                          ),
                          prefixIcon: const Icon(
                            Icons.search,
                            color: AppTheme.textSecondary,
                          ),
                          suffixIcon: widget.searchQuery.isNotEmpty
                              ? IconButton(
                                  onPressed: () {
                                    _searchController.clear();
                                    widget.onSearchChanged('');
                                  },
                                  icon: const Icon(
                                    Icons.close,
                                    color: AppTheme.textSecondary,
                                    size: 20,
                                  ),
                                )
                              : null,
                        ),
                        onChanged: widget.onSearchChanged,
                      ),
                    ),
                  );
                }
                return Row(
                  children: [
                    const Text(
                      'Habits',
                      style: TextStyle(
                        color: AppTheme.textPrimary,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(width: 12),
                    if (widget.currentStreak > 0)
                      _buildStreakBadge(widget.currentStreak),
                  ],
                );
              },
            ),
          ),

          const SizedBox(width: 12),

          // Search toggle button
          Container(
            decoration: BoxDecoration(
              color: widget.isSearching
                  ? AppTheme.primaryColor
                  : AppTheme.cardColor,
              borderRadius: BorderRadius.circular(12),
              boxShadow: AppTheme.cardShadow,
            ),
            child: IconButton(
              onPressed: widget.onSearchToggle,
              icon: Icon(
                widget.isSearching ? Icons.close : Icons.search,
                color: widget.isSearching
                    ? AppTheme.textOnPrimary
                    : AppTheme.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStreakBadge(int streak) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.8, end: 1.0),
      duration: const Duration(milliseconds: 600),
      curve: Curves.elasticOut,
      builder: (context, value, child) {
        return Transform.scale(
          scale: value,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [AppTheme.primaryColor, AppTheme.primaryLight],
              ),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: AppTheme.primaryColor.withValues(alpha: 0.4),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.local_fire_department,
                  color: AppTheme.textOnPrimary,
                  size: 16,
                ),
                const SizedBox(width: 4),
                Text(
                  '$streak',
                  style: const TextStyle(
                    color: AppTheme.textOnPrimary,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
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
