------------------------------------------------
--SQL Data Analysis Exercises – Facebook Games--
------------------------------------------------

USE data_analysis_facebook
GO

--Basic Analysis--

--1-How many members have joined facebook on 2013?
SELECT COUNT(*) 'num_members'
FROM facebook_members
WHERE YEAR(member_since) = 2013

--2-How many facebook members have less than three friends?
;WITH "cte-friendship"
 AS
 (
  SELECT mem.full_name, COUNT(fr.friend_id) 'cnt_friends'
  FROM facebook_members mem JOIN friendships fr
	  ON fr.member_id = mem.member_id
  GROUP BY mem.full_name
  HAVING COUNT(fr.friend_id) < 3
 )
SELECT COUNT(*) 'Less_than_3_friends'
FROM "cte-friendship" cte

--3-How many facebook members have no friends?
;WITH "cte"
 AS
 (
	SELECT member_id
	FROM facebook_members
	EXCEPT
	(
		SELECT member_id
		FROM friendships
		UNION
		SELECT friend_id
		FROM friendships
	)
 )
SELECT COUNT(*) num_users_no_friends
FROM "cte"

--4-List the number of games for each game category
SELECT game_category, COUNT(*) 'num_games_in_category'
FROM facebook_games
GROUP BY game_category
ORDER BY COUNT(*) DESC

--Advanced Analysis--

--1-What is the average amount_spent by each player id?
SELECT member_id,
	   CONCAT('$', AVG(CAST(REPLACE(amount_spent,'$','') AS FLOAT))) 'avg_amount_spent'
FROM games_and_players
GROUP BY member_id
ORDER BY avg_amount_spent DESC

--2-What is the average amount_spent by each gender in France?
SELECT mem.gender,
	   CONCAT('$', AVG(CAST(REPLACE(gp.amount_spent,'$','') AS FLOAT))) 'avg_amount_spent'
FROM facebook_members mem JOIN games_and_players gp
	ON gp.member_id = mem.member_id
WHERE mem.country = 'France'
GROUP BY mem.gender

--3-How many facebook users haven’t registered to any game?
SELECT COUNT(*) ' num_members_no_game'
FROM facebook_members mem LEFT JOIN games_and_players gp
	ON gp.member_id = mem.member_id
WHERE gp.member_id IS NULL

--4-What is the most profitable game?
SELECT TOP 1 fg.game_name, SUM(CAST(REPLACE(amount_spent,'$','') AS FLOAT)) 'sum_amount'
FROM games_and_players gp JOIN facebook_games fg
	ON fg.game_id = gp.game_id
GROUP BY fg.game_name
ORDER BY SUM(CAST(REPLACE(amount_spent,'$','') AS FLOAT)) DESC

--5-What is the most profitable game in France?
SELECT TOP 1 fg.game_name, SUM(CAST(REPLACE(amount_spent,'$','') AS FLOAT)) 'sum_amount'
FROM games_and_players gp JOIN facebook_games fg
	ON fg.game_id = gp.game_id JOIN facebook_members mem
	ON mem.member_id = gp.member_id
WHERE mem.country = 'France'
GROUP BY fg.game_name
ORDER BY SUM(CAST(REPLACE(amount_spent,'$','') AS FLOAT)) DESC

--6-What is the most favorite game category (by the number of users)?
SELECT TOP 1 fg.game_category, COUNT(gp.member_id) 'num_of_users'
FROM games_and_players gp JOIN facebook_games fg
	ON fg.game_id = gp.game_id
GROUP BY fg.game_category
ORDER BY COUNT(gp.member_id) DESC

--7-List Tom Stewart's friends
SELECT fr.friend_id, mem1.full_name
FROM facebook_members mem JOIN friendships fr
	ON fr.member_id = mem.member_id JOIN facebook_members mem1
	ON mem1.member_id = fr.friend_id
WHERE fr.member_id = (SELECT member_id
					  FROM facebook_members
					  WHERE full_name = 'Tom Stewart')

--8-List the games Tom Stewart’s friends are playing
SELECT fr.friend_id,
	   mem1.full_name,
	   gap.game_id,
	   fg.game_name
FROM facebook_members mem JOIN friendships fr
	ON fr.member_id = mem.member_id JOIN facebook_members mem1
	ON mem1.member_id = fr.friend_id JOIN games_and_players gap
	ON gap.member_id = mem1.member_id JOIN facebook_games fg
	ON fg.game_id = gap.game_id
WHERE mem.full_name = 'Tom Stewart'

--9-Create a distinct list of all games played by Tom Stewart and his friends
SELECT fg.game_name
FROM facebook_members mem JOIN games_and_players gap
	ON gap.member_id = mem.member_id JOIN facebook_games fg
	ON fg.game_id = gap.game_id
WHERE mem.full_name = 'Tom Stewart'
UNION
SELECT fg.game_name
FROM facebook_members mem JOIN friendships fr
	ON fr.member_id = mem.member_id JOIN facebook_members mem1
	ON mem1.member_id = fr.friend_id JOIN games_and_players gap
	ON gap.member_id = mem1.member_id JOIN facebook_games fg
	ON fg.game_id = gap.game_id
WHERE mem.full_name = 'Tom Stewart'
ORDER BY fg.game_name

--10-List all 2nd degree friends of Jami Whatson
SELECT fr.friend_id, mem1.full_name
FROM facebook_members mem JOIN friendships fr
	ON fr.member_id = mem.member_id JOIN facebook_members mem1
	ON mem1.member_id = fr.friend_id
WHERE fr.member_id IN
					 (SELECT fr.friend_id
					  FROM facebook_members mem JOIN friendships fr
						  ON fr.member_id = mem.member_id JOIN facebook_members mem1
						  ON mem1.member_id = fr.friend_id
				  	  WHERE fr.member_id = (SELECT member_id
											FROM facebook_members
											WHERE full_name = 'Jami Whatson'))
ORDER BY mem1.full_name

SELECT mem1.full_name
FROM friendships fr JOIN friendships fr1
	ON fr.friend_id = fr1.member_id JOIN facebook_members mem
	ON mem.member_id = fr.member_id JOIN facebook_members mem1
	ON mem1.member_id = fr1.friend_id
WHERE mem.full_name = 'Jami Whatson'
ORDER BY mem1.full_name