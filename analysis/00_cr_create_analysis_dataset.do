/*==============================================================================
DO FILE NAME:			00_cr_create_analysis_dataset
PROJECT:				HCQ in COVID-19 
DATE: 					17 June 2020 
AUTHOR:					C Rentsch
						adapted from A Schultze 										
DESCRIPTION OF FILE:	program 00, data management for HCQ project  
						reformat variables 
						categorise variables
						label variables 
DATASETS USED:			data in memory (from output/input.csv)

DATASETS CREATED: 		none
OTHER OUTPUT: 			logfiles, printed to folder output/$logdir
USER-INSTALLED ADO: 	 
  (place .ado file(s) in analysis folder)						
==============================================================================*/

* Open a log file

cap log close
log using $Logdir\00_cr_create_analysis_dataset, replace t


/* SET Index date ===========================================================*/
global indexdate 			= "01/03/2020"




/* DROP VARAIBLES===========================================================*/

*flu_vaccine is combination of the three others
drop flu_vaccine_tpp_table flu_vaccine_med flu_vaccine_clinical
*pneumococcal_vaccine is combination of the three others
drop pneumococcal_vaccine_tpp_table pneumococcal_vaccine_med pneumococcal_vaccine_clinical 



/* RENAME VARAIBLES===========================================================*/

rename bmi_date_measured  	    			bmi_date_measured
rename chronic_respiratory_excl_asthma		resp_excl_asthma
rename oral_prednisolone_exposure			oral_prednisolone
rename dmards_primary_care_exposure			dmards_primary_care


/* CONVERT STRINGS TO DATE====================================================*/
/* Comorb dates are given with month/year only, so adding day 15 to enable
   them to be processed as dates 											  */

foreach var of varlist 	 azith_last_date					///
						bmi_date_measured					///
						 cancer								///
						 chloroquine_not_hcq				///
						 chronic_cardiac_disease			///
						 chronic_liver_disease				///
						 creatinine_date					///
						 current_asthma						///	
						 diabetes							///
						 dmards_primary_care				///
						 hba1c_mmol_per_mol_date			///
						 hba1c_percentage_date				///
						 hcq_last_date						///
						 hypertension						///
						 esrf 								///						 
						 oral_prednisolone					///	   			 
						 other_neuro_conditions				///
						 permanent_immunodeficiency			///
						 resp_excl_asthma					///		
						 rheumatoid							///
						 sle								///
						 smoking_status_date				///
						 temporary_immunodeficiency	 {
						 	
		capture confirm string variable `var'
		if _rc!=0 {
			assert `var'==.
			rename `var' `var'_date
		}
	
		else {
				replace `var' = `var' + "-15"
				rename `var' `var'_dstr
				replace `var'_dstr = " " if `var'_dstr == "-15"
				gen `var'_date = date(`var'_dstr, "YMD") 
				order `var'_date, after(`var'_dstr)
				drop `var'_dstr
		}
	
	format `var'_date %td
}

* Note - outcome dates are handled separtely below 


*HCQ after baseline is in YMD format
gen hcq_first_after_date = date(hcq_first_after, "YMD")
format hcq_first_after_date %td
drop hcq_first_after


/* RENAME VARAIBLES===========================================================*/
*  An extra 'date' added to the end of some variable names, remove 
rename azith_last_date_date				azith_last_date
rename hcq_last_date_date				hcq_last_date
rename creatinine_date_date 			creatinine_measured_date
rename smoking_status_date_date 		smoking_status_measured_date
rename bmi_date_measured_date  			bmi_measured_date
rename hba1c_percentage_date_date		hba1c_percentage_date 
rename hba1c_mmol_per_mol_date_date		hba1c_mmol_per_mol_date


* Some names too long for loops below, shorten

rename permanent_immunodeficiency_date perm_immunodef_date
rename temporary_immunodeficiency_date temp_immunodef_date



/* CREATE BINARY VARIABLES====================================================*/
*  Make indicator variables for all conditions where relevant 

