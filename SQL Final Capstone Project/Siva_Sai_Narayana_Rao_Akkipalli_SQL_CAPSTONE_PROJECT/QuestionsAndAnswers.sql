------------------------------------------------ANALYSIS OF UEFA COMPETITIONS USING POSTGRESQL--------------------------------------------------------------------                                     
--------------------------------------------------------------------------------------------------------------------------------------------------------------------

-- Question 1: Count the total number of teams.

-- Answer: This can be done by simply counting the unique team names from the teams table. There are a total of 74 teams.

-- This following quert can view this:

   SELECT COUNT(DISTINCT(TEAM_NAME)) FROM teams;

-----------------------------------------------------------------------------------------------------------------------------------------------------------------

-- Question 2: Find the number of teams per country.

-- Answer: This can be done by selecting the country and count of team_name and then grouping by country and ordering by 
--         the count. 

-- The following query can view this:

   SELECT country, COUNT(team_name) AS num_teams
   FROM Teams
   GROUP BY country
   ORDER BY num_teams DESC;

--------------------------------------------------------------------------------------------------------------------------------------------------------------------

-- Question 3: Calculate the average team name length.

-- Answer: This can be done by using the length and average function on the team name. We use the round function to get up to
--         3 decimal points after the integer.

-- The following query can view this:

   SELECT ROUND(AVG(LENGTH(team_name)), 3) FROM teams;

-------------------------------------------------------------------------------------------------------------------------------------------------------------

-- Question 4: Calculate the average stadium capacity in each country and sort by the total stadium in the country.

-- Answer: This can be viewed by selecting the average stadium capacity & rounding it off. Then ordering by the number of
--         of stadiums present in each country.

-- The following query can view this:

   SELECT country, COUNT(stadium_name) AS country_stadium_count, ROUND(AVG(capacity), 3) AS stadium_capacity
   FROM stadiums
   GROUP BY country
   ORDER BY country_stadium_count DESC;

------------------------------------------------------------------------------------------------------------------------------------------------------------------

-- Question 5: Calculate the total goals scored.

-- Answer: This can be done by calculating the count of distinct goal_ids from the goals table.

-- The following query can view this:

   SELECT COUNT(DISTINCT(GOAL_ID)) FROM goals;

-----------------------------------------------------------------------------------------------------------------------------------------------------------------   

-- Question 6: Calculate the total number of teams that have cities in their names.

-- Answer: This can be done by calculating the count of team_name after joining the teams and stadium tables while using
--         ILIKE '%' || table.city_name || '%'. There are a total of 74 team names and 63 of them have city names in their name.

-- The following query can view this:

   SELECT COUNT(team_name) AS teams_with_citynames
   FROM teams t
   JOIN stadiums s
   ON t.team_name ILIKE '%' || s.CITY || '%';

----------------------------------------------------------------------------------------------------------------------------------------------------------------------------

-- Question 7: Use TEXT functions to concatenate team name and country name.

-- Answer: This can be done using the concat function, || operator, concat_ws function, format function, etc. 

-- The following queries show that:

   SELECT team_name || ' - ' || country AS team_country FROM teams;                  -- Method 1
   SELECT CONCAT(team_name, ' - ', country) AS team_country FROM teams;              -- Method 2
   SELECT CONCAT_WS(' - ', team_name, country) AS team_country FROM teams;           -- Method 3
   SELECT FORMAT('%s - %s', team_name, country) AS team_country FROM teams;          -- Method 4

--------------------------------------------------------------------------------------------------------------------------------------------------------------------

-- Question 8: What is the highest attendance recorded in the dataset, and which match (including home team, away team and
--             and date) which match does it correspond to?

-- Answer: This can be done using the subquery. We can simply calculate the maximum attendance in a subquery and give it 
--         to the main query to retrieve the relevant details like match_id, event_date, home_team, away_team, and also
--         the highest attendance from the matches dataset. The highest attendance is 98299 from the whole matches dataset.

-- The following query can view this:

   SELECT match_id, event_date, home_team, away_team, stadium, attendance AS highest_attendance 
   FROM matches 
   WHERE attendance = (SELECT MAX(attendance) FROM matches);

-------------------------------------------------------------------------------------------------------------------------------------------------------------------

