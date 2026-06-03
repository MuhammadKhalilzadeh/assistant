# Smart Assistant - Master Implementation Plan

> **Goal:** Transform all 15 feature modules into intelligent, sensor-connected, AI-orchestrated experiences powered by a hybrid central AI brain.

> **Created:** 2026-06-02 | **Status:** Planning

---

## Current State Summary

### What We Have
- **21 Flutter screens** across 15 data domains (water, sleep, steps, mood, calories, workout, heart rate, meditation, focus timer, screen time, habits, todos, inbox, calendar, weather)
- **Flutter-side Jarvis AI** with context injection from all 15 providers, 14 action types, daily briefing, smart nudges, cross-domain insights
- **Node.js backend** with 16 data models, full CRUD, basic stats (streaks, weekly averages, goal completion)
- **Backend Jarvis** is a dumb relay - sends messages to LLM with generic system prompt "You are Jarvis, a helpful AI assistant" - **NO user data context**
- **Health data is MOCKED** - steps, heart rate, sleep, workout have no device sensor integration
- **Screen time** works on Android only via MethodChannel
- **Calendar** reads from device via `device_calendar` plugin
- **Location** works via `geolocator` for weather

### What's Missing
1. No Health Connect / Samsung Health integration (steps, HR, sleep, workout are fake)
2. Backend Jarvis has zero knowledge of user's data
3. No cross-feature correlation engine (e.g., "your mood drops when you sleep < 6h")
4. No scheduled analysis or proactive intelligence
5. No push notifications for anomalies/reminders
6. No adaptive goals based on performance trends
7. No autonomous agent capabilities (auto-adjust, weekly plan generation)

---

## Architecture: Hybrid AI Brain

```
+-------------------------------------------------------------------+
|                        FLUTTER CLIENT                              |
|                                                                    |
|  [Jarvis Chat UI] <-> [JarvisProvider]                            |
|       |                    |                                       |
|       |              [JarvisDataService]  -- gathers from all     |
|       |              15 Riverpod providers for REAL-TIME context   |
|       |                    |                                       |
|       |              [ActionParser] -- executes AI actions         |
|       |              directly on app providers                     |
|       |                    |                                       |
|  [HealthConnectService] -- syncs device sensors to providers      |
|  [SmartNudgeEngine]     -- local nudges from cached insights      |
|  [InsightsProvider]     -- displays server-generated insights     |
|                                                                    |
|  Client Responsibilities:                                          |
|  - Real-time chat context injection (current session data)        |
|  - Action execution (log water, create todo, etc.)                |
|  - Device sensor sync (Health Connect -> providers -> backend)    |
|  - Display server insights, nudges, weekly reports                |
|  - Offline-first caching of AI insights                           |
+-------------------------------------------------------------------+
          |                    ^
          | HTTP/REST          | Push Notifications (FCM)
          v                    |
+-------------------------------------------------------------------+
|                        NODE.JS BACKEND                             |
|                                                                    |
|  [Jarvis Brain Controller]                                        |
|       |                                                            |
|       +-- [DataContextBuilder] -- queries ALL 16 models for       |
|       |   rich user data context (30-day history, stats, goals)   |
|       |                                                            |
|       +-- [CorrelationEngine] -- cross-feature pattern analysis   |
|       |   "mood correlates with sleep quality (r=0.73)"           |
|       |                                                            |
|       +-- [InsightGenerator] -- produces actionable insights      |
|       |   from correlations + trends + anomalies                  |
|       |                                                            |
|       +-- [GoalAdvisor] -- adaptive goal recommendations          |
|       |   based on 30-day performance trends                      |
|       |                                                            |
|       +-- [WeeklyPlanGenerator] -- autonomous weekly plan         |
|       |   considering all domains + calendar + weather             |
|       |                                                            |
|       +-- [ScheduledAnalysis] -- cron jobs for daily/weekly       |
|           analysis runs, anomaly detection, streak alerts         |
|                                                                    |
|  Server Responsibilities:                                          |
|  - Deep data analysis across ALL user history (30+ days)          |
|  - Cross-feature correlation and pattern detection                |
|  - Scheduled analysis runs (daily digest, weekly report)          |
|  - Anomaly detection and push notification triggers               |
|  - Adaptive goal recommendations                                  |
|  - Autonomous weekly plan generation                              |
|  - Rich system prompt construction for LLM calls                  |
+-------------------------------------------------------------------+
```

### How Client + Server AI Coordinate

| Scenario | Who Handles It | Why |
|----------|---------------|-----|
| User asks "how did I sleep?" | **Client** sends real-time context from sleep provider | Instant response, data already in memory |
| User asks "why am I tired lately?" | **Server** runs cross-feature query (sleep + mood + workout + screen time last 14 days) | Needs historical DB access + correlation |
| Morning daily briefing | **Client** gathers from all 15 providers | Real-time snapshot, already implemented |
| "Generate my weekly plan" | **Server** queries all data + calendar + weather forecast | Heavy computation, needs full history |
| Anomaly: user's sleep dropped 40% | **Server** scheduled job detects it, sends push notification | Background analysis, no app open needed |
| Smart nudge: "You haven't logged water" | **Client** checks local cache | Immediate, no network needed |
| Adaptive goal: "Increase step goal to 9000" | **Server** analyzes 30-day trend, suggests via insights API | Statistical analysis needs history |

---

## Implementation Waves

### Wave 1: Health Connect Integration (Phone Sensor Access)
> Connect all health modules to real device sensors via Samsung Health / Health Connect

### Wave 2: Server-Side AI Brain (Data Context)
> Give backend Jarvis full access to ALL user data with rich context building

### Wave 3: Cross-Feature Intelligence
> Correlation engine, pattern detection, smart insights generated server-side

### Wave 4: Proactive AI (Scheduled Analysis + Push Notifications)
> Daily/weekly analysis jobs, anomaly detection, FCM push notifications

### Wave 5: Autonomous Agent
> Auto-adjust goals, generate weekly plans, take actions on behalf of user

---

See individual wave files for detailed implementation specs:
- `progress/01-WAVE1-health-connect.md`
- `progress/02-WAVE2-server-ai-brain.md`
- `progress/03-WAVE3-cross-feature-intelligence.md`
- `progress/04-WAVE4-proactive-ai.md`
- `progress/05-WAVE5-autonomous-agent.md`
