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

SELECT concat((SELECT games FROM min_total), ' - ', (SELECT tot_count FROM min_total)) as Lowest_Countries,
concat((SELECT games FROM max_total), ' - ', (SELECT tot_count FROM max_total)) as Highest_Countries
FROM max_total, min_total

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

--8. Fetch the total no of sports played in each olympic games.
SELECT Games, COUNT(DISTINCT Sport) as no_of_sports
FROM [dbo].[athlete_events]
GROUP BY Games
ORDER BY no_of_sports desc

--9. Fetch oldest athletes to win a gold medal
WITH t1 as(
SELECT name, sex, age, team, games, city, sport, event, medal,
	case
	WHEN age = 'NA' THEN 0
	else age
	end as new_age
FROM [dbo].[athlete_events]
WHERE Medal = 'gold'
)

SELECT name, sex, new_age, team, games, city, sport, event, medal
FROM t1
WHERE new_age = (SELECT MAX(new_age) FROM t1)

--10. Find the Ratio of male and female athletes participated in all olympic games.
with t1 as (
SELECT sex, COUNT(name) as cn
FROM [dbo].[athlete_events]
GROUP BY sex
)

SELECT concat('1 :', round(cast(MAX(cn) as decimal)/MIN(cn), 2)) as ratio 
FROM t1

--11. Fetch the top 5 athletes who have won the most gold medals
with t1 as (
	SELECT name, team, COUNT(medal) as total_gold_medals
	FROM [dbo].[athlete_events]
	WHERE  medal = 'Gold'
	GROUP BY name, team, sport
), t2 as (
	SELECT name, team, total_gold_medals, DENSE_RANK() OVER (order by total_gold_medals desc) as rnk
	FROM t1	
)
 SELECT name, team, total_gold_medals
 FROM t2
 WHERE rnk <=5 

 --12. Fetch the top 5 athletes who have won the most medals (gold/silver/bronze).
 with t1 as (
	SELECT name, team, COUNT(medal) as total_gold_medals
	FROM [dbo].[athlete_events]
	WHERE  medal in ('Gold', 'Silver', 'Bronze')
	GROUP BY name, team
), t2 as (
	SELECT name, team, total_gold_medals, DENSE_RANK() OVER (order by total_gold_medals desc) as rnk
	FROM t1	
)
 SELECT name, team, total_gold_medals
 FROM t2
 WHERE rnk <=5 

 --13. Fetch the top 5 most successful countries in olympics. Success is defined by no of medals won.
 with t1 as (
	 SELECT region, COUNT(medal) as total_medals
	 FROM [dbo].[athlete_events] a JOIN [dbo].[noc_regions] b on a.noc = b.noc
	 WHERE medal in ('Gold', 'Silver', 'Bronze')
	 GROUP BY region 
 ), t2 as (
 SELECT region, total_medals, DENSE_RANK() OVER (order by total_medals desc) as rnk
 FROM t1
 )

 SELECT region, total_medals, rnk
 FROM t2
 WHERE rnk <= 5

 --14. List down total gold, silver and bronze medals won by each country.

SELECT country, coalesce(gold, 0) as gold
    	, coalesce(silver, 0) as silver
    	, coalesce(bronze, 0) as bronze
FROM (SELECT nr.region as country, medal, count(1) as total_medals
FROM [dbo].[athlete_events] oh
JOIN [dbo].[noc_regions] nr ON nr.noc = oh.noc
where medal <> 'NA'
GROUP BY nr.region,medal) as result
PIVOT (
	SUM([total_medals])
	FOR [medal]
	IN ([Bronze], [Silver], [Gold])
) as pivot_table
ORDER BY gold desc, silver desc, bronze desc


--15. List down total gold, silver and bronze medals won by each country corresponding to each olympic games.
SELECT country, coalesce(gold, 0) as gold, coalesce(silver, 0) as silver, coalesce(bronze, 0) as bronze
FROM (
SELECT games, nr.region as country, medal, count(medal) as total_medals 
FROM [dbo].[athlete_events] oh JOIN [dbo].[noc_regions] nr on oh.noc = nr.noc
WHERE medal <> 'NA'
GROUP BY games, nr.region, medal) as result
PIVOT (
SUM([total_medals])
FOR [medal]
IN ([Bronze], [Silver], [Gold])
) as pivot_table
ORDER BY games



