
# RFM Base Calculation

WITH rfm_base AS (
    SELECT 
        CustomerID,
        DATEDIFF(
            (SELECT MAX(InvoiceDate) FROM online_retail), 
            MAX(InvoiceDate)
        ) AS recency,
        COUNT(DISTINCT InvoiceNo) AS frequency,
        ROUND(SUM(Quantity * UnitPrice), 2) AS monetary
    FROM online_retail
    GROUP BY CustomerID
)
SELECT * FROM rfm_base
ORDER BY monetary DESC;


# RFM Scoring (Quartiles)

WITH rfm_base AS (
    SELECT 
        CustomerID,
        DATEDIFF(
            (SELECT MAX(InvoiceDate) FROM online_retail), 
            MAX(InvoiceDate)
        ) AS recency,
        COUNT(DISTINCT InvoiceNo) AS frequency,
        ROUND(SUM(Quantity * UnitPrice), 2) AS monetary
    FROM online_retail
    GROUP BY CustomerID
),
rfm_scores AS (
    SELECT 
        CustomerID,
        recency,
        frequency,
        monetary,
        NTILE(4) OVER (ORDER BY recency DESC) AS r_score,
        NTILE(4) OVER (ORDER BY frequency ASC) AS f_score,
        NTILE(4) OVER (ORDER BY monetary ASC) AS m_score
    FROM rfm_base
)
SELECT * FROM rfm_scores
ORDER BY CustomerID;

