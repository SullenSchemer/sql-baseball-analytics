-- Career home run leaders across all eras
-- Top 10 players by career home runs.
--
-- Batting is pre-aggregated by playerID before the join to People so that
-- distinct players who share a name (e.g., Frank Thomas Sr. and Frank Thomas
-- "The Big Hurt", or Ken Griffey Sr. and Jr.) are not collapsed by a
-- GROUP BY on player_name.

WITH career_hr AS (
  SELECT
    playerID,
    SUM(HR) AS career_home_runs
  FROM Batting
  GROUP BY playerID
)
SELECT
  p.nameFirst || ' ' || p.nameLast AS player_name,
  c.career_home_runs
FROM career_hr AS c
JOIN People AS p
  ON c.playerID = p.playerID
ORDER BY c.career_home_runs DESC
LIMIT 10;
