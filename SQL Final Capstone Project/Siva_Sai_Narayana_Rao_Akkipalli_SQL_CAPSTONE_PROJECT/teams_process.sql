-- Team table creation process
----------------------------------

CREATE TABLE teams (
	TEAM_NAME varchar(30) not null primary key,
	COUNTRY varchar(20) not null,
	HOME_STADIUM varchar(30) not null
);

COPY teams(TEAM_NAME, COUNTRY, HOME_STADIUM)
FROM 'N:/Data Analyst/SQL_final_capstone_project/Teams.csv'
DELIMITER ','
CSV HEADER;

select * from teams;

