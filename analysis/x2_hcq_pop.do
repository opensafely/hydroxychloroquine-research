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





/* DEMOGRAPHICS */ 

* Sex
gen male = 1 if sex == "M"
replace male = 0 if sex == "F"
drop sex

/*  IMD  */
* Group into 5 groups
rename imd imd_o
egen imd = cut(imd_o), group(5) icodes

* add one to create groups 1 - 5 
replace imd = imd + 1

* - 1 is missing, should be excluded from population 
replace imd = .u if imd_o == -1
drop imd_o

* Reverse the order (so high is more deprived)
recode imd 5 = 1 4 = 2 3 = 3 2 = 4 1 = 5 .u = .u

label define imd 1 "1 least deprived" 2 "2" 3 "3" 4 "4" 5 "5 most deprived" .u "Unknown"
label values imd imd 

/*  Age variables  */ 

* Create categorised age
recode age 18/39.9999 = 1 /// 
           40/49.9999 = 2 ///
		   50/59.9999 = 3 ///
	       60/69.9999 = 4 ///
		   70/79.9999 = 5 ///
		   80/max = 6, gen(agegroup) 

label define agegroup 	1 "18-<40" ///
						2 "40-<50" ///
						3 "50-<60" ///
						4 "60-<70" ///
						5 "70-<80" ///
						6 "80+"
						
label values agegroup agegroup
drop age








*get some stats 

*demographics
tab1 male imd agegroup, m

*PREVALENCE OVERALL
tab1 hcq dmard_pc, m
*hcq prevalence in patient groups
tab rheumatoid hcq,m row
tab sle hcq, m row
tab male hcq, m row
tab imd hcq, m row
tab agegroup hcq, m row
*dmard prevalence in patient groups
tab rheumatoid dmard_pc,m row
tab sle dmard_pc, m row
tab male dmard_pc, m row
tab imd dmard_pc, m row
tab agegroup dmard_pc, m row


*PREVALENCE IN RA
tab1 hcq dmard_pc if rheumatoid == 1, m
*hcq prevalence in patient groups
tab sle hcq if rheumatoid == 1, m row
tab male hcq if rheumatoid == 1, m row
tab imd hcq if rheumatoid == 1, m row
tab agegroup hcq if rheumatoid == 1, m row
*dmard prevalence in patient groups
tab sle dmard_pc if rheumatoid == 1, m row
tab male dmard_pc if rheumatoid == 1, m row
tab imd dmard_pc if rheumatoid == 1, m row
tab agegroup dmard_pc if rheumatoid == 1, m row

*PREVALENCE IN SLE
tab1 hcq dmard_pc if sle == 1, m
*hcq prevalence in patient groups
tab rheumatoid hcq if sle == 1, m row
tab male hcq if sle == 1, m row
tab imd hcq if sle == 1, m row
tab agegroup hcq if sle == 1, m row
*dmard prevalence in patient groups
tab rheumatoid dmard_pc if sle == 1, m row
tab male dmard_pc if sle == 1, m row
tab imd dmard_pc if sle == 1, m row
tab agegroup dmard_pc if sle == 1, m row