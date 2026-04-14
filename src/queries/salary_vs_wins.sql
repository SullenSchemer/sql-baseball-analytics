-- Team payroll vs. winning percentage by year and league
-- Years 2005–2016 when salary data is reliable

SELECT
  t.yearID,
  t.teamID,
  t.lgID AS League,
  t.W AS Wins,
  (t.G - t.W) AS Losses,
  CAST(t.W AS FLOAT) / t.G AS WinPct,
  SUM(s.salary) / 1000000.0 AS AvgSalary_Mil
FROM Teams AS t
JOIN Salaries AS s
  ON t.teamID = s.teamID AND t.yearID = s.yearID
WHERE t.yearID BETWEEN 2005 AND 2016
GROUP BY t.yearID, t.teamID, t.lgID, t.W, t.G;
