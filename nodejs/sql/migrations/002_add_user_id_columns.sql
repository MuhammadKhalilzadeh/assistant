-- Migration 002: Add user_id to all existing tables
-- Pre-production: add columns nullable first, then clean up

-- Add user_id columns to all data tables
ALTER TABLE categories ADD COLUMN IF NOT EXISTS user_id UUID REFERENCES users(id) ON DELETE CASCADE;
ALTER TABLE todos ADD COLUMN IF NOT EXISTS user_id UUID REFERENCES users(id) ON DELETE CASCADE;
ALTER TABLE habits ADD COLUMN IF NOT EXISTS user_id UUID REFERENCES users(id) ON DELETE CASCADE;
ALTER TABLE habit_completions ADD COLUMN IF NOT EXISTS user_id UUID REFERENCES users(id) ON DELETE CASCADE;
ALTER TABLE water_logs ADD COLUMN IF NOT EXISTS user_id UUID REFERENCES users(id) ON DELETE CASCADE;
ALTER TABLE hydration_goals ADD COLUMN IF NOT EXISTS user_id UUID REFERENCES users(id) ON DELETE CASCADE;
ALTER TABLE heart_rate_records ADD COLUMN IF NOT EXISTS user_id UUID REFERENCES users(id) ON DELETE CASCADE;
ALTER TABLE heart_rate_goals ADD COLUMN IF NOT EXISTS user_id UUID REFERENCES users(id) ON DELETE CASCADE;
ALTER TABLE step_records ADD COLUMN IF NOT EXISTS user_id UUID REFERENCES users(id) ON DELETE CASCADE;
ALTER TABLE steps_goals ADD COLUMN IF NOT EXISTS user_id UUID REFERENCES users(id) ON DELETE CASCADE;
ALTER TABLE mood_entries ADD COLUMN IF NOT EXISTS user_id UUID REFERENCES users(id) ON DELETE CASCADE;
ALTER TABLE mood_goals ADD COLUMN IF NOT EXISTS user_id UUID REFERENCES users(id) ON DELETE CASCADE;
ALTER TABLE sleep_records ADD COLUMN IF NOT EXISTS user_id UUID REFERENCES users(id) ON DELETE CASCADE;
ALTER TABLE sleep_goals ADD COLUMN IF NOT EXISTS user_id UUID REFERENCES users(id) ON DELETE CASCADE;
ALTER TABLE meditation_sessions ADD COLUMN IF NOT EXISTS user_id UUID REFERENCES users(id) ON DELETE CASCADE;
ALTER TABLE meditation_goals ADD COLUMN IF NOT EXISTS user_id UUID REFERENCES users(id) ON DELETE CASCADE;
ALTER TABLE workout_sessions ADD COLUMN IF NOT EXISTS user_id UUID REFERENCES users(id) ON DELETE CASCADE;
ALTER TABLE workout_goals ADD COLUMN IF NOT EXISTS user_id UUID REFERENCES users(id) ON DELETE CASCADE;
ALTER TABLE calorie_entries ADD COLUMN IF NOT EXISTS user_id UUID REFERENCES users(id) ON DELETE CASCADE;
ALTER TABLE nutrition_goals ADD COLUMN IF NOT EXISTS user_id UUID REFERENCES users(id) ON DELETE CASCADE;
ALTER TABLE focus_timer_sessions ADD COLUMN IF NOT EXISTS user_id UUID REFERENCES users(id) ON DELETE CASCADE;
ALTER TABLE focus_timer_goals ADD COLUMN IF NOT EXISTS user_id UUID REFERENCES users(id) ON DELETE CASCADE;
ALTER TABLE weather_settings ADD COLUMN IF NOT EXISTS user_id UUID REFERENCES users(id) ON DELETE CASCADE;
ALTER TABLE screen_time_records ADD COLUMN IF NOT EXISTS user_id UUID REFERENCES users(id) ON DELETE CASCADE;
ALTER TABLE app_usage ADD COLUMN IF NOT EXISTS user_id UUID REFERENCES users(id) ON DELETE CASCADE;
ALTER TABLE screen_time_goals ADD COLUMN IF NOT EXISTS user_id UUID REFERENCES users(id) ON DELETE CASCADE;
ALTER TABLE inbox_messages ADD COLUMN IF NOT EXISTS user_id UUID REFERENCES users(id) ON DELETE CASCADE;

