/*
************************************************************************************************************

Title: Analysing Cyclistic Bike Trip Data Using SQL Queries
Author: Yusri Jamain
Create Date: 12/6/2023

************************************************************************************************************
*/


/* Total of bike trip from May 2022 to April 2023 */

-- Overall total of bike trip = 5,616,010 Trips

SELECT
	COUNT(*) AS total_trip
FROM 
	aggregated_tripdata

-- Total trip difference between casual and member: Member = 3,353,334, Casual = 2,262,676

SELECT
	member_casual, 
	COUNT(*) AS total_trips,
	ROUND(COUNT(*) * 100.0 / sum(count(*)) Over(), 1) as 'percentage'
FROM
	aggregated_tripdata
GROUP BY
	member_casual


	
/* Bike preference between member and casual */

-- Overall bike preference
-- Member: Classic Bike = 1,689,277 (30%), Electric Bike = 1,664,057 (29%)
-- Casual: Classic Bike = 1,022,999 (18%), Electric Bike = 1,239,677 (22%)

SELECT
	member_casual,
	rideable_type,
	COUNT(*) AS total_trips,
	ROUND(COUNT(*) * 100 / SUM(COUNT(*)) OVER (), 1) AS percentage
FROM 
	aggregated_tripdata
GROUP BY
	member_casual,
	rideable_type
ORDER BY
	COUNT (*) DESC

-- Percentage for member: classic_bike = 50.4%, electric_bike = 49.6%

SELECT
	member_casual,
	rideable_type,
	ROUND(COUNT(*) * 100.0 / SUM(COUNT(*)) OVER(), 1) as percentage
FROM
	aggregated_tripdata
WHERE
	member_casual = 'member'
GROUP BY
	member_casual,
	rideable_type

-- Percentage for casual: classic_bike = 45.2%, electric_bike 54.8%

SELECT
	member_casual,
	rideable_type,
	ROUND(COUNT(*) * 100.0 / SUM(COUNT(*)) OVER(), 1) as percentage
FROM
	aggregated_tripdata
WHERE
	member_casual = 'casual'
GROUP BY
	member_casual,
	rideable_type



/* Total of bike trip per hour, per day and per month */

-- (MODE) Total of bike trips per hour between 'member' and 'casual'

SELECT 
	member_casual, 
	DATEPART(HOUR, started_at) AS time_of_trip, 
	COUNT(*) as num_of_trips
FROM 
	aggregated_tripdata
GROUP BY 
	member_casual,
	DATEPART(HOUR, started_at)
ORDER BY
	member_casual,
	COUNT(*) desc

-- (MODE) Total of bike trips per day between 'member' and 'casual'

SELECT
	member_casual,
	day_of_trip,
	COUNT(*) AS total_trip
FROM 
	aggregated_tripdata
GROUP BY
	member_casual,
	day_of_trip
ORDER BY
	member_casual,
	total_trip DESC

-- (MODE) Total of bike trips per month between 'member' and 'casual'

SELECT
	member_casual,
	month_of_trip,
	COUNT(*) AS total_trip
FROM 
	aggregated_tripdata
GROUP BY
	member_casual,
	month_of_trip
ORDER BY
	member_casual,
	total_trip DESC



/* Mean, max, min of ride_length */

-- Overall mean, max, min of ride_length between 'member' and 'casual'

SELECT
	member_casual,
	CAST(CAST(AVG(CAST(CAST(ride_length AS datetime) as float)) as datetime) as time(0)) AS avg_ride_length,
	CAST(CAST(MAX(CAST(CAST(ride_length AS datetime) as float)) as datetime) as time(0)) AS max_ride_length,
	CAST(CAST(MIN(CAST(CAST(ride_length AS datetime) as float)) as datetime) as time(0)) AS min_ride_length
FROM 
	aggregated_tripdata
GROUP BY
	member_casual

-- Mean, max, mid of ride_length PER HOUR between 'member' and 'casual'

SELECT
	member_casual,
	DATEPART(HOUR, started_at) AS time_of_trip,
	CAST(CAST(AVG(CAST(CAST(ride_length AS datetime) as float)) as datetime) as time(0)) AS avg_ride_length,
	CAST(CAST(MAX(CAST(CAST(ride_length AS datetime) as float)) as datetime) as time(0)) AS max_ride_length,
	CAST(CAST(MIN(CAST(CAST(ride_length AS datetime) as float)) as datetime) as time(0)) AS min_ride_length
FROM 
	aggregated_tripdata
GROUP BY
	member_casual,
	DATEPART(HOUR, started_at)
ORDER BY
	member_casual,
	DATEPART(HOUR, started_at)

-- Mean, max, min of ride_length PER DAY between 'member' and 'casual'

SELECT
	member_casual,
	day_of_trip,
	CAST(CAST(AVG(CAST(CAST(ride_length AS datetime) as float)) as datetime) as time(0)) AS avg_ride_length,
	CAST(CAST(MAX(CAST(CAST(ride_length AS datetime) as float)) as datetime) as time(0)) AS max_ride_length,
	CAST(CAST(MIN(CAST(CAST(ride_length AS datetime) as float)) as datetime) as time(0)) AS min_ride_length
FROM 
	aggregated_tripdata
GROUP BY
	member_casual,
	day_of_trip
ORDER BY
	member_casual,
	avg_ride_length DESC

-- Mean, max, min of ride_length PER MONTH between 'member' and 'casual'

SELECT
	member_casual,
	month_of_trip,
	CAST(CAST(AVG(CAST(CAST(ride_length AS datetime) as float)) as datetime) as time(0)) AS avg_ride_length,
	CAST(CAST(MAX(CAST(CAST(ride_length AS datetime) as float)) as datetime) as time(0)) AS max_ride_length,
	CAST(CAST(MIN(CAST(CAST(ride_length AS datetime) as float)) as datetime) as time(0)) AS min_ride_length
FROM 
	aggregated_tripdata
GROUP BY
	member_casual,
	month_of_trip
ORDER BY
	member_casual,
	avg_ride_length DESC



/* Start and end stations member vs casual */

-- Top 10 start and end stations for 'member'

SELECT
	TOP 10 start_station_name,
	COUNT(*) AS num_of_trip
FROM 
	aggregated_tripdata
WHERE
	member_casual = 'member'
	AND start_station_name IS NOT NULL
GROUP BY
	start_station_name
ORDER BY
	num_of_trip DESC

SELECT
	TOP 10 end_station_name,
	COUNT(*) AS num_of_trip
FROM 
	aggregated_tripdata
WHERE
	member_casual = 'member'
	AND end_station_name IS NOT NULL
GROUP BY
	end_station_name
ORDER BY
	num_of_trip DESC


-- Top 10 start and end stations for 'casual'

SELECT
	TOP 10 start_station_name,
	COUNT(*) AS num_of_trip
FROM 
	aggregated_tripdata
WHERE
	member_casual = 'casual'
	AND start_station_name IS NOT NULL
GROUP BY
	start_station_name
ORDER BY
	num_of_trip DESC

SELECT
	TOP 10 end_station_name,
	COUNT(*) AS num_of_trip
FROM 
	aggregated_tripdata
WHERE
	member_casual = 'casual'
	AND end_station_name IS NOT NULL
GROUP BY
	end_station_name
ORDER BY
	num_of_trip DESC
