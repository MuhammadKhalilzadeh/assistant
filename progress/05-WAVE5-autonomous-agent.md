# Wave 5: Autonomous Agent

> **Goal:** Jarvis becomes a fully autonomous agent that takes actions, adjusts goals, generates plans, and manages the user's wellness proactively
> **Status:** Not Started
> **Depends on:** Wave 4 (scheduled analysis + notifications)

---

## The Problem

Even with insights and notifications, Jarvis still only *informs*. It doesn't *act*. A truly autonomous assistant should:
- Auto-adjust goals when trends show they're too easy or too hard
- Generate personalized weekly plans based on calendar, weather, and performance trends
- Execute actions on the user's behalf (with permission)
- Learn from user feedback to improve recommendations
- Orchestrate multi-step workflows (e.g., "prepare me for a marathon")

---

## What Changes

### New Files to Create (Backend)

| File | Purpose |
|------|---------|
| `nodejs/src/services/agent/goal-advisor.service.ts` | Analyzes trends and recommends goal adjustments |
| `nodejs/src/services/agent/weekly-planner.service.ts` | Generates personalized weekly plans |
| `nodejs/src/services/agent/auto-action.service.ts` | Executes approved actions on user's behalf |
| `nodejs/src/services/agent/feedback-learner.service.ts` | Learns from user accept/reject patterns |
| `nodejs/src/services/agent/workflow-engine.service.ts` | Multi-step workflow orchestration |
| `nodejs/src/models/goal-suggestion.model.ts` | Stores goal adjustment suggestions + user responses |
| `nodejs/src/models/weekly-plan.model.ts` | Stores generated weekly plans |
| `nodejs/src/models/auto-action-log.model.ts` | Audit trail of autonomous actions taken |
| `nodejs/src/models/user-agent-settings.model.ts` | Per-user agent autonomy settings |
| `nodejs/src/controllers/agent.controller.ts` | API for agent actions, plans, goal suggestions |
| `nodejs/src/routes/agent.routes.ts` | Agent routes |

### Files to Modify (Backend)

| File | Change |
|------|--------|
| `nodejs/src/services/scheduler/analysis-scheduler.service.ts` | Add weekly plan generation + goal review jobs |
| `nodejs/src/services/brain/system-prompt.service.ts` | Add agent capabilities to system prompt |
| `nodejs/src/controllers/jarvis.controller.ts` | Add agent action execution from chat responses |
| `nodejs/src/index.ts` | Register agent routes |

### New Files to Create (Flutter)

| File | Purpose |
|------|---------|
| `lib/presentation/pages/weekly_plan_page.dart` | View and interact with AI-generated weekly plan |
| `lib/presentation/pages/goal_suggestions_page.dart` | Review and approve/reject goal adjustments |
| `lib/presentation/pages/agent_settings_page.dart` | Configure agent autonomy level |
| `lib/presentation/widgets/goal_suggestion_card.dart` | Card showing suggested goal change with approve/reject |
| `lib/presentation/widgets/plan_day_card.dart` | Single day view within weekly plan |
| `lib/providers/agent_provider.dart` | Manages agent state, plans, suggestions |
| `lib/data/services/agent_api_service.dart` | HTTP client for agent endpoints |

### Files to Modify (Flutter)

| File | Change |
|------|--------|
| `lib/presentation/pages/dashboard_page.dart` | Show weekly plan summary, pending goal suggestions |
| `lib/presentation/pages/settings_page.dart` | Link to agent settings |
| `lib/providers/jarvis_provider.dart` | Handle agent action responses from server |

---

## Goal Advisor Design

