/*==============================================================================
DO FILE NAME:			11_an_models_sep_pops
PROJECT:				HCQ in COVID-19 
DATE: 					13 July 2020 
AUTHOR:					C Rentsch
						adapted from A Schultze 							
DESCRIPTION OF FILE:	program 11, look at RA and SLE pops separately 
DATASETS USED:			data in memory ($Tempdir/analysis_dataset_STSET_outcome)

DATASETS CREATED: 		none
OTHER OUTPUT: 			logfiles, printed to folder $Logdir
						table7, printed to $Tabfigdir
							
==============================================================================*/

* Open a log file

cap log close
log using $Logdir\11_an_models_sep_pops, replace t

* Open Stata dataset
use $Tempdir\analysis_dataset_STSET_$outcome, clear



****************************************************************************************************************************************************************************************
****************************************************************************************************************************************************************************************
/* Restrict population========================================================*/ 
preserve 
keep if rheumatoid == 1
/* Sense check outcomes=======================================================*/ 
tab exposure $outcome, missing row
/* Main Model (same adjustments, removing those with missing ethnicity) ======*/
/* Univariable model */ 
stcox i.exposure 
estimates save $Tempdir/univar_ra, replace 
/* Multivariable models */ 
* Age and Sex 
* Age fit as spline 
stcox i.exposure i.male age1 age2 age3 
estimates save $Tempdir/multivar1_ra, replace 
* DAG adjusted (age, sex, geographic region, other immunosuppressives (will include biologics when we have them))  
stcox i.exposure i.male age1 age2 age3 i.dmard_pc i.oral_prednisolone, strata(stp)				
estimates save $Tempdir/multivar2_ra, replace 
* DAG+ other adjustments (NSAIDs, heart disease, lung disease, kidney disease, liver disease, BMI, hypertension, cancer, stroke, dementia, and respiratory disease excl asthma (OCS capturing ashtma))
stcox i.exposure i.male age1 age2 age3 i.dmard_pc i.oral_prednisolone i.nsaids i.chronic_cardiac_disease i.resp_excl_asthma i.egfr_cat_nomiss i.chronic_liver_disease i.obese4cat i.hypertension i.cancer_ever i.neuro_conditions, strata(stp)	
estimates save $Tempdir/multivar3_ra, replace 
restore
****************************************************************************************************************************************************************************************
****************************************************************************************************************************************************************************************

/* Restrict population========================================================*/ 
preserve 
keep if sle == 1
/* Sense check outcomes=======================================================*/ 
tab exposure $outcome, missing row
/* Main Model (additionally adjusted for ethnicity) ==========================*/
/* Univariable model */ 
stcox i.exposure 
estimates save $Tempdir/univar_sle, replace 
/* Multivariable models */ 
* Age and Sex 
* Age fit as spline 
stcox i.exposure i.male age1 age2 age3 
estimates save $Tempdir/multivar1_sle, replace 
* DAG adjusted (age, sex, geographic region, other immunosuppressives (will include biologics when we have them))  
stcox i.exposure i.male age1 age2 age3 i.ethnicity i.dmard_pc i.oral_prednisolone, strata(stp)				
estimates save $Tempdir/multivar2_sle, replace 
* DAG+ other adjustments (NSAIDs, heart disease, lung disease, kidney disease, liver disease, BMI, hypertension, cancer, stroke, dementia, and respiratory disease excl asthma (OCS capturing ashtma))
stcox i.exposure i.male age1 age2 age3 i.ethnicity i.dmard_pc i.oral_prednisolone i.nsaids i.chronic_cardiac_disease i.resp_excl_asthma i.egfr_cat_nomiss i.chronic_liver_disease i.obese4cat i.hypertension i.cancer_ever i.neuro_conditions, strata(stp)	
estimates save $Tempdir/multivar3_sle, replace 
restore
****************************************************************************************************************************************************************************************
****************************************************************************************************************************************************************************************



/* Print table================================================================*/ 
*  Print the results for the main model 

cap file close tablecontent
file open tablecontent using $Tabfigdir/table7.txt, write text replace

* Column headings 
file write tablecontent ("Table 7: RA and SLE populations separately") _n
file write tablecontent _tab ("N") _tab ("Univariable") _tab _tab ("Age/Sex Adjusted") _tab _tab ///
						("DAG Adjusted") _tab _tab ("Fully Adjusted") _tab _tab  _n
file write tablecontent _tab _tab ("HR") _tab ("95% CI") _tab ("HR") _tab ///
						("95% CI") _tab ("HR") _tab ("95% CI") _tab ("HR") _tab ("95% CI") _n
						
