-- Create Table for Flight Information
CREATE TABLE flights (
    flight_id NUMBER PRIMARY KEY,
    flight_number VARCHAR2(10) NOT NULL,
    departure_city VARCHAR2(50),
    arrival_city VARCHAR2(50),
    departure_time DATE,
    arrival_time DATE,
    available_seats NUMBER,
    status VARCHAR2(20) DEFAULT 'Scheduled'
);

-- Create Table for Passenger Information
CREATE TABLE passengers (
    passenger_id NUMBER PRIMARY KEY,
    passenger_name VARCHAR2(100) NOT NULL,
    passenger_email VARCHAR2(100),
    passenger_phone VARCHAR2(15)
);

-- Create Table for Bookings
CREATE TABLE bookings (
    booking_id NUMBER PRIMARY KEY,
    flight_id NUMBER,
    passenger_id NUMBER,
    seat_number NUMBER,
    booking_date DATE DEFAULT SYSDATE,
    FOREIGN KEY (flight_id) REFERENCES flights(flight_id),
    FOREIGN KEY (passenger_id) REFERENCES passengers(passenger_id)
);

-- Create Table for Flight Status
CREATE TABLE flight_status (
    flight_id NUMBER PRIMARY KEY,
    status VARCHAR2(20),
    updated_time DATE DEFAULT SYSDATE,
    FOREIGN KEY (flight_id) REFERENCES flights(flight_id)
);

-- Create Sequences for Auto-incrementing IDs
CREATE SEQUENCE seq_flight_id START WITH 1 INCREMENT BY 1 NOCACHE;
CREATE SEQUENCE seq_passenger_id START WITH 1 INCREMENT BY 1 NOCACHE;
CREATE SEQUENCE seq_booking_id START WITH 1 INCREMENT BY 1 NOCACHE;

-- Procedure to Add a New Flight
CREATE OR REPLACE PROCEDURE add_flight (
    p_flight_number IN VARCHAR2,
    p_departure_city IN VARCHAR2,
    p_arrival_city IN VARCHAR2,
    p_departure_time IN DATE,
    p_arrival_time IN DATE,
    p_available_seats IN NUMBER
) IS
BEGIN
    INSERT INTO flights (flight_id, flight_number, departure_city, arrival_city, departure_time, arrival_time, available_seats)
    VALUES (seq_flight_id.NEXTVAL, p_flight_number, p_departure_city, p_arrival_city, p_departure_time, p_arrival_time, p_available_seats);
    COMMIT;
END add_flight;
/

-- Procedure to Add a New Passenger
CREATE OR REPLACE PROCEDURE add_passenger (
    p_passenger_name IN VARCHAR2,
    p_passenger_email IN VARCHAR2,
    p_passenger_phone IN VARCHAR2
) IS
BEGIN
    INSERT INTO passengers (passenger_id, passenger_name, passenger_email, passenger_phone)
    VALUES (seq_passenger_id.NEXTVAL, p_passenger_name, p_passenger_email, p_passenger_phone);
    COMMIT;
END add_passenger;
/

-- Procedure to Book a Flight
CREATE OR REPLACE PROCEDURE book_flight (
    p_passenger_id IN NUMBER,
    p_flight_id IN NUMBER,
    p_seat_number IN NUMBER
) IS
    v_available_seats NUMBER;
BEGIN
    -- Check if the flight has available seats
    SELECT available_seats INTO v_available_seats
    FROM flights
    WHERE flight_id = p_flight_id;

    IF v_available_seats > 0 THEN
        -- Proceed with the booking
        INSERT INTO bookings (booking_id, flight_id, passenger_id, seat_number)
        VALUES (seq_booking_id.NEXTVAL, p_flight_id, p_passenger_id, p_seat_number);

        -- Update available seats in the flight
        UPDATE flights
        SET available_seats = available_seats - 1
        WHERE flight_id = p_flight_id;

        COMMIT;
        DBMS_OUTPUT.PUT_LINE('Booking successful! Seat Number: ' || p_seat_number);
    ELSE
        DBMS_OUTPUT.PUT_LINE('No available seats for this flight.');
    END IF;
END book_flight;
/

-- Procedure to Update Flight Status
CREATE OR REPLACE PROCEDURE update_flight_status (
    p_flight_id IN NUMBER,
    p_status IN VARCHAR2
) IS
BEGIN
    INSERT INTO flight_status (flight_id, status)
    VALUES (p_flight_id, p_status);
    COMMIT;
