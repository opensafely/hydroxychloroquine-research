/*==============================================================================
DO FILE NAME:			14_reviewer_comments
PROJECT:				HCQ in COVID-19 
DATE: 					5 October 2020 
AUTHOR:					C Rentsch
DESCRIPTION OF FILE:	Answers to reviewer comments
DATASETS USED:			$Tempdir\analysis_dataset.dta
DATASETS CREATED: 		None
OTHER OUTPUT: 			Log file: $Logdir\14_reviewer_comments
USER-INSTALLED ADO: 	-none-
  (place .ado file(s) in analysis folder)								
==============================================================================*/



* Open a log file

capture log close
log using $Logdir\14_reviewer_comments, replace t

* Open Stata dataset
use $Tempdir\analysis_dataset, clear


****** When was first HCQ Rx before index date
tab hcq_first hcq, m


****** Median number of HCQ Rx in exposure window 
summ hcq_count if hcq == 1, detail


****** How many non-users were censored after index date because they had a new HCQ Rx (and not for the other censoring vars)
count if hcq == 0 & stime_onscoviddeath == hcq_first_after_date & stime_onscoviddeath != onscoviddeathcensor_date & stime_onscoviddeath != died_date_ons 
*2918
count if hcq == 0
*164068
*<2%











****** Estimate cumulative mortality separately by RA/SLE population

* Open Stata dataset
use $Tempdir\analysis_dataset_STSET_$outcome, clear

* RA
keep if population == 0
stpm2 exposure male age1 age2 age3 dmard_pc oral_prednisolone population, df(4) scale(hazard) eform stratify(stp)

summ _t
local tmax=r(max)
local tmaxplus1=r(max)+1

range days 0 `tmax' `tmaxplus1'
stpm2_standsurv if exposure == 1, at1(exposure 0) at2(exposure 1) timevar(days) ci contrast(difference) fail

gen date = d(1/3/2020)+ days
format date %tddd_Month

for var _at1 _at2 _at1_lci _at1_uci _at2_lci _at2_uci _contrast2_1 _contrast2_1_lci _contrast2_1_uci: replace X=100*X

*cumulative mortality at last day of follow-up
list _at1* if days==`tmax', noobs
list _at2* if days==`tmax', noobs
list _contrast* if days==`tmax', noobs

*l date days _at1 _at1_lci _at1_uci _at2 _at2_lci _at2_uci if days<.

twoway  (rarea _at1_lci _at1_uci days, color(red%25)) ///
                 (rarea _at2_lci _at2_uci days if _at2_uci<1, color(blue%25)) ///
                 (line _at1 days, sort lcolor(red)) ///
                 (line _at2 days, sort lcolor(blue) lpattern(dash)) ///
                 , legend(order(1 "No HCQ" 2 "HCQ") ring(0) cols(1) pos(11) region(lwidth(none))) ///
				 title("Time to $tableoutcome, RA population", justification(left) size(med) )  	   ///
				 yscale(range(0, 1)) 											///
				 ylabel(0 (0.1) 1, angle(0) format(%4.1f) labsize(small))	///
				 xlabel(0 (20) 160, labsize(small))				   				///			
                 ytitle("Cumulative mortality (%)", size(medsmall)) ///
                 xtitle("Days since 1 Mar 2020", size(medsmall))      		///
				 graphregion(fcolor(white)) saving(adjcurv1, replace)

graph export "$Tabfigdir/adjcurv1_ra.svg", as(svg) replace

* Close window 
graph close

* Delete unneeded graphs
*erase adjcurv1_ra.gph



* Open Stata dataset
use $Tempdir\analysis_dataset_STSET_$outcome, clear

* SLE
keep if population == 1
stpm2 exposure male age1 age2 age3 dmard_pc oral_prednisolone population, df(4) scale(hazard) eform stratify(stp)

summ _t
local tmax=r(max)
local tmaxplus1=r(max)+1

range days 0 `tmax' `tmaxplus1'
stpm2_standsurv if exposure == 1, at1(exposure 0) at2(exposure 1) timevar(days) ci contrast(difference) fail

gen date = d(1/3/2020)+ days
format date %tddd_Month

for var _at1 _at2 _at1_lci _at1_uci _at2_lci _at2_uci _contrast2_1 _contrast2_1_lci _contrast2_1_uci: replace X=100*X

*cumulative mortality at last day of follow-up
list _at1* if days==`tmax', noobs
list _at2* if days==`tmax', noobs
list _contrast* if days==`tmax', noobs

*l date days _at1 _at1_lci _at1_uci _at2 _at2_lci _at2_uci if days<.

twoway  (rarea _at1_lci _at1_uci days, color(red%25)) ///
                 (rarea _at2_lci _at2_uci days if _at2_uci<1, color(blue%25)) ///
                 (line _at1 days, sort lcolor(red)) ///
                 (line _at2 days, sort lcolor(blue) lpattern(dash)) ///
                 , legend(order(1 "No HCQ" 2 "HCQ") ring(0) cols(1) pos(11) region(lwidth(none))) ///
				 title("Time to $tableoutcome, SLE population", justification(left) size(med) )  	   ///
				 yscale(range(0, 1)) 											///
				 ylabel(0 (0.1) 1, angle(0) format(%4.1f) labsize(small))	///
				 xlabel(0 (20) 160, labsize(small))				   				///			
                 ytitle("Cumulative mortality (%)", size(medsmall)) ///
                 xtitle("Days since 1 Mar 2020", size(medsmall))      		///
				 graphregion(fcolor(white)) saving(adjcurv1, replace)

graph export "$Tabfigdir/adjcurv1_sle.svg", as(svg) replace

* Close window 
graph close

* Delete unneeded graphs
*erase adjcurv1_sle.gph

log close













