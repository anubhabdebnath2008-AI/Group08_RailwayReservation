USE railway_db;
-- Basic SELECT (10)
SELECT * FROM station ORDER BY city;
SELECT train_no,name FROM train WHERE train_type='Rajdhani';
SELECT name,email FROM passenger WHERE role='USER' ORDER BY name;
SELECT * FROM schedule WHERE journey_date>=CURDATE() ORDER BY journey_date;
SELECT coach_no,class FROM coach WHERE class='3A';
SELECT pnr,total_fare FROM booking WHERE status='CONFIRMED' AND total_fare>1000;
SELECT name,age FROM booking_passenger WHERE age>=60;
SELECT * FROM payment WHERE mode='UPI';
SELECT DISTINCT train_type FROM train;
SELECT pnr,status FROM booking ORDER BY booked_at DESC LIMIT 5;
-- Aggregate / GROUP BY (5)
SELECT train_id,COUNT(*) AS stops FROM train_route GROUP BY train_id;
SELECT mode,SUM(amount) AS revenue FROM payment WHERE status='PAID' GROUP BY mode;
SELECT status,COUNT(*) FROM booking GROUP BY status;
SELECT gender,AVG(age) AS avg_age FROM booking_passenger GROUP BY gender;
SELECT schedule_id,COUNT(*) AS bookings FROM booking GROUP BY schedule_id HAVING COUNT(*)>=2;
-- JOIN (5)
SELECT * FROM v_booking_details;
SELECT t.name,st.name AS station,r.stop_seq FROM train_route r JOIN train t USING(train_id) JOIN station st USING(station_id) ORDER BY t.name,r.stop_seq;
SELECT c.coach_no,c.class,COUNT(s.seat_id) AS seats FROM coach c LEFT JOIN seat s USING(coach_id) GROUP BY c.coach_id,c.coach_no,c.class;
SELECT b.pnr,bp.name,s.seat_no,c.coach_no FROM booking_passenger bp JOIN booking b USING(booking_id) JOIN seat s USING(seat_id) JOIN coach c USING(coach_id);
SELECT b.pnr,x.refund_amount,x.reason FROM cancellation x JOIN booking b USING(booking_id);
-- Subqueries (3)
SELECT pnr,total_fare FROM booking WHERE total_fare>(SELECT AVG(total_fare) FROM booking);
SELECT name FROM passenger WHERE passenger_id IN (SELECT passenger_id FROM booking WHERE status='CANCELLED');
SELECT name FROM station WHERE station_id NOT IN (SELECT from_station FROM booking);
-- Correlated subqueries (2)
SELECT b1.pnr,b1.total_fare FROM booking b1 WHERE b1.total_fare>(SELECT AVG(b2.total_fare) FROM booking b2 WHERE b2.schedule_id=b1.schedule_id);
SELECT p.name FROM passenger p WHERE (SELECT COUNT(*) FROM booking b WHERE b.passenger_id=p.passenger_id)>=2;
-- Demo: transaction / procedure / trigger
-- CALL book_ticket(2,1,1,3,'Test',30,'M',5,'UPI',@pnr); SELECT @pnr;  CALL cancel_ticket(1,'Change of plan');
