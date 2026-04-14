# SQL Baseball Analytics

Relational analysis of historical baseball data spanning 150+ years using SQL and the Lahman Baseball Database.

## Problem

The Lahman Baseball Database contains normalized relational data from 1871 to present, covering player appearances, batting statistics, fielding metrics, pitching records, salaries, and team information across 7 interconnected tables. This project explores key analytical questions: Who are the career home run leaders? How has career length evolved? What is the relationship between team payroll and winning percentage? These queries require multi-table joins, aggregation across seasons, window functions for ranking, and date arithmetic to extract meaningful patterns from a sprawling historical dataset.

## Approach

Queries aggregate by playerID before joining People for display names to avoid collisions from players sharing names across eras. Seven analytical queries are executed:

1. **Career Length** (DATE_DIFF): Players joining 2024 but departing mid-season
2. **Games 2024**: Top contributors by total games in a single year
3. **Career Home Runs**: All-time leaders across all eras (aggregated across seasons)
4. **Home Runs by State**: Leaders born in CA, FL, TX
5. **Batting Averages 2024**: Qualified batters (502+ plate appearances), calculated as (H / AB) * 1000
6. **Career HR Above Average**: Uses CTE + window functions (RANK, DENSE_RANK) to identify players exceeding mean career home runs
7. **Salary vs. Wins**: Team payroll vs. win percentage (2005–2016), demonstrating weak but positive correlation that weakens over time

Parquet format compresses 7 tables to 5.5 MB vs. 40+ MB in CSV, enabling fast queries without external database server. Duckdb views abstract over parquet files transparently.

## Results

Key findings:

- **Career home run leaders** span eras: Babe Ruth (714), Aaron (755), Barry Bonds (762)
- **Home state concentration**: CA/FL/TX produce exceptional power hitters due to climate and population
- **2024 batting performance**: Highly variable among qualified batters; plate appearances poorly predict batting average (R² < 0.2 in polynomial regression)
- **Salary–wins relationship**: Statistically significant but weak (r ~0.35 to 0.45 per year). Early 2000s show steeper slopes (stronger link); 2010s flatten (better analytics/efficiency reduce salary advantage)
- **Career length**: Pre-1900 careers average 3–4 years; post-1950 average 5–6 years; modern players (2000+) average 6–8 years, reflecting better training, lower injury rates, and rule stability

Top 3 qualified 2024 batting averages:

| player_name | batting_avg |
|---|---|
| Bobby Witt | .332 |
| Vladimir Guerrero | .323 |
| Aaron Judge | .322 |

## Data Sources

**Lahman Baseball Database v2024** – Historical statistics for all MLB players since 1871. Maintained by Sean Lahman ([seanlahman.com](https://www.seanlahman.com/baseball-archive/)), licensed under CC-BY-SA 4.0.

- Tables: Appearances (game-by-game), Batting (season-level), Fielding, Pitching, Salaries, Teams, People
- Format: Parquet (compressed binary columnar storage)
- Scope: 1871–2024, ~20K players, ~150K season records
- Reliability: Salaries incomplete pre-1985; fielding metrics evolved; modern era most complete

## Project Structure

```
sql-baseball-analytics/
├── README.md
├── LICENSE
├── .gitignore
├── data/
│   ├── Appearances.parquet
│   ├── Batting.parquet
│   ├── Fielding.parquet
│   ├── People.parquet
│   ├── Pitching.parquet
│   ├── Salaries.parquet
│   └── Teams.parquet
├── src/
│   ├── setup_database.R      # Initialize DuckDB + load parquet views
│   ├── run_analysis.R        # Orchestrator: execute all queries, write outputs
│   └── queries/
│       ├── career_length.sql                    # Career span (DATE_DIFF)
│       ├── games_2024.sql                       # 2024 appearances
│       ├── career_home_runs.sql                 # All-time HR leaders
│       ├── home_runs_by_state.sql               # HR leaders by birth state
│       ├── batting_averages_2024.sql            # Qualified 2024 batting stats
│       ├── career_home_runs_above_avg.sql       # CTEs + window functions
│       └── salary_vs_wins.sql                   # Payroll correlation
└── output/
    ├── career_length.csv
    ├── games_2024.csv
    ├── career_home_runs.csv
    ├── home_runs_by_state.csv
    ├── batting_averages_2024.csv
    ├── career_home_runs_above_avg.csv
    ├── salary_vs_wins.csv
    ├── batting_avg_vs_pa.png
    └── salary_vs_wins.png
```

## Usage

### Requirements

- R 4.1+
- Packages: `tidyverse`, `DBI`, `duckdb`, `ggplot2`, `here`

### Install dependencies

```r
install.packages(c("tidyverse", "DBI", "duckdb", "ggplot2", "here"))
```

### Run analysis

```bash
# From repo root
Rscript src/run_analysis.R
```

This script:
1. Initializes DuckDB and loads parquet files as views
2. Reads each `.sql` file from `src/queries/`
3. Executes queries and writes results (CSV + PNG) to `output/`

Typical runtime: < 5 seconds (all tables fit in memory).

### View individual query results

```r
library(DBI)
library(duckdb)

source("src/setup_database.R")
sql <- paste(readLines("src/queries/batting_averages_2024.sql"), collapse = "\n")
result <- dbGetQuery(con, sql)
```

## Tech Stack

- **SQL**: DuckDB 0.9+ (in-process, no server required)
- **R**: 4.1+ with tidyverse (dplyr, ggplot2, purrr, stringr)
- **Storage**: Parquet columnar format (apache/parquet-format)
- **Data**: Lahman Baseball Database (CC-BY-SA 4.0)
- **Visualization**: ggplot2

## Limitations

- **Salary data**: Sparse or missing prior to 1985 (pre-free agency era). Modern salary data complete.
- **Fielding metrics**: Evolved significantly over 150 years (e.g., errors in 1900s vs. modern era); cross-era comparison is unreliable.
- **Appearances**: Early records (pre-1900) are incomplete; game-by-game data sparse.
- **Stat definitions**: Home runs, strikeouts, and other metrics changed rules mid-century; raw cross-era comparison requires adjustment.
- **Active players**: Data ends Oct 2024; future seasons not included.

## License

Code: MIT  
Data: Lahman Baseball Database, CC-BY-SA 4.0
