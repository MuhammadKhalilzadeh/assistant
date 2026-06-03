# Wave 3: Cross-Feature Intelligence

> **Goal:** Build a correlation engine that discovers patterns across all 15 data domains
> **Status:** Not Started
> **Depends on:** Wave 2 (server AI brain with data context)

---

## The Problem

Each module currently lives in isolation. Sleep doesn't know about mood. Steps don't know about screen time. The AI can describe individual metrics but can't answer "why am I feeling off this week?" by connecting the dots across domains.

---

## What Changes

### New Files to Create (Backend)

| File | Purpose |
|------|---------|
| `nodejs/src/services/intelligence/correlation.service.ts` | Statistical correlation engine across data domains |
| `nodejs/src/services/intelligence/pattern-detector.service.ts` | Detects recurring patterns (time-of-day, day-of-week, sequences) |
| `nodejs/src/services/intelligence/anomaly-detector.service.ts` | Flags unusual deviations from user's baseline |
| `nodejs/src/services/intelligence/trend-analyzer.service.ts` | 7/14/30 day trend analysis with direction + momentum |
| `nodejs/src/services/intelligence/insight-generator.service.ts` | Combines correlations + patterns + anomalies into human-readable insights |
| `nodejs/src/models/correlation.model.ts` | Stores discovered correlations with confidence scores |
| `nodejs/src/models/user-baseline.model.ts` | Stores per-user rolling baselines for anomaly detection |

### Files to Modify (Backend)

| File | Change |
|------|--------|
| `nodejs/src/services/brain/data-context.service.ts` | Add correlation summaries to context |
| `nodejs/src/services/brain/system-prompt.service.ts` | Include discovered patterns in system prompt |
| `nodejs/src/controllers/insights.controller.ts` | Add correlation + pattern endpoints |
| `nodejs/src/routes/insights.routes.ts` | New routes for correlations and patterns |
| `nodejs/src/index.ts` | Register new routes |

### New Files to Create (Flutter)

| File | Purpose |
|------|---------|
| `lib/presentation/widgets/correlation_card.dart` | Shows "X correlates with Y" insights visually |
| `lib/presentation/widgets/trend_chart.dart` | Mini sparkline chart showing 7/14/30 day trends |
| `lib/presentation/pages/insights_page.dart` | Dedicated page for AI-generated insights and patterns |

### Files to Modify (Flutter)

| File | Change |
|------|--------|
| `lib/presentation/pages/dashboard_page.dart` | Add insight cards, trend indicators |
| `lib/data/services/insights_api_service.dart` | Add correlation + pattern fetch methods |
| `lib/providers/server_insights_provider.dart` | Cache and manage correlation data |

---

## Correlation Engine Design

```typescript
// nodejs/src/services/intelligence/correlation.service.ts

interface CorrelationResult {
  featureA: string;          // e.g., 'sleep_quality'
  featureB: string;          // e.g., 'mood_score'
  coefficient: number;       // Pearson r: -1.0 to 1.0
  strength: 'weak' | 'moderate' | 'strong';
  direction: 'positive' | 'negative';
  sampleSize: number;        // days of data used
  confidence: number;        // p-value based confidence 0-1
  lag: number;               // days of lag (0 = same day, 1 = next day effect)
  humanReadable: string;     // "Your mood tends to be higher on days you sleep more than 7 hours"
}

class CorrelationService {
  /// Run all pairwise correlations for a user
  async analyzeAll(userId: string, days: number): Promise<CorrelationResult[]>;

  /// Specific domain pair correlation
  async correlate(userId: string, featureA: string, featureB: string, days: number): Promise<CorrelationResult>;

  /// Pre-defined high-value correlation pairs
  static readonly CORRELATION_PAIRS = [
    ['sleep_quality', 'mood_score'],
    ['sleep_duration', 'steps_count'],
    ['screen_time', 'sleep_quality'],
    ['screen_time', 'mood_score'],
    ['workout_minutes', 'mood_score'],
    ['workout_minutes', 'sleep_quality'],
    ['water_intake', 'mood_score'],
    ['meditation_minutes', 'mood_score'],
    ['meditation_minutes', 'sleep_quality'],
    ['focus_minutes', 'screen_time'],
    ['steps_count', 'mood_score'],
    ['calories_net', 'workout_minutes'],
    ['habits_completed', 'mood_score'],
    ['todos_completed', 'mood_score'],
    ['sleep_duration', 'heart_rate_resting'],
  ];
}
```

## Pattern Detector Design

```typescript
// nodejs/src/services/intelligence/pattern-detector.service.ts

interface Pattern {
  type: 'time_of_day' | 'day_of_week' | 'sequence' | 'threshold' | 'cycle';
  domain: string;
  description: string;
  confidence: number;
  evidence: string;         // data points supporting the pattern
}

class PatternDetectorService {
  /// Detect day-of-week patterns
  /// e.g., "You consistently sleep less on Friday nights"
  async detectDayOfWeekPatterns(userId: string, domain: string): Promise<Pattern[]>;

  /// Detect time-of-day patterns
  /// e.g., "Your mood is usually highest between 10am-12pm"
  async detectTimeOfDayPatterns(userId: string, domain: string): Promise<Pattern[]>;

  /// Detect sequences / cascading effects
  /// e.g., "After a workout, you tend to drink more water within 2 hours"
  async detectSequences(userId: string): Promise<Pattern[]>;

  /// Detect threshold effects
  /// e.g., "When you sleep less than 6 hours, next-day mood drops by 1.5 points on average"
  async detectThresholds(userId: string): Promise<Pattern[]>;
}
```

