SELECT * FROM [dbo].[athlete_events]
SELECT * FROM [dbo].[noc_regions]--NOC, region, notes


--1. How many olympics games have been held?
SELECT COUNT(DISTINCT Games)
FROM [dbo].[athlete_events]

--2. List down all Olympics games held so far.
SELECT DISTINCT year, season, city
FROM [dbo].[athlete_events]
ORDER BY year

--3. Mention the total no of nations who participated in each olympics game?
with all_info as (
	SELECT games, nr.region
	FROM [dbo].[athlete_events] ae JOIN [dbo].[noc_regions] nr on ae.NOC = nr.NOC
	GROUP BY games, nr.region
)

SELECT games, COUNT(region) as nat_count
FROM all_info
GROUP BY games
ORDER BY nat_count 

--4. Which year saw the highest and lowest no of countries participating in olympics
with all_info as (
	SELECT games, nr.region
	FROM [dbo].[athlete_events] ae JOIN [dbo].[noc_regions] nr on ae.NOC = nr.NOC
	GROUP BY games, nr.region
), total_countries as (
	SELECT games, COUNT(region) as tot_count
	FROM all_info
	GROUP BY games
), max_total as (
	SELECT games, tot_count
	FROM total_countries
	WHERE tot_count = (SELECT MAX(tot_count) FROM total_countries)
), min_total as (
	SELECT games, tot_count
	FROM total_countries
	WHERE tot_count = (SELECT MIN(tot_count) FROM total_countries)
)

--SELECT concat((SELECT games FROM min_total), ' - ', (SELECT tot_count FROM min_total)) as Lowest_Countries,
--concat((SELECT games FROM max_total), ' - ', (SELECT tot_count FROM max_total)) as Highest_Countries
--FROM max_total, min_total

--5. Which nation has participated in all of the olympic games
SELECT nr.region, COUNT(DISTINCT games) as total_participated_games
FROM [dbo].[athlete_events] ae JOIN [dbo].[noc_regions] nr on ae.NOC = nr.NOC
GROUP BY nr.region
HAVING COUNT(DISTINCT games) = (SELECT Count(DISTINCT games) FROM [dbo].[athlete_events])


--6. Identify the sport which was played in all summer olympics.
SELECT Sport, COUNT(DISTINCT Year) as no_of_games
FROM [dbo].[athlete_events]
WHERE Season = 'Summer'
GROUP BY Sport
HAVING COUNT(DISTINCT Year) = (SELECT COUNT(DISTINCT Year) as summer_games FROM [dbo].[athlete_events] WHERE Season = 'Summer')

--7. Which Sports were just played only once in the olympics.
WITH t1 as (
	SELECT Sport, COUNT(distinct Year) as no_of_games
	FROM [dbo].[athlete_events]
	GROUP BY Sport
	HAVING COUNT(distinct Year) = 1
)

SELECT DISTINCT t1.Sport, no_of_games, games
FROM [dbo].[athlete_events] t2 JOIN t1 on t1.Sport = t2.Sport
