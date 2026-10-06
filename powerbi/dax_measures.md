# DAX Measures Guide

This document contains all DAX measures for the Banking Transaction Analytics Power BI dashboard.

---

## 1. Creating the Measures Table

Best practice: Store all measures in a dedicated table to keep the model organized.

1. On the **Home** ribbon, click **Enter Data**.
2. In the dialog, rename the table to `_Measures` (the underscore keeps it at the top of the fields list).
3. Click **Load**.
4. Create your first measure in this table.
5. Once at least one measure exists, right-click `Column1` in the `_Measures` table → **Delete**.

> **Why a separate measures table?** It separates calculated metrics from raw data columns, making the model easier to navigate and maintain.

---

## 2. Core Transaction Measures

### Total Transactions
```dax
Total Transactions = COUNTROWS(Fact_Transactions)
```
- **Format**: Whole Number (0 decimals)
- **Description**: Count of all transaction records

---

### Total Transaction Value
```dax
Total Transaction Value = SUM(Fact_Transactions[Amount_INR])
```
- **Format**: Currency (₹) with 0 decimals
- **Description**: Sum of all transaction amounts in INR

---

### Avg Transaction Value
```dax
Avg Transaction Value = AVERAGE(Fact_Transactions[Amount_INR])
```
- **Format**: Currency (₹) with 2 decimals
- **Description**: Average transaction amount across all transactions

---

## 3. Status Measures

### Successful Transactions
```dax
Successful Transactions = 
CALCULATE(
    COUNTROWS(Fact_Transactions), 
    Fact_Transactions[Status] = "Success"
)
```
- **Format**: Whole Number
- **Description**: Count of transactions with Status = "Success"

---

### Failed Transactions
```dax
Failed Transactions = 
CALCULATE(
    COUNTROWS(Fact_Transactions), 
    Fact_Transactions[Status] = "Failed"
)
```
- **Format**: Whole Number
- **Description**: Count of transactions with Status = "Failed"

---

### Success Rate %
```dax
Success Rate % = 
DIVIDE(
    [Successful Transactions], 
    [Total Transactions], 
    0
)
```
- **Format**: Percentage with 2 decimals
- **Description**: Percentage of transactions that completed successfully

---

### Failure Rate %
```dax
Failure Rate % = 
DIVIDE(
    [Failed Transactions], 
    [Total Transactions], 
    0
)
```
- **Format**: Percentage with 2 decimals
- **Description**: Percentage of transactions that failed

---

## 4. Customer Measures

### Active Customers
```dax
Active Customers = 
DISTINCTCOUNT(Fact_Transactions[Customer_ID])
```
- **Format**: Whole Number
- **Description**: Count of unique customers who made at least one transaction

---

### Transactions per Customer
```dax
Transactions per Customer = 
DIVIDE(
    [Total Transactions], 
    [Active Customers], 
    0
)
```
- **Format**: Decimal (1 decimal place)
- **Description**: Average number of transactions per active customer

---

## 5. Revenue Measures

### Total Fee Revenue
```dax
Total Fee Revenue = SUM(Fact_Transactions[Fee_Revenue_INR])
```
- **Format**: Currency (₹) with 2 decimals
- **Description**: Sum of all fee revenue collected from transactions

---

### Avg Fee per Transaction
```dax
Avg Fee per Transaction = 
DIVIDE(
    [Total Fee Revenue], 
    [Total Transactions], 
    0
)
```
- **Format**: Currency (₹) with 2 decimals
- **Description**: Average fee revenue per transaction

---

## 6. Time Intelligence Measures

> **Prerequisite**: The `Dim_Date` table must be created, marked as a Date table, and connected to `Fact_Transactions[Transaction_Date]` via the `Date` column.

### Previous Month Transactions
```dax
Previous Month Transactions = 
CALCULATE(
    [Total Transactions], 
    DATEADD(Dim_Date[Date], -1, MONTH)
)
```
- **Format**: Whole Number
- **Description**: Transaction count from the previous month (for comparison)

---

### Previous Month Value
```dax
Previous Month Value = 
CALCULATE(
    [Total Transaction Value], 
    DATEADD(Dim_Date[Date], -1, MONTH)
)
```
- **Format**: Currency (₹)
- **Description**: Transaction value from the previous month

---

### MoM Transaction Growth %
```dax
MoM Transaction Growth % = 
VAR CurrentMonth = [Total Transactions]
VAR PreviousMonth = 
    CALCULATE(
        [Total Transactions], 
        DATEADD(Dim_Date[Date], -1, MONTH)
    )
RETURN 
    DIVIDE(
        CurrentMonth - PreviousMonth, 
        PreviousMonth, 
        0
    )
```
- **Format**: Percentage with 2 decimals
- **Description**: Month-over-month percentage change in transaction count

---

### MoM Value Growth %
```dax
MoM Value Growth % = 
VAR CurrentMonthValue = [Total Transaction Value]
VAR PreviousMonthValue = 
    CALCULATE(
        [Total Transaction Value], 
        DATEADD(Dim_Date[Date], -1, MONTH)
    )
RETURN 
    DIVIDE(
        CurrentMonthValue - PreviousMonthValue, 
        PreviousMonthValue, 
        0
    )
```
- **Format**: Percentage with 2 decimals
- **Description**: Month-over-month percentage change in transaction value

---

## 7. Measures Summary Table

| # | Measure Name | Category | Format |
|---|-------------|----------|--------|
| 1 | Total Transactions | Core | Whole Number |
| 2 | Total Transaction Value | Core | Currency ₹ |
| 3 | Avg Transaction Value | Core | Currency ₹ |
| 4 | Successful Transactions | Status | Whole Number |
| 5 | Failed Transactions | Status | Whole Number |
| 6 | Success Rate % | Status | Percentage |
| 7 | Failure Rate % | Status | Percentage |
| 8 | Active Customers | Customer | Whole Number |
| 9 | Transactions per Customer | Customer | Decimal |
| 10 | Total Fee Revenue | Revenue | Currency ₹ |
| 11 | Avg Fee per Transaction | Revenue | Currency ₹ |
| 12 | Previous Month Transactions | Time Intelligence | Whole Number |
| 13 | Previous Month Value | Time Intelligence | Currency ₹ |
| 14 | MoM Transaction Growth % | Time Intelligence | Percentage |
| 15 | MoM Value Growth % | Time Intelligence | Percentage |

---

## 8. How to Create a Measure in Power BI

1. In the **Fields** pane, click on the `_Measures` table.
2. On the **Modeling** tab (or Home tab), click **New Measure**.
3. In the formula bar, type the DAX formula from above.
4. Press **Enter** to confirm.
5. In the **Measure tools** tab that appears, set:
   - **Format**: Choose the appropriate format (Currency, Percentage, etc.)
   - **Home Table**: Ensure it shows `_Measures`
6. Repeat for all 15 measures.

> **Tip**: After creating all measures, organize them into display folders by right-clicking each measure → Properties → Display Folder. Suggested folders: `Core`, `Status`, `Customer`, `Revenue`, `Time Intelligence`.