-- Add Gmail-specific columns to inbox_messages
ALTER TABLE inbox_messages ADD COLUMN IF NOT EXISTS gmail_message_id VARCHAR(255);
ALTER TABLE inbox_messages ADD COLUMN IF NOT EXISTS body TEXT;

-- Delete any existing test data (pre-production only)
DELETE FROM habit_completions;
DELETE FROM app_usage;
DELETE FROM todos;
DELETE FROM habits;
DELETE FROM water_logs;
DELETE FROM hydration_goals;
DELETE FROM heart_rate_records;
DELETE FROM heart_rate_goals;
DELETE FROM step_records;
DELETE FROM steps_goals;
DELETE FROM mood_entries;
DELETE FROM mood_goals;
DELETE FROM sleep_records;
DELETE FROM sleep_goals;
DELETE FROM meditation_sessions;
DELETE FROM meditation_goals;
DELETE FROM workout_sessions;
DELETE FROM workout_goals;
DELETE FROM calorie_entries;
DELETE FROM nutrition_goals;
DELETE FROM focus_timer_sessions;
DELETE FROM focus_timer_goals;
DELETE FROM weather_settings;
DELETE FROM screen_time_records;
DELETE FROM screen_time_goals;
DELETE FROM inbox_messages;
DELETE FROM categories;

-- Now set NOT NULL constraints
ALTER TABLE categories ALTER COLUMN user_id SET NOT NULL;
ALTER TABLE todos ALTER COLUMN user_id SET NOT NULL;
ALTER TABLE habits ALTER COLUMN user_id SET NOT NULL;
ALTER TABLE habit_completions ALTER COLUMN user_id SET NOT NULL;
ALTER TABLE water_logs ALTER COLUMN user_id SET NOT NULL;
ALTER TABLE hydration_goals ALTER COLUMN user_id SET NOT NULL;
ALTER TABLE heart_rate_records ALTER COLUMN user_id SET NOT NULL;
ALTER TABLE heart_rate_goals ALTER COLUMN user_id SET NOT NULL;
ALTER TABLE step_records ALTER COLUMN user_id SET NOT NULL;
ALTER TABLE steps_goals ALTER COLUMN user_id SET NOT NULL;
ALTER TABLE mood_entries ALTER COLUMN user_id SET NOT NULL;
ALTER TABLE mood_goals ALTER COLUMN user_id SET NOT NULL;
ALTER TABLE sleep_records ALTER COLUMN user_id SET NOT NULL;
ALTER TABLE sleep_goals ALTER COLUMN user_id SET NOT NULL;
ALTER TABLE meditation_sessions ALTER COLUMN user_id SET NOT NULL;
ALTER TABLE meditation_goals ALTER COLUMN user_id SET NOT NULL;
ALTER TABLE workout_sessions ALTER COLUMN user_id SET NOT NULL;
ALTER TABLE workout_goals ALTER COLUMN user_id SET NOT NULL;
ALTER TABLE calorie_entries ALTER COLUMN user_id SET NOT NULL;
ALTER TABLE nutrition_goals ALTER COLUMN user_id SET NOT NULL;
ALTER TABLE focus_timer_sessions ALTER COLUMN user_id SET NOT NULL;
ALTER TABLE focus_timer_goals ALTER COLUMN user_id SET NOT NULL;
ALTER TABLE weather_settings ALTER COLUMN user_id SET NOT NULL;
ALTER TABLE screen_time_records ALTER COLUMN user_id SET NOT NULL;
ALTER TABLE app_usage ALTER COLUMN user_id SET NOT NULL;
ALTER TABLE screen_time_goals ALTER COLUMN user_id SET NOT NULL;
ALTER TABLE inbox_messages ALTER COLUMN user_id SET NOT NULL;

