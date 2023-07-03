
/*
************************************************************************************************************

Title: Cleaning Cyclistic Bike Trip Data Using SQL Queries
Author: Yusri Jamain
Create Date: 10/6/2023

************************************************************************************************************
*/


/******************************* COMBINING THE DATASETS INTO A SINGLE TABLE *******************************/

/* 
Aggregating all the 12 months CSV files into a single table
- NOTE: Some of the large files were split into two parts e.g. oct22_tripdata_1, oct22_tripdata_2
- UNION ALL were used rather than UNION to combine all the data without removing any duplicates as the latter will only return unique values
- The aggregated table contains Cyclistic bike trip data combined from May 2022 to April 2023
*/

SELECT * INTO aggregated_tripdata
FROM (
  SELECT * FROM cyclistic_bike_tripdata.dbo.apr23_tripdata
    UNION ALL
  SELECT * FROM cyclistic_bike_tripdata.dbo.mar23_tripdata
    UNION ALL
  SELECT * FROM cyclistic_bike_tripdata.dbo.feb23_tripdata
    UNION ALL
  SELECT * FROM cyclistic_bike_tripdata.dbo.jan23_tripdata
    UNION ALL
  SELECT * FROM cyclistic_bike_tripdata.dbo.dec22_tripdata
    UNION ALL
  SELECT * FROM cyclistic_bike_tripdata.dbo.nov22_tripdata
    UNION ALL
  SELECT * FROM cyclistic_bike_tripdata.dbo.oct22_tripdata_1
    UNION ALL
  SELECT * FROM cyclistic_bike_tripdata.dbo.oct22_tripdata_2
    UNION ALL
  SELECT * FROM cyclistic_bike_tripdata.dbo.sep22_tripdata_1
    UNION ALL
  SELECT * FROM cyclistic_bike_tripdata.dbo.sep22_tripdata_2
    UNION ALL
  SELECT * FROM cyclistic_bike_tripdata.dbo.aug22_tripdata_1
    UNION ALL
  SELECT * FROM cyclistic_bike_tripdata.dbo.aug22_tripdata_2
    UNION ALL
  SELECT * FROM cyclistic_bike_tripdata.dbo.jul22_tripdata_1
    UNION ALL
  SELECT * FROM cyclistic_bike_tripdata.dbo.jul22_tripdata_2
    UNION ALL
  SELECT * FROM cyclistic_bike_tripdata.dbo.jun22_tripdata_1
    UNION ALL
  SELECT * FROM cyclistic_bike_tripdata.dbo.jun22_tripdata_2
    UNION ALL
  SELECT * FROM cyclistic_bike_tripdata.dbo.may22_tripdata_1
    UNION ALL
  SELECT * FROM cyclistic_bike_tripdata.dbo.may22_tripdata_2
  ) AS table_1

-- View the combined data

SELECT *
FROM
  aggregated_tripdata

/* RESULT:
- The query returns 5,858,961 rows which are similar to the total of all CSVs combined
- The query returns 16 columns which are similar to the total of columns in the CSVs
*/



/****************************************** FORMATTING THE DATA *******************************************/


-- Altering format for started_at, ended_at, ride_length

ALTER TABLE aggregated_tripdata
ALTER COLUMN started_at DATETIME2(0)

ALTER TABLE aggregated_tripdata
ALTER COLUMN ended_at DATETIME2(0)

ALTER TABLE aggregated_tripdata
ALTER COLUMN ride_length TIME(0)

-- Altering format for start_lat, start_lng, end_lat, end_lng

ALTER TABLE aggregated_tripdata
ALTER COLUMN start_lat DECIMAL(9,6)

ALTER TABLE aggregated_tripdata
ALTER COLUMN start_lng DECIMAL(9,6)

ALTER TABLE aggregated_tripdata
ALTER COLUMN end_lat DECIMAL(9,6)

ALTER TABLE aggregated_tripdata
ALTER COLUMN end_lng DECIMAL(9,6)



/***************************** EXPLORING AND CLEANING THE DATA USING QUERIES ******************************/

/*-------------
    Ride_id 
--------------*/

/*	Exploring the data	*/

-- To find any trailing or leading spaces in the column using wildcard operator (%) and trim function, none were found
-- The former shows there are no data, while the later results in similar total of data: not_trimmed = 5858961, trimmed = 5858961

SELECT
  ride_id
FROM
  aggregated_tripdata
WHERE
  ride_id LIKE '% %'

SELECT 
  COUNT(ride_id) AS not_trimmed,
  COUNT(TRIM(ride_id)) AS trimmed
FROM
  aggregated_tripdata

-- Check whether there are ride_ids that exceed the 16 characters limit

SELECT
  LEN(ride_id) AS no_of_character,
  COUNT(*) AS count_of_ride_id
FROM 
  aggregated_tripdata
WHERE
  LEN(ride_id) <> 16
GROUP BY
  LEN(ride_id)

