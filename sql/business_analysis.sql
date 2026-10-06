/* ==============================================================================
   Project: Banking Transaction Analytics
   Description: Business Analysis Queries (15 Queries)
   Author: Data Analyst Portfolio
   
   Each query answers a specific business question using appropriate SQL 
   techniques including JOINs, CTEs, window functions, CASE WHEN, and 
   aggregate functions.
   ============================================================================== */


-- ==============================================================================
-- QUERY 1: Overall KPI Summary
-- Business Question: What is the overall performance of the bank in terms of 
--   transaction volume, value, success rate, and fee revenue?
-- Techniques: Aggregates, CASE WHEN, ROUND
-- ==============================================================================

SELECT 
    COUNT(Transaction_ID)                                                       AS Total_Transactions,
    SUM(Amount_INR)                                                             AS Total_Value,
    ROUND(AVG(Amount_INR), 2)                                                   AS Avg_Transaction_Value,
    SUM(CASE WHEN Status = 'Success' THEN 1 ELSE 0 END)                        AS Success_Count,
    SUM(CASE WHEN Status = 'Failed'  THEN 1 ELSE 0 END)                        AS Failure_Count,
    ROUND(
        CAST(SUM(CASE WHEN Status = 'Success' THEN 1 ELSE 0 END) AS FLOAT) 
        / COUNT(Transaction_ID) * 100, 2
    )                                                                           AS Success_Rate_Pct,
    SUM(Fee_Revenue_INR)                                                        AS Total_Fee_Revenue
FROM Transactions;


-- ==============================================================================
-- QUERY 2: Monthly Transaction Trends
-- Business Question: How do transaction volumes and values trend across months?
-- Techniques: FORMAT, GROUP BY, ORDER BY
-- Interpretation: Identifies seasonality and peak months for transactions.
-- ==============================================================================

SELECT 
    FORMAT(Transaction_Date, 'yyyy-MM')     AS Transaction_Month,
    COUNT(Transaction_ID)                   AS Total_Transactions,
    SUM(Amount_INR)                         AS Total_Value,
    ROUND(AVG(Amount_INR), 2)               AS Avg_Value
FROM Transactions
GROUP BY FORMAT(Transaction_Date, 'yyyy-MM')
ORDER BY Transaction_Month;


-- ==============================================================================
-- QUERY 3: Month-over-Month Growth
-- Business Question: What is the monthly growth rate in transaction volume 
--   and value?
-- Techniques: CTE, LAG() window function
-- Interpretation: Assesses business momentum — identifies periods of 
--   contraction or expansion.
-- ==============================================================================

WITH MonthlyStats AS (
    SELECT 
        DATEPART(YEAR, Transaction_Date)    AS Txn_Year,
        DATEPART(MONTH, Transaction_Date)   AS Txn_Month,
        COUNT(Transaction_ID)               AS Txn_Count,
        SUM(Amount_INR)                     AS Total_Value
    FROM Transactions
    GROUP BY 
        DATEPART(YEAR, Transaction_Date), 
        DATEPART(MONTH, Transaction_Date)
)
SELECT 
    Txn_Year,
    Txn_Month,
    Txn_Count,
    Total_Value,
    LAG(Txn_Count) OVER (ORDER BY Txn_Year, Txn_Month)         AS Prev_Month_Count,
    ROUND(
        (CAST(Txn_Count AS FLOAT) 
         - LAG(Txn_Count) OVER (ORDER BY Txn_Year, Txn_Month))
        / NULLIF(LAG(Txn_Count) OVER (ORDER BY Txn_Year, Txn_Month), 0) * 100, 2
    )                                                           AS MoM_Count_Growth_Pct,
    LAG(Total_Value) OVER (ORDER BY Txn_Year, Txn_Month)       AS Prev_Month_Value,
    ROUND(
        (Total_Value 
         - LAG(Total_Value) OVER (ORDER BY Txn_Year, Txn_Month))
        / NULLIF(LAG(Total_Value) OVER (ORDER BY Txn_Year, Txn_Month), 0) * 100, 2
    )                                                           AS MoM_Value_Growth_Pct
FROM MonthlyStats
ORDER BY Txn_Year, Txn_Month;


-- ==============================================================================
-- QUERY 4: Transaction Type Analysis
-- Business Question: Which transaction types are most popular and which have 
--   the highest failure rates?
-- Techniques: GROUP BY, CASE WHEN, ORDER BY
-- Interpretation: Pinpoints operational bottlenecks and product adoption.
-- ==============================================================================

