/* ==============================================================================
   Project: Banking Transaction Analytics
   Description: Data Validation and Cleaning Checks
   Author: Data Analyst Portfolio
   
   Cleaning Decision: 
   No cleaning transformations required — data passed all validation checks. 
   The only transformation applied was converting Excel serial dates to SQL 
   DATE format (done in database_setup.sql).
   ============================================================================== */


-- ============================================================================
-- SECTION 1: Record Count Validation
-- Expected: Branches = 8, Customers = 500, Transactions = 5000
-- ============================================================================

SELECT 'Branches' AS Table_Name, COUNT(*) AS Record_Count FROM Branches
UNION ALL
SELECT 'Customers', COUNT(*) FROM Customers
UNION ALL
SELECT 'Transactions', COUNT(*) FROM Transactions;


-- ============================================================================
-- SECTION 2: NULL Value Checks
-- Expected: 0 NULLs in all critical columns
-- ============================================================================

-- Branches NULL check
SELECT 
    SUM(CASE WHEN Branch_ID IS NULL THEN 1 ELSE 0 END) AS Null_Branch_ID,
    SUM(CASE WHEN Branch_Name IS NULL THEN 1 ELSE 0 END) AS Null_Branch_Name,
    SUM(CASE WHEN City IS NULL THEN 1 ELSE 0 END) AS Null_City,
    SUM(CASE WHEN Region IS NULL THEN 1 ELSE 0 END) AS Null_Region
FROM Branches;

-- Customers NULL check
SELECT 
    SUM(CASE WHEN Customer_ID IS NULL THEN 1 ELSE 0 END) AS Null_Customer_ID,
    SUM(CASE WHEN Gender IS NULL THEN 1 ELSE 0 END) AS Null_Gender,
    SUM(CASE WHEN Age IS NULL THEN 1 ELSE 0 END) AS Null_Age,
    SUM(CASE WHEN Account_Type IS NULL THEN 1 ELSE 0 END) AS Null_Account_Type,
    SUM(CASE WHEN Customer_Segment IS NULL THEN 1 ELSE 0 END) AS Null_Segment,
    SUM(CASE WHEN Home_Branch_ID IS NULL THEN 1 ELSE 0 END) AS Null_Home_Branch,
    SUM(CASE WHEN Join_Date IS NULL THEN 1 ELSE 0 END) AS Null_Join_Date
FROM Customers;

-- Transactions NULL check
SELECT 
    SUM(CASE WHEN Transaction_ID IS NULL THEN 1 ELSE 0 END) AS Null_Txn_ID,
    SUM(CASE WHEN Transaction_Date IS NULL THEN 1 ELSE 0 END) AS Null_Txn_Date,
    SUM(CASE WHEN Customer_ID IS NULL THEN 1 ELSE 0 END) AS Null_Customer_ID,
    SUM(CASE WHEN Branch_ID IS NULL THEN 1 ELSE 0 END) AS Null_Branch_ID,
    SUM(CASE WHEN Transaction_Type IS NULL THEN 1 ELSE 0 END) AS Null_Txn_Type,
    SUM(CASE WHEN Channel IS NULL THEN 1 ELSE 0 END) AS Null_Channel,
    SUM(CASE WHEN Amount_INR IS NULL THEN 1 ELSE 0 END) AS Null_Amount,
    SUM(CASE WHEN Status IS NULL THEN 1 ELSE 0 END) AS Null_Status,
    SUM(CASE WHEN Fee_Revenue_INR IS NULL THEN 1 ELSE 0 END) AS Null_Fee
FROM Transactions;


-- ============================================================================
-- SECTION 3: Primary Key Uniqueness Checks
-- Expected: 0 duplicate rows returned per table
-- ============================================================================

-- Check for duplicate Branch_IDs
SELECT Branch_ID, COUNT(*) AS Cnt 
FROM Branches 
GROUP BY Branch_ID 
HAVING COUNT(*) > 1;

-- Check for duplicate Customer_IDs
SELECT Customer_ID, COUNT(*) AS Cnt 
FROM Customers 
GROUP BY Customer_ID 
HAVING COUNT(*) > 1;

-- Check for duplicate Transaction_IDs
SELECT Transaction_ID, COUNT(*) AS Cnt 
FROM Transactions 
GROUP BY Transaction_ID 
HAVING COUNT(*) > 1;


-- ============================================================================
-- SECTION 4: Referential Integrity Checks
-- Expected: 0 orphan records in all checks
-- ============================================================================

-- Transactions referencing non-existent Customers
SELECT COUNT(*) AS Orphan_Transactions_Customer
FROM Transactions t
LEFT JOIN Customers c ON t.Customer_ID = c.Customer_ID
WHERE c.Customer_ID IS NULL;

