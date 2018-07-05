library(readxl)
library(here)
library(janitor)
library(tidyverse)

pros <- read_xlsx(here::here("data-raw", "00-xlsx",
                                     "birth_pro_staff_gm.xlsx"),
                 sheet = 1) %>%
  clean_names() %>%
  select(geo_name = 1, everything()) %>%
  mutate(geo_name = recode(geo_name, "Central African Rep." = "Central African Republic"))

pros_tidy <- pros %>%
  gather(year, perc_births_attended, -geo_name, na.rm = TRUE) %>%
  mutate(year = parse_number(year))

#' Keep data from 1950 to 2014
year_min <- 1950
year_max <- 2014
pros_tidy <- pros_tidy %>%
  filter(year %>% between(year_min, year_max))
str(pros_tidy)

write_csv(pros_tidy, here::here("data-raw", "01-csv",
                                "birth_pro_staff.csv"))