-- Question 9: What is the lowest attendance recorded in the dataset, and which match (including home and away teams, and date) 
--             does it correspond to setting the criteria as greater than 1 as some matches had 0 attendance because of COVID-19?

-- Answer: This can be done using the subquery. To retrieve the lowest attendance greater than 1 and the corresponding match details 
--         (including home team, away team, and event date), we can follow a similar approach as above in question 8, but now with 
--         the additional condition of attendance > 1.

-- The following query can view this: 

   SELECT match_id, event_date, home_team, away_team, stadium, attendance
   FROM matches
   WHERE attendance = (SELECT MIN(attendance) FROM matches WHERE attendance > 1);

------------------------------------------------------------------------------------------------------------------------------------------------------

-- Question 10:  Identify the match with the highest total score (sum of home and away team scores) in the dataset. 
--               Include the match ID, home and away teams, and the total score.

-- Answer: We can add the home_team_score and away_team_score and order it in descending order and then take the 
--         first-row value to see the highest of the total score and corresponding details.

-- The following query can view this:

   SELECT match_id, home_team, away_team, (home_team_score + away_team_score) AS total_score
   FROM matches
   ORDER BY total_score DESC
   LIMIT 1;

-------------------------------------------------------------------------------------------------------------------------------------------------------------------------

-- Question 11: Find the total goals scored by each team, distinguishing between home and away goals. Use a CASE WHEN 
--              statement to differentiate home and away goals within the subquery.

-- Answer: We can do this by sum of the home_team_score and away_team_score to get the total_goals and their individual sums as home_goals
--         and away goals. We use CASE...WHEN...THEN statement in the subquery to calculate the sum of the goals by comparing the team_name 
--         with the home_team name or away_team name and then if it condition is not true we put 0 using ELSE. Since the team_name column is
--         in the other table names teams, we used left join to join both matches and teams tables. Now the subquery is named goal_summary
--         and it is used by the main query to give us the home_goals, away_goals, and total_goals. Finally, we ordered the table in the
--         descending order using the ORDER BY total_goals DESC to know the highest goals.

-- The following query can view this: 

	WITH goals_summary AS (
	    SELECT t.team_name,
	           SUM(CASE WHEN m.home_team = t.team_name THEN m.home_team_score ELSE 0 END) AS home_goals,
	           SUM(CASE WHEN m.away_team = t.team_name THEN m.away_team_score ELSE 0 END) AS away_goals
	    FROM teams t
	    LEFT JOIN matches m
	      ON m.home_team = t.team_name OR m.away_team = t.team_name
	    GROUP BY t.team_name
	)
	SELECT team_name,
	       home_goals,
	       away_goals,
	       home_goals + away_goals AS total_goals
	FROM goals_summary
	ORDER BY total_goals DESC;

--------------------------------------------------------------------------------------------------------------------------------------------------------------------------

-- Question 12: Windows function - Rank teams based on their total scored goals (home and away combined) using a window function in the stadium 
--              "Old Trafford".

-- Answer:  This can be done by using a subquery. The subquery goals_summary uses CASE WHEN statement and the sum of it gives the home_goals,
--          away_goals and the total_goals. The comparison is facilitated by a LEFT JOIN of both "teams" table t and "matches" table m.
--          The condition for the join is equating the name of the team from home_team and away_team with the name in the "teams" table.
--          Now the filter condition of selecting only matches at "Old Trafford" is done with the help of WHERE. This output of the subquery
--          is given to the main query where the window function RANK() is used to rank the team in descending order.

-- The following query can view this:

   WITH goals_summary AS (
       SELECT t.team_name,
           SUM(CASE WHEN m.home_team = t.team_name THEN m.home_team_score ELSE 0 END) AS home_goals,
           SUM(CASE WHEN m.away_team = t.team_name THEN m.away_team_score ELSE 0 END) AS away_goals,
           SUM(CASE WHEN m.home_team = t.team_name THEN m.home_team_score ELSE 0 END) + 
           SUM(CASE WHEN m.away_team = t.team_name THEN m.away_team_score ELSE 0 END) AS total_goals
   FROM teams t
   LEFT JOIN matches m
      ON (m.home_team = t.team_name OR m.away_team = t.team_name)
   WHERE m.stadium = 'Old Trafford'  -- Filter for matches played at Old Trafford
   GROUP BY t.team_name
   )
   SELECT team_name,
       home_goals,
       away_goals,
       total_goals,
       RANK() OVER (ORDER BY total_goals DESC) AS rank
   FROM goals_summary;

