-- table creation process for goals.csv
----------------------------------------

CREATE TABLE goals (
    goal_id VARCHAR(10) PRIMARY KEY,
    match_id VARCHAR(10),
    pid VARCHAR(10),
    duration INT,
    assist VARCHAR(10),
    goal_desc VARCHAR(50)
);

COPY goals(GOAL_ID, MATCH_ID, PID, DURATION, ASSIST, GOAL_DESC)
FROM 'N:/Data Analyst/SQL_final_capstone_project/goals.csv'
DELIMITER ','
CSV HEADER;

select * from goals;

UPDATE goals
SET pid = COALESCE((
    SELECT pid
    FROM goals g2
    WHERE g2.pid IS NOT NULL
    LIMIT 1
), 'default_pid')
WHERE pid IS NULL;

UPDATE goals
SET assist = COALESCE((
    SELECT assist
    FROM goals g2
    WHERE g2.assist IS NOT NULL
    LIMIT 1
), 'default_assist')
WHERE assist IS NULL;

UPDATE goals
SET goal_desc = COALESCE((
    SELECT goal_desc
    FROM goals g2
    WHERE g2.goal_desc IS NOT NULL
    LIMIT 1
), 'default_goal_desc')
WHERE goal_desc IS NULL; 

ALTER TABLE goals
ALTER COLUMN goal_id SET NOT NULL,
ALTER COLUMN match_id SET NOT NULL,
ALTER COLUMN pid SET NOT NULL,
ALTER COLUMN duration SET NOT NULL,
ALTER COLUMN assist SET NOT NULL,
ALTER COLUMN goal_desc SET NOT NULL;

select * from goals;



  

