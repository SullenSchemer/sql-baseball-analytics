-- Career home run leaders born in CA, FL, or TX.
--
-- Batting is pre-aggregated by playerID before joining People. A plain
-- GROUP BY on player_name would merge distinct players who share a name
-- and inflate career totals.

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
WHERE p.birthState IN ('CA', 'FL', 'TX')
ORDER BY c.career_home_runs DESC
LIMIT 10;