foreach var of varlist 	 cancer_date						///
						 chloroquine_not_hcq_date			///
						 chronic_cardiac_disease_date		///
						 chronic_liver_disease_date			///
						 current_asthma_date				///	
						 diabetes_date						///
						 hypertension_date					///
						 esrf_date 							///						 
						 oral_prednisolone_date				///					 
						 other_neuro_conditions_date		///
						 perm_immunodef_date				///
						 resp_excl_asthma_date				///						 
						 smoking_status_measured_date		///
						 temp_immunodef_date			 {
	/* date ranges are applied in python, so presence of date indicates presence of 
	  disease in the correct time frame */ 
	local newvar =  substr("`var'", 1, length("`var'") - 5)
	gen `newvar' = (`var'!=. )
	order `newvar', after(`var')
	
}



/* CREATE VARIABLES===========================================================*/

/* DEMOGRAPHICS */ 

* Sex
gen male = 1 if sex == "M"
replace male = 0 if sex == "F"

* Ethnicity
replace ethnicity = .u if ethnicity == .

label define ethnicity 	1 "White"  					///
						2 "Mixed" 					///
						3 "Asian or Asian British"	///
						4 "Black"  					///
						5 "Other"					///
						.u "Unknown"
label values ethnicity ethnicity

* STP 
rename stp stp_old
bysort stp_old: gen stp = 1 if _n==1
replace stp = sum(stp)
drop stp_old

/*  IMD  */
* Group into 5 groups
rename imd imd_o
egen imd = cut(imd_o), group(5) icodes

* add one to create groups 1 - 5 
replace imd = imd + 1

* - 1 is missing, should be excluded from population 
replace imd = .u if imd_o == -1
drop imd_o

* Reverse the order (so high is more deprived)
recode imd 5 = 1 4 = 2 3 = 3 2 = 4 1 = 5 .u = .u

label define imd 1 "1 least deprived" 2 "2" 3 "3" 4 "4" 5 "5 most deprived" .u "Unknown"
label values imd imd 

/*  Age variables  */ 

* Create categorised age
recode age 18/39.9999 = 1 /// 
           40/49.9999 = 2 ///
		   50/59.9999 = 3 ///
	       60/69.9999 = 4 ///
		   70/79.9999 = 5 ///
		   80/max = 6, gen(agegroup) 

label define agegroup 	1 "18-<40" ///
						2 "40-<50" ///
						3 "50-<60" ///
						4 "60-<70" ///
						5 "70-<80" ///
						6 "80+"
						
label values agegroup agegroup

* Create binary age
recode age min/69.999 = 0 ///
           70/max = 1, gen(age70)

* Check there are no missing ages
assert age < .
assert agegroup < .
assert age70 < .

* Create restricted cubic splines for age
mkspline age = age, cubic nknots(4)

/*  Body Mass Index  */
* NB: watch for missingness

* Recode strange values 
replace bmi = . if bmi == 0 
replace bmi = . if !inrange(bmi, 15, 50)

* Restrict to within 10 years of index and aged > 16 
gen bmi_time = (date("$indexdate", "DMY") - bmi_measured_date)/365.25
gen bmi_age = age - bmi_time

replace bmi = . if bmi_age < 16 
replace bmi = . if bmi_time > 10 & bmi_time != . 

* Set to missing if no date, and vice versa 
replace bmi = . if bmi_measured_date == . 
replace bmi_measured_date = . if bmi == . 
replace bmi_measured_date = . if bmi == . 

gen 	bmicat = .
recode  bmicat . = 1 if bmi < 18.5
recode  bmicat . = 2 if bmi < 25
recode  bmicat . = 3 if bmi < 30
recode  bmicat . = 4 if bmi < 35
recode  bmicat . = 5 if bmi < 40
recode  bmicat . = 6 if bmi < .
replace bmicat = .u if bmi >= .

label define bmicat 1 "Underweight (<18.5)" 	///
					2 "Normal (18.5-24.9)"		///
					3 "Overweight (25-29.9)"	///
					4 "Obese I (30-34.9)"		///
					5 "Obese II (35-39.9)"		///
					6 "Obese III (40+)"			///
					.u "Unknown (.u)"
					
label values bmicat bmicat

* Create less  granular categorisation
recode bmicat 1/3 .u = 1 4 = 2 5 = 3 6 = 4, gen(obese4cat)

label define obese4cat 	1 "No record of obesity" 	///
						2 "Obese I (30-34.9)"		///
						3 "Obese II (35-39.9)"		///
						4 "Obese III (40+)"		

