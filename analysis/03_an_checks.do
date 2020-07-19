/*==============================================================================
DO FILE NAME:			03_an_checks
PROJECT:				HCQ in COVID-19 
DATE: 					30 June 2020 
AUTHOR:					C Rentsch
						adapted from A Schultze 	
DESCRIPTION OF FILE:	Run sanity checks on all variables
							- Check variables take expected ranges 
							- Cross-check logical relationships 
							- Explore expected relationships 
							- Check stsettings 
DATASETS USED:			$Tempdir\analysis_dataset.dta
DATASETS CREATED: 		None
OTHER OUTPUT: 			Log file: $Logdir\03_an_checks
USER-INSTALLED ADO: 	datacheck 
  (place .ado file(s) in analysis folder)								
==============================================================================*/


* Open a log file

capture log close
log using $Logdir\03_an_checks, replace t

* Open Stata dataset
use $Tempdir\analysis_dataset, clear


*Duplicate patient check
datacheck _n==1, by(patient_id) nol

/* EXPECTED VALUES============================================================*/ 

* Age
datacheck age<., nol
datacheck inlist(agegroup, 1, 2, 3, 4, 5, 6), nol
datacheck inlist(age70, 0, 1), nol

* Sex
datacheck inlist(male, 0, 1), nol

* BMI 
datacheck inlist(obese4cat, 1, 2, 3, 4), nol
datacheck inlist(bmicat, 1, 2, 3, 4, 5, 6, .u), nol

* IMD
datacheck inlist(imd, 1, 2, 3, 4, 5), nol

* Residence type
datacheck inlist(residence_type, 1, 2, 3, 4, 5, 6, 7, 8, .u), nol

* Ethnicity
datacheck inlist(ethnicity, 1, 2, 3, 4, 5, .u), nol

* Smoking
datacheck inlist(smoke, 1, 2, 3, .u), nol
datacheck inlist(smoke_nomiss, 1, 2, 3), nol 



* Check date ranges for all treatment variables   
foreach var of varlist 	hcq					///
						dmard_pc        	///
						oral_prednisolone 	///
						nsaids				///
						azith				///
	 {
						
	tab `var', missing					
	summ `var'_date, format

}

* Check date ranges for all comorbidities 
foreach var of varlist  chronic_cardiac_disease_date	///
						chronic_liver_disease_date		///
						egfr_date     					///
						hypertension_date				///
						diabetes_date					///
						cancer_ever_date 				///
						perm_immunodef_date				///
						temp_immunodef_date				///
						hba1c_mmol_per_mol_date			///
						hba1c_percentage_date			///
						resp_excl_asthma_date			///	
						current_asthma_date				///
						neuro_conditions_date	 		///
						rheumatoid_date					///
						sle_date	{ 
						
	summ `var', format

}



* Outcome dates
summ  died_date_onscovid died_date_onsnoncovid first_pos_test_sgss first_pos_test_primcare, format

* Censoring dates
summ  onscoviddeathcensor_date hcq_first_after_date, format

* Last dates
summ  stime_onscoviddeath stime_onsnoncoviddeath stime_firstpos_sgss stime_firstpos_primcare,   format




/* FREQUENCIES ===============================================================*/ 
* Check frequency of all variables in fully adjusted model 
foreach comorb in $varlist { 

	local comorb: subinstr local comorb "i." ""
	tab `comorb', m
	
}



/* LOGICAL RELATIONSHIPS======================================================*/ 

* BMI
bysort bmicat: summ bmi
tab bmicat obese4cat, m

* Age
bysort agegroup: summ age
tab agegroup age70, m

* Smoking
tab smoke smoke_nomiss, m

* Diabetes
tab diabcat diabetes, m

* eGFR
tab egfr_cat_nomiss egfr_cat, m

* urban residence
*tab residence_type urban, m




/* EXPECTED RELATIONSHIPS=====================================================*/ 

/*  Relationships between demographic/lifestyle variables  */

// tab agegroup bmicat, 	row 
// tab agegroup smoke, 	row  
// tab agegroup ethnicity, row 
// tab agegroup imd, 		row 
//
// tab bmicat smoke, 		 row   
// tab bmicat ethnicity, 	 row 
// tab bmicat imd, 	 	 row 
// tab bmicat hypertension, row 
//                            
// tab smoke ethnicity, 	row 
// tab smoke imd, 			row 
// tab smoke hypertension, row 
//                            
// tab ethnicity imd, 		row 
//
// * Relationships with age
// foreach var in $varlist  				{
// 	local var: subinstr local var "i." ""
//  	tab agegroup `var', row 
//  }
//
//
//  * Relationships with sex
// foreach var in $varlist 					{
// 	local var: subinstr local var "i." ""						
//  	tab male `var', row 
// }
//
//  * Relationships with smoking
// foreach var in $varlist 				{
// 	local var: subinstr local var "i." ""	
//  	tab smoke `var', row 
// }



/* CROSS TABS=================================================================*/ 
/* Treatment variables */ 
foreach var of varlist 	hcq					///
						dmard_pc 			///
						azith	        	///
						oral_prednisolone 	///
						{
						
	tab exposure `var', row col missing

}

/* AGE/SEX DISTRIBUTION BY HCQ USE      ======================================*/
tab agegroup sex if hcq == 1,m
tab agegroup sex if hcq == 0,m


/* SENSE CHECK POPULATIONS====================================================*/
tab rheumatoid sle, row col
tab population, m
tab population rheumatoid, m
tab population sle, m


/* SENSE CHECK OUTCOMES=======================================================*/
tab firstpos_sgss firstpos_primcare, row col
tab onscoviddeath onsnoncoviddeath, row col

/* ENSURE ENOUGH DEATHS IN EACH CATEGORY INCLUDED IN FULLY ADJUSTED MODEL ====*/
foreach var in $varlist 				{
	local var: subinstr local var "i." ""	
 	tab onscoviddeath `var', row 
}

foreach var in $varlist 				{
	local var: subinstr local var "i." ""	
 	tab onsnoncoviddeath `var', row 
}


* Close log file 
log close