```typescript
// nodejs/src/services/agent/goal-advisor.service.ts

interface GoalSuggestion {
  id: string;
  userId: string;
  domain: string;                    // e.g., 'steps', 'water', 'sleep'
  currentGoal: number;
  suggestedGoal: number;
  direction: 'increase' | 'decrease';
  reason: string;                    // "You've exceeded 8,000 steps 6 of the last 7 days"
  confidence: number;                // 0-1
  evidence: {
    daysAnalyzed: number;
    daysGoalMet: number;
    average: number;
    trend: 'up' | 'down' | 'stable';
    percentAboveGoal: number;        // how far above/below on average
  };
  status: 'pending' | 'accepted' | 'rejected' | 'expired';
  createdAt: Date;
  respondedAt: Date | null;
}

class GoalAdvisorService {
  /// Analyze all domains and generate goal suggestions
  async reviewGoals(userId: string): Promise<GoalSuggestion[]>;

  /// Rules:
  /// - Goal met 6+/7 days AND average is 120%+ of goal → suggest increase
  /// - Goal met 1-/7 days AND average is <60% of goal → suggest decrease
  /// - Never suggest more than 20% change at once
  /// - Don't suggest changes for domains with <14 days of data
  /// - Max 3 suggestions per week (avoid overwhelming user)
  /// - Don't re-suggest a rejected domain for 30 days

  /// Apply a user-accepted suggestion
  async applySuggestion(suggestionId: string): Promise<void>;
}
```

## Weekly Planner Design

```typescript
// nodejs/src/services/agent/weekly-planner.service.ts

interface DayPlan {
  date: string;
  dayOfWeek: string;
  isWorkday: boolean;

  // Calendar-aware scheduling
  calendarEvents: { time: string; title: string }[];
  freeBlocks: { start: string; end: string }[];

  // Activity recommendations
  recommendations: {
    activity: string;         // "Morning run", "Meditation session", "Hydration focus"
    domain: string;           // "workout", "meditation", "water"
    suggestedTime: string;    // "07:00"
    duration: number;         // minutes
    priority: 'must_do' | 'should_do' | 'nice_to_do';
    reason: string;           // "You haven't worked out since Tuesday"
    weatherNote?: string;     // "Rain expected after 2 PM, go in the morning"
  }[];

  // Daily targets (may differ from weekly goals)
  targets: {
    domain: string;
    target: number;
    rationale: string;        // "Rest day - lower step target"
  }[];
}

interface WeeklyPlan {
  id: string;
  userId: string;
  weekStart: Date;
  weekEnd: Date;
  days: DayPlan[];

  // Week-level goals
  weeklyGoals: {
    domain: string;
    weeklyTarget: number;
    strategy: string;         // "Front-load workouts Mon-Wed, rest Thu, active weekend"
  }[];

  // Focus areas for the week
  focusAreas: string[];       // ["Improve sleep consistency", "Hit step goal 5/7 days"]

  // AI-generated narrative
  aiSummary: string;          // Natural language overview of the week's plan

  status: 'draft' | 'active' | 'completed';
  createdAt: Date;
}

class WeeklyPlannerService {
  /// Generate a weekly plan for the upcoming week
  async generatePlan(userId: string): Promise<WeeklyPlan>;

  /// Factors considered:
  /// - Calendar events (busy days get lighter wellness targets)
  /// - Weather forecast (outdoor activities on nice days)
  /// - Recent performance trends (which domains need attention)
  /// - Correlations (schedule activities that boost connected metrics)
  /// - User patterns (e.g., user prefers morning workouts)
  /// - Recovery needs (after intense workout days, suggest rest)
  /// - Streak maintenance (prioritize near-risk streaks)

  /// Regenerate plan mid-week if circumstances change
  async adjustPlan(planId: string, reason: string): Promise<WeeklyPlan>;
}
```

## Auto-Action Engine Design

