-----------------------------------------------
--QL Data Analysis Exercises – Stack Exchange--
-----------------------------------------------
USE data_analysis_stack_exchange_movies
GO
--Basic Analysis

--1-How many post were made each year ?
SELECT YEAR(CreationDate) 'YYEAR', COUNT(*) 'number_of_posts'
FROM posts
GROUP BY YEAR(CreationDate)

--2-How many votes were made in each day of the week (Sunday, Monday, Tuesday, etc.) ?
SELECT DATENAME(WEEKDAY, CreationDate) 'day', COUNT(*) 'number_of_posts'
FROM posts
GROUP BY DATENAME(WEEKDAY, CreationDate)
ORDER BY number_of_posts

--3-List all comments created on September 19th, 2012
SELECT *
FROM Comments
--WHERE '2012-12-19' = CAST(CreationDate AS DATE)
WHERE DATEDIFF(DAY, CreationDate, '2012-12-19') = 0

--4-List all users under the age of 33, living in London
SELECT *
FROM Users
WHERE Age < 33 AND Location LIKE '%London%'


--Basic Analysis

--1-Display the number of votes for each post title
SELECT p.title, COUNT(*) 'number_votes'
FROM posts p JOIN Votes v
	ON v.PostId = p.Id
GROUP BY p.Title

--2-Display posts with comments created by users living in the same location as the post creator
SELECT p.Body, u2.Location 'post_location', u.Location 'comment_location'
FROM posts p JOIN Comments c
	ON c.PostId = p.Id JOIN Users u
	ON u.Id = p.OwnerUserId JOIN Users u2
	ON u2.Id = c.UserId
WHERE u.Location = u2.Location

--3-How many users have never voted ?
SELECT COUNT(*) 'num_users_never_voted'
FROM Users u LEFT JOIN Votes v
	ON v.UserId = u.Id
WHERE v.UserId IS NULL

--4-Display all posts having the highest amount of comments
;WITH "cte"
 AS
 (
 SELECT p.Id 'id', COUNT(*) 'CNT', DENSE_RANK() OVER (ORDER BY COUNT(*) DESC) 'Rank'
 FROM posts p JOIN Comments c
    ON c.PostId = p.Id
 GROUP BY p.Id
 )
SELECT id, CNT
FROM "cte"
WHERE Rank = 1

--5-For each post, how many votes are coming from users living in Canada ? What’s their percentage of the total number of votes
SELECT p.Title, COUNT(*) 'cnt_total', SUM(CASE WHEN u.location LIKE '%Canada%' THEN 1 ELSE 0 END) 'cnt_canada',
	   CONCAT(CAST(CAST(SUM(CASE WHEN u.location LIKE '%Canada%' THEN 1 ELSE 0 END) AS FLOAT) /
	   CAST(COUNT(*) AS FLOAT) * 100 AS NUMERIC (8,2)), '%') 'Precentage'
FROM posts p JOIN votes v
	ON v.PostId = p.Id JOIN Users u
	ON u.Id = v.UserId
GROUP BY p.Title
ORDER BY COUNT(*) DESC

--6-How many hours in average, it takes to the first comment to be posted after a creation of a new post ?
;WITH "cte"
 AS
 (
 SELECT p.Title, MIN(DATEDIFF(HOUR, p.CreationDate, c.CreationDate)) 'min_hours'
 FROM posts p JOIN Comments c
	 ON c.PostId = p.Id
 GROUP BY p.Title
 )
SELECT AVG(min_hours) 'hours'
FROM "cte"

--7-Whats the most common post tag ?
--SELECT tags, CASE WHEN Tags LIKE '%><%' THEN LEFT(Tags, CHARINDEX('>',Tags))
--				  ELSE Tags
--			 END '1',
--			 CASE WHEN Tags LIKE '%><%' THEN RIGHT(Tags, CHARINDEX('>',Tags) + 1)
--			 	  ELSE Tags
--			 END '2'
--FROM posts


--SELECT tags, len(Tags) - len(replace(Tags, '<', ''))
--FROM posts



--;WITH "CTE-TAGS-SEP" (Tags) AS
--(
--    SELECT CAST(Tags AS VARCHAR(MAX)) 
--    FROM Posts
--    UNION ALL
--    SELECT STUFF(Tags, 1, CHARINDEX('><' , Tags), '') 
--    FROM "CTE-TAGS-SEP"
--    WHERE Tags  LIKE '%><%'
--), "CTE-TAGS-COUNTER" AS 
--(   
--    SELECT CASE WHEN Tags LIKE '%><%' THEN LEFT(Tags, CHARINDEX('><' , Tags)) 
--                ELSE Tags 
--            END AS 'Tags'
--    FROM "CTE-TAGS-SEP"
--)
--SELECT COUNT(*), Tags
--FROM "CTE-TAGS-COUNTER"
--GROUP BY Tags 
--ORDER BY COUNT(*) DESC 

--8-Create a pivot table displaying how many posts were created for each year (Y axis) and each month (X axis)
SELECT *
FROM (SELECT DATENAME(MONTH,CreationDate) 'MNTH', YEAR(CreationDate) 'YER', Id
	  FROM posts
	  ) TBL
PIVOT(COUNT(Id)
	  FOR MNTH IN ([January],[February],[March],[April],[May],[June],[July],[August],[September],[October],[November],[December])
	  ) PVT
ORDER BY YER