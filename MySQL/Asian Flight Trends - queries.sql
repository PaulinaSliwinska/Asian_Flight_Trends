/*
This SQL script is used for analyzing and processing data related to air travel, primarily in Asia.
It utilizes two tables: 'customer_booking', containing reservation information, and 'airports', containing airport location data.
The script joins these tables, adds new columns, updates data formats, and creates views for further analysis and visualization in Python.
*/


SELECT *
FROM customer_booking;

-- Classify purchase_lead into different time ranges
SELECT purchase_lead,
CASE
	WHEN purchase_lead <= 7 THEN 'up to 7 days'
    WHEN purchase_lead BETWEEN 8 AND 30 THEN '8-30 days'
    WHEN purchase_lead BETWEEN 31 AND 90 THEN '31-90 days'
    WHEN purchase_lead BETWEEN 91 AND 180 THEN '91-180 days'
    WHEN purchase_lead BETWEEN 181 AND 365 THEN '181-365 days'
    ELSE 'more than 365 days'
END AS purchase_lead_range
FROM customer_booking;

-- Add and populate a new column for purchase_lead range
ALTER TABLE customer_booking 
ADD COLUMN purchase_lead_range VARCHAR(255);

UPDATE customer_booking
SET purchase_lead_range = CASE
	WHEN purchase_lead <= 7 THEN 'up to 7 days'
	WHEN purchase_lead BETWEEN 8 AND 30 THEN '8-30 days'
    WHEN purchase_lead BETWEEN 31 AND 90 THEN '31-90 days'
    WHEN purchase_lead BETWEEN 91 AND 180 THEN '91-180 days'
    WHEN purchase_lead BETWEEN 181 AND 365 THEN '181-365 days'
    ELSE 'more than 365 days'
END;

SELECT *
FROM customer_booking;

-- Classify length_of_stay into different time ranges
SELECT length_of_stay,
CASE
	WHEN length_of_stay <= 7 THEN 'up to 7 days'
    WHEN length_of_stay BETWEEN 8 AND 30 THEN '8-30 days'
    WHEN length_of_stay BETWEEN 31 AND 90 THEN '31-90 days'
    WHEN length_of_stay BETWEEN 91 AND 180 THEN '91-180 days'
    WHEN length_of_stay BETWEEN 181 AND 365 THEN '181-365 days'
    ELSE 'more than 365 days'
END AS length_of_stay_range
FROM customer_booking;

-- Add and populate a new column for length_of_stay range
ALTER TABLE customer_booking 
ADD COLUMN length_of_stay_range VARCHAR(255);

UPDATE customer_booking
SET length_of_stay_range = CASE
	WHEN length_of_stay <= 7 THEN 'up to 7 days'
    WHEN length_of_stay BETWEEN 8 AND 30 THEN '8-30 days'
    WHEN length_of_stay BETWEEN 31 AND 90 THEN '31-90 days'
    WHEN length_of_stay BETWEEN 91 AND 180 THEN '91-180 days'
    WHEN length_of_stay BETWEEN 181 AND 365 THEN '181-365 days'
    ELSE 'more than 365 days'
END;

SELECT *
FROM customer_booking;

-- Extract origin and destination codes from the route
SELECT route, substring(route, 1, 3) AS origin, substring(route, 4, 3) AS destination
FROM customer_booking;

-- Add and populate a new column for origin codes
ALTER TABLE customer_booking 
ADD COLUMN origin_code VARCHAR(255);

UPDATE customer_booking
SET origin_code = substring(route, 1, 3);

SELECT route, origin_code
FROM customer_booking;

-- Add and populate a new column for destination codes
ALTER TABLE customer_booking 
ADD COLUMN destination_code VARCHAR(255);

UPDATE customer_booking
SET destination_code = substring(route, 4, 3);

SELECT route, origin_code, destination_code
FROM customer_booking;

SELECT *
FROM customer_booking;

-- Retrieve all data from airports table
SELECT *
FROM airports;

-- Replace commas with dots for proper decimal formatting in Latitude and Longitude columns
UPDATE airports
SET Latitude = REPLACE(Latitude, ',', '.');

UPDATE airports
SET Longitude = REPLACE(Longitude, ',', '.');

-- Change Latitude and Longitude columns to decimal format
ALTER TABLE airports
MODIFY COLUMN Latitude DECIMAL(10,3);

ALTER TABLE airports
MODIFY COLUMN Longitude DECIMAL(10,3);

-- Join customer_booking with airports to get location details for origin
SELECT customer_booking.origin_code, airports.country, airports.city, airports.Latitude, airports.Longitude
FROM customer_booking
LEFT JOIN airports
ON customer_booking.origin_code = airports.code;

-- Add and populate new columns for origin location details
ALTER TABLE customer_booking
ADD COLUMN country VARCHAR(255),
ADD COLUMN city VARCHAR(255),
ADD COLUMN Latitude DECIMAL(10,3),
ADD COLUMN Longitude DECIMAL(10,3);

UPDATE customer_booking
LEFT JOIN airports ON customer_booking.origin_code = airports.code
SET customer_booking.country = airports.country,
    customer_booking.city = airports.city,
    customer_booking.Latitude = airports.Latitude,
    customer_booking.Longitude = airports.Longitude;
    
