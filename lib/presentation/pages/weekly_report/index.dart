import 'package:assistant/data/services/notifications_api_service.dart';
import 'package:assistant/presentation/constants/app_theme.dart';
import 'package:flutter/material.dart';

/// Full weekly report page showing detailed AI-generated analysis.
class WeeklyReportPage extends StatefulWidget {
  const WeeklyReportPage({super.key});

  @override
  State<WeeklyReportPage> createState() => _WeeklyReportPageState();
}

class _WeeklyReportPageState extends State<WeeklyReportPage> {
  final _api = NotificationsApiService();
  WeeklyReportData? _report;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadReport();
  }

  Future<void> _loadReport() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final report = await _api.requestWeeklyReport();
      if (mounted) {
        setState(() {
          _report = report;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString();
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: const Text('Weekly Report'),
        backgroundColor: AppTheme.backgroundColor,
        foregroundColor: AppTheme.textPrimary,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, size: 20),
            onPressed: _loadReport,
          ),
        ],
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.error_outline, size: 48, color: AppTheme.warningColor),
              const SizedBox(height: 12),
              Text(
                'Failed to load report',
                style: TextStyle(fontSize: 14, color: AppTheme.textSecondary),
              ),
              const SizedBox(height: 8),
              TextButton(onPressed: _loadReport, child: const Text('Retry')),
            ],
          ),
        ),
      );
    }

    final report = _report;
    if (report == null) return const SizedBox.shrink();

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Generated date
        Text(
          'Generated ${_formatDate(report.generatedAt)}',
          style: TextStyle(fontSize: 11, color: AppTheme.textTertiary),
        ),
        const SizedBox(height: 16),

        // Highlights
        if (report.highlights.isNotEmpty) ...[
          _buildSection('Highlights', Icons.star_outlined,
              AppTheme.successColor, report.highlights),
          const SizedBox(height: 16),
        ],

        // Concerns
        if (report.concerns.isNotEmpty) ...[
          _buildSection('Needs Attention', Icons.warning_amber_outlined,
              AppTheme.warningColor, report.concerns),
          const SizedBox(height: 16),
        ],

        // Correlations
        if (report.correlations.isNotEmpty) ...[
          _buildSection('Discovered Patterns', Icons.compare_arrows_outlined,
              const Color(0xFF8B5CF6), report.correlations),
          const SizedBox(height: 16),
        ],

        // Trends
        if (report.trends.isNotEmpty) ...[
          _buildSection('7-Day Trends', Icons.trending_up_outlined,
              AppTheme.primaryColor, report.trends),
          const SizedBox(height: 16),
        ],

        // Recommendations
        if (report.recommendations.isNotEmpty) ...[
          _buildSection('Recommendations', Icons.lightbulb_outlined,
              const Color(0xFFF59E0B), report.recommendations),
          const SizedBox(height: 16),
        ],
      ],
    );
  }

  Widget _buildSection(
      String title, IconData icon, Color color, List<String> items) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppTheme.cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.cardBorderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 16, color: color),
              const SizedBox(width: 6),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          ...items.map((item) => Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 4,
                      height: 4,
                      margin: const EdgeInsets.only(top: 6, right: 8),
                      decoration: BoxDecoration(
                        color: color,
                        shape: BoxShape.circle,
                      ),
                    ),
                    Expanded(
                      child: Text(
                        item,
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppTheme.textSecondary,
                          height: 1.4,
                        ),
                      ),
                    ),
                  ],
                ),
              )),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    final months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ];
    return '${months[date.month - 1]} ${date.day}, ${date.year}';
  }
}
