# Wave 4: Proactive AI (Scheduled Analysis + Push Notifications)

> **Goal:** Make Jarvis proactive - it analyzes data on a schedule, detects issues, and reaches out to the user via push notifications
> **Status:** Not Started
> **Depends on:** Wave 3 (correlation + anomaly detection engine)

---

## The Problem

Currently Jarvis only responds when the user talks to it. A truly smart assistant should proactively:
- Send a morning briefing notification
- Alert when something is off (sleep dropped, streak at risk, resting HR spike)
- Remind about unlogged data at appropriate times
- Deliver weekly progress reports without being asked

---

## What Changes

### New Files to Create (Backend)

| File | Purpose |
|------|---------|
| `nodejs/src/services/scheduler/analysis-scheduler.service.ts` | Cron-based scheduler for daily/weekly analysis jobs |
| `nodejs/src/services/scheduler/morning-briefing.service.ts` | Generates personalized morning briefing per user |
| `nodejs/src/services/scheduler/weekly-report.service.ts` | Generates comprehensive weekly progress report |
| `nodejs/src/services/scheduler/anomaly-alert.service.ts` | Checks for anomalies and triggers push notifications |
| `nodejs/src/services/scheduler/streak-monitor.service.ts` | Monitors streaks at risk and sends reminders |
| `nodejs/src/services/notification/fcm.service.ts` | Firebase Cloud Messaging integration for push notifications |
| `nodejs/src/services/notification/notification-template.service.ts` | Notification content templates and formatting |
| `nodejs/src/models/notification-log.model.ts` | Tracks sent notifications (prevent spam, analytics) |
| `nodejs/src/models/user-preferences.model.ts` | User notification preferences (quiet hours, channels, frequency) |
| `nodejs/src/controllers/notifications.controller.ts` | API for notification preferences + history |
| `nodejs/src/routes/notifications.routes.ts` | Notification routes |

### Files to Modify (Backend)

| File | Change |
|------|--------|
| `nodejs/src/index.ts` | Initialize scheduler on server start, register notification routes |
| `nodejs/src/services/intelligence/anomaly-detector.service.ts` | Hook into notification system when anomalies found |
| `nodejs/src/controllers/insights.controller.ts` | Add weekly report endpoint |

### New Files to Create (Flutter)

| File | Purpose |
|------|---------|
| `lib/data/services/fcm_service.dart` | Firebase Cloud Messaging setup, token management, foreground handlers |
| `lib/data/services/notification_service.dart` | Local notification display + deep linking from notifications |
| `lib/providers/notification_preferences_provider.dart` | Manage user's notification settings |
| `lib/presentation/pages/notification_settings_page.dart` | UI for notification preferences (quiet hours, types, frequency) |
| `lib/presentation/pages/weekly_report_page.dart` | Full weekly report view |
| `lib/presentation/widgets/morning_briefing_card.dart` | Expandable morning briefing card on dashboard |

### Files to Modify (Flutter)

| File | Change |
|------|--------|
| `pubspec.yaml` | Add `firebase_core`, `firebase_messaging`, `flutter_local_notifications` |
| `android/app/build.gradle.kts` | Firebase + google-services plugin |
| `android/app/google-services.json` | Firebase config (user must create Firebase project) |
| `lib/main.dart` | Initialize Firebase, register FCM token |
| `lib/presentation/pages/dashboard_page.dart` | Show morning briefing card |
| `lib/presentation/pages/settings_page.dart` | Link to notification settings |
| `lib/data/services/auth_api_service.dart` | Send FCM token to backend on login |

---

## Scheduled Jobs Design

```typescript
// nodejs/src/services/scheduler/analysis-scheduler.service.ts

class AnalysisScheduler {
  /// Initialize all cron jobs on server start
  initialize(): void {
    // Morning briefing: 7:00 AM in user's timezone
    cron.schedule('0 7 * * *', () => this.runMorningBriefings());

    // Midday check: 1:00 PM - gentle reminders for unlogged data
    cron.schedule('0 13 * * *', () => this.runMiddayReminders());

    // Evening analysis: 9:00 PM - daily wrap-up, streak alerts
    cron.schedule('0 21 * * *', () => this.runEveningAnalysis());

    // Weekly report: Sunday 8:00 PM
    cron.schedule('0 20 * * 0', () => this.runWeeklyReports());

    // Baseline update: 3:00 AM daily (low-traffic time)
    cron.schedule('0 3 * * *', () => this.updateBaselines());

    // Correlation refresh: Monday 4:00 AM weekly
    cron.schedule('0 4 * * 1', () => this.refreshCorrelations());
  }

  /// Process jobs respecting user timezone
  private async runForAllUsers(
    jobFn: (userId: string) => Promise<void>,
    targetHour: number
  ): Promise<void> {
    // Get all users whose local time matches targetHour
    const users = await this.getUsersAtLocalHour(targetHour);
    for (const user of users) {
      await jobFn(user.id);
    }
  }
}
```

