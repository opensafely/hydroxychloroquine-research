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
USER-INSTALLED ADO: 	 
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

sts graph, by(exposure) failure 							    			///	
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

* Close log file 
log close
