```typescript
// nodejs/src/services/agent/auto-action.service.ts

type AutonomyLevel = 'suggest_only' | 'ask_first' | 'auto_with_notify' | 'full_auto';

interface AutoAction {
  id: string;
  userId: string;
  actionType: string;           // one of the 14 ACTION types
  payload: Record<string, any>;
  reason: string;               // why the agent took this action
  autonomyLevel: AutonomyLevel; // what level was used
  status: 'pending_approval' | 'executed' | 'rejected' | 'failed';
  executedAt: Date | null;
}

class AutoActionService {
  /// Determine and execute appropriate auto-actions
  async processAutoActions(userId: string): Promise<AutoAction[]>;

  /// Auto-action examples by autonomy level:

  // suggest_only (default for new users):
  // - Suggests in chat: "I notice you haven't logged water. Want me to remind you at 2 PM?"
  // - No actual execution

  // ask_first:
  // - Push notification: "Your step goal should be 9,000 based on recent performance. Apply?"
  // - User must tap to approve

  // auto_with_notify:
  // - Executes action + sends notification
  // - "I adjusted your step goal from 8,000 to 9,000 based on your 2-week trend"
  // - User can undo

  // full_auto:
  // - Executes silently, logs for transparency
  // - Only for low-risk actions (reminders, logging nudges)
  // - Never for goal changes or data modifications

  /// Safety rules:
  /// - Goal changes: never full_auto, always at least ask_first
  /// - Data creation (log water, create todo): max auto_with_notify
  /// - Data deletion: always ask_first
  /// - Settings changes: always ask_first
  /// - Reminders/nudges: can be full_auto
}
```

## Feedback Learning Design

```typescript
// nodejs/src/services/agent/feedback-learner.service.ts

interface FeedbackSignal {
  userId: string;
  domain: string;
  actionType: 'goal_suggestion' | 'plan_recommendation' | 'auto_action' | 'insight';
  accepted: boolean;
  context: Record<string, any>;  // what the agent suggested + why
  timestamp: Date;
}

class FeedbackLearnerService {
  /// Record user's response to a suggestion
  async recordFeedback(signal: FeedbackSignal): Promise<void>;

  /// Adjust future behavior based on accumulated feedback
  async getAdjustedStrategy(userId: string, domain: string): Promise<{
    confidenceMultiplier: number;   // reduce suggestion frequency if often rejected
    preferredApproach: string;      // learned preferences
    avoidPatterns: string[];        // things user consistently rejects
  }>;

  /// Examples:
  /// - User rejects step goal increases → stop suggesting, they're happy at current level
  /// - User always accepts morning workout suggestions → prioritize morning scheduling
  /// - User rejects evening meditation → suggest morning or lunch meditation instead
  /// - User ignores water reminders after 8 PM → stop sending them past 8 PM
}
```

## Workflow Engine Design

```typescript
// nodejs/src/services/agent/workflow-engine.service.ts

interface Workflow {
  id: string;
  userId: string;
  name: string;               // "Marathon Preparation", "Better Sleep Program"
  goal: string;               // User's stated goal
  steps: WorkflowStep[];
  currentStep: number;
  status: 'active' | 'paused' | 'completed' | 'abandoned';
  startedAt: Date;
  estimatedCompletion: Date;
}

interface WorkflowStep {
  order: number;
  title: string;
  description: string;
  duration: string;           // "1 week", "2 weeks"
  targets: { domain: string; target: number }[];
  milestones: string[];
  status: 'pending' | 'active' | 'completed' | 'skipped';
}

class WorkflowEngineService {
  /// Create a multi-week workflow from a high-level goal
  async createWorkflow(userId: string, goal: string): Promise<Workflow>;

  /// Example: "I want to run a 5K in 8 weeks"
  /// → 8-step progressive workflow:
  ///   Week 1: Walk 30min/day, 6000 steps goal
  ///   Week 2: Walk/jog intervals, 7000 steps
  ///   Week 3: Jog 20min, add stretching
  ///   ...
  ///   Week 8: Run 5K, recovery plan
  ///
  /// Each week adjusts goals, suggests workouts, monitors progress,
  /// and adapts if user falls behind or surges ahead

  /// Progress check - are milestones being met?
  async checkProgress(workflowId: string): Promise<{
    onTrack: boolean;
    adjustments: string[];
    nextMilestone: string;
  }>;

  /// Adapt workflow based on actual performance
  async adaptWorkflow(workflowId: string): Promise<Workflow>;
}
```

## Agent Autonomy Settings (Flutter)

