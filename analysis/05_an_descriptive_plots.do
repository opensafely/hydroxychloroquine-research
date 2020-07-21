/*==============================================================================
DO FILE NAME:			05_an_descriptive_plots
PROJECT:				HCQ in COVID-19 
DATE: 					6 July 2020 
AUTHOR:					C Rentsch
						adapted from A Schultze 
DESCRIPTION OF FILE:	create KM plot
						save KM plot 
						
DATASETS USED:			$Tempdir\analysis_dataset_STSET_$outcome.dta
DATASETS CREATED: 		None
OTHER OUTPUT: 			Results in svg: $Tabfigdir\kmplot1
						Log file: $Logdir\05_an_descriptive_plots
USER-INSTALLED ADO: 	stmp2
  (place .ado file(s) in analysis folder)							
==============================================================================*/


* Open a log file
capture log close
log using $Logdir\05_an_descriptive_plots, replace t

* Open Stata dataset
use $Tempdir\analysis_dataset_STSET_$outcome, clear

/* Sense check outcomes=======================================================*/ 
tab exposure $outcome

/* Generate KM PLOT===========================================================*/ 

count if exposure != .u
noi display "RUNNING THE KM PLOT FOR `r(N)' PEOPLE WITH NON-MISSING EXPOSURE"

sts graph, by(exposure) failure ci							    			///	
		   title("Time to $tableoutcome", justification(left) size(medsmall) )  	   ///
		   xtitle("Days since 1 Mar 2020", size(small))						///
		   yscale(range(0, $ymax)) 											///
		   ylabel(0 (0.001) $ymax, angle(0) format(%4.3f) labsize(small))	///
		   xscale(range(30, 84)) 											///
		   xlabel(0 (20) 160, labsize(small))				   				///				
		   legend(size(vsmall) label (1 "No HCQ") label (2 "HCQ") region(lwidth(none)) position(12))	///
		   graphregion(fcolor(white)) ///	
		   risktable(,size(vsmall) order (1 "No HCQ" 2 "HCQ") title(,size(vsmall))) ///
		   saving(kmplot1, replace)

graph export "$Tabfigdir/kmplot1.svg", as(svg) replace

* Close window 
graph close

* Delete unneeded graphs
erase kmplot1.gph







/* DAG Adjusted curves =======================================================*/ 
//stpm2 exposure male age1 age2 age3 dmard_pc oral_prednisolone, df(4) scale(hazard) eform /*strata(stp population) ******************** TO DO: HOW TO HANDLE STRATA ***/	

*NOTE: this model will not run with stp and population as stratification variables
*Moved population to an indicator variable, and will compare model estimates from stcox
stpm2 exposure male age1 age2 age3 dmard_pc oral_prednisolone population, df(4) scale(hazard) eform stratify(stp)

summ _t
local tmax=r(max)
local tmaxplus1=r(max)+1

range days 0 `tmax' `tmaxplus1'
stpm2_standsurv if exposure == 1, at1(exposure 0) at2(exposure 1) timevar(days) ci contrast(difference) fail

gen date = d(1/3/2020)+ days
format date %tddd_Month

for var _at1 _at2 _at1_lci _at1_uci _at2_lci _at2_uci: replace X=100*X

*l date days _at1 _at1_lci _at1_uci _at2 _at2_lci _at2_uci if days<.

twoway  (rarea _at1_lci _at1_uci days, color(red%25)) ///
                 (rarea _at2_lci _at2_uci days if _at2_uci<1, color(blue%25)) ///
                 (line _at1 days, sort lcolor(red)) ///
                 (line _at2  days, sort lcolor(blue)) ///
                 , legend(order(1 "No HCQ" 2 "HCQ") ring(0) cols(1) pos(11) region(lwidth(none))) ///
				 title("Time to $tableoutcome", justification(left) size(med) )  	   ///
				 yscale(range(0, 1)) 											///
				 ylabel(0 (0.1) 1, angle(0) format(%4.1f) labsize(small))	///
				 xlabel(0 (20) 160, labsize(small))				   				///			
                 ytitle("Cumulative mortality (%)", size(medsmall)) ///
                 xtitle("Days since 1 Mar 2020", size(medsmall))      		///
				 graphregion(fcolor(white)) saving(adjcurv1, replace)

graph export "$Tabfigdir/adjcurv1.svg", as(svg) replace

* Close window 
graph close

* Delete unneeded graphs
erase adjcurv1.gph


* Close log file 
log close











