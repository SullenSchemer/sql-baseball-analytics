#!/usr/bin/env Rscript

# Setup DuckDB connection to Lahman Baseball Database (Parquet format)
# Creates views for each table: Appearances, Batting, Fielding, People, Pitching, Salaries, Teams

library(tidyverse)
library(DBI)
library(duckdb)
library(here)

# Initialize DuckDB in-memory database
con <- dbConnect(duckdb())

# Path to parquet files
parquet_path <- here::here("data")

# Table names
tables <- c("Appearances", "Batting", "Fielding", "People", "Pitching", "Salaries", "Teams")

# Create views for each parquet file
walk(tables, \(tbl) {
  my_sql <- str_glue(
    "CREATE OR REPLACE VIEW {tbl}
     AS SELECT * FROM read_parquet('{parquet_path}/{tbl}.parquet');"
  )
  dbExecute(con, my_sql)
  cat("Created view:", tbl, "\n")
})

# Verify tables loaded
result <- dbGetQuery(con, "SHOW TABLES;")
cat("\nLoaded tables/views:\n")
print(result)

# Return connection for use in downstream scripts
con