-- Check whether the exceeded ride_ids contain both numbers and alphabets, result shows it only contain numbers with irregular amount of zeros

SELECT 
  ride_id
FROM
  aggregated_tripdata
WHERE
  LEN(ride_id) <> 16

-- Check for duplicates of ride_id that have 16 characters: The count results shows similar number (5855066) hence no duplicates were found

SELECT 
  COUNT(ride_id) AS count_ride_id,
  COUNT(DISTINCT ride_id) AS distinct_ride_id
FROM
  aggregated_tripdata
WHERE
  LEN(ride_id) = 16

-- Count the total number of ride_id that have errors: Total exceed = 3895

SELECT
  COUNT(ride_id) AS error_ride_id
FROM
  aggregated_tripdata
WHERE
  LEN(ride_id) <> 16

/* FINDINGS: ---------------------------------------------------------------------------------
1. No trailing or leading spaces and duplicates for ride_id that have 16 alphanumeric characters 
2. Hence, only ride_ids that exceed 16 characters will be cleaned 
---------------------------------------------------------------------------------------------*/

/*	Cleaning the data	*/

-- Remove error ride_ids from the aggregated table (Total = 3895 rows)

DELETE
FROM
  aggregated_tripdata
WHERE
  LEN(ride_id) <> 16


/*-------------------
    Rideable_type
--------------------*/

/*	Exploring the data	*/

-- This query checks the whether there are other type of bikes rather than 'electric_bike', 'docked_bike' and 'classic_bike'
-- This query also checks the total number of 'docked_bike' that needs to be merged with 'classic_bike': Total of docked_bike = 170401

SELECT
  DISTINCT rideable_type,
  COUNT(*) AS no_of_bike
FROM
  aggregated_tripdata
GROUP BY
  rideable_type

/*	Cleaning the data	*/

-- This query replaces all of the instances of 'docked_bike' to 'classic_bike'
-- A total of 170401 rows were affected which is equal to the total number of 'docked_bike'

UPDATE aggregated_tripdata
SET rideable_type = 'classic_bike'
WHERE rideable_type = 'docked_bike'


/*---------------------------------------------
    Started_at, Ended_at and Ride_length
----------------------------------------------*/

/*	Exploring the data	*/

-- This query will check for the total of trips that are lesser than 1 minute or longer than a day: Total = 134563

SELECT
  COUNT(ride_length) AS error_ride_length
FROM
  aggregated_tripdata
WHERE
  ride_length < '00:01:00' 
  OR ride_length > '23:59:59'

/*	Cleaning the data	*/

-- This query will delete 134563 rows with ride_length that does not meet the requirements (< 1 minute or > 1 day)

DELETE
FROM
  aggregated_tripdata
WHERE
  ride_length < '00:01:00' 
  OR ride_length > '23:59:59'


/*------------------------------------------------------------------------------
    Start_station_name, end_station_name, start_station_id, end_station_id
-------------------------------------------------------------------------------*/

/*	Exploring the data	*/

-- Check for any errors in name and id for both start and end station
-- Multiple errors were found which will be described in the findings section below

SELECT
  DISTINCT start_station_name,
  start_station_id
FROM 
  aggregated_tripdata
ORDER BY
  start_station_name

SELECT
  DISTINCT end_station_name,
  end_station_id
FROM 
  aggregated_tripdata
ORDER BY
  end_station_name

-- To check whether there are any trailing or leading spaces present in start_station_name and end_station_name column
-- Both queries show similar result between trimmed and not_trimmed hence no trailing or leading spaces present

SELECT
  COUNT(TRIM(start_station_name)) AS trimmed,
  COUNT(start_station_name) AS not_trimmed
FROM
  aggregated_tripdata

SELECT
  COUNT(TRIM(end_station_name)) AS trimmed,
  COUNT(end_station_name) AS not_trimmed
FROM
  aggregated_tripdata

-- This query checks for 'classic_bike' trips that either have nulls or whitespaces in start or end station name
-- The result shows that only end_station_name contain nulls for 'classic_bike' trips

SELECT 
  COUNT(*)
FROM
  aggregated_tripdata
WHERE
  rideable_type = 'classic_bike'
  AND (start_station_name IS NULL
    OR end_station_name IS NULL
    OR LEN(start_station_name) = 0
    OR LEN(end_station_name) = 0)

/* FINDINGS: ------------------------------------------------------------------------
1. There are multiple test or warehouse stations found that need to be removed:
  - 'WEST CHI-WATSON', 'WestChi', 'Base - 2132 W Hubbard', 'Base - 2132 W Hubbard Warehouse'
2. There are multiple stations that contain asterisk(*) in its name which refer to charging stations that need to be removed
  - Note: The charging stations are labeled as 'chargingstx' in the station_id columns
3. There are multiple stations that contain '(Temp)' that need to be cleaned
4. There are multiple stations that contain 'Vaccination Site' that need to be cleaned
5. There are nulls found in end_station_name for 'classic_bike' that need to be removed
----------------------------------------------------------------------------------- */ 

