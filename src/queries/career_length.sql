-- Calculate career length in years for players who played in 2024 season
-- but did not finish the season

SELECT
  playerID,
  nameFirst,
  nameLast,
  debut,
  finalGame,
  DATE_DIFF('year', CAST(debut AS DATE), CAST(finalGame AS DATE)) AS career_length_years
FROM People
WHERE finalGame >= '2024-03-28'
  AND finalGame < '2024-10-01'
ORDER BY debut ASC;
