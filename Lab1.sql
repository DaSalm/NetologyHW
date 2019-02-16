
SELECT 'ФИО: Салманова Дарья';
--a.	Вывести список названий департаментов
--и количество главных врачей в каждом из этих департаментов
SELECT 	d.name,
		COUNT (DISTINCT e.chief_doc_id) as count_chief
FROM Department as d
LEFT JOIN Employee as e
ON d.id=e.department_id
GROUP BY d.name
ORDER BY count_chief DESC;

--b.	Вывести список департаментов, в которых работают 3 
--и более сотрудников (id и название департамента, количество сотрудников)
SELECT 	d.id, d.name,
		COUNT (e.id) as count_id
FROM Department as d
LEFT JOIN Employee as e
	ON d.id=e.department_id
GROUP BY d.id, d.name
HAVING COUNT (e.id) >= 3
ORDER BY count_id DESC;

--c.	Вывести список департаментов с максимальным количеством публикаций
--  (id и название департамента, количество публикаций)

SELECT d.id, d.name,
		SUM (e.num_public) as sum_public
FROM Department as d
LEFT JOIN Employee as e
	ON d.id=e.department_id
GROUP BY d.id, d.name
HAVING SUM (e.num_public) IN ( 
				SELECT
					SUM (e.num_public) as max_public
				FROM Employee as e
				GROUP BY e.department_id
				ORDER BY max_public DESC
				LIMIT 1
                              )
;

--d.	Вывести список сотрудников с минимальным количеством публикаций в своем
-- департаменте (id и название департамента, имя сотрудника, количество публикаций)
WITH min_p AS 
(
SELECT  department_id, name, num_public,
		MIN (num_public) OVER (PARTITION BY department_id) as min_public
FROM Employee 
GROUP BY department_id, name, num_public
)

SELECT d.id, d.name, min_p.name, min_p.num_public
FROM min_p
JOIN Department as d
	ON department_id = d.id
WHERE min_p.num_public = min_public
GROUP BY d.id,d.name, min_p.name, min_p.num_public
ORDER BY d.id
;

--e.	Вывести список департаментов и среднее количество публикаций для тех 
--департаментов, в которых работает более одного главного врача
-- (id и название департамента, среднее количество публикаций)
WITH avg_p AS
(
  SELECT DISTINCT department_id,
AVG (num_public) OVER (PARTITION BY department_id) as avg_public
FROM Employee
)

SELECT  d.id, d.name, avg_public
FROM Department AS d
JOIN Employee AS e
	ON d.id = e.department_id
JOIN avg_p 
	ON d.id = avg_p.department_id
GROUP BY d.id, avg_public
HAVING COUNT(DISTINCT chief_doc_id) >1
ORDER BY d.id
;
