# Rewards App

Small rewards redemption system built for a take-home exercise.

- **Backend**: Ruby on Rails 8 API + Postgres
- **Frontend**: React (TypeScript) + Vite
- **Infra**: Docker + Docker Compose
- **Tests**: RSpec (API), Vitest + Testing Library (web)
- **Quality**: Rubocop, ESLint

The app shows a demo user’s points balance, a list of rewards, and a history of redemptions.  
Redemptions are processed inside a transaction with row-level locks to prevent double-spend under concurrency.

---

## 1. Prerequisites

You only need:

- **Docker** (Docker Desktop or engine)
- **Docker Compose** (v2, usually built into Docker Desktop)

No local Ruby / Node / Postgres required.

---

## 2. Project structure

```text
rewards-app/
├── backend/      # Rails 8 API (Ruby 3.4, Postgres)
├── frontend/     # React + TypeScript + Vite web app
├── docker-compose.yml
└── README.md
```

---

## 3. Setup & first run

From the repository root:

```bash
git clone https://github.com/sowgat-mahmud/rewards-app.git rewards-app
cd rewards-app
```

### 3.1 Build Docker images

```bash
docker compose build
```

### 3.2 Create & migrate the database, then seed demo data

Run this once to create the `rewards` database and seed the demo user + rewards:

```bash
docker compose run --rm api bin/rails db:create db:migrate db:seed
```

> If you ever need to reseed, you can safely run `db:seed` again:
>
> ```bash
> docker compose run --rm api bin/rails db:seed
> ```

### 3.3 Start the stack

```bash
docker compose up
```

- The **API** container will wait for Postgres, run migrations and seeds (idempotent), then boot Puma.
- The **web** container will start Vite dev server.

You should see logs similar to:

- `Postgres is up - running migrations and seeds...`
- `Listening on http://0.0.0.0:3000` (Rails)
- `VITE vX.X.X ready ...` (frontend)

---

## 4. Application URLs and API Reference

Once `docker compose up` is running:

- **Frontend UI (dashboard)**  
  http://localhost:5173/

- **API base**  
  http://localhost:3000/api/v1

Key endpoints:

- `GET /api/v1/users/demo` – returns the seeded “Demo User”
- `GET /api/v1/users/:id` – show user info (id, name, email, points_balance)
- `GET /api/v1/rewards` – list available rewards
- `GET /api/v1/users/:user_id/redemptions` – list a user’s redemption history
- `POST /api/v1/redemptions` – perform a synchronous redemption (uses transactional service)
- `POST /redemptions` – enqueue an async redemption via `RedemptionJob` (used to demonstrate async flow)

All endpoints are JSON-based and expect `Content-Type: application/json` where a body is required.

Base URL (inside Docker): `http://localhost:3000`

Versioned API base: `http://localhost:3000/api/v1`

---

### Users

#### `GET /api/v1/users/demo`

Returns the seeded demo user.

- **Request body:** _none_
- **Example:**

```bash
curl http://localhost:3000/api/v1/users/demo
```

---

#### `GET /api/v1/users/:id`

Returns a single user by ID.

- **Path params:**
  - `id` – user ID (e.g. `42`)
- **Request body:** _none_
- **Example:**

```bash
curl http://localhost:3000/api/v1/users/42
```

Typical response shape:

```json
{
  "id": 42,
  "name": "Demo User",
  "email": "demo@example.com",
  "points_balance": 1000
}
```

---

### Rewards

#### `GET /api/v1/rewards`

Returns the list of available rewards.

- **Request body:** _none_
- **Example:**

```bash
curl http://localhost:3000/api/v1/rewards
```

Typical response shape:

```json
[
  {
    "id": 1,
    "name": "Coffee Mug",
    "cost_in_points": 200,
    "inventory": 10,
    "category": "merchandise",
    "available": true
  },
  {
    "id": 2,
    "name": "Gift Card",
    "cost_in_points": 500,
    "inventory": 5,
    "category": "gift_card",
    "available": true
  }
]
```

---

### Redemptions

#### `GET /api/v1/users/:user_id/redemptions`

Returns a user’s redemption history ordered by most recent first.

- **Path params:**
  - `user_id` – user ID (e.g. `42`)
