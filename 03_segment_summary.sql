
# Segment Labeling + Business Summary

-- RFM Customer Segmentation — Online Retail II Dataset
-- Segments customers based on Recency, Frequency, and Monetary value
-- to identify who to reward, who to win back, and who to let go.

WITH rfm_base AS (
    -- Step 1: Calculate raw RFM values per customer
    SELECT 
        CustomerID,
        -- Recency: days since their last purchase (lower = more engaged)
        DATEDIFF(
            (SELECT MAX(InvoiceDate) FROM online_retail), 
            MAX(InvoiceDate)
        ) AS recency,
        -- Frequency: how many separate orders they've placed
        COUNT(DISTINCT InvoiceNo) AS frequency,
        -- Monetary: total amount spent across all orders
        ROUND(SUM(Quantity * UnitPrice), 2) AS monetary
    FROM online_retail
    GROUP BY CustomerID
),

rfm_scores AS (
    -- Step 2: Rank customers into quartiles (1 = worst, 4 = best) on each dimension
    -- NTILE splits customers into 4 equal-sized groups per metric
    SELECT 
        CustomerID,
        recency,
        frequency,
        monetary,
        NTILE(4) OVER (ORDER BY recency DESC) AS r_score,   -- recent buyers score higher
        NTILE(4) OVER (ORDER BY frequency ASC) AS f_score,  -- frequent buyers score higher
        NTILE(4) OVER (ORDER BY monetary ASC) AS m_score    -- big spenders score higher
    FROM rfm_base
),

rfm_segments AS (
    -- Step 3: Translate scores into business-friendly customer segments
    SELECT 
        *,
        CASE 
            -- Top-tier customers: buy often, buy recently, spend the most
            WHEN r_score = 4 AND f_score = 4 AND m_score = 4 
                THEN 'Champions'

            -- Reliable, consistent customers — not top spenders, but engaged
            WHEN r_score >= 3 AND f_score >= 3 
                THEN 'Loyal Customers'

            -- Used to be valuable, but haven't purchased recently — win-back targets
            WHEN r_score <= 2 AND f_score >= 3 
                THEN 'At Risk'

            -- Rarely buy, haven't bought recently, spend little — likely churned
            WHEN r_score <= 2 AND f_score <= 2 AND m_score <= 2 
                THEN 'Lost'

            -- Everyone else — mixed signals, worth monitoring
            ELSE 'Needs Attention'
        END AS customer_segment
    FROM rfm_scores
)

-- Step 4: Summarize each segment's size and revenue contribution
SELECT 
    customer_segment,
    COUNT(*) AS num_customers,
    ROUND(AVG(monetary), 2) AS avg_spend,
    ROUND(SUM(monetary), 2) AS total_revenue,
    ROUND(SUM(monetary) * 100.0 / (SELECT SUM(monetary) FROM rfm_base), 2) AS pct_revenue
FROM rfm_segments
GROUP BY customer_segment
ORDER BY total_revenue DESC;