## Anomaly Detector Design

```typescript
// nodejs/src/services/intelligence/anomaly-detector.service.ts

interface Anomaly {
  domain: string;
  metric: string;
  value: number;
  baseline: number;         // user's rolling 30-day average
  deviation: number;        // standard deviations from baseline
  direction: 'above' | 'below';
  severity: 'mild' | 'notable' | 'significant';
  message: string;          // "Your step count today (2,100) is significantly below your usual 8,500"
}

class AnomalyDetectorService {
  /// Calculate and store user baselines (rolling 30-day averages + stddev)
  async updateBaselines(userId: string): Promise<void>;

  /// Check today's data against baselines
  async detectAnomalies(userId: string): Promise<Anomaly[]>;

  /// Thresholds for severity:
  /// mild: 1.0-1.5 stddev
  /// notable: 1.5-2.5 stddev
  /// significant: 2.5+ stddev
}
```

## Trend Analyzer Design

```typescript
// nodejs/src/services/intelligence/trend-analyzer.service.ts

interface Trend {
  domain: string;
  period: '7d' | '14d' | '30d';
  direction: 'improving' | 'declining' | 'stable';
  momentum: number;         // rate of change (-1 to 1)
  values: number[];         // daily values for sparkline
  summary: string;          // "Sleep quality improving: up 0.8 points over 14 days"
}

class TrendAnalyzerService {
  /// Analyze trends for all domains
  async analyzeTrends(userId: string, period: '7d' | '14d' | '30d'): Promise<Trend[]>;

  /// Linear regression to determine direction + momentum
  private calculateTrend(values: number[]): { slope: number; direction: string };
}
```

## Data Normalization

All features need to be normalized to comparable scales for correlation:

| Domain | Raw Metric | Normalized (0-1) |
|--------|-----------|-------------------|
| Sleep | 0-12 hours | hours / 12 |
| Sleep Quality | 1-5 scale | (quality - 1) / 4 |
| Mood | 1-5 scale | (mood - 1) / 4 |
| Steps | 0-25000 | steps / user_goal |
| Water | 0-5000 ml | ml / user_goal |
| Screen Time | 0-720 min | 1 - (minutes / 720) (inverted - less is better) |
| Workout | 0-180 min | minutes / 60 (capped at 1) |
| Meditation | 0-60 min | minutes / 30 (capped at 1) |
| Focus | 0-480 min | minutes / 240 (capped at 1) |
| Heart Rate (resting) | 40-100 bpm | 1 - ((bpm - 40) / 60) (lower is better) |
| Habits | 0-100% | completion_rate |
| Todos | 0-100% | completion_rate |
| Calories | varies | 1 - abs(net - goal) / goal (closer to goal is better) |

---

## Insight Generation Pipeline

```
Raw Data (16 models, 30 days)
    |
    v
[Normalization] --> comparable 0-1 scales
    |
    v
[Correlation Engine] --> pairwise coefficients
    |
    v
[Pattern Detector] --> time/day/sequence patterns
    |
    v
[Anomaly Detector] --> baseline deviations
    |
    v
[Trend Analyzer] --> 7/14/30 day directions
    |
    v
[Insight Generator] --> combines all signals into ranked insights
    |
    v
[Store in DB] --> insights table with expiry, confidence, domains
    |
    v
[API Response] --> Flutter displays cards on dashboard + insights page
```

---

## Example Generated Insights

| Type | Example |
|------|---------|
| Correlation | "Strong connection found: on days you meditate 10+ minutes, your mood is 1.2 points higher (based on 23 data points)" |
| Pattern | "You consistently skip workouts on Wednesdays. Consider rescheduling your Wednesday routine." |
| Anomaly | "Your resting heart rate jumped to 82 bpm yesterday, 15% above your baseline of 71. Worth monitoring." |
| Trend | "Great progress: your daily step count has been trending up 12% over the past 2 weeks." |
| Threshold | "Critical threshold: when your screen time exceeds 4 hours, your sleep quality drops by an average of 0.9 points." |
| Compound | "Your best mood days share 3 factors: 7+ hours sleep, 8000+ steps, and less than 3 hours screen time." |

---

## Checklist

- [ ] Create `nodejs/src/services/intelligence/` directory
- [ ] Implement data normalization layer for all 15 domains
- [ ] Implement `CorrelationService` with Pearson coefficient calculation
- [ ] Implement `PatternDetectorService` (day-of-week, time-of-day, sequences, thresholds)
- [ ] Implement `AnomalyDetectorService` with rolling baselines
- [ ] Implement `TrendAnalyzerService` with linear regression
- [ ] Implement `InsightGeneratorService` combining all signals
- [ ] Create `correlation.model.ts` + `user-baseline.model.ts` DB schemas
- [ ] Add DB migrations for correlations + baselines tables
- [ ] Integrate correlations into DataContextService system prompt
- [ ] Add correlation + pattern + trend endpoints to insights API
- [ ] Flutter: Create `insights_page.dart` with full insights view
- [ ] Flutter: Create `correlation_card.dart` widget
- [ ] Flutter: Create `trend_chart.dart` sparkline widget
- [ ] Flutter: Add insight cards + trend indicators to dashboard
- [ ] Test: verify correlation calculations with known data
- [ ] Test: verify anomaly detection triggers correctly
- [ ] Test: verify insights appear in Flutter UI