- **Request body:** _none_
- **Example:**

```bash
curl http://localhost:3000/api/v1/users/42/redemptions
```

Typical response shape:

```json
[
  {
    "id": 10,
    "status": "completed",
    "points_cost": 200,
    "reward": {
      "id": 1,
      "name": "Coffee Mug"
    },
    "created_at": "2025-12-02T17:34:33Z"
  }
]
```

---

#### `POST /api/v1/redemptions`

Performs a **synchronous** redemption using the transactional `Rewards::Redeemer` service (with row-level locking on `users` and `rewards`).

- **Request body (JSON):**

```json
{
  "redemption": {
    "user_id": 42,
    "reward_id": 1
  }
}
```

- **Success response (201 Created) – shape:**

```json
{
  "redemption": {
    "id": 11,
    "status": "completed",
    "points_cost": 200,
    "reward": {
      "id": 1,
      "name": "Coffee Mug"
    },
    "created_at": "2025-12-02T17:40:00Z"
  },
  "user": {
    "id": 42,
    "points_balance": 800
  }
}
```

- **Error responses (422 Unprocessable Entity) – examples:**

```json
{ "error": "Not enough points" }
```

```json
{ "error": "Reward is out of stock" }
```

- **Example curl:**

```bash
curl -X POST http://localhost:3000/api/v1/redemptions   -H "Content-Type: application/json"   -d '{
    "redemption": {
      "user_id": 42,
      "reward_id": 1
    }
  }'
```

---

#### `POST /redemptions`

Queues an **asynchronous** redemption via `RedemptionJob`. This endpoint is primarily to demonstrate async job handling; the job later calls the same `Rewards::Redeemer` service in the background.

- **Request body (JSON):**

```json
{
  "user_id": 42,
  "reward_id": 1
}
```

- **Success response (202 Accepted) – shape:**

```json
{
  "status": "queued",
  "user_id": 42,
  "reward_id": 1
}
```

- **Example curl:**

```bash
curl -X POST http://localhost:3000/redemptions   -H "Content-Type: application/json"   -d '{
    "user_id": 42,
    "reward_id": 1
  }'
```
---

## 5. How the redemption logic works

### 5.1 Domain models (simplified)

- **User**
  - `points_balance` – integer balance of points

- **Reward**
  - `cost_in_points` – points required to redeem
  - `inventory` – remaining stock
  - `category` – enum (e.g., `gift_card`, `merchandise`)

- **Redemption**
  - `user_id`, `reward_id`
  - `points_cost`
  - `status` – enum: `pending`, `completed`, `failed`

### 5.2 Transactional service with row-level locking

File: `backend/app/services/rewards/redeemer.rb`

High-level behavior:

1. Wraps everything in `Redemption.transaction`.
2. Acquires **row-level locks** on both `user` and `reward` with `lock!`:
   - `@user.lock!`
   - `@reward.lock!`
3. Performs **defensive checks** under the lock:
   - If `reward.inventory <= 0` → raises `OutOfStock`
   - If `user.points_balance < reward.cost_in_points` → raises `InsufficientPoints`
4. Updates in memory:
   - `user.points_balance -= reward.cost_in_points`
   - `reward.inventory  -= 1`
5. Saves both records with `save!`.
6. Creates a `Redemption` record with `status: :completed`.

If anything fails, the transaction is rolled back and no partial state leaks out.  
The combination of **transaction + `lock!`** ensures:

- Two concurrent requests cannot both redeem the **last** copy of a reward.
- Points / inventory cannot go negative due to race conditions.
- Review feedback about “missing transactions and proper locking” is explicitly addressed.

---

## 6. Synchronous vs async redemption

### 6.1 Synchronous API (used by the React UI)

Endpoint:

```http
POST /api/v1/redemptions
Content-Type: application/json

{
  "redemption": {
    "user_id": 42,
    "reward_id": 1
  }
}
```

Controller: `Api::V1::RedemptionsController#create`

- Finds `user` and `reward`.
- Calls `Rewards::Redeemer.new(user:, reward:).call`.
- Returns JSON containing:
  - The `redemption` (id, status, points_cost, reward info).
  - Updated `user` points balance.

The frontend uses this endpoint to:

