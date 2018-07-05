library(readxl)
library(here)
library(janitor)
library(tidyverse)

cpr <- read_xlsx(here::here("data-raw", "00-xlsx",
                                     "contraception_gm.xlsx"),
                 sheet = 1) %>%
  clean_names() %>%
  select(geo_name = 1, everything()) %>%
  mutate(geo_name = recode(geo_name, "Central African Rep." = "Central African Republic"))

cpr_tidy <- cpr %>%
  gather(year, contraceptive_prev_rate, -geo_name, na.rm = TRUE) %>%
  mutate(year = parse_number(year))

#' Keep data from 1950 to 2014
year_min <- 1950
year_max <- 2014
cpr_tidy <- cpr_tidy %>%
  filter(year %>% between(year_min, year_max))
str(cpr_tidy)

write_csv(cpr_tidy, here::here("data-raw", "01-csv",
                                "contraception.csv"))
