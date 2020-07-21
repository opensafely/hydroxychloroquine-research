import delimited `c(pwd)'/output/input.csv, clear
set more off 


* =====        MAIN ANALYSES       =================================================;
*set filepaths
global Projectdir `c(pwd)'
di "$Projectdir"
global Dodir "$Projectdir/analysis" 
di "$Dodir"
global Outdir "$Projectdir/output" 
di "$Outdir"
global Logdir "$Projectdir/output/log"
di "$Logdir"
global Tempdir "$Projectdir/output/tempdata" 
di "$Tempdir"
global Tabfigdir "$Projectdir/output/tabfig" 
di "$Tabfigdir"

* Create directories required  --- ANY OUTPUT STATA MAKES SHOULD BE PUT INTO OUTPUT FOLDER FROM ROOT DIRECTORY

*capture mkdir output /*ALREADY EXISTS WITH INPUT.CSV*/
capture mkdir "$Outdir/log"
capture mkdir "$Outdir/tempdata"
capture mkdir "$Outdir/tabfig"

* Set globals that will print in programs and direct output

global outcome 	  "onscoviddeath"
global tableoutcome "COVID-19 Death in ONS"
global ymax 0.005

* all variables included in fully adjusted models
global varlist "exposure male agegroup dmard_pc oral_prednisolone chronic_cardiac_disease resp_excl_asthma egfr_cat_nomiss chronic_liver_disease obese4cat hypertension cancer_ever neuro_conditions flu_vaccine"

pwd
cd  "$Dodir"
adopath + "$Dodir/adofiles"

/*  Pre-analysis data manipulation  */
do "00_cr_create_analysis_dataset.do"
* Data manipulation   
do "01_cr_create_population.do"
do "02_cr_create_exposure.do"
/*  Checks  */
do "03_an_checks.do"
/* Run analysis */ 
* Analyses 
do "04_an_descriptive_table.do"
do "05_an_descriptive_plots.do"
do "06_an_models.do"
do "07_an_models_interact.do"
do "08_an_model_checks.do"
do "09_an_model_explore.do"
do "10_an_models_ethnicity.do"
do "11_an_models_sep_pops.do"
do "12_an_models_sa_exposure.do"






/* DON'T NEED TO RUN AGAIN
* =====        PREVALENCE OF HCQ TPP-WIDE     =============================================;
cd ..
import delimited `c(pwd)'/output/input_hcq_pop.csv, clear
set more off 

pwd
cd  "$Dodir"
do "x2_hcq_pop.do"
*/







* =====        SENSITIVITY 1: Non-COVID death       =================================================;
clear 
cd ..
import delimited `c(pwd)'/output/input.csv, clear
set more off 

*set filepaths
global Projectdir `c(pwd)'
di "$Projectdir"
global Dodir "$Projectdir/analysis" 
di "$Dodir"
global Outdir "$Projectdir/output" 
di "$Outdir"
global Logdir "$Projectdir/output/sens1/log"
di "$Logdir"
global Tempdir "$Projectdir/output/sens1/tempdata" 
di "$Tempdir"
global Tabfigdir "$Projectdir/output/sens1/tabfig" 
di "$Tabfigdir"

* Create directories required  --- ANY OUTPUT STATA MAKES SHOULD BE PUT INTO OUTPUT FOLDER FROM ROOT DIRECTORY

capture mkdir "$Outdir/sens1" 
capture mkdir "$Outdir/sens1/log"
capture mkdir "$Outdir/sens1/tempdata"
capture mkdir "$Outdir/sens1/tabfig"

* Set globals that will print in programs and direct output

global outcome 	  "onsnoncoviddeath"
global tableoutcome "Non COVID-19 Death in ONS"
global ymax 0.01

* all variables included in fully adjusted models
global varlist "exposure male agegroup dmard_pc oral_prednisolone chronic_cardiac_disease resp_excl_asthma egfr_cat_nomiss chronic_liver_disease obese4cat hypertension cancer_ever neuro_conditions flu_vaccine"

pwd
cd  "$Dodir"
adopath + "$Dodir/adofiles"

/*  Pre-analysis data manipulation  */
do "00_cr_create_analysis_dataset.do"
* Data manipulation   
do "01_cr_create_population.do"
do "02_cr_create_exposure.do"
/*  Checks  */
*do "03_an_checks.do"
/* Run analysis */ 
* Analyses 
*do "04_an_descriptive_table.do"
do "05_an_descriptive_plots.do"
do "06_an_models.do"
do "07_an_models_interact.do"
do "08_an_model_checks.do"
do "09_an_model_explore.do"
do "10_an_models_ethnicity.do"
do "11_an_models_sep_pops.do"
do "12_an_models_sa_exposure.do"