--16. Identify which country won the most gold, most silver and most bronze medals in each olympic games.
with t1 as (
SELECT substring(games, 1, CHARINDEX(' - ', games) - 1) as games, substring(games, CHARINDEX(' - ', games) + 3, 50) as country,
             coalesce(gold, 0) as gold
            , coalesce(silver, 0) as silver
            , coalesce(bronze, 0) as bronze
FROM (
SELECT concat(games, ' - ', nr.region) as games, medal, count(1) as total_medals 
FROM [dbo].[athlete_events] oh JOIN [dbo].[noc_regions] nr on oh.noc = nr.noc
WHERE medal <> 'NA'
GROUP BY games, nr.region, medal) as result
PIVOT (
SUM([total_medals])
FOR [medal]
IN ([Bronze], [Silver], [Gold])
) as pivot_table
)

select distinct games
    	, concat(first_value(country) over(partition by games order by gold desc)
    			, ' - '
    			, first_value(gold) over(partition by games order by gold desc)) as Max_Gold
    	, concat(first_value(country) over(partition by games order by silver desc)
    			, ' - '
    			, first_value(silver) over(partition by games order by silver desc)) as Max_Silver
    	, concat(first_value(country) over(partition by games order by bronze desc)
    			, ' - '
    			, first_value(bronze) over(partition by games order by bronze desc)) as Max_Bronze
from t1
order by games

--17. Identify which country won the most gold, most silver, most bronze medals and the most medals in each olympic games.
with t1 as (
SELECT substring(games, 1, CHARINDEX(' - ', games) - 1) as games, substring(games, CHARINDEX(' - ', games) + 3, 50) as country,
             coalesce(gold, 0) as gold
            , coalesce(silver, 0) as silver
            , coalesce(bronze, 0) as bronze
FROM (
SELECT concat(games, ' - ', nr.region) as games, medal, count(1) as total_medals 
FROM [dbo].[athlete_events] oh JOIN [dbo].[noc_regions] nr on oh.noc = nr.noc
WHERE medal <> 'NA'
GROUP BY games, nr.region, medal) as result
PIVOT (
SUM([total_medals])
FOR [medal]
IN ([Bronze], [Silver], [Gold])
) as pivot_table
), t2 as (
SELECT games, nr.region as country, count(1) as total_medals
FROM [dbo].[athlete_events] oh
JOIN [dbo].[noc_regions] nr ON nr.noc = oh.noc
WHERE medal <> 'NA'
GROUP BY games, nr.region 
)

SELECT DISTINCT t1.games,  concat(first_value(t1.country) over(partition by t1.games order by gold desc)
    			, ' - '
    			, first_value(gold) over(partition by t1.games order by gold desc)) as Max_Gold
    	, concat(first_value(t1.country) over(partition by t1.games order by silver desc)
    			, ' - '
    			, first_value(silver) over(partition by t1.games order by silver desc)) as Max_Silver
    	, concat(first_value(t1.country) over(partition by t1.games order by bronze desc)
    			, ' - '
    			, first_value(bronze) over(partition by t1.games order by bronze desc)) as Max_Bronze,
				concat(first_value(t2.country) over (partition by t2.games order by total_medals desc)
    			, ' - '
    			, first_value(t2.total_medals) over(partition by t2.games order by total_medals desc)) as Max_Medals
FROM t1 JOIN t2 on t1.country = t2.country and t1.games = t2.games

--18. Which countries have never won gold medal but have won silver/bronze medals?
SElECT * 
FROM (
SELECT country, coalesce(gold, 0) as gold
    	, coalesce(silver, 0) as silver
    	, coalesce(bronze, 0) as bronze
FROM (SELECT nr.region as country, medal, count(1) as total_medals
FROM [dbo].[athlete_events] oh
JOIN [dbo].[noc_regions] nr ON nr.noc = oh.noc
where medal <> 'NA'
GROUP BY nr.region,medal) as result
PIVOT (
	SUM([total_medals])
	FOR [medal]
	IN ([Bronze], [Silver], [Gold])
) as pivot_table
) as subq
WHERE gold = 0 and (silver != 0 or bronze != 0)
order by gold desc, silver desc, bronze desc

--19. In which Sport/event, India has won highest medals.
with t1 as (
SELECT nr.region as country, sport, count(medal) as total_medals
FROM [dbo].[athlete_events] oh
JOIN [dbo].[noc_regions] nr ON nr.noc = oh.noc
where medal <> 'NA'
GROUP BY nr.region, sport
HAVING nr.region = 'India'
), t2 as(
SELECT *, rank() over(order by total_medals desc) as rnk
FROM t1
)
SELECT sport, total_medals
FROM t2
WHERE rnk = 1

--20. Break down all olympic games where India won medal for Hockey and how many medals in each olympic games

SELECT team, sport, games, COUNT(medal) as total_medals
FROM [dbo].[athlete_events]
WHERE team = 'India' and sport = 'Hockey'
GROUP BY team, sport, games
ORDER BY total_medals desc