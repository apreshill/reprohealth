# get wbstats
# note that "country" contains a lot of non-countries
# will need to clean up with countrycode package
# decision: start at 2000
# end at 2015

library(wbstats)
library(tidyverse)
library(countrycode)
library(usethis)

inds <- c("NY.GDP.PCAP.CD", #gdppercap
          "SP.DYN.LE00.FE.IN",
          "SP.DYN.CONU.ZS",
          "SP.DYN.TFRT.IN",
          "SP.DYN.WFRT",
          "SH.STA.BRTC.ZS",
          "SH.STA.MMRT", #Maternal mortality ratio (modeled estimate)
          "SE.ENR.PRSC.FM.ZS")

mat_vars <- wbsearch(pattern = "maternal")

mat_long <- wb(indicator = inds,
               startdate = 2000, enddate = 2015)

# to do
# figure out how many years per country per measure

mat_long %>%
  count(indicator, sort = TRUE)


# most data for (1) fertility and (2) life expectancy and (3) gdp
# next level is (4) maternal mortality, (5) school enrollment
# then (x) births attended, (x) contraceptive prevalence
# (x) worst = wanted fertility rate

mat_long %>%
  distinct(indicatorID, indicator)

# fertility
tfr <- mat_long %>%
  filter(indicatorID == "SP.DYN.TFRT.IN")

ggplot(tfr, aes(x = date)) +
  geom_bar()

by_year <- tfr %>%
  count(date)

# how many years per country
by_country <- tfr %>%
  count(country)

# maternal mortality (modeled): see our world in data
mmr <- mat_long %>%
  filter(indicatorID == "SH.STA.MMRT")

ggplot(mmr, aes(x = date)) +
  geom_bar()

# school enrollment
# starts in 1990
segpi <- mat_long %>%
  filter(indicatorID == "SE.ENR.PRSC.FM.ZS")

ggplot(segpi, aes(x = date)) +
  geom_bar()

# how many years per country
by_country <- segpi %>%
  count(country)

inds_to_keep <- c("SP.DYN.LE00.FE.IN", # life expectancy
          "SP.DYN.TFRT.IN", # total fertility
          "SH.STA.MMRT", # Maternal mortality ratio (modeled estimate)
          "NY.GDP.PCAP.CD", #gdppercap
          "SE.ENR.PRSC.FM.ZS") #school

mat_long %>%
  filter(indicatorID %in% inds_to_keep) %>%
  ggplot(aes(x = date)) +
  geom_bar() +
  facet_wrap(~indicator)

mat_keep <- mat_long %>%
  filter(indicatorID %in% inds_to_keep) %>%
  mutate(country_name = countrycode(iso3c, "iso3c", "country.name"),
         iso_num = countrycode(country, "country.name", "iso3n"),
         continent = countrycode(country, "country.name", "continent"),
         region = countrycode(country, "country.name", "region")) %>%
  drop_na("country_name") %>%
  mutate(variable = case_when(
    indicatorID == "SP.DYN.LE00.FE.IN" ~ "life_exp",
    indicatorID == "SP.DYN.TFRT.IN" ~ "tot_fertility",
    indicatorID == "SH.STA.MMRT" ~ "mat_mortality",
    indicatorID == "NY.GDP.PCAP.CD" ~ "gdp_per_cap",
    indicatorID == "SE.ENR.PRSC.FM.ZS" ~ "edu_gen_parity"
  )) %>%
  select(iso_alpha = iso3c, everything(),
         -country, -contains("indicator")) %>%
  rename(country = country_name, year = date) %>%
  spread(variable, value)

#' Most countries do contribute data for 16 years. Who contributes less?
mat_keep %>%
  select(country, tot_fertility) %>%
  drop_na("tot_fertility") %>%
  count(country) %>%
  filter(n < max(n)) %>%
  arrange(n) %>%
  print(n = Inf)

#' I will let these countries go.
wb_reprohealth <- mat_keep %>%
  add_count(country) %>%
  filter(n == max(n)) %>%
  select(-n, -contains("iso")) %>%
  arrange(country, year)
glimpse(wb_reprohealth)

use_data(wb_reprohealth, overwrite = TRUE)
