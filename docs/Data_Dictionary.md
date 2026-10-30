# Data Dictionary (summary; full types are in database/schema.sql)
| Table | Purpose | Key columns |
|---|---|---|
| station | Stations | code (unique), name, city |
| train | Trains | train_no (unique), name, train_type |
| train_route | Ordered stops with distance | stop_seq, dist_km (km from origin) |
| schedule | A train running on a date | journey_date, status |
| coach / seat | Physical layout | class (SL/3A/2A), berth |
| schedule_seat | Seat availability per journey | is_booked (maintained by triggers) |
| passenger | User accounts | email (unique), role (USER/ADMIN), password_hash |
| booking | Ticket header | pnr, from/to station, total_fare, status |
| booking_passenger | Travellers and seats | age 1-120, gender M/F/O, fare |
| payment | Payment record | mode UPI/CARD/NETBANKING, status PAID/REFUNDED |
| cancellation | Cancellation and refund | refund_amount, reason |