SELECT 
    Transaction_Type,
    COUNT(Transaction_ID)                   AS Volume,
    SUM(Amount_INR)                         AS Total_Value,
    ROUND(AVG(Amount_INR), 2)               AS Avg_Value,
    SUM(CASE WHEN Status = 'Failed' THEN 1 ELSE 0 END) AS Failed_Count,
    ROUND(
        CAST(SUM(CASE WHEN Status = 'Failed' THEN 1 ELSE 0 END) AS FLOAT) 
        / COUNT(Transaction_ID) * 100, 2
    )                                       AS Failure_Rate_Pct
FROM Transactions
GROUP BY Transaction_Type
ORDER BY Volume DESC;


-- ==============================================================================
-- QUERY 5: Channel Usage Analysis
-- Business Question: How are customers choosing to initiate their transactions?
-- Techniques: GROUP BY, CASE WHEN, percentage calculations
-- Interpretation: Guides IT infrastructure investment and digital transformation.
-- ==============================================================================

SELECT 
    Channel,
    COUNT(Transaction_ID)                   AS Volume,
    SUM(Amount_INR)                         AS Total_Value,
    ROUND(AVG(Amount_INR), 2)               AS Avg_Value,
    SUM(CASE WHEN Status = 'Failed' THEN 1 ELSE 0 END) AS Failed_Count,
    ROUND(
        CAST(SUM(CASE WHEN Status = 'Failed' THEN 1 ELSE 0 END) AS FLOAT) 
        / COUNT(Transaction_ID) * 100, 2
    )                                       AS Failure_Rate_Pct
FROM Transactions
GROUP BY Channel
ORDER BY Total_Value DESC;


-- ==============================================================================
-- QUERY 6: Failure Rate by Transaction Type × Channel
-- Business Question: Which specific type-channel combinations cause the most 
--   failures?
-- Techniques: Multi-column GROUP BY, CASE WHEN, HAVING
-- Interpretation: Provides actionable insights for IT to fix specific 
--   integration points.
-- ==============================================================================

SELECT 
    Transaction_Type,
    Channel,
    COUNT(Transaction_ID)                   AS Total_Attempts,
    SUM(CASE WHEN Status = 'Failed' THEN 1 ELSE 0 END) AS Failed_Attempts,
    ROUND(
        CAST(SUM(CASE WHEN Status = 'Failed' THEN 1 ELSE 0 END) AS FLOAT) 
        / COUNT(Transaction_ID) * 100, 2
    )                                       AS Failure_Rate_Pct
FROM Transactions
GROUP BY Transaction_Type, Channel
ORDER BY Failure_Rate_Pct DESC;


-- ==============================================================================
-- QUERY 7: Branch Performance Ranking
-- Business Question: How do branches rank by total transaction value, volume, 
--   and fee generation?
-- Techniques: JOIN, RANK() window function, GROUP BY
-- Interpretation: Identifies top-performing branches for reward and low 
--   performers for intervention.
-- ==============================================================================

SELECT 
    b.Branch_Name,
    b.City,
    COUNT(t.Transaction_ID)                 AS Transaction_Count,
    SUM(t.Amount_INR)                       AS Total_Value,
    ROUND(AVG(t.Amount_INR), 2)             AS Avg_Value,
    SUM(t.Fee_Revenue_INR)                  AS Total_Fee_Revenue,
    RANK() OVER (ORDER BY SUM(t.Amount_INR) DESC)  AS Rank_By_Value
FROM Branches b
LEFT JOIN Transactions t ON b.Branch_ID = t.Branch_ID
GROUP BY b.Branch_Name, b.City
ORDER BY Rank_By_Value;


-- ==============================================================================
-- QUERY 8: Top 10 Customers by Transaction Value
-- Business Question: Who are the bank's most valuable customers?
-- Techniques: JOIN, TOP, ORDER BY, GROUP BY
-- Interpretation: Identifies candidates for premium banking services and 
--   relationship management.
-- ==============================================================================

SELECT TOP 10
    c.Customer_ID,
    c.Customer_Segment,
    c.Account_Type,
    c.Gender,
    c.Age,
    COUNT(t.Transaction_ID)                 AS Total_Transactions,
    SUM(t.Amount_INR)                       AS Total_Value,
    ROUND(AVG(t.Amount_INR), 2)             AS Avg_Value
FROM Customers c
JOIN Transactions t ON c.Customer_ID = t.Customer_ID
WHERE t.Status = 'Success'
GROUP BY c.Customer_ID, c.Customer_Segment, c.Account_Type, c.Gender, c.Age
ORDER BY Total_Value DESC;


-- ==============================================================================
-- QUERY 9: Customer Segment Analysis
-- Business Question: How do different customer segments (Corporate, Retail, SME) 
--   compare in terms of volume, value, and failure rates?
-- Techniques: CTE, JOIN, GROUP BY, ROUND, CAST
-- Interpretation: Helps tailor product offerings and pricing by segment.
-- ==============================================================================

