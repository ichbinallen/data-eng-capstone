# ------------------------------------------------------------------------------
# ---- Load Libraries
# ------------------------------------------------------------------------------
library(DBI)

# ------------------------------------------------------------------------------
# ---- Postgres Connection Object
# ------------------------------------------------------------------------------
.conn_list = list(
  drv = RPostgres::Postgres(),
  # user="",
  # password="",
  # host="",
  dbname="dengcapstone",
  port=5432
)

.conn_list$get_conn = function() {
  conn = RPostgres::dbConnect(
    drv=.conn_list$drv,
    # user=.conn_list$user,
    # password=.conn_list$password,
    # host=.conn_list$host,
    dbname=.conn_list$dbname,
    port=.conn_list$port,
  )
  return(conn)
}

# ------------------------------------------------------------------------------
# ---- SQL Statements
# ------------------------------------------------------------------------------
.conn_list$sql_statements = list(
  home_sales_create = "
  CREATE TABLE IF NOT EXISTS home_sales (
    region_id INT,
    region_name VARCHAR(10),
    state_name VARCHAR(20),
    size_rank INT,
    sale_date VARCHAR(10),
    home_sale_count INT
  );",
  home_sales_drop = "DROP TABLE IF EXISTS home_sales;",
  home_values_create = "
  CREATE TABLE IF NOT EXISTS home_values (
    region_id INT,
    size_rank INT,
    region_name VARCHAR(10),
    region_type VARCHAR(20),
    state_name VARCHAR(20),
    state VARCHAR(10),
    city VARCHAR(40),
    metro VARCHAR(80),
    county_name VARCHAR(40),
    value_date VARCHAR(10),
    home_value REAL
  );",
  home_values_drop = "DROP TABLE IF EXISTS home_values;",
  irs_create = "
  CREATE TABLE IF NOT EXISTS irs (
    statefips INT,
    state VARCHAR(10),
    zipcode varchar(10),
    a00100 REAL,
    n00200 REAL,
    mean_agi_income REAL,
    value_date VARCHAR(10),
    income_year INT,
    year_filed INT
  );",
  irs_drop = "drop table if exists irs;",
  mortgage_rates_create = "
  CREATE TABLE IF NOT EXISTS mortgage_rates (
    mortgage_date VARCHAR(10),
    mortgage_rate REAL,
    loan_length VARCHAR(10)
  );",
  mortgage_rates_drop = "drop table if exists mortgage_rates;",
  unemployment_create = "
  CREATE TABLE IF NOT EXISTS unemployment (
    unemployment_date VARCHAR(10),
    unemployment_rate REAL
  );",
  unemployment_drop = "drop table if exists unemployment;",
  home_values_fact_create = "
  CREATE TABLE IF NOT EXISTS home_values_fact (
    zipcode varchar(10),
    val_month INT,
    val_year INT,
    home_value REAL,
    home_sale_count INT,
    income REAL,
    mortgage_rate15 REAL,
    mortgage_rate30 REAL,
    unemployment_rate REAL
  );",
  home_values_fact_drop = "drop table if exists home_values_fact;"
)
