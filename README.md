# Effect of pre-exposure use of hydroxychloroquine on COVID-19 mortality: a population-based cohort study in patients with rheumatoid arthritis or systemic lupus erythematosus using the OpenSAFELY platform

This is the repository for the code and configuration for our [paper on hydroxychloroquine published in the Lancet Rheumatology](https://doi.org/10.1016/S2665-9913(20)30378-7).


* If you are interested in how we defined our variables, take a look at the [study definition](analysis/study_definition.py); this is written in `python`, but non-programmers should be able to understand what is going on there.
* If you are interested in how we defined our code lists, look in the [codelists folder](./codelists/). A new tool called [OpenSafely OpenCodelists](https://codelists.opensafely.org/) was developed to allow codelists to be versioned and all of the codelists hosted online at [codelists.opensafely.org](https://codelists.opensafely.org/) for open inspection and re-use by anyone.
* Developers and epidemiologists interested in the code should review our [OpenSAFELY documentation](https://docs.opensafely.org/en/latest/).


# About the OpenSAFELY framework

The OpenSAFELY framework is a new secure analytics platform for
electronic health records research in the NHS.

Instead of requesting access for slices of patient data and
transporting them elsewhere for analysis, the framework supports
developing analytics against dummy data, and then running against the
real data *within the same infrastructure that the data is stored*.


The framework is under fast, active development to support rapid
analytics relating to COVID19; we're currently seeking funding to make
it easier for outside collaborators to work with our system.  

Read more at [OpenSAFELY.org](https://opensafely.org).
