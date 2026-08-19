-- queries.sql: ETL and analytical SQL queries

-- 1. Create staging table for raw data
CREATE TABLE StagingTelcoChurn (
    CustomerID VARCHAR(50) PRIMARY KEY,
    Gender VARCHAR(10),
    SeniorCitizen INT,
    Partner VARCHAR(5),
    Dependents VARCHAR(5),
    TenureMonths INT,
    PhoneService VARCHAR(5),
    MultipleLines VARCHAR(5),
    InternetService VARCHAR(20),
    OnlineSecurity VARCHAR(5),
    OnlineBackup VARCHAR(5),
    DeviceProtection VARCHAR(5),
    TechSupport VARCHAR(5),
    StreamingTV VARCHAR(5),
    StreamingMovies VARCHAR(5),
    ContractType VARCHAR(20),
    PaperlessBilling VARCHAR(5),
    PaymentMethod VARCHAR(50),
    MonthlyCharges DECIMAL(10,2),
    TotalCharges DECIMAL(10,2),
    ChurnFlag VARCHAR(5)   -- 'Yes' or 'No'
);

-- 2. Handle missing/inconsistent data (example: blank TotalCharges to NULL)
UPDATE StagingTelcoChurn
SET TotalCharges = NULL
WHERE TotalCharges = '' OR TotalCharges IS NULL;

-- Remove rows with null TotalCharges (if any)
DELETE FROM StagingTelcoChurn
WHERE TotalCharges IS NULL;

-- 3. Deduplicate records (if duplicates by CustomerID)
WITH CTE AS (
    SELECT CustomerID, ROW_NUMBER() OVER (PARTITION BY CustomerID ORDER BY CustomerID) AS rn
    FROM StagingTelcoChurn
)
DELETE FROM StagingTelcoChurn
WHERE CustomerID IN (SELECT CustomerID FROM CTE WHERE rn > 1);

-- 4. Create fact table with numeric churn flag
SELECT 
    CustomerID,
    Gender,
    SeniorCitizen,
    Partner,
    Dependents,
    TenureMonths,
    PhoneService,
    MultipleLines,
    InternetService,
    OnlineSecurity,
    OnlineBackup,
    DeviceProtection,
    TechSupport,
    StreamingTV,
    StreamingMovies,
    ContractType,
    PaperlessBilling,
    PaymentMethod,
    MonthlyCharges,
    TotalCharges,
    CASE WHEN ChurnFlag = 'Yes' THEN 1 ELSE 0 END AS ChurnNumeric
INTO FactTelcoChurn
FROM StagingTelcoChurn;

-- 5. Calculate overall churn metrics
SELECT 
    COUNT(*) AS TotalCustomers,
    SUM(ChurnNumeric) AS TotalChurners,
    (SUM(ChurnNumeric)*100.0 / COUNT(*)) AS ChurnRatePercent
FROM FactTelcoChurn;

-- 6. View: Churn by Contract Type
CREATE VIEW Vw_ChurnByContract AS
SELECT 
    ContractType,
    COUNT(*) AS Customers,
    SUM(ChurnNumeric) AS Churners,
    (SUM(ChurnNumeric)*100.0 / COUNT(*)) AS ChurnRatePercent
FROM FactTelcoChurn
GROUP BY ContractType;

-- 7. View: Churn by Payment Method
CREATE VIEW Vw_ChurnByPayment AS
SELECT 
    PaymentMethod,
    COUNT(*) AS Customers,
    SUM(ChurnNumeric) AS Churners,
    (SUM(ChurnNumeric)*100.0 / COUNT(*)) AS ChurnRatePercent
FROM FactTelcoChurn
GROUP BY PaymentMethod;

-- 8. View: Churn by Internet Service
CREATE VIEW Vw_ChurnByInternet AS
SELECT 
    InternetService,
    COUNT(*) AS Customers,
    SUM(ChurnNumeric) AS Churners,
    (SUM(ChurnNumeric)*100.0 / COUNT(*)) AS ChurnRatePercent
FROM FactTelcoChurn
GROUP BY InternetService;

-- 9. View: Churn by Tenure Band
CREATE VIEW Vw_ChurnByTenure AS
SELECT 
    CASE 
        WHEN TenureMonths < 12 THEN '0-11'
        WHEN TenureMonths < 24 THEN '12-23'
        WHEN TenureMonths < 48 THEN '24-47'
        ELSE '48+' 
    END AS TenureBand,
    COUNT(*) AS Customers,
    SUM(ChurnNumeric) AS Churners,
    (SUM(ChurnNumeric)*100.0 / COUNT(*)) AS ChurnRatePercent
FROM FactTelcoChurn
GROUP BY 
    CASE 
        WHEN TenureMonths < 12 THEN '0-11'
        WHEN TenureMonths < 24 THEN '12-23'
        WHEN TenureMonths < 48 THEN '24-47'
        ELSE '48+' 
    END;

-- 10. (Example) Insert churn summary per month (if a Date/Quarter field existed)
INSERT INTO ChurnMonthlySummary (YearMonth, TotalCustomers, TotalChurners, ChurnRate)
SELECT FORMAT(SubscriptionDate,'yyyy-MM'), COUNT(*), SUM(ChurnNumeric),  (SUM(ChurnNumeric)*100.0/COUNT(*))
FROM FactTelcoChurn
GROUP BY FORMAT(SubscriptionDate,'yyyy-MM');
