Continuity of Care Calculations for Electronic Health Records, reference: <a href="https://academic.oup.com/fampra/article/41/1/60/7504782" target="_blank">COCI</a>


I am about to organise and gather **patient encounter data** over a 5-years period time. 
<br/> Looking at yearly intervals
<br/>- N = Total number of visits for patient during 5 years  
<br/>- ni = number of visits per interval I, e.g. n1, n2, .., ni
<br/>- coci_patient_visit = {\sum(ni.(ni-1))}/N.(N-1), Note: the {\sum(ni.(ni-1))}/N.(N-1) is a measure of concentration or continuity for a period of time, with intervals of n1,n2,..., ni


<br/> In the joined, filtered structured table - setting the expression PatientEncounter, having the information of unique_patientID, n1,n2,...,n5, coci_patient_visit. where:



<br/>
Next step:
find COCI average for each period for all the patients

