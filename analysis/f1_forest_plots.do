/*==============================================================================
DO FILE NAME:			f1_forest_plots
PROJECT:				HCQ in COVID-19 
DATE: 					21 July 2020 
AUTHOR:					C Rentsch
DESCRIPTION OF FILE:	create forest plots
DATASETS USED:			datasets fro 06 .do file ($Tempdir/parmest_univar_$outcome)

DATASETS CREATED: 		none
OTHER OUTPUT: 			logfiles, printed to folder $Logdir
						forestplot1, printed to $Tabfigdir
USER-INSTALLED ADO: 	dsconcat 
  (place .ado file(s) in analysis folder)								
==============================================================================*/

* Open a log file

cap log close
log using $Logdir\f1_forest_plots, replace t




*read in datasets 
*covid death
*need to do some acrobatics to get tempdata out of multiple folders (one for each outcome)
cd  "$Dodir"
cd ..
if r(N) > 0 local hr "`hr' "`c(pwd)'/output/tempdata/parmest_univar_onscoviddeath.dta" "
if r(N) > 0 local hr "`hr' "`c(pwd)'/output/tempdata/parmest_multivar1_onscoviddeath.dta" "
if r(N) > 0 local hr "`hr' "`c(pwd)'/output/tempdata/parmest_multivar2_onscoviddeath.dta" "
if r(N) > 0 local hr "`hr' "`c(pwd)'/output/tempdata/parmest_multivar3_onscoviddeath.dta" "
*non covid death
if r(N) > 0 local hr "`hr' "`c(pwd)'/output/sens1/tempdata/parmest_univar_onsnoncoviddeath.dta" "
if r(N) > 0 local hr "`hr' "`c(pwd)'/output/sens1/tempdata/parmest_multivar1_onsnoncoviddeath.dta" "
if r(N) > 0 local hr "`hr' "`c(pwd)'/output/sens1/tempdata/parmest_multivar2_onsnoncoviddeath.dta" "
if r(N) > 0 local hr "`hr' "`c(pwd)'/output/sens1/tempdata/parmest_multivar3_onsnoncoviddeath.dta" "

*concatenate dataets
dsconcat `hr'
duplicates drop 

*only keep necessary info
keep if label=="HCQ Exposure"
drop if estimate == 1
drop label parm stderr z p

*create labels
split idstr, p(_)
drop idstr

*outcomes
gen outcome = "{bf:COVID-19 mortality}" if idstr3 == "onscoviddeath"
replace outcome = "{bf:Non COVID-19 mortality}" if idstr3 == "onsnoncoviddeath"
drop idstr3

*adjustments
gen adjust = 1 if idstr2 == "univar"
replace adjust = 2 if idstr2 == "multivar1"
replace adjust = 3 if idstr2 == "multivar2"
replace adjust = 4 if idstr2 == "multivar3"

label define adjust 1 "Unadjusted" 2 "Age/Sex Adjusted" 3 "DAG-Informed Adjustment" 4 "Extended Adjustment"
label values adjust adjust
drop idstr2
drop idstr1

*log base 2
gen log_estimate = log(estimate)
gen log_min95 = log(min95)
gen log_max95 = log(max95)

graph set window 
gen num=[_n]
sum num
save "`c(pwd)'/output/tempdata/HR_forestplot.dta", replace



use "`c(pwd)'/output/tempdata/HR_forestplot.dta", clear
metan log_estimate log_min95 log_max95 , eform random ///
	effect(Hazard Ratio) null(1) lcols(adjust) by(outcome)  dp(2) xlab (.25,.5,1,2,4) ///
	nowt nosubgroup nooverall nobox graphregion(color(white)) scheme(sj) texts(100) astext(65) ///
	graphregion(margin(zero)) ///
	saving("`c(pwd)'/output/tabfig\forestplot1.gph", replace)
	
graph export "`c(pwd)'/output/tabfig\forestplot1.svg", replace  

* Close window 
graph close

* Delete unneeded graphs
*erase `c(pwd)'/output/tabfig/forestplot1.gph

log close