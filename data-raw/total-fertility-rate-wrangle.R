library(readxl)
library(here)
library(janitor)
library(tidyverse)

tfr <- read_xlsx(here::here("data-raw", "00-xlsx",
                            "total_fertility_rate_gm.xlsx"),
                 sheet = 2) %>%
  clean_names() %>%
  select(-starts_with("indicator"))

tfr_tidy <- tfr %>%
  gather(year, tfr, x1800:x2100, na.rm = TRUE) %>%
  mutate(year = parse_number(year))

#' Keep data from 1950 to 2014
year_min <- 1950
year_max <- 2014
tfr_tidy <- tfr_tidy %>%
  filter(year %>% between(year_min, year_max))
str(tfr_tidy)

write_csv(tfr_tidy, here::here("data-raw", "01-csv",
                               "total_fertility_rate.csv"))
