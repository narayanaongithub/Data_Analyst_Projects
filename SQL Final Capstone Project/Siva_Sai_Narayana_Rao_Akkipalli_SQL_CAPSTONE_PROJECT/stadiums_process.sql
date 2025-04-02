-- Stadium table creation process
----------------------------------

CREATE TABLE stadiums (
	STADIUM_NAME varchar(30) not null primary key,
	CITY varchar(20) not null,
	COUNTRY varchar(20) not null,
	CAPACITY INT not null
);

COPY stadiums(STADIUM_NAME, CITY, COUNTRY, CAPACITY)
FROM 'N:/Data Analyst/SQL_final_capstone_project/Stadiums.csv'
DELIMITER ','
CSV HEADER;

select * from stadiums;