## Morning Briefing Design

```typescript
// nodejs/src/services/scheduler/morning-briefing.service.ts

interface MorningBriefing {
  greeting: string;              // "Good morning! Here's your day ahead."
  sleepSummary: string;          // "You slept 7.2 hours last night (quality: 4/5)"
  todayGoals: string[];          // ["8,000 steps", "2,000ml water", "3 habits"]
  calendarPreview: string;       // "You have 3 meetings today, first at 9:30 AM"
  weatherNote: string;           // "Sunny, 24°C - great day for outdoor exercise"
  streaksAtRisk: string[];       // ["Your meditation streak (12 days) - don't forget today!"]
  yesterdayHighlight: string;    // "You hit your step goal yesterday! 🎯"
  aiInsight: string;             // "Your mood has been trending up this week - keep it going"
  overdueTodos: string[];        // ["Buy groceries (2 days overdue)"]
}

class MorningBriefingService {
  /// Generate morning briefing for a user
  async generate(userId: string): Promise<MorningBriefing>;

  /// Format as push notification (short)
  formatNotification(briefing: MorningBriefing): { title: string; body: string };

  /// Format as full card (for dashboard display)
  formatCard(briefing: MorningBriefing): string;
}
```

## Push Notification Categories

| Category | Trigger | Priority | Example |
|----------|---------|----------|---------|
| Morning Briefing | 7 AM daily | Normal | "Good morning! You slept 7.2h. 3 meetings today. Step goal: 8,000" |
| Streak Alert | Evening, streak at risk | High | "Your 15-day meditation streak ends tonight! 5 min is all it takes." |
| Anomaly Alert | Real-time detection | High | "Unusual: your resting HR is 82 bpm today (normally 68). How are you feeling?" |
| Midday Nudge | 1 PM if data missing | Low | "You haven't logged water today. Stay hydrated!" |
| Goal Achieved | When goal met | Normal | "You hit 8,000 steps! That's 5 days in a row." |
| Weekly Report | Sunday evening | Normal | "Your weekly report is ready. Highlights: mood up 12%, sleep consistent." |
| Insight Discovery | When new pattern found | Normal | "New pattern: your focus sessions are 40% longer on days you meditate." |

## FCM Service Design

```typescript
// nodejs/src/services/notification/fcm.service.ts

import * as admin from 'firebase-admin';

class FCMService {
  /// Send notification to a specific user
  async sendToUser(
    userId: string,
    notification: {
      title: string;
      body: string;
      data?: Record<string, string>;  // deep link data
      category: string;
      priority: 'high' | 'normal';
    }
  ): Promise<void>;

  /// Send to multiple users (batch)
  async sendToUsers(userIds: string[], notification: any): Promise<void>;

  /// Check notification preferences before sending
  private async shouldSend(userId: string, category: string): Promise<boolean> {
    const prefs = await UserPreferences.findOne({ userId });
    if (!prefs) return true; // default: send all

    // Check quiet hours
    const userLocalHour = this.getUserLocalHour(userId);
    if (userLocalHour >= prefs.quietHoursStart && userLocalHour < prefs.quietHoursEnd) {
      return false;
    }

    // Check category opt-out
    if (prefs.disabledCategories.includes(category)) {
      return false;
    }

    // Check rate limiting (max 5 notifications per day)
    const todayCount = await NotificationLog.countDocuments({
      userId,
      sentAt: { $gte: startOfDay(new Date()) }
    });
    return todayCount < prefs.maxDailyNotifications;
  }
}
```

## User Notification Preferences

```typescript
// nodejs/src/models/user-preferences.model.ts

interface UserNotificationPreferences {
  userId: string;
  fcmToken: string;                    // Device FCM token
  enabled: boolean;                    // Master toggle
  quietHoursStart: number;             // e.g., 22 (10 PM)
  quietHoursEnd: number;               // e.g., 7 (7 AM)
  maxDailyNotifications: number;       // default: 5
  disabledCategories: string[];        // categories user has opted out of
  morningBriefingTime: string;         // "07:00" - customizable
  weeklyReportDay: number;             // 0 = Sunday, default
  timezone: string;                    // from device or user setting
}
```

