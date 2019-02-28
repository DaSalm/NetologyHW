--Cалманова Дарья
-- Таблицы взяты отсюда: https://www.kaggle.com/krasnovna/moscow-marathon-2018#1_full_results_mm_2018.csv

CREATE TABLE
full_results (
        bib INTEGER PRIMARY KEY,
        finish_time_sec REAL,
        finish_time_result VARCHAR(20),
        race VARCHAR(20),
        pace_sec DOUBLE PRECISION,
        pace_minpkm VARCHAR(20),
        pace_kmph VARCHAR(20),
        half_pace_sec DOUBLE PRECISION,
        half_pace_minpkm VARCHAR(20),
        half_pace_kmph VARCHAR(20),
        gender_en VARCHAR(20),
        age SMALLSERIAL,
        name_en VARCHAR(255),
        location_city_ru VARCHAR(50),
        location_city_en VARCHAR(50),
        country_code_alpha_3 VARCHAR(3),
        flag_DNF SMALLSERIAL,
        flag_all_split_exist SMALLSERIAL,
        race_uniform_index DOUBLE PRECISION
);

CREATE TABLE split_results (
        bib INTEGER NOT NULL,
        split_name VARCHAR(20) NOT NULL,
        split REAL NOT NULL,
        split_time_sec INTEGER,
        split_time_result VARCHAR(50),
        split_pace_sec REAL,
        split_pace_minpkm VARCHAR(20),
        split_pace_kmph VARCHAR(20),
        split_uniform_index DOUBLE PRECISION,
        PRIMARY KEY (bib, split_name)
        );


CREATE TABLE country_codes (
        name VARCHAR(100),
        alpha_2 VARCHAR(2),
        alpha_3 VARCHAR(3) PRIMARY KEY,
        country_code SERIAL,
        iso_3166_2 VARCHAR(20),
        region VARCHAR(100),
        sub_region VARCHAR(100),
        intermediate_region VARCHAR(30),
        region_code VARCHAR(3),
        sub_region_code VARCHAR(3),
        intermediate_region_code VARCHAR(3)
        );
        
        
      CREATE TABLE route (
        id SERIAL PRIMARY KEY,
        race VARCHAR(20),
        distance REAL,
        latitude REAL,
        longitude REAL,
        elevation REAL,
        elevation_delta REAL
        );
        
        psql -c "\\copy full_results FROM '/home/darya/marathon/1_full_results_mm_2018.csv' DELIMITER ',' CSV HEADER";
        psql -c "\\copy  split_results FROM '/home/darya/marathon/1_split_results_mm_2018.csv' DELIMITER ',' CSV HEADER";    
        psql -c "\\copy  route FROM '/home/darya/marathon/1_route_mm_2018.csv' DELIMITER ',' CSV HEADER";    
        psql -c "\\copy  country_codes FROM '/home/darya/marathon/country_codes.csv' DELIMITER ',' CSV HEADER";   
        
-- 1.Количество участников женщин, мужчин       
        SELECT  gender_en, COUNT(bib) 
        FROM full_results 
        GROUP BY  gender_en;

-- 2.Среднее время по стране без не финишировших, марафон
        SELECT   ROW_NUMBER() OVER(ORDER BY AVG(f.finish_time_sec)) AS Row, 
        c.name, race, AVG(f.finish_time_sec)
        FROM full_results f
        LEFT JOIN country_codes c
                ON f.country_code_alpha_3=c.alpha_3
        WHERE  f.flag_DNF=0 AND f.race='42.195 km'
        GROUP BY c.name, race
        LiMIT 10;
        
-- 3. Общий зачёт на марафонскую дистанцию
        SELECT    
        ROW_NUMBER() OVER(ORDER BY f.finish_time_sec) AS Row,
        f.name_en,
        c.name, 
        f.race,
        f.finish_time_sec
        FROM full_results f
        LEFT JOIN country_codes c
                ON f.country_code_alpha_3=c.alpha_3
        WHERE f.race='42.195 km'
        LiMIT 20;

