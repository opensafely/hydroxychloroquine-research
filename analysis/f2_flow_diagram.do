/*==============================================================================
DO FILE NAME:			f2_flow_diagram
PROJECT:				HCQ in COVID-19 
DATE: 					3 August 2020 
AUTHOR:					C Rentsch
DESCRIPTION OF FILE:	generate numbers for flow diagram 
DATASETS USED:			separate study definition input ($Outdir/input_flow_chart.csv)

DATASETS CREATED: 		none
OTHER OUTPUT: 			logfiles, printed to folder $Logdir
USER-INSTALLED ADO: 	 
  (place .ado file(s) in analysis folder)								
==============================================================================*/

* Open a log file

cap log close
log using $Logdir\f2_flow_diagram, replace t

cd ..
import delimited `c(pwd)'/output/input_flow_chart.csv, clear

/*
has_follow_up AND
(age >=18 AND age <= 110) AND
(sex = "M" OR sex = "F") AND
imd > 0 AND
(rheumatoid OR sle) AND NOT
chloroquine_not_hcq
*/

*assess variables
codebook has_follow_up age sex imd rheumatoid sle chloroquine_not_hcq ethnicity
count
drop if has_follow_up!=1
count
drop if age < 18 | age > 110
count
drop if sex != "M" & sex != "F"
count
drop if imd==.
count
drop if rheumatoid=="" & sle==""
count
drop if chloroquine_not_hcq != ""
count




* For sensitivity analyses, missing ethnicity
tab ethnicity, m
drop if ethnicity == .
count


log close