/*==============================================================================
DO FILE NAME:			x2_hcq_pop
PROJECT:				HCQ in COVID-19 
DATE: 					14 July 2020 
AUTHOR:					C Rentsch
						adapted from A Schultze 										
DESCRIPTION OF FILE:	program x2, 
DATASETS USED:			data in memory (from output/input_hcq_pop.csv)

DATASETS CREATED: 		none
OTHER OUTPUT: 			logfiles, printed to folder $Logdir
USER-INSTALLED ADO: 	 
  (place .ado file(s) in analysis folder)						
==============================================================================*/

* Open a log file

cap log close
log using $Logdir\x2_hcq_pop, replace t




/* SET Index date ===========================================================*/
global indexdate 			= "01/03/2020"





// variable i have are
// hcq_count
// dmards_primary_care_count
// rheumatoid
// sle




/* CONVERT STRINGS TO DATE====================================================*/
/* Comorb dates are given with month/year only, so adding day 15 to enable
   them to be processed as dates 											  */

foreach var of varlist 	 rheumatoid							///
						 sle								///
	 {
						 	
		capture confirm string variable `var'
		if _rc!=0 {
			assert `var'==.
			rename `var' `var'_date
		}
	
		else {
				replace `var' = `var' + "-15"
				rename `var' `var'_dstr
				replace `var'_dstr = " " if `var'_dstr == "-15"
				gen `var'_date = date(`var'_dstr, "YMD") 
				order `var'_date, after(`var'_dstr)
				drop `var'_dstr
		}
	
	format `var'_date %td
}


/* CREATE BINARY VARIABLES====================================================*/
*  Make indicator variables for all conditions where relevant 

foreach var of varlist 	 rheumatoid_date					///
						 sle_date							///
	 {
	/* date ranges are applied in python, so presence of date indicates presence of 
	  disease in the correct time frame */ 
	local newvar =  substr("`var'", 1, length("`var'") - 5)
	gen `newvar' = (`var'!=. )
	order `newvar', after(`var')
	
}



/* EXPOSURE INFORMATION ====================================================*/
gen hcq = 1 if hcq_count != . & hcq_count >= 2
recode hcq .=0


/* OTHER DRUGS =============================================================*/
gen dmard_pc = 1 if dmards_primary_care_count != . & dmards_primary_care_count >= 2
recode dmard_pc .=0







*get some stats on prevalence

*prevalence overall
tab1 hcq dmard_pc, m

*hcq prevalence in patient groups
tab hcq rheumatoid ,m row
tab hcq sle, m row

*hcq prevalence in patient groups
tab dmard_pc rheumatoid ,m row col
tab dmard_pc sle, m row col
