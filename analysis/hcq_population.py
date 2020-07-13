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
            """,

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
