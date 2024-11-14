-- ---------------------------------------------
--  		SYSTEM INFORMATION  
-- ---------------------------------------------





-- --------------------------------
-- List all Schemas in SQL Server Database 
SELECT * from INFORMATION_SCHEMA.SCHEMATA;


-- --------------------------------
-- Do we need clustered/Nonclustered indexes on tables ?
CREATE NONCLUSTERED INDEX indx_col_name ON TableName (tablename);


-- --------------------------------
-- Taking care of Authentication, Authorization and Encryption for data protection:



-- --------------------------------
-- database volume
SELECT 
    SUM(used_page_count) * 8.0 / 1024 AS UsedStorageInGB
FROM 
    sys.dm_pdw_nodes_db_partition_stats;




-- ---------------------------------------------
--  SELECT AND FILTER STATEMENTS, Azure Synapse  
-- ---------------------------------------------
-- select a column(col1) from database(TestDB) > schema (SchX) > table(Table1)
USE TestDB;
GO

SELECT [col1]
FROM [SchX].[Table1] 



-- --------------------------------
-- select a column(col1) from database(TestDB) > schema (SchX) > table(Table1), 
-- filter results to only include rows where column(col2) equals 'entity'
-- id est: retrieve all info about col1 with specified 'entity' in col2
USE TestDB;
GO

SELECT [col1]
FROM [SchX].[Table1] 
WHERE [col2] = 'entity' 


-- --------------------------------
-- select a column(col1) from database(TestDB) > schema (SchX) > table(Table1), 
-- remove duplicates
-- filter results to include rows where col2 equals 'entity'
-- count all the remaining rows
USE TestDB;
GO
WITH cte_name AS (
	SELECT
		col1,
		col2,
		ROW_NUMBER() OVER (PARTITION BY col1 ORDER BY (SELECT NULL)) AS rn
	FROM [SchX].[Table1] 
)
SELECT COUNT(*)
FROM cte_name
WHERE rn = 1 AND col2 = 'entity';

-- --------------------------------
-- select a column(col1) from database(TestDB) > schema (SchX) > table (Table1),
-- find min and max values from the column
-- return that as min_val, max_val
USE TestDB;
GO
SELECT
    MIN([NewColName]) AS min_val,
    MAX([NewColName]) AS max_val
FROM
    (SELECT DISTINCT [col1]
	FROM [SchX].[Table1] ) AS [NewColName];

-- --------------------------------
-- Database(TestDB) > schema (SchX) > table (Table1),
-- CTE to report several columns for person_id with specific condition SpeX
-- col1 = HbA1C, col2 = age, col3 = BMI, col4 = smoking_status
-- 
USE TestDB;
GO

WITH active_specific_condition AS (
	SELECT
		[col00],
		[col01],
		[col09]
	FROM [SchX].[Table1]

	-- AGE, BMI, SMOKER, DRINKER 
	JOIN [SchZ].[Table3]
	ON [SchX].[Table1].[PATIENT_ID] = [SchZ].[Table3].[PATIENT_ID] 

	-- SpX
	JOIN [SchY].[Table2]
	ON [SchX].[Table1].[PATIENT_ID] = [SchY].[Table2].[PATIENT_ID] 

	-- Filter Active Patients, Age >18 , specific_condition = SpX
	WHERE [SchX].[Table1].[PATIENT_ID] = 'ACTIVE' AND [SchY].[Table2].[specific_condition] < 'SpX' AND [SchZ].[Table3].[AGE] > 18
	GROUP BY [SchX].[Table1].[PATIENT_ID]
),
another_criteria AS (
	SELECT 
		[col88],
		[col45],
		[col33]
	FROM ...
	JOIN 
	HAVING COUNT([SchX].[Table1].[visits]) > 1
)
SELECT 
	[PATIENT_ID],
	[col1],
	[col2],
	[col3],
	[col4]
FROM active_specific_condition
UNION ALL 
SELECT 
	SUM ([col88]) AS sum_col88,
	[col6],
	[col7]
FROM another_criteria;








-- --------------------------------------
--  	    Continuity of Care 
-- --------------------------------------
--  The EHR database in which there is a table for consultation records called EHR_CONSULTS 
--  Unique patients can be found on DISTINCT [patient_id], [practice_name]
--  Looking at all the available information available with [consultation_date] > 2020
--  calculate n1,n2,n3,n4 n5,coci for each patient 
-- database  = EHR_PRIMARY_DATA
-- schema = [SchX]
-- table =  [EHR_CONSULTS]
-- columns: [patient_id], [practice_name], [consultation_date]

