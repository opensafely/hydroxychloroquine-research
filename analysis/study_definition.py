  
from cohortextractor import (StudyDefinition, patients, filter_codes_by_category, combine_codelists)

from codelists import *

study = StudyDefinition(
    # Configure the expectations framework
    default_expectations={
        "date": {"earliest": "1900-01-01", "latest": "today"},
        "rate": "uniform",
        "incidence": 0.1,
    },
    

# STUDY POPULATION


    # This line defines the study population
    population=patients.satisfying(
            """
            has_follow_up AND
            (age >=18 AND age <= 110) AND
            (sex = "M" OR sex = "F") AND
            imd > 0 AND
            (rheumatoid OR sle) AND NOT
            chloroquine_not_hcq
            """,
            has_follow_up=patients.registered_with_one_practice_between(
            "2019-02-28", "2020-02-29"         
        ),

    ),

    #OUTCOMES
     died_ons_covid_flag_any=patients.with_these_codes_on_death_certificate(
        covid_identification,
        on_or_after="2020-03-01",
        match_only_underlying_cause=False,
        return_expectations={"date": {"earliest": "2020-03-01"}},
    ),
    died_ons_covid_flag_underlying=patients.with_these_codes_on_death_certificate(
        covid_identification,
        on_or_after="2020-03-01",
        match_only_underlying_cause=True,
        return_expectations={"date": {"earliest": "2020-03-01"}},
    ),
    died_date_ons=patients.died_from_any_cause(
        on_or_after="2020-03-01",
        returning="date_of_death",
        include_month=True,
        include_day=True,
        return_expectations={"date": {"earliest": "2020-03-01"}},
    ),
    # SECONDARY OUTCOME:testing +ve for covid
        first_positive_test_date=patients.with_test_result_in_sgss(
        pathogen="SARS-CoV-2",
        test_result="positive",
        find_first_match_in_period=True,
        returning="date",
        date_format="YYYY-MM-DD",
        return_expectations={"date": {"earliest": "2020-03-01"}},
    ),

    # MEDICATIONS EXPOSURES

    #HYDROXYCHLOROQUINE 
    hcq_count=patients.with_these_medications(
        hcq_med_codes, 
        between=["2019-09-01", "2020-02-29"],
        returning="number_of_matches_in_period",
        return_expectations={
            "int": {"distribution": "normal", "mean": 3, "stddev": 2},
            "incidence": 0.30,
        },
    ),

     hcq_last_date=patients.with_these_medications(
        hcq_med_codes, 
        between=["2019-09-01", "2020-02-29"], 
        return_last_date_in_period=True,
        include_month=True,
        return_expectations={
            "date": {"earliest": "2019-09-01", "latest": "2020-02-29"}
        },
    ),

    hcq_first_after=patients.with_these_medications(
        hcq_med_codes, 
        on_or_after="2020-03-01",
        return_first_date_in_period=True,
        include_month=True,
        include_day=True,
        return_expectations={
            "date": {"earliest": "2020-03-01", "latest": "today"}
        },
    ),

    # DMARDS EXPOSURE (PRIMARY CARE) 
    dmards_primary_care_count=patients.with_these_medications(
        dmards_med_codes,
        between=["2019-09-01", "2020-02-29"],
        returning="number_of_matches_in_period",
        return_expectations={
            "int": {"distribution": "normal", "mean": 3, "stddev": 2},
            "incidence": 0.1,
        },
    ),

    dmards_primary_care_exposure=patients.with_these_medications(
        dmards_med_codes,
        between=["2019-09-01", "2020-02-29"], 
        return_last_date_in_period=True,
        include_month=True,
        return_expectations={
            "date": {"earliest": "2019-09-01", "latest": "2020-02-29"}
        },
    ),

    
    #MACROLIDES EXPOSURE PLACEHOLDER -  - https://github.com/opensafely/hydroxychloroquine-research/issues/4
    azith_count=patients.with_these_medications(
        azithromycin_med_codes,
        between=["2020-01-31", "2020-02-29"],
        returning="number_of_matches_in_period",
        return_expectations={
            "int": {"distribution": "normal", "mean": 2, "stddev": 2},
            "incidence": 0.25,
        },
    ),

    azith_last_date=patients.with_these_medications(
        azithromycin_med_codes, 
        between=["2020-01-31", "2020-02-29"], 
        return_last_date_in_period=True,
        include_month=True,
        return_expectations={
            "date": {"earliest": "2020-01-31", "latest": "2020-02-29"}
        },
    ),

    #CHLORUQUINE THAT ISN'T HCQ
    chloroquine_not_hcq=patients.with_these_medications(
        chloroquine_med_codes,
        between=["2019-09-01", "2020-02-29"],
        return_last_date_in_period=True,
        include_month=True,
            return_expectations={
            "date": {"earliest": "2019-09-01", "latest": "2020-02-29"}
        },
    ),

    #NSAIDs
	nsaids=patients.with_these_medications(
        nsaid_codes,
        between=["2019-09-01", "2020-02-29"],
        return_last_date_in_period=True,
        include_month=True,
        return_expectations={
            "date": {"earliest": "2019-09-01", "latest": "2020-02-29"}
        },
    ),
    # DMARDS EXPOSURE (SECONDARYCARE) - THIS IS A PLACEHOLDR FOR EXPECTED DATA - IT WILL BE QUEIRED IN DIFFERENT WAY (PROBABLY) TO OTHER MEDS




    # The rest of the lines define the covariates with associated GitHub issues
    # https://github.com/ebmdatalab/tpp-sql-notebook/issues/33
    age=patients.age_as_of(
        "2020-03-01",
        return_expectations={
            "rate": "universal",
            "int": {"distribution": "population_ages"},
        },
    ),
    # https://github.com/ebmdatalab/tpp-sql-notebook/issues/46
    sex=patients.sex(
        return_expectations={
            "rate": "universal",
            "category": {"ratios": {"M": 0.49, "F": 0.51}},
        }
    ),

        stp=patients.registered_practice_as_of(
            "2020-02-29",
            returning="stp_code",
            return_expectations={
                "rate": "universal",
                "category": {
                    "ratios": {
                        "STP1": 0.1,
                        "STP2": 0.1,
                        "STP3": 0.1,
                        "STP4": 0.1,
                        "STP5": 0.1,
                        "STP6": 0.1,
                        "STP7": 0.1,
                        "STP8": 0.1,
                        "STP9": 0.1,
                        "STP10": 0.1,
                    }
                },
            },
    ),

        ethnicity=patients.with_these_clinical_events(
        ethnicity_codes,
        returning="category",
        find_last_match_in_period=True,
        include_date_of_match=True,
        return_expectations={
            "category": {"ratios": {"1": 0.8, "5": 0.1, "3": 0.1}},
            "incidence": 0.75,
        },
    ),

    imd=patients.address_as_of(
        "2020-02-29",
        returning="index_of_multiple_deprivation",
        round_to_nearest=100,
        return_expectations={
            "rate": "universal",
            "category": {"ratios": {"100": 0.1, "200": 0.2, "300": 0.7}},
        },
    ),

    msoa=patients.registered_practice_as_of(
        "2020-02-01",
        returning="msoa_code",
        return_expectations={
            "rate": "universal",
            "category": {"ratios": {"MSOA1": 0.5, "MSOA2": 0.5}},
        },
    ),

    residence_type=patients.address_as_of(
        "2020-02-01",
        returning="rural_urban_classification",
        return_expectations={
            "rate": "universal",
            "category": {"ratios": {"1": 0.25, "2": 0.25, "7": 0.25, "8": 0.25}},
        },
    ),

    ##SHIELDING STATUS PLACEHOLDER

    ##RHEUMATOLOGY OUTPATENT VISITS - HES - PLACEHOLDER

    #CLINICAL COVARIATES
    #BMI
    bmi=patients.most_recent_bmi(
        on_or_after="2010-02-01",
        minimum_age_at_measurement=16,
        include_measurement_date=True,
        include_month=True,
        return_expectations={
            "date": {},
            "incidence": 0.6,
            "float": {"distribution": "normal", "mean": 35, "stddev": 10},
        },
    ),
    #SMOKING
    smoking_status=patients.categorised_as(
        {
            "S": "most_recent_smoking_code = 'S'",
            "E": """
                     most_recent_smoking_code = 'E' OR (    
                       most_recent_smoking_code = 'N' AND ever_smoked   
                     )  
                """,
            "N": "most_recent_smoking_code = 'N' AND NOT ever_smoked",
            "M": "DEFAULT",
        },
        return_expectations={
            "category": {"ratios": {"S": 0.6, "E": 0.1, "N": 0.2, "M": 0.1}}
        },
        most_recent_smoking_code=patients.with_these_clinical_events(
            clear_smoking_codes,
            find_last_match_in_period=True,
            on_or_before="2020-02-29",
            returning="category",
        ),
        ever_smoked=patients.with_these_clinical_events(
            filter_codes_by_category(clear_smoking_codes, include=["S", "E"]),
            on_or_before="2020-02-29",
        ),
    ),
    smoking_status_date=patients.with_these_clinical_events(
        clear_smoking_codes,
        on_or_before="2020-02-29",
        return_last_date_in_period=True,
        include_month=True,
        return_expectations={"date": {"latest": "2020-02-29"}},
    ),


    #HYPERTENSION - CLINICAL CODES ONLY
    hypertension=patients.with_these_clinical_events(
        hypertension_codes,
        on_or_before="2020-02-29",
        return_first_date_in_period=True,
        include_month=True,
        return_expectations={"date": {"latest": "2020-02-29"}},
    ),

    chronic_cardiac_disease=patients.with_these_clinical_events(
        chronic_cardiac_disease_codes,
        on_or_before="2020-02-29",
        return_first_date_in_period=True,
        include_month=True,
        return_expectations={"date": {"latest": "2020-02-29"}},
    ),

    chronic_liver_disease=patients.with_these_clinical_events(
        chronic_liver_disease_codes,
        on_or_before="2020-02-29",
        return_first_date_in_period=True,
        include_month=True,
        return_expectations={"date": {"latest": "2020-02-29"}},
    ),

    diabetes=patients.with_these_clinical_events( 
        diabetes_codes,
        on_or_before="2020-02-29",
        return_first_date_in_period=True,
        include_month=True,
        return_expectations={"date": {"latest": "2020-02-29"}},
    ),

       hba1c_mmol_per_mol=patients.with_these_clinical_events(
        hba1c_new_codes,
        find_last_match_in_period=True,
        on_or_before="2020-02-29",
        returning="numeric_value",
        include_date_of_match=True,
        include_month=True,
        return_expectations={
            "date": {"latest": "2020-02-29"},
            "float": {"distribution": "normal", "mean": 40.0, "stddev": 20},
            "incidence": 0.95,
        },
    ),

    hba1c_percentage=patients.with_these_clinical_events(
        hba1c_old_codes,
        find_last_match_in_period=True,
        on_or_before="2020-02-29",
        returning="numeric_value",
        include_date_of_match=True,
        include_month=True,
        return_expectations={
            "date": {"latest": "2020-02-29"},
            "float": {"distribution": "normal", "mean": 5, "stddev": 2},
            "incidence": 0.95,
        },
    ),

    #CHRONIC RESPIRATORY DISEASES - EXCL ASTHMA
    chronic_respiratory_excl_asthma=patients.with_these_clinical_events(
        chronic_respiratory_disease_codes,
        on_or_before="2020-02-29",
        return_first_date_in_period=True,
        include_month=True,
        return_expectations={"date": {"latest": "2020-02-29"}},
    ),

    #NEUROLOGICAL DISEASE PLACEHOLDER
    other_neuro_conditions=patients.with_these_clinical_events(
        other_neuro_codes,
        on_or_before="2020-02-29",
        return_first_date_in_period=True,
        include_month=True,
        return_expectations={"date": {"latest": "2020-02-29"}},
    ),

    #CURRENT ASTHMA - confirm if this or ever asthma
    current_asthma=patients.with_these_clinical_events(
        current_asthma_codes,
        on_or_before="2020-02-29",
        return_first_date_in_period=True,
        include_month=True,
        return_expectations={"date": {"latest": "2020-02-29"}},
    ),

    #oral pred / current medication tbc
    oral_prednisolone_exposure=patients.with_these_medications(
        oral_pred_codes,
        between=["2019-09-01", "2020-02-29"],
        return_last_date_in_period=True,
        include_month=True,
        return_expectations={
            "date": {"earliest": "2019-09-01", "latest": "2020-02-29"},
        },
    ),

    oral_prednisolone_count=patients.with_these_medications(
        oral_pred_codes,
        between=["2019-09-01", "2020-02-29"],
        returning="number_of_matches_in_period",
        return_expectations={
            "int": {"distribution": "normal", "mean": 3, "stddev": 2},
            "incidence": 0.1,
        },
    ),


    #CANCER - 3 TYPES
    cancer=patients.with_these_clinical_events(
        combine_codelists(lung_cancer_codes, haem_cancer_codes, other_cancer_codes),
        on_or_before="2020-02-29",
        return_first_date_in_period=True,
        include_month=True,
        return_expectations={"date": {"latest": "2020-02-29"}},
    ),

    #Rheumatoid Arthritis 
    rheumatoid=patients.with_these_clinical_events(
        rheumatoid_codes,
        on_or_before="2019-08-31",
        return_first_date_in_period=True,
        include_month=True,
        return_expectations={"date": {"latest": "2020-02-29"}},
    ),

    #SLE
    sle=patients.with_these_clinical_events(
        sle_codes,
        on_or_before="2019-08-31",
        return_first_date_in_period=True,
        include_month=True,
        return_expectations={"date": {"latest": "2020-02-29"}},
    ),

    #CKD
    creatinine=patients.with_these_clinical_events(
        creatinine_codes,
        find_last_match_in_period=True,
        between=["2019-02-28", "2020-02-29"],
        returning="numeric_value",
        include_date_of_match=True,
        include_month=True,
        return_expectations={
            "float": {"distribution": "normal", "mean": 150.0, "stddev": 200.0},
            "date": {"earliest": "2019-02-28", "latest": "2020-02-29"},
            "incidence": 0.95,
        },
    ),

    #### end stage renal disease codes incl. dialysis / transplant 
    esrf=patients.with_these_clinical_events(
        ckd_codes,  #CHECK IS THIS DEF RIGHT HERE
        on_or_before="2020-02-29",
        return_last_date_in_period=True,
        include_month=True,
        return_expectations={"date": {"latest": "2020-02-29"}},
    ),

    #IMMUNOSUPPRESSION
    #### PERMANENT
    permanent_immunodeficiency=patients.with_these_clinical_events(
        combine_codelists(aplastic_codes,
                          hiv_codes,
                          permanent_immune_codes,
                          sickle_cell_codes,
                          organ_transplant_codes,
                          spleen_codes)
        ,
        on_or_before="2020-02-29",
        return_last_date_in_period=True,
        include_month=True,
        return_expectations={"date": {"latest": "2020-02-29"}},
    ),

    #### TEMPORARY
    temporary_immunodeficiency=patients.with_these_clinical_events(
        temp_immune_codes,
        between=["2019-03-01", "2020-02-29"],
        return_last_date_in_period=True,
        include_month=True,
        return_expectations={
            "date": {"earliest": "2019-03-01", "latest": "2020-02-29"}
        },
    ),
  
    #FLU VACCINATION STATUS
    flu_vaccine_tpp_table=patients.with_tpp_vaccination_record(
        target_disease_matches="INFLUENZA",
        between=["2019-09-01", "2020-02-29"],  # current flu season
        find_first_match_in_period=True,
        returning="date",
        return_expectations={
            "date": {"earliest": "2019-09-01", "latest": "2020-02-29"}
        },
    ),
    flu_vaccine_med=patients.with_these_medications(
        flu_med_codes,
        between=["2019-09-01", "2020-02-29"],  # current flu season
        return_first_date_in_period=True,
        include_month=True,
        return_expectations={
            "date": {"earliest": "2019-09-01", "latest": "2020-02-29"}
        },
    ),
    flu_vaccine_clinical=patients.with_these_clinical_events(
        flu_clinical_given_codes,
        ignore_days_where_these_codes_occur=flu_clinical_not_given_codes,
        between=["2019-09-01", "2020-02-29"],  # current flu season
        return_first_date_in_period=True,
        include_month=True,
        return_expectations={
            "date": {"earliest": "2019-09-01", "latest": "2020-02-29"}
        },
    ),
    flu_vaccine=patients.satisfying(
        """
        flu_vaccine_tpp_table OR
        flu_vaccine_med OR
        flu_vaccine_clinical
        """,
    ),

    #PNEUMOCOCCAL VACCINATION STATUS
    pneumococcal_vaccine_tpp_table=patients.with_tpp_vaccination_record(
        target_disease_matches="PNEUMOCOCCAL",
        between=["2015-03-01", "2020-02-29"],
        find_first_match_in_period=True,
        returning="date",
        return_expectations={
            "date": {"earliest": "2015-03-01", "latest": "2020-02-29"}
        },
    ),
    pneumococcal_vaccine_med=patients.with_these_medications(
        pneumococcal_med_codes,
        between=["2015-03-01", "2020-02-29"],  # past five years
        return_first_date_in_period=True,
        include_month=True,
        return_expectations={
            "date": {"earliest": "2015-03-01", "latest": "2020-02-29"}
        },
    ),
    pneumococcal_vaccine_clinical=patients.with_these_clinical_events(
        pneumococcal_clinical_given_codes,
        ignore_days_where_these_codes_occur=pneumococcal_clinical_not_given_codes,
        between=["2015-03-01", "2020-02-29"],  # past five years
        return_first_date_in_period=True,
        include_month=True,
        return_expectations={
            "date": {"earliest": "2015-03-01", "latest": "2020-02-29"}
        },
    ),
    pneumococcal_vaccine=patients.satisfying(
        """
        pneumococcal_vaccine_tpp_table OR
        pneumococcal_vaccine_med OR
        pneumococcal_vaccine_clinical
        """,
    ),


    ### GP CONSULTATION RATE
    gp_consult_count=patients.with_gp_consultations(
        between=["2019-03-01", "2020-02-29"],
        returning="number_of_matches_in_period",
        return_expectations={
            "int": {"distribution": "normal", "mean": 4, "stddev": 2},
            "date": {"earliest": "2019-03-01", "latest": "2020-02-29"},
            "incidence": 0.7,
        },
    ),
    has_consultation_history=patients.with_complete_gp_consultation_history_between(
        "2019-03-01", "2020-02-29", return_expectations={"incidence": 0.9},
    ),


)




 