/* Main Model (same adjustments, removing those with missing ethnicity) ======*/
file write tablecontent ("Rheumatoid arthritis (RA)") _n 					

* Row headings 
local lab0: label exposure 0
local lab1: label exposure 1
 
/* Counts */
 
* First row, exposure = 0 (reference)

	cou if exposure == 0 & rheumatoid == 1
	local rowdenom = r(N)
	cou if exposure == 0 & $outcome == 1 & rheumatoid == 1
	local pct = 100*(r(N)/`rowdenom') 
	
	file write tablecontent ("`lab0'") _tab
	file write tablecontent (r(N)) (" (") %3.1f (`pct') (")") _tab
	file write tablecontent ("1.00 (ref)") _tab _tab ("1.00 (ref)") _tab _tab ("1.00 (ref)")  _tab _tab ("1.00 (ref)") _n
	
* Second row, exposure = 1 (comparator)

file write tablecontent ("`lab1'") _tab  

	cou if exposure == 1 & rheumatoid == 1
	local rowdenom = r(N)
	cou if exposure == 1 & $outcome == 1 & rheumatoid == 1
	local pct = 100*(r(N)/`rowdenom') 
	file write tablecontent (r(N)) (" (") %3.1f (`pct') (")") _tab

/* Main Model */ 
estimates use $Tempdir/univar_ra 
lincom 1.exposure, eform
file write tablecontent %4.2f (r(estimate)) _tab %4.2f (r(lb)) (" - ") %4.2f (r(ub)) _tab 

estimates use $Tempdir/multivar1_ra 
lincom 1.exposure, eform
file write tablecontent %4.2f (r(estimate)) _tab %4.2f (r(lb)) (" - ") %4.2f (r(ub)) _tab 

estimates use $Tempdir/multivar2_ra 
lincom 1.exposure, eform
file write tablecontent %4.2f (r(estimate)) _tab %4.2f (r(lb)) (" - ") %4.2f (r(ub)) _tab 

estimates use $Tempdir/multivar3_ra 
lincom 1.exposure, eform
file write tablecontent %4.2f (r(estimate)) _tab %4.2f (r(lb)) (" - ") %4.2f (r(ub)) _n 

file write tablecontent _n _n


/* Main Model (additionally adjusted for ethnicity) ==========================*/
file write tablecontent ("Systemic lupus erythematosus (SLE)") _n 					

* Row headings 
local lab0: label exposure 0
local lab1: label exposure 1
 
/* Counts */
 
* First row, exposure = 0 (reference)

	cou if exposure == 0 & sle == 1
	local rowdenom = r(N)
	cou if exposure == 0 & $outcome == 1 & sle == 1
	local pct = 100*(r(N)/`rowdenom') 
	
	file write tablecontent ("`lab0'") _tab
	file write tablecontent (r(N)) (" (") %3.1f (`pct') (")") _tab
	file write tablecontent ("1.00 (ref)") _tab _tab ("1.00 (ref)") _tab _tab ("1.00 (ref)")  _tab _tab ("1.00 (ref)") _n
	
* Second row, exposure = 1 (comparator)

file write tablecontent ("`lab1'") _tab  

	cou if exposure == 1 & sle == 1
	local rowdenom = r(N)
	cou if exposure == 1 & $outcome == 1 & sle == 1
	local pct = 100*(r(N)/`rowdenom') 
	file write tablecontent (r(N)) (" (") %3.1f (`pct') (")") _tab

/* Main Model */ 
estimates use $Tempdir/univar_sle 
lincom 1.exposure, eform
file write tablecontent %4.2f (r(estimate)) _tab %4.2f (r(lb)) (" - ") %4.2f (r(ub)) _tab 

estimates use $Tempdir/multivar1_sle  
lincom 1.exposure, eform
file write tablecontent %4.2f (r(estimate)) _tab %4.2f (r(lb)) (" - ") %4.2f (r(ub)) _tab 

estimates use $Tempdir/multivar2_sle  
lincom 1.exposure, eform
file write tablecontent %4.2f (r(estimate)) _tab %4.2f (r(lb)) (" - ") %4.2f (r(ub)) _tab 

estimates use $Tempdir/multivar3_sle  
lincom 1.exposure, eform
file write tablecontent %4.2f (r(estimate)) _tab %4.2f (r(lb)) (" - ") %4.2f (r(ub)) _n 

file write tablecontent _n

file close tablecontent

* Close log file 
log close