label values obese4cat obese4cat
order obese4cat, after(bmicat)

/*  Smoking  */

* Smoking 
label define smoke 1 "Never" 2 "Former" 3 "Current" .u "Unknown (.u)"

gen     smoke = 1  if smoking_status == "N"
replace smoke = 2  if smoking_status == "E"
replace smoke = 3  if smoking_status == "S"
replace smoke = .u if smoking_status == "M"
replace smoke = .u if smoking_status == "" 

label values smoke smoke
drop smoking_status

* Create non-missing 3-category variable for current smoking
* Assumes missing smoking is never smoking 
recode smoke .u = 1, gen(smoke_nomiss)
order smoke_nomiss, after(smoke)
label values smoke_nomiss smoke

/* CLINICAL COMORBIDITIES */ 


/* GP consultation rate */ 
replace gp_consult_count = 0 if gp_consult_count <1 

* those with no count assumed to have no visits 
replace gp_consult_count = 0 if gp_consult_count == . 
gen gp_consult = (gp_consult_count >=1)

/*  Cancer  */
*rename to make new vars stick to old code
rename cancer_date cancer_ever_date
rename cancer cancer_ever

/* Vaccines */ 
replace pneumococcal_vaccine = 0 if pneumococcal_vaccine == . 
replace flu_vaccine = 0 if flu_vaccine == . 

/*  Immunosuppression  */

* Immunosuppressed:
* permanent immunodeficiency ever (HIV, aplastic anaemia , etc) OR 
* temporary immunodeficiency in last year
gen temp1  = perm_immunodef
gen temp2  = inrange(temp_immunodef_date, (date("$indexdate", "DMY") - 365), date("$indexdate", "DMY"))

egen immunodef_any = rowmax(temp1 temp2)
drop temp1 temp2
order immunodef_any, after(temp_immunodef_date)

/* eGFR */

* Set implausible creatinine values to missing (Note: zero changed to missing)
replace creatinine = . if !inrange(creatinine, 20, 3000) 

* Remove creatinine dates if no measurements, and vice versa 

replace creatinine = . if creatinine_measured_date == . 
replace creatinine_measured_date = . if creatinine == . 


* Divide by 88.4 (to convert umol/l to mg/dl)
gen SCr_adj = creatinine/88.4

gen min = .
replace min = SCr_adj/0.7 if male==0
replace min = SCr_adj/0.9 if male==1
replace min = min^-0.329  if male==0
replace min = min^-0.411  if male==1
replace min = 1 if min<1

gen max=.
replace max=SCr_adj/0.7 if male==0
replace max=SCr_adj/0.9 if male==1
replace max=max^-1.209
replace max=1 if max>1

gen egfr=min*max*141
replace egfr=egfr*(0.993^age)
replace egfr=egfr*1.018 if male==0
label var egfr "egfr calculated using CKD-EPI formula with no eth"

* Categorise into ckd stages
egen egfr_cat_all = cut(egfr), at(0, 15, 30, 45, 60, 5000)
recode egfr_cat_all 0 = 5 15 = 4 30 = 3 45 = 2 60 = 0, generate(ckd_egfr)

/* 
0 "No CKD, eGFR>60" 	or missing -- have been shown reasonable in CPRD
2 "stage 3a, eGFR 45-59" 
3 "stage 3b, eGFR 30-44" 
4 "stage 4, eGFR 15-29" 
5 "stage 5, eGFR <15"
*/

gen egfr_cat = .
recode egfr_cat . = 3 if egfr < 30
recode egfr_cat . = 2 if egfr < 60
recode egfr_cat . = 1 if egfr < .
replace egfr_cat = .u if egfr >= .

label define egfr_cat 	1 ">=60" 		///
						2 "30-59"		///
						3 "<30"			///
						.u "Unknown (.u)"
					
label values egfr_cat egfr_cat

*if missing eGFR, assume normal

gen egfr_cat_nomiss = egfr_cat
replace egfr_cat_nomiss = 1 if egfr_cat == .u

label define egfr_cat_nomiss 	1 ">=60/missing" 	///
								2 "30-59"			///
								3 "<30"	
label values egfr_cat_nomiss egfr_cat_nomiss

