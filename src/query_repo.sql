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

SELECT *
FROM [SchX].[col1] 
WHERE [col2] = 'entity' 


-- select a column(col1) from database(TestDB) > schema (SchX) > table(Table1), 







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