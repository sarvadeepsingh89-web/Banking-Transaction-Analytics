/* ==============================================================================
   Project: Banking Transaction Analytics
   Description: Database setup, table creation, and initial data loading
   Author: Data Analyst Portfolio
   ============================================================================== */

-- Create Database (Optional)
-- CREATE DATABASE BankingAnalytics;
-- GO
-- USE BankingAnalytics;
-- GO

-- ============================================================================
-- 1. Create Branches Table (Dimension)
-- ============================================================================
CREATE TABLE Branches (
    Branch_ID CHAR(4) PRIMARY KEY,
    Branch_Name VARCHAR(50) NOT NULL,
    City VARCHAR(30) NOT NULL,
    Region VARCHAR(20) NOT NULL
);

-- ============================================================================
-- 2. Create Customers Table (Dimension)
-- ============================================================================
CREATE TABLE Customers (
    Customer_ID CHAR(5) PRIMARY KEY,
    Gender VARCHAR(10) CHECK (Gender IN ('Male', 'Female', 'Other')),
    Age INT CHECK (Age BETWEEN 18 AND 100),
    Account_Type VARCHAR(20) CHECK (Account_Type IN ('Current', 'Savings', 'Salary')),
    Customer_Segment VARCHAR(20) CHECK (Customer_Segment IN ('SME', 'Corporate', 'Retail')),
    Home_Branch_ID CHAR(4) FOREIGN KEY REFERENCES Branches(Branch_ID),
    Join_Date DATE
);

-- ============================================================================
-- 3. Create Transactions Table (Fact)
-- ============================================================================
CREATE TABLE Transactions (
    Transaction_ID CHAR(7) PRIMARY KEY,
    Transaction_Date DATE,
    Customer_ID CHAR(5) FOREIGN KEY REFERENCES Customers(Customer_ID),
    Branch_ID CHAR(4) FOREIGN KEY REFERENCES Branches(Branch_ID),
    Transaction_Type VARCHAR(20) CHECK (Transaction_Type IN ('Card', 'UPI', 'NEFT', 'IMPS', 'ATM', 'Branch Transfer')),
    Channel VARCHAR(10) CHECK (Channel IN ('ATM', 'Branch', 'Mobile', 'POS', 'Web')),
    Amount_INR DECIMAL(12,2) CHECK (Amount_INR >= 0),
    Status VARCHAR(10) CHECK (Status IN ('Success', 'Failed')),
    Fee_Revenue_INR DECIMAL(8,2) CHECK (Fee_Revenue_INR >= 0)
);

-- ============================================================================
-- 4. Insert Data into Branches (8 rows — hardcoded)
-- ============================================================================
INSERT INTO Branches (Branch_ID, Branch_Name, City, Region)
VALUES 
    ('B001', 'Goregaon East', 'Mumbai', 'West'),
    ('B002', 'Andheri East', 'Mumbai', 'West'),
    ('B003', 'Powai', 'Mumbai', 'West'),
    ('B004', 'Bandra', 'Mumbai', 'West'),
    ('B005', 'Thane', 'Thane', 'West'),
    ('B006', 'Navi Mumbai', 'Navi Mumbai', 'West'),
    ('B007', 'Pune Central', 'Pune', 'West'),
    ('B008', 'Nashik', 'Nashik', 'West');

/* ==============================================================================
   DATA IMPORT INSTRUCTIONS
   ============================================================================== 

   For Customers and Transactions tables, use one of the following methods:

   METHOD 1: SSMS Import Wizard
   1. Open SQL Server Management Studio (SSMS).
   2. Right-click on the database → Tasks → Import Data.
   3. Data Source: Choose "Flat File Source" and select the CSV file 
      (Customers.csv or Transactions.csv from the data/ directory).
   4. Destination: Select the corresponding table.
   5. Map columns and execute.

   METHOD 2: BULK INSERT (from CSV files with proper dates)
   The CSV files in the data/ directory already have dates converted 
   to 'YYYY-MM-DD' format, so they can be imported directly:

   BULK INSERT Customers
   FROM 'C:\path\to\data\Customers.csv'
   WITH (
       FIRSTROW = 2,           -- Skip header row
       FIELDTERMINATOR = ',',
       ROWTERMINATOR = '\n',
       TABLOCK
   );

   BULK INSERT Transactions
   FROM 'C:\path\to\data\Transactions.csv'
   WITH (
       FIRSTROW = 2,
       FIELDTERMINATOR = ',',
       ROWTERMINATOR = '\n',
       TABLOCK
   );

   METHOD 3: If importing from Excel (dates as serial integers)
   Import into staging tables first, then convert dates:

   UPDATE Customers_Staging
   SET Join_Date = DATEADD(DAY, CAST(Join_Date_Int AS INT) - 2, '1900-01-01');

   UPDATE Transactions_Staging
   SET Transaction_Date = DATEADD(DAY, CAST(Transaction_Date_Int AS INT) - 2, '1900-01-01');
   ============================================================================== */
