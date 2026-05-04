-- Legal Case Management Database Schema - FIXED for Postgres/Neon
-- ENUM types first, then tables. Run FULL script in DBeaver

DROP SCHEMA IF EXISTS public CASCADE;
CREATE SCHEMA public;

CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- ENUM Types
CREATE TYPE user_role AS ENUM ('admin
