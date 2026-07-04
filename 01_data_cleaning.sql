CREATE DATABASE project_1;
USE project_1;

CREATE TABLE online_retail (
    InvoiceNo VARCHAR(20),
    StockCode VARCHAR(20),
    Description VARCHAR(255),
    Quantity INT,
    InvoiceDate DATETIME,
    UnitPrice DECIMAL(10,2),
    CustomerID INT,
    Country VARCHAR(50)
);
-- TRUNCATE TABLE online_retail;

LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/online_retail_combined.csv'
INTO TABLE online_retail
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS
(InvoiceNo, StockCode, Description, Quantity, @InvoiceDate, UnitPrice, @CustomerID, Country)
SET 
    InvoiceDate = STR_TO_DATE(@InvoiceDate, '%Y-%m-%d %H:%i:%s'),
    CustomerID = NULLIF(@CustomerID, '');
    
SELECT COUNT(*) FROM online_retail;
SELECT MIN(InvoiceDate), MAX(InvoiceDate) FROM online_retail;
SELECT * FROM online_retail LIMIT 10;

-- SET SQL_SAFE_UPDATES = 0;

DELETE FROM online_retail WHERE CustomerID IS NULL;
DELETE FROM online_retail WHERE InvoiceNo LIKE 'C%' OR Quantity <= 0 OR UnitPrice <= 0;

-- SET SQL_SAFE_UPDATES = 1; 

SELECT COUNT(*) FROM online_retail;