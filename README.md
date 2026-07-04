# online-retail-rfm-analysis

# Customer Segmentation using RFM Analysis (SQL)

A SQL-based customer segmentation project using the **RFM (Recency, Frequency, Monetary)** framework on the Online Retail II dataset — identifying which customers to retain, win back, or deprioritize.

## Business Problem

A UK-based online gift-ware retailer has two years of transaction data but no clear view of which customers actually drive revenue. This project segments customers using RFM analysis to answer:
- Who are our most valuable customers?
- Who used to be valuable but is at risk of churning?
- Where should retention efforts be focused for maximum impact?

## Dataset

- **Source:** [UCI Machine Learning Repository — Online Retail II](https://archive.ics.uci.edu/dataset/502/online+retail+ii)
- **Size:** ~1.07 million transactions
- **Period:** December 1, 2009 – December 9, 2011
- **Fields:** InvoiceNo, StockCode, Description, Quantity, InvoiceDate, UnitPrice, CustomerID, Country

## Tools Used

- **MySQL** — data cleaning, RFM calculation, segmentation, aggregation
- **SQL concepts applied:** CTEs, window functions (`NTILE`), `CASE` statements, subqueries, `GROUP BY`/`HAVING`, date functions

## Project Workflow

### 1. Data Cleaning (`01_data_cleaning.sql`)
Raw data required cleaning before analysis:
- Removed **243,007 rows** with missing `CustomerID` — anonymous transactions can't be attributed to a customer segment
- Removed cancelled orders (`InvoiceNo` starting with `'C'`)
- Removed rows with zero or negative `Quantity`/`UnitPrice` (returns and data entry errors)
- **Result:** 1,067,371 → **805,531 clean rows**

### 2. RFM Calculation (`02_rfm_calculation.sql`)
For each customer, calculated:
- **Recency:** days since their most recent purchase
- **Frequency:** number of distinct orders placed
- **Monetary:** total amount spent

### 3. RFM Scoring (`02_rfm_calculation.sql`)
Used `NTILE(4)` window functions to rank customers into quartiles (1 = lowest, 4 = highest) independently on each of the three RFM dimensions.

### 4. Segment Labeling (`03_segment_summary.sql`)
Combined R/F/M scores into five business-relevant segments:

| Segment | Definition |
|---|---|
| **Champions** | Top quartile on all three dimensions — buy often, buy recently, spend the most |
| **Loyal Customers** | Consistently engaged, though not top spenders |
| **At Risk** | Previously frequent buyers who haven't purchased recently — win-back targets |
| **Needs Attention** | Mixed signals — worth monitoring |
| **Lost** | Low on all three dimensions — likely churned |

*Note: 13 customers (<0.3% of the base) had inconsistent `Country` values across orders and were excluded from the country-level breakdown to keep that analysis clean.*

## Key Findings

**1. Revenue is highly concentrated in a small customer segment**

| Segment | Customers | % of Base | Revenue | % of Revenue |
|---|---|---|---|---|
| Champions | 642 | 11.8% | ₹94.6L | **53.3%** |
| Loyal Customers | 1,401 | 25.7% | ₹41.6L | 23.4% |
| At Risk | 895 | 16.4% | ₹23.5L | 13.2% |
| Needs Attention | 1,152 | 21.1% | ₹11.9L | 6.7% |
| Lost | 1,788 | 32.8% | ₹5.8L | 3.3% |

➡️ **The top 11.8% of customers (Champions) generate over 53% of total revenue** — a clear Pareto pattern that supports prioritizing retention spend on this segment.

**2. Revenue is heavily concentrated in the UK**

The retailer's business is overwhelmingly domestic — the United Kingdom accounts for roughly **89% of total revenue**, with Ireland (EIRE), Netherlands, and Germany as distant secondary markets. This means the Champions/At-Risk segmentation above is effectively a UK-centric finding; other countries have too small a sample to segment reliably on their own.

**3. Revenue is strongly seasonal, peaking in November**

Both years in the dataset show a clear ramp-up from September through November, consistent with pre-holiday gift purchasing. December 2011 appears low in the trend data only because the dataset is truncated mid-month (through Dec 9), not due to an actual sales decline.

## Business Recommendations

- **Champions (53% of revenue):** Prioritize retention — loyalty perks, early access to new stock, personalized outreach
- **At Risk (13% of revenue):** Run targeted win-back campaigns before they fully churn
- **Loyal Customers:** Nurture toward Champion status with cross-sell/upsell offers
- **Lost:** Deprioritize active marketing spend; consider low-cost reactivation only
- Plan inventory and staffing around the **November peak** each year

## Repository Structure

```
online-retail-rfm-analysis/
├── README.md
├── 01_data_cleaning.sql
├── 02_rfm_calculation.sql
├── 03_segment_summary.sql
├── 04_segment_by_country.sql
├── 05_monthly_revenue_trend.sql
└── online_retail_combined.csv
```

## How to Reproduce

1. Download the dataset from here (https://archive.ics.uci.edu/dataset/502/online+retail+ii)
2. Create the `online_retail` table (schema in `01_data_cleaning.sql`)
3. Load the data using `LOAD DATA INFILE`
4. Run the SQL scripts in order (01 → 05)

## Author

Rajasri | Data Analyst (Fresher) | [LinkedIn] · [GitHub]