gen egfr_date = creatinine_measured_date
format egfr_date %td

* Add in end stage renal failure and create a single CKD variable 
* Missing assumed to not have CKD 
gen ckd = 0
replace ckd = 1 if ckd_egfr != . & ckd_egfr >= 1
replace ckd = 1 if esrf == 1

label define ckd 0 "No CKD" 1 "CKD"
label values ckd ckd
label var ckd "CKD stage calc without eth"

* Create date (most recent measure prior to index)
gen temp1_ckd_date = creatinine_measured_date if ckd_egfr >=1
gen temp2_ckd_date = esrf_date if esrf == 1
gen ckd_date = max(temp1_ckd_date,temp2_ckd_date) 
format ckd_date %td 

/* HbA1c */

/*  Diabetes severity  */

* Set zero or negative to missing
replace hba1c_percentage   = . if hba1c_percentage <= 0
replace hba1c_mmol_per_mol = . if hba1c_mmol_per_mol <= 0

/* Express  HbA1c as percentage  */ 

* Express all values as perecentage 
noi summ hba1c_percentage hba1c_mmol_per_mol 
gen 	hba1c_pct = hba1c_percentage 
replace hba1c_pct = (hba1c_mmol_per_mol/10.929)+2.15 if hba1c_mmol_per_mol<. 

* Valid % range between 0-20  
replace hba1c_pct = . if !inrange(hba1c_pct, 0, 20) 
replace hba1c_pct = round(hba1c_pct, 0.1)

/* Categorise hba1c and diabetes  */

* Group hba1c
gen 	hba1ccat = 0 if hba1c_pct <  6.5
replace hba1ccat = 1 if hba1c_pct >= 6.5  & hba1c_pct < 7.5
replace hba1ccat = 2 if hba1c_pct >= 7.5  & hba1c_pct < 8
replace hba1ccat = 3 if hba1c_pct >= 8    & hba1c_pct < 9
replace hba1ccat = 4 if hba1c_pct >= 9    & hba1c_pct !=.
label define hba1ccat 0 "<6.5%" 1">=6.5-7.4" 2">=7.5-7.9" 3">=8-8.9" 4">=9"
label values hba1ccat hba1ccat

* Create diabetes, split by control/not
gen     diabcat = 1 if diabetes==0
replace diabcat = 2 if diabetes==1 & inlist(hba1ccat, 0, 1)
replace diabcat = 3 if diabetes==1 & inlist(hba1ccat, 2, 3, 4)
replace diabcat = 4 if diabetes==1 & !inlist(hba1ccat, 0, 1, 2, 3, 4)

label define diabcat 	1 "No diabetes" 			///
						2 "Controlled diabetes"		///
						3 "Uncontrolled diabetes" 	///
						4 "Diabetes, no hba1c measure"
label values diabcat diabcat

* Delete unneeded variables
drop hba1c_pct hba1c_percentage hba1c_mmol_per_mol


* urban vs rural flag
gen urban = .
replace urban = 1 if rural_urban in(1,2,3,4)
replace urban = 0 if rural_urban in(5,6,7,8)

// label define imd 1 "1 least deprived" 2 "2" 3 "3" 4 "4" 5 "5 most deprived" .u "Unknown"
// label values imd imd 






/* EXPOSURE INFORMATION ====================================================*/
rename hcq_last_date hcq_date
gen hcq = 1 if hcq_count != . & hcq_count >= 2
recode hcq .=0

gen hcq_sa = 1 if hcq_count != . & hcq_count >= 1 & hcq_date != . & hcq_date >= mdy(12,1,2019)
recode hcq_sa .=0

tab1 hcq hcq_sa, m
tab hcq hcq_sa, m










/* OTHER DRUGS =============================================================*/

*DMARDS
rename dmards_primary_care_date dmard_pc_date

gen dmard_pc = 1 if dmards_primary_care_count != . & dmards_primary_care_count >= 2
recode dmard_pc .=0

gen dmard_pc_sa = 1 if dmards_primary_care_count != . & dmards_primary_care_count >= 1 & dmard_pc_date != . & dmard_pc_date >= mdy(12,1,2019)
recode dmard_pc_sa .=0

tab1 dmard_pc dmard_pc_sa, m
tab dmard_pc dmard_pc_sa, m


