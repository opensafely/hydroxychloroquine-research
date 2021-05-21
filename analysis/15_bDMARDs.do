/*==============================================================================
DO FILE NAME:			15_bDMARDs
PROJECT:				HCQ in COVID-19 
DATE: 					21 May 2021 
AUTHOR:					C Rentsch
DESCRIPTION OF FILE:	Answers to reviewer comments
DATASETS USED:			$Tempdir\analysis_dataset.dta
						
DATASETS CREATED: 		None
OTHER OUTPUT: 			Log file: $Logdir\15_bDMARDs
USER-INSTALLED ADO: 	-none-
  (place .ado file(s) in analysis folder)								
==============================================================================*/




* Open a log file

capture log close
log using $Logdir\15_bDMARDs, replace t

* Open Stata dataset used for publication
use E:\analyses\hydroxychloroquine-research\output\archive\original_submission\tempdata\analysis_dataset.dta, clear
*n=194,637

*pull in new cohort extract that includes bDMARDs
import delimited E:\analyses\hydroxychloroquine-research/output/input.csv, clear
*only keep patient_id and bDMARDs 
keep patient_id bdmard*

tab1 bdmard*, m

*create a flag for any bDMARD in the 6 months prior to index date
gen bdmard_any = 1 if bdmard_abatacept == 1 | bdmard_adalimumab == 1 | bdmard_certolizumab == 1 | bdmard_etanercept == 1 | bdmard_golimumab == 1 | bdmard_infliximab == 1 | bdmard_sarilumab == 1 | bdmard_tocilizumab == 1
recode bdmard_any .=0

tab1 bdmard_any, m

*save off as bDMARD table
save $Outdir/bdmard.dta , replace

*bring in analysis dataset from publication
sort patient_id
merge 1:1 patient_id using E:\analyses\hydroxychloroquine-research\output\archive\original_submission\tempdata\analysis_dataset.dta

*there are 2370 missing in new cohort extract who were in published analytic dataset
*there are 4905 additional in new cohort extrat who were not in published analytic dataset
*192,267 were found in both

**look at bDMARD prevalence among those missing
tab _m bdmard_any  , m row

*only keep those in published analytic dataset
drop if _m == 1

*fill in missing bDMARD info as no bDMARDs
recode bdmard_any .=0

*prevalence of bDMARD among HCQ exposed and unexposed
tab bdmard_any hcq  ,m col

*not looking like a difference
/*

           |          HCQ
bdmard_any |         0          1 |     Total
-----------+----------------------+----------
         0 |   158,836     29,885 |   188,721 
           |     96.81      97.76 |     96.96 
-----------+----------------------+----------
         1 |     5,232        684 |     5,916 
           |      3.19       2.24 |      3.04 
-----------+----------------------+----------
     Total |   164,068     30,569 |   194,637 
           |    100.00     100.00 |    100.00 
*/




***stset the dataset and then run the primary models
stset stime_$outcome, fail($outcome) id(patient_id) enter(enter_date) origin(enter_date)


/* Main Model=================================================================*/


*recode unknown ethnicity to missing
recode ethnicity .u=.
*mi set the data (aka stset) 
mi set mlong
*mi register (tell Stata which variable to impute)
mi register imputed ethnicity
*mi impute the dataset
mi impute mlogit ethnicity i.exposure _d i.population i.stp i.male age1 age2 age3 i.dmard_pc i.oral_prednisolone i.nsaids i.chronic_cardiac_disease i.resp_excl_asthma i.egfr_cat_nomiss i.chronic_liver_disease i.obese4cat i.hypertension i.cancer_ever i.neuro_conditions i.flu_vaccine i.imd i.diabcat i.smoke_nomiss, add(10) rseed(8675309) augment force 
*mi stset
mi stset stime_$outcome, fail($outcome) id(patient_id) enter(enter_date) origin(enter_date)	


 * DAG adjusted (age, sex, ethnicity, geographic region, other immunosuppressives 
mi estimate, dots post: stcox i.exposure i.male age1 age2 age3 i.ethnicity i.dmard_pc i.oral_prednisolone, strata(stp population)	
*AND NOW WITH BDMARDS
mi estimate, dots post: stcox i.exposure i.male age1 age2 age3 i.ethnicity i.dmard_pc i.oral_prednisolone i.bdmard_any, strata(stp population)				


* DAG+ other adjustments (NSAIDs, heart disease, lung disease, kidney disease, liver disease, BMI, hypertension, cancer, stroke, dementia, and respiratory disease excl asthma (OCS capturing ashtma))
mi estimate, dots post: stcox i.exposure i.male age1 age2 age3 i.ethnicity i.dmard_pc i.oral_prednisolone i.nsaids i.chronic_cardiac_disease i.resp_excl_asthma i.egfr_cat_nomiss i.chronic_liver_disease i.obese4cat i.hypertension i.cancer_ever i.neuro_conditions i.flu_vaccine i.imd i.diabcat i.smoke_nomiss, strata(stp population)	
*AND NOW WITH BDMARDS
mi estimate, dots post: stcox i.exposure i.male age1 age2 age3 i.ethnicity i.dmard_pc i.oral_prednisolone i.bdmard_any i.nsaids i.chronic_cardiac_disease i.resp_excl_asthma i.egfr_cat_nomiss i.chronic_liver_disease i.obese4cat i.hypertension i.cancer_ever i.neuro_conditions i.flu_vaccine i.imd i.diabcat i.smoke_nomiss, strata(stp population)	
 

log close
