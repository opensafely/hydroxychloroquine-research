cd  `c(pwd)'/analysis
import delimited input.csv, clear
set more off 


* Create directories required 

capture mkdir output
capture mkdir log
capture mkdir tempdata

* Set globals that will print in programs and direct output

global outcome 	  "onscoviddeath"
global outdir  	  "output" 
global logdir     "log"
global tempdir    "tempdata"
/*global varlist 		i.obese4cat					///
					i.smoke_nomiss				///
					i.imd 						///
					i.ckd	 					///
					i.hypertension			 	///
					i.heart_failure				///
					i.other_heart_disease		///
					i.diabcat 					///
					i.cancer_ever 				///
					i.statin 					///
					i.flu_vaccine 				///
					i.pneumococcal_vaccine		///
					i.exacerbations 			///
					i.asthma_ever				///
					i.immunodef_any
*/					
global tableoutcome "COVID-19 Death in ONS"
global ymax 0.005

/*  Pre-analysis data manipulation  */

*do "00_cr_create_analysis_dataset.do"