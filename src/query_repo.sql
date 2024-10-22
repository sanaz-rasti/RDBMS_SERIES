-- List all Schemas in SQL Server Database 
SELECT * from INFORMATION_SCHEMA.SCHEMATA;


-- Do we need clustered/Nonclustered indexes on tables ?
CREATE NONCLUSTERED INDEX indx_col_name ON TableName (tablename);


-- Taking care of Authentication, Authorization and Encryption for data protection:



-- Insert data into tables in SSMS studio:
USE OMOP;
GO

INSERT INTO [schema].[tableName] (
	[column1] ,[column2]
       ,[column3],[column3])

VALUES (123, NULL, 
	DEFAULT, 'str');