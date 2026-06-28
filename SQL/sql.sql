CREATE TABLE Customers (
    CustomerID INT PRIMARY KEY,
    Country VARCHAR(100)
);
SELECT* from Customers
CREATE TABLE Products (
    StockCode VARCHAR(20) PRIMARY KEY,
    Description VARCHAR(255),
    Price DECIMAL(10,2)
);
CREATE TABLE Sales (
    Invoice VARCHAR(20),
    CustomerID INT,
    StockCode VARCHAR(20),
    Quantity INT,
    InvoiceDate DATETIME,

    FOREIGN KEY (CustomerID)
        REFERENCES Customers(CustomerID),

    FOREIGN KEY (StockCode)
        REFERENCES Products(StockCode)
);
SHOW TABLES;
SELECT
    YEAR(InvoiceDate),
    MONTH(InvoiceDate),
    SUM(Quantity * Price) AS Revenue
FROM cleaned_online_retail_50k
GROUP BY YEAR(InvoiceDate), MONTH(InvoiceDate);
SELECT
    YEAR(InvoiceDate) AS Year,
    ROUND(SUM(Quantity * Price), 2) AS Revenue
FROM cleaned_online_retail_50k
GROUP BY YEAR(InvoiceDate)
ORDER BY Year;
SELECT
    p.Description,
    SUM(s.Quantity) AS TotalQuantitySold
FROM Sales s
JOIN Products p
ON s.StockCode = p.StockCode
GROUP BY p.Description
ORDER BY TotalQuantitySold DESC
LIMIT 10;
SELECT Description,
       SUM(Quantity) AS TotalSold
FROM cleaned_online_retail_50k
GROUP BY Description
ORDER BY TotalSold DESC
LIMIT 10;
SELECT
    Description AS Category,
    SUM(Quantity * Price) AS TotalRevenue
FROM cleaned_online_retail_50k
GROUP BY Description
ORDER BY TotalRevenue DESC;
SELECT
    Description,
    SUM(Quantity * Price) AS TotalRevenue
FROM cleaned_online_retail_50k
GROUP BY Description
ORDER BY TotalRevenue ASC
LIMIT 10;
SELECT
    `Customer ID`,
    SUM(Quantity * Price) AS TotalRevenue,
    DENSE_RANK() OVER (
        ORDER BY SUM(Quantity * Price) DESC
    ) AS CustomerRank
FROM cleaned_online_retail_50k
GROUP BY `Customer ID` ;
SELECT
    `Customer ID`,
    SUM(Quantity * Price) AS TotalSpend,
    CASE
        WHEN SUM(Quantity * Price) >= 10000 THEN 'High Value'
        WHEN SUM(Quantity * Price) >= 5000 THEN 'Medium Value'
        ELSE 'Low Value'
    END AS CustomerSegment
FROM cleaned_online_retail_50k
GROUP BY `Customer ID`
ORDER BY TotalSpend DESC;
SELECT
    `Customer ID`,
    SUM(Quantity * Price) AS TotalSpend
FROM cleaned_online_retail_50k
GROUP BY `Customer ID`
HAVING TotalSpend >= 10000
ORDER BY TotalSpend DESC;
SHOW Tables;
DESCRIBE sales;
DESCRIBE products;


select*from products;
INSERT INTO products (StockCode, Description, Price)
SELECT DISTINCT
    StockCode,
    Description,
    Price
FROM cleaned_online_retail_50k;
SELECT COUNT(*) FROM products;
TRUNCATE TABLE products;
INSERT IGNORE INTO products (StockCode, Description, Price)
SELECT
    StockCode,
    MAX(Description),
    MAX(Price)
FROM cleaned_online_retail_50k
GROUP BY StockCode;
SELECT *FROM products;

SELECT*FROM Customers;
INSERT INTO customers (CustomerID, Country)
SELECT DISTINCT
    `Customer ID`,
    Country
FROM cleaned_online_retail_50k
WHERE `Customer ID` IS NOT NULL;
SELECT *FROM customers;
INSERT INTO sales (Invoice, StockCode, CustomerID, Quantity, InvoiceDate)
SELECT
    Invoice,
    StockCode,
    `Customer ID`,
    Quantity,
    InvoiceDate
FROM cleaned_online_retail_50k
WHERE `Customer ID` IS NOT NULL;
SELECT
    p.Description,
    SUM(s.Quantity * p.Price) AS TotalRevenue,
    SUM(s.Quantity) AS TotalUnitsSold
FROM sales s
JOIN products p
    ON s.StockCode = p.StockCode