--------------------------------------------------------------------------------------------------------------------------------------------------------

-- Question 13: TOP 5 players who scored the most goals in Old Trafford, ensuring null values are not included in the result (especially pertinent 
--              for cases where a player might not have scored any goals).

-- Answer: This can be done by joining both "goals" and "matches" tables to get individual goals scored by the players and also
--         by joining "goals" and "players" tables on player_id to get the IDs of the players for the output. I used WHERE to filter
--         the stadium as "Old Trafford" and also HAVING COUNT to filter the players with 0 goals. I grouped by player_id and player_name
--         and ordered by total_goals in descending order and finally limited by 5 players to see the top 5.

-- The following query can view this:

   SELECT 
       p.player_id,
       p.first_name || ' ' || p.last_name AS player_name,
	   p.nationality,
   COUNT(g.goal_id) AS total_goals
   FROM goals g
   JOIN matches m ON g.match_id = m.match_id
   JOIN players p ON g.pid = p.player_id
   WHERE m.stadium = 'Old Trafford' -- Filter to select only 'Old Trafford Stadium'
   GROUP BY p.player_id, player_name
   HAVING COUNT(g.goal_id) > 0  -- Exclude players with no goals
   ORDER BY total_goals DESC
   LIMIT 5;

------------------------------------------------------------------------------------------------------------------------------------------------------------------

-- Question 14: Write a query to list all players along with the total number of goals they have scored. Order the results by the number of 
--              goals scored in descending order to easily identify the top 6 scorers.

-- Answer: We can simply join the "goals" and "matches" & "goals" and "players" tables to get the total goals, player_id and player_name
--         and finally order it in descending order to view the top 6 scorers. 

-- The following query can view this:

   SELECT 
       p.player_id,
       p.first_name || ' ' || p.last_name AS player_name,
	   p.nationality,
   COUNT(g.goal_id) AS total_goals
   FROM goals g
   JOIN matches m ON g.match_id = m.match_id
   JOIN players p ON g.pid = p.player_id
   GROUP BY p.player_id, player_name
   ORDER BY total_goals DESC
   LIMIT 6;

--------------------------------------------------------------------------------------------------------------------------------------------------------------------

-- Question 15: Identify the Top Scorer for Each Team - Find the player from each team who has scored the most goals in all matches combined. 
--              This question requires joining the Players, Goals, and possibly the Matches tables, and then using a subquery to aggregate goals 
--              by players and teams.

-- Answer: This can be done in three steps. The first step is aggregating goals by player and team. Here in the subquery, we count the total goals
--         by joining the players and goals tables on player_id and group by team_name, player_id and player_name.
--       ► In the second step, we rank each player within each team by their total goal count using a window function and rank them. Here
--         this subquery is named ranked_players and this takes the output of the first subquery named pgc (player_goal_counts). This subquery
--         selects team_name, player_id, player_name, and total_goals. The ROW_NUMBER() window function assigns a unique sequential integer value 
--         to each row, starting from 1 for the first row in each partition. PARTITION_BY divides the result set into partitions based on the TEAM column.
--         Within each partition (i.e., each team), the rows are sorted by the total_goals column in descending order. The player with the highest total goals 
--         will appear first in each team’s group.
--       ► In the final step, we take the output from the second subquery rp (ranked_players) and select the players with rank = 1 using 
--         WHERE and order the output in descending order by total goals.

