# Group XX: Railway Reservation and Passenger Management System (BTY39105)

**Team:** Member 1 (requirements, ER) · Member 2 (schema, normalization) · Member 3 (SQL, data) · Member 4 (backend, transactions) · Member 5 (frontend, GitHub, deployment) — *fill in names and contributions.*

## Problem and objectives
A railway booking application for trains, stations, routes, coaches, seats, passengers, bookings and cancellations. Seat availability updates automatically on booking and cancellation, enforced inside the database.

## Stack
MySQL 8 · Python Flask · Bootstrap 5 · Git/GitHub · Render (or similar) for hosting.

## Features
Login/logout and register · role-based access (USER, ADMIN) · train search with filter/sort · seat availability per journey date · multi-passenger booking in one transaction · cancellation with refund calculation · booking history · admin dashboard (5 report queries from the database) · station CRUD · input validation and friendly errors.

## Database
12 tables: station, train, train_route, schedule, coach, seat, schedule_seat, passenger, booking, booking_passenger, payment, cancellation. See `docs/`.
Key points: `schedule_seat` tracks availability per journey date. Triggers: `trg_bp_before_insert` (blocks double booking), `trg_bp_after_insert` (marks seat booked), `trg_bp_after_update` (frees seat), `trg_cancel_after_insert` (cancels booking and passengers). Procedures: `book_ticket`, `cancel_ticket` (COMMIT/ROLLBACK). Functions: `fn_fare`, `fn_refund`. Views: `v_occupancy`, `v_booking_details`.

## Setup
```
mysql -u root -p < database/schema.sql
mysql -u root -p < database/triggers.sql
mysql -u root -p < database/procedures.sql
mysql -u root -p < database/views.sql
mysql -u root -p < database/insert_data.sql     # load AFTER triggers/procedures
cd src/backend && pip install -r requirements.txt
export DB_HOST=localhost DB_USER=root DB_PASSWORD=yourpass DB_NAME=railway_db SECRET_KEY=change-me
python app.py        # http://127.0.0.1:5000
```
`database/gen_data.py` regenerates `insert_data.sql` (needs Flask installed). Never commit real passwords; use environment variables.

## Demo credentials
Admin: `admin@rail.com` / `admin123` · User: `aarav@mail.com` / `user123`
Try: Howrah → New Delhi on 2026-11-06 (or 2026-11-09, 2026-11-12). Sample trains run in Nov–Dec 2026.

## Live URL / screenshots
*Add after deployment and capture screenshots into `screenshots/`.*

## Known simplification
A booked seat is blocked for the whole journey of that schedule (not per segment). Mention this in your viva as a scope decision.