*Macrolides (i.e., azithromycin)
*rename macrolides azith_count
rename azith_last_date azith_date
gen azith = 1 if azith_count != . & azith_count >= 1
recode azith .=0

*Steroids (dealt with at the top of the do file -- only needed one Rx in time window)
*vars oral_prednisolone_count oral_prednisolone_date are available
*final var to use is oral_prednisolone 




*****************************************************************************************************************************TO DO: add NSAIDS





/* OUTCOME AND SURVIVAL TIME==================================================*/


/*  Cohort entry and censor dates  */

* Date of cohort entry, 1 Mar 2020
gen enter_date = date("$indexdate", "DMY")
format enter_date %td


/*   Outcomes   */

* Outcomes: First test positive date, ONS-covid death
* Censoring: First HCQ after baseline
* Recode to dates from the strings 
foreach var of varlist 	died_date_ons 				///
						first_positive_test_date	///
						{			
	confirm string variable `var'
	rename `var' `var'_dstr
	gen `var' = date(`var'_dstr, "YMD")
	drop `var'_dstr
	format `var' %td 
}

* Date of Covid death in ONS
gen died_date_onscovid = died_date_ons if died_ons_covid_flag_any == 1

* Date of non-COVID death in ONS 
* If missing date of death resulting died_date will also be missing
gen died_date_onsnoncovid = died_date_ons if died_ons_covid_flag_any != 1 

format died_date_ons %td
format died_date_onscovid %td 
format died_date_onsnoncovid %td
format first_positive_test_date %td

/* CENSORING */
/* SET FU DATES===============================================================*/ 
* Censoring dates for each outcome (largely, last date outcome data available, minus a lag window) ********* TO DO: graph outcomes to find lag
summ died_date_ons, format
gen onscoviddeathcensor_date = r(max)-7

summ first_positive_test_date, format
gen testposcensor_date = r(max)

format testposcensor_date onscoviddeathcensor_date	%td

* Only censor at first HCQ on or after baseline if in unexposed group. Do not censor among exposed group 
replace hcq_first_after_date = . if hcq == 1 | hcq_sa == 1


* Binary indicators for outcomes
gen onscoviddeath 	= (died_date_onscovid 	< .)
gen onsnoncoviddeath = (died_date_onsnoncovid < .)
gen firstpos 		= (first_positive_test_date		< .)

/*  Create survival times  */

* For looping later, name must be stime_binary_outcome_name

* Survival time = last followup date (first: end study, first HCQ after baseline among unexposed, death, or that outcome)
gen stime_onscoviddeath = min(onscoviddeathcensor_date, hcq_first_after_date, died_date_ons)
gen stime_firstpos  	= min(testposcensor_date, hcq_first_after_date, died_date_ons , first_positive_test_date)  

* Equivalent to onscoviddeath, but creating a separate variable for clarity 
gen stime_onsnoncoviddeath = min(onscoviddeathcensor_date, hcq_first_after_date, died_date_ons)

* If outcome was after censoring occurred, set to zero
replace onscoviddeath 	= 0 if (died_date_onscovid	> onscoviddeathcensor_date) 
replace onsnoncoviddeath = 0 if (died_date_onsnoncovid > onscoviddeathcensor_date)
replace firstpos 		= 0 if (first_positive_test_date		> testposcensor_date) 

* Format date variables
format  stime* %td 




















 












/* LABEL VARIABLES============================================================*/
*  Label variables you are intending to keep, drop the rest 

* Population
label var rheumatoid_date			"Date of RA"
label var sle						"Date of SLE"


* Demographics
label var patient_id				"Patient ID"
label var age 						"Age (years)"
label var agegroup					"Grouped age"
label var age70 					"70 years and older"
label var sex 						"Sex"
label var male 						"Male"
label var bmi 						"Body Mass Index (BMI, kg/m2)"
label var bmicat 					"Grouped BMI"
label var bmi_measured_date  		"Body Mass Index (BMI, kg/m2), date measured"
label var obese4cat					"Evidence of obesity (4 categories)"
label var smoke		 				"Smoking status"
label var smoke_nomiss	 			"Smoking status (missing set to non)"
label var imd 						"Index of Multiple Deprivation (IMD)"
label var ethnicity					"Ethnicity"
label var stp 						"Sustainability and Transformation Partnership"
label var rural_urban				"Residence type"
label var urban						"Urban residence"

