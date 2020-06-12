# ------------------------------------------------------------------------------
# ---- Load Libraries
# ------------------------------------------------------------------------------
library(openxlsx)
library(reshape2)
library(ggplot2)
library(dplyr)
library(magrittr)
library(scales)


# ------------------------------------------------------------------------------
# ---- Load Data
# ------------------------------------------------------------------------------
hv = read.csv("./data/home_values/Zip_Zhvi_SingleFamilyResidence.csv")

# ------------------------------------------------------------------------------
# ---- Wide to Long Format
# ------------------------------------------------------------------------------
id_names = names(hv)[grep("^X", x=names(hv), invert=T)]
hv_long = melt(
  hv, id.vars=id_names, variable.name="date", value.name="home_value") %>%
  mutate(
    date = as.Date(gsub("^X", "", date), "%Y.%m.%d")
  )

# ------------------------------------------------------------------------------
# ---- Make a plot
# ------------------------------------------------------------------------------
mn_zips = hv_long %>% 
  filter(RegionName %in% c("55408", "55112", "55102")) %>%
  mutate(
    RegionName = as.factor(RegionName)
  )

mn_zips %>% ggplot(aes(x=date, y=home_value, color=RegionName)) +
  geom_line() +
  scale_x_date(date_breaks = "1 year") +
  scale_y_continuous(labels=scales::dollar) +
  theme(axis.text.x = element_text(angle = 90, hjust = 1)) +
  xlab("") +
  ylab("Home Value") +
  ggtitle("Zillow Home value ('Typical' price by zip code)")
ggsave(filename="./data/plots/home_values.png")

# ------------------------------------------------------------------------------
# ---- Write to Postgres
# ------------------------------------------------------------------------------
hv_long = clean_names(hv_long) %>% rename(value_date=date)
conn = .conn_list$get_conn()
DBI::dbWriteTable(conn, "home_values", hv_long, append=T, row.names=F)
DBI::dbDisconnect(conn)