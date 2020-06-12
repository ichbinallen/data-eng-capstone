# ------------------------------------------------------------------------------
# ---- Load Libraries
# ------------------------------------------------------------------------------
library(openxlsx)
library(reshape2)
library(ggplot2)
library(dplyr)
library(magrittr)
library(scales)
library(jsonlite)

# ------------------------------------------------------------------------------
# ---- Load Data
# ------------------------------------------------------------------------------
unemp = read.csv("./data/unemployment/UNRATE.csv")
unemp$DATE = as.Date(unemp$DATE)

# ------------------------------------------------------------------------------
# ---- Make a plot
# ------------------------------------------------------------------------------
unemp %>% ggplot(aes(x=DATE, y=UNRATE / 100)) +
  geom_line() +
  scale_x_date(date_breaks = "10 years") +
  scale_y_continuous(labels=scales::percent) +
  theme(axis.text.x = element_text(angle = 90, hjust = 1)) +
  xlab("") +
  ylab("Unemployment Rate") +
  ggtitle("US Unemployment rates")
ggsave(filename="./data/plots/unemployment_rates.png")

# ------------------------------------------------------------------------------
# ---- Write to Postgres
# ------------------------------------------------------------------------------
unemp = clean_names(unemp) %>% 
  rename(unemployment_date = date, unemployment_rate = unrate)
conn = .conn_list$get_conn()
DBI::dbWriteTable(conn, "unemployment", unemp, append=T, row.names=F)
DBI::dbDisconnect(conn)