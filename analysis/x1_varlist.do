
 /*full dates*/
 died_date_ons
 first_positive_test_date
 
 /*month/year*/
 bmi_date_measured
 smoking_status_date
 hypertension
 chronic_cardiac_disease
 chronic_liver_disease
 diabetes
 hba1c_mmol_per_mol_date
 hba1c_percentage_date
 resp_excl_asthma
 other_neuro_conditions
 current_asthma
 oral_presnisolone
 cancer
 creatinine_date
 esrf 
 permanent_immunodeficiency
 temporary_immunodeficiency
 flu_vaccine_tpp_table /*year only*/
 flu_vaccine_med
 flu_vaccine_clinical
 pneumovax_tpp /*year only*/
 pneumovax_med
 pneumovax_clin
   
 /*other vars I have*/
 *set missing to 0
 died_ons_covid_flag_any
 died_ons_covid_flag_underlying
 hydroxychloroquine
 dmards_primary_care
 medicine_exposure
 macrolides
 flu_vaccine
 pneumococcal_vaccine
 gp_consult_count
 
 
 /*make binary out of counts*/
 *2 or more in 4 month window
 hydroxychloroquine
 *any in exposure window
 dmards_primary_care
 medicine_exposure
 macrolides
 gp_consult_count
 
 /*other vars I have*/
 *continuous
 age
 bmi 
 hba1c_mmol_per_mol
 hba1c_percentage
 creatinine
 *categorical
 sex
 stp_oldimd
 msoa
 rural_urban /*i think this is new*/
 smoking_status
 
 
 /*vars from ICS not in HCQ*/
   aplastic_anaemia
   asthma_ever
   copd
   haem_cancer
   heart_failure
   hiv
   ili
   lung_cancer
   other_cancer
   other_heart_disease
   other_respiratory
   insulin
   statin
