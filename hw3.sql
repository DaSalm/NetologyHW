SELECT 'ФИО: Салманова Дарья';
--Оконные функции.
WITH maxmin AS
(
  SELECT DISTINCT userId, movieId, rating, 
	MAX(rating) OVER (PARTITION BY userId) as maxr,
	MIN(rating) OVER (PARTITION BY userId) as minr
  FROM ratings
)
SELECT userId, movieId,
    (rating - minr)/(maxr - minr) as normed_rating,
AVG(rating) OVER (PARTITION BY userId) as avg_rating
FROM maxmin
WHERE maxr!= minr
ORDER BY userId, normed_rating
LIMIT 30;
--СОЗДАНИЯ ТАБЛИЦЫ
psql -c '
 CREATE TABLE IF NOT EXISTS keywords (
keywords_id bigint,
tags text
 );'

--ЗАЛИВКА ДАННЫХ В ТАБЛИЦУ
psql -c "\\copy keywords FROM '/usr/local/share/netology/raw_data/keywords.csv' DELIMITER ',' CSV HEADER";

--ЗАПРОС3
WITH top_rated AS (
SELECT DISTINCT r1.movieId,
AVG(r1.rating) OVER (PARTITION BY r1.movieId) as  avg_rating
FROM ratings r1
WHERE r1.movieId IN (
		SELECT DISTINCT r2.movieId
		FROM ratings r2
		GROUP BY r2.movieId
	HAVING COUNT (r2.movieId)>50
	)
ORDER BY avg_rating DESC, r1.movieId ASC
LIMIT 150
)
SELECT t1.*, t2.*
INTO top_rated_tags
FROM top_rated t1
JOIN keywords t2 
	ON t1.movieId=t2.keywords_id;

--ВЫГРУЗКА ТАБЛИЦЫ В ФАЙЛ
\copy (SELECT * FROM top_rated_tags) TO 'top_rated_tags.csv' WITH CSV HEADER DELIMITER as E'\t';