SELECT *
FROM customer_booking;

-- Rename the origin location columns for clarity
ALTER TABLE customer_booking
RENAME COLUMN country TO origin_country,
RENAME COLUMN city TO origin_city,
RENAME COLUMN Latitude TO origin_latitude,
RENAME COLUMN Longitude TO origin_longitude;

-- Join customer_booking with airports to get location details for destination
SELECT customer_booking.destination_code, airports.country, airports.city, airports.Latitude, airports.Longitude
FROM customer_booking
LEFT JOIN airports
ON customer_booking.destination_code = airports.code;

-- Add and populate new columns for destination location details
ALTER TABLE customer_booking
ADD COLUMN destination_country VARCHAR(255),
ADD COLUMN destination_city VARCHAR(255),
ADD COLUMN destination_latitude DECIMAL(10,3),
ADD COLUMN destination_longitude DECIMAL(10,3);

UPDATE customer_booking
LEFT JOIN airports ON customer_booking.destination_code = airports.code
SET customer_booking.destination_country = airports.country,
    customer_booking.destination_city = airports.city,
    customer_booking.destination_latitude = airports.Latitude,
    customer_booking.destination_longitude = airports.Longitude;

SELECT *
FROM customer_booking;

-- Add and populate a new column to combine origin and destination country into a route
ALTER TABLE customer_booking
ADD COLUMN origin_destination VARCHAR(511);

UPDATE customer_booking
SET origin_destination = CONCAT(origin_country, '->', destination_country);

SELECT *
FROM customer_booking;

-- Create views for future use in Python
CREATE VIEW count_of_flight_day AS
SELECT flight_day, COUNT(flight_day) AS count_of_flight_day
FROM customer_booking
GROUP BY flight_day;

CREATE VIEW count_of_sales_channel AS
SELECT sales_channel, COUNT(sales_channel) AS count_of_sales_channel
FROM customer_booking
GROUP BY sales_channel;

CREATE VIEW count_of_trip_type AS
SELECT trip_type, COUNT(trip_type) AS count_of_trip_type
FROM customer_booking
GROUP BY trip_type;

CREATE VIEW count_of_purchase_lead_range AS
SELECT purchase_lead_range, COUNT(purchase_lead_range) AS count_of_purchase_lead_range
FROM customer_booking
GROUP BY purchase_lead_range
ORDER BY
	CASE purchase_lead_range
		WHEN 'up to 7 days' THEN 1
        WHEN '8-30 days' THEN 2
		WHEN '31-90 days' THEN 3
        WHEN '91-180 days' THEN 4
        WHEN '181-365 days' THEN 5
        ELSE 6
	END;

CREATE VIEW count_of_length_of_stay_range AS
SELECT length_of_stay_range, COUNT(length_of_stay_range) AS count_of_length_of_stay_range
FROM customer_booking
GROUP BY length_of_stay_range
ORDER BY
	CASE length_of_stay_range
		WHEN 'up to 7 days' THEN 1
        WHEN '8-30 days' THEN 2
		WHEN '31-90 days' THEN 3
        WHEN '91-180 days' THEN 4
        WHEN '181-365 days' THEN 5
        ELSE 6
	END;

CREATE VIEW count_of_wants_extra_baggage AS
SELECT wants_extra_baggage, COUNT(wants_extra_baggage) AS count_of_wants_extra_baggage
FROM customer_booking
GROUP BY wants_extra_baggage;

CREATE VIEW count_of_wants_in_flight_meals AS
SELECT wants_in_flight_meals, COUNT(wants_in_flight_meals) AS count_of_wants_in_flight_meals
FROM customer_booking
GROUP BY wants_in_flight_meals;

CREATE VIEW count_of_wants_preferred_seat AS
SELECT wants_preferred_seat, COUNT(wants_preferred_seat) AS count_of_wants_preferred_seat
FROM customer_booking
GROUP BY wants_preferred_seat;

CREATE VIEW count_of_origin_country AS
SELECT origin_country, COUNT(origin_country) AS count_of_origin_country
FROM customer_booking
GROUP BY origin_country
ORDER BY count_of_origin_country DESC;

CREATE VIEW count_of_destination_country AS
SELECT destination_country, COUNT(destination_country) AS count_of_destination_country
FROM customer_booking
GROUP BY destination_country
ORDER BY count_of_destination_country DESC;

CREATE VIEW count_of_origin_place AS
SELECT origin_country, origin_city, COUNT(origin_country) AS count_of_origin_place
FROM customer_booking
GROUP BY origin_country, origin_city
ORDER BY count_of_origin_place DESC;

CREATE VIEW count_of_destination_place AS
SELECT destination_country, destination_city, COUNT(destination_country) AS count_of_destination_place
FROM customer_booking
GROUP BY destination_country, destination_city
ORDER BY count_of_destination_place DESC;

CREATE VIEW count_of_route AS
SELECT origin_destination, COUNT(origin_destination) AS count_of_route
FROM customer_booking
GROUP BY origin_destination
ORDER BY count_of_route DESC;