WITH ValidConsultations AS (
    SELECT *
    FROM EHR_PRIMARY_DATA.[SchX].[EHR_CONSULTS]
    WHERE [consultation_date] >= 2020
),
UniquePatients AS (
    SELECT DISTINCT [patient_id], [practice_name]
    FROM ValidConsultations
),
ConsultationCounts AS (
    SELECT
        p.[patient_id] AS patientID,
        p.[practice_name],
        SUM(CASE WHEN c.[consultation_date] BETWEEN 2020 AND 2021 THEN 1 ELSE 0 END) AS n1,
        SUM(CASE WHEN c.[consultation_date] BETWEEN 2021 AND 2022 THEN 1 ELSE 0 END) AS n2,
        SUM(CASE WHEN c.[consultation_date] BETWEEN 2022 AND 2023 THEN 1 ELSE 0 END) AS n3,
        SUM(CASE WHEN c.[consultation_date] BETWEEN 2023 AND 2024 THEN 1 ELSE 0 END) AS n4,
        SUM(CASE WHEN c.[consultation_date] BETWEEN 2024 AND 2025 THEN 1 ELSE 0 END) AS n5,
        CAST(SUM(CASE WHEN c.[consultation_date] BETWEEN 2020 AND 2025 THEN 1 ELSE 0 END) AS FLOAT) AS N
    FROM UniquePatients p
    JOIN ValidConsultations c ON p.[patient_id] = c.[patient_id] AND p.[practice_name] = c.[practice_name]
    GROUP BY p.[patient_id], p.[practice_name]
),
ContinuityIndex AS (
    SELECT 
        patientID,
        [practice_name],
        n1,
        n2,
        n3,
        n4,
        n5,
        N,
        (CAST(n1 * (n1 - 1) AS FLOAT) + 
         CAST(n2 * (n2 - 1) AS FLOAT) + 
         CAST(n3 * (n3 - 1) AS FLOAT) + 
         CAST(n4 * (n4 - 1) AS FLOAT) + 
         CAST(n5 * (n5 - 1) AS FLOAT)) / NULLIF(N * (N - 1), 0) AS coci
    FROM ConsultationCounts
)
SELECT 
    patientID,
    [practice_name],
    n1,
    n2,
    n3,
    n4,
    n5,
    coci
FROM ContinuityIndex;


-- -----------------------------------------------------------
--      Count of Patient Records on Frequency of Visits 
-- -----------------------------------------------------------
-- We define Frequency of Visits as the Count of Valid Patient Recordings during the year. 
-- The stats are driven for Counts of Patients for +1visits, +2visits, ...  
-- Setting search criteria for the last five years where [consultation_date] >= 2020,(year 2020 to 2024)
-- Unique patient records can be found on distinct [patient_id], [practice_name]
-- dataset: EHR_PRIMARY_DATA
-- Schema: [SchX]
-- Table: [EHR_CONSULTS]
-- Columns: [patient_id], [practice_name], [consultation_date]
-- Succeedingly the result can be plotted using Python 

WITH UniquePatients AS (
    SELECT 
        [practice_name], 
        [patient_id],
        COUNT(consultation_date) AS cnt
    FROM EHR_PRIMARY_DATA.[SchX].[EHR_CONSULTS]
    WHERE [consultation_date] >= 2020
    GROUP BY [practice_name], [patient_id]
),
VisitCounts AS (
    SELECT
        SUM(CASE WHEN cnt >= 1 THEN 1 ELSE 0 END) AS '+1visit',
        SUM(CASE WHEN cnt >= 2 THEN 1 ELSE 0 END) AS '+2visit',
        SUM(CASE WHEN cnt >= 3 THEN 1 ELSE 0 END) AS '+3visit',
        SUM(CASE WHEN cnt >= 4 THEN 1 ELSE 0 END) AS '+4visit',
        SUM(CASE WHEN cnt >= 4 THEN 1 ELSE 0 END) AS '+5visit'

    FROM UniquePatients
)
SELECT *
FROM VisitCounts;


-- --------------------------------------
--  		INSERT STATEMENTS 
-- --------------------------------------
-- Insert data into tables in SSMS studio:
USE OMOP;
GO

INSERT INTO [schema].[tableName] (
	[column1] ,[column2]
       ,[column3],[column3])

VALUES (123, NULL, 
	DEFAULT, 'str');