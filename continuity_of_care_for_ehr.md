Continuity of Care Calculations for Electronic Health Records, reference: <a href="https://academic.oup.com/fampra/article/41/1/60/7504782" target="_blank">COCI</a>


I am about to organise and gather **patient encounter data** over a 5-years period time. 
<br/> Looking at yearly intervals:
<br/>- N = Total number of visits for patient during 5 years  
<br/>- ni = number of visits per interval I, e.g. n1, n2, .., ni
<br/>- coci_patient_visit = $\frac{\sum (ni.(ni-1)) }{N.(N-1)}$, Note: the $\frac{\sum (ni.(ni-1)) }{N.(N-1)}$ is a measure of concentration or continuity for a period of time, with intervals of n1,n2,..., ni

 - Having a database called EHR_PRIMARY_DATA
 - In which there is a table for consultation records called EHR_CONSULTS 
 - columns: [patient_id], [practice_name], [consultation_date]
 - Unique patients can be found on DISTINCT [patient_id], [practice_name]
 - Looking at all the available information available with [consultation_date] > 2020
 - calculate n1,n2,n3,n4 n5,coci for each patient 



The code can be found in src/query_repo.sql under section
<br/>-- --------------------------------------
<br/>--  	Continuity of Care 
<br/>-- --------------------------------------

