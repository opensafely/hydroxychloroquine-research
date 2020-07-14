/*==============================================================================
DO FILE NAME:			08_an_model_checks
PROJECT:				HCQ in COVID-19 
DATE: 					13 July 2020 
AUTHOR:					C Rentsch
						adapted from A Schultze 						
DESCRIPTION OF FILE:	program 08 
						check the PH assumption, produce graphs 
DATASETS USED:			data in memory ($Tempdir/analysis_dataset_STSET_outcome)

DATASETS CREATED: 		none
OTHER OUTPUT: 			logfiles, printed to folder $Logdir
						table4, printed to $Tabfigdir
						schoenplots1-x, printed to $Tabfigdir 
							
==============================================================================*/

* Open a log file

cap log close
log using $Logdir\08_an_model_checks, replace t

* Open Stata dataset
use $Tempdir\analysis_dataset_STSET_$outcome, clear

* Exposure labels 
local lab1: label exposure 1

/* Quietly run models, perform test and store results in local macro==========*/

qui stcox i.exposure 
estat phtest, detail
local univar_p1 = round(r(phtest)[2,4],0.001)

di `univar_p1'
 
estat phtest, plot(1.exposure) ///
			  graphregion(fcolor(white)) ///
			  ylabel(, nogrid labsize(small)) ///
			  xlabel(, labsize(small)) ///
			  xtitle("Time", size(small)) ///
			  ytitle("Scaled Shoenfeld Residuals", size(small)) ///
			  msize(small) ///
			  mcolor(gs6) ///
			  msymbol(circle_hollow) ///
			  scheme(s1mono) ///
			  title ("Schoenfeld residuals against time, Univariable `lab1'", position(11) size(medsmall)) 

graph export "$Tabfigdir/schoenplot1a.svg", as(svg) replace

* Close window 
graph close  
			  
stcox i.exposure i.male age1 age2 age3 
estat phtest, detail
local multivar1_p1 = round(r(phtest)[2,4],0.001)
 
estat phtest, plot(1.exposure) ///
			  graphregion(fcolor(white)) ///
			  ylabel(, nogrid labsize(small)) ///
			  xlabel(, labsize(small)) ///
			  xtitle("Time", size(small)) ///
			  ytitle("Scaled Shoenfeld Residuals", size(small)) ///
			  msize(small) ///
			  mcolor(gs6) ///
			  msymbol(circle_hollow) ///
			  scheme(s1mono) ///
			  title ("Schoenfeld residuals against time, Age/Sex Adjusted `lab1'", position(11) size(medsmall)) 			  

graph export "$Tabfigdir/schoenplot2a.svg", as(svg) replace

* Close window 
graph close
		  
stcox i.exposure i.male age1 age2 age3 i.dmard_pc i.oral_prednisolone, strata(stp)
estat phtest, detail
local multivar2_p1 = round(r(phtest)[2,4],0.001)
 
estat phtest, plot(1.exposure) ///
			  graphregion(fcolor(white)) ///
			  ylabel(, nogrid labsize(small)) ///
			  xlabel(, labsize(small)) ///
			  xtitle("Time", size(small)) ///
			  ytitle("Scaled Shoenfeld Residuals", size(small)) ///
			  msize(small) ///
			  mcolor(gs6) ///
			  msymbol(circle_hollow) ///
			  scheme(s1mono) /// 
			  title ("Schoenfeld residuals against time, DAG Adjusted `lab1'", position(11) size(medsmall)) 		  
			  
graph export "$Tabfigdir/schoenplot3a.svg", as(svg) replace

* Close window 
graph close

stcox i.exposure i.male age1 age2 age3 i.dmard_pc i.oral_prednisolone i.nsaids i.chronic_cardiac_disease i.resp_excl_asthma i.egfr_cat_nomiss i.chronic_liver_disease i.obese4cat i.hypertension i.cancer_ever i.neuro_conditions, strata(stp)
estat phtest, detail
local multivar3_p1 = round(r(phtest)[2,4],0.001)
 
estat phtest, plot(1.exposure) ///
			  graphregion(fcolor(white)) ///
			  ylabel(, nogrid labsize(small)) ///
			  xlabel(, labsize(small)) ///
			  xtitle("Time", size(small)) ///
			  ytitle("Scaled Shoenfeld Residuals", size(small)) ///
			  msize(small) ///
			  mcolor(gs6) ///
			  msymbol(circle_hollow) ///
			  scheme(s1mono) /// 
			  title ("Schoenfeld residuals against time, Fully Adjusted `lab1'", position(11) size(medsmall)) 		  
			  
graph export "$Tabfigdir/schoenplot4a.svg", as(svg) replace

* Close window 
graph close

* Print table of results======================================================*/	


cap file close tablecontent
file open tablecontent using $Tabfigdir/table4.txt, write text replace

* Column headings 
file write tablecontent ("Table 4: Testing the PH assumption for $tableoutcome") _n
file write tablecontent _tab ("Univariable") _tab ("Age/Sex Adjusted") _tab ///
						("DAG Adjusted") _tab ("Fully Adjusted") _tab _n
						
file write tablecontent _tab ("p-value") _tab ("p-value") _tab ("p-value") _tab ("p-value") _tab _n

* Row heading and content  
file write tablecontent ("`lab1'") _tab
file write tablecontent ("`univar_p1'") _tab ("`multivar1_p1'") _tab ("`multivar2_p1'") _tab ("`multivar3_p1'") _n

file write tablecontent _n
file close tablecontent


* Close log file 
log close
