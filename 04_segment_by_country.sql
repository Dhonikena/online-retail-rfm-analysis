
# Segment Breakdown by Country

-- Same RFM logic as 03_segment_summary.sql, extended with a Country breakdown.
-- Excludes 13 customers (<0.3% of base) who had inconsistent Country values
-- across their orders, to keep the country mapping clean and one-to-one.

WITH inconsistent_customers AS (
    SELECT CustomerID
    FROM online_retail
    GROUP BY CustomerID
    HAVING COUNT(DISTINCT Country) > 1
),

rfm_base AS (
    SELECT 
        CustomerID,
        Country,
        DATEDIFF(
            (SELECT MAX(InvoiceDate) FROM online_retail), 
            MAX(InvoiceDate)
        ) AS recency,
        COUNT(DISTINCT InvoiceNo) AS frequency,
        ROUND(SUM(Quantity * UnitPrice), 2) AS monetary
    FROM online_retail
    WHERE CustomerID NOT IN (SELECT CustomerID FROM inconsistent_customers)
    GROUP BY CustomerID, Country
),

rfm_scores AS (
    SELECT 
        CustomerID,
        Country,
        recency,
        frequency,
        monetary,
        NTILE(4) OVER (ORDER BY recency DESC) AS r_score,
        NTILE(4) OVER (ORDER BY frequency ASC) AS f_score,
        NTILE(4) OVER (ORDER BY monetary ASC) AS m_score
    FROM rfm_base
),

rfm_segments AS (
    SELECT 
        *,
        CASE 
            WHEN r_score = 4 AND f_score = 4 AND m_score = 4 THEN 'Champions'
            WHEN r_score >= 3 AND f_score >= 3 THEN 'Loyal Customers'
            WHEN r_score <= 2 AND f_score >= 3 THEN 'At Risk'
            WHEN r_score <= 2 AND f_score <= 2 AND m_score <= 2 THEN 'Lost'
            ELSE 'Needs Attention'
        END AS customer_segment
    FROM rfm_scores
)

SELECT 
    Country,
    customer_segment,
    COUNT(*) AS num_customers,
    ROUND(SUM(monetary), 2) AS total_revenue
FROM rfm_segments
GROUP BY Country, customer_segment
ORDER BY Country, total_revenue DESC;


--   Top country overall

WITH inconsistent_customers AS (
    SELECT CustomerID
    FROM online_retail
    GROUP BY CustomerID
    HAVING COUNT(DISTINCT Country) > 1
),

rfm_base AS (
    SELECT 
        CustomerID,
        Country,
        DATEDIFF(
            (SELECT MAX(InvoiceDate) FROM online_retail), 
            MAX(InvoiceDate)
        ) AS recency,
        COUNT(DISTINCT InvoiceNo) AS frequency,
        ROUND(SUM(Quantity * UnitPrice), 2) AS monetary
    FROM online_retail
    WHERE CustomerID NOT IN (SELECT CustomerID FROM inconsistent_customers)
    GROUP BY CustomerID, Country
),

rfm_scores AS (
    SELECT 
        CustomerID,
        Country,
        recency,
        frequency,
        monetary,
        NTILE(4) OVER (ORDER BY recency DESC) AS r_score,
        NTILE(4) OVER (ORDER BY frequency ASC) AS f_score,
        NTILE(4) OVER (ORDER BY monetary ASC) AS m_score
    FROM rfm_base
),

rfm_segments AS (
    SELECT 
        *,
        CASE 
            WHEN r_score = 4 AND f_score = 4 AND m_score = 4 THEN 'Champions'
            WHEN r_score >= 3 AND f_score >= 3 THEN 'Loyal Customers'
            WHEN r_score <= 2 AND f_score >= 3 THEN 'At Risk'
            WHEN r_score <= 2 AND f_score <= 2 AND m_score <= 2 THEN 'Lost'
            ELSE 'Needs Attention'
        END AS customer_segment
    FROM rfm_scores
)
SELECT Country, ROUND(SUM(monetary),2) AS total_revenue
FROM rfm_segments
GROUP BY Country
ORDER BY total_revenue DESC
LIMIT 10;




