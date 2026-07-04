
# Monthly Revenue Trend

SELECT 
    DATE_FORMAT(InvoiceDate, '%Y-%m') AS yr_month,
    COUNT(DISTINCT InvoiceNo) AS num_orders,
    COUNT(DISTINCT CustomerID) AS num_customers,
    ROUND(SUM(Quantity * UnitPrice), 2) AS total_revenue
FROM online_retail
GROUP BY DATE_FORMAT(InvoiceDate, '%Y-%m')
ORDER BY yr_month;