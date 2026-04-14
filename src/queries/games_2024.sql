-- Total games played by each player in the 2024 season
-- Shows most frequent contributors

SELECT
  p.playerID,
  p.nameFirst,
  p.nameLast,
  a.teamID,
  SUM(a.G_all) AS total_games
FROM People AS p
JOIN Appearances AS a
  ON p.playerID = a.playerID
WHERE a.yearID = 2024
GROUP BY p.playerID, p.nameFirst, p.nameLast, a.teamID
ORDER BY total_games DESC, p.nameLast ASC
LIMIT 8;
