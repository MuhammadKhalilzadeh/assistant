-- Categories table
CREATE TABLE IF NOT EXISTS categories (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  name VARCHAR(100) NOT NULL,
  color VARCHAR(7) NOT NULL,
  icon VARCHAR(50)
);

-- Todos table
CREATE TABLE IF NOT EXISTS todos (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
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
CREATE INDEX IF NOT EXISTS idx_todos_category_id ON todos(category_id);
CREATE INDEX IF NOT EXISTS idx_todos_is_completed ON todos(is_completed);
CREATE INDEX IF NOT EXISTS idx_todos_due_date ON todos(due_date);
CREATE INDEX IF NOT EXISTS idx_todos_created_at ON todos(created_at);

-- Insert default categories (only if they don't exist)
INSERT INTO categories (name, color, icon)
SELECT 'Work', '#6366F1', 'work'
WHERE NOT EXISTS (SELECT 1 FROM categories WHERE name = 'Work');

INSERT INTO categories (name, color, icon)
SELECT 'Personal', '#EC4899', 'person'
WHERE NOT EXISTS (SELECT 1 FROM categories WHERE name = 'Personal');

INSERT INTO categories (name, color, icon)
SELECT 'Shopping', '#10B981', 'shopping_cart'
WHERE NOT EXISTS (SELECT 1 FROM categories WHERE name = 'Shopping');

INSERT INTO categories (name, color, icon)
SELECT 'Health', '#F59E0B', 'favorite'
WHERE NOT EXISTS (SELECT 1 FROM categories WHERE name = 'Health');

INSERT INTO categories (name, color, icon)
SELECT 'Other', '#6B7280', 'more_horiz'
WHERE NOT EXISTS (SELECT 1 FROM categories WHERE name = 'Other');

-- Habits table
CREATE TABLE IF NOT EXISTS habits (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
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
  habit_id UUID NOT NULL REFERENCES habits(id) ON DELETE CASCADE,
  completed_date DATE NOT NULL DEFAULT CURRENT_DATE,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  UNIQUE(habit_id, completed_date)
);

-- Indexes for habits
CREATE INDEX IF NOT EXISTS idx_habits_category ON habits(category);
CREATE INDEX IF NOT EXISTS idx_habits_created_at ON habits(created_at);
CREATE INDEX IF NOT EXISTS idx_habit_completions_habit_id ON habit_completions(habit_id);
CREATE INDEX IF NOT EXISTS idx_habit_completions_date ON habit_completions(completed_date);

-- Water logs table
CREATE TABLE IF NOT EXISTS water_logs (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  amount_ml INTEGER NOT NULL CHECK (amount_ml > 0 AND amount_ml <= 5000),
  beverage_type VARCHAR(20) DEFAULT 'water' CHECK (beverage_type IN ('water', 'coffee', 'tea', 'juice', 'milk', 'other')),
  note TEXT,
  logged_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Hydration goals table
CREATE TABLE IF NOT EXISTS hydration_goals (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  daily_goal_ml INTEGER NOT NULL DEFAULT 3000 CHECK (daily_goal_ml >= 500 AND daily_goal_ml <= 10000),
  reminder_interval_minutes INTEGER DEFAULT 60,
  reminders_enabled BOOLEAN DEFAULT TRUE,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Indexes for water logs
CREATE INDEX IF NOT EXISTS idx_water_logs_logged_at ON water_logs(logged_at);
CREATE INDEX IF NOT EXISTS idx_water_logs_beverage_type ON water_logs(beverage_type);

-- Default hydration goal (only if none exists)
INSERT INTO hydration_goals (daily_goal_ml, reminder_interval_minutes, reminders_enabled)
SELECT 3000, 60, TRUE WHERE NOT EXISTS (SELECT 1 FROM hydration_goals);

-- =============================================
-- HEART RATE TRACKING
-- =============================================

CREATE TABLE IF NOT EXISTS heart_rate_records (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  bpm INTEGER NOT NULL CHECK (bpm >= 30 AND bpm <= 250),
  zone VARCHAR(20) DEFAULT 'resting' CHECK (zone IN ('resting', 'warmUp', 'fatBurn', 'cardio', 'peak')),
  recorded_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS heart_rate_goals (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  target_resting_bpm INTEGER NOT NULL DEFAULT 65,
  max_bpm INTEGER NOT NULL DEFAULT 180,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX IF NOT EXISTS idx_heart_rate_records_recorded_at ON heart_rate_records(recorded_at);
CREATE INDEX IF NOT EXISTS idx_heart_rate_records_zone ON heart_rate_records(zone);

INSERT INTO heart_rate_goals (target_resting_bpm, max_bpm)
SELECT 65, 180 WHERE NOT EXISTS (SELECT 1 FROM heart_rate_goals);

-- =============================================
-- STEPS TRACKING
-- =============================================

CREATE TABLE IF NOT EXISTS step_records (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  date DATE NOT NULL UNIQUE,
  steps INTEGER NOT NULL DEFAULT 0 CHECK (steps >= 0 AND steps <= 200000),
  goal INTEGER NOT NULL DEFAULT 10000,
  distance_km DOUBLE PRECISION DEFAULT 0,
  calories_burned INTEGER DEFAULT 0,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS steps_goals (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  daily_goal INTEGER NOT NULL DEFAULT 10000,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX IF NOT EXISTS idx_step_records_date ON step_records(date);

INSERT INTO steps_goals (daily_goal)
SELECT 10000 WHERE NOT EXISTS (SELECT 1 FROM steps_goals);

-- =============================================
-- MOOD TRACKING
-- =============================================

CREATE TABLE IF NOT EXISTS mood_entries (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  mood VARCHAR(20) NOT NULL CHECK (mood IN ('great', 'good', 'okay', 'bad', 'awful')),
  notes TEXT,
  activities TEXT[] DEFAULT ARRAY[]::TEXT[],
  recorded_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS mood_goals (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  daily_entries_goal INTEGER NOT NULL DEFAULT 1,
  target_mood VARCHAR(20) DEFAULT 'good' CHECK (target_mood IN ('great', 'good', 'okay', 'bad', 'awful')),
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX IF NOT EXISTS idx_mood_entries_recorded_at ON mood_entries(recorded_at);
CREATE INDEX IF NOT EXISTS idx_mood_entries_mood ON mood_entries(mood);

INSERT INTO mood_goals (daily_entries_goal, target_mood)
SELECT 1, 'good' WHERE NOT EXISTS (SELECT 1 FROM mood_goals);

-- =============================================
-- SLEEP TRACKING
-- =============================================

CREATE TABLE IF NOT EXISTS sleep_records (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  bed_time TIMESTAMP NOT NULL,
  wake_time TIMESTAMP NOT NULL,
  quality VARCHAR(20) DEFAULT 'good' CHECK (quality IN ('poor', 'fair', 'good', 'excellent')),
  notes TEXT,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT chk_wake_after_bed CHECK (wake_time > bed_time)
);

CREATE TABLE IF NOT EXISTS sleep_goals (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  goal_minutes INTEGER NOT NULL DEFAULT 480,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX IF NOT EXISTS idx_sleep_records_bed_time ON sleep_records(bed_time);
CREATE INDEX IF NOT EXISTS idx_sleep_records_wake_time ON sleep_records(wake_time);

INSERT INTO sleep_goals (goal_minutes)
SELECT 480 WHERE NOT EXISTS (SELECT 1 FROM sleep_goals);

-- =============================================
-- MEDITATION TRACKING
-- =============================================

CREATE TABLE IF NOT EXISTS meditation_sessions (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  type VARCHAR(20) NOT NULL CHECK (type IN ('breathing', 'guided', 'unguided', 'sleep', 'focus')),
  start_time TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  duration_minutes INTEGER NOT NULL DEFAULT 10 CHECK (duration_minutes >= 1 AND duration_minutes <= 480),
  is_completed BOOLEAN DEFAULT FALSE,
  notes TEXT,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS meditation_goals (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  daily_minutes_goal INTEGER NOT NULL DEFAULT 10,
  weekly_sessions_goal INTEGER NOT NULL DEFAULT 7,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX IF NOT EXISTS idx_meditation_sessions_start_time ON meditation_sessions(start_time);
CREATE INDEX IF NOT EXISTS idx_meditation_sessions_type ON meditation_sessions(type);

INSERT INTO meditation_goals (daily_minutes_goal, weekly_sessions_goal)
SELECT 10, 7 WHERE NOT EXISTS (SELECT 1 FROM meditation_goals);

-- =============================================
-- WORKOUT TRACKING
-- =============================================

CREATE TABLE IF NOT EXISTS workout_sessions (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
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
  weekly_minutes_goal INTEGER NOT NULL DEFAULT 150,
  weekly_sessions_goal INTEGER NOT NULL DEFAULT 5,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX IF NOT EXISTS idx_workout_sessions_start_time ON workout_sessions(start_time);
CREATE INDEX IF NOT EXISTS idx_workout_sessions_type ON workout_sessions(type);

INSERT INTO workout_goals (weekly_minutes_goal, weekly_sessions_goal)
SELECT 150, 5 WHERE NOT EXISTS (SELECT 1 FROM workout_goals);

-- =============================================
-- CALORIES / NUTRITION TRACKING
-- =============================================

CREATE TABLE IF NOT EXISTS calorie_entries (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
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
  daily_calorie_goal INTEGER NOT NULL DEFAULT 2000,
  protein_goal_grams INTEGER NOT NULL DEFAULT 50,
  carbs_goal_grams INTEGER NOT NULL DEFAULT 250,
  fat_goal_grams INTEGER NOT NULL DEFAULT 65,
  reminders_enabled BOOLEAN DEFAULT FALSE,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX IF NOT EXISTS idx_calorie_entries_logged_at ON calorie_entries(logged_at);
CREATE INDEX IF NOT EXISTS idx_calorie_entries_meal_type ON calorie_entries(meal_type);

INSERT INTO nutrition_goals (daily_calorie_goal, protein_goal_grams, carbs_goal_grams, fat_goal_grams)
SELECT 2000, 50, 250, 65 WHERE NOT EXISTS (SELECT 1 FROM nutrition_goals);
