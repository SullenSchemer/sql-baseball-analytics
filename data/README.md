# Data: Lahman Baseball Database (Parquet Format)

## Files

Seven parquet files representing normalized relational tables:

| File | Records | Size | Description |
|---|---|---|---|
| People.parquet | ~20K | 438 KB | Player master: playerID, name, debut, finalGame, birthState |
| Batting.parquet | ~115K | 1.4 MB | Season-level batting stats: H, HR, AB, BB, etc. |
| Pitching.parquet | ~50K | 1.1 MB | Season-level pitching stats: W, L, ERA, SO |
| Appearances.parquet | ~105K | 1.1 MB | Game counts by position per player-year: G_all, G_C, G_1B, etc. |
| Fielding.parquet | ~70K | 1.4 MB | Fielding stats by position: POS, A (assists), E (errors) |
| Salaries.parquet | ~33K | 128 KB | Annual salaries 1985–2024; NULL pre-1985 |
| Teams.parquet | ~3K | 11 KB | Team-level records: W, L, G (games), teamID, lgID |

Total: ~5.5 MB (compressed)

## Source

**Lahman Baseball Database v2024**  
Maintained by Sean Lahman: [seanlahman.com/baseball-archive/](https://www.seanlahman.com/baseball-archive/)  
Licensed: CC-BY-SA 4.0

## Coverage

- **Time range**: 1871–2024
- **Scope**: All MLB regular season games
- **Players**: ~20,000 individuals
- **Seasons**: ~150 years

## Generating from Source

If parquet files are missing, regenerate from CRAN's Lahman package:

```r
# Install Lahman package
install.packages("Lahman")

# Load data
library(Lahman)

# Write to parquet
library(arrow)

tables <- c("People", "Batting", "Pitching", "Appearances", "Fielding", "Salaries", "Teams")

for (tbl in tables) {
  data <- get(tbl)
  arrow::write_parquet(data, paste0(tbl, ".parquet"))
}
```

Alternatively, download directly from the baseball archive:
- CSV files: https://www.seanlahman.com/baseball-archive/
- Parquet files (if available): https://www.seanlahman.com/baseball-archive/

## Notes

- Parquet format is **columnar and compressed**: 5.5 MB on disk vs. ~40 MB in CSV (7x reduction)
- No external database server required: DuckDB reads parquet transparently
- All character columns encoded UTF-8; dates in ISO format (YYYY-MM-DD)
- NA/NULL values preserved; use `IS NULL` in SQL filters