WITH SegmentStats AS (
    SELECT 
        c.Customer_Segment,
        COUNT(DISTINCT c.Customer_ID)       AS Customer_Count,
        COUNT(t.Transaction_ID)             AS Total_Transactions,
        SUM(t.Amount_INR)                   AS Total_Value,
        SUM(t.Fee_Revenue_INR)              AS Total_Fee_Revenue,
        SUM(CASE WHEN t.Status = 'Failed' THEN 1 ELSE 0 END) AS Failed_Txns
    FROM Customers c
    LEFT JOIN Transactions t ON c.Customer_ID = t.Customer_ID
    GROUP BY c.Customer_Segment
)
SELECT 
    Customer_Segment,
    Customer_Count,
    Total_Transactions,
    Total_Value,
    ROUND(Total_Value / NULLIF(Total_Transactions, 0), 2)                      AS Avg_Value_Per_Txn,
    ROUND(CAST(Total_Transactions AS FLOAT) / NULLIF(Customer_Count, 0), 2)    AS Avg_Txns_Per_Customer,
    ROUND(CAST(Failed_Txns AS FLOAT) / NULLIF(Total_Transactions, 0) * 100, 2) AS Failure_Rate_Pct,
    Total_Fee_Revenue
FROM SegmentStats
ORDER BY Total_Value DESC;


-- ==============================================================================
-- QUERY 10: Fee Revenue Analysis by Transaction Type and Branch
-- Business Question: Which transaction types and branches are driving the 
--   bank's fee revenue?
-- Techniques: JOIN, GROUP BY, aggregates, ORDER BY
-- Interpretation: Highlights profitable services and locations; guides fee 
--   strategy decisions.
-- ==============================================================================

SELECT 
    t.Transaction_Type,
    b.Branch_Name,
    COUNT(t.Transaction_ID)                 AS Txn_Count,
    SUM(t.Fee_Revenue_INR)                  AS Total_Fee_Revenue,
    ROUND(AVG(t.Fee_Revenue_INR), 2)        AS Avg_Fee_Per_Txn
FROM Transactions t
JOIN Branches b ON t.Branch_ID = b.Branch_ID
WHERE t.Fee_Revenue_INR > 0
GROUP BY t.Transaction_Type, b.Branch_Name
ORDER BY Total_Fee_Revenue DESC;


-- ==============================================================================
-- QUERY 11: Customer Activity Tiers
-- Business Question: How many customers fall into High, Medium, and Low 
--   activity tiers based on transaction count?
-- Techniques: CTE, CASE WHEN bucketing
-- Interpretation: Segments the user base for targeted engagement campaigns 
--   and loyalty programs.
-- ==============================================================================

WITH CustomerTxnCount AS (
    SELECT 
        Customer_ID,
        COUNT(Transaction_ID)               AS Txn_Count,
        SUM(Amount_INR)                     AS Total_Value
    FROM Transactions
    GROUP BY Customer_ID
),
Tiered AS (
    SELECT 
        Customer_ID,
        Txn_Count,
        Total_Value,
        CASE 
            WHEN Txn_Count > 15 THEN 'High (>15)'
            WHEN Txn_Count >= 8  THEN 'Medium (8-15)'
            ELSE 'Low (<8)'
        END AS Activity_Tier
    FROM CustomerTxnCount
)
SELECT 
    Activity_Tier,
    COUNT(Customer_ID)                      AS Customer_Count,
    SUM(Total_Value)                        AS Tier_Total_Value,
    ROUND(AVG(Total_Value), 2)              AS Tier_Avg_Value,
    ROUND(AVG(CAST(Txn_Count AS FLOAT)), 1) AS Avg_Txns_Per_Customer
FROM Tiered
GROUP BY Activity_Tier
ORDER BY 
    CASE Activity_Tier 
        WHEN 'High (>15)' THEN 1 
        WHEN 'Medium (8-15)' THEN 2 
        ELSE 3 
    END;


-- ==============================================================================
-- QUERY 12: Day-of-Week Transaction Patterns
-- Business Question: On which days of the week do we see the highest 
--   transaction activity?
-- Techniques: DATENAME, DATEPART, GROUP BY
-- Interpretation: Helps schedule maintenance during low-activity periods 
--   and plan staffing.
-- ==============================================================================

SELECT 
    DATENAME(WEEKDAY, Transaction_Date)     AS Day_Of_Week,
    COUNT(Transaction_ID)                   AS Total_Volume,
    SUM(Amount_INR)                         AS Total_Value,
    ROUND(AVG(Amount_INR), 2)               AS Avg_Value
FROM Transactions
GROUP BY 
    DATENAME(WEEKDAY, Transaction_Date), 
    DATEPART(WEEKDAY, Transaction_Date)
