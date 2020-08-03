  
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
    population=patients.all(),

    #population=patients.satisfying(
    #        """
    #        has_follow_up AND
    #        (age >=18 AND age <= 110) AND
    #        (sex = "M" OR sex = "F") AND
    #        imd > 0 AND
    #        (rheumatoid OR sle) AND NOT
    #        chloroquine_not_hcq
    #        """,
    #        has_follow_up=patients.registered_with_one_practice_between(
    #        "2019-02-28", "2020-02-29"         
    #    ),

    #),

	has_follow_up=patients.registered_with_one_practice_between(
        "2019-02-28", "2020-02-29", return_expectations={"incidence": 0.9},         
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

)