## Weekly Report Design

```typescript
// nodejs/src/services/scheduler/weekly-report.service.ts

interface WeeklyReport {
  period: { start: Date; end: Date };
  overallScore: number;              // 0-100 wellness score

  highlights: string[];              // top 3 achievements
  improvements: string[];            // top 3 areas that improved
  concerns: string[];                // areas trending down

  domainScores: {
    domain: string;
    score: number;                   // 0-100
    trend: 'up' | 'down' | 'stable';
    weekOverWeek: number;            // percentage change from last week
    bestDay: string;
    worstDay: string;
  }[];

  correlationsDiscovered: CorrelationResult[];
  patternsDetected: Pattern[];

  goalsProgress: {
    domain: string;
    goal: number;
    daysHit: number;                 // out of 7
    average: number;
    suggestion?: string;             // goal adjustment if warranted
  }[];

  streaks: {
    domain: string;
    currentStreak: number;
    longestEver: number;
    status: 'growing' | 'maintained' | 'broken';
  }[];

  aiSummary: string;                 // LLM-generated natural language summary
  nextWeekFocus: string[];           // AI-recommended focus areas
}
```

## Background Sync (Android WorkManager)

```dart
// lib/data/services/background_sync_service.dart (Wave 4 addition)

/// Uses Android WorkManager for periodic background health data sync
class BackgroundSyncService {
  /// Schedule periodic sync every 30 minutes
  Future<void> schedulePeriodicSync();

  /// One-time sync triggered by significant motion detection
  Future<void> scheduleEventDrivenSync();

  /// The actual sync work
  static Future<void> syncCallback() async {
    final healthService = HealthConnectService();
    final result = await healthService.syncRecent();
    // POST updated data to backend
    // Backend can then run anomaly detection on fresh data
  }
}
```

## Deep Linking from Notifications

```dart
// Notification tap -> opens specific page in app

// FCM data payload structure:
{
  "action": "open_page",
  "page": "weekly_report",    // or "insights", "sleep", "steps", etc.
  "params": { "reportId": "abc123" }
}

// In Flutter:
FirebaseMessaging.onMessageOpenedApp.listen((message) {
  final page = message.data['page'];
  final params = jsonDecode(message.data['params'] ?? '{}');
  NavigationService.navigateTo(page, params);
});
```

---

## Notification Rate Limiting Strategy

- Max 5 notifications per user per day (configurable)
- At least 2 hours between notifications (except high-priority anomalies)
- Morning briefing counts as 1 notification
- Streak alerts batched into one notification if multiple streaks at risk
- Weekly report is exempt from daily limit
- User can disable any category independently

---

## Checklist

- [ ] Set up Firebase project + add `google-services.json` to Android
- [ ] Add Firebase dependencies to Flutter (`firebase_core`, `firebase_messaging`, `flutter_local_notifications`)
- [ ] Implement `FCMService` on backend with Firebase Admin SDK
- [ ] Create `notification-log.model.ts` + `user-preferences.model.ts`
- [ ] Implement `AnalysisScheduler` with all cron jobs
- [ ] Implement `MorningBriefingService` - daily personalized briefing
- [ ] Implement `WeeklyReportService` - comprehensive weekly analysis
- [ ] Implement `AnomalyAlertService` - real-time anomaly notifications
- [ ] Implement `StreakMonitorService` - streak-at-risk alerts
- [ ] Implement `NotificationTemplateService` - notification formatting
- [ ] Create notifications API (preferences, history, mark read)
- [ ] Flutter: Implement `FCMService` - token registration, foreground handlers
- [ ] Flutter: Implement `NotificationService` - local display + deep linking
- [ ] Flutter: Create notification settings page
- [ ] Flutter: Create weekly report page
- [ ] Flutter: Add morning briefing card to dashboard
- [ ] Flutter: Implement deep linking from notification taps
- [ ] Flutter: Background sync with WorkManager (Android)
- [ ] Respect user quiet hours + rate limits
- [ ] Test: verify notifications arrive on Samsung device
- [ ] Test: verify deep linking opens correct page
- [ ] Test: verify scheduled jobs run at correct user-local times
