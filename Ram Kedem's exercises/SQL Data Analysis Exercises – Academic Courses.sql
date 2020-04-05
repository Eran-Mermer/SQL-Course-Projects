------------------------------------------------
--SQL Data Analysis Exercises – Academic Courses
------------------------------------------------

--Basic Analysis--

--1
SELECT COUNT(*) 'Num_live_liverpool'
FROM lecturers
WHERE city = 'Liverpool'

--2
SELECT course_title
FROM courses
WHERE course_title LIKE '%cognition%' OR course_title LIKE '%cognitive%'

--3
SELECT lecturer_id, COUNT(DISTINCT class_id) 'cnt_classes', COUNT(student_id) 'cnt_students'
FROM classes
GROUP BY lecturer_id

--4
SELECT first_name+' '+last_name 'full_name'
FROM students
WHERE gender = 'Female' AND
	  city = 'London'

--Advanced Anlytics--

--1
SELECT first_name+' '+last_name 'full_name'
FROM students st JOIN classes cl
	ON cl.student_id = st.id JOIN courses co
	ON co.course_id = cl.course_id
WHERE st.gender = 'Female' AND
	  st.city = 'London' AND
	  co.course_title = 'Topics in Applied Psychology'

--2
;WITH "cte"
 AS
 (
	SELECT lecturer_id, COUNT(student_id) 'avgg'
	FROM classes
	GROUP BY lecturer_id
 )
SELECT AVG(avgg)
FROM "cte"

--3
SELECT st.first_name+' '+st.last_name 'full_name'
FROM students st JOIN classes cl
	ON cl.student_id = st.id JOIN lecturers le
	ON le.id = cl.lecturer_id
WHERE le.first_name = 'Jacob' AND
	  le.last_name = 'Willshear'

--4
SELECT DISTINCT le.id, le.first_name+' '+le.last_name 'full_name'
FROM lecturers le JOIN classes cl
	ON cl.lecturer_id = le.id JOIN courses co
	ON co.course_id = cl.course_id
WHERE co.course_id IN (
				SELECT DISTINCT cl.course_id
				FROM lecturers le JOIN classes cl
					ON cl.lecturer_id = le.id
				WHERE le.first_name = 'Jacob' AND
					  le.last_name = 'Willshear') AND le.first_name+' '+le.last_name != 'Jacob Willshear'

--5
SELECT DISTINCT le.first_name+' '+le.first_name 'full_name'
FROM lecturers le JOIN classes cl
	ON cl.lecturer_id = le.id JOIN courses co
	ON co.course_id = cl.course_id
WHERE  co.course_title = 'Topics in Perception & Cognition'

--6
;WITH "cte"
 AS
 (
	SELECT le.first_name+' '+le.last_name 'full_name_lecturer',
					CASE WHEN grade_test_b IS NULL THEN grade_test_a
						 WHEN grade_test_c IS NULL THEN grade_test_b
						 ELSE grade_test_c
					END 'finall_grade'
	FROM lecturers le JOIN classes cl
		ON cl.lecturer_id = le.id JOIN courses co
		ON co.course_id = cl.course_id
	WHERE  co.course_title = 'Topics in Perception & Cognition'
 )
SELECT TOP 1 full_name_lecturer, AVG(finall_grade) 'grade'
FROM "cte"
GROUP BY full_name_lecturer
ORDER BY grade DESC

--7-When the same course like question 6
SELECT COUNT(DISTINCT st.id) 'total'
FROM lecturers le JOIN classes cl
	ON cl.lecturer_id = le.id JOIN courses co
	ON co.course_id = cl.course_id JOIN students st
	ON st.id = cl.student_id
WHERE grade_test_c IS NULL AND grade_test_b > grade_test_a OR
		grade_test_c IS NOT NULL AND grade_test_c > grade_test_b AND grade_test_c > grade_test_a 

--8
;WITH "cte"
 AS
 (
	SELECT st.id, COUNT(DISTINCT co.course_id) 'cnt'
	FROM courses co JOIN classes cl
		ON cl.course_id = co.course_id JOIN students st
		ON st.id = cl.student_id
	GROUP BY st.id
 )
SELECT AVG(cnt) 'avg_courses'
FROM "cte"

--9
;WITH "cte"
 AS
 (
	SELECT CAST(id AS VARCHAR) + 's' 'position'
	FROM students
	WHERE city != 'London'
	UNION
	SELECT CAST(id AS VARCHAR) + 'l'
	FROM lecturers
	WHERE city != 'London'
 )
SELECT SUM(CASE WHEN position LIKE '%s' THEN 1 ELSE 0 END) 'students',
	   SUM(CASE WHEN position LIKE '%l' THEN 1 ELSE 0 END) 'lecturers'
FROM "cte"

--10
;WITH "cte"
 AS
 (
	SELECT co.course_title, st.first_name+' '+st.last_name 'full_name',
		   COALESCE(cl.grade_test_c, cl.grade_test_b, cl.grade_test_a) 'final_grade',
		   DENSE_RANK() OVER (PARTITION BY co.course_title ORDER BY COALESCE(cl.grade_test_c, cl.grade_test_b, cl.grade_test_a)DESC) 'rnk'
	FROM courses co JOIN classes cl
		ON cl.course_id = co.course_id JOIN students st
		ON st.id = cl.student_id
 )
SELECT full_name, final_grade, course_title
FROM "cte"
WHERE rnk <= 2