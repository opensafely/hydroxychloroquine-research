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
            imd > 0 
            """,
            has_follow_up=patients.registered_with_one_practice_between(
            "2019-02-28", "2020-02-29"         
        ),

    ),

    #HYDROXYCHLOROQUINE Population
    hcq_count=patients.with_these_medications(
        hcq_med_codes, 
        between=["2019-09-01", "2020-02-29"],
        returning="number_of_matches_in_period",
        return_expectations={
            "int": {"distribution": "normal", "mean": 3, "stddev": 2},
            "incidence": 0.30,
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

    imd=patients.address_as_of(
        "2020-02-29",
        returning="index_of_multiple_deprivation",
        round_to_nearest=100,
        return_expectations={
            "rate": "universal",
            "category": {"ratios": {"100": 0.1, "200": 0.2, "300": 0.7}},
        },
    ),
)