-- Create indexes for user_id on all tables
CREATE INDEX IF NOT EXISTS idx_categories_user_id ON categories(user_id);
CREATE INDEX IF NOT EXISTS idx_todos_user_id ON todos(user_id);
CREATE INDEX IF NOT EXISTS idx_habits_user_id ON habits(user_id);
CREATE INDEX IF NOT EXISTS idx_habit_completions_user_id ON habit_completions(user_id);
CREATE INDEX IF NOT EXISTS idx_water_logs_user_id ON water_logs(user_id);
CREATE INDEX IF NOT EXISTS idx_hydration_goals_user_id ON hydration_goals(user_id);
CREATE INDEX IF NOT EXISTS idx_heart_rate_records_user_id ON heart_rate_records(user_id);
CREATE INDEX IF NOT EXISTS idx_heart_rate_goals_user_id ON heart_rate_goals(user_id);
CREATE INDEX IF NOT EXISTS idx_step_records_user_id ON step_records(user_id);
CREATE INDEX IF NOT EXISTS idx_steps_goals_user_id ON steps_goals(user_id);
CREATE INDEX IF NOT EXISTS idx_mood_entries_user_id ON mood_entries(user_id);
CREATE INDEX IF NOT EXISTS idx_mood_goals_user_id ON mood_goals(user_id);
CREATE INDEX IF NOT EXISTS idx_sleep_records_user_id ON sleep_records(user_id);
CREATE INDEX IF NOT EXISTS idx_sleep_goals_user_id ON sleep_goals(user_id);
CREATE INDEX IF NOT EXISTS idx_meditation_sessions_user_id ON meditation_sessions(user_id);
CREATE INDEX IF NOT EXISTS idx_meditation_goals_user_id ON meditation_goals(user_id);
CREATE INDEX IF NOT EXISTS idx_workout_sessions_user_id ON workout_sessions(user_id);
CREATE INDEX IF NOT EXISTS idx_workout_goals_user_id ON workout_goals(user_id);
CREATE INDEX IF NOT EXISTS idx_calorie_entries_user_id ON calorie_entries(user_id);
CREATE INDEX IF NOT EXISTS idx_nutrition_goals_user_id ON nutrition_goals(user_id);
CREATE INDEX IF NOT EXISTS idx_focus_timer_sessions_user_id ON focus_timer_sessions(user_id);
CREATE INDEX IF NOT EXISTS idx_focus_timer_goals_user_id ON focus_timer_goals(user_id);
CREATE INDEX IF NOT EXISTS idx_weather_settings_user_id ON weather_settings(user_id);
CREATE INDEX IF NOT EXISTS idx_screen_time_records_user_id ON screen_time_records(user_id);
CREATE INDEX IF NOT EXISTS idx_app_usage_user_id ON app_usage(user_id);
CREATE INDEX IF NOT EXISTS idx_screen_time_goals_user_id ON screen_time_goals(user_id);
CREATE INDEX IF NOT EXISTS idx_inbox_messages_user_id ON inbox_messages(user_id);

-- Update unique constraints for per-user data
-- Drop old unique constraints (these are table constraints, not just indexes)
ALTER TABLE step_records DROP CONSTRAINT IF EXISTS step_records_date_key;
DROP INDEX IF EXISTS step_records_date_key;
CREATE UNIQUE INDEX IF NOT EXISTS idx_step_records_user_date ON step_records(user_id, date);

ALTER TABLE screen_time_records DROP CONSTRAINT IF EXISTS screen_time_records_date_key;
DROP INDEX IF EXISTS screen_time_records_date_key;
CREATE UNIQUE INDEX IF NOT EXISTS idx_screen_time_records_user_date ON screen_time_records(user_id, date);

ALTER TABLE habit_completions DROP CONSTRAINT IF EXISTS habit_completions_habit_id_completed_date_key;
DROP INDEX IF EXISTS habit_completions_habit_id_completed_date_key;
CREATE UNIQUE INDEX IF NOT EXISTS idx_habit_completions_user_habit_date ON habit_completions(user_id, habit_id, completed_date);

-- Unique constraint for gmail message deduplication
CREATE UNIQUE INDEX IF NOT EXISTS idx_inbox_user_gmail_msg ON inbox_messages(user_id, gmail_message_id) WHERE gmail_message_id IS NOT NULL;
