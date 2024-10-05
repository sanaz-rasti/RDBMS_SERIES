-- List all Schemas in SQL Server Database 
SELECT * from INFORMATION_SCHEMA.SCHEMATA;


-- Do we need clustered/Nonclustered indexes on tables ?
CREATE NONCLUSTERED INDEX indx_col_name ON TableName (tablename);


-- taking care of Authentication, Authorization and Encryption for data protection:

