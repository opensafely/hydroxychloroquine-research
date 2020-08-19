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
							07_an_models_interact
						 model checks are in: 
							08_an_model_checks
DATASETS USED:			data in memory ($Tempdir/analysis_dataset_STSET_$outcome)

DATASETS CREATED: 		none
OTHER OUTPUT: 			logfiles, printed to folder $Logdir
						table2, printed to $Tabfigdir
USER-INSTALLED ADO: 	parmest 
  (place .ado file(s) in analysis folder)								
==============================================================================*/


* Open a log file

cap log close
log using $Logdir\06_an_models, replace t

* Open Stata dataset
use $Tempdir\analysis_dataset_STSET_$outcome, clear

/* Main Model=================================================================*/

/* Univariable model */ 

stcox i.exposure, nolog
estimates save $Tempdir/univar, replace 
parmest, label eform format(estimate p lb ub) saving("$Tempdir/parmest_univar_$outcome", replace) idstr("parmest_univar_$outcome") 


/* Multivariable models */ 

* Age and Sex 
* Age fit as spline 

stcox i.exposure i.male age1 age2 age3 
estimates save $Tempdir/multivar1, replace 
parmest, label eform format(estimate p lb ub) saving("$Tempdir/parmest_multivar1_$outcome", replace) idstr("parmest_multivar1_$outcome") 


*recode unknown ethnicity to missing
recode ethnicity .u=.
*mi set the data (aka stset) 
mi set mlong
*mi register (tell Stata which variable to impute)
mi register imputed ethnicity
*mi impute the dataset
mi impute mlogit ethnicity i.exposure _d i.population i.stp i.male age1 age2 age3 i.dmard_pc i.oral_prednisolone i.nsaids i.chronic_cardiac_disease i.resp_excl_asthma i.egfr_cat_nomiss i.chronic_liver_disease i.obese4cat i.hypertension i.cancer_ever i.neuro_conditions i.flu_vaccine i.imd i.diabcat i.smoke_nomiss, add(10) rseed(8675309) augment
*mi stset
mi stset stime_$outcome, fail($outcome) id(patient_id) enter(enter_date) origin(enter_date)	
 * DAG adjusted (age, sex, ethnicity, geographic region, other immunosuppressives (will include biologics when we have them))  
*eform doesnt allow for lincom to build tables. use post
mi estimate, dots post: stcox i.exposure i.male age1 age2 age3 i.ethnicity i.dmard_pc i.oral_prednisolone, strata(stp population)				
estimates save $Tempdir/multivar2_mi, replace 
parmest, label eform format(estimate p lb ub) saving("$Tempdir/parmest_multivar2_mi_$outcome", replace) idstr("parmest_multivar2_mi_$outcome") 

* DAG+ other adjustments (NSAIDs, heart disease, lung disease, kidney disease, liver disease, BMI, hypertension, cancer, stroke, dementia, and respiratory disease excl asthma (OCS capturing ashtma))

mi estimate, dots post: stcox i.exposure i.male age1 age2 age3 i.ethnicity i.dmard_pc i.oral_prednisolone i.nsaids i.chronic_cardiac_disease i.resp_excl_asthma i.egfr_cat_nomiss i.chronic_liver_disease i.obese4cat i.hypertension i.cancer_ever i.neuro_conditions i.flu_vaccine i.imd i.diabcat i.smoke_nomiss, strata(stp population)	
estimates save $Tempdir/multivar3_mi, replace 
parmest, label eform format(estimate p lb ub) saving("$Tempdir/parmest_multivar3_mi_$outcome", replace) idstr("parmest_multivar3_mi_$outcome") 

 



* Open Stata dataset
use $Tempdir\analysis_dataset_STSET_$outcome, clear

/* Print table================================================================*/ 
*  Print the results for the main model 

cap file close tablecontent
file open tablecontent using $Tabfigdir/table2.txt, write text replace

* Column headings 
file write tablecontent ("Table 2: Association between HCQ use and $tableoutcome - IMPUTED ETHNICITY") _n
file write tablecontent _tab ("N") _tab ("Univariable") _tab _tab ("Age/Sex Adjusted") _tab _tab ///
						("DAG Adjusted") _tab _tab ("Fully Adjusted") _tab _tab  _n
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
file write tablecontent %4.2f (r(estimate)) _tab ("(") %4.2f (r(lb)) ("-") %4.2f (r(ub)) (")") _tab 

estimates use $Tempdir/multivar1
lincom 1.exposure, eform
file write tablecontent %4.2f (r(estimate)) _tab ("(") %4.2f (r(lb)) ("-") %4.2f (r(ub)) (")") _tab 

estimates use $Tempdir/multivar2_mi 
lincom 1.exposure, eform
file write tablecontent %4.2f (r(estimate)) _tab ("(") %4.2f (r(lb)) ("-") %4.2f (r(ub)) (")") _tab 

estimates use $Tempdir/multivar3_mi 
lincom 1.exposure, eform
file write tablecontent %4.2f (r(estimate)) _tab ("(") %4.2f (r(lb)) ("-") %4.2f (r(ub)) (")") _n 

file write tablecontent _n
file close tablecontent

* Close log file 
log close




