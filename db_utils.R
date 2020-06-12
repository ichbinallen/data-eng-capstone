# ------------------------------------------------------------------------------
# ---- Load Libraries
# ------------------------------------------------------------------------------
library(RPostgres)
source("psql_conn.R")

# ------------------------------------------------------------------------------
# ---- CREATE DIM TABLES STATEMENTS
# ------------------------------------------------------------------------------
create_tables = function() {
  conn = .conn_list$get_conn()
  dbExecute(conn, .conn_list$sql_statements$home_sales_create)
  dbExecute(conn, .conn_list$sql_statements$home_values_create)
  dbExecute(conn, .conn_list$sql_statements$irs_create)
  dbExecute(conn, .conn_list$sql_statements$mortgage_rates_create)
  dbExecute(conn, .conn_list$sql_statements$unemployment_create)
  DBI::dbDisconnect(conn)
}
create_tables()

# ------------------------------------------------------------------------------
# ---- CREATE FACT TABLE STATEMENTS
# ------------------------------------------------------------------------------
conn = .conn_list$get_conn()
dbExecute(conn, .conn_list$sql_statements$home_values_fact_create)
dbDisconnect(conn)

# ------------------------------------------------------------------------------
# ---- Load DIM TABLE DATA
# ------------------------------------------------------------------------------
source("eda_home_sales.R")
source("eda_home_values.R")
source("eda_irs.R")
source("eda_mortgage_rates.R")
source("eda_unemployment.R")

# ------------------------------------------------------------------------------
# ---- Load FACT TABLE DATA
# ------------------------------------------------------------------------------
conn = .conn_list$get_conn()
hs = dbGetQuery(
  conn,
  "SELECT
    region_name AS zipcode, 
    DATE_PART('month', TO_DATE(sale_date, 'YYYY-MM-DD')) AS val_month,
    DATE_PART('year', TO_DATE(sale_date, 'YYYY-MM-DD')) AS val_year,
    home_sale_count
  FROM
    home_sales;"
)
hv = dbGetQuery(
  conn,
  "SELECT
    region_name AS zipcode, 
    DATE_PART('month', TO_DATE(value_date, 'YYYY-MM-DD')) AS val_month,
    DATE_PART('year', TO_DATE(value_date, 'YYYY-MM-DD')) AS val_year,
    home_value
  FROM
    home_values;"
)
irs = dbGetQuery(
  conn,
  "SELECT
    zipcode,
    DATE_PART('year', TO_DATE(value_date, 'YYYY-MM-DD')) as val_year,
    mean_agi_income AS income
  FROM
    irs;"
)
mr = dbGetQuery(
  conn,
  "SELECT
     DATE_PART('year', TO_DATE(mortgage_date, 'YYYY-MM-DD')) AS val_year,
     DATE_PART('month', TO_DATE(mortgage_date, 'YYYY-MM-DD')) AS val_month,
     loan_length,
    AVG(mortgage_rate) as avg_mortgage_rate
   FROM
     mortgage_rates
   GROUP BY
    val_year, val_month, loan_length;"
)
mr = dcast(
  data=mr, 
  formula=val_year + val_month ~ loan_length, 
  value.var="avg_mortgage_rate"
)
names(mr) = c("val_year", "val_month", "mortgage_rate15", "mortgage_rate30")
unemp = dbGetQuery(
  conn, 
  "SELECT
     DATE_PART('year', TO_DATE(unemployment_date, 'YYYY-MM-DD')) AS val_year,
     DATE_PART('month', TO_DATE(unemployment_date, 'YYYY-MM-DD')) AS val_month,
     unemployment_rate
   FROM
    unemployment;"
)

hv_fact = hv %>% 
  left_join(hs, by=c("val_year", "val_month", "zipcode")) %>%
  left_join(irs, by=c("val_year", "zipcode")) %>%
  left_join(mr, by=c("val_year", "val_month")) %>%
  left_join(unemp, by=c("val_year", "val_month"))

dbWriteTable(conn, "home_values_fact", hv_fact, append=T, row.names=F)

# ------------------------------------------------------------------------------
# ---- Data Quality Check Section TABLES
# ------------------------------------------------------------------------------
dbGetQuery(conn, "SELECT count(*) FROM home_sales;")
dbGetQuery(conn, "SELECT count(*) FROM home_values;")
dbGetQuery(conn, "SELECT count(*) FROM irs;")
dbGetQuery(conn, "SELECT count(*) FROM mortgage_rates;")
dbGetQuery(conn, "SELECT count(*) FROM unemployment;")
dbGetQuery(conn, "SELECT count(*) FROM home_values_fact;")
DBI::dbDisconnect(conn)

# ------------------------------------------------------------------------------
# ---- DROP TABLES
# ------------------------------------------------------------------------------
drop_tables = function() {
  conn = .conn_list$get_conn()
  dbExecute(conn, .conn_list$sql_statements$home_sales_drop)
  dbExecute(conn, .conn_list$sql_statements$home_values_drop)
  dbExecute(conn, .conn_list$sql_statements$irs_drop)
  dbExecute(conn, .conn_list$sql_statements$unemployment_drop)
  dbExecute(conn, .conn_list$sql_statements$mortgage_rates_drop)
  dbExecute(conn, .conn_list$sql_statements$home_values_fact_drop)
  DBI::dbDisconnect(conn)
}
# drop_tables()