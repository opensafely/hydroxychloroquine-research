/*==============================================================================
DO FILE NAME:			01_cr_create_asthma_population
PROJECT:				HCQ in COVID-19 
DATE: 					17 June 2020 
AUTHOR:					C Rentsch
						adapted from A Schultze 	 										
DESCRIPTION OF FILE:	program 01, HCQ project  
						check inclusion/exclusion citeria
						drop patients if not relevant 
DEPENDENCIES: 
DATASETS USED:			data in memory (from output/input.csv)

DATASETS CREATED: 		analysis_dataset.dta
						lives in folder $Tempdir 
OTHER OUTPUT: 			logfiles, printed to folder $Logdir

USER-INSTALLED ADO: 	datacheck 
  (place .ado file(s) in analysis folder)							
==============================================================================*/

* Open a log file

cap log close
log using $Logdir\01_cr_create_population, replace t


/* APPLY INCLUSION/EXCLUIONS==================================================*/ 

noi di "DROP MISSING GENDER:"
drop if inlist(sex,"I", "U")

noi di "DROP AGE <18:"
drop if age < 18 

noi di "DROP AGE >110:"
drop if age > 110 & age != .

noi di "DROP AGE MISSING:"
drop if age == . 

noi di "DROP IMD MISSING"
drop if imd == .u

noi di "DROP IF DEAD BEFORE INDEX"
drop if stime_$outcome  <= date("$indexdate", "DMY")

noi di "DROP EXPOSURE TO CHLOROQUINE"
drop if chloroquine_not_hcq == 1 




/* CHECK INCLUSION AND EXCLUSION CRITERIA=====================================*/ 

* DATA STRUCTURE: Confirm one row per patient 
duplicates tag patient_id, generate(dup_check)
assert dup_check == 0 
drop dup_check

* INCLUSION 1: RA or SLE in before exposure window, which begins 1 September 2019 
gen excl_ra = 1 if rheumatoid_date != . & rheumatoid_date >= mdy(9,1,2019)
recode excl_ra .=0
gen excl_sle = 1 if sle_date != . & sle_date >= mdy(9,1,2019)
recode excl_sle .=0

datacheck excl_ra==0, nol
datacheck excl_sle==0, nol
datacheck population != ., nol


* INCLUSION 2: >=18 and <=110 at 1 March 2020 
assert age < .
assert age >= 18 
assert age <= 110
 
 
* EXCLUSION 1: No chloroquine phosphate/sulfate exposure window
gen chlor_check = 1 if chloroquine_not_hcq == 1 
datacheck chlor_check >=., nol
drop chlor_check


* EXCLUSION 2: 12 months or baseline time 
* [CANNOT BE QUANTIFIED AS VARIABLE NOT EXPORTED] 


* EXCLUSION 3a: M or F gender at 1 March 2020 
assert inlist(sex, "M", "F")

* EXCLUSION 3b:  MISSING IMD
assert inlist(imd, 1, 2, 3, 4, 5)




* Close log file 
log close					   
