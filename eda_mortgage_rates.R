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
if(!file.exists("./data/mortgage_rates/mortgage_rates.json")) {
  # Read from csv
  mr15 = read.csv("./data/mortgage_rates/MORTGAGE15US.csv")
  mr30 = read.csv("./data/mortgage_rates/MORTGAGE30US.csv")
  # combine into one file
  names(mr15) = c("date", "mortgage_rate")
  mr15$loan_length = "15yr"
  names(mr30) = c("date", "mortgage_rate")
  mr30$loan_length = "30yr"
  mr = rbind.data.frame(mr30, mr15) %>% arrange(.by_group=date) %>%
    mutate(
      date = as.Date(date),
      year = format(date, "%Y")
  )
  # Write to JSON
  write_json(x=mr, path="./data/mortgage_rates/mortgage_rates.json")
} else {
  mr = as.data.frame(fromJSON(
    txt="./data/mortgage_rates/mortgage_rates.json"
  ))
}

# ------------------------------------------------------------------------------
# ---- Make a plot
# ------------------------------------------------------------------------------
mr %>% 
  mutate(date = as.Date(date)) %>%
  ggplot(aes(x=date, y=mortgage_rate / 100, color=loan_length)) +
  geom_line() +
  scale_x_date(date_breaks = "3 years") +
  scale_y_continuous(labels=scales::percent) +
  theme(axis.text.x = element_text(angle = 90, hjust = 1)) +
  xlab("") +
  ylab("Mortage Rate") +
  ggtitle("Countrywide mortgage rates")
ggsave(filename="./data/plots/mortgage_rates.png")