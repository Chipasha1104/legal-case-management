-- COMPLETE LEGAL CASE SCHEMA for DBeaver/Neon - Paste & Run

-- 1. ENUM TYPES
CREATE TYPE user_role AS ENUM ('admin', 'partner', 'lawyer', 'secretary');
CREATE TYPE case_status AS ENUM ('open', 'pending', 'closed');
CREATE TYPE case_priority AS ENUM ('high', 'medium', 'low');
CREATE TYPE arrears_stage AS ENUM ('reminder', 'demand_notice', 'pre_legal', 'legal_review', 'service_process');
CREATE TYPE task_status AS ENUM ('pending', 'in_progress', 'completed');
CREATE TYPE notification_type AS ENUM ('sms', 'email');
CREATE TYPE notification_status AS ENUM ('sent', 'failed');

-- 2. TABLES
CREATE TABLE users (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  username VARCHAR(50) UNIQUE NOT NULL,
  email VARCHAR(100) UNIQUE NOT NULL,
  password_hash VARCHAR(255) NOT NULL,
  role user_role NOT NULL,
  created_at TIMESTAMP DEFAULT NOW()
);

CREATE TABLE clients (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  full_name VARCHAR(255) NOT NULL,
  nrc_number VARCHAR(50) UNIQUE NOT NULL,
  phone VARCHAR(20),
  email VARCHAR(100),
  address TEXT,
  created_at TIMESTAMP DEFAULT NOW()
);

CREATE TABLE cases (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  case_id VARCHAR(50) UNIQUE NOT NULL,
  type VARCHAR(100) NOT NULL,
  status case_status DEFAULT 'open',
  priority case_priority DEFAULT 'medium',
  assigned_lawyer_id UUID REFERENCES users(id),
  judge_id UUID,
  court VARCHAR(100),
  clients JSONB DEFAULT '[]',
  tags JSONB DEFAULT '[]',
  timeline JSONB DEFAULT '[]',
  created_at TIMESTAMP DEFAULT NOW()
);

CREATE TABLE arrears_cases (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  case_id VARCHAR(50) UNIQUE NOT NULL,
  nrc_number VARCHAR(50) NOT NULL,
  principal_amount DECIMAL(15,2) NOT NULL,
  days_in_arrears INTEGER,
  stage arrears_stage NOT NULL,
  stage_history JSONB DEFAULT '[]',
  created_at TIMESTAMP DEFAULT NOW()
);

CREATE TABLE judges (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  name VARCHAR(255) NOT NULL,
  jurisdiction VARCHAR(100),
  location VARCHAR(100),
  created_at TIMESTAMP DEFAULT NOW()
);

CREATE TABLE documents (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  case_id UUID REFERENCES cases(id),
  filename VARCHAR(255) NOT NULL,
  path VARCHAR(500) NOT NULL,
  uploaded_by UUID REFERENCES users(id),
  created_at TIMESTAMP DEFAULT NOW()
);

CREATE TABLE hearings (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  case_id UUID REFERENCES cases(id),
  date TIMESTAMP NOT NULL,
  outcome TEXT,
  created_at TIMESTAMP DEFAULT NOW()
);

CREATE TABLE tasks (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  title VARCHAR(255) NOT NULL,
  case_id UUID REFERENCES cases(id),
  assigned_to UUID REFERENCES users(id),
  due_date TIMESTAMP,
  status task_status DEFAULT 'pending',
  created_at TIMESTAMP DEFAULT NOW()
);

CREATE TABLE notifications (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  type notification_type NOT NULL,
  recipient VARCHAR(100),
  message TEXT,
  status notification_status DEFAULT 'sent',
  created_at TIMESTAMP DEFAULT NOW()
);

CREATE TABLE audit_logs (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id UUID REFERENCES users(id),
  action VARCHAR(100),
  entity_id UUID,
  changes JSONB,
  created_at TIMESTAMP DEFAULT NOW()
);

-- INDEXES
CREATE INDEX idx_cases_status ON cases(status);
CREATE INDEX idx_cases_priority ON cases(priority);
CREATE INDEX idx_clients_nrc ON clients(nrc_number);

-- SAMPLE DATA
INSERT INTO users (username, email, password_hash, role) VALUES 
('admin', 'admin@legal.com', '$2b$10$K.ExampleHashForAdmin', 'admin'),
('lawyer1', 'lawyer@legal.com', '$2b$10$K.ExampleHashForLawyer', 'lawyer');

-- SUCCESS
SELECT 'Schema created successfully!' as status;

