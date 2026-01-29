import 'package:assistant/data/mock/models/heart_rate_record_model.dart';
import 'package:assistant/data/mock/repositories/mock_repository.dart';
import 'package:assistant/presentation/constants/app_theme.dart';
import 'package:flutter/material.dart';

class HeartRatePage extends StatelessWidget {
  const HeartRatePage({super.key});

  Color _getZoneColor(HeartRateZone zone) {
    switch (zone) {
      case HeartRateZone.resting:
        return Colors.blue;
      case HeartRateZone.warmUp:
        return Colors.green;
      case HeartRateZone.fatBurn:
        return Colors.yellow;
      case HeartRateZone.cardio:
        return Colors.orange;
      case HeartRateZone.peak:
        return Colors.red;
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final padding = (screenWidth * 0.04).clamp(16.0, 24.0);
    final repository = MockRepository();
    final latestRecord = repository.latestHeartRate;
    final restingBpm = repository.restingHeartRate;
    final records = repository.heartRateRecords;

    return Scaffold(
      body: SafeArea(
        child: Container(
          decoration: const BoxDecoration(
            gradient: AppTheme.primaryGradient,
          ),
          child: Column(
            children: [
              _buildAppBar(context, padding),
              Expanded(
                child: SingleChildScrollView(
                  child: Padding(
                    padding: EdgeInsets.all(padding),
                    child: Column(
                      children: [
                        _buildCurrentHeartRate(latestRecord, screenWidth, padding),
                        SizedBox(height: padding),
                        _buildStatsRow(latestRecord, restingBpm, padding),
                        SizedBox(height: padding),
                        _buildZonesInfo(padding),
                        SizedBox(height: padding),
                        _buildHistory(records, padding),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAppBar(BuildContext context, double padding) {
    return Padding(
      padding: EdgeInsets.all(padding),
      child: Row(
        children: [
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.arrow_back, color: Colors.white),
          ),
          SizedBox(width: AppTheme.spacingSM),
          const Expanded(
            child: Text(
              'Heart Rate',
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCurrentHeartRate(HeartRateRecordModel? record, double screenWidth, double padding) {
    final bpm = record?.bpm ?? 0;
    final zone = record?.zone ?? HeartRateZone.resting;
    final zoneLabel = record?.zoneLabel ?? 'No data';

    return Container(
      padding: EdgeInsets.all(padding * 1.5),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
      ),
      child: Column(
        children: [
          const Text(
            'Current Heart Rate',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: AppTheme.spacingLG),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.favorite,
                color: _getZoneColor(zone),
                size: 48,
              ),
              SizedBox(width: AppTheme.spacingMD),
              Flexible(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            '$bpm',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: (screenWidth * 0.15).clamp(40.0, 64.0),
                              fontWeight: FontWeight.bold,
                              height: 1,
                            ),
                          ),
                          Padding(
                            padding: EdgeInsets.only(bottom: AppTheme.spacingSM, left: AppTheme.spacingXS),
                            child: const Text(
                              'BPM',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 20,
                                fontWeight: FontWeight.w300,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: AppTheme.spacingSM + AppTheme.spacingXS, vertical: AppTheme.spacingXS),
                    decoration: BoxDecoration(
                      color: _getZoneColor(zone).withValues(alpha: 0.3),
                      borderRadius: BorderRadius.circular(12),
                    ),
                      child: Text(
                        zoneLabel,
                        style: TextStyle(
                          color: _getZoneColor(zone),
                          fontWeight: FontWeight.w600,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (record != null) ...[
            SizedBox(height: AppTheme.spacingMD),
            Text(
              'Last updated ${_formatTimeAgo(record.recordedAt)}',
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.6),
                fontSize: 12,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildStatsRow(HeartRateRecordModel? latest, int resting, double padding) {
    return Container(
      padding: EdgeInsets.all(padding),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
      ),
      child: Row(
        children: [
          Expanded(child: _buildStatItem(Icons.bedtime, '$resting', 'Resting')),
          Expanded(child: _buildStatItem(Icons.favorite, '${latest?.bpm ?? 0}', 'Current')),
          Expanded(child: _buildStatItem(Icons.trending_up, '${(latest?.bpm ?? 0) + 20}', 'Max Today')),
        ],
      ),
    );
  }

  Widget _buildStatItem(IconData icon, String value, String label) {
    return Column(
      children: [
        Icon(icon, color: Colors.white, size: 24),
        SizedBox(height: AppTheme.spacingSM),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.7),
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  Widget _buildZonesInfo(double padding) {
    final zones = [
      (HeartRateZone.resting, '< 60', 'Resting'),
      (HeartRateZone.warmUp, '60-99', 'Warm Up'),
      (HeartRateZone.fatBurn, '100-139', 'Fat Burn'),
      (HeartRateZone.cardio, '140-169', 'Cardio'),
      (HeartRateZone.peak, '170+', 'Peak'),
    ];

    return Container(
      padding: EdgeInsets.all(padding),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Heart Rate Zones',
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: AppTheme.spacingSM + AppTheme.spacingXS),
          ...zones.map((zone) => Padding(
            padding: EdgeInsets.only(bottom: AppTheme.spacingSM),
            child: Row(
              children: [
                Container(
                  width: 12,
                  height: 12,
                  decoration: BoxDecoration(
                    color: _getZoneColor(zone.$1),
                    shape: BoxShape.circle,
                  ),
                ),
                SizedBox(width: AppTheme.spacingSM + AppTheme.spacingXS),
                Expanded(
                  child: Text(
                    zone.$3,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                Text(
                  zone.$2,
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.7),
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          )),
        ],
      ),
    );
  }

  Widget _buildHistory(List<HeartRateRecordModel> records, double padding) {
    if (records.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Recent Readings',
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: AppTheme.spacingSM + AppTheme.spacingXS),
        ...records.take(10).map((record) => Container(
          margin: EdgeInsets.only(bottom: AppTheme.spacingSM),
          padding: EdgeInsets.all(padding),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              Icon(
                Icons.favorite,
                color: _getZoneColor(record.zone),
                size: 20,
              ),
              SizedBox(width: AppTheme.spacingSM + AppTheme.spacingXS),
              Expanded(
                child: Text(
                  '${record.bpm} BPM',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: AppTheme.spacingSM, vertical: 2),
                decoration: BoxDecoration(
                  color: _getZoneColor(record.zone).withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  record.zoneLabel,
                  style: TextStyle(
                    color: _getZoneColor(record.zone),
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              SizedBox(width: AppTheme.spacingSM + AppTheme.spacingXS),
              Text(
                _formatTimeAgo(record.recordedAt),
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.6),
                  fontSize: 12,
                ),
              ),
            ],
          ),
        )),
      ],
    );
  }

  String _formatTimeAgo(DateTime time) {
    final diff = DateTime.now().difference(time);
    if (diff.inMinutes < 1) return 'just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    return '${diff.inDays}d ago';
  }
}