--4. Суммарное расстояние, сколько пробежали все финишировавшие участники 
        SELECT SUM(CAST(TRANSLATE(f.race,' km','') AS FLOAT))
        FROM full_results f
        WHERE  f.flag_DNF=0 ;
        
--5. Средний возраст участника на каждой из дистанций
        SELECT   f.race,
        AVG(f.age) avg_age
        FROM full_results f
        WHERE  f.flag_DNF=0
        GROUP BY f.race;
        
--6. Самый(-ые) молодой(-ые) и самый(-ые) пожилые участники марафонской дистанции - имя, возраст, город, результат
WITH minmaxage AS (
	SELECT DISTINCT race,
  		MIN (age) OVER (PARTITION BY race) as min_age,
  		MAX (age) OVER (PARTITION BY race) as max_age  
        FROM full_results 
        WHERE  flag_DNF=0 AND race='42.195 km'
)
SELECT   f.name_en,
        f.age,
        f.location_city_en,
        f.finish_time_result
FROM full_results f
JOIN minmaxage m
        ON f.race=m.race
WHERE  f.flag_DNF=0 AND f.race='42.195 km' AND f.age IN (min_age, max_age)
ORDER BY finish_time_result        
;
--7. Из нефинишировавших участников марафона после какого участка трассы сколько слилось человек?
WITH maxs AS (
SELECT s.bib
	, MAX (s.split) AS max_split
FROM full_results f
JOIN split_results s 
	ON f.bib=s.bib
WHERE  f.flag_DNF=1 
	AND
	f.race='42.195 km'
GROUP BY s.bib
)

SELECT maxs.max_split
	, COUNT (maxs.bib) AS last_split_for
FROM maxs
GROUP BY maxs.max_split
ORDER BY last_split_for DESC
;
--8. Разбить участников на группы по возрасту с шагом 10 лет - для каждой группы вывести средний результат на дистанции 42км, 10км
SELECT f.race
	, ROUND( f.age/10 , 0) AS group_age
	, AVG(finish_time_sec) AS avg_time 
FROM full_results f
GROUP BY f.race, group_age 
ORDER BY f.race, group_age
;
--9. Какой из 5-километровых участков на дистанции самый трудный по суммарной высоте подъема 
--(учитывать только положительные значения elevation_delta)?
WITH elev AS (
SELECT  r.race
	, CAST(r.distance AS int)/5 AS group_distance
	, SUM(r.elevation_delta) AS sum_elev
	, MAX(SUM(r.elevation_delta) ) OVER (PARTITION BY race) AS max_elev
FROM route r
WHERE r.elevation_delta >0
GROUP BY group_distance, r.race
ORDER BY r.race, group_distance
)
SELECT  elev.race
	,CONCAT (
		group_distance*5
		, ' - '
		,group_distance*5 +5
	) AS distance
	,max_elev
FROM elev
WHERE sum_elev = max_elev
GROUP BY elev.race ,group_distance ,max_elev
;

-- 10. Найти участника, максимально разогнавшегося на последнем участке
-- вывести имя, возраст, страну, и  общий результат
WITH split_end AS (
SELECT DISTINCT s.split, s.split_name, bib, split_time_sec
	,MAX (split_time_sec) OVER (PARTITION BY bib)
	- MIN (split_time_sec) OVER (PARTITION BY bib)	
	AS les_time_end	
FROM split_results s 
WHERE s.split IN ('42.195','40')
ORDER BY les_time_end
)

SELECT  DISTINCT f.bib
	,f.finish_time_sec
	,f.age
	,f.name_en
	,f.country_code_alpha_3
	,s.les_time_end
FROM full_results f
JOIN split_end s
	ON f.bib = s.bib
WHERE flag_DNF=0 AND f.race='42.195 km' AND s.les_time_end!=0
ORDER BY s.les_time_end,finish_time_sec
LIMIT 1;

