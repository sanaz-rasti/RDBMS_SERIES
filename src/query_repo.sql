-- ---------------------------------------------
--  		SYSTEM INFORMATION  
-- ---------------------------------------------






-- List all Schemas in SQL Server Database 
SELECT * from INFORMATION_SCHEMA.SCHEMATA;


-- Do we need clustered/Nonclustered indexes on tables ?
CREATE NONCLUSTERED INDEX indx_col_name ON TableName (tablename);


-- Taking care of Authentication, Authorization and Encryption for data protection:








-- ---------------------------------------------
--  SELECT AND FILTER STATEMENTS, Azure Synapse  
-- ---------------------------------------------
-- select a column(col1) from database(TestDB) > schema (SchX) > table(Table1)
USE TestDB;
GO

SELECT [col1]
FROM [SchX].[Table1] 


-- select a column(col1) from database(TestDB) > schema (SchX) > table(Table1), 
-- filter results to only include rows where column(col2) equals 'entity'
-- id est: retrieve all info about col1 with specified 'entity' in col2
USE TestDB;
GO

SELECT [col1]
FROM [SchX].[Table1] 
WHERE [col2] = 'entity' 



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