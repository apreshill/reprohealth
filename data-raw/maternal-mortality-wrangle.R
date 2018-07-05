library(readxl)
library(here)
library(janitor)
library(tidyverse)

mmr <- read_xlsx(here::here("data-raw", "00-xlsx",
                                     "maternal_mortality_ratio_gm.xlsx"),
                 sheet = 1) %>%
  clean_names() %>%
  select(geo_name = 1, everything())

mmr_tidy <- mmr %>%
  gather(year, mat_mortality_ratio, -geo_name, na.rm = TRUE) %>%
  mutate(year = parse_number(year))

#' Keep data from 1950 to 2014
year_min <- 1950
year_max <- 2014
mmr_tidy <- mmr_tidy %>%
  filter(year %>% between(year_min, year_max))
str(mmr_tidy)

write_csv(mmr_tidy, here::here("data-raw", "01-csv",
                                "mat_mortality_ratio.csv"))
