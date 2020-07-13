/*==============================================================================
DO FILE NAME:			06_an_models
PROJECT:				HCQ in COVID-19 
DATE: 					6 July 2020 
AUTHOR:					C Rentsch
						adapted from A Schultze 							
DESCRIPTION OF FILE:	program 06 
						univariable regression
						multivariable regression 
						interaction models are in: 
							07_an_model_interact
						 model checks are in: 
							08_an_model_checks
DATASETS USED:			data in memory ($Tempdir/analysis_dataset_STSET_$outcome)

DATASETS CREATED: 		none
OTHER OUTPUT: 			logfiles, printed to folder $Logdir
						table2, printed to $Tabfigdir
USER-INSTALLED ADO: 	 
  (place .ado file(s) in analysis folder)								
==============================================================================*/


* Open a log file

cap log close
log using $Logdir\06_an_models, replace t

* Open Stata dataset
use $Tempdir\analysis_dataset_STSET_$outcome, clear

/* Sense check outcomes=======================================================*/ 

tab exposure $outcome, missing row

/* Main Model=================================================================*/

/* Univariable model */ 

stcox i.exposure 
estimates save $Tempdir/univar, replace 

/* Multivariable models */ 

* Age and Sex 
* Age fit as spline 

stcox i.exposure i.male age1 age2 age3 
estimates save $Tempdir/multivar1, replace 

* DAG adjusted (age, sex, geographic region, other immunosuppressives (will include biologics when we have them))  
	*Note: ethnicity missing for ~20-25%. will model ethnicity in several ways in separate do file

stcox i.exposure i.male age1 age2 age3 i.dmard_pc i.oral_prednisolone, strata(stp)				
										
estimates save $Tempdir/multivar2, replace 

* DAG+ other adjustments (heart disease, lung disease, kidney disease, liver disease, BMI, hypertension, cancer, stroke, dementia, and respiratory disease excl asthma (OCS capturing ashtma))

stcox i.exposure i.male age1 age2 age3 i.dmard_pc i.oral_prednisolone i.chronic_cardiac_disease i.resp_excl_asthma i.egfr_cat_nomiss i.chronic_liver_disease i.obese4cat i.hypertension i.cancer_ever i.other_neuro_conditions, strata(stp)				
										
estimates save $Tempdir/multivar3, replace 




/* Print table================================================================*/ 
*  Print the results for the main model 

cap file close tablecontent
file open tablecontent using $Tabfigdir/table2.txt, write text replace

* Column headings 
file write tablecontent ("Table 2: Association between current HCQ use and $tableoutcome") _n
file write tablecontent _tab ("N") _tab ("Univariable") _tab _tab ("Age/Sex Adjusted") _tab _tab ///
						("DAG Adjusted") _tab _tab ("DAG+ Adjusted") _tab _tab  _n
file write tablecontent _tab _tab ("HR") _tab ("95% CI") _tab ("HR") _tab ///
						("95% CI") _tab ("HR") _tab ("95% CI") _tab ("HR") _tab ("95% CI") _n
file write tablecontent ("Main Analysis") _n 					

* Row headings 
local lab0: label exposure 0
local lab1: label exposure 1
 
/* Counts */
 
* First row, exposure = 0 (reference)

	cou if exposure == 0 
	local rowdenom = r(N)
	cou if exposure == 0 & $outcome == 1
	local pct = 100*(r(N)/`rowdenom') 
	
	file write tablecontent ("`lab0'") _tab
	file write tablecontent (r(N)) (" (") %3.1f (`pct') (")") _tab
	file write tablecontent ("1.00 (ref)") _tab _tab ("1.00 (ref)") _tab _tab ("1.00 (ref)")  _tab _tab ("1.00 (ref)") _n
	
* Second row, exposure = 1 (comparator)

file write tablecontent ("`lab1'") _tab  

	cou if exposure == 1 
	local rowdenom = r(N)
	cou if exposure == 1 & $outcome == 1
	local pct = 100*(r(N)/`rowdenom') 
	file write tablecontent (r(N)) (" (") %3.1f (`pct') (")") _tab

/* Main Model */ 
estimates use $Tempdir/univar 
lincom 1.exposure, eform
file write tablecontent %4.2f (r(estimate)) _tab %4.2f (r(lb)) (" - ") %4.2f (r(ub)) _tab 

estimates use $Tempdir/multivar1 
lincom 1.exposure, eform
file write tablecontent %4.2f (r(estimate)) _tab %4.2f (r(lb)) (" - ") %4.2f (r(ub)) _tab 

estimates use $Tempdir/multivar2 
lincom 1.exposure, eform
file write tablecontent %4.2f (r(estimate)) _tab %4.2f (r(lb)) (" - ") %4.2f (r(ub)) _tab 

estimates use $Tempdir/multivar3 
lincom 1.exposure, eform
file write tablecontent %4.2f (r(estimate)) _tab %4.2f (r(lb)) (" - ") %4.2f (r(ub)) _n 

file write tablecontent _n
file close tablecontent

* Close log file 
log close
