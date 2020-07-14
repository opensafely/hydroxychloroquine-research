/*==============================================================================
DO FILE NAME:			09_an_model_explore
PROJECT:				HCQ in COVID-19 
DATE: 					13 July 2020 
AUTHOR:					C Rentsch
						adapted from A Schultze 									
DESCRIPTION OF FILE:	program 09 
						explore different models by including one var at time
DATASETS USED:			data in memory ($Tempdir/analysis_dataset_STSET_outcome)

DATASETS CREATED: 		none
OTHER OUTPUT: 			logfiles, printed to folder $Logdir
						table5, printed to $Tabfigdir
							
==============================================================================*/

* Open a log file

cap log close
log using $Logdir\09_an_model_explore_asthma, replace t

* Open Stata dataset
use $Tempdir\analysis_dataset_STSET_$outcome, clear

/* Print table================================================================*/ 
*  Print the results for the main model 

cap file close tablecontent
file open tablecontent using $Tabfigdir/table5.txt, write text replace

* Column headings 
file write tablecontent ("Table 5: 1 by 1 adjustments (after age/sex and strata adjustments)") _n
file write tablecontent _tab ("HR") _tab ("95% CI") _n

/* Adjust one covariate at a time=============================================*/

foreach var in i.dmard_pc i.oral_prednisolone i.nsaids i.chronic_cardiac_disease i.resp_excl_asthma i.egfr_cat_nomiss i.chronic_liver_disease i.obese4cat i.hypertension i.cancer_ever i.neuro_conditions { 
	local var: subinstr local var "i." ""
	local lab: variable label `var'
	file write tablecontent ("`lab'") _n 
	
	capture stcox i.exposure i.male age1 age2 age3 i.`var', strata(stp)	
	if !_rc {
		local lab0: label exposure 0
		local lab1: label exposure 1

		file write tablecontent ("`lab0'") _tab
		file write tablecontent ("1.00 (ref)") _tab _n
		file write tablecontent ("`lab1'") _tab  
		
		qui lincom 1.exposure, eform
		file write tablecontent %4.2f (r(estimate)) _tab %4.2f (r(lb)) (" - ") %4.2f (r(ub)) _n
						
									
	}
	else di "*WARNING `var' MODEL DID NOT SUCCESSFULLY FIT*"
}

file write tablecontent _n
file close tablecontent

* Close log file 
log close
