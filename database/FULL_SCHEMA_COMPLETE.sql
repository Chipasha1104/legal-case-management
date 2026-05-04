-- FULL LEGAL CASE MANAGEMENT SCHEMA - Neon/DBeaver Ready
-- Copy ALL → DBeaver → Execute Script → DONE!

-- EXTENSIONS
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- ENUMS
CREATE TYPE user_role AS ENUM ('admin', 'partner', 'lawyer', 'secretary');
CREATE TYPE case_status AS ENUM ('open', 'pending', 'closed');
CREATE TYPE case_priority AS ENUM ('high', 'medium', 'low');
CREATE TYPE arrears_stage AS ENUM ('reminder', 'demand_notice', 'pre_legal', 'legal_review', 'service_process');
CREATE TYPE task_status AS ENUM ('pending', 'in_progress', 'completed');
CREATE TYPE notification_type AS ENUM ('sms', 'email');
CREATE TYPE notification_status AS ENUM ('sent', 'failed');

-- CORE TABLES
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

-- ARREARS (SEPARATE MODULE)
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

-- SUPPORT TABLES
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
  category VARCHAR(100),
  uploaded_by UUID REFERENCES users(id),
  created_at TIMESTAMP DEFAULT NOW()
);

CREATE TABLE hearings (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  case_id UUID REFERENCES cases(id),
  date TIMESTAMP NOT NULL,
  outcome TEXT,
  next_action TEXT,
  created_at TIMESTAMP DEFAULT NOW()
);

CREATE TABLE tasks (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  title VARCHAR(255) NOT NULL,
  description TEXT,
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
  case_id UUID REFERENCES cases(id),
  sent_at TIMESTAMP,
  status notification_status DEFAULT 'sent'
);

CREATE TABLE audit_logs (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id UUID REFERENCES users(id),
  action VARCHAR(100),
  entity_type VARCHAR(50),
  entity_id UUID,
  old_values JSONB,
  new_values JSONB,
  created_at TIMESTAMP DEFAULT NOW()
);

-- INDEXES (PERFORMANCE)
CREATE INDEX idx_cases_status ON cases(status);
CREATE INDEX idx_cases_priority ON cases(priority);
CREATE INDEX idx_clients_nrc ON clients(nrc_number);
CREATE INDEX idx_arrears_days ON arrears_cases(days_in_arrears);
CREATE INDEX idx_audit_user ON audit_logs(user_id);
CREATE INDEX idx_audit_created ON audit_logs(created_at);

-- SAMPLE DATA
INSERT INTO users (username, email, password_hash, role) VALUES 
('admin', 'admin@legal.com', '$2b$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', 'admin'),
('lawyer1', 'lawyer1@legal.com', '$2b$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', 'lawyer'),
('secretary1', 'secretary1@legal.com', '$2b$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', 'secretary');

INSERT INTO clients (full_name, nrc_number, phone) VALUES 
('John Doe', '123456/78/9', '+260971234567'),
('Jane Smith', '987654/32/1', '+260961234567');

-- SUCCESS
SELECT '✅ FULL SCHEMA + SAMPLES LOADED!' as status;