-- The following query can view this: 

   -- Step 1: Aggregate goals by player and team.
   WITH player_goal_counts AS (
     SELECT 
       p.TEAM,
       p.PLAYER_ID,
       p.FIRST_NAME,
       p.LAST_NAME,
     COUNT(g.GOAL_ID) AS total_goals
     FROM Players p
     LEFT JOIN Goals g 
       ON p.PLAYER_ID = g.PID
     GROUP BY p.TEAM, p.PLAYER_ID, p.FIRST_NAME, p.LAST_NAME
     ),
     -- Step 2: Rank players within each team by their goal count, giving the highest scorer rank 1.
     ranked_players AS (
     SELECT 
        pgc.TEAM,
        pgc.PLAYER_ID,
        pgc.FIRST_NAME,
        pgc.LAST_NAME,
        pgc.total_goals,
     ROW_NUMBER() OVER (PARTITION BY pgc.TEAM ORDER BY pgc.total_goals DESC) AS rank
     FROM player_goal_counts pgc
     )
     -- Step 3: Select only the top-ranked player from each team (the first one in case of ties).
     SELECT 
       rp.TEAM,
       rp.PLAYER_ID,
       rp.FIRST_NAME,
       rp.LAST_NAME,
       rp.total_goals
     FROM ranked_players rp
     WHERE rp.rank = 1
     ORDER BY rp.total_goals DESC;  -- Sorting by highest goals first

-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

-- Question 16: Find the Total Number of Goals Scored in the Latest Season - Calculate the total number of goals scored in the latest season available in the dataset. 
--              This question involves using a subquery to first identify the latest season from the Matches table, then summing the goals from the Goals table that 
--              occurred in matches from that season.

-- Answer: We can do this by first selecting the latest season using the MAX() in a subquery from matches and then giving this to the main query and then counting
--         the goals in the latest season from the goals table by joining the goals and matches tables on match_id and using the latest season output.
--         from the subquery to filter by joining the matches and the latest_season subquery.

-- The following query can view this:

   -- Step 1: Find the latest season from the Matches table
   WITH latest_season AS (
     SELECT MAX(SEASON) AS latest_season  -- Common Table Expression
     FROM Matches
   )

   -- Step 2: Count the total number of goals scored in the latest season
   SELECT 
     COUNT(g.GOAL_ID) AS latest_season_total_goals
   FROM Goals g
   JOIN Matches m 
     ON g.MATCH_ID = m.MATCH_ID  -- Here we joined goals and matches, matches and latest_season_subquery
   JOIN latest_season ls
     ON m.SEASON = ls.latest_season; 

------------------------------------------------------------------------------------------------------------------------------------------------------------------------

-- Question 17: Find Matches with Above Average Attendance - Retrieve a list of matches that had an attendance higher than the average attendance across all matches. 
--              This question requires a subquery to calculate the average attendance first, then use it to filter matches.

-- Answer: We can do this by calculating the AVERAGE of the attendance column in a subquery and then joining the CTE with the matches table and
--         filtering is done while joining with the ON clause to give the final output.

-- The following query can view this:

   -- Step 1: Calculate the average attendance across all matches
   WITH avg_attendance AS (
     SELECT AVG(ATTENDANCE) AS average_attendance
   FROM Matches
   )
   -- Step 2: Retrieve matches with attendance greater than the average
   SELECT 
     m.MATCH_ID,
     m.SEASON,
     m.EVENT_DATE,
     m.HOME_TEAM,
     m.AWAY_TEAM,
     m.ATTENDANCE
   FROM Matches m
   JOIN avg_attendance aa
   ON m.ATTENDANCE > aa.average_attendance;

-----------------------------------------------------------------------------------------------------------------------------------------------------------------------

-- Question 18: Find the Number of Matches Played Each Month - Count how many matches were played in each month across all seasons. This question requires extracting 
--              the month from the match dates and grouping the results by this value. as January Feb march

-- Answer: This can be done by using the TO_DATE() first to convert the string in the cell to date format and then extracting the month number
--         from MONTH and EXTRACT keywords and also the name of the month using the TO_CHAR() function in a subquery. Now we give this date from
--         subquery and count the matches using the group by of both month and month_number across all seasons and finally order it by month_number
--         to avoid some months coming first than others.

-- The following query can view this:

	WITH month_data AS (
	  SELECT 
	    TO_CHAR(TO_DATE(event_date, 'DD-MM-YYYY'), 'FMMonth') AS month,
	    EXTRACT(MONTH FROM TO_DATE(event_date, 'DD-MM-YYYY')) AS month_number -- for sorting purposes
	  FROM matches
	)
	SELECT 
	  month,
	  COUNT(*) AS match_count
	FROM month_data
	GROUP BY month, month_number
	ORDER BY month_number;

------------------------------------------------------------------END OF THE DOCUMENT-----------------------------------------------------------------------------