ORDER BY DATEPART(WEEKDAY, Transaction_Date);


-- ==============================================================================
-- QUERY 13: Quarterly Performance Comparison
-- Business Question: How does transaction performance compare quarter-over-quarter?
-- Techniques: CTE, DATEPART, LAG() window function
-- Interpretation: Provides a macro view of business growth trajectory.
-- ==============================================================================

WITH QuarterlyStats AS (
    SELECT 
        DATEPART(YEAR, Transaction_Date)    AS Txn_Year,
        DATEPART(QUARTER, Transaction_Date) AS Txn_Quarter,
        COUNT(Transaction_ID)               AS Txn_Count,
        SUM(Amount_INR)                     AS Total_Value,
        ROUND(AVG(Amount_INR), 2)           AS Avg_Value
    FROM Transactions
    GROUP BY 
        DATEPART(YEAR, Transaction_Date), 
        DATEPART(QUARTER, Transaction_Date)
)
SELECT 
    Txn_Year,
    'Q' + CAST(Txn_Quarter AS VARCHAR)      AS Quarter,
    Txn_Count,
    Total_Value,
    Avg_Value,
    LAG(Total_Value) OVER (ORDER BY Txn_Year, Txn_Quarter) AS Prev_Qtr_Value,
    ROUND(
        (Total_Value - LAG(Total_Value) OVER (ORDER BY Txn_Year, Txn_Quarter))
        / NULLIF(LAG(Total_Value) OVER (ORDER BY Txn_Year, Txn_Quarter), 0) * 100, 2
    )                                       AS QoQ_Growth_Pct
FROM QuarterlyStats
ORDER BY Txn_Year, Txn_Quarter;


-- ==============================================================================
-- QUERY 14: Age Group Segmentation
-- Business Question: How do transaction patterns differ across customer age 
--   demographics?
-- Techniques: CTE, CASE WHEN, JOINs, GROUP BY
-- Interpretation: Influences marketing strategies tailored to different 
--   age groups.
-- ==============================================================================

WITH AgeBuckets AS (
    SELECT 
        Customer_ID,
        Age,
        CASE 
            WHEN Age BETWEEN 18 AND 25 THEN '18-25'
            WHEN Age BETWEEN 26 AND 35 THEN '26-35'
            WHEN Age BETWEEN 36 AND 45 THEN '36-45'
            WHEN Age BETWEEN 46 AND 55 THEN '46-55'
            WHEN Age > 55              THEN '56-70'
            ELSE 'Unknown'
        END AS Age_Group
    FROM Customers
)
SELECT 
    a.Age_Group,
    COUNT(DISTINCT a.Customer_ID)           AS Customer_Count,
    COUNT(t.Transaction_ID)                 AS Total_Txns,
    SUM(t.Amount_INR)                       AS Total_Value,
    ROUND(AVG(t.Amount_INR), 2)             AS Avg_Value_Per_Txn,
    ROUND(
        CAST(COUNT(t.Transaction_ID) AS FLOAT) 
        / NULLIF(COUNT(DISTINCT a.Customer_ID), 0), 1
    )                                       AS Avg_Txns_Per_Customer
FROM AgeBuckets a
JOIN Transactions t ON a.Customer_ID = t.Customer_ID
GROUP BY a.Age_Group
ORDER BY a.Age_Group;


-- ==============================================================================
-- QUERY 15: High-Value Transaction Investigation
-- Business Question: What are the characteristics of the largest transactions 
--   (above ₹10,000)?
-- Techniques: Subquery, JOINs, WHERE, ORDER BY
-- Interpretation: Useful for liquidity planning, AML monitoring, and 
--   understanding high-value customer behaviour.
-- ==============================================================================

SELECT 
    t.Transaction_ID,
    t.Transaction_Date,
    t.Amount_INR,
    t.Fee_Revenue_INR,
    t.Status,
    c.Customer_ID,
    c.Customer_Segment,
    c.Account_Type,
    c.Age,
    b.Branch_Name,
    b.City,
    t.Transaction_Type,
    t.Channel
FROM Transactions t
JOIN Customers c ON t.Customer_ID = c.Customer_ID
JOIN Branches b ON t.Branch_ID = b.Branch_ID
WHERE t.Amount_INR > 10000
ORDER BY t.Amount_INR DESC;

-- Summary: Count and value of high-value transactions
SELECT 
    COUNT(*)                AS High_Value_Count,
    SUM(Amount_INR)         AS Total_High_Value,
    ROUND(AVG(Amount_INR), 2) AS Avg_High_Value,
    SUM(CASE WHEN Status = 'Failed' THEN 1 ELSE 0 END) AS Failed_High_Value
FROM Transactions
WHERE Amount_INR > 10000;
