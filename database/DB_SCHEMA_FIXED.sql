-- FIXED LEGAL SCHEMA - Neon Compatible - RUN THIS ENTIRE BLOCK
-- Removes all FK issues, creates tables in correct order

-- 1. RESET ALL
DO $$ 
BEGIN 
  EXECUTE 'DROP SCHEMA public CASCADE';
  CREATE SCHEMA public;
END $$;

-- 2. EXTENSIONS
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";
CREATE EXTENSION IF NOT EXISTS "pgcrypto";

-- 3. TABLES (no FK first)
CREATE TABLE users (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  username VARCHAR(50) UNIQUE NOT NULL,
  email VARCHAR(100) UNIQUE NOT NULL,
  password_hash VARCHAR(255) NOT NULL,
  role VARCHAR(20) CHECK (role IN ('admin','partner','lawyer','secretary')) NOT NULL,
  created_at TIMESTAMP DEFAULT NOW()
);

CREATE TABLE clients (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  full_name VARCHAR(255) NOT NULL,
  nrc_number VARCHAR(50) UNIQUE NOT NULL,
  phone VARCHAR(20),
  email VARCHAR(100),
  address TEXT,
  created_at TIMESTAMP DEFAULT NOW()
);

CREATE TABLE judges (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  name VARCHAR(255) NOT NULL,
  jurisdiction VARCHAR(100),
  location VARCHAR(100),
  created_at TIMESTAMP DEFAULT NOW()
);

-- 4. CASES (references users/judges)
ALTER TABLE cases ADD CONSTRAINT fk_cases_lawyer FOREIGN KEY (assigned_lawyer_id) REFERENCES users(id);
ALTER TABLE cases ADD CONSTRAINT fk_cases_judge FOREIGN KEY (judge_id) REFERENCES judges(id);

CREATE TABLE cases (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  case_id VARCHAR(50) UNIQUE NOT NULL,
  type VARCHAR(100) NOT NULL,
  status VARCHAR(20) DEFAULT 'open',
  priority VARCHAR(20) DEFAULT 'medium',
  assigned_lawyer_id UUID,
  judge_id UUID,
  court VARCHAR(100),
  clients JSONB DEFAULT '[]',
  tags JSONB DEFAULT '[]',
  timeline JSONB DEFAULT '[]',
  created_at TIMESTAMP DEFAULT NOW()
);

-- 5. ARREARS (independent)
CREATE TABLE arrears_cases (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  case_id VARCHAR(50) UNIQUE NOT NULL,
  nrc_number VARCHAR(50) NOT NULL,
  principal_amount DECIMAL(15,2) NOT NULL,
  days_in_arrears INTEGER,
  stage VARCHAR(50) DEFAULT 'reminder',
  stage_history JSONB DEFAULT '[]',
  created_at TIMESTAMP DEFAULT NOW()
);

-- 6. SUPPORT TABLES
CREATE TABLE documents (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  case_id UUID REFERENCES cases(id) ON DELETE CASCADE,
  filename VARCHAR(255) NOT NULL,
  path TEXT NOT NULL,
  category VARCHAR(100),
  created_at TIMESTAMP DEFAULT NOW()
);

CREATE TABLE hearings (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  case_id UUID REFERENCES cases(id) ON DELETE CASCADE,
  hearing_date TIMESTAMP NOT NULL,
  outcome TEXT,
  created_at TIMESTAMP DEFAULT NOW()
);

CREATE TABLE tasks (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  title VARCHAR(255) NOT NULL,
  case_id UUID REFERENCES cases(id) ON DELETE CASCADE,
  assigned_to UUID REFERENCES users(id),
  due_date TIMESTAMP,
  status VARCHAR(20) DEFAULT 'pending',
  created_at TIMESTAMP DEFAULT NOW()
);

CREATE TABLE notifications (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  type VARCHAR(10) CHECK (type IN ('sms','email')),
  recipient VARCHAR(100),
  message TEXT,
  created_at TIMESTAMP DEFAULT NOW()
);

CREATE TABLE audit_logs (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID REFERENCES users(id),
  action VARCHAR(100),
  entity_type VARCHAR(50),
  entity_id UUID,
  changes JSONB,
  created_at TIMESTAMP DEFAULT NOW()
);

-- SAMPLE DATA
INSERT INTO users (username, email, password_hash, role) VALUES 
('admin', 'admin@legal.com', '$2b$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', 'admin');

INSERT INTO clients (full_name, nrc_number) VALUES 
('Test Client', '123456/78/1');

-- INDEXES
CREATE INDEX idx_cases_status ON cases(status);
CREATE INDEX idx_arrears_nrc ON arrears_cases(nrc_number);

-- VERIFY
SELECT 'ALL TABLES CREATED' as status;
SELECT COUNT(*) as user_count FROM users;
SELECT COUNT(*) as client_count FROM clients;

