# Legal Case Management System

## Overview
Modern SaaS for global legal case management with arrears module, RBAC, notifications, etc. Blue/white theme.

## Local Setup
**Note: Docker Desktop required for Postgres or use external DB like Neon.**

1. cd legal-case-management
2. Backend: cd backend && npm install && copy .env.example .env && npm run dev
3. Frontend: cd ../frontend && npm install && npm run dev
4. DB: docker compose up -d (or external Postgres, update .env)
5. Run schema: docker exec -i postgres psql -U postgres legaldb < ../database/schema.sql
6. Test API: POST /api/auth/login {email: 'admin@legal.com', password: 'password'}
Backend: http://localhost:5000 | Frontend: http://localhost:3000

## Neon Postgres Setup
1. Sign up at neon.tech and create a new project/database.
2. In Neon, create a branch and get the connection string from the dashboard.
3. Copy the connection string into `legal-case-management/backend/.env` as:

   DATABASE_URL=postgresql://<user>:<password>@<host>:<port>/<database>
   DB_SSL=true

4. If you prefer env-based config instead of connection string, set Neon host/user/pass in `backend/.env`.
5. Run the schema against Neon using the SQL editor in Neon or locally:

   psql "$DATABASE_URL" -f database/schema.sql

6. Start the backend from `legal-case-management/backend`:

   npm install
   npm run dev

7. Verify with `http://localhost:5000/health`.

## Deployment
- Backend: Render.com (connect GitHub repo, Node, add .env)
- Frontend: Vercel.com (connect GitHub)
- DB: Neon.tech (free tier)


## Deployment
- Backend: Render (Node)
- Frontend: Vercel
- DB: Neon Postgres (connection via DBeaver)

## Tech Stack
- Backend: Node/Express/Postgres
- Frontend: React/Tailwind/Zustand/React Query

**Commercial ready with audit, RBAC, scalable APIs.**