/*	Cleaning the data	*/

-- 1. Remove test and warehouse stations:
  -- 'WEST CHI-WATSON', 'WestChi', 'Base - 2132 W Hubbard' and 'Base - 2132 W Hubbard Warehouse'

-- Double checking the rows that will be deleted using the SELECT * statement: Total = 1711 rows

SELECT *
FROM
  aggregated_tripdata
WHERE
  start_station_name LIKE '%WEST CHI-WATSON%' 
  OR start_station_name LIKE '%WestChi%' 
  OR start_station_name LIKE '%Base%'
  OR end_station_name LIKE '%WEST CHI-WATSON%' 
  OR end_station_name LIKE '%WestChi%' 
  OR end_station_name LIKE '%Base%'

-- Removing rows that contain test or warehouse station using DELETE statement

DELETE
FROM
  aggregated_tripdata
WHERE
  start_station_name LIKE '%WEST CHI-WATSON%' 
  OR start_station_name LIKE '%WestChi%' 
  OR start_station_name LIKE '%Base%'
  OR end_station_name LIKE '%WEST CHI-WATSON%' 
  OR end_station_name LIKE '%WestChi%' 
  OR end_station_name LIKE '%Base%'

-- 2. Remove charging stations that were identified by the asterisk (*) sign in its name and 'chargingstx' in station_id

-- Using % Wildcard on '*' and 'charging' to certify the total number of charging stations exist in the data
-- Both queries showed similar total = 86170 charging stations found
-- Using SELECT * statement to double check the rows that will be deleted: Total = 86170

SELECT *
FROM 
  aggregated_tripdata
WHERE 
  start_station_name LIKE '%*%' OR end_station_name LIKE '%*%'

SELECT *
FROM 
  aggregated_tripdata
WHERE 
  start_station_id LIKE '%charging%' OR end_station_id LIKE '%charging%'

-- Removing charging stations from the bike trip data using DELETE statement

DELETE
FROM 
  aggregated_tripdata
WHERE
  start_station_name LIKE '%*%' OR end_station_name LIKE '%*%'

-- 3. Cleaning the stations that contain '(Temp)'

-- Removing '(Temp)' from start and end station names using UPDATE, TRIM, REPLACE statement, LIKE and % Wildcard operator

UPDATE aggregated_tripdata 
SET start_station_name = TRIM(REPLACE(start_station_name, '(Temp)', '')) 
WHERE start_station_name LIKE '%(Temp)%'

UPDATE aggregated_tripdata 
SET end_station_name = TRIM(REPLACE(end_station_name, '(Temp)', '')) 
WHERE end_station_name LIKE '%(Temp)%'

-- 4. Cleaning station names that contain 'Vaccination Site'

-- Removing 'Vaccination Site' from start and end station names using UPDATE, TRIM, REPLACE statement, LIKE and % Wildcard operator

UPDATE aggregated_tripdata 
SET start_station_name = TRIM(REPLACE(start_station_name, 'Vaccination Site', '')) 
WHERE start_station_name LIKE '%Vaccination Site%'

UPDATE aggregated_tripdata 
SET end_station_name = TRIM(REPLACE(end_station_name, 'Vaccination Site', '')) 
WHERE end_station_name LIKE '%Vaccination Site%'

-- 5. Removing 'classic_bike' trips data contain nulls in end_station_name

-- Double check the 'classic_bike' trips that need to be removed using AND and IS NULL operator: Total = 6047

SELECT * 
FROM
  aggregated_tripdata 
WHERE 
  rideable_type = 'classic_bike' AND end_station_name IS NULL

-- Removing null stations for 'classic_bike' using DELETE statement

DELETE
FROM
  aggregated_tripdata
WHERE
  rideable_type = 'classic_bike' AND end_station_name IS NULL


/*------------------------------------------------
    Start_lat, start_lng, end_lat, end_lng
-------------------------------------------------*/

/*	Exploring the data	*/

-- Check for nulls in start_lat, start_lng, end_lat, end_lng: Total = 10565 rows to be removed

SELECT *
FROM
  aggregated_tripdata
WHERE
  start_lat IS NULL
  OR start_lng IS NULL
  OR end_lat IS NULL
  OR end_lng IS NULL

/*	Cleaning the data	*/

-- Remove bike trips with nulls in either start_lat, start_lng, end_lat, end_lng using DELETE statement and OR operator

DELETE
FROM
  aggregated_tripdata
WHERE
  start_lat IS NULL
  OR start_lng IS NULL
  OR end_lat IS NULL
  OR end_lng IS NULL


/*---------------------
    Member_casual
----------------------*/

/*	Exploring the data	*/

-- Check for membership types and make sure there are only two categories: member or casual
-- The query result shows there are only two types with no trailing or leading spaces present
-- Therefore, there is no cleaning necessary

SELECT
  DISTINCT member_casual
FROM
  aggregated_tripdata