GROUP BY p.Description
ORDER BY TotalRevenue DESC
LIMIT 100;
SELECT COUNT(*) FROM sales;
SELECT COUNT(*) FROM products;
SELECT COUNT(*) FROM customers;
SELECT DISTINCT s.StockCode
FROM sales s
LEFT JOIN products p
ON s.StockCode = p.StockCode
WHERE p.StockCode IS NULL
LIMIT 20;
SELECT
    p.Description,
    SUM(s.Quantity) AS UnitsSold,
    SUM(s.Quantity * p.Price) AS Revenue
FROM sales s
JOIN products p
ON s.StockCode = p.StockCode
GROUP BY p.Description
ORDER BY Revenue DESC
LIMIT 10;
SELECT
    p.Description,
    SUM(s.Quantity * p.Price) AS TotalProfit
FROM sales s
JOIN products p
    ON s.StockCode = p.StockCode
GROUP BY p.Description
ORDER BY TotalProfit DESC
LIMIT 10;
SELECT
    p.Description,
    SUM(s.Quantity * p.Price) AS Revenue,
    SUM(s.Quantity) AS UnitsSold
FROM sales s
JOIN products p
    ON s.StockCode = p.StockCode
GROUP BY p.Description
ORDER BY Revenue ASC
LIMIT 100;
SELECT *
FROM (
    SELECT
        CustomerID,
        TotalSpend,
        DENSE_RANK() OVER (ORDER BY TotalSpend DESC) AS CustomerRank
    FROM (
        SELECT
            s.CustomerID,
            SUM(s.Quantity * p.Price) AS TotalSpend
        FROM sales s
        JOIN products p
            ON s.StockCode = p.StockCode
        GROUP BY s.CustomerID
    ) t
) r
WHERE CustomerRank <= 10;
WITH CustomerSpend AS (
    SELECT
        s.CustomerID,
        SUM(s.Quantity * p.Price) AS TotalSpend
    FROM sales s
    JOIN products p
        ON s.StockCode = p.StockCode
    GROUP BY s.CustomerID
)
SELECT
    CustomerID,
    TotalSpend,
    CASE
        WHEN TotalSpend >= 10000 THEN 'High Value'
        WHEN TotalSpend >= 5000 THEN 'Medium Value'
        ELSE 'Low Value'
    END AS CustomerSegment
FROM CustomerSpend
ORDER BY TotalSpend DESC;
SELECT
    s.CustomerID,
    SUM(s.Quantity * p.Price) AS TotalSpend
FROM sales s
JOIN products p
    ON s.StockCode = p.StockCode
GROUP BY s.CustomerID
ORDER BY TotalSpend DESC
LIMIT 100;
CREATE TABLE top_tier_customers AS
SELECT
    s.CustomerID,
    SUM(s.Quantity * p.Price) AS TotalSpend,
    MAX(s.InvoiceDate) AS LastPurchaseDate,
    COUNT(DISTINCT s.Invoice) AS Frequency
FROM sales s
JOIN products p
    ON s.StockCode = p.StockCode
GROUP BY s.CustomerID
ORDER BY TotalSpend DESC;
SHOW variables LIKE 'secure_file_priv';
SELECT *
FROM top_tier_customers
INTO OUTFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/top_tier_customers.csv'
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n';
SELECT*FROM top_tier_customers;
SELECT
    p.Description,
    SUM(s.Quantity) AS UnitsSold,
    ROUND(SUM(s.Quantity * p.Price),2) AS Revenue
FROM sales s
JOIN products p
    ON s.StockCode = p.StockCode
GROUP BY p.Description
ORDER BY Revenue DESC
LIMIT 20;
DESC sales;
DESC products;
ALTER TABLE sales
ADD COLUMN Discount DECIMAL(5,2);
UPDATE sales
SET Discount =
CASE
    WHEN RAND() < 0.25 THEN 5
    WHEN RAND() < 0.50 THEN 10
    WHEN RAND() < 0.75 THEN 15
    ELSE 20
END;
SELECT
    p.Description,
    ROUND(AVG(s.Discount),2) AS AvgDiscount
FROM sales s
JOIN products p
ON s.StockCode = p.StockCode
GROUP BY p.Description
ORDER BY AvgDiscount DESC;
SELECT
    p.Description,
    ROUND(AVG(s.Discount),2) AS AvgDiscount,
    ROUND(SUM(s.Quantity * p.Price * (1 - s.Discount/100)),2) AS NetRevenue
FROM sales s
JOIN products p
ON s.StockCode = p.StockCode
GROUP BY p.Description
ORDER BY NetRevenue DESC;
SELECT
    p.Description AS Category,
    ROUND(AVG(s.Discount), 2) AS AvgDiscount
FROM sales s
JOIN products p
    ON s.StockCode = p.StockCode
