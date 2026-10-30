CREATE DATABASE IF NOT EXISTS railway_db; USE railway_db;
CREATE TABLE station(station_id INT AUTO_INCREMENT PRIMARY KEY, code VARCHAR(6) NOT NULL UNIQUE, name VARCHAR(60) NOT NULL, city VARCHAR(40) NOT NULL);
CREATE TABLE train(train_id INT AUTO_INCREMENT PRIMARY KEY, train_no VARCHAR(8) NOT NULL UNIQUE, name VARCHAR(60) NOT NULL, train_type VARCHAR(20) NOT NULL);
CREATE TABLE train_route(route_id INT AUTO_INCREMENT PRIMARY KEY, train_id INT NOT NULL, station_id INT NOT NULL, stop_seq INT NOT NULL, arr_time TIME, dep_time TIME, dist_km INT NOT NULL CHECK(dist_km>=0),
 UNIQUE(train_id,stop_seq), UNIQUE(train_id,station_id), FOREIGN KEY(train_id) REFERENCES train(train_id), FOREIGN KEY(station_id) REFERENCES station(station_id));
CREATE TABLE schedule(schedule_id INT AUTO_INCREMENT PRIMARY KEY, train_id INT NOT NULL, journey_date DATE NOT NULL, status ENUM('SCHEDULED','CANCELLED') DEFAULT 'SCHEDULED',
 UNIQUE(train_id,journey_date), FOREIGN KEY(train_id) REFERENCES train(train_id));
CREATE TABLE coach(coach_id INT AUTO_INCREMENT PRIMARY KEY, train_id INT NOT NULL, coach_no VARCHAR(4) NOT NULL, class ENUM('SL','3A','2A') NOT NULL, UNIQUE(train_id,coach_no), FOREIGN KEY(train_id) REFERENCES train(train_id));
CREATE TABLE seat(seat_id INT AUTO_INCREMENT PRIMARY KEY, coach_id INT NOT NULL, seat_no INT NOT NULL, berth ENUM('LOWER','MIDDLE','UPPER','SIDE') NOT NULL, UNIQUE(coach_id,seat_no), FOREIGN KEY(coach_id) REFERENCES coach(coach_id));
CREATE TABLE schedule_seat(schedule_id INT NOT NULL, seat_id INT NOT NULL, is_booked BOOLEAN NOT NULL DEFAULT 0, PRIMARY KEY(schedule_id,seat_id), FOREIGN KEY(schedule_id) REFERENCES schedule(schedule_id), FOREIGN KEY(seat_id) REFERENCES seat(seat_id));
CREATE TABLE passenger(passenger_id INT AUTO_INCREMENT PRIMARY KEY, name VARCHAR(60) NOT NULL, email VARCHAR(80) NOT NULL UNIQUE, phone VARCHAR(15), password_hash VARCHAR(255) NOT NULL, role ENUM('USER','ADMIN') NOT NULL DEFAULT 'USER');
CREATE TABLE booking(booking_id INT AUTO_INCREMENT PRIMARY KEY, pnr CHAR(10) NOT NULL UNIQUE, passenger_id INT NOT NULL, schedule_id INT NOT NULL, from_station INT NOT NULL, to_station INT NOT NULL,
 booked_at DATETIME DEFAULT CURRENT_TIMESTAMP, total_fare DECIMAL(10,2) NOT NULL DEFAULT 0, status ENUM('CONFIRMED','CANCELLED') DEFAULT 'CONFIRMED', CHECK(from_station<>to_station),
 FOREIGN KEY(passenger_id) REFERENCES passenger(passenger_id), FOREIGN KEY(schedule_id) REFERENCES schedule(schedule_id), FOREIGN KEY(from_station) REFERENCES station(station_id), FOREIGN KEY(to_station) REFERENCES station(station_id));
CREATE TABLE booking_passenger(bp_id INT AUTO_INCREMENT PRIMARY KEY, booking_id INT NOT NULL, schedule_id INT NOT NULL, seat_id INT NOT NULL, name VARCHAR(60) NOT NULL, age INT NOT NULL CHECK(age BETWEEN 1 AND 120), gender ENUM('M','F','O') NOT NULL, fare DECIMAL(10,2) NOT NULL,
 status ENUM('CONFIRMED','CANCELLED') DEFAULT 'CONFIRMED', FOREIGN KEY(booking_id) REFERENCES booking(booking_id), FOREIGN KEY(schedule_id,seat_id) REFERENCES schedule_seat(schedule_id,seat_id));
CREATE TABLE payment(payment_id INT AUTO_INCREMENT PRIMARY KEY, booking_id INT NOT NULL, amount DECIMAL(10,2) NOT NULL, mode ENUM('UPI','CARD','NETBANKING') NOT NULL, status ENUM('PAID','REFUNDED') DEFAULT 'PAID', paid_at DATETIME DEFAULT CURRENT_TIMESTAMP, FOREIGN KEY(booking_id) REFERENCES booking(booking_id));
CREATE TABLE cancellation(cancel_id INT AUTO_INCREMENT PRIMARY KEY, booking_id INT NOT NULL UNIQUE, cancelled_at DATETIME DEFAULT CURRENT_TIMESTAMP, refund_amount DECIMAL(10,2) NOT NULL, reason VARCHAR(100), FOREIGN KEY(booking_id) REFERENCES booking(booking_id));
CREATE INDEX idx_route_station ON train_route(station_id, train_id);
CREATE INDEX idx_booking_user ON booking(passenger_id, booked_at);