```dart
// lib/presentation/pages/agent_settings_page.dart

/// User configures how autonomous Jarvis can be

// Global autonomy level
enum AutonomyLevel { suggestOnly, askFirst, autoWithNotify, fullAuto }

// Per-domain overrides
// e.g., user might want:
//   - Goals: ask_first (always ask before changing goals)
//   - Reminders: full_auto (send reminders freely)
//   - Weekly plan: auto_with_notify (generate plan, notify me)
//   - Data logging: suggest_only (just suggest, I'll log myself)

// Safety constraints (always enforced regardless of level):
//   - Never delete data without explicit confirmation
//   - Never change goals by more than 20% at once
//   - Max 3 auto-actions per day
//   - All auto-actions logged and reviewable
//   - One-tap undo for any auto-action
```

## Agent Action Flow

```
Scheduled Analysis runs (Wave 4)
    |
    v
Insights + Anomalies + Trends generated
    |
    v
Goal Advisor checks if any goals need adjustment
    |
    +-- Suggestion generated
    |       |
    |       v
    |   Check user autonomy level for 'goals' domain
    |       |
    |       +-- suggest_only → Queue insight card in app
    |       +-- ask_first → Send push notification with approve/reject
    |       +-- auto_with_notify → Apply change + notify user + enable undo
    |       +-- full_auto → (not allowed for goals)
    |
    v
Weekly Planner generates next week's plan (Sunday evening)
    |
    +-- Considers: calendar, weather, trends, correlations, feedback history
    |
    v
    Plan delivered to user via notification + dashboard card
    |
    v
Throughout the week:
    +-- Monitor adherence to plan
    +-- Send contextual nudges for plan items
    +-- Adapt plan if circumstances change (rain cancels outdoor workout)
    +-- Celebrate milestones
    +-- End-of-week review feeds into next plan
```

---

## Example Agent Behaviors

| Trigger | Agent Action | Autonomy Level |
|---------|-------------|----------------|
| User exceeded step goal 6/7 days | Suggest increasing goal from 8K to 9K | ask_first |
| Rain forecast on planned outdoor workout day | Move workout to indoor alternative | auto_with_notify |
| User's sleep declined 3 days in a row | Send concern notification + suggest screen time limit | suggest_only |
| Streak about to break at 9 PM | Send urgent reminder with motivational message | auto_with_notify |
| User said "prepare me for a marathon" | Create 12-week progressive workflow | ask_first |
| Weekly plan generated | Deliver plan via notification on Sunday evening | auto_with_notify |
| User consistently rejects water reminders after 8 PM | Stop sending water reminders after 8 PM | learned behavior |
| Big calendar day (6+ meetings) | Reduce activity targets, suggest short meditation | auto_with_notify |

---

## Checklist

- [ ] Create `nodejs/src/services/agent/` directory
- [ ] Implement `GoalAdvisorService` with trend-based goal suggestions
- [ ] Implement `WeeklyPlannerService` with calendar + weather + trend integration
- [ ] Implement `AutoActionService` with autonomy levels + safety rules
- [ ] Implement `FeedbackLearnerService` for learning from accept/reject patterns
- [ ] Implement `WorkflowEngineService` for multi-week goal programs
- [ ] Create `goal-suggestion.model.ts` + `weekly-plan.model.ts` + `auto-action-log.model.ts`
- [ ] Create `user-agent-settings.model.ts` for per-user autonomy configuration
- [ ] Create agent API controller + routes
- [ ] Add goal review + weekly plan generation to scheduler
- [ ] Update system prompt with agent capabilities
- [ ] Flutter: Create `weekly_plan_page.dart` with day-by-day view
- [ ] Flutter: Create `goal_suggestions_page.dart` with approve/reject UI
- [ ] Flutter: Create `agent_settings_page.dart` with autonomy controls
- [ ] Flutter: Create `agent_provider.dart` managing agent state
- [ ] Flutter: Create `agent_api_service.dart` HTTP client
- [ ] Flutter: Add weekly plan summary + pending suggestions to dashboard
- [ ] Flutter: Implement one-tap undo for auto-actions
- [ ] Test: verify goal suggestions are reasonable and respect safety rules
- [ ] Test: verify weekly plan considers calendar + weather
- [ ] Test: verify feedback learning adjusts behavior over time
- [ ] Test: verify autonomy levels are enforced correctly
- [ ] Test: verify auto-actions are logged and undoable