label var age1 						"Age spline 1"
label var age2 						"Age spline 2"
label var age3 						"Age spline 3"

* Treatment variables 

label var hcq						"HCQ"
label var hcq_sa					"HCQ for sensitivity analysis"
label var dmard_pc					"DMARD (PC)"
label var dmard_pc_sa				"DMARD (PC) for sensivity analysis"
label var azith						"Azithromycin"
label var oral_prednisolone			"OCS"
label var chloroquine_not_hcq		"Chloroquine phosphate/sulfate"

label var hcq_date					"Last HCQ Rx"
label var dmard_pc_date				"Last Other DMARD Rx"
label var azith_date				"Last azithromycin Rx"   
label var oral_prednisolone_date	"Last OCS Rx"
label var chloroquine_not_hcq_date	"Last chloroquine phosphate/sulfate Rx"


* Comorbidities of interest 
label var chronic_cardiac_disease 		"Chronic cardiac disease"
label var chronic_liver_disease			"Chronic liver disease"
label var ckd     					 	"Chronic kidney disease" 
label var egfr_cat						"Calculated eGFR"
label var egfr_cat_nomiss				"Calculated eGFR (missing set to norm)"
label var hypertension				    "Diagnosed hypertension"
label var diabetes						"Diabetes"
label var cancer_ever 					"Cancer"
label var immunodef_any					"Immunosuppressed (combination algorithm)"
label var diabcat						"Diabetes Severity"
label var resp_excl_asthma				"Respiratory disease (excl asthma)"
label var current_asthma				"Current asthma"
label var other_neuro_conditions		"Neurological conditions (stroke+dementia)"

label var chronic_cardiac_disease_date	"Date of chronic cardiac disease"
label var chronic_liver_disease_date	"Date of chronic liver disease"
label var ckd_date     				 	"Date of chronic kidney disease" 
label var egfr_date						"Date of eGFR (creatinine)"
label var hypertension_date			    "Date of diagnosed hypertension"
label var diabetes_date					"Date of diabetes"
label var cancer_ever_date 				"Date of cancer"
label var perm_immunodef_date			"Date of permanent immunosuppression"
label var temp_immunodef_date			"Date of temporary immunosuppression"
label var hba1c_mmol_per_mol_date		"Date of HbA1c mmol/mol"
label var hba1c_percentage_date			"Date of HbA1c %"
label var resp_excl_asthma_date			"Date of respiratory disease (excl asthma)"
label var current_asthma_date			"Date of current asthma"
label var other_neuro_conditions_date	"Date of other neurological conditions"

label var flu_vaccine					"Flu vaccine"
label var pneumococcal_vaccine			"Pneumococcal Vaccine"
label var gp_consult					"GP consultation in last year"
label var gp_consult_count				"GP consultation count"



* Outcomes and follow-up
label var enter_date					"Date of study entry"
label var testposcensor_date 			"Date of admin censoring for positive test"
label var onscoviddeathcensor_date 		"Date of admin censoring for ONS deaths"
label var hcq_first_after_date			"Date of censoring for initiating HCQ after baseline"

label var firstpos						"Failure/censoring indicator for outcome: SGSS positive test"
label var onscoviddeath					"Failure/censoring indicator for outcome: ONS covid death"
label var onsnoncoviddeath				"Failure/censoring indicator for outcome: ONS non-covid death"

label var first_positive_test_date		"Date of first SGSS positive test"
label var died_date_ons					"Date of ONS Death"
label var died_date_onscovid 			"Date of ONS COVID Death"
label var died_date_onsnoncovid			"Date of ONS non-COVID death"

* Survival times
label var  stime_firstpos 				"Survival time (date); outcome SGSS positive test"
label var  stime_onscoviddeath 			"Survival time (date); outcome ONS covid death"
label var  stime_onsnoncoviddeath		"Survival tme (date); outcome ONS non covid death"

/* TIDY DATA==================================================================*/
*  Drop variables that are not needed (those not labelled)
ds, not(varlabel)
drop `r(varlist)'
	

* Close log file 
log close


