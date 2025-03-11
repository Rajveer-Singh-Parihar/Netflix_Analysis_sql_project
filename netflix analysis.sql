-- CREATING TABLE
DROP TABLE IF EXISTS netflix;
CREATE TABLE netflix
(
	show_id	VARCHAR(5),
	type    VARCHAR(10),
	title	VARCHAR(250),
	director VARCHAR(550),
	casts	VARCHAR(1050),
	country	VARCHAR(550),
	date_added	VARCHAR(55),
	release_year	INT,
	rating	VARCHAR(15),
	duration	VARCHAR(15),
	listed_in	VARCHAR(250),
	description VARCHAR(550)
);

select * from netflix;

-- PERFORMING EDA

select count(*) as total_count
from netflix;

select distinct type from netflix;

select distinct title from netflix;

select distinct director from netflix;

-- SOLVING BUSSINESS PROBLEM

-- 1] COUNT THE NUMBER OF MOVIES VS TV SHOWS

select 
type,
count(*) as total
from netflix
group by type;

-- 2] FIND THE MOST COMMON RATING FOR THE MOVIES AND TV SHOWS

select 
type,
rating
from
(select
type,
rating,
count(*),
rank() over(partition by type order by count(*) desc) as ranking
from netflix
group by 1,2
) as t1
where 
ranking = 1;

-- 3] LIST ALL MOVIES RELEASED IN YEAR (2020)

select * from netflix
where 
type = 'Movie'
and
release_year = 2020;


-- 4] FIND THE TOP 5 COUNTRIES WITH THE MOST content on netflix

select 
unnest(string_to_array(country, ',')) as new_country,
count(show_id) as total_content
from netflix
group by 1
order by 2 desc
limit 5;

-- 5]  FIND THE LONGEST MOVIE

select * from netflix
where
type = 'Movie'
and
duration = (select max(duration) from netflix );




-- 6] FIND THE CONTENT ADDED IN THE LAST 5 YEARS


select * from netflix
where
TO_DATE(date_added , 'Month DD,YYYY') >= current_date - INTERVAL '5 years';


-- 7]  FIND ALL THE MOVIES AND TV SHOES BY DIRECTOR 'RAJIV CHILAKA'

select * from netflix
where
director = 'Rajiv Chilaka';


-- 8] LIST ALL THE TV SHOWS WITH MORE THAN 5 SESSION


select * from netflix
where
type = 'TV Show'
and
split_part(duration,' ',1)::numeric >5;




-- 9] COUNT THE NUMBER OF CONTENT ITEM IN EACH GENRE


select
unnest(string_to_array(listed_in,',')) as genre,
count(show_id) as total_content
from netflix
group by 1;


-- 10] FIND EACH YEAR AND THE AVERAGE NUMBERS OF CONTENT RELEASE BY INDIA ON NETFLIX
-- RETURN TOP 5 YEAR WITH HIGHEST AVG CONTENT RELEASE

select 
extract(year from to_date(date_added,'Month DD,YYYY')) as year,
count(*)
from netflix
where country = 'India'
group by 1;


-- 11] LIST ALL THE MOVIES WHICH ARE DOCUMENTRIES


select * from netflix
where 
listed_in = 'Documentaries';


-- 12]  FIND ALL THE CONTENT WITHOUT A DIRECTOR


select * from netflix
where 
director is null;


-- 13] FIND HOW MANY MOVIES ACTOR 'SALMAN KHAN' APPEARED IN LAST 10 YEARS?

select * from netflix
where
casts ILIKE '%Salman Khan%'
and 
release_year > extract(year from current_date) - 10;


-- 14] FIND THE TOP10 ACTORE WHO APPEARED IN THE HIGHEST NUMBER OF MOVIES IN PRODUCE IN INDIA


select 
unnest(string_to_array(casts,',')) as actors,
count(*) as total_count
from netflix
where
country = 'India'
group by 1
order by 2 desc
limit 10;


-- 15] CATEGORIES THE CONTENT BASED ON THE PRESENCE OF THE KEYBOARDS 'KILL' AND 'VIOLENCE'
-- IN THE DESCRIPTION FIELD . LABEL CONTENT CONTAINING THESE KEYWORDS AS 'BAD' AND ALL
-- OTHER CONTENT AS 'GOOD' . COUNT HOW MANY ITEMS FALL INTO EACH CATEGORY.

with new_table
as
(
select *,
case
when
description ILIKE '%kill%' or
description ILIKE '%violence' then 'Bad_content'
else 'Good Content'
end category
from netflix
)
select 
category,
count(*) as total_content
from new_table
group by 1;
