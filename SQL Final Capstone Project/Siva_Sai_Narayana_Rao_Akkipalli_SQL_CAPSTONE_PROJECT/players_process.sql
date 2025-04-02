-- Players table creation process
-----------------------------------

CREATE TABLE players (
	PLAYER_ID varchar(10) primary key,
    FIRST_NAME varchar(20),
	LAST_NAME varchar(20),
	NATIONALITY varchar(30),
    DOB DATE,
    TEAM varchar(30),
    JERSEY_NUMBER FLOAT,
	PLAYER_POSITION varchar(15),
    HEIGHT FLOAT,
    WEIGHT FLOAT,
    FOOT char(1)
);


COPY players FROM 'N:/Data Analyst/SQL_final_capstone_project/Players.csv' DELIMITER ',' CSV HEADER;

-- Updating the null values

-- Update the Players table without using NULL as a mode
UPDATE Players
SET 
    first_name = (
        SELECT first_name
        FROM (
            SELECT first_name
            FROM Players
            WHERE first_name IS NOT NULL
            GROUP BY first_name
            ORDER BY COUNT(*) DESC
            LIMIT 1
        ) AS mode_first_name
    ),
    
    DOB = '1900-01-01', -- A placeholder date for the null values

    jersey_number = (
        SELECT jersey_number
        FROM (
            SELECT jersey_number
            FROM Players
            WHERE jersey_number IS NOT NULL
            GROUP BY jersey_number
            ORDER BY COUNT(*) DESC
            LIMIT 1
        ) AS mode_jersey_number
    ),

    height = (
        SELECT height
        FROM (
            SELECT height
            FROM Players
            WHERE height IS NOT NULL
            GROUP BY height
            ORDER BY COUNT(*) DESC
            LIMIT 1
        ) AS mode_height
    ),

    weight = (
        SELECT weight
        FROM (
            SELECT weight
            FROM Players
            WHERE weight IS NOT NULL
            GROUP BY weight
            ORDER BY COUNT(*) DESC
            LIMIT 1
        ) AS mode_weight
    ),

    foot = (
        SELECT foot
        FROM (
            SELECT foot
            FROM Players
            WHERE foot IS NOT NULL
            GROUP BY foot
            ORDER BY COUNT(*) DESC
            LIMIT 1
        ) AS mode_foot
    )

WHERE first_name IS NULL OR
      jersey_number IS NULL OR
      DOB IS NULL OR
      weight IS NULL OR
      height IS NULL OR
      foot IS NULL;


-- Now it is time to clean the player position column

UPDATE Players
SET player_position = 'Goalkeeper'
WHERE player_position = 'Goalkeeping';

UPDATE Players
SET player_position = NULL
WHERE player_position NOT IN ('Defender', 'Midfielder', 'Forward', 'GoalKeeper') 
AND player_position IS NOT NULL;

UPDATE Players
SET player_position = COALESCE(player_position, 
    CASE FLOOR(RANDOM() * 3)
        WHEN 0 THEN 'Defender'
        WHEN 1 THEN 'Midfielder'
        WHEN 2 THEN 'Forward'
    END
)
WHERE player_position IS NULL;


ALTER TABLE players
ALTER PLAYER_ID SET NOT NULL,
ALTER FIRST_NAME SET NOT NULL,
ALTER LAST_NAME SET NOT NULL,
ALTER NATIONALITY SET NOT NULL,
ALTER DOB SET NOT NULL,
ALTER TEAM SET NOT NULL,
ALTER JERSEY_NUMBER SET NOT NULL,
ALTER HEIGHT SET NOT NULL,
ALTER WEIGHT SET NOT NULL,
ALTER FOOT SET NOT NULL;

select * from players;

