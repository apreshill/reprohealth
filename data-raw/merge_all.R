# make merged data file
# http://serialmentor.com/blog/2016/6/13/reading-and-combining-many-tidy-data-files-in-R

library(tidyverse)
library(countrycode)

data_path <- here::here("data-raw", "01-csv") # path to the data
files <- dir(data_path, pattern = "*.csv") # get file names

reprohealth <- files %>%
  # read in all the files, appending the path before the filename
  map(~ read_csv(file.path(data_path, .))) %>%
  reduce(dplyr::full_join) %>%
  select(country = geo_name, starts_with("iso"), year, everything(), -geo) %>%
  mutate(iso_alpha = countrycode(country, "country.name", "iso3c"),
         iso_num = countrycode(country, "country.name", "iso3n"),
         continent = countrycode(country, "country.name", "continent"),
         region = countrycode(country, "country.name", "region"))

#' During data exploration, I learned that most countries have data every five
#' years, e.g. 1952, 1957, 1962, and so on. Let's make that official.
reprohealth_test <- reprohealth %>%
  filter(year %% 5 == 2) %>%
  filter(year >= 1970)
glimpse(reprohealth_test)

reprohealth_5 <- reprohealth %>%
  filter(year >= 2000 & year <= 2015)

#' 15 years present and accounted for
reprohealth_5 %>%
  count(year)

#' Does every country contribute data for all 15 years?
reprohealth_5 %>%
  count(country) %>%
  count(n)
#' No, but most do (201)

reprohealth_5 %>%
  count(country)

ggplot(country_freq, aes(x = n)) +
  geom_histogram(binwidth = 1)

#' Most countries do contribute data for 15 years. Who contributes less?
reprohealth_5 %>%
  count(country) %>%
  filter(n < max(n)) %>%
  arrange(n) %>%
  print(n = Inf)

#' I will let these countries go.
reprohealth_5 <- reprohealth_5 %>%
  add_count(country) %>%
  filter(n == max(n)) %>%
  select(-n) %>%
  arrange(country, year)
glimpse(reprohealth_5)

#' Channel Islands and Netherlands Antilles won't have ISO
#' # English to ISO
countrycode('Channel Islands', 'country.name', 'iso.name.en')
countrycode('Channel Islands', 'country.name', 'wb')
countrycode('Netherlands Antilles', 'country.name', 'region')
countrycode('Netherlands Antilles', 'country.name', 'continent')

