-- Players whose career home runs exceed the average
-- Uses CTE + window functions for ranking

WITH career_totals AS (
  SELECT
    b.playerID,
    p.nameFirst || ' ' || p.nameLast AS player_name,
    SUM(b.HR) AS career_HR
  FROM Batting AS b
  JOIN People AS p
    ON b.playerID = p.playerID
  GROUP BY b.playerID, player_name
),
avg_hr AS (
  SELECT AVG(career_HR) AS avg_career_HR
  FROM career_totals
)
SELECT
  c.playerID,
  c.player_name,
  c.career_HR,
  RANK() OVER (ORDER BY c.career_HR DESC) AS rank_position,
  DENSE_RANK() OVER (ORDER BY c.career_HR DESC) AS dense_rank_position
FROM career_totals AS c, avg_hr AS a
WHERE c.career_HR > a.avg_career_HR
ORDER BY c.career_HR DESC
LIMIT 10 OFFSET 100;