* =====        SENSITIVITY 2: SGSS positive test      =================================================;
do "f1_forest_plots.do"




/* DON'T NEED TO RUN AGAIN
* =====        SENSITIVITY 2: SGSS positive test      =================================================;
clear 
cd ..
import delimited `c(pwd)'/output/input.csv, clear
set more off 

*set filepaths
global Projectdir `c(pwd)'
di "$Projectdir"
global Dodir "$Projectdir/analysis" 
di "$Dodir"
global Outdir "$Projectdir/output" 
di "$Outdir"
global Logdir "$Projectdir/output/sens2/log"
di "$Logdir"
global Tempdir "$Projectdir/output/sens2/tempdata" 
di "$Tempdir"
global Tabfigdir "$Projectdir/output/sens2/tabfig" 
di "$Tabfigdir"

* Create directories required  --- ANY OUTPUT STATA MAKES SHOULD BE PUT INTO OUTPUT FOLDER FROM ROOT DIRECTORY

capture mkdir "$Outdir/sens2" 
capture mkdir "$Outdir/sens2/log"
capture mkdir "$Outdir/sens2/tempdata"
capture mkdir "$Outdir/sens2/tabfig"

* Set globals that will print in programs and direct output

global outcome 	  "firstpos_sgss"
global tableoutcome "SGSS positive COVID-19 test"
global ymax 0.01

* all variables included in fully adjusted models
global varlist "exposure male agegroup dmard_pc oral_prednisolone chronic_cardiac_disease resp_excl_asthma egfr_cat_nomiss chronic_liver_disease obese4cat hypertension cancer_ever neuro_conditions flu_vaccine"

pwd
cd  "$Dodir"
adopath + "$Dodir/adofiles"

/*  Pre-analysis data manipulation  */
do "00_cr_create_analysis_dataset.do"
* Data manipulation   
do "01_cr_create_population.do"
do "02_cr_create_exposure.do"
/*  Checks  */
*do "03_an_checks.do"
/* Run analysis */ 
* Analyses 
*do "04_an_descriptive_table.do"
do "05_an_descriptive_plots.do"
do "06_an_models.do"
do "07_an_models_interact.do"
do "08_an_model_checks.do"
do "09_an_model_explore.do"
do "10_an_models_ethnicity.do"
do "11_an_models_sep_pops.do"
do "12_an_models_sa_exposure.do"










* =====        SENSITIVITY 3: primary care positive test      =================================================;
clear 
cd ..
import delimited `c(pwd)'/output/input.csv, clear
set more off 

*set filepaths
global Projectdir `c(pwd)'
di "$Projectdir"
global Dodir "$Projectdir/analysis" 
di "$Dodir"
global Outdir "$Projectdir/output" 
di "$Outdir"
global Logdir "$Projectdir/output/sens3/log"
di "$Logdir"
global Tempdir "$Projectdir/output/sens3/tempdata" 
di "$Tempdir"
global Tabfigdir "$Projectdir/output/sens3/tabfig" 
di "$Tabfigdir"

* Create directories required  --- ANY OUTPUT STATA MAKES SHOULD BE PUT INTO OUTPUT FOLDER FROM ROOT DIRECTORY

capture mkdir "$Outdir/sens3" 
capture mkdir "$Outdir/sens3/log"
capture mkdir "$Outdir/sens3/tempdata"
capture mkdir "$Outdir/sens3/tabfig"

* Set globals that will print in programs and direct output

global outcome 	  "firstpos_primcare"
global tableoutcome "Primary care positive COVID-19 test"
global ymax 0.01

* all variables included in fully adjusted models
global varlist "exposure male agegroup dmard_pc oral_prednisolone chronic_cardiac_disease resp_excl_asthma egfr_cat_nomiss chronic_liver_disease obese4cat hypertension cancer_ever neuro_conditions flu_vaccine"

pwd
cd  "$Dodir"
adopath + "$Dodir/adofiles"

/*  Pre-analysis data manipulation  */
do "00_cr_create_analysis_dataset.do"
* Data manipulation   
do "01_cr_create_population.do"
do "02_cr_create_exposure.do"
/*  Checks  */
*do "03_an_checks.do"
/* Run analysis */ 
* Analyses 
*do "04_an_descriptive_table.do"
do "05_an_descriptive_plots.do"
do "06_an_models.do"
do "07_an_models_interact.do"
do "08_an_model_checks.do"
do "09_an_model_explore.do"
do "10_an_models_ethnicity.do"
do "11_an_models_sep_pops.do"
do "12_an_models_sa_exposure.do"
*/