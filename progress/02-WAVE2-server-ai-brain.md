# Wave 2: Server-Side AI Brain (Data Context)

> **Goal:** Transform backend Jarvis from a dumb relay into a data-aware AI brain
> **Status:** Complete (core implementation done)
> **Depends on:** Wave 1 (real data flowing to backend)

---

## The Problem

Currently `jarvis.controller.ts` line 132:
```typescript
{ role: 'system', content: 'You are Jarvis, a helpful AI assistant. Be concise and helpful.' }
```

That's ALL the context the backend AI gets. It knows nothing about the user's health, habits, goals, or history. The Flutter client already has rich context injection - now we bring that power to the server.

---

## What Changes

### New Files to Create (Backend)

| File | Purpose |
|------|---------|
| `nodejs/src/services/brain/data-context.service.ts` | Queries ALL 16 models, builds rich text context for LLM |
| `nodejs/src/services/brain/system-prompt.service.ts` | Constructs dynamic system prompts based on query + user data |
| `nodejs/src/services/brain/query-router.service.ts` | Determines if query needs server-side data or is simple chat |
| `nodejs/src/controllers/insights.controller.ts` | New API for server-generated insights |
| `nodejs/src/routes/insights.routes.ts` | Routes for insights endpoints |
| `nodejs/src/models/insight.model.ts` | Stores generated insights, correlations, recommendations |

### Files to Modify (Backend)

| File | Change |
|------|--------|
| `nodejs/src/controllers/jarvis.controller.ts` | Inject data context into LLM calls, add query routing |
| `nodejs/src/routes/jarvis.routes.ts` | Add new endpoint: POST `/api/jarvis/analyze` for deep analysis |
| `nodejs/src/index.ts` | Register insights routes |

### New Files to Create (Flutter)

| File | Purpose |
|------|---------|
| `lib/data/services/insights_api_service.dart` | HTTP client for insights API |
| `lib/providers/server_insights_provider.dart` | Fetches + caches server-generated insights |
| `lib/presentation/widgets/insight_card.dart` | UI card for displaying AI insights |

### Files to Modify (Flutter)

| File | Change |
|------|--------|
| `lib/providers/jarvis_provider.dart` | Route complex queries to server, simple ones stay client-side |
| `lib/presentation/pages/dashboard_page.dart` | Show server-generated insight cards |
| `lib/data/services/jarvis_api_service.dart` | Add `analyze()` method for server-side deep queries |

---

## DataContextBuilder Design

```typescript
// nodejs/src/services/brain/data-context.service.ts

interface UserDataContext {
  // Summary stats (always included - compact)
  summary: {
    todaySteps: number;
    todayWater: number;
    todayCalories: { consumed: number; burned: number };
    todayMood: number | null;
    sleepLastNight: { hours: number; quality: number } | null;
    activeStreaks: { feature: string; days: number }[];
    goalsMetToday: string[];
    goalsMissedToday: string[];
  };

  // Detailed history (included for relevant domains based on query)
  detailed?: {
    sleep7Days?: SleepRecord[];
    mood7Days?: MoodEntry[];
    steps7Days?: StepRecord[];
    habits?: { name: string; completionRate: number; streak: number }[];
    todosOverdue?: Todo[];
    calendarToday?: CalendarEvent[];
    weather?: WeatherData;
    screenTime7Days?: ScreenTimeRecord[];
    workouts7Days?: WorkoutSession[];
  };

  // User profile & preferences
  profile: {
    goals: Record<string, number>;
    timezone: string;
    memberSince: string;
  };
}

class DataContextService {
  /// Build compact summary context (always included, ~500 tokens)
  async buildSummary(userId: string): Promise<string>;

  /// Build detailed context for specific domains (~1500 tokens)
  async buildDetailed(userId: string, domains: string[]): Promise<string>;

  /// Full context for deep analysis (~3000 tokens)
  async buildFullContext(userId: string): Promise<string>;
}
```

## Query Router Design

```typescript
// nodejs/src/services/brain/query-router.service.ts

type QueryComplexity = 'simple' | 'data_aware' | 'deep_analysis';

interface QueryRoute {
  complexity: QueryComplexity;
  domains: string[];        // which data domains are relevant
  needsHistory: boolean;    // needs 7+ day history
  needsCorrelation: boolean; // needs cross-feature analysis
}

class QueryRouterService {
  /// Analyze the user's message to determine routing
  route(message: string, history: ChatMessage[]): QueryRoute;
}

// Examples:
// "hello" -> { complexity: 'simple', domains: [], ... }
// "how did I sleep?" -> { complexity: 'data_aware', domains: ['sleep'], needsHistory: false }
// "why am I tired lately?" -> { complexity: 'deep_analysis', domains: ['sleep','mood','workout','screen_time'], needsHistory: true }
// "generate my weekly plan" -> { complexity: 'deep_analysis', domains: ALL, needsHistory: true, needsCorrelation: true }
```

