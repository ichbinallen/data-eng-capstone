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
# ---- Load Utilities
# ------------------------------------------------------------------------------
source("psql_conn.R")

# ------------------------------------------------------------------------------
# ---- Load Data
# ------------------------------------------------------------------------------
hs = read.csv("./data/home_sales/Sale_Counts_Zip.csv")

# ------------------------------------------------------------------------------
# ---- Wide to Long Format
# ------------------------------------------------------------------------------
date_names = names(hs)[grep("^X", x=names(hs), invert=F)]
hs_long = melt(
  hs, id.vars=c("RegionID", "RegionName", "StateName", "SizeRank"),
  measure.vars=date_names, variable.name="date", 
  value.name="home_sale_count") %>%
  mutate(date = as.Date(
    paste0(gsub("^X", "", date), ".01"), "%Y.%m.%d"
    )
  )


# ------------------------------------------------------------------------------
# ---- Seasonal Adjustment
# ------------------------------------------------------------------------------
# TODO: use seasonal adjustment on the home sales values

# ------------------------------------------------------------------------------
# ---- Make a plot
# ------------------------------------------------------------------------------
mn_zips = hs_long %>% 
  filter(RegionName %in% c("55408", "55112", "55102")) %>%
  mutate(
    RegionName = as.factor(RegionName)
  )

mn_zips %>% ggplot(aes(x=date, y=home_sale_count, color=RegionName)) +
  geom_line() +
  scale_x_date(date_breaks = "1 year") +
  # scale_y_continuous(labels=scales::dollar) +
  theme(axis.text.x = element_text(angle = 90, hjust = 1)) +
  xlab("") +
  ylab("Number of Sales") +
  ggtitle("Zillow Monthly Home Sale Count (Sales per month by zip code)")
ggsave(filename="./data/plots/home_sales.png")

# ------------------------------------------------------------------------------
# ---- Write to Postgres
# ------------------------------------------------------------------------------
hs_long = clean_names(hs_long) %>% rename(sale_date=date)
conn = .conn_list$get_conn()
DBI::dbWriteTable(conn, "home_sales", hs_long, append=T, row.names=F)
DBI::dbDisconnect(conn)
