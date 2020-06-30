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
log using $logdir\02_cr_create_exposure, replace t

/* TREATMENT EXPOSURE=========================================================*/	

/* SABA ONLY */ 

* At least one prescription of SABA single 
gen exposure = 0 if saba_single == 1

* And not a LABA, ICS or LTRA single or in combination 
recode exposure(0 = .u) if ics_single == 1 
recode exposure(0 = .u) if laba_ics == 1 
recode exposure(0 = .u) if laba_lama == 1
recode exposure(0 = .u) if laba_lama_ics == 1 
recode exposure(0 = .u) if ltra_single == 1 

/* ICS */
				
* Most recent low or high dose before index

replace exposure = 1 if low_med_dose_ics == 1 & ///
						low_med_dose_ics_date == max(low_med_dose_ics_date, high_dose_ics_date)
replace exposure = 2 if high_dose_ics == 1 & /// 
						high_dose_ics_date == max(low_med_dose_ics_date, high_dose_ics_date)	

* If both on same date, code above assumes high dose		

replace exposure = .u if exposure >= .
						
label define exposure 0 "SABA only" 1 "ICS (Low/Medium Dose)" 2 "ICS (High Dose)" .u "Other"
label values exposure exposure 

label var exposure "Asthma Treatment Exposure"

/* SAVE DATA==================================================================*/	

sort patient_id
save $tempdir\analysis_dataset, replace

* Save a version set on outcome
stset stime_$outcome, fail($outcome) id(patient_id) enter(enter_date) origin(enter_date)	
save $tempdir\analysis_dataset_STSET_$outcome, replace

* Close log file 
log close
