/*==============================================================================
DO FILE NAME:			07_an_models_interact
PROJECT:				HCQ in COVID-19 
DATE: 					13 July 2020 
AUTHOR:					C Rentsch
						adapted from A Schultze 						
DESCRIPTION OF FILE:	program 07, evaluate interactions 
DATASETS USED:			data in memory ($Tempdir/analysis_dataset_STSET_outcome)

DATASETS CREATED: 		none
OTHER OUTPUT: 			logfiles, printed to folder $Logdir
						table3, printed to $Tabfigdir
											
==============================================================================*/



* Open a log file

cap log close
log using $Logdir\07_an_models_interact, replace t

* Open Stata dataset
use $Tempdir\analysis_dataset_STSET_$outcome, clear

/* So few deaths occuring below 60 years this cannot be used as a category, so combining 18-59 */ 
gen agegroup2 = agegroup
recode agegroup2(1 = 2)
recode agegroup2(2 = 3)
tab agegroup2, nolabel 

label define agegroup2 	3 "18-<60" ///
						4 "60-<70" ///
						5 "70-<80" ///
						6 "80+"
						
label values agegroup2 agegroup2
tab agegroup agegroup2 , m


foreach intvar of varlist agegroup2 dmard_pc oral_prednisolone nsaids {
/* Check Counts */ 

bysort `intvar': tab exposure $outcome, row

/* Univariable model */ 
stcox i.exposure i.agegroup2
estimates store A

stcox i.exposure##i.`intvar' i.agegroup2
estimates store B
estimates save $Tempdir/univar_int_`intvar', replace 

lrtest A B
global univar_p_`intvar' = round(r(p),0.001)

/* Multivariable models */ 

* Age and Sex 
stcox i.exposure i.agegroup2 i.male
estimates store A

stcox i.exposure##i.`intvar' i.agegroup2 i.male
estimates store B
estimates save $Tempdir/multivar1_int_`intvar', replace 

lrtest A B
global multivar1_p_`intvar' = round(r(p),0.001)

* DAG Adjusted 
stcox i.exposure i.agegroup2 i.male i.dmard_pc i.oral_prednisolone, strata(stp)					
										
estimates store A

stcox i.exposure##i.`intvar' i.agegroup2 i.male i.dmard_pc i.oral_prednisolone, strata(stp)			
estimates store B
estimates save $Tempdir/multivar2_int_`intvar', replace 

lrtest A B
global multivar2_p_`intvar' = round(r(p),0.001)

* Fully Adjusted 
stcox i.exposure i.agegroup2 i.male i.dmard_pc i.oral_prednisolone i.nsaids i.chronic_cardiac_disease i.resp_excl_asthma i.egfr_cat_nomiss i.chronic_liver_disease i.obese4cat i.hypertension i.cancer_ever i.neuro_conditions, strata(stp)
estimates store A

stcox i.exposure##i.`intvar' i.agegroup2 i.male i.dmard_pc i.oral_prednisolone i.nsaids i.chronic_cardiac_disease i.resp_excl_asthma i.egfr_cat_nomiss i.chronic_liver_disease i.obese4cat i.hypertension i.cancer_ever i.neuro_conditions, strata(stp)
estimates store B
estimates save $Tempdir/multivar3_int_`intvar', replace 

lrtest A B
global multivar3_p_`intvar' = round(r(p),0.001)

}






/* Print interaction table====================================================*/ 
cap file close tablecontent
file open tablecontent using $Tabfigdir/table3.txt, write text replace

* Column headings 
file write tablecontent ("Table 3: Interactions with HCQ use on risk of $tableoutcome") _n
file write tablecontent _tab ("N") _tab ("Univariable") _tab _tab _tab ("Age/Sex Adjusted") _tab _tab _tab  ///
						("DAG Adjusted") _tab _tab _tab ("Fully Adjusted") _tab _tab _tab _n
file write tablecontent _tab _tab ("HR") _tab ("95% CI") _tab ("p (interaction)") _tab ("HR") _tab ///
						("95% CI") _tab ("p (interaction)") _tab ("HR") _tab ("95% CI") _tab ("p (interaction)") _tab ///
						("HR") _tab ("95% CI") _tab ("p (interaction)") _tab _n

						
* Generic program to print model for a level of another variable 
cap prog drop printinteraction
prog define printinteraction 
syntax, variable(varname) min(real) max(real) 

* Overall p-values 

file write tablecontent ("`variable'") _tab _tab _tab _tab ("${univar_p_`variable'}") ///
						_tab _tab _tab ("${multivar1_p_`variable'}") /// 
						_tab _tab _tab ("${multivar2_p_`variable'}") ///
						_tab _tab _tab ("${multivar3_p_`variable'}") _n
	forvalues varlevel = `min'/`max'{ 

		* Row headings 
							
		file write tablecontent ("`varlevel'") _n 	

		local lab0: label exposure 0
		local lab1: label exposure 1
		 
		/* Counts */
			
		* First row, exposure = 0 (reference)
		
	file write tablecontent ("`lab0'") _tab

			cou if exposure == 0 & `variable' == `varlevel'
			local rowdenom = r(N)
			cou if exposure == 0  & `variable' == `varlevel' & $outcome == 1
			local pct = 100*(r(N)/`rowdenom')
			
			
		file write tablecontent (r(N)) (" (") %3.1f (`pct') (")") _tab
		file write tablecontent ("1.00 (ref)") _tab _tab _tab ("1.00 (ref)") _tab _tab _tab ("1.00 (ref)") _tab _tab _tab ("1.00 (ref)") _n
			
		* Second row, exposure = 1 (comparator)

		file write tablecontent ("`lab1'") _tab  

			cou if exposure == 1 & `variable' == `varlevel'
			local rowdenom = r(N)
			cou if exposure == 1 & `variable' == `varlevel' & $outcome == 1
			local pct = 100*(r(N)/`rowdenom')
			
		file write tablecontent (r(N)) (" (") %3.1f (`pct') (")") _tab

		* Print models 
		estimates use $Tempdir/univar_int_`variable' 
		qui lincom 1.exposure + 1.exposure#`varlevel'.`variable', eform
		file write tablecontent %4.2f (r(estimate)) _tab %4.2f (r(lb)) (" - ") %4.2f (r(ub)) _tab _tab

		estimates use $Tempdir/multivar1_int_`variable'
		qui lincom 1.exposure + 1.exposure#`varlevel'.`variable', eform
		file write tablecontent %4.2f (r(estimate)) _tab %4.2f (r(lb)) (" - ") %4.2f (r(ub)) _tab _tab

		estimates use $Tempdir/multivar2_int_`variable'
		qui lincom 1.exposure + 1.exposure#`varlevel'.`variable', eform
		file write tablecontent %4.2f (r(estimate)) _tab %4.2f (r(lb)) (" - ") %4.2f (r(ub)) _tab _tab 
	
		estimates use $Tempdir/multivar3_int_`variable'
		qui lincom 1.exposure + 1.exposure#`varlevel'.`variable', eform
		file write tablecontent %4.2f (r(estimate)) _tab %4.2f (r(lb)) (" - ") %4.2f (r(ub)) _tab _n
	} 
		
end

printinteraction, variable(agegroup2) min(3) max(6) 
file write tablecontent _n _n

printinteraction, variable(dmard_pc) min(0) max(1) 
file write tablecontent _n _n
  
printinteraction, variable(oral_prednisolone) min(0) max(1) 
file write tablecontent _n _n

printinteraction, variable(nsaids) min(0) max(1) 



file write tablecontent _n
file close tablecontent

* Close log file 
log close