-- Transactions referencing non-existent Branches
SELECT COUNT(*) AS Orphan_Transactions_Branch
FROM Transactions t
LEFT JOIN Branches b ON t.Branch_ID = b.Branch_ID
WHERE b.Branch_ID IS NULL;

-- Customers referencing non-existent Home Branches
SELECT COUNT(*) AS Orphan_Customers_HomeBranch
FROM Customers c
LEFT JOIN Branches b ON c.Home_Branch_ID = b.Branch_ID
WHERE b.Branch_ID IS NULL;


-- ============================================================================
-- SECTION 5: Data Range Validation
-- Expected: 0 invalid records per check
-- ============================================================================

-- Age should be between 18 and 70
SELECT COUNT(*) AS Invalid_Age 
FROM Customers 
WHERE Age < 18 OR Age > 70;

-- Amount_INR should be > 0
SELECT COUNT(*) AS Invalid_Amount 
FROM Transactions 
WHERE Amount_INR <= 0;

-- Fee_Revenue_INR should be >= 0
SELECT COUNT(*) AS Negative_Fee 
FROM Transactions 
WHERE Fee_Revenue_INR < 0;

-- Transaction dates should be within 2025
SELECT COUNT(*) AS Out_Of_Range_Txn_Date 
FROM Transactions 
WHERE Transaction_Date < '2025-01-01' OR Transaction_Date > '2025-12-31';

-- Join dates should be within expected range (2022-01-01 to 2025-12-31)
SELECT COUNT(*) AS Out_Of_Range_Join_Date 
FROM Customers 
WHERE Join_Date < '2022-01-01' OR Join_Date > '2025-12-31';


-- ============================================================================
-- SECTION 6: Category Consistency Checks
-- Expected: Only valid categories returned
-- ============================================================================

-- Valid Transaction Types: Card, UPI, NEFT, IMPS, ATM, Branch Transfer
SELECT DISTINCT Transaction_Type FROM Transactions ORDER BY Transaction_Type;

-- Valid Channels: ATM, Branch, Mobile, POS, Web
SELECT DISTINCT Channel FROM Transactions ORDER BY Channel;

-- Valid Statuses: Success, Failed
SELECT DISTINCT Status FROM Transactions ORDER BY Status;

-- Valid Genders: Male, Female
SELECT DISTINCT Gender FROM Customers ORDER BY Gender;

-- Valid Account Types: Current, Savings, Salary
SELECT DISTINCT Account_Type FROM Customers ORDER BY Account_Type;

-- Valid Customer Segments: Corporate, Retail, SME
SELECT DISTINCT Customer_Segment FROM Customers ORDER BY Customer_Segment;


-- ============================================================================
-- SECTION 7: Business Logic Validation
-- ============================================================================

-- Failed transactions should have zero fee revenue
-- Expected: 0 rows (no failed transactions should have fees > 0)
SELECT COUNT(*) AS Failed_With_Fee 
FROM Transactions 
WHERE Status = 'Failed' AND Fee_Revenue_INR > 0;

-- Check if any transaction occurred before the customer's join date
-- Expected: Some transactions may predate join if join was backdated, but worth investigating
SELECT COUNT(*) AS Txn_Before_Join 
FROM Transactions t
JOIN Customers c ON t.Customer_ID = c.Customer_ID
WHERE t.Transaction_Date < c.Join_Date;


-- ============================================================================
-- SECTION 8: Full Row Duplicate Detection
-- Expected: 0 full duplicate rows
-- ============================================================================

SELECT 
    Transaction_ID, Transaction_Date, Customer_ID, Branch_ID, 
    Transaction_Type, Channel, Amount_INR, Status, Fee_Revenue_INR, 
    COUNT(*) AS Duplicate_Count
FROM Transactions
GROUP BY 
    Transaction_ID, Transaction_Date, Customer_ID, Branch_ID, 
    Transaction_Type, Channel, Amount_INR, Status, Fee_Revenue_INR
HAVING COUNT(*) > 1;


/* ==============================================================================
   CLEANING SUMMARY
   ==============================================================================
   
   All validation checks passed:
   ✅ No missing values (NULLs) in any column across all three tables
   ✅ No duplicate primary keys
   ✅ Full referential integrity — all foreign keys map to valid parent records
   ✅ All values within expected ranges (age, amounts, fees, dates)
   ✅ All categorical values are consistent and valid
   ✅ Failed transactions correctly have zero fee revenue
   ✅ No full duplicate rows detected
   
   Only transformation applied:
   ⚠️ Excel serial date integers converted to SQL DATE format during import
   
   ============================================================================== */
