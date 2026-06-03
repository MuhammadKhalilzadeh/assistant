-- =============================================
-- USERS (Authentication)
-- =============================================

CREATE TABLE IF NOT EXISTS users (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  google_id VARCHAR(255) NOT NULL UNIQUE,
  email VARCHAR(255) NOT NULL UNIQUE,
  display_name VARCHAR(255),
  photo_url TEXT,
  nickname VARCHAR(100),
  gmail_access_token TEXT,
  gmail_refresh_token TEXT,
  gmail_token_expiry TIMESTAMP,
  gmail_connected BOOLEAN DEFAULT FALSE,
  refresh_token_hash VARCHAR(255),
  last_login_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX IF NOT EXISTS idx_users_google_id ON users(google_id);
CREATE INDEX IF NOT EXISTS idx_users_email ON users(email);

-- Categories table
CREATE TABLE IF NOT EXISTS categories (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  name VARCHAR(100) NOT NULL,
  color VARCHAR(7) NOT NULL,
  icon VARCHAR(50)
);

-- Todos table
CREATE TABLE IF NOT EXISTS todos (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  title VARCHAR(255) NOT NULL,
  description TEXT,
  is_completed BOOLEAN DEFAULT FALSE,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  completed_at TIMESTAMP,
  due_date DATE,
  priority INTEGER DEFAULT 2 CHECK (priority BETWEEN 1 AND 3),
  category_id UUID REFERENCES categories(id) ON DELETE SET NULL
);

-- Create indexes for better query performance
CREATE INDEX IF NOT EXISTS idx_todos_user_id ON todos(user_id);
CREATE INDEX IF NOT EXISTS idx_todos_category_id ON todos(category_id);
CREATE INDEX IF NOT EXISTS idx_todos_is_completed ON todos(is_completed);
CREATE INDEX IF NOT EXISTS idx_todos_due_date ON todos(due_date);
CREATE INDEX IF NOT EXISTS idx_todos_created_at ON todos(created_at);
CREATE INDEX IF NOT EXISTS idx_categories_user_id ON categories(user_id);

-- Habits table
CREATE TABLE IF NOT EXISTS habits (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  name VARCHAR(255) NOT NULL,
  description TEXT,
  icon VARCHAR(50) DEFAULT 'check_circle',
  category VARCHAR(20) DEFAULT 'other' CHECK (category IN ('health', 'fitness', 'mindfulness', 'learning', 'productivity', 'social', 'other')),
  frequency VARCHAR(20) DEFAULT 'daily' CHECK (frequency IN ('daily', 'weekdays', 'weekends', 'specificDays')),
  target_days INTEGER[] DEFAULT ARRAY[0,1,2,3,4,5,6],
  streak INTEGER DEFAULT 0,
  best_streak INTEGER DEFAULT 0,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Habit completions table (tracks which days each habit was completed)
CREATE TABLE IF NOT EXISTS habit_completions (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  habit_id UUID NOT NULL REFERENCES habits(id) ON DELETE CASCADE,
  completed_date DATE NOT NULL DEFAULT CURRENT_DATE,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  UNIQUE(user_id, habit_id, completed_date)
);

-- Indexes for habits
CREATE INDEX IF NOT EXISTS idx_habits_user_id ON habits(user_id);
CREATE INDEX IF NOT EXISTS idx_habits_category ON habits(category);
CREATE INDEX IF NOT EXISTS idx_habits_created_at ON habits(created_at);
CREATE INDEX IF NOT EXISTS idx_habit_completions_user_id ON habit_completions(user_id);
CREATE INDEX IF NOT EXISTS idx_habit_completions_habit_id ON habit_completions(habit_id);
CREATE INDEX IF NOT EXISTS idx_habit_completions_date ON habit_completions(completed_date);

-- Water logs table
CREATE TABLE IF NOT EXISTS water_logs (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  amount_ml INTEGER NOT NULL CHECK (amount_ml > 0 AND amount_ml <= 5000),
  beverage_type VARCHAR(20) DEFAULT 'water' CHECK (beverage_type IN ('water', 'coffee', 'tea', 'juice', 'milk', 'other')),
  note TEXT,
  logged_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Hydration goals table
CREATE TABLE IF NOT EXISTS hydration_goals (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  daily_goal_ml INTEGER NOT NULL DEFAULT 3000 CHECK (daily_goal_ml >= 500 AND daily_goal_ml <= 10000),
  reminder_interval_minutes INTEGER DEFAULT 60,
  reminders_enabled BOOLEAN DEFAULT TRUE,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Indexes for water logs
CREATE INDEX IF NOT EXISTS idx_water_logs_user_id ON water_logs(user_id);
CREATE INDEX IF NOT EXISTS idx_water_logs_logged_at ON water_logs(logged_at);
CREATE INDEX IF NOT EXISTS idx_water_logs_beverage_type ON water_logs(beverage_type);
CREATE INDEX IF NOT EXISTS idx_hydration_goals_user_id ON hydration_goals(user_id);

-- =============================================
-- HEART RATE TRACKING
-- =============================================

CREATE TABLE IF NOT EXISTS heart_rate_records (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  bpm INTEGER NOT NULL CHECK (bpm >= 30 AND bpm <= 250),
  zone VARCHAR(20) DEFAULT 'resting' CHECK (zone IN ('resting', 'warmUp', 'fatBurn', 'cardio', 'peak')),
  recorded_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS heart_rate_goals (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  target_resting_bpm INTEGER NOT NULL DEFAULT 65,
  max_bpm INTEGER NOT NULL DEFAULT 180,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX IF NOT EXISTS idx_heart_rate_records_user_id ON heart_rate_records(user_id);
CREATE INDEX IF NOT EXISTS idx_heart_rate_records_recorded_at ON heart_rate_records(recorded_at);
CREATE INDEX IF NOT EXISTS idx_heart_rate_records_zone ON heart_rate_records(zone);
CREATE INDEX IF NOT EXISTS idx_heart_rate_goals_user_id ON heart_rate_goals(user_id);

-- =============================================
-- STEPS TRACKING
-- =============================================

CREATE TABLE IF NOT EXISTS step_records (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  date DATE NOT NULL,
  steps INTEGER NOT NULL DEFAULT 0 CHECK (steps >= 0 AND steps <= 200000),
  goal INTEGER NOT NULL DEFAULT 10000,
  distance_km DOUBLE PRECISION DEFAULT 0,
  calories_burned INTEGER DEFAULT 0,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  UNIQUE(user_id, date)
);

CREATE TABLE IF NOT EXISTS steps_goals (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  daily_goal INTEGER NOT NULL DEFAULT 10000,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX IF NOT EXISTS idx_step_records_user_id ON step_records(user_id);
CREATE INDEX IF NOT EXISTS idx_step_records_date ON step_records(date);
CREATE INDEX IF NOT EXISTS idx_steps_goals_user_id ON steps_goals(user_id);

-- =============================================
-- MOOD TRACKING
-- =============================================

CREATE TABLE IF NOT EXISTS mood_entries (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  mood VARCHAR(20) NOT NULL CHECK (mood IN ('great', 'good', 'okay', 'bad', 'awful')),
  notes TEXT,
  activities TEXT[] DEFAULT ARRAY[]::TEXT[],
  recorded_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS mood_goals (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  daily_entries_goal INTEGER NOT NULL DEFAULT 1,
  target_mood VARCHAR(20) DEFAULT 'good' CHECK (target_mood IN ('great', 'good', 'okay', 'bad', 'awful')),
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX IF NOT EXISTS idx_mood_entries_user_id ON mood_entries(user_id);
CREATE INDEX IF NOT EXISTS idx_mood_entries_recorded_at ON mood_entries(recorded_at);
CREATE INDEX IF NOT EXISTS idx_mood_entries_mood ON mood_entries(mood);
CREATE INDEX IF NOT EXISTS idx_mood_goals_user_id ON mood_goals(user_id);

-- =============================================
-- SLEEP TRACKING
-- =============================================

CREATE TABLE IF NOT EXISTS sleep_records (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  bed_time TIMESTAMP NOT NULL,
  wake_time TIMESTAMP NOT NULL,
  quality VARCHAR(20) DEFAULT 'good' CHECK (quality IN ('poor', 'fair', 'good', 'excellent')),
  notes TEXT,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT chk_wake_after_bed CHECK (wake_time > bed_time)
);

CREATE TABLE IF NOT EXISTS sleep_goals (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  goal_minutes INTEGER NOT NULL DEFAULT 480,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX IF NOT EXISTS idx_sleep_records_user_id ON sleep_records(user_id);
CREATE INDEX IF NOT EXISTS idx_sleep_records_bed_time ON sleep_records(bed_time);
CREATE INDEX IF NOT EXISTS idx_sleep_records_wake_time ON sleep_records(wake_time);
CREATE INDEX IF NOT EXISTS idx_sleep_goals_user_id ON sleep_goals(user_id);

-- =============================================
-- MEDITATION TRACKING
-- =============================================

CREATE TABLE IF NOT EXISTS meditation_sessions (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  type VARCHAR(20) NOT NULL CHECK (type IN ('breathing', 'guided', 'unguided', 'sleep', 'focus')),
  start_time TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  duration_minutes INTEGER NOT NULL DEFAULT 10 CHECK (duration_minutes >= 1 AND duration_minutes <= 480),
  is_completed BOOLEAN DEFAULT FALSE,
  notes TEXT,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS meditation_goals (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  daily_minutes_goal INTEGER NOT NULL DEFAULT 10,
  weekly_sessions_goal INTEGER NOT NULL DEFAULT 7,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX IF NOT EXISTS idx_meditation_sessions_user_id ON meditation_sessions(user_id);
CREATE INDEX IF NOT EXISTS idx_meditation_sessions_start_time ON meditation_sessions(start_time);
CREATE INDEX IF NOT EXISTS idx_meditation_sessions_type ON meditation_sessions(type);
CREATE INDEX IF NOT EXISTS idx_meditation_goals_user_id ON meditation_goals(user_id);

-- =============================================
-- WORKOUT TRACKING
-- =============================================

CREATE TABLE IF NOT EXISTS workout_sessions (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  type VARCHAR(20) NOT NULL CHECK (type IN ('running', 'cycling', 'strength', 'yoga', 'swimming', 'walking', 'hiit', 'other')),
  start_time TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  end_time TIMESTAMP,
  duration_minutes INTEGER DEFAULT 0 CHECK (duration_minutes >= 0 AND duration_minutes <= 1440),
  calories_burned INTEGER DEFAULT 0,
  exercises JSONB DEFAULT '[]',
  notes TEXT,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS workout_goals (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  weekly_minutes_goal INTEGER NOT NULL DEFAULT 150,
  weekly_sessions_goal INTEGER NOT NULL DEFAULT 5,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX IF NOT EXISTS idx_workout_sessions_user_id ON workout_sessions(user_id);
CREATE INDEX IF NOT EXISTS idx_workout_sessions_start_time ON workout_sessions(start_time);
CREATE INDEX IF NOT EXISTS idx_workout_sessions_type ON workout_sessions(type);
CREATE INDEX IF NOT EXISTS idx_workout_goals_user_id ON workout_goals(user_id);

-- =============================================
-- CALORIES / NUTRITION TRACKING
-- =============================================

CREATE TABLE IF NOT EXISTS calorie_entries (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  food_name VARCHAR(255) NOT NULL,
  calories INTEGER NOT NULL DEFAULT 0 CHECK (calories >= 0 AND calories <= 10000),
  meal_type VARCHAR(20) NOT NULL CHECK (meal_type IN ('breakfast', 'lunch', 'dinner', 'snack')),
  protein INTEGER DEFAULT 0,
  carbs INTEGER DEFAULT 0,
  fat INTEGER DEFAULT 0,
  food_category VARCHAR(20) DEFAULT 'other' CHECK (food_category IN ('grains', 'protein', 'dairy', 'fruits', 'vegetables', 'fats', 'sweets', 'beverages', 'other')),
  serving_size INTEGER,
  note TEXT,
  logged_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS nutrition_goals (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  daily_calorie_goal INTEGER NOT NULL DEFAULT 2000,
  protein_goal_grams INTEGER NOT NULL DEFAULT 50,
  carbs_goal_grams INTEGER NOT NULL DEFAULT 250,
  fat_goal_grams INTEGER NOT NULL DEFAULT 65,
  reminders_enabled BOOLEAN DEFAULT FALSE,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX IF NOT EXISTS idx_calorie_entries_user_id ON calorie_entries(user_id);
CREATE INDEX IF NOT EXISTS idx_calorie_entries_logged_at ON calorie_entries(logged_at);
CREATE INDEX IF NOT EXISTS idx_calorie_entries_meal_type ON calorie_entries(meal_type);
CREATE INDEX IF NOT EXISTS idx_nutrition_goals_user_id ON nutrition_goals(user_id);

-- =============================================
-- FOCUS TIMER
-- =============================================

CREATE TABLE IF NOT EXISTS focus_timer_sessions (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  type VARCHAR(20) NOT NULL CHECK (type IN ('focus', 'short_break', 'long_break')),
  start_time TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  end_time TIMESTAMP,
  duration_minutes INTEGER NOT NULL DEFAULT 25 CHECK (duration_minutes >= 1 AND duration_minutes <= 480),
  is_completed BOOLEAN DEFAULT FALSE,
  task TEXT,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS focus_timer_goals (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  daily_goal_sessions INTEGER NOT NULL DEFAULT 8 CHECK (daily_goal_sessions >= 1 AND daily_goal_sessions <= 50),
  focus_duration INTEGER NOT NULL DEFAULT 25,
  short_break_duration INTEGER NOT NULL DEFAULT 5,
  long_break_duration INTEGER NOT NULL DEFAULT 15,
  sessions_before_long_break INTEGER NOT NULL DEFAULT 4,
  auto_start_breaks BOOLEAN DEFAULT FALSE,
  auto_start_focus BOOLEAN DEFAULT FALSE,
  sound_enabled BOOLEAN DEFAULT TRUE,
  vibration_enabled BOOLEAN DEFAULT TRUE,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX IF NOT EXISTS idx_focus_timer_sessions_user_id ON focus_timer_sessions(user_id);
CREATE INDEX IF NOT EXISTS idx_focus_timer_sessions_start_time ON focus_timer_sessions(start_time);
CREATE INDEX IF NOT EXISTS idx_focus_timer_sessions_type ON focus_timer_sessions(type);
CREATE INDEX IF NOT EXISTS idx_focus_timer_goals_user_id ON focus_timer_goals(user_id);

-- =============================================
-- WEATHER SETTINGS
-- =============================================

CREATE TABLE IF NOT EXISTS weather_settings (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  latitude DECIMAL(8,5) NOT NULL DEFAULT 40.71280,
  longitude DECIMAL(9,5) NOT NULL DEFAULT -74.00600,
  city_name VARCHAR(200) NOT NULL DEFAULT 'New York',
  temperature_unit VARCHAR(10) NOT NULL DEFAULT 'celsius' CHECK (temperature_unit IN ('celsius', 'fahrenheit')),
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX IF NOT EXISTS idx_weather_settings_user_id ON weather_settings(user_id);

-- =============================================
-- SCREEN TIME TRACKING
-- =============================================

CREATE TABLE IF NOT EXISTS screen_time_records (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  date DATE NOT NULL,
  total_minutes INTEGER NOT NULL DEFAULT 0 CHECK (total_minutes >= 0 AND total_minutes <= 1440),
  pickups INTEGER NOT NULL DEFAULT 0 CHECK (pickups >= 0),
  note TEXT,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  UNIQUE(user_id, date)
);

CREATE TABLE IF NOT EXISTS app_usage (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  screen_time_id UUID NOT NULL REFERENCES screen_time_records(id) ON DELETE CASCADE,
  app_name VARCHAR(255) NOT NULL,
  category VARCHAR(50) DEFAULT 'other',
  minutes_used INTEGER NOT NULL DEFAULT 0 CHECK (minutes_used >= 0),
  icon_name VARCHAR(50) DEFAULT 'apps'
);

CREATE TABLE IF NOT EXISTS screen_time_goals (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  daily_limit_minutes INTEGER NOT NULL DEFAULT 180 CHECK (daily_limit_minutes >= 30 AND daily_limit_minutes <= 1440),
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX IF NOT EXISTS idx_screen_time_records_user_id ON screen_time_records(user_id);
CREATE INDEX IF NOT EXISTS idx_screen_time_records_date ON screen_time_records(date);
CREATE INDEX IF NOT EXISTS idx_app_usage_user_id ON app_usage(user_id);
CREATE INDEX IF NOT EXISTS idx_app_usage_screen_time_id ON app_usage(screen_time_id);
CREATE INDEX IF NOT EXISTS idx_screen_time_goals_user_id ON screen_time_goals(user_id);

-- =============================================
-- INBOX MESSAGES
-- =============================================

CREATE TABLE IF NOT EXISTS inbox_messages (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  service VARCHAR(50) NOT NULL DEFAULT 'General',
  sender VARCHAR(255) NOT NULL,
  subject VARCHAR(500) NOT NULL,
  preview TEXT DEFAULT '',
  body TEXT,
  gmail_message_id VARCHAR(255),
  is_read BOOLEAN DEFAULT FALSE,
  is_starred BOOLEAN DEFAULT FALSE,
  received_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX IF NOT EXISTS idx_inbox_messages_user_id ON inbox_messages(user_id);
CREATE INDEX IF NOT EXISTS idx_inbox_messages_service ON inbox_messages(service);
CREATE INDEX IF NOT EXISTS idx_inbox_messages_is_read ON inbox_messages(is_read);
CREATE INDEX IF NOT EXISTS idx_inbox_messages_received_at ON inbox_messages(received_at);
CREATE UNIQUE INDEX IF NOT EXISTS idx_inbox_user_gmail_msg ON inbox_messages(user_id, gmail_message_id) WHERE gmail_message_id IS NOT NULL;

-- =============================================
-- INSIGHTS (AI-generated insights)
-- =============================================

CREATE TABLE IF NOT EXISTS insights (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  type VARCHAR(20) NOT NULL,
  domains TEXT[] DEFAULT '{}',
  title VARCHAR(255) NOT NULL,
  description TEXT NOT NULL,
  confidence DECIMAL(3,2) DEFAULT 0.50,
  data JSONB DEFAULT '{}',
  dismissed BOOLEAN DEFAULT FALSE,
  expires_at TIMESTAMPTZ,
  created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX IF NOT EXISTS idx_insights_user_id ON insights(user_id);
CREATE INDEX IF NOT EXISTS idx_insights_type ON insights(type);
CREATE INDEX IF NOT EXISTS idx_insights_dismissed ON insights(dismissed);

-- =============================================
-- NOTIFICATION LOG (Rate limiting + analytics)
-- =============================================

CREATE TABLE IF NOT EXISTS notification_log (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  category VARCHAR(50) NOT NULL,
  title VARCHAR(255) NOT NULL,
  sent_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX IF NOT EXISTS idx_notification_log_user ON notification_log(user_id, category, sent_at);

-- =============================================
-- GOAL SUGGESTIONS (Agent goal advisor)
-- =============================================

CREATE TABLE IF NOT EXISTS goal_suggestions (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  domain VARCHAR(50) NOT NULL,
  current_goal DECIMAL NOT NULL,
  suggested_goal DECIMAL NOT NULL,
  direction VARCHAR(10) NOT NULL,
  reason TEXT NOT NULL,
  confidence DECIMAL(3,2) DEFAULT 0.50,
  evidence JSONB DEFAULT '{}',
  status VARCHAR(20) DEFAULT 'pending',
  created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
  responded_at TIMESTAMPTZ
);

CREATE INDEX IF NOT EXISTS idx_goal_suggestions_user ON goal_suggestions(user_id, status);

-- =============================================
-- WEEKLY PLANS (Agent weekly planner)
-- =============================================

CREATE TABLE IF NOT EXISTS weekly_plans (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  week_start DATE NOT NULL,
  week_end DATE NOT NULL,
  days JSONB NOT NULL DEFAULT '[]',
  focus_areas TEXT[] DEFAULT '{}',
  ai_summary TEXT DEFAULT '',
  status VARCHAR(20) DEFAULT 'draft',
  created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX IF NOT EXISTS idx_weekly_plans_user ON weekly_plans(user_id, week_start);

-- =============================================
-- AUTO ACTION LOG (Agent auto-actions)
-- =============================================

CREATE TABLE IF NOT EXISTS auto_action_log (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  action_type VARCHAR(50) NOT NULL,
  payload JSONB NOT NULL DEFAULT '{}',
  reason TEXT NOT NULL,
  autonomy_level VARCHAR(20) NOT NULL,
  status VARCHAR(20) DEFAULT 'pending_approval',
  created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
  executed_at TIMESTAMPTZ
);

CREATE INDEX IF NOT EXISTS idx_auto_action_log_user ON auto_action_log(user_id, status, created_at);

-- =============================================
-- USER AGENT SETTINGS (Per-user autonomy config)
-- =============================================

CREATE TABLE IF NOT EXISTS user_agent_settings (
  user_id UUID PRIMARY KEY REFERENCES users(id) ON DELETE CASCADE,
  autonomy_level VARCHAR(20) DEFAULT 'suggest_only',
  goal_changes VARCHAR(20) DEFAULT 'ask_first',
  reminders VARCHAR(20) DEFAULT 'auto_with_notify',
  data_logging VARCHAR(20) DEFAULT 'suggest_only'
);