GROUP BY p.Description
ORDER BY AvgDiscount DESC;
ALTER TABLE sales
ADD COLUMN Profit DECIMAL(10,2);
UPDATE sales s
JOIN products p
ON s.StockCode = p.StockCode
SET s.Profit = s.Quantity * p.Price * 0.20;
SELECT ROUND(SUM(Profit),2) AS TotalProfit
FROM sales;
SELECT
    p.Description,
    ROUND(SUM(s.Profit),2) AS TotalProfit
FROM sales s
JOIN products p
ON s.StockCode = p.StockCode
GROUP BY p.Description
ORDER BY TotalProfit DESC;
SELECT
    ROUND(
        (SUM(Profit) / SUM(s.Quantity * p.Price)) * 100,
        2
    ) AS ProfitMarginPct
FROM sales s
JOIN products p
ON s.StockCode = p.StockCode;
SELECT
    p.Description AS Category,
    ROUND(AVG(s.Discount), 2) AS AvgDiscount
FROM sales s
JOIN products p
    ON s.StockCode = p.StockCode
GROUP BY p.Description
ORDER BY AvgDiscount DESC;
SELECT ROUND(SUM(s.Quantity * p.Price),2) AS TotalRevenue
FROM sales s
JOIN products p
ON s.StockCode = p.StockCode;
SELECT
    YEAR(InvoiceDate) AS Year,
    MONTH(InvoiceDate) AS Month,
    ROUND(SUM(s.Quantity * p.Price),2) AS Revenue
FROM sales s
JOIN products p
ON s.StockCode = p.StockCode
GROUP BY YEAR(InvoiceDate), MONTH(InvoiceDate)
ORDER BY Year, Month;
SELECT
    s.CustomerID,
    ROUND(SUM(s.Quantity * p.Price),2) AS TotalSpend
FROM sales s
JOIN products p
ON s.StockCode = p.StockCode
GROUP BY s.CustomerID
ORDER BY TotalSpend DESC
LIMIT 10;
WITH CustomerSpend AS (
    SELECT
        s.CustomerID,
        SUM(s.Quantity * p.Price) AS TotalSpend
    FROM sales s
    JOIN products p
    ON s.StockCode = p.StockCode
    GROUP BY s.CustomerID
)
SELECT
    CustomerID,
    TotalSpend,
    CASE
        WHEN TotalSpend >= 10000 THEN 'High Value'
        WHEN TotalSpend >= 5000 THEN 'Medium Value'
        ELSE 'Low Value'
    END AS CustomerSegment
FROM CustomerSpend;
SELECT
    p.Description,
    ROUND(SUM(s.Quantity * p.Price),2) AS Revenue
FROM sales s
JOIN products p
ON s.StockCode = p.StockCode
GROUP BY p.Description
ORDER BY Revenue DESC
LIMIT 10;
SELECT
    p.Description,
    ROUND(SUM(s.Quantity * p.Price),2) AS Revenue
FROM sales s
JOIN products p
ON s.StockCode = p.StockCode
GROUP BY p.Description
ORDER BY Revenue ASC
LIMIT 10;
SELECT
    CustomerID,
    COUNT(DISTINCT Invoice) AS PurchaseFrequency
FROM sales
GROUP BY CustomerID
ORDER BY PurchaseFrequency DESC;
SELECT
    p.Description,
    ROUND(AVG(s.Discount),2) AS AvgDiscount
FROM sales s
JOIN products p
ON s.StockCode = p.StockCode
GROUP BY p.Description
ORDER BY AvgDiscount DESC;
SELECT
    p.Description,
    ROUND(SUM(s.Profit),2) AS TotalProfit
FROM sales s
JOIN products p
ON s.StockCode = p.StockCode
GROUP BY p.Description
ORDER BY TotalProfit DESC;
SELECT
    ROUND(SUM(s.Quantity * p.Price),2) AS Revenue,
    ROUND(SUM(s.Profit),2) AS Profit,
    ROUND(
        (SUM(s.Profit) /
        SUM(s.Quantity * p.Price)) * 100,2
    ) AS ProfitMarginPct
FROM sales s
JOIN products p
ON s.StockCode = p.StockCode;
SELECT
    s.CustomerID,
    SUM(s.Quantity * p.Price) AS TotalSpend,
    MAX(s.InvoiceDate) AS LastPurchaseDate,
    COUNT(DISTINCT s.Invoice) AS Frequency
FROM sales s
JOIN products p
ON s.StockCode = p.StockCode
GROUP BY s.CustomerID
ORDER BY TotalSpend DESC;
SELECT
    ROUND(SUM(Profit),2) AS RawTotalProfit
