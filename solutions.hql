-- Creating a database for the project
CREATE DATABASE project1

-- Selecting the database
use project1;

-- Create a table to upload the data from the files
CREATE EXTERNAL TABLE IF NOT EXISTS pageviews1(lang STRING,	
					   page STRING,
					   views INT)
					   ROW FORMAT DELIMITED
					   FIELDS TERMINATED BY ' '
					   STORED AS TEXTFILE;
					   
-- Loading the files into the table
LOAD DATA INPATH '/user/maria_dev/data/formated_00.txt' INTO TABLE pageviews1;
LOAD DATA INPATH '/user/maria_dev/data/formated_01.txt' INTO TABLE pageviews1;
LOAD DATA INPATH '/user/maria_dev/data/formated_02.txt' INTO TABLE pageviews1;
.
.
.
LOAD DATA INPATH '/user/maria_dev/data/formated_23.txt' INTO TABLE pageviews1;

-- Display the contents of the table 
select *from pageviews1

-- Counting the total views from each page and storing it in a table
CREATE TABLE IF NOT EXISTS total_en_pageviews
AS SELECT DISTINCT(page), SUM(views) OVER (PARTITION BY page ORDER BY page) 
AS total_views FROM pageviews1 
WHERE page != 'Main_Page' AND page != 'Special:Search' AND page != '-';

-- Question 1 - Page with the most amount of views
SELECT * FROM total_en_pageviews
WHERE total_views > 100000
ORDER BY total_views DESC
LIMIT 1;


-- Create an external table to load the data from the file
CREATE EXTERNAL TABLE IF NOT EXISTS clickstream (
	prev STRING,
	curr STRING,
	type STRING,
	occ INT)
	ROW FORMAT DELIMITED
	FIELDS TERMINATED BY '\t'
	STORED AS TEXTFILE;

-- Load the data into the table from the file
LOAD DATA INPATH '/user/maria_dev/data/clickstream-enwiki-2020-12.tsv' INTO TABLE clickstream;

-- Question 2 - Page with the most views in which internal links were used
select prev, sum(occ) as visits from clickstream
where type = "link" 
group by prev
order by visits desc
limit 10;

-- Create an external table to load the data from the file
CREATE EXTERNAL TABLE IF NOT EXISTS clickstream (
	prev STRING,
	curr STRING,
	type STRING,
	occ INT)
	ROW FORMAT DELIMITED
	FIELDS TERMINATED BY '\t'
	STORED AS TEXTFILE;

-- Load the data into the table from the file
LOAD DATA INPATH '/user/maria_dev/data/clickstream-enwiki-2020-12.tsv' INTO TABLE clickstream;


-- Question 3 - Pages starting with "Hotel California" who has the highest views and have clicked internal links

select prev, sum(occ) as visits from clickstream where prev like "%Hotel_California%" group by prev ORDER BY visits DESC limit 20;

(or) 

select prev, sum(pair) as visit 
from clickstream 
where prev regexp "Hotel_California" and types = "link"  
group by prev 
order by visit desc
limit 10;

-- Create an external table to store all the data from the fike
create external table data (domain_code string, page_title string, count_views int, total_response_size int)
row format delimited
fields terminated by ' '
stored as textfile
;

-- Loading the data from file to the table
load DATA INPATH "/user/maria_dev/data/pageviews-20210101-000000" into table data;

-- Creating a table to store data for only German
create table de_data as select * from us_data where domain_code regexp "de";

-- Creating a table to store data for only English
create table en_data as select * from us_data where domain_code regexp "en";

-- Question 4
select en.page_title, sum(en.count_views) as us_visits, de.page_title ,sum(de.count_views) as ge_visits from en_data en
join de_data de
where en.page_title = de.page_title 
group by en.page_title, de.page_title
having us_visits > ge_visits 
order by us_visits desc, ge_visits
limit 20;

-- Create a table to upload the data from the files
CREATE EXTERNAL TABLE IF NOT EXISTS pageviews1(lang STRING,	
					   page STRING,
					   views INT)
					   ROW FORMAT DELIMITED
					   FIELDS TERMINATED BY ' '
					   STORED AS TEXTFILE;
					   
-- Loading the files into the table
LOAD DATA INPATH '/user/maria_dev/data/formated_00.txt' INTO TABLE pageviews1;
LOAD DATA INPATH '/user/maria_dev/data/formated_01.txt' INTO TABLE pageviews1;
LOAD DATA INPATH '/user/maria_dev/data/formated_02.txt' INTO TABLE pageviews1;
.
.
.
LOAD DATA INPATH '/user/maria_dev/data/formated_23.txt' INTO TABLE pageviews1;


-- Question 5
select domain_code, sum(count_views) from data_01 
group by domain_code
having domain_code regexp "en.m$|en$";
