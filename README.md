# NeighborHub

A real-time community events board built with Phoenix LiveView. Neighbors post local events — stoop sales, block parties, park meetups — and RSVP instantly, no page reloads.

## What it does

- Sign up, log in, and post events with title, location, date, and description
- Browse all upcoming events on a bulletin-board style feed
- RSVP to events in real time via Phoenix LiveView — counts update instantly across the page over a WebSocket connection, with zero custom JavaScript
- Full REST API with token-based authentication, so the same backend can serve a future mobile client alongside the web app

## Architecture

NeighborHub follows a standard Phoenix context-based architecture, separating business logic from the web layer:

```
lib/neighbor_hub/              # Business logic (no web concerns)
  accounts.ex                  # User auth, signup, login
  accounts/user.ex             # User schema + changesets
  events.ex                    # Event + RSVP business logic
  events/event.ex              # Event schema
  events/rsvp.ex               # RSVP schema (join table, unique per user/event)

lib/neighbor_hub_web/          # Web layer
  router.ex                    # Routes, pipelines, auth gating
  controllers/                 # Classic request/response (auth, events CRUD)
  live/event_live.ex           # Real-time event page with live RSVP
  plugs/load_current_user.ex   # Session-based auth middleware
  controllers/api_*            # JSON API with token auth
```

**Why this structure:** controllers and LiveViews never talk to the database directly — they call context modules (`Accounts`, `Events`), which own all business logic and validation. This keeps the web layer thin and the domain logic testable and reusable across both the HTML controllers and the JSON API.

## Key technical decisions

**Dual authentication.** Session cookies for the browser (via a custom `LoadCurrentUser` plug that runs on every request) and signed tokens for the API (`Phoenix.Token`, verified per-request via an `Authorization: Bearer` header) — same `Accounts` context powers both.

**Real-time RSVPs via LiveView.** The event detail page (`EventLive`) keeps a WebSocket connection open. Clicking RSVP sends a `phx-click` event to the server, which updates the database and recalculates the count — Phoenix then diffs the rendered HTML and pushes only the changed DOM nodes back to the browser.

**Database-enforced constraints.** Email uniqueness and one-RSVP-per-user-per-event are enforced at the PostgreSQL level (unique indexes), not just in application code, so the data stays consistent even under concurrent requests.

## Tech stack

Elixir · Phoenix · Phoenix LiveView · Ecto · PostgreSQL · Tailwind CSS

## Running locally

```bash
mix deps.get
mix ecto.setup       # create db, run migrations, run seeds
mix phx.server
```

Visit `localhost:4000`. Seed data includes 4 sample users and 6 events so the app isn't empty on first run.

## What I'd build next

- Event categories and filtering
- Email reminders before an event starts
- Image uploads for event posts