## Real Estate Data

This project makes available a collection of datasets related to the real
estate, housing prices and ecconomic influences.

### Raw Data Sources

#### Home Sales
Number of home sales per month.

![Home Sales](/data/plots/home_sales.png)

Source: [Zillow Inventory and sales](https://www.zillow.com/research/data/) 

Grain is month/zip code.

#### Home Values
Value of the average home in a zip code.

Source: [Zillow Home Values](https://www.zillow.com/research/data/) 

![Home Values](/data/plots/home_values.png)

Grain is month/zip code.

#### IRS reported Adjustable gross income
Average adjustable gross income.  Grain is year/zip code. IRS maintains data
privacy to prevent individuals from being uniquely identified.
As a result, median adjustable gross income is not available and the number of
tax filers within a zip code has been rounded to the nearest 10. Never the
less, this should provide a fairly acurate representation of income within a
zip code.

Source: [SOI Tax Stats](https://www.irs.gov/statistics/soi-tax-stats-individual-income-tax-statistics-2017-zip-code-data-soi) 

![IRS Adjusted Gross Income](/data/plots/income.png)

Grain is year/zip code.

#### Mortage Rates
Average US wide mortgage rates for fixed rate 30 year and 15 year loans.

Source: [Saint Louis Fed]](https://fred.stlouisfed.org/categories/114)

![Mortgage Rates](/data/plots/mortgage_rates.png)

Grain is year/loan_length.

#### Unemployment
Average US unemployment rate.

Source: [Saint Louis Fed]](https://fred.stlouisfed.org/series/UNRATE)

![Unemployment Rates](/data/plots/unemployment_rates.png)

Grain is year.
