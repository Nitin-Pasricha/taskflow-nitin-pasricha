# TaskFlow API

Backend submission for the **TaskFlow** take-home: a JSON REST API for users, projects, and tasks with JWT authentication and PostgreSQL.

## 1. Overview

TaskFlow lets people **register and log in**, **create projects**, and **manage tasks** (status, priority, assignee, due date) under those projects. Access rules follow the assignment: project owners and users with tasks on a project can see it; only owners may update or delete a project; task updates require project access; task delete is allowed for the **project owner** or **task creator**.

**Tech stack**

- **Ruby on Rails 8.1** (API-only mode)
- **PostgreSQL** (UUID primary keys, reversible migrations)
- **bcrypt** (passwords, cost ≥ 12) and **JWT** (24h access tokens, `user_id` + `email` claims)
- **Docker Compose** at the repo root for PostgreSQL + API (see **`.env.example`** for variables)
- **Multi-stage `Dockerfile`** (build stage + slim runtime image, per assignment infrastructure requirements)
- **RSpec** request specs under **`spec/requests/`** (auth, projects, tasks) — covers the assignment’s **optional backend bonus** for integration-style API tests (in addition to the **Postman** collection for manual exploration)

**Language choice:** The brief prefers **Go**; this implementation uses **Ruby on Rails** for speed of delivery, built-in migrations and Active Record, and familiarity. The API shape matches the assignment rather than Go-specific conventions. In parallel, **IP warmup** (a current initiative implemented in **Go**) is the vehicle for **ramping up in Go**; this submission stays in Rails to deliver a complete API within the time box.

---

## 2. Architecture Decisions

- **Thin controllers, plain models.** Business rules for “who can see what” live on `Project` (`accessible_to` / `accessible_to?`) and in controllers for HTTP-specific 401/403/404 responses.
- **Concerns** for cross-cutting behavior: `Authenticatable` (Bearer JWT), `ApiErrors` (consistent JSON errors), `FilterValidation` / UUID checks on path and query params to avoid PostgreSQL errors on malformed IDs, `TaskPayload` for response shape.
- **JWT in `Authorization: Bearer …`** with secrets from **`ENV["JWT_SECRET"]`** only (never committed).
- **Production** uses Rails 8 defaults for **Solid Cache, Solid Queue, and Solid Cable**, each with its own PostgreSQL database. Docker Compose creates those databases on first Postgres boot so `db:prepare` can migrate all of them without extra manual steps.
- **Logging:** **Rails provides logging by default** (request lines, log levels, tagged request IDs in production). In Docker, production is configured to **log to STDOUT**, which container runtimes aggregate. No extra logging gems are required for basic observability. Deliberately omitted for this scope: a dedicated **JSON / structured** log pipeline (e.g. `lograge`) on top of those defaults.
- **Intentionally omitted:** frontend (backend track), pagination and stats endpoints (time box).

---

## 3. Running Locally

The assignment assumes **Docker** only (no local Ruby install required for the API).

```bash
git clone https://github.com/Nitin-Pasricha/taskflow-nitin-pasricha.git
cd taskflow-nitin-pasricha
cp .env.example .env
```

Configure **`.env`** before the first start:

1. **`RAILS_MASTER_KEY`** — paste the full single line from **`config/master.key`** (generated with the app; not committed to git).
2. **`JWT_SECRET`** — any long random string (never commit real secrets).

Start the stack (builds the **`web`** image on first run):

```bash
docker compose up --build
```

With the default **`WEB_PORT`**, the API is available at **`http://localhost:3000`**.

