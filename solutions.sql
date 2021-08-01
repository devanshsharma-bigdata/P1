CREATE DATABASE P1;
USE P1;

#1
CREATE TABLE pageviews (
lang STRING,
page STRING,
views INT)
ROW FORMAT DELIMITED
FIELDS TERMINATED BY ' ';
CREATE TABLE total_pageviews
AS SELECT page, SUM(views) OVER (PARTITION BY page ORDER BY page)
AS total_views FROM pageviews
WHERE page != 'Main_Page' AND page != 'Special:Search' AND page != '-';
SELECT DISTINCT page, total_views FROM total_pageviews ORDER BY total_views DESC;

#2
CREATE TABLE june_clickstream (
prev STRING,
curr STRING,
type STRING,
n INT)
ROW FORMAT DELIMITED
FIELDS TERMINATED BY '\t';
CREATE TABLE total_internal_links
AS SELECT prev, type, SUM(n) OVER (PARTITION BY prev ORDER BY prev)
AS ttlClicks_OnIntLinks FROM june_clickstream
WHERE prev != 'Main_Page' AND type = 'link';
CREATE TABLE total_internal_links_final
AS SELECT DISTINCT prev, type, ttlclicks_onintlinks FROM total_internal_links;
SELECT * FROM total_internal_links_final ORDER BY ttlclicks_onintlinks DESC;

#3
SELECT * FROM total_internal_links_final WHERE prev='Hotel_California' ORDER BY ttlclicks_onintlinks DESC;

#4
CREATE TABLE all_lang_pageviews (
	lang STRING,
	page STRING,
	views INT)
	ROW FORMAT DELIMITED
	FIELDS TERMINATED BY ' ';

LOAD DATA INPATH '/user/root/all_lang_wikipedia_20th_jan/' INTO TABLE all_lang_pageviews;

create table german_pageviews as select * from all_lang_pageviews where lang regexp "de";
select en.page, sum(en.views) as american_views, de.page ,sum(de.views) as german_views
from pageviews en
join german_pageviews de
where en.page = de.page 
group by en.page, de.page
having american_views > german_views 
order by american_views desc, german_views
limit 20;

#5
SELECT lang, SUM(views) from pageviews where lang='en.m' OR lang='en' GROUP BY lang;
