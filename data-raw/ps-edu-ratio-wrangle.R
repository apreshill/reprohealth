library(readxl)
library(here)
library(janitor)
library(tidyverse)

edu <- read_xlsx(here::here("data-raw", "00-xlsx",
                                "ps_edu_ratio_gm.xlsx"),
                 sheet = 1) %>%
  clean_names() %>%
  select(geo_name = 1, everything())

edu_tidy <- edu %>%
  gather(year, seratio, -geo_name, na.rm = TRUE) %>%
  mutate(year = parse_number(year))

#' Keep data from 1950 to 2014
year_min <- 1950
year_max <- 2014
edu_tidy <- edu_tidy %>%
  filter(year %>% between(year_min, year_max))
str(edu_tidy)

write_csv(edu_tidy, (here::here("data-raw", "01-csv",
                                    "ps_edu_ratio.csv")))