END update_flight_status;
/

-- Procedure to View All Flights
CREATE OR REPLACE PROCEDURE view_flights IS
BEGIN
    FOR flight_rec IN (SELECT * FROM flights) LOOP
        DBMS_OUTPUT.PUT_LINE('Flight ID: ' || flight_rec.flight_id || ' | Flight No: ' || flight_rec.flight_number || ' | Departure: ' || flight_rec.departure_city || ' | Arrival: ' || flight_rec.arrival_city || ' | Available Seats: ' || flight_rec.available_seats || ' | Status: ' || flight_rec.status);
    END LOOP;
END view_flights;
/

-- Procedure to View All Passengers
CREATE OR REPLACE PROCEDURE view_passengers IS
BEGIN
    FOR passenger_rec IN (SELECT * FROM passengers) LOOP
        DBMS_OUTPUT.PUT_LINE('Passenger ID: ' || passenger_rec.passenger_id || ' | Name: ' || passenger_rec.passenger_name || ' | Email: ' || passenger_rec.passenger_email || ' | Phone: ' || passenger_rec.passenger_phone);
    END LOOP;
END view_passengers;
/

-- Procedure to View Bookings for a Flight
CREATE OR REPLACE PROCEDURE view_bookings_for_flight (
    p_flight_id IN NUMBER
) IS
BEGIN
    FOR booking_rec IN (SELECT * FROM bookings WHERE flight_id = p_flight_id) LOOP
        DBMS_OUTPUT.PUT_LINE('Booking ID: ' || booking_rec.booking_id || ' | Passenger ID: ' || booking_rec.passenger_id || ' | Seat Number: ' || booking_rec.seat_number || ' | Booking Date: ' || booking_rec.booking_date);
    END LOOP;
END view_bookings_for_flight;
/

-- Procedure to View Flight Status
CREATE OR REPLACE PROCEDURE view_flight_status (
    p_flight_id IN NUMBER
) IS
BEGIN
    FOR status_rec IN (SELECT * FROM flight_status WHERE flight_id = p_flight_id ORDER BY updated_time DESC) LOOP
        DBMS_OUTPUT.PUT_LINE('Flight ID: ' || status_rec.flight_id || ' | Status: ' || status_rec.status || ' | Updated: ' || status_rec.updated_time);
    END LOOP;
END view_flight_status;
/

-- Procedure to View Bookings for a Passenger
CREATE OR REPLACE PROCEDURE view_bookings_for_passenger (
    p_passenger_id IN NUMBER
) IS
BEGIN
    FOR booking_rec IN (SELECT * FROM bookings WHERE passenger_id = p_passenger_id) LOOP
        DBMS_OUTPUT.PUT_LINE('Booking ID: ' || booking_rec.booking_id || ' | Flight ID: ' || booking_rec.flight_id || ' | Seat Number: ' || booking_rec.seat_number || ' | Booking Date: ' || booking_rec.booking_date);
    END LOOP;
END view_bookings_for_passenger;
/

-- Example of adding flights
BEGIN
    add_flight('AI202', 'New York', 'London', TO_DATE('2025-01-10 10:00:00', 'YYYY-MM-DD HH24:MI:SS'), TO_DATE('2025-01-10 18:00:00', 'YYYY-MM-DD HH24:MI:SS'), 100);
    add_flight('BA305', 'London', 'Paris', TO_DATE('2025-02-05 08:00:00', 'YYYY-MM-DD HH24:MI:SS'), TO_DATE('2025-02-05 10:30:00', 'YYYY-MM-DD HH24:MI:SS'), 150);
END;
/

-- Example of adding passengers
BEGIN
    add_passenger('John Doe', 'john.doe@example.com', '1234567890');
    add_passenger('Jane Smith', 'jane.smith@example.com', '9876543210');
END;
/

-- Example of making bookings
BEGIN
    book_flight(1, 1, 1); -- John Doe books seat 1 on flight AI202
    book_flight(2, 2, 2); -- Jane Smith books seat 2 on flight BA305
END;
/

-- Example of updating flight status
BEGIN
    update_flight_status(1, 'Delayed');
    update_flight_status(2, 'Completed');
END;
/

-- Example of viewing flights, passengers, bookings, and status
BEGIN
    view_flights;
    view_passengers;
    view_bookings_for_flight(1);
    view_flight_status(1);
    view_bookings_for_passenger(1);
END;
/
