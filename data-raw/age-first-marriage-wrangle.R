library(readxl)
library(here)
library(janitor)
library(tidyverse)

afm <- read_xlsx(here::here("data-raw", "00-xlsx",
                                     "age_first_marriage_gm.xlsx"),
                 sheet = 1) %>%
  clean_names() %>%
  select(geo_name = 1, everything()) %>%
  mutate(geo_name = recode(geo_name, "Central African rep." = "Central African Republic")) %>%
  mutate(geo_name = recode(geo_name, "VietNam" = "Vietnam"))

afm_tidy <- afm %>%
  gather(year, age_first_marriage, -geo_name, na.rm = TRUE) %>%
  mutate(year = parse_number(year))

#' Keep data from 1950 to 2014
year_min <- 1950
year_max <- 2014
afm_tidy <- afm_tidy %>%
  filter(year %>% between(year_min, year_max))
str(afm_tidy)

write_csv(afm_tidy, here::here("data-raw", "01-csv",
                                              "age_first_marriage.csv"))
