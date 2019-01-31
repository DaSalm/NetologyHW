SELECT 'ФИО: Салманова Дарья';

--1. Простые выборки
--1.1
SELECT *
FROM ratings
LIMIT 10;
--1.2
SELECT *
FROM links
WHERE		imdbid LIKE '%42'
	AND 	movieid>=100
	AND	movieid<=1000 
LIMIT 10;

--2. Сложные выборки: JOIN
--2.1
SELECT l.imdbid, r.rating
FROM links as l
INNER JOIN ratings as r
ON l.movieid=r.movieid
WHERE r.rating='5'
LIMIT 10;

--3. Аггрегация данных: базовые статистики
--3.1
SELECT COUNT(DISTINCT l.movieid)
FROM links l
LEFT JOIN ratings r
ON l.movieid=r.movieid
WHERE r.rating IS NULL;
--3.2
SELECT
    userId,
    AVG(rating) avg_rating
FROM ratings
GROUP BY userid
HAVING AVG(rating) > 3.5
ORDER BY userid DESC
LIMIT 10;

--4. Иерархические запросы
--4.1
SELECT imdbid
FROM links l
WHERE	l.movieid IN (	
	SELECT
	r.movieid
	FROM ratings r
	GROUP BY r.movieid
	HAVING AVG(r.rating) > 3.5
	)
LIMIT 10;
--4.2
SELECT AVG(rating)
FROM ratings r1 
WHERE r1.userid IN (	
	SELECT
	r2.userid
	FROM ratings r2
	GROUP BY r2.userid
	HAVING COUNT(r2.rating) > 10
	);