FROM sales;
SELECT*FROM products;
SELECT*FROM cleaned_online_retail_50k;
SELECT
    CustomerID,
    SUM(Quantity * Price) AS TotalSpend
FROM sales
GROUP BY CustomerID;
DESC sales;
SELECT
    CustomerID,
    SUM(Profit) AS TotalProfit,
    AVG(Discount) AS AvgDiscount
FROM sales
GROUP BY CustomerID;
SHOW COLUMNS FROM sales;
SELECT
    s.CustomerID,
    COUNT(DISTINCT s.Invoice) AS TotalOrders,
    SUM(s.Quantity) AS TotalQuantity,
    ROUND(AVG(s.Discount),2) AS AvgDiscount,
    SUM(s.Profit) AS TotalProfit,
    SUM(s.Quantity * p.Price) AS TotalRevenue
FROM sales s
JOIN products p
    ON s.StockCode = p.StockCode
GROUP BY s.CustomerID;
Describe sales;
SELECT
    `CustomerID`,
    DATEDIFF(
        (SELECT MAX(`InvoiceDate`) FROM sales),
        MAX(`InvoiceDate`)
    ) AS Recency
FROM sales
GROUP BY `CustomerID`;
SELECT
    `CustomerID`,
    COUNT(DISTINCT Invoice) AS Frequency
FROM sales
GROUP BY `CustomerID`;
SELECT
    `CustomerID`,
    DATEDIFF(
        (SELECT MAX(`InvoiceDate`) FROM sales),
        MAX(`InvoiceDate`)
    ) AS Recency,
    COUNT(DISTINCT Invoice) AS Frequency
FROM sales
GROUP BY `CustomerID`;
SELECT
    s.`CustomerID`,
    SUM(s.Quantity * p.Price) AS Monetary
FROM sales s
JOIN products p
    ON s.StockCode = p.StockCode
GROUP BY s.`CustomerID`;
WITH rfm AS (
    SELECT
        s.`CustomerID`,
        DATEDIFF(
            (SELECT MAX(`InvoiceDate`) FROM sales),
            MAX(s.`InvoiceDate`)
        ) AS Recency,
        COUNT(DISTINCT s.Invoice) AS Frequency,
        SUM(s.Quantity * p.Price) AS Monetary
    FROM sales s
    JOIN products p
        ON s.StockCode = p.StockCode
    GROUP BY s.`CustomerID`
)
SELECT *,
       NTILE(5) OVER (ORDER BY Recency DESC) AS R_Score,
       NTILE(5) OVER (ORDER BY Frequency) AS F_Score,
       NTILE(5) OVER (ORDER BY Monetary) AS M_Score
FROM rfm;
CREATE TABLE rfm_scores AS
SELECT
    s.`CustomerID`,
    DATEDIFF(
        (SELECT MAX(`InvoiceDate`) FROM sales),
        MAX(s.`InvoiceDate`)
    ) AS Recency,
    COUNT(DISTINCT s.Invoice) AS Frequency,
    SUM(s.Quantity * p.Price) AS Monetary
FROM sales s
JOIN products p
    ON s.StockCode = p.StockCode
GROUP BY s.`CustomerID`;
CREATE TABLE rfm_scores AS
SELECT
    s.CustomerID,
    DATEDIFF(
        (SELECT MAX(InvoiceDate) FROM sales),
        MAX(s.InvoiceDate)
    ) AS Recency,
    COUNT(DISTINCT s.Invoice) AS Frequency,
    SUM(s.Quantity * p.Price) AS Monetary
FROM sales s
JOIN products p
    ON s.StockCode = p.StockCode
GROUP BY s.CustomerID;
SELECT*FROM rfm_scores LIMIT 5;
SHOW Tables;
SELECT
    CustomerID,
    Recency,
    Frequency,
    Monetary,
    CASE
        WHEN Recency <= 30 AND Frequency >= 5 AND Monetary >= 1000
            THEN 'Champions'

        WHEN Recency <= 60 AND Frequency >= 3
            THEN 'Loyal Customers'

        WHEN Recency <= 30 AND Frequency <= 2
            THEN 'New Customers'

        WHEN Recency > 90 AND Frequency >= 3
            THEN 'At Risk'

        ELSE 'Others'
    END AS Segment
FROM rfm_scores;
SHOW Tables;
SELECT
    p.Description,
    s.CustomerID,
    SUM(s.Quantity * p.Price) AS TotalRevenue,
    SUM(s.Profit) AS TotalProfit,
    COUNT(*) AS TotalOrders,
    SUM(s.Quantity) AS TotalQuantity,
    AVG(s.Discount) AS AvgDiscount
FROM sales s
JOIN products p
    ON s.StockCode = p.StockCode
GROUP BY
    p.Description,
    s.CustomerID;