- **Browser:** [http://localhost:3000/up](http://localhost:3000/up) should return **200** (Rails health check).
- **API usage:** this is a **JSON API** (backend track); use **curl**, **Postman**, or **`postman/taskflow-nitin-pasricha.postman_collection.json`**.

PostgreSQL credentials and ports are configurable via **`.env`** (see **`.env.example`**). Override the host port with **`WEB_PORT`** (e.g. `3001`).

Stop with `Ctrl+C`, then `docker compose down`. To reset data and re-run Postgres init scripts: `docker compose down -v`.

---

## 4. Running Migrations

**No manual migration step is required** when using Docker Compose: the assignment’s “migrations on container start” expectation is met by **`bin/docker-entrypoint`** on each **`web`** container start:

1. **`bin/rails db:prepare`** — creates databases if needed and applies pending migrations (primary plus Solid **cache**, **queue**, and **cable** databases).
2. **`bin/rails db:seed`** — loads the seed user, project, and three tasks (idempotent).

Application migrations live under **`db/migrate`** and use reversible **`change`** steps where supported, so **`db:rollback`** works for local development.

For a **non-Docker** production-mode boot, run:

```bash
bin/rails db:prepare
bin/rails db:seed
```

---

## 5. Test Credentials

After **`docker compose up`**, **`db:seed`** creates a user that can log in without registering:

```
Email:    seed@example.com
Password: password123
```

If you set **`SEED_USER_PASSWORD`** in `.env`, use that password instead.

The seeded project is named **TaskFlow Demo** and includes **three tasks** in **todo**, **in_progress**, and **done**.

---

## 6. API Reference

**Base URL (Docker default):** `http://localhost:3000`  
**Auth (except register/login):** `Authorization: Bearer <jwt>`  
**Content-Type:** `application/json` for bodies

| Method | Path | Auth | Notes |
|--------|------|------|--------|
| GET | `/up` | No | Health check |
| POST | `/auth/register` | No | Body: `name`, `email`, `password` |
| POST | `/auth/login` | No | Body: `email`, `password` |
| GET | `/projects` | Yes | Lists projects accessible to the user |
| POST | `/projects` | Yes | Body: `name`, `description` (optional) |
| GET | `/projects/:id` | Yes | Includes nested `tasks` |
| PATCH | `/projects/:id` | Yes | Owner only; `name`, `description` |
| DELETE | `/projects/:id` | Yes | Owner only; **204** |
| GET | `/projects/:project_id/tasks` | Yes | Query: `?status=`, `?assignee=` (UUID) |
| POST | `/projects/:project_id/tasks` | Yes | Body: `title` (required), optional `description`, `status`, `priority`, `assignee_id`, `due_date` |
| PATCH | `/tasks/:id` | Yes | Project must be accessible |
| DELETE | `/tasks/:id` | Yes | Project owner **or** task creator; **204** |

**Errors (assignment shape):**

- **400** validation: `{ "error": "validation failed", "fields": { ... } }`
- **401** unauthenticated: `{ "error": "unauthorized" }`
- **403** forbidden: `{ "error": "forbidden" }`
- **404** not found: `{ "error": "not found" }`

**Postman:** Import **`postman/taskflow-nitin-pasricha.postman_collection.json`**. Set the collection variable **`base_url`** to `http://localhost:3000`, run **Auth/login** (or register), then other requests (scripts can store `token`, `project_id`, `task_id`).

**RSpec (optional backend bonus):** The brief lists integration tests as a **bonus**; this repo includes **request specs** that hit the real HTTP stack (`spec/requests/auth_spec.rb`, `projects_spec.rb`, `tasks_spec.rb`). Run them with **Ruby 3.2+** and PostgreSQL for the test database:

```bash
bundle install
export JWT_SECRET=test_jwt_secret_minimum_length_for_hs256
bin/rails db:test:prepare
bundle exec rspec
```

---

## 7. What You’d Do With More Time

- **Broader test coverage:** more request specs for 403/404 branches and model specs.
- **Structured JSON logging** as a layer on top of Rails’ default logs (e.g. `lograge` or a custom formatter), if reviewers required machine-parseable one-line JSON; and a short **SIGTERM** note for operators: Puma stops gracefully on `docker stop` when the runtime sends SIGTERM.
- **Pagination** on `GET /projects` and task indexes; **`GET /projects/:id/stats`** per the bonus brief.
- **Configurable workflow statuses:** today `status` is a fixed enum (`todo`, `in_progress`, `done`). A richer product would let **each project (or workspace) define its own statuses** (and optionally **tags**), with APIs to **add, reorder, archive, or delete** them, and migrate tasks when a status is retired—similar to custom columns in Trello or Jira workflows.
- **Task types / work item kinds:** add a **`type`** (or **issue type**) dimension—e.g. **story**, **spike**, **bug**, **task**—with optional rules (estimates, acceptance criteria) per type, closer to Jira’s issue types.
- **Admin / super-user role:** introduce an **`admin`** (or **platform superuser**) flag or role that **bypasses normal project scoping** for support and governance: list or inspect any user, project, or task; reset passwords; disable accounts; audit logs. Regular users would remain scoped to **accessible projects** only.
- **Developer experience:** optional `dotenv-rails` so local `bin/rails s` loads `.env` without manual `export`.

Shortcuts taken for the deadline: relying on **Rails’ built-in logging** rather than extra structured-logging gems, no OpenAPI export (Postman + RSpec instead), and reliance on Rails 8 Solid multi-DB defaults in Docker rather than collapsing to a single database.
