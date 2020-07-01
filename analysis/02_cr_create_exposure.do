/*==============================================================================
DO FILE NAME:			02_cr_create_asthma_exposure
PROJECT:				HCQ in COVID-19 
DATE: 					17 June 2020 
AUTHOR:					C Rentsch
						adapted from A Schultze 	 								
DESCRIPTION OF FILE:	create exposure of interest 
DATASETS USED:			data in memory (from output/input.csv)

DATASETS CREATED: 		analysis_dataset.dta
						analysis_dataset_STSET_cpnsdeath.dta 
						both live in folder output/$tempdir
OTHER OUTPUT: 			logfiles, printed to folder output/$logdir
							
==============================================================================*/



* Open a log file

cap log close
log using $Logdir\02_cr_create_exposure, replace t

/* TREATMENT EXPOSURE=========================================================*/	

/* SABA ONLY */ 

* At least one prescription of SABA single 
gen exposure=hcq  

						
label define exposure 0 "No HCQ" 1 "HCQ"
label values exposure exposure 

label var exposure "HCQ Exposure"

/* SAVE DATA==================================================================*/	

sort patient_id
save $Tempdir\analysis_dataset, replace

* Save a version set on outcome
stset stime_$outcome, fail($outcome) id(patient_id) enter(enter_date) origin(enter_date)	
save $Tempdir\analysis_dataset_STSET_$outcome, replace

* Close log file 
log close
