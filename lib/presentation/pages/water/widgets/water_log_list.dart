import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:assistant/data/models/water_log_model.dart';
import 'package:assistant/presentation/constants/app_theme.dart';

/// Today's water log list with swipe-to-delete functionality
class WaterLogList extends StatelessWidget {
  final List<WaterLogModel> logs;
  final Function(String id) onDelete;
  final double padding;
  final Animation<double>? animation;

  const WaterLogList({
    super.key,
    required this.logs,
    required this.onDelete,
    required this.padding,
    this.animation,
  });

  IconData _getIcon(BeverageType type) {
    switch (type) {
      case BeverageType.water:
        return Icons.water_drop;
      case BeverageType.coffee:
        return Icons.coffee;
      case BeverageType.tea:
        return Icons.emoji_food_beverage;
      case BeverageType.juice:
        return Icons.local_bar;
      case BeverageType.milk:
        return Icons.local_cafe;
      case BeverageType.other:
        return Icons.local_drink;
    }
  }

  Color _getColor(BeverageType type) {
    switch (type) {
      case BeverageType.water:
        return AppTheme.primaryColor;
      case BeverageType.coffee:
        return const Color(0xFF8B5A2B);
      case BeverageType.tea:
        return AppTheme.warningColor;
      case BeverageType.juice:
        return const Color(0xFFEA580C);
      case BeverageType.milk:
        return AppTheme.textSecondary;
      case BeverageType.other:
        return AppTheme.infoColor;
    }
  }

  String _formatTime(DateTime time) {
    final hour = time.hour > 12 ? time.hour - 12 : (time.hour == 0 ? 12 : time.hour);
    final period = time.hour >= 12 ? 'PM' : 'AM';
    return '$hour:${time.minute.toString().padLeft(2, '0')} $period';
  }

  @override
  Widget build(BuildContext context) {
    Widget content = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              Icons.history,
              color: AppTheme.textSecondary,
              size: 20,
            ),
            const SizedBox(width: 8),
            Text(
              "Today's Logs",
              style: TextStyle(
                color: AppTheme.textPrimary,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const Spacer(),
            if (logs.isNotEmpty)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppTheme.primaryColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '${logs.length} entries',
                  style: TextStyle(
                    color: AppTheme.primaryColor,
                    fontSize: 12,
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(height: 16),
        if (logs.isEmpty)
          _buildEmptyState()
        else
          ...logs.asMap().entries.map((entry) {
            final index = entry.key;
            final log = entry.value;
            return _WaterLogItem(
              log: log,
              icon: _getIcon(log.beverageType),
              color: _getColor(log.beverageType),
              timeString: _formatTime(log.loggedAt),
              onDelete: () => onDelete(log.id),
              padding: padding,
              delay: index * 80,
            );
          }),
      ],
    );

    if (animation != null) {
      return FadeTransition(
        opacity: animation!,
        child: SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(0, 0.1),
            end: Offset.zero,
          ).animate(CurvedAnimation(
            parent: animation!,
            curve: Curves.easeOutCubic,
          )),
          child: content,
        ),
      );
    }

    return content;
  }

  Widget _buildEmptyState() {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: AppTheme.cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: AppTheme.cardShadow,
      ),
      child: Column(
        children: [
          Icon(
            Icons.water_drop_outlined,
            size: 48,
            color: AppTheme.textTertiary,
          ),
          const SizedBox(height: 12),
          Text(
            'No water logged today',
            style: TextStyle(
              color: AppTheme.textSecondary,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Tap the buttons above to start tracking',
            style: TextStyle(
              color: AppTheme.textTertiary,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}

class _WaterLogItem extends StatefulWidget {
  final WaterLogModel log;
  final IconData icon;
  final Color color;
  final String timeString;
  final VoidCallback onDelete;
  final double padding;
  final int delay;

  const _WaterLogItem({
    required this.log,
    required this.icon,
    required this.color,
    required this.timeString,
    required this.onDelete,
    required this.padding,
    required this.delay,
  });

  @override
  State<_WaterLogItem> createState() => _WaterLogItemState();
}

class _WaterLogItemState extends State<_WaterLogItem>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.2),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic));

    Future.delayed(Duration(milliseconds: widget.delay), () {
      if (mounted) _controller.forward();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: SlideTransition(
        position: _slideAnimation,
        child: Dismissible(
          key: Key(widget.log.id),
          direction: DismissDirection.endToStart,
          onDismissed: (_) {
            HapticFeedback.mediumImpact();
            widget.onDelete();
          },
          background: Container(
            margin: const EdgeInsets.only(bottom: 8),
            decoration: BoxDecoration(
              color: AppTheme.errorColor.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            alignment: Alignment.centerRight,
            padding: const EdgeInsets.only(right: 20),
            child: Icon(
              Icons.delete_outline,
              color: AppTheme.errorColor,
            ),
          ),
          child: Container(
            margin: const EdgeInsets.only(bottom: 8),
            padding: EdgeInsets.all(widget.padding),
            decoration: BoxDecoration(
              color: AppTheme.cardColor,
              borderRadius: BorderRadius.circular(12),
              boxShadow: AppTheme.cardShadow,
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: widget.color.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    widget.icon,
                    color: widget.color,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            '${widget.log.amountMl}ml',
                            style: TextStyle(
                              color: AppTheme.textPrimary,
                              fontWeight: FontWeight.w600,
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: widget.color.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              widget.log.beverageType.displayName,
                              style: TextStyle(
                                color: widget.color,
                                fontSize: 10,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                      if (widget.log.note != null) ...[
                        const SizedBox(height: 4),
                        Text(
                          widget.log.note!,
                          style: TextStyle(
                            color: AppTheme.textTertiary,
                            fontSize: 12,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ],
                  ),
                ),
                Text(
                  widget.timeString,
                  style: TextStyle(
                    color: AppTheme.textTertiary,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
