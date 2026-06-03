/**
 * QueryRouterService determines:
 * 1. What complexity level of data context is needed
 * 2. Which domains are relevant to the user's query
 */

export type QueryComplexity = 'simple' | 'data_aware' | 'deep_analysis';

export interface QueryRoute {
  complexity: QueryComplexity;
  domains: string[];
  contextLevel: 'summary' | 'detailed' | 'full';
}

// Keywords that signal domain relevance
const DOMAIN_KEYWORDS: Record<string, string[]> = {
  steps: ['steps', 'walk', 'walking', 'distance', 'pedometer', 'move', 'movement', '10000', '10k steps'],
  sleep: ['sleep', 'slept', 'bed', 'bedtime', 'wake', 'woke', 'insomnia', 'rest', 'nap', 'tired', 'fatigue'],
  heartRate: ['heart', 'heart rate', 'bpm', 'pulse', 'cardio', 'resting heart', 'hr'],
  workout: ['workout', 'exercise', 'training', 'gym', 'run', 'running', 'cycling', 'swim', 'yoga', 'hiit', 'strength', 'lift'],
  calories: ['calorie', 'calories', 'food', 'eat', 'eating', 'nutrition', 'diet', 'meal', 'protein', 'carbs', 'fat', 'macro'],
  water: ['water', 'hydration', 'hydrate', 'drink', 'drinking', 'fluid', 'thirst'],
  mood: ['mood', 'feeling', 'feel', 'happy', 'sad', 'anxious', 'stress', 'mental', 'emotion', 'wellbeing'],
  habits: ['habit', 'habits', 'routine', 'streak', 'consistency', 'daily routine'],
  todos: ['todo', 'task', 'tasks', 'to-do', 'to do', 'deadline', 'overdue', 'reminder', 'plan'],
  meditation: ['meditat', 'mindful', 'breathe', 'breathing', 'calm', 'relax'],
  focusTimer: ['focus', 'pomodoro', 'productivity', 'concentrate', 'deep work', 'distraction'],
  screenTime: ['screen', 'phone', 'screen time', 'device', 'usage', 'app usage'],
  weather: ['weather', 'temperature', 'rain', 'sun', 'forecast', 'outside', 'outdoor'],
};

// Keywords that signal complex / deep analysis queries
const DEEP_ANALYSIS_KEYWORDS = [
  'trend', 'pattern', 'correlat', 'why', 'because', 'reason',
  'compare', 'analysis', 'analyz', 'insight', 'improve',
  'recomm', 'suggest', 'advice', 'plan', 'strategy', 'goal adjust',
  'weekly report', 'monthly', 'progress', 'overall', 'summary of',
  'relationship between', 'affect', 'impact', 'how does',
  'best day', 'worst day', 'average', 'what should',
];

// Keywords that indicate no data context is needed
const SIMPLE_KEYWORDS = [
  'hello', 'hi', 'hey', 'thanks', 'thank', 'bye', 'ok', 'okay',
  'what is', 'define', 'explain', 'tell me about', 'how does',
  'joke', 'fun fact', 'trivia', 'who is', 'what are',
];

export const queryRouterService = {
  /**
   * Analyze a user message and determine routing
   */
  route(message: string): QueryRoute {
    const lower = message.toLowerCase();

    // Check if it's a simple query (no data needed)
    if (this.isSimpleQuery(lower)) {
      return {
        complexity: 'simple',
        domains: [],
        contextLevel: 'summary',
      };
    }

    // Detect relevant domains
    const domains = this.detectDomains(lower);

    // Check if it's a deep analysis query
    if (this.isDeepAnalysis(lower)) {
      return {
        complexity: 'deep_analysis',
        domains: domains.length > 0 ? domains : Object.keys(DOMAIN_KEYWORDS),
        contextLevel: 'full',
      };
    }

    // Data-aware query (mentions specific domains)
    if (domains.length > 0) {
      return {
        complexity: 'data_aware',
        domains,
        contextLevel: domains.length <= 3 ? 'detailed' : 'summary',
      };
    }

    // Default: data-aware with summary (user is talking to their health assistant)
    return {
      complexity: 'data_aware',
      domains: [],
      contextLevel: 'summary',
    };
  },

  /**
   * Detect which domains are mentioned in the query
   */
  detectDomains(lower: string): string[] {
    const matched: string[] = [];

    for (const [domain, keywords] of Object.entries(DOMAIN_KEYWORDS)) {
      for (const keyword of keywords) {
        if (lower.includes(keyword)) {
          matched.push(domain);
          break;
        }
      }
    }

    return matched;
  },

  /**
   * Check if query requires deep analysis
   */
  isDeepAnalysis(lower: string): boolean {
    return DEEP_ANALYSIS_KEYWORDS.some(kw => lower.includes(kw));
  },

  /**
   * Check if query is simple and doesn't need user data
   */
  isSimpleQuery(lower: string): boolean {
    // Very short greetings
    if (lower.length < 15) {
      return SIMPLE_KEYWORDS.some(kw => lower.includes(kw));
    }

    // Questions that are clearly not about user data
    const isGenericQuestion = SIMPLE_KEYWORDS.some(kw => lower.startsWith(kw));
    const mentionsDomain = Object.values(DOMAIN_KEYWORDS).flat().some(kw => lower.includes(kw));

    return isGenericQuestion && !mentionsDomain;
  },
};