- Update the balance panel.
- Update reward inventory.
- Prepend the new redemption into the history list.

### 6.2 Async job (demonstrates async reward handling)

File: `backend/app/jobs/redemption_job.rb`

```rb
class RedemptionJob < ApplicationJob
  queue_as :default

  def perform(user_id, reward_id)
    user = User.find(user_id)
    reward = Reward.find(reward_id)

    Rewards::Redeemer.new(user: user, reward: reward).call
  rescue Rewards::Redeemer::Error => e
    Rails.logger.error("Redemption failed: #{e.message}")
  end
end
```

Non-namespaced controller: `RedemptionsController#create`  
Route: `POST /redemptions`

- Enqueues `RedemptionJob.perform_later(user_id, reward_id)`.
- Returns `202 Accepted` with a simple `{ status: "queued", ... }` JSON payload.
- Covered by request spec and job spec to demonstrate async wiring.

This shows how the app could evolve from **sync** to **async** redemptions without changing the core `Rewards::Redeemer` business logic.

---

## 7. Frontend behavior (Dashboard)

The main page is `frontend/src/pages/DashboardPage.tsx`.

On load it:

1. Calls `GET /api/v1/users/demo` to get the demo user (id + points).
2. Uses that id to call:
   - `GET /api/v1/rewards`
   - `GET /api/v1/users/:id/redemptions`
3. Renders:
   - **BalancePanel** – demo user name + points_balance.
   - **RewardsList** – each reward’s name, cost, category, inventory, and Redeem button.
   - **RedemptionHistory** – list of past redemptions.

### 7.1 Redeem flow

When clicking **Redeem**:

1. `DashboardPage` calls:

   ```ts
   createRedemption(user.id, rewardId);
   // (POST /api/v1/redemptions)
   ```

2. Shows a loading state on that button (`Redeeming...`).
3. On success:
   - Updates the in-memory `user.points_balance`.
   - Decrements the reward’s `inventory` and `available` flag.
   - Prepends the new redemption to the history.
4. On failure:
   - Shows an error banner (using `ErrorBanner` component).

The `RewardsList` disables the button when:

- Reward is out of stock (`available === false`), or
- User doesn’t have enough points, or
- A redemption is currently in progress for that reward id.

---

## 8. Running tests & linters

All commands below are run from the **repo root** (`rewards-app/`).

### 8.1 Backend: RSpec test suite

Use the API service with test environment:

```bash
docker compose run --rm -e RAILS_ENV=test api bundle exec rspec
```

This runs:

- Service tests for `Rewards::Redeemer`.
- Job tests for `RedemptionJob`.
- Request specs for API endpoints, including the async `/redemptions` route.

### 8.2 Backend: Rubocop

```bash
docker compose run --rm api bundle exec rubocop
```

Or, to auto-correct safe offenses:

```bash
docker compose run --rm api bundle exec rubocop -A
```

---

### 8.3 Frontend: unit tests (Vitest)

```bash
docker compose run --rm web npm test
```

This includes, for example:

- `DashboardPage.test.tsx` – verifies error state when the user API fails.

### 8.4 Frontend: ESLint

```bash
docker compose run --rm web npm run lint
```

The project enforces TypeScript rules, React Hooks rules, and basic style constraints.

---

## 9. Notes / trade-offs

- **DB bootstrapping**  
  On the first run, you must run `db:create db:migrate db:seed` once; afterward, `docker compose up` is enough (migrations + seeds are idempotent).

- **Demo user id**  
  The demo user’s id is **not** hard-coded as `1`. Instead:
  - Seeds ensure a `demo@example.com` user exists.
  - The frontend calls `GET /api/v1/users/demo` to discover the correct id before loading data.

- **Sync vs async**  
  The UI currently uses the synchronous `/api/v1/redemptions` endpoint for simplicity.  
  The separate `/redemptions` endpoint and `RedemptionJob` show how the same business logic can run asynchronously via ActiveJob.

---

## 10. Quick start (TL;DR)

```bash
git clone <your-repo-url> rewards-app
cd rewards-app

docker compose build
docker compose run --rm api bin/rails db:create db:migrate db:seed
docker compose up
```

Then open:

- Frontend: http://localhost:5173/
- API docs / endpoints: http://localhost:3000/api/v1
