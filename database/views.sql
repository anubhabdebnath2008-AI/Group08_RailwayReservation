USE railway_db;
CREATE OR REPLACE VIEW v_occupancy AS
SELECT s.schedule_id, t.train_no, t.name AS train, s.journey_date, COUNT(*) AS total_seats, SUM(ss.is_booked) AS booked, ROUND(100*SUM(ss.is_booked)/COUNT(*),1) AS occupancy_pct
FROM schedule s JOIN train t ON t.train_id=s.train_id JOIN schedule_seat ss ON ss.schedule_id=s.schedule_id GROUP BY s.schedule_id, t.train_no, t.name, s.journey_date;
CREATE OR REPLACE VIEW v_booking_details AS
SELECT b.booking_id, b.pnr, b.passenger_id, p.name AS account, t.train_no, t.name AS train, s.journey_date, fs.name AS from_stn, ts.name AS to_stn, b.total_fare, b.status
FROM booking b JOIN passenger p ON p.passenger_id=b.passenger_id JOIN schedule s ON s.schedule_id=b.schedule_id JOIN train t ON t.train_id=s.train_id
JOIN station fs ON fs.station_id=b.from_station JOIN station ts ON ts.station_id=b.to_station;