## Enhanced System Prompt

```typescript
// nodejs/src/services/brain/system-prompt.service.ts

class SystemPromptService {
  buildPrompt(context: UserDataContext, query: QueryRoute): string {
    return `You are Jarvis, the user's personal AI health & productivity assistant.
You have access to their real data from their phone sensors and manual tracking.

TODAY'S SNAPSHOT:
${context.summary}

${query.needsHistory ? `RECENT HISTORY:\n${context.detailed}` : ''}

RULES:
- Always reference specific numbers from the data (don't say "you slept well", say "you slept 7.2 hours")
- When you spot patterns, explain the correlation and confidence level
- Suggest specific, actionable next steps based on the data
- If data is missing or insufficient, say so honestly
- You can suggest actions using [ACTION:type:json] format (same 14 types as client)
- For goal adjustments, use [GOAL_SUGGEST:feature:newValue:reason]

AVAILABLE ACTIONS:
[ACTION:water:{"amount":250}] - Log water
[ACTION:mood:{"mood":4,"notes":"..."}] - Log mood
[ACTION:todo:{"title":"...","priority":"high"}] - Create todo
... (all 14 action types)

GOAL SUGGESTIONS (new):
[GOAL_SUGGEST:steps:9000:You've exceeded 8000 steps 6 of the last 7 days]
[GOAL_SUGGEST:water:2500:Your average intake is 2800ml, current goal 2000ml is too easy]
`;
  }
}
```

## Hybrid Routing: Client vs Server

```
User sends message in Flutter
    |
    v
JarvisProvider analyzes message locally
    |
    +-- Simple / real-time? --> Client handles (existing flow)
    |   "log 500ml water"
    |   "what's the weather?"
    |   "remind me to..."
    |
    +-- Needs historical data? --> Route to server
        "how did I sleep this week?"
        "why is my mood low?"
        "what patterns do you see?"
        "generate my weekly plan"
        "analyze my habits"
            |
            v
        POST /api/jarvis/chat (with routing hint)
            |
            v
        Server builds rich context from DB
            |
            v
        LLM call with full data context
            |
            v
        Response returned to Flutter
            |
            v
        ActionParser handles any [ACTION:...] tags
```

## Insights API

```typescript
// New endpoints:
GET  /api/insights              // Get latest insights for user
GET  /api/insights/weekly-report // Get this week's AI-generated report
POST /api/insights/generate     // Trigger on-demand insight generation
GET  /api/insights/correlations  // Get discovered correlations
```

## Insight Model

```typescript
interface Insight {
  id: string;
  userId: string;
  type: 'pattern' | 'anomaly' | 'recommendation' | 'correlation' | 'achievement';
  title: string;
  description: string;
  domains: string[];        // which features are involved
  confidence: number;       // 0-1
  actionable: boolean;
  suggestedAction?: string; // ACTION tag if applicable
  expiresAt: Date;          // insights are time-sensitive
  readAt: Date | null;
  createdAt: Date;
}
```

---

## Checklist

- [x] Create `nodejs/src/services/brain/` directory
- [x] Implement `DataContextService` - query all 16 models, build summary/detailed/full context strings
- [x] Implement `QueryRouterService` - keyword-based domain detection + complexity routing
- [x] Implement `SystemPromptService` - dynamic prompt with data injection + action format
- [x] Modify `jarvis.controller.ts` - inject data context into LLM calls via route+prompt
- [x] Create `insights.controller.ts` + routes (GET, POST /generate, POST /:id/dismiss, GET /context)
- [x] Create `insight.model.ts` with DB schema (type, domains, confidence, expiry)
- [x] Add insights table to init.sql
- [ ] Flutter: Update `JarvisProvider` to route complex queries to server
- [ ] Flutter: Create `InsightsApiService` + `ServerInsightsProvider`
- [ ] Flutter: Add insight cards to dashboard
- [ ] Test: verify data context shows in LLM responses
- [ ] Test: verify hybrid routing works correctly
