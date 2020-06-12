# ------------------------------------------------------------------------------
# ---- Load Libraries
# ------------------------------------------------------------------------------
library(openxlsx)
library(reshape2)
library(ggplot2)
library(dplyr)
library(magrittr)
library(scales)
library(janitor)
# library(seasonal)
# library(xts)

# ------------------------------------------------------------------------------
# ---- Load Data
# ------------------------------------------------------------------------------
# unzip files
zip_files = list.files("./data/irs", pattern = ".zip")
for (zf in zip_files) {
  year = gsub("[^0-9]", "", zf)
  year_dir = paste0("./data/irs/irs_", year)
  unzip(paste0("./data/irs/", zf), exdir=year_dir)
}

# Read irs data function, reads from file by year
read_irs = function(file, year) {
  irs = read.csv(file) %>%
    mutate(
      mean_agi_income = 1000 * A00100 / N00200, 
      date = as.Date(paste0(year, "-01-01")),
      income_year = year,
      year_filed = year+1) %>%
    select(
      STATEFIPS, STATE, ZIPCODE, A00100, N00200,  mean_agi_income,
      date, income_year, year_filed)
  return(irs)
}




# ------------------------------------------------------------------------------
# ---- Combine data from all years
# ------------------------------------------------------------------------------
irs_list = list()
for (yr in 2009:2017) {
  irs_file = "./data/irs/irs_%s/%szpallnoagi.csv"
  irs_file = sprintf(irs_file, yr, substr(as.character(yr), 3, 4))
  print(irs_file)
  irs_list[[as.character(yr)]] = read_irs(irs_file, yr)
}
irs_df = do.call(rbind.data.frame, irs_list)

# ------------------------------------------------------------------------------
# ---- Make a plot
# ------------------------------------------------------------------------------
irs_df %>% 
  filter(ZIPCODE %in% c(55408, 55112, 55102)) %>%
  mutate(ZIPCODE = as.factor(ZIPCODE)) %>%
  ggplot(aes(x=date, y=mean_agi_income, color=ZIPCODE)) +
  geom_line() +
  scale_x_date(date_breaks = "1 year") +
  scale_y_continuous(labels=scales::dollar) +
  theme(axis.text.x = element_text(angle = 90, hjust = 1)) +
  xlab("") +
  ylab("Adjusted Gross Income (AGI)") +
  ggtitle("IRS Income (Average AGI by zip code)")
ggsave(filename="./data/plots/income.png")

# ------------------------------------------------------------------------------
# ---- Write to Postgres
# ------------------------------------------------------------------------------
irs_df = clean_names(irs_df) %>% rename(value_date=date)
conn = .conn_list$get_conn()
DBI::dbWriteTable(conn, "irs", irs_df, append=T, row.names=F)
DBI::dbDisconnect(conn)