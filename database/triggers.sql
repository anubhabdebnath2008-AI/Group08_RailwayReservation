USE railway_db;
DROP TRIGGER IF EXISTS trg_bp_before_insert; DROP TRIGGER IF EXISTS trg_bp_after_insert; DROP TRIGGER IF EXISTS trg_bp_after_update; DROP TRIGGER IF EXISTS trg_cancel_after_insert;
DELIMITER //
CREATE TRIGGER trg_bp_before_insert BEFORE INSERT ON booking_passenger FOR EACH ROW
BEGIN
 IF (SELECT is_booked FROM schedule_seat WHERE schedule_id=NEW.schedule_id AND seat_id=NEW.seat_id FOR UPDATE)=1 THEN
  SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='Seat already booked for this journey';
 END IF;
END//
CREATE TRIGGER trg_bp_after_insert AFTER INSERT ON booking_passenger FOR EACH ROW
 UPDATE schedule_seat SET is_booked=1 WHERE schedule_id=NEW.schedule_id AND seat_id=NEW.seat_id//
CREATE TRIGGER trg_bp_after_update AFTER UPDATE ON booking_passenger FOR EACH ROW
BEGIN
 IF NEW.status='CANCELLED' AND OLD.status='CONFIRMED' THEN
  UPDATE schedule_seat SET is_booked=0 WHERE schedule_id=NEW.schedule_id AND seat_id=NEW.seat_id;
 END IF;
END//
CREATE TRIGGER trg_cancel_after_insert AFTER INSERT ON cancellation FOR EACH ROW
BEGIN
 UPDATE booking SET status='CANCELLED' WHERE booking_id=NEW.booking_id;
 UPDATE booking_passenger SET status='CANCELLED' WHERE booking_id=NEW.booking_id AND status='CONFIRMED';
END//
DELIMITER ;
