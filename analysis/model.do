import delimited `c(pwd)'/output/input.csv, clear
set more off 


*set filepaths
global Projectdir `c(pwd)'
di "$Projectdir"
global Dodir "$Projectdir\analysis" 
di "$Dodir"
global Outdir "$Projectdir\output" 
di "$Outdir"
global Logdir "$Projectdir\output\log"
di "$Logdir"
global Tempdir "$Projectdir\output\tempdata" 
di "$Tempdir"


* Create directories required  --- ANY OUTPUT STATA MAKES SHOULD BE PUT INTO OUTPUT FOLDER FROM ROOT DIRECTORY

*capture mkdir output /*ALREADY EXISTS WITH INPUT.CSV*/
capture mkdir "$Outdir/log"
capture mkdir "$Outdir/tempdata"

* Set globals that will print in programs and direct output

global outcome 	  "onscoviddeath"
// global outdir  	  "output" 
// global logdir     "log"
// global tempdir    "tempdata"
global varlist 		i.agegroup					///
					i.male						///
					i.ethnicity					///
					i.imd						///
					i.urban						///
					i.obese4cat					///
					i.smoke						///
					i.smoke_nomiss				///
					i.dmard_pc					///
					i.azith						///
					i.oral_prednisolone			///
					i.chronic_cardiac_disease	///
					i.chronic_liver_disease		///
					i.ckd 						///
					i.egfr_cat	 				///
					i.hypertension			 	///
					i.diabetes					///
					i.diabcat 					///
					i.cancer_ever				///
					i.immunodef_any 			///
					i.resp_excl_asthma 			///
					i.current_asthma 			///
					i.other_neuro_conditions	///
					i.flu_vaccine 				///
					i.pneumococcal_vaccine		///
					i.gp_consult

				 

global tableoutcome "COVID-19 Death in ONS"
global ymax 0.005

cd  "$Dodir"

/*  Pre-analysis data manipulation  */

do "00_cr_create_analysis_dataset.do"

* Data manipulation   
do "01_cr_create_population.do"
do "02_cr_create_exposure.do"

/*  Checks  */

do "03_an_checks.do"

/* Run analysis */ 

* Analyses 
*do "04_an_descriptive_table.do"
*do "05_an_descriptive_plots.do"
*do "06_an_models.do"
*do "07_an_models_interact.do"
*do "08_an_model_checks.do"
*do "09_an_model_explore.do"
*do "10_an_models_ethnicity.do"
