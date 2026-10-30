USE railway_db;
DROP FUNCTION IF EXISTS fn_fare; DROP FUNCTION IF EXISTS fn_refund; DROP PROCEDURE IF EXISTS book_ticket; DROP PROCEDURE IF EXISTS cancel_ticket;
DELIMITER //
CREATE FUNCTION fn_fare(p_train INT, p_from INT, p_to INT, p_class VARCHAR(3)) RETURNS DECIMAL(10,2) READS SQL DATA
BEGIN
 DECLARE d INT; DECLARE rate DECIMAL(5,2);
 SELECT ABS(MAX(CASE WHEN station_id=p_to THEN dist_km END)-MAX(CASE WHEN station_id=p_from THEN dist_km END)) INTO d FROM train_route WHERE train_id=p_train;
 SET rate = CASE p_class WHEN 'SL' THEN 0.60 WHEN '3A' THEN 1.60 ELSE 2.30 END;
 RETURN ROUND(IFNULL(d,0)*rate,2);
END//
CREATE FUNCTION fn_refund(p_booking INT) RETURNS DECIMAL(10,2) READS SQL DATA
BEGIN
 DECLARE days INT; DECLARE fare DECIMAL(10,2);
 SELECT DATEDIFF(s.journey_date,CURDATE()), b.total_fare INTO days, fare FROM booking b JOIN schedule s ON s.schedule_id=b.schedule_id WHERE b.booking_id=p_booking;
 RETURN ROUND(fare*CASE WHEN days>=2 THEN 0.90 WHEN days>=1 THEN 0.50 ELSE 0 END,2);
END//
CREATE PROCEDURE book_ticket(IN p_user INT, IN p_sched INT, IN p_from INT, IN p_to INT, IN p_name VARCHAR(60), IN p_age INT, IN p_gender CHAR(1), IN p_seat INT, IN p_mode VARCHAR(12), OUT o_pnr CHAR(10))
BEGIN
 DECLARE v_fare DECIMAL(10,2); DECLARE v_id INT;
 DECLARE EXIT HANDLER FOR SQLEXCEPTION BEGIN ROLLBACK; RESIGNAL; END;
 START TRANSACTION;
 SELECT fn_fare(s.train_id,p_from,p_to,c.class) INTO v_fare FROM schedule s JOIN seat st ON st.seat_id=p_seat JOIN coach c ON c.coach_id=st.coach_id WHERE s.schedule_id=p_sched;
 SET o_pnr = LPAD(FLOOR(RAND()*10000000000),10,'0');
 INSERT INTO booking(pnr,passenger_id,schedule_id,from_station,to_station,total_fare) VALUES(o_pnr,p_user,p_sched,p_from,p_to,v_fare);
 SET v_id = LAST_INSERT_ID();
 INSERT INTO booking_passenger(booking_id,schedule_id,seat_id,name,age,gender,fare) VALUES(v_id,p_sched,p_seat,p_name,p_age,p_gender,v_fare);
 INSERT INTO payment(booking_id,amount,mode) VALUES(v_id,v_fare,p_mode);
 COMMIT;
END//
CREATE PROCEDURE cancel_ticket(IN p_booking INT, IN p_reason VARCHAR(100))
BEGIN
 DECLARE EXIT HANDLER FOR SQLEXCEPTION BEGIN ROLLBACK; RESIGNAL; END;
 START TRANSACTION;
 IF (SELECT status FROM booking WHERE booking_id=p_booking FOR UPDATE)<>'CONFIRMED' THEN SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='Booking is not active'; END IF;
 INSERT INTO cancellation(booking_id,refund_amount,reason) VALUES(p_booking,fn_refund(p_booking),p_reason);
 UPDATE payment SET status='REFUNDED' WHERE booking_id=p_booking;
 COMMIT;
END//
DELIMITER ;
