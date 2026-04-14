-- 2024 batting averages for qualified players
-- Qualified = at least 502 plate appearances
-- Plate appearances = AB + BB + IBB + HBP + SH + SF
--
-- Batting is pre-aggregated by playerID before joining People so that
-- distinct players who share a first+last name cannot be collapsed by a
-- GROUP BY on player_name. Same pattern as career_home_runs.sql.

WITH season_totals AS (
  SELECT
    playerID,
    SUM(AB)                                       AS total_AB,
    SUM(H)                                        AS total_H,
    SUM(BB + IBB)                                 AS total_BB,
    SUM(HBP)                                      AS total_HBP,
    SUM(SH)                                       AS total_SH,
    SUM(SF)                                       AS total_SF,
    SUM(AB + BB + IBB + HBP + SH + SF)            AS total_PA,
    ROUND((CAST(SUM(H) AS FLOAT) / SUM(AB)) * 1000, 0) AS batting_avg_x1000
  FROM Batting
  WHERE yearID = 2024
    AND AB > 0
  GROUP BY playerID
  HAVING SUM(AB + BB + IBB + HBP + SH + SF) >= 502
)
SELECT
  p.nameFirst || ' ' || p.nameLast AS player_name,
  s.total_AB,
  s.total_H,
  s.total_BB,
  s.total_HBP,
  s.total_SH,
  s.total_SF,
  s.total_PA,
  s.batting_avg_x1000
FROM season_totals AS s
JOIN People AS p
  ON s.playerID = p.playerID
ORDER BY s.batting_avg_x1000 DESC;
