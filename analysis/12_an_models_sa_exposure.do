/*==============================================================================
DO FILE NAME:			12_an_models_sa_exposure
PROJECT:				HCQ in COVID-19 
DATE: 					13 July 2020 
AUTHOR:					C Rentsch
						adapted from A Schultze 							
DESCRIPTION OF FILE:	program 12 
						Tightening exposure window for HCQ
						univariable regression
						multivariable regression 
DATASETS USED:			data in memory ($Tempdir/analysis_dataset_STSET_$outcome)

DATASETS CREATED: 		none
OTHER OUTPUT: 			logfiles, printed to folder $Logdir
						table2, printed to $Tabfigdir
USER-INSTALLED ADO: 	 
  (place .ado file(s) in analysis folder)								
==============================================================================*/


* Open a log file

cap log close
log using $Logdir\12_an_models_sa_exposure, replace t

* Open Stata dataset
use $Tempdir\analysis_dataset_STSET_$outcome, clear

/* Sense check outcomes=======================================================*/ 

tab exposure_sa $outcome, missing row

/* Main Model=================================================================*/

/* Univariable model */ 

stcox i.exposure_sa 
estimates save $Tempdir/univar_sa_exposure, replace 

/* Multivariable models */ 

* Age and Sex 
* Age fit as spline 

stcox i.exposure_sa i.male age1 age2 age3 
estimates save $Tempdir/multivar1_sa_exposure, replace 

* DAG adjusted (age, sex, geographic region, other immunosuppressives (will include biologics when we have them))  
	*Note: ethnicity missing for ~20-25%. will model ethnicity in several ways in separate do file

stcox i.exposure_sa i.male age1 age2 age3 i.dmard_pc i.oral_prednisolone, strata(stp)				
										
estimates save $Tempdir/multivar2_sa_exposure, replace 

* DAG+ other adjustments (NSAIDs, heart disease, lung disease, kidney disease, liver disease, BMI, hypertension, cancer, stroke, dementia, and respiratory disease excl asthma (OCS capturing ashtma))

stcox i.exposure_sa i.male age1 age2 age3 i.dmard_pc i.oral_prednisolone i.nsaids i.chronic_cardiac_disease i.resp_excl_asthma i.egfr_cat_nomiss i.chronic_liver_disease i.obese4cat i.hypertension i.cancer_ever i.other_neuro_conditions, strata(stp)	
										
estimates save $Tempdir/multivar3_sa_exposure, replace 




/* Print table================================================================*/ 
*  Print the results for the main model 

cap file close tablecontent
file open tablecontent using $Tabfigdir/table8.txt, write text replace

* Column headings 
file write tablecontent ("Table 8: Association between HCQ use and $tableoutcome, 3 month window") _n
file write tablecontent _tab ("N") _tab ("Univariable") _tab _tab ("Age/Sex Adjusted") _tab _tab ///
						("DAG Adjusted") _tab _tab ("Fully Adjusted") _tab _tab  _n
file write tablecontent _tab _tab ("HR") _tab ("95% CI") _tab ("HR") _tab ///
						("95% CI") _tab ("HR") _tab ("95% CI") _tab ("HR") _tab ("95% CI") _n
file write tablecontent ("Main Analysis") _n 					

* Row headings 
local lab0: label exposure_sa 0
local lab1: label exposure_sa 1
 
/* Counts */
 
* First row, exposure_sa = 0 (reference)

	cou if exposure_sa == 0 
	local rowdenom = r(N)
	cou if exposure_sa == 0 & $outcome == 1
	local pct = 100*(r(N)/`rowdenom') 
	
	file write tablecontent ("`lab0'") _tab
	file write tablecontent (r(N)) (" (") %3.1f (`pct') (")") _tab
	file write tablecontent ("1.00 (ref)") _tab _tab ("1.00 (ref)") _tab _tab ("1.00 (ref)")  _tab _tab ("1.00 (ref)") _n
	
* Second row, exposure_sa = 1 (comparator)

file write tablecontent ("`lab1'") _tab  

	cou if exposure_sa == 1 
	local rowdenom = r(N)
	cou if exposure_sa == 1 & $outcome == 1
	local pct = 100*(r(N)/`rowdenom') 
	file write tablecontent (r(N)) (" (") %3.1f (`pct') (")") _tab

/* Main Model */ 
estimates use $Tempdir/univar_sa_exposure 
lincom 1.exposure_sa, eform
file write tablecontent %4.2f (r(estimate)) _tab %4.2f (r(lb)) (" - ") %4.2f (r(ub)) _tab 

estimates use $Tempdir/multivar1_sa_exposure 
lincom 1.exposure_sa, eform
file write tablecontent %4.2f (r(estimate)) _tab %4.2f (r(lb)) (" - ") %4.2f (r(ub)) _tab 

estimates use $Tempdir/multivar2_sa_exposure 
lincom 1.exposure_sa, eform
file write tablecontent %4.2f (r(estimate)) _tab %4.2f (r(lb)) (" - ") %4.2f (r(ub)) _tab 

estimates use $Tempdir/multivar3_sa_exposure 
lincom 1.exposure_sa, eform
file write tablecontent %4.2f (r(estimate)) _tab %4.2f (r(lb)) (" - ") %4.2f (r(ub)) _n 

file write tablecontent _n
file close tablecontent

* Close log file 
log close
