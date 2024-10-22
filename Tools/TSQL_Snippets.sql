The Snippets facilitate 

-- Database




-- Tables

-- Insert into table 

USE OMOP;
GO

INSERT INTO [standardized_clinical_data].[person] 
    ([user_id] ,[user_name]
    ,[user_email],[year_of_birth]
    ,[month_of_birth], [day_of_birth]
    ,[birth_datetime], [race_concept_id]
    ,[race_source_value], [person_source_value]
    ,[gender_source_value], [gender_source_concept_id]
    ,[race_source_concept_id], [ethnicity_source_value]
    ,[ethnicity_source_concept_id]
    ,[location_id]
    ,[care_site_id]
    ,[provider_id] )

VALUES (123,'FirstName',
'firstname@email.com',2014,
09,23,
DEFAULT,00,
NULL,NULL,
NULL,NULL,
00,00,
0,
NULL,
NULL,
NULL);



