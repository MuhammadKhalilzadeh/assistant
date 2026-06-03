import 'package:assistant/data/services/insights_api_service.dart';
import 'package:assistant/presentation/constants/app_theme.dart';
import 'package:assistant/presentation/widgets/cards/correlation_card.dart';
import 'package:assistant/presentation/widgets/cards/server_insight_card.dart';
import 'package:assistant/presentation/widgets/cards/trend_chart_card.dart';
import 'package:assistant/providers/insights_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Dedicated page showing all AI-generated insights, correlations, and trends.
class InsightsPage extends ConsumerStatefulWidget {
  const InsightsPage({super.key});

  @override
  ConsumerState<InsightsPage> createState() => _InsightsPageState();
}

class _InsightsPageState extends ConsumerState<InsightsPage> {
  List<Correlation> _correlations = [];
  List<TrendData> _trends = [];
  List<AnomalyData> _anomalies = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadIntelligence();
  }

  Future<void> _loadIntelligence() async {
    setState(() => _isLoading = true);
    final api = ref.read(insightsApiServiceProvider);

    try {
      final results = await Future.wait([
        api.getCorrelations(),
        api.getTrends(),
        api.getAnomalies(),
      ]);

      if (mounted) {
        setState(() {
          _correlations = results[0] as List<Correlation>;
          _trends = results[1] as List<TrendData>;
          _anomalies = results[2] as List<AnomalyData>;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final insightsState = ref.watch(insightsProvider);
    final serverInsights = insightsState.activeServerInsights;

    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: const Text('AI Insights'),
        backgroundColor: AppTheme.backgroundColor,
        foregroundColor: AppTheme.textPrimary,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, size: 20),
            onPressed: () {
              ref.read(insightsProvider.notifier).refresh(force: true);
              _loadIntelligence();
            },
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: () async {
                ref.read(insightsProvider.notifier).refresh(force: true);
                await _loadIntelligence();
              },
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  // Anomalies (most urgent)
                  if (_anomalies.isNotEmpty) ...[
                    _buildSectionHeader(
                        Icons.warning_amber_outlined, 'Anomalies'),
                    ..._anomalies.map((a) => Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: _buildAnomalyCard(a),
                        )),
                    const SizedBox(height: 12),
                  ],

                  // Server insights
                  if (serverInsights.isNotEmpty) ...[
                    _buildSectionHeader(
                        Icons.insights_outlined, 'AI Insights'),
                    ...serverInsights.map((i) => Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: ServerInsightCard(
                            insight: i,
                            onDismiss: () => ref
                                .read(insightsProvider.notifier)
                                .dismissServerInsight(i.id),
                          ),
                        )),
                    const SizedBox(height: 12),
                  ],

                  // Correlations
                  if (_correlations.isNotEmpty) ...[
                    _buildSectionHeader(
                        Icons.compare_arrows_outlined, 'Correlations'),
                    ..._correlations.map((c) => Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: CorrelationCard(correlation: c),
                        )),
                    const SizedBox(height: 12),
                  ],

                  // Trends
                  if (_trends.isNotEmpty) ...[
                    _buildSectionHeader(
                        Icons.trending_up_outlined, '7-Day Trends'),
                    ..._trends.map((t) => Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: TrendChartCard(trend: t),
                        )),
                    const SizedBox(height: 12),
                  ],

                  // Empty state
                  if (_anomalies.isEmpty &&
                      serverInsights.isEmpty &&
                      _correlations.isEmpty &&
                      _trends.isEmpty)
                    Center(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 48),
                        child: Column(
                          children: [
                            Icon(Icons.insights_outlined,
                                size: 48, color: AppTheme.textTertiary),
                            const SizedBox(height: 12),
                            Text(
                              'No insights yet',
                              style: TextStyle(
                                fontSize: 14,
                                color: AppTheme.textTertiary,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Keep tracking your data and insights will appear here',
                              style: TextStyle(
                                fontSize: 12,
                                color: AppTheme.textTertiary,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
            ),
    );
  }

  Widget _buildSectionHeader(IconData icon, String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Icon(icon, size: 14, color: AppTheme.primaryColor),
          const SizedBox(width: 6),
          Text(
            title,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: AppTheme.textPrimary,
              letterSpacing: -0.2,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAnomalyCard(AnomalyData anomaly) {
    final color = anomaly.severity == 'significant'
        ? AppTheme.warningColor
        : anomaly.severity == 'notable'
            ? const Color(0xFFF59E0B)
            : AppTheme.textTertiary;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppTheme.cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              anomaly.direction == 'above'
                  ? Icons.arrow_upward
                  : Icons.arrow_downward,
              size: 16,
              color: color,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        'Unusual ${anomaly.domain}',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.textPrimary,
                        ),
                      ),
                    ),
                    const SizedBox(width: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 5, vertical: 1),
                      decoration: BoxDecoration(
                        color: color.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        anomaly.severity,
                        style: TextStyle(
                          fontSize: 9,
                          fontWeight: FontWeight.w700,
                          color: color,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 3),
                Text(
                  anomaly.message,
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 11,
                    color: AppTheme.textSecondary,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
