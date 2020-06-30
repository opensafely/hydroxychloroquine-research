cd  `c(pwd)'
import delimited "$Outdir/input.csv", clear
set more off 


* Create directories required  --- ANY OUTPUT STATA MAKES SHOULD BE PUT INTO OUTPUT FOLDER FROM ROOT DIRECTORY

*capture mkdir output /*ALREADY EXISTS WITH INPUT.CSV*/
capture mkdir "$Outdir/log"
capture mkdir "$Outdir/tempdata"

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

cd $Dodir

/*  Pre-analysis data manipulation  */

do "00_cr_create_analysis_dataset.do"

* Data manipulation   
*do "01_cr_create_population.do"
*do "02_cr_create_exposure.do"

/*  Checks  */

*do "03_an_checks.do"

/* Run analysis */ 

* Analyses 
*do "04_an_descriptive_table.do"
*do "05_an_descriptive_plots.do"
*do "06_an_models.do"
*do "07_an_models_interact.do"
*do "08_an_model_checks.do"
*do "09_an_model_explore.do"
*do "10_an_models_ethnicity.do"
