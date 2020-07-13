/*==============================================================================
DO FILE NAME:			02_cr_create_exposure
PROJECT:				HCQ in COVID-19 
DATE: 					17 June 2020 
AUTHOR:					C Rentsch
						adapted from A Schultze 	 								
DESCRIPTION OF FILE:	create exposure of interest 
DATASETS USED:			data in memory (from output/input.csv)

DATASETS CREATED: 		analysis_dataset.dta
						analysis_dataset_STSET_(outcome).dta 
						both live in folder $Tempdir
OTHER OUTPUT: 			logfiles, printed to folder $Logdir
USER-INSTALLED ADO: 	 
  (place .ado file(s) in analysis folder)	
  
==============================================================================*/



* Open a log file

cap log close
log using $Logdir\02_cr_create_exposure, replace t

/* TREATMENT EXPOSURE=========================================================*/	

* At least two prescriptions of HCQ in 6 months prior
gen exposure=hcq  
label define exposure 0 "No HCQ" 1 "HCQ"
label values exposure exposure 
label var exposure "HCQ Exposure"

* At least one prescriptions of HCQ in 3 months prior
gen exposure_sa=hcq  
label define exposure_sa 0 "No HCQ" 1 "HCQ"
label values exposure_sa exposure_sa 
label var exposure_sa "HCQ Exposure, 3 mos"

/* SAVE DATA==================================================================*/	

sort patient_id
save $Tempdir\analysis_dataset, replace

* Save a version set on outcome
stset stime_$outcome, fail($outcome) id(patient_id) enter(enter_date) origin(enter_date)	
save $Tempdir\analysis_dataset_STSET_$outcome, replace

* Close log file 
log close
