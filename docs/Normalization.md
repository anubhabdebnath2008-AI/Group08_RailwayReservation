# Normalization
**FDs:** station_id→code,name,city · train_id→train_no,name,type · (train_id,stop_seq)→station_id,times,dist · (train_id,journey_date)→schedule_id · seat_id→coach_id,seat_no,berth · (schedule_id,seat_id)→is_booked · booking_id→pnr,passenger,schedule,stations,fare,status · bp_id→booking,seat,name,age,gender,fare.
**1NF:** all attributes atomic; multiple travellers per ticket are rows in booking_passenger, not a list column.
**2NF:** no partial dependencies; composite-key tables (train_route via surrogate key with unique pairs, schedule_seat) have non-key attributes depending on the whole key.
**3NF:** no transitive dependencies. Station details live in station, train details in train, class in coach (seat does not repeat it). Fare is stored per passenger as a historical snapshot (deliberate, so later rate changes don't alter past tickets).
**BCNF:** every determinant is a candidate key in all tables.
**Original unnormalized form** (for the report): one sheet with PNR, train, stations, passengers[], seats[] normalizes by splitting repeating groups (1NF), then separating train, station, seat and coach facts (2NF/3NF).
