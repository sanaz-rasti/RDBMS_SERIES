Continuity of Care Calculations for Electronic Health Records, reference: <a href="https://academic.oup.com/fampra/article/41/1/60/7504782" target="_blank">COCI</a>


I am about to organise and gather **patient encounter data** over a 5-years period time. 
<br/> Looking at yearly intervals:
<br/>- N = Total number of visits for patient during 5 years  
<br/>- ni = number of visits per interval I, e.g. n1, n2, .., ni
<br/>- coci_patient_visit = $\frac{\sum (ni.(ni-1)) }{N.(N-1)}$, Note: the $\frac{\sum (ni.(ni-1)) }{N.(N-1)}$ is a measure of concentration or continuity for a period of time, with intervals of n1,n2,..., ni

<br/> - In Azure Synapse Environment having a database with the following information:
<br/>database  = EHR_PRIMARY_DATA
<br/>schema = [SchX]
<br/>table =  [EHR_CONSULTS]
<br/>column1 = [patient_id]
<br/>column2 = [practice_name]
<br/>column3 = [consultation_date]



[consultation_date] is coming in format of integer(e.g. 2022,2023)

USING SQL CTE we write a query:
1) Looking at all the available information available with [consultation_date] > 2020
2) Find Unique patients by distinct on  [patient_id], [practice_name]
3) for each patient calculate
- n1 = count of CONSULTATION_DATE records between 2020 and 2021
- n2 =count of CONSULTATION_DATE records between 2021 and 2022
- n3 = count of CONSULTATION_DATE records between 2022 and 2023
- n4 = count of CONSULTATION_DATE records between 2023 and 2024
- n5 =count of CONSULTATION_DATE records between 2024 and 2025
- N = n1+n2+n3+n4+n5
4) calculate Continuity of Care (coci) for each patient:
coci = n1*(n1-1)/N(N-1) + n2*(n2-1)/N(N-1) +n3*(n3-1)/N(N-1) +n4*(n4-1)/N(N-1) +n5*(n5-1)/N(N-1)

4) Return a table with following columns:
PatienID | practice_name | n1  |  n2  |  n3  |  n4  | n5 | coci 



The code can be found in src/query_repo.sql under section
<br/>-- --------------------------------------
<br/>--  	Continuity of Care 
<br/>-- --------------------------------------

