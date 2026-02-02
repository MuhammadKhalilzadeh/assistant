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
