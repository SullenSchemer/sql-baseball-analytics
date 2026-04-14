#!/usr/bin/env Rscript

# Execute all analytical queries and write results to output/

library(tidyverse)
library(DBI)
library(duckdb)
library(here)

# Setup database
source(here("src/setup_database.R"))

# Get query directory
query_dir <- here("src/queries")

# Helper function to read and execute SQL query file
run_query <- \(filename) {
  query_path <- file.path(query_dir, filename)
  sql <- read_file(query_path)
  dbGetQuery(con, sql)
}

# ============================================================================
# Career Length: Players who played in 2024 but did not finish
# ============================================================================
cat("\n=== Career Length (2024 starters who left) ===\n")
career_length <- run_query("career_length.sql")
print(career_length)
write_csv(career_length, here("output/career_length.csv"))

# ============================================================================
# Games in 2024: Top contributors by appearances
# ============================================================================
cat("\n=== Games Played in 2024 (Top 8) ===\n")
games_2024 <- run_query("games_2024.sql")
print(games_2024)
write_csv(games_2024, here("output/games_2024.csv"))

# ============================================================================
# Career Home Runs: All-time leaders
# ============================================================================
cat("\n=== Career Home Run Leaders (Top 10) ===\n")
career_hr <- run_query("career_home_runs.sql")
print(career_hr)
write_csv(career_hr, here("output/career_home_runs.csv"))

# ============================================================================
# Home Runs by State: Leaders from CA, FL, TX
# ============================================================================
cat("\n=== Career Home Run Leaders (CA/FL/TX) ===\n")
hr_by_state <- run_query("home_runs_by_state.sql")
print(hr_by_state)
write_csv(hr_by_state, here("output/home_runs_by_state.csv"))

# ============================================================================
# Batting Averages 2024: Qualified batters (502+ PA)
# ============================================================================
cat("\n=== 2024 Batting Averages (Qualified) ===\n")
batting_avg_2024 <- run_query("batting_averages_2024.sql")
print(batting_avg_2024)
write_csv(batting_avg_2024, here("output/batting_averages_2024.csv"))

# ============================================================================
# Career HR Above Average: Players ranked by HR with window functions
# ============================================================================
cat("\n=== Players Above Average Career HR (Ranks 101-110) ===\n")
hr_above_avg <- run_query("career_home_runs_above_avg.sql")
print(hr_above_avg)
write_csv(hr_above_avg, here("output/career_home_runs_above_avg.csv"))

# ============================================================================
# Salary vs Wins: Team payroll correlation 2005-2016
# ============================================================================
cat("\n=== Team Salary vs Wins (2005-2016) ===\n")
salary_wins <- run_query("salary_vs_wins.sql")
print(head(salary_wins, 20))
write_csv(salary_wins, here("output/salary_vs_wins.csv"))

# ============================================================================
# Visualize: Batting Average vs Plate Appearances (2024 qualified)
# ============================================================================
library(ggplot2)

batting_viz <- batting_avg_2024 %>%
  mutate(batting_avg = batting_avg_x1000 / 1000)

p1 <- ggplot(batting_viz, aes(x = total_PA, y = batting_avg)) +
  geom_point(color = "black", alpha = 0.7, size = 2) +
  geom_smooth(method = "lm", se = FALSE, color = "red", linewidth = 1) +
  geom_smooth(method = "loess", se = FALSE, color = "blue", linewidth = 1) +
  labs(
    title = "2024 Batting Average vs. Plate Appearances",
    subtitle = "Qualified batters (502+ PA)",
    x = "Total Plate Appearances",
    y = "Batting Average"
  ) +
  theme_minimal(base_size = 11) +
  theme(plot.title = element_text(face = "bold", hjust = 0.5),
        plot.subtitle = element_text(size = 10, hjust = 0.5))

ggsave(here("output/batting_avg_vs_pa.png"), p1, width = 7, height = 5, dpi = 150)
cat("\nSaved: batting_avg_vs_pa.png\n")

# ============================================================================
# Visualize: Team Salary vs. Wins (2005-2016 faceted by year)
# ============================================================================

p2 <- ggplot(salary_wins, aes(x = AvgSalary_Mil, y = WinPct, color = League)) +
  geom_point(size = 2, alpha = 0.7) +
  geom_smooth(method = "lm", se = FALSE, linewidth = 0.8) +
  facet_wrap(~yearID, ncol = 4) +
  scale_color_manual(values = c("AL" = "#1f77b4", "NL" = "#e15759")) +
  labs(
    title = "Team Salary vs. Winning Percentage (2005–2016)",
    subtitle = "Do higher budgets buy more wins?",
    x = "Total Team Payroll (Millions USD)",
    y = "Win Percentage",
    color = "League"
  ) +
  theme_minimal(base_size = 10) +
  theme(plot.title = element_text(face = "bold", hjust = 0.5),
        plot.subtitle = element_text(size = 9, hjust = 0.5),
        legend.position = "right")

ggsave(here("output/salary_vs_wins.png"), p2, width = 12, height = 8, dpi = 150)
cat("Saved: salary_vs_wins.png\n")

# ============================================================================
# Close connection
# ============================================================================
dbDisconnect(con, shutdown = TRUE)
cat("\nDatabase connection closed.\n")
cat("Analysis complete. Results written to output/\n")
