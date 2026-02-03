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
